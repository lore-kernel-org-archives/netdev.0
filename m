From: Gregory Haskins <ghaskins@novell.com>
Subject: [RFC PATCH v2 05/19] vbus: add a "vbus-proxy" bus model for
	vbus_driver objects
Date: Thu, 09 Apr 2009 12:31:08 -0400
Message-ID: <20090409163107.32740.89596.stgit@dev.haskins.net>
References: <20090409155200.32740.19358.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org, avi@redhat.com,
	bhutchings@solarflare.com, andi@firstfloor.org, gregkh@suse.de,
	herber@gondor.apana.org.au, chrisw@sous-sol.org,
	shemminger@vyatta.com
To: linux-kernel@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090409155200.32740.19358.stgit@dev.haskins.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This will generally be used for hypervisors to publish any host-side
virtual devices up to a guest.  The guest will have the opportunity
to consume any devices present on the vbus-proxy as if they were
platform devices, similar to existing buses like PCI.

Signed-off-by: Gregory Haskins <ghaskins@novell.com>
---

 include/linux/vbus_driver.h |   73 +++++++++++++++++++++
 kernel/vbus/Kconfig         |    9 +++
 kernel/vbus/Makefile        |    4 +
 kernel/vbus/proxy.c         |  152 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 238 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/vbus_driver.h
 create mode 100644 kernel/vbus/proxy.c

diff --git a/include/linux/vbus_driver.h b/include/linux/vbus_driver.h
new file mode 100644
index 0000000..c53e13f
--- /dev/null
+++ b/include/linux/vbus_driver.h
@@ -0,0 +1,73 @@
+/*
+ * Copyright 2009 Novell.  All Rights Reserved.
+ *
+ * Mediates access to a host VBUS from a guest kernel by providing a
+ * global view of all VBUS devices
+ *
+ * Author:
+ *      Gregory Haskins <ghaskins@novell.com>
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
+ */
+
+#ifndef _LINUX_VBUS_DRIVER_H
+#define _LINUX_VBUS_DRIVER_H
+
+#include <linux/device.h>
+#include <linux/shm_signal.h>
+
+struct vbus_device_proxy;
+struct vbus_driver;
+
+struct vbus_device_proxy_ops {
+	int (*open)(struct vbus_device_proxy *dev, int version, int flags);
+	int (*close)(struct vbus_device_proxy *dev, int flags);
+	int (*shm)(struct vbus_device_proxy *dev, int id, int prio,
+		   void *ptr, size_t len,
+		   struct shm_signal_desc *sigdesc, struct shm_signal **signal,
+		   int flags);
+	int (*call)(struct vbus_device_proxy *dev, u32 func,
+		    void *data, size_t len, int flags);
+	void (*release)(struct vbus_device_proxy *dev);
+};
+
+struct vbus_device_proxy {
+	char                          *type;
+	u64                            id;
+	void                          *priv; /* Used by drivers */
+	struct vbus_device_proxy_ops  *ops;
+	struct device                  dev;
+};
+
+int vbus_device_proxy_register(struct vbus_device_proxy *dev);
+void vbus_device_proxy_unregister(struct vbus_device_proxy *dev);
+
+struct vbus_device_proxy *vbus_device_proxy_find(u64 id);
+
+struct vbus_driver_ops {
+	int (*probe)(struct vbus_device_proxy *dev);
+	int (*remove)(struct vbus_device_proxy *dev);
+};
+
+struct vbus_driver {
+	char                          *type;
+	struct module                 *owner;
+	struct vbus_driver_ops        *ops;
+	struct device_driver           drv;
+};
+
+int vbus_driver_register(struct vbus_driver *drv);
+void vbus_driver_unregister(struct vbus_driver *drv);
+
+#endif /* _LINUX_VBUS_DRIVER_H */
diff --git a/kernel/vbus/Kconfig b/kernel/vbus/Kconfig
index f2b92f5..3aaa085 100644
--- a/kernel/vbus/Kconfig
+++ b/kernel/vbus/Kconfig
@@ -12,3 +12,12 @@ config VBUS
 	various tasks and devices which reside on the bus.
 
 	If unsure, say N
+
+config VBUS_DRIVERS
+       tristate "VBUS Driver support"
+       default n
+       help
+        Adds support for a virtual bus model for proxying drivers.
+
+	If unsure, say N
+
diff --git a/kernel/vbus/Makefile b/kernel/vbus/Makefile
index 4d440e5..d028ece 100644
--- a/kernel/vbus/Makefile
+++ b/kernel/vbus/Makefile
@@ -1 +1,5 @@
 obj-$(CONFIG_VBUS) += core.o devclass.o config.o attribute.o map.o client.o
+
+vbus-proxy-objs += proxy.o
+obj-$(CONFIG_VBUS_DRIVERS) += vbus-proxy.o
+
diff --git a/kernel/vbus/proxy.c b/kernel/vbus/proxy.c
new file mode 100644
index 0000000..ea48f00
--- /dev/null
+++ b/kernel/vbus/proxy.c
@@ -0,0 +1,152 @@
+/*
+ * Copyright 2009 Novell.  All Rights Reserved.
+ *
+ * Author:
+ *      Gregory Haskins <ghaskins@novell.com>
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of version 2 of the GNU General Public License
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
+ */
+
+#include <linux/module.h>
+#include <linux/vbus_driver.h>
+
+MODULE_AUTHOR("Gregory Haskins");
+MODULE_LICENSE("GPL");
+
+#define VBUS_PROXY_NAME "vbus-proxy"
+
+static struct vbus_device_proxy *to_dev(struct device *_dev)
+{
+	return _dev ? container_of(_dev, struct vbus_device_proxy, dev) : NULL;
+}
+
+static struct vbus_driver *to_drv(struct device_driver *_drv)
+{
+	return container_of(_drv, struct vbus_driver, drv);
+}
+
+/*
+ * This function is invoked whenever a new driver and/or device is added
+ * to check if there is a match
+ */
+static int vbus_dev_proxy_match(struct device *_dev, struct device_driver *_drv)
+{
+	struct vbus_device_proxy *dev = to_dev(_dev);
+	struct vbus_driver *drv = to_drv(_drv);
+
+	return !strcmp(dev->type, drv->type);
+}
+
+/*
+ * This function is invoked after the bus infrastructure has already made a
+ * match.  The device will contain a reference to the paired driver which
+ * we will extract.
+ */
+static int vbus_dev_proxy_probe(struct device *_dev)
+{
+	int ret = 0;
+	struct vbus_device_proxy *dev = to_dev(_dev);
+	struct vbus_driver *drv = to_drv(_dev->driver);
+
+	if (drv->ops->probe)
+		ret = drv->ops->probe(dev);
+
+	return ret;
+}
+
+static struct bus_type vbus_proxy = {
+	.name   = VBUS_PROXY_NAME,
+	.match  = vbus_dev_proxy_match,
+};
+
+static struct device vbus_proxy_rootdev = {
+	.parent = NULL,
+	.bus_id = VBUS_PROXY_NAME,
+};
+
+static int __init vbus_init(void)
+{
+	int ret;
+
+	ret = bus_register(&vbus_proxy);
+	BUG_ON(ret < 0);
+
+	ret = device_register(&vbus_proxy_rootdev);
+	BUG_ON(ret < 0);
+
+	return 0;
+}
+
+postcore_initcall(vbus_init);
+
+static void device_release(struct device *dev)
+{
+	struct vbus_device_proxy *_dev;
+
+	_dev = container_of(dev, struct vbus_device_proxy, dev);
+
+	_dev->ops->release(_dev);
+}
+
+int vbus_device_proxy_register(struct vbus_device_proxy *new)
+{
+	new->dev.parent  = &vbus_proxy_rootdev;
+	new->dev.bus     = &vbus_proxy;
+	new->dev.release = &device_release;
+
+	return device_register(&new->dev);
+}
+EXPORT_SYMBOL_GPL(vbus_device_proxy_register);
+
+void vbus_device_proxy_unregister(struct vbus_device_proxy *dev)
+{
+	device_unregister(&dev->dev);
+}
+EXPORT_SYMBOL_GPL(vbus_device_proxy_unregister);
+
+static int match_device_id(struct device *_dev, void *data)
+{
+	struct vbus_device_proxy *dev = to_dev(_dev);
+	u64 id = *(u64 *)data;
+
+	return dev->id == id;
+}
+
+struct vbus_device_proxy *vbus_device_proxy_find(u64 id)
+{
+	struct device *dev;
+
+	dev = bus_find_device(&vbus_proxy, NULL, &id, &match_device_id);
+
+	return to_dev(dev);
+}
+EXPORT_SYMBOL_GPL(vbus_device_proxy_find);
+
+int vbus_driver_register(struct vbus_driver *new)
+{
+	new->drv.bus   = &vbus_proxy;
+	new->drv.name  = new->type;
+	new->drv.owner = new->owner;
+	new->drv.probe = vbus_dev_proxy_probe;
+
+	return driver_register(&new->drv);
+}
+EXPORT_SYMBOL_GPL(vbus_driver_register);
+
+void vbus_driver_unregister(struct vbus_driver *drv)
+{
+	driver_unregister(&drv->drv);
+}
+EXPORT_SYMBOL_GPL(vbus_driver_unregister);
+

