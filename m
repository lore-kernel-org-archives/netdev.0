From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v2.2 01/22] fjes: Introduce FUJITSU Extended Socket Network Device driver
Date: Thu, 20 Aug 2015 17:46:05 +0900
Message-ID: <1440060386-13189-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1440060306-13040-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: platform-driver-x86@vger.kernel.org, dvhart@infradead.org,
	rkhan@redhat.com, alexander.h.duyck@redhat.com,
	linux-acpi@vger.kernel.org, joe@perches.com,
	sergei.shtylyov@cogentembedded.com, stephen@networkplumber.org,
	yasu.isimatu@gmail.com, Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1440060306-13040-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the basic code of FUJITSU Extended Socket
Network Device driver.

When "PNP0C02" is found in ACPI DSDT, it evaluates "_STR"
to check if "PNP0C02" is for Extended Socket device driver
and retrieves ACPI resource information. Then creates
platform_device.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/Kconfig          |   7 ++
 drivers/net/Makefile         |   2 +
 drivers/net/fjes/Makefile    |  31 +++++++
 drivers/net/fjes/fjes.h      |  33 +++++++
 drivers/net/fjes/fjes_main.c | 214 +++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 287 insertions(+)
 create mode 100644 drivers/net/fjes/Makefile
 create mode 100644 drivers/net/fjes/fjes.h
 create mode 100644 drivers/net/fjes/fjes_main.c

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index c18f9e6..c78a81a 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -407,6 +407,13 @@ config VMXNET3
 	  To compile this driver as a module, choose M here: the
 	  module will be called vmxnet3.
 
+config FUJITSU_ES
+	tristate "FUJITSU Extended Socket Network Device driver"
+	depends on ACPI
+	help
+	  This driver provides support for Extended Socket network device
+          on Extended Partitioning of FUJITSU PRIMEQUEST 2000 E2 series.
+
 source "drivers/net/hyperv/Kconfig"
 
 endif # NETDEVICES
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index c12cb22..677c7b4 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -67,3 +67,5 @@ obj-$(CONFIG_USB_NET_DRIVERS) += usb/
 
 obj-$(CONFIG_HYPERV_NET) += hyperv/
 obj-$(CONFIG_NTB_NETDEV) += ntb_netdev.o
+
+obj-$(CONFIG_FUJITSU_ES) += fjes/
diff --git a/drivers/net/fjes/Makefile b/drivers/net/fjes/Makefile
new file mode 100644
index 0000000..98e59cb
--- /dev/null
+++ b/drivers/net/fjes/Makefile
@@ -0,0 +1,31 @@
+################################################################################
+#
+# FUJITSU Extended Socket Network Device driver
+# Copyright (c) 2015 FUJITSU LIMITED
+#
+# This program is free software; you can redistribute it and/or modify it
+# under the terms and conditions of the GNU General Public License,
+# version 2, as published by the Free Software Foundation.
+#
+# This program is distributed in the hope it will be useful, but WITHOUT
+# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+# more details.
+#
+# You should have received a copy of the GNU General Public License along with
+# this program; if not, see <http://www.gnu.org/licenses/>.
+#
+# The full GNU General Public License is included in this distribution in
+# the file called "COPYING".
+#
+################################################################################
+
+
+#
+# Makefile for the FUJITSU Extended Socket network device driver
+#
+
+obj-$(CONFIG_FUJITSU_ES) += fjes.o
+
+fjes-objs := fjes_main.o
+
diff --git a/drivers/net/fjes/fjes.h b/drivers/net/fjes/fjes.h
new file mode 100644
index 0000000..4622da1
--- /dev/null
+++ b/drivers/net/fjes/fjes.h
@@ -0,0 +1,33 @@
+/*
+ *  FUJITSU Extended Socket Network Device driver
+ *  Copyright (c) 2015 FUJITSU LIMITED
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ */
+
+#ifndef FJES_H_
+#define FJES_H_
+
+#include <linux/acpi.h>
+
+#define FJES_ACPI_SYMBOL	"Extended Socket"
+
+extern char fjes_driver_name[];
+extern char fjes_driver_version[];
+extern u32 fjes_support_mtu[];
+
+#endif /* FJES_H_ */
diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
new file mode 100644
index 0000000..ab4d20c
--- /dev/null
+++ b/drivers/net/fjes/fjes_main.c
@@ -0,0 +1,214 @@
+/*
+ *  FUJITSU Extended Socket Network Device driver
+ *  Copyright (c) 2015 FUJITSU LIMITED
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/nls.h>
+#include <linux/platform_device.h>
+
+#include "fjes.h"
+
+#define MAJ 1
+#define MIN 0
+#define DRV_VERSION __stringify(MAJ) "." __stringify(MIN)
+#define DRV_NAME	"fjes"
+char fjes_driver_name[] = DRV_NAME;
+char fjes_driver_version[] = DRV_VERSION;
+static const char fjes_driver_string[] =
+		"FUJITSU Extended Socket Network Device Driver";
+static const char fjes_copyright[] =
+		"Copyright (c) 2015 FUJITSU LIMITED";
+
+MODULE_AUTHOR("Taku Izumi <izumi.taku@jp.fujitsu.com>");
+MODULE_DESCRIPTION("FUJITSU Extended Socket Network Device Driver");
+MODULE_LICENSE("GPL");
+MODULE_VERSION(DRV_VERSION);
+
+static int fjes_acpi_add(struct acpi_device *);
+static int fjes_acpi_remove(struct acpi_device *);
+static acpi_status fjes_get_acpi_resource(struct acpi_resource *, void*);
+
+static int fjes_probe(struct platform_device *);
+static int fjes_remove(struct platform_device *);
+
+static const struct acpi_device_id fjes_acpi_ids[] = {
+	{"PNP0C02", 0},
+	{"", 0},
+};
+MODULE_DEVICE_TABLE(acpi, fjes_acpi_ids);
+
+static struct acpi_driver fjes_acpi_driver = {
+	.name = DRV_NAME,
+	.class = DRV_NAME,
+	.owner = THIS_MODULE,
+	.ids = fjes_acpi_ids,
+	.ops = {
+		.add = fjes_acpi_add,
+		.remove = fjes_acpi_remove,
+	},
+};
+
+static struct platform_driver fjes_driver = {
+	.driver = {
+		.name = DRV_NAME,
+		.owner = THIS_MODULE,
+	},
+	.probe = fjes_probe,
+	.remove = fjes_remove,
+};
+
+static struct resource fjes_resource[] = {
+	{
+		.flags = IORESOURCE_MEM,
+		.start = 0,
+		.end = 0,
+	},
+	{
+		.flags = IORESOURCE_IRQ,
+		.start = 0,
+		.end = 0,
+	},
+};
+
+static int fjes_acpi_add(struct acpi_device *device)
+{
+	acpi_status status;
+	struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL};
+	union acpi_object *str;
+	char str_buf[sizeof(FJES_ACPI_SYMBOL) + 1];
+	int result;
+	struct platform_device *plat_dev;
+
+	status = acpi_evaluate_object(device->handle, "_STR", NULL, &buffer);
+	if (ACPI_FAILURE(status))
+		return -ENODEV;
+
+	str = buffer.pointer;
+	result = utf16s_to_utf8s((wchar_t *)str->string.pointer,
+				 str->string.length, UTF16_LITTLE_ENDIAN,
+				 str_buf, sizeof(str_buf) - 1);
+	str_buf[result] = 0;
+
+	if (strncmp(FJES_ACPI_SYMBOL, str_buf, strlen(FJES_ACPI_SYMBOL)) != 0) {
+		kfree(buffer.pointer);
+		return -ENODEV;
+	}
+	kfree(buffer.pointer);
+
+	status = acpi_walk_resources(device->handle, METHOD_NAME__CRS,
+				     fjes_get_acpi_resource, fjes_resource);
+	if (ACPI_FAILURE(status))
+		return -ENODEV;
+
+	/* create platform_device */
+	plat_dev = platform_device_register_simple(DRV_NAME, 0, fjes_resource,
+						   ARRAY_SIZE(fjes_resource));
+	device->driver_data = plat_dev;
+
+	return 0;
+}
+
+static int fjes_acpi_remove(struct acpi_device *device)
+{
+	struct platform_device *plat_dev;
+
+	plat_dev = (struct platform_device *)acpi_driver_data(device);
+	platform_device_unregister(plat_dev);
+
+	return 0;
+}
+
+static acpi_status
+fjes_get_acpi_resource(struct acpi_resource *acpi_res, void *data)
+{
+	struct resource *res = data;
+	struct acpi_resource_address32 *addr;
+	struct acpi_resource_irq *irq;
+
+	switch (acpi_res->type) {
+	case ACPI_RESOURCE_TYPE_ADDRESS32:
+		addr = &acpi_res->data.address32;
+		res[0].start = addr->address.minimum;
+		res[0].end = addr->address.minimum +
+			addr->address.address_length - 1;
+		break;
+
+	case ACPI_RESOURCE_TYPE_IRQ:
+		irq = &acpi_res->data.irq;
+		if (irq->interrupt_count != 1)
+			return AE_ERROR;
+		res[1].start = irq->interrupts[0];
+		res[1].end = irq->interrupts[0];
+		break;
+
+	default:
+		break;
+	}
+
+	return AE_OK;
+}
+
+/* fjes_probe - Device Initialization Routine */
+static int fjes_probe(struct platform_device *plat_dev)
+{
+	return 0;
+}
+
+/* fjes_remove - Device Removal Routine */
+static int fjes_remove(struct platform_device *plat_dev)
+{
+	return 0;
+}
+
+/* fjes_init_module - Driver Registration Routine */
+static int __init fjes_init_module(void)
+{
+	int result;
+
+	pr_info("%s - version %s - %s\n",
+		fjes_driver_string, fjes_driver_version, fjes_copyright);
+
+	result = platform_driver_register(&fjes_driver);
+	if (result < 0)
+		return result;
+
+	result = acpi_bus_register_driver(&fjes_acpi_driver);
+	if (result < 0)
+		goto fail_acpi_driver;
+
+	return 0;
+
+fail_acpi_driver:
+	platform_driver_unregister(&fjes_driver);
+	return result;
+}
+
+module_init(fjes_init_module);
+
+/* fjes_exit_module - Driver Exit Cleanup Routine */
+static void __exit fjes_exit_module(void)
+{
+	acpi_bus_unregister_driver(&fjes_acpi_driver);
+	platform_driver_unregister(&fjes_driver);
+}
+
+module_exit(fjes_exit_module);
+
-- 
1.8.3.1

