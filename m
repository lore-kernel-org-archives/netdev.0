From: Mario Limonciello <mario_limonciello@dell.com>
Subject: [PATCH v2] r8152: Add support for setting MAC to system's Auxiliary MAC address
Date: Thu,  2 Jun 2016 11:58:07 -0500
Message-ID: <1464886687-16284-2-git-send-email-mario_limonciello@dell.com>
References: <1464886687-16284-1-git-send-email-mario_limonciello@dell.com>
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Linux USB <linux-usb@vger.kernel.org>, pali.rohar@gmail.com,
	anthony.wong@canonical.com, Greg KH <gregkh@linuxfoundation.org>,
	Mario Limonciello <mario_limonciello@dell.com>
To: hayeswang@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from AUSXIPPS310.us.dell.com ([143.166.148.211]:36740 "EHLO
	ausxipps310.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161332AbcFBQ6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 12:58:23 -0400
In-Reply-To: <1464886687-16284-1-git-send-email-mario_limonciello@dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dell systems with Type-C ports have support for a persistent system
specific MAC address when used with Dell Type-C docks and dongles.
This means a dock plugged into two different systems will show different
(but persistent) MAC addresses.  Dell Type-C docks and dongles use the
r8152 driver.

This information for the system's persistent MAC address is burned in when
the HW is built and available under _SB\AMAC in the DSDT at runtime.

More information about the technology is available here:
http://www.dell.com/support/article/us/en/04/SLN301147

Signed-off-by: Mario Limonciello <mario_limonciello@dell.com>
---
 drivers/net/usb/r8152.c | 53 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 53 insertions(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 3f9f6ed..6dea542 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -26,6 +26,8 @@
 #include <linux/mdio.h>
 #include <linux/usb/cdc.h>
 #include <linux/suspend.h>
+#include <linux/acpi.h>
+#include <linux/dmi.h>
 
 /* Information for net-next */
 #define NETNEXT_VERSION		"08"
@@ -500,6 +502,7 @@ enum rtl8152_flags {
 	SELECTIVE_SUSPEND,
 	PHY_RESET,
 	SCHEDULE_NAPI,
+	MAC_PASSTHRU = 0,
 };
 
 /* Define these values to match your device */
@@ -653,6 +656,7 @@ enum tx_csum_stat {
  */
 static const int multicast_filter_limit = 32;
 static unsigned int agg_buf_sz = 16384;
+static bool mac_passthru_active;
 
 #define RTL_LIMITED_TSO_SIZE	(agg_buf_sz - sizeof(struct tx_desc) - \
 				 VLAN_ETH_HLEN - VLAN_HLEN)
@@ -1030,6 +1034,49 @@ out1:
 	return ret;
 }
 
+static int get_auxiliary_addr(struct r8152 *tp, struct sockaddr *sa)
+{
+	acpi_status status;
+	struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL };
+	union acpi_object *obj;
+	int ret = -1;
+	unsigned char buf[6];
+
+	if (!dmi_name_in_vendors("Dell Inc.") || mac_passthru_active)
+		return -1;
+
+	/* returns _AUXMAC_#AABBCCDDEEFF# */
+	status = acpi_evaluate_object(NULL, "\\_SB.AMAC", NULL, &buffer);
+	obj = (union acpi_object *)buffer.pointer;
+	if (ACPI_SUCCESS(status)) {
+		if (obj->type != ACPI_TYPE_BUFFER ||
+		    obj->string.length != 0x17) {
+			pr_warn("r8152: get_auxiliary_addr: Invalid buffer");
+			goto amacout;
+		}
+		if (strncmp(obj->string.pointer, "_AUXMAC_#", 9) != 0) {
+			pr_warn("r8152: get_auxiliary_addr: Invalid header");
+			goto amacout;
+		}
+		ret = hex2bin(buf, obj->string.pointer + 9, 6);
+		if (ret < 0) {
+			pr_warn("r8152: get_auxiliary_addr: Invalid MAC");
+			goto amacout;
+		}
+		memcpy(sa->sa_data, buf, 6);
+		ether_addr_copy(tp->netdev->dev_addr, sa->sa_data);
+		netdev_info(tp->netdev, "Using system MAC address %pM\n",
+			    sa->sa_data);
+		set_bit(MAC_PASSTHRU, &tp->flags);
+		mac_passthru_active = true;
+		ret = 1;
+	}
+
+amacout:
+	kfree(obj);
+	return ret;
+}
+
 static int set_ethernet_addr(struct r8152 *tp)
 {
 	struct net_device *dev = tp->netdev;
@@ -1041,6 +1088,10 @@ static int set_ethernet_addr(struct r8152 *tp)
 	else
 		ret = pla_ocp_read(tp, PLA_BACKUP, 8, sa.sa_data);
 
+	/* if system provides auxiliary MAC address */
+	if (get_auxiliary_addr(tp, &sa))
+		ret = 0;
+
 	if (ret < 0) {
 		netif_err(tp, probe, dev, "Get ether addr fail\n");
 	} else if (!is_valid_ether_addr(sa.sa_data)) {
@@ -4268,6 +4319,8 @@ static void rtl8152_disconnect(struct usb_interface *intf)
 		if (udev->state == USB_STATE_NOTATTACHED)
 			set_bit(RTL8152_UNPLUG, &tp->flags);
 
+		if (test_bit(MAC_PASSTHRU, &tp->flags))
+			mac_passthru_active = false;
 		netif_napi_del(&tp->napi);
 		unregister_netdev(tp->netdev);
 		tp->rtl_ops.unload(tp);
-- 
2.7.4
