From: Roger Luethi <rl@hellgate.ch>
Subject: [4/9][PATCH 2.6] Rewrite PHY detection
Date: Tue, 15 Jun 2004 19:49:10 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040615174910.GA11215@k3.hellgate.ch>
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

Instead of probing, set phy_id to 1 for Rhine III and read phy_id from
EEPROM-controlled register for Rhine I/II.

Remove code for handling anything other than 1 MII PHY. If it wasn't
unnecessary code to begin with, it would need to be fixed because it
wouldn't work.

Use mii_if_info.phy_id as the only container of phy_id. Not particulary
happy about those names (phy_id vs. MII_PHYSIDx), but being consequent
about it mitigates confusion.

Signed-off-by: Roger Luethi <rl@hellgate.ch>

--- orig/drivers/net/via-rhine.c
+++ mod/drivers/net/via-rhine.c
@@ -475,7 +475,6 @@
 	CmdNoTxPoll=0x0800, CmdReset=0x8000,
 };
 
-#define MAX_MII_CNT	4
 struct rhine_private {
 	/* Descriptor rings */
 	struct rx_desc *rx_ring;
@@ -513,8 +512,6 @@
 	u8 tx_thresh, rx_thresh;
 
 	/* MII transceiver section. */
-	unsigned char phys[MAX_MII_CNT];	/* MII device addresses. */
-	unsigned int mii_cnt;		/* number of MIIs found, but only the first one is used */
 	u16 mii_status;			/* last read MII status */
 	struct mii_if_info mii_if;
 };
@@ -622,6 +619,7 @@
 
 /*
  * Loads bytes 0x00-0x05, 0x6E-0x6F, 0x78-0x7B from EEPROM
+ * (plus 0x6C for Rhine I/II)
  */
 static void __devinit rhine_reload_eeprom(long pioaddr, struct net_device *dev)
 {
@@ -680,8 +678,7 @@
 	long pioaddr;
 	long memaddr;
 	long ioaddr;
-	int io_size;
-	int phy, phy_idx = 0;
+	int io_size, phy_id;
 	const char *name;
 
 /* when built into the kernel, we only print version if device is found */
@@ -696,6 +693,7 @@
 	pci_read_config_byte(pdev, PCI_REVISION_ID, &pci_rev);
 
 	io_size = 256;
+	phy_id = 0;
 	if (pci_rev < VT6102) {
 		quirks = rqRhineI;
 		io_size = 128;
@@ -709,6 +707,7 @@
 		}
 		else {
 			name = "Rhine III";
+			phy_id = 1;	/* Integrated PHY, phy_id fixed to 1 */
 			if (pci_rev >= VT6105_B0)
 				quirks |= rq6patterns;
 		}
@@ -804,6 +803,10 @@
 		writeb(readb(ioaddr + ConfigD) & (0xF0 | backoff),
 		       ioaddr + ConfigD);
 
+	/* For Rhine I/II, phy_id is loaded from EEPROM */
+	if (!phy_id)
+		phy_id = readb(ioaddr + 0x6C);
+
 	dev->irq = pdev->irq;
 
 	spin_lock_init(&rp->lock);
@@ -867,17 +870,15 @@
 
 	pci_set_drvdata(pdev, dev);
 
-	rp->phys[0] = 1;		/* Standard for this chip. */
-	for (phy = 1; phy < 32 && phy_idx < MAX_MII_CNT; phy++) {
-		int mii_status = mdio_read(dev, phy, 1);
+	{
+		int mii_status = mdio_read(dev, phy_id, 1);
 		if (mii_status != 0xffff && mii_status != 0x0000) {
-			rp->phys[phy_idx++] = phy;
-			rp->mii_if.advertising = mdio_read(dev, phy, 4);
+			rp->mii_if.advertising = mdio_read(dev, phy_id, 4);
 			printk(KERN_INFO "%s: MII PHY found at address "
 			       "%d, status 0x%4.4x advertising %4.4x "
-			       "Link %4.4x.\n", dev->name, phy,
+			       "Link %4.4x.\n", dev->name, phy_id,
 			       mii_status, rp->mii_if.advertising,
-			       mdio_read(dev, phy, 5));
+			       mdio_read(dev, phy_id, 5));
 
 			/* set IFF_RUNNING */
 			if (mii_status & BMSR_LSTATUS)
@@ -885,11 +886,9 @@
 			else
 				netif_carrier_off(dev);
 
-			break;
 		}
 	}
-	rp->mii_cnt = phy_idx;
-	rp->mii_if.phy_id = rp->phys[0];
+	rp->mii_if.phy_id = phy_id;
 
 	/* Allow forcing the media type. */
 	if (option > 0) {
@@ -900,10 +899,9 @@
 				"operation.\n",
 			       (option & 0x300 ? 100 : 10),
 			       (option & 0x220 ? "full" : "half"));
-			if (rp->mii_cnt)
-				mdio_write(dev, rp->phys[0], MII_BMCR,
-					   ((option & 0x300) ? 0x2000 : 0) | /* 100mbps? */
-					   ((option & 0x220) ? 0x0100 : 0)); /* Full duplex? */
+			mdio_write(dev, phy_id, MII_BMCR,
+				   ((option & 0x300) ? 0x2000 : 0) | /* 100mbps? */
+				   ((option & 0x220) ? 0x0100 : 0)); /* Full duplex? */
 		}
 	}
 
@@ -1140,7 +1138,7 @@
 	long ioaddr = dev->base_addr;
 	int boguscnt = 1024;
 
-	if (phy_id == rp->phys[0]) {
+	if (phy_id == rp->mii_if.phy_id) {
 		switch (regnum) {
 		case MII_BMCR:		/* Is user forcing speed/duplex? */
 			if (value & 0x9000)	/* Autonegotiation. */
@@ -1191,7 +1189,7 @@
 		printk(KERN_DEBUG "%s: Done rhine_open(), status %4.4x "
 		       "MII status: %4.4x.\n",
 		       dev->name, readw(ioaddr + ChipCmd),
-		       mdio_read(dev, rp->phys[0], MII_BMSR));
+		       mdio_read(dev, rp->mii_if.phy_id, MII_BMSR));
 
 	netif_start_queue(dev);
 
@@ -1209,7 +1207,7 @@
 {
 	struct rhine_private *rp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
-	int mii_lpa = mdio_read(dev, rp->phys[0], MII_LPA);
+	int mii_lpa = mdio_read(dev, rp->mii_if.phy_id, MII_LPA);
 	int negotiated = mii_lpa & rp->mii_if.advertising;
 	int duplex;
 
@@ -1222,7 +1220,7 @@
 			printk(KERN_INFO "%s: Setting %s-duplex based on "
 			       "MII #%d link partner capability of %4.4x.\n",
 			       dev->name, duplex ? "full" : "half",
-			       rp->phys[0], mii_lpa);
+			       rp->mii_if.phy_id, mii_lpa);
 		if (duplex)
 			rp->chip_cmd |= CmdFDuplex;
 		else
@@ -1250,7 +1248,7 @@
 	rhine_check_duplex(dev);
 
 	/* make IFF_RUNNING follow the MII status bit "Link established" */
-	mii_status = mdio_read(dev, rp->phys[0], MII_BMSR);
+	mii_status = mdio_read(dev, rp->mii_if.phy_id, MII_BMSR);
 	if ((mii_status & BMSR_LSTATUS) != (rp->mii_status & BMSR_LSTATUS)) {
 		if (mii_status & BMSR_LSTATUS)
 			netif_carrier_on(dev);
@@ -1274,7 +1272,7 @@
 	printk(KERN_WARNING "%s: Transmit timed out, status %4.4x, PHY status "
 	       "%4.4x, resetting...\n",
 	       dev->name, readw(ioaddr + IntrStatus),
-	       mdio_read(dev, rp->phys[0], MII_BMSR));
+	       mdio_read(dev, rp->mii_if.phy_id, MII_BMSR));
 
 	/* protect against concurrent rx interrupts */
 	disable_irq(rp->pdev->irq);
@@ -1691,8 +1689,8 @@
 			printk(KERN_ERR "%s: MII status changed: "
 			       "Autonegotiation advertising %4.4x partner "
 			       "%4.4x.\n", dev->name,
-			       mdio_read(dev, rp->phys[0], MII_ADVERTISE),
-			       mdio_read(dev, rp->phys[0], MII_LPA));
+			       mdio_read(dev, rp->mii_if.phy_id, MII_ADVERTISE),
+			       mdio_read(dev, rp->mii_if.phy_id, MII_LPA));
 	}
 	if (intr_status & IntrStatsMax) {
 		rp->stats.rx_crc_errors += readw(ioaddr + RxCRCErrs);
