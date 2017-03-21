From: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Subject: [PATCH v3 1/2] fjes: Do not load fjes driver if system does not have
 extended socket device.
Date: Tue, 21 Mar 2017 11:44:25 -0400
Message-ID: <8a4a2203-9047-88b9-caad-d1c67b1fe9f2@gmail.com>
References: <c0bb31ae-1f5b-9b73-ed51-a8d56361ff59@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, izumi.taku@jp.fujitsu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:35262 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933049AbdCUPuf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 11:50:35 -0400
Received: by mail-qt0-f196.google.com with SMTP id r5so21915699qtb.2
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 08:50:34 -0700 (PDT)
In-Reply-To: <c0bb31ae-1f5b-9b73-ed51-a8d56361ff59@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fjes driver is used only by FUJITSU servers and almost of all
servers in the world never use it. But currently if ACPI PNP0C02
is defined in the ACPI table, the following message is always shown:

 "FUJITSU Extended Socket Network Device Driver - version 1.2
  - Copyright (c) 2015 FUJITSU LIMITED"

The message makes users confused because there is no reason that
the message is shown in other vendor servers.

To avoid the confusion, the patch adds a check that the server
has a extended socket device or not.

Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
CC: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
v3:
	- Rebase on net tree

v2:
	- Order local variable declarations from longest to shortest line

 drivers/net/fjes/fjes_main.c | 52 +++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 47 insertions(+), 5 deletions(-)

diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index c4b3c4b..7b58964 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -45,6 +45,8 @@
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);

+#define ACPI_MOTHERBOARD_RESOURCE_HID "PNP0C02"
+
 static int fjes_request_irq(struct fjes_adapter *);
 static void fjes_free_irq(struct fjes_adapter *);

@@ -78,7 +80,7 @@
 static int fjes_poll(struct napi_struct *, int);

 static const struct acpi_device_id fjes_acpi_ids[] = {
-	{"PNP0C02", 0},
+	{ACPI_MOTHERBOARD_RESOURCE_HID, 0},
 	{"", 0},
 };
 MODULE_DEVICE_TABLE(acpi, fjes_acpi_ids);
@@ -115,18 +117,17 @@
 	},
 };

-static int fjes_acpi_add(struct acpi_device *device)
+static bool is_extended_socket_device(struct acpi_device *device)
 {
 	struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL};
 	char str_buf[sizeof(FJES_ACPI_SYMBOL) + 1];
-	struct platform_device *plat_dev;
 	union acpi_object *str;
 	acpi_status status;
 	int result;

 	status = acpi_evaluate_object(device->handle, "_STR", NULL, &buffer);
 	if (ACPI_FAILURE(status))
-		return -ENODEV;
+		return false;

 	str = buffer.pointer;
 	result = utf16s_to_utf8s((wchar_t *)str->string.pointer,
@@ -136,10 +137,21 @@ static int fjes_acpi_add(struct acpi_device *device)

 	if (strncmp(FJES_ACPI_SYMBOL, str_buf, strlen(FJES_ACPI_SYMBOL)) != 0) {
 		kfree(buffer.pointer);
-		return -ENODEV;
+		return false;
 	}
 	kfree(buffer.pointer);

+	return true;
+}
+
+static int fjes_acpi_add(struct acpi_device *device)
+{
+	struct platform_device *plat_dev;
+	acpi_status status;
+
+	if (!is_extended_socket_device(device))
+		return -ENODEV;
+
 	status = acpi_walk_resources(device->handle, METHOD_NAME__CRS,
 				     fjes_get_acpi_resource, fjes_resource);
 	if (ACPI_FAILURE(status))
@@ -1473,11 +1485,41 @@ static void fjes_watch_unshare_task(struct work_struct *work)
 	}
 }

+static acpi_status
+acpi_find_extended_socket_device(acpi_handle obj_handle, u32 level,
+				 void *context, void **return_value)
+{
+	struct acpi_device *device;
+	bool *found = context;
+	int result;
+
+	result = acpi_bus_get_device(obj_handle, &device);
+	if (result)
+		return AE_OK;
+
+	if (strcmp(acpi_device_hid(device), ACPI_MOTHERBOARD_RESOURCE_HID))
+		return AE_OK;
+
+	if (!is_extended_socket_device(device))
+		return AE_OK;
+
+	*found = true;
+	return AE_CTRL_TERMINATE;
+}
+
 /* fjes_init_module - Driver Registration Routine */
 static int __init fjes_init_module(void)
 {
+	bool found = false;
 	int result;

+	acpi_walk_namespace(ACPI_TYPE_DEVICE, ACPI_ROOT_OBJECT, ACPI_UINT32_MAX,
+			    acpi_find_extended_socket_device, NULL, &found,
+			    NULL);
+
+	if (!found)
+		return -ENODEV;
+
 	pr_info("%s - version %s - %s\n",
 		fjes_driver_string, fjes_driver_version, fjes_copyright);

-- 
1.8.3.1



On 03/21/2017 11:28 AM, YASUAKI ISHIMATSU wrote:
> The fjes driver is used only by FUJITSU servers and almost of all
> servers in the world never use it. But currently if ACPI PNP0C02
> is defined in the ACPI table, the following message is always shown:
> 
>  "FUJITSU Extended Socket Network Device Driver - version 1.2
>   - Copyright (c) 2015 FUJITSU LIMITED"
> 
> The message makes users confused because there is no reason that
> the message is shown in other vendor servers.
> 
> To avoid the confusion, the patch adds several checks.
> 
> v3:
>   - Rebase on latest net tree.
>   - Add _STA method check to avoid loading fjes driver.
> 
> v2:
>   - Order local variable declarations from longest to shortest line
> 
> Yasuaki Ishimatsu(2):
>   fjes: Do not load fjes driver if system does not have extended socket device.
>   fjes: Do not load fjes driver if extended socket device is not power on.
> 
>  drivers/net/fjes/fjes_main.c | 76 +++++++++++++++++++++++++++++++++++++++++---
>  1 file changed, 71 insertions(+), 5 deletions(-)
> 
