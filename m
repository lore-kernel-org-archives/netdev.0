From: Giuseppe Scrivano <giuseppe-A9uVI2HLR7kOP4wsBPIw7w@public.gmane.org>
Subject: Re: [PATCH ] cdc_ncm: fixes for big-endian architecture / MIPS
Date: Wed, 03 Aug 2011 17:46:43 +0200
Message-ID: <87ipqeebvg.fsf@gnu.org>
References: <87hb5yock6.fsf@gnu.org>
	<2AC7D4AD8BA1C640B4C60C61C8E520153E3DEF6C26@EXDCVYMBSTM006.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "netdev\@vger.kernel.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"oliver\@neukum.org" <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	"linux-usb\@vger.kernel.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"gregkh\@suse.de" <gregkh-l3A5Bk7waGM@public.gmane.org>,
	"alexey.orishko\@gmail.com" <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Alexey ORISHKO <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2AC7D4AD8BA1C640B4C60C61C8E520153E3DEF6C26-8ZTw5gFVCTjVH5byLeRTJxkTb7+GphCuwzqs5ZKRSiY@public.gmane.org>
	(Alexey ORISHKO's message of "Wed, 3 Aug 2011 16:07:18 +0200")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Alexey ORISHKO <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org> writes:

> Since it was incorrect to use struct usb_cdc_notification I would rather
> remove cdc_ncm_do_request() function and provide u16 parameters directly to 
> usb_control_msg without creating yet additional structure for usb control request.

here another version, I have removed cdc_ncm_do_request and call
directly usb_control_msg.  Tested on mips.

Cheers,
Giuseppe



>From 7ba49d858103acb2ce4043127e3512ea29dff307 Mon Sep 17 00:00:00 2001
From: Giuseppe Scrivano <giuseppe-A9uVI2HLR7kOP4wsBPIw7w@public.gmane.org>
Date: Fri, 15 Jul 2011 15:34:14 +0200
Subject: [PATCH] cdc_ncm: fix endianess problem.

Signed-off-by: Giuseppe Scrivano <giuseppe-A9uVI2HLR7kOP4wsBPIw7w@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c |  156 ++++++++++++++++-----------------------------
 1 files changed, 56 insertions(+), 100 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index f33ca6a..9c37d54 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -54,7 +54,7 @@
 #include <linux/usb/usbnet.h>
 #include <linux/usb/cdc.h>
 
-#define	DRIVER_VERSION				"01-June-2011"
+#define	DRIVER_VERSION				"03-Aug-2011"
 
 /* CDC NCM subclass 3.2.1 */
 #define USB_CDC_NCM_NDP16_LENGTH_MIN		0x10
@@ -164,35 +164,8 @@ cdc_ncm_get_drvinfo(struct net_device *net, struct ethtool_drvinfo *info)
 	usb_make_path(dev->udev, info->bus_info, sizeof(info->bus_info));
 }
 
-static int
-cdc_ncm_do_request(struct cdc_ncm_ctx *ctx, struct usb_cdc_notification *req,
-		   void *data, u16 flags, u16 *actlen, u16 timeout)
-{
-	int err;
-
-	err = usb_control_msg(ctx->udev, (req->bmRequestType & USB_DIR_IN) ?
-				usb_rcvctrlpipe(ctx->udev, 0) :
-				usb_sndctrlpipe(ctx->udev, 0),
-				req->bNotificationType, req->bmRequestType,
-				req->wValue,
-				req->wIndex, data,
-				req->wLength, timeout);
-
-	if (err < 0) {
-		if (actlen)
-			*actlen = 0;
-		return err;
-	}
-
-	if (actlen)
-		*actlen = err;
-
-	return 0;
-}
-
 static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
 {
-	struct usb_cdc_notification req;
 	u32 val;
 	u8 flags;
 	u8 iface_no;
@@ -201,14 +174,14 @@ static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
 
 	iface_no = ctx->control->cur_altsetting->desc.bInterfaceNumber;
 
-	req.bmRequestType = USB_TYPE_CLASS | USB_DIR_IN | USB_RECIP_INTERFACE;
-	req.bNotificationType = USB_CDC_GET_NTB_PARAMETERS;
-	req.wValue = 0;
-	req.wIndex = cpu_to_le16(iface_no);
-	req.wLength = cpu_to_le16(sizeof(ctx->ncm_parm));
-
-	err = cdc_ncm_do_request(ctx, &req, &ctx->ncm_parm, 0, NULL, 1000);
-	if (err) {
+	err = usb_control_msg(ctx->udev,
+				usb_rcvctrlpipe(ctx->udev, 0),
+				USB_CDC_GET_NTB_PARAMETERS,
+				USB_TYPE_CLASS | USB_DIR_IN
+				 | USB_RECIP_INTERFACE,
+				0, iface_no, &ctx->ncm_parm,
+				sizeof(ctx->ncm_parm), 10000);
+	if (err < 0) {
 		pr_debug("failed GET_NTB_PARAMETERS\n");
 		return 1;
 	}
@@ -254,31 +227,26 @@ static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
 
 	/* inform device about NTB input size changes */
 	if (ctx->rx_max != le32_to_cpu(ctx->ncm_parm.dwNtbInMaxSize)) {
-		req.bmRequestType = USB_TYPE_CLASS | USB_DIR_OUT |
-							USB_RECIP_INTERFACE;
-		req.bNotificationType = USB_CDC_SET_NTB_INPUT_SIZE;
-		req.wValue = 0;
-		req.wIndex = cpu_to_le16(iface_no);
 
 		if (flags & USB_CDC_NCM_NCAP_NTB_INPUT_SIZE) {
 			struct usb_cdc_ncm_ndp_input_size ndp_in_sz;
-
-			req.wLength = 8;
-			ndp_in_sz.dwNtbInMaxSize = cpu_to_le32(ctx->rx_max);
-			ndp_in_sz.wNtbInMaxDatagrams =
-					cpu_to_le16(CDC_NCM_DPT_DATAGRAMS_MAX);
-			ndp_in_sz.wReserved = 0;
-			err = cdc_ncm_do_request(ctx, &req, &ndp_in_sz, 0, NULL,
-									1000);
+			err = usb_control_msg(ctx->udev,
+					usb_sndctrlpipe(ctx->udev, 0),
+					USB_CDC_SET_NTB_INPUT_SIZE,
+					USB_TYPE_CLASS | USB_DIR_OUT
+					 | USB_RECIP_INTERFACE,
+					0, iface_no, &ndp_in_sz, 8, 1000);
 		} else {
 			__le32 dwNtbInMaxSize = cpu_to_le32(ctx->rx_max);
-
-			req.wLength = 4;
-			err = cdc_ncm_do_request(ctx, &req, &dwNtbInMaxSize, 0,
-								NULL, 1000);
+			err = usb_control_msg(ctx->udev,
+					usb_sndctrlpipe(ctx->udev, 0),
+					USB_CDC_SET_NTB_INPUT_SIZE,
+					USB_TYPE_CLASS | USB_DIR_OUT
+					 | USB_RECIP_INTERFACE,
+					0, iface_no, &dwNtbInMaxSize, 4, 1000);
 		}
 
-		if (err)
+		if (err < 0)
 			pr_debug("Setting NTB Input Size failed\n");
 	}
 
@@ -333,29 +301,24 @@ static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
 
 	/* set CRC Mode */
 	if (flags & USB_CDC_NCM_NCAP_CRC_MODE) {
-		req.bmRequestType = USB_TYPE_CLASS | USB_DIR_OUT |
-							USB_RECIP_INTERFACE;
-		req.bNotificationType = USB_CDC_SET_CRC_MODE;
-		req.wValue = cpu_to_le16(USB_CDC_NCM_CRC_NOT_APPENDED);
-		req.wIndex = cpu_to_le16(iface_no);
-		req.wLength = 0;
-
-		err = cdc_ncm_do_request(ctx, &req, NULL, 0, NULL, 1000);
-		if (err)
+		err = usb_control_msg(ctx->udev, usb_sndctrlpipe(ctx->udev, 0),
+				USB_CDC_SET_CRC_MODE,
+				USB_TYPE_CLASS | USB_DIR_OUT
+				 | USB_RECIP_INTERFACE,
+				USB_CDC_NCM_CRC_NOT_APPENDED,
+				iface_no, NULL, 0, 1000);
+		if (err < 0)
 			pr_debug("Setting CRC mode off failed\n");
 	}
 
 	/* set NTB format, if both formats are supported */
 	if (ntb_fmt_supported & USB_CDC_NCM_NTH32_SIGN) {
-		req.bmRequestType = USB_TYPE_CLASS | USB_DIR_OUT |
-							USB_RECIP_INTERFACE;
-		req.bNotificationType = USB_CDC_SET_NTB_FORMAT;
-		req.wValue = cpu_to_le16(USB_CDC_NCM_NTB16_FORMAT);
-		req.wIndex = cpu_to_le16(iface_no);
-		req.wLength = 0;
-
-		err = cdc_ncm_do_request(ctx, &req, NULL, 0, NULL, 1000);
-		if (err)
+		err = usb_control_msg(ctx->udev, usb_sndctrlpipe(ctx->udev, 0),
+				USB_CDC_SET_NTB_FORMAT, USB_TYPE_CLASS
+				 | USB_DIR_OUT | USB_RECIP_INTERFACE,
+				USB_CDC_NCM_NTB16_FORMAT,
+				iface_no, NULL, 0, 1000);
+		if (err < 0)
 			pr_debug("Setting NTB format to 16-bit failed\n");
 	}
 
@@ -365,17 +328,13 @@ static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
 	if (flags & USB_CDC_NCM_NCAP_MAX_DATAGRAM_SIZE) {
 		__le16 max_datagram_size;
 		u16 eth_max_sz = le16_to_cpu(ctx->ether_desc->wMaxSegmentSize);
-
-		req.bmRequestType = USB_TYPE_CLASS | USB_DIR_IN |
-							USB_RECIP_INTERFACE;
-		req.bNotificationType = USB_CDC_GET_MAX_DATAGRAM_SIZE;
-		req.wValue = 0;
-		req.wIndex = cpu_to_le16(iface_no);
-		req.wLength = cpu_to_le16(2);
-
-		err = cdc_ncm_do_request(ctx, &req, &max_datagram_size, 0, NULL,
-									1000);
-		if (err) {
+		err = usb_control_msg(ctx->udev, usb_rcvctrlpipe(ctx->udev, 0),
+				USB_CDC_GET_MAX_DATAGRAM_SIZE,
+				USB_TYPE_CLASS | USB_DIR_IN
+				 | USB_RECIP_INTERFACE,
+				0, iface_no, &max_datagram_size,
+				2, 1000);
+		if (err < 0) {
 			pr_debug("GET_MAX_DATAGRAM_SIZE failed, use size=%u\n",
 						CDC_NCM_MIN_DATAGRAM_SIZE);
 		} else {
@@ -396,17 +355,15 @@ static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
 					CDC_NCM_MIN_DATAGRAM_SIZE;
 
 			/* if value changed, update device */
-			req.bmRequestType = USB_TYPE_CLASS | USB_DIR_OUT |
-							USB_RECIP_INTERFACE;
-			req.bNotificationType = USB_CDC_SET_MAX_DATAGRAM_SIZE;
-			req.wValue = 0;
-			req.wIndex = cpu_to_le16(iface_no);
-			req.wLength = 2;
-			max_datagram_size = cpu_to_le16(ctx->max_datagram_size);
-
-			err = cdc_ncm_do_request(ctx, &req, &max_datagram_size,
-								0, NULL, 1000);
-			if (err)
+			err = usb_control_msg(ctx->udev,
+						usb_sndctrlpipe(ctx->udev, 0),
+						USB_CDC_SET_MAX_DATAGRAM_SIZE,
+						USB_TYPE_CLASS | USB_DIR_OUT
+						 | USB_RECIP_INTERFACE,
+						0,
+						iface_no, &max_datagram_size,
+						2, 1000);
+			if (err < 0)
 				pr_debug("SET_MAX_DATAGRAM_SIZE failed\n");
 		}
 
@@ -672,7 +629,7 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb)
 	u32 rem;
 	u32 offset;
 	u32 last_offset;
-	u16 n = 0;
+	u16 n = 0, index;
 	u8 ready2send = 0;
 
 	/* if there is a remaining skb, it gets priority */
@@ -860,8 +817,8 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb)
 					cpu_to_le16(sizeof(ctx->tx_ncm.nth16));
 	ctx->tx_ncm.nth16.wSequence = cpu_to_le16(ctx->tx_seq);
 	ctx->tx_ncm.nth16.wBlockLength = cpu_to_le16(last_offset);
-	ctx->tx_ncm.nth16.wNdpIndex = ALIGN(sizeof(struct usb_cdc_ncm_nth16),
-							ctx->tx_ndp_modulus);
+	index = ALIGN(sizeof(struct usb_cdc_ncm_nth16), ctx->tx_ndp_modulus);
+	ctx->tx_ncm.nth16.wNdpIndex = cpu_to_le16(index);
 
 	memcpy(skb_out->data, &(ctx->tx_ncm.nth16), sizeof(ctx->tx_ncm.nth16));
 	ctx->tx_seq++;
@@ -874,12 +831,11 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb)
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
-- 
1.7.5.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
