From: Giuseppe Scrivano <giuseppe@southpole.se>
Subject: Re: [PATCH ] cdc_ncm: fixes for big-endian architecture / MIPS
Date: Wed, 03 Aug 2011 15:21:45 +0200
Message-ID: <87hb5yock6.fsf@gnu.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, oliver@neukum.org,
	linux-usb@vger.kernel.org, gregkh@suse.de
To: alexey.orishko@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([140.186.70.10]:45764 "EHLO
	fencepost.gnu.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755668Ab1HCNV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 09:21:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have reworked the original patch I have submitted to Alexey.

Regards,
Giuseppe



>From 8bd65735b4f0db5b6213f59a443c21d0d55dba8e Mon Sep 17 00:00:00 2001
From: Giuseppe Scrivano <giuseppe@southpole.se>
Date: Fri, 15 Jul 2011 15:34:14 +0200
Subject: [PATCH] cdc_ncm: fix endianess problem.

Signed-off-by: Giuseppe Scrivano <giuseppe@southpole.se>
---
 drivers/net/usb/cdc_ncm.c |   65 +++++++++++++++++++++++++--------------------
 1 files changed, 36 insertions(+), 29 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index f33ca6a..cd5d819 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -54,7 +54,7 @@
 #include <linux/usb/usbnet.h>
 #include <linux/usb/cdc.h>
 
-#define	DRIVER_VERSION				"01-June-2011"
+#define	DRIVER_VERSION				"03-Aug-2011"
 
 /* CDC NCM subclass 3.2.1 */
 #define USB_CDC_NCM_NDP16_LENGTH_MIN		0x10
@@ -136,6 +136,14 @@ struct cdc_ncm_ctx {
 	u16 connected;
 };
 
+struct cdc_ncm_request {
+	u8	bRequest;
+	u8	bmRequestType;
+	u16	wValue;
+	u16	wIndex;
+	u16	wLength;
+} __packed;
+
 static void cdc_ncm_tx_timeout(unsigned long arg);
 static const struct driver_info cdc_ncm_info;
 static struct usb_driver cdc_ncm_driver;
@@ -165,7 +173,7 @@ cdc_ncm_get_drvinfo(struct net_device *net, struct ethtool_drvinfo *info)
 }
 
 static int
-cdc_ncm_do_request(struct cdc_ncm_ctx *ctx, struct usb_cdc_notification *req,
+cdc_ncm_do_request(struct cdc_ncm_ctx *ctx, struct cdc_ncm_request *req,
 		   void *data, u16 flags, u16 *actlen, u16 timeout)
 {
 	int err;
@@ -173,7 +181,7 @@ cdc_ncm_do_request(struct cdc_ncm_ctx *ctx, struct usb_cdc_notification *req,
 	err = usb_control_msg(ctx->udev, (req->bmRequestType & USB_DIR_IN) ?
 				usb_rcvctrlpipe(ctx->udev, 0) :
 				usb_sndctrlpipe(ctx->udev, 0),
-				req->bNotificationType, req->bmRequestType,
+				req->bRequest, req->bmRequestType,
 				req->wValue,
 				req->wIndex, data,
 				req->wLength, timeout);
@@ -192,7 +200,7 @@ cdc_ncm_do_request(struct cdc_ncm_ctx *ctx, struct usb_cdc_notification *req,
 
 static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
 {
-	struct usb_cdc_notification req;
+	struct cdc_ncm_request req;
 	u32 val;
 	u8 flags;
 	u8 iface_no;
@@ -202,10 +210,10 @@ static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
 	iface_no = ctx->control->cur_altsetting->desc.bInterfaceNumber;
 
 	req.bmRequestType = USB_TYPE_CLASS | USB_DIR_IN | USB_RECIP_INTERFACE;
-	req.bNotificationType = USB_CDC_GET_NTB_PARAMETERS;
+	req.bRequest = USB_CDC_GET_NTB_PARAMETERS;
 	req.wValue = 0;
-	req.wIndex = cpu_to_le16(iface_no);
-	req.wLength = cpu_to_le16(sizeof(ctx->ncm_parm));
+	req.wIndex = iface_no;
+	req.wLength = sizeof(ctx->ncm_parm);
 
 	err = cdc_ncm_do_request(ctx, &req, &ctx->ncm_parm, 0, NULL, 1000);
 	if (err) {
@@ -256,9 +264,9 @@ static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
 	if (ctx->rx_max != le32_to_cpu(ctx->ncm_parm.dwNtbInMaxSize)) {
 		req.bmRequestType = USB_TYPE_CLASS | USB_DIR_OUT |
 							USB_RECIP_INTERFACE;
-		req.bNotificationType = USB_CDC_SET_NTB_INPUT_SIZE;
+		req.bRequest = USB_CDC_SET_NTB_INPUT_SIZE;
 		req.wValue = 0;
-		req.wIndex = cpu_to_le16(iface_no);
+		req.wIndex = iface_no;
 
 		if (flags & USB_CDC_NCM_NCAP_NTB_INPUT_SIZE) {
 			struct usb_cdc_ncm_ndp_input_size ndp_in_sz;
@@ -335,9 +343,9 @@ static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
 	if (flags & USB_CDC_NCM_NCAP_CRC_MODE) {
 		req.bmRequestType = USB_TYPE_CLASS | USB_DIR_OUT |
 							USB_RECIP_INTERFACE;
-		req.bNotificationType = USB_CDC_SET_CRC_MODE;
-		req.wValue = cpu_to_le16(USB_CDC_NCM_CRC_NOT_APPENDED);
-		req.wIndex = cpu_to_le16(iface_no);
+		req.bRequest = USB_CDC_SET_CRC_MODE;
+		req.wValue = USB_CDC_NCM_CRC_NOT_APPENDED;
+		req.wIndex = iface_no;
 		req.wLength = 0;
 
 		err = cdc_ncm_do_request(ctx, &req, NULL, 0, NULL, 1000);
@@ -349,9 +357,9 @@ static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
 	if (ntb_fmt_supported & USB_CDC_NCM_NTH32_SIGN) {
 		req.bmRequestType = USB_TYPE_CLASS | USB_DIR_OUT |
 							USB_RECIP_INTERFACE;
-		req.bNotificationType = USB_CDC_SET_NTB_FORMAT;
-		req.wValue = cpu_to_le16(USB_CDC_NCM_NTB16_FORMAT);
-		req.wIndex = cpu_to_le16(iface_no);
+		req.bRequest = USB_CDC_SET_NTB_FORMAT;
+		req.wValue = USB_CDC_NCM_NTB16_FORMAT;
+		req.wIndex = iface_no;
 		req.wLength = 0;
 
 		err = cdc_ncm_do_request(ctx, &req, NULL, 0, NULL, 1000);
@@ -368,10 +376,10 @@ static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
 
 		req.bmRequestType = USB_TYPE_CLASS | USB_DIR_IN |
 							USB_RECIP_INTERFACE;
-		req.bNotificationType = USB_CDC_GET_MAX_DATAGRAM_SIZE;
+		req.bRequest = USB_CDC_GET_MAX_DATAGRAM_SIZE;
 		req.wValue = 0;
-		req.wIndex = cpu_to_le16(iface_no);
-		req.wLength = cpu_to_le16(2);
+		req.wIndex = iface_no;
+		req.wLength = 2;
 
 		err = cdc_ncm_do_request(ctx, &req, &max_datagram_size, 0, NULL,
 									1000);
@@ -398,9 +406,9 @@ static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
 			/* if value changed, update device */
 			req.bmRequestType = USB_TYPE_CLASS | USB_DIR_OUT |
 							USB_RECIP_INTERFACE;
-			req.bNotificationType = USB_CDC_SET_MAX_DATAGRAM_SIZE;
+			req.bRequest = USB_CDC_SET_MAX_DATAGRAM_SIZE;
 			req.wValue = 0;
-			req.wIndex = cpu_to_le16(iface_no);
+			req.wIndex = iface_no;
 			req.wLength = 2;
 			max_datagram_size = cpu_to_le16(ctx->max_datagram_size);
 
@@ -672,7 +680,7 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb)
 	u32 rem;
 	u32 offset;
 	u32 last_offset;
-	u16 n = 0;
+	u16 n = 0, index;
 	u8 ready2send = 0;
 
 	/* if there is a remaining skb, it gets priority */
@@ -860,8 +868,8 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb)
 					cpu_to_le16(sizeof(ctx->tx_ncm.nth16));
 	ctx->tx_ncm.nth16.wSequence = cpu_to_le16(ctx->tx_seq);
 	ctx->tx_ncm.nth16.wBlockLength = cpu_to_le16(last_offset);
-	ctx->tx_ncm.nth16.wNdpIndex = ALIGN(sizeof(struct usb_cdc_ncm_nth16),
-							ctx->tx_ndp_modulus);
+	index = ALIGN(sizeof(struct usb_cdc_ncm_nth16), ctx->tx_ndp_modulus);
+	ctx->tx_ncm.nth16.wNdpIndex = cpu_to_le16(index);
 
 	memcpy(skb_out->data, &(ctx->tx_ncm.nth16), sizeof(ctx->tx_ncm.nth16));
 	ctx->tx_seq++;
@@ -874,12 +882,11 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb)
 	ctx->tx_ncm.ndp16.wLength = cpu_to_le16(rem);
 	ctx->tx_ncm.ndp16.wNextNdpIndex = 0; /* reserved */
 
-	memcpy(((u8 *)skb_out->data) + ctx->tx_ncm.nth16.wNdpIndex,
+	memcpy(((u8 *)skb_out->data) + index,
 						&(ctx->tx_ncm.ndp16),
 						sizeof(ctx->tx_ncm.ndp16));
 
-	memcpy(((u8 *)skb_out->data) + ctx->tx_ncm.nth16.wNdpIndex +
-					sizeof(ctx->tx_ncm.ndp16),
+	memcpy(((u8 *)skb_out->data) + index + sizeof(ctx->tx_ncm.ndp16),
 					&(ctx->tx_ncm.dpe16),
 					(ctx->tx_curr_frame_num + 1) *
 					sizeof(struct usb_cdc_ncm_dpe16));
@@ -1129,7 +1136,7 @@ cdc_ncm_speed_change(struct cdc_ncm_ctx *ctx,
 static void cdc_ncm_status(struct usbnet *dev, struct urb *urb)
 {
 	struct cdc_ncm_ctx *ctx;
-	struct usb_cdc_notification *event;
+	struct cdc_ncm_request *event;
 
 	ctx = (struct cdc_ncm_ctx *)dev->data[0];
 
@@ -1145,7 +1152,7 @@ static void cdc_ncm_status(struct usbnet *dev, struct urb *urb)
 
 	event = urb->transfer_buffer;
 
-	switch (event->bNotificationType) {
+	switch (event->bRequest) {
 	case USB_CDC_NOTIFY_NETWORK_CONNECTION:
 		/*
 		 * According to the CDC NCM specification ch.7.1
@@ -1177,7 +1184,7 @@ static void cdc_ncm_status(struct usbnet *dev, struct urb *urb)
 
 	default:
 		dev_err(&dev->udev->dev, "NCM: unexpected "
-			"notification 0x%02x!\n", event->bNotificationType);
+			"notification 0x%02x!\n", event->bRequest);
 		break;
 	}
 }
-- 
1.7.5.4

