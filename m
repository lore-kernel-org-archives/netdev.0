From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next] mlx4: Better use of order-0 pages in RX path
Date: Sun, 12 Mar 2017 17:58:47 -0700
Message-ID: <20170313005848.7076-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:36858 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755792AbdCMA6y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 20:58:54 -0400
Received: by mail-pf0-f172.google.com with SMTP id o126so62852408pfb.3
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 17:58:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When adding order-0 pages allocations and page recycling in receive path,
I added issues on PowerPC, or more generally on arches with large pages.

A GRO packet, aggregating 45 segments, ended up using 45 page frags
on 45 different pages. Before my changes we were very likely packing
up to 42 Ethernet frames per 64KB page.

1) At skb freeing time, all put_page() on the skb frags now touch 45
   different 'struct page' and this adds more cache line misses.
   Too bad that standard Ethernet MTU is so small :/

2) Using one order-0 page per ring slot consumes ~42 times more memory
   on PowerPC.

3) Allocating order-0 pages is very likely to use pages from very
   different locations, increasing TLB pressure on hosts with more
   than 256 GB of memory after days of uptime.

This patch uses a refined strategy, addressing these points.

We still use order-0 pages, but the page recyling technique is modified
so that we have better chances to lower number of pages containing the
frags for a given GRO skb (factor of 2 on x86, and 21 on PowerPC)

Page allocations are split in two halves :
- One currently visible by the NIC for DMA operations.
- The other contains pages that already added to old skbs, put in
  a quarantine.

When we receive a frame, we look at the oldest entry in the pool and
check if the page count is back to one, meaning old skbs/frags were
consumed and the page can be recycled.

Page allocations are attempted using high order ones, trying
to lower TLB pressure.

On x86, memory allocations stay the same. (One page per RX slot for MTU=1500)
But on PowerPC, this patch considerably reduces the allocated memory.

Performance gain on PowerPC is about 50% for a single TCP flow.

On x86, I could not measure the difference, my test machine being
limited by the sender (33 Gbit per TCP flow).
22 less cache line misses per 64 KB GRO packet is probably in the order
of 2 % or so.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Tariq Toukan <tariqt@mellanox.com>
Cc: Saeed Mahameed <saeedm@mellanox.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 462 +++++++++++++++------------
 drivers/net/ethernet/mellanox/mlx4/en_tx.c   |  15 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  54 +++-
 3 files changed, 310 insertions(+), 221 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index aa074e57ce06fb2842fa1faabd156c3cd2fe10f5..de455c8a2dec389cfeca6b6d474a6184d6acf618 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -31,7 +31,6 @@
  *
  */
 
-#include <net/busy_poll.h>
 #include <linux/bpf.h>
 #include <linux/bpf_trace.h>
 #include <linux/mlx4/cq.h>
@@ -50,59 +49,41 @@
 
 #include "mlx4_en.h"
 
-static int mlx4_alloc_page(struct mlx4_en_priv *priv,
-			   struct mlx4_en_rx_alloc *frag,
-			   gfp_t gfp)
+static struct page *mlx4_alloc_page(struct mlx4_en_priv *priv,
+				    struct mlx4_en_rx_ring *ring,
+				    dma_addr_t *dma,
+				    unsigned int node, gfp_t gfp)
 {
 	struct page *page;
-	dma_addr_t dma;
-
-	page = alloc_page(gfp);
-	if (unlikely(!page))
-		return -ENOMEM;
-	dma = dma_map_page(priv->ddev, page, 0, PAGE_SIZE, priv->dma_dir);
-	if (unlikely(dma_mapping_error(priv->ddev, dma))) {
-		__free_page(page);
-		return -ENOMEM;
-	}
-	frag->page = page;
-	frag->dma = dma;
-	frag->page_offset = priv->rx_headroom;
-	return 0;
-}
 
-static int mlx4_en_alloc_frags(struct mlx4_en_priv *priv,
-			       struct mlx4_en_rx_ring *ring,
-			       struct mlx4_en_rx_desc *rx_desc,
-			       struct mlx4_en_rx_alloc *frags,
-			       gfp_t gfp)
-{
-	int i;
+	if (unlikely(!ring->pre_allocated_count)) {
+		unsigned int order = READ_ONCE(ring->rx_alloc_order);
 
-	for (i = 0; i < priv->num_frags; i++, frags++) {
-		if (!frags->page) {
-			if (mlx4_alloc_page(priv, frags, gfp))
-				return -ENOMEM;
-			ring->rx_alloc_pages++;
+		page = __alloc_pages_node(node, gfp | __GFP_NOMEMALLOC |
+						__GFP_NOWARN | __GFP_NORETRY,
+					  order);
+		if (page) {
+			split_page(page, order);
+			ring->pre_allocated_count = 1U << order;
+		} else {
+			if (order > 1)
+				ring->rx_alloc_order--;
+			page = __alloc_pages_node(node, gfp, 0);
+			if (unlikely(!page))
+				return NULL;
+			ring->pre_allocated_count = 1U;
 		}
-		rx_desc->data[i].addr = cpu_to_be64(frags->dma +
-						    frags->page_offset);
+		ring->pre_allocated = page;
+		ring->rx_alloc_pages += ring->pre_allocated_count;
 	}
-	return 0;
-}
-
-static void mlx4_en_free_frag(const struct mlx4_en_priv *priv,
-			      struct mlx4_en_rx_alloc *frag)
-{
-	if (frag->page) {
-		dma_unmap_page(priv->ddev, frag->dma,
-			       PAGE_SIZE, priv->dma_dir);
-		__free_page(frag->page);
+	page = ring->pre_allocated++;
+	ring->pre_allocated_count--;
+	*dma = dma_map_page(priv->ddev, page, 0, PAGE_SIZE, priv->dma_dir);
+	if (unlikely(dma_mapping_error(priv->ddev, *dma))) {
+		__free_page(page);
+		return NULL;
 	}
-	/* We need to clear all fields, otherwise a change of priv->log_rx_info
-	 * could lead to see garbage later in frag->page.
-	 */
-	memset(frag, 0, sizeof(*frag));
+	return page;
 }
 
 static void mlx4_en_init_rx_desc(const struct mlx4_en_priv *priv,
@@ -130,32 +111,18 @@ static void mlx4_en_init_rx_desc(const struct mlx4_en_priv *priv,
 	}
 }
 
-static int mlx4_en_prepare_rx_desc(struct mlx4_en_priv *priv,
-				   struct mlx4_en_rx_ring *ring, int index,
-				   gfp_t gfp)
+static void mlx4_en_prepare_rx_desc(struct mlx4_en_priv *priv,
+				    struct mlx4_en_rx_ring *ring,
+				    unsigned int index)
 {
 	struct mlx4_en_rx_desc *rx_desc = ring->buf + (index * ring->stride);
-	struct mlx4_en_rx_alloc *frags = ring->rx_info +
-					(index << priv->log_rx_info);
-	if (ring->page_cache.index > 0) {
-		/* XDP uses a single page per frame */
-		if (!frags->page) {
-			ring->page_cache.index--;
-			frags->page = ring->page_cache.buf[ring->page_cache.index].page;
-			frags->dma  = ring->page_cache.buf[ring->page_cache.index].dma;
-		}
-		frags->page_offset = XDP_PACKET_HEADROOM;
-		rx_desc->data[0].addr = cpu_to_be64(frags->dma +
-						    XDP_PACKET_HEADROOM);
-		return 0;
-	}
-
-	return mlx4_en_alloc_frags(priv, ring, rx_desc, frags, gfp);
-}
+	const struct mlx4_en_rx_alloc *frags = ring->rx_info +
+						(index << priv->log_rx_info);
+	int i;
 
-static bool mlx4_en_is_ring_empty(const struct mlx4_en_rx_ring *ring)
-{
-	return ring->prod == ring->cons;
+	for (i = 0; i < priv->num_frags; i++, frags++)
+		rx_desc->data[i].addr = cpu_to_be64(frags->dma +
+						    frags->page_offset);
 }
 
 static inline void mlx4_en_update_rx_prod_db(struct mlx4_en_rx_ring *ring)
@@ -163,79 +130,135 @@ static inline void mlx4_en_update_rx_prod_db(struct mlx4_en_rx_ring *ring)
 	*ring->wqres.db.db = cpu_to_be32(ring->prod & 0xffff);
 }
 
-/* slow path */
-static void mlx4_en_free_rx_desc(const struct mlx4_en_priv *priv,
-				 struct mlx4_en_rx_ring *ring,
-				 int index)
+static void mlx4_en_free_rx_buf(struct mlx4_en_priv *priv,
+				struct mlx4_en_rx_ring *ring)
 {
-	struct mlx4_en_rx_alloc *frags;
-	int nr;
+	int index;
+
+	if (ring->pool.array) {
+		const struct mlx4_en_page *en_page = ring->pool.array;
 
-	frags = ring->rx_info + (index << priv->log_rx_info);
-	for (nr = 0; nr < priv->num_frags; nr++) {
-		en_dbg(DRV, priv, "Freeing fragment:%d\n", nr);
-		mlx4_en_free_frag(priv, frags + nr);
+		for (index = 0; index < ring->pool.pool_size; index++) {
+			dma_unmap_page(priv->ddev, en_page->dma,
+				       PAGE_SIZE, priv->dma_dir);
+			__free_page(en_page->page);
+			en_page++;
+		}
+		kfree(ring->pool.array);
+		ring->pool.array = NULL;
+		while (ring->pre_allocated_count) {
+			__free_page(ring->pre_allocated++);
+			ring->pre_allocated_count--;
+		}
 	}
+	ring->cons = 0;
+	ring->prod = 0;
 }
 
 static int mlx4_en_fill_rx_buffers(struct mlx4_en_priv *priv)
 {
+	int ring_ind, i, new_size = priv->prof->rx_ring_size;
+	unsigned int stride_bytes = 0;
 	struct mlx4_en_rx_ring *ring;
-	int ring_ind;
-	int buf_ind;
-	int new_size;
+	unsigned int pages_per_ring;
+	unsigned int page_ind;
+	unsigned int total;
+	unsigned int order;
+
+	for (i = 0; i < priv->num_frags; i++)
+		stride_bytes += priv->frag_info[i].frag_stride;
+
+	/* Page recycling works best if we have enough pages in the pool.
+	 * Apply a factor of two on the minimal allocations required to
+	 * populate RX rings.
+	 */
+retry:
+	total = 0;
+	pages_per_ring = new_size * stride_bytes * 2 / PAGE_SIZE;
+	pages_per_ring = roundup_pow_of_two(pages_per_ring);
+
+	order = min_t(u32, ilog2(pages_per_ring), MAX_ORDER - 1);
+
+	for (ring_ind = 0; ring_ind < priv->rx_ring_num; ring_ind++) {
+		ring = priv->rx_ring[ring_ind];
+		mlx4_en_free_rx_buf(priv, ring);
 
-	for (buf_ind = 0; buf_ind < priv->prof->rx_ring_size; buf_ind++) {
+		/* Note: use kvalloc() when available, no hurry */
+		ring->pool.array = kmalloc_node(sizeof(*ring->pool.array) *
+						pages_per_ring,
+						GFP_KERNEL, ring->node);
+		if (!ring->pool.array)
+			return -ENOMEM;
+		ring->pool.pool_idx = 0;
+		ring->pool.pool_size = 0;
+		ring->rx_alloc_order = ring->rx_pref_alloc_order = order;
+	}
+
+	for (page_ind = 0; page_ind < pages_per_ring; page_ind++) {
 		for (ring_ind = 0; ring_ind < priv->rx_ring_num; ring_ind++) {
-			ring = priv->rx_ring[ring_ind];
+			struct page *page;
+			dma_addr_t dma;
 
-			if (mlx4_en_prepare_rx_desc(priv, ring,
-						    ring->actual_size,
-						    GFP_KERNEL | __GFP_COLD)) {
-				if (ring->actual_size < MLX4_EN_MIN_RX_SIZE) {
-					en_err(priv, "Failed to allocate enough rx buffers\n");
-					return -ENOMEM;
-				} else {
-					new_size = rounddown_pow_of_two(ring->actual_size);
-					en_warn(priv, "Only %d buffers allocated reducing ring size to %d\n",
-						ring->actual_size, new_size);
-					goto reduce_rings;
-				}
-			}
-			ring->actual_size++;
-			ring->prod++;
+			ring = priv->rx_ring[ring_ind];
+			page = mlx4_alloc_page(priv, ring, &dma,
+					       ring->node, GFP_KERNEL);
+			if (!page)
+				goto fail;
+			ring->pool.array[page_ind].page = page;
+			ring->pool.array[page_ind].dma = dma;
+			ring->pool.pool_size = page_ind + 1;
+			total++;
+			cond_resched();
 		}
 	}
-	return 0;
 
-reduce_rings:
+	order = min_t(u32, ilog2(pages_per_ring >> 1), MAX_ORDER - 1);
+
 	for (ring_ind = 0; ring_ind < priv->rx_ring_num; ring_ind++) {
 		ring = priv->rx_ring[ring_ind];
-		while (ring->actual_size > new_size) {
-			ring->actual_size--;
-			ring->prod--;
-			mlx4_en_free_rx_desc(priv, ring, ring->actual_size);
-		}
-	}
+		ring->rx_alloc_order = ring->rx_pref_alloc_order = order;
 
-	return 0;
-}
+		memcpy(ring->frag_info, priv->frag_info,
+		       sizeof(priv->frag_info));
 
-static void mlx4_en_free_rx_buf(struct mlx4_en_priv *priv,
-				struct mlx4_en_rx_ring *ring)
-{
-	int index;
+		while (ring->actual_size < new_size) {
+			struct mlx4_en_frag_info *frag_info = ring->frag_info;
+			struct mlx4_en_rx_alloc *frags = ring->rx_info +
+					(ring->actual_size << priv->log_rx_info);
+
+			for (i = 0; i < priv->num_frags; i++, frag_info++, frags++) {
+				if (frag_info->frag_stride + frag_info->page_offset > PAGE_SIZE) {
+					struct mlx4_en_page *en_page;
+
+					en_page = &ring->pool.array[ring->pool.pool_idx];
+					frag_info->page_offset = priv->rx_headroom;
+					frag_info->dma = en_page->dma;
+					frag_info->page = en_page->page;
+					++ring->pool.pool_idx;
 
-	en_dbg(DRV, priv, "Freeing Rx buf - cons:%d prod:%d\n",
-	       ring->cons, ring->prod);
+					WARN_ON_ONCE(ring->pool.pool_idx >=
+						     ring->pool.pool_size);
+				}
+				frags->page = frag_info->page;
+				frags->dma = frag_info->dma;
+				frags->page_offset = frag_info->page_offset;
 
-	/* Unmap and free Rx buffers */
-	for (index = 0; index < ring->size; index++) {
-		en_dbg(DRV, priv, "Processing descriptor:%d\n", index);
-		mlx4_en_free_rx_desc(priv, ring, index);
+				frag_info->page_offset += frag_info->frag_stride;
+			}
+			mlx4_en_prepare_rx_desc(priv, ring, ring->actual_size);
+			ring->actual_size++;
+			ring->prod++;
+		}
 	}
-	ring->cons = 0;
-	ring->prod = 0;
+	return 0;
+fail:
+	new_size >>= 1;
+	if (new_size < MLX4_EN_MIN_RX_SIZE) {
+		en_err(priv, "Failed to allocate enough rx pages, got %u of them\n",
+		       total);
+		return -ENOMEM;
+	}
+	goto retry;
 }
 
 void mlx4_en_set_num_rx_rings(struct mlx4_en_dev *mdev)
@@ -277,6 +300,7 @@ int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
 		}
 	}
 
+	ring->node = node;
 	ring->prod = 0;
 	ring->cons = 0;
 	ring->size = size;
@@ -386,23 +410,21 @@ int mlx4_en_activate_rx_rings(struct mlx4_en_priv *priv)
 	return err;
 }
 
-/* We recover from out of memory by scheduling our napi poll
- * function (mlx4_en_process_cq), which tries to allocate
- * all missing RX buffers (call to mlx4_en_refill_rx_buffers).
+/* Under memory pressure, each ring->rx_alloc_order might be lowered
+ * to very small values. Periodically reset it to initial value for
+ * optimal allocations, in case stress is over.
  */
 void mlx4_en_recover_from_oom(struct mlx4_en_priv *priv)
 {
-	int ring;
+	struct mlx4_en_rx_ring *ring;
+	int ring_ind;
 
 	if (!priv->port_up)
 		return;
 
-	for (ring = 0; ring < priv->rx_ring_num; ring++) {
-		if (mlx4_en_is_ring_empty(priv->rx_ring[ring])) {
-			local_bh_disable();
-			napi_reschedule(&priv->rx_cq[ring]->napi);
-			local_bh_enable();
-		}
+	for (ring_ind = 0; ring_ind < priv->rx_ring_num; ring_ind++) {
+		ring = priv->rx_ring[ring_ind];
+		WRITE_ONCE(ring->rx_alloc_order, ring->rx_pref_alloc_order);
 	}
 }
 
@@ -413,15 +435,15 @@ void mlx4_en_recover_from_oom(struct mlx4_en_priv *priv)
  * this cache when it is sized to be a multiple of the napi budget.
  */
 bool mlx4_en_rx_recycle(struct mlx4_en_rx_ring *ring,
-			struct mlx4_en_rx_alloc *frame)
+			struct page *page, dma_addr_t dma)
 {
 	struct mlx4_en_page_cache *cache = &ring->page_cache;
 
 	if (cache->index >= MLX4_EN_CACHE_SIZE)
 		return false;
 
-	cache->buf[cache->index].page = frame->page;
-	cache->buf[cache->index].dma = frame->dma;
+	cache->buf[cache->index].page = page;
+	cache->buf[cache->index].dma = dma;
 	cache->index++;
 	return true;
 }
@@ -454,7 +476,7 @@ void mlx4_en_deactivate_rx_ring(struct mlx4_en_priv *priv,
 	for (i = 0; i < ring->page_cache.index; i++) {
 		dma_unmap_page(priv->ddev, ring->page_cache.buf[i].dma,
 			       PAGE_SIZE, priv->dma_dir);
-		put_page(ring->page_cache.buf[i].page);
+		__free_page(ring->page_cache.buf[i].page);
 	}
 	ring->page_cache.index = 0;
 	mlx4_en_free_rx_buf(priv, ring);
@@ -462,67 +484,95 @@ void mlx4_en_deactivate_rx_ring(struct mlx4_en_priv *priv,
 		ring->buf -= TXBB_SIZE;
 }
 
+static bool mlx4_page_is_reusable(struct page *page)
+{
+	return likely(page_count(page) == 1) &&
+	       likely(!page_is_pfmemalloc(page)) &&
+	       likely(page_to_nid(page) == numa_mem_id());
+}
 
-static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
-				    struct mlx4_en_rx_alloc *frags,
-				    struct sk_buff *skb,
-				    int length)
+static bool mlx4_replenish(struct mlx4_en_priv *priv,
+			   struct mlx4_en_rx_ring *ring,
+			   struct mlx4_en_frag_info *frag_info)
 {
-	const struct mlx4_en_frag_info *frag_info = priv->frag_info;
-	unsigned int truesize = 0;
-	int nr, frag_size;
+	struct mlx4_en_page *en_page = &ring->pool.array[ring->pool.pool_idx];
 	struct page *page;
 	dma_addr_t dma;
-	bool release;
 
-	/* Collect used fragments while replacing them in the HW descriptors */
-	for (nr = 0;; frags++) {
-		frag_size = min_t(int, length, frag_info->frag_size);
+	if (!mlx4_page_is_reusable(en_page->page)) {
+		page = mlx4_alloc_page(priv, ring, &dma, numa_mem_id(),
+				       GFP_ATOMIC | __GFP_MEMALLOC);
+		if (unlikely(!page)) {
+			/* Only drop incoming packet if previous page
+			 * can not be reused at all. NUMA placement is a hint,
+			 * pfmemalloc skbs will eventually be dropped if
+			 * necessary.
+			 */
+			if (page_count(en_page->page) != 1)
+				return false;
+		} else {
+			dma_unmap_page(priv->ddev, en_page->dma, PAGE_SIZE,
+				       priv->dma_dir);
+			__free_page(en_page->page);
+			en_page->page = page;
+			en_page->dma = dma;
+		}
+	}
+	frag_info->page_offset = priv->rx_headroom;
+	frag_info->page = en_page->page;
+	frag_info->dma = en_page->dma;
 
-		page = frags->page;
-		if (unlikely(!page))
-			goto fail;
+	if (unlikely(++ring->pool.pool_idx == ring->pool.pool_size))
+		ring->pool.pool_idx = 0;
 
-		dma = frags->dma;
-		dma_sync_single_range_for_cpu(priv->ddev, dma, frags->page_offset,
-					      frag_size, priv->dma_dir);
+	return true;
+}
 
-		__skb_fill_page_desc(skb, nr, page, frags->page_offset,
-				     frag_size);
+static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
+				    struct mlx4_en_rx_ring *ring,
+				    struct mlx4_en_rx_alloc *frags,
+				    struct sk_buff *skb,
+				    int length)
+{
+	struct mlx4_en_frag_info *frag_info = ring->frag_info;
+	int nr, frag_size;
 
-		truesize += frag_info->frag_stride;
-		if (frag_info->frag_stride == PAGE_SIZE / 2) {
-			frags->page_offset ^= PAGE_SIZE / 2;
-			release = page_count(page) != 1 ||
-				  page_is_pfmemalloc(page) ||
-				  page_to_nid(page) != numa_mem_id();
-		} else {
-			u32 sz_align = ALIGN(frag_size, SMP_CACHE_BYTES);
+	/* Make sure we can replenish RX ring with new page frags,
+	 * otherwise we drop this packet. Very sad but true.
+	 */
+	for (nr = 0; nr < priv->num_frags; nr++, frag_info++) {
+		if (frag_info->frag_stride + frag_info->page_offset <= PAGE_SIZE)
+			continue;
+		if (!mlx4_replenish(priv, ring, frag_info))
+			return -1;
+	}
+	frag_info = ring->frag_info;
 
-			frags->page_offset += sz_align;
-			release = frags->page_offset + frag_info->frag_size > PAGE_SIZE;
-		}
-		if (release) {
-			dma_unmap_page(priv->ddev, dma, PAGE_SIZE, priv->dma_dir);
-			frags->page = NULL;
-		} else {
-			page_ref_inc(page);
-		}
+	for (nr = 0;; frag_info++, frags++) {
+		frag_size = min_t(int, length, frag_info->frag_size);
 
-		nr++;
-		length -= frag_size;
-		if (!length)
+		if (frag_size) {
+			dma_sync_single_range_for_cpu(priv->ddev, frags->dma,
+						      frags->page_offset,
+						      frag_size,
+						      priv->dma_dir);
+
+			skb_fill_page_desc(skb, nr, frags->page,
+					   frags->page_offset,
+					   frag_size);
+			page_ref_inc(frags->page);
+			skb->truesize += frag_info->frag_stride;
+			length -= frag_size;
+		}
+		/* prepare what is needed for the next frame */
+		frags->page = frag_info->page;
+		frags->dma = frag_info->dma;
+		frags->page_offset = frag_info->page_offset;
+		frag_info->page_offset += frag_info->frag_stride;
+		if (++nr == priv->num_frags)
 			break;
-		frag_info++;
 	}
-	skb->truesize += truesize;
-	return nr;
 
-fail:
-	while (nr > 0) {
-		nr--;
-		__skb_frag_unref(skb_shinfo(skb)->frags + nr);
-	}
 	return 0;
 }
 
@@ -539,20 +589,16 @@ static void validate_loopback(struct mlx4_en_priv *priv, void *va)
 	priv->loopback_ok = 1;
 }
 
-static bool mlx4_en_refill_rx_buffers(struct mlx4_en_priv *priv,
-				      struct mlx4_en_rx_ring *ring)
+static bool mlx4_en_remap_rx_buffers(struct mlx4_en_priv *priv,
+				     struct mlx4_en_rx_ring *ring)
 {
 	u32 missing = ring->actual_size - (ring->prod - ring->cons);
 
-	/* Try to batch allocations, but not too much. */
 	if (missing < 8)
 		return false;
 	do {
-		if (mlx4_en_prepare_rx_desc(priv, ring,
-					    ring->prod & ring->size_mask,
-					    GFP_ATOMIC | __GFP_COLD |
-					    __GFP_MEMALLOC))
-			break;
+		mlx4_en_prepare_rx_desc(priv, ring,
+					ring->prod & ring->size_mask);
 		ring->prod++;
 	} while (--missing);
 
@@ -740,7 +786,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		 */
 		if (xdp_prog) {
 			struct xdp_buff xdp;
-			dma_addr_t dma;
+			struct page *npage;
+			dma_addr_t ndma, dma;
 			void *orig_data;
 			u32 act;
 
@@ -767,10 +814,30 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 			case XDP_PASS:
 				break;
 			case XDP_TX:
+				/* Make sure we have one page ready to replace this one */
+				npage = NULL;
+				if (!ring->page_cache.index) {
+					npage = mlx4_alloc_page(priv, ring,
+								&ndma, numa_mem_id(),
+								GFP_ATOMIC | __GFP_MEMALLOC);
+					if (!npage) {
+						ring->xdp_drop++;
+						goto next;
+					}
+				}
 				if (likely(!mlx4_en_xmit_frame(ring, frags, dev,
 							length, cq->ring,
 							&doorbell_pending))) {
-					frags[0].page = NULL;
+					if (ring->page_cache.index) {
+						u32 idx = --ring->page_cache.index;
+
+						frags[0].page = ring->page_cache.buf[idx].page;
+						frags[0].dma = ring->page_cache.buf[idx].dma;
+					} else {
+						frags[0].page = npage;
+						frags[0].dma = ndma;
+					}
+					frags[0].page_offset = XDP_PACKET_HEADROOM;
 					goto next;
 				}
 				trace_xdp_exception(dev, xdp_prog, act);
@@ -853,9 +920,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021AD),
 					       be16_to_cpu(cqe->sl_vid));
 
-		nr = mlx4_en_complete_rx_desc(priv, frags, skb, length);
-		if (likely(nr)) {
-			skb_shinfo(skb)->nr_frags = nr;
+		nr = mlx4_en_complete_rx_desc(priv, ring, frags, skb, length);
+		if (likely(nr >= 0)) {
 			skb->len = length;
 			skb->data_len = length;
 			napi_gro_frags(&cq->napi);
@@ -883,7 +949,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 	}
 	AVG_PERF_COUNTER(priv->pstats.rx_coal_avg, polled);
 
-	if (mlx4_en_refill_rx_buffers(priv, ring))
+	if (mlx4_en_remap_rx_buffers(priv, ring))
 		mlx4_en_update_rx_prod_db(ring);
 
 	return polled;
@@ -956,6 +1022,7 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
 		 * expense of more costly truesize accounting
 		 */
 		priv->frag_info[0].frag_stride = PAGE_SIZE;
+		priv->frag_info[0].page_offset = PAGE_SIZE;
 		priv->dma_dir = PCI_DMA_BIDIRECTIONAL;
 		priv->rx_headroom = XDP_PACKET_HEADROOM;
 		i = 1;
@@ -974,6 +1041,7 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
 				frag_size = min(frag_size, frag_size_max);
 
 			priv->frag_info[i].frag_size = frag_size;
+			priv->frag_info[i].page_offset = PAGE_SIZE;
 			frag_stride = ALIGN(frag_size, SMP_CACHE_BYTES);
 			/* We can only pack 2 1536-bytes frames in on 4K page
 			 * Therefore, each frame would consume more bytes (truesize)
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index e0c5ffb3e3a6607456e1f191b0b8c8becfc71219..76da4c33ae431dbf351699ee9010ea0452a41084 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -351,15 +351,12 @@ u32 mlx4_en_recycle_tx_desc(struct mlx4_en_priv *priv,
 			    int napi_mode)
 {
 	struct mlx4_en_tx_info *tx_info = &ring->tx_info[index];
-	struct mlx4_en_rx_alloc frame = {
-		.page = tx_info->page,
-		.dma = tx_info->map0_dma,
-	};
-
-	if (!mlx4_en_rx_recycle(ring->recycle_ring, &frame)) {
-		dma_unmap_page(priv->ddev, tx_info->map0_dma,
-			       PAGE_SIZE, priv->dma_dir);
-		put_page(tx_info->page);
+	struct page *page = tx_info->page;
+	dma_addr_t dma = tx_info->map0_dma;
+
+	if (!mlx4_en_rx_recycle(ring->recycle_ring, page, dma)) {
+		dma_unmap_page(priv->ddev, dma, PAGE_SIZE, priv->dma_dir);
+		__free_page(page);
 	}
 
 	return tx_info->nr_txbb;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 39f401aa30474e61c0b0029463b23a829ec35fa3..23e66b1eb6ddd4665339b238618dead537d2155e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -99,17 +99,13 @@
 
 #define MLX4_EN_WATCHDOG_TIMEOUT	(15 * HZ)
 
-/* Use the maximum between 16384 and a single page */
-#define MLX4_EN_ALLOC_SIZE	PAGE_ALIGN(16384)
-
 #define MLX4_EN_MAX_RX_FRAGS	4
 
 /* Maximum ring sizes */
 #define MLX4_EN_MAX_TX_SIZE	8192
 #define MLX4_EN_MAX_RX_SIZE	8192
 
-/* Minimum ring size for our page-allocation scheme to work */
-#define MLX4_EN_MIN_RX_SIZE	(MLX4_EN_ALLOC_SIZE / SMP_CACHE_BYTES)
+#define MLX4_EN_MIN_RX_SIZE	256
 #define MLX4_EN_MIN_TX_SIZE	(4096 / TXBB_SIZE)
 
 #define MLX4_EN_SMALL_PKT_SIZE		64
@@ -325,6 +321,30 @@ struct mlx4_en_rx_desc {
 	struct mlx4_wqe_data_seg data[0];
 };
 
+/* Each rx_ring has a pool of pages, with associated dma mapping.
+ * We try to recycle the pages, by keeping a reference on them.
+ */
+struct mlx4_en_page {
+	struct page	*page;
+	dma_addr_t	dma; /* might be kept in page_private() ? */
+};
+
+/* A page pool contains a fixed number of pages, and a current index.
+ */
+struct mlx4_en_page_pool {
+	unsigned int		pool_size;
+	unsigned int		pool_idx;
+	struct mlx4_en_page	*array;
+};
+
+struct mlx4_en_frag_info {
+	u16		frag_size;
+	u32		frag_stride;
+	struct page	*page;
+	dma_addr_t	dma;
+	u32		page_offset;
+};
+
 struct mlx4_en_rx_ring {
 	struct mlx4_hwq_resources wqres;
 	u32 size ;	/* number of Rx descs*/
@@ -337,22 +357,31 @@ struct mlx4_en_rx_ring {
 	u32 cons;
 	u32 buf_size;
 	u8  fcs_del;
+	u8  hwtstamp_rx_filter;
+	u16 node;
 	void *buf;
 	void *rx_info;
-	struct bpf_prog __rcu *xdp_prog;
-	struct mlx4_en_page_cache page_cache;
+	struct bpf_prog __rcu		*xdp_prog;
+	struct mlx4_en_page_pool	pool;
+	unsigned long			rx_alloc_pages;
+
+	struct page			*pre_allocated;
+	unsigned int			pre_allocated_count;
+	unsigned int			rx_alloc_order;
+	struct mlx4_en_frag_info	frag_info[MLX4_EN_MAX_RX_FRAGS];
+	struct mlx4_en_page_cache	page_cache;
+
 	unsigned long bytes;
 	unsigned long packets;
 	unsigned long csum_ok;
 	unsigned long csum_none;
 	unsigned long csum_complete;
-	unsigned long rx_alloc_pages;
 	unsigned long xdp_drop;
 	unsigned long xdp_tx;
 	unsigned long xdp_tx_full;
 	unsigned long dropped;
-	int hwtstamp_rx_filter;
 	cpumask_var_t affinity_mask;
+	unsigned int			rx_pref_alloc_order;
 };
 
 struct mlx4_en_cq {
@@ -462,11 +491,6 @@ struct mlx4_en_mc_list {
 	u64			tunnel_reg_id;
 };
 
-struct mlx4_en_frag_info {
-	u16 frag_size;
-	u32 frag_stride;
-};
-
 #ifdef CONFIG_MLX4_EN_DCB
 /* Minimal TC BW - setting to 0 will block traffic */
 #define MLX4_EN_BW_MIN 1
@@ -693,7 +717,7 @@ netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_ring *rx_ring,
 			       int tx_ind, int *doorbell_pending);
 void mlx4_en_xmit_doorbell(struct mlx4_en_tx_ring *ring);
 bool mlx4_en_rx_recycle(struct mlx4_en_rx_ring *ring,
-			struct mlx4_en_rx_alloc *frame);
+			struct page *page, dma_addr_t dma);
 
 int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 			   struct mlx4_en_tx_ring **pring,
-- 
2.12.0.246.ga2ecc84866-goog
