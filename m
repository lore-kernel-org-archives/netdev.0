From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH respin] phy: implement release function
Date: Thu, 11 Oct 2007 16:49:05 +0400
Message-ID: <20071011124905.GC13963@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755267AbXJKMtF@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lately I've got this nice badness on mdio bus removal:

Device 'e0103120:06' does not have a release() function, it is broken and must be fixed.
------------[ cut here ]------------
Badness at drivers/base/core.c:107
NIP: c015c1a8 LR: c015c1a8 CTR: c0157488
REGS: c34bdcf0 TRAP: 0700   Not tainted  (2.6.23-rc5-g9ebadfbb-dirty)
MSR: 00029032 <EE,ME,IR,DR>  CR: 24088422  XER: 00000000
...
[c34bdda0] [c015c1a8] device_release+0x78/0x80 (unreliable)
[c34bddb0] [c01354cc] kobject_cleanup+0x80/0xbc
[c34bddd0] [c01365f0] kref_put+0x54/0x6c
[c34bdde0] [c013543c] kobject_put+0x24/0x34
[c34bddf0] [c015c384] put_device+0x1c/0x2c
[c34bde00] [c0180e84] mdiobus_unregister+0x2c/0x58
...

Though actually there is nothing broken, it just device
subsystem core expects another "pattern" of resource managment.

This patch implement phy device's release function, thus
we're getting rid of this badness.

Also small hidden bug fixed, hope none other introduced. ;-)

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
Acked-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/phy/mdio_bus.c   |    9 +++++----
 drivers/net/phy/phy_device.c |   13 +++++++++++++
 include/linux/phy.h          |    1 +
 3 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index fc2f0e6..c30196d 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -91,9 +91,12 @@ int mdiobus_register(struct mii_bus *bus)
 
 			err = device_register(&phydev->dev);
 
-			if (err)
+			if (err) {
 				printk(KERN_ERR "phy %d failed to register\n",
 						i);
+				phy_device_free(phydev);
+				phydev = NULL;
+			}
 		}
 
 		bus->phy_map[i] = phydev;
@@ -110,10 +113,8 @@ void mdiobus_unregister(struct mii_bus *bus)
 	int i;
 
 	for (i = 0; i < PHY_MAX_ADDR; i++) {
-		if (bus->phy_map[i]) {
+		if (bus->phy_map[i])
 			device_unregister(&bus->phy_map[i]->dev);
-			kfree(bus->phy_map[i]);
-		}
 	}
 }
 EXPORT_SYMBOL(mdiobus_unregister);
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 49328e0..8e25bf7 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -44,6 +44,17 @@ static struct phy_driver genphy_driver;
 extern int mdio_bus_init(void);
 extern void mdio_bus_exit(void);
 
+void phy_device_free(struct phy_device *phydev)
+{
+	kfree(phydev);
+}
+EXPORT_SYMBOL(phy_device_free);
+
+static void phy_device_release(struct device *dev)
+{
+	phy_device_free(to_phy_device(dev));
+}
+
 struct phy_device* phy_device_create(struct mii_bus *bus, int addr, int phy_id)
 {
 	struct phy_device *dev;
@@ -54,6 +65,8 @@ struct phy_device* phy_device_create(struct mii_bus *bus, int addr, int phy_id)
 	if (NULL == dev)
 		return (struct phy_device*) PTR_ERR((void*)-ENOMEM);
 
+	dev->dev.release = phy_device_release;
+
 	dev->speed = 0;
 	dev->duplex = -1;
 	dev->pause = dev->asym_pause = 0;
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 2a65978..9ec1363 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -398,6 +398,7 @@ int phy_mii_ioctl(struct phy_device *phydev,
 int phy_start_interrupts(struct phy_device *phydev);
 void phy_print_status(struct phy_device *phydev);
 struct phy_device* phy_device_create(struct mii_bus *bus, int addr, int phy_id);
+void phy_device_free(struct phy_device *phydev);
 
 extern struct bus_type mdio_bus_type;
 #endif /* __PHY_H */
-- 
1.5.0.6
