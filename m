From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC Patch net-next] ipv6: look up neighbours on demand in
 ip6_finish_output2()
Date: Mon, 14 Jan 2013 08:29:30 -0800
Message-ID: <1358180970.8744.3016.camel@edumazet-glaptop>
References: <1358170515-1383-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roland Dreier <roland@purestorage.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:53197 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756778Ab3ANQ3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 11:29:33 -0500
Received: by mail-pa0-f41.google.com with SMTP id bj3so2330428pad.28
        for <netdev@vger.kernel.org>; Mon, 14 Jan 2013 08:29:33 -0800 (PST)
In-Reply-To: <1358170515-1383-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-01-14 at 21:35 +0800, Cong Wang wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> 
> Roland reported that we may use a "stray" neigh entry if someone else
> holds a refcount of this entry. Therefore leads to neigh_blackhole().
> 
> And David said:
> 
> "Another reason we must make ipv6 like ipv4, which looks up neighbours
> on demand at packet output time rather than caching them in the route
> entries."

Not sure why you quoted this, as your patch doesn't do that.

(Its rt6_bind_neighbour() part)

> 
> Thus, we just follow what IPv4 does, call __ipv6_neigh_lookup_noref()
> to avoid using the "stray" neighbour.
> 
> Roland, could you test if this could fix your problem? I don't
> have the environment.
> 
> Reported-by: Roland Dreier <roland@purestorage.com>
> Cc: Roland Dreier <roland@purestorage.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>


diff --git a/include/net/ndisc.h b/include/net/ndisc.h
> index 23b3a7c..a5fe1b3 100644
> --- a/include/net/ndisc.h
> +++ b/include/net/ndisc.h
> @@ -148,14 +148,16 @@ static inline u32 ndisc_hashfn(const void *pkey, const struct net_device *dev, _
>  		(p32[3] * hash_rnd[3]));
>  }
>  
> -static inline struct neighbour *__ipv6_neigh_lookup(struct neigh_table *tbl, struct net_device *dev, const void *pkey)
> +static inline
> +struct neighbour *__ipv6_neigh_lookup_noref(struct neigh_table *tbl,
> +					    struct net_device *dev,
> +					    const void *pkey)
>  {
> 

__ipv6_neigh_lookup_noref() should be moved to net/ipv6/route.c


> @@ -124,9 +125,17 @@ static int ip6_finish_output2(struct sk_buff *skb)
>  	}
>  
>  	rt = (struct rt6_info *) dst;
> -	neigh = rt->n;
> -	if (neigh)
> +	rcu_read_lock_bh();
> +	if (rt->rt6i_flags & RTF_GATEWAY)
> +		daddr = &rt->rt6i_gateway;
> +	neigh = __ipv6_neigh_lookup_noref(&nd_tbl, dev, daddr);
> +	if (unlikely(!neigh))
> +		neigh = __neigh_create(&nd_tbl, daddr, dev, false);
> +	if (!IS_ERR(neigh)) {
> +		rcu_read_unlock_bh();

You release the lock too soon. Take a look at IPv4 ...

>  		return dst_neigh_output(dst, neigh, skb);
> +	}
> +	rcu_read_unlock_bh();
>  
>  	IP6_INC_STATS_BH(dev_net(dst->dev),
>  			 ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);

And really, you should not post patches like this without testing them,
as testing is probably the hardest part of the equation.

Thanks
