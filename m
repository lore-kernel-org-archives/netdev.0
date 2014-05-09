From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH v2 2/3] drivers: net: cpsw-phy-sel: add dra7xx support for phy sel
Date: Fri, 9 May 2014 19:07:34 +0530
Message-ID: <1399642655-6412-3-git-send-email-mugunthanvnm@ti.com>
References: <1399642655-6412-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:52809 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756541AbaEINhn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 May 2014 09:37:43 -0400
In-Reply-To: <1399642655-6412-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add dra7xx support for selecting the phy mode which is present in control
module of dra7xx SoC

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 .../devicetree/bindings/net/cpsw-phy-sel.txt       |  3 +-
 drivers/net/ethernet/ti/cpsw-phy-sel.c             | 57 +++++++++++++++++++++-
 2 files changed, 58 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/cpsw-phy-sel.txt b/Documentation/devicetree/bindings/net/cpsw-phy-sel.txt
index 7ff57a1..d9da911 100644
--- a/Documentation/devicetree/bindings/net/cpsw-phy-sel.txt
+++ b/Documentation/devicetree/bindings/net/cpsw-phy-sel.txt
@@ -2,7 +2,8 @@ TI CPSW Phy mode Selection Device Tree Bindings
 -----------------------------------------------
 
 Required properties:
-- compatible		: Should be "ti,am3352-cpsw-phy-sel"
+- compatible		: Should be "ti,am3352-cpsw-phy-sel" for am335x platform and
+			  "ti,dra7xx-cpsw-phy-sel" for dra7xx platform
 - reg			: physical base address and size of the cpsw
 			  registers map
 - reg-names		: names of the register map given in "reg" node
diff --git a/drivers/net/ethernet/ti/cpsw-phy-sel.c b/drivers/net/ethernet/ti/cpsw-phy-sel.c
index 86b5dce..b93838d 100644
--- a/drivers/net/ethernet/ti/cpsw-phy-sel.c
+++ b/drivers/net/ethernet/ti/cpsw-phy-sel.c
@@ -29,6 +29,8 @@
 #define AM33XX_GMII_SEL_RMII2_IO_CLK_EN	BIT(7)
 #define AM33XX_GMII_SEL_RMII1_IO_CLK_EN	BIT(6)
 
+#define GMII_SEL_MODE_MASK		0x3
+
 struct cpsw_phy_sel_priv {
 	struct device	*dev;
 	u32 __iomem	*gmii_sel;
@@ -65,7 +67,7 @@ static void cpsw_gmii_sel_am3352(struct cpsw_phy_sel_priv *priv,
 		break;
 	};
 
-	mask = 0x3 << (slave * 2) | BIT(slave + 6);
+	mask = GMII_SEL_MODE_MASK << (slave * 2) | BIT(slave + 6);
 	mode <<= slave * 2;
 
 	if (priv->rmii_clock_external) {
@@ -81,6 +83,55 @@ static void cpsw_gmii_sel_am3352(struct cpsw_phy_sel_priv *priv,
 	writel(reg, priv->gmii_sel);
 }
 
+static void cpsw_gmii_sel_dra7xx(struct cpsw_phy_sel_priv *priv,
+				 phy_interface_t phy_mode, int slave)
+{
+	u32 reg;
+	u32 mask;
+	u32 mode = 0;
+
+	reg = readl(priv->gmii_sel);
+
+	switch (phy_mode) {
+	case PHY_INTERFACE_MODE_RMII:
+		mode = AM33XX_GMII_SEL_MODE_RMII;
+		break;
+
+	case PHY_INTERFACE_MODE_RGMII:
+	case PHY_INTERFACE_MODE_RGMII_ID:
+	case PHY_INTERFACE_MODE_RGMII_RXID:
+	case PHY_INTERFACE_MODE_RGMII_TXID:
+		mode = AM33XX_GMII_SEL_MODE_RGMII;
+		break;
+
+	case PHY_INTERFACE_MODE_MII:
+	default:
+		mode = AM33XX_GMII_SEL_MODE_MII;
+		break;
+	};
+
+	switch (slave) {
+	case 0:
+		mask = GMII_SEL_MODE_MASK;
+		break;
+	case 1:
+		mask = GMII_SEL_MODE_MASK << 4;
+		mode <<= 4;
+		break;
+	default:
+		dev_err(priv->dev, "invalid slave number...\n");
+		return;
+	}
+
+	if (priv->rmii_clock_external)
+		dev_err(priv->dev, "RMII External clock is not supported\n");
+
+	reg &= ~mask;
+	reg |= mode;
+
+	writel(reg, priv->gmii_sel);
+}
+
 static struct platform_driver cpsw_phy_sel_driver;
 static int match(struct device *dev, void *data)
 {
@@ -112,6 +163,10 @@ static const struct of_device_id cpsw_phy_sel_id_table[] = {
 		.compatible	= "ti,am3352-cpsw-phy-sel",
 		.data		= &cpsw_gmii_sel_am3352,
 	},
+	{
+		.compatible	= "ti,dra7xx-cpsw-phy-sel",
+		.data		= &cpsw_gmii_sel_dra7xx,
+	},
 	{}
 };
 MODULE_DEVICE_TABLE(of, cpsw_phy_sel_id_table);
-- 
1.9.2.459.g68773ac
