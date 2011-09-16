From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] pcnet32: constify function table
Date: Fri, 16 Sep 2011 14:06:26 -0700
Message-ID: <20110916140626.2648c477@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Don Fry <pcnet32@frontier.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42548 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932215Ab1IPVG1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Sep 2011 17:06:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Function tables need to be const to prevent malicious use.

This is compile tested only.
Gleaned from PAX.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/ethernet/amd/pcnet32.c |  202 +++++++++++++++++++++++++-------------------------
 1 file changed, 101 insertions(+), 101 deletions(-)

--- a/drivers/net/ethernet/amd/pcnet32.c	2011-09-16 13:12:56.421369669 -0700
+++ b/drivers/net/ethernet/amd/pcnet32.c	2011-09-16 13:18:39.973385541 -0700
@@ -270,7 +270,7 @@ struct pcnet32_private {
 	struct sk_buff		**rx_skbuff;
 	dma_addr_t		*tx_dma_addr;
 	dma_addr_t		*rx_dma_addr;
-	struct pcnet32_access	a;
+	const struct pcnet32_access *a;
 	spinlock_t		lock;		/* Guard lock */
 	unsigned int		cur_rx, cur_tx;	/* The next free ring entry */
 	unsigned int		rx_ring_size;	/* current rx ring size */
@@ -379,7 +379,7 @@ static int pcnet32_wio_check(unsigned lo
 	return inw(addr + PCNET32_WIO_RAP) == 88;
 }
 
-static struct pcnet32_access pcnet32_wio = {
+static const struct pcnet32_access pcnet32_wio = {
 	.read_csr = pcnet32_wio_read_csr,
 	.write_csr = pcnet32_wio_write_csr,
 	.read_bcr = pcnet32_wio_read_bcr,
@@ -434,7 +434,7 @@ static int pcnet32_dwio_check(unsigned l
 	return (inl(addr + PCNET32_DWIO_RAP) & 0xffff) == 88;
 }
 
-static struct pcnet32_access pcnet32_dwio = {
+static const struct pcnet32_access pcnet32_dwio = {
 	.read_csr = pcnet32_dwio_read_csr,
 	.write_csr = pcnet32_dwio_write_csr,
 	.read_bcr = pcnet32_dwio_read_bcr,
@@ -460,9 +460,9 @@ static void pcnet32_netif_start(struct n
 	u16 val;
 
 	netif_wake_queue(dev);
-	val = lp->a.read_csr(ioaddr, CSR3);
+	val = lp->a->read_csr(ioaddr, CSR3);
 	val &= 0x00ff;
-	lp->a.write_csr(ioaddr, CSR3, val);
+	lp->a->write_csr(ioaddr, CSR3, val);
 	napi_enable(&lp->napi);
 }
 
@@ -730,7 +730,7 @@ static u32 pcnet32_get_link(struct net_d
 		r = mii_link_ok(&lp->mii_if);
 	} else if (lp->chip_version >= PCNET32_79C970A) {
 		ulong ioaddr = dev->base_addr;	/* card base I/O address */
-		r = (lp->a.read_bcr(ioaddr, 4) != 0xc0);
+		r = (lp->a->read_bcr(ioaddr, 4) != 0xc0);
 	} else {	/* can not detect link on really old chips */
 		r = 1;
 	}
@@ -792,7 +792,7 @@ static int pcnet32_set_ringparam(struct
 		pcnet32_netif_stop(dev);
 
 	spin_lock_irqsave(&lp->lock, flags);
-	lp->a.write_csr(ioaddr, CSR0, CSR0_STOP);	/* stop the chip */
+	lp->a->write_csr(ioaddr, CSR0, CSR0_STOP);	/* stop the chip */
 
 	size = min(ering->tx_pending, (unsigned int)TX_MAX_RING_SIZE);
 
@@ -868,7 +868,7 @@ static void pcnet32_ethtool_test(struct
 static int pcnet32_loopback_test(struct net_device *dev, uint64_t * data1)
 {
 	struct pcnet32_private *lp = netdev_priv(dev);
-	struct pcnet32_access *a = &lp->a;	/* access to registers */
+	const struct pcnet32_access *a = lp->a;	/* access to registers */
 	ulong ioaddr = dev->base_addr;	/* card base I/O address */
 	struct sk_buff *skb;	/* sk buff */
 	int x, i;		/* counters */
@@ -888,21 +888,21 @@ static int pcnet32_loopback_test(struct
 		pcnet32_netif_stop(dev);
 
 	spin_lock_irqsave(&lp->lock, flags);
-	lp->a.write_csr(ioaddr, CSR0, CSR0_STOP);	/* stop the chip */
+	lp->a->write_csr(ioaddr, CSR0, CSR0_STOP);	/* stop the chip */
 
 	numbuffs = min(numbuffs, (int)min(lp->rx_ring_size, lp->tx_ring_size));
 
 	/* Reset the PCNET32 */
-	lp->a.reset(ioaddr);
-	lp->a.write_csr(ioaddr, CSR4, 0x0915);	/* auto tx pad */
+	lp->a->reset(ioaddr);
+	lp->a->write_csr(ioaddr, CSR4, 0x0915);	/* auto tx pad */
 
 	/* switch pcnet32 to 32bit mode */
-	lp->a.write_bcr(ioaddr, 20, 2);
+	lp->a->write_bcr(ioaddr, 20, 2);
 
 	/* purge & init rings but don't actually restart */
 	pcnet32_restart(dev, 0x0000);
 
-	lp->a.write_csr(ioaddr, CSR0, CSR0_STOP);	/* Set STOP bit */
+	lp->a->write_csr(ioaddr, CSR0, CSR0_STOP);	/* Set STOP bit */
 
 	/* Initialize Transmit buffers. */
 	size = data_len + 15;
@@ -947,10 +947,10 @@ static int pcnet32_loopback_test(struct
 
 	/* set int loopback in CSR15 */
 	x = a->read_csr(ioaddr, CSR15) & 0xfffc;
-	lp->a.write_csr(ioaddr, CSR15, x | 0x0044);
+	lp->a->write_csr(ioaddr, CSR15, x | 0x0044);
 
 	teststatus = cpu_to_le16(0x8000);
-	lp->a.write_csr(ioaddr, CSR0, CSR0_START);	/* Set STRT bit */
+	lp->a->write_csr(ioaddr, CSR0, CSR0_START);	/* Set STRT bit */
 
 	/* Check status of descriptors */
 	for (x = 0; x < numbuffs; x++) {
@@ -969,7 +969,7 @@ static int pcnet32_loopback_test(struct
 		}
 	}
 
-	lp->a.write_csr(ioaddr, CSR0, CSR0_STOP);	/* Set STOP bit */
+	lp->a->write_csr(ioaddr, CSR0, CSR0_STOP);	/* Set STOP bit */
 	wmb();
 	if (netif_msg_hw(lp) && netif_msg_pktdata(lp)) {
 		netdev_printk(KERN_DEBUG, dev, "RX loopback packets:\n");
@@ -1015,7 +1015,7 @@ clean_up:
 		pcnet32_restart(dev, CSR0_NORMAL);
 	} else {
 		pcnet32_purge_rx_ring(dev);
-		lp->a.write_bcr(ioaddr, 20, 4);	/* return to 16bit mode */
+		lp->a->write_bcr(ioaddr, 20, 4);	/* return to 16bit mode */
 	}
 	spin_unlock_irqrestore(&lp->lock, flags);
 
@@ -1026,7 +1026,7 @@ static int pcnet32_set_phys_id(struct ne
 			       enum ethtool_phys_id_state state)
 {
 	struct pcnet32_private *lp = netdev_priv(dev);
-	struct pcnet32_access *a = &lp->a;
+	const struct pcnet32_access *a = lp->a;
 	ulong ioaddr = dev->base_addr;
 	unsigned long flags;
 	int i;
@@ -1067,7 +1067,7 @@ static int pcnet32_suspend(struct net_de
 {
 	int csr5;
 	struct pcnet32_private *lp = netdev_priv(dev);
-	struct pcnet32_access *a = &lp->a;
+	const struct pcnet32_access *a = lp->a;
 	ulong ioaddr = dev->base_addr;
 	int ticks;
 
@@ -1324,8 +1324,8 @@ static int pcnet32_poll(struct napi_stru
 	spin_lock_irqsave(&lp->lock, flags);
 	if (pcnet32_tx(dev)) {
 		/* reset the chip to clear the error condition, then restart */
-		lp->a.reset(ioaddr);
-		lp->a.write_csr(ioaddr, CSR4, 0x0915);	/* auto tx pad */
+		lp->a->reset(ioaddr);
+		lp->a->write_csr(ioaddr, CSR4, 0x0915);	/* auto tx pad */
 		pcnet32_restart(dev, CSR0_START);
 		netif_wake_queue(dev);
 	}
@@ -1337,12 +1337,12 @@ static int pcnet32_poll(struct napi_stru
 		__napi_complete(napi);
 
 		/* clear interrupt masks */
-		val = lp->a.read_csr(ioaddr, CSR3);
+		val = lp->a->read_csr(ioaddr, CSR3);
 		val &= 0x00ff;
-		lp->a.write_csr(ioaddr, CSR3, val);
+		lp->a->write_csr(ioaddr, CSR3, val);
 
 		/* Set interrupt enable. */
-		lp->a.write_csr(ioaddr, CSR0, CSR0_INTEN);
+		lp->a->write_csr(ioaddr, CSR0, CSR0_INTEN);
 
 		spin_unlock_irqrestore(&lp->lock, flags);
 	}
@@ -1365,7 +1365,7 @@ static void pcnet32_get_regs(struct net_
 	int i, csr0;
 	u16 *buff = ptr;
 	struct pcnet32_private *lp = netdev_priv(dev);
-	struct pcnet32_access *a = &lp->a;
+	const struct pcnet32_access *a = lp->a;
 	ulong ioaddr = dev->base_addr;
 	unsigned long flags;
 
@@ -1401,9 +1401,9 @@ static void pcnet32_get_regs(struct net_
 		for (j = 0; j < PCNET32_MAX_PHYS; j++) {
 			if (lp->phymask & (1 << j)) {
 				for (i = 0; i < PCNET32_REGS_PER_PHY; i++) {
-					lp->a.write_bcr(ioaddr, 33,
+					lp->a->write_bcr(ioaddr, 33,
 							(j << 5) | i);
-					*buff++ = lp->a.read_bcr(ioaddr, 34);
+					*buff++ = lp->a->read_bcr(ioaddr, 34);
 				}
 			}
 		}
@@ -1528,7 +1528,7 @@ pcnet32_probe1(unsigned long ioaddr, int
 	int chip_version;
 	char *chipname;
 	struct net_device *dev;
-	struct pcnet32_access *a = NULL;
+	const struct pcnet32_access *a = NULL;
 	u8 promaddr[6];
 	int ret = -ENODEV;
 
@@ -1785,7 +1785,7 @@ pcnet32_probe1(unsigned long ioaddr, int
 	    ((cards_found >= MAX_UNITS) || full_duplex[cards_found]))
 		lp->options |= PCNET32_PORT_FD;
 
-	lp->a = *a;
+	lp->a = a;
 
 	/* prior to register_netdev, dev->name is not yet correct */
 	if (pcnet32_alloc_ring(dev, pci_name(lp->pci_dev))) {
@@ -1844,7 +1844,7 @@ pcnet32_probe1(unsigned long ioaddr, int
 	if (lp->mii) {
 		/* lp->phycount and lp->phymask are set to 0 by memset above */
 
-		lp->mii_if.phy_id = ((lp->a.read_bcr(ioaddr, 33)) >> 5) & 0x1f;
+		lp->mii_if.phy_id = ((lp->a->read_bcr(ioaddr, 33)) >> 5) & 0x1f;
 		/* scan for PHYs */
 		for (i = 0; i < PCNET32_MAX_PHYS; i++) {
 			unsigned short id1, id2;
@@ -1864,7 +1864,7 @@ pcnet32_probe1(unsigned long ioaddr, int
 				pr_info("Found PHY %04x:%04x at address %d\n",
 					id1, id2, i);
 		}
-		lp->a.write_bcr(ioaddr, 33, (lp->mii_if.phy_id) << 5);
+		lp->a->write_bcr(ioaddr, 33, (lp->mii_if.phy_id) << 5);
 		if (lp->phycount > 1)
 			lp->options |= PCNET32_PORT_MII;
 	}
@@ -2020,10 +2020,10 @@ static int pcnet32_open(struct net_devic
 	}
 
 	/* Reset the PCNET32 */
-	lp->a.reset(ioaddr);
+	lp->a->reset(ioaddr);
 
 	/* switch pcnet32 to 32bit mode */
-	lp->a.write_bcr(ioaddr, 20, 2);
+	lp->a->write_bcr(ioaddr, 20, 2);
 
 	netif_printk(lp, ifup, KERN_DEBUG, dev,
 		     "%s() irq %d tx/rx rings %#x/%#x init %#x\n",
@@ -2032,14 +2032,14 @@ static int pcnet32_open(struct net_devic
 		     (u32) (lp->init_dma_addr));
 
 	/* set/reset autoselect bit */
-	val = lp->a.read_bcr(ioaddr, 2) & ~2;
+	val = lp->a->read_bcr(ioaddr, 2) & ~2;
 	if (lp->options & PCNET32_PORT_ASEL)
 		val |= 2;
-	lp->a.write_bcr(ioaddr, 2, val);
+	lp->a->write_bcr(ioaddr, 2, val);
 
 	/* handle full duplex setting */
 	if (lp->mii_if.full_duplex) {
-		val = lp->a.read_bcr(ioaddr, 9) & ~3;
+		val = lp->a->read_bcr(ioaddr, 9) & ~3;
 		if (lp->options & PCNET32_PORT_FD) {
 			val |= 1;
 			if (lp->options == (PCNET32_PORT_FD | PCNET32_PORT_AUI))
@@ -2049,14 +2049,14 @@ static int pcnet32_open(struct net_devic
 			if (lp->chip_version == 0x2627)
 				val |= 3;
 		}
-		lp->a.write_bcr(ioaddr, 9, val);
+		lp->a->write_bcr(ioaddr, 9, val);
 	}
 
 	/* set/reset GPSI bit in test register */
-	val = lp->a.read_csr(ioaddr, 124) & ~0x10;
+	val = lp->a->read_csr(ioaddr, 124) & ~0x10;
 	if ((lp->options & PCNET32_PORT_PORTSEL) == PCNET32_PORT_GPSI)
 		val |= 0x10;
-	lp->a.write_csr(ioaddr, 124, val);
+	lp->a->write_csr(ioaddr, 124, val);
 
 	/* Allied Telesyn AT 2700/2701 FX are 100Mbit only and do not negotiate */
 	if (pdev && pdev->subsystem_vendor == PCI_VENDOR_ID_AT &&
@@ -2075,24 +2075,24 @@ static int pcnet32_open(struct net_devic
 		 * duplex, and/or enable auto negotiation, and clear DANAS
 		 */
 		if (lp->mii && !(lp->options & PCNET32_PORT_ASEL)) {
-			lp->a.write_bcr(ioaddr, 32,
-					lp->a.read_bcr(ioaddr, 32) | 0x0080);
+			lp->a->write_bcr(ioaddr, 32,
+					lp->a->read_bcr(ioaddr, 32) | 0x0080);
 			/* disable Auto Negotiation, set 10Mpbs, HD */
-			val = lp->a.read_bcr(ioaddr, 32) & ~0xb8;
+			val = lp->a->read_bcr(ioaddr, 32) & ~0xb8;
 			if (lp->options & PCNET32_PORT_FD)
 				val |= 0x10;
 			if (lp->options & PCNET32_PORT_100)
 				val |= 0x08;
-			lp->a.write_bcr(ioaddr, 32, val);
+			lp->a->write_bcr(ioaddr, 32, val);
 		} else {
 			if (lp->options & PCNET32_PORT_ASEL) {
-				lp->a.write_bcr(ioaddr, 32,
-						lp->a.read_bcr(ioaddr,
+				lp->a->write_bcr(ioaddr, 32,
+						lp->a->read_bcr(ioaddr,
 							       32) | 0x0080);
 				/* enable auto negotiate, setup, disable fd */
-				val = lp->a.read_bcr(ioaddr, 32) & ~0x98;
+				val = lp->a->read_bcr(ioaddr, 32) & ~0x98;
 				val |= 0x20;
-				lp->a.write_bcr(ioaddr, 32, val);
+				lp->a->write_bcr(ioaddr, 32, val);
 			}
 		}
 	} else {
@@ -2105,10 +2105,10 @@ static int pcnet32_open(struct net_devic
 		 * There is really no good other way to handle multiple PHYs
 		 * other than turning off all automatics
 		 */
-		val = lp->a.read_bcr(ioaddr, 2);
-		lp->a.write_bcr(ioaddr, 2, val & ~2);
-		val = lp->a.read_bcr(ioaddr, 32);
-		lp->a.write_bcr(ioaddr, 32, val & ~(1 << 7));	/* stop MII manager */
+		val = lp->a->read_bcr(ioaddr, 2);
+		lp->a->write_bcr(ioaddr, 2, val & ~2);
+		val = lp->a->read_bcr(ioaddr, 32);
+		lp->a->write_bcr(ioaddr, 32, val & ~(1 << 7));	/* stop MII manager */
 
 		if (!(lp->options & PCNET32_PORT_ASEL)) {
 			/* setup ecmd */
@@ -2118,7 +2118,7 @@ static int pcnet32_open(struct net_devic
 			ethtool_cmd_speed_set(&ecmd,
 					      (lp->options & PCNET32_PORT_100) ?
 					      SPEED_100 : SPEED_10);
-			bcr9 = lp->a.read_bcr(ioaddr, 9);
+			bcr9 = lp->a->read_bcr(ioaddr, 9);
 
 			if (lp->options & PCNET32_PORT_FD) {
 				ecmd.duplex = DUPLEX_FULL;
@@ -2127,7 +2127,7 @@ static int pcnet32_open(struct net_devic
 				ecmd.duplex = DUPLEX_HALF;
 				bcr9 |= ~(1 << 0);
 			}
-			lp->a.write_bcr(ioaddr, 9, bcr9);
+			lp->a->write_bcr(ioaddr, 9, bcr9);
 		}
 
 		for (i = 0; i < PCNET32_MAX_PHYS; i++) {
@@ -2158,9 +2158,9 @@ static int pcnet32_open(struct net_devic
 
 #ifdef DO_DXSUFLO
 	if (lp->dxsuflo) {	/* Disable transmit stop on underflow */
-		val = lp->a.read_csr(ioaddr, CSR3);
+		val = lp->a->read_csr(ioaddr, CSR3);
 		val |= 0x40;
-		lp->a.write_csr(ioaddr, CSR3, val);
+		lp->a->write_csr(ioaddr, CSR3, val);
 	}
 #endif
 
@@ -2176,11 +2176,11 @@ static int pcnet32_open(struct net_devic
 	napi_enable(&lp->napi);
 
 	/* Re-initialize the PCNET32, and start it when done. */
-	lp->a.write_csr(ioaddr, 1, (lp->init_dma_addr & 0xffff));
-	lp->a.write_csr(ioaddr, 2, (lp->init_dma_addr >> 16));
+	lp->a->write_csr(ioaddr, 1, (lp->init_dma_addr & 0xffff));
+	lp->a->write_csr(ioaddr, 2, (lp->init_dma_addr >> 16));
 
-	lp->a.write_csr(ioaddr, CSR4, 0x0915);	/* auto tx pad */
-	lp->a.write_csr(ioaddr, CSR0, CSR0_INIT);
+	lp->a->write_csr(ioaddr, CSR4, 0x0915);	/* auto tx pad */
+	lp->a->write_csr(ioaddr, CSR0, CSR0_INIT);
 
 	netif_start_queue(dev);
 
@@ -2192,19 +2192,19 @@ static int pcnet32_open(struct net_devic
 
 	i = 0;
 	while (i++ < 100)
-		if (lp->a.read_csr(ioaddr, CSR0) & CSR0_IDON)
+		if (lp->a->read_csr(ioaddr, CSR0) & CSR0_IDON)
 			break;
 	/*
 	 * We used to clear the InitDone bit, 0x0100, here but Mark Stockton
 	 * reports that doing so triggers a bug in the '974.
 	 */
-	lp->a.write_csr(ioaddr, CSR0, CSR0_NORMAL);
+	lp->a->write_csr(ioaddr, CSR0, CSR0_NORMAL);
 
 	netif_printk(lp, ifup, KERN_DEBUG, dev,
 		     "pcnet32 open after %d ticks, init block %#x csr0 %4.4x\n",
 		     i,
 		     (u32) (lp->init_dma_addr),
-		     lp->a.read_csr(ioaddr, CSR0));
+		     lp->a->read_csr(ioaddr, CSR0));
 
 	spin_unlock_irqrestore(&lp->lock, flags);
 
@@ -2218,7 +2218,7 @@ err_free_ring:
 	 * Switch back to 16bit mode to avoid problems with dumb
 	 * DOS packet driver after a warm reboot
 	 */
-	lp->a.write_bcr(ioaddr, 20, 4);
+	lp->a->write_bcr(ioaddr, 20, 4);
 
 err_free_irq:
 	spin_unlock_irqrestore(&lp->lock, flags);
@@ -2323,7 +2323,7 @@ static void pcnet32_restart(struct net_d
 
 	/* wait for stop */
 	for (i = 0; i < 100; i++)
-		if (lp->a.read_csr(ioaddr, CSR0) & CSR0_STOP)
+		if (lp->a->read_csr(ioaddr, CSR0) & CSR0_STOP)
 			break;
 
 	if (i >= 100)
@@ -2335,13 +2335,13 @@ static void pcnet32_restart(struct net_d
 		return;
 
 	/* ReInit Ring */
-	lp->a.write_csr(ioaddr, CSR0, CSR0_INIT);
+	lp->a->write_csr(ioaddr, CSR0, CSR0_INIT);
 	i = 0;
 	while (i++ < 1000)
-		if (lp->a.read_csr(ioaddr, CSR0) & CSR0_IDON)
+		if (lp->a->read_csr(ioaddr, CSR0) & CSR0_IDON)
 			break;
 
-	lp->a.write_csr(ioaddr, CSR0, csr0_bits);
+	lp->a->write_csr(ioaddr, CSR0, csr0_bits);
 }
 
 static void pcnet32_tx_timeout(struct net_device *dev)
@@ -2353,8 +2353,8 @@ static void pcnet32_tx_timeout(struct ne
 	/* Transmitter timeout, serious problems. */
 	if (pcnet32_debug & NETIF_MSG_DRV)
 		pr_err("%s: transmit timed out, status %4.4x, resetting\n",
-		       dev->name, lp->a.read_csr(ioaddr, CSR0));
-	lp->a.write_csr(ioaddr, CSR0, CSR0_STOP);
+		       dev->name, lp->a->read_csr(ioaddr, CSR0));
+	lp->a->write_csr(ioaddr, CSR0, CSR0_STOP);
 	dev->stats.tx_errors++;
 	if (netif_msg_tx_err(lp)) {
 		int i;
@@ -2397,7 +2397,7 @@ static netdev_tx_t pcnet32_start_xmit(st
 
 	netif_printk(lp, tx_queued, KERN_DEBUG, dev,
 		     "%s() called, csr0 %4.4x\n",
-		     __func__, lp->a.read_csr(ioaddr, CSR0));
+		     __func__, lp->a->read_csr(ioaddr, CSR0));
 
 	/* Default status -- will not enable Successful-TxDone
 	 * interrupt when that option is available to us.
@@ -2427,7 +2427,7 @@ static netdev_tx_t pcnet32_start_xmit(st
 	dev->stats.tx_bytes += skb->len;
 
 	/* Trigger an immediate send poll. */
-	lp->a.write_csr(ioaddr, CSR0, CSR0_INTEN | CSR0_TXPOLL);
+	lp->a->write_csr(ioaddr, CSR0, CSR0_INTEN | CSR0_TXPOLL);
 
 	if (lp->tx_ring[(entry + 1) & lp->tx_mod_mask].base != 0) {
 		lp->tx_full = 1;
@@ -2452,16 +2452,16 @@ pcnet32_interrupt(int irq, void *dev_id)
 
 	spin_lock(&lp->lock);
 
-	csr0 = lp->a.read_csr(ioaddr, CSR0);
+	csr0 = lp->a->read_csr(ioaddr, CSR0);
 	while ((csr0 & 0x8f00) && --boguscnt >= 0) {
 		if (csr0 == 0xffff)
 			break;	/* PCMCIA remove happened */
 		/* Acknowledge all of the current interrupt sources ASAP. */
-		lp->a.write_csr(ioaddr, CSR0, csr0 & ~0x004f);
+		lp->a->write_csr(ioaddr, CSR0, csr0 & ~0x004f);
 
 		netif_printk(lp, intr, KERN_DEBUG, dev,
 			     "interrupt  csr0=%#2.2x new csr=%#2.2x\n",
-			     csr0, lp->a.read_csr(ioaddr, CSR0));
+			     csr0, lp->a->read_csr(ioaddr, CSR0));
 
 		/* Log misc errors. */
 		if (csr0 & 0x4000)
@@ -2488,19 +2488,19 @@ pcnet32_interrupt(int irq, void *dev_id)
 		if (napi_schedule_prep(&lp->napi)) {
 			u16 val;
 			/* set interrupt masks */
-			val = lp->a.read_csr(ioaddr, CSR3);
+			val = lp->a->read_csr(ioaddr, CSR3);
 			val |= 0x5f00;
-			lp->a.write_csr(ioaddr, CSR3, val);
+			lp->a->write_csr(ioaddr, CSR3, val);
 
 			__napi_schedule(&lp->napi);
 			break;
 		}
-		csr0 = lp->a.read_csr(ioaddr, CSR0);
+		csr0 = lp->a->read_csr(ioaddr, CSR0);
 	}
 
 	netif_printk(lp, intr, KERN_DEBUG, dev,
 		     "exiting interrupt, csr0=%#4.4x\n",
-		     lp->a.read_csr(ioaddr, CSR0));
+		     lp->a->read_csr(ioaddr, CSR0));
 
 	spin_unlock(&lp->lock);
 
@@ -2520,20 +2520,20 @@ static int pcnet32_close(struct net_devi
 
 	spin_lock_irqsave(&lp->lock, flags);
 
-	dev->stats.rx_missed_errors = lp->a.read_csr(ioaddr, 112);
+	dev->stats.rx_missed_errors = lp->a->read_csr(ioaddr, 112);
 
 	netif_printk(lp, ifdown, KERN_DEBUG, dev,
 		     "Shutting down ethercard, status was %2.2x\n",
-		     lp->a.read_csr(ioaddr, CSR0));
+		     lp->a->read_csr(ioaddr, CSR0));
 
 	/* We stop the PCNET32 here -- it occasionally polls memory if we don't. */
-	lp->a.write_csr(ioaddr, CSR0, CSR0_STOP);
+	lp->a->write_csr(ioaddr, CSR0, CSR0_STOP);
 
 	/*
 	 * Switch back to 16bit mode to avoid problems with dumb
 	 * DOS packet driver after a warm reboot
 	 */
-	lp->a.write_bcr(ioaddr, 20, 4);
+	lp->a->write_bcr(ioaddr, 20, 4);
 
 	spin_unlock_irqrestore(&lp->lock, flags);
 
@@ -2556,7 +2556,7 @@ static struct net_device_stats *pcnet32_
 	unsigned long flags;
 
 	spin_lock_irqsave(&lp->lock, flags);
-	dev->stats.rx_missed_errors = lp->a.read_csr(ioaddr, 112);
+	dev->stats.rx_missed_errors = lp->a->read_csr(ioaddr, 112);
 	spin_unlock_irqrestore(&lp->lock, flags);
 
 	return &dev->stats;
@@ -2577,10 +2577,10 @@ static void pcnet32_load_multicast(struc
 	if (dev->flags & IFF_ALLMULTI) {
 		ib->filter[0] = cpu_to_le32(~0U);
 		ib->filter[1] = cpu_to_le32(~0U);
-		lp->a.write_csr(ioaddr, PCNET32_MC_FILTER, 0xffff);
-		lp->a.write_csr(ioaddr, PCNET32_MC_FILTER+1, 0xffff);
-		lp->a.write_csr(ioaddr, PCNET32_MC_FILTER+2, 0xffff);
-		lp->a.write_csr(ioaddr, PCNET32_MC_FILTER+3, 0xffff);
+		lp->a->write_csr(ioaddr, PCNET32_MC_FILTER, 0xffff);
+		lp->a->write_csr(ioaddr, PCNET32_MC_FILTER+1, 0xffff);
+		lp->a->write_csr(ioaddr, PCNET32_MC_FILTER+2, 0xffff);
+		lp->a->write_csr(ioaddr, PCNET32_MC_FILTER+3, 0xffff);
 		return;
 	}
 	/* clear the multicast filter */
@@ -2594,7 +2594,7 @@ static void pcnet32_load_multicast(struc
 		mcast_table[crc >> 4] |= cpu_to_le16(1 << (crc & 0xf));
 	}
 	for (i = 0; i < 4; i++)
-		lp->a.write_csr(ioaddr, PCNET32_MC_FILTER + i,
+		lp->a->write_csr(ioaddr, PCNET32_MC_FILTER + i,
 				le16_to_cpu(mcast_table[i]));
 }
 
@@ -2609,28 +2609,28 @@ static void pcnet32_set_multicast_list(s
 
 	spin_lock_irqsave(&lp->lock, flags);
 	suspended = pcnet32_suspend(dev, &flags, 0);
-	csr15 = lp->a.read_csr(ioaddr, CSR15);
+	csr15 = lp->a->read_csr(ioaddr, CSR15);
 	if (dev->flags & IFF_PROMISC) {
 		/* Log any net taps. */
 		netif_info(lp, hw, dev, "Promiscuous mode enabled\n");
 		lp->init_block->mode =
 		    cpu_to_le16(0x8000 | (lp->options & PCNET32_PORT_PORTSEL) <<
 				7);
-		lp->a.write_csr(ioaddr, CSR15, csr15 | 0x8000);
+		lp->a->write_csr(ioaddr, CSR15, csr15 | 0x8000);
 	} else {
 		lp->init_block->mode =
 		    cpu_to_le16((lp->options & PCNET32_PORT_PORTSEL) << 7);
-		lp->a.write_csr(ioaddr, CSR15, csr15 & 0x7fff);
+		lp->a->write_csr(ioaddr, CSR15, csr15 & 0x7fff);
 		pcnet32_load_multicast(dev);
 	}
 
 	if (suspended) {
 		int csr5;
 		/* clear SUSPEND (SPND) - CSR5 bit 0 */
-		csr5 = lp->a.read_csr(ioaddr, CSR5);
-		lp->a.write_csr(ioaddr, CSR5, csr5 & (~CSR5_SUSPEND));
+		csr5 = lp->a->read_csr(ioaddr, CSR5);
+		lp->a->write_csr(ioaddr, CSR5, csr5 & (~CSR5_SUSPEND));
 	} else {
-		lp->a.write_csr(ioaddr, CSR0, CSR0_STOP);
+		lp->a->write_csr(ioaddr, CSR0, CSR0_STOP);
 		pcnet32_restart(dev, CSR0_NORMAL);
 		netif_wake_queue(dev);
 	}
@@ -2648,8 +2648,8 @@ static int mdio_read(struct net_device *
 	if (!lp->mii)
 		return 0;
 
-	lp->a.write_bcr(ioaddr, 33, ((phy_id & 0x1f) << 5) | (reg_num & 0x1f));
-	val_out = lp->a.read_bcr(ioaddr, 34);
+	lp->a->write_bcr(ioaddr, 33, ((phy_id & 0x1f) << 5) | (reg_num & 0x1f));
+	val_out = lp->a->read_bcr(ioaddr, 34);
 
 	return val_out;
 }
@@ -2663,8 +2663,8 @@ static void mdio_write(struct net_device
 	if (!lp->mii)
 		return;
 
-	lp->a.write_bcr(ioaddr, 33, ((phy_id & 0x1f) << 5) | (reg_num & 0x1f));
-	lp->a.write_bcr(ioaddr, 34, val);
+	lp->a->write_bcr(ioaddr, 33, ((phy_id & 0x1f) << 5) | (reg_num & 0x1f));
+	lp->a->write_bcr(ioaddr, 34, val);
 }
 
 static int pcnet32_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
@@ -2741,7 +2741,7 @@ static void pcnet32_check_media(struct n
 		curr_link = mii_link_ok(&lp->mii_if);
 	} else {
 		ulong ioaddr = dev->base_addr;	/* card base I/O address */
-		curr_link = (lp->a.read_bcr(ioaddr, 4) != 0xc0);
+		curr_link = (lp->a->read_bcr(ioaddr, 4) != 0xc0);
 	}
 	if (!curr_link) {
 		if (prev_link || verbose) {
@@ -2764,13 +2764,13 @@ static void pcnet32_check_media(struct n
 					    (ecmd.duplex == DUPLEX_FULL)
 					    ? "full" : "half");
 			}
-			bcr9 = lp->a.read_bcr(dev->base_addr, 9);
+			bcr9 = lp->a->read_bcr(dev->base_addr, 9);
 			if ((bcr9 & (1 << 0)) != lp->mii_if.full_duplex) {
 				if (lp->mii_if.full_duplex)
 					bcr9 |= (1 << 0);
 				else
 					bcr9 &= ~(1 << 0);
-				lp->a.write_bcr(dev->base_addr, 9, bcr9);
+				lp->a->write_bcr(dev->base_addr, 9, bcr9);
 			}
 		} else {
 			netif_info(lp, link, dev, "link up\n");
