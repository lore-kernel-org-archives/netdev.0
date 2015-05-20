From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 3/7] fjes: Implement platform_driver functionality
Date: Wed, 20 May 2015 08:18:48 +0000
Message-ID: <E86EADE93E2D054CBCD4E708C38D364A5422D850@G01JPEXMBYT01>
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


This patch adds implementation of platform_device driver
to FUJITSU Extended Socket Network Device driver.

When "PNP0C02" is found and ACPI resource can be retrieved
successfuly, this driver creates platform_device.
platform_driver.probe and .remove routine are mock code.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/platform/x86/fjes/fjes_main.c | 47 +++++++++++++++++++++++++++++++++++
 1 file changed, 47 insertions(+)

diff --git a/drivers/platform/x86/fjes/fjes_main.c b/drivers/platform/x86/fjes/fjes_main.c
index 3454098..87057b8 100644
--- a/drivers/platform/x86/fjes/fjes_main.c
+++ b/drivers/platform/x86/fjes/fjes_main.c
@@ -22,6 +22,7 @@
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/nls.h>
+#include <linux/platform_device.h>
 
 #include "fjes.h"
 
@@ -47,6 +48,9 @@ static int fjes_acpi_add(struct acpi_device *);
 static int fjes_acpi_remove(struct acpi_device *);
 static acpi_status fjes_get_acpi_resource(struct acpi_resource *, void*);
 
+static int fjes_probe(struct platform_device *);
+static int fjes_remove(struct platform_device *);
+
 
 static const struct acpi_device_id fjes_acpi_ids[] = {
 	{"PNP0C02", 0},
@@ -65,6 +69,15 @@ static struct acpi_driver fjes_acpi_driver = {
 	},
 };
 
+static struct platform_driver fjes_driver = {
+	.driver = {
+		.name = DRV_NAME,
+		.owner = THIS_MODULE,
+	},
+	.probe = fjes_probe,
+	.remove = fjes_remove,
+};
+
 static struct resource fjes_resource[] = {
 	{
 		.flags = IORESOURCE_MEM,
@@ -93,6 +106,10 @@ static int __init fjes_init_module(void)
 			fjes_driver_string, fjes_driver_version);
 	pr_info("%s\n", fjes_copyright);
 
+	result = platform_driver_register(&fjes_driver);
+	if (result < 0)
+		return result;
+
 	result = acpi_bus_register_driver(&fjes_acpi_driver);
 	if (result < 0)
 		goto fail_acpi_driver;
@@ -100,6 +117,7 @@ static int __init fjes_init_module(void)
 	return 0;
 
 fail_acpi_driver:
+	platform_driver_unregister(&fjes_driver);
 	return result;
 }
 
@@ -114,6 +132,7 @@ module_init(fjes_init_module);
 static void __exit fjes_exit_module(void)
 {
 	acpi_bus_unregister_driver(&fjes_acpi_driver);
+	platform_driver_unregister(&fjes_driver);
 }
 
 module_exit(fjes_exit_module);
@@ -126,6 +145,7 @@ static int fjes_acpi_add(struct acpi_device *device)
 	union acpi_object *str;
 	char str_buf[sizeof(FJES_ACPI_SYMBOL) + 1];
 	int result;
+	struct platform_device *plat_dev;
 
 	status = acpi_evaluate_object(device->handle, "_STR", NULL, &buffer);
 	if (ACPI_FAILURE(status))
@@ -148,11 +168,21 @@ static int fjes_acpi_add(struct acpi_device *device)
 	if (ACPI_FAILURE(status))
 		return -ENODEV;
 
+	/* create platform_device */
+	plat_dev = platform_device_register_simple(DRV_NAME, 0,
+				fjes_resource, ARRAY_SIZE(fjes_resource));
+	device->driver_data = plat_dev;
+
 	return 0;
 }
 
 static int fjes_acpi_remove(struct acpi_device *device)
 {
+	struct platform_device *plat_dev;
+
+	plat_dev = (struct platform_device *)acpi_driver_data(device);
+	platform_device_unregister(plat_dev);
+
 	return 0;
 }
 
@@ -186,5 +216,22 @@ static acpi_status fjes_get_acpi_resource(struct acpi_resource *acpi_res,
 	return AE_OK;
 }
 
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
 
 
-- 
1.8.3.1
