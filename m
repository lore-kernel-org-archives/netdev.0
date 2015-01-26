From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH net-next 1/1] net: phy: unbind phy device from generic and specifical driver
Date: Mon, 26 Jan 2015 16:14:05 +0800
Message-ID: <1422260045-22527-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <s.hauer@pengutronix.de>,
	<f.fainelli@gmail.com>, <bhutchings@solarflare.com>,
	<stephen@networkplumber.org>, <b38611@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0125.outbound.protection.outlook.com ([207.46.100.125]:49900
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750793AbbAZIa6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jan 2015 03:30:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current .phy_detach() function only unbind generic phy driver, which causes
specifical driver suspend/resume function still work like Atheros AT803X PHYs.

For example:
ifconfig eth0 down
echo mem > /sys/power/status

After eth0 interface down, driver call phy_detach to unbind phy driver, and then
do suspend/resume operation, at803x_suspend()/at803x_resume() functions still get
called that call mdio bus read/write function. When eth0 interface down, MAC driver
may close all clocks and mdio bus cannot work. So the issue happens.

The patch can unbind generic and specifical driver.

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 drivers/net/phy/phy_device.c |   15 ++-------------
 1 files changed, 2 insertions(+), 13 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 3fc91e8..8adbc5d 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -672,8 +672,6 @@ EXPORT_SYMBOL(phy_attach);
  */
 void phy_detach(struct phy_device *phydev)
 {
-	int i;
-
 	if (phydev->bus->dev.driver)
 		module_put(phydev->bus->dev.driver->owner);
 
@@ -681,17 +679,8 @@ void phy_detach(struct phy_device *phydev)
 	phydev->attached_dev = NULL;
 	phy_suspend(phydev);
 
-	/* If the device had no specific driver before (i.e. - it
-	 * was using the generic driver), we unbind the device
-	 * from the generic driver so that there's a chance a
-	 * real driver could be loaded
-	 */
-	for (i = 0; i < ARRAY_SIZE(genphy_driver); i++) {
-		if (phydev->dev.driver == &genphy_driver[i].driver) {
-			device_release_driver(&phydev->dev);
-			break;
-		}
-	}
+	if (phydev->dev.driver)
+		device_release_driver(&phydev->dev);
 }
 EXPORT_SYMBOL(phy_detach);
 
-- 
1.7.8
