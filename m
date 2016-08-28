From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 4/9] net/mlx5e: Don't wait for SQ completions on close
Date: Mon, 29 Aug 2016 01:13:45 +0300
Message-ID: <1472422430-21583-5-git-send-email-saeedm@mellanox.com>
References: <1472422430-21583-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53044 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756028AbcH1WOe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2016 18:14:34 -0400
In-Reply-To: <1472422430-21583-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of asking the firmware to flush the SQ (Send Queue) via
asynchronous completions when moved to error, we handle SQ flush
manually (mlx5e_free_tx_descs) same as we did when SQ flush got
timed out or on tx_timeout.

This will reduce SQs flush time and speedup interface down procedure.

Moved mlx5e_free_tx_descs to the end of en_tx.c for tx
critical code locality.

Fixes: 29429f3300a3 ('net/mlx5e: Timeout if SQ doesn't flush during close')
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  3 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 38 ++-----------
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   | 67 +++++++++++------------
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c |  6 +-
 4 files changed, 44 insertions(+), 70 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 26a7ec7..bf722aa 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -369,9 +369,8 @@ struct mlx5e_sq_dma {
 };
 
 enum {
-	MLX5E_SQ_STATE_WAKE_TXQ_ENABLE,
+	MLX5E_SQ_STATE_FLUSH,
 	MLX5E_SQ_STATE_BF_ENABLE,
-	MLX5E_SQ_STATE_TX_TIMEOUT,
 };
 
 struct mlx5e_ico_wqe_info {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index e259eaa..297781a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -39,13 +39,6 @@
 #include "eswitch.h"
 #include "vxlan.h"
 
-enum {
-	MLX5_EN_QP_FLUSH_TIMEOUT_MS	= 5000,
-	MLX5_EN_QP_FLUSH_MSLEEP_QUANT	= 20,
-	MLX5_EN_QP_FLUSH_MAX_ITER	= MLX5_EN_QP_FLUSH_TIMEOUT_MS /
-					  MLX5_EN_QP_FLUSH_MSLEEP_QUANT,
-};
-
 struct mlx5e_rq_param {
 	u32			rqc[MLX5_ST_SZ_DW(rqc)];
 	struct mlx5_wq_param	wq;
@@ -827,7 +820,6 @@ static int mlx5e_open_sq(struct mlx5e_channel *c,
 		goto err_disable_sq;
 
 	if (sq->txq) {
-		set_bit(MLX5E_SQ_STATE_WAKE_TXQ_ENABLE, &sq->state);
 		netdev_tx_reset_queue(sq->txq);
 		netif_tx_start_queue(sq->txq);
 	}
@@ -851,38 +843,20 @@ static inline void netif_tx_disable_queue(struct netdev_queue *txq)
 
 static void mlx5e_close_sq(struct mlx5e_sq *sq)
 {
-	int tout = 0;
-	int err;
+	set_bit(MLX5E_SQ_STATE_FLUSH, &sq->state);
+	/* prevent netif_tx_wake_queue */
+	napi_synchronize(&sq->channel->napi);
 
 	if (sq->txq) {
-		clear_bit(MLX5E_SQ_STATE_WAKE_TXQ_ENABLE, &sq->state);
-		/* prevent netif_tx_wake_queue */
-		napi_synchronize(&sq->channel->napi);
 		netif_tx_disable_queue(sq->txq);
 
-		/* ensure hw is notified of all pending wqes */
+		/* last doorbell out, godspeed .. */
 		if (mlx5e_sq_has_room_for(sq, 1))
 			mlx5e_send_nop(sq, true);
-
-		err = mlx5e_modify_sq(sq, MLX5_SQC_STATE_RDY,
-				      MLX5_SQC_STATE_ERR, false, 0);
-		if (err)
-			set_bit(MLX5E_SQ_STATE_TX_TIMEOUT, &sq->state);
 	}
 
-	/* wait till sq is empty, unless a TX timeout occurred on this SQ */
-	while (sq->cc != sq->pc &&
-	       !test_bit(MLX5E_SQ_STATE_TX_TIMEOUT, &sq->state)) {
-		msleep(MLX5_EN_QP_FLUSH_MSLEEP_QUANT);
-		if (tout++ > MLX5_EN_QP_FLUSH_MAX_ITER)
-			set_bit(MLX5E_SQ_STATE_TX_TIMEOUT, &sq->state);
-	}
-
-	/* avoid destroying sq before mlx5e_poll_tx_cq() is done with it */
-	napi_synchronize(&sq->channel->napi);
-
-	mlx5e_free_tx_descs(sq);
 	mlx5e_disable_sq(sq);
+	mlx5e_free_tx_descs(sq);
 	mlx5e_destroy_sq(sq);
 }
 
@@ -2802,7 +2776,7 @@ static void mlx5e_tx_timeout(struct net_device *dev)
 		if (!netif_xmit_stopped(netdev_get_tx_queue(dev, i)))
 			continue;
 		sched_work = true;
-		set_bit(MLX5E_SQ_STATE_TX_TIMEOUT, &sq->state);
+		set_bit(MLX5E_SQ_STATE_FLUSH, &sq->state);
 		netdev_err(dev, "TX timeout on queue: %d, SQ: 0x%x, CQ: 0x%x, SQ Cons: 0x%x SQ Prod: 0x%x\n",
 			   i, sq->sqn, sq->cq.mcq.cqn, sq->cc, sq->pc);
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index e073bf59..5f209ad 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -394,35 +394,6 @@ netdev_tx_t mlx5e_xmit(struct sk_buff *skb, struct net_device *dev)
 	return mlx5e_sq_xmit(sq, skb);
 }
 
-void mlx5e_free_tx_descs(struct mlx5e_sq *sq)
-{
-	struct mlx5e_tx_wqe_info *wi;
-	struct sk_buff *skb;
-	u16 ci;
-	int i;
-
-	while (sq->cc != sq->pc) {
-		ci = sq->cc & sq->wq.sz_m1;
-		skb = sq->skb[ci];
-		wi = &sq->wqe_info[ci];
-
-		if (!skb) { /* nop */
-			sq->cc++;
-			continue;
-		}
-
-		for (i = 0; i < wi->num_dma; i++) {
-			struct mlx5e_sq_dma *dma =
-				mlx5e_dma_get(sq, sq->dma_fifo_cc++);
-
-			mlx5e_tx_dma_unmap(sq->pdev, dma);
-		}
-
-		dev_kfree_skb_any(skb);
-		sq->cc += wi->num_wqebbs;
-	}
-}
-
 bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget)
 {
 	struct mlx5e_sq *sq;
@@ -434,7 +405,7 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget)
 
 	sq = container_of(cq, struct mlx5e_sq, cq);
 
-	if (unlikely(test_bit(MLX5E_SQ_STATE_TX_TIMEOUT, &sq->state)))
+	if (unlikely(test_bit(MLX5E_SQ_STATE_FLUSH, &sq->state)))
 		return false;
 
 	npkts = 0;
@@ -512,11 +483,39 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget)
 	netdev_tx_completed_queue(sq->txq, npkts, nbytes);
 
 	if (netif_tx_queue_stopped(sq->txq) &&
-	    mlx5e_sq_has_room_for(sq, MLX5E_SQ_STOP_ROOM) &&
-	    likely(test_bit(MLX5E_SQ_STATE_WAKE_TXQ_ENABLE, &sq->state))) {
-				netif_tx_wake_queue(sq->txq);
-				sq->stats.wake++;
+	    mlx5e_sq_has_room_for(sq, MLX5E_SQ_STOP_ROOM)) {
+		netif_tx_wake_queue(sq->txq);
+		sq->stats.wake++;
 	}
 
 	return (i == MLX5E_TX_CQ_POLL_BUDGET);
 }
+
+void mlx5e_free_tx_descs(struct mlx5e_sq *sq)
+{
+	struct mlx5e_tx_wqe_info *wi;
+	struct sk_buff *skb;
+	u16 ci;
+	int i;
+
+	while (sq->cc != sq->pc) {
+		ci = sq->cc & sq->wq.sz_m1;
+		skb = sq->skb[ci];
+		wi = &sq->wqe_info[ci];
+
+		if (!skb) { /* nop */
+			sq->cc++;
+			continue;
+		}
+
+		for (i = 0; i < wi->num_dma; i++) {
+			struct mlx5e_sq_dma *dma =
+				mlx5e_dma_get(sq, sq->dma_fifo_cc++);
+
+			mlx5e_tx_dma_unmap(sq->pdev, dma);
+		}
+
+		dev_kfree_skb_any(skb);
+		sq->cc += wi->num_wqebbs;
+	}
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
index 64ae2e8..9bf33bb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
@@ -51,16 +51,18 @@ struct mlx5_cqe64 *mlx5e_get_cqe(struct mlx5e_cq *cq)
 
 static void mlx5e_poll_ico_cq(struct mlx5e_cq *cq)
 {
+	struct mlx5e_sq *sq = container_of(cq, struct mlx5e_sq, cq);
 	struct mlx5_wq_cyc *wq;
 	struct mlx5_cqe64 *cqe;
-	struct mlx5e_sq *sq;
 	u16 sqcc;
 
+	if (unlikely(test_bit(MLX5E_SQ_STATE_FLUSH, &sq->state)))
+		return;
+
 	cqe = mlx5e_get_cqe(cq);
 	if (likely(!cqe))
 		return;
 
-	sq = container_of(cq, struct mlx5e_sq, cq);
 	wq = &sq->wq;
 
 	/* sq->cc must be updated only after mlx5_cqwq_update_db_record(),
-- 
2.7.4
