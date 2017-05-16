From: Jim Baxter <jim_baxter-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
Subject: [RFC V1 1/1] net: cdc_ncm: Reduce memory use when kernel memory low
Date: Tue, 16 May 2017 18:41:20 +0100
Message-ID: <1494956480-6127-2-git-send-email-jim_baxter@mentor.com>
References: <1494956480-6127-1-git-send-email-jim_baxter@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jim_baxter-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
To: <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1494956480-6127-1-git-send-email-jim_baxter-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The CDC-NCM driver can require large amounts of memory to create
skb's and this can be a problem when the memory becomes fragmented.

This especially affects embedded systems that have constrained
resources but wish to maximise the throughput of CDC-NCM with 16KiB
NTB's.

The issue is after running for a while the kernel memory can become
fragmented and it needs compacting.
If the NTB allocation is needed before the memory has been compacted
the atomic allocation can fail which can cause increased latency,
large re-transmissions or disconnections depending upon the data
being transmitted at the time.
This situation occurs for less than a second until the kernel has
compacted the memory but the failed devices can take a lot longer to
recover from the failed TX packets.

To ease this temporary situation I modified the CDC-NCM TX path to
temporarily switch into a reduced memory mode which allocates an NTB
that will fit into a USB_CDC_NCM_NTB_MIN_OUT_SIZE (default 2048 Bytes)
sized memory block and only transmit NTB's with a single network frame
until the memory situation is resolved.
Once the memory is compacted the CDC-NCM data can resume transmitting
at the normal tx_max rate once again.

Signed-off-by: Jim Baxter <jim_baxter-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c   | 39 +++++++++++++++++++++++++++------------
 include/linux/usb/cdc_ncm.h |  1 +
 2 files changed, 28 insertions(+), 12 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index b5cec18..c06d20f 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1055,10 +1055,10 @@ static struct usb_cdc_ncm_ndp16 *cdc_ncm_ndp(struct cdc_ncm_ctx *ctx, struct sk_
 
 	/* align new NDP */
 	if (!(ctx->drvflags & CDC_NCM_FLAG_NDP_TO_END))
-		cdc_ncm_align_tail(skb, ctx->tx_ndp_modulus, 0, ctx->tx_max);
+		cdc_ncm_align_tail(skb, ctx->tx_ndp_modulus, 0, ctx->tx_curr_size);
 
 	/* verify that there is room for the NDP and the datagram (reserve) */
-	if ((ctx->tx_max - skb->len - reserve) < ctx->max_ndp_size)
+	if ((ctx->tx_curr_size - skb->len - reserve) < ctx->max_ndp_size)
 		return NULL;
 
 	/* link to it */
@@ -1111,13 +1111,28 @@ struct sk_buff *
 
 	/* allocate a new OUT skb */
 	if (!skb_out) {
-		skb_out = alloc_skb(ctx->tx_max, GFP_ATOMIC);
+		ctx->tx_curr_size = ctx->tx_max;
+		skb_out = alloc_skb(ctx->tx_curr_size, GFP_ATOMIC);
 		if (skb_out == NULL) {
-			if (skb != NULL) {
-				dev_kfree_skb_any(skb);
-				dev->net->stats.tx_dropped++;
+			/* See if a very small allocation is possible.
+			 * We will send this packet immediately and hope
+			 * that there is more memory available later.
+			 */
+			if (skb)
+				ctx->tx_curr_size = max(skb->len,
+					(u32)USB_CDC_NCM_NTB_MIN_OUT_SIZE);
+			else
+				ctx->tx_curr_size = USB_CDC_NCM_NTB_MIN_OUT_SIZE;
+			skb_out = alloc_skb(ctx->tx_curr_size, GFP_ATOMIC);
+
+			/* No allocation possible so we will abort */
+			if (skb_out == NULL) {
+				if (skb != NULL) {
+					dev_kfree_skb_any(skb);
+					dev->net->stats.tx_dropped++;
+				}
+				goto exit_no_skb;
 			}
-			goto exit_no_skb;
 		}
 		/* fill out the initial 16-bit NTB header */
 		nth16 = (struct usb_cdc_ncm_nth16 *)memset(skb_put(skb_out, sizeof(struct usb_cdc_ncm_nth16)), 0, sizeof(struct usb_cdc_ncm_nth16));
@@ -1148,10 +1163,10 @@ struct sk_buff *
 		ndp16 = cdc_ncm_ndp(ctx, skb_out, sign, skb->len + ctx->tx_modulus + ctx->tx_remainder);
 
 		/* align beginning of next frame */
-		cdc_ncm_align_tail(skb_out,  ctx->tx_modulus, ctx->tx_remainder, ctx->tx_max);
+		cdc_ncm_align_tail(skb_out,  ctx->tx_modulus, ctx->tx_remainder, ctx->tx_curr_size);
 
 		/* check if we had enough room left for both NDP and frame */
-		if (!ndp16 || skb_out->len + skb->len + delayed_ndp_size > ctx->tx_max) {
+		if (!ndp16 || skb_out->len + skb->len + delayed_ndp_size > ctx->tx_curr_size) {
 			if (n == 0) {
 				/* won't fit, MTU problem? */
 				dev_kfree_skb_any(skb);
@@ -1227,7 +1242,7 @@ struct sk_buff *
 	/* If requested, put NDP at end of frame. */
 	if (ctx->drvflags & CDC_NCM_FLAG_NDP_TO_END) {
 		nth16 = (struct usb_cdc_ncm_nth16 *)skb_out->data;
-		cdc_ncm_align_tail(skb_out, ctx->tx_ndp_modulus, 0, ctx->tx_max);
+		cdc_ncm_align_tail(skb_out, ctx->tx_ndp_modulus, 0, ctx->tx_curr_size);
 		nth16->wNdpIndex = cpu_to_le16(skb_out->len);
 		memcpy(skb_put(skb_out, ctx->max_ndp_size), ctx->delayed_ndp16, ctx->max_ndp_size);
 
@@ -1246,9 +1261,9 @@ struct sk_buff *
 	 */
 	if (!(dev->driver_info->flags & FLAG_SEND_ZLP) &&
 	    skb_out->len > ctx->min_tx_pkt) {
-		padding_count = ctx->tx_max - skb_out->len;
+		padding_count = ctx->tx_curr_size - skb_out->len;
 		memset(skb_put(skb_out, padding_count), 0, padding_count);
-	} else if (skb_out->len < ctx->tx_max &&
+	} else if (skb_out->len < ctx->tx_curr_size &&
 		   (skb_out->len % dev->maxpacket) == 0) {
 		*skb_put(skb_out, 1) = 0;	/* force short packet */
 	}
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index 00d2324..5162f38 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -117,6 +117,7 @@ struct cdc_ncm_ctx {
 	u32 tx_curr_frame_num;
 	u32 rx_max;
 	u32 tx_max;
+	u32 tx_curr_size;
 	u32 max_datagram_size;
 	u16 tx_max_datagrams;
 	u16 tx_remainder;
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
