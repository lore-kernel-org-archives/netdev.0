From: David Miller <davem@davemloft.net>
Subject: Re: skb_try_coalesce bug?
Date: Wed, 23 Apr 2014 13:33:49 -0400 (EDT)
Message-ID: <20140423.133349.1007553448019102626.davem@davemloft.net>
References: <1398202178.29946.62.camel@edumazet-glaptop2.roam.corp.google.com>
	<1398202653.29946.63.camel@edumazet-glaptop2.roam.corp.google.com>
	<5357F0B4.5040606@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, erik.hugne@ericsson.com,
	netdev@vger.kernel.org
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50213 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752302AbaDWRdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 13:33:51 -0400
In-Reply-To: <5357F0B4.5040606@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Wed, 23 Apr 2014 12:56:20 -0400

> On 04/22/2014 05:37 PM, Eric Dumazet wrote:
>> On Tue, 2014-04-22 at 14:29 -0700, Eric Dumazet wrote:
>> 
>>> Then if you do that, you also need to change head->data_len !
>> 
>> Untested patch would be :
>> 
>> diff --git a/net/tipc/link.c b/net/tipc/link.c
>> index c5190ab75290..85077dd7c63e 100644
>> --- a/net/tipc/link.c
>> +++ b/net/tipc/link.c
>> @@ -2349,6 +2349,7 @@ int tipc_link_frag_rcv(struct sk_buff **head, struct sk_buff **tail,
>>  			(*tail)->next = frag;
>>  		*tail = frag;
>>  		(*head)->truesize += frag->truesize;
>> +		(*head)->data_len += frag->len;
> 
> Just to confirm, does this mean that head's own (linear) data is not
> included in data_len? 

For a given SKB, skb->len is the entire length of the packet, fragments and
all.

skb->data_len counts the sum of all of the page and SKB based fragments, ie.
all bytes which are not in the top-level SKBs linear area.

So the linear length is always "skb->len - skb->data_len", and this is exactly
what skb_headlen() does.
