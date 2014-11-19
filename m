From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 04/10] net: phy: micrel: add has-broadcast-disable flag to type data
Date: Wed, 19 Nov 2014 12:59:17 +0100
Message-ID: <1416398363-32306-5-git-send-email-johan@kernel.org>
References: <1416398363-32306-1-git-send-email-johan@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Bruno Thomsen <bth@kamstrup.dk>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Mark Rutland <mark.rutland@arm.com>,
	Johan Hovold <johan@kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:54447 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753133AbaKSL7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 06:59:49 -0500
In-Reply-To: <1416398363-32306-1-git-send-email-johan@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add has_broadcast_disable flag to type-data and generic config_init.

This allows us to remove the ksz8081 config_init callback.

Note that ksz8021_config_init is kept for now due to a95a18afe4c8
("phy/micrel: KSZ8031RNL RMII clock reconfiguration bug").

Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/phy/micrel.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 6a81aaca5b1c..a0e944099020 100644
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
@@ -692,7 +690,7 @@ static struct phy_driver ksphy_driver[] = {
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
