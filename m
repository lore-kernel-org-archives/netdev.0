From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 3/4] b44: packet offset is constant
Date: Mon, 04 Jun 2007 13:25:39 -0700
Message-ID: <20070604202712.448439563@linux-foundation.org>
References: <20070604202536.503165465@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Gary Zambrano <zambrano@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48881 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753437AbXFDUkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2007 16:40:51 -0400
Content-Disposition: inline; filename=b44-rx-offset.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The receive buffer offset is constant in this driver.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/b44.c |   29 ++++++++++++-----------------
 drivers/net/b44.h |    2 --
 2 files changed, 12 insertions(+), 19 deletions(-)

Index: lifebook/drivers/net/b44.c
===================================================================
--- lifebook.orig/drivers/net/b44.c	2007-06-04 13:22:12.000000000 -0700
+++ lifebook/drivers/net/b44.c	2007-06-04 13:27:47.000000000 -0700
@@ -15,6 +15,7 @@
 #include <linux/ethtool.h>
 #include <linux/mii.h>
 #include <linux/if_ether.h>
+#include <linux/if_vlan.h>
 #include <linux/etherdevice.h>
 #include <linux/pci.h>
 #include <linux/delay.h>
@@ -68,7 +69,8 @@
 	  (BP)->tx_cons - (BP)->tx_prod - TX_RING_GAP(BP))
 #define NEXT_TX(N)		(((N) + 1) & (B44_TX_RING_SIZE - 1))
 
-#define RX_PKT_BUF_SZ		(1536 + bp->rx_offset + 64)
+#define RX_PKT_OFFSET		30
+#define RX_PKT_BUF_SZ		(1536 + RX_PKT_OFFSET + 64)
 
 /* minimum number of free TX descriptors required to wake up TX process */
 #define B44_TX_WAKEUP_THRESH		(B44_TX_RING_SIZE / 4)
@@ -683,10 +685,9 @@
 	}
 
 	skb->dev = bp->dev;
-	skb_reserve(skb, bp->rx_offset);
+	rh = (struct rx_header *) skb->data;
+	skb_reserve(skb, RX_PKT_OFFSET);
 
-	rh = (struct rx_header *)
-		(skb->data - bp->rx_offset);
 	rh->len = 0;
 	rh->flags = 0;
 
@@ -696,13 +697,13 @@
 	if (src_map != NULL)
 		src_map->skb = NULL;
 
-	ctrl  = (DESC_CTRL_LEN & (RX_PKT_BUF_SZ - bp->rx_offset));
+	ctrl  = (DESC_CTRL_LEN & (RX_PKT_BUF_SZ - RX_PKT_OFFSET));
 	if (dest_idx == (B44_RX_RING_SIZE - 1))
 		ctrl |= DESC_CTRL_EOT;
 
 	dp = &bp->rx_ring[dest_idx];
 	dp->ctrl = cpu_to_le32(ctrl);
-	dp->addr = cpu_to_le32((u32) mapping + bp->rx_offset + bp->dma_offset);
+	dp->addr = cpu_to_le32((u32) mapping + RX_PKT_OFFSET + bp->dma_offset);
 
 	if (bp->flags & B44_FLAG_RX_RING_HACK)
 		b44_sync_dma_desc_for_device(bp->pdev, bp->rx_ring_dma,
@@ -781,7 +782,7 @@
 					    PCI_DMA_FROMDEVICE);
 		rh = (struct rx_header *) skb->data;
 		len = le16_to_cpu(rh->len);
-		if ((len > (RX_PKT_BUF_SZ - bp->rx_offset)) ||
+		if ((len > (RX_PKT_BUF_SZ - RX_PKT_OFFSET)) ||
 		    (rh->flags & cpu_to_le16(RX_FLAG_ERRORS))) {
 		drop_it:
 			b44_recycle_rx(bp, cons, bp->rx_prod);
@@ -813,8 +814,8 @@
 			pci_unmap_single(bp->pdev, map,
 					 skb_size, PCI_DMA_FROMDEVICE);
 			/* Leave out rx_header */
-                	skb_put(skb, len+bp->rx_offset);
-            	        skb_pull(skb,bp->rx_offset);
+                	skb_put(skb, len + RX_PKT_OFFSET);
+            	        skb_pull(skb, RX_PKT_OFFSET);
 		} else {
 			struct sk_buff *copy_skb;
 
@@ -826,7 +827,7 @@
 			skb_reserve(copy_skb, 2);
 			skb_put(copy_skb, len);
 			/* DMA sync done above, copy just the actual packet */
-			skb_copy_from_linear_data_offset(skb, bp->rx_offset,
+			skb_copy_from_linear_data_offset(skb, RX_PKT_OFFSET,
 							 copy_skb->data, len);
 			skb = copy_skb;
 		}
@@ -1393,12 +1394,12 @@
 	bw32(bp, B44_TX_WMARK, 56); /* XXX magic */
 	if (reset_kind == B44_PARTIAL_RESET) {
 		bw32(bp, B44_DMARX_CTRL, (DMARX_CTRL_ENABLE |
-				      (bp->rx_offset << DMARX_CTRL_ROSHIFT)));
+				      (RX_PKT_OFFSET << DMARX_CTRL_ROSHIFT)));
 	} else {
 		bw32(bp, B44_DMATX_CTRL, DMATX_CTRL_ENABLE);
 		bw32(bp, B44_DMATX_ADDR, bp->tx_ring_dma + bp->dma_offset);
 		bw32(bp, B44_DMARX_CTRL, (DMARX_CTRL_ENABLE |
-				      (bp->rx_offset << DMARX_CTRL_ROSHIFT)));
+				      (RX_PKT_OFFSET << DMARX_CTRL_ROSHIFT)));
 		bw32(bp, B44_DMARX_ADDR, bp->rx_ring_dma + bp->dma_offset);
 
 		bw32(bp, B44_DMARX_PTR, bp->rx_pending);
@@ -2090,11 +2091,6 @@
 
 	bp->phy_addr = eeprom[90] & 0x1f;
 
-	/* With this, plus the rx_header prepended to the data by the
-	 * hardware, we'll land the ethernet header on a 2-byte boundary.
-	 */
-	bp->rx_offset = 30;
-
 	bp->imask = IMASK_DEF;
 
 	bp->core_unit = ssb_core_unit(bp);
Index: lifebook/drivers/net/b44.h
===================================================================
--- lifebook.orig/drivers/net/b44.h	2007-06-04 13:18:25.000000000 -0700
+++ lifebook/drivers/net/b44.h	2007-06-04 13:22:15.000000000 -0700
@@ -443,8 +443,6 @@
 #define B44_FLAG_TX_RING_HACK	0x40000000
 #define B44_FLAG_WOL_ENABLE	0x80000000
 
-	u32			rx_offset;
-
 	u32			msg_enable;
 
 	struct timer_list	timer;

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

