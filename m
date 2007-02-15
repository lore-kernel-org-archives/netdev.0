From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH v2, resend] gianfar: don't duplicate gfar_error()
Date: Thu, 15 Feb 2007 15:12:27 -0600
Message-ID: <50956413-2C26-4DEC-89E0-F23351825EAB@freescale.com>
References: <200702151656.01313.sshtylyov@ru.mvista.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, linuxppc-embedded@ozlabs.org
To: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Return-path: <linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <200702151656.01313.sshtylyov@ru.mvista.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


On Feb 15, 2007, at 07:56, Sergei Shtylyov wrote:

> It was hardly necessary to repeat most of the code from gfar_error 
> () in
> gfar_interrupt(), especially having some inconsistencies between  
> the two.
> So, make the gfar_interrupt() just call gfar_error(), and not  
> acknowledge
> the interrupts itself as gfar_{receive/transmit/error}() do it anyway.
> While at it, also clarify/cleanup debug messages in gfar_error()...
>
> Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

Acked-by: Andy Fleming <afleming@freescale.com>

>
> ---
> The patch survived netperf stressing on MPC8540ADS realtime  
> kernel. :-)
>
> Sorry, forgot to remove the obsolete regs argument from gfar_error 
> () call,
> call, so the previous version wasn't even compilable -- I've tested  
> the patch
> in the older kernel. Resending now with better placed comments  
> which you won't
> have to edit out... :-<
>
>  drivers/net/gianfar.c |   85 +++++++ 
> +------------------------------------------
>  1 files changed, 15 insertions(+), 70 deletions(-)
>
> Index: linux-2.6/drivers/net/gianfar.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/gianfar.c
> +++ linux-2.6/drivers/net/gianfar.c
> @@ -10,6 +10,7 @@
>   * Maintainer: Kumar Gala
>   *
>   * Copyright (c) 2002-2006 Freescale Semiconductor, Inc.
> + * Copyright (c) 2007 MontaVista Software, Inc.
>   *
>   * This program is free software; you can redistribute  it and/or  
> modify it
>   * under  the terms of  the GNU General  Public License as  
> published by the
> @@ -1613,71 +1614,17 @@ static irqreturn_t gfar_interrupt(int ir
>  	/* Save ievent for future reference */
>  	u32 events = gfar_read(&priv->regs->ievent);
>
> -	/* Clear IEVENT */
> -	gfar_write(&priv->regs->ievent, events);
> -
>  	/* Check for reception */
> -	if ((events & IEVENT_RXF0) || (events & IEVENT_RXB0))
> +	if (events & IEVENT_RX_MASK)
>  		gfar_receive(irq, dev_id);
>
>  	/* Check for transmit completion */
> -	if ((events & IEVENT_TXF) || (events & IEVENT_TXB))
> +	if (events & IEVENT_TX_MASK)
>  		gfar_transmit(irq, dev_id);
>
> -	/* Update error statistics */
> -	if (events & IEVENT_TXE) {
> -		priv->stats.tx_errors++;
> -
> -		if (events & IEVENT_LC)
> -			priv->stats.tx_window_errors++;
> -		if (events & IEVENT_CRL)
> -			priv->stats.tx_aborted_errors++;
> -		if (events & IEVENT_XFUN) {
> -			if (netif_msg_tx_err(priv))
> -				printk(KERN_WARNING "%s: tx underrun. dropped packet\n", dev- 
> >name);
> -			priv->stats.tx_dropped++;
> -			priv->extra_stats.tx_underrun++;
> -
> -			/* Reactivate the Tx Queues */
> -			gfar_write(&priv->regs->tstat, TSTAT_CLEAR_THALT);
> -		}
> -	}
> -	if (events & IEVENT_BSY) {
> -		priv->stats.rx_errors++;
> -		priv->extra_stats.rx_bsy++;
> -
> -		gfar_receive(irq, dev_id);
> -
> -#ifndef CONFIG_GFAR_NAPI
> -		/* Clear the halt bit in RSTAT */
> -		gfar_write(&priv->regs->rstat, RSTAT_CLEAR_RHALT);
> -#endif
> -
> -		if (netif_msg_rx_err(priv))
> -			printk(KERN_DEBUG "%s: busy error (rhalt: %x)\n",
> -					dev->name,
> -					gfar_read(&priv->regs->rstat));
> -	}
> -	if (events & IEVENT_BABR) {
> -		priv->stats.rx_errors++;
> -		priv->extra_stats.rx_babr++;
> -
> -		if (netif_msg_rx_err(priv))
> -			printk(KERN_DEBUG "%s: babbling error\n", dev->name);
> -	}
> -	if (events & IEVENT_EBERR) {
> -		priv->extra_stats.eberr++;
> -		if (netif_msg_rx_err(priv))
> -			printk(KERN_DEBUG "%s: EBERR\n", dev->name);
> -	}
> -	if ((events & IEVENT_RXC) && (netif_msg_rx_err(priv)))
> -			printk(KERN_DEBUG "%s: control frame\n", dev->name);
> -
> -	if (events & IEVENT_BABT) {
> -		priv->extra_stats.tx_babt++;
> -		if (netif_msg_rx_err(priv))
> -			printk(KERN_DEBUG "%s: babt error\n", dev->name);
> -	}
> +	/* Check for errors */
> +	if (events & IEVENT_ERR_MASK)
> +		gfar_error(irq, dev_id);
>
>  	return IRQ_HANDLED;
>  }
> @@ -1939,7 +1886,7 @@ static irqreturn_t gfar_error(int irq, v
>  	/* Hmm... */
>  	if (netif_msg_rx_err(priv) || netif_msg_tx_err(priv))
>  		printk(KERN_DEBUG "%s: error interrupt (ievent=0x%08x imask=0x% 
> 08x)\n",
> -				dev->name, events, gfar_read(&priv->regs->imask));
> +		       dev->name, events, gfar_read(&priv->regs->imask));
>
>  	/* Update the error counters */
>  	if (events & IEVENT_TXE) {
> @@ -1951,8 +1898,8 @@ static irqreturn_t gfar_error(int irq, v
>  			priv->stats.tx_aborted_errors++;
>  		if (events & IEVENT_XFUN) {
>  			if (netif_msg_tx_err(priv))
> -				printk(KERN_DEBUG "%s: underrun.  packet dropped.\n",
> -						dev->name);
> +				printk(KERN_DEBUG "%s: TX FIFO underrun, "
> +				       "packet dropped.\n", dev->name);
>  			priv->stats.tx_dropped++;
>  			priv->extra_stats.tx_underrun++;
>
> @@ -1974,30 +1921,28 @@ static irqreturn_t gfar_error(int irq, v
>  #endif
>
>  		if (netif_msg_rx_err(priv))
> -			printk(KERN_DEBUG "%s: busy error (rhalt: %x)\n",
> -					dev->name,
> -					gfar_read(&priv->regs->rstat));
> +			printk(KERN_DEBUG "%s: busy error (rstat: %x)\n",
> +			       dev->name, gfar_read(&priv->regs->rstat));
>  	}
>  	if (events & IEVENT_BABR) {
>  		priv->stats.rx_errors++;
>  		priv->extra_stats.rx_babr++;
>
>  		if (netif_msg_rx_err(priv))
> -			printk(KERN_DEBUG "%s: babbling error\n", dev->name);
> +			printk(KERN_DEBUG "%s: babbling RX error\n", dev->name);
>  	}
>  	if (events & IEVENT_EBERR) {
>  		priv->extra_stats.eberr++;
>  		if (netif_msg_rx_err(priv))
> -			printk(KERN_DEBUG "%s: EBERR\n", dev->name);
> +			printk(KERN_DEBUG "%s: bus error\n", dev->name);
>  	}
>  	if ((events & IEVENT_RXC) && netif_msg_rx_status(priv))
> -		if (netif_msg_rx_status(priv))
> -			printk(KERN_DEBUG "%s: control frame\n", dev->name);
> +		printk(KERN_DEBUG "%s: control frame\n", dev->name);
>
>  	if (events & IEVENT_BABT) {
>  		priv->extra_stats.tx_babt++;
>  		if (netif_msg_tx_err(priv))
> -			printk(KERN_DEBUG "%s: babt error\n", dev->name);
> +			printk(KERN_DEBUG "%s: babbling TX error\n", dev->name);
>  	}
>  	return IRQ_HANDLED;
>  }
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
