From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 03/12] usbnet: cdc-ncm: apply introduced usb command APIs
Date: Tue,  2 Oct 2012 14:51:14 +0800
Message-ID: <1349160684-6627-4-git-send-email-ming.lei@canonical.com>
References: <1349160684-6627-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:41411 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754161Ab2JBGvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 02:51:54 -0400
In-Reply-To: <1349160684-6627-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/cdc_ncm.c |   73 ++++++++++++++-------------------------------
 1 file changed, 23 insertions(+), 50 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 4cd582a..429a2ad 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -159,16 +159,16 @@ static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
 	u8 iface_no;
 	int err;
 	u16 ntb_fmt_supported;
+	struct usbnet *dev = netdev_priv(ctx->netdev);
 
 	iface_no = ctx->control->cur_altsetting->desc.bInterfaceNumber;
 
-	err = usb_control_msg(ctx->udev,
-				usb_rcvctrlpipe(ctx->udev, 0),
+	err = usbnet_read_cmd(dev,
 				USB_CDC_GET_NTB_PARAMETERS,
 				USB_TYPE_CLASS | USB_DIR_IN
 				 | USB_RECIP_INTERFACE,
 				0, iface_no, &ctx->ncm_parm,
-				sizeof(ctx->ncm_parm), 10000);
+				sizeof(ctx->ncm_parm));
 	if (err < 0) {
 		pr_debug("failed GET_NTB_PARAMETERS\n");
 		return 1;
@@ -217,40 +217,23 @@ static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
 	if (ctx->rx_max != le32_to_cpu(ctx->ncm_parm.dwNtbInMaxSize)) {
 
 		if (flags & USB_CDC_NCM_NCAP_NTB_INPUT_SIZE) {
-			struct usb_cdc_ncm_ndp_input_size *ndp_in_sz;
+			struct usb_cdc_ncm_ndp_input_size ndp_in_sz;
 
-			ndp_in_sz = kzalloc(sizeof(*ndp_in_sz), GFP_KERNEL);
-			if (!ndp_in_sz) {
-				err = -ENOMEM;
-				goto size_err;
-			}
-
-			err = usb_control_msg(ctx->udev,
-					usb_sndctrlpipe(ctx->udev, 0),
+			memset(&ndp_in_sz, 0, sizeof(ndp_in_sz));
+			err = usbnet_write_cmd(dev,
 					USB_CDC_SET_NTB_INPUT_SIZE,
 					USB_TYPE_CLASS | USB_DIR_OUT
 					 | USB_RECIP_INTERFACE,
-					0, iface_no, ndp_in_sz, 8, 1000);
-			kfree(ndp_in_sz);
+					0, iface_no, &ndp_in_sz, 8);
 		} else {
-			__le32 *dwNtbInMaxSize;
-			dwNtbInMaxSize = kzalloc(sizeof(*dwNtbInMaxSize),
-					GFP_KERNEL);
-			if (!dwNtbInMaxSize) {
-				err = -ENOMEM;
-				goto size_err;
-			}
-			*dwNtbInMaxSize = cpu_to_le32(ctx->rx_max);
+			__le32 dwNtbInMaxSize = cpu_to_le32(ctx->rx_max);
 
-			err = usb_control_msg(ctx->udev,
-					usb_sndctrlpipe(ctx->udev, 0),
+			err = usbnet_write_cmd(dev,
 					USB_CDC_SET_NTB_INPUT_SIZE,
 					USB_TYPE_CLASS | USB_DIR_OUT
 					 | USB_RECIP_INTERFACE,
-					0, iface_no, dwNtbInMaxSize, 4, 1000);
-			kfree(dwNtbInMaxSize);
+					0, iface_no, &dwNtbInMaxSize, 4);
 		}
-size_err:
 		if (err < 0)
 			pr_debug("Setting NTB Input Size failed\n");
 	}
@@ -306,23 +289,23 @@ size_err:
 
 	/* set CRC Mode */
 	if (flags & USB_CDC_NCM_NCAP_CRC_MODE) {
-		err = usb_control_msg(ctx->udev, usb_sndctrlpipe(ctx->udev, 0),
+		err = usbnet_write_cmd(dev,
 				USB_CDC_SET_CRC_MODE,
 				USB_TYPE_CLASS | USB_DIR_OUT
 				 | USB_RECIP_INTERFACE,
 				USB_CDC_NCM_CRC_NOT_APPENDED,
-				iface_no, NULL, 0, 1000);
+				iface_no, NULL, 0);
 		if (err < 0)
 			pr_debug("Setting CRC mode off failed\n");
 	}
 
 	/* set NTB format, if both formats are supported */
 	if (ntb_fmt_supported & USB_CDC_NCM_NTH32_SIGN) {
-		err = usb_control_msg(ctx->udev, usb_sndctrlpipe(ctx->udev, 0),
+		err = usbnet_write_cmd(dev,
 				USB_CDC_SET_NTB_FORMAT, USB_TYPE_CLASS
 				 | USB_DIR_OUT | USB_RECIP_INTERFACE,
 				USB_CDC_NCM_NTB16_FORMAT,
-				iface_no, NULL, 0, 1000);
+				iface_no, NULL, 0);
 		if (err < 0)
 			pr_debug("Setting NTB format to 16-bit failed\n");
 	}
@@ -331,28 +314,21 @@ size_err:
 
 	/* set Max Datagram Size (MTU) */
 	if (flags & USB_CDC_NCM_NCAP_MAX_DATAGRAM_SIZE) {
-		__le16 *max_datagram_size;
+		__le16 max_datagram_size;
 		u16 eth_max_sz = le16_to_cpu(ctx->ether_desc->wMaxSegmentSize);
 
-		max_datagram_size = kzalloc(sizeof(*max_datagram_size),
-				GFP_KERNEL);
-		if (!max_datagram_size) {
-			err = -ENOMEM;
-			goto max_dgram_err;
-		}
-
-		err = usb_control_msg(ctx->udev, usb_rcvctrlpipe(ctx->udev, 0),
+		err = usbnet_write_cmd(dev,
 				USB_CDC_GET_MAX_DATAGRAM_SIZE,
 				USB_TYPE_CLASS | USB_DIR_IN
 				 | USB_RECIP_INTERFACE,
-				0, iface_no, max_datagram_size,
-				2, 1000);
+				0, iface_no, &max_datagram_size,
+				2);
 		if (err < 0) {
 			pr_debug("GET_MAX_DATAGRAM_SIZE failed, use size=%u\n",
 						CDC_NCM_MIN_DATAGRAM_SIZE);
 		} else {
 			ctx->max_datagram_size =
-				le16_to_cpu(*max_datagram_size);
+				le16_to_cpu(max_datagram_size);
 			/* Check Eth descriptor value */
 			if (ctx->max_datagram_size > eth_max_sz)
 					ctx->max_datagram_size = eth_max_sz;
@@ -367,23 +343,20 @@ size_err:
 
 			/* if value changed, update device */
 			if (ctx->max_datagram_size !=
-					le16_to_cpu(*max_datagram_size)) {
-				err = usb_control_msg(ctx->udev,
-						usb_sndctrlpipe(ctx->udev, 0),
+					le16_to_cpu(max_datagram_size)) {
+				err = usbnet_write_cmd(dev,
 						USB_CDC_SET_MAX_DATAGRAM_SIZE,
 						USB_TYPE_CLASS | USB_DIR_OUT
 						 | USB_RECIP_INTERFACE,
 						0,
-						iface_no, max_datagram_size,
-						2, 1000);
+						iface_no, &max_datagram_size,
+						2);
 				if (err < 0)
 					pr_debug("SET_MAX_DGRAM_SIZE failed\n");
 			}
 		}
-		kfree(max_datagram_size);
 	}
 
-max_dgram_err:
 	if (ctx->netdev->mtu != (ctx->max_datagram_size - ETH_HLEN))
 		ctx->netdev->mtu = ctx->max_datagram_size - ETH_HLEN;
 
-- 
1.7.9.5
