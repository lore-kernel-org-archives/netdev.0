From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 01/15] net/mlx5e: Build SKB with exact frag_size
Date: Fri, 23 Jun 2017 17:26:08 +0300
Message-ID: <20170623142622.16565-2-saeedm@mellanox.com>
References: <20170623142622.16565-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54013 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753397AbdFWO1m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 10:27:42 -0400
In-Reply-To: <20170623142622.16565-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

Build the SKB over the receive packet instead of the
whole page. Getting the SKB's linear data and shared_info
closer improves locality.
In addition, this opens up the possibility to make use of
other parts of the page in the downstream page-reuse patch.

Fixes: 1bfecfca565c ("net/mlx5e: Build RX SKB on demand")
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      | 2 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 6 +-----
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   | 4 +++-
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 5d9ace493d85..6af1fbe62082 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -72,6 +72,8 @@
 #define MLX5E_PARAMS_MAXIMUM_LOG_RQ_SIZE_MPW            0x6
 
 #define MLX5_RX_HEADROOM NET_SKB_PAD
+#define MLX5_SKB_FRAG_SZ(len)	(SKB_DATA_ALIGN(len) +	\
+				 SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
 
 #define MLX5_MPWRQ_MIN_LOG_STRIDE_SZ(mdev) \
 	(6 + MLX5_CAP_GEN(mdev, cache_line_128byte)) /* HW restriction */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 167bca50320a..c991c1e9ea1f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -639,11 +639,7 @@ static int mlx5e_alloc_rq(struct mlx5e_channel *c,
 		byte_count = rq->buff.wqe_sz;
 
 		/* calc the required page order */
-		frag_sz = rq->rx_headroom +
-			  byte_count /* packet data */ +
-			  SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
-		frag_sz = SKB_DATA_ALIGN(frag_sz);
-
+		frag_sz = MLX5_SKB_FRAG_SZ(rq->rx_headroom + byte_count);
 		npages = DIV_ROUND_UP(frag_sz, PAGE_SIZE);
 		rq->buff.page_order = order_base_2(npages);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index abf6d2fcfe0f..2eef4e701ab3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -740,6 +740,7 @@ struct sk_buff *skb_from_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe,
 	void *va, *data;
 	u16 rx_headroom = rq->rx_headroom;
 	bool consumed;
+	u32 frag_size;
 
 	di             = &rq->dma_info[wqe_counter];
 	va             = page_address(di->page);
@@ -764,7 +765,8 @@ struct sk_buff *skb_from_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe,
 	if (consumed)
 		return NULL; /* page/packet was consumed by XDP */
 
-	skb = build_skb(va, RQ_PAGE_SIZE(rq));
+	frag_size = MLX5_SKB_FRAG_SZ(rx_headroom + cqe_bcnt);
+	skb = build_skb(va, frag_size);
 	if (unlikely(!skb)) {
 		rq->stats.buff_alloc_err++;
 		mlx5e_page_release(rq, di, true);
-- 
2.11.0
