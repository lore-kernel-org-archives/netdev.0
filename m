From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: [PATCH net-next v5 2/2] net: stmmac: dwmac-meson8b: make the RGMII TX delay configurable
Date: Sun, 22 Jan 2017 23:02:46 +0100
Message-ID: <20170122220246.13602-3-martin.blumenstingl@googlemail.com>
References: <20161217182119.4037-1-martin.blumenstingl@googlemail.com>
 <20170122220246.13602-1-martin.blumenstingl@googlemail.com>
Cc: robh+dt@kernel.org, mark.rutland@arm.com, carlo@caione.org,
        khilman@baylibre.com, narmstrong@baylibre.com,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-amlogic@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34372 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750704AbdAVWC7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 17:02:59 -0500
In-Reply-To: <20170122220246.13602-1-martin.blumenstingl@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prior to this patch we were using a hardcoded RGMII TX clock delay of
2ns (= 1/4 cycle of the 125MHz RGMII TX clock). This value works for
many boards, but unfortunately not for all (due to the way the actual
circuit is designed, sometimes because the TX delay is enabled in the
PHY, etc.). Making the TX delay on the MAC side configurable allows us
to support all possible hardware combinations.

This allows fixing a compatibility issue on some boards, where the
RTL8211F PHY is configured to generate the TX delay. We can now turn
off the TX delay in the MAC, because otherwise we would be applying the
delay twice (which results in non-working TX traffic).

Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Tested-by: Neil Armstrong <narmstrong@baylibre.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
index ffaed1f35efe..8840a360a0b7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
@@ -35,10 +35,6 @@
 
 #define PRG_ETH0_TXDLY_SHIFT		5
 #define PRG_ETH0_TXDLY_MASK		GENMASK(6, 5)
-#define PRG_ETH0_TXDLY_OFF		(0x0 << PRG_ETH0_TXDLY_SHIFT)
-#define PRG_ETH0_TXDLY_QUARTER		(0x1 << PRG_ETH0_TXDLY_SHIFT)
-#define PRG_ETH0_TXDLY_HALF		(0x2 << PRG_ETH0_TXDLY_SHIFT)
-#define PRG_ETH0_TXDLY_THREE_QUARTERS	(0x3 << PRG_ETH0_TXDLY_SHIFT)
 
 /* divider for the result of m250_sel */
 #define PRG_ETH0_CLK_M250_DIV_SHIFT	7
@@ -69,6 +65,8 @@ struct meson8b_dwmac {
 
 	struct clk_divider	m25_div;
 	struct clk		*m25_div_clk;
+
+	u32			tx_delay_ns;
 };
 
 static void meson8b_dwmac_mask_bits(struct meson8b_dwmac *dwmac, u32 reg,
@@ -179,6 +177,7 @@ static int meson8b_init_prg_eth(struct meson8b_dwmac *dwmac)
 {
 	int ret;
 	unsigned long clk_rate;
+	u8 tx_dly_val;
 
 	switch (dwmac->phy_mode) {
 	case PHY_INTERFACE_MODE_RGMII:
@@ -196,9 +195,13 @@ static int meson8b_init_prg_eth(struct meson8b_dwmac *dwmac)
 		meson8b_dwmac_mask_bits(dwmac, PRG_ETH0,
 					PRG_ETH0_INVERTED_RMII_CLK, 0);
 
-		/* TX clock delay - all known boards use a 1/4 cycle delay */
+		/* TX clock delay in ns = "8ns / 4 * tx_dly_val" (where
+		 * 8ns are exactly one cycle of the 125MHz RGMII TX clock):
+		 * 0ns = 0x0, 2ns = 0x1, 4ns = 0x2, 6ns = 0x3
+		 */
+		tx_dly_val = dwmac->tx_delay_ns >> 1;
 		meson8b_dwmac_mask_bits(dwmac, PRG_ETH0, PRG_ETH0_TXDLY_MASK,
-					PRG_ETH0_TXDLY_QUARTER);
+					tx_dly_val << PRG_ETH0_TXDLY_SHIFT);
 		break;
 
 	case PHY_INTERFACE_MODE_RMII:
@@ -284,6 +287,11 @@ static int meson8b_dwmac_probe(struct platform_device *pdev)
 		goto err_remove_config_dt;
 	}
 
+	/* use 2ns as fallback since this value was previously hardcoded */
+	if (of_property_read_u32(pdev->dev.of_node, "amlogic,tx-delay-ns",
+				 &dwmac->tx_delay_ns))
+		dwmac->tx_delay_ns = 2;
+
 	ret = meson8b_init_clk(dwmac);
 	if (ret)
 		goto err_remove_config_dt;
-- 
2.11.0
