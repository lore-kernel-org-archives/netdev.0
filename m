From: Johan Hovold <johan@kernel.org>
Subject: [PATCH] net: phy: micrel: use generic config_init for KSZ8021/KSZ8031
Date: Tue, 23 Dec 2014 12:59:17 +0100
Message-ID: <1419335957-18020-1-git-send-email-johan@kernel.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Bruno Thomsen <bth@kamstrup.dk>,
	Johan Hovold <johan@kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use generic config_init callback also for KSZ8021 and KSZ8031.

This has been avoided this far due to commit b838b4aced99 ("phy/micrel:
KSZ8031RNL RMII clock reconfiguration bug"), which claims that the PHY
becomes unresponsive if the broadcast-disable flag is set before
configuring the clock mode.

Turns out that the problem seemingly worked-around by the above
mentioned commit was really due to a hardware-configuration issue, where
the PHY was in fact strapped to address 3 rather than 0.

Tested-by: Bruno Thomsen <bth@kamstrup.dk>
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/phy/micrel.c | 18 +++---------------
 1 file changed, 3 insertions(+), 15 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index c530de1e63f5..3ad8ca76196d 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -88,6 +88,7 @@ struct kszphy_priv {
 
 static const struct kszphy_type ksz8021_type = {
 	.led_mode_reg		= MII_KSZPHY_CTRL_2,
+	.has_broadcast_disable	= true,
 	.has_rmii_ref_clk_sel	= true,
 };
 
@@ -258,19 +259,6 @@ static int kszphy_config_init(struct phy_device *phydev)
 	return 0;
 }
 
-static int ksz8021_config_init(struct phy_device *phydev)
-{
-	int rc;
-
-	rc = kszphy_config_init(phydev);
-	if (rc)
-		return rc;
-
-	rc = kszphy_broadcast_disable(phydev);
-
-	return rc < 0 ? rc : 0;
-}
-
 static int ksz9021_load_values_from_of(struct phy_device *phydev,
 				       struct device_node *of_node, u16 reg,
 				       char *field1, char *field2,
@@ -584,7 +572,7 @@ static struct phy_driver ksphy_driver[] = {
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.driver_data	= &ksz8021_type,
 	.probe		= kszphy_probe,
-	.config_init	= ksz8021_config_init,
+	.config_init	= kszphy_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
@@ -601,7 +589,7 @@ static struct phy_driver ksphy_driver[] = {
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.driver_data	= &ksz8021_type,
 	.probe		= kszphy_probe,
-	.config_init	= ksz8021_config_init,
+	.config_init	= kszphy_config_init,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
-- 
2.0.5
