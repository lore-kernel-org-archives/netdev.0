From: "Gary Zambrano" <zambrano@broadcom.com>
Subject: [PATCH 1/4] b44: add wol and setup for later 4401
Date: Wed, 24 May 2006 07:40:44 -0700
Message-ID: <1148481644.2976.51.camel@dhcp-10-7-81-7.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:50706 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S932764AbWEXVmh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 May 2006 17:42:37 -0400
To: "Jeff Garzik" <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch adds set and get functions and support for the later 4401 revs.

Signed-off-by: Gary Zambrano <zambrano@broadcom.com>

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 7b3dfc4..e42e0aa 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -75,6 +75,12 @@
 /* minimum number of free TX descriptors required to wake up TX process */
 #define B44_TX_WAKEUP_THRESH		(B44_TX_RING_SIZE / 4)

+/* b44 internal pattern match filter info */
+#define B44_WOL_PATTERN_BASE	0x400
+#define B44_WOL_PATTERN_SIZE	0x80
+#define B44_WOL_MASK_BASE	0x600
+#define B44_WOL_MASK_SIZE	0x10
+
 static char version[] __devinitdata =
 	DRV_MODULE_NAME ".c:v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";

@@ -1442,6 +1448,43 @@ static void b44_poll_controller(struct n
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
+		bw32 (bp, B44_WKUP_LEN, WKUP_LEN_DISABLE);
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
+	} else {
+		b44_setup_pseudo_magicp(bp);
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
@@ -1467,6 +1510,11 @@ static int b44_close(struct net_device *

 	netif_poll_enable(dev);

+	if (bp->flags & B44_FLAG_WOL_ENABLE){
+		b44_init_hw(bp);
+		b44_setup_wol(bp);
+	}
+
 	b44_free_consistent(bp);

 	return 0;
@@ -1810,12 +1858,38 @@ static void b44_get_ethtool_stats(struct
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
+	if (wol->wolopts & WAKE_MAGIC)
+		bp->flags |= B44_FLAG_WOL_ENABLE;
+	else
+		bp->flags &= ~B44_FLAG_WOL_ENABLE;
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
@@ -1894,6 +1968,10 @@ static int __devinit b44_get_invariants(
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
diff --git a/drivers/net/b44.h b/drivers/net/b44.h
index b178662..18baa19 100644
--- a/drivers/net/b44.h
+++ b/drivers/net/b44.h
@@ -24,6 +24,8 @@
 #define  WKUP_LEN_P3_MASK	0x7f000000 /* Pattern 3 */
 #define  WKUP_LEN_P3_SHIFT	24
 #define  WKUP_LEN_D3		0x80000000
+#define  WKUP_LEN_DISABLE	0x80808080
+#define  WKUP_LEN_ENABLE_TWO	0x80800000
 #define B44_ISTAT	0x0020UL /* Interrupt Status */
 #define  ISTAT_LS		0x00000020 /* Link Change (B0 only) */
 #define  ISTAT_PME		0x00000040 /* Power Management Event */
@@ -264,6 +266,8 @@
 #define  SBIDHIGH_VC_SHIFT	16

 /* SSB PCI config space registers.  */
+#define SSB_PMCSR		0x44
+#define  SSB_PE			0x100
 #define	SSB_BAR0_WIN		0x80
 #define	SSB_BAR1_WIN		0x84
 #define	SSB_SPROM_CONTROL	0x88
@@ -420,6 +424,7 @@ struct b44 {

 	u32			dma_offset;
 	u32			flags;
+#define B44_FLAG_B0_ANDLATER	0x00000001
 #define B44_FLAG_BUGGY_TXPTR	0x00000002
 #define B44_FLAG_REORDER_BUG	0x00000004
 #define B44_FLAG_PAUSE_AUTO	0x00008000
@@ -435,6 +440,7 @@ struct b44 {
 #define B44_FLAG_INTERNAL_PHY	0x10000000
 #define B44_FLAG_RX_RING_HACK	0x20000000
 #define B44_FLAG_TX_RING_HACK	0x40000000
+#define B44_FLAG_WOL_ENABLE	0x80000000

 	u32			rx_offset;


