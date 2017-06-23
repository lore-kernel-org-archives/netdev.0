From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 02/15] net/mlx5e: Enhance RX SKB headroom logic
Date: Fri, 23 Jun 2017 17:26:09 +0300
Message-ID: <20170623142622.16565-3-saeedm@mellanox.com>
References: <20170623142622.16565-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54027 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752006AbdFWO1m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 10:27:42 -0400
In-Reply-To: <20170623142622.16565-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

In the RX memory scheme of non Striding RQ, we use linear SKBs.
Keeping NET_IP_ALIGN in headroom can improve performance on some archs.
In addition, take this headroom into account when calculating the
LRO WQE size.

These are not needed in Striding RQ as they're done implicitly
within the non-linear SKB allocation.

Fixes: 1bfecfca565c ("net/mlx5e: Build RX SKB on demand")
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 14 ++++++--------
 2 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 6af1fbe62082..00ff2a1651e7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -217,6 +217,7 @@ struct mlx5e_cq_moder {
 struct mlx5e_params {
 	u8  log_sq_size;
 	u8  rq_wq_type;
+	u16 rq_headroom;
 	u8  mpwqe_log_stride_sz;
 	u8  mpwqe_log_num_strides;
 	u8  log_rq_size;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index c991c1e9ea1f..66173e5545ce 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -96,9 +96,12 @@ void mlx5e_set_rq_type_params(struct mlx5_core_dev *mdev,
 		params->log_rq_size = is_kdump_kernel() ?
 			MLX5E_PARAMS_MINIMUM_LOG_RQ_SIZE :
 			MLX5E_PARAMS_DEFAULT_LOG_RQ_SIZE;
+		params->rq_headroom = params->xdp_prog ?
+			XDP_PACKET_HEADROOM : MLX5_RX_HEADROOM;
+		params->rq_headroom += NET_IP_ALIGN;
 
 		/* Extra room needed for build_skb */
-		params->lro_wqe_sz -= MLX5_RX_HEADROOM +
+		params->lro_wqe_sz -= params->rq_headroom +
 			SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 	}
 
@@ -579,13 +582,8 @@ static int mlx5e_alloc_rq(struct mlx5e_channel *c,
 		goto err_rq_wq_destroy;
 	}
 
-	if (rq->xdp_prog) {
-		rq->buff.map_dir = DMA_BIDIRECTIONAL;
-		rq->rx_headroom = XDP_PACKET_HEADROOM;
-	} else {
-		rq->buff.map_dir = DMA_FROM_DEVICE;
-		rq->rx_headroom = MLX5_RX_HEADROOM;
-	}
+	rq->buff.map_dir = rq->xdp_prog ? DMA_BIDIRECTIONAL : DMA_FROM_DEVICE;
+	rq->rx_headroom = params->rq_headroom;
 
 	switch (rq->wq_type) {
 	case MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ:
-- 
2.11.0
