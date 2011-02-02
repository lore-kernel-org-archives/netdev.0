From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH] bna: use device model DMA API
Date: Wed,  2 Feb 2011 15:37:02 +0100
Message-ID: <1296657422-13537-1-git-send-email-ivecera@redhat.com>
Cc: rmody@brocade.com, ddutt@brocade.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12854 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753285Ab1BBOhI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Feb 2011 09:37:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use DMA API as PCI equivalents will be deprecated.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/bna/bnad.c |  108 +++++++++++++++++++++++++-----------------------
 drivers/net/bna/bnad.h |    2 +-
 2 files changed, 57 insertions(+), 53 deletions(-)

diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index fad9126..9f356d5 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -126,22 +126,22 @@ bnad_free_all_txbufs(struct bnad *bnad,
 		}
 		unmap_array[unmap_cons].skb = NULL;
 
-		pci_unmap_single(bnad->pcidev,
-				 pci_unmap_addr(&unmap_array[unmap_cons],
+		dma_unmap_single(&bnad->pcidev->dev,
+				 dma_unmap_addr(&unmap_array[unmap_cons],
 						dma_addr), skb_headlen(skb),
-						PCI_DMA_TODEVICE);
+						DMA_TO_DEVICE);
 
-		pci_unmap_addr_set(&unmap_array[unmap_cons], dma_addr, 0);
+		dma_unmap_addr_set(&unmap_array[unmap_cons], dma_addr, 0);
 		if (++unmap_cons >= unmap_q->q_depth)
 			break;
 
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-			pci_unmap_page(bnad->pcidev,
-				       pci_unmap_addr(&unmap_array[unmap_cons],
+			dma_unmap_page(&bnad->pcidev->dev,
+				       dma_unmap_addr(&unmap_array[unmap_cons],
 						      dma_addr),
 				       skb_shinfo(skb)->frags[i].size,
-				       PCI_DMA_TODEVICE);
-			pci_unmap_addr_set(&unmap_array[unmap_cons], dma_addr,
+				       DMA_TO_DEVICE);
+			dma_unmap_addr_set(&unmap_array[unmap_cons], dma_addr,
 					   0);
 			if (++unmap_cons >= unmap_q->q_depth)
 				break;
@@ -199,23 +199,23 @@ bnad_free_txbufs(struct bnad *bnad,
 		sent_bytes += skb->len;
 		wis -= BNA_TXQ_WI_NEEDED(1 + skb_shinfo(skb)->nr_frags);
 
-		pci_unmap_single(bnad->pcidev,
-				 pci_unmap_addr(&unmap_array[unmap_cons],
+		dma_unmap_single(&bnad->pcidev->dev,
+				 dma_unmap_addr(&unmap_array[unmap_cons],
 						dma_addr), skb_headlen(skb),
-				 PCI_DMA_TODEVICE);
-		pci_unmap_addr_set(&unmap_array[unmap_cons], dma_addr, 0);
+				 DMA_TO_DEVICE);
+		dma_unmap_addr_set(&unmap_array[unmap_cons], dma_addr, 0);
 		BNA_QE_INDX_ADD(unmap_cons, 1, unmap_q->q_depth);
 
 		prefetch(&unmap_array[unmap_cons + 1]);
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 			prefetch(&unmap_array[unmap_cons + 1]);
 
-			pci_unmap_page(bnad->pcidev,
-				       pci_unmap_addr(&unmap_array[unmap_cons],
+			dma_unmap_page(&bnad->pcidev->dev,
+				       dma_unmap_addr(&unmap_array[unmap_cons],
 						      dma_addr),
 				       skb_shinfo(skb)->frags[i].size,
-				       PCI_DMA_TODEVICE);
-			pci_unmap_addr_set(&unmap_array[unmap_cons], dma_addr,
+				       DMA_TO_DEVICE);
+			dma_unmap_addr_set(&unmap_array[unmap_cons], dma_addr,
 					   0);
 			BNA_QE_INDX_ADD(unmap_cons, 1, unmap_q->q_depth);
 		}
@@ -340,19 +340,22 @@ static void
 bnad_free_all_rxbufs(struct bnad *bnad, struct bna_rcb *rcb)
 {
 	struct bnad_unmap_q *unmap_q;
+	struct bnad_skb_unmap *unmap_array;
 	struct sk_buff *skb;
 	int unmap_cons;
 
 	unmap_q = rcb->unmap_q;
+	unmap_array = unmap_q->unmap_array;
 	for (unmap_cons = 0; unmap_cons < unmap_q->q_depth; unmap_cons++) {
-		skb = unmap_q->unmap_array[unmap_cons].skb;
+		skb = unmap_array[unmap_cons].skb;
 		if (!skb)
 			continue;
-		unmap_q->unmap_array[unmap_cons].skb = NULL;
-		pci_unmap_single(bnad->pcidev, pci_unmap_addr(&unmap_q->
-					unmap_array[unmap_cons],
-					dma_addr), rcb->rxq->buffer_size,
-					PCI_DMA_FROMDEVICE);
+		unmap_array[unmap_cons].skb = NULL;
+		dma_unmap_single(&bnad->pcidev->dev,
+				 dma_unmap_addr(&unmap_array[unmap_cons],
+						dma_addr),
+				 rcb->rxq->buffer_size,
+				 DMA_FROM_DEVICE);
 		dev_kfree_skb(skb);
 	}
 	bnad_reset_rcb(bnad, rcb);
@@ -391,9 +394,10 @@ bnad_alloc_n_post_rxbufs(struct bnad *bnad, struct bna_rcb *rcb)
 		skb->dev = bnad->netdev;
 		skb_reserve(skb, NET_IP_ALIGN);
 		unmap_array[unmap_prod].skb = skb;
-		dma_addr = pci_map_single(bnad->pcidev, skb->data,
-			rcb->rxq->buffer_size, PCI_DMA_FROMDEVICE);
-		pci_unmap_addr_set(&unmap_array[unmap_prod], dma_addr,
+		dma_addr = dma_map_single(&bnad->pcidev->dev, skb->data,
+					  rcb->rxq->buffer_size,
+					  DMA_FROM_DEVICE);
+		dma_unmap_addr_set(&unmap_array[unmap_prod], dma_addr,
 				   dma_addr);
 		BNA_SET_DMA_ADDR(dma_addr, &rxent->host_addr);
 		BNA_QE_INDX_ADD(unmap_prod, 1, unmap_q->q_depth);
@@ -434,8 +438,9 @@ bnad_poll_cq(struct bnad *bnad, struct bna_ccb *ccb, int budget)
 	struct bna_rcb *rcb = NULL;
 	unsigned int wi_range, packets = 0, wis = 0;
 	struct bnad_unmap_q *unmap_q;
+	struct bnad_skb_unmap *unmap_array;
 	struct sk_buff *skb;
-	u32 flags;
+	u32 flags, unmap_cons;
 	u32 qid0 = ccb->rcb[0]->rxq->rxq_id;
 	struct bna_pkt_rate *pkt_rt = &ccb->pkt_rate;
 
@@ -456,17 +461,17 @@ bnad_poll_cq(struct bnad *bnad, struct bna_ccb *ccb, int budget)
 			rcb = ccb->rcb[1];
 
 		unmap_q = rcb->unmap_q;
+		unmap_array = unmap_q->unmap_array;
+		unmap_cons = unmap_q->consumer_index;
 
-		skb = unmap_q->unmap_array[unmap_q->consumer_index].skb;
+		skb = unmap_array[unmap_cons].skb;
 		BUG_ON(!(skb));
-		unmap_q->unmap_array[unmap_q->consumer_index].skb = NULL;
-		pci_unmap_single(bnad->pcidev,
-				 pci_unmap_addr(&unmap_q->
-						unmap_array[unmap_q->
-							    consumer_index],
+		unmap_array[unmap_cons].skb = NULL;
+		dma_unmap_single(&bnad->pcidev->dev,
+				 dma_unmap_addr(&unmap_array[unmap_cons],
 						dma_addr),
-						rcb->rxq->buffer_size,
-						PCI_DMA_FROMDEVICE);
+				 rcb->rxq->buffer_size,
+				 DMA_FROM_DEVICE);
 		BNA_QE_INDX_ADD(unmap_q->consumer_index, 1, unmap_q->q_depth);
 
 		/* Should be more efficient ? Performance ? */
@@ -1015,9 +1020,9 @@ bnad_mem_free(struct bnad *bnad,
 			if (mem_info->mem_type == BNA_MEM_T_DMA) {
 				BNA_GET_DMA_ADDR(&(mem_info->mdl[i].dma),
 						dma_pa);
-				pci_free_consistent(bnad->pcidev,
-						mem_info->mdl[i].len,
-						mem_info->mdl[i].kva, dma_pa);
+				dma_free_coherent(&bnad->pcidev->dev,
+						  mem_info->mdl[i].len,
+						  mem_info->mdl[i].kva, dma_pa);
 			} else
 				kfree(mem_info->mdl[i].kva);
 		}
@@ -1047,8 +1052,9 @@ bnad_mem_alloc(struct bnad *bnad,
 		for (i = 0; i < mem_info->num; i++) {
 			mem_info->mdl[i].len = mem_info->len;
 			mem_info->mdl[i].kva =
-				pci_alloc_consistent(bnad->pcidev,
-						mem_info->len, &dma_pa);
+				dma_alloc_coherent(&bnad->pcidev->dev,
+						mem_info->len, &dma_pa,
+						GFP_KERNEL);
 
 			if (mem_info->mdl[i].kva == NULL)
 				goto err_return;
@@ -2600,9 +2606,9 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	unmap_q->unmap_array[unmap_prod].skb = skb;
 	BUG_ON(!(skb_headlen(skb) <= BFI_TX_MAX_DATA_PER_VECTOR));
 	txqent->vector[vect_id].length = htons(skb_headlen(skb));
-	dma_addr = pci_map_single(bnad->pcidev, skb->data, skb_headlen(skb),
-		PCI_DMA_TODEVICE);
-	pci_unmap_addr_set(&unmap_q->unmap_array[unmap_prod], dma_addr,
+	dma_addr = dma_map_single(&bnad->pcidev->dev, skb->data,
+				  skb_headlen(skb), DMA_TO_DEVICE);
+	dma_unmap_addr_set(&unmap_q->unmap_array[unmap_prod], dma_addr,
 			   dma_addr);
 
 	BNA_SET_DMA_ADDR(dma_addr, &txqent->vector[vect_id].host_addr);
@@ -2630,11 +2636,9 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 		BUG_ON(!(size <= BFI_TX_MAX_DATA_PER_VECTOR));
 		txqent->vector[vect_id].length = htons(size);
-		dma_addr =
-			pci_map_page(bnad->pcidev, frag->page,
-				     frag->page_offset, size,
-				     PCI_DMA_TODEVICE);
-		pci_unmap_addr_set(&unmap_q->unmap_array[unmap_prod], dma_addr,
+		dma_addr = dma_map_page(&bnad->pcidev->dev, frag->page,
+					frag->page_offset, size, DMA_TO_DEVICE);
+		dma_unmap_addr_set(&unmap_q->unmap_array[unmap_prod], dma_addr,
 				   dma_addr);
 		BNA_SET_DMA_ADDR(dma_addr, &txqent->vector[vect_id].host_addr);
 		BNA_QE_INDX_ADD(unmap_prod, 1, unmap_q->q_depth);
@@ -3022,14 +3026,14 @@ bnad_pci_init(struct bnad *bnad,
 	err = pci_request_regions(pdev, BNAD_NAME);
 	if (err)
 		goto disable_device;
-	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64)) &&
-	    !pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64))) {
+	if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(64)) &&
+	    !dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64))) {
 		*using_dac = 1;
 	} else {
-		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
+		err = dma_set_mask(&pdev->dev, DMA_BIT_MASK(32));
 		if (err) {
-			err = pci_set_consistent_dma_mask(pdev,
-						DMA_BIT_MASK(32));
+			err = dma_set_coherent_mask(&pdev->dev,
+						    DMA_BIT_MASK(32));
 			if (err)
 				goto release_regions;
 		}
diff --git a/drivers/net/bna/bnad.h b/drivers/net/bna/bnad.h
index 8b1d515..a89117f 100644
--- a/drivers/net/bna/bnad.h
+++ b/drivers/net/bna/bnad.h
@@ -181,7 +181,7 @@ struct bnad_rx_info {
 /* Unmap queues for Tx / Rx cleanup */
 struct bnad_skb_unmap {
 	struct sk_buff		*skb;
-	DECLARE_PCI_UNMAP_ADDR(dma_addr)
+	DEFINE_DMA_UNMAP_ADDR(dma_addr);
 };
 
 struct bnad_unmap_q {
-- 
1.7.3.4

