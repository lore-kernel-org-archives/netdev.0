From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] Add support the Korina (IDT RC32434) Ethernet MAC
Date: Wed, 19 Mar 2008 22:55:35 +0100
Message-ID: <20080319215535.GB24710@electric-eye.fr.zoreil.com>
References: <200803052345.06610.florian.fainelli@telecomint.eu> <200803191714.52407.florian.fainelli@telecomint.eu> <20080319202613.GA24710@electric-eye.fr.zoreil.com> <200803192217.25860.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>, Felix Fietkau <nbd@openwrt.org>
To: Florian Fainelli <florian.fainelli@telecomint.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:46566 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1764904AbYCSWOA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 18:14:00 -0400
Content-Disposition: inline
In-Reply-To: <200803192217.25860.florian.fainelli@telecomint.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <florian.fainelli@telecomint.eu> :
> Le mercredi 19 mars 2008, Francois Romieu a ?crit?:
> > Please have some sleep, some coffee (in that order) and write down the
> > sequence of instructions of the code above when request_irq does _not_
> > fail.
> 
> Ermm, please find the fixed version below (hopefully).

Some remarks below before I have to go.

[...]
> --- /dev/null
> +++ b/drivers/net/korina.c
> @@ -0,0 +1,1234 @@
> +/*
> + *  Driver for the IDT RC32434 (Korina) on-chip ethernet controller.
> + *
> + *  Copyright 2004 IDT Inc. (rischelp@idt.com)
> + *  Copyright 2006 Felix Fietkau <nbd@openwrt.org>
> + *  Copyright 2008 Florian Fainelli <florian@openwrt.org>
> + *
> + *  This program is free software; you can redistribute  it and/or modify it
> + *  under  the terms of  the GNU General  Public License as published by the
> + *  Free Software Foundation;  either version 2 of the  License, or (at your
> + *  option) any later version.
[...]
> + *
    */

   /*
> + *  Writing to a DMA status register:
> + *
> + *  When writing to the status register, you should mask the bit you have
> + *  been testing the status register with. Both Tx and Rx DMA registers
> + *  should stick to this procedure.
[...]
> +#define DRV_NAME        "korina"
> +#define DRV_VERSION     "0.10"
> +#define DRV_RELDATE     "04Mar2008"

Almost :o)

[...]
> +#define MII_CLOCK 1250000 	/* no more than 2.5MHz */
                            ^ space before tab (vim highlights them)
[...]
> +#define RD_RING_SIZE 	(KORINA_NUM_RDS * sizeof(struct dma_desc))
                       ^ space before tab
[...]
> +#define TX_TIMEOUT 	(6000 * HZ / 1000)
                     ^ space before tab

[...]
> +static int korina_rx(struct net_device *dev, int limit)
> +{
[...]
> +				if (!skb_new)
> +					break;

Ok, let's go for it. I'd add a TODO/FIXME though.

[...]
> +static void korina_multicast_list(struct net_device *dev)
> +{
> +	struct korina_private *lp = netdev_priv(dev);
> +	unsigned long flags;
> +	struct dev_mc_list *dmi = dev->mc_list;
> +	u32 recognise = ETH_ARC_AB;	/* always accept broadcasts */
> +	int i;
> +
> +	/* Set promiscuous mode */
> +	if (dev->flags & IFF_PROMISC)
> +		recognise |= ETH_ARC_PRO;
> +
> +	else if ((dev->flags & IFF_ALLMULTI) || (dev->mc_count > 4))
> +		/* All multicast and broadcast */
> +		recognise |= ETH_ARC_AM;

Excess line break in the 'if ... else' above.

[...]
> +static void korina_alloc_ring(struct net_device *dev)
> +{
> +	struct korina_private *lp = netdev_priv(dev);
> +	int i;
> +
> +	/* Initialize the transmit descriptors */
> +	for (i = 0; i < KORINA_NUM_TDS; i++) {
> +		lp->td_ring[i].control = DMA_DESC_IOF;
> +		lp->td_ring[i].devcs = ETH_TX_FD | ETH_TX_LD;
> +		lp->td_ring[i].ca = 0;
> +		lp->td_ring[i].link = 0;
> +	}
> +	lp->tx_next_done = lp->tx_chain_head = lp->tx_chain_tail =
> +			lp->tx_full = lp->tx_count = 0;
> +	lp->tx_chain_status = desc_empty;
> +
> +	/* Initialize the receive descriptors */
> +	for (i = 0; i < KORINA_NUM_RDS; i++) {
> +		struct sk_buff *skb = lp->rx_skb[i];
> +
> +		skb = dev_alloc_skb(KORINA_RBSIZE + 2);
> +		if (!skb)
> +			break;
> +		skb_reserve(skb, 2);
> +		lp->rx_skb[i] = skb;
> +		lp->rd_ring[i].control = DMA_DESC_IOD |
> +				DMA_COUNT(KORINA_RBSIZE);
> +		lp->rd_ring[i].devcs = 0;
> +		lp->rd_ring[i].ca = CPHYSADDR(skb->data);
> +		lp->rd_ring[i].link = CPHYSADDR(&lp->rd_ring[i+1]);
> +	}
> +
> +	/* loop back */
> +	lp->rd_ring[i].link = CPHYSADDR(&lp->rd_ring[0]);
> +	lp->rx_next_done  = 0;
> +
> +	lp->rd_ring[i].control |= DMA_DESC_COD;
> +	lp->rx_chain_head = 0;
> +	lp->rx_chain_tail = 0;
> +	lp->rx_chain_status = desc_empty;

If the allocation fails, the driver will have to handle a shorter
than expected ring (it is probably ok, I have not checked it). You
may consider initializing the link field for each descriptor if
possible. See epic_init_ring() for some inspiration.

[...]
> +static int korina_close(struct net_device *dev)
> +{
> +	struct korina_private *lp = netdev_priv(dev);
> +	u32 tmp;
> +
> +	/* Disable interrupts */
> +	disable_irq(lp->rx_irq);
> +	disable_irq(lp->tx_irq);
> +	disable_irq(lp->ovr_irq);
> +	disable_irq(lp->und_irq);

The irqs will be disabled for whatever device shares them...

[...]
> +	free_irq(lp->rx_irq, dev);
> +	free_irq(lp->tx_irq, dev);
> +	free_irq(lp->ovr_irq, dev);
> +	free_irq(lp->und_irq, dev);

... and they will not be enabled again.

You should avoid disable_irq here and disable the irq with some
korina register write prior to free_irq instead.

[...]
> +static int korina_probe(struct platform_device *pdev)
> +{
> +	struct korina_device *bif = platform_get_drvdata(pdev);
> +	struct korina_private *lp;
> +	struct net_device *dev;
> +	struct resource *r;
> +	int retval, err;

It will work as is but you could merge both of those in a single
variable (name it 'rc' and the consequences will appear directly
in the diff between this patch and the next version).

[...]
> +	err = register_netdev(dev);
> +	if (err) {
> +		printk(KERN_ERR DRV_NAME
> +			": cannot register net device %d\n", err);
> +		retval = -EINVAL;
> +		goto probe_err_register;
> +	}
> +	return 0;

	return err/rc/retval
> +
> +probe_err_register:
> +	kfree(lp->td_ring);
> +probe_err_td_ring:
> +	iounmap(lp->tx_dma_regs);
> +probe_err_dma_tx:
> +	iounmap(lp->rx_dma_regs);
> +probe_err_dma_rx:
> +	iounmap(lp->eth_regs);
> +probe_err_out:
> +	free_netdev(dev);
> +	return retval;

See ?

[...]
> +static int korina_remove(struct platform_device *pdev)
> +{
> +	struct korina_device *bif = platform_get_drvdata(pdev);
> +	struct korina_private *lp = netdev_priv(bif->dev);
> +
> +	if (lp->eth_regs)
> +		iounmap(lp->eth_regs);
> +	if (lp->rx_dma_regs)
> +		iounmap(lp->rx_dma_regs);
> +	if (lp->tx_dma_regs)
> +		iounmap(lp->tx_dma_regs);

You can remove the 'if's.

It's getting better. Don't go away :o)

-- 
Ueimor
