From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2 v2] net: Cache dst in tunnels
Date: Wed, 18 Dec 2013 13:38:49 -0800
Message-ID: <1387402729.19078.340.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.DEB.2.02.1312181158500.31112@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:43025 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755715Ab3LRVil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 16:38:41 -0500
Received: by mail-pd0-f171.google.com with SMTP id z10so210903pdj.16
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 13:38:41 -0800 (PST)
In-Reply-To: <alpine.DEB.2.02.1312181158500.31112@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-12-18 at 12:06 -0800, Tom Herbert wrote:
> Avoid doing a route lookup on every packet being tunneled.
> 
> In ip_tunnel.c cache the route returned from ip_route_output if
> the tunnel is "connected" so that all the rouitng parameters are
> taken from tunnel parms for a packet. Specifically, not NBMA tunnel
> and tos is from tunnel parms (not inner packet).
> 

It seems title suffix should be "ipv4", not "net" ?

> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  include/net/ip_tunnels.h |   3 ++
>  net/ipv4/ip_tunnel.c     | 110 ++++++++++++++++++++++++++++++++++++-----------
>  2 files changed, 89 insertions(+), 24 deletions(-)
> 
> diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
> index 732f8c6..bde50fc 100644
> --- a/include/net/ip_tunnels.h
> +++ b/include/net/ip_tunnels.h
> @@ -54,6 +54,9 @@ struct ip_tunnel {
>  	int		hlen;		/* Precalculated header length */
>  	int		mlink;
>  
> +	struct		dst_entry __rcu *dst_cache;
> +	spinlock_t	dst_lock;
> +
>  	struct ip_tunnel_parm parms;
>  
>  	/* for SIT */
> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> index 90ff957..f9ffe38 100644
> --- a/net/ipv4/ip_tunnel.c
> +++ b/net/ipv4/ip_tunnel.c
> @@ -68,6 +68,51 @@ static unsigned int ip_tunnel_hash(struct ip_tunnel_net *itn,
>  			 IP_TNL_HASH_BITS);
>  }
>  
> +static inline void __tunnel_dst_set(struct ip_tunnel *t, struct dst_entry *dst)
> +{
> +	struct dst_entry *old_dst;
> +
> +	spin_lock_bh(&t->dst_lock);
> +	old_dst = rcu_dereference_raw(t->dst_cache);
> +	rcu_assign_pointer(t->dst_cache, dst);
> +	dst_release(old_dst);
> +	spin_unlock_bh(&t->dst_lock);
> +}
> +

You could use xchg() like in commit
e47eb5dfb296bf21
    "udp: ipv4: do not use sk_dst_lock from softirq context"

Also, it would be nice to make sure DST_NOCACHE is not set in dst flags,
otherwise dst_release() wont respect RCU grace period.

See __skb_dst_set_noref() for details.

It might be possible to trigger this using a multicast address.

Note: Its possible we could get rid of DST_NOCACHE if we deploy enough
caches obsoleting the rcu issue, but thats a separate discussion.


> +static inline void tunnel_dst_set(struct ip_tunnel *t, struct dst_entry *dst)
> +{
> +	__tunnel_dst_set(t, dst);
> +}
> +
...
>  static int ip_tunnel_bind_dev(struct net_device *dev)
> @@ -350,18 +393,18 @@ static int ip_tunnel_bind_dev(struct net_device *dev)
>  		struct flowi4 fl4;
>  		struct rtable *rt;
>  
> -		rt = ip_route_output_tunnel(tunnel->net, &fl4,
> -					    tunnel->parms.iph.protocol,
> -					    iph->daddr, iph->saddr,
> -					    tunnel->parms.o_key,
> -					    RT_TOS(iph->tos),
> -					    tunnel->parms.link);
> +		init_tunnel_flow(&fl4, iph->protocol, iph->daddr,
> +				 iph->saddr, tunnel->parms.o_key,
>   +				 RT_TOS(iph->tos), tunnel->parms.link);
> +		rt = ip_route_output_key(tunnel->net, &fl4);
> +
>  		if (!IS_ERR(rt)) {
>  			tdev = rt->dst.dev;
>  			ip_rt_put(rt);
>  		}
>  		if (dev->type != ARPHRD_ETHER)
>  			dev->flags |= IFF_POINTOPOINT;

Here, it seems we can have IS_ERR(rt), so dst_clone() will crash

> +		tunnel_dst_set(tunnel, dst_clone(&rt->dst));
>  	}
>  
