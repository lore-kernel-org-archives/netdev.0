From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 13/17] net/mlx5e: Don't recycle page if moved to far NUMA
Date: Sun,  3 Sep 2017 07:21:13 +0300
Message-ID: <20170903042117.28923-14-saeedm@mellanox.com>
References: <20170903042117.28923-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:60182 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751530AbdICEWS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 00:22:18 -0400
In-Reply-To: <20170903042117.28923-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

Avoid recycling an RX page if it moved to another NUMA node.
Add an ethtool counter to count such events.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    | 6 ++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h | 4 ++++
 3 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index a4c9a0a2c408..2da2ea222aaa 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -208,6 +208,7 @@ static void mlx5e_update_sw_counters(struct mlx5e_priv *priv)
 		s->rx_cache_full  += rq_stats->cache_full;
 		s->rx_cache_empty += rq_stats->cache_empty;
 		s->rx_cache_busy  += rq_stats->cache_busy;
+		s->rx_cache_waive += rq_stats->cache_waive;
 
 		for (j = 0; j < priv->channels.params.num_tc; j++) {
 			sq_stats = &c->sq[j].stats;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 88a8749c67d6..f1dd638384d3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -163,7 +163,7 @@ static inline u32 mlx5e_decompress_cqes_start(struct mlx5e_rq *rq,
 
 static inline bool mlx5e_page_is_reserved(struct page *page)
 {
-	return page_is_pfmemalloc(page) || page_to_nid(page) != numa_node_id();
+	return page_is_pfmemalloc(page) || page_to_nid(page) != numa_mem_id();
 }
 
 static inline bool mlx5e_rx_cache_put(struct mlx5e_rq *rq,
@@ -177,8 +177,10 @@ static inline bool mlx5e_rx_cache_put(struct mlx5e_rq *rq,
 		return false;
 	}
 
-	if (unlikely(page_is_pfmemalloc(dma_info->page)))
+	if (unlikely(mlx5e_page_is_reserved(dma_info->page))) {
+		rq->stats.cache_waive++;
 		return false;
+	}
 
 	cache->page_cache[cache->tail] = *dma_info;
 	cache->tail = tail_next;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
index 6761796e803c..6d199ffb1c0b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
@@ -84,6 +84,7 @@ struct mlx5e_sw_stats {
 	u64 rx_cache_full;
 	u64 rx_cache_empty;
 	u64 rx_cache_busy;
+	u64 rx_cache_waive;
 
 	/* Special handling counters */
 	u64 link_down_events_phy;
@@ -123,6 +124,7 @@ static const struct counter_desc sw_stats_desc[] = {
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_cache_full) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_cache_empty) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_cache_busy) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_cache_waive) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, link_down_events_phy) },
 };
 
@@ -354,6 +356,7 @@ struct mlx5e_rq_stats {
 	u64 cache_full;
 	u64 cache_empty;
 	u64 cache_busy;
+	u64 cache_waive;
 };
 
 static const struct counter_desc rq_stats_desc[] = {
@@ -377,6 +380,7 @@ static const struct counter_desc rq_stats_desc[] = {
 	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, cache_full) },
 	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, cache_empty) },
 	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, cache_busy) },
+	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, cache_waive) },
 };
 
 struct mlx5e_sq_stats {
-- 
2.13.0
