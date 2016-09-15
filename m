From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 3/3] net/mlx5e: Implement RX mapped page cache for page recycle
Date: Thu, 15 Sep 2016 16:08:38 +0300
Message-ID: <1473944918-31290-4-git-send-email-tariqt@mellanox.com>
References: <1473944918-31290-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:50123 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753319AbcIONJI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 09:09:08 -0400
In-Reply-To: <1473944918-31290-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of reallocating and mapping pages for RX data-path,
recycle already used pages in a per ring cache.

Performance tests:
The following results were measured on a freshly booted system,
giving optimal baseline performance, as high-order pages are yet to
be fragmented and depleted.

We ran pktgen single-stream benchmarks, with iptables-raw-drop:

Single stride, 64 bytes:
* 4,739,057 - baseline
* 4,749,550 - order0 no cache
* 4,786,899 - order0 with cache
1% gain

Larger packets, no page cross, 1024 bytes:
* 3,982,361 - baseline
* 3,845,682 - order0 no cache
* 4,127,852 - order0 with cache
3.7% gain

Larger packets, every 3rd packet crosses a page, 1500 bytes:
* 3,731,189 - baseline
* 3,579,414 - order0 no cache
* 3,931,708 - order0 with cache
5.4% gain

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       | 16 ++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 15 ++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    | 57 ++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h | 16 ++++++
 4 files changed, 99 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 401b2f7b165f..7dd4763e726e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -287,6 +287,18 @@ struct mlx5e_rx_am { /* Adaptive Moderation */
 	u8					tired;
 };
 
+/* a single cache unit is capable to serve one napi call (for non-striding rq)
+ * or a MPWQE (for striding rq).
+ */
+#define MLX5E_CACHE_UNIT	(MLX5_MPWRQ_PAGES_PER_WQE > NAPI_POLL_WEIGHT ? \
+				 MLX5_MPWRQ_PAGES_PER_WQE : NAPI_POLL_WEIGHT)
+#define MLX5E_CACHE_SIZE	(2 * roundup_pow_of_two(MLX5E_CACHE_UNIT))
+struct mlx5e_page_cache {
+	u32 head;
+	u32 tail;
+	struct mlx5e_dma_info page_cache[MLX5E_CACHE_SIZE];
+};
+
 struct mlx5e_rq {
 	/* data path */
 	struct mlx5_wq_ll      wq;
@@ -301,6 +313,8 @@ struct mlx5e_rq {
 	struct mlx5e_tstamp   *tstamp;
 	struct mlx5e_rq_stats  stats;
 	struct mlx5e_cq        cq;
+	struct mlx5e_page_cache page_cache;
+
 	mlx5e_fp_handle_rx_cqe handle_rx_cqe;
 	mlx5e_fp_alloc_wqe     alloc_wqe;
 	mlx5e_fp_dealloc_wqe   dealloc_wqe;
@@ -651,6 +665,8 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget);
 int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget);
 void mlx5e_free_tx_descs(struct mlx5e_sq *sq);
 
+void mlx5e_page_release(struct mlx5e_rq *rq, struct mlx5e_dma_info *dma_info,
+			bool recycle);
 void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe);
 void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe);
 bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 136554b77c3b..8595b507e200 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -141,6 +141,10 @@ static void mlx5e_update_sw_counters(struct mlx5e_priv *priv)
 		s->rx_buff_alloc_err += rq_stats->buff_alloc_err;
 		s->rx_cqe_compress_blks += rq_stats->cqe_compress_blks;
 		s->rx_cqe_compress_pkts += rq_stats->cqe_compress_pkts;
+		s->rx_cache_reuse += rq_stats->cache_reuse;
+		s->rx_cache_full  += rq_stats->cache_full;
+		s->rx_cache_empty += rq_stats->cache_empty;
+		s->rx_cache_busy  += rq_stats->cache_busy;
 
 		for (j = 0; j < priv->params.num_tc; j++) {
 			sq_stats = &priv->channel[i]->sq[j].stats;
@@ -475,6 +479,9 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 	INIT_WORK(&rq->am.work, mlx5e_rx_am_work);
 	rq->am.mode = priv->params.rx_cq_period_mode;
 
+	rq->page_cache.head = 0;
+	rq->page_cache.tail = 0;
+
 	return 0;
 
 err_rq_wq_destroy:
@@ -485,6 +492,8 @@ err_rq_wq_destroy:
 
 static void mlx5e_destroy_rq(struct mlx5e_rq *rq)
 {
+	int i;
+
 	switch (rq->wq_type) {
 	case MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ:
 		mlx5e_rq_free_mpwqe_info(rq);
@@ -493,6 +502,12 @@ static void mlx5e_destroy_rq(struct mlx5e_rq *rq)
 		kfree(rq->skb);
 	}
 
+	for (i = rq->page_cache.head; i != rq->page_cache.tail;
+	     i = (i + 1) & (MLX5E_CACHE_SIZE - 1)) {
+		struct mlx5e_dma_info *dma_info = &rq->page_cache.page_cache[i];
+
+		mlx5e_page_release(rq, dma_info, false);
+	}
 	mlx5_wq_destroy(&rq->wq_ctrl);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 0c34daa04c43..dc8677933f76 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -305,11 +305,55 @@ static inline void mlx5e_post_umr_wqe(struct mlx5e_rq *rq, u16 ix)
 	mlx5e_tx_notify_hw(sq, &wqe->ctrl, 0);
 }
 
+static inline bool mlx5e_rx_cache_put(struct mlx5e_rq *rq,
+				      struct mlx5e_dma_info *dma_info)
+{
+	struct mlx5e_page_cache *cache = &rq->page_cache;
+	u32 tail_next = (cache->tail + 1) & (MLX5E_CACHE_SIZE - 1);
+
+	if (tail_next == cache->head) {
+		rq->stats.cache_full++;
+		return false;
+	}
+
+	cache->page_cache[cache->tail] = *dma_info;
+	cache->tail = tail_next;
+	return true;
+}
+
+static inline bool mlx5e_rx_cache_get(struct mlx5e_rq *rq,
+				      struct mlx5e_dma_info *dma_info)
+{
+	struct mlx5e_page_cache *cache = &rq->page_cache;
+
+	if (unlikely(cache->head == cache->tail)) {
+		rq->stats.cache_empty++;
+		return false;
+	}
+
+	if (page_ref_count(cache->page_cache[cache->head].page) != 1) {
+		rq->stats.cache_busy++;
+		return false;
+	}
+
+	*dma_info = cache->page_cache[cache->head];
+	cache->head = (cache->head + 1) & (MLX5E_CACHE_SIZE - 1);
+	rq->stats.cache_reuse++;
+
+	dma_sync_single_for_device(rq->pdev, dma_info->addr, PAGE_SIZE,
+				   DMA_FROM_DEVICE);
+	return true;
+}
+
 static inline int mlx5e_page_alloc_mapped(struct mlx5e_rq *rq,
 					  struct mlx5e_dma_info *dma_info)
 {
-	struct page *page = dev_alloc_page();
+	struct page *page;
+
+	if (mlx5e_rx_cache_get(rq, dma_info))
+		return 0;
 
+	page = dev_alloc_page();
 	if (unlikely(!page))
 		return -ENOMEM;
 
@@ -324,9 +368,12 @@ static inline int mlx5e_page_alloc_mapped(struct mlx5e_rq *rq,
 	return 0;
 }
 
-static inline void mlx5e_page_release(struct mlx5e_rq *rq,
-				      struct mlx5e_dma_info *dma_info)
+void mlx5e_page_release(struct mlx5e_rq *rq, struct mlx5e_dma_info *dma_info,
+			bool recycle)
 {
+	if (likely(recycle) && mlx5e_rx_cache_put(rq, dma_info))
+		return;
+
 	dma_unmap_page(rq->pdev, dma_info->addr, PAGE_SIZE, DMA_FROM_DEVICE);
 	put_page(dma_info->page);
 }
@@ -362,7 +409,7 @@ err_unmap:
 		struct mlx5e_dma_info *dma_info = &wi->umr.dma_info[i];
 
 		page_ref_sub(dma_info->page, pg_strides);
-		mlx5e_page_release(rq, dma_info);
+		mlx5e_page_release(rq, dma_info, true);
 	}
 
 	return err;
@@ -377,7 +424,7 @@ void mlx5e_free_rx_mpwqe(struct mlx5e_rq *rq, struct mlx5e_mpw_info *wi)
 		struct mlx5e_dma_info *dma_info = &wi->umr.dma_info[i];
 
 		page_ref_sub(dma_info->page, pg_strides - wi->skbs_frags[i]);
-		mlx5e_page_release(rq, dma_info);
+		mlx5e_page_release(rq, dma_info, true);
 	}
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
index 1f56543feb63..6af8d79e8c2a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
@@ -76,6 +76,10 @@ struct mlx5e_sw_stats {
 	u64 rx_buff_alloc_err;
 	u64 rx_cqe_compress_blks;
 	u64 rx_cqe_compress_pkts;
+	u64 rx_cache_reuse;
+	u64 rx_cache_full;
+	u64 rx_cache_empty;
+	u64 rx_cache_busy;
 
 	/* Special handling counters */
 	u64 link_down_events_phy;
@@ -107,6 +111,10 @@ static const struct counter_desc sw_stats_desc[] = {
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_buff_alloc_err) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_cqe_compress_blks) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_cqe_compress_pkts) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_cache_reuse) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_cache_full) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_cache_empty) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_cache_busy) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, link_down_events_phy) },
 };
 
@@ -275,6 +283,10 @@ struct mlx5e_rq_stats {
 	u64 buff_alloc_err;
 	u64 cqe_compress_blks;
 	u64 cqe_compress_pkts;
+	u64 cache_reuse;
+	u64 cache_full;
+	u64 cache_empty;
+	u64 cache_busy;
 };
 
 static const struct counter_desc rq_stats_desc[] = {
@@ -290,6 +302,10 @@ static const struct counter_desc rq_stats_desc[] = {
 	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, buff_alloc_err) },
 	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, cqe_compress_blks) },
 	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, cqe_compress_pkts) },
+	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, cache_reuse) },
+	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, cache_full) },
+	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, cache_empty) },
+	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, cache_busy) },
 };
 
 struct mlx5e_sq_stats {
-- 
1.8.3.1
