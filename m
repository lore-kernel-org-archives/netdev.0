From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net V1 1/2] net/mlx4_en: Rename name of mlx4_en_rx_alloc members
Date: Mon,  7 Oct 2013 13:38:12 +0200
Message-ID: <1381145893-20930-2-git-send-email-amirv@mellanox.com>
References: <1381145893-20930-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:35372 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751351Ab3JGLio (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Oct 2013 07:38:44 -0400
In-Reply-To: <1381145893-20930-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add page prefix to page related members: @size and @offset into
@page_size and @page_offset

CC: Eric Dumazet <edumazet@google.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 40 ++++++++++++++++------------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  4 +--
 2 files changed, 25 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index dec455c..066fc27 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -70,14 +70,15 @@ static int mlx4_alloc_pages(struct mlx4_en_priv *priv,
 		put_page(page);
 		return -ENOMEM;
 	}
-	page_alloc->size = PAGE_SIZE << order;
+	page_alloc->page_size = PAGE_SIZE << order;
 	page_alloc->page = page;
 	page_alloc->dma = dma;
-	page_alloc->offset = frag_info->frag_align;
+	page_alloc->page_offset = frag_info->frag_align;
 	/* Not doing get_page() for each frag is a big win
 	 * on asymetric workloads.
 	 */
-	atomic_set(&page->_count, page_alloc->size / frag_info->frag_stride);
+	atomic_set(&page->_count,
+		   page_alloc->page_size / frag_info->frag_stride);
 	return 0;
 }
 
@@ -96,16 +97,19 @@ static int mlx4_en_alloc_frags(struct mlx4_en_priv *priv,
 	for (i = 0; i < priv->num_frags; i++) {
 		frag_info = &priv->frag_info[i];
 		page_alloc[i] = ring_alloc[i];
-		page_alloc[i].offset += frag_info->frag_stride;
-		if (page_alloc[i].offset + frag_info->frag_stride <= ring_alloc[i].size)
+		page_alloc[i].page_offset += frag_info->frag_stride;
+
+		if (page_alloc[i].page_offset + frag_info->frag_stride <=
+		    ring_alloc[i].page_size)
 			continue;
+
 		if (mlx4_alloc_pages(priv, &page_alloc[i], frag_info, gfp))
 			goto out;
 	}
 
 	for (i = 0; i < priv->num_frags; i++) {
 		frags[i] = ring_alloc[i];
-		dma = ring_alloc[i].dma + ring_alloc[i].offset;
+		dma = ring_alloc[i].dma + ring_alloc[i].page_offset;
 		ring_alloc[i] = page_alloc[i];
 		rx_desc->data[i].addr = cpu_to_be64(dma);
 	}
@@ -117,7 +121,7 @@ out:
 		frag_info = &priv->frag_info[i];
 		if (page_alloc[i].page != ring_alloc[i].page) {
 			dma_unmap_page(priv->ddev, page_alloc[i].dma,
-				page_alloc[i].size, PCI_DMA_FROMDEVICE);
+				page_alloc[i].page_size, PCI_DMA_FROMDEVICE);
 			page = page_alloc[i].page;
 			atomic_set(&page->_count, 1);
 			put_page(page);
@@ -132,9 +136,10 @@ static void mlx4_en_free_frag(struct mlx4_en_priv *priv,
 {
 	const struct mlx4_en_frag_info *frag_info = &priv->frag_info[i];
 
-	if (frags[i].offset + frag_info->frag_stride > frags[i].size)
-		dma_unmap_page(priv->ddev, frags[i].dma, frags[i].size,
-					 PCI_DMA_FROMDEVICE);
+	if (frags[i].page_offset + frag_info->frag_stride >
+	    frags[i].page_size)
+		dma_unmap_page(priv->ddev, frags[i].dma, frags[i].page_size,
+			       PCI_DMA_FROMDEVICE);
 
 	if (frags[i].page)
 		put_page(frags[i].page);
@@ -161,7 +166,7 @@ out:
 
 		page_alloc = &ring->page_alloc[i];
 		dma_unmap_page(priv->ddev, page_alloc->dma,
-			       page_alloc->size, PCI_DMA_FROMDEVICE);
+			       page_alloc->page_size, PCI_DMA_FROMDEVICE);
 		page = page_alloc->page;
 		atomic_set(&page->_count, 1);
 		put_page(page);
@@ -184,10 +189,11 @@ static void mlx4_en_destroy_allocator(struct mlx4_en_priv *priv,
 		       i, page_count(page_alloc->page));
 
 		dma_unmap_page(priv->ddev, page_alloc->dma,
-				page_alloc->size, PCI_DMA_FROMDEVICE);
-		while (page_alloc->offset + frag_info->frag_stride < page_alloc->size) {
+				page_alloc->page_size, PCI_DMA_FROMDEVICE);
+		while (page_alloc->page_offset + frag_info->frag_stride <
+		       page_alloc->page_size) {
 			put_page(page_alloc->page);
-			page_alloc->offset += frag_info->frag_stride;
+			page_alloc->page_offset += frag_info->frag_stride;
 		}
 		page_alloc->page = NULL;
 	}
@@ -478,7 +484,7 @@ static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
 		/* Save page reference in skb */
 		__skb_frag_set_page(&skb_frags_rx[nr], frags[nr].page);
 		skb_frag_size_set(&skb_frags_rx[nr], frag_info->frag_size);
-		skb_frags_rx[nr].page_offset = frags[nr].offset;
+		skb_frags_rx[nr].page_offset = frags[nr].page_offset;
 		skb->truesize += frag_info->frag_stride;
 		frags[nr].page = NULL;
 	}
@@ -517,7 +523,7 @@ static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
 
 	/* Get pointer to first fragment so we could copy the headers into the
 	 * (linear part of the) skb */
-	va = page_address(frags[0].page) + frags[0].offset;
+	va = page_address(frags[0].page) + frags[0].page_offset;
 
 	if (length <= SMALL_PACKET_SIZE) {
 		/* We are copying all relevant data to the skb - temporarily
@@ -645,7 +651,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 			dma_sync_single_for_cpu(priv->ddev, dma, sizeof(*ethh),
 						DMA_FROM_DEVICE);
 			ethh = (struct ethhdr *)(page_address(frags[0].page) +
-						 frags[0].offset);
+						 frags[0].page_offset);
 
 			if (is_multicast_ether_addr(ethh->h_dest)) {
 				struct mlx4_mac_entry *entry;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 5e0aa56..bf06e36 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -237,8 +237,8 @@ struct mlx4_en_tx_desc {
 struct mlx4_en_rx_alloc {
 	struct page	*page;
 	dma_addr_t	dma;
-	u32		offset;
-	u32		size;
+	u32		page_offset;
+	u32		page_size;
 };
 
 struct mlx4_en_tx_ring {
-- 
1.8.3.4
