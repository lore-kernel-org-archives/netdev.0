From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 05/17] net/mlx5e: Small enhancements for RX MPWQE allocation and free
Date: Sun,  3 Sep 2017 07:21:05 +0300
Message-ID: <20170903042117.28923-6-saeedm@mellanox.com>
References: <20170903042117.28923-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:59998 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751070AbdICEWL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 00:22:11 -0400
In-Reply-To: <20170903042117.28923-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

The dma offset of a MPWQE (Multi-Packet WQE) in memory region
is fixed for all rounds. Calculate it once on creation time,
instead of in runtime. This also obsoletes the wqe argument in
the function.

In addition, optimize dma_info iterator calculation.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  6 ++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   | 18 ++++++------------
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 591e0dca9671..5aa4681f7c3c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -674,6 +674,12 @@ static int mlx5e_alloc_rq(struct mlx5e_channel *c,
 	for (i = 0; i < wq_sz; i++) {
 		struct mlx5e_rx_wqe *wqe = mlx5_wq_ll_get_wqe(&rq->wq, i);
 
+		if (rq->wq_type == MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ) {
+			u64 dma_offset = (u64)mlx5e_get_wqe_mtt_offset(rq, i) << PAGE_SHIFT;
+
+			wqe->data.addr = cpu_to_be64(dma_offset);
+		}
+
 		wqe->data.byte_count = cpu_to_be32(byte_count);
 		wqe->data.lkey = rq->mkey_be;
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index db372dcecbe0..fb3b83609aea 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -374,18 +374,15 @@ static inline void mlx5e_post_umr_wqe(struct mlx5e_rq *rq, u16 ix)
 }
 
 static int mlx5e_alloc_rx_umr_mpwqe(struct mlx5e_rq *rq,
-				    struct mlx5e_rx_wqe *wqe,
 				    u16 ix)
 {
 	struct mlx5e_mpw_info *wi = &rq->mpwqe.info[ix];
-	u64 dma_offset = (u64)mlx5e_get_wqe_mtt_offset(rq, ix) << PAGE_SHIFT;
 	int pg_strides = mlx5e_mpwqe_strides_per_page(rq);
+	struct mlx5e_dma_info *dma_info = &wi->umr.dma_info[0];
 	int err;
 	int i;
 
-	for (i = 0; i < MLX5_MPWRQ_PAGES_PER_WQE; i++) {
-		struct mlx5e_dma_info *dma_info = &wi->umr.dma_info[i];
-
+	for (i = 0; i < MLX5_MPWRQ_PAGES_PER_WQE; i++, dma_info++) {
 		err = mlx5e_page_alloc_mapped(rq, dma_info);
 		if (unlikely(err))
 			goto err_unmap;
@@ -395,14 +392,12 @@ static int mlx5e_alloc_rx_umr_mpwqe(struct mlx5e_rq *rq,
 
 	memset(wi->skbs_frags, 0, sizeof(*wi->skbs_frags) * MLX5_MPWRQ_PAGES_PER_WQE);
 	wi->consumed_strides = 0;
-	wqe->data.addr = cpu_to_be64(dma_offset);
 
 	return 0;
 
 err_unmap:
 	while (--i >= 0) {
-		struct mlx5e_dma_info *dma_info = &wi->umr.dma_info[i];
-
+		dma_info--;
 		page_ref_sub(dma_info->page, pg_strides);
 		mlx5e_page_release(rq, dma_info, true);
 	}
@@ -413,11 +408,10 @@ static int mlx5e_alloc_rx_umr_mpwqe(struct mlx5e_rq *rq,
 void mlx5e_free_rx_mpwqe(struct mlx5e_rq *rq, struct mlx5e_mpw_info *wi)
 {
 	int pg_strides = mlx5e_mpwqe_strides_per_page(rq);
+	struct mlx5e_dma_info *dma_info = &wi->umr.dma_info[0];
 	int i;
 
-	for (i = 0; i < MLX5_MPWRQ_PAGES_PER_WQE; i++) {
-		struct mlx5e_dma_info *dma_info = &wi->umr.dma_info[i];
-
+	for (i = 0; i < MLX5_MPWRQ_PAGES_PER_WQE; i++, dma_info++) {
 		page_ref_sub(dma_info->page, pg_strides - wi->skbs_frags[i]);
 		mlx5e_page_release(rq, dma_info, true);
 	}
@@ -447,7 +441,7 @@ int mlx5e_alloc_rx_mpwqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe, u16 ix)
 {
 	int err;
 
-	err = mlx5e_alloc_rx_umr_mpwqe(rq, wqe, ix);
+	err = mlx5e_alloc_rx_umr_mpwqe(rq, ix);
 	if (unlikely(err))
 		return err;
 	set_bit(MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS, &rq->state);
-- 
2.13.0
