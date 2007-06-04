From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/4] b44: tx bounce sizing.
Date: Mon, 04 Jun 2007 13:25:38 -0700
Message-ID: <20070604202712.318911391@linux-foundation.org>
References: <20070604202536.503165465@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Gary Zambrano <zambrano@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:51826 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753733AbXFDUlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2007 16:41:01 -0400
Content-Disposition: inline; filename=b44-tx-bounce-size.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No need to grap full size MTU buffer for possibly small transmit
bounce buffers.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/b44.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

--- a/drivers/net/b44.c	2007-06-04 12:46:54.000000000 -0700
+++ b/drivers/net/b44.c	2007-06-04 12:48:21.000000000 -0700
@@ -69,7 +69,6 @@
 #define NEXT_TX(N)		(((N) + 1) & (B44_TX_RING_SIZE - 1))
 
 #define RX_PKT_BUF_SZ		(1536 + bp->rx_offset + 64)
-#define TX_PKT_BUF_SZ		(B44_MAX_MTU + ETH_HLEN + 8)
 
 /* minimum number of free TX descriptors required to wake up TX process */
 #define B44_TX_WAKEUP_THRESH		(B44_TX_RING_SIZE / 4)
@@ -968,7 +967,6 @@ static void b44_tx_timeout(struct net_de
 static int b44_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct b44 *bp = netdev_priv(dev);
-	struct sk_buff *bounce_skb;
 	int rc = NETDEV_TX_OK;
 	dma_addr_t mapping;
 	u32 len, entry, ctrl;
@@ -986,12 +984,13 @@ static int b44_start_xmit(struct sk_buff
 
 	mapping = pci_map_single(bp->pdev, skb->data, len, PCI_DMA_TODEVICE);
 	if (dma_mapping_error(mapping) || mapping + len > DMA_30BIT_MASK) {
+		struct sk_buff *bounce_skb;
+
 		/* Chip can't handle DMA to/from >1GB, use bounce buffer */
 		if (!dma_mapping_error(mapping))
 			pci_unmap_single(bp->pdev, mapping, len, PCI_DMA_TODEVICE);
 
-		bounce_skb = __dev_alloc_skb(TX_PKT_BUF_SZ,
-					     GFP_ATOMIC|GFP_DMA);
+		bounce_skb = __dev_alloc_skb(len, GFP_ATOMIC | GFP_DMA);
 		if (!bounce_skb)
 			goto err_out;
 
@@ -1000,13 +999,12 @@ static int b44_start_xmit(struct sk_buff
 		if (dma_mapping_error(mapping) || mapping + len > DMA_30BIT_MASK) {
 			if (!dma_mapping_error(mapping))
 				pci_unmap_single(bp->pdev, mapping,
-					 len, PCI_DMA_TODEVICE);
+						 len, PCI_DMA_TODEVICE);
 			dev_kfree_skb_any(bounce_skb);
 			goto err_out;
 		}
 
-		skb_copy_from_linear_data(skb, skb_put(bounce_skb, len),
-					  skb->len);
+		skb_copy_from_linear_data(skb, skb_put(bounce_skb, len), len);
 		dev_kfree_skb_any(skb);
 		skb = bounce_skb;
 	}

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

