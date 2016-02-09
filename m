From: Sergio Prado <sergio.prado-1e4yhPs3/ABSwrhanM7KvQ@public.gmane.org>
Subject: [PATCH net-next] net: macb: add wake-on-lan support via magic packet
Date: Tue,  9 Feb 2016 12:07:16 -0200
Message-ID: <1455026836-12908-1-git-send-email-sergio.prado@e-labworks.com>
Cc: Sergio Prado <sergio.prado-1e4yhPs3/ABSwrhanM7KvQ@public.gmane.org>
To: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org,
	michal.simek-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org, harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org,
	boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Tested on Acqua A5 SoM (http://www.acmesystems.it/acqua).

Signed-off-by: Sergio Prado <sergio.prado-1e4yhPs3/ABSwrhanM7KvQ@public.gmane.org>
---
 Documentation/devicetree/bindings/net/macb.txt |  2 +
 drivers/net/ethernet/cadence/macb.c            | 67 +++++++++++++++++++++++---
 drivers/net/ethernet/cadence/macb.h            |  4 ++
 3 files changed, 67 insertions(+), 6 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
index d2e243b1ec0e..c6b1cb5ffa87 100644
--- a/Documentation/devicetree/bindings/net/macb.txt
+++ b/Documentation/devicetree/bindings/net/macb.txt
@@ -25,6 +25,8 @@ Required properties:
 
 Optional properties for PHY child node:
 - reset-gpios : Should specify the gpio for phy reset
+- cdns,magic-packet : If present, indicates that the hardware supports waking
+  up via magic packet.
 
 Examples:
 
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 50c94104f19c..69af049e55a8 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -58,6 +58,9 @@
 
 #define GEM_MTU_MIN_SIZE	68
 
+#define MACB_WOL_HAS_MAGIC_PACKET	(0x1 << 0)
+#define MACB_WOL_ENABLED		(0x1 << 1)
+
 /*
  * Graceful stop timeouts in us. We should allow up to
  * 1 frame time (10 Mbits/s, full-duplex, ignoring collisions)
@@ -2124,6 +2127,39 @@ static void macb_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 	}
 }
 
+static void macb_get_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
+{
+	struct macb *bp = netdev_priv(netdev);
+
+	wol->supported = 0;
+	wol->wolopts = 0;
+
+	if (bp->wol & MACB_WOL_HAS_MAGIC_PACKET) {
+		wol->supported = WAKE_MAGIC;
+
+		if (bp->wol & MACB_WOL_ENABLED)
+			wol->wolopts |= WAKE_MAGIC;
+	}
+}
+
+static int macb_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
+{
+	struct macb *bp = netdev_priv(netdev);
+
+	if (!(bp->wol & MACB_WOL_HAS_MAGIC_PACKET) ||
+	    (wol->wolopts & ~WAKE_MAGIC))
+		return -EOPNOTSUPP;
+
+	if (wol->wolopts & WAKE_MAGIC)
+		bp->wol |= MACB_WOL_ENABLED;
+	else
+		bp->wol &= ~MACB_WOL_ENABLED;
+
+	device_set_wakeup_enable(&bp->pdev->dev, bp->wol & MACB_WOL_ENABLED);
+
+	return 0;
+}
+
 static const struct ethtool_ops macb_ethtool_ops = {
 	.get_settings		= macb_get_settings,
 	.set_settings		= macb_set_settings,
@@ -2131,6 +2167,8 @@ static const struct ethtool_ops macb_ethtool_ops = {
 	.get_regs		= macb_get_regs,
 	.get_link		= ethtool_op_get_link,
 	.get_ts_info		= ethtool_op_get_ts_info,
+	.get_wol		= macb_get_wol,
+	.set_wol		= macb_set_wol,
 };
 
 static const struct ethtool_ops gem_ethtool_ops = {
@@ -2890,6 +2928,11 @@ static int macb_probe(struct platform_device *pdev)
 	if (macb_config)
 		bp->jumbo_max_len = macb_config->jumbo_max_len;
 
+	bp->wol = 0;
+	if (of_get_property(np, "cdns,magic-packet", NULL))
+		bp->wol |= MACB_WOL_HAS_MAGIC_PACKET;
+	device_init_wakeup(&pdev->dev, bp->wol & MACB_WOL_HAS_MAGIC_PACKET);
+
 	spin_lock_init(&bp->lock);
 
 	/* setup capabilities */
@@ -3006,9 +3049,15 @@ static int __maybe_unused macb_suspend(struct device *dev)
 	netif_carrier_off(netdev);
 	netif_device_detach(netdev);
 
-	clk_disable_unprepare(bp->tx_clk);
-	clk_disable_unprepare(bp->hclk);
-	clk_disable_unprepare(bp->pclk);
+	if (bp->wol & MACB_WOL_ENABLED) {
+		macb_writel(bp, IER, MACB_BIT(WOL));
+		macb_writel(bp, WOL, MACB_BIT(MAG));
+		enable_irq_wake(bp->queues[0].irq);
+	} else {
+		clk_disable_unprepare(bp->tx_clk);
+		clk_disable_unprepare(bp->hclk);
+		clk_disable_unprepare(bp->pclk);
+	}
 
 	return 0;
 }
@@ -3019,9 +3068,15 @@ static int __maybe_unused macb_resume(struct device *dev)
 	struct net_device *netdev = platform_get_drvdata(pdev);
 	struct macb *bp = netdev_priv(netdev);
 
-	clk_prepare_enable(bp->pclk);
-	clk_prepare_enable(bp->hclk);
-	clk_prepare_enable(bp->tx_clk);
+	if (bp->wol & MACB_WOL_ENABLED) {
+		macb_writel(bp, IDR, MACB_BIT(WOL));
+		macb_writel(bp, WOL, 0);
+		disable_irq_wake(bp->queues[0].irq);
+	} else {
+		clk_prepare_enable(bp->pclk);
+		clk_prepare_enable(bp->hclk);
+		clk_prepare_enable(bp->tx_clk);
+	}
 
 	netif_device_attach(netdev);
 
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 0d4ecfcd60b7..9ba416d5afff 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -312,6 +312,8 @@
 #define MACB_PFR_SIZE		1
 #define MACB_PTZ_OFFSET		13 /* Enable pause time zero interrupt */
 #define MACB_PTZ_SIZE		1
+#define MACB_WOL_OFFSET		14 /* Enable wake-on-lan interrupt */
+#define MACB_WOL_SIZE		1
 
 /* Bitfields in MAN */
 #define MACB_DATA_OFFSET	0 /* data */
@@ -842,6 +844,8 @@ struct macb {
 
 	unsigned int		rx_frm_len_mask;
 	unsigned int		jumbo_max_len;
+
+	u32			wol;
 };
 
 static inline bool macb_is_gem(struct macb *bp)
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
