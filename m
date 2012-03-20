From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/1] ARC VMAC driver.
Date: Tue, 20 Mar 2012 12:54:22 +0100
Message-ID: <20120320115422.GA7226@electric-eye.fr.zoreil.com>
References: <CALtMJECEj7dtseSas9708L6xKs2fobS9_m3bVY_BCe6icLWRsA@mail.gmail.com> <1332232945-27869-1-git-send-email-afenkart@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Andreas Fenkart <afenkart@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:33866 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757346Ab2CTL41 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2012 07:56:27 -0400
Content-Disposition: inline
In-Reply-To: <1332232945-27869-1-git-send-email-afenkart@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andreas Fenkart <afenkart@gmail.com> :
> This is a driver for the MAC IP block from ARC International. It
> is based on an existing driver found in ARC Linux distribution,
> but essentially, a full rewrite.
> 
> Signed-off-by: Andreas Fenkart <afenkart@gmail.com>
> ---
>  drivers/net/ethernet/Kconfig   |    9 +
>  drivers/net/ethernet/Makefile  |    1 +
>  drivers/net/ethernet/arcvmac.c | 1472 ++++++++++++++++++++++++++++++++++++++++
>  drivers/net/ethernet/arcvmac.h |  269 ++++++++
>  4 files changed, 1751 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
> index 597f4d4..4b6baf8 100644
> --- a/drivers/net/ethernet/Kconfig
> +++ b/drivers/net/ethernet/Kconfig
> @@ -23,6 +23,15 @@ source "drivers/net/ethernet/aeroflex/Kconfig"
>  source "drivers/net/ethernet/alteon/Kconfig"
>  source "drivers/net/ethernet/amd/Kconfig"
>  source "drivers/net/ethernet/apple/Kconfig"
> +
> +config ARCVMAC
> +	tristate "ARC VMAC ethernet driver"
> +	select MII
> +	select PHYLIB
> +	select CRC32
> +	help
> +	  MAC present Zoran43xx, IP from ARC international

It may not hurt to tell if it targets gigabit or fast ethernet.

> +
>  source "drivers/net/ethernet/atheros/Kconfig"
>  source "drivers/net/ethernet/cadence/Kconfig"
>  source "drivers/net/ethernet/adi/Kconfig"
> diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
> index be5dde0..cb61799 100644
> --- a/drivers/net/ethernet/Makefile
> +++ b/drivers/net/ethernet/Makefile
> @@ -9,6 +9,7 @@ obj-$(CONFIG_GRETH) += aeroflex/
>  obj-$(CONFIG_NET_VENDOR_ALTEON) += alteon/
>  obj-$(CONFIG_NET_VENDOR_AMD) += amd/
>  obj-$(CONFIG_NET_VENDOR_APPLE) += apple/
> +obj-$(CONFIG_ARCVMAC) += arcvmac.o

I am not sure we want it directly under drivers/net/ethernet.

[...]
> diff --git a/drivers/net/ethernet/arcvmac.c b/drivers/net/ethernet/arcvmac.c
> new file mode 100644
> index 0000000..d512806
> --- /dev/null
> +++ b/drivers/net/ethernet/arcvmac.c
[...]
> +				   unsigned char hwaddr[ETH_ALEN])
> +{
> +	struct vmac_priv *ap = netdev_priv(dev);
> +	u32 mac_lo, mac_hi;
> +
> +	WARN_ON(!hwaddr);

Useless. It will issue a nice Oops a few lines below anyway.

> +	mac_lo = vmac_readl(ap, ADDRL);
> +	mac_hi = vmac_readl(ap, ADDRH);
> +
> +	hwaddr[0] = (mac_lo >> 0) & 0xff;
> +	hwaddr[1] = (mac_lo >> 8) & 0xff;
> +	hwaddr[2] = (mac_lo >> 16) & 0xff;
> +	hwaddr[3] = (mac_lo >> 24) & 0xff;
> +	hwaddr[4] = (mac_hi >> 0) & 0xff;
> +	hwaddr[5] = (mac_hi >> 8) & 0xff;
> +	return hwaddr;
> +}
[...]
> +static int __devinit vmac_mii_init(struct vmac_priv *ap)
> +{
> +	unsigned long flags;
> +	int err, i;
> +
> +	spin_lock_irqsave(&ap->lock, flags);
> +
> +	ap->mii_bus = mdiobus_alloc();

Bug: non GFP_ATOMIC alloc with spinlock held.

> +	if (!ap->mii_bus)
> +		return -ENOMEM;
> +
> +	ap->mii_bus->name = "vmac_mii_bus";
> +	ap->mii_bus->read = &vmac_mdio_read;
> +	ap->mii_bus->write = &vmac_mdio_write;
> +
> +	snprintf(ap->mii_bus->id, MII_BUS_ID_SIZE, "%x", 0);
> +
> +	ap->mii_bus->priv = ap;
> +
> +	err = -ENOMEM;
> +	ap->mii_bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);

Sic.

[...]
> +static void vmac_mii_exit_unlocked(struct net_device *dev)
> +{
> +	struct vmac_priv *ap = netdev_priv(dev);
> +
> +	if (ap->phy_dev)

It can't be NULL.

> +		phy_disconnect(ap->phy_dev);
> +
> +	mdiobus_unregister(ap->mii_bus);
> +	kfree(ap->mii_bus->irq);
> +	mdiobus_free(ap->mii_bus);
> +}
> +
> +static int vmacether_get_settings(struct net_device *dev,
> +				  struct ethtool_cmd *cmd)
> +{
> +	struct vmac_priv *ap = netdev_priv(dev);
> +	struct phy_device *phydev = ap->phy_dev;
> +
> +	if (!phydev)
> +		return -ENODEV;

It can't be NULL here either.

Please check you driver. Most of times, it can't be NULL.

> +
> +	return phy_ethtool_gset(phydev, cmd);
> +}
> +
> +static int vmacether_set_settings(struct net_device *dev,
> +				  struct ethtool_cmd *cmd)
> +{
> +	struct vmac_priv *ap = netdev_priv(dev);
> +	struct phy_device *phydev = ap->phy_dev;
> +
> +	if (!phydev)
> +		return -ENODEV;

Sic.

> +
> +	return phy_ethtool_sset(phydev, cmd);
> +}
> +
> +static int vmac_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
> +{
> +	struct vmac_priv *ap = netdev_priv(dev);
> +	struct phy_device *phydev = ap->phy_dev;
> +
> +	if (!netif_running(dev))
> +		return -EINVAL;
> +
> +	if (!phydev)
> +		return -ENODEV;

Sic.

[...]
> +static int update_error_counters_unlocked(struct net_device *dev, int status)
> +{
> +	struct vmac_priv *ap = netdev_priv(dev);
> +
> +	dev_dbg(&ap->pdev->dev, "rx error counter overrun. status = 0x%x\n",
> +		status);
> +
> +	/* programming error */
> +	WARN_ON(status & TXCH_MASK);
> +	WARN_ON(!(status & (MSER_MASK | RXCR_MASK | RXFR_MASK | RXFL_MASK)));
> +
> +	if (status & MSER_MASK)
> +		dev->stats.rx_over_errors += 256; /* ran out of BD */
> +	if (status & RXCR_MASK)
> +		dev->stats.rx_crc_errors += 256;
> +	if (status & RXFR_MASK)
> +		dev->stats.rx_frame_errors += 256;
> +	if (status & RXFL_MASK)
> +		dev->stats.rx_fifo_errors += 256;

I would not mind a local &dev->stats variable.

[...]
> +static void update_tx_errors_unlocked(struct net_device *dev, int status)
> +{
> +	struct vmac_priv *ap = netdev_priv(dev);
> +
> +	if (status & BD_UFLO)
> +		dev->stats.tx_fifo_errors++;
> +
> +	if (ap->duplex)
> +		return;
> +
> +	/* half duplex flags */
> +	if (status & BD_LTCL)
> +		dev->stats.tx_window_errors++;
> +	if (status & BD_RETRY_CT)
> +		dev->stats.collisions += (status & BD_RETRY_CT) >> 24;
> +	if (status & BD_DROP)  /* too many retries */
> +		dev->stats.tx_aborted_errors++;
> +	if (status & BD_DEFER)
> +		dev_vdbg(&ap->pdev->dev, "\"defer to traffic\"\n");
> +	if (status & BD_CARLOSS)
> +		dev->stats.tx_carrier_errors++;

Same thing as above.

[...]
> +static int vmac_poll(struct napi_struct *napi, int budget)
> +{
> +	struct vmac_priv *ap;
> +	int rx_work_done;
> +
> +	ap = container_of(napi, struct vmac_priv, napi);

You can 'struct vmac_priv *ap = container_of(napi ..."

> +
> +	vmac_tx_reclaim_unlocked(ap->dev, false);
> +
> +	rx_work_done = vmac_rx_receive(ap->dev, budget);
> +	if (rx_work_done >= budget) {
> +		/* rx queue is not yet empty/clean */
> +		return rx_work_done;
> +	}

Please no comment nor curly brace.

> +
> +	/* no more packet in rx/tx queue, remove device from poll queue */
> +	napi_complete(napi);
> +
> +	/* clear status, only 1' affect register state */
> +	vmac_writel(ap, RXINT_MASK | TXINT_MASK, STAT);
> +
> +	/* reenable IRQ */
> +	vmac_toggle_rxint_unlocked(ap->dev, true);
> +	vmac_toggle_txint_unlocked(ap->dev, true);
> +
> +	return rx_work_done;
> +}
> +
> +static irqreturn_t vmac_intr(int irq, void *dev_instance)
> +{
> +	struct net_device *dev = dev_instance;
> +	struct vmac_priv *ap = netdev_priv(dev);
> +	u32 status;
> +
> +	spin_lock(&ap->lock);
> +
> +	status = vmac_readl(ap, STAT);
> +	vmac_writel(ap, status, STAT);

I do not know what you are trying to achieve with the lock but it is not
held in start_xmit when STAT is written.

> +
> +	if (unlikely(ap->shutdown))
> +		dev_err(&ap->pdev->dev, "ISR during close\n");
> +
> +	if (unlikely(!status & (RXINT_MASK|MDIO_MASK|ERR_MASK)))
> +		dev_err(&ap->pdev->dev, "Spurious IRQ\n");
> +
> +	if ((status & RXINT_MASK) && (vmac_readl(ap, ENABLE) & RXINT_MASK) &&
> +	    (ap->dma_rx_head != vmac_readl(ap, MAC_RXRING_HEAD))) {
> +		vmac_toggle_rxint_unlocked(dev, false);
> +		napi_schedule(&ap->napi);
> +	}
> +
> +	if ((status & TXINT_MASK) && (vmac_readl(ap, ENABLE) & TXINT_MASK)) {
> +		vmac_toggle_txint_unlocked(dev, false);
> +		napi_schedule(&ap->napi);
> +	}
> +
> +	if (status & MDIO_MASK)
> +		complete(&ap->mdio_complete);
> +
> +	if (unlikely(status & ERR_MASK))
> +		update_error_counters_unlocked(dev, status);

Do yourself a favor : move everything to NAPI context.

[...]
> +static int vmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct vmac_priv *ap = netdev_priv(dev);
> +	struct vmac_buffer_desc *desc;
> +
> +	/* running under xmit lock */
> +	/* locking: modifies tx_ring head, tx_reclaim only tail */
> +
> +	/* no scatter/gatter see features below */
> +	WARN_ON(skb_shinfo(skb)->nr_frags != 0);
> +	WARN_ON(skb->len > MAX_TX_BUFFER_LEN);
> +
> +	if (unlikely(fifo_full(&ap->tx_ring))) {
> +		netif_stop_queue(dev);
> +		dev_err(&ap->pdev->dev,
> +			"xmit called while no tx desc available\n");
> +		return NETDEV_TX_BUSY;
> +	}
> +
> +	if (unlikely(skb->len < ETH_ZLEN)) {
> +		if (skb_padto(skb, ETH_ZLEN))
> +			return NETDEV_TX_OK;
> +		skb_put(skb, ETH_ZLEN - skb->len);
> +	}
> +
> +	/* fill descriptor */
> +	ap->tx_skbuff[ap->tx_ring.head] = skb;
> +	desc = &ap->txbd[ap->tx_ring.head];
> +	WARN_ON(desc->info & cpu_to_le32(BD_DMA_OWN));
> +
> +	desc->data = dma_map_single(&ap->pdev->dev, skb->data, skb->len,
> +				    DMA_TO_DEVICE);
> +
> +	/* dma might already be polling */
> +	wmb();
> +	desc->info = cpu_to_le32(BD_DMA_OWN | BD_FRST | BD_LAST | skb->len);
> +
> +	/* kick tx dma, only 1' affect register */
> +	vmac_writel(ap, TXPL_MASK, STAT);
> +
> +	dev->stats.tx_packets++;
> +	dev->stats.tx_bytes += skb->len;

No byte queue limit ?

> +	fifo_inc_head(&ap->tx_ring);
> +
> +	/* stop queue if no more desc available */
> +	if (fifo_full(&ap->tx_ring))
> +		netif_stop_queue(dev);
> +
> +	return NETDEV_TX_OK;
> +}
> +
> +static int alloc_buffers_unlocked(struct net_device *dev)
> +{
> +	struct vmac_priv *ap = netdev_priv(dev);
> +	int size, err = -ENOMEM;
> +
> +	fifo_init(&ap->rx_ring, RX_BDT_LEN);
> +	fifo_init(&ap->tx_ring, TX_BDT_LEN);
> +
> +	/* initialize skb list */
> +	memset(ap->rx_skbuff, 0, sizeof(ap->rx_skbuff));
> +	memset(ap->tx_skbuff, 0, sizeof(ap->tx_skbuff));
> +
> +	/* allocate DMA received descriptors */
> +	size = sizeof(*ap->rxbd) * ap->rx_ring.size;
> +	ap->rxbd = dma_alloc_coherent(&ap->pdev->dev, size,
> +				      &ap->rxbd_dma,
> +				      GFP_KERNEL);
> +	if (!ap->rxbd)
> +		goto err_out;
> +
> +	/* allocate DMA transmit descriptors */
> +	size = sizeof(*ap->txbd) * ap->tx_ring.size;
> +	ap->txbd = dma_alloc_coherent(&ap->pdev->dev, size,
> +				      &ap->txbd_dma,
> +				      GFP_KERNEL);
> +	if (!ap->txbd)
> +		goto err_free_rxbd;
> +
> +	/* ensure 8-byte aligned */
> +	WARN_ON(((uintptr_t)ap->txbd & 0x7) || ((uintptr_t)ap->rxbd & 0x7));
> +
> +	memset(ap->txbd, 0, sizeof(*ap->txbd) * ap->tx_ring.size);
> +	memset(ap->rxbd, 0, sizeof(*ap->rxbd) * ap->rx_ring.size);

It is already zeroed after dma_alloc_coherent.

[...]
> +static int vmac_open(struct net_device *dev)
> +{
> +	struct vmac_priv *ap = netdev_priv(dev);
> +	struct phy_device *phydev;
> +	unsigned long flags;
> +	u32 mask, ctrl;
> +	int err = 0;
> +
> +	/* locking: no concurrency yet */
> +
> +	if (!ap)
> +		return -ENODEV;
> +
> +	spin_lock_irqsave(&ap->lock, flags);
> +	ap->shutdown = false;
> +
> +	err = get_register_map(ap);
> +	if (err)
> +		return err;
> +
> +	vmac_hw_init(dev);
> +
> +	/* mac address changed? */
> +	write_mac_reg(dev, dev->dev_addr);
> +
> +	err = alloc_buffers_unlocked(dev);

dma_alloc_coherent(... GFP_KERNEL) with spinlock held.

What are you trying to lock against anyway ?

[...]
> +static int vmac_close(struct net_device *dev)
> +{
> +	struct vmac_priv *ap = netdev_priv(dev);
> +	unsigned long flags;
> +	u32 tmp;
> +
> +	/* locking: protect everything, DMA / IRQ / timer */
> +	spin_lock_irqsave(&ap->lock, flags);
> +
> +	/* complete running transfer, then stop */
> +	tmp = vmac_readl(ap, CONTROL);
> +	tmp &= ~(TXRN_MASK | RXRN_MASK);
> +	vmac_writel(ap, tmp, CONTROL);
> +
> +	/* save statistics, before unmapping */
> +	update_vmac_stats_unlocked(dev);
> +
> +	/* reenable IRQ, process pending */
> +	spin_unlock_irqrestore(&ap->lock, flags);
> +
> +	set_current_state(TASK_INTERRUPTIBLE);
> +	schedule_timeout(msecs_to_jiffies(20));
> +
> +	/* shut it down now */
> +	spin_lock_irqsave(&ap->lock, flags);
> +	ap->shutdown = true;
> +
> +	netif_stop_queue(dev);
> +	napi_disable(&ap->napi);

Bug: napi_disable may sleep and the driver is holding a spinlock.

> +	/* disable phy */
> +	phy_stop(ap->phy_dev);
> +	vmac_mii_exit_unlocked(dev);
> +	netif_carrier_off(dev);
> +
> +	/* disable interrupts */
> +	vmac_writel(ap, 0, ENABLE);
> +	free_irq(dev->irq, dev);
> +
> +	/* turn off vmac */
> +	vmac_writel(ap, 0, CONTROL);
> +	/* vmac_reset_hw(vmac) */
> +
> +	/* locking: concurrency off */
> +	spin_unlock_irqrestore(&ap->lock, flags);

[...]
> +static void update_vmac_stats_unlocked(struct net_device *dev)
> +{
> +	struct net_device_stats *_stats = &dev->stats;

What's wrong with plain 'stats' ?

[...]
> +static void create_multicast_filter(struct net_device *dev,
> +				    int32_t *bitmask)
> +{
> +	char *addrs;
> +	u32 crc;
> +
> +	/* locking: done by net_device */
> +
> +	WARN_ON(netdev_mc_count(dev) == 0);
> +	WARN_ON(dev->flags & IFF_ALLMULTI);
> +
> +	bitmask[0] = bitmask[1] = 0;
> +
> +	{

?

[...]
> +static int __devinit vmac_probe(struct platform_device *pdev)
> +{
> +	struct net_device *dev;
> +	struct vmac_priv *ap;
> +	struct resource *mem;
> +	int err;
> +
> +	/* locking: no concurrency */
> +
> +	if (dma_get_mask(&pdev->dev) > DMA_BIT_MASK(32) ||
> +	    pdev->dev.coherent_dma_mask > DMA_BIT_MASK(32)) {
> +		dev_err(&pdev->dev,
> +			"arcvmac supports only 32-bit DMA addresses\n");
> +		return -ENODEV;
> +	}
> +
> +	dev = alloc_etherdev(sizeof(*ap));
> +	if (!dev) {
> +		dev_err(&pdev->dev, "etherdev alloc failed, aborting.\n");
> +		return -ENOMEM;
> +	}
> +
> +	ap = netdev_priv(dev);
> +
> +	err = -ENODEV;
> +	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	if (!mem) {
> +		dev_err(&pdev->dev, "no mmio resource defined\n");
> +		goto err_out;
> +	}
> +	ap->mem = mem;
> +
> +	err = platform_get_irq(pdev, 0);
> +	if (err < 0) {
> +		dev_err(&pdev->dev, "no irq found\n");
> +		goto err_out;
> +	}
> +	dev->irq = err;

net_device.{irq, base_addr} have been obsolete for years. Please don't use
it to expose kernel internals to userspace.

> +
> +	spin_lock_init(&ap->lock);
> +
> +	SET_NETDEV_DEV(dev, &pdev->dev);
> +	ap->dev = dev;
> +	ap->pdev = pdev;
> +
> +	/* init rx timeout (used for oom) */
> +	init_timer(&ap->refill_timer);
> +	ap->refill_timer.function = vmac_refill_rx_timer;
> +	ap->refill_timer.data = (unsigned long)dev;
> +	spin_lock_init(&ap->refill_lock);
> +
> +	netif_napi_add(dev, &ap->napi, vmac_poll, 64);
> +	dev->netdev_ops = &vmac_netdev_ops;
> +	dev->ethtool_ops = &vmac_ethtool_ops;
> +
> +	dev->base_addr = (unsigned long)ap->regs;

(see above)

> +
> +	/* prevent buffer chaining, favor speed over space */
> +	ap->rx_skb_size = ETH_FRAME_LEN + VMAC_BUFFER_PAD;
> +
> +	/* private struct functional */
> +
> +	/* temporarily map registers to fetch mac addr */
> +	err = get_register_map(ap);
> +	if (err)
> +		goto err_out;

Please use 'goto err_perform_some_unwinding_action' style.

You don't need to be literate. 'goto err_napi_del' will be good enough :o)

> +
> +	/* mac address intialize, set vmac_open  */
> +	read_mac_reg(dev, dev->dev_addr);
> +
> +	if (!is_valid_ether_addr(dev->dev_addr))
> +		dev_hw_addr_random(dev, dev->dev_addr);
> +
> +	err = register_netdev(dev);
> +	if (err) {
> +		dev_err(&pdev->dev, "Cannot register net device, aborting.\n");
> +		goto err_out;

Should be something like 'goto err_I_wont_leak_register_memory_region'

> +	}
> +
> +	/* release the memory region, till open is called */

Why ? It adds a failure opportunity.

[...]
> diff --git a/drivers/net/ethernet/arcvmac.h b/drivers/net/ethernet/arcvmac.h
> new file mode 100644
> index 0000000..f94ab38
> --- /dev/null
> +++ b/drivers/net/ethernet/arcvmac.h
[...]
> +/* stat/enable use same bit mask */
> +#define VMAC_STAT		0x04
> +#define VMAC_ENABLE		0x08
> +#  define TXINT_MASK		0x00000001 /* Transmit interrupt */
> +#  define RXINT_MASK		0x00000002 /* Receive interrupt */
> +#  define ERR_MASK		0x00000004 /* Error interrupt */
> +#  define TXCH_MASK		0x00000008 /* Transmit chaining error */
> +#  define MSER_MASK		0x00000010 /* Missed packet counter error */
> +#  define RXCR_MASK		0x00000100 /* RXCRCERR counter rolled over	 */

Please keep things aligned and add the extra space after "define" (see tg3.h).

[...]
> +struct vmac_priv {
> +	struct net_device *dev;
> +	struct platform_device *pdev;
> +
> +	struct completion mdio_complete;
> +	spinlock_t lock; /* protects structure plus hw regs of device */
> +
> +	/* base address of register set */
> +	char *regs;

It should be __iomem annotated.

[...]
> +/* DMA ring management */
> +
> +/* for a fifo with size n,
> + * - [0..n] fill levels are n + 1 states
> + * - there are only n different deltas (head - tail) values
> + * => not all fill levels can be represented with head, tail
> + *    pointers only
> + * we give up the n fill level, aka fifo full */
> +
> +/* sacrifice one elt as a sentinel */
> +static inline int fifo_used(struct dma_fifo *f);
> +static inline int fifo_inc_ct(int ct, int size);
> +static inline void fifo_dump(struct dma_fifo *fifo);

Please reorder and remove the forward declarations.

-- 
Ueimor
