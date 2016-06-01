From: Mario Limonciello <mario_limonciello@dell.com>
Subject: [PATCH] r8152: Add support for setting MAC to system's Auxiliary MAC address
Date: Wed,  1 Jun 2016 16:50:44 -0500
Message-ID: <1464817844-27206-1-git-send-email-mario_limonciello@dell.com>
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Linux USB <linux-usb@vger.kernel.org>, pali.rohar@gmail.com,
	anthony.wong@canonical.com,
	Mario Limonciello <mario_limonciello@dell.com>
To: hayeswang@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxipps301.us.dell.com ([143.166.148.223]:31645 "EHLO
	ausxipps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932089AbcFAVvC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 17:51:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dell systems with Type-C ports have support for a persistent system
specific MAC address when used with Dell Type-C docks and dongles.
This means a dock plugged into two different systems will show different
(but persistent) MAC addresses.  Dell Type-C docks and dongles use the
r8152 driver.

This information for the system's persistent MAC address is burned in when
the HW is built and avilable under _SB\AMAC in the DSDT at runtime.

More information about the technology is available here:
http://www.dell.com/support/article/us/en/04/SLN301147

Signed-off-by: Mario Limonciello <mario_limonciello@dell.com>
---
 drivers/net/usb/Kconfig |  1 +
 drivers/net/usb/r8152.c | 37 +++++++++++++++++++++++++++++++++++++
 2 files changed, 38 insertions(+)

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index cdde590..c320930 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -98,6 +98,7 @@ config USB_RTL8150
 config USB_RTL8152
 	tristate "Realtek RTL8152/RTL8153 Based USB Ethernet Adapters"
 	select MII
+	depends on ACPI
 	help
 	  This option adds support for Realtek RTL8152 based USB 2.0
 	  10/100 Ethernet adapters and RTL8153 based USB 3.0 10/100/1000
diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 3f9f6ed..62af3b4 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -26,6 +26,7 @@
 #include <linux/mdio.h>
 #include <linux/usb/cdc.h>
 #include <linux/suspend.h>
+#include <linux/acpi.h>
 
 /* Information for net-next */
 #define NETNEXT_VERSION		"08"
@@ -1030,6 +1031,39 @@ out1:
 	return ret;
 }
 
+static u8 amac_ascii_to_hex(int c)
+{
+	if (c <= 0x39)
+		return (u8)(c - 0x30);
+	else if (c <= 0x46)
+		return (u8)(c - 0x37);
+	return (u8)(c - 0x57);
+}
+
+static void set_auxiliary_addr(struct sockaddr *sa)
+{
+	acpi_status status;
+	acpi_handle handle;
+	struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL };
+	union acpi_object *obj;
+	int i;
+	char *ptr;
+
+	acpi_get_handle(NULL, "\\_SB", &handle);
+	status = acpi_evaluate_object(handle, "AMAC", NULL, &buffer);
+	obj = (union acpi_object *)buffer.pointer;
+	if (ACPI_SUCCESS(status) && (obj->string.length == 0x17)) {
+		/* returns _AUXMAC_#AABBCCDDEEFF#
+		 * this pulls out _AUXMAC# from start and # from end
+		 */
+		ptr = obj->string.pointer + 9;
+		pr_info("r8152: Using system auxiliary MAC address");
+		for (i = 0; i < 6; i++, ptr += 2)
+			sa->sa_data[i] = amac_ascii_to_hex(*ptr) << 4 |
+					 amac_ascii_to_hex(*(ptr + 1));
+	}
+}
+
 static int set_ethernet_addr(struct r8152 *tp)
 {
 	struct net_device *dev = tp->netdev;
@@ -1041,6 +1075,9 @@ static int set_ethernet_addr(struct r8152 *tp)
 	else
 		ret = pla_ocp_read(tp, PLA_BACKUP, 8, sa.sa_data);
 
+	/* if system provides auxiliary MAC address */
+	set_auxiliary_addr(&sa);
+
 	if (ret < 0) {
 		netif_err(tp, probe, dev, "Get ether addr fail\n");
 	} else if (!is_valid_ether_addr(sa.sa_data)) {
-- 
2.7.4
