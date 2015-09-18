From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH 2/7] phy: fix mdiobus module safety
Date: Fri, 18 Sep 2015 10:55:01 +0100
Message-ID: <E1ZcsNh-0001Bl-9h@rmk-PC.arm.linux.org.uk>
References: <20150918094625.GB21084@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: devicetree@vger.kernel.org, Frank Rowand <frowand.list@gmail.com>,
	Grant Likely <grant.likely@linaro.org>,
	Iyappan Subramanian <isubramanian@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, Li Yang <leoli@freescale.com>,
	Michal Simek <michal.simek@xilinx.com>, netdev@vger.kernel.org,
	Robert Richter <rric@kernel.org>,
	Rob Herring <robh+dt@kernel.org>,
	"Soren Brinkmann" <soren.brinkmann@xilinx.com>,
	Sunil Goutham <sgoutham@cavium.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150918094625.GB21084@n2100.arm.linux.org.uk>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Re-implement the mdiobus module refcounting to ensure that we actually
ensure that the mdiobus module code does not go away while we might call
into it.

The old scheme using bus->dev.driver was buggy, because bus->dev is a
class device which never has a struct device_driver associated with it,
and hence the associated code trying to obtain a refcount did nothing
useful.

Instead, take the approach that other subsystems do: pass the module
when calling mdiobus_register(), and record that in the mii_bus struct.
When we need to increment the module use count in the phy code, use
this stored pointer.  When the phy is deteched, drop the module
refcount, remembering that the phy device might go away at that point.

This doesn't stop the mii_bus going away while there are in-use phys -
it merely stops the underlying code vanishing.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/phy/mdio_bus.c   |  5 +++--
 drivers/net/phy/phy_device.c | 32 ++++++++++++++++++--------------
 include/linux/phy.h          |  5 ++++-
 3 files changed, 25 insertions(+), 17 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 67553e13bd36..992406624b7c 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -244,7 +244,7 @@ static inline void of_mdiobus_link_phydev(struct mii_bus *mdio,
  *
  * Returns 0 on success or < 0 on error.
  */
-int mdiobus_register(struct mii_bus *bus)
+int __mdiobus_register(struct mii_bus *bus, struct module *owner)
 {
 	int i, err;
 
@@ -255,6 +255,7 @@ int mdiobus_register(struct mii_bus *bus)
 	BUG_ON(bus->state != MDIOBUS_ALLOCATED &&
 	       bus->state != MDIOBUS_UNREGISTERED);
 
+	bus->owner = owner;
 	bus->dev.parent = bus->parent;
 	bus->dev.class = &mdio_bus_class;
 	bus->dev.groups = NULL;
@@ -296,7 +297,7 @@ int mdiobus_register(struct mii_bus *bus)
 	device_del(&bus->dev);
 	return err;
 }
-EXPORT_SYMBOL(mdiobus_register);
+EXPORT_SYMBOL(__mdiobus_register);
 
 void mdiobus_unregister(struct mii_bus *bus)
 {
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index c0f211127274..03adf328f49b 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -582,10 +582,15 @@ EXPORT_SYMBOL(phy_init_hw);
 int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 		      u32 flags, phy_interface_t interface)
 {
+	struct mii_bus *bus = phydev->bus;
 	struct device *d = &phydev->dev;
-	struct module *bus_module;
 	int err;
 
+	if (!try_module_get(bus->owner)) {
+		dev_err(&dev->dev, "failed to get the bus module\n");
+		return -EIO;
+	}
+
 	/* Assume that if there is no driver, that it doesn't
 	 * exist, and we should use the genphy driver.
 	 */
@@ -600,20 +605,13 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 			err = device_bind_driver(d);
 
 		if (err)
-			return err;
+			goto error;
 	}
 
 	if (phydev->attached_dev) {
 		dev_err(&dev->dev, "PHY already attached\n");
-		return -EBUSY;
-	}
-
-	/* Increment the bus module reference count */
-	bus_module = phydev->bus->dev.driver ?
-		     phydev->bus->dev.driver->owner : NULL;
-	if (!try_module_get(bus_module)) {
-		dev_err(&dev->dev, "failed to get the bus module\n");
-		return -EIO;
+		err = -EBUSY;
+		goto error;
 	}
 
 	phydev->attached_dev = dev;
@@ -636,6 +634,10 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 		phy_resume(phydev);
 
 	return err;
+
+error:
+	module_put(bus->owner);
+	return err;
 }
 EXPORT_SYMBOL(phy_attach_direct);
 
@@ -680,11 +682,9 @@ EXPORT_SYMBOL(phy_attach);
  */
 void phy_detach(struct phy_device *phydev)
 {
+	struct mii_bus *bus;
 	int i;
 
-	if (phydev->bus->dev.driver)
-		module_put(phydev->bus->dev.driver->owner);
-
 	phydev->attached_dev->phydev = NULL;
 	phydev->attached_dev = NULL;
 	phy_suspend(phydev);
@@ -700,6 +700,10 @@ void phy_detach(struct phy_device *phydev)
 			break;
 		}
 	}
+
+	bus = phydev->bus;
+
+	module_put(bus->owner);
 }
 EXPORT_SYMBOL(phy_detach);
 
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 962387a192f1..11bce44f6d65 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -19,6 +19,7 @@
 #include <linux/spinlock.h>
 #include <linux/ethtool.h>
 #include <linux/mii.h>
+#include <linux/module.h>
 #include <linux/timer.h>
 #include <linux/workqueue.h>
 #include <linux/mod_devicetable.h>
@@ -153,6 +154,7 @@ struct sk_buff;
  * PHYs should register using this structure
  */
 struct mii_bus {
+	struct module *owner;
 	const char *name;
 	char id[MII_BUS_ID_SIZE];
 	void *priv;
@@ -198,7 +200,8 @@ static inline struct mii_bus *mdiobus_alloc(void)
 	return mdiobus_alloc_size(0);
 }
 
-int mdiobus_register(struct mii_bus *bus);
+int __mdiobus_register(struct mii_bus *bus, struct module *owner);
+#define mdiobus_register(bus) __mdiobus_register(bus, THIS_MODULE)
 void mdiobus_unregister(struct mii_bus *bus);
 void mdiobus_free(struct mii_bus *bus);
 struct mii_bus *devm_mdiobus_alloc_size(struct device *dev, int sizeof_priv);
-- 
2.1.0
