From: Leonard Crestez <leonard.crestez@nxp.com>
Subject: [PATCH v2 net 2/2] net: phy: micrel: Restore led_mode and clk_sel on resume
Date: Wed, 31 May 2017 13:29:30 +0300
Message-ID: <1460beebce4ba23722cfb185b0f9f884cca3b9e9.1496224930.git.leonard.crestez@nxp.com>
References: <cover.1496224930.git.leonard.crestez@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andy Duan <fugang.duan@nxp.com>, Johan Hovold <johan@kernel.org>,
        Alexandre Belloni <alexandre.belloni@free-electrons.com>,
        Philipp Zabel <p.zabel@pengutronix.de>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
        <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, Shawn Guo <shawnguo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1496224930.git.leonard.crestez@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These bits seem to be lost after a suspend/resume cycle so just set them
again. Do this by splitting the handling of these bits into a function
that is also called on resume.

This patch fixes ethernet suspend/resume on imx6ul-14x14-evk boards.

Signed-off-by: Leonard Crestez <leonard.crestez@nxp.com>
---
 drivers/net/phy/micrel.c | 42 ++++++++++++++++++++++++++++--------------
 1 file changed, 28 insertions(+), 14 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 6a5fd18..b9252b8d8 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -268,23 +268,12 @@ static int kszphy_nand_tree_disable(struct phy_device *phydev)
 	return ret;
 }
 
-static int kszphy_config_init(struct phy_device *phydev)
+/* Some config bits need to be set again on resume, handle them here. */
+static int kszphy_config_reset(struct phy_device *phydev)
 {
 	struct kszphy_priv *priv = phydev->priv;
-	const struct kszphy_type *type;
 	int ret;
 
-	if (!priv)
-		return 0;
-
-	type = priv->type;
-
-	if (type->has_broadcast_disable)
-		kszphy_broadcast_disable(phydev);
-
-	if (type->has_nand_tree_disable)
-		kszphy_nand_tree_disable(phydev);
-
 	if (priv->rmii_ref_clk_sel) {
 		ret = kszphy_rmii_clk_sel(phydev, priv->rmii_ref_clk_sel_val);
 		if (ret) {
@@ -295,11 +284,30 @@ static int kszphy_config_init(struct phy_device *phydev)
 	}
 
 	if (priv->led_mode >= 0)
-		kszphy_setup_led(phydev, type->led_mode_reg, priv->led_mode);
+		kszphy_setup_led(phydev, priv->type->led_mode_reg, priv->led_mode);
 
 	return 0;
 }
 
+static int kszphy_config_init(struct phy_device *phydev)
+{
+	struct kszphy_priv *priv = phydev->priv;
+	const struct kszphy_type *type;
+
+	if (!priv)
+		return 0;
+
+	type = priv->type;
+
+	if (type->has_broadcast_disable)
+		kszphy_broadcast_disable(phydev);
+
+	if (type->has_nand_tree_disable)
+		kszphy_nand_tree_disable(phydev);
+
+	return kszphy_config_reset(phydev);
+}
+
 static int ksz8041_config_init(struct phy_device *phydev)
 {
 	struct device_node *of_node = phydev->mdio.dev.of_node;
@@ -700,8 +708,14 @@ static int kszphy_suspend(struct phy_device *phydev)
 
 static int kszphy_resume(struct phy_device *phydev)
 {
+	int ret;
+
 	genphy_resume(phydev);
 
+	ret = kszphy_config_reset(phydev);
+	if (ret)
+		return ret;
+
 	/* Enable PHY Interrupts */
 	if (phy_interrupt_is_valid(phydev)) {
 		phydev->interrupts = PHY_INTERRUPT_ENABLED;
-- 
2.7.4
