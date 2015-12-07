From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH net 1/2] net: cadence: macb: Disable USRIO register on some platforms
Date: Mon,  7 Dec 2015 11:58:33 +0100
Message-ID: <1449485914-12883-2-git-send-email-narmstrong@baylibre.com>
References: <1449485914-12883-1-git-send-email-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong@baylibre.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Harini Katakam <harini.katakam@xilinx.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:36956 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755578AbbLGK7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 05:59:01 -0500
Received: by wmww144 with SMTP id w144so144889754wmw.0
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2015 02:58:58 -0800 (PST)
In-Reply-To: <1449485914-12883-1-git-send-email-narmstrong@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On some platforms, the macb integration does not use the USRIO
register to configure the (R)MII port and clocks.
When the register is not implemented and the MACB error signal
is connected to the bus error, reading or writing to the USRIO
register can trigger some Imprecise External Aborts on ARM platforms.
---
 drivers/net/ethernet/cadence/macb.c | 29 +++++++++++++++++------------
 1 file changed, 17 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 169059c..3897620 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2122,7 +2122,9 @@ static void macb_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 	regs_buff[10] = macb_tx_dma(&bp->queues[0], tail);
 	regs_buff[11] = macb_tx_dma(&bp->queues[0], head);
 
-	regs_buff[12] = macb_or_gem_readl(bp, USRIO);
+	if (!of_property_read_bool(bp->pdev->dev.of_node, "no-usrio")) {
+		regs_buff[12] = macb_or_gem_readl(bp, USRIO);
+	}
 	if (macb_is_gem(bp)) {
 		regs_buff[13] = gem_readl(bp, DMACFG);
 	}
@@ -2401,19 +2403,22 @@ static int macb_init(struct platform_device *pdev)
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
+	/* Some platform do not implement the USRIO register */
+	if (!of_property_read_bool(pdev->dev.of_node, "no-usrio")) {
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
-- 
1.9.1
