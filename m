From: Heiner Kallweit <hkallweit1@gmail.com>
Subject: [PATCH] net: stmmac: don't set tx delay in RGMII_ID and RGMII_TXID
 mode
Date: Wed, 1 Feb 2017 20:19:25 +0100
Message-ID: <ed022e67-2494-209e-9e51-b7a57c219d02@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        linux-amlogic@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f195.google.com ([209.85.210.195]:35809 "EHLO
        mail-wj0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751781AbdBATTg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 14:19:36 -0500
Received: by mail-wj0-f195.google.com with SMTP id i7so14138047wjf.2
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 11:19:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As documented in Documentation/devicetree/bindings/net/ethernet.txt,
in RGMII_ID and RGMII_TXID mode the MAC should not add a tx delay.

Signed-off-by: Heiner Kallweit <hkallweit1@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
index 8840a360..96855559 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
@@ -177,12 +177,19 @@ static int meson8b_init_prg_eth(struct meson8b_dwmac *dwmac)
 {
 	int ret;
 	unsigned long clk_rate;
-	u8 tx_dly_val;
+	u8 tx_dly_val = 0;
 
 	switch (dwmac->phy_mode) {
 	case PHY_INTERFACE_MODE_RGMII:
-	case PHY_INTERFACE_MODE_RGMII_ID:
 	case PHY_INTERFACE_MODE_RGMII_RXID:
+		/* TX clock delay in ns = "8ns / 4 * tx_dly_val" (where
+		 * 8ns are exactly one cycle of the 125MHz RGMII TX clock):
+		 * 0ns = 0x0, 2ns = 0x1, 4ns = 0x2, 6ns = 0x3
+		 */
+		tx_dly_val = dwmac->tx_delay_ns >> 1;
+		/* fall through */
+
+	case PHY_INTERFACE_MODE_RGMII_ID:
 	case PHY_INTERFACE_MODE_RGMII_TXID:
 		/* Generate a 25MHz clock for the PHY */
 		clk_rate = 25 * 1000 * 1000;
@@ -195,11 +202,6 @@ static int meson8b_init_prg_eth(struct meson8b_dwmac *dwmac)
 		meson8b_dwmac_mask_bits(dwmac, PRG_ETH0,
 					PRG_ETH0_INVERTED_RMII_CLK, 0);
 
-		/* TX clock delay in ns = "8ns / 4 * tx_dly_val" (where
-		 * 8ns are exactly one cycle of the 125MHz RGMII TX clock):
-		 * 0ns = 0x0, 2ns = 0x1, 4ns = 0x2, 6ns = 0x3
-		 */
-		tx_dly_val = dwmac->tx_delay_ns >> 1;
 		meson8b_dwmac_mask_bits(dwmac, PRG_ETH0, PRG_ETH0_TXDLY_MASK,
 					tx_dly_val << PRG_ETH0_TXDLY_SHIFT);
 		break;
-- 
2.11.0
