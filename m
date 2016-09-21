From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next V2 8/8] net/mlx5e: XDP TX xmit more
Date: Wed, 21 Sep 2016 12:19:49 +0300
Message-ID: <1474449589-27035-9-git-send-email-tariqt@mellanox.com>
References: <1474449589-27035-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Rana Shahout <ranas@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41596 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932882AbcIUJUk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 05:20:40 -0400
In-Reply-To: <1474449589-27035-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Previously we rang XDP SQ doorbell on every forwarded XDP packet.

Here we introduce a xmit more like mechanism that will queue up more
than one packet into SQ (up to RX napi budget) w/o notifying the hardware.

Once RX napi budget is consumed and we exit napi RX loop, we will
flush (doorbell) all XDP looped packets in case there are such.

XDP forward packet rate:

Comparing XDP with and w/o xmit more (bulk transmit):

RX Cores    XDP TX       XDP TX (xmit more)
---------------------------------------------------
1           6.5Mpps      12.4Mpps
2          13.2Mpps      24.2Mpps
4          25.2Mpps      36.3Mpps*
8          36.3Mpps*     36.3Mpps*

*My xmitter was limited to 36.3Mpps, so it is the bottleneck.
It seems that receive side can handle more.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h    |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c | 32 ++++++++++++++++++-------
 2 files changed, 25 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 82eededfc92a..346015407b70 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -433,6 +433,7 @@ struct mlx5e_sq {
 		struct {
 			struct mlx5e_sq_wqe_info  *wqe_info;
 			struct mlx5e_dma_info     *di;
+			bool                       doorbell;
 		} xdp;
 	} db;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 57d49513a87a..0a81bd34abbe 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -632,6 +632,18 @@ static inline void mlx5e_complete_rx_cqe(struct mlx5e_rq *rq,
 	napi_gro_receive(rq->cq.napi, skb);
 }
 
+static inline void mlx5e_xmit_xdp_doorbell(struct mlx5e_sq *sq)
+{
+	struct mlx5_wq_cyc *wq = &sq->wq;
+	struct mlx5e_tx_wqe *wqe;
+	u16 pi = (sq->pc - MLX5E_XDP_TX_WQEBBS) & wq->sz_m1; /* last pi */
+
+	wqe  = mlx5_wq_cyc_get_wqe(wq, pi);
+
+	wqe->ctrl.fm_ce_se = MLX5_WQE_CTRL_CQ_UPDATE;
+	mlx5e_tx_notify_hw(sq, &wqe->ctrl, 0);
+}
+
 static inline void mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
 					struct mlx5e_dma_info *di,
 					unsigned int data_offset,
@@ -652,6 +664,11 @@ static inline void mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
 	void *data           = page_address(di->page) + data_offset;
 
 	if (unlikely(!mlx5e_sq_has_room_for(sq, MLX5E_XDP_TX_WQEBBS))) {
+		if (sq->db.xdp.doorbell) {
+			/* SQ is full, ring doorbell */
+			mlx5e_xmit_xdp_doorbell(sq);
+			sq->db.xdp.doorbell = false;
+		}
 		rq->stats.xdp_tx_full++;
 		mlx5e_page_release(rq, di, true);
 		return;
@@ -681,14 +698,7 @@ static inline void mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
 	wi->num_wqebbs = MLX5E_XDP_TX_WQEBBS;
 	sq->pc += MLX5E_XDP_TX_WQEBBS;
 
-	wqe->ctrl.fm_ce_se = MLX5_WQE_CTRL_CQ_UPDATE;
-	mlx5e_tx_notify_hw(sq, &wqe->ctrl, 0);
-
-	/* fill sq edge with nops to avoid wqe wrap around */
-	while ((pi = (sq->pc & wq->sz_m1)) > sq->edge) {
-		sq->db.xdp.wqe_info[pi].opcode = MLX5_OPCODE_NOP;
-		mlx5e_send_nop(sq, false);
-	}
+	sq->db.xdp.doorbell = true;
 	rq->stats.xdp_tx++;
 }
 
@@ -863,6 +873,7 @@ mpwrq_cqe_out:
 int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 {
 	struct mlx5e_rq *rq = container_of(cq, struct mlx5e_rq, cq);
+	struct mlx5e_sq *xdp_sq = &rq->channel->xdp_sq;
 	int work_done = 0;
 
 	if (unlikely(test_bit(MLX5E_RQ_STATE_FLUSH, &rq->state)))
@@ -889,6 +900,11 @@ int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 		rq->handle_rx_cqe(rq, cqe);
 	}
 
+	if (xdp_sq->db.xdp.doorbell) {
+		mlx5e_xmit_xdp_doorbell(xdp_sq);
+		xdp_sq->db.xdp.doorbell = false;
+	}
+
 	mlx5_cqwq_update_db_record(&cq->wq);
 
 	/* ensure cq space is freed before enabling more cqes */
-- 
1.8.3.1
