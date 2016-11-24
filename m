From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: [net-next PATCH v1 2/2] net: stmmac: dwmac-meson8b: make the RGMII TX delay configurable
Date: Thu, 24 Nov 2016 15:34:17 +0100
Message-ID: <20161124143417.10178-3-martin.blumenstingl@googlemail.com>
References: <20161124143417.10178-1-martin.blumenstingl@googlemail.com>
Cc: linux-arm-kernel@lists.infradead.org, alexandre.torgue@st.com,
        peppe.cavallaro@st.com, carlo@caione.org, jbrunet@baylibre.com,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>
To: linux-amlogic@lists.infradead.org, devicetree@vger.kernel.org,
        netdev@vger.kernel.org, davem@davemloft.net, khilman@baylibre.com,
        mark.rutland@arm.com, robh+dt@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36799 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753153AbcKXOed (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 09:34:33 -0500
In-Reply-To: <20161124143417.10178-1-martin.blumenstingl@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prior to this patch we were using a hardcoded RGMII TX clock delay of
1/4 cycle (= 2ns). This value works for many boards, but unfortunately
not for all (due to the way the actual circuit is designed, sometimes
because the TX delay is enabled in the PHY, etc.).
Making the TX delay on the MAC side configurable allows us to support
all possible hardware combinations (which may or not be out there).

This allows fixing a compatibility issue on some boards, where the
RTL8211F PHY is configured to generate the TX delay. We can now turn
off the TX delay in the MAC, because otherwise we would be applying the
delay twice (which results in non-working TX traffic).

Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
index 250e4ce..1697d1a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
@@ -23,6 +23,8 @@
 #include <linux/platform_device.h>
 #include <linux/stmmac.h>
 
+#include <dt-bindings/net/dwmac-meson8b.h>
+
 #include "stmmac_platform.h"
 
 #define PRG_ETH0			0x0
@@ -35,10 +37,6 @@
 
 #define PRG_ETH0_TXDLY_SHIFT		5
 #define PRG_ETH0_TXDLY_MASK		GENMASK(6, 5)
-#define PRG_ETH0_TXDLY_OFF		(0x0 << PRG_ETH0_TXDLY_SHIFT)
-#define PRG_ETH0_TXDLY_QUARTER		(0x1 << PRG_ETH0_TXDLY_SHIFT)
-#define PRG_ETH0_TXDLY_HALF		(0x2 << PRG_ETH0_TXDLY_SHIFT)
-#define PRG_ETH0_TXDLY_THREE_QUARTERS	(0x3 << PRG_ETH0_TXDLY_SHIFT)
 
 /* divider for the result of m250_sel */
 #define PRG_ETH0_CLK_M250_DIV_SHIFT	7
@@ -69,6 +67,8 @@ struct meson8b_dwmac {
 
 	struct clk_divider	m25_div;
 	struct clk		*m25_div_clk;
+
+	u32			tx_dly;
 };
 
 static void meson8b_dwmac_mask_bits(struct meson8b_dwmac *dwmac, u32 reg,
@@ -198,7 +198,7 @@ static int meson8b_init_prg_eth(struct meson8b_dwmac *dwmac)
 
 		/* TX clock delay - all known boards use a 1/4 cycle delay */
 		meson8b_dwmac_mask_bits(dwmac, PRG_ETH0, PRG_ETH0_TXDLY_MASK,
-					PRG_ETH0_TXDLY_QUARTER);
+					dwmac->tx_dly << PRG_ETH0_TXDLY_SHIFT);
 		break;
 
 	case PHY_INTERFACE_MODE_RMII:
@@ -279,6 +279,12 @@ static int meson8b_dwmac_probe(struct platform_device *pdev)
 		return -EINVAL;
 	}
 
+	ret = of_property_read_u32(pdev->dev.of_node, "amlogic,tx-delay",
+				   &dwmac->tx_dly);
+	if (ret)
+		/* default to 1/4 cycle (= 2ns for RGMII) */
+		dwmac->tx_dly = DWMAC_MESON8B_TXDLY_QUARTER_CYCLE;
+
 	ret = meson8b_init_clk(dwmac);
 	if (ret)
 		return ret;
-- 
2.10.2
