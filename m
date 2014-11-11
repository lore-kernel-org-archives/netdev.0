From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 16/22] net: phy: micrel: add has-broadcast-disable flag to type data
Date: Tue, 11 Nov 2014 18:37:34 +0100
Message-ID: <1415727460-20417-17-git-send-email-johan@kernel.org>
References: <1415727460-20417-1-git-send-email-johan@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Johan Hovold <johan@kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415727460-20417-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add has_broadcast_disable flag to type-data and generic config_init.

This allows us to remove the ksz8081 config_init callback.

Note that ksz8021_config_init is kept for now due to a95a18afe4c8
("phy/micrel: KSZ8031RNL RMII clock reconfiguration bug").

Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/phy/micrel.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 928248187a11..6467bcc5a39d 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -75,6 +75,7 @@
 
 struct kszphy_type {
 	u32 led_mode_reg;
+	bool has_broadcast_disable;
 };
 
 struct kszphy_priv {
@@ -96,6 +97,7 @@ static const struct kszphy_type ksz8051_type = {
 
 static const struct kszphy_type ksz8081_type = {
 	.led_mode_reg		= MII_KSZPHY_CTRL_2,
+	.has_broadcast_disable	= true,
 };
 
 static int ksz_config_flags(struct phy_device *phydev)
@@ -247,6 +249,9 @@ static int kszphy_config_init(struct phy_device *phydev)
 
 	type = priv->type;
 
+	if (type->has_broadcast_disable)
+		kszphy_broadcast_disable(phydev);
+
 	if (priv->led_mode >= 0)
 		kszphy_setup_led(phydev, type->led_mode_reg, priv->led_mode);
 
@@ -278,13 +283,6 @@ static int ks8051_config_init(struct phy_device *phydev)
 	return rc < 0 ? rc : 0;
 }
 
-static int ksz8081_config_init(struct phy_device *phydev)
-{
-	kszphy_broadcast_disable(phydev);
-
-	return kszphy_config_init(phydev);
-}
-
 static int ksz9021_load_values_from_of(struct phy_device *phydev,
 				       struct device_node *of_node, u16 reg,
 				       char *field1, char *field2,
@@ -691,7 +689,7 @@ static struct phy_driver ksphy_driver[] = {
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.driver_data	= &ksz8081_type,
 	.probe		= kszphy_probe,
-	.config_init	= ksz8081_config_init,
+	.config_init	= kszphy_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
-- 
2.0.4
