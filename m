From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] RM9000 network driver
Date: Wed, 05 Jul 2006 14:00:48 -0400
Message-ID: <44ABFE50.4010401@garzik.org>
References: <20060605235313.GA13994@linux-mips.org> <449B57DC.1040205@garzik.org> <20060623142127.GA23299@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Koeller <thomas.koeller@baslerweb.com>,
	Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:23954 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S964947AbWGESA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2006 14:00:58 -0400
To: Ralf Baechle <ralf@linux-mips.org>
In-Reply-To: <20060623142127.GA23299@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ralf Baechle wrote:
> +/* module parameters */
> +
> +static int param_set_ethaddr(const char *val, struct kernel_param *kp)
> +{
> +	static const char fmt[] = "%2hhx:%2hhx:%2hhx:%2hhx:%2hhx:%2hhx";
> +	unsigned char * const cc = (unsigned char *) kp->arg;
> +
> +	if (!val) return -EINVAL;
> +
> +	return (6 == sscanf(val, fmt, &cc[0], &cc[1], &cc[2], &cc[3],
> +			    &cc[4], &cc[5])) ? 0 : -EINVAL;
> +}
> +
> +static int param_get_ethaddr(char *buffer, struct kernel_param *kp)
> +{
> +	static const char fmt[] = "%02x:%02x:%02x:%02x:%02x:%02x";
> +	const unsigned char * const cc = (unsigned char *) kp->arg;
> +
> +	return scnprintf(buffer, 18, fmt,
> +			 cc[0], cc[1], cc[2], cc[3], cc[4], cc[5]);
> +}
> +
> +#define param_check_ethaddr(name, p) __param_check(name, *p, unsigned char)

kill this, it is settable via ifconfig already


> +enum {
> +	speed_10m = 0x0,
> +	speed_100m = 0x1,
> +	speed_1g = 0x2
> +};
> +
> +static int autoneg = 1;
> +static unsigned int speed = speed_1g;
> +static int full_duplex = 1;
> +static unsigned char hwaddr[6] = {0x00, 0x30, 0x53, 0x00, 0x00, 0x00};
> +
> +module_param(autoneg, bool, 0444);
> +module_param(full_duplex, bool, 0444);
> +module_param(speed, uint, 0444);
> +module_param(hwaddr, ethaddr, 0444);

kill all this, use ethtool


> +/* XDMA descriptors */
> +typedef struct {
> +	volatile u64	cpu_part;
> +	volatile u64	xdma_part;
> +} rx_desc_t;
> +
> +typedef volatile u64 tx_desc_t;

volatile inevitably implies that the programmer was too lazy with 
barriers such.

Remove 'volatile', and make sure it still works.  If not, debug...


> +/* Port specific data structure */
> +typedef struct {
> +	unsigned int			port_num;
> +	unsigned int			irq_phy;
> +	u8				port_mac_addr[6];
> +
> +	/* Statistics */
> +	spinlock_t			stat_lock;
> +	struct timer_list		stat_timer;
> +
> +	/* Tx next descriptor pointer */
> +	int 				tx_next_desc;
> +
> +	/* SKB queues */
> +	struct sk_buff_head		rx_queue;
> +	struct sk_buff_head		tx_queue;
> +
> +	/* XDMA descriptor area */
> +	rx_desc_t			* rx_desc_area;
> +	tx_desc_t			* tx_desc_area;
> +
> +	/* DMA structures and handles */
> +	dma_addr_t			tx_dma;
> +	dma_addr_t			rx_dma;
> +
> +	/* Device lock */
> +	spinlock_t			lock;
> +
> +	unsigned int			rx_ring_size;
> +	unsigned int			tx_ring_size;
> +
> +	struct net_device_stats		stats;
> +
> +	/* Tx and Rx coalescing */
> +	unsigned long			rx_int_coal;
> +	unsigned long			tx_int_coal;
> +
> +	/* NAPI work limit */
> +	unsigned int			rx_work_limit;
> +
> +	/* Values set from platform resources */
> +	unsigned int			slice;
> +	unsigned int			mdio_channel;
> +	unsigned int			rxfifo_start, rxfifo_len;
> +	unsigned int			txfifo_start, txfifo_len;
> +	void __iomem *			addr_xdma;
> +	void __iomem *			addr_mac;
> +	void __iomem *			addr_pktproc;
> +	void __iomem *			addr_mstat;
> +	void __iomem *			addr_fifo_rx;
> +	void __iomem *			addr_fifo_tx;
> +	void  __iomem *			addr_mdio;
> +} rm9k_ge_port_info;
> +

> +static inline rx_desc_t * rm9k_ge_rxdesc_from_skb(const struct sk_buff * skb)
> +{
> +	rx_desc_t ** const d = (rx_desc_t **) skb->cb;
> +	return *d;
> +}
> +
> +
> +
> +static inline void
> +rm9k_ge_rxdesc_to_skb(struct sk_buff * skb, rx_desc_t * desc)
> +{
> +	rx_desc_t ** const d = (rx_desc_t **) skb->cb;
> +	*d = desc;
> +}
> +
> +
> +
> +static inline tx_desc_t *
> +rm9k_ge_txdesc_from_skb(const struct sk_buff * skb)
> +{
> +	tx_desc_t ** const d = (tx_desc_t **) skb->cb;
> +	return *d;
> +}
> +
> +
> +
> +static inline void
> +rm9k_ge_txdesc_to_skb(struct sk_buff * skb, tx_desc_t * desc)
> +{
> +	tx_desc_t ** const d = (tx_desc_t **) skb->cb;
> +	*d = desc;
> +}

Don't use skb->cb for this stuff, that's not the intended usage.  It 
will get stomped on.

Besides that, this is backwards from how other net drivers set things 
up:  most net drivers create a list of descriptor information, and 
directly index the skb pointer from that.



> +/*
> + * Change the MTU of the Ethernet Device
> + */
> +static int rm9k_ge_change_mtu(struct net_device *netdev, int new_mtu)
> +{
> +	if ((new_mtu > ETH_DATA_LEN) || (new_mtu < 64))
> +		return -EINVAL;
> +
> +	netdev->mtu = new_mtu;
> +
> +	if (netif_running(netdev)) {
> +		rm9k_ge_port_info * const info = netdev_priv(netdev);
> +
> +		/* Rebuild the RX queue */
> +		rm9k_ge_free_rx_queue(netdev);
> +		gpi_writel(rm9k_eth_rx_frame_len(new_mtu),
> +			   info->addr_mac + 0x0008);
> +		gpi_writel(rm9k_eth_tx_frame_len(new_mtu),
> +			   info->addr_mac + 0x0058);
> +		rm9k_ge_setup_rx_queue(netdev);

Seems to need some sort of locking?


> +static int rm9k_ge_xdma_ints(u32 mask)
> +{
> +	static spinlock_t intflg_lock = SPIN_LOCK_UNLOCKED;
> +	u32 flg;
> +
> +	/*
> +	 * The interrupt decoding below assumes that the 'low priority core'
> +	 * feature of the RM9000 is not used!
> +	 */
> +	switch (smp_processor_id()) {
> +		case 0:
> +			spin_lock(&intflg_lock);
> +			flg = titan_readl(0x0048) & titan_readl(0x0038)
> +					  & mask;
> +			if (flg)
> +				titan_writel(flg, 0x0048);
> +			spin_unlock(&intflg_lock);
> +			break;
> +
> +		case 1:
> +			spin_lock(&intflg_lock);
> +			flg = titan_readl(0x004c) & titan_readl(0x003c)
> +					  & mask;
> +			if (flg)
> +				titan_writel(flg, 0x004c);
> +			spin_unlock(&intflg_lock);
> +			break;
> +
> +		default:
> +			flg = 0;
> +			break;
> +	}
> +
> +	return flg != 0;
> +}
> +
> +
> +
> +/*
> + * Tx Timeout function
> + */
> +static void rm9k_ge_tx_timeout(struct net_device *netdev)
> +{
> +	rm9k_ge_port_info * const info = netdev_priv(netdev);
> +	u32 reg;
> +
> +	/* Stop the tx queue */
> +	netif_stop_queue(netdev);
> +
> +	/* Reset the tx xdma */
> +	spin_lock(&info->tx_queue.lock);
> +	info->stats.tx_errors += skb_queue_len(&info->tx_queue);
> +	reg = gpi_readl(info->addr_xdma + 0x0000);
> +	gpi_writel(reg | 0x80000000, info->addr_xdma + 0x0000);
> +	iob();
> +	spin_unlock(&info->tx_queue.lock);
> +
> +	/* Flush the tx queue */
> +	__skb_queue_purge(&info->tx_queue);
> +	info->tx_next_desc = 0;
> +
> +	/* Restart the tx xdma channel */
> +	gpi_writel(reg & ~0x80000000, info->addr_xdma + 0x0000);
> +	iob();
> +
> +	/* Restart the tx queue */
> +	printk(KERN_ERR "%s: TX timeout - queue flushed\n", netdev->name);
> +	netif_start_queue(netdev);
> +}
> +
> +
> +
> +static struct sk_buff *rm9k_ge_get_tx_skb(rm9k_ge_port_info * info)
> +{
> +	struct sk_buff * s;
> +
> +	spin_lock(&info->tx_queue.lock);
> +	s = skb_queue_len(&info->tx_queue) > gpi_readl(info->addr_xdma + 0x0004) ?
> +	__skb_dequeue(&info->tx_queue) : NULL;
> +	spin_unlock(&info->tx_queue.lock);
> +	return s;
> +}
> +
> +
> +
> +
> +
> +static irqreturn_t rm9k_ge_main_int_handler(int irq, void *dev_id,
> +					    struct pt_regs *regs)
> +{
> +	u32 reg;
> +	struct net_device * const netdev = (struct net_device *) dev_id;
> +	rm9k_ge_port_info * const info = netdev_priv(netdev);
> +	const u32 eth_int_cause_error = gpi_readl(info->addr_xdma + 0x000c);
> +	const int int_tx = rm9k_ge_xdma_ints(0x1 << (info->slice * 8 + 1)),
> +		  int_rx = rm9k_ge_xdma_ints(0x1 << (info->slice * 8 + 0));
> +
> +	if (!int_tx && !int_rx && !eth_int_cause_error)
> +		return IRQ_NONE;
> +
> +	/* Handle Tx first */
> +	if (int_tx) {
> +		struct sk_buff *skb;
> +
> +		while (skb = rm9k_ge_get_tx_skb(info), skb != NULL) {
> +			tx_desc_t * const desc =
> +				rm9k_ge_txdesc_from_skb(skb);
> +
> +			dma_unmap_single(netdev->class_dev.dev,
> +					 *desc & 0x00000000ffffffffull,
> +					 skb->len, DMA_TO_DEVICE);
> +			dev_kfree_skb_irq(skb);
> +		}
> +
> +		if (netif_queue_stopped(netdev))
> +			netif_start_queue(netdev);
> +	}
> +
> +	/* Handle the Rx next */
> +	if (int_rx) {
> +		if (netif_rx_schedule_prep(netdev)) {
> +			/* Disable Tx and Rx */
> +			lock_titan_regs();
> +			reg = titan_readl(0x0058);
> +			reg &= ~(0x1 << (info->slice * 8));
> +			titan_writel(reg, 0x0058);
> +			unlock_titan_regs();
> +			__netif_rx_schedule(netdev);
> +		}
> +	}
> +
> +	/* Handle error interrupts */
> +	if (eth_int_cause_error && (eth_int_cause_error != 0x2)) {
> +		printk(KERN_ERR
> +			"XDMA Channel Error : %x  on port %d\n",
> +			eth_int_cause_error, info->slice);
> +
> +		printk(KERN_ERR
> +		       "XDMA GDI Hardware error : %x  on port %d\n",
> +		       titan_readl(0x5008), info->slice);
> +
> +		printk(KERN_ERR
> +			"XDMA currently has %d Rx descriptors \n",
> +			gpi_readl(info->addr_xdma +0x0008));
> +
> +		printk(KERN_ERR
> +			"XDMA currently has prefetcted %d Rx descriptors \n",
> +			gpi_readl(info->addr_xdma + 0x001c));
> +
> +		gpi_writel(eth_int_cause_error, info->addr_xdma + 0x000c);
> +	}
> +	return IRQ_HANDLED;
> +}
> +
> +static irqreturn_t rm9k_ge_phy_int_handler(int irq, void *dev_id,
> +					   struct pt_regs *regs)
> +{
> +	struct net_device * const netdev = (struct net_device *) dev_id;
> +	u16 phy_intstat;
> +
> +	/*
> +	 * PHY interrupt to inform abt the changes. Reading the
> +	 * PHY Status register will clear the interrupt
> +	 */
> +	rm9k_ge_mdio_read(PHY_ADDR, RM9K_GE_MDIO_PHY_INTSTAT, &phy_intstat);
> +
> +	if (phy_intstat & 0x0010) {
> +		rm9k_ge_port_info * const info = netdev_priv(netdev);
> +		/* Autonegotiation completed */
> +		static const u16 val[8] =
> +			{ 0x1000, 0x0000, 0x1100, 0x0100,
> +			  0x1201, 0x0201, 0x1201, 0x0201 };

magic numbers



> +		u16 phy_reg = 0;
> +		int i;
> +
> +		gpi_writel(0x00000000, info->addr_mac + 0x014c);
> +		rm9k_ge_mdio_read(PHY_ADDR, RM9K_GE_MDIO_PHY_STATUS, &phy_reg);
> +		i = ((phy_reg >> 1) & 0x1) | ((phy_reg >> 2) & 0x6);
> +
> +		wmb();
> +		gpi_writel(val[i], info->addr_mac + 0x0150);
> +		wmb();
> +		gpi_writel(0x00000003, info->addr_mac + 0x014c);
> +		iob();

author desperately needs to read memory-barriers doc...

and investigate write posting.


> +		netif_carrier_on(netdev);
> +		pr_debug("%s: autonegotiation completed\n", netdev->name);
> +	} else {
> +		u16 val;
> +		rm9k_ge_mdio_read(PHY_ADDR, RM9K_GE_MDIO_PHY_STATUS, &val);
> +
> +		if (val & 0x0004) {
> +			pr_debug("%s: carrier detected\n", netdev->name);
> +			if (!autoneg)
> +				netif_carrier_on(netdev);
> +		} else {
> +			netif_carrier_off(netdev);
> +			pr_debug("%s: carrier lost\n", netdev->name);
> +		}
> +	}
> +
> +	rm9k_ge_mdio_write(PHY_ADDR, RM9K_GE_MDIO_PHY_INTCLEAR, phy_intstat);
> +	return IRQ_HANDLED;
> +}
> +
> +/*
> + * Multicast and Promiscuous mode set. The
> + * set_multi entry point is called whenever the
> + * multicast address list or the network interface
> + * flags are updated.
> + */
> +static void rm9k_ge_set_multi(struct net_device *netdev)
> +{
> +	rm9k_ge_port_info * const info = netdev_priv(netdev);
> +	u32 reg;
> +
> +	reg = gpi_readl(info->addr_pktproc + 0x0124);
> +
> +	if (netdev->flags & IFF_PROMISC) {
> +		reg |= 0x2;
> +	}
> +	else if (netdev->flags & IFF_ALLMULTI) {
> +		reg |= 0x401; /* Use the 64-bit Multicast Hash bin */
> +	}
> +	else {
> +		reg = 0x2;

doesn't this code turn on promisc, even in unicast situations?


> +	gpi_writel(reg, info->addr_pktproc + 0x0124);
> +	if (reg & 0x01) {
> +		gpi_writel(0xffff, info->addr_pktproc + 0x0110);
> +		gpi_writel(0xffff, info->addr_pktproc + 0x0114);
> +		gpi_writel(0xffff, info->addr_pktproc + 0x0118);
> +		gpi_writel(0xffff, info->addr_pktproc + 0x011c);

magic numbers, and no comments.  WTF does this code actually do?

Seems like a broken way to program the multicast filter, to me.



> + * Open the network device
> + */
> +static int rm9k_ge_open(struct net_device *netdev)
> +{
> +	rm9k_ge_port_info * const info = netdev_priv(netdev);
> +	static const char irqerr[] =
> +		KERN_ERR "%s: failed to set up irq %u - error %d\n";
> +	int res;
> +	u32 reg, xdma_initval;
> +	u16 phy_reg;
> +	unsigned long end;
> +
> +	/* Check, if slice in GMII/MII (not TBI) mode */
> +	reg = titan_readl(0x0010);
> +	if (~reg & (0x100 << info->slice)) {

magic numbers


> +		printk(KERN_ERR "Ethernet slice #%u wrong mode\n",
> +		info->slice);
> +		return -EINVAL;
> +	}
> +
> +	/* Compute the XDMA channel initialization value */
> +	xdma_initval = 0x440;
> +
> +	switch (info->tx_ring_size) {
> +		case 512:
> +			break;
> +		case 256:
> +			xdma_initval |= 0x10000000;
> +			break;
> +		case 128:
> +			xdma_initval |= 0x20000000;
> +			break;
> +		case 64:
> +			xdma_initval |= 0x30000000;
> +			break;
> +		default:
> +			return -EINVAL;
> +	}
> +
> +	switch (info->rx_ring_size) {
> +		case 512:
> +			break;
> +		case 256:
> +			xdma_initval |= 0x00010000;
> +			break;
> +		case 128:
> +			xdma_initval |= 0x00020000;
> +			break;
> +		case 64:
> +			xdma_initval |= 0x00030000;
> +			break;
> +		default:
> +			return -EINVAL;
> +	}
> +
> +	/* Set up the GPI interrupt */
> +	res = request_irq(netdev->irq, rm9k_ge_main_int_handler,
> +		     SA_INTERRUPT | SA_SAMPLE_RANDOM | SA_SHIRQ,
> +		     netdev->name, netdev);
> +
> +	if (res) {
> +		printk(irqerr, netdev->name, netdev->irq, -res);
> +		return res;
> +	}
> +
> +	/* Set up the PHY interrupt */
> +	res = request_irq(info->irq_phy, rm9k_ge_phy_int_handler,
> +		     SA_INTERRUPT | SA_SAMPLE_RANDOM,
> +		     netdev->name, netdev);
> +
> +	if (res) {
> +		free_irq(netdev->irq, netdev);
> +		printk(irqerr, netdev->name, info->irq_phy, -res);
> +		return res;
> +	}
> +
> +	/* Set the MAC Address */
> +	memcpy(info->port_mac_addr, netdev->dev_addr, ETH_ALEN);
> +
> +	rm9k_ge_update_afx(info);
> +
> +	/* Enable the slice */
> +	lock_titan_regs();
> +	reg = titan_readl(0x0004);
> +	reg &= ~(0x30000 << (info->slice * 2));	/* enable slice */
> +	reg |= 0x3 << (info->slice * 2);	/* disable DLLs */
> +	titan_writel(reg, 0x0004);
> +	unlock_titan_regs();
> +
> +	/* Set up the Tx descriptor ring */
> +	gpi_writel((u32) info->tx_dma, info->addr_xdma + 0x0014);
> +	info->tx_next_desc = 0;
> +
> +	/* IR register for the XDMA: no Rx_OOD */
> +	gpi_writel(0x80068000, info->addr_xdma + 0x0010);
> +
> +	/* Start the XDMA controller */
> +	gpi_writel(xdma_initval, info->addr_xdma + 0x0000);
> +
> +	/* Set up the Rx skb queue */
> +	res = rm9k_ge_setup_rx_queue(netdev);
> +	if (res)
> +		return res;
> +
> +	/* Rx FIFO BAV2,BAV and DAV settings */
> +	reg = (info->rxfifo_len << 10) | info->rxfifo_start;
> +	gpi_writel(0x100000 | reg, info->addr_fifo_rx + 0x0000);
> +	gpi_writel((0x10 << 20) | (0x10 << 10) | 0x1,
> +		   info->addr_fifo_rx + 0x0004);
> +	gpi_writel(0x200000 | reg, info->addr_fifo_rx + 0x0000);
> +
> +	/* Tx FIFO BAV2, BAV and DAV settings */
> +	reg = (info->txfifo_len << 10) | info->txfifo_start;
> +	gpi_writel(0x100000 | reg, info->addr_fifo_tx + 0x0000);
> +	gpi_writel((0x1 << 20) | (0x1 << 10) | 0x10,
> +		   info->addr_fifo_tx + 0x0004);
> +	gpi_writel(0x200000 | reg, info->addr_fifo_tx + 0x0000);

magic numbers galore


> +	if (hw_hdr_align) {
> +		/*
> +		 * TRTG block enable
> +		 * This is the 1.2 revision of the chip. It has a fix for the
> +		 * IP header alignment. Now, the IP header begins at an
> +		 * aligned address and this wont need an extra copy in the
> +		 * driver. This performance drawback existed in the previous
> +		 * versions of the silicon.
> +		 */
> +		reg = gpi_readl(info->addr_pktproc + 0x003c);
> +		reg |= 0x40000000;
> +		gpi_writel(reg, info->addr_pktproc + 0x003c);
> +
> +		reg |= 0x04000000;
> +		gpi_writel(reg, info->addr_pktproc + 0x003c);
> +		udelay(7);
> +		reg &= ~0x04000000;
> +		gpi_writel(reg, info->addr_pktproc + 0x003c);
> +		udelay(2);

memory barriers / write posting


> +		/* Priority & start of range to checksum */
> +		gpi_writel(0x00010010 + ((ETH_HLEN + NET_IP_ALIGN) << 8),
> +			   info->addr_pktproc + 0x0038);
> +
> +	} else {
> +		/* Priority & start of range to checksum */
> +		gpi_writel(0x00010010 + (ETH_HLEN << 8),
> +			   info->addr_pktproc + 0x0038);
> +	}
> +
> +	gpi_writel(0x00008001, info->addr_pktproc + 0x0000);
> +
> +	gpi_writel(0x00000000, info->addr_mac + 0x0028);
> +	gpi_writel(0x00000000, info->addr_mac + 0x014c);
> +	wmb();
> +
> +	/* Start the Tx activity */
> +	gpi_writel(0xe1b7, info->addr_mac + 0x0044);
> +	gpi_writel(rm9k_eth_tx_frame_len(netdev->mtu), info->addr_mac + 0x0058);
> +	gpi_writel(RM9K_GE_TMAC_OPTIONS | 0x1, info->addr_mac + 0x0040);
> +
> +	/* Destination Address drop bit */
> +	gpi_writel(0x0009, info->addr_mac + 0x0004);
> +	gpi_writel(0x3, info->addr_mac + 0x0018);
> +	gpi_writel(rm9k_eth_rx_frame_len(netdev->mtu), info->addr_mac + 0x0008);
> +
> +	/* Start the Rx activity */
> +	gpi_writel(RM9K_GE_RMAC_OPTIONS | 0x1, info->addr_mac + 0x0000);
> +
> +	lock_titan_regs();
> +
> +	/* Enable the info->slice interrupts */
> +	reg = titan_readl(0x0050);
> +	titan_writel(reg | (0x1f << (info->slice * 5)), 0x0050);
> +
> +	/* Enable the Interrupts for Tx and Rx */
> +	reg = titan_readl(0x0058);
> +	reg |= 0x3 << (info->slice * 8);
> +	titan_writel(reg, 0x0058);
> +
> +	unlock_titan_regs();
> +
> +	/* Start the MDIO */
> +	rm9k_ge_init_mdio(info->addr_mdio, info->mdio_channel);
> +
> +	/* Reset the PHY */
> +	end = jiffies + HZ;
> +	rm9k_ge_mdio_write(PHY_ADDR, RM9K_GE_MDIO_PHY_BMCR, 0x8000);
> +	while (time_before(jiffies, end)) {
> +		rm9k_ge_mdio_read(PHY_ADDR, RM9K_GE_MDIO_PHY_BMCR, &phy_reg);
> +		if (~phy_reg & 0x8000)
> +			break;
> +		yield();
> +	}
> +	if (unlikely(phy_reg & 0x8000)) {
> +		free_irq(info->irq_phy, netdev);
> +		free_irq(netdev->irq, netdev);
> +		printk(KERN_ERR "%s: PHY reset timed out\n", netdev->name);
> +		return -ETIME;
> +	}
> +
> +	/* Set up the PHY */
> +	if (autoneg) {
> +		/* Force the connection to be re-negotiated. */
> +		rm9k_ge_mdio_write(PHY_ADDR, RM9K_GE_MDIO_PHY_BMCR, 0x1000);
> +		rm9k_ge_mdio_write(PHY_ADDR, RM9K_GE_MDIO_PHY_INTMASK, 0x4010);
> +	} else {
> +		u32 mac_val = full_duplex ? 0x00000000 : 0x00001000;
> +		phy_reg = full_duplex ? 0x0100 : 0x0000;
> +
> +		switch (speed) {
> +			case speed_1g:
> +				mac_val |= 0x00000200;
> +				phy_reg |= 0x0040;
> +				break;
> +			case speed_100m:
> +				mac_val |= 0x00000100;
> +				phy_reg |= 0x2000;
> +				break;
> +		}
> +		gpi_writel(mac_val, info->addr_mac + 0x0150);
> +		rm9k_ge_mdio_write(PHY_ADDR, RM9K_GE_MDIO_PHY_BMCR, phy_reg);
> +		rm9k_ge_mdio_write(PHY_ADDR, RM9K_GE_MDIO_PHY_INTMASK, 0x4000);
> +	}
> +
> +	gpi_writel(0x00000003, info->addr_mac + 0x014c);
> +
> +	rm9k_ge_mdio_read(PHY_ADDR, RM9K_GE_MDIO_PHY_STATUS, &phy_reg);
> +	if (phy_reg & 0x0004) {
> +		pr_debug("%s: link is up\n", netdev->name);
> +		netif_carrier_on(netdev);
> +	} else {
> +		pr_debug("%s: link is down\n", netdev->name);
> +		netif_carrier_off(netdev);
> +	}
> +
> +	/* Set up statistics gathering */
> +	rm9k_ge_update_stats(netdev);
> +	mod_timer(&info->stat_timer, jiffies + HZ * 600);
> +
> +	return 0;
> +}
> +
> +
> +
> +/*
> + * Close the network device
> + */
> +static int rm9k_ge_stop(struct net_device *netdev)
> +{
> +	rm9k_ge_port_info * const info = netdev_priv(netdev);
> +	u32 reg;
> +
> +	del_timer(&info->stat_timer);

del_timer_sync()


> +	/* Reset the XDMA */
> +	gpi_writel(0x80080000, info->addr_xdma + 0x0000);
> +
> +	/* Disable the GMII data paths */
> +	gpi_writel(0x00000000, info->addr_mac + 0x014c);
> +
> +	/* Reset the FIFOs */
> +	gpi_writel(0x00100000 | (info->rxfifo_len << 10) | info->rxfifo_start,
> +		   info->addr_fifo_rx + 0x0000);
> +	gpi_writel(0x00100000 | (info->txfifo_len << 10) | info->txfifo_start,
> +		   info->addr_fifo_tx + 0x0000);
> +
> +	/* Reset the packet processor */
> +	gpi_writel(0x00000001, info->addr_pktproc + 0x0000);
> +
> +	/* Reset RX and TX MACs */
> +	gpi_writel(RM9K_GE_RMAC_OPTIONS, info->addr_mac + 0x0000);
> +	gpi_writel(RM9K_GE_TMAC_OPTIONS, info->addr_mac + 0x0040);
> +
> +	/* Power down the PHY */
> +	rm9k_ge_mdio_write(PHY_ADDR, RM9K_GE_MDIO_PHY_INTMASK, 0x0000);
> +	rm9k_ge_mdio_write(PHY_ADDR, RM9K_GE_MDIO_PHY_BMCR, 0x0800);

magic numbers


> +	rm9k_ge_cleanup_mdio(info->mdio_channel);
> +
> +	/* Disable the Tx and Rx interrupts */
> +	lock_titan_regs();
> +	reg = titan_readl(0x0058);
> +	titan_writel(reg & ~(0xff << (info->slice * 8)), 0x0058);
> +	iob();
> +	unlock_titan_regs();
> +
> +	/* Release the interrupts */
> +	free_irq(info->irq_phy, netdev);
> +	free_irq(netdev->irq, netdev);
> +
> +	rm9k_ge_free_tx_queue(netdev);
> +	rm9k_ge_free_rx_queue(netdev);
> +
> +	/* Disable the Tx and Rx interrupts */
> +	lock_titan_regs();
> +	reg = titan_readl(0x0058);
> +	titan_writel(reg & ~(0xff << (info->slice * 8)), 0x0058);
> +	unlock_titan_regs();
> +
> +	return 0;
> +}
> +
> +
> +
> +/*
> + * Set up the skb queue for the RX direction
> + */
> +static int rm9k_ge_setup_rx_queue(struct net_device * netdev)
> +{
> +	rm9k_ge_port_info * const info = netdev_priv(netdev);
> +	struct sk_buff_head * const q = &info->rx_queue;
> +	rx_desc_t * d;
> +
> +	if (!skb_queue_empty(q))
> +		return -EBUSY;
> +
> +	spin_lock_irq(&q->lock);

spin_lock_irqsave is preferred -- much less fragile


> +	for (d = info->rx_desc_area;
> +	     d < info->rx_desc_area + info->rx_ring_size;
> +	     d++) {
> +		struct sk_buff * const s =
> +			alloc_skb(rm9k_eth_rx_frame_len(netdev->mtu), GFP_KERNEL);
> +
> +		if (!s) {
> +			__skb_queue_purge(q);
> +			spin_unlock_irq(&q->lock);
> +			return -ENOMEM;
> +		}
> +
> +		d->cpu_part =
> +			dma_map_single(netdev->class_dev.dev, s->data,
> +				       rm9k_eth_rx_frame_len(netdev->mtu),
> +				       DMA_FROM_DEVICE);
> +		d->xdma_part = RM9K_GE_RX_BUFFER_OWNED;
> +		s->dev = netdev;
> +		rm9k_ge_rxdesc_to_skb(s, d);
> +		skb_queue_tail(q, s);
> +	}
> +
> +	gpi_writel((unsigned long) info->rx_dma, info->addr_xdma + 0x0018);
> +	gpi_writel(info->rx_ring_size, info->addr_xdma + 0x0008);
> +	spin_unlock_irq(&q->lock);
> +	return 0;
> +}
> +
> +
> +
> +/*
> + * Free the RX queue
> + */
> +static void rm9k_ge_free_rx_queue(struct net_device *netdev)
> +{
> +	rm9k_ge_port_info * const info = netdev_priv(netdev);
> +	u32 reg;
> +
> +	/* Stop the RX DMA */
> +	reg = gpi_readl(info->addr_xdma + 0x0000);
> +	gpi_writel(reg | 0x000c0000, info->addr_xdma + 0x0000);
> +
> +	/* Disable the RMAC */
> +	gpi_writel(RM9K_GE_RMAC_OPTIONS, info->addr_mac + 0x0000);
> +	iob();
> +
> +	skb_queue_purge(&info->rx_queue);
> +}
> +
> +
> +
> +/*
> + * Free the TX queue
> + */
> +static void rm9k_ge_free_tx_queue(struct net_device *netdev)
> +{
> +	rm9k_ge_port_info * const info = netdev_priv(netdev);
> +	u32 reg;
> +
> +	/* Stop the Tx DMA */
> +	reg = gpi_readl(info->addr_xdma + 0x0000);
> +	gpi_writel(reg | 0xc0000000, info->addr_xdma + 0x0000);
> +
> +	/* Disable the TMAC */
> +	gpi_writel(RM9K_GE_TMAC_OPTIONS, info->addr_mac + 0x0040);
> +	iob();
> +
> +	skb_queue_purge(&info->tx_queue);
> +}
> +
> +
> +
> +/*
> + * Queue the packet for Tx. Currently no support for zero copy,
> + * checksum offload and Scatter Gather. The chip does support
> + * Scatter Gather only. But, that wont help here since zero copy
> + * requires support for Tx checksumming also.
> + */
> +static int rm9k_ge_start_xmit(struct sk_buff *skb, struct net_device *netdev)
> +{
> +	rm9k_ge_port_info * const info = netdev_priv(netdev);
> +
> +	struct device *device = netdev->class_dev.dev;
> +	const unsigned int curr_desc = info->tx_next_desc;
> +	tx_desc_t * const tx_curr = info->tx_desc_area + curr_desc;
> +
> +	*tx_curr = dma_map_single(device, skb->data, skb->len, DMA_TO_DEVICE)
> +		   | ((tx_desc_t) (skb->len & 0x00003fff) << 32)
> +		   | (1ULL << 48)
> +		   | (1ULL << 53)
> +		   | (1ULL << 63);
> +
> +	rm9k_ge_txdesc_to_skb(skb, tx_curr);
> +	skb_queue_tail(&info->tx_queue, skb);
> +	info->tx_next_desc = (curr_desc + 1) % info->tx_ring_size;
> +	gpi_writel(0x1, info->addr_xdma + 0x0004);
> +	netdev->trans_start = jiffies;
> +	pr_debug("%s: packet sent\n", netdev->name);

locking against TX completion?


> +static struct sk_buff * rm9k_ge_get_rx_skb(rm9k_ge_port_info * info)
> +{
> +	unsigned long flg;
> +	struct sk_buff * s;
> +
> +	spin_lock_irqsave(&info->rx_queue.lock, flg);
> +	s = skb_peek(&info->rx_queue);
> +	if (s) {
> +		const rx_desc_t * const desc =
> +			rm9k_ge_rxdesc_from_skb(s);
> +		s = (desc->xdma_part & RM9K_GE_RX_BUFFER_OWNED)
> +			? NULL : __skb_dequeue(&info->rx_queue);
> +	}
> +	spin_unlock_irqrestore(&info->rx_queue.lock, flg);
> +

rx queue rarely needs a lock


> +#define	TX_THRESHOLD	4
> +
> +/*
> + * Receive packets and send them to the kernel.
> + */
> +static int rm9k_ge_receive_queue(struct net_device *netdev, unsigned int max)
> +{
> +	rm9k_ge_port_info * const info = netdev_priv(netdev);
> +	unsigned long received_packets = 0;
> +
> +	while (info->rx_work_limit) {
> +		static const unsigned int error_mask =
> +			(0x1 << 27) | (0x1 << 20) | (0x1 << 19) | (0x1 << 15);
> +		struct sk_buff * skb_reuse;
> +		unsigned int len, cmd_sts, checksum;
> +		rx_desc_t * desc;
> +
> +		struct sk_buff * skb = rm9k_ge_get_rx_skb(info);
> +		if (!skb)
> +			break;
> +
> +		info->rx_work_limit--;
> +		pr_debug("%s: packet received\n", netdev->name);
> +
> +		desc = rm9k_ge_rxdesc_from_skb(skb);
> +		dma_unmap_single(netdev->class_dev.dev, desc->cpu_part,
> +				 rm9k_eth_rx_frame_len(netdev->mtu),
> +				 DMA_FROM_DEVICE);
> +		len = (desc->xdma_part >> 32) & 0x7fff;
> +		cmd_sts = desc->xdma_part >> 32;
> +		checksum = ntohs((desc->xdma_part >> 16) & 0x0000ffff);
> +
> +		if (cmd_sts & error_mask) {
> +			info->stats.rx_errors++;
> +			desc->cpu_part =
> +				dma_map_single(netdev->class_dev.dev,
> +					       skb->data,
> +					       rm9k_eth_rx_frame_len(netdev->mtu),
> +					       DMA_FROM_DEVICE);
> +			desc->xdma_part = RM9K_GE_RX_BUFFER_OWNED;
> +			skb_queue_tail(&info->rx_queue, skb);
> +			gpi_writel(1, info->addr_xdma + 0x0008);
> +			continue;
> +		}
> +
> +		received_packets++;
> +
> +		if (hw_hdr_align) {
> +			/* Hardware header alignment supported */
> +			skb_reuse = alloc_skb(rm9k_eth_rx_frame_len(netdev->mtu),
> +					      GFP_ATOMIC);
> +			if (skb_reuse) {
> +				skb_reserve(skb, NET_IP_ALIGN);
> +				skb_put(skb, len - NET_IP_ALIGN);
> +			} else {
> +				skb_reuse = skb;
> +				skb = NULL;
> +			}
> +		} else {
> +			/* Header alignment must be done in software */
> +			skb_reuse = skb;
> +
> +			skb = alloc_skb(len + NET_IP_ALIGN, GFP_ATOMIC);

dev_alloc_skb()


> +			if (skb) {
> +				skb->dev = netdev;
> +				skb_reserve(skb, NET_IP_ALIGN);
> +				skb_put(skb, len);
> +				memcpy(skb->data, skb_reuse->data, len);
> +			}
> +		}
> +
> +		if (skb) {
> +			skb->ip_summed = CHECKSUM_HW;
> +			skb->csum = checksum;
> +			skb->protocol = eth_type_trans(skb, netdev);
> +			netif_receive_skb(skb);
> +		} else {
> +			info->stats.rx_dropped++;
> +		}
> +
> +		desc->cpu_part =
> +			dma_map_single(netdev->class_dev.dev, skb_reuse->data,
> +				       rm9k_eth_rx_frame_len(netdev->mtu),
> +				       DMA_FROM_DEVICE);
> +		desc->xdma_part = RM9K_GE_RX_BUFFER_OWNED;
> +		skb_reuse->dev = netdev;
> +		rm9k_ge_rxdesc_to_skb(skb_reuse, desc);
> +		skb_queue_tail(&info->rx_queue, skb_reuse);
> +		gpi_writel(1, info->addr_xdma + 0x0008);
> +	}
> +
> +	return received_packets;
> +}
> +
> +
> +
> +/*
> + * Main function to handle the polling for Rx side NAPI.
> + * Receive interrupts have been disabled at this point.
> + */
> +static int rm9k_ge_poll(struct net_device *netdev, int *budget)
> +{
> +	rm9k_ge_port_info * const info = netdev_priv(netdev);
> +	int work_done = 0;
> +	unsigned long flags;
> +	u32 reg;
> +	const u32 mask = 0x1 << (info->slice * 8);
> +
> +	info->rx_work_limit = *budget;
> +	if (info->rx_work_limit > netdev->quota)
> +		info->rx_work_limit = netdev->quota;
> +
> +	do {
> +		work_done += rm9k_ge_receive_queue(netdev, 0);
> +
> +		/* Out of quota and there is work to be done */
> +		if (info->rx_work_limit < 0) {
> +			*budget -= work_done;
> +			netdev->quota -= work_done;
> +			return 1;
> +		}
> +
> +		reg = (titan_readl(0x0048) | titan_readl(0x004c)) & mask;
> +		titan_writel(reg, 0x0048);
> +		titan_writel(reg, 0x004c);
> +	} while (reg);
> +
> +	/*
> +	 * No more packets on the poll list. Turn the interrupts
> +	 * back on and we should be able to catch the new
> +	 * packets in the interrupt handler
> +	 */
> +	if (!work_done)
> +		work_done = 1;
> +
> +	*budget -= work_done;
> +	netdev->quota -= work_done;
> +
> +	spin_lock_irqsave(&info->lock, flags);
> +
> +	/* Remove us from the poll list */
> +	netif_rx_complete(netdev);
> +
> +	spin_unlock_irqrestore(&info->lock, flags);
> +
> +	/* Re-enable interrupts */
> +	lock_titan_regs();
> +	reg = titan_readl(0x0058);
> +	titan_writel(reg | mask, 0x0058);
> +	unlock_titan_regs();
> +
> +	return 0;
> +}
> +
> +
> +
> +static inline unsigned long long rm9k_ge_sctr(void __iomem * p)
> +{
> +	return	((unsigned long long) (gpi_readl(p + 8) & 0x0000ffff) << 32)
> +		| ((unsigned long long) (gpi_readl(p + 4) & 0x0000ffff) << 16)
> +		| (gpi_readl(p) & 0x0000ffff);
> +}
> +
> +
> +
> +static void rm9k_ge_update_stats(struct net_device *netdev)
> +{
> +	unsigned long flg;
> +	unsigned long long good_rx_frames, total_rx_frames;
> +	rm9k_ge_port_info * const info = netdev_priv(netdev);
> +	struct net_device_stats * const s = &info->stats;
> +
> +	spin_lock_irqsave(&info->stat_lock, flg);
> +
> +	/* Latch and clear counters */
> +	gpi_writel(0x00000022, info->addr_mstat + 0x0028);
> +	iob();
> +
> +	good_rx_frames = rm9k_ge_sctr(info->addr_mstat + 0x0040),
> +	total_rx_frames = rm9k_ge_sctr(info->addr_mstat + 0x0060);
> +
> +	s->rx_packets += good_rx_frames;
> +	s->rx_bytes += rm9k_ge_sctr(info->addr_mstat + 0x0050);
> +	s->rx_errors +=  total_rx_frames - good_rx_frames;
> +	s->multicast += rm9k_ge_sctr(info->addr_mstat + 0x00a0);
> +	s->rx_crc_errors += rm9k_ge_sctr(info->addr_mstat + 0x00e0);
> +	s->rx_frame_errors += rm9k_ge_sctr(info->addr_mstat + 0x00f0);
> +	s->rx_length_errors += rm9k_ge_sctr(info->addr_mstat + 0x0120)
> +				+ rm9k_ge_sctr(info->addr_mstat + 0x0130)
> +				+ rm9k_ge_sctr(info->addr_mstat + 0x0140)
> +				+ rm9k_ge_sctr(info->addr_mstat + 0x0150)
> +				+ rm9k_ge_sctr(info->addr_mstat + 0x0160);
> +
> +	s->tx_packets += rm9k_ge_sctr(info->addr_mstat + 0x0250);
> +	s->tx_bytes += rm9k_ge_sctr(info->addr_mstat + 0x0260);
> +
> +	spin_unlock_irqrestore(&info->stat_lock, flg);
> +	mod_timer(&info->stat_timer, jiffies + HZ * 600);
> +}
> +
> +
> +
> +/*
> + * Update the MAC address. Note that we have to write the
> + * address in three station registers, 16 bits each. And this
> + * has to be done for TMAC and RMAC
> + */
> +static void rm9k_ge_update_mac_address(struct net_device *netdev)
> +{
> +	rm9k_ge_port_info *const info = netdev_priv(netdev);
> +	u8 p_addr[6];
> +
> +	memcpy(info->port_mac_addr, netdev->dev_addr, ETH_ALEN);
> +	memcpy(p_addr, netdev->dev_addr, ETH_ALEN);
> +
> +	/* Update the Address Filtering Match tables */
> +	rm9k_ge_update_afx(info);
> +
> + 	pr_debug("%s: station MAC : %d %d %d %d %d %d\n",
> +		 netdev->name,
> + 		 p_addr[5], p_addr[4], p_addr[3],
> + 		 p_addr[2], p_addr[1], p_addr[0]);
> +
> + 	/* Set the MAC address here for TMAC and RMAC */
> + 	gpi_writel((p_addr[5] << 8) | p_addr[4], info->addr_mac + 0x004c);
> + 	gpi_writel((p_addr[3] << 8) | p_addr[2], info->addr_mac + 0x0050);
> + 	gpi_writel((p_addr[1] << 8) | p_addr[0], info->addr_mac + 0x0054);
> +
> + 	gpi_writel((p_addr[5] << 8) | p_addr[4], info->addr_mac + 0x000c);
> + 	gpi_writel((p_addr[3] << 8) | p_addr[2], info->addr_mac + 0x0010);
> + 	gpi_writel((p_addr[1] << 8) | p_addr[0], info->addr_mac + 0x0014);


> + * Set the MAC address of the Ethernet device
> + */
> +static int rm9k_ge_set_mac_address(struct net_device *netdev, void *addr)
> +{
> +	rm9k_ge_port_info * const info = netdev_priv(netdev);
> +	struct sockaddr *sa = addr;
> +
> +	memcpy(netdev->dev_addr, sa->sa_data, netdev->addr_len);
> +
> +	spin_lock_irq(&info->lock);
> +	rm9k_ge_update_mac_address(netdev);
> +	spin_unlock_irq(&info->lock);
> +
> +	return 0;
> +}
> +
> +#if defined(CONFIG_NET_POLL_CONTROLLER)
> +/*
> + * Netpoll support
> + */
> +static void rm9k_ge_netpoll(struct net_device *netdev)
> +{
> +	rm9k_ge_main_int_handler(netdev->irq, netdev, NULL);
> +}
> +#endif
> +
> +
> +
> +/*
> + * Get the Ethernet device stats
> + */
> +static struct net_device_stats * rm9k_ge_get_stats(struct net_device *netdev)
> +{
> +	rm9k_ge_port_info * const info = netdev_priv(netdev);
> +	rm9k_ge_update_stats(netdev);
> +	return &info->stats;
> +}
> +
> +/*
> + * Initialize the device as an Ethernet device
> + */
> +static int __init rm9k_ge_probe(struct device *dev)
> +{
> +	int err;
> +	unsigned int n_desc, n_rx, n_tx;
> +	struct platform_device * pdv;
> +	struct net_device * netdev;
> +	rm9k_ge_port_info * info;
> +	const struct resource
> +		*rsrc_slice, *rsrc_phy, *rsrc_rxdma, *rsrc_txdma,
> +		*rsrc_fifomem_rx, *rsrc_fifomem_tx, *rsrc_mac,
> +		*rsrc_mstat, *rsrc_pktproc, *rsrc_xdma, *rsrc_mdio,
> +		*rsrc_fifo_rx, *rsrc_fifo_tx, *rsrc_irq_main, *rsrc_irq_phy;
> +
> +	/* Get the platform dev. */
> +	if (unlikely(dev->bus != &platform_bus_type)) {
> +		err = -ENODEV;
> +		goto out;
> +	}
> +
> +	pdv = to_platform_device(dev);
> +
> +	rsrc_slice = rm9k_get_resource(pdv, 0, RM9K_GE_RESOURCE_GPI_SLICE);
> +	rsrc_phy = rm9k_get_resource(pdv, IORESOURCE_MEM, RM9K_GE_RESOURCE_PHY);
> +	rsrc_rxdma = rm9k_get_resource(pdv, IORESOURCE_MEM, RM9K_GE_RESOURCE_DMADESC_RX);
> +	rsrc_txdma = rm9k_get_resource(pdv, IORESOURCE_MEM, RM9K_GE_RESOURCE_DMADESC_TX);
> +	rsrc_fifomem_rx = rm9k_get_resource(pdv, 0,RM9K_GE_RESOURCE_FIFOMEM_RX);
> +	rsrc_fifomem_tx = rm9k_get_resource(pdv, 0,RM9K_GE_RESOURCE_FIFOMEM_TX);
> +	rsrc_mac = rm9k_get_resource(pdv, IORESOURCE_MEM, RM9K_GE_RESOURCE_MAC);
> +	rsrc_mstat = rm9k_get_resource(pdv, IORESOURCE_MEM, RM9K_GE_RESOURCE_MSTAT);
> +	rsrc_pktproc = rm9k_get_resource(pdv, IORESOURCE_MEM, RM9K_GE_RESOURCE_PKTPROC);
> +	rsrc_xdma = rm9k_get_resource(pdv, IORESOURCE_MEM, RM9K_GE_RESOURCE_XDMA);
> +	rsrc_mdio = rm9k_get_resource(pdv, 0, RM9K_GE_RESOURCE_MDIO_CHANNEL);
> +	rsrc_fifo_rx = rm9k_get_resource(pdv, IORESOURCE_MEM, RM9K_GE_RESOURCE_FIFO_RX);
> +	rsrc_fifo_tx = rm9k_get_resource(pdv, IORESOURCE_MEM, RM9K_GE_RESOURCE_FIFO_TX);
> +	rsrc_irq_main = rm9k_get_resource(pdv, IORESOURCE_IRQ, RM9K_GE_RESOURCE_IRQ_MAIN);
> +	rsrc_irq_phy = rm9k_get_resource(pdv, IORESOURCE_IRQ, RM9K_GE_RESOURCE_IRQ_PHY);
> +
> +	if (!rsrc_slice || !rsrc_phy || !rsrc_rxdma || !rsrc_fifo_rx
> +	    || !rsrc_fifo_tx || !rsrc_txdma || !rsrc_fifomem_rx
> +	    || !rsrc_mstat || !rsrc_fifomem_tx || !rsrc_mac || !rsrc_mdio
> +	    || !rsrc_pktproc || !rsrc_xdma || !rsrc_irq_main
> +	    || !rsrc_irq_phy) {
> +	    	err = -ENODEV;
> +		goto out;
> +	}

leak, if some succeed but others fail


> +	/* Compute RX and TX ring sizes */
> +	n_desc = (rsrc_rxdma->end - rsrc_rxdma->start + 1) / sizeof (rx_desc_t);
> +	switch (n_desc) {
> +		case 64 ... 127:
> +			n_rx = 64;
> +			break;
> +		case 128 ... 255:
> +			n_rx = 128;
> +			break;
> +		case 256 ... 511:
> +			n_rx = 256;
> +			break;
> +		default:
> +			n_rx = (n_desc >= 512) ? 512 : 0;
> +			break;
> +	}
> +
> +	n_desc = (rsrc_txdma->end - rsrc_txdma->start + 1) / sizeof (tx_desc_t);
> +	switch (n_desc) {
> +		case 64 ... 127:
> +			n_tx = 64;
> +			break;
> +		case 128 ... 255:
> +			n_tx = 128;
> +			break;
> +		case 256 ... 511:
> +			n_tx = 256;
> +			break;
> +		default:
> +			n_tx = (n_desc >= 512) ? 512 : 0;
> +			break;
> +	}
> +	if ((!n_rx || !n_tx)) {
> +		err = -EINVAL;
> +		goto out;
> +	}
> +
> +	netdev = alloc_etherdev(sizeof(rm9k_ge_port_info)
> +				+ (n_rx + n_tx) * sizeof (struct sk_buff *));

add some parens for increased readability


> +	if (!netdev) {
> +		err = -ENODEV;
> +		goto out;
> +	}
> +
> +	dev_set_drvdata(dev, netdev);
> +	SET_NETDEV_DEV(netdev, dev);
> +	netdev->irq = rsrc_irq_main->start;
> +	netdev->open = rm9k_ge_open;
> +	netdev->stop = rm9k_ge_stop;
> +	netdev->hard_start_xmit = rm9k_ge_start_xmit;
> +	netdev->get_stats = rm9k_ge_get_stats;
> +	netdev->set_multicast_list = rm9k_ge_set_multi;
> +	netdev->set_mac_address = rm9k_ge_set_mac_address;
> +	netdev->mtu = ETH_DATA_LEN;
> +#if defined(CONFIG_NET_POLL_CONTROLLER)
> +	netdev->poll_controller = rm9k_ge_netpoll;
> +#endif
> +
> +	/* Tx timeout */
> +	netdev->tx_timeout = rm9k_ge_tx_timeout;
> +	netdev->watchdog_timeo = 2 * HZ;
> +
> +	/* Set these to very high values */
> +	netdev->poll = rm9k_ge_poll;
> +	netdev->weight = 64;
> +	netdev->base_addr = 0;
> +
> +	netdev->change_mtu = rm9k_ge_change_mtu;
> +
> +	info = netdev_priv(netdev);
> +	spin_lock_init(&info->stat_lock);
> +	init_timer(&info->stat_timer);
> +	info->stat_timer.function = (void *) rm9k_ge_update_stats;
> +	info->stat_timer.data = (unsigned long) netdev;
> +
> +	skb_queue_head_init(&info->rx_queue);
> +	skb_queue_head_init(&info->tx_queue);
> +
> +	info->irq_phy = rsrc_irq_phy->start;
> +	info->port_num = pdv->id;
> +	info->slice = rsrc_slice->start;
> +	info->mdio_channel = rsrc_mdio->start;
> +
> +	info->addr_mdio = ioremap_nocache(
> +		rsrc_phy->start, rsrc_phy->end + 1 - rsrc_phy->start);

check for NULL return value, handle error


> +	/* Set up RX descriptor ring */
> +	info->rx_ring_size = n_rx;
> +	info->rx_desc_area = (rx_desc_t *) ioremap_nocache(
> +		rsrc_rxdma->start, n_rx * sizeof (rx_desc_t *));
> +	info->rx_dma = (dma_addr_t) rsrc_rxdma->start;
> +
> +	/* Set up the TX descriptor ring */
> +	info->tx_ring_size = n_tx;
> +	info->tx_desc_area = (tx_desc_t *) ioremap_nocache(
> +		rsrc_txdma->start, n_tx * sizeof (tx_desc_t *));
> +	info->tx_dma = (dma_addr_t) rsrc_txdma->start;
> +
> +	/* Set up the RX and TX FIFOs */
> +	info->rxfifo_start = rsrc_fifomem_rx->start;
> +	info->rxfifo_len = rsrc_fifomem_rx->end + 1 - rsrc_fifomem_rx->start;
> +	info->txfifo_start = rsrc_fifomem_tx->start;
> +	info->txfifo_len = rsrc_fifomem_tx->end + 1 - rsrc_fifomem_tx->start;
> +
> +	info->addr_mac = ioremap_nocache(
> +		rsrc_mac->start, rsrc_mac->end + 1 - rsrc_mac->start);
> +	info->addr_pktproc = ioremap_nocache(
> +		rsrc_pktproc->start,
> +		rsrc_pktproc->end + 1 - rsrc_pktproc->start);
> +	info->addr_xdma = ioremap_nocache(
> +		rsrc_xdma->start, rsrc_xdma->end + 1 - rsrc_xdma->start);
> +	info->addr_mstat = ioremap_nocache(
> +		rsrc_mstat->start, rsrc_mstat->end + 1 - rsrc_mstat->start);
> +	info->addr_fifo_rx = ioremap_nocache(
> +		rsrc_fifo_rx->start,
> +		rsrc_fifo_rx->end + 1 - rsrc_fifo_rx->start);
> +	info->addr_fifo_tx = ioremap_nocache(
> +		rsrc_fifo_tx->start,
> +		rsrc_fifo_tx->end + 1 - rsrc_fifo_tx->start);

check all these for NULL, handle failure


> +	spin_lock_init(&info->lock);
> +
> +	/* set MAC addresses */
> +	memcpy(netdev->dev_addr, hwaddr, ETH_ALEN);
> +
> +	err = register_netdev(netdev);
> +
> +	if (err)
> +		goto out_free_netdev;
> +
> +	return 0;
> +
> +out_free_netdev:
> +	if (info->addr_mdio) iounmap(info->addr_mdio);
> +	if (info->rx_desc_area) iounmap(info->rx_desc_area);
> +	if (info->tx_desc_area) iounmap(info->tx_desc_area);
> +	if (info->addr_mac) iounmap(info->addr_mac);
> +	if (info->addr_pktproc) iounmap(info->addr_pktproc);
> +	if (info->addr_xdma) iounmap(info->addr_xdma);
> +	if (info->addr_mstat) iounmap(info->addr_mstat);
> +	if (info->addr_fifo_rx) iounmap(info->addr_fifo_rx);
> +	if (info->addr_fifo_tx) iounmap(info->addr_fifo_tx);
> +	kfree(netdev);
> +
> +out:
> +	return err;
> +}
> +
> +static int __exit rm9k_ge_remove(struct device *dev)
> +{
> +	struct net_device * const netdev =
> +		(struct net_device *) dev_get_drvdata(dev);
> +	unregister_netdev(netdev);
> +	free_netdev(netdev);
> +	return 0;
> +}
> +
> +static struct device_driver rm9k_ge_driver = {
> +	.name   = RM9K_GE_NAME,
> +	.bus    = &platform_bus_type,
> +	.probe  = rm9k_ge_probe,
> +	.remove	= __exit_p(rm9k_ge_remove)
> +};
> +
> +static void rm9k_ge_init_mdio(void * addr, unsigned int chan)
> +{
> +	u32 reg;
> +
> +	/* Take the MDIO channel out of reset */
> +	lock_titan_regs();
> +	reg = titan_readl(0x0004);
> +	reg &= ~(0x1 << (11 + chan));
> +	titan_writel(reg, 0x0004);
> +	unlock_titan_regs();
> +	iob();
> +
> +	if(rm9k_ge_mdio_setup(addr, 0x1f)) {
> +		lock_titan_regs();
> +		reg = titan_readl(0x0004);
> +		reg |= 0x1 << (11 + chan);
> +		titan_writel(reg, 0x0004);
> +		unlock_titan_regs();
> +		iob();
> +	}
> +}
> +
> +static void rm9k_ge_cleanup_mdio(unsigned int chan)
> +{
> +	u32 reg;
> +	rm9k_ge_mdio_cleanup();
> +
> +	/* Reset the MDIO channel */
> +	lock_titan_regs();
> +	reg = titan_readl(0x0004);
> +	reg |= 0x1 << (11 + chan);
> +	titan_writel(reg, 0x0004);
> +	unlock_titan_regs();
> +}
> +
> +/*
> + * Register the Titan GE with the kernel
> + */
> +static int __init rm9k_ge_init_module(void)
> +{
> +	unsigned int rev;
> +
> +	rev = read_c0_prid() & 0x000000ff;
> +	hw_hdr_align = rev > 0x30;
> +
> +	if (driver_register(&rm9k_ge_driver)) {
> +		printk(KERN_ERR "%s: Driver registration failed\n",
> +		       rm9k_ge_name);
> +		return 1;
> +	}
> +
> +	printk(KERN_NOTICE "%s: RM9K Gigabit Ethernet Driver loaded "
> +	       "(H/W rev. %#04x)\n",
> +	       rm9k_ge_name, rev);
> +	return 0;
> +}
> +
> +/*
> + * Unregister the Titan GE from the kernel
> + */
> +static void __exit rm9k_ge_cleanup_module(void)
> +{
> +	driver_unregister(&rm9k_ge_driver);
> +}
> +
> +MODULE_AUTHOR("Thomas Koeller <thomas.koeller@baslerweb.com>");
> +MODULE_DESCRIPTION("Rm9k gigabit ethernet driver");
> +MODULE_LICENSE("GPL");
> +
> +MODULE_PARM_DESC(autoneg, "Enable speed/duplex autonegotiation (bool)");
> +MODULE_PARM_DESC(full_duplex, "Force full/half duplex mode (bool)");
> +MODULE_PARM_DESC(speed, "Force speed (0 - 10MBit, 1 - 100MBit, 2 - 1GBit)");
> +MODULE_PARM_DESC(hwaddr, "Ethernet address (xx:xx:xx:xx:xx:xx)");
> +
> +module_init(rm9k_ge_init_module);
> +module_exit(rm9k_ge_cleanup_module);
> Index: linux-excite/drivers/net/rm9k_mdio.c
> ===================================================================
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ linux-excite/drivers/net/rm9k_mdio.c	2006-06-23 13:28:55.000000000 +0100
> @@ -0,0 +1,165 @@
> +/*
> + * drivers/net/titan_mdio.c - Driver for Titan ethernet ports
> + *
> + * Copyright (C) 2003 PMC-Sierra Inc.
> + * Author : Manish Lachwani (lachwani@pmc-sierra.com)
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * as published by the Free Software Foundation; either version 2
> + * of the License, or (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
> + *
> + * Management Data IO (MDIO) driver for the Titan GMII. Interacts with the Marvel PHY
> + * on the Titan. No support for the TBI as yet.
> + *
> + */
> +
> +#include <linux/types.h>
> +#include <linux/ioport.h>
> +#include <asm/io.h>
> +#include <asm/delay.h>
> +
> +#include "rm9k_mdio.h"
> +
> +#define MDIO_DEBUG
> +
> +#define gpi_readl(__a__)		__raw_readl((__a__))
> +#define gpi_writel(__v__, __a__)	__raw_writel((__v__), (__a__))
> +
> +/*
> + * Local constants
> + */
> +#define MAX_CLKA		1023
> +#define MAX_PHY_DEV		31
> +#define MAX_PHY_REG		31
> +#define	READ_OPCODE		(0x2 << 8)
> +#define WRITE_OPCODE		(0x1 << 8)
> +#define MAX_MDIO_POLL		100
> +
> +/*
> + * Titan MDIO and SCMB register offsets
> + */
> +#define SCMB_CONTROL			0x00  /* SCMB Control */
> +#define SCMB_CLKA			0x04  /* SCMB Clock A */
> +#define MDIO_COMMAND			0x10  /* MDIO Command */
> +#define MDIO_DEVICE_PORT_ADDRESS	0x14  /* MDIO Device and Port addrs */
> +#define MDIO_DATA			0x18  /* MDIO Data */
> +#define MDIO_INTERRUPTS			0x1c  /* MDIO Interrupts */
> +
> +void __iomem * base = NULL;
> +
> +/*
> + * Function to poll the MDIO
> + */
> +static int mdio_poll(void)
> +{
> +	int i;
> +
> +	for (i = 0; i < MAX_MDIO_POLL; i++) {
> +		if(!(gpi_readl(base + MDIO_COMMAND) & 0x8000))
> +			break;
> +		udelay(10);
> +	}
> +
> +	return i >= MAX_MDIO_POLL;
> +}
> +
> +/*
> + * Initialize and configure the MDIO
> + */
> +int rm9k_ge_mdio_setup(void __iomem * addr, unsigned int clka)
> +{
> +	if (base)
> +		return -1;
> +
> +	base = addr;
> +
> +	/* Reset the SCMB and program into MDIO mode*/
> +	gpi_writel(0x9000, base + SCMB_CONTROL);
> +	wmb();
> +	gpi_writel(0x1000, base + SCMB_CONTROL);
> +	wmb();
> +
> +	/* CLK A */
> +	gpi_writel(clka & 0x3ff, base + SCMB_CLKA);
> +
> +	pr_debug("%s(%p, %u)\n"
> +		 "\tSCMB_CONTROL (%p) = %#010x\n",
> +		 __func__, addr, clka, base + SCMB_CLKA,
> +		 gpi_readl(base + SCMB_CLKA));
> +
> +	return 0;
> +}
> +
> +void rm9k_ge_mdio_cleanup(void)
> +{
> +	base = 0;
> +}
> +
> +/*
> + * Read the MDIO register. This is what the individual parametes mean:
> + *
> + * dev_addr : PHY ID
> + * reg_addr : register offset
> + *
> + * See the spec for the Titan MAC. We operate in the Direct Mode.
> + */
> +
> +#define MAX_RETRIES	2
> +
> +int rm9k_ge_mdio_read(int dev_addr, int reg_addr, u16 *pdata)
> +{
> +	u32 val;
> +	int retries;
> +
> +	for (retries = 0; retries < MAX_RETRIES; retries++) {
> +		gpi_writel(((dev_addr << 8) & 0x1f00)
> +			     | ( reg_addr & 0x001f) | 0x4000,
> +			     base + MDIO_DEVICE_PORT_ADDRESS);
> +			     wmb();
> +		gpi_writel(READ_OPCODE | 0x1, base + MDIO_COMMAND);
> +		if (mdio_poll())
> +			return -1;
> +		*pdata = (unsigned int)
> +			 (gpi_readl(base + MDIO_DATA) & 0x0000ffff);
> +		val = gpi_readl(base + MDIO_INTERRUPTS);
> +		if (~val & 0x2)
> +			return 0;
> +		udelay(30);
> +	}
> +
> +	return -1;
> +}
> +
> +/*
> + * Write to the MDIO register
> + *
> + * dev_addr : PHY ID
> + * reg_addr : register that needs to be written to
> + *
> + */
> +int rm9k_ge_mdio_write(int dev_addr, int reg_addr, u16 data)
> +{
> +	if (mdio_poll())
> +		return -1;
> +
> +	gpi_writel(((dev_addr << 8) & 0x1f00)
> +		     | (reg_addr & 0x001f) | 0x4000,
> +		     base + MDIO_DEVICE_PORT_ADDRESS);
> +	gpi_writel(data, base + MDIO_DATA);
> +	wmb();
> +	gpi_writel(WRITE_OPCODE | 0x1, base + MDIO_COMMAND);
> +	if (mdio_poll())
> +		return -1;
> +
> +	return	(gpi_readl(base + MDIO_INTERRUPTS) & 0x2) ? -1 : 0;
> +}
> Index: linux-excite/drivers/net/rm9k_mdio.h
> ===================================================================
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ linux-excite/drivers/net/rm9k_mdio.h	2006-06-23 13:28:55.000000000 +0100
> @@ -0,0 +1,36 @@
> +/*
> + * MDIO used to interact with the PHY when using GMII/MII
> + */
> +#ifndef _RM9K_MDIO_H
> +#define _RM9K_MDIO_H
> +
> +#include <asm/types.h>
> +
> +
> +/* GMII specific registers */
> +#define RM9K_GE_MDIO_PHY_BMCR		0x00
> +#define RM9K_GE_MDIO_PHY_BMSR		0x01
> +#define RM9K_GE_MDIO_PHY_ID_HI		0x02
> +#define RM9K_GE_MDIO_PHY_ID_LO		0x03
> +#define	RM9K_PHY_AUTONEG_ADV		0x04
> +#define	RM9K_PHY_LP_ABILITY		0x05
> +#define	RM9K_GE_MDIO_MII_CTRL		0x09
> +#define	RM9K_GE_MDIO_MII_EXTENDED	0x0f
> +#define	RM9K_GE_MDIO_PHY_CTRL		0x10
> +#define	RM9K_GE_MDIO_PHY_STATUS		0x11
> +#define	RM9K_GE_MDIO_PHY_INTSTAT	0x14
> +#define	RM9K_GE_MDIO_PHY_INTMASK	0x15
> +#define	RM9K_GE_MDIO_PHY_INTCLEAR	0x17
> +#define	RM9K_GE_MDIO_PHY_LED		0x18
> +#define	RM9K_GE_MDIO_PHY_LED_OVER	0x19
> +
> +/*
> + * Function Prototypes
> + */
> +int rm9k_ge_mdio_setup(void *, unsigned int);
> +void rm9k_ge_mdio_cleanup(void);
> +unsigned long rm9k_ge_mdio_ident_phy(int);
> +int rm9k_ge_mdio_read(int, int, u16 *);
> +int rm9k_ge_mdio_write(int, int, u16);
> +
> +#endif /* _RM9K_MDIO_H */
> 

