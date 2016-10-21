From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [RFC PATCH 08/13] dwmac-meson8b: add support for phy selection
Date: Fri, 21 Oct 2016 16:40:33 +0200
Message-ID: <1477060838-14164-9-git-send-email-narmstrong@baylibre.com>
References: <1477060838-14164-1-git-send-email-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong@baylibre.com>,
        linux-gpio@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-amlogic@lists.infradead.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: khilman@baylibre.com, carlo@caione.org, linus.walleij@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:36199 "EHLO
        mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934430AbcJUOlA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 10:41:00 -0400
Received: by mail-lf0-f49.google.com with SMTP id b75so146327386lfg.3
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 07:40:59 -0700 (PDT)
In-Reply-To: <1477060838-14164-1-git-send-email-narmstrong@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Meson GXL dwmac Glue Layer also provides switching between an external PHY
and an internal RMII 10/100 PHY.
Add a way to setup the correct PHY switching from a device tree attribute.

Currently, the register format is unknown and this is a temporary workaround
until a clarification on the registers fields is received from Amlogic.

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 .../net/ethernet/stmicro/stmmac/dwmac-meson8b.c    | 25 ++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
index 250e4ce..875cd7c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c
@@ -53,10 +53,15 @@
 
 #define MUX_CLK_NUM_PARENTS		2
 
+#define PHYSEL_REG0			0x0
+#define PHYSEL_REG0_VALUE		0x10110181
+#define PHYSEL_REG1			0x4
+
 struct meson8b_dwmac {
 	struct platform_device	*pdev;
 
 	void __iomem		*regs;
+	void __iomem		*physel_regs;
 
 	phy_interface_t		phy_mode;
 
@@ -244,6 +249,23 @@ static int meson8b_init_prg_eth(struct meson8b_dwmac *dwmac)
 	meson8b_dwmac_mask_bits(dwmac, PRG_ETH0, PRG_ETH0_TX_AND_PHY_REF_CLK,
 				PRG_ETH0_TX_AND_PHY_REF_CLK);
 
+	/* Select PHY, either internal or external if specified */
+	if (!IS_ERR(dwmac->physel_regs) &&
+	    of_find_property(dwmac->pdev->dev.of_node,
+			     "amlogic,phy-select", NULL)) {
+		u32 val;
+
+		ret = of_property_read_u32(dwmac->pdev->dev.of_node,
+					   "amlogic,phy-select", &val);
+		if (ret) {
+			dev_err(&dwmac->pdev->dev, "invalid phy-select property\n");
+		} else {
+			writel(PHYSEL_REG0_VALUE,
+			       dwmac->physel_regs + PHYSEL_REG0);
+			writel(val, dwmac->physel_regs + PHYSEL_REG1);
+		}
+	}
+
 	return 0;
 }
 
@@ -272,6 +294,9 @@ static int meson8b_dwmac_probe(struct platform_device *pdev)
 	if (IS_ERR(dwmac->regs))
 		return PTR_ERR(dwmac->regs);
 
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 2);
+	dwmac->physel_regs = devm_ioremap_resource(&pdev->dev, res);
+
 	dwmac->pdev = pdev;
 	dwmac->phy_mode = of_get_phy_mode(pdev->dev.of_node);
 	if (dwmac->phy_mode < 0) {
-- 
1.9.1
