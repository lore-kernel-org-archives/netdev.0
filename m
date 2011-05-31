From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC/PATCH] sungem: Spring cleaning and GRO support
Date: Tue, 31 May 2011 21:59:24 +0100
Message-ID: <1306875564.2866.39.camel@bwh-desktop>
References: <1306828745.7481.660.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"R. Herbst" <ruediger.herbst@googlemail.com>,
	Brian Hamilton <bhamilton04@gmail.com>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:57714 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932282Ab1EaU72 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2011 16:59:28 -0400
In-Reply-To: <1306828745.7481.660.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-31 at 17:59 +1000, Benjamin Herrenschmidt wrote:
> Hi David !
> 
> For RFC only at this stage, see blow why.
> 
> This patch simplifies the logic and locking in sungem significantly:
> 
>  - LLTX is gone, private tx lock is gone
>  - We don't poll the PHY while the interface is down
>  - The above allowed me to get rid of a pile of state flags
>    using the proper interface state provided by the networking
>    stack when needed
>  - Allocate the bulk of RX skbs at init time using GFP_KERNEL
>  - Fix a bug where the dev->features were set after register_netdev()
>  - Added GRO while at it
> 
> Now the results .... on a dual G5 machine with a 1000Mb link, no
> measurable netperf difference on Rx and a 3% loss on Tx.

Is TX throughput now CPU-limited or is there some other problem?

Lacking TSO is going to hurt, but I know we managed multi-gigabit
single-stream TCP throughput without TSO on x86 systems from 2005.

[...]
> @@ -736,6 +747,22 @@ static __inline__ void gem_post_rxds(struct gem *gp, int limit)
>  	}
>  }
>  
> +#define ALIGNED_RX_SKB_ADDR(addr) \
> +        ((((unsigned long)(addr) + (64UL - 1UL)) & ~(64UL - 1UL)) - (unsigned long)(addr))

We already have a macro for most of this, so you can define this as:

	(PTR_ALIGN(addr, 64) - (addr))

(assuming addr is always a byte pointer; otherwise you need ALIGN and
the casts to unsigned long).

> +static __inline__ struct sk_buff *gem_alloc_skb(struct net_device *dev, int size,
> +						gfp_t gfp_flags)
> +{
> +	struct sk_buff *skb = alloc_skb(size + 64, gfp_flags);

You probably should be using netdev_alloc_skb().

> +	if (likely(skb)) {
> +		int offset = (int) ALIGNED_RX_SKB_ADDR(skb->data);
> +		if (offset)
> +			skb_reserve(skb, offset);

skb_reserve() is inline and very simple, so it may be cheaper to call it
unconditionally.

> +		skb->dev = dev;
> +	}
> +	return skb;
> +}
> +
[...]
> @@ -951,11 +956,12 @@ static irqreturn_t gem_interrupt(int irq, void *dev_id)
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  static void gem_poll_controller(struct net_device *dev)
>  {
> -	/* gem_interrupt is safe to reentrance so no need
> -	 * to disable_irq here.
> -	 */
> -	gem_interrupt(dev->irq, dev);
> -}
> +	struct gem *gp = netdev_priv(dev);
> +
> +	disable_irq(gp->pdev->irq);
> +	gem_interrupt(gp->pdev->irq, dev);
> +	enable_irq(gp->pdev->irq);
> +
>  #endif

This might work better with the closing brace left in place...

The change from dev->irq to gp->pdev->irq looks unnecessary - though I
hope that one day we can get rid of those I/O resource details in struct
net_device.

[...]
>  static int gem_do_start(struct net_device *dev)
>  {
[...] 
>  	if (request_irq(gp->pdev->irq, gem_interrupt,
>  				   IRQF_SHARED, dev->name, (void *)dev)) {
>  		netdev_err(dev, "failed to request irq !\n");
>  
> -		spin_lock_irqsave(&gp->lock, flags);
> -		spin_lock(&gp->tx_lock);
> -
>  		napi_disable(&gp->napi);
> -
> -		gp->running =  0;
> +		netif_device_detach(dev);

I don't think this can be right, as there seems to be no way for the
device to be re-attached after this failure other than a suspend/resume
cycle.

>  		gem_reset(gp);
>  		gem_clean_rings(gp);
> -		gem_put_cell(gp);
>  
> -		spin_unlock(&gp->tx_lock);
> -		spin_unlock_irqrestore(&gp->lock, flags);
> +		spin_lock_bh(&gp->lock);
> +		gem_put_cell(gp);
> +		spin_unlock_bh(&gp->lock);
>  
>  		return -EAGAIN;
>  	}
[...]

Is the pm_mutex really needed?  All control operations should already be
serialised by the RTNL lock, and you've started taking that in the
suspend and resume functions.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

