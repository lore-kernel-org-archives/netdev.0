From: Mario Limonciello <mario_limonciello@dell.com>
Subject: [PATCH v6 RESEND] r8152: Add support for setting pass through MAC address on RTL8153-AD
Date: Mon, 11 Jul 2016 19:58:04 -0500
Message-ID: <1468285084-26557-1-git-send-email-mario_limonciello@dell.com>
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Linux USB <linux-usb@vger.kernel.org>,
	anthony.wong@canonical.com,
	Mario Limonciello <mario_limonciello@dell.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The RTL8153-AD supports a persistent system specific MAC address.
This means a device plugged into two different systems with host side
support will show different (but persistent) MAC addresses.

This information for the system's persistent MAC address is burned in when
the system HW is built and available under \_SB.AMAC in the DSDT at runtime.

This technology is currently implemented in the Dell TB15 and WD15 Type-C
docks.  More information is available here:
http://www.dell.com/support/article/us/en/04/SLN301147

Signed-off-by: Mario Limonciello <mario_limonciello@dell.com>
---
 drivers/net/usb/r8152.c | 76 +++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 74 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 0da72d3..2298f26 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -26,6 +26,7 @@
 #include <linux/mdio.h>
 #include <linux/usb/cdc.h>
 #include <linux/suspend.h>
+#include <linux/acpi.h>
 
 /* Information for net-next */
 #define NETNEXT_VERSION		"08"
@@ -460,6 +461,11 @@
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
@@ -1036,6 +1042,65 @@ out1:
 	return ret;
 }
 
+/* Devices containing RTL8153-AD can support a persistent
+ * host system provided MAC address.
+ * Examples of this are Dell TB15 and Dell WD15 docks
+ */
+static int vendor_mac_passthru_addr_read(struct r8152 *tp, struct sockaddr *sa)
+{
+	acpi_status status;
+	struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL };
+	union acpi_object *obj;
+	int ret = -EINVAL;
+	u32 ocp_data;
+	unsigned char buf[6];
+
+	/* test for -AD variant of RTL8153 */
+	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_MISC_0);
+	if ((ocp_data & AD_MASK) != 0x1000)
+		return -ENODEV;
+
+	/* test for MAC address pass-through bit */
+	ocp_data = ocp_read_byte(tp, MCU_TYPE_USB, EFUSE);
+	if ((ocp_data & PASS_THRU_MASK) != 1)
+		return -ENODEV;
+
+	/* returns _AUXMAC_#AABBCCDDEEFF# */
+	status = acpi_evaluate_object(NULL, "\\_SB.AMAC", NULL, &buffer);
+	obj = (union acpi_object *)buffer.pointer;
+	if (!ACPI_SUCCESS(status))
+		return -ENODEV;
+	if (obj->type != ACPI_TYPE_BUFFER || obj->string.length != 0x17) {
+		netif_warn(tp, probe, tp->netdev,
+			   "Invalid buffer when reading pass-thru MAC addr: "
+			   "(%d, %d)\n",
+			   obj->type, obj->string.length);
+		goto amacout;
+	}
+	if (strncmp(obj->string.pointer, "_AUXMAC_#", 9) != 0 ||
+	    strncmp(obj->string.pointer + 0x15, "#", 1) != 0) {
+		netif_warn(tp, probe, tp->netdev,
+			   "Invalid header when reading pass-thru MAC addr\n");
+		goto amacout;
+	}
+	ret = hex2bin(buf, obj->string.pointer + 9, 6);
+	if (!(ret == 0 && is_valid_ether_addr(buf))) {
+		netif_warn(tp, probe, tp->netdev,
+			   "Invalid MAC when reading pass-thru MAC addr: "
+			   "%d, %pM\n", ret, buf);
+		ret = -EINVAL;
+		goto amacout;
+	}
+	memcpy(sa->sa_data, buf, 6);
+	ether_addr_copy(tp->netdev->dev_addr, sa->sa_data);
+	netif_info(tp, probe, tp->netdev,
+		   "Using pass-thru MAC addr %pM\n", sa->sa_data);
+
+amacout:
+	kfree(obj);
+	return ret;
+}
+
 static int set_ethernet_addr(struct r8152 *tp)
 {
 	struct net_device *dev = tp->netdev;
@@ -1044,8 +1109,15 @@ static int set_ethernet_addr(struct r8152 *tp)
 
 	if (tp->version == RTL_VER_01)
 		ret = pla_ocp_read(tp, PLA_IDR, 8, sa.sa_data);
-	else
-		ret = pla_ocp_read(tp, PLA_BACKUP, 8, sa.sa_data);
+	else {
+		/* if this is not an RTL8153-AD, no eFuse mac pass thru set,
+		 * or system doesn't provide valid _SB.AMAC this will be
+		 * be expected to non-zero
+		 */
+		ret = vendor_mac_passthru_addr_read(tp, &sa);
+		if (ret < 0)
+			ret = pla_ocp_read(tp, PLA_BACKUP, 8, sa.sa_data);
+	}
 
 	if (ret < 0) {
 		netif_err(tp, probe, dev, "Get ether addr fail\n");
-- 
2.7.4
