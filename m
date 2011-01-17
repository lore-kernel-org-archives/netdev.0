From: Alexey Orishko <alexey.orishko@gmail.com>
Subject: [PATCHv2] USB CDC NCM: tx_fixup() race condition fix
Date: Mon, 17 Jan 2011 18:07:25 +0100
Message-ID: <1295284045-9310-1-git-send-email-alexey.orishko@stericsson.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net, gregkh@suse.de,
	yauheni.kaliuta@nokia.com,
	Alexey Orishko <alexey.orishko@stericsson.com>
To: linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:35525 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753332Ab1AQRIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jan 2011 12:08:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- tx_fixup() can be called from either timer callback or from xmit()
  in usbnet, so spinlock is added to avoid concurrency-related problem.
- minor correction due to checkpatch warning for some line over 80
  chars after previous patch was applied.

Signed-off-by: Alexey Orishko <alexey.orishko@stericsson.com>
---
 drivers/net/usb/cdc_ncm.c |   19 ++++++++++++-------
 1 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index d776c4a..04e8ce1 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -54,7 +54,7 @@
 #include <linux/usb/usbnet.h>
 #include <linux/usb/cdc.h>
 
-#define	DRIVER_VERSION				"30-Nov-2010"
+#define	DRIVER_VERSION				"17-Jan-2011"
 
 /* CDC NCM subclass 3.2.1 */
 #define USB_CDC_NCM_NDP16_LENGTH_MIN		0x10
@@ -868,15 +868,19 @@ static void cdc_ncm_tx_timeout(unsigned long arg)
 	if (ctx->tx_timer_pending != 0) {
 		ctx->tx_timer_pending--;
 		restart = 1;
-	} else
+	} else {
 		restart = 0;
+	}
 
 	spin_unlock(&ctx->mtx);
 
-	if (restart)
+	if (restart) {
+		spin_lock(&ctx->mtx);
 		cdc_ncm_tx_timeout_start(ctx);
-	else if (ctx->netdev != NULL)
+		spin_unlock(&ctx->mtx);
+	} else if (ctx->netdev != NULL) {
 		usbnet_start_xmit(NULL, ctx->netdev);
+	}
 }
 
 static struct sk_buff *
@@ -900,7 +904,6 @@ cdc_ncm_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
 	skb_out = cdc_ncm_fill_tx_frame(ctx, skb);
 	if (ctx->tx_curr_skb != NULL)
 		need_timer = 1;
-	spin_unlock(&ctx->mtx);
 
 	/* Start timer, if there is a remaining skb */
 	if (need_timer)
@@ -908,6 +911,8 @@ cdc_ncm_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
 
 	if (skb_out)
 		dev->net->stats.tx_packets += ctx->tx_curr_frame_num;
+
+	spin_unlock(&ctx->mtx);
 	return skb_out;
 
 error:
@@ -1020,8 +1025,8 @@ static int cdc_ncm_rx_fixup(struct usbnet *dev, struct sk_buff *skb_in)
 		if (((offset + temp) > actlen) ||
 		    (temp > CDC_NCM_MAX_DATAGRAM_SIZE) || (temp < ETH_HLEN)) {
 			pr_debug("invalid frame detected (ignored)"
-				"offset[%u]=%u, length=%u, skb=%p\n",
-							x, offset, temp, skb_in);
+					"offset[%u]=%u, length=%u, skb=%p\n",
+					x, offset, temp, skb_in);
 			if (!x)
 				goto error;
 			break;
-- 
1.7.0.4

