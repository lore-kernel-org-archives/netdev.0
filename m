From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: phy: Allow building mdio-boardinfo into the kernel
Date: Tue, 28 Mar 2017 12:57:09 -0700
Message-ID: <20170328195709.13549-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, arnd@arndb.de, andrew@lunn.ch,
        rmk+kernel@armlinux.org.uk, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35190 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751943AbdC1T5S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 15:57:18 -0400
Received: by mail-wm0-f65.google.com with SMTP id z133so1542466wmb.2
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 12:57:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mdio-boardinfo contains code that is helpful for platforms to register
specific MDIO bus devices independent of how CONFIG_MDIO_DEVICE or
CONFIG_PHYLIB will be selected (modular or built-in). In order to make
that possible, let's do the following:

- descend into drivers/net/phy/ unconditionally

- make mdiobus_setup_mdiodev_from_board_info() take a callback argument
  which allows us not to expose the internal MDIO board info list and
  mutex, yet maintain the logic within the same file

- relocate the code that creates a MDIO device into
  drivers/net/phy/mdio_bus.c

- build mdio-boardinfo.o into the kernel as soon as MDIO_DEVICE is
  defined (y or m)

Fixes: 90eff9096c01 ("net: phy: Allow splitting MDIO bus/device support from PHYs")
Fixes: 648ea0134069 ("net: phy: Allow pre-declaration of MDIO devices")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/Makefile             |  2 +-
 drivers/net/phy/Makefile         |  6 +++++-
 drivers/net/phy/mdio-boardinfo.c | 21 +++++++--------------
 drivers/net/phy/mdio-boardinfo.h |  5 ++++-
 drivers/net/phy/mdio_bus.c       | 32 +++++++++++++++++++++++++++++++-
 5 files changed, 48 insertions(+), 18 deletions(-)

diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 55f75aea283c..57fc47ad5ab3 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -18,7 +18,7 @@ obj-$(CONFIG_MII) += mii.o
 obj-$(CONFIG_MDIO) += mdio.o
 obj-$(CONFIG_NET) += Space.o loopback.o
 obj-$(CONFIG_NETCONSOLE) += netconsole.o
-obj-$(CONFIG_MDIO_DEVICE) += phy/
+obj-y += phy/
 obj-$(CONFIG_RIONET) += rionet.o
 obj-$(CONFIG_NET_TEAM) += team/
 obj-$(CONFIG_TUN) += tun.o
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 0e1ec0438c23..e36db9a2ba38 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -1,7 +1,11 @@
 # Makefile for Linux PHY drivers and MDIO bus drivers
 
 libphy-y			:= phy.o phy-core.o phy_device.o
-mdio-bus-y			+= mdio_bus.o mdio_device.o mdio-boardinfo.o
+mdio-bus-y			+= mdio_bus.o mdio_device.o
+
+ifdef CONFIG_MDIO_DEVICE
+obj-y				+= mdio-boardinfo.o
+endif
 
 # PHYLIB implies MDIO_DEVICE, in that case, we have a bunch of circular
 # dependencies that does not make it possible to split mdio-bus objects into a
diff --git a/drivers/net/phy/mdio-boardinfo.c b/drivers/net/phy/mdio-boardinfo.c
index 61941e29daae..1861f387820d 100644
--- a/drivers/net/phy/mdio-boardinfo.c
+++ b/drivers/net/phy/mdio-boardinfo.c
@@ -24,10 +24,12 @@ static DEFINE_MUTEX(mdio_board_lock);
  * @mdiodev: MDIO device pointer
  * Context: can sleep
  */
-void mdiobus_setup_mdiodev_from_board_info(struct mii_bus *bus)
+void mdiobus_setup_mdiodev_from_board_info(struct mii_bus *bus,
+					   int (*cb)
+					   (struct mii_bus *bus,
+					    struct mdio_board_info *bi))
 {
 	struct mdio_board_entry *be;
-	struct mdio_device *mdiodev;
 	struct mdio_board_info *bi;
 	int ret;
 
@@ -38,23 +40,14 @@ void mdiobus_setup_mdiodev_from_board_info(struct mii_bus *bus)
 		if (strcmp(bus->id, bi->bus_id))
 			continue;
 
-		mdiodev = mdio_device_create(bus, bi->mdio_addr);
-		if (IS_ERR(mdiodev))
+		ret = cb(bus, bi);
+		if (ret)
 			continue;
 
-		strncpy(mdiodev->modalias, bi->modalias,
-			sizeof(mdiodev->modalias));
-		mdiodev->bus_match = mdio_device_bus_match;
-		mdiodev->dev.platform_data = (void *)bi->platform_data;
-
-		ret = mdio_device_register(mdiodev);
-		if (ret) {
-			mdio_device_free(mdiodev);
-			continue;
-		}
 	}
 	mutex_unlock(&mdio_board_lock);
 }
+EXPORT_SYMBOL(mdiobus_setup_mdiodev_from_board_info);
 
 /**
  * mdio_register_board_info - register MDIO devices for a given board
diff --git a/drivers/net/phy/mdio-boardinfo.h b/drivers/net/phy/mdio-boardinfo.h
index 00f98163e90e..3a7f143904e8 100644
--- a/drivers/net/phy/mdio-boardinfo.h
+++ b/drivers/net/phy/mdio-boardinfo.h
@@ -14,6 +14,9 @@ struct mdio_board_entry {
 	struct mdio_board_info	board_info;
 };
 
-void mdiobus_setup_mdiodev_from_board_info(struct mii_bus *bus);
+void mdiobus_setup_mdiodev_from_board_info(struct mii_bus *bus,
+					   int (*cb)
+					   (struct mii_bus *bus,
+					    struct mdio_board_info *bi));
 
 #endif /* __MDIO_BOARD_INFO_H */
diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 46b468eb6e12..5a214f3b8671 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -290,6 +290,36 @@ static inline void of_mdiobus_link_mdiodev(struct mii_bus *mdio,
 #endif
 
 /**
+ * mdiobus_create_device_from_board_info - create a full MDIO device given
+ * a mdio_board_info structure
+ * @bus: MDIO bus to create the devices on
+ * @bi: mdio_board_info structure describing the devices
+ *
+ * Returns 0 on success or < 0 on error.
+ */
+static int mdiobus_create_device(struct mii_bus *bus,
+				 struct mdio_board_info *bi)
+{
+	struct mdio_device *mdiodev;
+	int ret = 0;
+
+	mdiodev = mdio_device_create(bus, bi->mdio_addr);
+	if (IS_ERR(mdiodev))
+		return -ENODEV;
+
+	strncpy(mdiodev->modalias, bi->modalias,
+		sizeof(mdiodev->modalias));
+	mdiodev->bus_match = mdio_device_bus_match;
+	mdiodev->dev.platform_data = (void *)bi->platform_data;
+
+	ret = mdio_device_register(mdiodev);
+	if (ret)
+		mdio_device_free(mdiodev);
+
+	return ret;
+}
+
+/**
  * __mdiobus_register - bring up all the PHYs on a given bus and attach them to bus
  * @bus: target mii_bus
  * @owner: module containing bus accessor functions
@@ -345,7 +375,7 @@ int __mdiobus_register(struct mii_bus *bus, struct module *owner)
 		}
 	}
 
-	mdiobus_setup_mdiodev_from_board_info(bus);
+	mdiobus_setup_mdiodev_from_board_info(bus, mdiobus_create_device);
 
 	bus->state = MDIOBUS_REGISTERED;
 	pr_info("%s: probed\n", bus->name);
-- 
2.9.3
