From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCH net-next 22/24] mdio: Abstract device_remove() and device_free()
Date: Mon,  4 Jan 2016 18:37:00 +0100
Message-ID: <1451929022-5580-23-git-send-email-andrew@lunn.ch>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35029 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752025AbcADRkD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2016 12:40:03 -0500
In-Reply-To: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make device_free and device_remove operations in the mdio device
structure, so the core code does not need to differentiate between
phy devices and generic mdio devices.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/mdio_bus.c    | 23 +++++++++--------------
 drivers/net/phy/mdio_device.c |  2 ++
 drivers/net/phy/phy_device.c  | 18 ++++++++++++++++++
 include/linux/mdio.h          |  4 ++++
 4 files changed, 33 insertions(+), 14 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 0573cfd2116f..0be7b3d65f0f 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -299,6 +299,7 @@ static inline void of_mdiobus_link_mdiodev(struct mii_bus *mdio,
  */
 int __mdiobus_register(struct mii_bus *bus, struct module *owner)
 {
+	struct mdio_device *mdiodev;
 	int i, err;
 
 	if (NULL == bus || NULL == bus->name ||
@@ -344,11 +345,12 @@ int __mdiobus_register(struct mii_bus *bus, struct module *owner)
 
 error:
 	while (--i >= 0) {
-		struct phy_device *phydev = mdiobus_get_phy(bus, i);
-		if (phydev) {
-			phy_device_remove(phydev);
-			phy_device_free(phydev);
-		}
+		mdiodev = bus->mdio_map[i];
+		if (!mdiodev)
+			continue;
+
+		mdiodev->device_remove(mdiodev);
+		mdiodev->device_free(mdiodev);
 	}
 	device_del(&bus->dev);
 	return err;
@@ -358,7 +360,6 @@ EXPORT_SYMBOL(__mdiobus_register);
 void mdiobus_unregister(struct mii_bus *bus)
 {
 	struct mdio_device *mdiodev;
-	struct phy_device *phydev;
 	int i;
 
 	BUG_ON(bus->state != MDIOBUS_REGISTERED);
@@ -369,14 +370,8 @@ void mdiobus_unregister(struct mii_bus *bus)
 		if (!mdiodev)
 			continue;
 
-		if (!(mdiodev->flags & MDIO_DEVICE_FLAG_PHY)) {
-			phydev = container_of(mdiodev, struct phy_device, mdio);
-			phy_device_remove(phydev);
-			phy_device_free(phydev);
-		} else {
-			mdio_device_remove(mdiodev);
-			mdio_device_free(mdiodev);
-		}
+		mdiodev->device_remove(mdiodev);
+		mdiodev->device_free(mdiodev);
 	}
 	device_del(&bus->dev);
 }
diff --git a/drivers/net/phy/mdio_device.c b/drivers/net/phy/mdio_device.c
index 64e3777c85b4..9c88e6749b9a 100644
--- a/drivers/net/phy/mdio_device.c
+++ b/drivers/net/phy/mdio_device.c
@@ -46,6 +46,8 @@ struct mdio_device *mdio_device_create(struct mii_bus *bus, int addr)
 	mdiodev->dev.release = mdio_device_release;
 	mdiodev->dev.parent = &bus->dev;
 	mdiodev->dev.bus = &mdio_bus_type;
+	mdiodev->device_free = mdio_device_free;
+	mdiodev->device_remove = mdio_device_remove;
 	mdiodev->bus = bus;
 	mdiodev->addr = addr;
 
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index b9a1bed29ea9..839f4f4b2940 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -47,11 +47,27 @@ void phy_device_free(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(phy_device_free);
 
+static void phy_mdio_device_free(struct mdio_device *mdiodev)
+{
+	struct phy_device *phydev;
+
+	phydev = container_of(mdiodev, struct phy_device, mdio);
+	phy_device_free(phydev);
+}
+
 static void phy_device_release(struct device *dev)
 {
 	kfree(to_phy_device(dev));
 }
 
+static void phy_mdio_device_remove(struct mdio_device *mdiodev)
+{
+	struct phy_device *phydev;
+
+	phydev = container_of(mdiodev, struct phy_device, mdio);
+	phy_device_remove(phydev);
+}
+
 enum genphy_driver {
 	GENPHY_DRV_1G,
 	GENPHY_DRV_10G,
@@ -308,6 +324,8 @@ struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
 	mdiodev->bus_match = phy_bus_match;
 	mdiodev->addr = addr;
 	mdiodev->flags = MDIO_DEVICE_FLAG_PHY;
+	mdiodev->device_free = phy_mdio_device_free;
+	mdiodev->device_remove = phy_mdio_device_remove;
 
 	dev->speed = 0;
 	dev->duplex = -1;
diff --git a/include/linux/mdio.h b/include/linux/mdio.h
index 75f7fad0af4f..5bfd99d1a40a 100644
--- a/include/linux/mdio.h
+++ b/include/linux/mdio.h
@@ -18,7 +18,11 @@ struct mdio_device {
 
 	const struct dev_pm_ops *pm_ops;
 	struct mii_bus *bus;
+
 	int (*bus_match)(struct device *dev, struct device_driver *drv);
+	void (*device_free)(struct mdio_device *mdiodev);
+	void (*device_remove)(struct mdio_device *mdiodev);
+
 	/* Bus address of the MDIO device (0-31) */
 	int addr;
 	int flags;
-- 
2.6.4
