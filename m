From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 14/22] net: phy: micrel: add device-type abstraction
Date: Tue, 11 Nov 2014 18:37:32 +0100
Message-ID: <1415727460-20417-15-git-send-email-johan@kernel.org>
References: <1415727460-20417-1-git-send-email-johan@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Johan Hovold <johan@kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415727460-20417-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add structured device-type information and support for generic led-mode
setup to the generic config_init callback.

This is a first step in ultimately getting rid of device-type specific
callbacks.

Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/phy/micrel.c | 82 ++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 69 insertions(+), 13 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 30e894d6ffbd..189fddb829bc 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -73,6 +73,30 @@
 
 #define PS_TO_REG				200
 
+struct kszphy_type {
+	u32 led_mode_reg;
+};
+
+struct kszphy_priv {
+	const struct kszphy_type *type;
+};
+
+static const struct kszphy_type ksz8021_type = {
+	.led_mode_reg		= MII_KSZPHY_CTRL_2,
+};
+
+static const struct kszphy_type ksz8041_type = {
+	.led_mode_reg		= MII_KSZPHY_CTRL_1,
+};
+
+static const struct kszphy_type ksz8051_type = {
+	.led_mode_reg		= MII_KSZPHY_CTRL_2,
+};
+
+static const struct kszphy_type ksz8081_type = {
+	.led_mode_reg		= MII_KSZPHY_CTRL_2,
+};
+
 static int ksz_config_flags(struct phy_device *phydev)
 {
 	int regval;
@@ -229,19 +253,25 @@ out:
 
 static int kszphy_config_init(struct phy_device *phydev)
 {
-	return 0;
-}
+	struct kszphy_priv *priv = phydev->priv;
+	const struct kszphy_type *type;
 
-static int kszphy_config_init_led8041(struct phy_device *phydev)
-{
-	return kszphy_setup_led(phydev, MII_KSZPHY_CTRL_1);
+	if (!priv)
+		return 0;
+
+	type = priv->type;
+
+	if (type->led_mode_reg)
+		kszphy_setup_led(phydev, type->led_mode_reg);
+
+	return 0;
 }
 
 static int ksz8021_config_init(struct phy_device *phydev)
 {
 	int rc;
 
-	kszphy_setup_led(phydev, MII_KSZPHY_CTRL_2);
+	kszphy_config_init(phydev);
 
 	rc = ksz_config_flags(phydev);
 	if (rc < 0)
@@ -256,7 +286,7 @@ static int ks8051_config_init(struct phy_device *phydev)
 {
 	int rc;
 
-	kszphy_setup_led(phydev, MII_KSZPHY_CTRL_2);
+	kszphy_config_init(phydev);
 
 	rc = ksz_config_flags(phydev);
 	return rc < 0 ? rc : 0;
@@ -265,9 +295,8 @@ static int ks8051_config_init(struct phy_device *phydev)
 static int ksz8081_config_init(struct phy_device *phydev)
 {
 	kszphy_broadcast_disable(phydev);
-	kszphy_setup_led(phydev, MII_KSZPHY_CTRL_2);
 
-	return 0;
+	return kszphy_config_init(phydev);
 }
 
 static int ksz9021_load_values_from_of(struct phy_device *phydev,
@@ -499,6 +528,22 @@ ksz9021_wr_mmd_phyreg(struct phy_device *phydev, int ptrad, int devnum,
 {
 }
 
+static int kszphy_probe(struct phy_device *phydev)
+{
+	const struct kszphy_type *type = phydev->drv->driver_data;
+	struct kszphy_priv *priv;
+
+	priv = devm_kzalloc(&phydev->dev, sizeof(*priv), GFP_KERNEL);
+	if (!priv)
+		return -ENOMEM;
+
+	phydev->priv = priv;
+
+	priv->type = type;
+
+	return 0;
+}
+
 static int ksz8021_probe(struct phy_device *phydev)
 {
 	struct clk *clk;
@@ -517,7 +562,7 @@ static int ksz8021_probe(struct phy_device *phydev)
 		}
 	}
 
-	return 0;
+	return kszphy_probe(phydev);
 }
 
 static struct phy_driver ksphy_driver[] = {
@@ -542,6 +587,7 @@ static struct phy_driver ksphy_driver[] = {
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
 			   SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.driver_data	= &ksz8021_type,
 	.probe		= ksz8021_probe,
 	.config_init	= ksz8021_config_init,
 	.config_aneg	= genphy_config_aneg,
@@ -558,6 +604,7 @@ static struct phy_driver ksphy_driver[] = {
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause |
 			   SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.driver_data	= &ksz8021_type,
 	.probe		= ksz8021_probe,
 	.config_init	= ksz8021_config_init,
 	.config_aneg	= genphy_config_aneg,
@@ -574,7 +621,9 @@ static struct phy_driver ksphy_driver[] = {
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
 				| SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
-	.config_init	= kszphy_config_init_led8041,
+	.driver_data	= &ksz8041_type,
+	.probe		= kszphy_probe,
+	.config_init	= kszphy_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
@@ -589,7 +638,9 @@ static struct phy_driver ksphy_driver[] = {
 	.features	= PHY_BASIC_FEATURES |
 			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
-	.config_init	= kszphy_config_init_led8041,
+	.driver_data	= &ksz8041_type,
+	.probe		= kszphy_probe,
+	.config_init	= kszphy_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
@@ -604,6 +655,7 @@ static struct phy_driver ksphy_driver[] = {
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
 				| SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.driver_data	= &ksz8051_type,
 	.config_init	= ks8051_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
@@ -618,7 +670,9 @@ static struct phy_driver ksphy_driver[] = {
 	.phy_id_mask	= 0x00ffffff,
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
-	.config_init	= kszphy_config_init_led8041,
+	.driver_data	= &ksz8041_type,
+	.probe		= kszphy_probe,
+	.config_init	= kszphy_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
@@ -632,6 +686,8 @@ static struct phy_driver ksphy_driver[] = {
 	.phy_id_mask	= 0x00fffff0,
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
+	.driver_data	= &ksz8081_type,
+	.probe		= kszphy_probe,
 	.config_init	= ksz8081_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
-- 
2.0.4
