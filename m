From: Shengzhou Liu <Shengzhou.Liu@freescale.com>
Subject: [PATCH] net/phy: refactor RTL8211F initialization
Date: Wed, 22 Apr 2015 18:22:00 +0800
Message-ID: <1429698120-17882-1-git-send-email-Shengzhou.Liu@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shengzhou Liu <Shengzhou.Liu@freescale.com>
To: <netdev@vger.kernel.org>, <joe.hershberger@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0123.outbound.protection.outlook.com ([65.55.169.123]:34112
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752465AbbDVKZ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Apr 2015 06:25:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RTL8211F needs to enalbe TXDLY for RGMII during
phy initialization, so move it to rtl8211f_config
for early initialization.

Signed-off-by: Shengzhou Liu <Shengzhou.Liu@freescale.com>
cc: Joe Hershberger <joe.hershberger@gmail.com>
---
 drivers/net/phy/realtek.c | 25 +++++++++++++++++--------
 1 file changed, 17 insertions(+), 8 deletions(-)

diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
index 3917c82..d48095b 100644
--- a/drivers/net/phy/realtek.c
+++ b/drivers/net/phy/realtek.c
@@ -43,6 +43,22 @@ static int rtl8211x_config(struct phy_device *phydev)
 	return 0;
 }
 
+static int rtl8211f_config(struct phy_device *phydev)
+{
+	phy_write(phydev, MDIO_DEVAD_NONE, MII_BMCR, BMCR_RESET);
+
+	if (phydev->interface == PHY_INTERFACE_MODE_RGMII) {
+		/* enable TXDLY */
+		phy_write(phydev, MDIO_DEVAD_NONE,
+			  MIIM_RTL8211F_PAGE_SELECT, 0xd08);
+		phy_write(phydev, MDIO_DEVAD_NONE, 0x11, 0x109);
+	}
+
+	genphy_config_aneg(phydev);
+
+	return 0;
+}
+
 static int rtl8211x_parse_status(struct phy_device *phydev)
 {
 	unsigned int speed;
@@ -142,13 +158,6 @@ static int rtl8211f_parse_status(struct phy_device *phydev)
 		phydev->speed = SPEED_10;
 	}
 
-	if (phydev->interface == PHY_INTERFACE_MODE_RGMII) {
-		/* enable TXDLY */
-		phy_write(phydev, MDIO_DEVAD_NONE,
-			  MIIM_RTL8211F_PAGE_SELECT, 0xd08);
-		phy_write(phydev, MDIO_DEVAD_NONE, 0x11, 0x109);
-	}
-
 	return 0;
 }
 
@@ -209,7 +218,7 @@ static struct phy_driver RTL8211F_driver = {
 	.uid = 0x1cc916,
 	.mask = 0xffffff,
 	.features = PHY_GBIT_FEATURES,
-	.config = &rtl8211x_config,
+	.config = &rtl8211f_config,
 	.startup = &rtl8211f_startup,
 	.shutdown = &genphy_shutdown,
 };
-- 
2.1.0.27.g96db324
