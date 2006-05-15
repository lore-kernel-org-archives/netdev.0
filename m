From: "Andi Kleen" <ak@suse.de>
Subject: [PATCH for 2.6.17] [1/5] x86_64: Check for bad dma address in b44 1GB DMA workaround
Date: Mon, 15 May 2006 18:19:35 +0200
Message-ID: <4468AA17.mail5UX1TLS4A@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:64200 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S932146AbWEOQTh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 12:19:37 -0400
To: torvalds@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Needed for interaction with the nommu code in x86-64 which
will return bad_dma_address if the address exceeds dma_mask.

Cc: netdev@vger.kernel.org

Signed-off-by: Andi Kleen <ak@suse.de>

---
 drivers/net/b44.c |   28 ++++++++++++++++++----------
 1 files changed, 18 insertions(+), 10 deletions(-)

Index: linux/drivers/net/b44.c
===================================================================
--- linux.orig/drivers/net/b44.c
+++ linux/drivers/net/b44.c
@@ -650,9 +650,11 @@ static int b44_alloc_rx_skb(struct b44 *
 
 	/* Hardware bug work-around, the chip is unable to do PCI DMA
 	   to/from anything above 1GB :-( */
-	if (mapping + RX_PKT_BUF_SZ > B44_DMA_MASK) {
+	if (dma_mapping_error(mapping) ||
+		mapping + RX_PKT_BUF_SZ > B44_DMA_MASK) {
 		/* Sigh... */
-		pci_unmap_single(bp->pdev, mapping, RX_PKT_BUF_SZ,PCI_DMA_FROMDEVICE);
+		if (!dma_mapping_error(mapping))
+			pci_unmap_single(bp->pdev, mapping, RX_PKT_BUF_SZ,PCI_DMA_FROMDEVICE);
 		dev_kfree_skb_any(skb);
 		skb = __dev_alloc_skb(RX_PKT_BUF_SZ,GFP_DMA);
 		if (skb == NULL)
@@ -660,8 +662,10 @@ static int b44_alloc_rx_skb(struct b44 *
 		mapping = pci_map_single(bp->pdev, skb->data,
 					 RX_PKT_BUF_SZ,
 					 PCI_DMA_FROMDEVICE);
-		if (mapping + RX_PKT_BUF_SZ > B44_DMA_MASK) {
-			pci_unmap_single(bp->pdev, mapping, RX_PKT_BUF_SZ,PCI_DMA_FROMDEVICE);
+		if (dma_mapping_error(mapping) ||
+			mapping + RX_PKT_BUF_SZ > B44_DMA_MASK) {
+			if (!dma_mapping_error(mapping))
+				pci_unmap_single(bp->pdev, mapping, RX_PKT_BUF_SZ,PCI_DMA_FROMDEVICE);
 			dev_kfree_skb_any(skb);
 			return -ENOMEM;
 		}
@@ -967,9 +971,10 @@ static int b44_start_xmit(struct sk_buff
 	}
 
 	mapping = pci_map_single(bp->pdev, skb->data, len, PCI_DMA_TODEVICE);
-	if (mapping + len > B44_DMA_MASK) {
+	if (dma_mapping_error(mapping) || mapping + len > B44_DMA_MASK) {
 		/* Chip can't handle DMA to/from >1GB, use bounce buffer */
-		pci_unmap_single(bp->pdev, mapping, len, PCI_DMA_TODEVICE);
+		if (!dma_mapping_error(mapping))
+			pci_unmap_single(bp->pdev, mapping, len, PCI_DMA_TODEVICE);
 
 		bounce_skb = __dev_alloc_skb(TX_PKT_BUF_SZ,
 					     GFP_ATOMIC|GFP_DMA);
@@ -978,8 +983,9 @@ static int b44_start_xmit(struct sk_buff
 
 		mapping = pci_map_single(bp->pdev, bounce_skb->data,
 					 len, PCI_DMA_TODEVICE);
-		if (mapping + len > B44_DMA_MASK) {
-			pci_unmap_single(bp->pdev, mapping,
+		if (dma_mapping_error(mapping) || mapping + len > B44_DMA_MASK) {
+			if (!dma_mapping_error(mapping))
+				pci_unmap_single(bp->pdev, mapping,
 					 len, PCI_DMA_TODEVICE);
 			dev_kfree_skb_any(bounce_skb);
 			goto err_out;
@@ -1203,7 +1209,8 @@ static int b44_alloc_consistent(struct b
 		                             DMA_TABLE_BYTES,
 		                             DMA_BIDIRECTIONAL);
 
-		if (rx_ring_dma + size > B44_DMA_MASK) {
+		if (dma_mapping_error(rx_ring_dma) ||
+			rx_ring_dma + size > B44_DMA_MASK) {
 			kfree(rx_ring);
 			goto out_err;
 		}
@@ -1229,7 +1236,8 @@ static int b44_alloc_consistent(struct b
 		                             DMA_TABLE_BYTES,
 		                             DMA_TO_DEVICE);
 
-		if (tx_ring_dma + size > B44_DMA_MASK) {
+		if (dma_mapping_error(tx_ring_dma) ||
+			tx_ring_dma + size > B44_DMA_MASK) {
 			kfree(tx_ring);
 			goto out_err;
 		}
