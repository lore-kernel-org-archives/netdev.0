From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next] r8152: check hw version first
Date: Fri, 17 Mar 2017 11:20:13 +0800
Message-ID: <1394712342-15778-255-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Check hw version first in probe(). Do nothing if the driver doesn't
support the chip.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 102 ++++++++++++++++++++++++++++++------------------
 1 file changed, 63 insertions(+), 39 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 4b85e95..3262a32 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -4236,44 +4236,6 @@ static const struct net_device_ops rtl8152_netdev_ops = {
 	.ndo_features_check	= rtl8152_features_check,
 };
 
-static void r8152b_get_version(struct r8152 *tp)
-{
-	u32	ocp_data;
-	u16	version;
-
-	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_TCR1);
-	version = (u16)(ocp_data & VERSION_MASK);
-
-	switch (version) {
-	case 0x4c00:
-		tp->version = RTL_VER_01;
-		break;
-	case 0x4c10:
-		tp->version = RTL_VER_02;
-		break;
-	case 0x5c00:
-		tp->version = RTL_VER_03;
-		tp->mii.supports_gmii = 1;
-		break;
-	case 0x5c10:
-		tp->version = RTL_VER_04;
-		tp->mii.supports_gmii = 1;
-		break;
-	case 0x5c20:
-		tp->version = RTL_VER_05;
-		tp->mii.supports_gmii = 1;
-		break;
-	case 0x5c30:
-		tp->version = RTL_VER_06;
-		tp->mii.supports_gmii = 1;
-		break;
-	default:
-		netif_info(tp, probe, tp->netdev,
-			   "Unknown version 0x%04x\n", version);
-		break;
-	}
-}
-
 static void rtl8152_unload(struct r8152 *tp)
 {
 	if (test_bit(RTL8152_UNPLUG, &tp->flags))
@@ -4338,14 +4300,66 @@ static int rtl_ops_init(struct r8152 *tp)
 	return ret;
 }
 
+static u8 rtl_get_version(struct usb_interface *intf)
+{
+	struct usb_device *udev = interface_to_usbdev(intf);
+	u32 ocp_data = 0;
+	__le32 *tmp;
+	u8 version;
+	int ret;
+
+	tmp = kmalloc(sizeof(*tmp), GFP_KERNEL);
+	if (!tmp)
+		return 0;
+
+	ret = usb_control_msg(udev, usb_rcvctrlpipe(udev, 0),
+			      RTL8152_REQ_GET_REGS, RTL8152_REQT_READ,
+			      PLA_TCR0, MCU_TYPE_PLA, tmp, sizeof(*tmp), 500);
+	if (ret > 0)
+		ocp_data = (__le32_to_cpu(*tmp) >> 16) & VERSION_MASK;
+
+	kfree(tmp);
+
+	switch (ocp_data) {
+	case 0x4c00:
+		version = RTL_VER_01;
+		break;
+	case 0x4c10:
+		version = RTL_VER_02;
+		break;
+	case 0x5c00:
+		version = RTL_VER_03;
+		break;
+	case 0x5c10:
+		version = RTL_VER_04;
+		break;
+	case 0x5c20:
+		version = RTL_VER_05;
+		break;
+	case 0x5c30:
+		version = RTL_VER_06;
+		break;
+	default:
+		version = RTL_VER_UNKNOWN;
+		dev_info(&intf->dev, "Unknown version 0x%04x\n", ocp_data);
+		break;
+	}
+
+	return version;
+}
+
 static int rtl8152_probe(struct usb_interface *intf,
 			 const struct usb_device_id *id)
 {
 	struct usb_device *udev = interface_to_usbdev(intf);
+	u8 version = rtl_get_version(intf);
 	struct r8152 *tp;
 	struct net_device *netdev;
 	int ret;
 
+	if (version == RTL_VER_UNKNOWN)
+		return -ENODEV;
+
 	if (udev->actconfig->desc.bConfigurationValue != 1) {
 		usb_driver_set_configuration(udev, 1);
 		return -ENODEV;
@@ -4365,8 +4379,18 @@ static int rtl8152_probe(struct usb_interface *intf,
 	tp->udev = udev;
 	tp->netdev = netdev;
 	tp->intf = intf;
+	tp->version = version;
+
+	switch (version) {
+	case RTL_VER_01:
+	case RTL_VER_02:
+		tp->mii.supports_gmii = 0;
+		break;
+	default:
+		tp->mii.supports_gmii = 1;
+		break;
+	}
 
-	r8152b_get_version(tp);
 	ret = rtl_ops_init(tp);
 	if (ret)
 		goto out;
-- 
2.7.4
