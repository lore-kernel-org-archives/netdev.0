From: "Gary Zambrano" <zambrano@broadcom.com>
Subject: [PATCH 2/6] b44: add wol
Date: Fri, 16 Jun 2006 12:19:16 -0700
Message-ID: <1150485556.8716.51.camel@dhcp-10-7-81-7.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:23570 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1750784AbWFPTTj
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jun 2006 15:19:39 -0400
To: "Jeff Garzik" <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adds wol to the driver.
This is a redo of a previous patch thanks to feedback from Francois Romieu.

Signed-off-by Gary Zambrano <zambrano@broadcom.com>

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 41b1618..81f434e 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -1450,6 +1450,41 @@ static void b44_poll_controller(struct n
 }
 #endif

+
+static void b44_setup_wol(struct b44 *bp)
+{
+	u32 val;
+	u16 pmval;
+
+	bw32(bp, B44_RXCONFIG, RXCONFIG_ALLMULTI);
+
+	if (bp->flags & B44_FLAG_B0_ANDLATER) {
+
+		bw32(bp, B44_WKUP_LEN, WKUP_LEN_DISABLE);
+
+		val = bp->dev->dev_addr[2] << 24 |
+			bp->dev->dev_addr[3] << 16 |
+			bp->dev->dev_addr[4] << 8 |
+			bp->dev->dev_addr[5];
+		bw32(bp, B44_ADDR_LO, val);
+
+		val = bp->dev->dev_addr[0] << 8 |
+			bp->dev->dev_addr[1];
+		bw32(bp, B44_ADDR_HI, val);
+
+		val = br32(bp, B44_DEVCTRL);
+		bw32(bp, B44_DEVCTRL, val | DEVCTRL_MPM | DEVCTRL_PFE);
+
+	}
+
+	val = br32(bp, B44_SBTMSLOW);
+	bw32(bp, B44_SBTMSLOW, val | SBTMSLOW_PE);
+
+	pci_read_config_word(bp->pdev, SSB_PMCSR, &pmval);
+	pci_write_config_word(bp->pdev, SSB_PMCSR, pmval | SSB_PE);
+
+}
+
 static int b44_close(struct net_device *dev)
 {
 	struct b44 *bp = netdev_priv(dev);
@@ -1475,6 +1510,11 @@ static int b44_close(struct net_device *

 	netif_poll_enable(dev);

+	if (bp->flags & B44_FLAG_WOL_ENABLE) {
+		b44_init_hw(bp);
+		b44_setup_wol(bp);
+	}
+
 	b44_free_consistent(bp);

 	return 0;
@@ -1831,12 +1871,40 @@ static void b44_get_ethtool_stats(struct
 	spin_unlock_irq(&bp->lock);
 }

+static void b44_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct b44 *bp = netdev_priv(dev);
+
+	wol->supported = WAKE_MAGIC;
+	if (bp->flags & B44_FLAG_WOL_ENABLE)
+		wol->wolopts = WAKE_MAGIC;
+	else
+		wol->wolopts = 0;
+	memset(&wol->sopass, 0, sizeof(wol->sopass));
+}
+
+static int b44_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct b44 *bp = netdev_priv(dev);
+
+	spin_lock_irq(&bp->lock);
+	if (wol->wolopts & WAKE_MAGIC)
+		bp->flags |= B44_FLAG_WOL_ENABLE;
+	else
+		bp->flags &= ~B44_FLAG_WOL_ENABLE;
+	spin_unlock_irq(&bp->lock);
+
+	return 0;
+}
+
 static struct ethtool_ops b44_ethtool_ops = {
 	.get_drvinfo		= b44_get_drvinfo,
 	.get_settings		= b44_get_settings,
 	.set_settings		= b44_set_settings,
 	.nway_reset		= b44_nway_reset,
 	.get_link		= ethtool_op_get_link,
+	.get_wol		= b44_get_wol,
+	.set_wol		= b44_set_wol,
 	.get_ringparam		= b44_get_ringparam,
 	.set_ringparam		= b44_set_ringparam,
 	.get_pauseparam		= b44_get_pauseparam,
@@ -1915,6 +1983,10 @@ static int __devinit b44_get_invariants(
 	/* XXX - really required?
 	   bp->flags |= B44_FLAG_BUGGY_TXPTR;
          */
+
+ 	if (ssb_get_core_rev(bp) >= 7)
+ 		bp->flags |= B44_FLAG_B0_ANDLATER;
+
 out:
 	return err;
 }
@@ -2115,6 +2187,10 @@ static int b44_suspend(struct pci_dev *p
 	spin_unlock_irq(&bp->lock);

 	free_irq(dev->irq, dev);
+	if (bp->flags & B44_FLAG_WOL_ENABLE) {
+		b44_init_hw(bp);
+		b44_setup_wol(bp);
+	}
 	pci_disable_device(pdev);
 	return 0;
 }
diff --git a/drivers/net/b44.h b/drivers/net/b44.h
index b178662..1f47777 100644
--- a/drivers/net/b44.h
+++ b/drivers/net/b44.h
@@ -264,6 +264,8 @@
 #define  SBIDHIGH_VC_SHIFT	16

 /* SSB PCI config space registers.  */
+#define SSB_PMCSR		0x44
+#define  SSB_PE			0x100
 #define	SSB_BAR0_WIN		0x80
 #define	SSB_BAR1_WIN		0x84
 #define	SSB_SPROM_CONTROL	0x88
@@ -420,6 +422,7 @@ struct b44 {

 	u32			dma_offset;
 	u32			flags;
+#define B44_FLAG_B0_ANDLATER	0x00000001
 #define B44_FLAG_BUGGY_TXPTR	0x00000002
 #define B44_FLAG_REORDER_BUG	0x00000004
 #define B44_FLAG_PAUSE_AUTO	0x00008000
@@ -435,6 +438,7 @@ struct b44 {
 #define B44_FLAG_INTERNAL_PHY	0x10000000
 #define B44_FLAG_RX_RING_HACK	0x20000000
 #define B44_FLAG_TX_RING_HACK	0x40000000
+#define B44_FLAG_WOL_ENABLE	0x80000000

 	u32			rx_offset;


