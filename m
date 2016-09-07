From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 3/3] r8152: add CONFIG_RTL8152_CONFIG_VALUE
Date: Wed, 7 Sep 2016 16:12:22 +0800
Message-ID: <1394712342-15778-218-Taiwan-albertk@realtek.com>
References: <1394712342-15778-215-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-215-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

According to CONFIG_RTL8152_CONFIG_VALUE, to determine which mode the
driver supports. The value 0 means to support both vendor mode and
ECM mode. The value 1 means to support vendor mode only. The value 2
means to support ECM mode only.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/Kconfig | 13 +++++++++++++
 drivers/net/usb/r8152.c | 30 ++++++++++++++++++++++++------
 2 files changed, 37 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index cdde590..3d2fd09 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -106,6 +106,19 @@ config USB_RTL8152
 	  To compile this driver as a module, choose M here: the
 	  module will be called r8152.
 
+config RTL8152_CONFIG_VALUE
+	depends on USB_RTL8152
+	int "RTL8152/RTL8153 USB Configuration Value"
+	default 1
+	help
+		This is used to select the USB configuration value of RTL8152/RTL8153.
+		0: support all configuration values. It means the user could
+		   change the configuration value. However, it may have problem
+		   if you change the configuration value frequently. Don't set
+		   this value unless you really know what you want.
+		1: use vendor mode only. (recommended)
+		2: use ECM mode only.
+
 config USB_LAN78XX
 	tristate "Microchip LAN78XX Based USB Ethernet Adapters"
 	select MII
diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index c4e8339..480af78 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -30,7 +30,7 @@
 #include <linux/usb/usbnet.h>
 
 /* Information for net-next */
-#define NETNEXT_VERSION		"08"
+#define NETNEXT_VERSION		"09"
 
 /* Information for net */
 #define NET_VERSION		"5"
@@ -4267,11 +4267,6 @@ static int rtl8152_probe(struct usb_interface *intf,
 	if (version == RTL_VER_UNKNOWN)
 		return -ENODEV;
 
-	if (udev->actconfig->desc.bConfigurationValue != 1) {
-		usb_driver_set_configuration(udev, 1);
-		return -ENODEV;
-	}
-
 	usb_reset_device(udev);
 	netdev = alloc_etherdev(sizeof(struct r8152));
 	if (!netdev) {
@@ -4403,9 +4398,32 @@ static void rtl8152_disconnect(struct usb_interface *intf)
 	}
 }
 
+static bool rtl_change_config(struct usb_interface *intf)
+{
+	struct usb_device *udev = interface_to_usbdev(intf);
+	u8 actconfig = udev->actconfig->desc.bConfigurationValue;
+
+	if (CONFIG_RTL8152_CONFIG_VALUE <= 0 ||
+	    udev->descriptor.bNumConfigurations < CONFIG_RTL8152_CONFIG_VALUE ||
+	    actconfig == CONFIG_RTL8152_CONFIG_VALUE)
+		return false;
+
+	if (CONFIG_RTL8152_CONFIG_VALUE == 1 && !rtl_get_version(intf))
+		return false;
+
+	return true;
+}
+
 static int rtl_usbnet_probe(struct usb_interface *intf,
 			    const struct usb_device_id *id)
 {
+	if (rtl_change_config(intf)) {
+		struct usb_device *udev = interface_to_usbdev(intf);
+
+		usb_driver_set_configuration(udev, CONFIG_RTL8152_CONFIG_VALUE);
+		return -ENODEV;
+	}
+
 	switch (id->bInterfaceClass) {
 	case USB_CLASS_VENDOR_SPEC:
 		return rtl8152_probe(intf, id);
-- 
2.7.4
