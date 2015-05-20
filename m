From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 2/7] fjes: Implement acpi_driver functionality
Date: Wed, 20 May 2015 08:18:06 +0000
Message-ID: <E86EADE93E2D054CBCD4E708C38D364A5422D83E@G01JPEXMBYT01>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Cc: "Hart, Darren" <darren.hart@intel.com>,
	"rkhan@redhat.com" <rkhan@redhat.com>,
	"alexander.h.duyck@redhat.com" <alexander.h.duyck@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>
To: "platform-driver-x86@vger.kernel.org"
	<platform-driver-x86@vger.kernel.org>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Language: ja-JP
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch adds implementation of "PNP0C02" acpi_device driver
to FUJITSU Extended Socket Network Device driver.

When "PNP0C02" is found in ACPI DSDT, it evaluates "_STR"
to check if "PNP0C02" is for Extended Socket device driver
and retrieves ACPI resource information.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/platform/x86/fjes/fjes.h      |   4 ++
 drivers/platform/x86/fjes/fjes_main.c | 116 ++++++++++++++++++++++++++++++++++
 2 files changed, 120 insertions(+)

diff --git a/drivers/platform/x86/fjes/fjes.h b/drivers/platform/x86/fjes/fjes.h
index f12fe11..5586305 100644
--- a/drivers/platform/x86/fjes/fjes.h
+++ b/drivers/platform/x86/fjes/fjes.h
@@ -23,6 +23,10 @@
 #ifndef FJES_H_
 #define FJES_H_
 
+#include <linux/acpi.h>
+
+#define FJES_ACPI_SYMBOL	"Extended Socket"
+
 extern char fjes_driver_name[];
 extern char fjes_driver_version[];
 extern u32 fjes_support_mtu[];
diff --git a/drivers/platform/x86/fjes/fjes_main.c b/drivers/platform/x86/fjes/fjes_main.c
index f1e2fa0..3454098 100644
--- a/drivers/platform/x86/fjes/fjes_main.c
+++ b/drivers/platform/x86/fjes/fjes_main.c
@@ -21,6 +21,7 @@
 
 #include <linux/module.h>
 #include <linux/types.h>
+#include <linux/nls.h>
 
 #include "fjes.h"
 
@@ -42,6 +43,42 @@ MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
 
+static int fjes_acpi_add(struct acpi_device *);
+static int fjes_acpi_remove(struct acpi_device *);
+static acpi_status fjes_get_acpi_resource(struct acpi_resource *, void*);
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
+
 /*
  *  fjes_init_module - Driver Registration Routine
  *
@@ -50,11 +87,20 @@ MODULE_VERSION(DRV_VERSION);
  */
 static int __init fjes_init_module(void)
 {
+	int result;
+
 	pr_info("%s - version %s\n",
 			fjes_driver_string, fjes_driver_version);
 	pr_info("%s\n", fjes_copyright);
 
+	result = acpi_bus_register_driver(&fjes_acpi_driver);
+	if (result < 0)
+		goto fail_acpi_driver;
+
 	return 0;
+
+fail_acpi_driver:
+	return result;
 }
 
 module_init(fjes_init_module);
@@ -67,8 +113,78 @@ module_init(fjes_init_module);
  */
 static void __exit fjes_exit_module(void)
 {
+	acpi_bus_unregister_driver(&fjes_acpi_driver);
 }
 
 module_exit(fjes_exit_module);
 
 
+static int fjes_acpi_add(struct acpi_device *device)
+{
+	acpi_status status;
+	struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL};
+	union acpi_object *str;
+	char str_buf[sizeof(FJES_ACPI_SYMBOL) + 1];
+	int result;
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
+	return 0;
+}
+
+static int fjes_acpi_remove(struct acpi_device *device)
+{
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
+
+
-- 
1.8.3.1
