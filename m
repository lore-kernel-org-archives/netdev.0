From: Sylvain Rochet <sylvain.rochet@finsecur.com>
Subject: [PATCH] net: phy: micrel: disable NAND-tree for KSZ8021,KSZ8031,KSZ8051,KSZ8081
Date: Fri, 13 Feb 2015 21:35:33 +0100
Message-ID: <1423859733-21456-1-git-send-email-sylvain.rochet@finsecur.com>
Cc: Sylvain Rochet <sylvain.rochet@finsecur.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	voice.shen@atmel.com, josh.wu@atmel.com,
	ludovic.desroches@atmel.com,
	Boris Brezillon <boris.brezillon@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NAND-tree is used to check wiring between MAC and PHY using NAND gates
on the PHY side, hence the name.

NAND-tree initial status is latched at reset by probing the IRQ pin.
However some devices are sharing the PHY IRQ pin with other peripherals
such as Atmel SAMA5D[34]x-EK boards when using the optional TM7000
display module, therefore they are switching the PHY in NAND-tree test
mode depending on the current IRQ line status at reset.

This patch ensure PHY is not in NAND-tree test mode for all Micrel PHYs
using IRQ line as a NAND-tree toggle mode at reset.

Signed-off-by: Sylvain Rochet <sylvain.rochet@finsecur.com>
Signed-off-by: Boris Brezillon <boris.brezillon@free-electrons.com>
---
 drivers/net/phy/micrel.c | 28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 3ad8ca7..1190fd8 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -32,6 +32,7 @@
 /* Operation Mode Strap Override */
 #define MII_KSZPHY_OMSO				0x16
 #define KSZPHY_OMSO_B_CAST_OFF			BIT(9)
+#define KSZPHY_OMSO_NAND_TREE_ON		BIT(5)
 #define KSZPHY_OMSO_RMII_OVERRIDE		BIT(1)
 #define KSZPHY_OMSO_MII_OVERRIDE		BIT(0)
 
@@ -76,6 +77,7 @@ struct kszphy_type {
 	u32 led_mode_reg;
 	u16 interrupt_level_mask;
 	bool has_broadcast_disable;
+	bool has_nand_tree_disable;
 	bool has_rmii_ref_clk_sel;
 };
 
@@ -89,6 +91,7 @@ struct kszphy_priv {
 static const struct kszphy_type ksz8021_type = {
 	.led_mode_reg		= MII_KSZPHY_CTRL_2,
 	.has_broadcast_disable	= true,
+	.has_nand_tree_disable	= true,
 	.has_rmii_ref_clk_sel	= true,
 };
 
@@ -98,11 +101,13 @@ static const struct kszphy_type ksz8041_type = {
 
 static const struct kszphy_type ksz8051_type = {
 	.led_mode_reg		= MII_KSZPHY_CTRL_2,
+	.has_nand_tree_disable	= true,
 };
 
 static const struct kszphy_type ksz8081_type = {
 	.led_mode_reg		= MII_KSZPHY_CTRL_2,
 	.has_broadcast_disable	= true,
+	.has_nand_tree_disable	= true,
 	.has_rmii_ref_clk_sel	= true,
 };
 
@@ -231,6 +236,26 @@ out:
 	return ret;
 }
 
+static int kszphy_nand_tree_disable(struct phy_device *phydev)
+{
+	int ret;
+
+	ret = phy_read(phydev, MII_KSZPHY_OMSO);
+	if (ret < 0)
+		goto out;
+
+	if (!(ret & KSZPHY_OMSO_NAND_TREE_ON))
+		return 0;
+
+	ret = phy_write(phydev, MII_KSZPHY_OMSO,
+			ret & ~KSZPHY_OMSO_NAND_TREE_ON);
+out:
+	if (ret)
+		dev_err(&phydev->dev, "failed to disable NAND tree mode\n");
+
+	return ret;
+}
+
 static int kszphy_config_init(struct phy_device *phydev)
 {
 	struct kszphy_priv *priv = phydev->priv;
@@ -245,6 +270,9 @@ static int kszphy_config_init(struct phy_device *phydev)
 	if (type->has_broadcast_disable)
 		kszphy_broadcast_disable(phydev);
 
+	if (type->has_nand_tree_disable)
+		kszphy_nand_tree_disable(phydev);
+
 	if (priv->rmii_ref_clk_sel) {
 		ret = kszphy_rmii_clk_sel(phydev, priv->rmii_ref_clk_sel_val);
 		if (ret) {
-- 
2.1.4
