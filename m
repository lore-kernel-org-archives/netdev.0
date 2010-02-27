From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH v2] net: consolidate netif_needs_gso()
 checks
Date: Sat, 27 Feb 2010 03:27:25 -0800 (PST)
Message-ID: <20100227.032725.158512690.davem@davemloft.net>
References: <20100227001954.32474.62766.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	john.r.fastabend@intel.com, herbert@gondor.apana.org.au
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33098
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965569Ab0B0L1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 06:27:08 -0500
In-Reply-To: <20100227001954.32474.62766.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 26 Feb 2010 16:20:11 -0800

> From: John Fastabend <john.r.fastabend@intel.com>
> 
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
> the stack only checks if gso is needed in
> dev_hard_start_xmit().
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

This looks mostly fine, but I have at least one doubt.

If we have ip_summed == CHECKSUM_PARTIAL might some classifier
or packet scheduler action module require that the
transport header is setup properly before the SKB gets into
there?

Arguably, that's happening already in the GSO case but this
change is bringing the issue more to light.

Herbert, could you also take a look at this patch?

Thanks!

> diff --git a/net/core/dev.c b/net/core/dev.c
> index eb7f1a4..626124d 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1835,12 +1835,40 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
>  {
>  	const struct net_device_ops *ops = dev->netdev_ops;
>  	int rc = NETDEV_TX_OK;
> +	int need_gso = netif_needs_gso(dev, skb);
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
> +			if (!dev_can_checksum(dev, skb) &&
> +			     skb_checksum_help(skb))
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
> @@ -2056,25 +2084,6 @@ int dev_queue_xmit(struct sk_buff *skb)
>  	struct Qdisc *q;
>  	int rc = -ENOMEM;
>  
> -	/* GSO will handle the following emulations directly. */
> -	if (netif_needs_gso(dev, skb))
> -		goto gso;
> -
> -	/* Convert a paged skb to linear, if required */
> -	if (skb_needs_linearize(skb, dev) && __skb_linearize(skb))
> -		goto out_kfree_skb;
> -
> -	/* If packet is not checksummed and device does not support
> -	 * checksumming for this protocol, complete checksumming here.
> -	 */
> -	if (skb->ip_summed == CHECKSUM_PARTIAL) {
> -		skb_set_transport_header(skb, skb->csum_start -
> -					      skb_headroom(skb));
> -		if (!dev_can_checksum(dev, skb) && skb_checksum_help(skb))
> -			goto out_kfree_skb;
> -	}
> -
> -gso:
>  	/* Disable soft irqs for various locks below. Also
>  	 * stops preemption for RCU.
>  	 */
> @@ -2133,7 +2142,6 @@ gso:
>  	rc = -ENETDOWN;
>  	rcu_read_unlock_bh();
>  
> -out_kfree_skb:
>  	kfree_skb(skb);
>  	return rc;
>  out:
> 

