From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.36] vlan: Avoid hwaccel vlan packets when vid not
 used
Date: Wed, 08 Dec 2010 08:47:31 -0800 (PST)
Message-ID: <20101208.084731.189716071.davem@davemloft.net>
References: <1291108809.2904.3.camel@edumazet-laptop>
	<20101201111716.424fb771@xenia.leun.net>
	<1291200914.2856.546.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lkml20101129@newton.leun.net, greearb@candelatech.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jesse@nicira.com, stable@kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291200914.2856.546.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 01 Dec 2010 11:55:14 +0100


Greg/-stable, please integrate this patch from Eric into 2.6.36 if you
haven't already done so.

Thanks!

> [PATCH v2 2.6.36] vlan: Avoid hwaccel vlan packets when vid not used.
> 
> Normally hardware accelerated vlan packets are quickly dropped if
> there is no corresponding vlan device configured.  The one exception
> is promiscuous mode, where we allow all of these packets through so
> they can be picked up by tcpdump.  However, this behavior causes a
> crash if we actually try to receive these packets.  This fixes that
> crash by ignoring packets with vids not corresponding to a configured
> device in the vlan hwaccel routines and then dropping them before they
> get to consumers in the network stack.
> 
> Reported-by: Ben Greear <greearb@candelatech.com>
> Signed-off-by: Jesse Gross <jesse@nicira.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Tested-by: Michael Leun <lkml20101129@newton.leun.net>
> ---
> v2: survives to tcpdump :)
> 
>  net/core/dev.c        |   10 ++++++++++
>  net/8021q/vlan_core.c |    3 +++
>  2 files changed, 13 insertions(+)
> 
> --- linux-2.6.36/net/core/dev.c.orig
> +++ linux-2.6.36/net/core/dev.c
> @@ -2891,6 +2891,15 @@
>  ncls:
>  #endif
>  
> +	/* If we got this far with a hardware accelerated VLAN tag, it means
> +	 * that we were put in promiscuous mode but nobody is interested in
> +	 * this vid. Drop the packet now to prevent it from getting propagated
> +	 * to other parts of the stack that won't know how to deal with packets
> +	 * tagged in this manner.
> +	 */
> +	if (unlikely(vlan_tx_tag_present(skb)))
> +		goto bypass;
> +
>  	/* Handle special case of bridge or macvlan */
>  	rx_handler = rcu_dereference(skb->dev->rx_handler);
>  	if (rx_handler) {
> @@ -2927,6 +2936,7 @@
>  		}
>  	}
>  
> +bypass:
>  	if (pt_prev) {
>  		ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
>  	} else {
> --- linux-2.6.36/net/8021q/vlan_core.c.orig
> +++ linux-2.6.36/net/8021q/vlan_core.c
> @@ -43,6 +43,9 @@
>  	struct net_device *dev = skb->dev;
>  	struct vlan_rx_stats     *rx_stats;
>  
> +	if (unlikely(!is_vlan_dev(dev)))
> +		return 0;
> +
>  	skb->dev = vlan_dev_info(dev)->real_dev;
>  	netif_nit_deliver(skb);
>  
> 
> 
