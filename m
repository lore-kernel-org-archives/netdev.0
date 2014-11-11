From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 17/22] net: phy: micrel: add generic rmii-ref-clk-sel support
Date: Tue, 11 Nov 2014 18:37:35 +0100
Message-ID: <1415727460-20417-18-git-send-email-johan@kernel.org>
References: <1415727460-20417-1-git-send-email-johan@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Johan Hovold <johan@kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415727460-20417-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add generic RMII-reference-clock-select support.

Several Micrel PHY have a RMII-reference-clock-select bit to select
25 MHz or 50 MHz clock mode. Recently, support for configuring this
through device tree for KSZ8021 and KSZ8031 was added.

Generalise this support so that it can be configured for other PHY types
as well.

Note that some PHY revisions (of the same type) has this bit inverted.
This should be either configurable through a new device-tree property,
or preferably, determined based on PHY ID if possible.

Also note that this removes support for setting 25 MHz mode from board
files which was also added by the above mentioned commit 45f56cb82e45
("net/phy: micrel: Add clock support for KSZ8021/KSZ8031").

Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/phy/micrel.c   | 94 +++++++++++++++++++++++++---------------------
 include/linux/micrel_phy.h |  1 -
 2 files changed, 51 insertions(+), 44 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 6467bcc5a39d..d2e790cd3651 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -57,7 +57,7 @@
 #define KSZPHY_CTRL_INT_ACTIVE_HIGH		BIT(9)
 #define KSZ9021_CTRL_INT_ACTIVE_HIGH		BIT(14)
 #define KS8737_CTRL_INT_ACTIVE_HIGH		BIT(14)
-#define KSZ8051_RMII_50MHZ_CLK			BIT(7)
+#define KSZPHY_RMII_REF_CLK_SEL			BIT(7)
 
 /* Write/read to/from extended registers */
 #define MII_KSZPHY_EXTREG                       0x0b
@@ -76,15 +76,19 @@
 struct kszphy_type {
 	u32 led_mode_reg;
 	bool has_broadcast_disable;
+	bool has_rmii_ref_clk_sel;
 };
 
 struct kszphy_priv {
 	const struct kszphy_type *type;
 	int led_mode;
+	bool rmii_ref_clk_sel;
+	bool rmii_ref_clk_sel_val;
 };
 
 static const struct kszphy_type ksz8021_type = {
 	.led_mode_reg		= MII_KSZPHY_CTRL_2,
+	.has_rmii_ref_clk_sel	= true,
 };
 
 static const struct kszphy_type ksz8041_type = {
@@ -100,21 +104,6 @@ static const struct kszphy_type ksz8081_type = {
 	.has_broadcast_disable	= true,
 };
 
-static int ksz_config_flags(struct phy_device *phydev)
-{
-	int regval;
-
-	if (phydev->dev_flags & (MICREL_PHY_50MHZ_CLK | MICREL_PHY_25MHZ_CLK)) {
-		regval = phy_read(phydev, MII_KSZPHY_CTRL);
-		if (phydev->dev_flags & MICREL_PHY_50MHZ_CLK)
-			regval |= KSZ8051_RMII_50MHZ_CLK;
-		else
-			regval &= ~KSZ8051_RMII_50MHZ_CLK;
-		return phy_write(phydev, MII_KSZPHY_CTRL, regval);
-	}
-	return 0;
-}
-
 static int kszphy_extended_write(struct phy_device *phydev,
 				u32 regnum, u16 val)
 {
@@ -189,6 +178,22 @@ static int ks8737_config_intr(struct phy_device *phydev)
 	return rc < 0 ? rc : 0;
 }
 
+static int kszphy_rmii_clk_sel(struct phy_device *phydev, bool val)
+{
+	int ctrl;
+
+	ctrl = phy_read(phydev, MII_KSZPHY_CTRL);
+	if (ctrl < 0)
+		return ctrl;
+
+	if (val)
+		ctrl |= KSZPHY_RMII_REF_CLK_SEL;
+	else
+		ctrl &= ~KSZPHY_RMII_REF_CLK_SEL;
+
+	return phy_write(phydev, MII_KSZPHY_CTRL, ctrl);
+}
+
 static int kszphy_setup_led(struct phy_device *phydev, u32 reg, int val)
 {
 	int rc, temp, shift;
@@ -243,6 +248,7 @@ static int kszphy_config_init(struct phy_device *phydev)
 {
 	struct kszphy_priv *priv = phydev->priv;
 	const struct kszphy_type *type;
+	int ret;
 
 	if (!priv)
 		return 0;
@@ -252,6 +258,14 @@ static int kszphy_config_init(struct phy_device *phydev)
 	if (type->has_broadcast_disable)
 		kszphy_broadcast_disable(phydev);
 
+	if (priv->rmii_ref_clk_sel) {
+		ret = kszphy_rmii_clk_sel(phydev, priv->rmii_ref_clk_sel_val);
+		if (ret) {
+			dev_err(&phydev->dev, "failed to set rmii reference clock\n");
+			return ret;
+		}
+	}
+
 	if (priv->led_mode >= 0)
 		kszphy_setup_led(phydev, type->led_mode_reg, priv->led_mode);
 
@@ -262,10 +276,8 @@ static int ksz8021_config_init(struct phy_device *phydev)
 {
 	int rc;
 
-	kszphy_config_init(phydev);
-
-	rc = ksz_config_flags(phydev);
-	if (rc < 0)
+	rc = kszphy_config_init(phydev);
+	if (rc)
 		return rc;
 
 	rc = kszphy_broadcast_disable(phydev);
@@ -273,16 +285,6 @@ static int ksz8021_config_init(struct phy_device *phydev)
 	return rc < 0 ? rc : 0;
 }
 
-static int ks8051_config_init(struct phy_device *phydev)
-{
-	int rc;
-
-	kszphy_config_init(phydev);
-
-	rc = ksz_config_flags(phydev);
-	return rc < 0 ? rc : 0;
-}
-
 static int ksz9021_load_values_from_of(struct phy_device *phydev,
 				       struct device_node *of_node, u16 reg,
 				       char *field1, char *field2,
@@ -517,6 +519,7 @@ static int kszphy_probe(struct phy_device *phydev)
 	const struct kszphy_type *type = phydev->drv->driver_data;
 	struct device_node *np = phydev->dev.of_node;
 	struct kszphy_priv *priv;
+	struct clk *clk;
 	int ret;
 
 	priv = devm_kzalloc(&phydev->dev, sizeof(*priv), GFP_KERNEL);
@@ -542,28 +545,32 @@ static int kszphy_probe(struct phy_device *phydev)
 		priv->led_mode = -1;
 	}
 
-	return 0;
-}
-
-static int ksz8021_probe(struct phy_device *phydev)
-{
-	struct clk *clk;
-
 	clk = devm_clk_get(&phydev->dev, "rmii-ref");
 	if (!IS_ERR(clk)) {
 		unsigned long rate = clk_get_rate(clk);
 
+		priv->rmii_ref_clk_sel = type->has_rmii_ref_clk_sel;
+
+		/* FIXME: add support for PHY revisions that have this bit
+		 * inverted (e.g. through new property or based on PHY ID).
+		 */
 		if (rate > 24500000 && rate < 25500000) {
-			phydev->dev_flags |= MICREL_PHY_25MHZ_CLK;
+			priv->rmii_ref_clk_sel_val = false;
 		} else if (rate > 49500000 && rate < 50500000) {
-			phydev->dev_flags |= MICREL_PHY_50MHZ_CLK;
+			priv->rmii_ref_clk_sel_val = true;
 		} else {
 			dev_err(&phydev->dev, "Clock rate out of range: %ld\n", rate);
 			return -EINVAL;
 		}
 	}
 
-	return kszphy_probe(phydev);
+	/* Support legacy board-file configuration */
+	if (phydev->dev_flags & MICREL_PHY_50MHZ_CLK) {
+		priv->rmii_ref_clk_sel = true;
+		priv->rmii_ref_clk_sel_val = true;
+	}
+
+	return 0;
 }
 
 static struct phy_driver ksphy_driver[] = {
@@ -589,7 +596,7 @@ static struct phy_driver ksphy_driver[] = {
 			   SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.driver_data	= &ksz8021_type,
-	.probe		= ksz8021_probe,
+	.probe		= kszphy_probe,
 	.config_init	= ksz8021_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
@@ -606,7 +613,7 @@ static struct phy_driver ksphy_driver[] = {
 			   SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.driver_data	= &ksz8021_type,
-	.probe		= ksz8021_probe,
+	.probe		= kszphy_probe,
 	.config_init	= ksz8021_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
@@ -657,7 +664,8 @@ static struct phy_driver ksphy_driver[] = {
 				| SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.driver_data	= &ksz8051_type,
-	.config_init	= ks8051_config_init,
+	.probe		= kszphy_probe,
+	.config_init	= kszphy_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
diff --git a/include/linux/micrel_phy.h b/include/linux/micrel_phy.h
index 53d33dee70e1..2e5b194b9b19 100644
--- a/include/linux/micrel_phy.h
+++ b/include/linux/micrel_phy.h
@@ -37,7 +37,6 @@
 
 /* struct phy_device dev_flags definitions */
 #define MICREL_PHY_50MHZ_CLK	0x00000001
-#define MICREL_PHY_25MHZ_CLK	0x00000002
 
 #define MICREL_KSZ9021_EXTREG_CTRL	0xB
 #define MICREL_KSZ9021_EXTREG_DATA_WRITE	0xC
-- 
2.0.4
