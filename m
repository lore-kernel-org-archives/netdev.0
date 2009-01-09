From: Felix Fietkau <nbd@openwrt.org>
Subject: [PATCH v2] b44: fix misalignment and wasted space in rx handling
Date: Fri, 09 Jan 2009 13:39:57 +0100
Message-ID: <4967459D.3070207@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([88.198.39.176]:54226 "EHLO ds10.mine.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752534AbZAIMkA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 07:40:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Broadcom 4400 puts a header of configurable size (apparently needs
to be at least 28 bytes) in front of received packets. When handling
this, the previous code accidentally added the offset 30 *twice* for
the software and once for the hardware, thereby cancelling out the
IP alignment effect of the 30 byte padding and wasting an additional
30 bytes of memory per packet.

This patch fixes this problem and improves routing throughput by
about 30% on MIPS, where unaligned access is expensive.

Signed-off-by: Felix Fietkau <nbd@openwrt.org>
---
Sorry about the line wrapping in the previous mail. Should be fixed now

--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -73,8 +73,8 @@
 	  (BP)->tx_cons - (BP)->tx_prod - TX_RING_GAP(BP))
 #define NEXT_TX(N)		(((N) + 1) & (B44_TX_RING_SIZE - 1))
 
-#define RX_PKT_OFFSET		30
-#define RX_PKT_BUF_SZ		(1536 + RX_PKT_OFFSET + 64)
+#define RX_PKT_OFFSET		(RX_HEADER_LEN + 2)
+#define RX_PKT_BUF_SZ		(1536 + RX_PKT_OFFSET)
 
 /* minimum number of free TX descriptors required to wake up TX process */
 #define B44_TX_WAKEUP_THRESH		(B44_TX_RING_SIZE / 4)
@@ -682,7 +682,6 @@ static int b44_alloc_rx_skb(struct b44 *
 	}
 
 	rh = (struct rx_header *) skb->data;
-	skb_reserve(skb, RX_PKT_OFFSET);
 
 	rh->len = 0;
 	rh->flags = 0;
@@ -693,13 +692,13 @@ static int b44_alloc_rx_skb(struct b44 *
 	if (src_map != NULL)
 		src_map->skb = NULL;
 
-	ctrl  = (DESC_CTRL_LEN & (RX_PKT_BUF_SZ - RX_PKT_OFFSET));
+	ctrl = (DESC_CTRL_LEN & RX_PKT_BUF_SZ);
 	if (dest_idx == (B44_RX_RING_SIZE - 1))
 		ctrl |= DESC_CTRL_EOT;
 
 	dp = &bp->rx_ring[dest_idx];
 	dp->ctrl = cpu_to_le32(ctrl);
-	dp->addr = cpu_to_le32((u32) mapping + RX_PKT_OFFSET + bp->dma_offset);
+	dp->addr = cpu_to_le32((u32) mapping + bp->dma_offset);
 
 	if (bp->flags & B44_FLAG_RX_RING_HACK)
 		b44_sync_dma_desc_for_device(bp->sdev, bp->rx_ring_dma,
@@ -809,8 +808,8 @@ static int b44_rx(struct b44 *bp, int bu
 			ssb_dma_unmap_single(bp->sdev, map,
 					     skb_size, DMA_FROM_DEVICE);
 			/* Leave out rx_header */
-                	skb_put(skb, len + RX_PKT_OFFSET);
-            	        skb_pull(skb, RX_PKT_OFFSET);
+			skb_put(skb, len + RX_PKT_OFFSET);
+			skb_pull(skb, RX_PKT_OFFSET);
 		} else {
 			struct sk_buff *copy_skb;
 
