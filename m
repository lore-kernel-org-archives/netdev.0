From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 9/9] mlx4: add page recycling in receive path
Date: Mon,  6 Feb 2017 19:02:40 -0800
Message-ID: <20170207030240.31357-10-edumazet@google.com>
References: <20170207030240.31357-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:34338 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752811AbdBGDDq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 22:03:46 -0500
Received: by mail-pg0-f54.google.com with SMTP id 14so34069024pgg.1
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 19:03:46 -0800 (PST)
In-Reply-To: <20170207030240.31357-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Same technique than some Intel drivers, for arches where PAGE_SIZE = 4096

In most cases, pages are reused because they were consumed
before we could loop around the RX ring.

This brings back performance, and is even better,
a single TCP flow reaches 30Gbit on my hosts.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 238 ++++++++-------------------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |   1 -
 2 files changed, 68 insertions(+), 171 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index be4f3491a4fcb6ee0e9fe4e71abfd2bc5373..6854a19087edbf0bc9bf29e20a82deaaf043 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -50,10 +50,9 @@
 
 #include "mlx4_en.h"
 
-static int mlx4_alloc_pages(struct mlx4_en_priv *priv,
-			    struct mlx4_en_rx_alloc *page_alloc,
-			    const struct mlx4_en_frag_info *frag_info,
-			    gfp_t gfp)
+static int mlx4_alloc_page(const struct mlx4_en_priv *priv,
+			   struct mlx4_en_rx_alloc *frag,
+			   gfp_t gfp)
 {
 	struct page *page;
 	dma_addr_t dma;
@@ -66,142 +65,40 @@ static int mlx4_alloc_pages(struct mlx4_en_priv *priv,
 		put_page(page);
 		return -ENOMEM;
 	}
-	page_alloc->page = page;
-	page_alloc->dma = dma;
-	page_alloc->page_offset = 0;
-	/* Not doing get_page() for each frag is a big win
-	 * on asymetric workloads. Note we can not use atomic_set().
-	 */
-	page_ref_add(page, PAGE_SIZE / frag_info->frag_stride - 1);
+	frag->page = page;
+	frag->dma = dma;
+	frag->page_offset = priv->rx_headroom;
 	return 0;
 }
 
-static int mlx4_en_alloc_frags(struct mlx4_en_priv *priv,
+static int mlx4_en_alloc_frags(const struct mlx4_en_priv *priv,
 			       struct mlx4_en_rx_desc *rx_desc,
 			       struct mlx4_en_rx_alloc *frags,
-			       struct mlx4_en_rx_alloc *ring_alloc,
 			       gfp_t gfp)
 {
-	struct mlx4_en_rx_alloc page_alloc[MLX4_EN_MAX_RX_FRAGS];
-	const struct mlx4_en_frag_info *frag_info;
-	struct page *page;
 	int i;
 
-	for (i = 0; i < priv->num_frags; i++) {
-		frag_info = &priv->frag_info[i];
-		page_alloc[i] = ring_alloc[i];
-		page_alloc[i].page_offset += frag_info->frag_stride;
-
-		if (page_alloc[i].page_offset + frag_info->frag_stride <=
-		    PAGE_SIZE)
-			continue;
-
-		if (unlikely(mlx4_alloc_pages(priv, &page_alloc[i],
-					      frag_info, gfp)))
-			goto out;
-	}
-
-	for (i = 0; i < priv->num_frags; i++) {
-		frags[i] = ring_alloc[i];
-		frags[i].page_offset += priv->rx_headroom;
-		rx_desc->data[i].addr = cpu_to_be64(frags[i].dma +
-						    frags[i].page_offset);
-		ring_alloc[i] = page_alloc[i];
-	}
-
-	return 0;
-
-out:
-	while (i--) {
-		if (page_alloc[i].page != ring_alloc[i].page) {
-			dma_unmap_page(priv->ddev, page_alloc[i].dma,
-				       PAGE_SIZE, priv->dma_dir);
-			page = page_alloc[i].page;
-			/* Revert changes done by mlx4_alloc_pages */
-			page_ref_sub(page, PAGE_SIZE /
-					   priv->frag_info[i].frag_stride - 1);
-			put_page(page);
-		}
-	}
-	return -ENOMEM;
-}
-
-static void mlx4_en_free_frag(struct mlx4_en_priv *priv,
-			      struct mlx4_en_rx_alloc *frags,
-			      int i)
-{
-	const struct mlx4_en_frag_info *frag_info = &priv->frag_info[i];
-	u32 next_frag_end = frags[i].page_offset + 2 * frag_info->frag_stride;
-
-
-	if (next_frag_end > PAGE_SIZE)
-		dma_unmap_page(priv->ddev, frags[i].dma, PAGE_SIZE,
-			       priv->dma_dir);
-
-	if (frags[i].page)
-		put_page(frags[i].page);
-}
-
-static int mlx4_en_init_allocator(struct mlx4_en_priv *priv,
-				  struct mlx4_en_rx_ring *ring)
-{
-	int i;
-	struct mlx4_en_rx_alloc *page_alloc;
-
-	for (i = 0; i < priv->num_frags; i++) {
-		const struct mlx4_en_frag_info *frag_info = &priv->frag_info[i];
-
-		if (mlx4_alloc_pages(priv, &ring->page_alloc[i],
-				     frag_info, GFP_KERNEL | __GFP_COLD))
-			goto out;
-
-		en_dbg(DRV, priv, "  frag %d allocator: - frags:%d\n",
-		       i, page_ref_count(ring->page_alloc[i].page));
+	for (i = 0; i < priv->num_frags; i++, frags++) {
+		if (!frags->page && mlx4_alloc_page(priv, frags, gfp))
+			return -ENOMEM;
+		rx_desc->data[i].addr = cpu_to_be64(frags->dma +
+						    frags->page_offset);
 	}
 	return 0;
-
-out:
-	while (i--) {
-		struct page *page;
-
-		page_alloc = &ring->page_alloc[i];
-		dma_unmap_page(priv->ddev, page_alloc->dma,
-			       PAGE_SIZE, priv->dma_dir);
-		page = page_alloc->page;
-		/* Revert changes done by mlx4_alloc_pages */
-		page_ref_sub(page, PAGE_SIZE /
-				   priv->frag_info[i].frag_stride - 1);
-		put_page(page);
-		page_alloc->page = NULL;
-	}
-	return -ENOMEM;
 }
 
-static void mlx4_en_destroy_allocator(struct mlx4_en_priv *priv,
-				      struct mlx4_en_rx_ring *ring)
+static void mlx4_en_free_frag(const struct mlx4_en_priv *priv,
+			      struct mlx4_en_rx_alloc *frag)
 {
-	struct mlx4_en_rx_alloc *page_alloc;
-	int i;
-
-	for (i = 0; i < priv->num_frags; i++) {
-		const struct mlx4_en_frag_info *frag_info = &priv->frag_info[i];
-
-		page_alloc = &ring->page_alloc[i];
-		en_dbg(DRV, priv, "Freeing allocator:%d count:%d\n",
-		       i, page_count(page_alloc->page));
-
-		dma_unmap_page(priv->ddev, page_alloc->dma,
+	if (frag->page) {
+		dma_unmap_page(priv->ddev, frag->dma,
 			       PAGE_SIZE, priv->dma_dir);
-		while (page_alloc->page_offset + frag_info->frag_stride <
-		       PAGE_SIZE) {
-			put_page(page_alloc->page);
-			page_alloc->page_offset += frag_info->frag_stride;
-		}
-		page_alloc->page = NULL;
+		put_page(frag->page);
+		frag->page = NULL;
 	}
 }
 
-static void mlx4_en_init_rx_desc(struct mlx4_en_priv *priv,
+static void mlx4_en_init_rx_desc(const struct mlx4_en_priv *priv,
 				 struct mlx4_en_rx_ring *ring, int index)
 {
 	struct mlx4_en_rx_desc *rx_desc = ring->buf + ring->stride * index;
@@ -226,7 +123,7 @@ static void mlx4_en_init_rx_desc(struct mlx4_en_priv *priv,
 	}
 }
 
-static int mlx4_en_prepare_rx_desc(struct mlx4_en_priv *priv,
+static int mlx4_en_prepare_rx_desc(const struct mlx4_en_priv *priv,
 				   struct mlx4_en_rx_ring *ring, int index,
 				   gfp_t gfp)
 {
@@ -235,19 +132,21 @@ static int mlx4_en_prepare_rx_desc(struct mlx4_en_priv *priv,
 					(index << priv->log_rx_info);
 
 	if (ring->page_cache.index > 0) {
-		ring->page_cache.index--;
-		frags[0].page = ring->page_cache.buf[ring->page_cache.index].page;
-		frags[0].dma  = ring->page_cache.buf[ring->page_cache.index].dma;
+		if (frags[0].page) {
+			ring->page_cache.index--;
+			frags[0].page = ring->page_cache.buf[ring->page_cache.index].page;
+			frags[0].dma  = ring->page_cache.buf[ring->page_cache.index].dma;
+		}
 		frags[0].page_offset = XDP_PACKET_HEADROOM;
 		rx_desc->data[0].addr = cpu_to_be64(frags[0].dma +
 						    frags[0].page_offset);
 		return 0;
 	}
 
-	return mlx4_en_alloc_frags(priv, rx_desc, frags, ring->page_alloc, gfp);
+	return mlx4_en_alloc_frags(priv, rx_desc, frags, gfp);
 }
 
-static inline bool mlx4_en_is_ring_empty(struct mlx4_en_rx_ring *ring)
+static bool mlx4_en_is_ring_empty(const struct mlx4_en_rx_ring *ring)
 {
 	return ring->prod == ring->cons;
 }
@@ -257,7 +156,8 @@ static inline void mlx4_en_update_rx_prod_db(struct mlx4_en_rx_ring *ring)
 	*ring->wqres.db.db = cpu_to_be32(ring->prod & 0xffff);
 }
 
-static void mlx4_en_free_rx_desc(struct mlx4_en_priv *priv,
+/* slow path */
+static void mlx4_en_free_rx_desc(const struct mlx4_en_priv *priv,
 				 struct mlx4_en_rx_ring *ring,
 				 int index)
 {
@@ -267,7 +167,7 @@ static void mlx4_en_free_rx_desc(struct mlx4_en_priv *priv,
 	frags = ring->rx_info + (index << priv->log_rx_info);
 	for (nr = 0; nr < priv->num_frags; nr++) {
 		en_dbg(DRV, priv, "Freeing fragment:%d\n", nr);
-		mlx4_en_free_frag(priv, frags, nr);
+		mlx4_en_free_frag(priv, frags + nr);
 	}
 }
 
@@ -380,9 +280,9 @@ int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
 
 	tmp = size * roundup_pow_of_two(MLX4_EN_MAX_RX_FRAGS *
 					sizeof(struct mlx4_en_rx_alloc));
-	ring->rx_info = vmalloc_node(tmp, node);
+	ring->rx_info = vzalloc_node(tmp, node);
 	if (!ring->rx_info) {
-		ring->rx_info = vmalloc(tmp);
+		ring->rx_info = vzalloc(tmp);
 		if (!ring->rx_info) {
 			err = -ENOMEM;
 			goto err_ring;
@@ -452,16 +352,6 @@ int mlx4_en_activate_rx_rings(struct mlx4_en_priv *priv)
 		/* Initialize all descriptors */
 		for (i = 0; i < ring->size; i++)
 			mlx4_en_init_rx_desc(priv, ring, i);
-
-		/* Initialize page allocators */
-		err = mlx4_en_init_allocator(priv, ring);
-		if (err) {
-			en_err(priv, "Failed initializing ring allocator\n");
-			if (ring->stride <= TXBB_SIZE)
-				ring->buf -= TXBB_SIZE;
-			ring_ind--;
-			goto err_allocator;
-		}
 	}
 	err = mlx4_en_fill_rx_buffers(priv);
 	if (err)
@@ -481,11 +371,9 @@ int mlx4_en_activate_rx_rings(struct mlx4_en_priv *priv)
 		mlx4_en_free_rx_buf(priv, priv->rx_ring[ring_ind]);
 
 	ring_ind = priv->rx_ring_num - 1;
-err_allocator:
 	while (ring_ind >= 0) {
 		if (priv->rx_ring[ring_ind]->stride <= TXBB_SIZE)
 			priv->rx_ring[ring_ind]->buf -= TXBB_SIZE;
-		mlx4_en_destroy_allocator(priv, priv->rx_ring[ring_ind]);
 		ring_ind--;
 	}
 	return err;
@@ -562,50 +450,64 @@ void mlx4_en_deactivate_rx_ring(struct mlx4_en_priv *priv,
 	mlx4_en_free_rx_buf(priv, ring);
 	if (ring->stride <= TXBB_SIZE)
 		ring->buf -= TXBB_SIZE;
-	mlx4_en_destroy_allocator(priv, ring);
 }
 
 
-static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
-				    struct mlx4_en_rx_desc *rx_desc,
+static noinline int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
 				    struct mlx4_en_rx_alloc *frags,
 				    struct sk_buff *skb,
 				    int length)
 {
-	struct skb_frag_struct *skb_frags_rx = skb_shinfo(skb)->frags;
 	struct mlx4_en_frag_info *frag_info = priv->frag_info;
 	int nr, frag_size;
+	struct page *page;
 	dma_addr_t dma;
+	bool release;
+	unsigned int truesize = 0;
 
 	/* Collect used fragments while replacing them in the HW descriptors */
 	for (nr = 0;;) {
 		frag_size = min_t(int, length, frag_info->frag_size);
 
-		if (unlikely(!frags[nr].page))
+		page = frags[nr].page;
+		if (unlikely(!page))
 			goto fail;
 
-		dma = be64_to_cpu(rx_desc->data[nr].addr);
-		dma_sync_single_for_cpu(priv->ddev, dma, frag_info->frag_size,
-					DMA_FROM_DEVICE);
+		dma = frags[nr].dma;
+		dma_sync_single_range_for_cpu(priv->ddev, dma, frags[nr].page_offset,
+					      frag_info->frag_size, priv->dma_dir);
 
-		__skb_fill_page_desc(skb, nr, frags[nr].page,
-				     frags[nr].page_offset,
+		__skb_fill_page_desc(skb, nr, page, frags[nr].page_offset,
 				     frag_size);
 
-		skb->truesize += frag_info->frag_stride;
-		frags[nr].page = NULL;
+		truesize += frag_info->frag_stride;
+		if (frag_info->frag_stride == PAGE_SIZE / 2) {
+			frags[nr].page_offset ^= PAGE_SIZE / 2;
+			release = page_count(page) != 1 || page_is_pfmemalloc(page);
+		} else {
+			frags[nr].page_offset += frag_info->frag_stride;
+			release = frags[nr].page_offset + frag_info->frag_size > PAGE_SIZE;
+		}
+		if (release) {
+			dma_unmap_page(priv->ddev, dma, PAGE_SIZE, priv->dma_dir);
+			frags[nr].page = NULL;
+		} else {
+			page_ref_inc(page);
+		}
+
 		nr++;
 		length -= frag_size;
 		if (!length)
 			break;
 		frag_info++;
 	}
+	skb->truesize += truesize;
 	return nr;
 
 fail:
 	while (nr > 0) {
 		nr--;
-		__skb_frag_unref(&skb_frags_rx[nr]);
+		__skb_frag_unref(skb_shinfo(skb)->frags + nr);
 	}
 	return 0;
 }
@@ -636,7 +538,8 @@ static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
 	if (length <= SMALL_PACKET_SIZE) {
 		/* We are copying all relevant data to the skb - temporarily
 		 * sync buffers for the copy */
-		dma = be64_to_cpu(rx_desc->data[0].addr);
+
+		dma = frags[0].dma + frags[0].page_offset;
 		dma_sync_single_for_cpu(priv->ddev, dma, length,
 					DMA_FROM_DEVICE);
 		skb_copy_to_linear_data(skb, va, length);
@@ -645,7 +548,7 @@ static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
 		unsigned int pull_len;
 
 		/* Move relevant fragments to skb */
-		used_frags = mlx4_en_complete_rx_desc(priv, rx_desc, frags,
+		used_frags = mlx4_en_complete_rx_desc(priv, frags,
 							skb, length);
 		if (unlikely(!used_frags)) {
 			kfree_skb(skb);
@@ -913,8 +816,10 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 			case XDP_TX:
 				if (likely(!mlx4_en_xmit_frame(ring, frags, dev,
 							length, cq->ring,
-							&doorbell_pending)))
-					goto consumed;
+							&doorbell_pending))) {
+					frags[0].page = NULL;
+					goto next;
+				}
 				trace_xdp_exception(dev, xdp_prog, act);
 				goto xdp_drop_no_cnt; /* Drop on xmit failure */
 			default:
@@ -924,8 +829,6 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 			case XDP_DROP:
 				ring->xdp_drop++;
 xdp_drop_no_cnt:
-				if (likely(mlx4_en_rx_recycle(ring, frags)))
-					goto consumed;
 				goto next;
 			}
 		}
@@ -971,9 +874,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 			if (!gro_skb)
 				goto next;
 
-			nr = mlx4_en_complete_rx_desc(priv,
-				rx_desc, frags, gro_skb,
-				length);
+			nr = mlx4_en_complete_rx_desc(priv, frags, gro_skb,
+						      length);
 			if (!nr)
 				goto next;
 
@@ -1081,10 +983,6 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 
 		napi_gro_receive(&cq->napi, skb);
 next:
-		for (nr = 0; nr < priv->num_frags; nr++)
-			mlx4_en_free_frag(priv, frags, nr);
-
-consumed:
 		++cq->mcq.cons_index;
 		index = (cq->mcq.cons_index) & ring->size_mask;
 		cqe = mlx4_en_get_cqe(cq->buf, index, priv->cqe_size) + factor;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 4016086b13539c8bd848242a3a1788eff245..4a6594325a10b238b8a4f01805493b5c6e8b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -327,7 +327,6 @@ struct mlx4_en_rx_desc {
 
 struct mlx4_en_rx_ring {
 	struct mlx4_hwq_resources wqres;
-	struct mlx4_en_rx_alloc page_alloc[MLX4_EN_MAX_RX_FRAGS];
 	u32 size ;	/* number of Rx descs*/
 	u32 actual_size;
 	u32 size_mask;
-- 
2.11.0.483.g087da7b7c-goog
