From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] Add support the Korina (IDT RC32434) Ethernet MAC
Date: Mon, 10 Mar 2008 23:30:07 +0100
Message-ID: <20080310223007.GA2887@electric-eye.fr.zoreil.com>
References: <200803052345.06610.florian.fainelli@telecomint.eu> <1204886746.6387.17.camel@johannes.berg> <200803081905.46020.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>, Felix Fietkau <nbd@openwrt.org>
To: Florian Fainelli <florian.fainelli@telecomint.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:56579 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751520AbYCJWsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2008 18:48:40 -0400
Content-Disposition: inline
In-Reply-To: <200803081905.46020.florian.fainelli@telecomint.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <florian.fainelli@telecomint.eu> :
[...]
> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
> index 4c0d4e5..0338ab3 100644
> --- a/drivers/net/Makefile
> +++ b/drivers/net/Makefile
> @@ -169,6 +169,7 @@ obj-$(CONFIG_ZORRO8390) += zorro8390.o
>  obj-$(CONFIG_HPLANCE) += hplance.o 7990.o
>  obj-$(CONFIG_MVME147_NET) += mvme147.o 7990.o
>  obj-$(CONFIG_EQUALIZER) += eql.o
> +obj-$(CONFIG_KORINA) += korina.o
>  obj-$(CONFIG_MIPS_JAZZ_SONIC) += jazzsonic.o
>  obj-$(CONFIG_MIPS_AU1X00_ENET) += au1000_eth.o
>  obj-$(CONFIG_MIPS_SIM_NET) += mipsnet.o
> diff --git a/drivers/net/korina.c b/drivers/net/korina.c
> new file mode 100644
> index 0000000..ac5129d
> --- /dev/null
> +++ b/drivers/net/korina.c
> @@ -0,0 +1,1215 @@
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
> + *
> + *  THIS  SOFTWARE  IS PROVIDED   ``AS  IS'' AND   ANY  EXPRESS OR IMPLIED
> + *  WARRANTIES,   INCLUDING, BUT NOT  LIMITED  TO, THE IMPLIED WARRANTIES OF
> + *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN
> + *  NO  EVENT  SHALL   THE AUTHOR  BE    LIABLE FOR ANY   DIRECT, INDIRECT,
> + *  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
> + *  NOT LIMITED   TO, PROCUREMENT OF  SUBSTITUTE GOODS  OR SERVICES; LOSS OF
> + *  USE, DATA,  OR PROFITS; OR  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
> + *  ANY THEORY OF LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT
> + *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
> + *  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
> + *
> + *  You should have received a copy of the  GNU General Public License along
> + *  with this program; if not, write  to the Free Software Foundation, Inc.,
> + *  675 Mass Ave, Cambridge, MA 02139, USA.
> + *
> + *  Writing to a DMA status register:
> + *
> + *  When writing to the status register, you should mask the bit you have
> + *  been testing the status register with. Both Tx and Rx DMA registers
> + *  should stick to this procedure.
> + */
> +
> +#include <linux/module.h>
> +#include <linux/kernel.h>
> +#include <linux/moduleparam.h>
> +#include <linux/sched.h>
> +#include <linux/ctype.h>
> +#include <linux/types.h>
> +#include <linux/fcntl.h>
> +#include <linux/interrupt.h>
> +#include <linux/ptrace.h>

I would not have expected it there.

[...]
> +static int korina_send_packet(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct korina_private *lp = netdev_priv(dev);
> +	unsigned long flags;
> +	u32 length;
> +	struct dma_desc *td;
> +
> +	spin_lock_irqsave(&lp->lock, flags);
> +
> +	td = &lp->td_ring[lp->tx_chain_tail];
> +
> +	/* stop queue when full, drop pkts if queue already full */
> +	if (lp->tx_count >= (KORINA_NUM_TDS - 2)) {
> +		lp->tx_full = 1;
> +
> +		if (lp->tx_count == (KORINA_NUM_TDS - 2))
> +			netif_stop_queue(dev);
> +		else {
> +			dev->stats.tx_dropped++;
> +			dev_kfree_skb_any(skb);
> +			spin_unlock_irqrestore(&lp->lock, flags);
> +			return 1;

			return NETDEV_TX_BUSY;
> +		}
> +	}
> +
> +	lp->tx_count++;
> +
> +	lp->tx_skb[lp->tx_chain_tail] = skb;
> +
> +	length = skb->len;
> +	dma_cache_wback((u32)skb->data, skb->len);
> +
> +	/* Setup the transmit descriptor. */
> +	dma_cache_inv((u32) td, sizeof(*td));
> +	td->ca = CPHYSADDR(skb->data);
> +
> +	if (readl(&(lp->tx_dma_regs->dmandptr)) == 0) {
> +		if (lp->tx_chain_status == desc_empty) {
> +			/* Update tail */
> +			td->control = DMA_COUNT(length) |
> +					DMA_DESC_COF | DMA_DESC_IOF;
> +			/* Move tail */
> +			lp->tx_chain_tail = (lp->tx_chain_tail + 1) &
> +					KORINA_TDS_MASK;
> +			/* Write to NDPTR */
> +			writel(CPHYSADDR(&lp->td_ring[lp->tx_chain_head]),
> +					&(lp->tx_dma_regs->dmandptr));

You can kill the parenthesis.

> +			/* Move head to tail */
> +			lp->tx_chain_head = lp->tx_chain_tail;
> +		} else {
> +			/* Update tail */
> +			td->control = DMA_COUNT(length) |
> +					DMA_DESC_COF | DMA_DESC_IOF;
> +			/* Link to prev */
> +			lp->td_ring[(lp->tx_chain_tail - 1) &
> +					KORINA_TDS_MASK].control &=
> +					~DMA_DESC_COF;
> +			/* Link to prev */
> +			lp->td_ring[(lp->tx_chain_tail - 1) &
> +					KORINA_TDS_MASK].link =  CPHYSADDR(td);

You want a local variable to store (lp->tx_chain_tail - 1) & KORINA_TDS_MASK

[...]
> +/* Ethernet Rx DMA interrupt */
> +static irqreturn_t
> +korina_rx_dma_interrupt(int irq, void *dev_id)

   static irqreturn_t korina_rx_dma_interrupt(int irq, void *dev_id)

[...]
> +static int korina_rx(struct net_device *dev, int limit)
> +{
> +	struct korina_private *lp = netdev_priv(dev);
> +	struct dma_desc *rd = &lp->rd_ring[lp->rx_next_done];
> +	struct sk_buff *skb, *skb_new;
> +	u8 *pkt_buf;
> +	u32 devcs, count, pkt_len, pktuncrc_len;
> +	u32 dmas;
> +
> +	dma_cache_inv((u32)rd, sizeof(*rd));
> +	while ((count = KORINA_RBSIZE - (u32)DMA_COUNT(rd->control)) != 0) {
> +		/* init the var. used for the later
> +		 * operations within the while loop */
> +		skb_new = NULL;
> +		devcs = rd->devcs;
> +		pkt_len = RCVPKT_LENGTH(devcs);
> +		skb = lp->rx_skb[lp->rx_next_done];
> +
> +		if (count < 64) {
> +			dev->stats.rx_errors++;
> +			dev->stats.rx_dropped++;
> +		} else if ((devcs & ETH_RX_LD) != ETH_RX_LD) {
> +			/* check that this is a whole packet */
> +			/* WARNING: DMA_FD bit incorrectly set
> +			 * in Rc32434 (errata ref #077) */
> +			dev->stats.rx_errors++;
> +			dev->stats.rx_dropped++;
> +		} else if ((devcs & ETH_RX_ROK)) {
> +			/* must be the (first and) last descriptor then */
> +			pkt_buf = (u8 *)lp->rx_skb[lp->rx_next_done]->data;
> +
> +			pktuncrc_len = pkt_len - 4;
> +			/* invalidate the cache */
> +			dma_cache_inv((unsigned long)pkt_buf, pktuncrc_len);
> +
> +			/* Malloc up new buffer. */
> +			skb_new = dev_alloc_skb(KORINA_RBSIZE + 2);
> +
> +			if (skb_new) {
> +				/* Make room */
> +				skb_put(skb, pktuncrc_len);
> +
> +				skb->protocol = eth_type_trans(skb, dev);
> +
> +				/* pass the packet to upper layers */
> +				netif_receive_skb(skb);
> +				dev->last_rx = jiffies;
> +				dev->stats.rx_packets++;
> +				dev->stats.rx_bytes += pktuncrc_len;
> +
> +				if (devcs & ETH_RX_MP)
> +					dev->stats.multicast++;
> +
> +				/* 16 bit align */
> +				skb_reserve(skb_new, 2);
> +
> +				skb_new->dev = dev;

It will be set in eth_type_trans() anyway.

> +				lp->rx_skb[lp->rx_next_done] = skb_new;
> +			} else {
> +				printk(KERN_ERR DRV_NAME "%s :no memory"
> +					"dropping rx packet.\n", dev->name);
> +				dev->stats.rx_errors++;
> +				dev->stats.rx_dropped++;

You are dropping a perfectly fine packet. Can't you defer the Rx refill ?

> +			}
> +		} else {
> +			/* This should only happen if we
> +			 * enable accepting broken packets */
> +			dev->stats.rx_errors++;
> +			dev->stats.rx_dropped++;
> +
> +			/* add statistics counters */
> +			if (devcs & ETH_RX_CRC)
> +				dev->stats.rx_crc_errors++;
> +			if (devcs & ETH_RX_LOR)
> +				dev->stats.rx_length_errors++;
> +			if (devcs & ETH_RX_LE)
> +				dev->stats.rx_length_errors++;
> +			if (devcs & ETH_RX_OVR)
> +				dev->stats.rx_over_errors++;
> +			if (devcs & ETH_RX_CV)
> +				dev->stats.rx_frame_errors++;
> +			if (devcs & ETH_RX_CES)
> +				dev->stats.rx_length_errors++;

Stick a struct net_device_stats *stats = &dev->stats somewhere perhaps ?

[...]
> +static void korina_tx(struct net_device *dev)
> +{
> +	struct korina_private *lp = netdev_priv(dev);
> +	struct dma_desc *td = &lp->td_ring[lp->tx_next_done];
> +	u32 devcs;
> +	u32 dmas;
> +
> +	spin_lock(&lp->lock);

-> korina_tx_dma_interrupt(int irq, void *dev_id)
   [...]
   -> spin_lock(&lp->lock);
      [...]
      if (dmas & (DMA_STAT_FINI | DMA_STAT_ERR)) {
          korina_tx(dev);

*deadlock*

(it applies to korina_tx_dma_interrupt() too)

[...]
> +static void korina_check_media(struct net_device *dev, unsigned int init_media)
> +{
> +	struct korina_private *lp = netdev_priv(dev);
> +
> +	mii_check_media(&lp->mii_if, 0, init_media);
> +
> +	if (lp->mii_if.full_duplex)
> +		printk(KERN_INFO DRV_NAME "setting to full duplex\n");
> +	else
> +		printk(KERN_INFO DRV_NAME "setting to half duplex\n");

There is nothing wrong with the ternary operator.

[...]
> +static int korina_init(struct net_device *dev)
> +{
> +	struct korina_private *lp = netdev_priv(dev);
> +	int i, j;
> +
> +	/* Disable DMA */
> +	korina_abort_tx(dev);
> +	korina_abort_rx(dev);
> +
> +	/* reset ethernet logic */
> +	writel(0, &lp->eth_regs->ethintfc);
> +	while ((readl(&lp->eth_regs->ethintfc) & ETH_INT_FC_RIP))
> +		dev->trans_start = jiffies;
> +
> +	/* Enable Ethernet Interface */
> +	writel(ETH_INT_FC_EN, &lp->eth_regs->ethintfc);
> +
> +	/* Initialize the transmit Descriptors */
> +	for (i = 0; i < KORINA_NUM_TDS; i++) {
> +		lp->td_ring[i].control = DMA_DESC_IOF;
> +		lp->td_ring[i].devcs = ETH_TX_FD | ETH_TX_LD;
> +		lp->td_ring[i].ca = 0;
> +		lp->td_ring[i].link = 0;
> +		if (lp->tx_skb[i] != NULL) {
> +			dev_kfree_skb_any(lp->tx_skb[i]);
> +			lp->tx_skb[i] = NULL;
> +		}
> +	}
> +	lp->tx_next_done = lp->tx_chain_head = lp->tx_chain_tail =
> +		lp->tx_full = lp->tx_count = 0;
> +	lp->tx_chain_status = desc_empty;
> +
> +	/*
> +	 * Initialize the receive descriptors so that they
> +	 * become a circular linked list, ie. let the last
> +	 * descriptor point to the first again.
> +	 */
> +	for (i = 0; i < KORINA_NUM_RDS; i++) {
> +		struct sk_buff *skb = lp->rx_skb[i];
> +
> +		if (!lp->rx_skb[i]) {
> +			skb = dev_alloc_skb(KORINA_RBSIZE + 2);
> +			if (!skb) {
> +				printk(KERN_ERR DRV_NAME
> +					"%s: no memory in the system\n",
> +					dev->name);
> +				for (j = 0; j < KORINA_NUM_RDS; j ++)
> +					if (lp->rx_skb[j])
> +						dev_kfree_skb_any(lp->rx_skb[j]);
> +				return 1;

				return -ENOMEM;

(please propagate it gently)

[...]
> +static int korina_restart(struct net_device *dev)
> +{
> +	struct korina_private *lp = netdev_priv(dev);
> +
> +	/*
> +	 * Disable interrupts
> +	 */
> +	disable_irq(lp->rx_irq);
> +	disable_irq(lp->tx_irq);
> +	disable_irq(lp->ovr_irq);
> +	disable_irq(lp->und_irq);
> +
> +	writel(readl(&lp->tx_dma_regs->dmasm) |
> +				DMA_STAT_FINI | DMA_STAT_ERR,
> +				&lp->tx_dma_regs->dmasm);
> +	writel(readl(&lp->rx_dma_regs->dmasm) |
> +				DMA_STAT_DONE | DMA_STAT_HALT | DMA_STAT_ERR,
> +				&lp->rx_dma_regs->dmasm);
> +
> +	korina_init(dev);

Unchecked return value.

> +	korina_multicast_list(dev);
> +
> +	enable_irq(lp->und_irq);
> +	enable_irq(lp->ovr_irq);
> +	enable_irq(lp->tx_irq);
> +	enable_irq(lp->rx_irq);
> +
> +	return 0;
> +}
> +
> +static void korina_clear_and_restart(struct net_device *dev, u32 value)
> +{
> +	struct korina_private *lp = netdev_priv(dev);
> +
> +	netif_stop_queue(dev);
> +	writel(value, &lp->eth_regs->ethintfc);
> +	korina_restart(dev);
> +}
> +
> +/* Ethernet Tx Underflow interrupt */
> +static irqreturn_t
> +korina_und_interrupt(int irq, void *dev_id)

Needless line break.

[...]
> +static int korina_open(struct net_device *dev)
> +{
> +	struct korina_private *lp = netdev_priv(dev);
> +
> +	/* Initialize */
> +	if (korina_init(dev)) {
> +		printk(KERN_ERR DRV_NAME "%s: cannot open device\n", dev->name);
> +		return -ENXIO;

Please use gotos for the error paths in korina_open and propagate the
status code from korina_init.

> +	}
> +
> +	/* Install the interrupt handler
> +	 * that handles the Done Finished
> +	 * Ovr and Und Events */
> +	if (request_irq(lp->rx_irq, &korina_rx_dma_interrupt,
> +		IRQF_SHARED | IRQF_DISABLED,
> +			"Korina ethernet Rx", dev)) {
> +		printk(KERN_ERR DRV_NAME "%s: unable to get Rx DMA IRQ %d\n",
> +		    dev->name, lp->rx_irq);
> +		return -ENXIO;
> +	}
> +	if (request_irq(lp->tx_irq, &korina_tx_dma_interrupt,
> +		IRQF_SHARED | IRQF_DISABLED,
> +			"Korina ethernet Tx", dev)) {
> +		printk(KERN_ERR DRV_NAME "%s: unable to get Tx DMA IRQ %d\n",
> +		    dev->name, lp->tx_irq);
> +		free_irq(lp->rx_irq, dev);
> +		return -ENXIO;
> +	}
> +
> +	/* Install handler for overrun error. */
> +	if (request_irq(lp->ovr_irq, &korina_ovr_interrupt,
> +			IRQF_SHARED | IRQF_DISABLED,
> +			"Ethernet Overflow", dev)) {
> +		printk(KERN_ERR DRV_NAME"%s: unable to get OVR IRQ %d\n",
> +		    dev->name, lp->ovr_irq);
> +		free_irq(lp->rx_irq, dev);
> +		free_irq(lp->tx_irq, dev);
> +		return -ENXIO;
> +	}
> +
> +	/* Install handler for underflow error. */
> +	if (request_irq(lp->und_irq, &korina_und_interrupt,
> +			IRQF_SHARED | IRQF_DISABLED,
> +			"Ethernet Underflow", dev)) {
> +		printk(KERN_ERR DRV_NAME "%s: unable to get UND IRQ %d\n",
> +		    dev->name, lp->und_irq);
> +		free_irq(lp->rx_irq, dev);
> +		free_irq(lp->tx_irq, dev);
> +		free_irq(lp->ovr_irq, dev);
> +		return -ENXIO;
> +	}
> +	return 0;
> +}
[...]
> +static int korina_probe(struct platform_device *pdev)
> +{
> +	struct korina_device *bif = (struct korina_device *)pdev->dev.platform_data;
> +	struct korina_private *lp;
> +	struct net_device *dev;
> +	struct resource *r;
> +	int retval, err;
> +
> +	dev = alloc_etherdev(sizeof(struct korina_private));
> +	if (!dev) {
> +		printk(KERN_ERR DRV_NAME ": alloc_etherdev failed\n");
> +		return -ENOMEM;
> +	}
> +	SET_NETDEV_DEV(dev, &pdev->dev);
> +	platform_set_drvdata(pdev, dev);
> +	lp = netdev_priv(dev);
> +
> +	bif->dev = dev;
> +	memcpy(dev->dev_addr, bif->mac, 6);
> +
> +	lp->rx_irq = platform_get_irq_byname(pdev, "korina_rx");
> +	lp->tx_irq = platform_get_irq_byname(pdev, "korina_tx");
> +	lp->ovr_irq = platform_get_irq_byname(pdev, "korina_ovr");
> +	lp->und_irq = platform_get_irq_byname(pdev, "korina_und");
> +
> +	r = platform_get_resource_byname(pdev, IORESOURCE_MEM, "korina_regs");
> +	dev->base_addr = r->start;
> +	lp->eth_regs = ioremap_nocache(r->start, r->end - r->start);
> +	if (!lp->eth_regs) {
> +		printk(KERN_ERR DRV_NAME "cannot remap registers\n");
> +		retval = -ENXIO;
> +		goto probe_err_out;
> +	}
> +
> +	r = platform_get_resource_byname(pdev, IORESOURCE_MEM, "korina_dma_rx");
> +	lp->rx_dma_regs = ioremap_nocache(r->start, r->end - r->start);
> +	if (!lp->rx_dma_regs) {
> +		printk(KERN_ERR DRV_NAME "cannot remap Rx DMA registers\n");
> +		retval = -ENXIO;
> +		goto probe_err_dma_rx;
> +	}
> +
> +	r = platform_get_resource_byname(pdev, IORESOURCE_MEM, "korina_dma_tx");
> +	lp->tx_dma_regs = ioremap_nocache(r->start, r->end - r->start);
> +	if (!lp->tx_dma_regs) {
> +		printk(KERN_ERR DRV_NAME "cannot remap Tx DMA registers\n");
> +		retval = -ENXIO;
> +		goto probe_err_dma_tx;
> +	}
> +
> +	lp->td_ring = kmalloc(TD_RING_SIZE + RD_RING_SIZE, GFP_KERNEL);
> +	if (!lp->td_ring) {
> +		printk(KERN_ERR DRV_NAME "cannot allocate descriptors\n");
> +		retval = -ENOMEM;
> +		goto probe_err_td_ring;
> +	}
> +
> +	dma_cache_inv((unsigned long)(lp->td_ring),
> +			TD_RING_SIZE + RD_RING_SIZE);
> +
> +	/* now convert TD_RING pointer to KSEG1 */
> +	lp->td_ring = (struct dma_desc *)KSEG1ADDR(lp->td_ring);
> +	lp->rd_ring = &lp->td_ring[KORINA_NUM_TDS];
> +
> +	spin_lock_init(&lp->lock);
> +	/* just use the rx dma irq */
> +	dev->irq = lp->rx_irq;
> +	lp->dev = dev;
> +
> +	dev->open = korina_open;
> +	dev->stop = korina_close;
> +	dev->hard_start_xmit = korina_send_packet;
> +	dev->set_multicast_list = &korina_multicast_list;
> +	dev->ethtool_ops = &netdev_ethtool_ops;
> +	dev->tx_timeout = korina_tx_timeout;
> +	dev->watchdog_timeo = TX_TIMEOUT;
> +	dev->do_ioctl = &korina_ioctl;
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +	dev->poll_controller = korina_poll_controller;
> +#endif
> +	netif_napi_add(dev, &lp->napi, korina_poll, 64);
> +
> +	lp->phy_addr = (((lp->rx_irq == 0x2c? 1:0) << 8) | 0x05);
> +	lp->mii_if.dev = dev;
> +	lp->mii_if.mdio_read = mdio_read;
> +	lp->mii_if.mdio_write = mdio_write;
> +	lp->mii_if.phy_id = lp->phy_addr;
> +	lp->mii_if.phy_id_mask = 0x1f;
> +	lp->mii_if.reg_num_mask = 0x1f;
> +
> +	err = register_netdev(dev);
> +	if (err) {
> +		printk(KERN_ERR DRV_NAME
> +			": cannot register net device %d\n", err);
> +		retval = -EINVAL;
> +		goto probe_err_out;
> +	}
> +
> +	printk(KERN_INFO DRV_NAME ": Rx IRQ %d\nTx IRQ %d\n",
> +				lp->rx_irq, lp->tx_irq);
> +
> +	return 0;
> +
> +probe_err_dma_rx:
> +	iounmap(lp->eth_regs);
> +probe_err_dma_tx:
> +	iounmap(lp->rx_dma_regs);
> +probe_err_td_ring:
> +	iounmap(lp->tx_dma_regs);
> +probe_err_out:
> +	iounmap(lp->td_ring);

Broken, see above:
	lp->td_ring = kmalloc(TD_RING_SIZE + RD_RING_SIZE, GFP_KERNEL);

> +	free_netdev(dev);
> +	return retval;
> +}
> +
> +static int korina_remove(struct platform_device *pdev)
> +{
> +	struct korina_device *bif = pdev->dev.platform_data;
> +
> +	if (bif->dev) {

Can it really happen ?

-- 
Ueimor
