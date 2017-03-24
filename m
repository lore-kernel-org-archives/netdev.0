From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 06/12] net/mlx5e: Move XDP SQ instance into RQ
Date: Sat, 25 Mar 2017 00:52:08 +0300
Message-ID: <20170324215214.25711-7-saeedm@mellanox.com>
References: <20170324215214.25711-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35763 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S934748AbdCXVwZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 17:52:25 -0400
In-Reply-To: <20170324215214.25711-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To save many rq->channel->sq dereferences in fast-path.
And rename it to xdpsq.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  4 +++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 12 ++++++------
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   | 18 +++++++++++-------
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c |  2 +-
 4 files changed, 21 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 8d789a25a1c0..5e4ae94c9f6a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -479,7 +479,10 @@ struct mlx5e_rq {
 	u16                    rx_headroom;
 
 	struct mlx5e_rx_am     am; /* Adaptive Moderation */
+
+	/* XDP */
 	struct bpf_prog       *xdp_prog;
+	struct mlx5e_sq        xdpsq;
 
 	/* control */
 	struct mlx5_wq_ctrl    wq_ctrl;
@@ -499,7 +502,6 @@ enum channel_flags {
 struct mlx5e_channel {
 	/* data path */
 	struct mlx5e_rq            rq;
-	struct mlx5e_sq            xdp_sq;
 	struct mlx5e_sq            sq[MLX5E_MAX_NUM_TC];
 	struct mlx5e_sq            icosq;   /* internal control operations */
 	bool                       xdp;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 49c1769d13b9..210033187bfe 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1562,7 +1562,7 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 		goto err_close_tx_cqs;
 
 	/* XDP SQ CQ params are same as normal TXQ sq CQ params */
-	err = c->xdp ? mlx5e_open_cq(c, &cparam->tx_cq, &c->xdp_sq.cq,
+	err = c->xdp ? mlx5e_open_cq(c, &cparam->tx_cq, &c->rq.xdpsq.cq,
 				     priv->params.tx_cq_moderation) : 0;
 	if (err)
 		goto err_close_rx_cq;
@@ -1587,7 +1587,7 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 		}
 	}
 
-	err = c->xdp ? mlx5e_open_sq(c, 0, &cparam->xdp_sq, &c->xdp_sq) : 0;
+	err = c->xdp ? mlx5e_open_sq(c, 0, &cparam->xdp_sq, &c->rq.xdpsq) : 0;
 	if (err)
 		goto err_close_sqs;
 
@@ -1601,7 +1601,7 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 	return 0;
 err_close_xdp_sq:
 	if (c->xdp)
-		mlx5e_close_sq(&c->xdp_sq);
+		mlx5e_close_sq(&c->rq.xdpsq);
 
 err_close_sqs:
 	mlx5e_close_sqs(c);
@@ -1612,7 +1612,7 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 err_disable_napi:
 	napi_disable(&c->napi);
 	if (c->xdp)
-		mlx5e_close_cq(&c->xdp_sq.cq);
+		mlx5e_close_cq(&c->rq.xdpsq.cq);
 
 err_close_rx_cq:
 	mlx5e_close_cq(&c->rq.cq);
@@ -1634,12 +1634,12 @@ static void mlx5e_close_channel(struct mlx5e_channel *c)
 {
 	mlx5e_close_rq(&c->rq);
 	if (c->xdp)
-		mlx5e_close_sq(&c->xdp_sq);
+		mlx5e_close_sq(&c->rq.xdpsq);
 	mlx5e_close_sqs(c);
 	mlx5e_close_sq(&c->icosq);
 	napi_disable(&c->napi);
 	if (c->xdp)
-		mlx5e_close_cq(&c->xdp_sq.cq);
+		mlx5e_close_cq(&c->rq.xdpsq.cq);
 	mlx5e_close_cq(&c->rq.cq);
 	mlx5e_close_tx_cqs(c);
 	mlx5e_close_cq(&c->icosq.cq);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index bc74d6032a5c..040074f36313 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -653,7 +653,7 @@ static inline bool mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
 					struct mlx5e_dma_info *di,
 					const struct xdp_buff *xdp)
 {
-	struct mlx5e_sq          *sq   = &rq->channel->xdp_sq;
+	struct mlx5e_sq          *sq   = &rq->xdpsq;
 	struct mlx5_wq_cyc       *wq   = &sq->wq;
 	u16                      pi    = sq->pc & wq->sz_m1;
 	struct mlx5e_tx_wqe      *wqe  = mlx5_wq_cyc_get_wqe(wq, pi);
@@ -950,7 +950,7 @@ void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 {
 	struct mlx5e_rq *rq = container_of(cq, struct mlx5e_rq, cq);
-	struct mlx5e_sq *xdp_sq = &rq->channel->xdp_sq;
+	struct mlx5e_sq *xdpsq = &rq->xdpsq;
 	int work_done = 0;
 
 	if (unlikely(!test_bit(MLX5E_RQ_STATE_ENABLED, &rq->state)))
@@ -977,9 +977,9 @@ int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 		rq->handle_rx_cqe(rq, cqe);
 	}
 
-	if (xdp_sq->db.xdp.doorbell) {
-		mlx5e_xmit_xdp_doorbell(xdp_sq);
-		xdp_sq->db.xdp.doorbell = false;
+	if (xdpsq->db.xdp.doorbell) {
+		mlx5e_xmit_xdp_doorbell(xdpsq);
+		xdpsq->db.xdp.doorbell = false;
 	}
 
 	mlx5_cqwq_update_db_record(&cq->wq);
@@ -993,6 +993,7 @@ int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 bool mlx5e_poll_xdpsq_cq(struct mlx5e_cq *cq)
 {
 	struct mlx5e_sq *sq;
+	struct mlx5e_rq *rq;
 	u16 sqcc;
 	int i;
 
@@ -1001,6 +1002,8 @@ bool mlx5e_poll_xdpsq_cq(struct mlx5e_cq *cq)
 	if (unlikely(!test_bit(MLX5E_SQ_STATE_ENABLED, &sq->state)))
 		return false;
 
+	rq = container_of(sq, struct mlx5e_rq, xdpsq);
+
 	/* sq->cc must be updated only after mlx5_cqwq_update_db_record(),
 	 * otherwise a cq overrun may occur
 	 */
@@ -1037,7 +1040,7 @@ bool mlx5e_poll_xdpsq_cq(struct mlx5e_cq *cq)
 
 			sqcc += wi->num_wqebbs;
 			/* Recycle RX page */
-			mlx5e_page_release(&sq->channel->rq, di, true);
+			mlx5e_page_release(rq, di, true);
 		} while (!last_wqe);
 	}
 
@@ -1052,6 +1055,7 @@ bool mlx5e_poll_xdpsq_cq(struct mlx5e_cq *cq)
 
 void mlx5e_free_xdpsq_descs(struct mlx5e_sq *sq)
 {
+	struct mlx5e_rq *rq = container_of(sq, struct mlx5e_rq, xdpsq);
 	struct mlx5e_sq_wqe_info *wi;
 	struct mlx5e_dma_info *di;
 	u16 ci;
@@ -1068,6 +1072,6 @@ void mlx5e_free_xdpsq_descs(struct mlx5e_sq *sq)
 
 		sq->cc += wi->num_wqebbs;
 
-		mlx5e_page_release(&sq->channel->rq, di, false);
+		mlx5e_page_release(rq, di, false);
 	}
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
index f23dedc58175..9beeb4a1212f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
@@ -122,7 +122,7 @@ int mlx5e_napi_poll(struct napi_struct *napi, int budget)
 	busy |= work_done == budget;
 
 	if (c->xdp)
-		busy |= mlx5e_poll_xdpsq_cq(&c->xdp_sq.cq);
+		busy |= mlx5e_poll_xdpsq_cq(&c->rq.xdpsq.cq);
 
 	mlx5e_poll_ico_cq(&c->icosq.cq);
 
-- 
2.11.0
