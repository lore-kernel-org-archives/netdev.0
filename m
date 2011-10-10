From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 2/9] mlx4: convert to SKB paged frag API.
Date: Mon, 10 Oct 2011 12:11:34 +0100
Message-ID: <1318245101-16890-2-git-send-email-ian.campbell@citrix.com>
References: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:47504 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753688Ab1JJLLp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Oct 2011 07:11:45 -0400
In-Reply-To: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c |   34 ++++++++++++++--------------
 drivers/net/ethernet/mellanox/mlx4/en_tx.c |   20 +++-------------
 2 files changed, 21 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 37cc9e5..12e0bee 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -44,7 +44,7 @@
 
 static int mlx4_en_alloc_frag(struct mlx4_en_priv *priv,
 			      struct mlx4_en_rx_desc *rx_desc,
-			      struct skb_frag_struct *skb_frags,
+			      struct subpage *skb_frags,
 			      struct mlx4_en_rx_alloc *ring_alloc,
 			      int i)
 {
@@ -157,8 +157,8 @@ static int mlx4_en_prepare_rx_desc(struct mlx4_en_priv *priv,
 				   struct mlx4_en_rx_ring *ring, int index)
 {
 	struct mlx4_en_rx_desc *rx_desc = ring->buf + (index * ring->stride);
-	struct skb_frag_struct *skb_frags = ring->rx_info +
-					    (index << priv->log_rx_info);
+	struct subpage *skb_frags = ring->rx_info +
+				    (index << priv->log_rx_info);
 	int i;
 
 	for (i = 0; i < priv->num_frags; i++)
@@ -183,7 +183,7 @@ static void mlx4_en_free_rx_desc(struct mlx4_en_priv *priv,
 				 int index)
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
-	struct skb_frag_struct *skb_frags;
+	struct subpage *skb_frags;
 	struct mlx4_en_rx_desc *rx_desc = ring->buf + (index << ring->log_stride);
 	dma_addr_t dma;
 	int nr;
@@ -403,8 +403,8 @@ void mlx4_en_deactivate_rx_ring(struct mlx4_en_priv *priv,
 /* Unmap a completed descriptor and free unused pages */
 static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
 				    struct mlx4_en_rx_desc *rx_desc,
-				    struct skb_frag_struct *skb_frags,
-				    struct skb_frag_struct *skb_frags_rx,
+				    struct subpage *skb_frags,
+				    struct sk_buff *skb,
 				    struct mlx4_en_rx_alloc *page_alloc,
 				    int length)
 {
@@ -420,9 +420,10 @@ static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
 			break;
 
 		/* Save page reference in skb */
-		skb_frags_rx[nr].page = skb_frags[nr].page;
-		skb_frags_rx[nr].size = skb_frags[nr].size;
-		skb_frags_rx[nr].page_offset = skb_frags[nr].page_offset;
+		__skb_fill_page_desc(skb, nr,
+				     skb_frags[nr].page,
+				     skb_frags[nr].size,
+				     skb_frags[nr].page_offset);
 		dma = be64_to_cpu(rx_desc->data[nr].addr);
 
 		/* Allocate a replacement page */
@@ -430,12 +431,12 @@ static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
 			goto fail;
 
 		/* Unmap buffer */
-		pci_unmap_single(mdev->pdev, dma, skb_frags_rx[nr].size,
+		pci_unmap_single(mdev->pdev, dma, skb_shinfo(skb)->frags[nr].size,
 				 PCI_DMA_FROMDEVICE);
 	}
 	/* Adjust size of last fragment to match actual length */
 	if (nr > 0)
-		skb_frags_rx[nr - 1].size = length -
+		skb_shinfo(skb)->frags[nr - 1].size = length -
 			priv->frag_info[nr - 1].frag_prefix_size;
 	return nr;
 
@@ -444,7 +445,7 @@ fail:
 	 * the descriptor) of this packet; remaining fragments are reused... */
 	while (nr > 0) {
 		nr--;
-		put_page(skb_frags_rx[nr].page);
+		skb_frag_unref(skb, nr);
 	}
 	return 0;
 }
@@ -452,7 +453,7 @@ fail:
 
 static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
 				      struct mlx4_en_rx_desc *rx_desc,
-				      struct skb_frag_struct *skb_frags,
+				      struct subpage *skb_frags,
 				      struct mlx4_en_rx_alloc *page_alloc,
 				      unsigned int length)
 {
@@ -490,8 +491,7 @@ static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
 
 		/* Move relevant fragments to skb */
 		used_frags = mlx4_en_complete_rx_desc(priv, rx_desc, skb_frags,
-						      skb_shinfo(skb)->frags,
-						      page_alloc, length);
+						      skb, page_alloc, length);
 		if (unlikely(!used_frags)) {
 			kfree_skb(skb);
 			return NULL;
@@ -533,7 +533,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_cqe *cqe;
 	struct mlx4_en_rx_ring *ring = &priv->rx_ring[cq->ring];
-	struct skb_frag_struct *skb_frags;
+	struct subpage *skb_frags;
 	struct mlx4_en_rx_desc *rx_desc;
 	struct sk_buff *skb;
 	int index;
@@ -600,7 +600,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 
 					nr = mlx4_en_complete_rx_desc(
 						priv, rx_desc,
-						skb_frags, skb_shinfo(gro_skb)->frags,
+						skb_frags, gro_skb,
 						ring->page_alloc, length);
 					if (!nr)
 						goto next;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 6e03de0..e8cc987 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -460,26 +460,13 @@ static inline void mlx4_en_xmit_poll(struct mlx4_en_priv *priv, int tx_ind)
 		}
 }
 
-static void *get_frag_ptr(struct sk_buff *skb)
-{
-	struct skb_frag_struct *frag =  &skb_shinfo(skb)->frags[0];
-	struct page *page = frag->page;
-	void *ptr;
-
-	ptr = page_address(page);
-	if (unlikely(!ptr))
-		return NULL;
-
-	return ptr + frag->page_offset;
-}
-
 static int is_inline(struct sk_buff *skb, void **pfrag)
 {
 	void *ptr;
 
 	if (inline_thold && !skb_is_gso(skb) && skb->len <= inline_thold) {
 		if (skb_shinfo(skb)->nr_frags == 1) {
-			ptr = get_frag_ptr(skb);
+			ptr = skb_frag_address_safe(&skb_shinfo(skb)->frags[0]);
 			if (unlikely(!ptr))
 				return 0;
 
@@ -756,8 +743,9 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		/* Map fragments */
 		for (i = skb_shinfo(skb)->nr_frags - 1; i >= 0; i--) {
 			frag = &skb_shinfo(skb)->frags[i];
-			dma = pci_map_page(mdev->dev->pdev, frag->page, frag->page_offset,
-					   frag->size, PCI_DMA_TODEVICE);
+			dma = skb_frag_dma_map(&mdev->dev->pdev->dev, frag,
+					       0, frag->size,
+					       DMA_TO_DEVICE);
 			data->addr = cpu_to_be64(dma);
 			data->lkey = cpu_to_be32(mdev->mr.key);
 			wmb();
-- 
1.7.2.5
