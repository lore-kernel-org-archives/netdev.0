From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v2 03/11] usbnet: cdc-ncm: apply introduced usb command APIs
Date: Thu, 25 Oct 2012 13:46:56 +0800
Message-ID: <1351144024-16596-4-git-send-email-ming.lei@canonical.com>
References: <1351144024-16596-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:44655 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932112Ab2JYFsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 01:48:10 -0400
In-Reply-To: <1351144024-16596-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Oliver Neukum <oneukum@suse.de>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/cdc_ncm.c |   85 +++++++++++++++++----------------------------
 1 file changed, 31 insertions(+), 54 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 0ed03b1..d0ea419 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -82,16 +82,15 @@ static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
 	u16 ntb_fmt_supported;
 	u32 min_dgram_size;
 	u32 min_hdr_size;
+	struct usbnet *dev = netdev_priv(ctx->netdev);
 
 	iface_no = ctx->control->cur_altsetting->desc.bInterfaceNumber;
 
-	err = usb_control_msg(ctx->udev,
-				usb_rcvctrlpipe(ctx->udev, 0),
-				USB_CDC_GET_NTB_PARAMETERS,
-				USB_TYPE_CLASS | USB_DIR_IN
-				 | USB_RECIP_INTERFACE,
-				0, iface_no, &ctx->ncm_parm,
-				sizeof(ctx->ncm_parm), 10000);
+	err = usbnet_read_cmd(dev, USB_CDC_GET_NTB_PARAMETERS,
+			      USB_TYPE_CLASS | USB_DIR_IN
+			      |USB_RECIP_INTERFACE,
+			      0, iface_no, &ctx->ncm_parm,
+			      sizeof(ctx->ncm_parm));
 	if (err < 0) {
 		pr_debug("failed GET_NTB_PARAMETERS\n");
 		return 1;
@@ -147,22 +146,12 @@ static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
 
 	/* inform device about NTB input size changes */
 	if (ctx->rx_max != le32_to_cpu(ctx->ncm_parm.dwNtbInMaxSize)) {
-		__le32 *dwNtbInMaxSize;
+		__le32 dwNtbInMaxSize = cpu_to_le32(ctx->rx_max);
 
-		dwNtbInMaxSize = kzalloc(sizeof(*dwNtbInMaxSize), GFP_KERNEL);
-		if (!dwNtbInMaxSize) {
-			err = -ENOMEM;
-			goto size_err;
-		}
-		*dwNtbInMaxSize = cpu_to_le32(ctx->rx_max);
-		err = usb_control_msg(ctx->udev,
-				      usb_sndctrlpipe(ctx->udev, 0),
-				      USB_CDC_SET_NTB_INPUT_SIZE,
-				      USB_TYPE_CLASS | USB_DIR_OUT
-				      | USB_RECIP_INTERFACE,
-				      0, iface_no, dwNtbInMaxSize, 4, 1000);
-		kfree(dwNtbInMaxSize);
-size_err:
+		err = usbnet_write_cmd(dev, USB_CDC_SET_NTB_INPUT_SIZE,
+				       USB_TYPE_CLASS | USB_DIR_OUT
+				       | USB_RECIP_INTERFACE,
+				       0, iface_no, &dwNtbInMaxSize, 4);
 		if (err < 0)
 			pr_debug("Setting NTB Input Size failed\n");
 	}
@@ -218,23 +207,22 @@ size_err:
 
 	/* set CRC Mode */
 	if (flags & USB_CDC_NCM_NCAP_CRC_MODE) {
-		err = usb_control_msg(ctx->udev, usb_sndctrlpipe(ctx->udev, 0),
-				USB_CDC_SET_CRC_MODE,
-				USB_TYPE_CLASS | USB_DIR_OUT
-				 | USB_RECIP_INTERFACE,
-				USB_CDC_NCM_CRC_NOT_APPENDED,
-				iface_no, NULL, 0, 1000);
+		err = usbnet_write_cmd(dev, USB_CDC_SET_CRC_MODE,
+				       USB_TYPE_CLASS | USB_DIR_OUT
+				       | USB_RECIP_INTERFACE,
+				       USB_CDC_NCM_CRC_NOT_APPENDED,
+				       iface_no, NULL, 0);
 		if (err < 0)
 			pr_debug("Setting CRC mode off failed\n");
 	}
 
 	/* set NTB format, if both formats are supported */
 	if (ntb_fmt_supported & USB_CDC_NCM_NTH32_SIGN) {
-		err = usb_control_msg(ctx->udev, usb_sndctrlpipe(ctx->udev, 0),
-				USB_CDC_SET_NTB_FORMAT, USB_TYPE_CLASS
-				 | USB_DIR_OUT | USB_RECIP_INTERFACE,
-				USB_CDC_NCM_NTB16_FORMAT,
-				iface_no, NULL, 0, 1000);
+		err = usbnet_write_cmd(dev, USB_CDC_SET_NTB_FORMAT,
+				       USB_TYPE_CLASS | USB_DIR_OUT
+				       | USB_RECIP_INTERFACE,
+				       USB_CDC_NCM_NTB16_FORMAT,
+				       iface_no, NULL, 0);
 		if (err < 0)
 			pr_debug("Setting NTB format to 16-bit failed\n");
 	}
@@ -243,7 +231,7 @@ size_err:
 
 	/* set Max Datagram Size (MTU) */
 	if (flags & USB_CDC_NCM_NCAP_MAX_DATAGRAM_SIZE) {
-		__le16 *max_datagram_size;
+		__le16 max_datagram_size;
 		u16 eth_max_sz;
 		if (ctx->ether_desc != NULL)
 			eth_max_sz = le16_to_cpu(ctx->ether_desc->wMaxSegmentSize);
@@ -252,25 +240,16 @@ size_err:
 		else
 			goto max_dgram_err;
 
-		max_datagram_size = kzalloc(sizeof(*max_datagram_size),
-				GFP_KERNEL);
-		if (!max_datagram_size) {
-			err = -ENOMEM;
-			goto max_dgram_err;
-		}
-
-		err = usb_control_msg(ctx->udev, usb_rcvctrlpipe(ctx->udev, 0),
-				USB_CDC_GET_MAX_DATAGRAM_SIZE,
-				USB_TYPE_CLASS | USB_DIR_IN
-				 | USB_RECIP_INTERFACE,
-				0, iface_no, max_datagram_size,
-				2, 1000);
+		err = usbnet_read_cmd(dev, USB_CDC_GET_MAX_DATAGRAM_SIZE,
+				      USB_TYPE_CLASS | USB_DIR_IN
+				      | USB_RECIP_INTERFACE,
+				      0, iface_no, &max_datagram_size, 2);
 		if (err < 0) {
 			pr_debug("GET_MAX_DATAGRAM_SIZE failed, use size=%u\n",
 				 min_dgram_size);
 		} else {
 			ctx->max_datagram_size =
-				le16_to_cpu(*max_datagram_size);
+				le16_to_cpu(max_datagram_size);
 			/* Check Eth descriptor value */
 			if (ctx->max_datagram_size > eth_max_sz)
 					ctx->max_datagram_size = eth_max_sz;
@@ -283,20 +262,18 @@ size_err:
 
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
 
 max_dgram_err:
-- 
1.7.9.5
