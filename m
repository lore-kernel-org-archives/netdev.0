From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 07/17] net/mlx5e: Early-return on empty completion queues
Date: Sun,  3 Sep 2017 07:21:07 +0300
Message-ID: <20170903042117.28923-8-saeedm@mellanox.com>
References: <20170903042117.28923-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:60018 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751082AbdICEWL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 00:22:11 -0400
In-Reply-To: <20170903042117.28923-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

NAPI context handles different kinds of completion queues
(RX, TX, and others). Hence, upon a poll trial, some of them
might be empty.
Here we early-return upon empty completion queues, as well as
full rx buffer, and save unnecessary logic and memory barriers.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c | 40 ++++++++++++++-----------
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c | 16 +++++-----
 2 files changed, 32 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 8af6577b7501..ab1213a3615e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -459,16 +459,19 @@ void mlx5e_dealloc_rx_mpwqe(struct mlx5e_rq *rq, u16 ix)
 bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq)
 {
 	struct mlx5_wq_ll *wq = &rq->wq;
+	int err;
 
 	if (unlikely(!test_bit(MLX5E_RQ_STATE_ENABLED, &rq->state)))
 		return false;
 
+	if (mlx5_wq_ll_is_full(wq))
+		return false;
+
 	if (test_bit(MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS, &rq->state))
 		return true;
 
-	while (!mlx5_wq_ll_is_full(wq)) {
+	do {
 		struct mlx5e_rx_wqe *wqe = mlx5_wq_ll_get_wqe(wq, wq->head);
-		int err;
 
 		err = rq->alloc_wqe(rq, wqe, wq->head);
 		if (err == -EBUSY)
@@ -479,14 +482,14 @@ bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq)
 		}
 
 		mlx5_wq_ll_push(wq, be16_to_cpu(wqe->next.next_wqe_index));
-	}
+	} while (!mlx5_wq_ll_is_full(wq));
 
 	/* ensure wqes are visible to device before updating doorbell record */
 	dma_wmb();
 
 	mlx5_wq_ll_update_db_record(wq);
 
-	return !mlx5_wq_ll_is_full(wq);
+	return !!err;
 }
 
 static void mlx5e_lro_update_hdr(struct sk_buff *skb, struct mlx5_cqe64 *cqe,
@@ -981,7 +984,8 @@ void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 {
 	struct mlx5e_rq *rq = container_of(cq, struct mlx5e_rq, cq);
-	struct mlx5e_xdpsq *xdpsq = &rq->xdpsq;
+	struct mlx5e_xdpsq *xdpsq;
+	struct mlx5_cqe64 *cqe;
 	int work_done = 0;
 
 	if (unlikely(!test_bit(MLX5E_RQ_STATE_ENABLED, &rq->state)))
@@ -990,12 +994,13 @@ int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 	if (cq->decmprs_left)
 		work_done += mlx5e_decompress_cqes_cont(rq, cq, 0, budget);
 
-	for (; work_done < budget; work_done++) {
-		struct mlx5_cqe64 *cqe = mlx5_cqwq_get_cqe(&cq->wq);
+	cqe = mlx5_cqwq_get_cqe(&cq->wq);
+	if (!cqe)
+		return 0;
 
-		if (!cqe)
-			break;
+	xdpsq = &rq->xdpsq;
 
+	do {
 		if (mlx5_get_cqe_format(cqe) == MLX5_COMPRESSED) {
 			work_done +=
 				mlx5e_decompress_cqes_start(rq, cq,
@@ -1006,7 +1011,7 @@ int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 		mlx5_cqwq_pop(&cq->wq);
 
 		rq->handle_rx_cqe(rq, cqe);
-	}
+	} while ((++work_done < budget) && (cqe = mlx5_cqwq_get_cqe(&cq->wq)));
 
 	if (xdpsq->db.doorbell) {
 		mlx5e_xmit_xdp_doorbell(xdpsq);
@@ -1024,6 +1029,7 @@ int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 bool mlx5e_poll_xdpsq_cq(struct mlx5e_cq *cq)
 {
 	struct mlx5e_xdpsq *sq;
+	struct mlx5_cqe64 *cqe;
 	struct mlx5e_rq *rq;
 	u16 sqcc;
 	int i;
@@ -1033,6 +1039,10 @@ bool mlx5e_poll_xdpsq_cq(struct mlx5e_cq *cq)
 	if (unlikely(!test_bit(MLX5E_SQ_STATE_ENABLED, &sq->state)))
 		return false;
 
+	cqe = mlx5_cqwq_get_cqe(&cq->wq);
+	if (!cqe)
+		return false;
+
 	rq = container_of(sq, struct mlx5e_rq, xdpsq);
 
 	/* sq->cc must be updated only after mlx5_cqwq_update_db_record(),
@@ -1040,15 +1050,11 @@ bool mlx5e_poll_xdpsq_cq(struct mlx5e_cq *cq)
 	 */
 	sqcc = sq->cc;
 
-	for (i = 0; i < MLX5E_TX_CQ_POLL_BUDGET; i++) {
-		struct mlx5_cqe64 *cqe;
+	i = 0;
+	do {
 		u16 wqe_counter;
 		bool last_wqe;
 
-		cqe = mlx5_cqwq_get_cqe(&cq->wq);
-		if (!cqe)
-			break;
-
 		mlx5_cqwq_pop(&cq->wq);
 
 		wqe_counter = be16_to_cpu(cqe->wqe_counter);
@@ -1066,7 +1072,7 @@ bool mlx5e_poll_xdpsq_cq(struct mlx5e_cq *cq)
 			/* Recycle RX page */
 			mlx5e_page_release(rq, di, true);
 		} while (!last_wqe);
-	}
+	} while ((++i < MLX5E_TX_CQ_POLL_BUDGET) && (cqe = mlx5_cqwq_get_cqe(&cq->wq)));
 
 	mlx5_cqwq_update_db_record(&cq->wq);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 31353e5c3c78..80d2121643ee 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -394,6 +394,7 @@ netdev_tx_t mlx5e_xmit(struct sk_buff *skb, struct net_device *dev)
 bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget)
 {
 	struct mlx5e_txqsq *sq;
+	struct mlx5_cqe64 *cqe;
 	u32 dma_fifo_cc;
 	u32 nbytes;
 	u16 npkts;
@@ -405,6 +406,10 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget)
 	if (unlikely(!test_bit(MLX5E_SQ_STATE_ENABLED, &sq->state)))
 		return false;
 
+	cqe = mlx5_cqwq_get_cqe(&cq->wq);
+	if (!cqe)
+		return false;
+
 	npkts = 0;
 	nbytes = 0;
 
@@ -416,15 +421,11 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget)
 	/* avoid dirtying sq cache line every cqe */
 	dma_fifo_cc = sq->dma_fifo_cc;
 
-	for (i = 0; i < MLX5E_TX_CQ_POLL_BUDGET; i++) {
-		struct mlx5_cqe64 *cqe;
+	i = 0;
+	do {
 		u16 wqe_counter;
 		bool last_wqe;
 
-		cqe = mlx5_cqwq_get_cqe(&cq->wq);
-		if (!cqe)
-			break;
-
 		mlx5_cqwq_pop(&cq->wq);
 
 		wqe_counter = be16_to_cpu(cqe->wqe_counter);
@@ -467,7 +468,8 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget)
 			sqcc += wi->num_wqebbs;
 			napi_consume_skb(skb, napi_budget);
 		} while (!last_wqe);
-	}
+
+	} while ((++i < MLX5E_TX_CQ_POLL_BUDGET) && (cqe = mlx5_cqwq_get_cqe(&cq->wq)));
 
 	mlx5_cqwq_update_db_record(&cq->wq);
 
-- 
2.13.0
