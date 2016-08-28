From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 1/9] net/mlx5e: Limit UMR length to the device's limitation
Date: Mon, 29 Aug 2016 01:13:42 +0300
Message-ID: <1472422430-21583-2-git-send-email-saeedm@mellanox.com>
References: <1472422430-21583-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53026 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752619AbcH1WO3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2016 18:14:29 -0400
In-Reply-To: <1472422430-21583-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ConnectX-4 UMR (User Memory Region) MTT translation table offset in WQE
is limited to U16_MAX, before this patch we ignored that limitation and
requested the maximum possible UMR translation length that the netdev
might need (MAX channels * MAX pages per channel).
In case of a system with #cores > 32 and when linear WQE allocation fails,
falling back to using UMR WQEs will cause the RQ (Receive Queue) to get
stuck.

Here we limit UMR length to min(U16_MAX, max required pages) (while
considering the required alignments) on driver load, by default U16_MAX is
sufficient since the default RX rings value guarantees that we are in
range, dynamically (on set_ringparam/set_channels) we will check if the
new required UMR length (num mtts) is still in range, if not, fail the
request.

Fixes: bc77b240b3c5 ('net/mlx5e: Add fragmented memory support for RX multi packet WQE')
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h         | 14 +++++++-------
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c | 19 +++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c    | 11 ++++++++---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c      | 12 ++++++------
 4 files changed, 40 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 1b495ef..d63a1b8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -73,8 +73,12 @@
 #define MLX5_MPWRQ_PAGES_PER_WQE		BIT(MLX5_MPWRQ_WQE_PAGE_ORDER)
 #define MLX5_MPWRQ_STRIDES_PER_PAGE		(MLX5_MPWRQ_NUM_STRIDES >> \
 						 MLX5_MPWRQ_WQE_PAGE_ORDER)
-#define MLX5_CHANNEL_MAX_NUM_MTTS (ALIGN(MLX5_MPWRQ_PAGES_PER_WQE, 8) * \
-				   BIT(MLX5E_PARAMS_MAXIMUM_LOG_RQ_SIZE_MPW))
+
+#define MLX5_MTT_OCTW(npages) (ALIGN(npages, 8) / 2)
+#define MLX5E_REQUIRED_MTTS(rqs, wqes)\
+	(rqs * wqes * ALIGN(MLX5_MPWRQ_PAGES_PER_WQE, 8))
+#define MLX5E_VALID_NUM_MTTS(num_mtts) (MLX5_MTT_OCTW(num_mtts) <= U16_MAX)
+
 #define MLX5_UMR_ALIGN				(2048)
 #define MLX5_MPWRQ_SMALL_PACKET_THRESHOLD	(128)
 
@@ -304,6 +308,7 @@ struct mlx5e_rq {
 
 	unsigned long          state;
 	int                    ix;
+	u32                    mpwqe_mtt_offset;
 
 	struct mlx5e_rx_am     am; /* Adaptive Moderation */
 
@@ -814,11 +819,6 @@ static inline int mlx5e_get_max_num_channels(struct mlx5_core_dev *mdev)
 		     MLX5E_MAX_NUM_CHANNELS);
 }
 
-static inline int mlx5e_get_mtt_octw(int npages)
-{
-	return ALIGN(npages, 8) / 2;
-}
-
 extern const struct ethtool_ops mlx5e_ethtool_ops;
 #ifdef CONFIG_MLX5_CORE_EN_DCB
 extern const struct dcbnl_rtnl_ops mlx5e_dcbnl_ops;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 4a3757e..9cfe408 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -373,6 +373,7 @@ static int mlx5e_set_ringparam(struct net_device *dev,
 	u16 min_rx_wqes;
 	u8 log_rq_size;
 	u8 log_sq_size;
+	u32 num_mtts;
 	int err = 0;
 
 	if (param->rx_jumbo_pending) {
@@ -397,6 +398,15 @@ static int mlx5e_set_ringparam(struct net_device *dev,
 			    1 << mlx5_max_log_rq_size(rq_wq_type));
 		return -EINVAL;
 	}
+
+	num_mtts = MLX5E_REQUIRED_MTTS(priv->params.num_channels, param->rx_pending);
+	if (priv->params.rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ &&
+	    !MLX5E_VALID_NUM_MTTS(num_mtts)) {
+		netdev_info(dev, "%s: rx_pending (%d) request can't be satisfied, try to reduce.\n",
+			    __func__, param->rx_pending);
+		return -EINVAL;
+	}
+
 	if (param->tx_pending < (1 << MLX5E_PARAMS_MINIMUM_LOG_SQ_SIZE)) {
 		netdev_info(dev, "%s: tx_pending (%d) < min (%d)\n",
 			    __func__, param->tx_pending,
@@ -454,6 +464,7 @@ static int mlx5e_set_channels(struct net_device *dev,
 	unsigned int count = ch->combined_count;
 	bool arfs_enabled;
 	bool was_opened;
+	u32 num_mtts;
 	int err = 0;
 
 	if (!count) {
@@ -472,6 +483,14 @@ static int mlx5e_set_channels(struct net_device *dev,
 		return -EINVAL;
 	}
 
+	num_mtts = MLX5E_REQUIRED_MTTS(count, BIT(priv->params.log_rq_size));
+	if (priv->params.rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ &&
+	    !MLX5E_VALID_NUM_MTTS(num_mtts)) {
+		netdev_info(dev, "%s: rx count (%d) request can't be satisfied, try to reduce.\n",
+			    __func__, count);
+		return -EINVAL;
+	}
+
 	if (priv->params.num_channels == count)
 		return 0;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 03d944c..65360b1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -340,6 +340,9 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 		rq->alloc_wqe = mlx5e_alloc_rx_mpwqe;
 		rq->dealloc_wqe = mlx5e_dealloc_rx_mpwqe;
 
+		rq->mpwqe_mtt_offset = c->ix *
+			MLX5E_REQUIRED_MTTS(1, BIT(priv->params.log_rq_size));
+
 		rq->mpwqe_stride_sz = BIT(priv->params.mpwqe_log_stride_sz);
 		rq->mpwqe_num_strides = BIT(priv->params.mpwqe_log_num_strides);
 		rq->wqe_sz = rq->mpwqe_stride_sz * rq->mpwqe_num_strides;
@@ -3233,8 +3236,8 @@ static int mlx5e_create_umr_mkey(struct mlx5e_priv *priv)
 	struct mlx5_create_mkey_mbox_in *in;
 	struct mlx5_mkey_seg *mkc;
 	int inlen = sizeof(*in);
-	u64 npages =
-		priv->profile->max_nch(mdev) * MLX5_CHANNEL_MAX_NUM_MTTS;
+	u64 npages = MLX5E_REQUIRED_MTTS(priv->profile->max_nch(mdev),
+					 BIT(MLX5E_PARAMS_MAXIMUM_LOG_RQ_SIZE_MPW));
 	int err;
 
 	in = mlx5_vzalloc(inlen);
@@ -3248,10 +3251,12 @@ static int mlx5e_create_umr_mkey(struct mlx5e_priv *priv)
 		     MLX5_PERM_LOCAL_WRITE |
 		     MLX5_ACCESS_MODE_MTT;
 
+	npages = min_t(u32, ALIGN(U16_MAX, 4) * 2, npages);
+
 	mkc->qpn_mkey7_0 = cpu_to_be32(0xffffff << 8);
 	mkc->flags_pd = cpu_to_be32(mdev->mlx5e_res.pdn);
 	mkc->len = cpu_to_be64(npages << PAGE_SHIFT);
-	mkc->xlt_oct_size = cpu_to_be32(mlx5e_get_mtt_octw(npages));
+	mkc->xlt_oct_size = cpu_to_be32(MLX5_MTT_OCTW(npages));
 	mkc->log2_page_size = PAGE_SHIFT;
 
 	err = mlx5_core_create_mkey(mdev, &priv->umr_mkey, in, inlen, NULL,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 9f2a16a..bdc9e33 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -324,9 +324,9 @@ mlx5e_copy_skb_header_fragmented_mpwqe(struct device *pdev,
 	}
 }
 
-static u16 mlx5e_get_wqe_mtt_offset(u16 rq_ix, u16 wqe_ix)
+static u32 mlx5e_get_wqe_mtt_offset(struct mlx5e_rq *rq, u16 wqe_ix)
 {
-	return rq_ix * MLX5_CHANNEL_MAX_NUM_MTTS +
+	return rq->mpwqe_mtt_offset +
 		wqe_ix * ALIGN(MLX5_MPWRQ_PAGES_PER_WQE, 8);
 }
 
@@ -340,7 +340,7 @@ static void mlx5e_build_umr_wqe(struct mlx5e_rq *rq,
 	struct mlx5_wqe_data_seg      *dseg = &wqe->data;
 	struct mlx5e_mpw_info *wi = &rq->wqe_info[ix];
 	u8 ds_cnt = DIV_ROUND_UP(sizeof(*wqe), MLX5_SEND_WQE_DS);
-	u16 umr_wqe_mtt_offset = mlx5e_get_wqe_mtt_offset(rq->ix, ix);
+	u32 umr_wqe_mtt_offset = mlx5e_get_wqe_mtt_offset(rq, ix);
 
 	memset(wqe, 0, sizeof(*wqe));
 	cseg->opmod_idx_opcode =
@@ -353,9 +353,9 @@ static void mlx5e_build_umr_wqe(struct mlx5e_rq *rq,
 
 	ucseg->flags = MLX5_UMR_TRANSLATION_OFFSET_EN;
 	ucseg->klm_octowords =
-		cpu_to_be16(mlx5e_get_mtt_octw(MLX5_MPWRQ_PAGES_PER_WQE));
+		cpu_to_be16(MLX5_MTT_OCTW(MLX5_MPWRQ_PAGES_PER_WQE));
 	ucseg->bsf_octowords =
-		cpu_to_be16(mlx5e_get_mtt_octw(umr_wqe_mtt_offset));
+		cpu_to_be16(MLX5_MTT_OCTW(umr_wqe_mtt_offset));
 	ucseg->mkey_mask     = cpu_to_be64(MLX5_MKEY_MASK_FREE);
 
 	dseg->lkey = sq->mkey_be;
@@ -423,7 +423,7 @@ static int mlx5e_alloc_rx_fragmented_mpwqe(struct mlx5e_rq *rq,
 {
 	struct mlx5e_mpw_info *wi = &rq->wqe_info[ix];
 	int mtt_sz = mlx5e_get_wqe_mtt_sz();
-	u32 dma_offset = mlx5e_get_wqe_mtt_offset(rq->ix, ix) << PAGE_SHIFT;
+	u64 dma_offset = (u64)mlx5e_get_wqe_mtt_offset(rq, ix) << PAGE_SHIFT;
 	int i;
 
 	wi->umr.dma_info = kmalloc(sizeof(*wi->umr.dma_info) *
-- 
2.7.4
