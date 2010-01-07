From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: consolidate netif_needs_gso() checks
Date: Wed, 06 Jan 2010 20:34:23 -0800 (PST)
Message-ID: <20100106.203423.58447620.davem@davemloft.net>
References: <20100104102153.11639.48828.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53956
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932350Ab0AGEeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 23:34:15 -0500
In-Reply-To: <20100104102153.11639.48828.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Mon, 04 Jan 2010 10:21:53 +0000

> netif_needs_gso() is checked twice in the TX path once,
> before submitting the skb to the qdisc and once after
> it is dequeued from the qdisc just before calling
> ndo_hard_start().  This opens a window for a user to
> change the gso/tso or tx checksum settings that can
> cause netif_needs_gso to be true in one check and false
> in the other.
> 
> Specifically, changing TX checksum setting may cause
> the warning in skb_gso_segment() to be triggered if
> the checksum is calculated earlier.
> 
> This consolidates the netif_needs_gso() calls so that
> the stack only checks if gso is needed after the skb
> is dequeued from the qdisc.  Or if the device has no
> queue then before dev_hard_start_xmit() in dev_queue_xmit().
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Herbert, please review.

> ---
> 
>  net/core/dev.c |   88 +++++++++++++++++++++++++++++++++++++-------------------
>  1 files changed, 58 insertions(+), 30 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index c36a17a..91077df 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1808,12 +1808,39 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
>  {
>  	const struct net_device_ops *ops = dev->netdev_ops;
>  	int rc = NETDEV_TX_OK;
> +	int need_gso = netif_needs_gso(dev,skb);
> +
> +	if (!need_gso) {
> +		if (skb_has_frags(skb) &&
> +		    !(dev->features & NETIF_F_FRAGLIST) &&
> +		    __skb_linearize(skb))
> +			goto out_kfree_skb;
> +
> +		/* Fragmented skb is linearized if device does not support SG,
> +		 * or if at least one of fragments is in highmem and device
> +		 * does not support DMA from it.
> +		 */
> +		if (skb_shinfo(skb)->nr_frags &&
> +		    (!(dev->features & NETIF_F_SG) ||
> +		      illegal_highdma(dev, skb)) &&
> +		    __skb_linearize(skb))
> +			goto out_kfree_skb;
> +		/* If packet is not checksummed and device does not support
> +		 * checksumming for this protocol, complete checksumming here.
> +		 */
> +		if (skb->ip_summed == CHECKSUM_PARTIAL) {
> +			skb_set_transport_header(skb, skb->csum_start -
> +				      skb_headroom(skb));
> +			if (!dev_can_checksum(dev, skb) && skb_checksum_help(skb))
> +				goto out_kfree_skb;
> +		}
> +	}
>  
>  	if (likely(!skb->next)) {
>  		if (!list_empty(&ptype_all))
>  			dev_queue_xmit_nit(skb, dev);
>  
> -		if (netif_needs_gso(dev, skb)) {
> +		if (need_gso) {
>  			if (unlikely(dev_gso_segment(skb)))
>  				goto out_kfree_skb;
>  			if (skb->next)
> @@ -2006,6 +2033,35 @@ int dev_queue_xmit(struct sk_buff *skb)
>  	struct Qdisc *q;
>  	int rc = -ENOMEM;
>  
> +	/* Disable soft irqs for various locks below. Also
> +	 * stops preemption for RCU.
> +	 */
> +	rcu_read_lock_bh();
> +
> +	txq = dev_pick_tx(dev, skb);
> +	q = rcu_dereference(txq->qdisc);
> +
> +#ifdef CONFIG_NET_CLS_ACT
> +	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_EGRESS);
> +#endif
> +	if (q->enqueue) {
> +		rc = __dev_xmit_skb(skb, q, dev, txq);
> +		goto out;
> +	}
> +
> +	/* The device has no queue. Common case for software devices:
> +	   loopback, all the sorts of tunnels...
> +
> +	   Really, it is unlikely that netif_tx_lock protection is necessary
> +	   here.  (f.e. loopback and IP tunnels are clean ignoring statistics
> +	   counters.)
> +	   However, it is possible, that they rely on protection
> +	   made by us here.
> +
> +	   Check this and shot the lock. It is not prone from deadlocks.
> +	   Either shot noqueue qdisc, it is even simpler 8)
> +	 */
> +
>  	/* GSO will handle the following emulations directly. */
>  	if (netif_needs_gso(dev, skb))
>  		goto gso;
> @@ -2035,34 +2091,6 @@ int dev_queue_xmit(struct sk_buff *skb)
>  	}
>  
>  gso:
> -	/* Disable soft irqs for various locks below. Also
> -	 * stops preemption for RCU.
> -	 */
> -	rcu_read_lock_bh();
> -
> -	txq = dev_pick_tx(dev, skb);
> -	q = rcu_dereference(txq->qdisc);
> -
> -#ifdef CONFIG_NET_CLS_ACT
> -	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_EGRESS);
> -#endif
> -	if (q->enqueue) {
> -		rc = __dev_xmit_skb(skb, q, dev, txq);
> -		goto out;
> -	}
> -
> -	/* The device has no queue. Common case for software devices:
> -	   loopback, all the sorts of tunnels...
> -
> -	   Really, it is unlikely that netif_tx_lock protection is necessary
> -	   here.  (f.e. loopback and IP tunnels are clean ignoring statistics
> -	   counters.)
> -	   However, it is possible, that they rely on protection
> -	   made by us here.
> -
> -	   Check this and shot the lock. It is not prone from deadlocks.
> -	   Either shot noqueue qdisc, it is even simpler 8)
> -	 */
>  	if (dev->flags & IFF_UP) {
>  		int cpu = smp_processor_id(); /* ok because BHs are off */
>  
> @@ -4869,7 +4897,7 @@ unsigned long netdev_fix_features(unsigned long features, const char *name)
>  			printk(KERN_NOTICE "%s: Dropping NETIF_F_SG since no "
>  			       "checksum feature.\n", name);
>  		features &= ~NETIF_F_SG;
> -	}
> +}
>  
>  	/* TSO requires that SG is present as well. */
>  	if ((features & NETIF_F_TSO) && !(features & NETIF_F_SG)) {
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
