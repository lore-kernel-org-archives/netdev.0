From: Roger Luethi <rl@hellgate.ch>
Subject: [9/9][PATCH 2.6] Add WOL support
Date: Tue, 15 Jun 2004 19:50:03 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040615175003.GA11382@k3.hellgate.ch>
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

Add rhine_shutdown callback to prepare Rhine power registers for
shutdown.

Add rhine_get_wol/rhine_set_wol for ethtool ioctl.

Signed-off-by: Roger Luethi <rl@hellgate.ch>

--- 2.6-mm/drivers/net/via-rhine.c.orig	2004-06-15 18:34:21.000000000 +0200
+++ 2.6-mm/drivers/net/via-rhine.c	2004-06-15 18:36:12.000000000 +0200
@@ -394,8 +394,8 @@
 	ConfigA=0x78, ConfigB=0x79, ConfigC=0x7A, ConfigD=0x7B,
 	RxMissed=0x7C, RxCRCErrs=0x7E, MiscCmd=0x81,
 	StickyHW=0x83, IntrStatus2=0x84,
-	WOLcrSet=0xA0, WOLcrClr=0xA4, WOLcrClr1=0xA6,
-	WOLcgClr=0xA7,
+	WOLcrSet=0xA0, PwcfgSet=0xA1, WOLcgSet=0xA3, WOLcrClr=0xA4,
+	WOLcrClr1=0xA6, WOLcgClr=0xA7,
 	PwrcsrSet=0xA8, PwrcsrSet1=0xA9, PwrcsrClr=0xAC, PwrcsrClr1=0xAD,
 };
 
@@ -427,6 +427,15 @@
 	IntrTxErrSummary=0x082218,
 };
 
+/* Bits in WOLcrSet/WOLcrClr and PwrcsrSet/PwrcsrClr */
+enum wol_bits {
+	WOLucast	= 0x10,
+	WOLmagic	= 0x20,
+	WOLbmcast	= 0x30,
+	WOLlnkon	= 0x40,
+	WOLlnkoff	= 0x80,
+};
+
 /* The Rx and Tx buffer descriptors. */
 struct rx_desc {
 	s32 rx_status;
@@ -491,8 +500,8 @@
 	unsigned int cur_rx, dirty_rx;	/* Producer/consumer ring indices */
 	unsigned int cur_tx, dirty_tx;
 	unsigned int rx_buf_sz;		/* Based on MTU+slack. */
+	u8 wolopts;
 
-	/* These values are keep track of the transceiver/media in use. */
 	u8 tx_thresh, rx_thresh;
 
 	struct mii_if_info mii_if;
@@ -512,6 +521,7 @@
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static struct ethtool_ops netdev_ethtool_ops;
 static int  rhine_close(struct net_device *dev);
+static void rhine_shutdown (struct device *gdev);
 
 #define RHINE_WAIT_FOR(condition) do {					\
 	int i=1024;							\
@@ -537,12 +547,13 @@
 
 /*
  * Get power related registers into sane state.
- * Returns content of power-event (WOL) registers.
+ * Notify user about past WOL event.
  */
 static void rhine_power_init(struct net_device *dev)
 {
 	long ioaddr = dev->base_addr;
 	struct rhine_private *rp = netdev_priv(dev);
+	u16 wolstat;
 
 	if (rp->quirks & rqWOL) {
 		/* Make sure chip is in power state D0 */
@@ -557,10 +568,40 @@
 		if (rp->quirks & rq6patterns)
 			writeb(0x03, ioaddr + WOLcrClr1);
 
+		/* Save power-event status bits */
+		wolstat = readb(ioaddr + PwrcsrSet);
+		if (rp->quirks & rq6patterns)
+			wolstat |= (readb(ioaddr + PwrcsrSet1) & 0x03) << 8;
+
 		/* Clear power-event status bits */
 		writeb(0xFF, ioaddr + PwrcsrClr);
 		if (rp->quirks & rq6patterns)
 			writeb(0x03, ioaddr + PwrcsrClr1);
+
+		if (wolstat) {
+			char *reason;
+			switch (wolstat) {
+			case WOLmagic:
+				reason = "Magic packet";
+				break;
+			case WOLlnkon:
+				reason = "Link went up";
+				break;
+			case WOLlnkoff:
+				reason = "Link went down";
+				break;
+			case WOLucast:
+				reason = "Unicast packet";
+				break;
+			case WOLbmcast:
+				reason = "Multicast/broadcast packet";
+				break;
+			default:
+				reason = "Unknown";
+			}
+			printk("%s: Woke system up. Reason: %s.\n",
+			       DRV_NAME, reason);
+		}
 	}
 }
 
@@ -1766,6 +1807,39 @@
 	debug = value;
 }
 
+static void rhine_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct rhine_private *rp = netdev_priv(dev);
+
+	if (!(rp->quirks & rqWOL))
+		return;
+
+	spin_lock_irq(&rp->lock);
+	wol->supported = WAKE_PHY | WAKE_MAGIC |
+			 WAKE_UCAST | WAKE_MCAST | WAKE_BCAST;	/* Untested */
+	wol->wolopts = rp->wolopts;
+	spin_unlock_irq(&rp->lock);
+}
+
+static int rhine_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct rhine_private *rp = netdev_priv(dev);
+	u32 support = WAKE_PHY | WAKE_MAGIC |
+		      WAKE_UCAST | WAKE_MCAST | WAKE_BCAST;	/* Untested */
+
+	if (!(rp->quirks & rqWOL))
+		return -EINVAL;
+
+	if (wol->wolopts & ~support)
+		return -EINVAL;
+
+	spin_lock_irq(&rp->lock);
+	rp->wolopts = wol->wolopts;
+	spin_unlock_irq(&rp->lock);
+
+	return 0;
+}
+
 static struct ethtool_ops netdev_ethtool_ops = {
 	.get_drvinfo		= netdev_get_drvinfo,
 	.get_settings		= netdev_get_settings,
@@ -1774,6 +1848,8 @@
 	.get_link		= netdev_get_link,
 	.get_msglevel		= netdev_get_msglevel,
 	.set_msglevel		= netdev_set_msglevel,
+	.get_wol		= rhine_get_wol,
+	.set_wol		= rhine_set_wol,
 	.get_sg			= ethtool_op_get_sg,
 	.get_tx_csum		= ethtool_op_get_tx_csum,
 };
@@ -1844,12 +1920,51 @@
 	pci_set_drvdata(pdev, NULL);
 }
 
+static void rhine_shutdown (struct device *gendev)
+{
+	struct pci_dev *pdev = to_pci_dev(gendev);
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct rhine_private *rp = netdev_priv(dev);
+
+	long ioaddr = dev->base_addr;
+
+	rhine_power_init(dev);
+
+	/* Make sure we use pattern 0, 1 and not 4, 5 */
+	if (rp->quirks & rq6patterns)
+		writeb(0x04, ioaddr + 0xA7);
+
+	if (rp->wolopts & WAKE_MAGIC)
+		writeb(WOLmagic, ioaddr + WOLcrSet);
+
+	if (rp->wolopts & (WAKE_BCAST|WAKE_MCAST))
+		writeb(WOLbmcast, ioaddr + WOLcgSet);
+
+	if (rp->wolopts & WAKE_PHY)
+		writeb(WOLlnkon | WOLlnkoff, ioaddr + WOLcrSet);
+
+	if (rp->wolopts & WAKE_UCAST)
+		writeb(WOLucast, ioaddr + WOLcrSet);
+
+	/* Enable legacy WOL (for old motherboards) */
+	writeb(0x01, ioaddr + PwcfgSet);
+	writeb(readb(ioaddr + StickyHW) | 0x04, ioaddr + StickyHW);
+
+	/* Hit power state D3 (sleep) */
+	writeb(readb(ioaddr + StickyHW) | 0x03, ioaddr + StickyHW);
+
+	/* TODO: Check use of pci_enable_wake() */
+
+}
 
 static struct pci_driver rhine_driver = {
 	.name		= DRV_NAME,
 	.id_table	= rhine_pci_tbl,
 	.probe		= rhine_init_one,
 	.remove		= __devexit_p(rhine_remove_one),
+	.driver = {
+		.shutdown = rhine_shutdown,
+	}
 };
