From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 2/9] net/mlx5e: Don't wait for RQ completions on close
Date: Mon, 29 Aug 2016 01:13:43 +0300
Message-ID: <1472422430-21583-3-git-send-email-saeedm@mellanox.com>
References: <1472422430-21583-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53050 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756151AbcH1WOh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2016 18:14:37 -0400
In-Reply-To: <1472422430-21583-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will significantly reduce receive queue flush time on interface
down.

Instead of asking the firmware to flush the RQ (Receive Queue) via
asynchronous completions when moved to error, we handle RQ flush
manually (mlx5e_free_rx_descs) same as we did when RQ flush got timed
out.

This will reduce RQs flush time and speedup interface down procedure
(ifconfig down) from 6 sec to 0.3 sec on a 48 cores system.

Moved mlx5e_free_rx_descs en_main.c where it is needed, to keep en_rx.c
free form non critical data path code for better code locality.

Fixes: 6cd392a082de ('net/mlx5e: Handle RQ flush in error cases')
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  4 +--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 37 +++++++++++------------
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   | 23 ++------------
 3 files changed, 22 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index d63a1b8..26a7ec7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -223,9 +223,8 @@ struct mlx5e_tstamp {
 };
 
 enum {
-	MLX5E_RQ_STATE_POST_WQES_ENABLE,
+	MLX5E_RQ_STATE_FLUSH,
 	MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS,
-	MLX5E_RQ_STATE_FLUSH_TIMEOUT,
 	MLX5E_RQ_STATE_AM,
 };
 
@@ -703,7 +702,6 @@ int mlx5e_napi_poll(struct napi_struct *napi, int budget);
 bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget);
 int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget);
 void mlx5e_free_tx_descs(struct mlx5e_sq *sq);
-void mlx5e_free_rx_descs(struct mlx5e_rq *rq);
 
 void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe);
 void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 65360b1..2463eba 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -431,7 +431,6 @@ static int mlx5e_enable_rq(struct mlx5e_rq *rq, struct mlx5e_rq_param *param)
 
 	MLX5_SET(rqc,  rqc, cqn,		rq->cq.mcq.cqn);
 	MLX5_SET(rqc,  rqc, state,		MLX5_RQC_STATE_RST);
-	MLX5_SET(rqc,  rqc, flush_in_error_en,	1);
 	MLX5_SET(rqc,  rqc, vsd, priv->params.vlan_strip_disable);
 	MLX5_SET(wq,   wq,  log_wq_pg_sz,	rq->wq_ctrl.buf.page_shift -
 						MLX5_ADAPTER_PAGE_SHIFT);
@@ -528,6 +527,23 @@ static int mlx5e_wait_for_min_rx_wqes(struct mlx5e_rq *rq)
 	return -ETIMEDOUT;
 }
 
+static void mlx5e_free_rx_descs(struct mlx5e_rq *rq)
+{
+	struct mlx5_wq_ll *wq = &rq->wq;
+	struct mlx5e_rx_wqe *wqe;
+	__be16 wqe_ix_be;
+	u16 wqe_ix;
+
+	while (!mlx5_wq_ll_is_empty(wq)) {
+		wqe_ix_be = *wq->tail_next;
+		wqe_ix    = be16_to_cpu(wqe_ix_be);
+		wqe       = mlx5_wq_ll_get_wqe(&rq->wq, wqe_ix);
+		rq->dealloc_wqe(rq, wqe_ix);
+		mlx5_wq_ll_pop(&rq->wq, wqe_ix_be,
+			       &wqe->next.next_wqe_index);
+	}
+}
+
 static int mlx5e_open_rq(struct mlx5e_channel *c,
 			 struct mlx5e_rq_param *param,
 			 struct mlx5e_rq *rq)
@@ -551,8 +567,6 @@ static int mlx5e_open_rq(struct mlx5e_channel *c,
 	if (param->am_enabled)
 		set_bit(MLX5E_RQ_STATE_AM, &c->rq.state);
 
-	set_bit(MLX5E_RQ_STATE_POST_WQES_ENABLE, &rq->state);
-
 	sq->ico_wqe_info[pi].opcode     = MLX5_OPCODE_NOP;
 	sq->ico_wqe_info[pi].num_wqebbs = 1;
 	mlx5e_send_nop(sq, true); /* trigger mlx5e_post_rx_wqes() */
@@ -569,23 +583,8 @@ err_destroy_rq:
 
 static void mlx5e_close_rq(struct mlx5e_rq *rq)
 {
-	int tout = 0;
-	int err;
-
-	clear_bit(MLX5E_RQ_STATE_POST_WQES_ENABLE, &rq->state);
+	set_bit(MLX5E_RQ_STATE_FLUSH, &rq->state);
 	napi_synchronize(&rq->channel->napi); /* prevent mlx5e_post_rx_wqes */
-
-	err = mlx5e_modify_rq_state(rq, MLX5_RQC_STATE_RDY, MLX5_RQC_STATE_ERR);
-	while (!mlx5_wq_ll_is_empty(&rq->wq) && !err &&
-	       tout++ < MLX5_EN_QP_FLUSH_MAX_ITER)
-		msleep(MLX5_EN_QP_FLUSH_MSLEEP_QUANT);
-
-	if (err || tout == MLX5_EN_QP_FLUSH_MAX_ITER)
-		set_bit(MLX5E_RQ_STATE_FLUSH_TIMEOUT, &rq->state);
-
-	/* avoid destroying rq before mlx5e_poll_rx_cq() is done with it */
-	napi_synchronize(&rq->channel->napi);
-
 	cancel_work_sync(&rq->am.work);
 
 	mlx5e_disable_rq(rq);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index bdc9e33..fee1e47 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -595,26 +595,9 @@ void mlx5e_dealloc_rx_mpwqe(struct mlx5e_rq *rq, u16 ix)
 	wi->free_wqe(rq, wi);
 }
 
-void mlx5e_free_rx_descs(struct mlx5e_rq *rq)
-{
-	struct mlx5_wq_ll *wq = &rq->wq;
-	struct mlx5e_rx_wqe *wqe;
-	__be16 wqe_ix_be;
-	u16 wqe_ix;
-
-	while (!mlx5_wq_ll_is_empty(wq)) {
-		wqe_ix_be = *wq->tail_next;
-		wqe_ix    = be16_to_cpu(wqe_ix_be);
-		wqe       = mlx5_wq_ll_get_wqe(&rq->wq, wqe_ix);
-		rq->dealloc_wqe(rq, wqe_ix);
-		mlx5_wq_ll_pop(&rq->wq, wqe_ix_be,
-			       &wqe->next.next_wqe_index);
-	}
-}
-
 #define RQ_CANNOT_POST(rq) \
-		(!test_bit(MLX5E_RQ_STATE_POST_WQES_ENABLE, &rq->state) || \
-		 test_bit(MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS, &rq->state))
+	(test_bit(MLX5E_RQ_STATE_FLUSH, &rq->state) || \
+	 test_bit(MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS, &rq->state))
 
 bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq)
 {
@@ -916,7 +899,7 @@ int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 	struct mlx5e_rq *rq = container_of(cq, struct mlx5e_rq, cq);
 	int work_done = 0;
 
-	if (unlikely(test_bit(MLX5E_RQ_STATE_FLUSH_TIMEOUT, &rq->state)))
+	if (unlikely(test_bit(MLX5E_RQ_STATE_FLUSH, &rq->state)))
 		return 0;
 
 	if (cq->decmprs_left)
-- 
2.7.4
