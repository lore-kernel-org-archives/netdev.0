From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH 0/5] bridge: RCU annotation and cleanup
Date: Mon, 15 Nov 2010 21:23:37 +0900
Message-ID: <201011152123.HHB21896.HFOOVSMFOtLJQF@I-love.SAKURA.ne.jp>
References: <20101114211201.678755903@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: shemminger@vyatta.com, davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([122.1.235.145]:64649 "EHLO smtp.wine.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754072Ab0KOMXl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Nov 2010 07:23:41 -0500
In-Reply-To: <20101114211201.678755903@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> This is a split up of what Eric did with a couple of small changes and additions.
Something seems to be wrong with this patchset.

--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
> @@ -173,8 +177,8 @@ forward:
>  	switch (p->state) {
>  	case BR_STATE_FORWARDING:
>  		rhook = rcu_dereference(br_should_route_hook);
> -		if (rhook != NULL) {
> -			if (rhook(skb))
> +		if (rhook) {
> +			if ((*rhook)(skb))

Is *rhook != NULL guaranteed when rhook != NULL?

>  				return skb;
>  			dest = eth_hdr(skb)->h_dest;
>  		}

--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
> @@ -242,7 +242,7 @@ static void br_multicast_flood(struct ne
>  		if ((unsigned long)lport >= (unsigned long)port)
>  			p = rcu_dereference(p->next);
>  		if ((unsigned long)rport >= (unsigned long)port)
> -			rp = rcu_dereference(rp->next);
> +			rp = rcu_dereference(hlist_next_rcu(rp->next));

I think this one is hlist_next_rcu(rp).

>  	}
>  
>  	if (!prev)

--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
> @@ -475,11 +475,8 @@ int br_del_if(struct net_bridge *br, str
>  {
>  	struct net_bridge_port *p;
>  
> -	if (!br_port_exists(dev))
> -		return -EINVAL;
> -
>  	p = br_port_get(dev);

Don't you need to use br_port_get_rtnl()?  (I don't know.)

> -	if (p->br != br)
> +	if (!p || p->br != br)
>  		return -EINVAL;
>  
>  	del_nbp(p);

--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
> @@ -169,9 +171,9 @@ static int br_rtm_setlink(struct sk_buff
>  	if (!dev)
>  		return -ENODEV;
>  
> -	if (!br_port_exists(dev))
> -		return -EINVAL;
>  	p = br_port_get(dev);

Don't you need to use br_port_get_rtnl()?  (I don't know.)

> +	if (!p)
> +		return -EINVAL;
>  
>  	/* if kernel STP is running, don't allow changes */
>  	if (p->br->stp_enabled == BR_KERNEL_STP)

--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
> @@ -151,11 +151,21 @@ struct net_bridge_port
>  #endif
>  };
>  
> -#define br_port_get_rcu(dev) \
> -	((struct net_bridge_port *) rcu_dereference(dev->rx_handler_data))
> -#define br_port_get(dev) ((struct net_bridge_port *) dev->rx_handler_data)
>  #define br_port_exists(dev) (dev->priv_flags & IFF_BRIDGE_PORT)
>  
> +static inline struct net_bridge_port *br_port_get_rcu(const struct net_device *dev)
> +{
> +	return br_port_exists(dev) ?
> +		rcu_dereference(dev->rx_handler_data) : NULL;
> +}
> +
> +static inline struct net_bridge_port *br_port_get(struct net_device *dev)
> +{
> +	return br_port_exists(dev) ? dev->rx_handler_data : NULL;
> +}
> +
> +#define br_port_get(dev) ((struct net_bridge_port *) dev->rx_handler_data)

Why are you defining br_port_get() twice, once as macro and once as inlined
function?
