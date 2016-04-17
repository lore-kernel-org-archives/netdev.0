From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 07/11] net/mlx5e: Add fragmented memory support for RX multi packet WQE
Date: Mon, 18 Apr 2016 00:32:01 +0300
Message-ID: <1460928725-18741-8-git-send-email-saeedm@mellanox.com>
References: <1460928725-18741-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37026 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751981AbcDQVcp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Apr 2016 17:32:45 -0400
In-Reply-To: <1460928725-18741-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

If the allocation of a linear (physically continuous) MPWQE fails,
we allocate a fragmented MPWQE.

This is implemented via device's UMR (User Memory Registration)
which allows to register multiple memory fragments into ConnectX
hardware as a continuous buffer.
UMR registration is an asynchronous operation and is done via
ICO SQs.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |   78 ++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   64 ++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |  357 +++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   |    4 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c |    3 +
 5 files changed, 458 insertions(+), 48 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index f62495f..1d4e8fe 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -69,6 +69,10 @@
 						 MLX5_MPWRQ_LOG_STRIDE_SIZE)
 #define MLX5_MPWRQ_WQE_PAGE_ORDER  (max_t(int, 0, \
 					  MLX5_MPWRQ_LOG_WQE_SZ - PAGE_SHIFT))
+#define MLX5_MPWRQ_WQE_NUM_PAGES		BIT(MLX5_MPWRQ_WQE_PAGE_ORDER)
+#define MLX5_CHANNEL_MAX_NUM_MTTS (ALIGN(MLX5_MPWRQ_WQE_NUM_PAGES, 8) * \
+				   BIT(MLX5E_PARAMS_MAXIMUM_LOG_RQ_SIZE_MPW))
+#define MLX5_UMR_ALIGN				(2048)
 #define MLX5_MPWRQ_SMALL_PACKET_THRESHOLD	(128)
 
 #define MLX5E_PARAMS_DEFAULT_LRO_WQE_SZ                 (64 * 1024)
@@ -131,6 +135,13 @@ struct mlx5e_rx_wqe {
 	struct mlx5_wqe_data_seg      data;
 };
 
+struct mlx5e_umr_wqe {
+	struct mlx5_wqe_ctrl_seg       ctrl;
+	struct mlx5_wqe_umr_ctrl_seg   uctrl;
+	struct mlx5_mkey_seg           mkc;
+	struct mlx5_wqe_data_seg       data;
+};
+
 #ifdef CONFIG_MLX5_CORE_EN_DCB
 #define MLX5E_MAX_BW_ALLOC 100 /* Max percentage of BW allocation */
 #define MLX5E_MIN_BW_ALLOC 1   /* Min percentage of BW allocation */
@@ -176,6 +187,7 @@ static const char vport_strings[][ETH_GSTRING_LEN] = {
 	"tx_queue_dropped",
 	"rx_wqe_err",
 	"rx_mpwqe_filler",
+	"rx_mpwqe_frag",
 };
 
 struct mlx5e_vport_stats {
@@ -218,8 +230,9 @@ struct mlx5e_vport_stats {
 	u64 tx_queue_dropped;
 	u64 rx_wqe_err;
 	u64 rx_mpwqe_filler;
+	u64 rx_mpwqe_frag;
 
-#define NUM_VPORT_COUNTERS     36
+#define NUM_VPORT_COUNTERS     37
 };
 
 static const char pport_strings[][ETH_GSTRING_LEN] = {
@@ -314,6 +327,7 @@ static const char rq_stats_strings[][ETH_GSTRING_LEN] = {
 	"lro_bytes",
 	"wqe_err",
 	"mpwqe_filler",
+	"mpwqe_frag",
 };
 
 struct mlx5e_rq_stats {
@@ -325,7 +339,8 @@ struct mlx5e_rq_stats {
 	u64 lro_bytes;
 	u64 wqe_err;
 	u64 mpwqe_filler;
-#define NUM_RQ_STATS 8
+	u64 mpwqe_frag;
+#define NUM_RQ_STATS 9
 };
 
 static const char sq_stats_strings[][ETH_GSTRING_LEN] = {
@@ -404,6 +419,7 @@ struct mlx5e_tstamp {
 
 enum {
 	MLX5E_RQ_STATE_POST_WQES_ENABLE,
+	MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS,
 };
 
 struct mlx5e_cq {
@@ -431,18 +447,14 @@ struct mlx5e_dma_info {
 	dma_addr_t	addr;
 };
 
-struct mlx5e_mpw_info {
-	struct mlx5e_dma_info dma_info;
-	u16		     consumed_strides;
-	u16		     skbs_frags;
-};
-
 struct mlx5e_rq {
 	/* data path */
 	struct mlx5_wq_ll      wq;
 	u32                    wqe_sz;
 	struct sk_buff       **skb;
 	struct mlx5e_mpw_info *wqe_info;
+	__be32                 mkey_be;
+	__be32                 umr_mkey_be;
 
 	struct device         *pdev;
 	struct net_device     *netdev;
@@ -463,6 +475,29 @@ struct mlx5e_rq {
 	struct mlx5e_priv     *priv;
 } ____cacheline_aligned_in_smp;
 
+struct mlx5e_umr_dma_info {
+	__be64                *mtt;
+	__be64                *mtt_no_align;
+	dma_addr_t             mtt_addr;
+	struct mlx5e_dma_info *dma_info;
+};
+
+struct mlx5e_mpw_info {
+	union {
+		struct mlx5e_dma_info     dma_info;
+		struct mlx5e_umr_dma_info umr;
+	};
+	u16 consumed_strides;
+	u16 skbs_frags;
+
+	void (*complete_wqe)(struct mlx5e_rq *rq,
+			     struct mlx5_cqe64 *cqe,
+			     u16 byte_cnt,
+			     struct mlx5e_mpw_info *wi,
+			     struct sk_buff *skb);
+	void (*free_wqe)(struct mlx5e_rq *rq, struct mlx5e_mpw_info *wi);
+};
+
 struct mlx5e_tx_wqe_info {
 	u32 num_bytes;
 	u8  num_wqebbs;
@@ -655,6 +690,7 @@ struct mlx5e_priv {
 	u32                        pdn;
 	u32                        tdn;
 	struct mlx5_core_mkey      mkey;
+	struct mlx5_core_mkey      umr_mkey;
 	struct mlx5e_rq            drop_rq;
 
 	struct mlx5e_channel     **channel;
@@ -727,6 +763,21 @@ void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe);
 bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq);
 int mlx5e_alloc_rx_wqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe, u16 ix);
 int mlx5e_alloc_rx_mpwqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe, u16 ix);
+void mlx5e_post_rx_fragmented_mpwqe(struct mlx5e_rq *rq);
+void mlx5e_complete_rx_linear_mpwqe(struct mlx5e_rq *rq,
+				    struct mlx5_cqe64 *cqe,
+				    u16 byte_cnt,
+				    struct mlx5e_mpw_info *wi,
+				    struct sk_buff *skb);
+void mlx5e_complete_rx_fragmented_mpwqe(struct mlx5e_rq *rq,
+					struct mlx5_cqe64 *cqe,
+					u16 byte_cnt,
+					struct mlx5e_mpw_info *wi,
+					struct sk_buff *skb);
+void mlx5e_free_rx_linear_mpwqe(struct mlx5e_rq *rq,
+				struct mlx5e_mpw_info *wi);
+void mlx5e_free_rx_fragmented_mpwqe(struct mlx5e_rq *rq,
+				    struct mlx5e_mpw_info *wi);
 struct mlx5_cqe64 *mlx5e_get_cqe(struct mlx5e_cq *cq);
 
 void mlx5e_update_stats(struct mlx5e_priv *priv);
@@ -760,7 +811,7 @@ void mlx5e_build_default_indir_rqt(struct mlx5_core_dev *mdev,
 				   int num_channels);
 
 static inline void mlx5e_tx_notify_hw(struct mlx5e_sq *sq,
-				      struct mlx5e_tx_wqe *wqe, int bf_sz)
+				      struct mlx5_wqe_ctrl_seg *ctrl, int bf_sz)
 {
 	u16 ofst = MLX5_BF_OFFSET + sq->bf_offset;
 
@@ -774,9 +825,9 @@ static inline void mlx5e_tx_notify_hw(struct mlx5e_sq *sq,
 	 */
 	wmb();
 	if (bf_sz)
-		__iowrite64_copy(sq->uar_map + ofst, &wqe->ctrl, bf_sz);
+		__iowrite64_copy(sq->uar_map + ofst, ctrl, bf_sz);
 	else
-		mlx5_write64((__be32 *)&wqe->ctrl, sq->uar_map + ofst, NULL);
+		mlx5_write64((__be32 *)ctrl, sq->uar_map + ofst, NULL);
 	/* flush the write-combining mapped buffer */
 	wmb();
 
@@ -797,6 +848,11 @@ static inline int mlx5e_get_max_num_channels(struct mlx5_core_dev *mdev)
 		     MLX5E_MAX_NUM_CHANNELS);
 }
 
+static inline int mlx5e_get_mtt_octw(int npages)
+{
+	return ALIGN(npages, 8) / 2;
+}
+
 extern const struct ethtool_ops mlx5e_ethtool_ops;
 #ifdef CONFIG_MLX5_CORE_EN_DCB
 extern const struct dcbnl_rtnl_ops mlx5e_dcbnl_ops;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index b25b429..942829e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -179,6 +179,7 @@ void mlx5e_update_stats(struct mlx5e_priv *priv)
 	s->rx_csum_sw		= 0;
 	s->rx_wqe_err		= 0;
 	s->rx_mpwqe_filler	= 0;
+	s->rx_mpwqe_frag	= 0;
 	for (i = 0; i < priv->params.num_channels; i++) {
 		rq_stats = &priv->channel[i]->rq.stats;
 
@@ -190,6 +191,7 @@ void mlx5e_update_stats(struct mlx5e_priv *priv)
 		s->rx_csum_sw	+= rq_stats->csum_sw;
 		s->rx_wqe_err   += rq_stats->wqe_err;
 		s->rx_mpwqe_filler += rq_stats->mpwqe_filler;
+		s->rx_mpwqe_frag   += rq_stats->mpwqe_frag;
 
 		for (j = 0; j < priv->params.num_tc; j++) {
 			sq_stats = &priv->channel[i]->sq[j].stats;
@@ -379,7 +381,6 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 	for (i = 0; i < wq_sz; i++) {
 		struct mlx5e_rx_wqe *wqe = mlx5_wq_ll_get_wqe(&rq->wq, i);
 
-		wqe->data.lkey       = c->mkey_be;
 		wqe->data.byte_count = cpu_to_be32(byte_count);
 	}
 
@@ -390,6 +391,8 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 	rq->channel = c;
 	rq->ix      = c->ix;
 	rq->priv    = c->priv;
+	rq->mkey_be = c->mkey_be;
+	rq->umr_mkey_be = cpu_to_be32(c->priv->umr_mkey.key);
 
 	return 0;
 
@@ -1256,6 +1259,7 @@ static void mlx5e_build_icosq_param(struct mlx5e_priv *priv,
 	mlx5e_build_sq_param_common(priv, param);
 
 	MLX5_SET(wq, wq, log_wq_sz, log_wq_size);
+	MLX5_SET(sqc, sqc, reg_umr, MLX5_CAP_ETH(priv->mdev, reg_umr_sq));
 
 	param->icosq = true;
 }
@@ -1263,7 +1267,7 @@ static void mlx5e_build_icosq_param(struct mlx5e_priv *priv,
 static void mlx5e_build_channel_param(struct mlx5e_priv *priv,
 				      struct mlx5e_channel_param *cparam)
 {
-	u8 icosq_log_wq_sz = 0;
+	u8 icosq_log_wq_sz = MLX5E_PARAMS_MINIMUM_LOG_SQ_SIZE;
 
 	memset(cparam, 0, sizeof(*cparam));
 
@@ -2458,6 +2462,13 @@ void mlx5e_build_default_indir_rqt(struct mlx5_core_dev *mdev,
 		indirection_rqt[i] = i % num_channels;
 }
 
+static bool mlx5e_check_fragmented_striding_rq_cap(struct mlx5_core_dev *mdev)
+{
+	return MLX5_CAP_GEN(mdev, striding_rq) &&
+		MLX5_CAP_GEN(mdev, umr_ptr_rlky) &&
+		MLX5_CAP_ETH(mdev, reg_umr_sq);
+}
+
 static void mlx5e_build_netdev_priv(struct mlx5_core_dev *mdev,
 				    struct net_device *netdev,
 				    int num_channels)
@@ -2466,7 +2477,7 @@ static void mlx5e_build_netdev_priv(struct mlx5_core_dev *mdev,
 
 	priv->params.log_sq_size           =
 		MLX5E_PARAMS_DEFAULT_LOG_SQ_SIZE;
-	priv->params.rq_wq_type = MLX5_CAP_GEN(mdev, striding_rq) ?
+	priv->params.rq_wq_type = mlx5e_check_fragmented_striding_rq_cap(mdev) ?
 		MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ :
 		MLX5_WQ_TYPE_LINKED_LIST;
 
@@ -2639,6 +2650,41 @@ static void mlx5e_destroy_q_counter(struct mlx5e_priv *priv)
 	mlx5_core_dealloc_q_counter(priv->mdev, priv->q_counter);
 }
 
+static int mlx5e_create_umr_mkey(struct mlx5e_priv *priv)
+{
+	struct mlx5_core_dev *mdev = priv->mdev;
+	struct mlx5_create_mkey_mbox_in *in;
+	struct mlx5_mkey_seg *mkc;
+	int inlen = sizeof(*in);
+	u64 npages =
+		mlx5e_get_max_num_channels(mdev) * MLX5_CHANNEL_MAX_NUM_MTTS;
+	int err;
+
+	in = mlx5_vzalloc(inlen);
+	if (!in)
+		return -ENOMEM;
+
+	mkc = &in->seg;
+	mkc->status = MLX5_MKEY_STATUS_FREE;
+	mkc->flags = MLX5_PERM_UMR_EN |
+		     MLX5_PERM_LOCAL_READ |
+		     MLX5_PERM_LOCAL_WRITE |
+		     MLX5_ACCESS_MODE_MTT;
+
+	mkc->qpn_mkey7_0 = cpu_to_be32(0xffffff << 8);
+	mkc->flags_pd = cpu_to_be32(priv->pdn);
+	mkc->len = cpu_to_be64(npages << PAGE_SHIFT);
+	mkc->xlt_oct_size = cpu_to_be32(mlx5e_get_mtt_octw(npages));
+	mkc->log2_page_size = PAGE_SHIFT;
+
+	err = mlx5_core_create_mkey(mdev, &priv->umr_mkey, in, inlen, NULL,
+				    NULL, NULL);
+
+	kvfree(in);
+
+	return err;
+}
+
 static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 {
 	struct net_device *netdev;
@@ -2688,10 +2734,16 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 		goto err_dealloc_transport_domain;
 	}
 
+	err = mlx5e_create_umr_mkey(priv);
+	if (err) {
+		mlx5_core_err(mdev, "create umr mkey failed, %d\n", err);
+		goto err_destroy_mkey;
+	}
+
 	err = mlx5e_create_tises(priv);
 	if (err) {
 		mlx5_core_warn(mdev, "create tises failed, %d\n", err);
-		goto err_destroy_mkey;
+		goto err_destroy_umr_mkey;
 	}
 
 	err = mlx5e_open_drop_rq(priv);
@@ -2774,6 +2826,9 @@ err_close_drop_rq:
 err_destroy_tises:
 	mlx5e_destroy_tises(priv);
 
+err_destroy_umr_mkey:
+	mlx5_core_destroy_mkey(mdev, &priv->umr_mkey);
+
 err_destroy_mkey:
 	mlx5_core_destroy_mkey(mdev, &priv->mkey);
 
@@ -2812,6 +2867,7 @@ static void mlx5e_destroy_netdev(struct mlx5_core_dev *mdev, void *vpriv)
 	mlx5e_destroy_rqt(priv, MLX5E_INDIRECTION_RQT);
 	mlx5e_close_drop_rq(priv);
 	mlx5e_destroy_tises(priv);
+	mlx5_core_destroy_mkey(priv->mdev, &priv->umr_mkey);
 	mlx5_core_destroy_mkey(priv->mdev, &priv->mkey);
 	mlx5_core_dealloc_transport_domain(priv->mdev, priv->tdn);
 	mlx5_core_dealloc_pd(priv->mdev, priv->pdn);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index e652604..22c2812 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -65,6 +65,7 @@ int mlx5e_alloc_rx_wqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe, u16 ix)
 
 	*((dma_addr_t *)skb->cb) = dma_addr;
 	wqe->data.addr = cpu_to_be64(dma_addr + MLX5E_NET_IP_ALIGN);
+	wqe->data.lkey = rq->mkey_be;
 
 	rq->skb[ix] = skb;
 
@@ -76,7 +77,190 @@ err_free_skb:
 	return -ENOMEM;
 }
 
-int mlx5e_alloc_rx_mpwqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe, u16 ix)
+static u16 mlx5e_get_wqe_mtt_offset(u16 rq_ix, u16 wqe_ix)
+{
+	return rq_ix * MLX5_CHANNEL_MAX_NUM_MTTS +
+		wqe_ix * ALIGN(MLX5_MPWRQ_WQE_NUM_PAGES, 8);
+}
+
+static void mlx5e_build_umr_wqe(struct mlx5e_rq *rq,
+				struct mlx5e_sq *sq,
+				struct mlx5e_umr_wqe *wqe,
+				u16 ix)
+{
+	struct mlx5_wqe_ctrl_seg      *cseg = &wqe->ctrl;
+	struct mlx5_wqe_umr_ctrl_seg *ucseg = &wqe->uctrl;
+	struct mlx5_wqe_data_seg      *dseg = &wqe->data;
+	struct mlx5e_mpw_info *wi = &rq->wqe_info[ix];
+	u8 ds_cnt = DIV_ROUND_UP(sizeof(*wqe), MLX5_SEND_WQE_DS);
+	u16 umr_wqe_mtt_offset = mlx5e_get_wqe_mtt_offset(rq->ix, ix);
+
+	memset(wqe, 0, sizeof(*wqe));
+	cseg->opmod_idx_opcode =
+		cpu_to_be32((sq->pc << MLX5_WQE_CTRL_WQE_INDEX_SHIFT) |
+			    MLX5_OPCODE_UMR);
+	cseg->qpn_ds    = cpu_to_be32((sq->sqn << MLX5_WQE_CTRL_QPN_SHIFT) |
+				      ds_cnt);
+	cseg->fm_ce_se  = MLX5_WQE_CTRL_CQ_UPDATE;
+	cseg->imm       = rq->umr_mkey_be;
+
+	ucseg->flags = MLX5_UMR_TRANSLATION_OFFSET_EN;
+	ucseg->klm_octowords =
+		cpu_to_be16(mlx5e_get_mtt_octw(MLX5_MPWRQ_WQE_NUM_PAGES));
+	ucseg->bsf_octowords =
+		cpu_to_be16(mlx5e_get_mtt_octw(umr_wqe_mtt_offset));
+	ucseg->mkey_mask     = cpu_to_be64(MLX5_MKEY_MASK_FREE);
+
+	dseg->lkey = sq->mkey_be;
+	dseg->addr = cpu_to_be64(wi->umr.mtt_addr);
+}
+
+static void mlx5e_post_umr_wqe(struct mlx5e_rq *rq, u16 ix)
+{
+	struct mlx5e_sq *sq = &rq->channel->icosq;
+	struct mlx5_wq_cyc *wq = &sq->wq;
+	struct mlx5e_umr_wqe *wqe;
+	u8 num_wqebbs = DIV_ROUND_UP(sizeof(*wqe), MLX5_SEND_WQE_BB);
+	u16 pi;
+
+	/* fill sq edge with nops to avoid wqe wrap around */
+	while ((pi = (sq->pc & wq->sz_m1)) > sq->edge) {
+		sq->ico_wqe_info[pi].opcode = MLX5_OPCODE_NOP;
+		sq->ico_wqe_info[pi].num_wqebbs = 1;
+		mlx5e_send_nop(sq, true);
+	}
+
+	wqe = mlx5_wq_cyc_get_wqe(wq, pi);
+	mlx5e_build_umr_wqe(rq, sq, wqe, ix);
+	sq->ico_wqe_info[pi].opcode = MLX5_OPCODE_UMR;
+	sq->ico_wqe_info[pi].num_wqebbs = num_wqebbs;
+	sq->pc += num_wqebbs;
+	mlx5e_tx_notify_hw(sq, &wqe->ctrl, 0);
+}
+
+static inline int mlx5e_get_wqe_mtt_sz(void)
+{
+	/* UMR copies MTTs in units of MLX5_UMR_MTT_ALIGNMENT bytes.
+	 * To avoid copying garbage after the mtt array, we allocate
+	 * a little more.
+	 */
+	return ALIGN(MLX5_MPWRQ_WQE_NUM_PAGES * sizeof(__be64),
+		     MLX5_UMR_MTT_ALIGNMENT);
+}
+
+static int mlx5e_alloc_and_map_page(struct mlx5e_rq *rq,
+				    struct mlx5e_mpw_info *wi,
+				    int i)
+{
+	struct page *page;
+
+	page = dev_alloc_page();
+	if (unlikely(!page))
+		return -ENOMEM;
+
+	wi->umr.dma_info[i].page = page;
+	wi->umr.dma_info[i].addr = dma_map_page(rq->pdev, page, 0, PAGE_SIZE,
+						PCI_DMA_FROMDEVICE);
+	if (unlikely(dma_mapping_error(rq->pdev, wi->umr.dma_info[i].addr))) {
+		put_page(page);
+		return -ENOMEM;
+	}
+	wi->umr.mtt[i] = cpu_to_be64(wi->umr.dma_info[i].addr | MLX5_EN_WR);
+
+	return 0;
+}
+
+static int mlx5e_alloc_rx_fragmented_mpwqe(struct mlx5e_rq *rq,
+					   struct mlx5e_rx_wqe *wqe,
+					   u16 ix)
+{
+	struct mlx5e_mpw_info *wi = &rq->wqe_info[ix];
+	int mtt_sz = mlx5e_get_wqe_mtt_sz();
+	u32 dma_offset = mlx5e_get_wqe_mtt_offset(rq->ix, ix) << PAGE_SHIFT;
+	int i;
+
+	wi->umr.dma_info = kmalloc(sizeof(*wi->umr.dma_info) *
+				   MLX5_MPWRQ_WQE_NUM_PAGES,
+				   GFP_ATOMIC);
+	if (unlikely(!wi->umr.dma_info))
+		goto err_out;
+
+	/* We allocate more than mtt_sz as we will align the pointer */
+	wi->umr.mtt_no_align = kzalloc(mtt_sz + MLX5_UMR_ALIGN - 1,
+				       GFP_ATOMIC);
+	if (unlikely(!wi->umr.mtt_no_align))
+		goto err_free_umr;
+
+	wi->umr.mtt = PTR_ALIGN(wi->umr.mtt_no_align, MLX5_UMR_ALIGN);
+	wi->umr.mtt_addr = dma_map_single(rq->pdev, wi->umr.mtt, mtt_sz,
+					  PCI_DMA_TODEVICE);
+	if (unlikely(dma_mapping_error(rq->pdev, wi->umr.mtt_addr)))
+		goto err_free_mtt;
+
+	for (i = 0; i < MLX5_MPWRQ_WQE_NUM_PAGES; i++)
+		if (unlikely(mlx5e_alloc_and_map_page(rq, wi, i)))
+			goto err_unmap;
+
+	wi->consumed_strides = 0;
+	wi->complete_wqe = mlx5e_complete_rx_fragmented_mpwqe;
+	wi->free_wqe     = mlx5e_free_rx_fragmented_mpwqe;
+	wqe->data.lkey = rq->umr_mkey_be;
+	wqe->data.addr = cpu_to_be64(dma_offset);
+
+	return 0;
+
+err_unmap:
+	while (--i >= 0) {
+		dma_unmap_page(rq->pdev, wi->umr.dma_info[i].addr, PAGE_SIZE,
+			       PCI_DMA_FROMDEVICE);
+		put_page(wi->umr.dma_info[i].page);
+	}
+	dma_unmap_single(rq->pdev, wi->umr.mtt_addr, mtt_sz, PCI_DMA_TODEVICE);
+
+err_free_mtt:
+	kfree(wi->umr.mtt_no_align);
+
+err_free_umr:
+	kfree(wi->umr.dma_info);
+
+err_out:
+	return -ENOMEM;
+}
+
+void mlx5e_free_rx_fragmented_mpwqe(struct mlx5e_rq *rq,
+				    struct mlx5e_mpw_info *wi)
+{
+	int mtt_sz = mlx5e_get_wqe_mtt_sz();
+	int i;
+
+	for (i = 0; i < MLX5_MPWRQ_WQE_NUM_PAGES; i++) {
+		dma_unmap_page(rq->pdev, wi->umr.dma_info[i].addr, PAGE_SIZE,
+			       PCI_DMA_FROMDEVICE);
+		put_page(wi->umr.dma_info[i].page);
+	}
+	dma_unmap_single(rq->pdev, wi->umr.mtt_addr, mtt_sz, PCI_DMA_TODEVICE);
+	kfree(wi->umr.mtt_no_align);
+	kfree(wi->umr.dma_info);
+}
+
+void mlx5e_post_rx_fragmented_mpwqe(struct mlx5e_rq *rq)
+{
+	struct mlx5_wq_ll *wq = &rq->wq;
+	struct mlx5e_rx_wqe *wqe = mlx5_wq_ll_get_wqe(wq, wq->head);
+
+	clear_bit(MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS, &rq->state);
+	mlx5_wq_ll_push(wq, be16_to_cpu(wqe->next.next_wqe_index));
+	rq->stats.mpwqe_frag++;
+
+	/* ensure wqes are visible to device before updating doorbell record */
+	dma_wmb();
+
+	mlx5_wq_ll_update_db_record(wq);
+}
+
+static int mlx5e_alloc_rx_linear_mpwqe(struct mlx5e_rq *rq,
+				       struct mlx5e_rx_wqe *wqe,
+				       u16 ix)
 {
 	struct mlx5e_mpw_info *wi = &rq->wqe_info[ix];
 	int ret = 0;
@@ -95,7 +279,10 @@ int mlx5e_alloc_rx_mpwqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe, u16 ix)
 	atomic_add(MLX5_MPWRQ_NUM_STRIDES, &wi->dma_info.page->_count);
 	wi->skbs_frags       = 0;
 	wi->consumed_strides = 0;
-	wqe->data.addr       = cpu_to_be64(wi->dma_info.addr);
+	wi->complete_wqe = mlx5e_complete_rx_linear_mpwqe;
+	wi->free_wqe     = mlx5e_free_rx_linear_mpwqe;
+	wqe->data.lkey = rq->mkey_be;
+	wqe->data.addr = cpu_to_be64(wi->dma_info.addr);
 
 	return 0;
 
@@ -104,11 +291,42 @@ err_put_page:
 	return ret;
 }
 
+void mlx5e_free_rx_linear_mpwqe(struct mlx5e_rq *rq,
+				struct mlx5e_mpw_info *wi)
+{
+	dma_unmap_page(rq->pdev, wi->dma_info.addr, rq->wqe_sz,
+		       PCI_DMA_FROMDEVICE);
+	atomic_sub(MLX5_MPWRQ_NUM_STRIDES - wi->skbs_frags,
+		   &wi->dma_info.page->_count);
+	put_page(wi->dma_info.page);
+}
+
+int mlx5e_alloc_rx_mpwqe(struct mlx5e_rq *rq, struct mlx5e_rx_wqe *wqe, u16 ix)
+{
+	int err;
+
+	err = mlx5e_alloc_rx_linear_mpwqe(rq, wqe, ix);
+	if (unlikely(err)) {
+		err = mlx5e_alloc_rx_fragmented_mpwqe(rq, wqe, ix);
+		if (unlikely(err))
+			return err;
+		set_bit(MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS, &rq->state);
+		mlx5e_post_umr_wqe(rq, ix);
+		return -EBUSY;
+	}
+
+	return 0;
+}
+
+#define RQ_CANNOT_POST(rq) \
+		(!test_bit(MLX5E_RQ_STATE_POST_WQES_ENABLE, &rq->state) || \
+		 test_bit(MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS, &rq->state))
+
 bool mlx5e_post_rx_wqes(struct mlx5e_rq *rq)
 {
 	struct mlx5_wq_ll *wq = &rq->wq;
 
-	if (unlikely(!test_bit(MLX5E_RQ_STATE_POST_WQES_ENABLE, &rq->state)))
+	if (unlikely(RQ_CANNOT_POST(rq)))
 		return false;
 
 	while (!mlx5_wq_ll_is_full(wq)) {
@@ -302,19 +520,119 @@ wq_ll_pop:
 		       &wqe->next.next_wqe_index);
 }
 
-void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
+static inline void mlx5e_sync_copy_linear_data(struct mlx5e_rq *rq,
+					       struct sk_buff *skb,
+					       struct mlx5e_dma_info *dma_info,
+					       unsigned int pg_offset,
+					       unsigned int skb_offset,
+					       unsigned int len)
+{
+	 /* Aligning len to sizeof(long) optimizes memcpy performance */
+	len = ALIGN(len, sizeof(long));
+	dma_sync_single_for_cpu(rq->pdev, dma_info->addr + pg_offset, len,
+				DMA_FROM_DEVICE);
+	skb_copy_to_linear_data_offset(skb, skb_offset,
+				       page_address(dma_info->page) + pg_offset,
+				       len);
+}
+
+void mlx5e_complete_rx_fragmented_mpwqe(struct mlx5e_rq *rq,
+					struct mlx5_cqe64 *cqe,
+					u16 byte_cnt,
+					struct mlx5e_mpw_info *wi,
+					struct sk_buff *skb)
+{
+	u16 stride_ix      = mpwrq_get_cqe_stride_index(cqe);
+	u32 wqe_offset     = stride_ix * MLX5_MPWRQ_STRIDE_SIZE;
+	u32 head_offset    = wqe_offset & (PAGE_SIZE - 1);
+	u32 page_idx       = wqe_offset >> PAGE_SHIFT;
+	struct mlx5e_dma_info *head_dma_info;
+	struct mlx5e_dma_info *dma_info;
+	u16 headlen = min_t(u16, MLX5_MPWRQ_SMALL_PACKET_THRESHOLD, byte_cnt);
+	u16 headlen_pg = min_t(u32, headlen, PAGE_SIZE - head_offset);
+	u32 frag_offset = head_offset + headlen;
+
+	dma_info = &wi->umr.dma_info[page_idx];
+	head_dma_info = dma_info;
+#if (MLX5_MPWRQ_SMALL_PACKET_THRESHOLD >= MLX5_MPWRQ_STRIDE_SIZE)
+	if (unlikely(frag_offset >= PAGE_SIZE)) {
+		dma_info++;
+		frag_offset = headlen - headlen_pg;
+	}
+#endif
+
+	byte_cnt -= headlen;
+
+	while (byte_cnt) {
+		u32 pg_consumed_bytes =
+			min_t(u32, PAGE_SIZE - frag_offset, byte_cnt);
+		unsigned int truesize;
+
+		dma_sync_single_for_cpu(rq->pdev,
+					dma_info->addr + frag_offset,
+					pg_consumed_bytes,
+					DMA_FROM_DEVICE);
+		truesize = ALIGN(pg_consumed_bytes, MLX5_MPWRQ_STRIDE_SIZE);
+		get_page(dma_info->page);
+		skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, dma_info->page,
+				frag_offset, pg_consumed_bytes, truesize);
+		byte_cnt -= pg_consumed_bytes;
+		dma_info++;
+		frag_offset = 0;
+	}
+	/* copy header */
+	mlx5e_sync_copy_linear_data(rq, skb, head_dma_info, head_offset, 0,
+				    headlen_pg);
+#if (MLX5_MPWRQ_SMALL_PACKET_THRESHOLD >= MLX5_MPWRQ_STRIDE_SIZE)
+	if (unlikely(headlen - headlen_pg > 0)) {
+		mlx5e_sync_copy_linear_data(rq, skb, ++head_dma_info, 0,
+					    headlen_pg, headlen - headlen_pg);
+	}
+#endif
+	/* skb linear part was allocated with headlen and aligned to long */
+	skb->tail += headlen;
+	skb->len  += headlen;
+}
+
+void mlx5e_complete_rx_linear_mpwqe(struct mlx5e_rq *rq,
+				    struct mlx5_cqe64 *cqe,
+				    u16 byte_cnt,
+				    struct mlx5e_mpw_info *wi,
+				    struct sk_buff *skb)
 {
 	u16 cstrides       = mpwrq_get_cqe_consumed_strides(cqe);
 	u16 stride_ix      = mpwrq_get_cqe_stride_index(cqe);
 	u32 consumed_bytes = cstrides  * MLX5_MPWRQ_STRIDE_SIZE;
 	u32 data_offset    = stride_ix * MLX5_MPWRQ_STRIDE_SIZE;
+	u16 headlen = min_t(u16, MLX5_MPWRQ_SMALL_PACKET_THRESHOLD, byte_cnt);
+	struct mlx5e_dma_info *dma_info;
+
+	dma_info = &wi->dma_info;
+	dma_sync_single_for_cpu(rq->pdev, dma_info->addr + data_offset,
+				consumed_bytes, DMA_FROM_DEVICE);
+
+	byte_cnt -= headlen;
+	if (byte_cnt) {
+		wi->skbs_frags++;
+		skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, dma_info->page,
+				data_offset + headlen, byte_cnt,
+				ALIGN(byte_cnt, MLX5_MPWRQ_STRIDE_SIZE));
+	}
+	skb_copy_to_linear_data(skb, page_address(dma_info->page) + data_offset,
+				ALIGN(headlen, sizeof(long)));
+	/* skb linear part was allocated with headlen and aligned to long */
+	skb->tail += headlen;
+	skb->len  += headlen;
+}
+
+void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
+{
+	u16 cstrides       = mpwrq_get_cqe_consumed_strides(cqe);
 	u16 wqe_id         = be16_to_cpu(cqe->wqe_id);
 	struct mlx5e_mpw_info *wi = &rq->wqe_info[wqe_id];
 	struct mlx5e_rx_wqe  *wqe = mlx5_wq_ll_get_wqe(&rq->wq, wqe_id);
 	struct sk_buff *skb;
-	u16 byte_cnt;
 	u16 cqe_bcnt;
-	u16 headlen;
 
 	wi->consumed_strides += cstrides;
 
@@ -335,27 +653,8 @@ void mlx5e_handle_rx_cqe_mpwrq(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
 		goto mpwrq_cqe_out;
 
 	prefetch(skb->data);
-	dma_sync_single_for_cpu(rq->pdev, wi->dma_info.addr + data_offset,
-				consumed_bytes, DMA_FROM_DEVICE);
-
 	cqe_bcnt = mpwrq_get_cqe_byte_cnt(cqe);
-	headlen = min_t(u16, MLX5_MPWRQ_SMALL_PACKET_THRESHOLD, cqe_bcnt);
-
-	byte_cnt = cqe_bcnt - headlen;
-	if (byte_cnt) {
-		wi->skbs_frags++;
-		skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags,
-				wi->dma_info.page, data_offset + headlen,
-				byte_cnt,
-				ALIGN(byte_cnt, MLX5_MPWRQ_STRIDE_SIZE));
-	}
-
-	skb_copy_to_linear_data(skb,
-				page_address(wi->dma_info.page) + data_offset,
-				ALIGN(headlen, sizeof(long)));
-	/* skb linear part was allocated with headlen and aligned to long */
-	skb->tail += headlen;
-	skb->len  += headlen;
+	wi->complete_wqe(rq, cqe, cqe_bcnt, wi, skb);
 
 	mlx5e_complete_rx_cqe(rq, cqe, cqe_bcnt, skb);
 
@@ -363,11 +662,7 @@ mpwrq_cqe_out:
 	if (likely(wi->consumed_strides < MLX5_MPWRQ_NUM_STRIDES))
 		return;
 
-	dma_unmap_page(rq->pdev, wi->dma_info.addr, rq->wqe_sz,
-		       PCI_DMA_FROMDEVICE);
-	atomic_sub(MLX5_MPWRQ_NUM_STRIDES - wi->skbs_frags,
-		   &wi->dma_info.page->_count);
-	put_page(wi->dma_info.page);
+	wi->free_wqe(rq, wi);
 	mlx5_wq_ll_pop(&rq->wq, cqe->wqe_id, &wqe->next.next_wqe_index);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index a8d2935..229ab16 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -58,7 +58,7 @@ void mlx5e_send_nop(struct mlx5e_sq *sq, bool notify_hw)
 
 	if (notify_hw) {
 		cseg->fm_ce_se = MLX5_WQE_CTRL_CQ_UPDATE;
-		mlx5e_tx_notify_hw(sq, wqe, 0);
+		mlx5e_tx_notify_hw(sq, &wqe->ctrl, 0);
 	}
 }
 
@@ -310,7 +310,7 @@ static netdev_tx_t mlx5e_sq_xmit(struct mlx5e_sq *sq, struct sk_buff *skb)
 			bf_sz = wi->num_wqebbs << 3;
 
 		cseg->fm_ce_se = MLX5_WQE_CTRL_CQ_UPDATE;
-		mlx5e_tx_notify_hw(sq, wqe, bf_sz);
+		mlx5e_tx_notify_hw(sq, &wqe->ctrl, bf_sz);
 	}
 
 	/* fill sq edge with nops to avoid wqe wrap around */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
index ad624cb..a3fd0f5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
@@ -84,6 +84,9 @@ static void mlx5e_poll_ico_cq(struct mlx5e_cq *cq)
 		switch (icowi->opcode) {
 		case MLX5_OPCODE_NOP:
 			break;
+		case MLX5_OPCODE_UMR:
+			mlx5e_post_rx_fragmented_mpwqe(&sq->channel->rq);
+			break;
 		default:
 			WARN_ONCE(true,
 				  "mlx5e: Bad OPCODE in ICOSQ WQE info: 0x%x\n",
-- 
1.7.1
