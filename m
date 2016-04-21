From: Pramod Kumar <pramod.kumar@broadcom.com>
Subject: [PATCH 1/6] bus: Add shared MDIO bus framework
Date: Thu, 21 Apr 2016 14:48:38 +0530
Message-ID: <1461230323-27891-2-git-send-email-pramod.kumar@broadcom.com>
References: <1461230323-27891-1-git-send-email-pramod.kumar@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Pawel Moll <pawel.moll@arm.com>, Arnd Bergmann <arnd@arndb.de>,
 Suzuki K Poulose <suzuki.poulose@arm.com>, netdev@vger.kernel.org,
 Punit Agrawal <punit.agrawal@arm.com>, linux-kernel@vger.kernel.org,
 Pramod Kumar <pramod.kumar@broadcom.com>,
 BCM Kernel Feedback <bcm-kernel-feedback-list@broadcom.com>,
 linux-arm-kernel@lists.infradead.org, Anup Patel <anup.patel@broadcom.com>
To: Rob Herring <robh+dt@kernel.org>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Will Deacon <will.deacon@arm.com>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 Chen-Yu Tsai <wens@csie.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1461230323-27891-1-git-send-email-pramod.kumar@broadcom.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Add a common shared MDIO bus framework for sharing single (or few) MDIO
bus across IO subsystems such as SATA, PCIe, USB, and Ethernet.

The IO specific PHY drivers will register to common shared MDIO
bus as shared MDIO drivers and access the MDIO bus only using
shared MDIO APIs.

Signed-off-by: Pramod Kumar <pramod.kumar@broadcom.com>
Signed-off-by: Anup Patel <anup.patel@broadcom.com>
Reviewed-by: Ray Jui <ray.jui@broadcom.com>
Reviewed-by: Scott Branden <scott.branden@broadcom.com>
Reviewed-by: Vikram Prakash <vikram.prakash@broadcom.com>
---
 drivers/bus/Kconfig         |  11 +++
 drivers/bus/Makefile        |   1 +
 drivers/bus/shared_mdio.c   | 179 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/shared_mdio.h | 123 ++++++++++++++++++++++++++++++
 4 files changed, 314 insertions(+)
 create mode 100644 drivers/bus/shared_mdio.c
 create mode 100644 include/linux/shared_mdio.h

diff --git a/drivers/bus/Kconfig b/drivers/bus/Kconfig
index d4a3a31..1b51b1a 100644
--- a/drivers/bus/Kconfig
+++ b/drivers/bus/Kconfig
@@ -107,6 +107,17 @@ config OMAP_OCP2SCP
 	  OCP2SCP and in OMAP5, both USB PHY and SATA PHY is connected via
 	  OCP2SCP.
 
+config SHARED_MDIO
+	bool "Shared MDIO bus"
+	depends on OF
+
+	help
+	  Shared MDIO bus implementation for SoCs having common MDIO bus
+	  for different IO subsystems. All masters should be registered to
+	  this bus via a platform driver using shared framework API.
+	  Respective drivers would be called matching a compatible string
+	  provided in master node.
+
 config SIMPLE_PM_BUS
 	bool "Simple Power-Managed Bus Driver"
 	depends on OF && PM
diff --git a/drivers/bus/Makefile b/drivers/bus/Makefile
index ccff007..2b6d6e9 100644
--- a/drivers/bus/Makefile
+++ b/drivers/bus/Makefile
@@ -19,3 +19,4 @@ obj-$(CONFIG_SUNXI_RSB)		+= sunxi-rsb.o
 obj-$(CONFIG_SIMPLE_PM_BUS)	+= simple-pm-bus.o
 obj-$(CONFIG_UNIPHIER_SYSTEM_BUS)	+= uniphier-system-bus.o
 obj-$(CONFIG_VEXPRESS_CONFIG)	+= vexpress-config.o
+obj-$(CONFIG_SHARED_MDIO)	+= shared_mdio.o
diff --git a/drivers/bus/shared_mdio.c b/drivers/bus/shared_mdio.c
new file mode 100644
index 0000000..909af73
--- /dev/null
+++ b/drivers/bus/shared_mdio.c
@@ -0,0 +1,179 @@
+/*
+ * Copyright (C) 2016 Broadcom
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation version 2.
+ *
+ * This program is distributed "as is" WITHOUT ANY WARRANTY of any
+ * kind, whether express or implied; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * Shared MDIO Bus
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/errno.h>
+#include <linux/idr.h>
+#include <linux/of_device.h>
+#include <linux/stddef.h>
+#include <linux/module.h>
+#include <linux/shared_mdio.h>
+#include <linux/slab.h>
+
+static DEFINE_IDA(shared_mdio_ida);
+
+static void shared_mdio_release_master(struct device *dev)
+{
+	struct shared_mdio_master *master = to_shared_mdio_master(dev);
+
+	ida_simple_remove(&shared_mdio_ida, master->dev_num);
+	kfree(master);
+}
+
+struct shared_mdio_master *shared_mdio_alloc_master(struct device *parent,
+						    struct device_node *node)
+{
+	int ret = 0;
+	struct shared_mdio_master *master;
+
+	master = kzalloc(sizeof(*master), GFP_KERNEL);
+	if (!master) {
+		ret = -ENOMEM;
+		goto fail1;
+	}
+
+	master->dev.parent = parent;
+	master->dev.bus = &shared_mdio_bus;
+	master->dev.release = shared_mdio_release_master;
+
+	device_initialize(&master->dev);
+
+	ret = ida_simple_get(&shared_mdio_ida, 0, 0, GFP_KERNEL);
+	if (ret < 0)
+		goto fail2;
+	master->dev_num = ret;
+
+	dev_set_name(&master->dev, "shared-mdio-master%d", master->dev_num);
+
+	of_node_get(node);
+	master->dev.of_node = node;
+
+	return master;
+
+fail2:
+	kfree(master);
+fail1:
+	return ERR_PTR(ret);
+}
+EXPORT_SYMBOL(shared_mdio_alloc_master);
+
+int shared_mdio_add_master(struct shared_mdio_master *master)
+{
+	if (!master)
+		return -EINVAL;
+
+	return device_add(&master->dev);
+}
+EXPORT_SYMBOL(shared_mdio_add_master);
+
+static int shared_mdio_driver_probe(struct device *dev)
+{
+	int rc;
+	struct shared_mdio_master *master = to_shared_mdio_master(dev);
+	struct shared_mdio_driver *drv = to_shared_mdio_driver(dev->driver);
+
+	if (!drv->probe)
+		return -ENODEV;
+
+	rc = drv->probe(master);
+	if (rc)
+		return rc;
+
+	return 0;
+}
+
+static int shared_mdio_driver_remove(struct device *dev)
+{
+	struct shared_mdio_driver *drv = to_shared_mdio_driver(dev->driver);
+
+	if (drv->remove)
+		return drv->remove(to_shared_mdio_master(dev));
+
+	return 0;
+}
+
+static void shared_mdio_driver_shutdown(struct device *dev)
+{
+	struct shared_mdio_driver *drv = to_shared_mdio_driver(dev->driver);
+
+	if (drv->shutdown)
+		drv->shutdown(to_shared_mdio_master(dev));
+}
+
+int __shared_mdio_register_driver(struct shared_mdio_driver *drv,
+				  struct module *owner)
+{
+	int rc;
+
+	drv->driver.bus = &shared_mdio_bus;
+	drv->driver.owner = owner;
+	drv->driver.probe = shared_mdio_driver_probe;
+	drv->driver.remove = shared_mdio_driver_remove;
+	drv->driver.shutdown = shared_mdio_driver_shutdown;
+
+	rc = driver_register(&drv->driver);
+	if (rc) {
+		pr_err("driver_register() failed for %s, error: %d\n",
+			drv->driver.name, rc);
+		return rc;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(__shared_mdio_register_driver);
+
+static int shared_mdio_bus_match(struct device *dev, struct device_driver *drv)
+{
+	/* Attempt an OF style match */
+	if (of_driver_match_device(dev, drv))
+		return 1;
+
+	return 0;
+}
+
+struct bus_type shared_mdio_bus = {
+	.name	= "shared_mdio",
+	.match	= shared_mdio_bus_match,
+};
+EXPORT_SYMBOL(shared_mdio_bus);
+
+static int __init shared_mdio_init(void)
+{
+	int rc;
+
+	rc = bus_register(&shared_mdio_bus);
+	if (rc) {
+		pr_err("Failed to register shared_mdio bus, error: %d\n", rc);
+		return rc;
+	}
+
+	return 0;
+}
+
+static void __exit shared_mdio_exit(void)
+{
+	bus_unregister(&shared_mdio_bus);
+
+	ida_destroy(&shared_mdio_ida);
+}
+
+subsys_initcall(shared_mdio_init);
+module_exit(shared_mdio_exit);
+
+MODULE_DESCRIPTION("Shared MDIO Bus");
+MODULE_AUTHOR("Anup Patel <anup.patel@broadcom.com>");
+MODULE_AUTHOR("Pramod Kumar <pramod.kumar@broadcom.com>");
+MODULE_LICENSE("GPL v2");
diff --git a/include/linux/shared_mdio.h b/include/linux/shared_mdio.h
new file mode 100644
index 0000000..db6e442
--- /dev/null
+++ b/include/linux/shared_mdio.h
@@ -0,0 +1,123 @@
+/*
+ * Copyright (C) 2016 Broadcom
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation version 2.
+ *
+ * This program is distributed "as is" WITHOUT ANY WARRANTY of any
+ * kind, whether express or implied; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#ifndef __SHARED_MDIO_H__
+#define __SHARED_MDIO_H__
+
+#include <linux/device.h>
+#include <linux/types.h>
+
+extern struct bus_type shared_mdio_bus;
+
+/*
+ * This structure represets the mdio master that control the MDIO bus
+ * to access the phy attached on it.
+ * @dev Underlying device for mdio master
+ * @dev_num Unique device number of mdio master
+ * @mdio_write Write callback of mdio master
+ * @mdio_read Read callback for mdio master
+ */
+struct shared_mdio_master {
+	struct device dev;
+	int dev_num;
+	void *priv;
+
+	int (*mdio_write)(struct shared_mdio_master *master,
+				u16 phyid, u16 reg, u16 data);
+	int (*mdio_read)(struct shared_mdio_master *master, u16 phyid, u16 reg);
+};
+#define to_shared_mdio_master(d)		\
+			container_of(d, struct shared_mdio_master, dev)
+
+struct shared_mdio_driver {
+	int (*probe)(struct shared_mdio_master *master);
+	int (*remove)(struct shared_mdio_master *master);
+	void (*shutdown)(struct shared_mdio_master *master);
+
+	struct device_driver driver;
+};
+#define to_shared_mdio_driver(d)	\
+			container_of(d, struct shared_mdio_driver, driver)
+
+struct shared_mdio_master *shared_mdio_alloc_master(struct device *parent,
+						    struct device_node *node);
+
+int shared_mdio_add_master(struct shared_mdio_master *master);
+
+static inline void shared_mdio_remove_master(struct shared_mdio_master *master)
+{
+		device_unregister(&master->dev);
+}
+
+int __shared_mdio_register_driver(struct shared_mdio_driver *drv,
+				  struct module *owner);
+
+/* use a define to avoid include chaining to get THIS_MODULE & friends */
+#define shared_mdio_register_driver(drv) \
+	__shared_mdio_register_driver(drv, THIS_MODULE)
+
+static inline void shared_mdio_unregister_driver(
+					struct shared_mdio_driver *drv)
+{
+		driver_unregister(&drv->driver);
+}
+
+/**
+ * module_shared_mdio_driver() - Helper macro for registering a shared_mdio
+ * driver
+ * @__shared_mdio_driver: shared_mdio_driver struct
+ *
+ * Helper macro for shared mdio drivers which do not do anything special in
+ * module init/exit. This eliminates a lot of boilerplate. Each module
+ * may only use this macro once, and calling it replaces module_init()
+ * and module_exit().
+ */
+#define module_shared_mdio_driver(__shared_mdio_driver) \
+	module_driver(__shared_mdio_driver, shared_mdio_register_driver, \
+		       shared_mdio_unregister_driver)
+
+
+static inline int shared_mdio_write(struct shared_mdio_master *master,
+						u16 phy, u16 reg, u16 data)
+{
+	if (master->mdio_write)
+		return master->mdio_write(master, phy, reg, data);
+
+	return -ENOTSUPP;
+}
+
+static inline int shared_mdio_read(struct shared_mdio_master *master,
+							u16 phy_id, u16 reg)
+{
+	if (master->mdio_read)
+		return master->mdio_read(master, phy_id, reg);
+
+	return -ENOTSUPP;
+}
+
+/*
+ * Use the following functions to manipulate shared_mdio's per-master
+ * driver-specific data.
+ */
+static inline void *shared_mdio_get_drvdata(struct shared_mdio_master *master)
+{
+	return dev_get_drvdata(&master->dev);
+}
+
+static inline void shared_mdio_set_drvdata(struct shared_mdio_master *master,
+					   void *data)
+{
+	dev_set_drvdata(&master->dev, data);
+}
+
+#endif
-- 
1.9.1
