From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/2] net: bridge: change unicast boolean to exact
 pkt_type
Date: Tue, 30 Aug 2016 17:00:41 +0200
Message-ID: <1344bd99-cc38-2dda-4875-337796892685@cumulusnetworks.com>
References: <1472562539-23247-1-git-send-email-nikolay@cumulusnetworks.com>
 <1472562539-23247-2-git-send-email-nikolay@cumulusnetworks.com>
 <20160830075953.739291e1@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        sashok@cumulusnetworks.com, bridge@lists.linux-foundation.org,
        davem@davemloft.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:33682 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753135AbcH3PAt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 11:00:49 -0400
Received: by mail-lf0-f47.google.com with SMTP id b199so15912954lfe.0
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 08:00:48 -0700 (PDT)
In-Reply-To: <20160830075953.739291e1@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/08/16 16:59, Stephen Hemminger wrote:
> On Tue, 30 Aug 2016 15:08:58 +0200
> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
> 
>> -	if (!is_broadcast_ether_addr(dest) && is_multicast_ether_addr(dest) &&
>> -	    br_multicast_rcv(br, p, skb, vid))
>> -		goto drop;
>> +	local_rcv = !!(br->dev->flags & IFF_PROMISC);
> local_rcv is needlessly initialized in existing code. Pls remove that.
> 

Please check again, I did remove it in this patch.

>> +	if (is_multicast_ether_addr(dest)) {
>> +		/* by definition the broadcast is also a multicast address */
>> +		if (is_broadcast_ether_addr(dest)) {
>> +			pkt_type = BR_PKT_BROADCAST;
>> +			local_rcv = true;
>> +		} else {
>> +			pkt_type = BR_PKT_MULTICAST;
>> +			if (br_multicast_rcv(br, p, skb, vid))
>> +				goto drop;
>> +		}
>> +	}
>>
> 
> 
> These could go after the BR_STATE_LEARNING check

They can't because of br_multicast_rcv().

> 
>>  	if (p->state == BR_STATE_LEARNING)
>>  		goto drop;
>>  
>>  	BR_INPUT_SKB_CB(skb)->brdev = br->dev;
>>  
>> -	local_rcv = !!(br->dev->flags & IFF_PROMISC);
>> -
>>  	if (IS_ENABLED(CONFIG_INET) && skb->protocol == htons(ETH_P_ARP))
>>  		br_do_proxy_arp(skb, br, vid, p);
>>
> 
> can't proxy_arp change what was a broadcast packet into a unicast packet?
> 
