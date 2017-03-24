From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 04/12] net/mlx5e: Move XDP completion functions to rx file
Date: Sat, 25 Mar 2017 00:52:06 +0300
Message-ID: <20170324215214.25711-5-saeedm@mellanox.com>
References: <20170324215214.25711-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35748 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S934739AbdCXVwY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 17:52:24 -0400
In-Reply-To: <20170324215214.25711-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

XDP code belongs to RX path, move mlx5e_poll_xdp_tx_cq and
mlx5e_free_xdp_tx_descs to en_rx.c.

Rename them to mlx5e_poll_xdpsq_cq and mlx5e_free_xdpsq_descs.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  2 +
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   | 82 +++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   | 24 +------
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c | 62 +----------------
 4 files changed, 86 insertions(+), 84 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 22e4bad03f05..fce0eca0701c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -737,6 +737,8 @@ void mlx5e_cq_error_event(struct mlx5_core_cq *mcq, enum mlx5_event event);
 int mlx5e_napi_poll(struct napi_struct *napi, int budget);
 bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget);
 int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget);
+bool mlx5e_poll_xdpsq_cq(struct mlx5e_cq *cq);
+void mlx5e_free_xdpsq_descs(struct mlx5e_sq *sq);
 void mlx5e_free_sq_descs(struct mlx5e_sq *sq);
 
 void mlx5e_page_release(struct mlx5e_rq *rq, struct mlx5e_dma_info *dma_info,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 873b3085756c..bc74d6032a5c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -989,3 +989,85 @@ int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 
 	return work_done;
 }
+
+bool mlx5e_poll_xdpsq_cq(struct mlx5e_cq *cq)
+{
+	struct mlx5e_sq *sq;
+	u16 sqcc;
+	int i;
+
+	sq = container_of(cq, struct mlx5e_sq, cq);
+
+	if (unlikely(!test_bit(MLX5E_SQ_STATE_ENABLED, &sq->state)))
+		return false;
+
+	/* sq->cc must be updated only after mlx5_cqwq_update_db_record(),
+	 * otherwise a cq overrun may occur
+	 */
+	sqcc = sq->cc;
+
+	for (i = 0; i < MLX5E_TX_CQ_POLL_BUDGET; i++) {
+		struct mlx5_cqe64 *cqe;
+		u16 wqe_counter;
+		bool last_wqe;
+
+		cqe = mlx5e_get_cqe(cq);
+		if (!cqe)
+			break;
+
+		mlx5_cqwq_pop(&cq->wq);
+
+		wqe_counter = be16_to_cpu(cqe->wqe_counter);
+
+		do {
+			struct mlx5e_sq_wqe_info *wi;
+			struct mlx5e_dma_info *di;
+			u16 ci;
+
+			last_wqe = (sqcc == wqe_counter);
+
+			ci = sqcc & sq->wq.sz_m1;
+			di = &sq->db.xdp.di[ci];
+			wi = &sq->db.xdp.wqe_info[ci];
+
+			if (unlikely(wi->opcode == MLX5_OPCODE_NOP)) {
+				sqcc++;
+				continue;
+			}
+
+			sqcc += wi->num_wqebbs;
+			/* Recycle RX page */
+			mlx5e_page_release(&sq->channel->rq, di, true);
+		} while (!last_wqe);
+	}
+
+	mlx5_cqwq_update_db_record(&cq->wq);
+
+	/* ensure cq space is freed before enabling more cqes */
+	wmb();
+
+	sq->cc = sqcc;
+	return (i == MLX5E_TX_CQ_POLL_BUDGET);
+}
+
+void mlx5e_free_xdpsq_descs(struct mlx5e_sq *sq)
+{
+	struct mlx5e_sq_wqe_info *wi;
+	struct mlx5e_dma_info *di;
+	u16 ci;
+
+	while (sq->cc != sq->pc) {
+		ci = sq->cc & sq->wq.sz_m1;
+		di = &sq->db.xdp.di[ci];
+		wi = &sq->db.xdp.wqe_info[ci];
+
+		if (wi->opcode == MLX5_OPCODE_NOP) {
+			sq->cc++;
+			continue;
+		}
+
+		sq->cc += wi->num_wqebbs;
+
+		mlx5e_page_release(&sq->channel->rq, di, false);
+	}
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index eec4354208ee..7497b6ac4382 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -493,28 +493,6 @@ static void mlx5e_free_txq_sq_descs(struct mlx5e_sq *sq)
 	}
 }
 
-static void mlx5e_free_xdp_sq_descs(struct mlx5e_sq *sq)
-{
-	struct mlx5e_sq_wqe_info *wi;
-	struct mlx5e_dma_info *di;
-	u16 ci;
-
-	while (sq->cc != sq->pc) {
-		ci = sq->cc & sq->wq.sz_m1;
-		di = &sq->db.xdp.di[ci];
-		wi = &sq->db.xdp.wqe_info[ci];
-
-		if (wi->opcode == MLX5_OPCODE_NOP) {
-			sq->cc++;
-			continue;
-		}
-
-		sq->cc += wi->num_wqebbs;
-
-		mlx5e_page_release(&sq->channel->rq, di, false);
-	}
-}
-
 void mlx5e_free_sq_descs(struct mlx5e_sq *sq)
 {
 	switch (sq->type) {
@@ -522,7 +500,7 @@ void mlx5e_free_sq_descs(struct mlx5e_sq *sq)
 		mlx5e_free_txq_sq_descs(sq);
 		break;
 	case MLX5E_SQ_XDP:
-		mlx5e_free_xdp_sq_descs(sq);
+		mlx5e_free_xdpsq_descs(sq);
 		break;
 	}
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
index d8cda2f6239b..f23dedc58175 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
@@ -105,66 +105,6 @@ static void mlx5e_poll_ico_cq(struct mlx5e_cq *cq)
 	sq->cc = sqcc;
 }
 
-static inline bool mlx5e_poll_xdp_tx_cq(struct mlx5e_cq *cq)
-{
-	struct mlx5e_sq *sq;
-	u16 sqcc;
-	int i;
-
-	sq = container_of(cq, struct mlx5e_sq, cq);
-
-	if (unlikely(!test_bit(MLX5E_SQ_STATE_ENABLED, &sq->state)))
-		return false;
-
-	/* sq->cc must be updated only after mlx5_cqwq_update_db_record(),
-	 * otherwise a cq overrun may occur
-	 */
-	sqcc = sq->cc;
-
-	for (i = 0; i < MLX5E_TX_CQ_POLL_BUDGET; i++) {
-		struct mlx5_cqe64 *cqe;
-		u16 wqe_counter;
-		bool last_wqe;
-
-		cqe = mlx5e_get_cqe(cq);
-		if (!cqe)
-			break;
-
-		mlx5_cqwq_pop(&cq->wq);
-
-		wqe_counter = be16_to_cpu(cqe->wqe_counter);
-
-		do {
-			struct mlx5e_sq_wqe_info *wi;
-			struct mlx5e_dma_info *di;
-			u16 ci;
-
-			last_wqe = (sqcc == wqe_counter);
-
-			ci = sqcc & sq->wq.sz_m1;
-			di = &sq->db.xdp.di[ci];
-			wi = &sq->db.xdp.wqe_info[ci];
-
-			if (unlikely(wi->opcode == MLX5_OPCODE_NOP)) {
-				sqcc++;
-				continue;
-			}
-
-			sqcc += wi->num_wqebbs;
-			/* Recycle RX page */
-			mlx5e_page_release(&sq->channel->rq, di, true);
-		} while (!last_wqe);
-	}
-
-	mlx5_cqwq_update_db_record(&cq->wq);
-
-	/* ensure cq space is freed before enabling more cqes */
-	wmb();
-
-	sq->cc = sqcc;
-	return (i == MLX5E_TX_CQ_POLL_BUDGET);
-}
-
 int mlx5e_napi_poll(struct napi_struct *napi, int budget)
 {
 	struct mlx5e_channel *c = container_of(napi, struct mlx5e_channel,
@@ -182,7 +122,7 @@ int mlx5e_napi_poll(struct napi_struct *napi, int budget)
 	busy |= work_done == budget;
 
 	if (c->xdp)
-		busy |= mlx5e_poll_xdp_tx_cq(&c->xdp_sq.cq);
+		busy |= mlx5e_poll_xdpsq_cq(&c->xdp_sq.cq);
 
 	mlx5e_poll_ico_cq(&c->icosq.cq);
 
-- 
2.11.0
