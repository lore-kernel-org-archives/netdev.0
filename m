From: Wei Shuai <cpuwolf@gmail.com>
Subject: [PATCH] CDC_NCM adding support IFF_NOARP for buggy device
Date: Thu, 10 Jan 2013 21:59:28 +0800
Message-ID: <1357826368-30543-1-git-send-email-cpuwolf@gmail.com>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	Wei Shuai <cpuwolf@gmail.com>
To: gregkh@linuxfoundation.org, alexey.orishko@stericsson.com,
	hans.petter.selasky@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:52142 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041Ab3AJOBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 09:01:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Wei Shuai <cpuwolf@gmail.com>
---
 drivers/net/usb/cdc_ncm.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 71b6e92..9903f79 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -545,6 +545,7 @@ EXPORT_SYMBOL_GPL(cdc_ncm_unbind);
 static int cdc_ncm_bind(struct usbnet *dev, struct usb_interface *intf)
 {
 	int ret;
+	struct usb_device *udev = interface_to_usbdev(intf);
 
 	/* The MBIM spec defines a NCM compatible default altsetting,
 	 * which we may have matched:
@@ -572,6 +573,10 @@ static int cdc_ncm_bind(struct usbnet *dev, struct usb_interface *intf)
 	    cdc_ncm_comm_intf_is_mbim(intf->cur_altsetting))
 		return -ENODEV;
 #endif
+	/*  this buggy device cannot do ARP */
+	if( (le16_to_cpu(udev->descriptor.idVendor) == 0xAAAA) ) {
+		dev->net->flags |= IFF_NOARP;
+	}
 
 	/* NCM data altsetting is always 1 */
 	ret = cdc_ncm_bind_common(dev, intf, 1);
@@ -1186,6 +1191,16 @@ static const struct usb_device_id cdc_devs[] = {
 	  .driver_info = (unsigned long) &wwan_info,
 	},
 
+	/* buggy device cannot send ARP */
+	{ .match_flags = USB_DEVICE_ID_MATCH_INT_INFO
+		| USB_DEVICE_ID_MATCH_VENDOR,
+	  .idVendor = 0xAAAA,
+	  .bInterfaceClass = USB_CLASS_COMM,
+	  .bInterfaceSubClass = USB_CDC_SUBCLASS_NCM,
+	  .bInterfaceProtocol = USB_CDC_PROTO_NONE,
+	  .driver_info = (unsigned long) &wwan_info,
+	},
+
 	/* Huawei NCM devices disguised as vendor specific */
 	{ USB_VENDOR_AND_INTERFACE_INFO(0x12d1, 0xff, 0x02, 0x16),
 	  .driver_info = (unsigned long)&wwan_info,
-- 
1.7.6.5
