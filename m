From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH][RFC take 2] Add support for the RDC R6040 Fast Ethernet
 controller
Date: Tue, 13 Nov 2007 11:09:30 -0800
Message-ID: <20071113110930.561d038b@freepuppy.rosehill>
References: <200710292251.43257.florian.fainelli@telecomint.eu>
	<200711101922.19004.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
To: Florian Fainelli <florian.fainelli@telecomint.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35627 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760931AbXKMTMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 14:12:06 -0500
In-Reply-To: <200711101922.19004.florian.fainelli@telecomint.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 10 Nov 2007 19:22:18 +0100
Florian Fainelli <florian.fainelli@telecomint.eu> wrote:

> This patch adds support for the RDC R6040 MAC we can find in the RDC R-321x System-on-chips and some other devices.
> You will need the RDC PCI identifiers if you want to test this driver :
> 
> RDC_PCI_VENDOR_ID = 0x17f3
> RDC_PCI_DEVICE_ID_RDC_R6040 = 0x6040
> 
> Changes from first patch :
> - use ioread/iowrite
> - cleaned up NAPI
> - suppressed wrong use of local_irq_enable/disable
> - handle multicast cases
> - notify when the carrier changes
> - add ethtool routines
> - rewrite IRQ handling with
> - cleaned up PCI table
> - make checkpatch happy
> - documented registers
> - 
> 
> (I do not mention everything you have been saying in your mails, but I have fixed them as well).
> 
> Thanks to Jeff and Stephen for their detailed comments.


More comments

> +static void
> +r6040_tx_timeout(struct net_device *dev)
> +{
> +	struct r6040_private *priv = netdev_priv(dev);
> +
> +	disable_irq(dev->irq);
> +	napi_disable(&priv->napi);
> +	spin_lock(&priv->lock);
> +	dev->stats.tx_errors++;
> +	spin_unlock(&priv->lock);
> +
> +	netif_stop_queue(dev);

Message!

Also, the intention is for driver to do recovery on transmit timeout


> +}
> +
> +/* Allocate skb buffer for rx descriptor */
> +static void rx_buf_alloc(struct r6040_private *lp, struct net_device *dev)
> +{
> +	struct r6040_descriptor *descptr;
> +	void __iomem *ioaddr = lp->base;
> +
> +	descptr = lp->rx_insert_ptr;
> +	while (lp->rx_free_desc < RX_DCNT) {
> +		descptr->skb_ptr = dev_alloc_skb(MAX_BUF_SIZE);

Use netdev_alloc_skb()

You may get better performance if you allocate slightly larger buffer
and use skb_reserve(skb, NET_IP_ALIGN)

> +
> +		if (!descptr->skb_ptr)
> +			break;
> +		descptr->buf = cpu_to_le32(pci_map_single(lp->pdev,
> +			descptr->skb_ptr->tail,
> +			MAX_BUF_SIZE, PCI_DMA_FROMDEVICE));
> +		descptr->status = 0x8000;
> +		descptr = descptr->vndescp;
> +		lp->rx_free_desc++;
> +		/* Trigger RX DMA */
> +		iowrite16(lp->mcr0 | 0x0002, ioaddr);
> +	}
> +	lp->rx_insert_ptr = descptr;
> +}
> +
> +
> +static struct net_device_stats *r6040_get_stats(struct net_device *dev)
> +{
> +	struct r6040_private *priv = netdev_priv(dev);
> +	void __iomem *ioaddr = priv->base;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&priv->lock, flags);
> +	priv->stats.rx_crc_errors += ioread8(ioaddr + ME_CNT1);
> +	priv->stats.multicast += ioread8(ioaddr + ME_CNT0);
> +	spin_unlock_irqrestore(&priv->lock, flags);

Don't need to have net_device_stats in r6040_private, there is space
already reserved in dev->net_stats.

> +	return &priv->stats;
> +}
> +

> +static int r6040_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
> +{
> +	struct r6040_private *lp = netdev_priv(dev);
> +	struct mii_ioctl_data *data = (struct mii_ioctl_data *) &rq->ifr_data;
> +	int rc;
> +
> +	if (!netif_running(dev))
> +		return -EINVAL;
> +	spin_lock_irq(&lp->lock);
> +	rc = generic_mii_ioctl(&lp->mii_if, data, cmd, NULL);
> +	spin_unlock_irq(&lp->lock);
> +	r6040_set_carrier(&lp->mii_if);
> +	return rc;
> +}
> +
> +static int r6040_rx(struct net_device *dev, int limit)
> +{
> +	struct r6040_private *priv = netdev_priv(dev);
> +	int count;
> +	void __iomem *ioaddr = priv->base;
> +	u16 err;
> +
> +	for (count = 0; count < limit; ++count) {
> +		struct r6040_descriptor *descptr = priv->rx_remove_ptr;
> +		struct sk_buff *skb_ptr;
> +
> +		/* Disable RX interrupt */
> +		iowrite16(ioread16(ioaddr + MIER) & (~RX_INT), ioaddr + MIER);
> +		descptr = priv->rx_remove_ptr;
> +
> +		/* Check for errors */
> +		err = ioread16(ioaddr + MLSR);
> +		if (err & 0x0400) priv->stats.rx_errors++;
> +		/* RX FIFO over-run */
> +		if (err & 0x8000) priv->stats.rx_fifo_errors++;
> +		/* RX descriptor unavailable */
> +		if (err & 0x0080) priv->stats.rx_frame_errors++;
> +		/* Received packet with length over buffer lenght */
> +		if (err & 0x0020) priv->stats.rx_over_errors++;
> +		/* Received packet with too long or short */
> +		if (err & (0x0010|0x0008)) priv->stats.rx_length_errors++;
> +		/* Received packet with CRC errors */
> +		if (err & 0x0004) {
> +			spin_lock(&priv->lock);
> +			priv->stats.rx_crc_errors++;
> +			spin_unlock(&priv->lock);
> +		}
> +
> +		while (priv->rx_free_desc) {
> +			/* No RX packet */
> +			if (descptr->status & 0x8000)
> +				break;
> +			skb_ptr = descptr->skb_ptr;
> +			if (!skb_ptr) {
> +				printk(KERN_ERR "%s: Inconsistent RX"
> +					"descriptor chain\n",
> +					dev->name);
> +				break;
> +			}
> +			descptr->skb_ptr = NULL;
> +			skb_ptr->dev = priv->dev;
> +			/* Do not count the CRC */
> +			skb_put(skb_ptr, descptr->len - 4);
> +			pci_unmap_single(priv->pdev, descptr->buf,
> +				MAX_BUF_SIZE, PCI_DMA_FROMDEVICE);
> +			skb_ptr->protocol = eth_type_trans(skb_ptr, priv->dev);
> +			/* Send to upper layer */
> +			netif_receive_skb(skb_ptr);
> +			dev->last_rx = jiffies;
> +			priv->dev->stats.rx_packets++;
> +			priv->dev->stats.rx_bytes += descptr->len;
> +			/* To next descriptor */
> +			descptr = descptr->vndescp;
> +			priv->rx_free_desc--;
> +		}
> +		priv->rx_remove_ptr = descptr;
> +	}
> +	/* Allocate new RX buffer */
> +	if (priv->rx_free_desc < RX_DCNT)
> +		rx_buf_alloc(priv, priv->dev);
> +
> +	return count;
> +}
> +
> +static void r6040_tx(struct net_device *dev)
> +{
> +	struct r6040_private *priv = netdev_priv(dev);
> +	struct r6040_descriptor *descptr;
> +	void __iomem *ioaddr = priv->base;
> +	struct sk_buff *skb_ptr;
> +	u16 err;
> +
> +	spin_lock(&priv->lock);
> +	descptr = priv->tx_remove_ptr;
> +	while (priv->tx_free_desc < TX_DCNT) {
> +		/* Check for errors */
> +		err = ioread16(ioaddr + MLSR);
> +
> +		if (err & 0x0200) priv->stats.rx_fifo_errors++;
> +		if (err & (0x2000 | 0x4000)) priv->stats.tx_carrier_errors++;

Break these into two lines.

> +		if (descptr->status & 0x8000)
> +			break; /* Not complte */

Fix spelling.

> +		skb_ptr = descptr->skb_ptr;
> +		pci_unmap_single(priv->pdev, descptr->buf,
> +			skb_ptr->len, PCI_DMA_TODEVICE);
> +		/* Free buffer */
> +		dev_kfree_skb_irq(skb_ptr);
> +		descptr->skb_ptr = NULL;
> +		/* To next descriptor */
> +		descptr = descptr->vndescp;
> +		priv->tx_free_desc++;
> +	}
> +	priv->tx_remove_ptr = descptr;
> +
> +	if (priv->tx_free_desc)
> +		netif_wake_queue(dev);
> +	spin_unlock(&priv->lock);
> +}
>
> +/* The RDC interrupt handler. */
> +static irqreturn_t r6040_interrupt(int irq, void *dev_id)
> +{
> +	struct net_device *dev = dev_id;
> +	struct r6040_private *lp = netdev_priv(dev);
> +	void __iomem *ioaddr = lp->base;
> +	u16 status;
> +	int handled = 1;

Don't bother with handled...

> +	/* Mask off RDC MAC interrupt */
> +	iowrite16(MSK_INT, ioaddr + MIER);
> +	/* Read MISR status and clear */
> +	status = ioread16(ioaddr + MISR);
> +
> +	if (status == 0x0000 || status == 0xffff)
> +		return IRQ_NONE;
> +
> +	/* RX interrupt request */
> +	if (status & 0x01) {
> +		netif_rx_schedule(dev, &lp->napi);
> +		iowrite16(TX_INT, ioaddr + MIER);
> +	}
> +
> +	/* TX interrupt request */
> +	if (status & 0x10)
> +		r6040_tx(dev);
> +
> +	return IRQ_RETVAL(handled);
	return IRQ_HANDLED;

> +}
> +
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +static void r6040_poll_controller(struct net_device *dev)
> +{
> +	disable_irq(dev->irq);
> +	r6040_interrupt(dev->irq, (void *)dev);
> +	enable_irq(dev->irq);
> +}
> +#endif
> +
> +
> +/* Init RDC MAC */
> +static void r6040_up(struct net_device *dev)
> +{
> +	struct r6040_private *lp = netdev_priv(dev);
> +	struct r6040_descriptor *descptr;
> +	void __iomem *ioaddr = lp->base;
> +	int i;
> +	__le32 tmp_addr;
> +	dma_addr_t desc_dma, start_dma;
> +
> +	/* Initialize */
> +	lp->tx_free_desc = TX_DCNT;
> +	lp->rx_free_desc = 0;
> +	/* Init descriptor */
> +	memset(lp->desc_pool, 0, ALLOC_DESC_SIZE); /* Let all descriptor = 0 */
> +	lp->tx_insert_ptr = (struct r6040_descriptor *)lp->desc_pool;
> +	lp->tx_remove_ptr = lp->tx_insert_ptr;
> +	lp->rx_insert_ptr = (struct r6040_descriptor *)lp->tx_insert_ptr +
> +		TX_DCNT;
> +	lp->rx_remove_ptr = lp->rx_insert_ptr;
> +	/* Init TX descriptor */
> +	descptr = lp->tx_insert_ptr;
> +	desc_dma = lp->desc_dma;
> +	start_dma = desc_dma;
> +	for (i = 0; i < TX_DCNT; i++) {
> +		descptr->ndesc = cpu_to_le32(desc_dma +
> +			sizeof(struct r6040_descriptor));
> +		descptr->vndescp = (descptr + 1);
> +		descptr = (descptr + 1);
> +		desc_dma += sizeof(struct r6040_descriptor);
> +	}
> +	(descptr - 1)->ndesc = cpu_to_le32(start_dma);
> +	(descptr - 1)->vndescp = lp->tx_insert_ptr;
> +	/* Init RX descriptor */
> +	start_dma = desc_dma;
> +	descptr = lp->rx_insert_ptr;
> +	for (i = 0; i < RX_DCNT; i++) {
> +		descptr->ndesc = cpu_to_le32(desc_dma +
> +			sizeof(struct r6040_descriptor));
> +		descptr->vndescp = (descptr + 1);
> +		descptr = (descptr + 1);
> +		desc_dma += sizeof(struct r6040_descriptor);
> +	}
> +	(descptr - 1)->ndesc = cpu_to_le32(start_dma);
> +	(descptr - 1)->vndescp = lp->rx_insert_ptr;
> +
> +	/* Allocate buffer for RX descriptor */
> +	rx_buf_alloc(lp, dev);
> +
> +	/* TX and RX descriptor start Register */
> +	tmp_addr = cpu_to_le32((u32)lp->tx_insert_ptr);
> +	tmp_addr = virt_to_bus((volatile void *)tmp_addr);
> +	iowrite16(tmp_addr, ioaddr + MTD_SA0);
> +	iowrite16(tmp_addr >> 16, ioaddr + MTD_SA1);
> +	tmp_addr = cpu_to_le32((u32)lp->rx_insert_ptr);
> +	tmp_addr = virt_to_bus((volatile void *)tmp_addr);
> +	iowrite16(tmp_addr, ioaddr + MRD_SA0);
> +	iowrite16(tmp_addr >> 16, ioaddr + MRD_SA1);
> +
> +	/* Buffer Size Register */
> +	iowrite16(MAX_BUF_SIZE, ioaddr + MR_BSR);
> +	/* Read the PHY ID */
> +	lp->switch_sig = phy_read(ioaddr, 0, 2);
> +
> +	if (lp->switch_sig  == ICPLUS_PHY_ID) {
> +		phy_write(ioaddr, 29, 31, 0x175C); /* Enable registers */
> +		lp->phy_mode = 0x8000;
> +	} else {
> +		/* PHY Mode Check */
> +		phy_write(ioaddr, lp->phy_addr, 4, PHY_CAP);
> +		phy_write(ioaddr, lp->phy_addr, 0, PHY_MODE);
> +
> +		if (PHY_MODE == 0x3100)
> +			lp->phy_mode = phy_mode_chk(dev);
> +		else
> +			lp->phy_mode = (PHY_MODE & 0x0100) ? 0x8000:0x0;
> +	}
> +	/* MAC Bus Control Register */
> +	iowrite16(MBCR_DEFAULT, ioaddr + MBCR);
> +
> +	/* MAC TX/RX Enable */
> +	lp->mcr0 |= lp->phy_mode;
> +	iowrite16(lp->mcr0, ioaddr);
> +
> +	/* set interrupt waiting time and packet numbers */
> +	iowrite16(0x0F06, ioaddr + MT_ICR);
> +	iowrite16(0x0F06, ioaddr + MR_ICR);
> +
> +	/* improve performance (by RDC guys) */
> +	phy_write(ioaddr, 30, 17, (phy_read(ioaddr, 30, 17) | 0x4000));
> +	phy_write(ioaddr, 30, 17, ~((~phy_read(ioaddr, 30, 17)) | 0x2000));
> +	phy_write(ioaddr, 0, 19, 0x0000);
> +	phy_write(ioaddr, 0, 30, 0x01F0);
> +
> +	/* Interrupt Mask Register */
> +	iowrite16(INT_MASK, ioaddr + MIER);
> +}
> +
> +/*
> +  A periodic timer routine
> +	Polling PHY Chip Link Status
> +*/
> +static void r6040_timer(unsigned long data)
> +{
> +	struct net_device *dev = (struct net_device *)data;
> +	struct r6040_private *lp = netdev_priv(dev->priv);
> +	void __iomem *ioaddr = lp->base;
> +	u16 phy_mode;
> +
> +	/* Polling PHY Chip Status */
> +	if (PHY_MODE == 0x3100)
> +		phy_mode = phy_mode_chk(dev);
> +	else
> +		phy_mode = (PHY_MODE & 0x0100) ? 0x8000:0x0;
> +
> +	if (phy_mode != lp->phy_mode) {
> +		lp->phy_mode = phy_mode;
> +		lp->mcr0 = (lp->mcr0 & 0x7fff) | phy_mode;
> +		iowrite16(lp->mcr0, ioaddr);
> +		printk(KERN_INFO "Link Change %x \n", ioread16(ioaddr));
> +	}
> +
> +	/* Timer active again */
> +	lp->timer.expires = TIMER_WUT;
> +	add_timer(&lp->timer);

	Don't use add_timer like this it is racy.
	You should be doing:

	mod_timer(&lp->timer, jiffies + round_jiffies(HZ));

	Get rid of TIMER_WUT


> +
> +/* Read/set MAC address routines */
> +static void r6040_mac_address(struct net_device *dev)
> +{
> +	struct r6040_private *lp = netdev_priv(dev);
> +	void __iomem *ioaddr = lp->base;
> +	u16 *adrp;
> +
> +	/* MAC operation register */
> +	iowrite16(0x01, ioaddr + MCR1); /* Reset MAC */
> +	iowrite16(2, ioaddr + MAC_SM); /* Reset internal state machine */
> +	iowrite16(0, ioaddr + MAC_SM);
> +	udelay(5000);
> +
> +	/* Restore MAC Address */
> +	adrp = (u16 *) dev->dev_addr;
> +	iowrite16(adrp[0], ioaddr + MID_0L);
> +	iowrite16(adrp[1], ioaddr + MID_0M);
> +	iowrite16(adrp[2], ioaddr + MID_0H);
> +}
> +
> +static int
> +r6040_open(struct net_device *dev)
> +{
> +	struct r6040_private *lp = dev->priv;
> +	int ret;
> +
> +	/* Request IRQ and Register interrupt handler */
> +	ret = request_irq(dev->irq, &r6040_interrupt,
> +		IRQF_SHARED, dev->name, dev);
> +	if (ret)
> +		return ret;
> +
> +	/* Set MAC address */
> +	r6040_mac_address(dev);
> +
> +	/* Allocate Descriptor memory */
> +	lp->desc_pool = pci_alloc_consistent(lp->pdev,
> +		ALLOC_DESC_SIZE, &lp->desc_dma);
> +	if (!lp->desc_pool)
> +		return -ENOMEM;
> +
> +	r6040_up(dev);
> +
> +	napi_enable(&lp->napi);
> +	netif_start_queue(dev);
> +
> +	if (lp->switch_sig != ICPLUS_PHY_ID) {
> +		/* set and active a timer process */
> +		init_timer(&lp->timer);
> +		lp->timer.expires = TIMER_WUT;
> +		lp->timer.data = (unsigned long)dev;
> +		lp->timer.function = &r6040_timer;
> +		add_timer(&lp->timer);
> +	}
> +	return 0;
> +}
> +
> +static int
> +r6040_start_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct r6040_private *lp = netdev_priv(dev);
> +	struct r6040_descriptor *descptr;
> +	void __iomem *ioaddr = lp->base;
> +	unsigned long flags;
> +	int ret;
> +
> +	if (!skb)	/* NULL skb directly return */
> +		return ret;

The start_xmit() should never be called with NULL!

> +	if (skb->len >= MAX_BUF_SIZE) {	/* Packet too long, drop it */
> +		dev_kfree_skb(skb);
> +		return ret;
ret is not initialized!  
		return NETDEV_TX_OK;
> +	}
> +
> +	/* Critical Section */
> +	spin_lock_irqsave(&lp->lock, flags);
> +
> +	/* TX resource check */
> +	if (!lp->tx_free_desc) {
> +		spin_unlock_irqrestore(&lp->lock, flags);
> +		printk(KERN_ERR DRV_NAME ": no tx descriptor\n");
> +		ret = 1;
> +		return ret;
Use instead
		return NETDEV_TX_BUSY;
and don't free skb!

> +	}
> +
> +	/* Statistic Counter */
> +	dev->stats.tx_packets++;
> +	dev->stats.tx_bytes += skb->len;
> +	/* Set TX descriptor & Transmit it */
> +	lp->tx_free_desc--;
> +	descptr = lp->tx_insert_ptr;
> +	if (skb->len < MISR)
> +		descptr->len = MISR;
> +	else
> +		descptr->len = skb->len;
> +
> +	descptr->skb_ptr = skb;
> +	descptr->buf = cpu_to_le32(pci_map_single(lp->pdev,
> +		skb->data, skb->len, PCI_DMA_TODEVICE));
> +	descptr->status = 0x8000;
> +	/* Trigger the MAC to check the TX descriptor */
> +	iowrite16(0x01, ioaddr + MTPR);
> +	lp->tx_insert_ptr = descptr->vndescp;
> +
> +	/* If no tx resource, stop */
> +	if (!lp->tx_free_desc)
> +		netif_stop_queue(dev);
> +
> +	dev->trans_start = jiffies;
> +	spin_unlock_irqrestore(&lp->lock, flags);
> +	return ret;
> +}
> +
> +static void
> +r6040_multicast_list(struct net_device *dev)
> +{
> +	struct r6040_private *lp = netdev_priv(dev);
> +	void __iomem *ioaddr = lp->base;
> +	u16 *adrp;
> +	u16 reg;
> +	unsigned long flags;
> +	struct dev_mc_list *dmi = dev->mc_list;
> +	int i;
> +
> +	/* MAC Address */
> +	adrp = (u16 *)dev->dev_addr;
> +	iowrite16(adrp[0], ioaddr + MID_0L);
> +	iowrite16(adrp[1], ioaddr + MID_0M);
> +	iowrite16(adrp[2], ioaddr + MID_0H);
> +
> +	/* Promiscous Mode */
> +	spin_lock_irqsave(&lp->lock, flags);
> +
> +	/* Clear AMCP & PROM bits */
> +	reg = ioread16(ioaddr) & ~0x0120;
> +	if (dev->flags & IFF_PROMISC) {
> +		reg |= 0x0020;
> +		lp->mcr0 |= 0x0020;
> +	}
> +	/* Too many multicast addresses
> +	 * accept all traffic */
> +	else if ((dev->mc_count > MCAST_MAX)
> +		|| (dev->flags & IFF_ALLMULTI))
> +		reg |= 0x0020;
> +
> +	iowrite16(reg, ioaddr);
> +	spin_unlock_irqrestore(&lp->lock, flags);
> +
> +	/* Build the hash table */
> +	if (dev->mc_count > MCAST_MAX) {
> +		u16 hash_table[4];
> +		u32 crc;
> +
> +		for (i = 0; i < 4; i++)
> +			hash_table[i] = 0;
> +
> +		for (i = 0; i < dev->mc_count; i++) {
> +			char *addrs = dmi->dmi_addr;
> +
> +			dmi = dmi->next;
> +
> +			if (!(*addrs & 1))
> +				continue;
> +
> +			crc = ether_crc_le(6, addrs);
> +			crc >>= 26;
> +			hash_table[crc >> 4] |= 1 << (15 - (crc & 0xf));
> +		}
> +		/* Write the index of the hash table */
> +		for (i = 0; i < 4; i++)
> +			iowrite16(hash_table[i] << 14, ioaddr + MCR1);
> +		/* Fill the MAC hash tables with their values */
> +		iowrite16(hash_table[0], ioaddr + MAR0);
> +		iowrite16(hash_table[1], ioaddr + MAR1);
> +		iowrite16(hash_table[2], ioaddr + MAR2);
> +		iowrite16(hash_table[3], ioaddr + MAR3);
> +	}
> +	/* Multicast Address 1~4 case */
> +	for (i = 0, dmi; (i < dev->mc_count) && (i < MCAST_MAX); i++) {
> +		adrp = (u16 *)dmi->dmi_addr;
> +		iowrite16(adrp[0], ioaddr + MID_1L + 8*i);
> +		iowrite16(adrp[1], ioaddr + MID_1M + 8*i);
> +		iowrite16(adrp[2], ioaddr + MID_1H + 8*i);
> +		dmi = dmi->next;
> +	}
> +	for (i = dev->mc_count; i < MCAST_MAX; i++) {
> +		iowrite16(0xffff, ioaddr + MID_0L + 8*i);
> +		iowrite16(0xffff, ioaddr + MID_0M + 8*i);
> +		iowrite16(0xffff, ioaddr + MID_0H + 8*i);
> +	}
> +}
> +
> +static void netdev_get_drvinfo(struct net_device *dev,
> +			struct ethtool_drvinfo *info)
> +{
> +	struct r6040_private *rp = netdev_priv(dev);
> +
> +	strcpy(info->driver, DRV_NAME);
> +	strcpy(info->version, DRV_VERSION);
> +	strcpy(info->bus_info, pci_name(rp->pdev));
> +}
> +
> +static int netdev_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
> +{
> +	struct r6040_private *rp = netdev_priv(dev);
> +	int rc;
> +
> +	spin_lock_irq(&rp->lock);
> +	rc = mii_ethtool_gset(&rp->mii_if, cmd);
> +	spin_unlock_irq(&rp->mii_if);
	
Shouldn't this be?
	spin_unlock_irq(&rp->lock)


> +static struct pci_device_id r6040_pci_tbl[] = {
> +	{ PCI_DEVICE(PCI_VENDOR_ID_RDC, PCI_DEVICE_ID_RDC_R6040) },
> +	{0 }
Balance space?

	{ 0 }
> +};
> +MODULE_DEVICE_TABLE(pci, r6040_pci_tbl);
> +


More warnings from checkpatch.pl

WARNING: Use of volatile is usually wrong: see Documentation/volatile-considered-harmful.txt
#739: FILE: drivers/net/r6040.c:632:
+       tmp_addr = virt_to_bus((volatile void *)tmp_addr);

WARNING: Use of volatile is usually wrong: see Documentation/volatile-considered-harmful.txt
#743: FILE: drivers/net/r6040.c:636:
+       tmp_addr = virt_to_bus((volatile void *)tmp_addr);

total: 0 errors, 2 warnings, 1135 lines checked

