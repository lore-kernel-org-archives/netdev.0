From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next V2 7/8] net/mlx5e: XDP TX forwarding support
Date: Wed, 21 Sep 2016 12:19:48 +0300
Message-ID: <1474449589-27035-8-git-send-email-tariqt@mellanox.com>
References: <1474449589-27035-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Rana Shahout <ranas@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41591 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932916AbcIUJUk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 05:20:40 -0400
In-Reply-To: <1474449589-27035-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Adding support for XDP_TX forwarding from xdp program.
Using XDP, now user can loop packets out of the same port.

We create a dedicated TX SQ for each channel that will serve
XDP programs that return XDP_TX action to loop packets back to
the wire directly from the channel RQ RX path.

For that RX pages will now need to be mapped bi-directionally,
and on XDP_TX action we will sync the page back to device then
queue it into SQ for transmission.  The XDP xmit frame function will
report back to the RX path if the page was consumed (transmitted), if so,
RX path will forget about that page as if it were released to the stack.
Later on, on XDP TX completion, the page will be released back to the
page cache.

For simplicity this patch will hit a doorbell on every XDP TX packet.

Next patch will introduce a xmit more like mechanism that will
queue up more than one packet into SQ w/o notifying the hardware,
once RX napi loop is done we will hit doorbell once for all XDP TX
packets form the previous loop.  This should drastically improve
XDP TX performance.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  25 ++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  93 +++++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    | 110 +++++++++++++++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h |   8 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |  39 +++++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c  |  65 +++++++++++-
 6 files changed, 304 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 5917f5e609ae..82eededfc92a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -104,6 +104,15 @@
 #define MLX5E_ICOSQ_MAX_WQEBBS \
 	(DIV_ROUND_UP(sizeof(struct mlx5e_umr_wqe), MLX5_SEND_WQE_BB))
 
+#define MLX5E_XDP_MIN_INLINE (ETH_HLEN + VLAN_HLEN)
+#define MLX5E_XDP_IHS_DS_COUNT \
+	DIV_ROUND_UP(MLX5E_XDP_MIN_INLINE - 2, MLX5_SEND_WQE_DS)
+#define MLX5E_XDP_TX_DS_COUNT \
+	(MLX5E_XDP_IHS_DS_COUNT + \
+	 (sizeof(struct mlx5e_tx_wqe) / MLX5_SEND_WQE_DS) + 1 /* SG DS */)
+#define MLX5E_XDP_TX_WQEBBS \
+	DIV_ROUND_UP(MLX5E_XDP_TX_DS_COUNT, MLX5_SEND_WQEBB_NUM_DS)
+
 #define MLX5E_NUM_MAIN_GROUPS 9
 
 static inline u16 mlx5_min_rx_wqes(int wq_type, u32 wq_size)
@@ -319,6 +328,7 @@ struct mlx5e_rq {
 	struct {
 		u8             page_order;
 		u32            wqe_sz;    /* wqe data buffer size */
+		u8             map_dir;   /* dma map direction */
 	} buff;
 	__be32                 mkey_be;
 
@@ -384,14 +394,15 @@ enum {
 	MLX5E_SQ_STATE_BF_ENABLE,
 };
 
-struct mlx5e_ico_wqe_info {
+struct mlx5e_sq_wqe_info {
 	u8  opcode;
 	u8  num_wqebbs;
 };
 
 enum mlx5e_sq_type {
 	MLX5E_SQ_TXQ,
-	MLX5E_SQ_ICO
+	MLX5E_SQ_ICO,
+	MLX5E_SQ_XDP
 };
 
 struct mlx5e_sq {
@@ -418,7 +429,11 @@ struct mlx5e_sq {
 			struct mlx5e_sq_dma       *dma_fifo;
 			struct mlx5e_tx_wqe_info  *wqe_info;
 		} txq;
-		struct mlx5e_ico_wqe_info *ico_wqe;
+		struct mlx5e_sq_wqe_info *ico_wqe;
+		struct {
+			struct mlx5e_sq_wqe_info  *wqe_info;
+			struct mlx5e_dma_info     *di;
+		} xdp;
 	} db;
 
 	/* read only */
@@ -458,8 +473,10 @@ enum channel_flags {
 struct mlx5e_channel {
 	/* data path */
 	struct mlx5e_rq            rq;
+	struct mlx5e_sq            xdp_sq;
 	struct mlx5e_sq            sq[MLX5E_MAX_NUM_TC];
 	struct mlx5e_sq            icosq;   /* internal control operations */
+	bool                       xdp;
 	struct napi_struct         napi;
 	struct device             *pdev;
 	struct net_device         *netdev;
@@ -688,7 +705,7 @@ void mlx5e_cq_error_event(struct mlx5_core_cq *mcq, enum mlx5_event event);
 int mlx5e_napi_poll(struct napi_struct *napi, int budget);
 bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget);
 int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget);
-void mlx5e_free_tx_descs(struct mlx5e_sq *sq);
+void mlx5e_free_sq_descs(struct mlx5e_sq *sq);
 
 void mlx5e_page_release(struct mlx5e_rq *rq, struct mlx5e_dma_info *dma_info,
 			bool recycle);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 632de09e69cf..a9fc9d4c6af4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -64,6 +64,7 @@ struct mlx5e_cq_param {
 struct mlx5e_channel_param {
 	struct mlx5e_rq_param      rq;
 	struct mlx5e_sq_param      sq;
+	struct mlx5e_sq_param      xdp_sq;
 	struct mlx5e_sq_param      icosq;
 	struct mlx5e_cq_param      rx_cq;
 	struct mlx5e_cq_param      tx_cq;
@@ -180,6 +181,8 @@ static void mlx5e_update_sw_counters(struct mlx5e_priv *priv)
 		s->rx_csum_complete += rq_stats->csum_complete;
 		s->rx_csum_unnecessary_inner += rq_stats->csum_unnecessary_inner;
 		s->rx_xdp_drop += rq_stats->xdp_drop;
+		s->rx_xdp_tx += rq_stats->xdp_tx;
+		s->rx_xdp_tx_full += rq_stats->xdp_tx_full;
 		s->rx_wqe_err   += rq_stats->wqe_err;
 		s->rx_mpwqe_filler += rq_stats->mpwqe_filler;
 		s->rx_buff_alloc_err += rq_stats->buff_alloc_err;
@@ -478,6 +481,10 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 	rq->priv    = c->priv;
 	rq->xdp_prog = priv->xdp_prog;
 
+	rq->buff.map_dir = DMA_FROM_DEVICE;
+	if (rq->xdp_prog)
+		rq->buff.map_dir = DMA_BIDIRECTIONAL;
+
 	switch (priv->params.rq_wq_type) {
 	case MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ:
 		rq->handle_rx_cqe = mlx5e_handle_rx_cqe_mpwrq;
@@ -765,6 +772,28 @@ static void mlx5e_close_rq(struct mlx5e_rq *rq)
 	mlx5e_destroy_rq(rq);
 }
 
+static void mlx5e_free_sq_xdp_db(struct mlx5e_sq *sq)
+{
+	kfree(sq->db.xdp.di);
+	kfree(sq->db.xdp.wqe_info);
+}
+
+static int mlx5e_alloc_sq_xdp_db(struct mlx5e_sq *sq, int numa)
+{
+	int wq_sz = mlx5_wq_cyc_get_size(&sq->wq);
+
+	sq->db.xdp.di = kzalloc_node(sizeof(*sq->db.xdp.di) * wq_sz,
+				     GFP_KERNEL, numa);
+	sq->db.xdp.wqe_info = kzalloc_node(sizeof(*sq->db.xdp.wqe_info) * wq_sz,
+					   GFP_KERNEL, numa);
+	if (!sq->db.xdp.di || !sq->db.xdp.wqe_info) {
+		mlx5e_free_sq_xdp_db(sq);
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+
 static void mlx5e_free_sq_ico_db(struct mlx5e_sq *sq)
 {
 	kfree(sq->db.ico_wqe);
@@ -819,6 +848,9 @@ static void mlx5e_free_sq_db(struct mlx5e_sq *sq)
 	case MLX5E_SQ_ICO:
 		mlx5e_free_sq_ico_db(sq);
 		break;
+	case MLX5E_SQ_XDP:
+		mlx5e_free_sq_xdp_db(sq);
+		break;
 	}
 }
 
@@ -829,11 +861,24 @@ static int mlx5e_alloc_sq_db(struct mlx5e_sq *sq, int numa)
 		return mlx5e_alloc_sq_txq_db(sq, numa);
 	case MLX5E_SQ_ICO:
 		return mlx5e_alloc_sq_ico_db(sq, numa);
+	case MLX5E_SQ_XDP:
+		return mlx5e_alloc_sq_xdp_db(sq, numa);
 	}
 
 	return 0;
 }
 
+static int mlx5e_sq_get_max_wqebbs(u8 sq_type)
+{
+	switch (sq_type) {
+	case MLX5E_SQ_ICO:
+		return MLX5E_ICOSQ_MAX_WQEBBS;
+	case MLX5E_SQ_XDP:
+		return MLX5E_XDP_TX_WQEBBS;
+	}
+	return MLX5_SEND_WQE_MAX_WQEBBS;
+}
+
 static int mlx5e_create_sq(struct mlx5e_channel *c,
 			   int tc,
 			   struct mlx5e_sq_param *param,
@@ -844,7 +889,6 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 
 	void *sqc = param->sqc;
 	void *sqc_wq = MLX5_ADDR_OF(sqc, sqc, wq);
-	u16 sq_max_wqebbs;
 	int err;
 
 	sq->type      = param->type;
@@ -882,7 +926,6 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 	if (err)
 		goto err_sq_wq_destroy;
 
-	sq_max_wqebbs = MLX5_SEND_WQE_MAX_WQEBBS;
 	if (sq->type == MLX5E_SQ_TXQ) {
 		int txq_ix;
 
@@ -891,10 +934,7 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 		priv->txq_to_sq_map[txq_ix] = sq;
 	}
 
-	if (sq->type == MLX5E_SQ_ICO)
-		sq_max_wqebbs = MLX5E_ICOSQ_MAX_WQEBBS;
-
-	sq->edge      = (sq->wq.sz_m1 + 1) - sq_max_wqebbs;
+	sq->edge = (sq->wq.sz_m1 + 1) - mlx5e_sq_get_max_wqebbs(sq->type);
 	sq->bf_budget = MLX5E_SQ_BF_BUDGET;
 
 	return 0;
@@ -1068,7 +1108,7 @@ static void mlx5e_close_sq(struct mlx5e_sq *sq)
 	}
 
 	mlx5e_disable_sq(sq);
-	mlx5e_free_tx_descs(sq);
+	mlx5e_free_sq_descs(sq);
 	mlx5e_destroy_sq(sq);
 }
 
@@ -1429,14 +1469,31 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 		}
 	}
 
+	if (priv->xdp_prog) {
+		/* XDP SQ CQ params are same as normal TXQ sq CQ params */
+		err = mlx5e_open_cq(c, &cparam->tx_cq, &c->xdp_sq.cq,
+				    priv->params.tx_cq_moderation);
+		if (err)
+			goto err_close_sqs;
+
+		err = mlx5e_open_sq(c, 0, &cparam->xdp_sq, &c->xdp_sq);
+		if (err) {
+			mlx5e_close_cq(&c->xdp_sq.cq);
+			goto err_close_sqs;
+		}
+	}
+
+	c->xdp = !!priv->xdp_prog;
 	err = mlx5e_open_rq(c, &cparam->rq, &c->rq);
 	if (err)
-		goto err_close_sqs;
+		goto err_close_xdp_sq;
 
 	netif_set_xps_queue(netdev, get_cpu_mask(c->cpu), ix);
 	*cp = c;
 
 	return 0;
+err_close_xdp_sq:
+	mlx5e_close_sq(&c->xdp_sq);
 
 err_close_sqs:
 	mlx5e_close_sqs(c);
@@ -1465,9 +1522,13 @@ err_napi_del:
 static void mlx5e_close_channel(struct mlx5e_channel *c)
 {
 	mlx5e_close_rq(&c->rq);
+	if (c->xdp)
+		mlx5e_close_sq(&c->xdp_sq);
 	mlx5e_close_sqs(c);
 	mlx5e_close_sq(&c->icosq);
 	napi_disable(&c->napi);
+	if (c->xdp)
+		mlx5e_close_cq(&c->xdp_sq.cq);
 	mlx5e_close_cq(&c->rq.cq);
 	mlx5e_close_tx_cqs(c);
 	mlx5e_close_cq(&c->icosq.cq);
@@ -1618,12 +1679,28 @@ static void mlx5e_build_icosq_param(struct mlx5e_priv *priv,
 	param->type = MLX5E_SQ_ICO;
 }
 
+static void mlx5e_build_xdpsq_param(struct mlx5e_priv *priv,
+				    struct mlx5e_sq_param *param)
+{
+	void *sqc = param->sqc;
+	void *wq = MLX5_ADDR_OF(sqc, sqc, wq);
+
+	mlx5e_build_sq_param_common(priv, param);
+	MLX5_SET(wq, wq, log_wq_sz,     priv->params.log_sq_size);
+
+	param->max_inline = priv->params.tx_max_inline;
+	/* FOR XDP SQs will support only L2 inline mode */
+	param->min_inline_mode = MLX5_INLINE_MODE_NONE;
+	param->type = MLX5E_SQ_XDP;
+}
+
 static void mlx5e_build_channel_param(struct mlx5e_priv *priv, struct mlx5e_channel_param *cparam)
 {
 	u8 icosq_log_wq_sz = MLX5E_PARAMS_MINIMUM_LOG_SQ_SIZE;
 
 	mlx5e_build_rq_param(priv, &cparam->rq);
 	mlx5e_build_sq_param(priv, &cparam->sq);
+	mlx5e_build_xdpsq_param(priv, &cparam->xdp_sq);
 	mlx5e_build_icosq_param(priv, &cparam->icosq, icosq_log_wq_sz);
 	mlx5e_build_rx_cq_param(priv, &cparam->rx_cq);
 	mlx5e_build_tx_cq_param(priv, &cparam->tx_cq);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 941e53169838..57d49513a87a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -236,7 +236,7 @@ static inline int mlx5e_page_alloc_mapped(struct mlx5e_rq *rq,
 
 	dma_info->page = page;
 	dma_info->addr = dma_map_page(rq->pdev, page, 0,
-				      RQ_PAGE_SIZE(rq), DMA_FROM_DEVICE);
+				      RQ_PAGE_SIZE(rq), rq->buff.map_dir);
 	if (unlikely(dma_mapping_error(rq->pdev, dma_info->addr))) {
 		put_page(page);
 		return -ENOMEM;
@@ -252,7 +252,7 @@ void mlx5e_page_release(struct mlx5e_rq *rq, struct mlx5e_dma_info *dma_info,
 		return;
 
 	dma_unmap_page(rq->pdev, dma_info->addr, RQ_PAGE_SIZE(rq),
-		       DMA_FROM_DEVICE);
+		       rq->buff.map_dir);
 	put_page(dma_info->page);
 }
 
@@ -632,15 +632,95 @@ static inline void mlx5e_complete_rx_cqe(struct mlx5e_rq *rq,
 	napi_gro_receive(rq->cq.napi, skb);
 }
 
-static inline enum xdp_action mlx5e_xdp_handle(struct mlx5e_rq *rq,
-					       const struct bpf_prog *prog,
-					       void *data, u32 len)
+static inline void mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
+					struct mlx5e_dma_info *di,
+					unsigned int data_offset,
+					int len)
+{
+	struct mlx5e_sq          *sq   = &rq->channel->xdp_sq;
+	struct mlx5_wq_cyc       *wq   = &sq->wq;
+	u16                      pi    = sq->pc & wq->sz_m1;
+	struct mlx5e_tx_wqe      *wqe  = mlx5_wq_cyc_get_wqe(wq, pi);
+	struct mlx5e_sq_wqe_info *wi   = &sq->db.xdp.wqe_info[pi];
+
+	struct mlx5_wqe_ctrl_seg *cseg = &wqe->ctrl;
+	struct mlx5_wqe_eth_seg  *eseg = &wqe->eth;
+	struct mlx5_wqe_data_seg *dseg;
+
+	dma_addr_t dma_addr  = di->addr + data_offset + MLX5E_XDP_MIN_INLINE;
+	unsigned int dma_len = len - MLX5E_XDP_MIN_INLINE;
+	void *data           = page_address(di->page) + data_offset;
+
+	if (unlikely(!mlx5e_sq_has_room_for(sq, MLX5E_XDP_TX_WQEBBS))) {
+		rq->stats.xdp_tx_full++;
+		mlx5e_page_release(rq, di, true);
+		return;
+	}
+
+	dma_sync_single_for_device(sq->pdev, dma_addr, dma_len,
+				   PCI_DMA_TODEVICE);
+
+	memset(wqe, 0, sizeof(*wqe));
+
+	/* copy the inline part */
+	memcpy(eseg->inline_hdr_start, data, MLX5E_XDP_MIN_INLINE);
+	eseg->inline_hdr_sz = cpu_to_be16(MLX5E_XDP_MIN_INLINE);
+
+	dseg = (struct mlx5_wqe_data_seg *)cseg + (MLX5E_XDP_TX_DS_COUNT - 1);
+
+	/* write the dma part */
+	dseg->addr       = cpu_to_be64(dma_addr);
+	dseg->byte_count = cpu_to_be32(dma_len);
+	dseg->lkey       = sq->mkey_be;
+
+	cseg->opmod_idx_opcode = cpu_to_be32((sq->pc << 8) | MLX5_OPCODE_SEND);
+	cseg->qpn_ds = cpu_to_be32((sq->sqn << 8) | MLX5E_XDP_TX_DS_COUNT);
+
+	sq->db.xdp.di[pi] = *di;
+	wi->opcode     = MLX5_OPCODE_SEND;
+	wi->num_wqebbs = MLX5E_XDP_TX_WQEBBS;
+	sq->pc += MLX5E_XDP_TX_WQEBBS;
+
+	wqe->ctrl.fm_ce_se = MLX5_WQE_CTRL_CQ_UPDATE;
+	mlx5e_tx_notify_hw(sq, &wqe->ctrl, 0);
+
+	/* fill sq edge with nops to avoid wqe wrap around */
+	while ((pi = (sq->pc & wq->sz_m1)) > sq->edge) {
+		sq->db.xdp.wqe_info[pi].opcode = MLX5_OPCODE_NOP;
+		mlx5e_send_nop(sq, false);
+	}
+	rq->stats.xdp_tx++;
+}
+
+/* returns true if packet was consumed by xdp */
+static inline bool mlx5e_xdp_handle(struct mlx5e_rq *rq,
+				    const struct bpf_prog *prog,
+				    struct mlx5e_dma_info *di,
+				    void *data, u16 len)
 {
 	struct xdp_buff xdp;
+	u32 act;
+
+	if (!prog)
+		return false;
 
 	xdp.data = data;
 	xdp.data_end = xdp.data + len;
-	return bpf_prog_run_xdp(prog, &xdp);
+	act = bpf_prog_run_xdp(prog, &xdp);
+	switch (act) {
+	case XDP_PASS:
+		return false;
+	case XDP_TX:
+		mlx5e_xmit_xdp_frame(rq, di, MLX5_RX_HEADROOM, len);
+		return true;
+	default:
+		bpf_warn_invalid_xdp_action(act);
+	case XDP_ABORTED:
+	case XDP_DROP:
+		rq->stats.xdp_drop++;
+		mlx5e_page_release(rq, di, true);
+		return true;
+	}
 }
 
 void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
@@ -651,21 +731,22 @@ void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 	__be16 wqe_counter_be;
 	struct sk_buff *skb;
 	u16 wqe_counter;
+	void *va, *data;
 	u32 cqe_bcnt;
-	void *va;
 
 	wqe_counter_be = cqe->wqe_counter;
 	wqe_counter    = be16_to_cpu(wqe_counter_be);
 	wqe            = mlx5_wq_ll_get_wqe(&rq->wq, wqe_counter);
 	di             = &rq->dma_info[wqe_counter];
 	va             = page_address(di->page);
+	data           = va + MLX5_RX_HEADROOM;
 
 	dma_sync_single_range_for_cpu(rq->pdev,
 				      di->addr,
 				      MLX5_RX_HEADROOM,
 				      rq->buff.wqe_sz,
 				      DMA_FROM_DEVICE);
-	prefetch(va + MLX5_RX_HEADROOM);
+	prefetch(data);
 	cqe_bcnt = be32_to_cpu(cqe->byte_cnt);
 
 	if (unlikely((cqe->op_own >> 4) != MLX5_CQE_RESP_SEND)) {
@@ -674,17 +755,8 @@ void mlx5e_handle_rx_cqe(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 		goto wq_ll_pop;
 	}
 
-	if (xdp_prog) {
-		enum xdp_action act =
-			mlx5e_xdp_handle(rq, xdp_prog, va + MLX5_RX_HEADROOM,
-					 cqe_bcnt);
-
-		if (act != XDP_PASS) {
-			rq->stats.xdp_drop++;
-			mlx5e_page_release(rq, di, true);
-			goto wq_ll_pop;
-		}
-	}
+	if (mlx5e_xdp_handle(rq, xdp_prog, di, data, cqe_bcnt))
+		goto wq_ll_pop; /* page/packet was consumed by XDP */
 
 	skb = build_skb(va, RQ_PAGE_SIZE(rq));
 	if (unlikely(!skb)) {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
index 084d6c893a6e..57452fdc5154 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
@@ -66,6 +66,8 @@ struct mlx5e_sw_stats {
 	u64 rx_csum_complete;
 	u64 rx_csum_unnecessary_inner;
 	u64 rx_xdp_drop;
+	u64 rx_xdp_tx;
+	u64 rx_xdp_tx_full;
 	u64 tx_csum_partial;
 	u64 tx_csum_partial_inner;
 	u64 tx_queue_stopped;
@@ -102,6 +104,8 @@ static const struct counter_desc sw_stats_desc[] = {
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_csum_complete) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_csum_unnecessary_inner) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_xdp_drop) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_xdp_tx) },
+	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_xdp_tx_full) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_csum_partial) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_csum_partial_inner) },
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, tx_queue_stopped) },
@@ -281,6 +285,8 @@ struct mlx5e_rq_stats {
 	u64 lro_packets;
 	u64 lro_bytes;
 	u64 xdp_drop;
+	u64 xdp_tx;
+	u64 xdp_tx_full;
 	u64 wqe_err;
 	u64 mpwqe_filler;
 	u64 buff_alloc_err;
@@ -299,6 +305,8 @@ static const struct counter_desc rq_stats_desc[] = {
 	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, csum_unnecessary_inner) },
 	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, csum_none) },
 	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, xdp_drop) },
+	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, xdp_tx) },
+	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, xdp_tx_full) },
 	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, lro_packets) },
 	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, lro_bytes) },
 	{ MLX5E_DECLARE_RX_STAT(struct mlx5e_rq_stats, wqe_err) },
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index f02f24cfcb7a..70a717382357 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -495,16 +495,13 @@ bool mlx5e_poll_tx_cq(struct mlx5e_cq *cq, int napi_budget)
 	return (i == MLX5E_TX_CQ_POLL_BUDGET);
 }
 
-void mlx5e_free_tx_descs(struct mlx5e_sq *sq)
+static void mlx5e_free_txq_sq_descs(struct mlx5e_sq *sq)
 {
 	struct mlx5e_tx_wqe_info *wi;
 	struct sk_buff *skb;
 	u16 ci;
 	int i;
 
-	if (sq->type != MLX5E_SQ_TXQ)
-		return;
-
 	while (sq->cc != sq->pc) {
 		ci = sq->cc & sq->wq.sz_m1;
 		skb = sq->db.txq.skb[ci];
@@ -526,3 +523,37 @@ void mlx5e_free_tx_descs(struct mlx5e_sq *sq)
 		sq->cc += wi->num_wqebbs;
 	}
 }
+
+static void mlx5e_free_xdp_sq_descs(struct mlx5e_sq *sq)
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
+
+void mlx5e_free_sq_descs(struct mlx5e_sq *sq)
+{
+	switch (sq->type) {
+	case MLX5E_SQ_TXQ:
+		mlx5e_free_txq_sq_descs(sq);
+		break;
+	case MLX5E_SQ_XDP:
+		mlx5e_free_xdp_sq_descs(sq);
+		break;
+	}
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
index 47cd5619ae02..5703f19a6a24 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
@@ -72,7 +72,7 @@ static void mlx5e_poll_ico_cq(struct mlx5e_cq *cq)
 
 	do {
 		u16 ci = be16_to_cpu(cqe->wqe_counter) & wq->sz_m1;
-		struct mlx5e_ico_wqe_info *icowi = &sq->db.ico_wqe[ci];
+		struct mlx5e_sq_wqe_info *icowi = &sq->db.ico_wqe[ci];
 
 		mlx5_cqwq_pop(&cq->wq);
 		sqcc += icowi->num_wqebbs;
@@ -105,6 +105,66 @@ static void mlx5e_poll_ico_cq(struct mlx5e_cq *cq)
 	sq->cc = sqcc;
 }
 
+static inline bool mlx5e_poll_xdp_tx_cq(struct mlx5e_cq *cq)
+{
+	struct mlx5e_sq *sq;
+	u16 sqcc;
+	int i;
+
+	sq = container_of(cq, struct mlx5e_sq, cq);
+
+	if (unlikely(test_bit(MLX5E_SQ_STATE_FLUSH, &sq->state)))
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
 int mlx5e_napi_poll(struct napi_struct *napi, int budget)
 {
 	struct mlx5e_channel *c = container_of(napi, struct mlx5e_channel,
@@ -121,6 +181,9 @@ int mlx5e_napi_poll(struct napi_struct *napi, int budget)
 	work_done = mlx5e_poll_rx_cq(&c->rq.cq, budget);
 	busy |= work_done == budget;
 
+	if (c->xdp)
+		busy |= mlx5e_poll_xdp_tx_cq(&c->xdp_sq.cq);
+
 	mlx5e_poll_ico_cq(&c->icosq.cq);
 
 	busy |= mlx5e_post_rx_wqes(&c->rq);
-- 
1.8.3.1
