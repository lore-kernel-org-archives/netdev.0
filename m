From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH v3 net-next] net: ethernet: cadence-macb: Add disabled usrio caps
Date: Mon,  4 Jan 2016 10:01:43 +0100
Message-ID: <1451898103-21868-1-git-send-email-narmstrong@baylibre.com>
References: <1449582726-6148-1-git-send-email-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong@baylibre.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net,
	harini.katakam@xilinx.com, boris.brezillon@free-electrons.com,
	alexandre.belloni@free-electrons.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, joshc@ni.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449582726-6148-1-git-send-email-narmstrong@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On some platforms, the macb integration does not use the USRIO
register to configure the (R)MII port and clocks.
When the register is not implemented and the MACB error signal
is connected to the bus error, reading or writing to the USRIO
register can trigger some Imprecise External Aborts on ARM platforms.

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 drivers/net/ethernet/cadence/macb.c | 27 +++++++++++++++------------
 drivers/net/ethernet/cadence/macb.h |  1 +
 2 files changed, 16 insertions(+), 12 deletions(-)

Nicolas,
I post only the first patch of the previous set posted here :
http://lkml.kernel.org/r/1449582726-6148-1-git-send-email-narmstrong@baylibre.com
to hopefully make it into the 4.5 merge time,
I'll post the vendor prefix once this patch will hit mainline.

Regards,
Neil

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
