From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH] net: macb: fix default configuration for GMAC on AT91
Date: Thu, 10 Mar 2016 16:44:32 +0100
Message-ID: <1457624672-30666-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	<romain.henriet@l-acoustics.com>, <michal.simek@xilinx.com>,
	<punnaia@xilinx.com>, Nicolas Ferre <nicolas.ferre@atmel.com>
To: <linux-arm-kernel@lists.infradead.org>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On AT91 SoCs, the User Register (USRIO) exposes a switch to configure the
"Reduced" or "Traditional" version of the Media Independent Interface
(RMII vs. MII or RGMII vs. GMII).
As on the older EMAC version, on GMAC, this switch is set by default to the
non-reduced type of interface, so use the existing capability and extend it to
GMII as well. We then keep the current logic in the macb_init() function.

The capabilities of sama5d2, sama5d4 and sama5d3 GEM interface are updated in
the macb_config structure to be able to properly enable them with a traditional
interface (GMII or MII).

Reported-by: Romain HENRIET <romain.henriet@l-acoustics.com>
Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c | 13 +++++++------
 drivers/net/ethernet/cadence/macb.h |  2 +-
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 7ccf2298a5fa..3ce6095ced3d 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2440,9 +2440,9 @@ static int macb_init(struct platform_device *pdev)
 		if (bp->phy_interface == PHY_INTERFACE_MODE_RGMII)
 			val = GEM_BIT(RGMII);
 		else if (bp->phy_interface == PHY_INTERFACE_MODE_RMII &&
-			 (bp->caps & MACB_CAPS_USRIO_DEFAULT_IS_MII))
+			 (bp->caps & MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII))
 			val = MACB_BIT(RMII);
-		else if (!(bp->caps & MACB_CAPS_USRIO_DEFAULT_IS_MII))
+		else if (!(bp->caps & MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII))
 			val = MACB_BIT(MII);
 
 		if (bp->caps & MACB_CAPS_USRIO_HAS_CLKEN)
@@ -2774,7 +2774,7 @@ static int at91ether_init(struct platform_device *pdev)
 }
 
 static const struct macb_config at91sam9260_config = {
-	.caps = MACB_CAPS_USRIO_HAS_CLKEN | MACB_CAPS_USRIO_DEFAULT_IS_MII,
+	.caps = MACB_CAPS_USRIO_HAS_CLKEN | MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII,
 	.clk_init = macb_clk_init,
 	.init = macb_init,
 };
@@ -2787,21 +2787,22 @@ static const struct macb_config pc302gem_config = {
 };
 
 static const struct macb_config sama5d2_config = {
-	.caps = 0,
+	.caps = MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII,
 	.dma_burst_length = 16,
 	.clk_init = macb_clk_init,
 	.init = macb_init,
 };
 
 static const struct macb_config sama5d3_config = {
-	.caps = MACB_CAPS_SG_DISABLED | MACB_CAPS_GIGABIT_MODE_AVAILABLE,
+	.caps = MACB_CAPS_SG_DISABLED | MACB_CAPS_GIGABIT_MODE_AVAILABLE
+	      | MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII,
 	.dma_burst_length = 16,
 	.clk_init = macb_clk_init,
 	.init = macb_init,
 };
 
 static const struct macb_config sama5d4_config = {
-	.caps = 0,
+	.caps = MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII,
 	.dma_burst_length = 4,
 	.clk_init = macb_clk_init,
 	.init = macb_init,
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 9ba416d5afff..8a13824ef802 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -400,7 +400,7 @@
 /* Capability mask bits */
 #define MACB_CAPS_ISR_CLEAR_ON_WRITE		0x00000001
 #define MACB_CAPS_USRIO_HAS_CLKEN		0x00000002
-#define MACB_CAPS_USRIO_DEFAULT_IS_MII		0x00000004
+#define MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII	0x00000004
 #define MACB_CAPS_NO_GIGABIT_HALF		0x00000008
 #define MACB_CAPS_USRIO_DISABLED		0x00000010
 #define MACB_CAPS_FIFO_MODE			0x10000000
-- 
2.1.3
