From: Alexey Orishko <alexey.orishko@gmail.com>
Subject: [PATCH] CDC NCM: Add mising short packet in cdc_ncm driver
Date: Fri,  6 May 2011 15:01:30 +0200
Message-ID: <1304686890-2543-1-git-send-email-alexey.orishko@stericsson.com>
References: <y>
Cc: linux-usb@vger.kernel.org, davem@davemloft.net, gregkh@suse.de,
	Alexey Orishko <alexey.orishko@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:34519 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752411Ab1EFNED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2011 09:04:03 -0400
In-Reply-To: <y>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes:
- while making NTB, driver shall check if device dwNtbOutMaxSize is higher than
 host value and shall add a short packet if this is the case
- previous temporary patch for this issue is replaced by this one

Signed-off-by: Alexey Orishko <alexey.orishko@stericsson.com>
---
 drivers/net/usb/cdc_ncm.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 1033ef6..4ab557d 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -54,13 +54,13 @@
 #include <linux/usb/usbnet.h>
 #include <linux/usb/cdc.h>
 
-#define	DRIVER_VERSION				"23-Apr-2011"
+#define	DRIVER_VERSION				"06-May-2011"
 
 /* CDC NCM subclass 3.2.1 */
 #define USB_CDC_NCM_NDP16_LENGTH_MIN		0x10
 
 /* Maximum NTB length */
-#define	CDC_NCM_NTB_MAX_SIZE_TX			(16384 + 4) /* bytes, must be short terminated */
+#define	CDC_NCM_NTB_MAX_SIZE_TX			16384	/* bytes */
 #define	CDC_NCM_NTB_MAX_SIZE_RX			16384	/* bytes */
 
 /* Minimum value for MaxDatagramSize, ch. 6.2.9 */
@@ -722,7 +722,7 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb)
 
 	} else {
 		/* reset variables */
-		skb_out = alloc_skb(ctx->tx_max, GFP_ATOMIC);
+		skb_out = alloc_skb((ctx->tx_max + 1), GFP_ATOMIC);
 		if (skb_out == NULL) {
 			if (skb != NULL) {
 				dev_kfree_skb_any(skb);
@@ -861,8 +861,11 @@ cdc_ncm_fill_tx_frame(struct cdc_ncm_ctx *ctx, struct sk_buff *skb)
 	/* store last offset */
 	last_offset = offset;
 
-	if ((last_offset < ctx->tx_max) && ((last_offset %
-			le16_to_cpu(ctx->out_ep->desc.wMaxPacketSize)) == 0)) {
+	if (((last_offset < ctx->tx_max) && ((last_offset %
+			le16_to_cpu(ctx->out_ep->desc.wMaxPacketSize)) == 0)) ||
+	    (((last_offset == ctx->tx_max) && ((ctx->tx_max %
+		le16_to_cpu(ctx->out_ep->desc.wMaxPacketSize)) == 0)) &&
+		(ctx->tx_max < le32_to_cpu(ctx->ncm_parm.dwNtbOutMaxSize)))) {
 		/* force short packet */
 		*(((u8 *)skb_out->data) + last_offset) = 0;
 		last_offset++;
-- 
1.7.4.3

