From: Kishon Vijay Abraham I <kishon@ti.com>
Subject: [PATCH v2 1/5] drivers: phy: add generic PHY framework
Date: Tue, 19 Feb 2013 11:23:14 +0530
Message-ID: <1361253198-7401-2-git-send-email-kishon@ti.com>
References: <1361253198-7401-1-git-send-email-kishon@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <rob@landley.net>, <tony@atomide.com>, <linux@arm.linux.org.uk>,
	<eballetbo@gmail.com>, <javier@dowhile0.org>, <kishon@ti.com>,
	<balbi@ti.com>, <gregkh@linuxfoundation.org>,
	<akpm@linux-foundation.org>, <mchehab@redhat.com>,
	<cesarb@cesarb.net>, <davem@davemloft.net>, <arnd@arndb.de>,
	<santosh.shilimkar@ti.com>, <broonie@opensource.wolfsonmicro.com>,
	<swarren@nvidia.com>, <linux-doc@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<netdev@vger.kernel.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1361253198-7401-1-git-send-email-kishon@ti.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PHY framework provides a set of APIs for the PHY drivers to
create/destroy a PHY and APIs for the PHY users to obtain a reference to the
PHY with or without using phandle. To obtain a reference to the PHY without
using phandle, the platform specfic intialization code (say from board file)
should have already called phy_bind with the binding information. The binding
information consists of phy's device name, phy user device name and an index.
The index is used when the same phy user binds to mulitple phys.

PHY drivers should create the PHY by passing phy_descriptor that has
describes the PHY (label, type etc..) and ops like init, exit, suspend, resume,
poweron, shutdown.

The documentation for the generic PHY framework is added in
Documentation/phy.txt and the documentation for the sysfs entry is added
in Documentation/ABI/testing/sysfs-class-phy.

Signed-off-by: Kishon Vijay Abraham I <kishon@ti.com>
---
 Documentation/ABI/testing/sysfs-class-phy |   15 +
 Documentation/phy.txt                     |  113 +++++++
 MAINTAINERS                               |    7 +
 drivers/Kconfig                           |    2 +
 drivers/Makefile                          |    2 +
 drivers/phy/Kconfig                       |   13 +
 drivers/phy/Makefile                      |    5 +
 drivers/phy/phy-core.c                    |  519 +++++++++++++++++++++++++++++
 include/linux/phy/phy.h                   |  198 +++++++++++
 9 files changed, 874 insertions(+)
 create mode 100644 Documentation/ABI/testing/sysfs-class-phy
 create mode 100644 Documentation/phy.txt
 create mode 100644 drivers/phy/Kconfig
 create mode 100644 drivers/phy/Makefile
 create mode 100644 drivers/phy/phy-core.c
 create mode 100644 include/linux/phy/phy.h

diff --git a/Documentation/ABI/testing/sysfs-class-phy b/Documentation/ABI/testing/sysfs-class-phy
new file mode 100644
index 0000000..ffd9930
--- /dev/null
+++ b/Documentation/ABI/testing/sysfs-class-phy
@@ -0,0 +1,15 @@
+What:		/sys/class/phy/<phy>/label
+Date:		Feb 2013
+KernelVersion:	3.10
+Contact:	Kishon Vijay Abraham I <kishon@ti.com>
+Description:
+		This is a read-only file for getting the label of the phy.
+
+What:		/sys/class/phy/<phy>/bind
+Date:		Feb 2013
+KernelVersion:	3.10
+Contact:	Kishon Vijay Abraham I <kishon@ti.com>
+Description:
+		This is a read-only file for reading the phy binding
+		information. It contains the device name of the controller,
+		the index and the device name of the PHY in that order.
diff --git a/Documentation/phy.txt b/Documentation/phy.txt
new file mode 100644
index 0000000..a850aa0
--- /dev/null
+++ b/Documentation/phy.txt
@@ -0,0 +1,113 @@
+			The Generic PHY Framework
+		  Kishon Vijay Abraham I <kishon@ti.com>
+
+This document explains the Generic PHY Framework along with the APIs provided,
+how-to-use, current status and the future work list.
+
+1. Introduction
+
+*PHY* is the abbreviation for physical layer. It is used to connect a device
+to the physical medium e.g., the USB controller has a PHY to provide functions
+such as serialization, de-serialization, encoding, decoding and is responsible
+for obtaining the required data transmission rate. Note that some USB
+controller has PHY functionality embedded into it and others use an external
+PHY. Other peripherals that uses a PHY include Wireless LAN, Ethernet,
+SATA etc.
+
+The intention of creating this framework is to bring the phy drivers spread
+all over the Linux kernel to drivers/phy to increase code re-use and to
+increase code maintainability.
+
+This framework will be of use only to devices that uses external PHY (PHY
+functionality is not embedded within the controller).
+
+2. Creating the PHY
+
+The PHY driver should create the PHY in order for other peripheral controllers
+to make use of it. The PHY framework provides 2 APIs to create the PHY.
+
+struct phy *phy_create(struct device *dev, struct phy_descriptor *desc);
+struct phy *devm_phy_create(struct device *dev, struct phy_descriptor *desc);
+
+The PHY drivers can use one of the above 2 APIs to create the PHY by passing
+the device pointer and the phy_descriptor. phy_descriptor is a structure that
+contains information about the PHY such as label, type, bus_type and phy_ops.
+phy_ops is a set of function pointers for performing PHY operations such as
+init, exit, suspend, resume, poweron and shutdown.
+
+3. Binding the PHY to the controller
+
+The framework provides an API for binding the controller to the PHY in the
+case of non dt boot.
+
+struct phy_bind *phy_bind(const char *dev_name, u8 index,
+				const char *phy_dev_name);
+
+The API fills the phy_bind structure with the dev_name (device name of the
+controller), index and phy_dev_name (device name of the PHY). This will
+be used when the controller requests this phy. This API should be used by
+platform specific initialization code (board file).
+
+In the case of dt boot, the binding information should be added in the dt
+data of the controller.
+
+4. Getting a reference to the PHY
+
+Before the controller can make use of the PHY, it has to get a reference to
+the PHY. The PHY framework provides 4 APIs to get a reference to the PHY.
+
+struct phy *phy_get(struct device *dev, u8 index);
+struct phy *devm_phy_get(struct device *dev, u8 index);
+struct phy *of_phy_get(struct device *dev, const char *phandle, u8 index);
+struct phy *devm_of_phy_get(struct device *dev, const char *phandle, u8 index);
+
+phy_get and devm_phy_get can be used to get the PHY in non-dt boot. This API
+uses the binding information added using the phy_bind API to find and return
+the appropriate PHY. The only difference between the two APIs is that
+devm_phy_get associates the device with the PHY using devres on successful PHY
+get. On driver detach, release function is invoked on the the devres data and
+devres data is freed.
+
+of_phy_get and devm_of_phy_get can be used to get the PHY in dt boot. These
+APIs take the phandle and index to get a reference to the PHY. The only
+difference between the two APIs is that devm_of_phy_get associates the device
+with the PHY using devres on successful phy get. On driver detach, release
+function is invoked on the the devres data and devres data is freed.
+
+5. Releasing a reference to the PHY
+
+When the controller no longer needs the PHY, it has to release the reference
+to the PHY it has obtained using the APIs mentioned in the above section. The
+PHY framework provides 2 APIS to release a reference to the PHY.
+
+void phy_put(struct phy *phy);
+void devm_phy_put(struct device *dev, struct phy *phy);
+
+Both these APIs are used to release a reference to the PHY and devm_phy_put
+destroys the devres associated with this PHY.
+
+6. Destroying the PHY
+
+When the driver that created the PHY is unloaded, it should destroy the PHY it
+created using one of the following 2 APIs.
+
+void phy_destroy(struct phy *phy);
+void devm_phy_destroy(struct device *dev, struct phy *phy);
+
+Both these APIs destroys the PHY and devm_phy_destroy destroys the devres
+associated with this PHY.
+
+7. Current Status
+
+Currently only USB in OMAP is made to use this framework. However using the
+USB PHY library cannot be completely removed because it is intertwined with
+OTG. Once we move OTG out of PHY completely, using the old PHY library can be
+completely removed. SATA in OMAP will also more likely use this new framework
+and we should have a patch for it soon.
+
+8. Future Work list
+
+The intention of writing this framework is to have all the phy drivers spread
+all over the kernel to use this framework and have it in drivers/phy/. So
+immediate action items include make USB and Ethernet use this Generic PHY
+Framework.
diff --git a/MAINTAINERS b/MAINTAINERS
index c5b37de..cba2a92 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3381,6 +3381,13 @@ S:	Maintained
 F:	include/asm-generic
 F:	include/uapi/asm-generic
 
+GENERIC PHY FRAMEWORK
+M:	Kishon Vijay Abraham I <kishon@ti.com>
+L:	linux-kernel@vger.kernel.org
+S:	Supported
+F:	drivers/phy/
+F:	include/linux/phy/
+
 GENERIC UIO DRIVER FOR PCI DEVICES
 M:	"Michael S. Tsirkin" <mst@redhat.com>
 L:	kvm@vger.kernel.org
diff --git a/drivers/Kconfig b/drivers/Kconfig
index f5fb072..5230abe 100644
--- a/drivers/Kconfig
+++ b/drivers/Kconfig
@@ -158,4 +158,6 @@ source "drivers/irqchip/Kconfig"
 
 source "drivers/ipack/Kconfig"
 
+source "drivers/phy/Kconfig"
+
 endmenu
diff --git a/drivers/Makefile b/drivers/Makefile
index 7863b9f..4d5c9cb 100644
--- a/drivers/Makefile
+++ b/drivers/Makefile
@@ -45,6 +45,8 @@ obj-y				+= char/
 # gpu/ comes after char for AGP vs DRM startup
 obj-y				+= gpu/
 
+obj-y				+= phy/
+
 obj-$(CONFIG_CONNECTOR)		+= connector/
 
 # i810fb and intelfb depend on char/agp/
diff --git a/drivers/phy/Kconfig b/drivers/phy/Kconfig
new file mode 100644
index 0000000..34f7077
--- /dev/null
+++ b/drivers/phy/Kconfig
@@ -0,0 +1,13 @@
+#
+# PHY
+#
+
+menuconfig GENERIC_PHY
+	tristate "Generic PHY Support"
+	help
+	  Generic PHY support.
+
+	  This framework is designed to provide a generic interface for PHY
+	  devices present in the kernel. This layer will have the generic
+	  API by which phy drivers can create PHY using the phy framework and
+	  phy users can obtain reference to the PHY.
diff --git a/drivers/phy/Makefile b/drivers/phy/Makefile
new file mode 100644
index 0000000..9e9560f
--- /dev/null
+++ b/drivers/phy/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the phy drivers.
+#
+
+obj-$(CONFIG_GENERIC_PHY)	+= phy-core.o
diff --git a/drivers/phy/phy-core.c b/drivers/phy/phy-core.c
new file mode 100644
index 0000000..c52aaf8
--- /dev/null
+++ b/drivers/phy/phy-core.c
@@ -0,0 +1,519 @@
+/*
+ * phy-core.c  --  Generic Phy framework.
+ *
+ * Copyright (C) 2013 Texas Instruments
+ *
+ * Author: Kishon Vijay Abraham I <kishon@ti.com>
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#include <linux/kernel.h>
+#include <linux/export.h>
+#include <linux/module.h>
+#include <linux/err.h>
+#include <linux/device.h>
+#include <linux/slab.h>
+#include <linux/of.h>
+#include <linux/phy/phy.h>
+
+static struct class *phy_class;
+static LIST_HEAD(phy_list);
+static DEFINE_MUTEX(phy_list_mutex);
+static LIST_HEAD(phy_bind_list);
+
+static void devm_phy_release(struct device *dev, void *res)
+{
+	struct phy *phy = *(struct phy **)res;
+
+	phy_put(phy);
+}
+
+static void devm_phy_consume(struct device *dev, void *res)
+{
+	struct phy *phy = *(struct phy **)res;
+
+	phy_destroy(phy);
+}
+
+static int devm_phy_match(struct device *dev, void *res, void *match_data)
+{
+	return res == match_data;
+}
+
+static struct phy *phy_lookup(struct device *dev, u8 index)
+{
+	struct phy_bind *phy_bind = NULL;
+
+	list_for_each_entry(phy_bind, &phy_bind_list, list) {
+		if (!(strcmp(phy_bind->dev_name, dev_name(dev)) &&
+				phy_bind->index == index)) {
+			if (phy_bind->phy)
+				return phy_bind->phy;
+			else
+				return ERR_PTR(-EPROBE_DEFER);
+		}
+	}
+
+	return ERR_PTR(-ENODEV);
+}
+
+static struct phy *of_phy_lookup(struct device *dev, struct device_node *node)
+{
+	struct phy *phy;
+
+	list_for_each_entry(phy, &phy_list, head) {
+		if (node != phy->desc->of_node)
+			continue;
+
+		return phy;
+	}
+
+	return ERR_PTR(-EPROBE_DEFER);
+}
+
+/**
+ * phy_put - release the PHY
+ * @phy: the phy returned by phy_get()
+ *
+ * Releases a refcount the caller received from phy_get().
+ */
+void phy_put(struct phy *phy)
+{
+	if (phy) {
+		module_put(phy->desc->ops->owner);
+		put_device(&phy->dev);
+	}
+}
+EXPORT_SYMBOL_GPL(phy_put);
+
+/**
+ * devm_phy_put - release the PHY
+ * @dev: device that wants to release this phy
+ * @phy: the phy returned by devm_phy_get()
+ *
+ * destroys the devres associated with this phy and invokes phy_put
+ * to release the phy.
+ */
+void devm_phy_put(struct device *dev, struct phy *phy)
+{
+	int r;
+
+	r = devres_destroy(dev, devm_phy_release, devm_phy_match, phy);
+	dev_WARN_ONCE(dev, r, "couldn't find PHY resource\n");
+}
+EXPORT_SYMBOL_GPL(devm_phy_put);
+
+/**
+ * of_phy_get - lookup and obtain a reference to a phy by phandle
+ * @dev: device that requests this phy
+ * @phandle: name of the property holding the phy phandle value
+ * @index - the index of the phy
+ *
+ * Returns the phy associated with the given phandle value,
+ * after getting a refcount to it or -ENODEV if there is no such phy or
+ * -EPROBE_DEFER if there is a phandle to the phy, but the device is
+ * not yet loaded.
+ */
+struct phy *of_phy_get(struct device *dev, const char *phandle, u8 index)
+{
+	struct phy *phy = NULL;
+	struct phy_bind *phy_map = NULL;
+	struct device_node *node;
+
+	if (!dev->of_node) {
+		dev_dbg(dev, "device does not have a device node entry\n");
+		return ERR_PTR(-EINVAL);
+	}
+
+	node = of_parse_phandle(dev->of_node, phandle, index);
+	if (!node) {
+		dev_dbg(dev, "failed to get %s phandle in %s node\n", phandle,
+			dev->of_node->full_name);
+		return ERR_PTR(-ENODEV);
+	}
+
+	mutex_lock(&phy_list_mutex);
+
+	phy = of_phy_lookup(dev, node);
+	if (IS_ERR(phy) || !try_module_get(phy->desc->ops->owner)) {
+		phy = ERR_PTR(-EPROBE_DEFER);
+		goto err0;
+	}
+
+	phy_map = phy_bind(dev_name(dev), index, dev_name(&phy->dev));
+	if (!IS_ERR(phy_map)) {
+		phy_map->phy = phy;
+		phy_map->auto_bind = true;
+	}
+
+	get_device(&phy->dev);
+
+err0:
+	mutex_unlock(&phy_list_mutex);
+	of_node_put(node);
+
+	return phy;
+}
+EXPORT_SYMBOL_GPL(of_phy_get);
+
+/**
+ * devm_of_phy_get - lookup and obtain a reference to a phy by phandle
+ * @dev: device that requests this phy
+ * @phandle: name of the property holding the phy phandle value
+ * @index - the index of the phy
+ *
+ * Calls of_phy_get to get a reference to the PHY and passes on the return
+ * value of of_phy_get. While at that, it also associates the device with the
+ * phy using devres on successful phy get. On driver detach, release function
+ * is invoked on the the devres data and devres data is freed.
+ */
+struct phy *devm_of_phy_get(struct device *dev, const char *phandle, u8 index)
+{
+	struct phy *phy = NULL, **ptr;
+
+	ptr = devres_alloc(devm_phy_release, sizeof(*ptr), GFP_KERNEL);
+	if (!ptr)
+		return ERR_PTR(-ENOMEM);
+
+	phy = of_phy_get(dev, phandle, index);
+	if (!IS_ERR(phy)) {
+		*ptr = phy;
+		devres_add(dev, ptr);
+	} else {
+		devres_free(ptr);
+	}
+
+	return phy;
+}
+EXPORT_SYMBOL_GPL(devm_of_phy_get);
+
+/**
+ * phy_get - lookup and obtain a reference to a phy.
+ * @dev: device that requests this phy
+ * @index: the index of the phy
+ *
+ * Returns the phy driver, after getting a refcount to it; or
+ * -ENODEV if there is no such phy.  The caller is responsible for
+ * calling phy_put() to release that count.
+ */
+struct phy *phy_get(struct device *dev, u8 index)
+{
+	struct phy *phy = NULL;
+
+	mutex_lock(&phy_list_mutex);
+
+	phy = phy_lookup(dev, index);
+	if (IS_ERR(phy)) {
+		dev_err(dev, "unable to find phy\n");
+		goto err0;
+	}
+
+	if (!try_module_get(phy->desc->ops->owner)) {
+		phy = ERR_PTR(-EPROBE_DEFER);
+		goto err0;
+	}
+
+	get_device(&phy->dev);
+
+err0:
+	mutex_unlock(&phy_list_mutex);
+
+	return phy;
+}
+EXPORT_SYMBOL_GPL(phy_get);
+
+/**
+ * devm_phy_get - lookup and obtain a reference to a phy.
+ * @dev: device that requests this phy
+ * @index: the index of the phy
+ *
+ * Gets the phy using phy_get(), and associates a device with it using
+ * devres. On driver detach, release function is invoked on the devres data,
+ * then, devres data is freed.
+ */
+struct phy *devm_phy_get(struct device *dev, u8 index)
+{
+	struct phy **ptr, *phy;
+
+	ptr = devres_alloc(devm_phy_release, sizeof(*ptr), GFP_KERNEL);
+	if (!ptr)
+		return ERR_PTR(-ENOMEM);
+
+	phy = phy_get(dev, index);
+	if (!IS_ERR(phy)) {
+		*ptr = phy;
+		devres_add(dev, ptr);
+	} else {
+		devres_free(ptr);
+	}
+
+	return phy;
+}
+EXPORT_SYMBOL_GPL(devm_phy_get);
+
+/**
+ * phy_create - create a new phy
+ * @dev: device that is creating the new phy
+ * @desc: descriptor of the phy
+ *
+ * Called to create a phy using phy framework.
+ */
+struct phy *phy_create(struct device *dev, struct phy_descriptor *desc)
+{
+	int ret;
+	struct phy *phy;
+	struct phy_bind *phy_bind;
+	const char *devname = NULL;
+
+	if (!dev || !desc) {
+		dev_err(dev, "no descriptor/device provided for PHY\n");
+		ret = -EINVAL;
+		goto err0;
+	}
+
+	if (!(desc->ops)) {
+		dev_err(dev, "no PHY ops/PHY owner provided\n");
+		ret = -EINVAL;
+		goto err0;
+	}
+
+	phy = kzalloc(sizeof(*phy), GFP_KERNEL);
+	if (!phy) {
+		ret = -ENOMEM;
+		goto err0;
+	}
+
+	devname = dev_name(dev);
+	device_initialize(&phy->dev);
+	phy->desc = desc;
+	phy->dev.class = phy_class;
+	phy->dev.parent = dev;
+	phy->dev.bus = desc->bus;
+	ret = dev_set_name(&phy->dev, "%s", devname);
+	if (ret)
+		goto err1;
+
+	mutex_lock(&phy_list_mutex);
+	list_for_each_entry(phy_bind, &phy_bind_list, list)
+		if (!(strcmp(phy_bind->phy_dev_name, devname)))
+			phy_bind->phy = phy;
+
+	list_add_tail(&phy->head, &phy_list);
+
+	ret = device_add(&phy->dev);
+	if (ret)
+		goto err2;
+
+	mutex_unlock(&phy_list_mutex);
+
+	return phy;
+
+err2:
+	phy_bind->phy = NULL;
+	list_del(&phy->head);
+	mutex_unlock(&phy_list_mutex);
+
+err1:
+	put_device(&phy->dev);
+	kfree(phy);
+
+err0:
+	return ERR_PTR(ret);
+}
+EXPORT_SYMBOL_GPL(phy_create);
+
+/**
+ * devm_phy_create - create a new phy
+ * @dev: device that is creating the new phy
+ * @desc: descriptor of the phy
+ *
+ * Creates a new PHY device adding it to the PHY class.
+ * While at that, it also associates the device with the phy using devres.
+ * On driver detach, release function is invoked on the devres data,
+ * then, devres data is freed.
+ */
+struct phy *devm_phy_create(struct device *dev, struct phy_descriptor *desc)
+{
+	struct phy **ptr, *phy;
+
+	ptr = devres_alloc(devm_phy_consume, sizeof(*ptr), GFP_KERNEL);
+	if (!ptr)
+		return ERR_PTR(-ENOMEM);
+
+	phy = phy_create(dev, desc);
+	if (!IS_ERR(phy)) {
+		*ptr = phy;
+		devres_add(dev, ptr);
+	} else {
+		devres_free(ptr);
+	}
+
+	return phy;
+}
+EXPORT_SYMBOL_GPL(devm_phy_create);
+
+/**
+ * phy_destroy - destroy the phy
+ * @phy: the phy to be destroyed
+ *
+ * Called to destroy the phy.
+ */
+void phy_destroy(struct phy *phy)
+{
+	struct phy_bind *phy_bind;
+
+	mutex_lock(&phy_list_mutex);
+	list_for_each_entry(phy_bind, &phy_bind_list, list) {
+		if (phy_bind->phy == phy)
+			phy_bind->phy = NULL;
+
+		if (phy_bind->auto_bind) {
+			list_del(&phy_bind->list);
+			kfree(phy_bind);
+		}
+	}
+
+	list_del(&phy->head);
+	mutex_unlock(&phy_list_mutex);
+
+	device_unregister(&phy->dev);
+}
+EXPORT_SYMBOL_GPL(phy_destroy);
+
+/**
+ * devm_phy_destroy - destroy the PHY
+ * @dev: device that wants to release this phy
+ * @phy: the phy returned by devm_phy_get()
+ *
+ * destroys the devres associated with this phy and invokes phy_destroy
+ * to destroy the phy.
+ */
+void devm_phy_destroy(struct device *dev, struct phy *phy)
+{
+	int r;
+
+	r = devres_destroy(dev, devm_phy_consume, devm_phy_match, phy);
+	dev_WARN_ONCE(dev, r, "couldn't find PHY resource\n");
+}
+EXPORT_SYMBOL_GPL(devm_phy_destroy);
+
+/**
+ * phy_bind - bind the phy and the controller that uses the phy
+ * @dev_name: the device name of the device that will bind to the phy
+ * @index: index to specify the port number
+ * @phy_dev_name: the device name of the phy
+ *
+ * Fills the phy_bind structure with the dev_name and phy_dev_name. This will
+ * be used when the phy driver registers the phy and when the controller
+ * requests this phy.
+ *
+ * To be used by platform specific initialization code.
+ */
+struct phy_bind *phy_bind(const char *dev_name, u8 index,
+				const char *phy_dev_name)
+{
+	struct phy_bind *phy_bind;
+
+	phy_bind = kzalloc(sizeof(*phy_bind), GFP_KERNEL);
+	if (!phy_bind)
+		return ERR_PTR(-ENOMEM);
+
+	phy_bind->dev_name = dev_name;
+	phy_bind->phy_dev_name = phy_dev_name;
+	phy_bind->index = index;
+	phy_bind->auto_bind = false;
+
+	list_add_tail(&phy_bind->list, &phy_bind_list);
+
+	return phy_bind;
+}
+EXPORT_SYMBOL_GPL(phy_bind);
+
+static ssize_t phy_name_show(struct device *dev,
+			     struct device_attribute *attr, char *buf)
+{
+	struct phy *phy;
+
+	phy = container_of(dev, struct phy, dev);
+
+	return sprintf(buf, "%s\n", phy->desc->label);
+}
+
+static ssize_t phy_bind_show(struct device *dev,
+			     struct device_attribute *attr, char *buf)
+{
+	struct phy_bind *phy_bind;
+	struct phy *phy;
+	char *p = buf;
+	int len;
+
+	phy = container_of(dev, struct phy, dev);
+
+	list_for_each_entry(phy_bind, &phy_bind_list, list)
+		if (phy_bind->phy == phy)
+			p += sprintf(p, "%s %d %s\n", phy_bind->dev_name,
+				phy_bind->index, phy_bind->phy_dev_name);
+	len = (p - buf);
+
+	return len;
+}
+
+static struct device_attribute phy_dev_attrs[] = {
+	__ATTR(label, 0444, phy_name_show, NULL),
+	__ATTR(bind, 0444, phy_bind_show, NULL),
+	__ATTR_NULL,
+};
+
+/**
+ * phy_release - release the phy
+ * @dev: the dev member within phy
+ *
+ * when the last reference to the device is removed; it is called
+ * from the embedded kobject as release method.
+ */
+static void phy_release(struct device *dev)
+{
+	struct phy *phy;
+
+	phy = container_of(dev, struct phy, dev);
+	dev_dbg(dev, "releasing '%s'\n", dev_name(dev));
+	kfree(phy);
+}
+
+static int __init phy_core_init(void)
+{
+	phy_class = class_create(THIS_MODULE, "phy");
+	if (IS_ERR(phy_class)) {
+		pr_err("failed to create phy class --> %ld\n",
+			PTR_ERR(phy_class));
+		return PTR_ERR(phy_class);
+	}
+
+	phy_class->dev_release = phy_release;
+	phy_class->dev_attrs = phy_dev_attrs;
+
+	return 0;
+}
+subsys_initcall(phy_core_init);
+
+static void __exit phy_core_exit(void)
+{
+	class_destroy(phy_class);
+}
+module_exit(phy_core_exit);
+
+MODULE_DESCRIPTION("Generic PHY Framework");
+MODULE_AUTHOR("Kishon Vijay Abraham I <kishon@ti.com>");
+MODULE_LICENSE("GPL v2");
diff --git a/include/linux/phy/phy.h b/include/linux/phy/phy.h
new file mode 100644
index 0000000..4e9076d
--- /dev/null
+++ b/include/linux/phy/phy.h
@@ -0,0 +1,198 @@
+/*
+ * phy.h -- generic phy header file
+ *
+ * Copyright (C) 2013 Texas Instruments Incorporated - http://www.ti.com
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * Author: Kishon Vijay Abraham I <kishon@ti.com>
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ */
+
+#ifndef __DRIVERS_PHY_H
+#define __DRIVERS_PHY_H
+
+#include <linux/err.h>
+
+struct phy;
+
+/**
+ * struct phy_descriptor - structure that describes the PHY
+ * @label: label given to phy
+ * @type: specifies the phy type
+ * @of_node: device node of the phy
+ * @ops: function pointers for performing phy operations
+ */
+struct phy_descriptor {
+	const char		*label;
+	int			type;
+	struct bus_type		*bus;
+	struct device_node	*of_node;
+	struct phy_ops		*ops;
+};
+
+/**
+ * struct phy_ops - set of function pointers for performing phy operations
+ * @init: operation to be performed for initializing phy
+ * @exit: operation to be performed while exiting
+ * @suspend: suspending the phy
+ * @resume: resuming the phy
+ * @poweron: powering on the phy
+ * @shutdown: shutting down the phy
+ * @owner: the module owner containing the ops
+ */
+struct phy_ops {
+	int	(*init)(struct phy_descriptor *desc);
+	int	(*exit)(struct phy_descriptor *desc);
+	int	(*suspend)(struct phy_descriptor *desc);
+	int	(*resume)(struct phy_descriptor *desc);
+	int	(*poweron)(struct phy_descriptor *desc);
+	int	(*shutdown)(struct phy_descriptor *desc);
+	struct module *owner;
+};
+
+/**
+ * struct phy - represent the phy device
+ * @desc: descriptor for the phy
+ * @head: to support multiple transceivers
+ */
+struct phy {
+	struct device		dev;
+	struct phy_descriptor	*desc;
+	struct list_head	head;
+};
+
+/**
+ * struct phy_bind - represent the binding for the phy
+ * @dev_name: the device name of the device that will bind to the phy
+ * @phy_dev_name: the device name of the phy
+ * @index: used if a single controller uses multiple phys
+ * @auto_bind: tells if the binding is done explicitly from board file or not
+ * @phy: reference to the phy
+ * @list: to maintain a linked list of the binding information
+ */
+struct phy_bind {
+	const char	*dev_name;
+	const char	*phy_dev_name;
+	u8		index;
+	int		auto_bind:1;
+	struct phy	*phy;
+	struct list_head list;
+};
+
+#if defined(CONFIG_GENERIC_PHY) || defined(CONFIG_GENERIC_PHY_MODULE)
+extern struct phy *devm_phy_get(struct device *dev, u8 index);
+extern void devm_phy_put(struct device *dev, struct phy *phy);
+extern struct phy *devm_of_phy_get(struct device *dev, const char *phandle,
+	u8 index);
+extern struct phy *phy_get(struct device *dev, u8 index);
+extern void phy_put(struct phy *phy);
+extern struct phy *phy_create(struct device *dev, struct phy_descriptor *desc);
+extern struct phy *devm_phy_create(struct device *dev,
+	struct phy_descriptor *desc);
+extern void phy_destroy(struct phy *phy);
+extern struct phy_bind *phy_bind(const char *dev_name, u8 index,
+				const char *phy_dev_name);
+#else
+static inline struct phy *devm_phy_get(struct device *dev, u8 index)
+{
+	return ERR_PTR(-EINVAL);
+}
+
+static inline void devm_phy_put(struct device *dev, struct phy *phy)
+{
+}
+
+static inline struct phy *devm_of_phy_get(struct device *dev,
+		const char *phandlei, u8 index)
+{
+	return ERR_PTR(-EINVAL);
+}
+
+static inline struct phy *phy_get(struct device *dev, u8 index)
+{
+	return ERR_PTR(-EINVAL);
+}
+
+static inline void phy_put(struct phy *phy)
+{
+}
+
+static inline struct phy *phy_create(struct device *dev,
+	struct phy_descriptor *desc)
+{
+	return ERR_PTR(-EINVAL);
+}
+
+static inline struct phy *devm_phy_create(struct device *dev,
+	struct phy_descriptor *desc)
+{
+	return ERR_PTR(-EINVAL);
+}
+
+static inline void phy_destroy(struct phy *phy)
+{
+}
+
+static inline struct phy_bind *phy_bind(const char *dev_name, u8 index,
+				const char *phy_dev_name)
+{
+	return ERR_PTR(-EINVAL);
+}
+#endif
+
+static inline int phy_init(struct phy *phy)
+{
+	if (phy->desc->ops->init)
+		return phy->desc->ops->init(phy->desc);
+
+	return -EINVAL;
+}
+
+static inline int phy_exit(struct phy *phy)
+{
+	if (phy->desc->ops->exit)
+		return phy->desc->ops->exit(phy->desc);
+
+	return -EINVAL;
+}
+
+static inline int phy_suspend(struct phy *phy)
+{
+	if (phy->desc->ops->suspend)
+		return phy->desc->ops->suspend(phy->desc);
+
+	return -EINVAL;
+}
+
+static inline int phy_resume(struct phy *phy)
+{
+	if (phy->desc->ops->resume)
+		return phy->desc->ops->resume(phy->desc);
+
+	return -EINVAL;
+}
+
+static inline int phy_poweron(struct phy *phy)
+{
+	if (phy->desc->ops->poweron)
+		return phy->desc->ops->poweron(phy->desc);
+
+	return -EINVAL;
+}
+
+static inline int phy_shutdown(struct phy *phy)
+{
+	if (phy->desc->ops->shutdown)
+		return phy->desc->ops->shutdown(phy->desc);
+
+	return -EINVAL;
+}
+#endif /* __DRIVERS_PHY_H */
-- 
1.7.10.4

