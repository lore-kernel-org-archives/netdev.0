From: <shh.xie@gmail.com>
Subject: [PATCH] net/mdio: fix mdio_bus_match for c45 PHY
Date: Fri, 17 Jul 2015 18:07:19 +0800
Message-ID: <1437127639-48082-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shaohui Xie <Shaohui.Xie@freescale.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0057.outbound.protection.outlook.com ([65.55.169.57]:3185
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757213AbbGQK1d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jul 2015 06:27:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohui Xie <Shaohui.Xie@freescale.com>

We store c45 PHY's id information in c45_ids, so it should be used to
check the matching between PHY driver and PHY device for c45 PHY.

Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
---
 drivers/net/phy/mdio_bus.c | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 095ef3f..46a14cb 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -421,6 +421,8 @@ static int mdio_bus_match(struct device *dev, struct device_driver *drv)
 {
 	struct phy_device *phydev = to_phy_device(dev);
 	struct phy_driver *phydrv = to_phy_driver(drv);
+	const int num_ids = ARRAY_SIZE(phydev->c45_ids.device_ids);
+	int i;
 
 	if (of_driver_match_device(dev, drv))
 		return 1;
@@ -428,8 +430,21 @@ static int mdio_bus_match(struct device *dev, struct device_driver *drv)
 	if (phydrv->match_phy_device)
 		return phydrv->match_phy_device(phydev);
 
-	return (phydrv->phy_id & phydrv->phy_id_mask) ==
-		(phydev->phy_id & phydrv->phy_id_mask);
+	if (phydev->is_c45) {
+		for (i = 1; i < num_ids; i++) {
+			if (!(phydev->c45_ids.devices_in_package & (1 << i)))
+				continue;
+
+			if ((phydrv->phy_id & phydrv->phy_id_mask) ==
+			    (phydev->c45_ids.device_ids[i] &
+			     phydrv->phy_id_mask))
+				return 1;
+		}
+		return 0;
+	} else {
+		return (phydrv->phy_id & phydrv->phy_id_mask) ==
+			(phydev->phy_id & phydrv->phy_id_mask);
+	}
 }
 
 #ifdef CONFIG_PM
-- 
2.1.0.27.g96db324
