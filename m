From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCHv2 3/3] phylib: give mdio buses a device tree presence
Date: Thu, 2 Oct 2008 03:42:01 +0200
Message-ID: <20081002014201.GD26575@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Byron Bradley <byron.bbradley@gmail.com>,
	Tim Ellis <tim.ellis@mac.com>, Imre Kaloz <kaloz@openwrt.org>,
	Nicolas Pitre <nico@cam.org>, Dirk Teurlings <dirk@upexia.nl>,
	Peter van Valderen <p.v.valderen@gmail.com>
To: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:42403 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853AbYJBBmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 21:42:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce the mdio_bus class, and give each 'struct mii_bus' its own
'struct device', so that mii_bus objects are represented in the device
tree and can be found by querying the device tree.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/phy/mdio_bus.c |   75 +++++++++++++++++++++++++++++++++++++++++--
 include/linux/phy.h        |    8 +++++
 2 files changed, 79 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index e889a06..6671e2d 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -43,11 +43,35 @@
  */
 struct mii_bus *mdiobus_alloc(void)
 {
-	return kzalloc(sizeof(struct mii_bus), GFP_KERNEL);
+	struct mii_bus *bus;
+
+	bus = kzalloc(sizeof(*bus), GFP_KERNEL);
+	if (bus != NULL)
+		bus->state = MDIOBUS_ALLOCATED;
+
+	return bus;
 }
 EXPORT_SYMBOL(mdiobus_alloc);
 
 /**
+ * mdiobus_release - mii_bus device release callback
+ *
+ * Description: called when the last reference to an mii_bus is
+ * dropped, to free the underlying memory.
+ */
+static void mdiobus_release(struct device *d)
+{
+	struct mii_bus *bus = to_mii_bus(d);
+	BUG_ON(bus->state != MDIOBUS_RELEASED);
+	kfree(bus);
+}
+
+static struct class mdio_bus_class = {
+	.name		= "mdio_bus",
+	.dev_release	= mdiobus_release,
+};
+
+/**
  * mdiobus_register - bring up all the PHYs on a given bus and attach them to bus
  * @bus: target mii_bus
  *
@@ -66,6 +90,22 @@ int mdiobus_register(struct mii_bus *bus)
 			NULL == bus->write)
 		return -EINVAL;
 
+	BUG_ON(bus->state != MDIOBUS_ALLOCATED &&
+	       bus->state != MDIOBUS_UNREGISTERED);
+
+	bus->dev.parent = bus->parent;
+	bus->dev.class = &mdio_bus_class;
+	bus->dev.groups = NULL;
+	memcpy(bus->dev.bus_id, bus->id, MII_BUS_ID_SIZE);
+
+	err = device_register(&bus->dev);
+	if (err) {
+		printk(KERN_ERR "mii_bus %s failed to register\n", bus->id);
+		return -EINVAL;
+	}
+
+	bus->state = MDIOBUS_REGISTERED;
+
 	mutex_init(&bus->mdio_lock);
 
 	if (bus->reset)
@@ -92,6 +132,10 @@ void mdiobus_unregister(struct mii_bus *bus)
 {
 	int i;
 
+	BUG_ON(bus->state != MDIOBUS_REGISTERED);
+	bus->state = MDIOBUS_UNREGISTERED;
+
+	device_unregister(&bus->dev);
 	for (i = 0; i < PHY_MAX_ADDR; i++) {
 		if (bus->phy_map[i])
 			device_unregister(&bus->phy_map[i]->dev);
@@ -103,11 +147,24 @@ EXPORT_SYMBOL(mdiobus_unregister);
  * mdiobus_free - free a struct mii_bus
  * @bus: mii_bus to free
  *
- * This function frees the mii_bus.
+ * This function releases the reference to the underlying device
+ * object in the mii_bus.  If this is the last reference, the mii_bus
+ * will be freed.
  */
 void mdiobus_free(struct mii_bus *bus)
 {
-	kfree(bus);
+	/*
+	 * For compatibility with error handling in drivers.
+	 */
+	if (bus->state == MDIOBUS_ALLOCATED) {
+		kfree(bus);
+		return;
+	}
+
+	BUG_ON(bus->state != MDIOBUS_UNREGISTERED);
+	bus->state = MDIOBUS_RELEASED;
+
+	put_device(&bus->dev);
 }
 EXPORT_SYMBOL(mdiobus_free);
 
@@ -254,10 +311,20 @@ EXPORT_SYMBOL(mdio_bus_type);
 
 int __init mdio_bus_init(void)
 {
-	return bus_register(&mdio_bus_type);
+	int ret;
+
+	ret = class_register(&mdio_bus_class);
+	if (!ret) {
+		ret = bus_register(&mdio_bus_type);
+		if (ret)
+			class_unregister(&mdio_bus_class);
+	}
+
+	return ret;
 }
 
 void mdio_bus_exit(void)
 {
+	class_unregister(&mdio_bus_class);
 	bus_unregister(&mdio_bus_type);
 }
diff --git a/include/linux/phy.h b/include/linux/phy.h
index e6c46c8..77c4ed6 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -100,6 +100,13 @@ struct mii_bus {
 	struct mutex mdio_lock;
 
 	struct device *parent;
+	enum {
+		MDIOBUS_ALLOCATED = 1,
+		MDIOBUS_REGISTERED,
+		MDIOBUS_UNREGISTERED,
+		MDIOBUS_RELEASED,
+	} state;
+	struct device dev;
 
 	/* list of all PHYs on bus */
 	struct phy_device *phy_map[PHY_MAX_ADDR];
@@ -113,6 +120,7 @@ struct mii_bus {
 	 */
 	int *irq;
 };
+#define to_mii_bus(d) container_of(d, struct mii_bus, dev)
 
 struct mii_bus *mdiobus_alloc(void);
 int mdiobus_register(struct mii_bus *bus);
-- 
1.5.6.4
