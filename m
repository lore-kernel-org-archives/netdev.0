From: Roger Luethi <rl@hellgate.ch>
Subject: [7/9][PATCH 2.6] Media mode rewrite
Date: Tue, 15 Jun 2004 19:49:42 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040615174942.GA11319@k3.hellgate.ch>
References: <20040615174732.GA10241@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040615174732.GA10241@k3.hellgate.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Remove rhine_check_duplex, rhine_timer and related data structures

Add rhine_check_media: wrapper for generic mii_check_media, sets duplex
bit in MAC

Add rhine_enable_linkmon, rhine_disable_linkmon to enable hardware link
status monitoring

Update mdio_read, mdio_write accordingly

Remove get_intr_status check in rhine_start_tx because we are not racing
anymore

Signed-off-by: Roger Luethi <rl@hellgate.ch>

--- orig/drivers/net/via-rhine.c
+++ mod/drivers/net/via-rhine.c
@@ -485,7 +485,6 @@
 
 	struct pci_dev *pdev;
 	struct net_device_stats stats;
-	struct timer_list timer;	/* Media monitoring timer. */
 	spinlock_t lock;
 
 	/* Frequently used values: keep some adjacent for cache effect. */
@@ -498,16 +497,12 @@
 	/* These values are keep track of the transceiver/media in use. */
 	u8 tx_thresh, rx_thresh;
 
-	/* MII transceiver section. */
-	u16 mii_status;			/* last read MII status */
 	struct mii_if_info mii_if;
 };
 
 static int  mdio_read(struct net_device *dev, int phy_id, int location);
 static void mdio_write(struct net_device *dev, int phy_id, int location, int value);
 static int  rhine_open(struct net_device *dev);
-static void rhine_check_duplex(struct net_device *dev);
-static void rhine_timer(unsigned long data);
 static void rhine_tx_timeout(struct net_device *dev);
 static int  rhine_start_tx(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t rhine_interrupt(int irq, void *dev_instance, struct pt_regs *regs);
@@ -1032,6 +1027,21 @@
 	}
 }
 
+static void rhine_check_media(struct net_device *dev, unsigned int init_media)
+{
+	struct rhine_private *rp = netdev_priv(dev);
+	long ioaddr = dev->base_addr;
+
+	mii_check_media(&rp->mii_if, debug, init_media);
+
+	if (rp->mii_if.full_duplex)
+	    writeb(readb(ioaddr + ChipCmd1) | Cmd1FDuplex,
+		   ioaddr + ChipCmd1);
+	else
+	    writeb(readb(ioaddr + ChipCmd1) & ~Cmd1FDuplex,
+		   ioaddr + ChipCmd1);
+}
+
 static void init_registers(struct net_device *dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
@@ -1047,7 +1057,6 @@
 	writeb(0x20, ioaddr + TxConfig);
 	rp->tx_thresh = 0x20;
 	rp->rx_thresh = 0x60;		/* Written in rhine_set_rx_mode(). */
-	rp->mii_if.full_duplex = 0;
 
 	writel(rp->rx_ring_dma, ioaddr + RxRingPtr);
 	writel(rp->tx_ring_dma, ioaddr + TxRingPtr);
@@ -1063,14 +1072,42 @@
 
 	writew(CmdStart|CmdTxOn|CmdRxOn|(Cmd1NoTxPoll << 8),
 	       ioaddr + ChipCmd);
-	if (rp->mii_if.force_media)
-		writeb(readb(ioaddr + ChipCmd1) | Cmd1FDuplex,
-		       ioaddr + ChipCmd1);
-	else
-		writeb(readb(ioaddr + ChipCmd1) & ~Cmd1FDuplex,
-		       ioaddr + ChipCmd1);
+	rhine_check_media(dev, 1);
+}
+
+/* Enable MII link status auto-polling (required for IntrLinkChange) */
+static void rhine_enable_linkmon(long ioaddr)
+{
+	writeb(0, ioaddr + MIICmd);
+	writeb(MII_BMSR, ioaddr + MIIRegAddr);
+	writeb(0x80, ioaddr + MIICmd);
 
-	rhine_check_duplex(dev);
+	RHINE_WAIT_FOR((readb(ioaddr + MIIRegAddr) & 0x20));
+
+	writeb(MII_BMSR | 0x40, ioaddr + MIIRegAddr);
+}
+
+/* Disable MII link status auto-polling (required for MDIO access) */
+static void rhine_disable_linkmon(long ioaddr, u32 quirks)
+{
+	writeb(0, ioaddr + MIICmd);
+
+	if (quirks & rqRhineI) {
+		writeb(0x01, ioaddr + MIIRegAddr);	// MII_BMSR
+
+		/* Can be called from ISR. Evil. */
+		mdelay(1);
+
+		/* 0x80 must be set immediately before turning it off */
+		writeb(0x80, ioaddr + MIICmd);
+
+		RHINE_WAIT_FOR(readb(ioaddr + MIIRegAddr) & 0x20);
+
+		/* Heh. Now clear 0x80 again. */
+		writeb(0, ioaddr + MIICmd);
+	}
+	else
+		RHINE_WAIT_FOR(readb(ioaddr + MIIRegAddr) & 0x80);
 }
 
 /* Read and write over the MII Management Data I/O (MDIO) interface. */
@@ -1078,15 +1115,20 @@
 static int mdio_read(struct net_device *dev, int phy_id, int regnum)
 {
 	long ioaddr = dev->base_addr;
+	struct rhine_private *rp = netdev_priv(dev);
+	int result;
 
-	/* Wait for a previous command to complete. */
-	RHINE_WAIT_FOR(!(readb(ioaddr + MIICmd) & 0x60));
-	writeb(0x00, ioaddr + MIICmd);
+	rhine_disable_linkmon(ioaddr, rp->quirks);
+
+	writeb(0, ioaddr + MIICmd);
 	writeb(phy_id, ioaddr + MIIPhyAddr);
 	writeb(regnum, ioaddr + MIIRegAddr);
 	writeb(0x40, ioaddr + MIICmd);		/* Trigger read */
 	RHINE_WAIT_FOR(!(readb(ioaddr + MIICmd) & 0x40));
-	return readw(ioaddr + MIIData);
+	result = readw(ioaddr + MIIData);
+
+	rhine_enable_linkmon(ioaddr);
+	return result;
 }
 
 static void mdio_write(struct net_device *dev, int phy_id, int regnum, int value)
@@ -1094,29 +1136,17 @@
 	struct rhine_private *rp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 
-	if (phy_id == rp->mii_if.phy_id) {
-		switch (regnum) {
-		case MII_BMCR:		/* Is user forcing speed/duplex? */
-			if (value & 0x9000)	/* Autonegotiation. */
-				rp->mii_if.force_media = 0;
-			else
-				rp->mii_if.full_duplex = (value & 0x0100) ? 1 : 0;
-			break;
-		case MII_ADVERTISE:
-			rp->mii_if.advertising = value;
-			break;
-		}
-	}
+	rhine_disable_linkmon(ioaddr, rp->quirks);
 
-	/* Wait for a previous command to complete. */
-	RHINE_WAIT_FOR(!(readb(ioaddr + MIICmd) & 0x60));
-	writeb(0x00, ioaddr + MIICmd);
+	writeb(0, ioaddr + MIICmd);
 	writeb(phy_id, ioaddr + MIIPhyAddr);
 	writeb(regnum, ioaddr + MIIRegAddr);
 	writew(value, ioaddr + MIIData);
 	writeb(0x20, ioaddr + MIICmd);		/* Trigger write. */
-}
+	RHINE_WAIT_FOR(!(readb(ioaddr + MIICmd) & 0x20));
 
+	rhine_enable_linkmon(ioaddr);
+}
 
 static int rhine_open(struct net_device *dev)
 {
@@ -1148,78 +1178,9 @@
 
 	netif_start_queue(dev);
 
-	/* Set the timer to check for link beat. */
-	init_timer(&rp->timer);
-	rp->timer.expires = jiffies + 2 * HZ/100;
-	rp->timer.data = (unsigned long)dev;
-	rp->timer.function = &rhine_timer;		/* timer handler */
-	add_timer(&rp->timer);
-
 	return 0;
 }
 
-static void rhine_check_duplex(struct net_device *dev)
-{
-	struct rhine_private *rp = netdev_priv(dev);
-	long ioaddr = dev->base_addr;
-	int mii_lpa = mdio_read(dev, rp->mii_if.phy_id, MII_LPA);
-	int negotiated = mii_lpa & rp->mii_if.advertising;
-	int duplex;
-
-	if (rp->mii_if.force_media || mii_lpa == 0xffff)
-		return;
-	duplex = (negotiated & 0x0100) || (negotiated & 0x01C0) == 0x0040;
-	if (rp->mii_if.full_duplex != duplex) {
-		rp->mii_if.full_duplex = duplex;
-		if (debug)
-			printk(KERN_INFO "%s: Setting %s-duplex based on "
-			       "MII #%d link partner capability of %4.4x.\n",
-			       dev->name, duplex ? "full" : "half",
-			       rp->mii_if.phy_id, mii_lpa);
-		if (duplex)
-			writeb(readb(ioaddr + ChipCmd1) | Cmd1FDuplex,
-			       ioaddr + ChipCmd1);
-		else
-			writeb(readb(ioaddr + ChipCmd1) & ~Cmd1FDuplex,
-			       ioaddr + ChipCmd1);
-	}
-}
-
-
-static void rhine_timer(unsigned long data)
-{
-	struct net_device *dev = (struct net_device *)data;
-	struct rhine_private *rp = netdev_priv(dev);
-	long ioaddr = dev->base_addr;
-	int next_tick = 10*HZ;
-	int mii_status;
-
-	if (debug > 3) {
-		printk(KERN_DEBUG "%s: VIA Rhine monitor tick, status %4.4x.\n",
-		       dev->name, readw(ioaddr + IntrStatus));
-	}
-
-	spin_lock_irq (&rp->lock);
-
-	rhine_check_duplex(dev);
-
-	/* make IFF_RUNNING follow the MII status bit "Link established" */
-	mii_status = mdio_read(dev, rp->mii_if.phy_id, MII_BMSR);
-	if ((mii_status & BMSR_LSTATUS) != (rp->mii_status & BMSR_LSTATUS)) {
-		if (mii_status & BMSR_LSTATUS)
-			netif_carrier_on(dev);
-		else
-			netif_carrier_off(dev);
-	}
-	rp->mii_status = mii_status;
-
-	spin_unlock_irq(&rp->lock);
-
-	rp->timer.expires = jiffies + next_tick;
-	add_timer(&rp->timer);
-}
-
-
 static void rhine_tx_timeout(struct net_device *dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
@@ -1256,8 +1217,8 @@
 static int rhine_start_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
+	long ioaddr = dev->base_addr;
 	unsigned entry;
-	u32 intr_status;
 
 	/* Caution: the write order is important here, set the field
 	   with the "ownership" bits last. */
@@ -1308,15 +1269,9 @@
 
 	/* Non-x86 Todo: explicitly flush cache lines here. */
 
-	/*
-	 * Wake the potentially-idle transmit channel unless errors are
-	 * pending (the ISR must sort them out first).
-	 */
-	intr_status = get_intr_status(dev);
-	if ((intr_status & IntrTxErrSummary) == 0) {
-		writeb(readb(dev->base_addr + ChipCmd1) | Cmd1TxDemand,
-		       dev->base_addr + ChipCmd1);
-	}
+	/* Wake the potentially-idle transmit channel */
+	writeb(readb(ioaddr + ChipCmd1) | Cmd1TxDemand,
+	       ioaddr + ChipCmd1);
 	IOSYNC;
 
 	if (rp->cur_tx == rp->dirty_tx + TX_QUEUE_LEN)
@@ -1639,15 +1594,8 @@
 
 	spin_lock(&rp->lock);
 
-	if (intr_status & (IntrLinkChange)) {
-		rhine_check_duplex(dev);
-		if (debug)
-			printk(KERN_ERR "%s: MII status changed: "
-			       "Autonegotiation advertising %4.4x partner "
-			       "%4.4x.\n", dev->name,
-			       mdio_read(dev, rp->mii_if.phy_id, MII_ADVERTISE),
-			       mdio_read(dev, rp->mii_if.phy_id, MII_LPA));
-	}
+	if (intr_status & IntrLinkChange)
+		rhine_check_media(dev, 0);
 	if (intr_status & IntrStatsMax) {
 		rp->stats.rx_crc_errors += readw(ioaddr + RxCRCErrs);
 		rp->stats.rx_missed_errors += readw(ioaddr + RxMissed);
@@ -1839,8 +1786,6 @@
 	long ioaddr = dev->base_addr;
 	struct rhine_private *rp = netdev_priv(dev);
 
-	del_timer_sync(&rp->timer);
-
 	spin_lock_irq(&rp->lock);
 
 	netif_stop_queue(dev);
