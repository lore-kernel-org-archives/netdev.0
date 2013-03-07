From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] udp: don't rereference dst_entry dev pointer on rcv
Date: Thu, 07 Mar 2013 18:15:27 -0500 (EST)
Message-ID: <20130307.181527.390191009324148471.davem@davemloft.net>
References: <1362695800-8633-1-git-send-email-tparkin@katalix.com>
	<1362695800-8633-2-git-send-email-tparkin@katalix.com>
	<1362696444.15793.220.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tparkin@katalix.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47263 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754282Ab3CGXPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 18:15:30 -0500
In-Reply-To: <1362696444.15793.220.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 07 Mar 2013 14:47:24 -0800

> On Thu, 2013-03-07 at 22:36 +0000, Tom Parkin wrote:
>> When a fragmented IP packet is queued during device teardown, it is possible
>> for the reassembled packet to hit the UDP rcv path with a NULL dst_entry dev
>> pointer.  Drop such packets to prevent an oops.
>> ---
>>  net/ipv4/udp.c |    3 +++
>>  1 file changed, 3 insertions(+)
>> 
>> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
>> index 0a073a2..c38a4b1 100644
>> --- a/net/ipv4/udp.c
>> +++ b/net/ipv4/udp.c
>> @@ -1700,6 +1700,9 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
>>  		return __udp4_lib_mcast_deliver(net, skb, uh,
>>  				saddr, daddr, udptable);
>>  
>> +	if (skb_dst(skb)->dev == NULL)
>> +		goto drop;
>> +
>>  	sk = __udp4_lib_lookup_skb(skb, uh->source, uh->dest, udptable);
>>  
>>  	if (sk != NULL) {
> 
> 
> Hmm... couldnt it be tested in reassembly layer instead ?
> 
> Why is it specific to UDP ?

Furthermore, when devices are unregistered we set the route's device
pointer to point to the loopback device, not NULL, exactly to avoid
this kind of problem.

I don't see anything in our generic DST handler nor the ipv4 specific
route handling, that would set dst->dev to NULL.

You really have to show us how this can actually happen.
