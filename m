From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 3/3] r8152: add supporting the vendor mode only
Date: Thu, 9 Jan 2014 14:50:32 +0800
Message-ID: <1389250232-8663-4-git-send-email-hayeswang@realtek.com>
References: <1389250232-8663-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <oliver@neukum.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:36700 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754531AbaAIGvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 01:51:04 -0500
In-Reply-To: <1389250232-8663-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the limitation that the ecm and r8152 drivers couldn't coexist.
Besides, add the feature to support the vendor mode only. This let
someone who doesn't want to use ecm driver easy to use the vendor
driver without creating the udev rule.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/Kconfig     |  9 +++++++++
 drivers/net/usb/cdc_ether.c |  2 +-
 drivers/net/usb/r8152.c     | 18 ++++++++++++++----
 drivers/net/usb/r815x.c     |  4 ++--
 4 files changed, 26 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 6b638a0..d36640e 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -102,6 +102,15 @@ config USB_RTL8152
 	  To compile this driver as a module, choose M here: the
 	  module will be called r8152.
 
+config USB_RTL8152_VENDOR_MODE_ONLY
+	boolean "Force using the vendor mode"
+	depends on USB_RTL8152
+	default n
+	help
+	  This would add the devices in the blacklist of the ECM driver.
+	  That is, the ECM mode would be disabled, and only the vendor
+	  mode could be used.
+
 config USB_USBNET
 	tristate "Multi-purpose USB Networking Framework"
 	select MII
diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 640406a..5c04f8b 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -653,7 +653,7 @@ static const struct usb_device_id	products[] = {
 	.driver_info = 0,
 },
 
-#if defined(CONFIG_USB_RTL8152) || defined(CONFIG_USB_RTL8152_MODULE)
+#if defined(CONFIG_USB_RTL8152_VENDOR_MODE_ONLY)
 /* Samsung USB Ethernet Adapters */
 {
 	USB_DEVICE_AND_INTERFACE_INFO(SAMSUNG_VENDOR_ID, 0xa101, USB_CLASS_COMM,
diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index eab078b..e59e99a 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -450,6 +450,13 @@ enum rtl8152_flags {
 #define MCU_TYPE_PLA			0x0100
 #define MCU_TYPE_USB			0x0000
 
+#if defined(CONFIG_USB_RTL8152_VENDOR_MODE_ONLY)
+	#define REALTEK_USB_DEVICE(vend, prod)	USB_DEVICE(vend, prod)
+#else
+	#define REALTEK_USB_DEVICE(vend, prod)	\
+	USB_DEVICE_INTERFACE_CLASS(vend, prod, USB_CLASS_VENDOR_SPEC)
+#endif
+
 struct rx_desc {
 	__le32 opts1;
 #define RX_LEN_MASK			0x7fff
@@ -2733,13 +2740,16 @@ static int rtl_ops_init(struct r8152 *tp, const struct usb_device_id *id)
 static int rtl8152_probe(struct usb_interface *intf,
 			 const struct usb_device_id *id)
 {
+	struct usb_host_interface *alt = intf->cur_altsetting;
 	struct usb_device *udev = interface_to_usbdev(intf);
 	struct r8152 *tp;
 	struct net_device *netdev;
 	int ret;
 
-	if (udev->actconfig->desc.bConfigurationValue != 1) {
+	if (alt->desc.bInterfaceClass != USB_CLASS_VENDOR_SPEC) {
+#if defined(CONFIG_USB_RTL8152_VENDOR_MODE_ONLY)
 		usb_driver_set_configuration(udev, 1);
+#endif
 		return -ENODEV;
 	}
 
@@ -2823,9 +2833,9 @@ static void rtl8152_disconnect(struct usb_interface *intf)
 
 /* table of devices that work with this driver */
 static struct usb_device_id rtl8152_table[] = {
-	{USB_DEVICE(VENDOR_ID_REALTEK, PRODUCT_ID_RTL8152)},
-	{USB_DEVICE(VENDOR_ID_REALTEK, PRODUCT_ID_RTL8153)},
-	{USB_DEVICE(VENDOR_ID_SAMSUNG, PRODUCT_ID_SAMSUNG)},
+	{REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, PRODUCT_ID_RTL8152)},
+	{REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, PRODUCT_ID_RTL8153)},
+	{REALTEK_USB_DEVICE(VENDOR_ID_SAMSUNG, PRODUCT_ID_SAMSUNG)},
 	{}
 };
 
diff --git a/drivers/net/usb/r815x.c b/drivers/net/usb/r815x.c
index 5fd2ca6..9934447 100644
--- a/drivers/net/usb/r815x.c
+++ b/drivers/net/usb/r815x.c
@@ -216,7 +216,7 @@ static const struct usb_device_id products[] = {
 {
 	USB_DEVICE_AND_INTERFACE_INFO(REALTEK_VENDOR_ID, 0x8152, USB_CLASS_COMM,
 			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
-#if defined(CONFIG_USB_RTL8152) || defined(CONFIG_USB_RTL8152_MODULE)
+#if defined(CONFIG_USB_RTL8152_VENDOR_MODE_ONLY)
 	.driver_info = 0,
 #else
 	.driver_info = (unsigned long) &r8152_info,
@@ -226,7 +226,7 @@ static const struct usb_device_id products[] = {
 {
 	USB_DEVICE_AND_INTERFACE_INFO(REALTEK_VENDOR_ID, 0x8153, USB_CLASS_COMM,
 			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
-#if defined(CONFIG_USB_RTL8152) || defined(CONFIG_USB_RTL8152_MODULE)
+#if defined(CONFIG_USB_RTL8152_VENDOR_MODE_ONLY)
 	.driver_info = 0,
 #else
 	.driver_info = (unsigned long) &r8153_info,
-- 
1.8.4.2
