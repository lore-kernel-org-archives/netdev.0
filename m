From: Andreas Mohr <andi@lisas.de>
Subject: [PATCH RFC 13/15] via-rhine: misc. cleanup.
Date: Mon, 31 Dec 2012 16:25:47 +0100
Message-ID: <1356967549-5056-14-git-send-email-andi@lisas.de>
References: <1356967549-5056-1-git-send-email-andi@lisas.de>
Cc: Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: andim2@users.sf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:54145 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751367Ab2LaPep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2012 10:34:45 -0500
In-Reply-To: <1356967549-5056-1-git-send-email-andi@lisas.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Mohr <andim2@users.sf.net>

Several register values remained open-coded - use their defines instead.
Improve register define grouping.
Improve log messages.
Add comments.

Signed-off-by: Andreas Mohr <andim2@users.sf.net>
---
 drivers/net/ethernet/via/via-rhine.c |   92 ++++++++++++++++++++++++++++------
 1 files changed, 76 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 90d109a..984f056 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -27,6 +27,34 @@
 	http://www.scyld.com/network/via-rhine.html
 	[link no longer provides useful info -jgarzik]
 
+
+	This driver should get some whack: several handlers
+	seem to have their concerns intermingled. Rather,
+	functions should be grouped into generically usable micro handlers
+	(I/O access concerns, WOL handling, MII, etc. - with card specifics
+	properly dealt with via suitable *internal* abstraction as needed)
+	which are then being invoked by *specifically-purposed*
+	high-level, system-side operational handlers
+	on an as-needed-in-this-scope basis.
+	But that's a very painful issue with too many drivers, unfortunately.
+	Some rather unrelated handling within a function may easily end up
+	becoming an unwanted "side effect" once other use cases appear,
+	with rather unclear grouping of concerns being the root cause :(
+	Or, to put it bluntly: you're in the wild here - an uncontrollable mass
+	of unwashed developers hacking away at things
+	(and breaking things willy-nilly whenever getting confused
+	about intentions of original implementation!!),
+	with the only marginal chance of getting this avoided being
+	to better get your core implementation, layering
+	and especially component naming right (well, DAMN RIGHT).
+
+	TODO: one example would be clean encapsulation of I/O register access -
+	such helper functions would optionally allow keeping a watch on access
+	to extended registers unsupported by earlier revs.
+
+	TODO list:
+		(see TODO annotations at future work sites below
+		 [more hunk-friendly])
 */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
@@ -299,18 +327,23 @@ enum register_offsets {
 	MIIPhyAddr=0x6C, MIIStatus=0x6D, PCIBusConfig=0x6E, PCIBusConfig1=0x6F,
 	MIICmd=0x70, MIIRegAddr=0x71, MIIData=0x72, MACRegEEcsr=0x74,
 	ConfigA=0x78, ConfigB=0x79, ConfigC=0x7A, ConfigD=0x7B,
-	RxMissed=0x7C, RxCRCErrs=0x7E, MiscCmd=0x81,
+	RxMissed = 0x7C, RxCRCErrs = 0x7E,
+	/*** Extended register range (newer revs only) starts here ***/
+	MiscCmd = 0x81,
 	StickyHW=0x83, IntrStatus2=0x84,
-	CamMask=0x88, CamCon=0x92, CamAddr=0x93,
-	WOLcrSet=0xA0, PwcfgSet=0xA1, WOLcgSet=0xA3, WOLcrClr=0xA4,
-	WOLcrClr1=0xA6, WOLcgClr=0xA7,
-	PwrcsrSet=0xA8, PwrcsrSet1=0xA9, PwrcsrClr=0xAC, PwrcsrClr1=0xAD,
+	CamMask = 0x88, CamCon = 0x92, CamAddr = 0x93,
+	/* various flag set/clear registers */
+	WOLcrSet = 0xA0, PwcfgSet = 0xA1, WOLcgSet = 0xA3,
+	WOLcrClr = 0xA4, WOLcrClr1 = 0xA6, WOLcgClr = 0xA7,
+	PwrcsrSet = 0xA8, PwrcsrSet1 = 0xA9,
+	PwrcsrClr = 0xAC, PwrcsrClr1 = 0xAD,
 };
 
 /* Bits in ConfigD */
 enum backoff_bits {
-	BackOptional=0x01, BackModify=0x02,
-	BackCaptureEffect=0x04, BackRandom=0x08
+	BackOptional = 0x01, BackModify = 0x02,
+	BackCaptureEffect = 0x04, BackRandom = 0x08,
+	MMIOEnable = 0x80
 };
 
 /* Bits in the TxConfig (TCR) register */
@@ -688,7 +721,7 @@ static void enable_mmio(long pioaddr, u32 quirks)
 		n = inb(pioaddr + ConfigA) | 0x20;
 		outb(n, pioaddr + ConfigA);
 	} else {
-		n = inb(pioaddr + ConfigD) | 0x80;
+		n = inb(pioaddr + ConfigD) | MMIOEnable;
 		outb(n, pioaddr + ConfigD);
 	}
 }
@@ -759,6 +792,18 @@ static void rhine_poll(struct net_device *dev)
 	struct rhine_private *rp = netdev_priv(dev);
 	const int irq = rp->pdev->irq;
 
+	/*
+	 * TODO: this "weird" section (passes in a "fake" irq number
+	 * param, etc.) here looks like some functionality inversion
+	 * is in order (i.e., probably the non-irq related IRQ handler core
+	 * should be moved into helper function, which then is the one
+	 * to *cleanly* be called from here, too!)
+	 * OTOH maybe it's a specific requirement to disable IRQ
+	 * and then do call the real handler impl instead -
+	 * but then a comment should have been provided,
+	 * to explain specifics of why we're manually calling
+	 * into the actual interrupt handler...
+	 */
 	disable_irq(irq);
 	rhine_interrupt(irq, dev);
 	enable_irq(irq);
@@ -771,7 +816,7 @@ static void rhine_kick_tx_threshold(struct rhine_private *rp)
 		void __iomem *ioaddr = rp->base;
 
 		rp->tx_thresh += 0x20;
-		BYTE_REG_BITS_SET(rp->tx_thresh, 0x80, ioaddr + TxConfig);
+		BYTE_REG_BITS_SET(rp->tx_thresh, TCR_RTSF, ioaddr + TxConfig);
 	}
 }
 
@@ -1044,6 +1089,7 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	rhine_power_init(dev);
 	rhine_hw_init(dev, rp->pioaddr);
 
+	/* Do bootstrap-only init steps (initial dev_addr, phy_id) */
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = ioread8(ioaddr + StationAddr + i);
 
@@ -1058,7 +1104,7 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* For Rhine-I/II, phy_id is loaded from EEPROM */
 	if (!phy_id)
-		phy_id = ioread8(ioaddr + 0x6C);
+		phy_id = ioread8(ioaddr + MIIPhyAddr);
 
 	spin_lock_init(&rp->lock);
 	mutex_init(&rp->task_lock);
@@ -1097,6 +1143,10 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	pci_set_drvdata(pdev, dev);
 
+	/* FIXME!! I really *don't* think that this stuff has any business
+	 * being open-coded in probe() rather than being a helper possibly
+	 * called from multiple sites (resume, etc.) - netif_carrier_on()!!
+	 */
 	{
 		u16 mii_cmd;
 		int mii_status = mdio_read(dev, phy_id, 1);
@@ -1119,8 +1169,10 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		}
 	}
 	rp->mii_if.phy_id = phy_id;
+
+	/* Use this occasion to announce avoid_D3 state, too. */
 	if (avoid_D3)
-		netif_info(rp, probe, dev, "No D3 power state at shutdown\n");
+		netif_info(rp, probe, dev, "Will avoid entering D3 power state at shutdown\n");
 
 	return 0;
 
@@ -1499,8 +1551,10 @@ static void init_registers(struct net_device *dev)
 
 	/* Initialize other registers. */
 	iowrite16(0x0006, ioaddr + PCIBusConfig);	/* Tune configuration??? */
+	/* Seems that it's DMA Length reg (select "store & forward" option). */
+
 	/* Configure initial FIFO thresholds. */
-	iowrite8(0x20, ioaddr + TxConfig);
+	iowrite8(TCR_RTFT0, ioaddr + TxConfig);
 	rp->tx_thresh = 0x20;
 	rp->rx_thresh = 0x60;		/* Written in rhine_set_rx_mode(). */
 
@@ -1543,7 +1597,7 @@ static void rhine_disable_linkmon(struct rhine_private *rp)
 	iowrite8(0, ioaddr + MIICmd);
 
 	if (rp->quirks & rqRhineI) {
-		iowrite8(0x01, ioaddr + MIIRegAddr);	// MII_BMSR
+		iowrite8(MII_BMSR, ioaddr + MIIRegAddr);
 
 		/* Can be called from ISR. Evil. */
 		mdelay(1);
@@ -2316,11 +2370,11 @@ static int rhine_close(struct net_device *dev)
 	napi_disable(&rp->napi);
 	netif_stop_queue(dev);
 
-	netif_dbg(rp, ifdown, dev, "Shutting down ethercard, status was %04x\n",
-		  ioread16(ioaddr + ChipCmd));
+	netif_dbg(rp, ifdown, dev, "%s() Shutting down ethercard, status was %04x\n",
+		  __func__, ioread16(ioaddr + ChipCmd));
 
 	/* Switch to loopback mode to avoid hardware races. */
-	iowrite8(rp->tx_thresh | 0x02, ioaddr + TxConfig);
+	iowrite8(rp->tx_thresh | TCR_LB0, ioaddr + TxConfig);
 
 	rhine_irq_disable(rp);
 
@@ -2369,6 +2423,11 @@ rhine_shutdown_and_keep_wol(struct pci_dev *pdev)
 
 	spin_lock(&rp->lock);
 
+	/*
+	 * We are able to poke single bits in sequence
+	 * (due to registers being organised as a set/clear combo).
+	 */
+
 	if (rp->wolopts & WAKE_MAGIC) {
 		iowrite8(WOLmagic, ioaddr + WOLcrSet);
 		/*
@@ -2404,6 +2463,7 @@ rhine_shutdown_and_keep_wol(struct pci_dev *pdev)
 }
 
 #ifdef CONFIG_PM_SLEEP
+/* TODO: implement full runtime pm, e.g. as done by r8169.c */
 static int rhine_suspend(struct device *device)
 {
 	struct pci_dev *pdev = to_pci_dev(device);
-- 
1.7.2.5
