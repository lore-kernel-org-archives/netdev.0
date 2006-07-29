From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 4/3] forcedeth: fix NAPI hang in IRQ.
Date: Fri, 28 Jul 2006 21:10:00 -0700
Message-ID: <20060728211000.449d8727.akpm@osdl.org>
References: <20060728015007.625581647@localhost>
	<20060728015054.566221096@localhost>
	<20060727190114.68bfd817@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, aabdulla@nvidia.com, manfred@colorfullife.com,
	jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:11466 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161439AbWG2EKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 00:10:15 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060727190114.68bfd817@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 27 Jul 2006 19:01:14 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Fix for NAPI hanging in interrupt. With NAPI, we only need one
> iteration over the IRQ.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> 
> --- linux-2.6.orig/drivers/net/forcedeth.c	2006-07-27
> 18:58:21.000000000 -0700 +++ linux-2.6/drivers/net/forcedeth.c
> 2006-07-27 18:57:31.000000000 -0700 @@ -2422,10 +2422,11 @@
>  						dev->name, events);
>  		}
>  #ifdef CONFIG_FORCEDETH_NAPI
> -		if (netif_rx_schedule_prep(dev)) {
> -			__netif_rx_schedule(dev);
> +		if (events & NVREG_IRQ_RX_ALL) {
> +			netif_rx_schedule(dev);
>  			nv_disable_hw_interrupts(dev,
> NVREG_IRQ_RX_ALL); }
> +		return IRQ_HANDLED;
>  #else
>  		nv_rx_process(dev, dev->weight);
>  		if (nv_alloc_rx(dev)) {
> @@ -2434,7 +2435,6 @@
>  				mod_timer(&np->oom_kick, jiffies +
> OOM_REFILL); spin_unlock(&np->lock);
>  		}
> -#endif
>  		if (i > max_interrupt_work) {
>  			spin_lock(&np->lock);
>  			/* disable interrupts on the nic */
> @@ -2452,7 +2452,7 @@
>  			spin_unlock(&np->lock);
>  			break;
>  		}
> -
> +#endif
>  	}
>  	dprintk(KERN_DEBUG "%s: nv_nic_irq completed\n", dev->name);
>  

What on earth happened to that?
