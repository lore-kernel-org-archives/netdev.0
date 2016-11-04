From: Joachim Eastwood <manabian@gmail.com>
Subject: [net-next v2 4/7] stmmac: dwmac-sti: move st,gmac_en parsing to sti_dwmac_parse_data
Date: Fri,  4 Nov 2016 18:54:08 +0100
Message-ID: <20161104175411.12943-5-manabian@gmail.com>
References: <20161104175411.12943-1-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:36367 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965315AbcKDRz2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 13:55:28 -0400
Received: by mail-lf0-f68.google.com with SMTP id o20so4992128lfg.3
        for <netdev@vger.kernel.org>; Fri, 04 Nov 2016 10:55:27 -0700 (PDT)
In-Reply-To: <20161104175411.12943-1-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sti_dwmac_init() function is called both from probe and resume.
Since DT properties doesn't change between suspend/resume cycles move
parsing of this parameter into sti_dwmac_parse_data() where it belongs.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Tested-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
index bd6db22..269c7a5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
@@ -128,6 +128,7 @@ struct sti_dwmac {
 	int clk_sel_reg;	/* GMAC ext clk selection register */
 	struct device *dev;
 	struct regmap *regmap;
+	bool gmac_en;
 	u32 speed;
 	void (*fix_retime_src)(void *priv, unsigned int speed);
 };
@@ -233,14 +234,12 @@ static int sti_dwmac_init(struct platform_device *pdev, void *priv)
 	struct sti_dwmac *dwmac = priv;
 	struct regmap *regmap = dwmac->regmap;
 	int iface = dwmac->interface;
-	struct device *dev = dwmac->dev;
-	struct device_node *np = dev->of_node;
 	u32 reg = dwmac->ctrl_reg;
 	u32 val;
 
 	clk_prepare_enable(dwmac->clk);
 
-	if (of_property_read_bool(np, "st,gmac_en"))
+	if (dwmac->gmac_en)
 		regmap_update_bits(regmap, reg, EN_MASK, EN);
 
 	regmap_update_bits(regmap, reg, MII_PHY_SEL_MASK, phy_intf_sels[iface]);
@@ -281,6 +280,7 @@ static int sti_dwmac_parse_data(struct sti_dwmac *dwmac,
 	dwmac->dev = dev;
 	dwmac->interface = of_get_phy_mode(np);
 	dwmac->regmap = regmap;
+	dwmac->gmac_en = of_property_read_bool(np, "st,gmac_en");
 	dwmac->ext_phyclk = of_property_read_bool(np, "st,ext-phyclk");
 	dwmac->tx_retime_src = TX_RETIME_SRC_NA;
 	dwmac->speed = SPEED_100;
-- 
2.10.2
