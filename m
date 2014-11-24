From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 2/2] r8152: use ECM mode for unsupported chips
Date: Mon, 24 Nov 2014 11:09:49 +0800
Message-ID: <1394712342-15778-103-Taiwan-albertk@realtek.com>
References: <1394712342-15778-101-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-101-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use usbnet_cdc_bind to initialize the chips which the driver doesn't
support yet, if the cdc_ether is set.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 92 ++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 87 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 2d1c77e..9989e5b 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -25,9 +25,10 @@
 #include <uapi/linux/mdio.h>
 #include <linux/mdio.h>
 #include <linux/usb/cdc.h>
+#include <linux/usb/usbnet.h>
 
 /* Version Information */
-#define DRIVER_VERSION "v1.07.0 (2014/10/09)"
+#define DRIVER_VERSION "v1.08.0 (2014/11/24)"
 #define DRIVER_AUTHOR "Realtek linux nic maintainers <nic_swsd@realtek.com>"
 #define DRIVER_DESC "Realtek RTL8152/RTL8153 Based USB Ethernet Adapters"
 #define MODULENAME "r8152"
@@ -3219,12 +3220,24 @@ static void r8153_init(struct r8152 *tp)
 	rtl_tally_reset(tp);
 }
 
+static bool rtl_vendor_mode(struct usb_interface *intf)
+{
+	struct usb_host_interface *alt = intf->cur_altsetting;
+
+	return alt->desc.bInterfaceClass == USB_CLASS_VENDOR_SPEC;
+}
+
 static int rtl8152_suspend(struct usb_interface *intf, pm_message_t message)
 {
 	struct r8152 *tp = usb_get_intfdata(intf);
 	struct net_device *netdev = tp->netdev;
 	int ret = 0;
 
+#if defined(CONFIG_USB_NET_CDCETHER) || defined(CONFIG_USB_NET_CDCETHER_MODULE)
+	if (!rtl_vendor_mode(intf))
+		return usbnet_suspend(intf, message);
+#endif /* CONFIG_USB_NET_CDCETHER */
+
 	mutex_lock(&tp->control);
 
 	if (PMSG_IS_AUTO(message)) {
@@ -3261,6 +3274,11 @@ static int rtl8152_resume(struct usb_interface *intf)
 {
 	struct r8152 *tp = usb_get_intfdata(intf);
 
+#if defined(CONFIG_USB_NET_CDCETHER) || defined(CONFIG_USB_NET_CDCETHER_MODULE)
+	if (!rtl_vendor_mode(intf))
+		return usbnet_resume(intf);
+#endif /* CONFIG_USB_NET_CDCETHER */
+
 	mutex_lock(&tp->control);
 
 	if (!test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
@@ -3742,6 +3760,17 @@ static void r8152b_get_version(struct r8152 *tp)
 	}
 }
 
+static bool rtl_supported(struct usb_device *udev)
+{
+	struct r8152 fake;
+
+	memset(&fake, 0, sizeof(fake));
+	fake.udev = udev;
+	r8152b_get_version(&fake);
+
+	return fake.version != RTL_VER_UNKNOWN;
+}
+
 static void rtl8152_unload(struct r8152 *tp)
 {
 	if (test_bit(RTL8152_UNPLUG, &tp->flags))
@@ -3803,13 +3832,28 @@ static int rtl8152_probe(struct usb_interface *intf,
 			 const struct usb_device_id *id)
 {
 	struct usb_device *udev = interface_to_usbdev(intf);
+	bool support = rtl_supported(udev);
 	struct r8152 *tp;
 	struct net_device *netdev;
-	int ret;
+	int ret = -ENODEV;
 
-	if (udev->actconfig->desc.bConfigurationValue != 1) {
-		usb_driver_set_configuration(udev, 1);
-		return -ENODEV;
+	if (!rtl_vendor_mode(intf)) {
+		if (support)
+			usb_driver_set_configuration(udev, 1);
+#if defined(CONFIG_USB_NET_CDCETHER) || defined(CONFIG_USB_NET_CDCETHER_MODULE)
+		else
+			ret = usbnet_probe(intf, id);
+#endif /* CONFIG_USB_NET_CDCETHER */
+
+		return ret;
+	} else if (!support) {
+		/* The driver doesn't support this chip yet.
+		 * Try to use cdc_ether.
+		 */
+#if defined(CONFIG_USB_NET_CDCETHER) || defined(CONFIG_USB_NET_CDCETHER_MODULE)
+		usb_driver_set_configuration(udev, 2);
+#endif /* CONFIG_USB_NET_CDCETHER */
+		return ret;
 	}
 
 	usb_reset_device(udev);
@@ -3899,6 +3943,13 @@ static void rtl8152_disconnect(struct usb_interface *intf)
 {
 	struct r8152 *tp = usb_get_intfdata(intf);
 
+#if defined(CONFIG_USB_NET_CDCETHER) || defined(CONFIG_USB_NET_CDCETHER_MODULE)
+	if (!rtl_vendor_mode(intf)) {
+		usbnet_disconnect(intf);
+		return;
+	}
+#endif /* CONFIG_USB_NET_CDCETHER */
+
 	usb_set_intfdata(intf, NULL);
 	if (tp) {
 		struct usb_device *udev = tp->udev;
@@ -3913,6 +3964,35 @@ static void rtl8152_disconnect(struct usb_interface *intf)
 	}
 }
 
+#if defined(CONFIG_USB_NET_CDCETHER) || defined(CONFIG_USB_NET_CDCETHER_MODULE)
+static const struct driver_info	cdc_info = {
+	.description =	"r815x CDC Ethernet Device",
+	.flags =	FLAG_ETHER | FLAG_POINTTOPOINT,
+	.bind =		usbnet_cdc_bind,
+	.unbind =	usbnet_cdc_unbind,
+	.status =	usbnet_cdc_status,
+	.manage_power =	usbnet_manage_power,
+};
+
+#define REALTEK_USB_DEVICE(vend, prod)	\
+	.match_flags = USB_DEVICE_ID_MATCH_DEVICE | \
+		       USB_DEVICE_ID_MATCH_INT_CLASS, \
+	.idVendor = (vend), \
+	.idProduct = (prod), \
+	.bInterfaceClass = USB_CLASS_VENDOR_SPEC \
+}, \
+{ \
+	.match_flags = USB_DEVICE_ID_MATCH_INT_INFO | \
+		       USB_DEVICE_ID_MATCH_DEVICE, \
+	.idVendor = (vend), \
+	.idProduct = (prod), \
+	.bInterfaceClass = USB_CLASS_COMM, \
+	.bInterfaceSubClass = USB_CDC_SUBCLASS_ETHERNET, \
+	.bInterfaceProtocol = USB_CDC_PROTO_NONE, \
+	.driver_info = (unsigned long)&cdc_info,
+
+#else
+
 #define REALTEK_USB_DEVICE(vend, prod)	\
 	.match_flags = USB_DEVICE_ID_MATCH_DEVICE | \
 		       USB_DEVICE_ID_MATCH_INT_CLASS, \
@@ -3929,6 +4009,8 @@ static void rtl8152_disconnect(struct usb_interface *intf)
 	.bInterfaceSubClass = USB_CDC_SUBCLASS_ETHERNET, \
 	.bInterfaceProtocol = USB_CDC_PROTO_NONE
 
+#endif /* CONFIG_USB_NET_CDCETHER */
+
 /* table of devices that work with this driver */
 static struct usb_device_id rtl8152_table[] = {
 	{REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8152)},
-- 
1.9.3
