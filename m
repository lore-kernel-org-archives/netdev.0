From: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH ] cdc_ncm: fixes for big-endian architecture / MIPS
Date: Tue,  2 Aug 2011 18:20:26 +0200
Message-ID: <1312302026-7077-1-git-send-email-alexey.orishko@stericsson.com>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org,
	Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Changes:
- removed redandunt conversion for usb control requests
- added missing conversion for nth16.wNdpIndex
Thanks to Giuseppe Scrivano for providing fixes

This patch shall be applied on top of today's Josh Boyle patch
[PATCH v3] usbnet/cdc_ncm: Don't use stack variables for DMA

Signed-off-by: Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c |   33 ++++++++++++++++-----------------
 1 files changed, 16 insertions(+), 17 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index bbcb133..4b2a317 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -53,7 +53,7 @@
 #include <linux/usb/usbnet.h>
 #include <linux/usb/cdc.h>
 
-#define	DRIVER_VERSION				"01-June-2011"
+#define	DRIVER_VERSION				"02-Aug-2011"
 
 /* CDC NCM subclass 3.2.1 */
 #define USB_CDC_NCM_NDP16_LENGTH_MIN		0x10
@@ -203,8 +203,8 @@ static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
 	req.bmRequestType = USB_TYPE_CLASS | USB_DIR_IN | USB_RECIP_INTERFACE;
 	req.bNotificationType = USB_CDC_GET_NTB_PARAMETERS;
 	req.wValue = 0;
-	req.wIndex = cpu_to_le16(iface_no);
-	req.wLength = cpu_to_le16(sizeof(ctx->ncm_parm));
+	req.wIndex = iface_no;
+	req.wLength = sizeof(ctx->ncm_parm);
 
 	err = cdc_ncm_do_request(ctx, &req, &ctx->ncm_parm, 0, NULL, 1000);
 	if (err) {
@@ -257,7 +257,7 @@ static u8 cdc_ncm_setup(struct cdc_ncm_ctx *ctx)
 							USB_RECIP_INTERFACE;
 		req.bNotificationType = USB_CDC_SET_NTB_INPUT_SIZE;
 		req.wValue = 0;
-		req.wIndex = cpu_to_le16(iface_no);
+		req.wIndex = iface_no;
 
 		if (flags & USB_CDC_NCM_NCAP_NTB_INPUT_SIZE) {
 			struct usb_cdc_ncm_ndp_input_size *ndp_in_sz;
@@ -351,8 +351,8 @@ size_err:
 		req.bmRequestType = USB_TYPE_CLASS | USB_DIR_OUT |
 							USB_RECIP_INTERFACE;
 		req.bNotificationType = USB_CDC_SET_CRC_MODE;
-		req.wValue = cpu_to_le16(USB_CDC_NCM_CRC_NOT_APPENDED);
-		req.wIndex = cpu_to_le16(iface_no);
+		req.wValue = USB_CDC_NCM_CRC_NOT_APPENDED;
+		req.wIndex = iface_no;
 		req.wLength = 0;
 
 		err = cdc_ncm_do_request(ctx, &req, NULL, 0, NULL, 1000);
@@ -365,8 +365,8 @@ size_err:
 		req.bmRequestType = USB_TYPE_CLASS | USB_DIR_OUT |
 							USB_RECIP_INTERFACE;
 		req.bNotificationType = USB_CDC_SET_NTB_FORMAT;
-		req.wValue = cpu_to_le16(USB_CDC_NCM_NTB16_FORMAT);
-		req.wIndex = cpu_to_le16(iface_no);
+		req.wValue = USB_CDC_NCM_NTB16_FORMAT;
+		req.wIndex = iface_no;
 		req.wLength = 0;
 
 		err = cdc_ncm_do_request(ctx, &req, NULL, 0, NULL, 1000);
@@ -392,8 +392,8 @@ size_err:
 							USB_RECIP_INTERFACE;
 		req.bNotificationType = USB_CDC_GET_MAX_DATAGRAM_SIZE;
 		req.wValue = 0;
-		req.wIndex = cpu_to_le16(iface_no);
-		req.wLength = cpu_to_le16(2);
+		req.wIndex = iface_no;
+		req.wLength = 2;
 
 		err = cdc_ncm_do_request(ctx, &req, max_datagram_size, 0, NULL,
 									1000);
@@ -426,7 +426,7 @@ size_err:
 							USB_RECIP_INTERFACE;
 			req.bNotificationType = USB_CDC_SET_MAX_DATAGRAM_SIZE;
 			req.wValue = 0;
-			req.wIndex = cpu_to_le16(iface_no);
+			req.wIndex = iface_no;
 			req.wLength = 2;
 			*max_datagram_size =
 				cpu_to_le16(ctx->max_datagram_size);
@@ -702,6 +702,7 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb)
 	u32 offset;
 	u32 last_offset;
 	u16 n = 0;
+	u16 ndpIndex = 0;
 	u8 ready2send = 0;
 
 	/* if there is a remaining skb, it gets priority */
@@ -889,8 +890,8 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb)
 					cpu_to_le16(sizeof(ctx->tx_ncm.nth16));
 	ctx->tx_ncm.nth16.wSequence = cpu_to_le16(ctx->tx_seq);
 	ctx->tx_ncm.nth16.wBlockLength = cpu_to_le16(last_offset);
-	ctx->tx_ncm.nth16.wNdpIndex = ALIGN(sizeof(struct usb_cdc_ncm_nth16),
-							ctx->tx_ndp_modulus);
+	ndpIndex = ALIGN(sizeof(struct usb_cdc_ncm_nth16), ctx->tx_ndp_modulus);
+	ctx->tx_ncm.nth16.wNdpIndex = cpu_to_le16(ndpIndex);
 
 	memcpy(skb_out->data, &(ctx->tx_ncm.nth16), sizeof(ctx->tx_ncm.nth16));
 	ctx->tx_seq++;
@@ -903,12 +904,10 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb)
 	ctx->tx_ncm.ndp16.wLength = cpu_to_le16(rem);
 	ctx->tx_ncm.ndp16.wNextNdpIndex = 0; /* reserved */
 
-	memcpy(((u8 *)skb_out->data) + ctx->tx_ncm.nth16.wNdpIndex,
-						&(ctx->tx_ncm.ndp16),
+	memcpy(((u8 *)skb_out->data) + ndpIndex, &(ctx->tx_ncm.ndp16),
 						sizeof(ctx->tx_ncm.ndp16));
 
-	memcpy(((u8 *)skb_out->data) + ctx->tx_ncm.nth16.wNdpIndex +
-					sizeof(ctx->tx_ncm.ndp16),
+	memcpy(((u8 *)skb_out->data) + ndpIndex + sizeof(ctx->tx_ncm.ndp16),
 					&(ctx->tx_ncm.dpe16),
 					(ctx->tx_curr_frame_num + 1) *
 					sizeof(struct usb_cdc_ncm_dpe16));
-- 
1.7.4.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
