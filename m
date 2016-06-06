From: Mario Limonciello <mario_limonciello@dell.com>
Subject: [PATCH v3] r8152: Add support for setting pass through MAC address on RTL8153-AD
Date: Mon,  6 Jun 2016 09:15:21 -0500
Message-ID: <1465222521-7217-2-git-send-email-mario_limonciello@dell.com>
References: <1465222521-7217-1-git-send-email-mario_limonciello@dell.com>
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Linux USB <linux-usb@vger.kernel.org>, pali.rohar@gmail.com,
	anthony.wong@canonical.com, Greg KH <gregkh@linuxfoundation.org>,
	Mario Limonciello <mario_limonciello@dell.com>
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465222521-7217-1-git-send-email-mario_limonciello@dell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The RTL8153-AD supports a persistent system specific MAC address.
This means a device plugged into two different systems with host side
support will show different (but persistent) MAC addresses.

This information for the system's persistent MAC address is burned in when
the system HW is built and available under _SB\AMAC in the DSDT at runtime.

This technology is currently implemented in the Dell TB15 and WD15 Type-C
docks.  More information is available here:
http://www.dell.com/support/article/us/en/04/SLN301147

Signed-off-by: Mario Limonciello <mario_limonciello@dell.com>
---
 drivers/net/usb/r8152.c | 60 +++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 58 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 3f9f6ed..f4bd46d 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -26,6 +26,7 @@
 #include <linux/mdio.h>
 #include <linux/usb/cdc.h>
 #include <linux/suspend.h>
+#include <linux/acpi.h>
 
 /* Information for net-next */
 #define NETNEXT_VERSION		"08"
@@ -455,6 +456,11 @@
 /* SRAM_IMPEDANCE */
 #define RX_DRIVING_MASK		0x6000
 
+/* MAC PASSTHRU */
+#define AD_MASK			0xfee0
+#define EFUSE			0xcfdb
+#define PASS_THRU_MASK		0x1
+
 enum rtl_register_content {
 	_1000bps	= 0x10,
 	_100bps		= 0x08,
@@ -1030,6 +1036,53 @@ out1:
 	return ret;
 }
 
+static int get_passthru_addr(struct r8152 *tp, struct sockaddr *sa)
+{
+	acpi_status status;
+	struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL };
+	union acpi_object *obj;
+	int ret = -EINVAL;
+	u32 ocp_data;
+	unsigned char buf[6];
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_MISC_0);
+	if ((ocp_data & AD_MASK) != 0x1000)
+		return -ENODEV;
+
+	ocp_data = ocp_read_byte(tp, MCU_TYPE_USB, EFUSE);
+	if ((ocp_data & PASS_THRU_MASK) != 1)
+		return -ENODEV;
+
+	/* returns _AUXMAC_#AABBCCDDEEFF# */
+	status = acpi_evaluate_object(NULL, "\\_SB.AMAC", NULL, &buffer);
+	obj = (union acpi_object *)buffer.pointer;
+	if (ACPI_SUCCESS(status)) {
+		if (obj->type != ACPI_TYPE_BUFFER ||
+		    obj->string.length != 0x17) {
+			pr_warn("r8152: get_passthru_addr: Invalid buffer");
+			goto amacout;
+		}
+		if (strncmp(obj->string.pointer, "_AUXMAC_#", 9) != 0) {
+			pr_warn("r8152: get_passthru_addr: Invalid header");
+			goto amacout;
+		}
+		ret = hex2bin(buf, obj->string.pointer + 9, 6);
+		if (ret < 0 || !is_valid_ether_addr(buf)) {
+			pr_warn("r8152: get_passthru_addr: Invalid MAC");
+			goto amacout;
+		}
+		memcpy(sa->sa_data, buf, 6);
+		ether_addr_copy(tp->netdev->dev_addr, sa->sa_data);
+		netdev_info(tp->netdev, "Using pass-through MAC address %pM\n",
+			    sa->sa_data);
+		ret = 0;
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
@@ -1038,8 +1091,11 @@ static int set_ethernet_addr(struct r8152 *tp)
 
 	if (tp->version == RTL_VER_01)
 		ret = pla_ocp_read(tp, PLA_IDR, 8, sa.sa_data);
-	else
-		ret = pla_ocp_read(tp, PLA_BACKUP, 8, sa.sa_data);
+	else {
+		ret = get_passthru_addr(tp, &sa);
+		if (ret < 0)
+			ret = pla_ocp_read(tp, PLA_BACKUP, 8, sa.sa_data);
+	}
 
 	if (ret < 0) {
 		netif_err(tp, probe, dev, "Get ether addr fail\n");
-- 
2.7.4
