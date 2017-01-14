From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 09/10] net: phy: Allow pre-declaration of MDIO devices
Date: Sat, 14 Jan 2017 13:47:12 -0800
Message-ID: <20170114214713.28109-10-f.fainelli@gmail.com>
References: <20170114214713.28109-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Russell King <linux@armlinux.org.uk>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-arm-kernel@lists.infradead.org (moderated list:ARM
        SUB-ARCHITECTURES), linux-kernel@vger.kernel.org (open list),
        gregkh@linuxfoundation.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170114214713.28109-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow board support code to collect pre-declarations for MDIO devices by
registering them with mdiobus_register_board_info(). SPI and I2C buses
have a similar feature, we were missing this for MDIO devices, but this
is particularly useful for e.g: MDIO-connected switches which need to
provide their port layout (often board-specific) to a MDIO Ethernet
switch driver.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/Makefile         |  3 +-
 drivers/net/phy/mdio-boardinfo.c | 86 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/phy/mdio-boardinfo.h | 19 +++++++++
 drivers/net/phy/mdio_bus.c       |  4 ++
 drivers/net/phy/mdio_device.c    | 11 +++++
 include/linux/mdio.h             |  3 ++
 include/linux/mod_devicetable.h  |  1 +
 include/linux/phy.h              | 19 +++++++++
 8 files changed, 145 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/phy/mdio-boardinfo.c
 create mode 100644 drivers/net/phy/mdio-boardinfo.h

diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 356859ac7c18..407b0b601ea8 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -1,6 +1,7 @@
 # Makefile for Linux PHY drivers and MDIO bus drivers
 
-libphy-y			:= phy.o phy_device.o mdio_bus.o mdio_device.o
+libphy-y			:= phy.o phy_device.o mdio_bus.o mdio_device.o \
+				   mdio-boardinfo.o
 libphy-$(CONFIG_SWPHY)		+= swphy.o
 libphy-$(CONFIG_LED_TRIGGER_PHY)	+= phy_led_triggers.o
 
diff --git a/drivers/net/phy/mdio-boardinfo.c b/drivers/net/phy/mdio-boardinfo.c
new file mode 100644
index 000000000000..6b988f77da08
--- /dev/null
+++ b/drivers/net/phy/mdio-boardinfo.c
@@ -0,0 +1,86 @@
+/*
+ * mdio-boardinfo - Collect pre-declarations for MDIO devices
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ */
+
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/export.h>
+#include <linux/mutex.h>
+#include <linux/list.h>
+
+#include "mdio-boardinfo.h"
+
+static LIST_HEAD(mdio_board_list);
+static DEFINE_MUTEX(mdio_board_lock);
+
+/**
+ * mdiobus_setup_mdiodev_from_board_info - create and setup MDIO devices
+ * from pre-collected board specific MDIO information
+ * @mdiodev: MDIO device pointer
+ * Context: can sleep
+ */
+void mdiobus_setup_mdiodev_from_board_info(struct mii_bus *bus)
+{
+	struct mdio_board_entry *be;
+	struct mdio_device *mdiodev;
+	struct mdio_board_info *bi;
+	int ret;
+
+	mutex_lock(&mdio_board_lock);
+	list_for_each_entry(be, &mdio_board_list, list) {
+		bi = &be->board_info;
+
+		if (strcmp(bus->id, bi->bus_id))
+			continue;
+
+		mdiodev = mdio_device_create(bus, bi->mdio_addr);
+		if (IS_ERR(mdiodev))
+			continue;
+
+		strncpy(mdiodev->modalias, bi->modalias,
+			sizeof(mdiodev->modalias));
+		mdiodev->bus_match = mdio_device_bus_match;
+		mdiodev->dev.platform_data = (void *)bi->platform_data;
+
+		ret = mdio_device_register(mdiodev);
+		if (ret) {
+			mdio_device_free(mdiodev);
+			continue;
+		}
+	}
+	mutex_unlock(&mdio_board_lock);
+}
+
+/**
+ * mdio_register_board_info - register MDIO devices for a given board
+ * @info: array of devices descriptors
+ * @n: number of descriptors provided
+ * Context: can sleep
+ *
+ * The board info passed can be marked with __initdata but be pointers
+ * such as platform_data etc. are copied as-is
+ */
+int mdiobus_register_board_info(const struct mdio_board_info *info,
+				unsigned int n)
+{
+	struct mdio_board_entry *be;
+	unsigned int i;
+
+	be = kcalloc(n, sizeof(*be), GFP_KERNEL);
+	if (!be)
+		return -ENOMEM;
+
+	for (i = 0; i < n; i++, be++, info++) {
+		memcpy(&be->board_info, info, sizeof(*info));
+		mutex_lock(&mdio_board_lock);
+		list_add_tail(&be->list, &mdio_board_list);
+		mutex_unlock(&mdio_board_lock);
+	}
+
+	return 0;
+}
diff --git a/drivers/net/phy/mdio-boardinfo.h b/drivers/net/phy/mdio-boardinfo.h
new file mode 100644
index 000000000000..00f98163e90e
--- /dev/null
+++ b/drivers/net/phy/mdio-boardinfo.h
@@ -0,0 +1,19 @@
+/*
+ * mdio-boardinfo.h - board info interface internal to the mdio_bus
+ * component
+ */
+
+#ifndef __MDIO_BOARD_INFO_H
+#define __MDIO_BOARD_INFO_H
+
+#include <linux/phy.h>
+#include <linux/mutex.h>
+
+struct mdio_board_entry {
+	struct list_head	list;
+	struct mdio_board_info	board_info;
+};
+
+void mdiobus_setup_mdiodev_from_board_info(struct mii_bus *bus);
+
+#endif /* __MDIO_BOARD_INFO_H */
diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 653d076eafe5..fa7d51f14869 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -41,6 +41,8 @@
 #define CREATE_TRACE_POINTS
 #include <trace/events/mdio.h>
 
+#include "mdio-boardinfo.h"
+
 int mdiobus_register_device(struct mdio_device *mdiodev)
 {
 	if (mdiodev->bus->mdio_map[mdiodev->addr])
@@ -343,6 +345,8 @@ int __mdiobus_register(struct mii_bus *bus, struct module *owner)
 		}
 	}
 
+	mdiobus_setup_mdiodev_from_board_info(bus);
+
 	bus->state = MDIOBUS_REGISTERED;
 	pr_info("%s: probed\n", bus->name);
 	return 0;
diff --git a/drivers/net/phy/mdio_device.c b/drivers/net/phy/mdio_device.c
index fc3aaaa36b1d..e24f28924af8 100644
--- a/drivers/net/phy/mdio_device.c
+++ b/drivers/net/phy/mdio_device.c
@@ -34,6 +34,17 @@ static void mdio_device_release(struct device *dev)
 	kfree(to_mdio_device(dev));
 }
 
+int mdio_device_bus_match(struct device *dev, struct device_driver *drv)
+{
+	struct mdio_device *mdiodev = to_mdio_device(dev);
+	struct mdio_driver *mdiodrv = to_mdio_driver(drv);
+
+	if (mdiodrv->mdiodrv.flags & MDIO_DEVICE_IS_PHY)
+		return 0;
+
+	return strcmp(mdiodev->modalias, drv->name) == 0;
+}
+
 struct mdio_device *mdio_device_create(struct mii_bus *bus, int addr)
 {
 	struct mdio_device *mdiodev;
diff --git a/include/linux/mdio.h b/include/linux/mdio.h
index b6587a4b32e7..00a7f43c1482 100644
--- a/include/linux/mdio.h
+++ b/include/linux/mdio.h
@@ -10,6 +10,7 @@
 #define __LINUX_MDIO_H__
 
 #include <uapi/linux/mdio.h>
+#include <linux/mod_devicetable.h>
 
 struct mii_bus;
 
@@ -29,6 +30,7 @@ struct mdio_device {
 
 	const struct dev_pm_ops *pm_ops;
 	struct mii_bus *bus;
+	char modalias[MDIO_NAME_SIZE];
 
 	int (*bus_match)(struct device *dev, struct device_driver *drv);
 	void (*device_free)(struct mdio_device *mdiodev);
@@ -71,6 +73,7 @@ int mdio_device_register(struct mdio_device *mdiodev);
 void mdio_device_remove(struct mdio_device *mdiodev);
 int mdio_driver_register(struct mdio_driver *drv);
 void mdio_driver_unregister(struct mdio_driver *drv);
+int mdio_device_bus_match(struct device *dev, struct device_driver *drv);
 
 static inline bool mdio_phy_id_is_c45(int phy_id)
 {
diff --git a/include/linux/mod_devicetable.h b/include/linux/mod_devicetable.h
index 8a57f0b1242d..8850fcaf50db 100644
--- a/include/linux/mod_devicetable.h
+++ b/include/linux/mod_devicetable.h
@@ -501,6 +501,7 @@ struct platform_device_id {
 	kernel_ulong_t driver_data;
 };
 
+#define MDIO_NAME_SIZE		32
 #define MDIO_MODULE_PREFIX	"mdio:"
 
 #define MDIO_ID_FMT "%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d"
diff --git a/include/linux/phy.h b/include/linux/phy.h
index f7d95f644eed..7745f7391d3e 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -882,6 +882,25 @@ void mdio_bus_exit(void);
 
 extern struct bus_type mdio_bus_type;
 
+struct mdio_board_info {
+	const char	*bus_id;
+	char		modalias[MDIO_NAME_SIZE];
+	int		mdio_addr;
+	const void	*platform_data;
+};
+
+#if IS_ENABLED(CONFIG_PHYLIB)
+int mdiobus_register_board_info(const struct mdio_board_info *info,
+				unsigned int n);
+#else
+static inline int mdiobus_register_board_info(const struct mdio_board_info *i,
+					      unsigned int n)
+{
+	return 0;
+}
+#endif
+
+
 /**
  * module_phy_driver() - Helper macro for registering PHY drivers
  * @__phy_drivers: array of PHY drivers to register
-- 
2.9.3
