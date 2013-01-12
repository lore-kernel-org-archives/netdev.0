From: Wei Shuai <cpuwolf@gmail.com>
Subject: [PATCH] CDC_NCM adding support IFF_NOARP for infineon modem platform
Date: Sat, 12 Jan 2013 19:34:39 +0800
Message-ID: <1357990479-5836-1-git-send-email-cpuwolf@gmail.com>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	Wei Shuai <cpuwolf@gmail.com>
To: gregkh@linuxfoundation.org, alexey.orishko@stericsson.com,
	bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:63101 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752775Ab3ALLfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 06:35:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Infineon(now Intel) HSPA Modem platform NCM cannot support ARP. so I introduce a flag CDC_NCM_DRIVER_DATA_NOARP which is defined in driver_info:data. so later on, if more such buggy devices are found, they could use same flag to handle. 

Signed-off-by: Wei Shuai <cpuwolf@gmail.com>
---
 drivers/net/usb/cdc_ncm.c |   29 +++++++++++++++++++++++++++++
 1 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 71b6e92..6093e07 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -55,6 +55,9 @@
 
 #define	DRIVER_VERSION				"14-Mar-2012"
 
+/* Flags for driver_info::data */
+#define CDC_NCM_DRIVER_DATA_NOARP  1
+
 static void cdc_ncm_txpath_bh(unsigned long param);
 static void cdc_ncm_tx_timeout_start(struct cdc_ncm_ctx *ctx);
 static enum hrtimer_restart cdc_ncm_tx_timer_cb(struct hrtimer *hr_timer);
@@ -573,6 +576,10 @@ static int cdc_ncm_bind(struct usbnet *dev, struct usb_interface *intf)
 		return -ENODEV;
 #endif
 
+	if (dev->driver_info->data & CDC_NCM_DRIVER_DATA_NOARP) {
+		/* some buggy device cannot do ARP*/
+		dev->net->flags |= IFF_NOARP;
+	}
 	/* NCM data altsetting is always 1 */
 	ret = cdc_ncm_bind_common(dev, intf, 1);
 
@@ -1155,6 +1162,21 @@ static const struct driver_info wwan_info = {
 	.tx_fixup = cdc_ncm_tx_fixup,
 };
 
+/* Same as wwan_info, but with IFF_NOARP  */
+static const struct driver_info wwan_noarp_info = {
+	.description = "Mobile Broadband Network Device (NO ARP)",
+	.flags = FLAG_POINTTOPOINT | FLAG_NO_SETINT | FLAG_MULTI_PACKET
+			| FLAG_WWAN,
+	.data = CDC_NCM_DRIVER_DATA_NOARP,
+	.bind = cdc_ncm_bind,
+	.unbind = cdc_ncm_unbind,
+	.check_connect = cdc_ncm_check_connect,
+	.manage_power = usbnet_manage_power,
+	.status = cdc_ncm_status,
+	.rx_fixup = cdc_ncm_rx_fixup,
+	.tx_fixup = cdc_ncm_tx_fixup,
+};
+
 static const struct usb_device_id cdc_devs[] = {
 	/* Ericsson MBM devices like F5521gw */
 	{ .match_flags = USB_DEVICE_ID_MATCH_INT_INFO
@@ -1194,6 +1216,13 @@ static const struct usb_device_id cdc_devs[] = {
 	  .driver_info = (unsigned long)&wwan_info,
 	},
 
+	/* Infineon(now Intel) HSPA Modem platform */
+	{ USB_DEVICE_AND_INTERFACE_INFO(0x1519, 0x0443,
+		USB_CLASS_COMM,
+		USB_CDC_SUBCLASS_NCM, USB_CDC_PROTO_NONE),
+	  .driver_info = (unsigned long)&wwan_noarp_info,
+	},
+
 	/* Generic CDC-NCM devices */
 	{ USB_INTERFACE_INFO(USB_CLASS_COMM,
 		USB_CDC_SUBCLASS_NCM, USB_CDC_PROTO_NONE),
-- 
1.7.6.5
