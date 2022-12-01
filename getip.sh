#!/bin/bash
# Generate time range 1 days ago until now
SINCE=$(date --date='1 days ago' +%s)
UNTIL=$(date +%s)
## Telegram TOKEN
GROUP_ID=
BOT_TOKEN=
## Generate API token
TOKEN=$(curl -s -d '{"username":"USERNAMEHERE", "password":"PASSWORDHERE", "realm":"intel"}' https://api.spamhaus.org/api/v1/login | jq .token | tr -d '"')
FILE=reports-$(date +%d%m%y-%H%M%S).csv
echo "Node,IP,Status" >> $FILE
## Iterate requests
cat list-ip | while IFS=',' read node ip; do
    echo "$node";
    echo "$ip";
    CODE=$(curl -s "https://api.spamhaus.org/api/intel/v1/byobject/cidr/ALL/listed/live/$ip?limit=1&since=$SINCE&until=$UNTIL" -H "Authorization: Bearer $TOKEN" | jq .code);
    if [[ "$CODE" == *200* ]]; 
      then
        echo "IP Blocked"
        curl -s --data "text=$node ($ip) is Blocked" --data "chat_id=$GROUP_ID" https://api.telegram.org/bot$BOT_TOKEN/sendMessage > /dev/null
      else
        echo "IP Clean"
    fi
# Generate CSV
done | paste -d ',' - - - >> $FILE