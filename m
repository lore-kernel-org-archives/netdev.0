From: Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v4 net-next 1/3] net: ethernet: cadence-macb: Add disabled usrio caps
Date: Mon,  4 Jan 2016 10:42:51 +0100
Message-ID: <1451900573-22657-2-git-send-email-narmstrong@baylibre.com>
References: <1451898103-21868-1-git-send-email-narmstrong@baylibre.com>
 <1451900573-22657-1-git-send-email-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
To: nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org, boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
	alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, joshc-acOepvfBmUk@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1451900573-22657-1-git-send-email-narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On some platforms, the macb integration does not use the USRIO
register to configure the (R)MII port and clocks.
When the register is not implemented and the MACB error signal
is connected to the bus error, reading or writing to the USRIO
register can trigger some Imprecise External Aborts on ARM platforms.

Signed-off-by: Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/cadence/macb.c | 27 +++++++++++++++------------
 drivers/net/ethernet/cadence/macb.h |  1 +
 2 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 8b45bc9..fa53bc3 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2124,7 +2124,8 @@ static void macb_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 	regs_buff[10] = macb_tx_dma(&bp->queues[0], tail);
 	regs_buff[11] = macb_tx_dma(&bp->queues[0], head);
 
-	regs_buff[12] = macb_or_gem_readl(bp, USRIO);
+	if (!(bp->caps & MACB_CAPS_USRIO_DISABLED))
+		regs_buff[12] = macb_or_gem_readl(bp, USRIO);
 	if (macb_is_gem(bp)) {
 		regs_buff[13] = gem_readl(bp, DMACFG);
 	}
@@ -2403,19 +2404,21 @@ static int macb_init(struct platform_device *pdev)
 		dev->hw_features &= ~NETIF_F_SG;
 	dev->features = dev->hw_features;
 
-	val = 0;
-	if (bp->phy_interface == PHY_INTERFACE_MODE_RGMII)
-		val = GEM_BIT(RGMII);
-	else if (bp->phy_interface == PHY_INTERFACE_MODE_RMII &&
-		 (bp->caps & MACB_CAPS_USRIO_DEFAULT_IS_MII))
-		val = MACB_BIT(RMII);
-	else if (!(bp->caps & MACB_CAPS_USRIO_DEFAULT_IS_MII))
-		val = MACB_BIT(MII);
+	if (!(bp->caps & MACB_CAPS_USRIO_DISABLED)) {
+		val = 0;
+		if (bp->phy_interface == PHY_INTERFACE_MODE_RGMII)
+			val = GEM_BIT(RGMII);
+		else if (bp->phy_interface == PHY_INTERFACE_MODE_RMII &&
+			 (bp->caps & MACB_CAPS_USRIO_DEFAULT_IS_MII))
+			val = MACB_BIT(RMII);
+		else if (!(bp->caps & MACB_CAPS_USRIO_DEFAULT_IS_MII))
+			val = MACB_BIT(MII);
 
-	if (bp->caps & MACB_CAPS_USRIO_HAS_CLKEN)
-		val |= MACB_BIT(CLKEN);
+		if (bp->caps & MACB_CAPS_USRIO_HAS_CLKEN)
+			val |= MACB_BIT(CLKEN);
 
-	macb_or_gem_writel(bp, USRIO, val);
+		macb_or_gem_writel(bp, USRIO, val);
+	}
 
 	/* Set MII management clock divider */
 	val = macb_mdc_clk_div(bp);
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 5c03e81..0d4ecfc 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -400,6 +400,7 @@
 #define MACB_CAPS_USRIO_HAS_CLKEN		0x00000002
 #define MACB_CAPS_USRIO_DEFAULT_IS_MII		0x00000004
 #define MACB_CAPS_NO_GIGABIT_HALF		0x00000008
+#define MACB_CAPS_USRIO_DISABLED		0x00000010
 #define MACB_CAPS_FIFO_MODE			0x10000000
 #define MACB_CAPS_GIGABIT_MODE_AVAILABLE	0x20000000
 #define MACB_CAPS_SG_DISABLED			0x40000000
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
