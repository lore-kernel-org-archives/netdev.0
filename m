From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] ipv4: Update pmtu informations on inetpeer only
 for output routes
Date: Tue, 08 Nov 2011 14:36:30 -0500 (EST)
Message-ID: <20111108.143630.106539981030509701.davem@davemloft.net>
References: <20111011110842.GC1830@secunet.com>
	<20111011111027.GE1830@secunet.com>
	<20111012.170805.2172804476308993385.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41727 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753215Ab1KHTge (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 14:36:34 -0500
In-Reply-To: <20111012.170805.2172804476308993385.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 12 Oct 2011 17:08:05 -0400 (EDT)

> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Tue, 11 Oct 2011 13:10:27 +0200
> 
>> @@ -1817,9 +1819,14 @@ static void rt_init_metrics(struct rtable *rt, const struct flowi4 *fl4,
>>  		if (inet_metrics_new(peer))
>>  			memcpy(peer->metrics, fi->fib_metrics,
>>  			       sizeof(u32) * RTAX_MAX);
>> -		dst_init_metrics(&rt->dst, peer->metrics, false);
>>  
>> -		check_peer_pmtu(&rt->dst, peer);
>> +		dst_init_metrics(dst, peer->metrics, false);
>> +		check_peer_pmtu(dst, peer);
>> +
>> +		if (rt_is_input_route(rt))
>> +			dst_metric_set(dst, RTAX_MTU,
>> +				       dst->ops->default_mtu(dst));
>> +
> 
> You really can't do this, it's going to kill all of the memory savings from
> storing metrics in the inetpeer cache.
> 
> Every input route is going to have it's metrics COW'd with this change.
> 
> The whole idea is to use defaults as heavily as possible, and that's
> the entire reason why the dst->ops->default_mtu() method exists, so
> that we can just leave the values alone and have read-only copies %99
> of the time.
> 
> Please rearrange your fix so that these goals are still achieved.

What I think you can do to solve this problem is explicitly use
dst->ops->default_mtu() in ip_forward() instead of dst_mtu().

That way you won't use the cached PMTU for input routes.
