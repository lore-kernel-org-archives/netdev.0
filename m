From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [RFC PATCH 1/6] cdc_ncm: factor out skb allocation and finalizzing
Date: Mon, 29 Dec 2014 11:09:43 +0100
Message-ID: <1419847788-25610-2-git-send-email-mrkiko.rs@gmail.com>
References: <1419847788-25610-1-git-send-email-mrkiko.rs@gmail.com>
Cc: Enrico Mioso <mrkiko.rs@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:50050 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751312AbaL2KJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2014 05:09:51 -0500
Received: by mail-wi0-f169.google.com with SMTP id r20so23248154wiv.2
        for <netdev@vger.kernel.org>; Mon, 29 Dec 2014 02:09:49 -0800 (PST)
In-Reply-To: <1419847788-25610-1-git-send-email-mrkiko.rs@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This might help when we will refactor the code to prepare frames only when we
have enough data, allowing us to re-order the position of different NCM
fields.

Signed-Off-By: Enrico Mioso <mrkiko.rs@gmail.com>
---
 drivers/net/usb/cdc_ncm.c | 46 +++++++++++++++++++++++++++++++++++-----------
 1 file changed, 35 insertions(+), 11 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 389a3a4..48fee7a 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1014,6 +1014,36 @@ static struct usb_cdc_ncm_ndp16 *cdc_ncm_ndp16(struct cdc_ncm_ctx *ctx, struct s
 	return ndp16;
 }
 
+/* Allocate new SKB for use with 16-bit NCM according to actual TX/RX
+	settings */
+struct sk_buff *
+cdc_ncm_prepare_skb_ncm16(struct sk_buff *skb, struct cdc_ncm_ctx *ctx)
+{
+	struct usb_cdc_ncm_nth16 *nth16;
+	
+	skb = alloc_skb(ctx->tx_max, GFP_ATOMIC);
+	if (skb == NULL)
+			goto exit_no_mem;
+		
+	/* fill out the initial 16-bit NTB header */
+	nth16 = (struct usb_cdc_ncm_nth16 *)memset(skb_put(skb, sizeof(struct usb_cdc_ncm_nth16)), 0, sizeof(struct usb_cdc_ncm_nth16));
+	nth16->dwSignature = cpu_to_le32(USB_CDC_NCM_NTH16_SIGN);
+	nth16->wHeaderLength = cpu_to_le16(sizeof(struct usb_cdc_ncm_nth16));
+	nth16->wSequence = cpu_to_le16(ctx->tx_seq++);
+
+exit_no_mem:
+	return skb;
+}
+
+/* Adjust 16-bit NCM header frame length */
+struct usb_cdc_ncm_nth16 *
+cdc_ncm_finalize_nth16(struct usb_cdc_ncm_nth16 *nth16, struct sk_buff *skb)
+{
+	nth16 = (struct usb_cdc_ncm_nth16 *)skb->data;
+	nth16->wBlockLength = cpu_to_le16(skb->len);
+	return nth16;
+}
+
 struct sk_buff *
 cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk_buff *skb, __le32 sign)
 {
@@ -1037,7 +1067,7 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk_buff *skb, __le32 sign)
 
 	/* allocate a new OUT skb */
 	if (!skb_out) {
-		skb_out = alloc_skb(ctx->tx_max, GFP_ATOMIC);
+		skb_out = cdc_ncm_prepare_skb_ncm16(skb_out, ctx);
 		if (skb_out == NULL) {
 			if (skb != NULL) {
 				dev_kfree_skb_any(skb);
@@ -1045,11 +1075,6 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk_buff *skb, __le32 sign)
 			}
 			goto exit_no_skb;
 		}
-		/* fill out the initial 16-bit NTB header */
-		nth16 = (struct usb_cdc_ncm_nth16 *)memset(skb_put(skb_out, sizeof(struct usb_cdc_ncm_nth16)), 0, sizeof(struct usb_cdc_ncm_nth16));
-		nth16->dwSignature = cpu_to_le32(USB_CDC_NCM_NTH16_SIGN);
-		nth16->wHeaderLength = cpu_to_le16(sizeof(struct usb_cdc_ncm_nth16));
-		nth16->wSequence = cpu_to_le16(ctx->tx_seq++);
 
 		/* count total number of frames in this NTB */
 		ctx->tx_curr_frame_num = 0;
@@ -1165,11 +1190,10 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk_buff *skb, __le32 sign)
 		       ctx->tx_max - skb_out->len);
 	else if (skb_out->len < ctx->tx_max && (skb_out->len % dev->maxpacket) == 0)
 		*skb_put(skb_out, 1) = 0;	/* force short packet */
-
-	/* set final frame length */
-	nth16 = (struct usb_cdc_ncm_nth16 *)skb_out->data;
-	nth16->wBlockLength = cpu_to_le16(skb_out->len);
-
+	
+	/* Finalize packet */
+	nth16 = cdc_ncm_finalize_nth16(nth16, skb_out);
+	
 	/* return skb */
 	ctx->tx_curr_skb = NULL;
 	dev->net->stats.tx_packets += ctx->tx_curr_frame_num;
-- 
2.2.1
