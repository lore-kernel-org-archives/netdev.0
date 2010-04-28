From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH] skge: use the DMA state API instead of the pci equivalents
Date: Wed, 28 Apr 2010 09:57:04 +0900
Message-ID: <20100428095730K.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:57309 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755116Ab0D1A5U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Apr 2010 20:57:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This replace the PCI DMA state API (include/linux/pci-dma.h) with the
DMA equivalents since the PCI DMA state API will be obsolete.

No functional change.

For further information about the background:

http://marc.info/?l=linux-netdev&m=127037540020276&w=2

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 drivers/net/skge.c |   32 ++++++++++++++++----------------
 drivers/net/skge.h |    4 ++--
 2 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 96eee86..40e5c46 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -984,8 +984,8 @@ static void skge_rx_setup(struct skge_port *skge, struct skge_element *e,
 	wmb();
 
 	rd->control = BMU_OWN | BMU_STF | BMU_IRQ_EOF | BMU_TCP_CHECK | bufsize;
-	pci_unmap_addr_set(e, mapaddr, map);
-	pci_unmap_len_set(e, maplen, bufsize);
+	dma_unmap_addr_set(e, mapaddr, map);
+	dma_unmap_len_set(e, maplen, bufsize);
 }
 
 /* Resume receiving using existing skb,
@@ -1018,8 +1018,8 @@ static void skge_rx_clean(struct skge_port *skge)
 		rd->control = 0;
 		if (e->skb) {
 			pci_unmap_single(hw->pdev,
-					 pci_unmap_addr(e, mapaddr),
-					 pci_unmap_len(e, maplen),
+					 dma_unmap_addr(e, mapaddr),
+					 dma_unmap_len(e, maplen),
 					 PCI_DMA_FROMDEVICE);
 			dev_kfree_skb(e->skb);
 			e->skb = NULL;
@@ -2756,8 +2756,8 @@ static netdev_tx_t skge_xmit_frame(struct sk_buff *skb,
 	e->skb = skb;
 	len = skb_headlen(skb);
 	map = pci_map_single(hw->pdev, skb->data, len, PCI_DMA_TODEVICE);
-	pci_unmap_addr_set(e, mapaddr, map);
-	pci_unmap_len_set(e, maplen, len);
+	dma_unmap_addr_set(e, mapaddr, map);
+	dma_unmap_len_set(e, maplen, len);
 
 	td->dma_lo = map;
 	td->dma_hi = map >> 32;
@@ -2799,8 +2799,8 @@ static netdev_tx_t skge_xmit_frame(struct sk_buff *skb,
 
 			tf->dma_lo = map;
 			tf->dma_hi = (u64) map >> 32;
-			pci_unmap_addr_set(e, mapaddr, map);
-			pci_unmap_len_set(e, maplen, frag->size);
+			dma_unmap_addr_set(e, mapaddr, map);
+			dma_unmap_len_set(e, maplen, frag->size);
 
 			tf->control = BMU_OWN | BMU_SW | control | frag->size;
 		}
@@ -2837,12 +2837,12 @@ static void skge_tx_free(struct skge_port *skge, struct skge_element *e,
 
 	/* skb header vs. fragment */
 	if (control & BMU_STF)
-		pci_unmap_single(pdev, pci_unmap_addr(e, mapaddr),
-				 pci_unmap_len(e, maplen),
+		pci_unmap_single(pdev, dma_unmap_addr(e, mapaddr),
+				 dma_unmap_len(e, maplen),
 				 PCI_DMA_TODEVICE);
 	else
-		pci_unmap_page(pdev, pci_unmap_addr(e, mapaddr),
-			       pci_unmap_len(e, maplen),
+		pci_unmap_page(pdev, dma_unmap_addr(e, mapaddr),
+			       dma_unmap_len(e, maplen),
 			       PCI_DMA_TODEVICE);
 
 	if (control & BMU_EOF) {
@@ -3060,11 +3060,11 @@ static struct sk_buff *skge_rx_get(struct net_device *dev,
 			goto resubmit;
 
 		pci_dma_sync_single_for_cpu(skge->hw->pdev,
-					    pci_unmap_addr(e, mapaddr),
+					    dma_unmap_addr(e, mapaddr),
 					    len, PCI_DMA_FROMDEVICE);
 		skb_copy_from_linear_data(e->skb, skb->data, len);
 		pci_dma_sync_single_for_device(skge->hw->pdev,
-					       pci_unmap_addr(e, mapaddr),
+					       dma_unmap_addr(e, mapaddr),
 					       len, PCI_DMA_FROMDEVICE);
 		skge_rx_reuse(e, skge->rx_buf_size);
 	} else {
@@ -3075,8 +3075,8 @@ static struct sk_buff *skge_rx_get(struct net_device *dev,
 			goto resubmit;
 
 		pci_unmap_single(skge->hw->pdev,
-				 pci_unmap_addr(e, mapaddr),
-				 pci_unmap_len(e, maplen),
+				 dma_unmap_addr(e, mapaddr),
+				 dma_unmap_len(e, maplen),
 				 PCI_DMA_FROMDEVICE);
 		skb = e->skb;
 		prefetch(skb->data);
diff --git a/drivers/net/skge.h b/drivers/net/skge.h
index 831de1b..507addc 100644
--- a/drivers/net/skge.h
+++ b/drivers/net/skge.h
@@ -2393,8 +2393,8 @@ struct skge_element {
 	struct skge_element	*next;
 	void			*desc;
 	struct sk_buff  	*skb;
-	DECLARE_PCI_UNMAP_ADDR(mapaddr);
-	DECLARE_PCI_UNMAP_LEN(maplen);
+	DEFINE_DMA_UNMAP_ADDR(mapaddr);
+	DEFINE_DMA_UNMAP_LEN(maplen);
 };
 
 struct skge_ring {
-- 
1.6.5

