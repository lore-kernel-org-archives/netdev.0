From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH] myri10ge: use the DMA state API instead of the pci equivalents
Date: Tue, 13 Apr 2010 09:32:10 +0900
Message-ID: <1271118734-28353-2-git-send-email-fujita.tomonori@lab.ntt.co.jp>
References: <1271118734-28353-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Cc: fujita.tomonori@lab.ntt.co.jp, Andrew Gallatin <gallatin@myri.com>,
	Brice Goglin <brice@myri.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:38875 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754471Ab0DMAeT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 20:34:19 -0400
In-Reply-To: <1271118734-28353-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This replace the PCI DMA state API (include/linux/pci-dma.h) with the
DMA equivalents since the PCI DMA state API will be obsolete.

No functional change.

For further information about the background:

http://marc.info/?l=linux-netdev&m=127037540020276&w=2

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: Andrew Gallatin <gallatin@myri.com>
Cc: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |   44 +++++++++++++++++++-------------------
 1 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 72b4b19..958dc28 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -110,15 +110,15 @@ MODULE_LICENSE("Dual BSD/GPL");
 struct myri10ge_rx_buffer_state {
 	struct page *page;
 	int page_offset;
-	 DECLARE_PCI_UNMAP_ADDR(bus)
-	 DECLARE_PCI_UNMAP_LEN(len)
+	DEFINE_DMA_UNMAP_ADDR(bus);
+	DEFINE_DMA_UNMAP_LEN(len);
 };
 
 struct myri10ge_tx_buffer_state {
 	struct sk_buff *skb;
 	int last;
-	 DECLARE_PCI_UNMAP_ADDR(bus)
-	 DECLARE_PCI_UNMAP_LEN(len)
+	DEFINE_DMA_UNMAP_ADDR(bus);
+	DEFINE_DMA_UNMAP_LEN(len);
 };
 
 struct myri10ge_cmd {
@@ -1234,7 +1234,7 @@ myri10ge_alloc_rx_pages(struct myri10ge_priv *mgp, struct myri10ge_rx_buf *rx,
 		rx->info[idx].page_offset = rx->page_offset;
 		/* note that this is the address of the start of the
 		 * page */
-		pci_unmap_addr_set(&rx->info[idx], bus, rx->bus);
+		dma_unmap_addr_set(&rx->info[idx], bus, rx->bus);
 		rx->shadow[idx].addr_low =
 		    htonl(MYRI10GE_LOWPART_TO_U32(rx->bus) + rx->page_offset);
 		rx->shadow[idx].addr_high =
@@ -1266,7 +1266,7 @@ myri10ge_unmap_rx_page(struct pci_dev *pdev,
 	/* unmap the recvd page if we're the only or last user of it */
 	if (bytes >= MYRI10GE_ALLOC_SIZE / 2 ||
 	    (info->page_offset + 2 * bytes) > MYRI10GE_ALLOC_SIZE) {
-		pci_unmap_page(pdev, (pci_unmap_addr(info, bus)
+		pci_unmap_page(pdev, (dma_unmap_addr(info, bus)
 				      & ~(MYRI10GE_ALLOC_SIZE - 1)),
 			       MYRI10GE_ALLOC_SIZE, PCI_DMA_FROMDEVICE);
 	}
@@ -1373,21 +1373,21 @@ myri10ge_tx_done(struct myri10ge_slice_state *ss, int mcp_index)
 			tx->info[idx].last = 0;
 		}
 		tx->done++;
-		len = pci_unmap_len(&tx->info[idx], len);
-		pci_unmap_len_set(&tx->info[idx], len, 0);
+		len = dma_unmap_len(&tx->info[idx], len);
+		dma_unmap_len_set(&tx->info[idx], len, 0);
 		if (skb) {
 			ss->stats.tx_bytes += skb->len;
 			ss->stats.tx_packets++;
 			dev_kfree_skb_irq(skb);
 			if (len)
 				pci_unmap_single(pdev,
-						 pci_unmap_addr(&tx->info[idx],
+						 dma_unmap_addr(&tx->info[idx],
 								bus), len,
 						 PCI_DMA_TODEVICE);
 		} else {
 			if (len)
 				pci_unmap_page(pdev,
-					       pci_unmap_addr(&tx->info[idx],
+					       dma_unmap_addr(&tx->info[idx],
 							      bus), len,
 					       PCI_DMA_TODEVICE);
 		}
@@ -2094,20 +2094,20 @@ static void myri10ge_free_rings(struct myri10ge_slice_state *ss)
 		/* Mark as free */
 		tx->info[idx].skb = NULL;
 		tx->done++;
-		len = pci_unmap_len(&tx->info[idx], len);
-		pci_unmap_len_set(&tx->info[idx], len, 0);
+		len = dma_unmap_len(&tx->info[idx], len);
+		dma_unmap_len_set(&tx->info[idx], len, 0);
 		if (skb) {
 			ss->stats.tx_dropped++;
 			dev_kfree_skb_any(skb);
 			if (len)
 				pci_unmap_single(mgp->pdev,
-						 pci_unmap_addr(&tx->info[idx],
+						 dma_unmap_addr(&tx->info[idx],
 								bus), len,
 						 PCI_DMA_TODEVICE);
 		} else {
 			if (len)
 				pci_unmap_page(mgp->pdev,
-					       pci_unmap_addr(&tx->info[idx],
+					       dma_unmap_addr(&tx->info[idx],
 							      bus), len,
 					       PCI_DMA_TODEVICE);
 		}
@@ -2761,8 +2761,8 @@ again:
 	idx = tx->req & tx->mask;
 	tx->info[idx].skb = skb;
 	bus = pci_map_single(mgp->pdev, skb->data, len, PCI_DMA_TODEVICE);
-	pci_unmap_addr_set(&tx->info[idx], bus, bus);
-	pci_unmap_len_set(&tx->info[idx], len, len);
+	dma_unmap_addr_set(&tx->info[idx], bus, bus);
+	dma_unmap_len_set(&tx->info[idx], len, len);
 
 	frag_cnt = skb_shinfo(skb)->nr_frags;
 	frag_idx = 0;
@@ -2865,8 +2865,8 @@ again:
 		len = frag->size;
 		bus = pci_map_page(mgp->pdev, frag->page, frag->page_offset,
 				   len, PCI_DMA_TODEVICE);
-		pci_unmap_addr_set(&tx->info[idx], bus, bus);
-		pci_unmap_len_set(&tx->info[idx], len, len);
+		dma_unmap_addr_set(&tx->info[idx], bus, bus);
+		dma_unmap_len_set(&tx->info[idx], len, len);
 	}
 
 	(req - rdma_count)->rdma_count = rdma_count;
@@ -2903,19 +2903,19 @@ abort_linearize:
 	idx = tx->req & tx->mask;
 	tx->info[idx].skb = NULL;
 	do {
-		len = pci_unmap_len(&tx->info[idx], len);
+		len = dma_unmap_len(&tx->info[idx], len);
 		if (len) {
 			if (tx->info[idx].skb != NULL)
 				pci_unmap_single(mgp->pdev,
-						 pci_unmap_addr(&tx->info[idx],
+						 dma_unmap_addr(&tx->info[idx],
 								bus), len,
 						 PCI_DMA_TODEVICE);
 			else
 				pci_unmap_page(mgp->pdev,
-					       pci_unmap_addr(&tx->info[idx],
+					       dma_unmap_addr(&tx->info[idx],
 							      bus), len,
 					       PCI_DMA_TODEVICE);
-			pci_unmap_len_set(&tx->info[idx], len, 0);
+			dma_unmap_len_set(&tx->info[idx], len, 0);
 			tx->info[idx].skb = NULL;
 		}
 		idx = (idx + 1) & tx->mask;
-- 
1.6.5

