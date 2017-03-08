From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Subject: [PATCH v2] fjes: Do not load fjes driver if system does not have
 extended socket device.
Date: Wed, 8 Mar 2017 16:05:18 -0500
Message-ID: <7a1a2dbc-99e0-06ba-2261-6e6382937486@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, izumi.taku@jp.fujitsu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:34881 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751286AbdCHWmK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 17:42:10 -0500
Received: by mail-qk0-f196.google.com with SMTP id o135so15527355qke.2
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 14:41:10 -0800 (PST)
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
v2:
	- Order local variable declarations from longest to shortest line

  drivers/net/fjes/fjes_main.c | 52 +++++++++++++++++++++++++++++++++++++++-----
  1 file changed, 47 insertions(+), 5 deletions(-)

diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index b77e4ecf..a57c2cb 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -45,6 +45,8 @@
  MODULE_LICENSE("GPL");
  MODULE_VERSION(DRV_VERSION);

+#define ACPI_MOTHERBOARD_RESOURCE_HID "PNP0C02"
+
  static int fjes_request_irq(struct fjes_adapter *);
  static void fjes_free_irq(struct fjes_adapter *);

@@ -79,7 +81,7 @@
  static int fjes_poll(struct napi_struct *, int);

  static const struct acpi_device_id fjes_acpi_ids[] = {
-	{"PNP0C02", 0},
+	{ACPI_MOTHERBOARD_RESOURCE_HID, 0},
  	{"", 0},
  };
  MODULE_DEVICE_TABLE(acpi, fjes_acpi_ids);
@@ -116,18 +118,17 @@
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
@@ -137,10 +138,21 @@ static int fjes_acpi_add(struct acpi_device *device)

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
@@ -1476,11 +1488,41 @@ static void fjes_watch_unshare_task(struct work_struct *work)
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
