From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 1/4] usbnet: Use wwan%d interface name for mobile broadband devices
Date: Fri,  2 Oct 2009 17:15:25 +0200
Message-ID: <ff8a6da2784c27455e9666469ec95d84a1e00fd4.1254495724.git.marcel@holtmann.org>
References: <cover.1254495724.git.marcel@holtmann.org>
Cc: David Miller <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Greg KH <greg@kroah.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:33419 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754359AbZJBPPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 11:15:55 -0400
In-Reply-To: <cover.1254495724.git.marcel@holtmann.org>
In-Reply-To: <cover.1254495724.git.marcel@holtmann.org>
References: <cover.1254495724.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for usbnet based devices like CDC-Ether to indicate that they
are actually mobile broadband devices. In that case use wwan%d as default
interface name.

Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/net/usb/cdc_ether.c |   20 ++++++++++++++------
 drivers/net/usb/usbnet.c    |    3 +++
 include/linux/usb/usbnet.h  |    1 +
 3 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 4a6aff5..71e65fc 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -420,6 +420,14 @@ static const struct driver_info	cdc_info = {
 	.status =	cdc_status,
 };
 
+static const struct driver_info mbm_info = {
+	.description =	"Mobile Broadband Network Device",
+	.flags =	FLAG_WWAN,
+	.bind = 	cdc_bind,
+	.unbind =	usbnet_cdc_unbind,
+	.status =	cdc_status,
+};
+
 /*-------------------------------------------------------------------------*/
 
 
@@ -532,32 +540,32 @@ static const struct usb_device_id	products [] = {
 	/* Ericsson F3507g */
 	USB_DEVICE_AND_INTERFACE_INFO(0x0bdb, 0x1900, USB_CLASS_COMM,
 			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
-	.driver_info = (unsigned long) &cdc_info,
+	.driver_info = (unsigned long) &mbm_info,
 }, {
 	/* Ericsson F3507g ver. 2 */
 	USB_DEVICE_AND_INTERFACE_INFO(0x0bdb, 0x1902, USB_CLASS_COMM,
 			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
-	.driver_info = (unsigned long) &cdc_info,
+	.driver_info = (unsigned long) &mbm_info,
 }, {
 	/* Ericsson F3607gw */
 	USB_DEVICE_AND_INTERFACE_INFO(0x0bdb, 0x1904, USB_CLASS_COMM,
 			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
-	.driver_info = (unsigned long) &cdc_info,
+	.driver_info = (unsigned long) &mbm_info,
 }, {
 	/* Ericsson F3307 */
 	USB_DEVICE_AND_INTERFACE_INFO(0x0bdb, 0x1906, USB_CLASS_COMM,
 			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
-	.driver_info = (unsigned long) &cdc_info,
+	.driver_info = (unsigned long) &mbm_info,
 }, {
 	/* Toshiba F3507g */
 	USB_DEVICE_AND_INTERFACE_INFO(0x0930, 0x130b, USB_CLASS_COMM,
 			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
-	.driver_info = (unsigned long) &cdc_info,
+	.driver_info = (unsigned long) &mbm_info,
 }, {
 	/* Dell F3507g */
 	USB_DEVICE_AND_INTERFACE_INFO(0x413c, 0x8147, USB_CLASS_COMM,
 			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
-	.driver_info = (unsigned long) &cdc_info,
+	.driver_info = (unsigned long) &mbm_info,
 },
 	{ },		// END
 };
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index ca5ca5a..8124cf1 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1295,6 +1295,9 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 		/* WLAN devices should always be named "wlan%d" */
 		if ((dev->driver_info->flags & FLAG_WLAN) != 0)
 			strcpy(net->name, "wlan%d");
+		/* WWAN devices should always be named "wwan%d" */
+		if ((dev->driver_info->flags & FLAG_WWAN) != 0)
+			strcpy(net->name, "wwan%d");
 
 		/* maybe the remote can't receive an Ethernet MTU */
 		if (net->mtu > (dev->hard_mtu - net->hard_header_len))
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index f814730..86c31b7 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -90,6 +90,7 @@ struct driver_info {
 #define FLAG_WLAN	0x0080		/* use "wlan%d" names */
 #define FLAG_AVOID_UNLINK_URBS 0x0100	/* don't unlink urbs at usbnet_stop() */
 #define FLAG_SEND_ZLP	0x0200		/* hw requires ZLPs are sent */
+#define FLAG_WWAN	0x0400		/* use "wwan%d" names */
 
 
 	/* init device ... can sleep, or cause probe() failure */
-- 
1.6.2.5

