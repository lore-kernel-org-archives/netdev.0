From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH RFC v1 4/7] net: phy: suspend unused PHYs on mdio_bus in late_initcall
Date: Wed, 20 Nov 2013 21:21:50 +0100
Message-ID: <1384978913-8052-5-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1384978913-8052-1-git-send-email-sebastian.hesselbarth@gmail.com>
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:36683 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755149Ab3KTUWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 15:22:03 -0500
In-Reply-To: <1384978913-8052-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since phy_attach ensures PHYs are resumed, we can now suspend all
PHYs that have no attached netdev after initcalls.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
---
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/phy/mdio_bus.c |   27 +++++++++++++++++++++++++++
 1 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 5617876..10eba58 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -320,6 +320,33 @@ static int mdio_bus_match(struct device *dev, struct device_driver *drv)
 		(phydev->phy_id & phydrv->phy_id_mask));
 }
 
+static int mdio_bus_suspend_unused(struct device *busdev, void *data)
+{
+	struct mii_bus *bus = to_mii_bus(busdev);
+	struct phy_device *phydev;
+	struct phy_driver *phydrv;
+	int i;
+
+	for (i = 0; i < PHY_MAX_ADDR; i++) {
+		if (!bus->phy_map[i])
+			continue;
+
+		phydev = to_phy_device(&bus->phy_map[i]->dev);
+		phydrv = to_phy_driver(phydev->dev.driver);
+		if (!phydev->attached_dev && phydrv && phydrv->suspend)
+			phy_suspend(phydev);
+	}
+
+	return 0;
+}
+
+static int mdio_bus_class_suspend_unused(void)
+{
+	return class_for_each_device(&mdio_bus_class, NULL, NULL,
+				     mdio_bus_suspend_unused);
+}
+late_initcall_sync(mdio_bus_class_suspend_unused);
+
 #ifdef CONFIG_PM
 
 static bool mdio_bus_phy_may_suspend(struct phy_device *phydev)
-- 
1.7.2.5
