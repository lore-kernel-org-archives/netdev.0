From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net 1/2] net: bcmgenet: fix dev->stats.tx_bytes accounting
Date: Wed, 23 Mar 2016 14:47:45 -0700
Message-ID: <C2A46484-4AE6-418C-A4F4-760C3A4DC368@gmail.com>
References: <1458763289-95167-1-git-send-email-pgynther@google.com> <1458768237.10868.46.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jaedon.shin@gmail.com,
	edumazet@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Petri Gynther <pgynther@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36750 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750886AbcCWVr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 17:47:57 -0400
Received: by mail-pa0-f54.google.com with SMTP id tt10so5175469pab.3
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 14:47:57 -0700 (PDT)
In-Reply-To: <1458768237.10868.46.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On March 23, 2016 2:23:57 PM PDT, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>On Wed, 2016-03-23 at 13:01 -0700, Petri Gynther wrote:
>> 1. Add bytes_compl local variable to collect transmitted bytes
>>    - dev->stats updates can then be moved outside the while-loop
>>    - bytes_compl is also needed for future BQL support
>> 2. When bcmgenet device uses Tx checksum offload, each transmitted
>>    skb has an extra 64-byte header prepended to it. This needs to
>>    be deducted when counting transmitted bytes.
>> 3. skb->len covers the entire length of skb, whether it is linear or
>>    fragmented. Thus, when we clean the fragments, do not increase
>>    transmitted bytes.
>> 
>> Signed-off-by: Petri Gynther <pgynther@google.com>
>> ---
>>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 10 ++++++----
>>  1 file changed, 6 insertions(+), 4 deletions(-)
>> 
>> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>> index 6746fd0..9990582 100644
>> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
>> @@ -1171,6 +1171,7 @@ static unsigned int
>__bcmgenet_tx_reclaim(struct net_device *dev,
>>  	struct enet_cb *tx_cb_ptr;
>>  	struct netdev_queue *txq;
>>  	unsigned int pkts_compl = 0;
>> +	unsigned int bytes_compl = 0;
>>  	unsigned int c_index;
>>  	unsigned int txbds_ready;
>>  	unsigned int txbds_processed = 0;
>> @@ -1193,16 +1194,14 @@ static unsigned int
>__bcmgenet_tx_reclaim(struct net_device *dev,
>>  		tx_cb_ptr = &priv->tx_cbs[ring->clean_ptr];
>>  		if (tx_cb_ptr->skb) {
>>  			pkts_compl++;
>> -			dev->stats.tx_packets++;
>> -			dev->stats.tx_bytes += tx_cb_ptr->skb->len;
>> +			bytes_compl += tx_cb_ptr->skb->len -
>> +				       (priv->desc_64b_en ? 64 : 0);
>
>Please do not use this 64 scalar, prefer sizeof(struct status_64)
>
>I know this driver uses skb_pull(skb, 64); len -= 64; in
>bcmgenet_desc_rx(), but I would prefer not adding magic values.

Agreed, and just so we are more robust and ready to add BQL in the features please store this information in skb->cb, in the same spirit as what this does:

https://github.com/ffainelli/linux/commits/genet-bql

Thanks.

-- 
Florian
