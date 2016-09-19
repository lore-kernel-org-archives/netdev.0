From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 8/8] net/mlx5e: XDP TX xmit more
Date: Mon, 19 Sep 2016 16:58:59 +0300
Message-ID: <1474293539-2595-9-git-send-email-tariqt@mellanox.com>
References: <1474293539-2595-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Rana Shahout <ranas@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47761 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S940018AbcISOA3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 10:00:29 -0400
In-Reply-To: <1474293539-2595-1-git-send-email-tariqt@mellanox.com>
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
 drivers/net/ethernet/mellanox/mlx5/core/en.h    |  9 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c | 62 +++++++++++++++++--------
 2 files changed, 48 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 82eededfc92a..b490b5b14529 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -266,7 +266,8 @@ struct mlx5e_cq {
 
 struct mlx5e_rq;
 typedef void (*mlx5e_fp_handle_rx_cqe)(struct mlx5e_rq *rq,
-				       struct mlx5_cqe64 *cqe);
+				       struct mlx5_cqe64 *cqe,
+				       bool *xdp_doorbell);
 typedef int (*mlx5e_fp_alloc_wqe)(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe,
 				  u16 ix);
 
@@ -709,8 +710,10 @@ void mlx5e_free_sq_descs(struct mlx5e_sq *sq);
 
 void mlx5e_page_release(struct mlx5e_rq *rq, struct mlx5e_dma_info *dma_info,
 			bool recycle);
-void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe);
-void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe);
+void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe,
+			 bool *xdp_doorbell);
+void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe,
+			       bool *xdp_doorbell);
 bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq);
 int mlx5e_alloc_rx_wqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe, u16 ix);
 int mlx5e_alloc_rx_mpwqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe,	u16 ix);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index fd8011bf25f8..4e7290823212 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -117,7 +117,8 @@ static inline void mlx5e_decompress_cqe_no_hash(struct mlx5e_rq *rq,
 static inline u32 mlx5e_decompress_cqes_cont(struct mlx5e_rq *rq,
 					     struct mlx5e_cq *cq,
 					     int update_owner_only,
-					     int budget_rem)
+					     int budget_rem,
+					     bool *xdp_doorbell)
 {
 	u32 cqcc = cq->wq.cc + update_owner_only;
 	u32 cqe_count;
@@ -131,7 +132,7 @@ static inline u32 mlx5e_decompress_cqes_cont(struct mlx5e_rq *rq,
 			mlx5e_read_mini_arr_slot(cq, cqcc);
 
 		mlx5e_decompress_cqe_no_hash(rq, cq, cqcc);
-		rq->handle_rx_cqe(rq, &cq->title);
+		rq->handle_rx_cqe(rq, &cq->title, xdp_doorbell);
 	}
 	mlx5e_cqes_update_owner(cq, cq->wq.cc, cqcc - cq->wq.cc);
 	cq->wq.cc = cqcc;
@@ -143,15 +144,17 @@ static inline u32 mlx5e_decompress_cqes_cont(struct mlx5e_rq *rq,
 
 static inline u32 mlx5e_decompress_cqes_start(struct mlx5e_rq *rq,
 					      struct mlx5e_cq *cq,
-					      int budget_rem)
+					      int budget_rem,
+					      bool *xdp_doorbell)
 {
 	mlx5e_read_title_slot(rq, cq, cq->wq.cc);
 	mlx5e_read_mini_arr_slot(cq, cq->wq.cc + 1);
 	mlx5e_decompress_cqe(rq, cq, cq->wq.cc);
-	rq->handle_rx_cqe(rq, &cq->title);
+	rq->handle_rx_cqe(rq, &cq->title, xdp_doorbell);
 	cq->mini_arr_idx++;
 
-	return mlx5e_decompress_cqes_cont(rq, cq, 1, budget_rem) - 1;
+	return mlx5e_decompress_cqes_cont(rq, cq, 1, budget_rem,
+					  xdp_doorbell) - 1;
 }
 
 void mlx5e_modify_rx_cqe_compression(struct mlx5e_priv *priv, bool val)
@@ -679,23 +682,28 @@ static inline bool mlx5e_xmit_xdp_frame(struct mlx5e_sq *sq,
 	wi->num_wqebbs = MLX5E_XDP_TX_WQEBBS;
 	sq->pc += MLX5E_XDP_TX_WQEBBS;
 
-	/* TODO: xmit more */
+	/* mlx5e_sq_xmit_doorbel will be called after RX napi loop */
+	return true;
+}
+
+static inline void mlx5e_xmit_xdp_doorbell(struct mlx5e_sq *sq)
+{
+	struct mlx5_wq_cyc *wq = &sq->wq;
+	struct mlx5e_tx_wqe *wqe;
+	u16 pi = (sq->pc - MLX5E_XDP_TX_WQEBBS) & wq->sz_m1; /* last pi */
+
+	wqe  = mlx5_wq_cyc_get_wqe(wq, pi);
+
 	wqe->ctrl.fm_ce_se = MLX5_WQE_CTRL_CQ_UPDATE;
 	mlx5e_tx_notify_hw(sq, &wqe->ctrl, 0);
-
-	/* fill sq edge with nops to avoid wqe wrap around */
-	while ((pi = (sq->pc & wq->sz_m1)) > sq->edge) {
-		sq->db.xdp.wqe_info[pi].opcode = MLX5_OPCODE_NOP;
-		mlx5e_send_nop(sq, false);
-	}
-	return true;
 }
 
 /* returns true if packet was consumed by xdp */
 static inline bool mlx5e_xdp_handle(struct mlx5e_rq *rq,
 				    const struct bpf_prog *prog,
 				    struct mlx5e_dma_info *di,
-				    void *data, u16 len)
+				    void *data, u16 len,
+				    bool *xdp_doorbell)
 {
 	bool consumed = false;
 	struct xdp_buff xdp;
@@ -714,7 +722,13 @@ static inline bool mlx5e_xdp_handle(struct mlx5e_rq *rq,
 		consumed = mlx5e_xmit_xdp_frame(&rq->channel->xdp_sq, di,
 						MLX5_RX_HEADROOM,
 						len);
+		if (unlikely(!consumed) && (*xdp_doorbell)) {
+			/* SQ is full, ring doorbell */
+			mlx5e_xmit_xdp_doorbell(&rq->channel->xdp_sq);
+			*xdp_doorbell = false;
+		}
 		rq->stats.xdp_tx += consumed;
+		*xdp_doorbell |= consumed;
 		return consumed;
 	default:
 		bpf_warn_invalid_xdp_action(act);
@@ -729,7 +743,8 @@ static inline bool mlx5e_xdp_handle(struct mlx5e_rq *rq,
 	return false;
 }
 
-void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
+void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe,
+			 bool *xdp_doorbell)
 {
 	struct bpf_prog *xdp_prog = READ_ONCE(rq->xdp_prog);
 	struct mlx5e_dma_info *di;
@@ -761,7 +776,7 @@ void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 		goto wq_ll_pop;
 	}
 
-	if (mlx5e_xdp_handle(rq, xdp_prog, di, data, cqe_bcnt))
+	if (mlx5e_xdp_handle(rq, xdp_prog, di, data, cqe_bcnt, xdp_doorbell))
 		goto wq_ll_pop; /* page/packet was consumed by XDP */
 
 	skb = build_skb(va, RQ_PAGE_SIZE(rq));
@@ -823,7 +838,8 @@ static inline void mlx5e_mpwqe_fill_rx_skb(struct mlx5e_rq *rq,
 	skb->len  += headlen;
 }
 
-void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
+void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe,
+			       bool *xdp_doorbell)
 {
 	u16 cstrides       = mpwrq_get_cqe_consumed_strides(cqe);
 	u16 wqe_id         = be16_to_cpu(cqe->wqe_id);
@@ -869,13 +885,15 @@ mpwrq_cqe_out:
 int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 {
 	struct mlx5e_rq *rq = container_of(cq, struct mlx5e_rq, cq);
+	bool xdp_doorbell = false;
 	int work_done = 0;
 
 	if (unlikely(test_bit(MLX5E_RQ_STATE_FLUSH, &rq->state)))
 		return 0;
 
 	if (cq->decmprs_left)
-		work_done += mlx5e_decompress_cqes_cont(rq, cq, 0, budget);
+		work_done += mlx5e_decompress_cqes_cont(rq, cq, 0, budget,
+							&xdp_doorbell);
 
 	for (; work_done < budget; work_done++) {
 		struct mlx5_cqe64 *cqe = mlx5e_get_cqe(cq);
@@ -886,15 +904,19 @@ int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
 		if (mlx5_get_cqe_format(cqe) == MLX5_COMPRESSED) {
 			work_done +=
 				mlx5e_decompress_cqes_start(rq, cq,
-							    budget - work_done);
+							    budget - work_done,
+							    &xdp_doorbell);
 			continue;
 		}
 
 		mlx5_cqwq_pop(&cq->wq);
 
-		rq->handle_rx_cqe(rq, cqe);
+		rq->handle_rx_cqe(rq, cqe, &xdp_doorbell);
 	}
 
+	if (xdp_doorbell)
+		mlx5e_xmit_xdp_doorbell(&rq->channel->xdp_sq);
+
 	mlx5_cqwq_update_db_record(&cq->wq);
 
 	/* ensure cq space is freed before enabling more cqes */
-- 
1.8.3.1
