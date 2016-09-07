From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 2/3] r8152: support ECM mode
Date: Wed, 7 Sep 2016 16:12:21 +0800
Message-ID: <1394712342-15778-217-Taiwan-albertk@realtek.com>
References: <1394712342-15778-215-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([211.75.126.72]:53697 "EHLO
        rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756849AbcIGIMy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 04:12:54 -0400
In-Reply-To: <1394712342-15778-215-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If CONFIG_USB_NET_CDCETHER is enabled, support ECM mode through cdc_ether
driver.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 255 ++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 247 insertions(+), 8 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 8468704..c4e8339 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -27,6 +27,7 @@
 #include <linux/usb/cdc.h>
 #include <linux/suspend.h>
 #include <linux/acpi.h>
+#include <linux/usb/usbnet.h>
 
 /* Information for net-next */
 #define NETNEXT_VERSION		"08"
@@ -4402,6 +4403,243 @@ static void rtl8152_disconnect(struct usb_interface *intf)
 	}
 }
 
+static int rtl_usbnet_probe(struct usb_interface *intf,
+			    const struct usb_device_id *id)
+{
+	switch (id->bInterfaceClass) {
+	case USB_CLASS_VENDOR_SPEC:
+		return rtl8152_probe(intf, id);
+#if IS_ENABLED(CONFIG_USB_NET_CDCETHER)
+	case USB_CLASS_COMM:
+		if (id->bInterfaceSubClass == USB_CDC_SUBCLASS_ETHERNET &&
+		    id->bInterfaceProtocol == USB_CDC_PROTO_NONE)
+			return usbnet_probe(intf, id);
+#endif
+	default:
+		return -ENODEV;
+	}
+}
+
+static void rtl_usbnet_disconnect(struct usb_interface *intf)
+{
+	struct usb_host_interface *alt = intf->cur_altsetting;
+
+	switch (alt->desc.bInterfaceClass) {
+	case USB_CLASS_VENDOR_SPEC:
+		rtl8152_disconnect(intf);
+		break;
+#if IS_ENABLED(CONFIG_USB_NET_CDCETHER)
+	case USB_CLASS_COMM:
+		if (alt->desc.bInterfaceSubClass == USB_CDC_SUBCLASS_ETHERNET &&
+		    alt->desc.bInterfaceProtocol == USB_CDC_PROTO_NONE) {
+			usbnet_disconnect(intf);
+			break;
+		}
+#endif
+	default:
+		break;
+	}
+}
+
+static int rtl_usbnet_suspend(struct usb_interface *intf, pm_message_t message)
+{
+	struct usb_host_interface *alt = intf->cur_altsetting;
+
+	switch (alt->desc.bInterfaceClass) {
+	case USB_CLASS_VENDOR_SPEC:
+		return rtl8152_suspend(intf, message);
+#if IS_ENABLED(CONFIG_USB_NET_CDCETHER)
+	case USB_CLASS_COMM:
+		if (alt->desc.bInterfaceSubClass == USB_CDC_SUBCLASS_ETHERNET &&
+		    alt->desc.bInterfaceProtocol == USB_CDC_PROTO_NONE)
+			return usbnet_suspend(intf, message);
+#endif
+	default:
+		return -ENODEV;
+	}
+}
+
+static int rtl_usbnet_resume(struct usb_interface *intf)
+{
+	struct usb_host_interface *alt = intf->cur_altsetting;
+
+	switch (alt->desc.bInterfaceClass) {
+	case USB_CLASS_VENDOR_SPEC:
+		return rtl8152_resume(intf);
+#if IS_ENABLED(CONFIG_USB_NET_CDCETHER)
+	case USB_CLASS_COMM:
+		if (alt->desc.bInterfaceSubClass == USB_CDC_SUBCLASS_ETHERNET &&
+		    alt->desc.bInterfaceProtocol == USB_CDC_PROTO_NONE)
+			return usbnet_resume(intf);
+#endif
+	default:
+		return -ENODEV;
+	}
+}
+
+static int rtl_usbnet_reset_resume(struct usb_interface *intf)
+{
+	struct usb_host_interface *alt = intf->cur_altsetting;
+
+	switch (alt->desc.bInterfaceClass) {
+	case USB_CLASS_VENDOR_SPEC:
+		return rtl8152_reset_resume(intf);
+#if IS_ENABLED(CONFIG_USB_NET_CDCETHER)
+	case USB_CLASS_COMM:
+		if (alt->desc.bInterfaceSubClass == USB_CDC_SUBCLASS_ETHERNET &&
+		    alt->desc.bInterfaceProtocol == USB_CDC_PROTO_NONE)
+			return usbnet_resume(intf);
+#endif
+	default:
+		return -ENODEV;
+	}
+}
+
+static int rtl_usbnet_pre_reset(struct usb_interface *intf)
+{
+	struct usb_host_interface *alt = intf->cur_altsetting;
+
+	if (!usb_get_intfdata(intf))
+		return 0;
+
+	switch (alt->desc.bInterfaceClass) {
+	case USB_CLASS_VENDOR_SPEC:
+		return rtl8152_pre_reset(intf);
+	default:
+		return 1;
+	}
+}
+
+static int rtl_usbnet_post_reset(struct usb_interface *intf)
+{
+	struct usb_host_interface *alt = intf->cur_altsetting;
+
+	if (!usb_get_intfdata(intf))
+		return 0;
+
+	switch (alt->desc.bInterfaceClass) {
+	case USB_CLASS_VENDOR_SPEC:
+		return rtl8152_post_reset(intf);
+	default:
+		return 1;
+	}
+}
+
+#if IS_ENABLED(CONFIG_USB_NET_CDCETHER)
+
+static int r815x_mdio_read(struct net_device *netdev, int phy_id, int reg)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	__le32 tmp;
+	u16 index;
+	u8 shift;
+	int err;
+
+	if (phy_id != R8152_PHY_ID)
+		return -EINVAL;
+
+	index = 0xB400 + reg * 2;
+	shift = index & 2;
+	index &= ~3;
+
+	err = usbnet_read_cmd(dev, RTL8152_REQ_GET_REGS, RTL8152_REQT_READ,
+			      index, MCU_TYPE_PLA, &tmp, sizeof(tmp));
+
+	if (err > 0) {
+		err = __le32_to_cpu(tmp);
+		err >>= (shift * 8);
+		err &= 0xffff;
+	}
+
+	return err;
+}
+
+static
+void r815x_mdio_write(struct net_device *netdev, int phy_id, int reg, int val)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	__le32 tmp;
+	u16 index;
+	u16 byen = BYTE_EN_WORD;
+	u8 shift;
+
+	if (phy_id != R8152_PHY_ID)
+		return;
+
+	val &= 0xffff;
+	index = 0xB400 + reg * 2;
+	shift = index & 2;
+	index &= ~3;
+
+	if (shift) {
+		byen <<= shift;
+		val <<= (shift * 8);
+	}
+
+	tmp = __cpu_to_le32(val);
+
+	usbnet_write_cmd(dev, RTL8152_REQ_GET_REGS, RTL8152_REQT_WRITE, index,
+			 MCU_TYPE_PLA | byen, &tmp, sizeof(tmp));
+}
+
+static int rtl_ecm_bind(struct usbnet *dev, struct usb_interface *intf)
+{
+	__le32 tmp;
+	int err;
+
+	err = usbnet_cdc_bind(dev, intf);
+	if (err < 0)
+		goto err1;
+
+	tmp = __cpu_to_le32(0xa000);
+	err = usbnet_write_cmd(dev, RTL8152_REQ_GET_REGS, RTL8152_REQT_WRITE,
+			       PLA_OCP_GPHY_BASE, MCU_TYPE_PLA | BYTE_EN_WORD,
+			       &tmp, sizeof(tmp));
+	if (err < 0)
+		goto err2;
+
+	dev->mii.dev = dev->net;
+	dev->mii.mdio_read = r815x_mdio_read;
+	dev->mii.mdio_write = r815x_mdio_write;
+	dev->mii.phy_id_mask = 0x3f;
+	dev->mii.reg_num_mask = 0x1f;
+	dev->mii.phy_id = R8152_PHY_ID;
+
+	switch (rtl_get_version(intf)) {
+	case RTL_VER_01:
+	case RTL_VER_02:
+		dev->mii.supports_gmii = 0;
+		break;
+	default:
+		dev->mii.supports_gmii = 1;
+		break;
+	}
+
+	return 0;
+
+err2:
+	usbnet_cdc_unbind(dev, intf);
+err1:
+	return err;
+}
+
+static const struct driver_info rtl_ecm_info = {
+	.description =	"RTL8152/RTL8153 ECM Device",
+	.flags =	FLAG_ETHER | FLAG_POINTTOPOINT,
+	.bind =		rtl_ecm_bind,
+	.unbind =	usbnet_cdc_unbind,
+	.status =	usbnet_cdc_status,
+	.manage_power =	usbnet_manage_power,
+};
+
+#define RTL_ECM_INFO	((unsigned long)&rtl_ecm_info)
+
+#else
+
+#define RTL_ECM_INFO	0
+
+#endif
+
 #define REALTEK_USB_DEVICE(vend, prod)	\
 	.match_flags = USB_DEVICE_ID_MATCH_DEVICE | \
 		       USB_DEVICE_ID_MATCH_INT_CLASS, \
@@ -4416,7 +4654,8 @@ static void rtl8152_disconnect(struct usb_interface *intf)
 	.idProduct = (prod), \
 	.bInterfaceClass = USB_CLASS_COMM, \
 	.bInterfaceSubClass = USB_CDC_SUBCLASS_ETHERNET, \
-	.bInterfaceProtocol = USB_CDC_PROTO_NONE
+	.bInterfaceProtocol = USB_CDC_PROTO_NONE, \
+	.driver_info = RTL_ECM_INFO,
 
 /* table of devices that work with this driver */
 static struct usb_device_id rtl8152_table[] = {
@@ -4434,13 +4673,13 @@ MODULE_DEVICE_TABLE(usb, rtl8152_table);
 static struct usb_driver rtl8152_driver = {
 	.name =		MODULENAME,
 	.id_table =	rtl8152_table,
-	.probe =	rtl8152_probe,
-	.disconnect =	rtl8152_disconnect,
-	.suspend =	rtl8152_suspend,
-	.resume =	rtl8152_resume,
-	.reset_resume =	rtl8152_reset_resume,
-	.pre_reset =	rtl8152_pre_reset,
-	.post_reset =	rtl8152_post_reset,
+	.probe =	rtl_usbnet_probe,
+	.disconnect =	rtl_usbnet_disconnect,
+	.suspend =	rtl_usbnet_suspend,
+	.resume =	rtl_usbnet_resume,
+	.reset_resume =	rtl_usbnet_reset_resume,
+	.pre_reset =	rtl_usbnet_pre_reset,
+	.post_reset =	rtl_usbnet_post_reset,
 	.supports_autosuspend = 1,
 	.disable_hub_initiated_lpm = 1,
 };
-- 
2.7.4
