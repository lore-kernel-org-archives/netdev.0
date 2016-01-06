From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 18/22] phy: Move phy specific bus match into phy_device
Date: Wed,  6 Jan 2016 20:11:23 +0100
Message-ID: <1452107487-475-19-git-send-email-andrew@lunn.ch>
References: <1452107487-475-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42317 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751653AbcAFTMQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2016 14:12:16 -0500
In-Reply-To: <1452107487-475-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matching a driver to a device has both generic parts, and parts which
are specific to PHY devices. Move the PHY specific parts into
phy_device.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/mdio_bus.c   | 38 ++++++++++++--------------------------
 drivers/net/phy/phy_device.c | 28 ++++++++++++++++++++++++++++
 include/linux/mdio.h         |  1 +
 3 files changed, 41 insertions(+), 26 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 65ff8199bd09..bd523b2c6331 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -523,41 +523,27 @@ int mdiobus_write(struct mii_bus *bus, int addr, u32 regnum, u16 val)
 EXPORT_SYMBOL(mdiobus_write);
 
 /**
- * mdio_bus_match - determine if given PHY driver supports the given PHY device
- * @dev: target PHY device
- * @drv: given PHY driver
+ * mdio_bus_match - determine if given MDIO driver supports the given
+ *		    MDIO device
+ * @dev: target MDIO device
+ * @drv: given MDIO driver
  *
- * Description: Given a PHY device, and a PHY driver, return 1 if
- *   the driver supports the device.  Otherwise, return 0.
+ * Description: Given a MDIO device, and a MDIO driver, return 1 if
+ *   the driver supports the device.  Otherwise, return 0. This may
+ *   require calling the devices own match function, since different classes
+ *   of MDIO devices have different match criteria.
  */
 static int mdio_bus_match(struct device *dev, struct device_driver *drv)
 {
-	struct phy_device *phydev = to_phy_device(dev);
-	struct phy_driver *phydrv = to_phy_driver(drv);
-	const int num_ids = ARRAY_SIZE(phydev->c45_ids.device_ids);
-	int i;
+	struct mdio_device *mdio = to_mdio_device(dev);
 
 	if (of_driver_match_device(dev, drv))
 		return 1;
 
-	if (phydrv->match_phy_device)
-		return phydrv->match_phy_device(phydev);
+	if (mdio->bus_match)
+		return mdio->bus_match(dev, drv);
 
-	if (phydev->is_c45) {
-		for (i = 1; i < num_ids; i++) {
-			if (!(phydev->c45_ids.devices_in_package & (1 << i)))
-				continue;
-
-			if ((phydrv->phy_id & phydrv->phy_id_mask) ==
-			    (phydev->c45_ids.device_ids[i] &
-			     phydrv->phy_id_mask))
-				return 1;
-		}
-		return 0;
-	} else {
-		return (phydrv->phy_id & phydrv->phy_id_mask) ==
-			(phydev->phy_id & phydrv->phy_id_mask);
-	}
+	return 0;
 }
 
 #ifdef CONFIG_PM
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index a1b833cd4183..78628428ee28 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -257,6 +257,33 @@ static int phy_scan_fixups(struct phy_device *phydev)
 	return 0;
 }
 
+static int phy_bus_match(struct device *dev, struct device_driver *drv)
+{
+	struct phy_device *phydev = to_phy_device(dev);
+	struct phy_driver *phydrv = to_phy_driver(drv);
+	const int num_ids = ARRAY_SIZE(phydev->c45_ids.device_ids);
+	int i;
+
+	if (phydrv->match_phy_device)
+		return phydrv->match_phy_device(phydev);
+
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
+}
+
 struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
 				     bool is_c45,
 				     struct phy_c45_device_ids *c45_ids)
@@ -275,6 +302,7 @@ struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
 	mdiodev->dev.bus = &mdio_bus_type;
 	mdiodev->bus = bus;
 	mdiodev->pm_ops = MDIO_BUS_PHY_PM_OPS;
+	mdiodev->bus_match = phy_bus_match;
 	mdiodev->addr = addr;
 	mdiodev->flags = MDIO_DEVICE_FLAG_PHY;
 
diff --git a/include/linux/mdio.h b/include/linux/mdio.h
index 9f844d372ed5..0690359e55a5 100644
--- a/include/linux/mdio.h
+++ b/include/linux/mdio.h
@@ -17,6 +17,7 @@ struct mdio_device {
 	struct device dev;
 	const struct dev_pm_ops *pm_ops;
 	struct mii_bus *bus;
+	int (*bus_match)(struct device *dev, struct device_driver *drv);
 	/* Bus address of the MDIO device (0-31) */
 	int addr;
 	int flags;
-- 
2.6.4
