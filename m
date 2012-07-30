From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv4: fix RCU races on dst refcounts
Date: Mon, 30 Jul 2012 14:56:37 -0700 (PDT)
Message-ID: <20120730.145637.906924670032055493.davem@davemloft.net>
References: <1343640037.21269.15.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58915 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754715Ab2G3V4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 17:56:40 -0400
In-Reply-To: <1343640037.21269.15.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 30 Jul 2012 11:20:37 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> commit c6cffba4ffa2 (ipv4: Fix input route performance regression.)
> added various fatal races with dst refcounts.
> 
> crashes happen on tcp workloads if routes are added/deleted at the same
> time.
> 
> The dst_free() calls from free_fib_info_rcu() are clearly racy.
> 
> We need instead regular dst refcounting (dst_release()) and make
> sure dst_release() is aware of RCU grace periods :
> 
> Add DST_RCU_FREE flag so that dst_release() respects an RCU grace period
> before dst destruction for cached dst
> 
> Introduce a new inet_sk_rx_dst_set() helper, using atomic_inc_not_zero()
> to make sure we dont increase a zero refcount (On a dst currently
> waiting an rcu grace period before destruction)
> 
> rt_cache_route() must take a reference on the new cached route, and
> release it if was not able to install it.
> 
> With this patch, my machines survive various benchmarks.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

I'm applying this patch, however:

> +static inline void inet_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb)
> +{
> +	struct dst_entry *dst = skb_dst(skb);
> +
> +	if (atomic_inc_not_zero(&dst->__refcnt)) {
> +		if (!(dst->flags & DST_RCU_FREE))
> +			dst->flags |= DST_RCU_FREE;
> +
> +		sk->sk_rx_dst = dst;
> +		inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
> +	}
> +}

This is not safe.

We cannot allow clients outside of the DST providers make non-atomic
changes to the dst attributes, as you are here with this dst->flags
modification.

Make this "needs RCU liberation" indication at the spot where we get
rid of sk->sk_rx_dst, make a dst_release_rcu() or somthing like that.
