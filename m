From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [RFC PATCH 6/6] cdc_ncm: factor out NDP preparation and frame linking
Date: Mon, 29 Dec 2014 11:09:48 +0100
Message-ID: <1419847788-25610-7-git-send-email-mrkiko.rs@gmail.com>
References: <1419847788-25610-1-git-send-email-mrkiko.rs@gmail.com>
Cc: Enrico Mioso <mrkiko.rs@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:47000 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752070AbaL2KJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2014 05:09:59 -0500
Received: by mail-wi0-f171.google.com with SMTP id bs8so21557654wib.10
        for <netdev@vger.kernel.org>; Mon, 29 Dec 2014 02:09:58 -0800 (PST)
In-Reply-To: <1419847788-25610-1-git-send-email-mrkiko.rs@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To some extent, factor out NDP preparation and frame linking.
This is the change I like less - but I plan to revisit this once (in case) we
change the way the entire cdc_ncm_fill_tx_frame works.

Signed-Off-By: Enrico Mioso <mrkiko.rs@gmail.com>
---
 drivers/net/usb/cdc_ncm.c | 24 ++++++++++++++++--------
 1 file changed, 16 insertions(+), 8 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index babfaee..b21aab8 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1044,6 +1044,20 @@ cdc_ncm_finalize_nth16(struct usb_cdc_ncm_nth16 *nth16, struct sk_buff *skb)
 	return nth16;
 }
 
+u16
+cdc_ncm_calculate_ndp16(struct usb_cdc_ncm_ndp16 *ndp16, struct sk_buff *skb, struct sk_buff *next_skb) {
+	u16 ndplen, index;
+	
+	ndplen = le16_to_cpu(ndp16->wLength);
+	index = (ndplen - sizeof(struct usb_cdc_ncm_ndp16)) / sizeof(struct usb_cdc_ncm_dpe16) - 1;
+
+	/* OK, add this skb */
+	ndp16->dpe16[index].wDatagramLength = cpu_to_le16(skb->len);
+	ndp16->dpe16[index].wDatagramIndex = cpu_to_le16(next_skb->len);
+	ndp16->wLength = cpu_to_le16(ndplen + sizeof(struct usb_cdc_ncm_dpe16));
+	return index;
+}
+
 struct sk_buff *
 cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk_buff *skb, __le32 sign)
 {
@@ -1051,7 +1065,7 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk_buff *skb, __le32 sign)
 	struct usb_cdc_ncm_nth16 *nth16;
 	struct usb_cdc_ncm_ndp16 *ndp16;
 	struct sk_buff *skb_out;
-	u16 n = 0, index, ndplen;
+	u16 n = 0, index;
 	u8 ready2send = 0;
 
 	/* if there is a remaining skb, it gets priority */
@@ -1124,13 +1138,7 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk_buff *skb, __le32 sign)
 		}
 
 		/* calculate frame number within this NDP */
-		ndplen = le16_to_cpu(ndp16->wLength);
-		index = (ndplen - sizeof(struct usb_cdc_ncm_ndp16)) / sizeof(struct usb_cdc_ncm_dpe16) - 1;
-
-		/* OK, add this skb */
-		ndp16->dpe16[index].wDatagramLength = cpu_to_le16(skb->len);
-		ndp16->dpe16[index].wDatagramIndex = cpu_to_le16(skb_out->len);
-		ndp16->wLength = cpu_to_le16(ndplen + sizeof(struct usb_cdc_ncm_dpe16));
+		index = cdc_ncm_calculate_ndp16(ndp16, skb, skb_out);
 		memcpy(skb_put(skb_out, skb->len), skb->data, skb->len);
 		ctx->tx_curr_frame_payload += skb->len;	/* count real tx payload data */
 		dev_kfree_skb_any(skb);
-- 
2.2.1
