From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH,RFC] Marvell Orion SoC ethernet driver
Date: Thu, 25 Oct 2007 05:12:04 -0400
Message-ID: <47205DE4.7040001@garzik.org>
References: <20071016192806.GD19618@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tzachi@marvell.com, nico@cam.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38418 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752982AbXJYJMK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2007 05:12:10 -0400
In-Reply-To: <20071016192806.GD19618@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lennert Buytenhek wrote:
> +struct rx_desc {
> +	u32 cmd_sts;
> +	u16 size;
> +	u16 count;
> +	u32 buf;
> +	u32 next;
> +};
> +
> +struct tx_desc {
> +	u32 cmd_sts;
> +	u16 l4i_chk;
> +	u16 count;
> +	u32 buf;
> +	u32 next;
> +};

should use sparse type (__le32, etc.) and make sure this driver passes 
sparse checks

ditto for checkpatch (except for the excessively anal stuff)


> +struct orion_priv {
> +	unsigned long base_addr;
> +
> +	/*
> +	 * RX stuff
> +	 */
> +	u32 rxd_used;
> +	u32 rxd_curr;
> +	u32 rxd_count;
> +	u32 rxd_max_pending;
> +	struct sk_buff *rx_skb[RX_DESC_NR];
> +	struct rx_desc *rxd_base;
> +	dma_addr_t rxd_base_dma;
> +	spinlock_t rx_lock;
> +	struct timer_list rx_fill_timer;
> +
> +	/*
> +	 * TX stuff
> +	 */
> +	u32 txd_used;
> +	u32 txd_curr;
> +	u32 txd_count;
> +	u32 txd_max_pending;
> +	struct sk_buff *tx_skb[TX_DESC_NR];
> +	struct tx_desc *txd_base;
> +	dma_addr_t txd_base_dma;
> +	spinlock_t tx_lock;
> +
> +	/*
> +	 * PHY stuff
> +	 */
> +	struct mii_if_info mii;
> +	spinlock_t mii_lock;
> +
> +	/*
> +	 * Statistics counters
> +	 */
> +	struct net_device_stats stats;
> +};
> +
> +/*****************************************************************************
> + * PHY access
> + ****************************************************************************/
> +static int orion_mii_read(struct net_device *dev, int phy_id, int reg)
> +{
> +	struct orion_priv *op = netdev_priv(dev);
> +	int val, i;
> +
> +	spin_lock(&op->mii_lock);
> +
> +	/*
> +	 * Poll until not busy
> +	 */
> +	for (i = 10000; i && (rdl(op, ETH_SMI) & SMI_BUSY); i--)
> +		rmb();
> +
> +	if (i == 0) {
> +		printk("orion-eth mii read busy timeout\n");
> +		val = -1;
> +		goto out;
> +	}
> +
> +	/*
> +	 * Issue read command
> +	 */
> +	wrl(op, ETH_SMI, (phy_id << SMI_DEV_OFFS) |
> +			 (reg << SMI_REG_OFFS) | SMI_READ);
> +
> +	/*
> +	 * Poll until data is ready
> +	 */
> +	for (i = 10000; i && !(rdl(op, ETH_SMI) & SMI_READ_VALID); i--)
> +		rmb();
> +
> +	if (i == 0) {
> +		printk("orion-eth mii read busy timeout\n");
> +		val = -1;
> +		goto out;
> +	}
> +
> +	/*
> +	 * Read data
> +	 */
> +	val = rdl(op, ETH_SMI) & 0xffff;
> +
> +out:
> +	spin_unlock(&op->mii_lock);
> +	return val;
> +}
> +
> +static void orion_mii_write(struct net_device *dev, int phy_id, int reg, int data)
> +{
> +	struct orion_priv *op = netdev_priv(dev);
> +	int i;
> +
> +	spin_lock(&op->mii_lock);
> +
> +	/*
> +	 * Poll until not busy
> +	 */
> +	for (i = 10000; i && (rdl(op, ETH_SMI) & SMI_BUSY); i--)
> +		rmb();
> +
> +	if (i == 0) {
> +		printk("orion-eth mii write busy timeout\n");
> +		goto out;
> +	}
> +
> +	/*
> +	 * Issue write command
> +	 */
> +	wrl(op, ETH_SMI, (phy_id << 16) | (reg << 21) | data);
> +
> +out:
> +	spin_unlock(&op->mii_lock);
> +}
> +
> +/*
> + * Called from orion_irq in interrupt context.
> + * Not going out to read PHY status, using Orion registers instead.
> + */
> +static inline void orion_phy_link_change(struct net_device *dev)
> +{
> +	struct orion_priv *op = netdev_priv(dev);
> +	u32 stat = rdl(op, PORT_STAT);
> +
> +	if (!(stat & STAT_LINK_UP)) {
> +		netif_carrier_off(dev);
> +		netif_stop_queue(dev);
> +		printk(KERN_NOTICE "%s: link down.\n", dev->name);
> +	} else {
> +		netif_carrier_on(dev);
> +		netif_wake_queue(dev);
> +		netif_poll_enable(dev);
> +		printk(KERN_NOTICE "%s: link up, ", dev->name);
> +		if (stat & STAT_FULL_DUPLEX)
> +			printk("full duplex, ");
> +		else
> +			printk("half duplex, ");
> +		if (stat & STAT_SPEED_1000)
> +			printk("1000Mbps.\n");
> +		else if (stat & STAT_SPEED_100)
> +			printk("100Mbps\n");
> +		else
> +			printk("10Mbps\n");
> +	}
> +}
> +
> +/*****************************************************************************
> + * MAC address filtering
> + ****************************************************************************/
> +static void orion_set_unicast(struct orion_priv *op, u8 *addr)
> +{
> +	int i;
> +
> +	/*
> +	 * Clear unicast table
> +	 */
> +	for (i = 0; i < PORT_UCAST_SIZE; i += 4)
> +		wrl(op, PORT_UCAST_BASE + i, 0);
> +
> +	/*
> +	 * Setup MAC addr registers
> +	 */
> +	wrl(op, PORT_MAC_HI, (addr[0] << 24) | (addr[1] << 16) |
> +			     (addr[2] << 8) | addr[3]);
> +	wrl(op, PORT_MAC_LO, (addr[4] << 8) | addr[5]);
> +
> +	/*
> +	 * Enable our entry in unicat table
> +	 */
> +	wrb(op, PORT_UCAST_BASE + (addr[5] & 0xf), 1);
> +}
> +
> +static void orion_set_promisc(struct orion_priv *op)
> +{
> +	int i;
> +
> +	/*
> +	 * Turn on promiscuous mode
> +	 */
> +	wrl(op, PORT_CONF, rdl(op, PORT_CONF) | 1);
> +
> +	/*
> +	 * Remove our addr from MAC addr registers
> +	 */
> +	wrl(op, PORT_MAC_LO, 0xffff);
> +	wrl(op, PORT_MAC_HI, 0xffffffff);
> +
> +	/*
> +	 * Enable all entries in address filter tables
> +	 */
> +	for (i = 0; i < PORT_SPEC_MCAST_SIZE; i += 4)
> +		wrl(op, PORT_SPEC_MCAST_BASE + i, 0x01010101);
> +	for (i = 0; i < PORT_OTHER_MCAST_SIZE; i += 4)
> +		wrl(op, PORT_OTHER_MCAST_BASE + i, 0x01010101);
> +	for (i = 0; i < PORT_UCAST_SIZE; i += 4)
> +		wrl(op, PORT_UCAST_BASE + i, 0x01010101);
> +}
> +
> +static void orion_set_allmulti(struct orion_priv *op)
> +{
> +	int i;
> +
> +	/*
> +	 * Enable all entries in multicast address tables
> +	 */
> +	for (i = 0; i < PORT_SPEC_MCAST_SIZE; i += 4)
> +		wrl(op, PORT_SPEC_MCAST_BASE + i, 0x01010101);
> +	for (i = 0; i < PORT_OTHER_MCAST_SIZE; i += 4)
> +		wrl(op, PORT_OTHER_MCAST_BASE + i, 0x01010101);
> +}
> +
> +static u8 orion_mcast_hash(u8 *addr)
> +{
> +	/*
> +	 * CRC-8 x^8+x^2+x^1+1
> +	 */
> +#define b(bit)	(((addr[(bit)/8]) >> (7 - ((bit) % 8))) & 1)
> +
> +	return(((b(2)^b(4)^b(7)^b(8)^b(12)^b(13)^b(16)^b(17)^b(19)^
> +		b(24)^b(26)^b(28)^b(29)^b(31)^b(33)^b(35)^b(39)^b(40)^
> +		b(41)^b(47) ) << 0)
> +		|
> +		((b(1)^b(2)^b(3)^b(4)^b(6)^b(8)^b(11)^b(13)^b(15)^
> +		b(17)^b(18)^b(19)^b(23)^b(24)^b(25)^b(26)^b(27)^b(29)^
> +		b(30)^b(31)^b(32)^b(33)^b(34)^b(35)^b(38)^b(41)^b(46)^
> +		b(47)) << 1)
> +		|
> +		((b(0)^b(1)^b(3)^b(4)^b(5)^b(8)^b(10)^b(13)^b(14)^
> +		b(18)^b(19)^b(22)^b(23)^b(25)^b(30)^b(32)^b(34)^b(35)^
> +		b(37)^b(39)^b(41)^b(45)^b(46)^b(47)) << 2)
> +		|
> +		((b(0)^b(2)^b(3)^b(4)^b(7)^b(9)^b(12)^b(13)^b(17)^
> +		b(18)^b(21)^b(22)^b(24)^b(29)^b(31)^b(33)^b(34)^b(36)^
> +		b(38)^b(40)^b(44)^b(45)^b(46)) << 3)
> +		|
> +		((b(1)^b(2)^b(3)^b(6)^b(8)^b(11)^b(12)^b(16)^b(17)^
> +		b(20)^b(21)^b(23)^b(28)^b(30)^b(32)^b(33)^b(35)^b(37)^
> +		b(39)^b(43)^b(44)^b(45)) << 4)
> +		|
> +		((b(0)^b(1)^b(2)^b(5)^b(7)^b(10)^b(11)^b(15)^b(16)^
> +		b(19)^b(20)^b(22)^b(27)^b(29)^b(31)^b(32)^b(34)^b(36)^
> +		b(38)^b(42)^b(43)^b(44)) << 5)
> +		|
> +		((b(0)^b(1)^b(4)^b(6)^b(9)^b(10)^b(14)^b(15)^b(18)^
> +		b(19)^b(21)^b(26)^b(28)^b(30)^b(31)^b(33)^b(35)^b(37)^
> +		b(41)^b(42)^b(43)) << 6)
> +		|
> +		((b(0)^b(3)^b(5)^b(8)^b(9)^b(13)^b(14)^b(17)^b(18)^
> +		b(20)^b(25)^b(27)^b(29)^b(30)^b(32)^b(34)^b(36)^b(40)^
> +		b(41)^b(42)) << 7));
> +}

maybe a lib/ function?


> +static void orion_set_multi_list(struct net_device *dev)
> +{
> +	struct dev_mc_list *addr = dev->mc_list;
> +	struct orion_priv *op = netdev_priv(dev);
> +	int i;
> +	u8 *p;
> +
> +	/*
> +	 * Enable specific entries in multicast filter table
> +	 */
> +	for (i = 0; i < dev->mc_count; i++, addr = addr->next) {
> +		if (!addr)
> +			break;
> + 		p = addr->dmi_addr;
> +		if ((p[0] == 0x01) && (p[1] == 0x00) && (p[2] == 0x5E) &&
> +		    (p[3] == 0x00) && (p[4] == 0x00)) {
> +			wrb(op, PORT_SPEC_MCAST_BASE + p[5], 1);
> +		} else {
> +			u8 entry = orion_mcast_hash(p);
> +			wrb(op, PORT_OTHER_MCAST_BASE + entry, 1);
> +		}
> +	}

what happens if dev->mc_count is a big number?  (answer for most: fall 
back to ALLMULTI behavior)


> +static void orion_clr_allmulti(struct orion_priv *op)
> +{
> +	int i;
> +
> +	/*
> +	 * Clear multicast tables
> +	 */
> +	for (i = 0; i < PORT_SPEC_MCAST_SIZE; i += 4)
> +		wrl(op, PORT_SPEC_MCAST_BASE + i, 0);
> +	for (i = 0; i < PORT_OTHER_MCAST_SIZE; i += 4)
> +		wrl(op, PORT_OTHER_MCAST_BASE + i, 0);
> +}
> +
> +static void orion_multicast(struct net_device *dev)
> +{
> +	struct orion_priv *op = netdev_priv(dev);
> +
> +	if (dev->flags & IFF_PROMISC) {
> +		orion_set_promisc(op);
> +	} else {
> +		/*
> +		 * If we were in promisc mode, we now must turn it off and
> +		 * setup our MAC addr again in HW registers and unicast table
> +		 */
> +		wrl(op, PORT_CONF, rdl(op, PORT_CONF) & (~1));
> +		orion_set_unicast(op, dev->dev_addr);
> +
> +		if (dev->flags & IFF_ALLMULTI) {
> +			orion_set_allmulti(op);
> +		} else {
> +			/*
> +			 * If we were in promiscuous/allmulti mode, we now
> +			 * must clear the multicast tables first
> +			 */
> +			orion_clr_allmulti(op);
> +
> +			if (dev->mc_count) {
> +				orion_set_multi_list(dev);
> +			}
> +		}
> +	}
> +}
> +
> +static int orion_set_mac_addr(struct net_device *dev, void *p)
> +{
> +	struct orion_priv *op = netdev_priv(dev);
> +	struct sockaddr *addr = p;
> +
> +	if (!is_valid_ether_addr(addr->sa_data))
> +		return -EADDRNOTAVAIL;
> +
> +	/*
> +	 * Setup addr to HW registers and unicast table
> +	 */
> +	orion_set_unicast(op, addr->sa_data);
> +
> +	/*
> +	 * Store new addr in net_dev
> +	 */
> +	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
> +
> +	return 0;
> +}
> +
> +/*****************************************************************************
> + * Data flow RX/TX
> + ****************************************************************************/
> +static u32 orion_tx_done(struct net_device *dev)
> +{
> +	struct orion_priv *op = netdev_priv(dev);
> +	struct tx_desc *txd;
> +	u32 count = 0, cmd_sts;
> +
> +#ifndef ORION_TX_DONE_IN_TX
> +	spin_lock_bh(&op->tx_lock);
> +#endif

ifdef'd spinlocking is a maintenance problem


> +	while ((op->txd_count > 0)) {

why this condition?  its highly unusual, most net drivers use another 
loop ending condition


> +		txd = &op->txd_base[op->txd_used];
> +		cmd_sts = txd->cmd_sts;
> +
> +		if (cmd_sts & TXD_DMA)
> +			break;
> +
> +		dma_unmap_single(NULL, txd->buf, txd->count, DMA_TO_DEVICE);
> +
> +		if (cmd_sts & TXD_LAST) {
> +			/*
> +			 * The skb was stored at the packet's last frag index
> +			 */
> +			dev_kfree_skb_any(op->tx_skb[op->txd_used]);
> +
> +			if (cmd_sts & TXD_ERR)
> +				op->stats.tx_errors++;
> +		}
> +
> +		count++;
> +		op->txd_count--;
> +		op->txd_used = (op->txd_used + 1) % TX_DESC_NR;
> +	}
> +
> +	/*
> +	 * If transmission was previously stopped, now it can be restarted
> +	 */
> +	if (count && netif_queue_stopped(dev) && (dev->flags & IFF_UP))
> +		netif_wake_queue(dev);
> +
> +#ifndef ORION_TX_DONE_IN_TX
> +	spin_unlock_bh(&op->tx_lock);
> +#endif
> +	return count;
> +}
> +
> +static int orion_tx(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct orion_priv *op = netdev_priv(dev);
> +	struct tx_desc *txd, *txd_first;
> +	u32 count = 0, txd_flags = 0;
> +	int ret = NETDEV_TX_OK;
> +
> +	spin_lock_bh(&op->tx_lock);
> +
> +	if (unlikely(skb->len > MAX_PKT_SIZE)) {
> +		op->stats.tx_dropped++;
> +		dev_kfree_skb(skb);
> +		goto out;
> +	}
> +
> +	/*
> +	 * Stop TX if there are not enough descriptors available. The next
> +	 * TX-Done will enable TX back after making available descriptors.
> +	 */
> +	if (TX_DESC_NR - op->txd_count < skb_shinfo(skb)->nr_frags + 1) {
> +		netif_stop_queue(dev);
> +		ret = NETDEV_TX_BUSY;
> +		goto out;
> +	}
> +
> +	/*
> +	 * Buffers with a payload <= 8 bytes must be aligned on 8 bytes boundary.
> +	 * If there is such a small unaligned fragment we linearize the skb.
> +	 */
> +	if (skb_is_nonlinear(skb)) {
> +		int i;
> +		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
> +			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
> +			if (unlikely(frag->size <= 8 && frag->page_offset & 0x7)) {
> +				if (__skb_linearize(skb)) {
> +					op->stats.tx_dropped++;
> +					goto out;
> +				}
> +				break;
> +			}
> +		}
> +	}
> +
> +	/*
> +	 * Need to remember the first desc to handle multiple frags
> +	 */
> +	txd_first = &op->txd_base[op->txd_curr];
> +
> +	do {
> +		u8* buf;
> +		u32 size;
> +
> +		txd = &op->txd_base[op->txd_curr];
> +
> +		if (skb_shinfo(skb)->nr_frags == 0) {
> +			buf = skb->data;
> +			size = skb->len;
> +		} else {
> +			if (count == 0) {
> +				buf = skb->data;
> +				size = skb_headlen(skb);
> +			} else {
> +				skb_frag_t *frag = &skb_shinfo(skb)->frags[count - 1];
> +				buf = page_address(frag->page) + frag->page_offset;
> +				size = frag->size;
> +			}
> +		}
> +
> +		/*
> +		 * Setup the descriptor and only pass ownership to HW for the non-first
> +		 * descriptors. Some cmd_sts flags for the first and last descriptos are
> +		 * being set outside the loop.
> +		 */
> +		txd->buf = dma_map_single(NULL, buf, size, DMA_TO_DEVICE);
> +		txd->count = size;
> +		if (count > 0)
> +			txd->cmd_sts = TXD_DMA;
> +
> +		op->tx_skb[op->txd_curr] = (void *)0xffffffff;
> +
> +		count++;
> +		op->txd_curr = (op->txd_curr + 1) % TX_DESC_NR;
> +
> +	} while (count < skb_shinfo(skb)->nr_frags + 1);
> +
> +#ifdef ORION_TX_CSUM_OFFLOAD
> +	/*
> +	 * Setup checksum offloading flags for the 'first' txd
> +	 */
> +	if (skb->ip_summed == CHECKSUM_COMPLETE ||
> +		skb->ip_summed == CHECKSUM_PARTIAL) {
> +		txd_flags = TXD_IP_CSUM | TXD_IP_NO_FRAG | TXD_L4_CSUM |
> +				(ip_hdr(skb)->ihl << TXD_IP_HDRLEN_OFFS);
> +		if (ip_hdr(skb)->protocol == IPPROTO_UDP)
> +			txd_flags |= TXD_L4_UDP;
> +	} else {
> +		/*
> +		 * Workaround (Errata). Leaving IP hdr len '0' might cause
> +		 * a wrong checksum calc of the next packet.
> +		 */
> +		txd_flags = 5 << TXD_IP_HDRLEN_OFFS;
> +	}
> +#endif

don't ifdef this, control it via ethtool (default:off if necessary)


> +	wmb();
> +
> +	if (count == 1) {
> +		/*
> +		 * Single buffer case - set 'first' & 'last' flags
> +		 */
> +		txd->cmd_sts = txd_flags | TXD_DMA | TXD_CRC | TXD_INT |
> +				TXD_PAD | TXD_FRST | TXD_LAST;
> +	} else {
> +		/*
> +		 * Multiple buffers case - set 'last' flags first,
> +		 * and 'first' flags last.
> +		 */
> +		txd->cmd_sts = TXD_DMA | TXD_INT | TXD_PAD | TXD_LAST;
> +		wmb();
> +		txd_first->cmd_sts = txd_flags | TXD_DMA | TXD_CRC | TXD_FRST;
> +	}
> +
> +	/*
> +	 * Store skb for tx_done in the last frag index
> +	 */
> +	if(op->txd_curr != 0)
> +		op->tx_skb[op->txd_curr - 1] = skb;
> +	else
> +		op->tx_skb[TX_DESC_NR - 1] = skb;
> +
> +	/*
> +	 * Apply send command
> +	 */
> +	wmb();
> +	wrl(op, PORT_TXQ_CMD, PORT_EN_TXQ0);
> +
> +	op->txd_count += count;
> +	if (op->txd_count > op->txd_max_pending)
> +		op->txd_max_pending = op->txd_count;
> +
> +	op->stats.tx_bytes += skb->len;
> +	op->stats.tx_packets++;
> +	dev->trans_start = jiffies;
> +
> +#ifdef ORION_TX_DONE_IN_TX
> +	if(op->txd_count > TX_DONE_THRESH)
> +		orion_tx_done(dev);
> +#endif
> +
> +out:
> +	spin_unlock_bh(&op->tx_lock);
> +	return ret;
> +}
> +
> +static void orion_rx_fill(struct orion_priv *op)
> +{
> +	struct sk_buff *skb;
> +	struct rx_desc *rxd;
> +	int alloc_skb_failed = 0;
> +	u32 unaligned;
> +
> +	spin_lock_bh(&op->rx_lock);
> +
> +	while (op->rxd_count < RX_DESC_NR) {
> +
> +		rxd = &op->rxd_base[op->rxd_used];
> +
> +		if (rxd->cmd_sts & RXD_DMA) {
> +			printk(KERN_ERR "orion_rx_fill error, desc owned by DMA\n");
> +			break;
> +		}
> +
> +		skb = dev_alloc_skb(MAX_PKT_SIZE + dma_get_cache_alignment());
> +		if (!skb) {
> +			alloc_skb_failed = 1;
> +			break;
> +		}
> +
> +		unaligned = (u32)skb->data & (dma_get_cache_alignment() - 1);
> +		if (unaligned)
> +			skb_reserve(skb, dma_get_cache_alignment() - unaligned);
> +
> +		/*
> +		 * HW skips on first 2B to align the IP header
> +		 */
> +		skb_reserve(skb, 2);
> +
> +		op->rx_skb[op->rxd_used] = skb;
> +
> +		rxd->buf = dma_map_single(NULL, skb->data, MAX_PKT_SIZE - 2,
> +						DMA_FROM_DEVICE);
> +		rxd->size = MAX_PKT_SIZE & RXD_SIZE_MASK;
> +		rxd->count = 0;
> +		wmb();
> +		rxd->cmd_sts = RXD_DMA | RXD_INT;
> +
> +		op->rxd_count++;
> +		op->rxd_used = (op->rxd_used + 1) % RX_DESC_NR;
> +	}
> +
> +	/*
> +	 * If skb_alloc failed and the number of rx buffers in the ring is
> +	 * less than half of the ring size, then set a timer to try again
> +	 * later (100ms).
> +	 */
> +	if (alloc_skb_failed && op->rxd_count < RX_DESC_NR / 2) {
> +		printk(KERN_INFO "orion_rx_fill set timer to alloc bufs\n");
> +		if (!timer_pending(&op->rx_fill_timer))
> +			mod_timer(&op->rx_fill_timer, jiffies + (HZ / 10));
> +	}
> +
> +	spin_unlock_bh(&op->rx_lock);
> +}

why spin_lock_bh(rx_lock) ?  RX is traditionally pretty lightweight, 
lock-wise, because it is an independent process.

also, you could just use napi_enable/disable and completely remove the 
lock, controlling the RX process that way


> +static void orion_rx_fill_on_timeout(unsigned long data)
> +{
> +	orion_rx_fill(((struct net_device *)data)->priv);
> +}
> +
> +#ifdef ORION_RX_CSUM_OFFLOAD
> +static inline int orion_rx_is_good_csum(struct rx_desc *rxd)
> +{
> +	if ((rxd->count > 72) &&
> +	    (rxd->cmd_sts & RXD_IP_TYPE) &&
> +	    (rxd->cmd_sts & RXD_IP_HDR_OK) &&
> +	    (!(rxd->size & RXD_IP_FRAG)) &&
> +	    (!(rxd->cmd_sts & RXD_L4_NO_TYPE)) &&
> +	    (rxd->cmd_sts & RXD_L4_CSUM_OK))
> +		return 1;
> +
> +	return 0;
> +}
> +#endif
> +
> +static inline int get_rx_pending(struct orion_priv *op)
> +{
> +	u32 hw_rxd = (rdl(op, PORT_CURR_RXD) - op->rxd_base_dma) / sizeof(struct rx_desc);
> +	u32 sw_rxd = (&op->rxd_base[op->rxd_curr] - op->rxd_base) / sizeof(struct rx_desc);
> +
> +	if (hw_rxd > sw_rxd)
> +		return(hw_rxd - sw_rxd);
> +	else
> +		return(RX_DESC_NR - (sw_rxd - hw_rxd));
> +}
> +
> +static int orion_rx(struct net_device *dev, u32 work_to_do)
> +{
> +	struct orion_priv *op = netdev_priv(dev);
> +	struct rx_desc *rxd;
> +	u32 work_done = 0, cmd_sts;
> +	struct sk_buff *skb;
> +	u32 pending;
> +
> +	spin_lock_bh(&op->rx_lock);
> +
> +	pending = get_rx_pending(op);
> +	if (pending > op->rxd_max_pending)
> +		op->rxd_max_pending = pending;
> +
> +	while (op->rxd_count > 0 && work_done < work_to_do) {
> +
> +		rxd = &op->rxd_base[op->rxd_curr];
> +		cmd_sts = rxd->cmd_sts;
> +
> +		if (cmd_sts & RXD_DMA)
> +			break;
> +
> +		skb = op->rx_skb[op->rxd_curr];
> +		dma_unmap_single(NULL, rxd->buf, rxd->size & RXD_SIZE_MASK, DMA_FROM_DEVICE);
> +
> +		if ((cmd_sts & RXD_FRST) && (cmd_sts & RXD_LAST) &&
> +						!(cmd_sts & RXD_ERR)) {
> +
> +			/*
> +			 * Good RX
> +			 */
> +			op->stats.rx_packets++;
> +			op->stats.rx_bytes += rxd->count;
> +
> +			/*
> +			 * Reduce 4B crc + 2B offset
> +			 */
> +			skb_put(skb, (rxd->count - 4 - 2));
> +
> +#ifdef ORION_RX_CSUM_OFFLOAD
> +			if (orion_rx_is_good_csum(rxd)) {
> +				skb->csum =  htons((rxd->cmd_sts & RXD_L4_CSUM_MASK)
> +							>> RXD_L4_CSUM_OFFS);
> +				skb->ip_summed = CHECKSUM_UNNECESSARY;
> +			} else {
> +				skb->ip_summed = CHECKSUM_NONE;
> +			}
> +#else
> +			skb->ip_summed = CHECKSUM_NONE;
> +#endif
> +
> +			skb->protocol = eth_type_trans(skb, dev);
> +			skb->dev = dev;
> +
> +			netif_receive_skb(skb);
> +			work_done++;
> +
> +		} else {
> +			dev_kfree_skb(skb);
> +			op->stats.rx_errors++;
> +			op->stats.rx_dropped++;
> +		}
> +
> +		dev->last_rx = jiffies;
> +
> +		op->rxd_count--;
> +		op->rxd_curr = (op->rxd_curr + 1) % RX_DESC_NR;
> +	}
> +
> +	spin_unlock_bh(&op->rx_lock);
> +
> +	/*
> +	 * Refill RX buffers when only half of the decriptors left available
> +	 */
> +	if (work_done && (op->rxd_count < RX_DESC_NR / 2))
> +		orion_rx_fill(op);
> +
> +	return work_done;
> +}
> +
> +static int orion_poll(struct net_device *dev, int *budget)
> +{
> +	struct orion_priv *op = netdev_priv(dev);
> +	int rx_work_done = 0, tx_work_done = 0;
> +
> +#ifndef ORION_TX_DONE_IN_TX
> +	/*
> +	 * Release transmitted buffers
> +	 */
> +	tx_work_done = orion_tx_done(dev);
> +#endif
> +
> +	/*
> +	 * Push up receive buffers
> +	 */
> +	rx_work_done = orion_rx(dev, min(*budget, dev->quota));
> +	*budget -= rx_work_done;
> +	dev->quota -= rx_work_done;
> +
> +	/*
> +	 * If no work was done, go down from NAPI list and enable interrupts
> +	 */
> +	if (((tx_work_done == 0) && (rx_work_done == 0)) ||
> +		(!netif_running(dev)) ) {
> +		netif_rx_complete(dev);
> +		wrl(op, PORT_MASK, PIC_MASK);
> +		wrl(op, PORT_MASK_EXT, PICE_MASK);
> +		return 0;
> +	}
> +
> +	return 1;
> +}
> +
> +static irqreturn_t orion_irq(int irq , void *dev_id)
> +{
> +	struct net_device *dev = (struct net_device *)dev_id;

remove pointless cast


> +	struct orion_priv *op = netdev_priv(dev);
> +	u32 pic, pice = 0;
> +
> +	pic = rdl(op, PORT_CAUSE) & rdl(op, PORT_MASK);
> +	if (pic == 0)

generally wise to check for 0xffffffff (hardware fault / unplugged / 
scrogged)


> +		return IRQ_NONE;
> +	wrl(op, PORT_CAUSE, ~pic);
> +
> +	if (pic & PIC_EXT) {
> +		pice = rdl(op, PORT_CAUSE_EXT) & rdl(op, PORT_MASK_EXT);
> +		wrl(op, PORT_CAUSE_EXT, ~pice);
> +
> +		/*
> +		 * Link status change event
> +		 */
> +		if (pice & (PICE_PHY | PICE_LINK)) {
> +			orion_phy_link_change(dev);
> +			pice &= ~(PICE_PHY | PICE_LINK);
> +		}
> +		pic &= ~(PIC_EXT);
> +	}
> +
> +	/*
> +	 * RX/TX events handled outside IRQ context (NAPI) while interrups
> +	 * disabled (PHY Link interrupts left unmask)
> +	 */
> +	if (pic || pice) {
> +		if (netif_rx_schedule_prep(dev)) {
> +			wrl(op, PORT_MASK, PIC_EXT);
> +			wrl(op, PORT_MASK_EXT, PICE_PHY | PICE_LINK);
> +			wrl(op, PORT_CAUSE, 0);
> +			wrl(op, PORT_CAUSE_EXT, 0);
> +
> +			__netif_rx_schedule(dev);
> +		}
> +	}
> +
> +	return IRQ_HANDLED;
> +}
> +
> +/*****************************************************************************
> + * Tools and statistics
> + ****************************************************************************/
> +static struct net_device_stats *orion_get_stats(struct net_device *dev)
> +{
> +	struct orion_priv *op = netdev_priv(dev);
> +	return &(op->stats);

use struct net_device::stats rather than local copy


> +static void orion_get_drvinfo(struct net_device *dev,
> +				struct ethtool_drvinfo *info)
> +{
> +	strcpy(info->driver, DRV_NAME);
> +	strcpy(info->version, DRV_VERSION);
> +	strcpy(info->fw_version, "N/A");
> +}
> +
> +static int orion_get_settings(struct net_device *dev,
> +				struct ethtool_cmd *cmd)
> +{
> +	struct orion_priv *op = netdev_priv(dev);
> +	return mii_ethtool_gset(&op->mii, cmd);
> +}
> +
> +static int orion_set_settings(struct net_device *dev,
> +				struct ethtool_cmd *cmd)
> +{
> +	struct orion_priv *op = netdev_priv(dev);
> +	return mii_ethtool_sset(&op->mii, cmd);
> +}
> +
> +static int orion_nway_reset(struct net_device *dev)
> +{
> +	struct orion_priv *op = netdev_priv(dev);
> +	return mii_nway_restart(&op->mii);
> +}
> +
> +static u32 orion_get_link(struct net_device *dev)
> +{
> +	struct orion_priv *op = netdev_priv(dev);
> +	return mii_link_ok(&op->mii);
> +}
> +
> +static void orion_get_ringparam(struct net_device *dev,
> +				struct ethtool_ringparam *ring)
> +{
> +	struct orion_priv *op = netdev_priv(dev);
> +
> +	ring->rx_max_pending = op->rxd_max_pending;
> +	ring->tx_max_pending = op->txd_max_pending;
> +	ring->rx_pending = get_rx_pending(op);
> +	ring->tx_pending = op->txd_count;
> +	ring->rx_mini_max_pending = -1;
> +	ring->rx_jumbo_max_pending = -1;
> +	ring->rx_mini_pending = -1;
> +	ring->rx_jumbo_pending = -1;
> +}
> +
> +static u32 orion_get_rx_csum(struct net_device *netdev)
> +{
> +#ifdef ORION_RX_CSUM_OFFLOAD
> +	return 1;
> +#else
> +	return 0;
> +#endif
> +}
> +
> +static u32 orion_get_tx_csum(struct net_device *netdev)
> +{
> +#ifdef ORION_TX_CSUM_OFFLOAD
> +	return 1;
> +#else
> +	return 0;
> +#endif
> +}
> +
> +static struct ethtool_ops orion_ethtool_ops = {
> +	.get_drvinfo		= orion_get_drvinfo,
> +	.get_settings		= orion_get_settings,
> +	.set_settings		= orion_set_settings,
> +	.nway_reset		= orion_nway_reset,
> +	.get_link		= orion_get_link,
> +	.get_ringparam		= orion_get_ringparam,
> +	.get_rx_csum		= orion_get_rx_csum,
> +	.get_tx_csum		= orion_get_tx_csum,
> +};
> +
> +static int orion_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
> +{
> +	struct orion_priv *op = netdev_priv(dev);
> +	struct mii_ioctl_data *data = if_mii(ifr);
> +
> +	return generic_mii_ioctl(&op->mii, data, cmd, NULL);
> +}
> +
> +void orion_clr_mib(struct orion_priv *op)
> +{
> +	/*
> +	 * Dummy reads do the work
> +	 */
> +	int i, dummy;
> +	for (i = 0; i < PORT_MIB_SIZE; i += 4)
> +		dummy = rdl(op, (PORT_MIB_BASE + i));
> +}
> +
> +/*****************************************************************************
> + * Start/Stop
> + ****************************************************************************/
> +static void orion_init_hw(struct orion_priv *op)
> +{
> +	int i;
> +
> +	/*
> +	 * Mask and clear Ethernet unit interrupts
> +	 */
> +	wrl(op, ETH_MASK, 0);
> +	wrl(op, ETH_CAUSE, 0);
> +
> +	/*
> +	 * Clear address filter tables
> +	 */
> +	for (i = 0; i < PORT_UCAST_SIZE; i += 4)
> +		wrl(op, PORT_UCAST_BASE + i, 0);
> +	for (i = 0; i < PORT_SPEC_MCAST_SIZE; i += 4)
> +		wrl(op, PORT_SPEC_MCAST_BASE + i, 0);
> +	for (i = 0; i < PORT_OTHER_MCAST_SIZE; i += 4)
> +		wrl(op, PORT_OTHER_MCAST_BASE + i, 0);
> +}
> +
> +static void orion_start_hw(struct orion_priv *op)
> +{
> +	/*
> +	 * Clear and mask interrupts
> +	 */
> +	wrl(op, PORT_CAUSE, 0);
> +	wrl(op, PORT_CAUSE_EXT, 0);
> +	wrl(op, PORT_MASK, 0);
> +	wrl(op, PORT_MASK_EXT, 0);
> +
> +	/*
> +	 * Clear MIB counters
> +	 */
> +	orion_clr_mib(op);
> +
> +	/*
> +	 * Setup HW with TXD/RXD base
> +	 */
> +	wrl(op, PORT_CURR_TXD, op->txd_base_dma);
> +	wrl(op, PORT_CURR_RXD, op->rxd_base_dma);
> +
> +	/*
> +	 * Basic default port config
> +	 */
> +	wrl(op, PORT_CONF, (1 << 25));
> +	wrl(op, PORT_CONF_EXT, 0);
> +	wrl(op, PORT_SERIAL, 0x0240609);
> +	wrl(op, PORT_SDMA, 0x01021038);
> +	wrl(op, PORT_MTU, 0x0);
> +	wrl(op, PORT_TX_THRESH, 0x2100);
> +
> +	/*
> +	 * Enable RX & TX queues (using only queue '0')
> +	 */
> +	wrl(op, PORT_RXQ_CMD, PORT_EN_RXQ0);
> +	wrl(op, PORT_TXQ_CMD, PORT_EN_TXQ0);
> +
> +	/*
> +	 * Unmask interrupts
> +	 */
> +	wrl(op, PORT_MASK, PIC_MASK);
> +	wrl(op, PORT_MASK_EXT, PICE_MASK);
> +}
> +
> +static int orion_open(struct net_device *dev)
> +{
> +	struct orion_priv *op = netdev_priv(dev);
> +	int err;
> +
> +	setup_timer(&op->rx_fill_timer, orion_rx_fill_on_timeout,
> +					(unsigned long)dev);
> +
> +	err = request_irq(dev->irq, orion_irq, IRQF_SAMPLE_RANDOM, dev->name, dev);
> +	if (err) {
> +		del_timer(&op->rx_fill_timer);
> +		printk(KERN_ERR "Failed to request IRQ %d\n", dev->irq);
> +		return err;
> +	}
> +
> +	/*
> +	 * Fill RX buffers and start the HW
> +	 */
> +	orion_rx_fill(op);
> +	orion_start_hw(op);
> +	orion_phy_link_change(dev);
> +
> +	return 0;
> +}
> +
> +static int orion_close(struct net_device *dev)
> +{
> +	struct orion_priv *op = netdev_priv(dev);
> +
> +	/*
> +	 * Clear and mask interrupts
> +	 */
> +	wrl(op, PORT_MASK, 0);
> +	wrl(op, PORT_MASK_EXT, 0);
> +	wrl(op, PORT_CAUSE, 0);
> +	wrl(op, PORT_CAUSE_EXT, 0);
> +
> +	/*
> +	 * Stop RX, reset descriptors, free buffers and RX timer
> +	 */
> +	spin_lock_bh(&op->rx_lock);
> +
> +	wrl(op, PORT_RXQ_CMD, PORT_DIS_RXQ0);
> +	mdelay(1);

this is a poor and unfriendly synchronization method


> +	while (op->rxd_count > 0) {
> +		struct rx_desc *rxd = &op->rxd_base[op->rxd_curr];
> +		dma_unmap_single(NULL, rxd->buf, rxd->size & RXD_SIZE_MASK, DMA_FROM_DEVICE);
> +		rxd->cmd_sts = rxd->size = rxd->count = rxd->buf = 0;
> +		dev_kfree_skb_any(op->rx_skb[op->rxd_curr]);
> +		op->rxd_count--;
> +		op->rxd_curr = (op->rxd_curr + 1) % RX_DESC_NR;
> +	}
> +	op->rxd_curr = op->rxd_used = op->rxd_max_pending = 0;
> +	wrl(op, PORT_CURR_RXD, op->rxd_base_dma);
> +
> +
> +	spin_unlock_bh(&op->rx_lock);
> +
> +	/*
> +	 * Stop TX, reset descriptors, free buffers
> +	 */
> +	spin_lock_bh(&op->tx_lock);
> +
> +	netif_stop_queue(dev);
> +
> +	wrl(op, PORT_TXQ_CMD, PORT_DIS_TXQ0);
> +	mdelay(1);

ditto


> +	while (op->txd_count > 0) {
> +		struct tx_desc *txd = &op->txd_base[op->txd_curr];
> +		dma_unmap_single(NULL, txd->buf, txd->count, DMA_TO_DEVICE);
> +		if ((txd->cmd_sts & TXD_LAST))
> +			dev_kfree_skb_any(op->tx_skb[op->txd_used]);
> +		txd->cmd_sts = txd->l4i_chk = txd->count = txd->buf = 0;
> +		op->txd_count--;
> +		op->txd_used = (op->txd_used + 1) % TX_DESC_NR;
> +	}
> +	op->txd_curr = op->txd_used = op->txd_max_pending = 0;
> +	wrl(op, PORT_CURR_TXD, op->txd_base_dma);
> +
> +	spin_unlock_bh(&op->tx_lock);
> +
> +	/*
> +	 * Diable serial interface
> +	 */
> +	wrl(op, PORT_SERIAL, rdl(op, PORT_SERIAL) & (~1));
> +	mdelay(1);
> +
> +	free_irq(dev->irq, dev);
> +
> +	/*
> +	 * Stop poll and set Link down state
> +	 */
> +	netif_poll_disable(dev);
> +	netif_carrier_off(dev);
> +
> +	return 0;
> +}
> +
> +/*****************************************************************************
> + * Probe/Remove
> + ****************************************************************************/
> +static int orion_remove(struct platform_device *pdev)
> +{
> +	struct net_device *dev;
> +	struct orion_priv *op;
> +
> +	/*
> +	 * Remove net_device link
> +	 */
> +	dev = platform_get_drvdata(pdev);
> +	if (dev == NULL)
> +		return 0;

test for impossible condition


> +	platform_set_drvdata(pdev, NULL);
> +
> +	/*
> +	 * Close and remove interface
> +	 */
> +	unregister_netdev(dev);
> +
> +	/*
> +	 * Free our private data and net_device
> +	 */
> +	op = netdev_priv(dev);
> +	if (op == NULL)
> +		return 0;

ditto

> +	iounmap((void *)op->base_addr);

pointless void* cast


> +	del_timer(&op->rx_fill_timer);

del_timer_sync()


> +	if (op->rxd_base)
> +		dma_free_coherent(NULL, sizeof(struct rx_desc) * RX_DESC_NR,
> +			op->rxd_base, op->rxd_base_dma);
> +
> +	if (op->txd_base)
> +		dma_free_coherent(NULL, sizeof(struct tx_desc) * TX_DESC_NR,
> +			op->txd_base, op->txd_base_dma);
> +
> +	free_netdev(dev);
> +
> +	return 0;
> +}
> +
> +static int orion_probe(struct platform_device *pdev)
> +{
> +	struct orion_eth_data *data;
> +	struct net_device *dev;
> +	struct orion_priv *op;
> +	struct rx_desc *rxd;
> +	struct tx_desc *txd;
> +	int i, err, irq;
> +	struct resource *res;
> +	u32 base_addr;
> +
> +	if (pdev == NULL)
> +		return -ENODEV;

pointless test


> +	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	if (res == NULL)
> +		return -ENODEV;
> +	base_addr = res->start;
> +
> +	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
> +	if (res == NULL)
> +		return -ENODEV;
> +	irq = res->start;
> +
> +	data = pdev->dev.platform_data;
> +
> +	dev = alloc_etherdev(sizeof(struct orion_priv));
> +	if (dev == NULL)
> +		return -ENOMEM;
> +
> +	platform_set_drvdata(pdev, dev);
> +
> +	op = netdev_priv(dev);
> +	op->base_addr = (u32)ioremap(base_addr, 64 * 1024);
> +	if (!op->base_addr) {
> +		err = -EIO;
> +		goto err_out;
> +	}
> +
> +	/*
> + 	 * Put HW in quite mode
> +	 */
> +	orion_init_hw(op);
> +
> +	/*
> + 	 * Setup our net_device
> +	 */
> +	dev->base_addr = op->base_addr;
> +	dev->irq = irq;
> +	dev->open = orion_open;
> +	dev->stop = orion_close;
> +	dev->hard_start_xmit = orion_tx;
> +	dev->do_ioctl = orion_ioctl;
> +	dev->get_stats = orion_get_stats;
> +	dev->ethtool_ops = &orion_ethtool_ops;
> +	dev->set_mac_address = orion_set_mac_addr;
> +	dev->set_multicast_list = orion_multicast;
> +	dev->poll = orion_poll;
> +	dev->weight = 64;
> +	dev->tx_queue_len = TX_DESC_NR;
> +	SET_ETHTOOL_OPS(dev, &orion_ethtool_ops);
> +#ifdef ORION_TX_CSUM_OFFLOAD
> +	dev->features = NETIF_F_SG | NETIF_F_IP_CSUM;
> +#endif

a tx_timeout method (that resets the NIC, usually) would be nice


> +	/*
> +	 * Use MAC address from (1) board specific data, or (2) current HW
> +	 * settings, or (3) random address.
> +	 */
> +	if (is_valid_ether_addr(data->dev_addr)) {
> +		memcpy(dev->dev_addr, data->dev_addr, ETH_ALEN);
> +		printk(KERN_INFO "Using board specific MAC address\n");
> +	} else {
> +		/*
> +		 * Read from HW (Boot loader settings)
> +		 */
> +		u32 mac_h, mac_l;
> +		mac_h = rdl(op, PORT_MAC_HI);
> +		mac_l = rdl(op, PORT_MAC_LO);
> +
> +		dev->dev_addr[0] = (mac_h >> 24) & 0xff;
> +		dev->dev_addr[1] = (mac_h >> 16) & 0xff;
> +		dev->dev_addr[2] = (mac_h >> 8) & 0xff;
> +		dev->dev_addr[3] = mac_h & 0xff;
> +		dev->dev_addr[4] = (mac_l >> 8) & 0xff;
> +		dev->dev_addr[5] = mac_l & 0xff;
> +
> +		if (!is_valid_ether_addr(dev->dev_addr)) {
> +			printk(KERN_INFO "Invalid MAC address "
> +				"%.2x:%.2x:%.2x:%.2x:%.2x:%.2x, "
> +				"using random address instead\n",
> +				dev->dev_addr[0], dev->dev_addr[1],
> +				dev->dev_addr[2], dev->dev_addr[3],
> +				dev->dev_addr[4], dev->dev_addr[5]);
> +			random_ether_addr(dev->dev_addr);
> +		}
> +	}
> +
> +	orion_set_unicast(op, dev->dev_addr);
> +
> +	/*
> +	 * Setup MII data
> +	 */
> +	op->mii.phy_id = data->phy_id;
> +	op->mii.phy_id_mask = 0x1f;
> +	op->mii.reg_num_mask = 0x1f;
> +	op->mii.dev = dev;
> +	op->mii.supports_gmii = 1;
> +	op->mii.mdio_read = orion_mii_read;
> +	op->mii.mdio_write = orion_mii_write;
> +
> +	/*
> +	 * Enable PHY autoneg
> +	 */
> +	orion_mii_write(dev, op->mii.phy_id, MII_BMCR, orion_mii_read(dev,
> +			op->mii.phy_id, MII_BMCR) | BMCR_ANENABLE);
> +
> +	/*
> +	 * Setup our net_device private date
> +	 */
> +	spin_lock_init(&op->tx_lock);
> +	spin_lock_init(&op->rx_lock);
> +	spin_lock_init(&op->mii_lock);
> +
> +	/*
> +	 * Setup RX descriptors rings
> +	 */
> +	op->rxd_used = op->rxd_curr = op->rxd_count = 0;
> +	op->rxd_base = dma_alloc_coherent(NULL, sizeof(struct rx_desc) *
> +			RX_DESC_NR, &op->rxd_base_dma, GFP_KERNEL | GFP_DMA);
> +	if (op->rxd_base == NULL) {
> +		printk(KERN_ERR "Failed to alloc RX descriptors\n");
> +		err = -ENOMEM;
> +		goto err_out;
> +	}
> +	memset(op->rxd_base, 0, sizeof(struct rx_desc) * RX_DESC_NR);
> +	for (i = 0, rxd = op->rxd_base; i < RX_DESC_NR - 1; i++, rxd++)
> +		rxd->next = op->rxd_base_dma +
> +				((i + 1) * sizeof(struct rx_desc));
> +	rxd->next = op->rxd_base_dma;
> +
> +	/*
> +	 * Setup TX descriptors rings
> +	 */
> +	op->txd_used = op->txd_curr = op->txd_count = 0;
> +	op->txd_base = dma_alloc_coherent(NULL, sizeof(struct tx_desc) *
> +			TX_DESC_NR, &op->txd_base_dma, GFP_KERNEL | GFP_DMA);
> +	if (op->txd_base == NULL) {
> +		dev_err(&pdev->dev, "Failed to alloc TX descriptors\n");
> +		err = -ENOMEM;
> +		goto err_out;
> +	}
> +	memset(op->txd_base, 0, sizeof(struct tx_desc) * TX_DESC_NR);
> +	for (i = 0, txd = op->txd_base; i < TX_DESC_NR - 1; i++, txd++)
> +		txd->next = op->txd_base_dma +
> +				((i + 1) * sizeof(struct tx_desc));
> +	txd->next = op->txd_base_dma;
> +
> +	/*
> +	 * Register our device
> +	 */
> +	err = register_netdev(dev);
> +	if (err) {
> +		dev_err(&pdev->dev, "Failed to register netdev\n");
> +		goto err_out;
> +	}
> +
> +	printk(KERN_INFO "%s: Orion on-chip gigabit ethernet, IRQ %d, "
> +		"%.2x:%.2x:%.2x:%.2x:%.2x:%.2x, PHY ID %d.\n", dev->name,
> +		dev->irq, dev->dev_addr[0], dev->dev_addr[1],
> +		dev->dev_addr[2], dev->dev_addr[3],
> +		dev->dev_addr[4], dev->dev_addr[5], op->mii.phy_id);
> +
> +	return 0;
> +
> +err_out:
> +	orion_remove(pdev);
> +	return err;
> +}
> +
> +int orion_suspend(struct platform_device *pdev, pm_message_t state)
> +{
> +	/* Not implemented yet */
> +	return -ENOSYS;
> +}
> +
> +int orion_resume(struct platform_device *pdev)
> +{
> +	/* Not implemented yet */
> +	return -ENOSYS;
> +}

just delete these until actually implemented

