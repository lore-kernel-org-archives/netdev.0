From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 10/17] net/mlx5e: Non-atomic RQ state indicator for UMR WQE in progress
Date: Sun,  3 Sep 2017 07:21:10 +0300
Message-ID: <20170903042117.28923-11-saeedm@mellanox.com>
References: <20170903042117.28923-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:60094 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750858AbdICEWO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 00:22:14 -0400
In-Reply-To: <20170903042117.28923-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

The indication for a UMR WQE in progress is needed only within
the NAPI context, and hence no races possible and no need for
the use of atomic operations.
The only place the flag is read outside of NAPI context is
in closure flow, after RQ is disabled flag is no more accessed
in NAPI.
Use a boolean instead of a bit in ring state, so that its
non-atomic set operations do not race with the atomic sets of
the other bits.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  3 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   | 10 +++++-----
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 0c4f1f30085a..bce2080eb86a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -291,7 +291,6 @@ struct mlx5e_tstamp {
 
 enum {
 	MLX5E_RQ_STATE_ENABLED,
-	MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS,
 	MLX5E_RQ_STATE_AM,
 };
 
@@ -539,6 +538,7 @@ struct mlx5e_rq {
 			void                  *mtt_no_align;
 			u16                    num_strides;
 			u8                     log_stride_sz;
+			bool                   umr_in_progress;
 		} mpwqe;
 	};
 	struct {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 411fb68794bc..2767a3ee81bc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -886,7 +886,8 @@ static void mlx5e_free_rx_descs(struct mlx5e_rq *rq)
 	u16 wqe_ix;
 
 	/* UMR WQE (if in progress) is always at wq->head */
-	if (test_bit(MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS, &rq->state))
+	if (rq->wq_type == MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ &&
+	    rq->mpwqe.umr_in_progress)
 		mlx5e_free_rx_mpwqe(rq, &rq->mpwqe.info[wq->head]);
 
 	while (!mlx5_wq_ll_is_empty(wq)) {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index a5522c3992a2..11dba9940029 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -422,7 +422,7 @@ void mlx5e_post_rx_mpwqe(struct mlx5e_rq *rq)
 	struct mlx5_wq_ll *wq = &rq->wq;
 	struct mlx5e_rx_wqe *wqe = mlx5_wq_ll_get_wqe(wq, wq->head);
 
-	clear_bit(MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS, &rq->state);
+	rq->mpwqe.umr_in_progress = false;
 
 	if (unlikely(!MLX5E_TEST_BIT(rq->state, MLX5E_RQ_STATE_ENABLED))) {
 		mlx5e_free_rx_mpwqe(rq, &rq->mpwqe.info[wq->head]);
@@ -441,10 +441,13 @@ int mlx5e_alloc_rx_mpwqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe, u16 ix)
 {
 	int err;
 
+	if (rq->mpwqe.umr_in_progress)
+		return -EBUSY;
+
 	err = mlx5e_alloc_rx_umr_mpwqe(rq, ix);
 	if (unlikely(err))
 		return err;
-	set_bit(MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS, &rq->state);
+	rq->mpwqe.umr_in_progress = true;
 	mlx5e_post_umr_wqe(rq, ix);
 	return -EBUSY;
 }
@@ -467,9 +470,6 @@ bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq)
 	if (mlx5_wq_ll_is_full(wq))
 		return false;
 
-	if (test_bit(MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS, &rq->state))
-		return true;
-
 	do {
 		struct mlx5e_rx_wqe *wqe = mlx5_wq_ll_get_wqe(wq, wq->head);
 
-- 
2.13.0
