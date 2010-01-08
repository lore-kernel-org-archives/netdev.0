From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/1] net: Add Aeroflex Gaisler GRETH 10/100/1G Ethernet
	MAC driver
Date: Fri, 08 Jan 2010 22:57:39 +0000
Message-ID: <1262991459.17358.63.camel@achroite.uk.solarflarecom.com>
References: <1262965531-4800-1-git-send-email-kristoffer@gaisler.com>
	 <1262965531-4800-2-git-send-email-kristoffer@gaisler.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kristoffer Glembo <kristoffer@gaisler.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:52671 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754135Ab0AHW5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 17:57:43 -0500
In-Reply-To: <1262965531-4800-2-git-send-email-kristoffer@gaisler.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-01-08 at 16:45 +0100, Kristoffer Glembo wrote:
[...]
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index dd9a09c..806c127 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -983,6 +983,30 @@ config ETHOC
>  	help
>  	  Say Y here if you want to use the OpenCores 10/100 Mbps Ethernet MAC.
>  
> +config GRETH
> +	tristate "Aeroflex Gaisler GRETH Ethernet MAC support"
> +	depends on OF
> +	select PHYLIB
> +	select CRC32
> +	help
> +	  Say Y here if you want to use the Aeroflex Gaisler GRETH Ethernet MAC.
> +
> +config GRETH_MACMSB
> +	hex "MSB 24 bits of Ethernet MAC address (hex)" 
> +	default 00007A
> +	depends on GRETH
> +	---help---
> +	  Most significant 24 bits of the default MAC address
> +	  that is initialized when driver probes. 
> +
> +config GRETH_MACLSB
> +	hex "LSB 24 bits of MAC address (hex)" 
> +	default CC0012
> +	depends on GRETH
> +	---help---
> +	  Least significant 24 bits of the default MAC address
> +	  that is initialized when driver probes. 

This is just about the worst possible way to configure the MAC address.
You should be getting it from EEPROM/flash or OpenFirmware properties.

>  config SMC911X
>  	tristate "SMSC LAN911[5678] support"
>  	select CRC32
> @@ -2489,6 +2513,30 @@ config S6GMAC
>  
>  source "drivers/net/stmmac/Kconfig"
>  
> +config GRETH
> +	tristate "Aeroflex Gaisler GRETH_GBIT Ethernet MAC support"
> +	depends on OF
> +	select PHYLIB
> +	select CRC32
> +	help
> +	  Say Y here if you want to use the Aeroflex Gaisler GRETH_GBIT Ethernet MAC.
> +
> +config GRETH_MACMSB
> +	hex "MSB 24 bits of Ethernet MAC address (hex)" 
> +	default 00007A
> +	depends on GRETH
> +	---help---
> +	  Most significant 24 bits of the default MAC address
> +	  that is initialized when driver probes. 
> +
> +config GRETH_MACLSB
> +	hex "LSB 24 bits of MAC address (hex)" 
> +	default CC0012
> +	depends on GRETH
> +	---help---
> +	  Least significant 24 bits of the default MAC address
> +	  that is initialized when driver probes. 
> +

Is this driver really so good that we should configure it twice?

[...] 
> diff --git a/drivers/net/greth.c b/drivers/net/greth.c
> new file mode 100644
> index 0000000..7df4bee
[...]
> +#define GRETH_REGLOAD(a)	    (__raw_readl(&(a)))
> +#define GRETH_REGSAVE(a, v)         (__raw_writel(v, &(a)))
> +#define GRETH_REGORIN(a, v)         (GRETH_REGSAVE(a, (GRETH_REGLOAD(a) | (v))))
> +#define GRETH_REGANDIN(a, v)        (GRETH_REGSAVE(a, (GRETH_REGLOAD(a) & (v))))

I think you need an mmiowb() after the __raw_writel().

Also, are you sure the registers are going to match host byte order?

> +#ifdef DEBUG
> +static void greth_print_rx_packet(unsigned long addr, int len)
> +{
> +	int i;
> +
> +	pr_debug("RX packet: addr = %x, len = %d\n", addr, len);
> +
> +	for (i = 0; i < len; i++) {
> +
> +		if (!(i % 16))
> +			pr_debug("\n");
> +
> +		pr_debug(" %.2x", *(((unsigned char *) addr) + i));
> +	}
> +	pr_debug("\n");
> +}

Use print_hex_dump().

> +static void greth_print_tx_packet(struct sk_buff *skb)
> +{
> +	int i;
> +	int j;
> +	int count;
> +
> +	pr_debug("TX packet: len = %d nr_frags = %d \n", skb->len, skb_shinfo(skb)->nr_frags);
> +
> +	count = 0;
> +	for (i = 0; i < skb->len - skb->data_len; i++) {
> +
> +		if (!(count % 16))
> +			pr_debug("\n");
> +
> +		pr_debug(" %.2x", *(((unsigned char *) skb->data) + i));
> +		count++;
> +	}
> +
> +	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
> +
> +		for (j = 0; j < skb_shinfo(skb)->frags[i].size; j++) {
> +
> +			if (!(count % 16))
> +				pr_debug("\n");
> +
> +			pr_debug(" %.2x", *((unsigned char *)
> +					    (phys_to_virt
> +					     (skb_shinfo(skb)->frags[i].page) +
> +					     skb_shinfo(skb)->frags[i].page_offset + j)));

WTF?  phys_to_virt() does not work on pointers to struct page.

> +			count++;
> +		}
> +	}
> +	pr_debug("\n");
> +}
> +#endif
> +
> +/* Wait for a register change with a timeout, jiffies used has time reference */
> +#define wait_loop(wait_statement, timeout, label_on_timeout, arg_on_timeout) \
> +	{ \
> +		unsigned long _timeout = jiffies + HZ*timeout; \

You want to busy-wait for multiple seconds?!  And this apparently only
used for MDIO.  There is no way you should be waiting multiple seconds
for MDIO, and in any case your MDIO functions should be called in
process context so you can sleep.

> +		while (wait_statement) { \
> +			if (time_after(jiffies, _timeout)) { \
> +				arg_on_timeout; \
> +goto label_on_timeout; \
> +			} \
> +		} \
> +	}
> +
> +static int greth_init_rings(struct greth_private *greth)
> +{
> +	struct sk_buff *skb;
> +	struct greth_bd *rx_bd, *tx_bd;
> +	int i;
> +
> +	rx_bd = greth->rx_bd_base;
> +	tx_bd = greth->tx_bd_base;
> +
> +	/* Initialize descriptor rings and buffers */
> +	if (greth->gbit_mac) {
> +
> +		for (i = 0; i < GRETH_RXBD_NUM; i++) {
> +			skb = netdev_alloc_skb(greth->netdev, MAX_FRAME_SIZE + NET_IP_ALIGN);
> +			skb_reserve(skb, NET_IP_ALIGN);
> +			if (skb == NULL) {
> +				return -ENOMEM;
> +			}

It's a bit late to check for that.

> +			rx_bd[i].addr = dma_map_single(greth->dev,
> +						       skb->data,
> +						       MAX_FRAME_SIZE + NET_IP_ALIGN,
> +						       DMA_FROM_DEVICE);

And what if that fails?


> +			greth->rx_skbuff[i] = skb;
> +			rx_bd[i].stat = GRETH_BD_EN | GRETH_BD_IE;
> +		}
> +
> +	} else {
> +
> +		/* 10/100 MAC uses preallocated buffers */
> +		greth->tx_bufs = kmalloc(MAX_FRAME_SIZE * GRETH_TXBD_NUM, GFP_KERNEL);

This is a very large region (~200K) to allocate contiguously.  You
should try to avoid this if you can.

> +		if (greth->tx_bufs == NULL) {
> +			return -ENOMEM;
> +		}
> +
> +		greth->rx_bufs = kmalloc(MAX_FRAME_SIZE * GRETH_RXBD_NUM, GFP_KERNEL);
> +
> +		if (greth->rx_bufs == NULL) {
> +			kfree(greth->tx_bufs);
> +			return -ENOMEM;
> +		}
> +
> +		for (i = 0; i < GRETH_RXBD_NUM; i++) {
> +			rx_bd[i].addr = dma_map_single(greth->dev,
> +						       greth->rx_bufs +
> +						       MAX_FRAME_SIZE * i,
> +						       MAX_FRAME_SIZE, DMA_FROM_DEVICE);

If the buffers are contiguous, I don't see any need to allocate multiple
DMA mappings.

> +			rx_bd[i].stat = GRETH_BD_EN | GRETH_BD_IE;
> +		}
> +		for (i = 0; i < GRETH_TXBD_NUM; i++) {
> +			tx_bd[i].addr = dma_map_single(greth->dev,
> +						       greth->tx_bufs +
> +						       MAX_FRAME_SIZE * i,
> +						       MAX_FRAME_SIZE, DMA_TO_DEVICE);
> +			tx_bd[i].stat = 0;
> +		}
> +	}
> +	rx_bd[GRETH_RXBD_NUM - 1].stat |= GRETH_BD_WR;
> +
> +	/* Initialize pointers. */
> +	greth->rx_cur = 0;
> +	greth->tx_next = 0;
> +	greth->tx_last = 0;
> +	greth->tx_free = GRETH_TXBD_NUM;
> +
> +	/* Initialize descriptor base address */
> +	GRETH_REGSAVE(greth->regs->tx_desc_p, greth->tx_bd_base_phys);
> +	GRETH_REGSAVE(greth->regs->rx_desc_p, greth->rx_bd_base_phys);
> +
> +	return 0;
> +}
> +
> +static void greth_clean_rings(struct greth_private *greth)
> +{
> +	int i;
> +
> +	/* Free buffers */
> +	if (greth->gbit_mac) {
> +		for (i = 0; i < GRETH_RXBD_NUM; i++) {
> +			if (greth->rx_skbuff[i] != NULL) {
> +				dev_kfree_skb(greth->rx_skbuff[i]);
> +			}
> +		}
> +		for (i = 0; i < GRETH_TXBD_NUM; i++) {
> +			if (greth->tx_skbuff[i] != NULL) {
> +				dev_kfree_skb(greth->tx_skbuff[i]);
> +			}
> +		}
> +	} else {
> +		kfree(greth->tx_bufs);
> +		kfree(greth->rx_bufs);
> +	}
> +}
> +
> +static int greth_open(struct net_device *dev)
> +{
> +	struct greth_private *greth = netdev_priv(dev);
> +	struct greth_regs *regs = (struct greth_regs *) greth->regs;
> +	int err;
> +
> +	err = greth_init_rings(greth);
> +	if (err) {
> +		dev_err(&dev->dev, "Could not allocate memory for DMA rings\n");
> +		return err;
> +	}
> +
> +	err = request_irq(greth->irq, greth_interrupt, 0, "eth", (void *) dev);
> +	if (err) {
> +		dev_err(&dev->dev, "Could not allocate interrupt %d\n", dev->irq);

		greth_clean_rings(greth);

> +		return err;
> +	}
> +
> +	if (netif_queue_stopped(dev)) {
> +		dev_dbg(&dev->dev, " resuming queue\n");
> +		netif_wake_queue(dev);
> +	} else {
> +		dev_dbg(&dev->dev, " starting queue\n");
> +		netif_start_queue(dev);
> +	}

Just call netif_start_queue(dev).  There is no need to wake up the qdisc
as the queue must be empty at this point.

> +	napi_enable(&greth->napi);
> +
> +	/* Enable receiver and rx/tx interrupts */
> +	GRETH_REGORIN(regs->control, GRETH_RXEN | GRETH_RXI | GRETH_TXI);
> +	return 0;
> +
> +}
> +
> +static int greth_close(struct net_device *dev)
> +{
> +	struct greth_private *greth = netdev_priv(dev);
> +	struct greth_regs *regs = (struct greth_regs *) greth->regs;
> +
> +	napi_disable(&greth->napi);
> +
> +	free_irq(greth->irq, (void *) dev);

Surely this is too early as you can still receive TX completion
interrupts.

> +	/* Disable receiver and transmitter */
> +	GRETH_REGANDIN(regs->control, ~(GRETH_RXEN | GRETH_TXEN));
> +
> +	if (!netif_queue_stopped(dev))
> +		netif_stop_queue(dev);

No need for the condition.

> +	greth_clean_rings(greth);
> +
> +	return 0;
> +}
> +
[...]
> +static int greth_start_xmit_gbit(struct sk_buff *skb, struct net_device *dev)
> +{
[...]
> +		bdp->stat = status;
> +
> +		greth->tx_next = ((greth->tx_next + 1) & GRETH_TXBD_NUM_MASK);
> +		greth->tx_free--;
> +
> +		bdp = greth->tx_bd_base + greth->tx_next;
> +
> +		/* Add descriptors for the rest of the frags */
> +		for (i = 0; i < nr_frags; i++) {
> +
> +			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
> +
> +			greth->tx_skbuff[greth->tx_next] = NULL;
> +			greth->tx_free--;
> +
> +			bdp->addr = dma_map_page(greth->dev,
> +						 frag->page,
> +						 frag->page_offset, frag->size, DMA_TO_DEVICE);

You need to check for failure.

[...]
> +static irqreturn_t greth_interrupt(int irq, void *dev_id)
> +{
> +	struct net_device *dev = dev_id;
> +	struct greth_private *greth;
> +	u32 status;
> +
> +	greth = netdev_priv(dev);
> +
> +	spin_lock(&greth->devlock);
> +
> +	/* Get the interrupt events that caused us to be here. */
> +	status = GRETH_REGLOAD(greth->regs->status);
> +
> +	/* Clear interrupt status */
> +	GRETH_REGORIN(greth->regs->status,
> +		      status & (GRETH_INT_RX | GRETH_INT_TX | GRETH_STATUS_PHYSTAT));
> +
> +	/* Handle rx and tx interrupts through poll */
> +	if (status & (GRETH_INT_RX | GRETH_INT_TX)) {
> +		if (napi_schedule_prep(&greth->napi)) {
> +			/* Disable interrupts and schedule poll() */
> +			GRETH_REGANDIN(greth->regs->control, ~(GRETH_RXI | GRETH_TXI));
> +			__napi_schedule(&greth->napi);
> +		}

I think you should mask interrupts unconditionally, to avoid the
possibility of an interrupt storm.  And then you can just use
napi_schedule().

> +	}
> +
> +	spin_unlock(&greth->devlock);
> +
> +	return IRQ_HANDLED;

Are you sure you always get an exclusive IRQ?  If the IRQ can be shared
then you will need to return IRQ_NONE when status == 0 (or whatever
indicates that no interrupt was raised by your device).

> +}
> +
> +static void greth_clean_tx(struct net_device *dev)
> +{
> +	struct greth_private *greth;
> +	struct greth_bd *bdp;
> +	u32 stat;
> +
> +	greth = netdev_priv(dev);
> +
> +	while (1) {
> +		bdp = greth->tx_bd_base + greth->tx_last;
> +		stat = bdp->stat;
> +
> +		if (unlikely(stat & GRETH_BD_EN))
> +			break;
> +
> +		if (greth->tx_free == GRETH_TXBD_NUM)
> +			break;
> +
> +		/* Check status for errors
> +		 */
> +		if (unlikely(stat & GRETH_TXBD_STATUS)) {
> +			greth->stats.tx_errors++;
> +			if (stat & GRETH_TXBD_ERR_AL)
> +				greth->stats.tx_aborted_errors++;
> +			if (stat & GRETH_TXBD_ERR_UE)
> +				greth->stats.tx_fifo_errors++;
> +		}
> +		greth->stats.tx_packets++;
> +		greth->tx_last = (greth->tx_last + 1) & GRETH_TXBD_NUM_MASK;
> +		greth->tx_free++;
> +	}
> +
> +	if (unlikely(netif_queue_stopped(dev) && greth->tx_free > 0)) {
> +		netif_wake_queue(dev);
> +	}

The netif_queue_stopped(dev) condition is redundant.

> +}
> +
> +static void greth_clean_tx_gbit(struct net_device *dev)
> +{
> +	struct greth_private *greth;
> +	struct greth_bd *bdp;
> +	struct sk_buff *skb;
> +	u32 stat;
> +
> +	greth = netdev_priv(dev);
> +
> +	while (1) {
> +		bdp = greth->tx_bd_base + greth->tx_last;
> +		stat = bdp->stat;
> +
> +		if (stat & GRETH_BD_EN)
> +			break;
> +
> +		if (greth->tx_free >= GRETH_TXBD_NUM)
> +			break;
> +
> +		/* Check status for errors */
> +		if (unlikely(stat & GRETH_TXBD_STATUS)) {
> +			greth->stats.tx_errors++;
> +			if (stat & GRETH_TXBD_ERR_AL)
> +				greth->stats.tx_aborted_errors++;
> +			if (stat & GRETH_TXBD_ERR_UE)
> +				greth->stats.tx_fifo_errors++;
> +			if (stat & GRETH_TXBD_ERR_LC)
> +				greth->stats.tx_aborted_errors++;
> +		}
> +		greth->stats.tx_packets++;
> +
> +		dma_unmap_single(greth->dev,
> +				 bdp->addr, MAX_FRAME_SIZE + NET_IP_ALIGN, DMA_TO_DEVICE);

That does not match the DMA mappings you allocated.

> +		skb = greth->tx_skbuff[greth->tx_last];
> +		if (skb != NULL) {
> +			dev_kfree_skb_irq(skb);
> +		}
> +		greth->tx_last = (greth->tx_last + 1) & GRETH_TXBD_NUM_MASK;
> +		greth->tx_free++;
> +	}
> +
> +	if (unlikely(netif_queue_stopped(dev) && greth->tx_free > (MAX_SKB_FRAGS + 1))) {
> +		netif_wake_queue(dev);
> +	}
> +}
[...]

Didn't read any further.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

