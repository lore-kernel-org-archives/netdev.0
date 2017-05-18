From: Oliver Neukum <oneukum@suse.com>
Subject: [PATCH] cdc-ether: divorce initialisation with a filter reset and a generic method
Date: Thu, 18 May 2017 10:23:28 +0200
Message-ID: <20170518082328.10094-1-oneukum@suse.com>
Cc: Oliver Neukum <oneukum@suse.com>
To: davem@davemloft.net, netdev@vger.kernel.org, bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:60287 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754275AbdERIZL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 May 2017 04:25:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some devices need their multicast filter reset but others are crashed by that.
So the methods need to be separated.

Signed-off-by: Oliver Neukum <oneukum@suse.com>
Reported-by: "Ridgway, Keith" <kridgway@harris.com>
---
 drivers/net/usb/cdc_ether.c | 34 +++++++++++++++++++++++++---------
 1 file changed, 25 insertions(+), 9 deletions(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index f3ae88fdf332..70d823043803 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -310,6 +310,26 @@ int usbnet_generic_cdc_bind(struct usbnet *dev, struct usb_interface *intf)
 		return -ENODEV;
 	}
 
+	return 0;
+
+bad_desc:
+	dev_info(&dev->udev->dev, "bad CDC descriptors\n");
+	return -ENODEV;
+}
+EXPORT_SYMBOL_GPL(usbnet_generic_cdc_bind);
+
+
+/* like usbnet_generic_cdc_bind() but handles filter initialization
+ * correctly
+ */
+int usbnet_ether_cdc_bind(struct usbnet *dev, struct usb_interface *intf)
+{
+	int rv;
+
+	rv = usbnet_generic_cdc_bind(dev, intf);
+	if (rv < 0)
+		goto bail_out;
+
 	/* Some devices don't initialise properly. In particular
 	 * the packet filter is not reset. There are devices that
 	 * don't do reset all the way. So the packet filter should
@@ -317,13 +337,10 @@ int usbnet_generic_cdc_bind(struct usbnet *dev, struct usb_interface *intf)
 	 */
 	usbnet_cdc_update_filter(dev);
 
-	return 0;
-
-bad_desc:
-	dev_info(&dev->udev->dev, "bad CDC descriptors\n");
-	return -ENODEV;
+bail_out:
+	return rv;
 }
-EXPORT_SYMBOL_GPL(usbnet_generic_cdc_bind);
+EXPORT_SYMBOL_GPL(usbnet_ether_cdc_bind);
 
 void usbnet_cdc_unbind(struct usbnet *dev, struct usb_interface *intf)
 {
@@ -417,7 +434,7 @@ int usbnet_cdc_bind(struct usbnet *dev, struct usb_interface *intf)
 	BUILD_BUG_ON((sizeof(((struct usbnet *)0)->data)
 			< sizeof(struct cdc_state)));
 
-	status = usbnet_generic_cdc_bind(dev, intf);
+	status = usbnet_ether_cdc_bind(dev, intf);
 	if (status < 0)
 		return status;
 
@@ -472,7 +489,6 @@ static void usbnet_cdc_zte_status(struct usbnet *dev, struct urb *urb)
 
 	if (urb->actual_length < sizeof(*event))
 		return;
-
 	event = urb->transfer_buffer;
 
 	if (event->bNotificationType != USB_CDC_NOTIFY_NETWORK_CONNECTION) {
@@ -493,7 +509,7 @@ static void usbnet_cdc_zte_status(struct usbnet *dev, struct urb *urb)
 static const struct driver_info	cdc_info = {
 	.description =	"CDC Ethernet Device",
 	.flags =	FLAG_ETHER | FLAG_POINTTOPOINT,
-	.bind =		usbnet_cdc_bind,
+	.bind =		usbnet_ether_cdc_bind,
 	.unbind =	usbnet_cdc_unbind,
 	.status =	usbnet_cdc_status,
 	.set_rx_mode =	usbnet_cdc_update_filter,
-- 
2.12.0
