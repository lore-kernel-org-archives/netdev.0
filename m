From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 09/12] net/mlx5e: Generalize tx helper functions for different SQ types
Date: Sat, 25 Mar 2017 00:52:11 +0300
Message-ID: <20170324215214.25711-10-saeedm@mellanox.com>
References: <20170324215214.25711-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35764 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S936477AbdCXVwa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 17:52:30 -0400
In-Reply-To: <20170324215214.25711-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the next patches we will introduce different SQ types, for that we here
generalize some TX helper functions to work with more basic SQ parameters,
in order to re-use them for the different SQ types.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      | 35 ++++++++++++++++-----
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 13 +++++---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   | 10 +++---
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   | 37 +++++------------------
 4 files changed, 48 insertions(+), 47 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index f02d2cb8d148..50f895fa5f31 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -375,10 +375,10 @@ struct mlx5e_sq {
 	u8                         type;
 } ____cacheline_aligned_in_smp;
 
-static inline bool mlx5e_sq_has_room_for(struct mlx5e_sq *sq, u16 n)
+static inline bool
+mlx5e_wqc_has_room_for(struct mlx5_wq_cyc *wq, u16 cc, u16 pc, u16 n)
 {
-	return (((sq->wq.sz_m1 & (sq->cc - sq->pc)) >= n) ||
-		(sq->cc  == sq->pc));
+	return (((wq->sz_m1 & (cc - pc)) >= n) || (cc == pc));
 }
 
 struct mlx5e_dma_info {
@@ -721,7 +721,6 @@ struct mlx5e_priv {
 
 void mlx5e_build_ptys2ethtool_map(void);
 
-void mlx5e_send_nop(struct mlx5e_sq *sq, bool notify_hw);
 u16 mlx5e_select_queue(struct net_device *dev, struct sk_buff *skb,
 		       void *accel_priv, select_queue_fallback_t fallback);
 netdev_tx_t mlx5e_xmit(struct sk_buff *skb, struct net_device *dev);
@@ -807,20 +806,40 @@ void mlx5e_set_rx_cq_mode_params(struct mlx5e_params *params,
 				 u8 cq_period_mode);
 void mlx5e_set_rq_type_params(struct mlx5e_priv *priv, u8 rq_type);
 
-static inline void
-mlx5e_tx_notify_hw(struct mlx5e_sq *sq, struct mlx5_wqe_ctrl_seg *ctrl)
+static inline
+struct mlx5e_tx_wqe *mlx5e_post_nop(struct mlx5_wq_cyc *wq, u32 sqn, u16 *pc)
 {
+	u16                         pi   = *pc & wq->sz_m1;
+	struct mlx5e_tx_wqe        *wqe  = mlx5_wq_cyc_get_wqe(wq, pi);
+	struct mlx5_wqe_ctrl_seg   *cseg = &wqe->ctrl;
+
+	memset(cseg, 0, sizeof(*cseg));
+
+	cseg->opmod_idx_opcode = cpu_to_be32((*pc << 8) | MLX5_OPCODE_NOP);
+	cseg->qpn_ds           = cpu_to_be32((sqn << 8) | 0x01);
+
+	(*pc)++;
+
+	return wqe;
+}
+
+static inline
+void mlx5e_notify_hw(struct mlx5_wq_cyc *wq, u16 pc,
+		     void __iomem *uar_map,
+		     struct mlx5_wqe_ctrl_seg *ctrl)
+{
+	ctrl->fm_ce_se = MLX5_WQE_CTRL_CQ_UPDATE;
 	/* ensure wqe is visible to device before updating doorbell record */
 	dma_wmb();
 
-	*sq->wq.db = cpu_to_be32(sq->pc);
+	*wq->db = cpu_to_be32(pc);
 
 	/* ensure doorbell record is visible to device before ringing the
 	 * doorbell
 	 */
 	wmb();
 
-	mlx5_write64((__be32 *)ctrl, sq->uar_map, NULL);
+	mlx5_write64((__be32 *)ctrl, uar_map, NULL);
 }
 
 static inline void mlx5e_cq_arm(struct mlx5e_cq *cq)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index d39ee6669b8e..7faf2bcccfa6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -847,6 +847,7 @@ static int mlx5e_open_rq(struct mlx5e_channel *c,
 {
 	struct mlx5e_sq *sq = &c->icosq;
 	u16 pi = sq->pc & sq->wq.sz_m1;
+	struct mlx5e_tx_wqe *nopwqe;
 	int err;
 
 	err = mlx5e_create_rq(c, param, rq);
@@ -867,8 +868,9 @@ static int mlx5e_open_rq(struct mlx5e_channel *c,
 
 	sq->db.ico_wqe[pi].opcode     = MLX5_OPCODE_NOP;
 	sq->db.ico_wqe[pi].num_wqebbs = 1;
-	mlx5e_send_nop(sq, true); /* trigger mlx5e_post_rx_wqes() */
-
+	nopwqe = mlx5e_post_nop(&sq->wq, sq->sqn, &sq->pc);
+	mlx5e_notify_hw(&sq->wq, sq->pc, sq->uar_map, &nopwqe->ctrl);
+	sq->stats.nop++; /* TODO no need for SQ stats in ico */
 	return 0;
 
 err_disable_rq:
@@ -1202,9 +1204,12 @@ static void mlx5e_close_sq(struct mlx5e_sq *sq)
 		netif_tx_disable_queue(sq->txq);
 
 		/* last doorbell out, godspeed .. */
-		if (mlx5e_sq_has_room_for(sq, 1)) {
+		if (mlx5e_wqc_has_room_for(&sq->wq, sq->cc, sq->pc, 1)) {
+			struct mlx5e_tx_wqe *nop;
+
 			sq->db.txq.skb[(sq->pc & sq->wq.sz_m1)] = NULL;
-			mlx5e_send_nop(sq, true);
+			nop = mlx5e_post_nop(&sq->wq, sq->sqn, &sq->pc);
+			mlx5e_notify_hw(&sq->wq, sq->pc, sq->uar_map, &nop->ctrl);
 		}
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 1b50c54614ac..141dcc486063 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -341,7 +341,8 @@ static inline void mlx5e_post_umr_wqe(struct mlx5e_rq *rq, u16 ix)
 	while ((pi = (sq->pc & wq->sz_m1)) > sq->edge) {
 		sq->db.ico_wqe[pi].opcode = MLX5_OPCODE_NOP;
 		sq->db.ico_wqe[pi].num_wqebbs = 1;
-		mlx5e_send_nop(sq, false);
+		mlx5e_post_nop(wq, sq->sqn, &sq->pc);
+		sq->stats.nop++;
 	}
 
 	wqe = mlx5_wq_cyc_get_wqe(wq, pi);
@@ -353,7 +354,7 @@ static inline void mlx5e_post_umr_wqe(struct mlx5e_rq *rq, u16 ix)
 	sq->db.ico_wqe[pi].opcode = MLX5_OPCODE_UMR;
 	sq->db.ico_wqe[pi].num_wqebbs = num_wqebbs;
 	sq->pc += num_wqebbs;
-	mlx5e_tx_notify_hw(sq, &wqe->ctrl);
+	mlx5e_notify_hw(&sq->wq, sq->pc, sq->uar_map, &wqe->ctrl);
 }
 
 static int mlx5e_alloc_rx_umr_mpwqe(struct mlx5e_rq *rq,
@@ -645,8 +646,7 @@ static inline void mlx5e_xmit_xdp_doorbell(struct mlx5e_sq *sq)
 
 	wqe  = mlx5_wq_cyc_get_wqe(wq, pi);
 
-	wqe->ctrl.fm_ce_se = MLX5_WQE_CTRL_CQ_UPDATE;
-	mlx5e_tx_notify_hw(sq, &wqe->ctrl);
+	mlx5e_notify_hw(wq, sq->pc, sq->uar_map, &wqe->ctrl);
 }
 
 static inline bool mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
@@ -675,7 +675,7 @@ static inline bool mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
 		return false;
 	}
 
-	if (unlikely(!mlx5e_sq_has_room_for(sq, 1))) {
+	if (unlikely(!mlx5e_wqc_has_room_for(wq, sq->cc, sq->pc, 1))) {
 		if (sq->db.xdp.doorbell) {
 			/* SQ is full, ring doorbell */
 			mlx5e_xmit_xdp_doorbell(sq);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 7497b6ac4382..897eaea6f51f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -38,29 +38,6 @@
 #define MLX5E_SQ_STOP_ROOM (MLX5_SEND_WQE_MAX_WQEBBS +\
 			    MLX5E_SQ_NOPS_ROOM)
 
-void mlx5e_send_nop(struct mlx5e_sq *sq, bool notify_hw)
-{
-	struct mlx5_wq_cyc                *wq  = &sq->wq;
-
-	u16 pi = sq->pc & wq->sz_m1;
-	struct mlx5e_tx_wqe              *wqe  = mlx5_wq_cyc_get_wqe(wq, pi);
-
-	struct mlx5_wqe_ctrl_seg         *cseg = &wqe->ctrl;
-
-	memset(cseg, 0, sizeof(*cseg));
-
-	cseg->opmod_idx_opcode = cpu_to_be32((sq->pc << 8) | MLX5_OPCODE_NOP);
-	cseg->qpn_ds           = cpu_to_be32((sq->sqn << 8) | 0x01);
-
-	sq->pc++;
-	sq->stats.nop++;
-
-	if (notify_hw) {
-		cseg->fm_ce_se = MLX5_WQE_CTRL_CQ_UPDATE;
-		mlx5e_tx_notify_hw(sq, &wqe->ctrl);
-	}
-}
-
 static inline void mlx5e_tx_dma_unmap(struct device *pdev,
 				      struct mlx5e_sq_dma *dma)
 {
@@ -331,21 +308,21 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP))
 		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 
-	if (unlikely(!mlx5e_sq_has_room_for(sq, MLX5E_SQ_STOP_ROOM))) {
+	if (unlikely(!mlx5e_wqc_has_room_for(&sq->wq, sq->cc, sq->pc,
+					     MLX5E_SQ_STOP_ROOM))) {
 		netif_tx_stop_queue(sq->txq);
 		sq->stats.stopped++;
 	}
 
 	sq->stats.xmit_more += skb->xmit_more;
-	if (!skb->xmit_more || netif_xmit_stopped(sq->txq)) {
-		cseg->fm_ce_se = MLX5_WQE_CTRL_CQ_UPDATE;
-		mlx5e_tx_notify_hw(sq, &wqe->ctrl);
-	}
+	if (!skb->xmit_more || netif_xmit_stopped(sq->txq))
+		mlx5e_notify_hw(wq, sq->pc, sq->uar_map, cseg);
 
 	/* fill sq edge with nops to avoid wqe wrap around */
 	while ((pi = (sq->pc & wq->sz_m1)) > sq->edge) {
 		sq->db.txq.skb[pi] = NULL;
-		mlx5e_send_nop(sq, false);
+		mlx5e_post_nop(&sq->wq, sq->sqn, &sq->pc);
+		sq->stats.nop++;
 	}
 
 	return NETDEV_TX_OK;
@@ -456,7 +433,7 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget)
 	netdev_tx_completed_queue(sq->txq, npkts, nbytes);
 
 	if (netif_tx_queue_stopped(sq->txq) &&
-	    mlx5e_sq_has_room_for(sq, MLX5E_SQ_STOP_ROOM)) {
+	    mlx5e_wqc_has_room_for(&sq->wq, sq->cc, sq->pc, MLX5E_SQ_STOP_ROOM)) {
 		netif_tx_wake_queue(sq->txq);
 		sq->stats.wake++;
 	}
-- 
2.11.0
