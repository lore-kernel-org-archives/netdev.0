From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 01/22] fjes: Introduce FUJITSU Extended Socket Network Device driver
Date: Thu, 18 Jun 2015 09:49:26 +0900
Message-ID: <1434588587-25655-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1434588359-25589-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: rkhan@redhat.com, alexander.h.duyck@redhat.com,
	netdev@vger.kernel.org, linux-acpi@vger.kernel.org,
	Taku Izumi <izumi.taku@jp.fujitsu.com>
To: platform-driver-x86@vger.kernel.org, dvhart@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm04.jp.fujitsu.com ([202.219.69.171]:47513 "EHLO
	mgwkm04.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751684AbbFRAxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 20:53:05 -0400
In-Reply-To: <1434588359-25589-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the basic code of FUJITSU Extended Socket
Network Device driver.

When "PNP0C02" is found in ACPI DSDT, it evaluates "_STR"
to check if "PNP0C02" is for Extended Socket device driver
and retrieves ACPI resource information. Then creates
platform_device.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/platform/x86/Kconfig          |   7 +
 drivers/platform/x86/Makefile         |   2 +
 drivers/platform/x86/fjes/Makefile    |  31 +++++
 drivers/platform/x86/fjes/fjes.h      |  34 +++++
 drivers/platform/x86/fjes/fjes_main.c | 235 ++++++++++++++++++++++++++++++++++
 5 files changed, 309 insertions(+)
 create mode 100644 drivers/platform/x86/fjes/Makefile
 create mode 100644 drivers/platform/x86/fjes/fjes.h
 create mode 100644 drivers/platform/x86/fjes/fjes_main.c

diff --git a/drivers/platform/x86/Kconfig b/drivers/platform/x86/Kconfig
index 9752761..353b613 100644
--- a/drivers/platform/x86/Kconfig
+++ b/drivers/platform/x86/Kconfig
@@ -884,4 +884,11 @@ config PVPANIC
 	  a paravirtualized device provided by QEMU; it lets a virtual machine
 	  (guest) communicate panic events to the host.
 
+config FUJITSU_ES
+	tristate "FUJITSU Extended Socket Network Device driver"
+	depends on ACPI
+	---help---
+	  This driver provides support for Extended Socket network device on
+	  Extended Partitioning of FUJITSU PRIMEQUEST 2000 series.
+
 endif # X86_PLATFORM_DEVICES
diff --git a/drivers/platform/x86/Makefile b/drivers/platform/x86/Makefile
index f82232b..a88516c 100644
--- a/drivers/platform/x86/Makefile
+++ b/drivers/platform/x86/Makefile
@@ -58,3 +58,5 @@ obj-$(CONFIG_INTEL_SMARTCONNECT)	+= intel-smartconnect.o
 
 obj-$(CONFIG_PVPANIC)           += pvpanic.o
 obj-$(CONFIG_ALIENWARE_WMI)	+= alienware-wmi.o
+
+obj-$(CONFIG_FUJITSU_ES)        += fjes/
diff --git a/drivers/platform/x86/fjes/Makefile b/drivers/platform/x86/fjes/Makefile
new file mode 100644
index 0000000..98e59cb
--- /dev/null
+++ b/drivers/platform/x86/fjes/Makefile
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
diff --git a/drivers/platform/x86/fjes/fjes.h b/drivers/platform/x86/fjes/fjes.h
new file mode 100644
index 0000000..5586305
--- /dev/null
+++ b/drivers/platform/x86/fjes/fjes.h
@@ -0,0 +1,34 @@
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
diff --git a/drivers/platform/x86/fjes/fjes_main.c b/drivers/platform/x86/fjes/fjes_main.c
new file mode 100644
index 0000000..258929a1
--- /dev/null
+++ b/drivers/platform/x86/fjes/fjes_main.c
@@ -0,0 +1,235 @@
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
+
+MODULE_AUTHOR("Taku Izumi <izumi.taku@jp.fujitsu.com>");
+MODULE_DESCRIPTION("FUJITSU Extended Socket Network Device Driver");
+MODULE_LICENSE("GPL");
+MODULE_VERSION(DRV_VERSION);
+
+
+static int fjes_acpi_add(struct acpi_device *);
+static int fjes_acpi_remove(struct acpi_device *);
+static acpi_status fjes_get_acpi_resource(struct acpi_resource *, void*);
+
+static int fjes_probe(struct platform_device *);
+static int fjes_remove(struct platform_device *);
+
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
+				str->string.length, UTF16_LITTLE_ENDIAN,
+				str_buf, sizeof(str_buf) - 1);
+	str_buf[result] = 0;
+
+	if (strncmp(FJES_ACPI_SYMBOL, str_buf, strlen(FJES_ACPI_SYMBOL)) != 0) {
+		kfree(buffer.pointer);
+		return -ENODEV;
+	}
+	kfree(buffer.pointer);
+
+	status = acpi_walk_resources(device->handle, METHOD_NAME__CRS,
+				fjes_get_acpi_resource, fjes_resource);
+	if (ACPI_FAILURE(status))
+		return -ENODEV;
+
+	/* create platform_device */
+	plat_dev = platform_device_register_simple(DRV_NAME, 0,
+				fjes_resource, ARRAY_SIZE(fjes_resource));
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
+static acpi_status fjes_get_acpi_resource(struct acpi_resource *acpi_res,
+		void *data)
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
+			addr->address.address_length;
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
+/*
+ *  fjes_probe - Device Initialization Routine
+ *
+ *  Returns 0 on success, negative on failure
+ */
+static int fjes_probe(struct platform_device *plat_dev)
+{
+	return 0;
+}
+
+/*
+ *  fjes_remove - Device Removal Routine
+ */
+static int fjes_remove(struct platform_device *plat_dev)
+{
+	return 0;
+}
+
+
+/*
+ *  fjes_init_module - Driver Registration Routine
+ *
+ *  fjes_init_module is the first routine called when the driver is
+ *  loaded.
+ */
+static int __init fjes_init_module(void)
+{
+	int result;
+
+	pr_info("%s - version %s\n",
+			fjes_driver_string, fjes_driver_version);
+	pr_info("%s\n", fjes_copyright);
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
+
+/*
+ *  fjes_exit_module - Driver Exit Cleanup Routine
+ *
+ *  fjes_exit_module is called just before the driver is removed from memory.
+ */
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
