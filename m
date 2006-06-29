From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 8/9] pcnet32: NAPI implementation.
Date: Fri, 30 Jun 2006 00:24:38 +0200
Message-ID: <20060629222438.GB8122@electric-eye.fr.zoreil.com>
References: <20060629205551.GA22031@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tsbogend@alpha.franken.de, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:63661 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S933053AbWF2W0u
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 18:26:50 -0400
To: Don Fry <brazilnut@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <20060629205551.GA22031@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nit below.

Don Fry <brazilnut@us.ibm.com> :
[...]
> --- linux-2.6.17-git13/drivers/net/purge.pcnet32.c	Thu Jun 29 13:28:24 2006
> +++ linux-2.6.17-git13/drivers/net/pcnet32.c	Thu Jun 29 13:28:31 2006
[...]
> +#ifdef CONFIG_PCNET32_NAPI
> +static int pcnet32_poll(struct net_device *dev, int *budget)
> +{
[...]
> +	netif_rx_complete(dev);
> +
> +	spin_lock_irqsave(&lp->lock, flags);

No need to save/restore (it's true in pcnet32_{get_regs/suspend} too).

> +
> +	/* clear interrupt masks */
> +	val = lp->a.read_csr(ioaddr, CSR3);
> +	val &= 0x00ff;
> +	lp->a.write_csr(ioaddr, CSR3, val);
> +
> +	/* Set interrupt enable. */
> +	lp->a.write_csr(ioaddr, CSR0, CSR0_INTEN);

Insert mmiowb():

> +
> +	spin_unlock_irqrestore(&lp->lock, flags);

[...]
> @@ -2413,183 +2608,41 @@ pcnet32_interrupt(int irq, void *dev_id,
>  				       dev->name, csr0);
>  			/* unlike for the lance, there is no restart needed */
>  		}
> -
> -		if (must_restart) {
> +#ifdef CONFIG_PCNET32_NAPI
> +		if (netif_rx_schedule_prep(dev)) {
> +			u16 val;
> +			/* set interrupt masks */
> +			val = lp->a.read_csr(ioaddr, CSR3);
> +			val |= 0x5f00;
> +			lp->a.write_csr(ioaddr, CSR3, val);

Insert mmiowb();

-- 
Ueimor
