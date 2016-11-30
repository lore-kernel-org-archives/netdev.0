From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 3/7] net/mlx5e: Create UMR MKey per RQ
Date: Wed, 30 Nov 2016 17:59:39 +0200
Message-ID: <1480521583-12755-4-git-send-email-saeedm@mellanox.com>
References: <1480521583-12755-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Sebastian Ott <sebott@linux.vnet.ibm.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:59023 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1758040AbcK3Q2F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 11:28:05 -0500
In-Reply-To: <1480521583-12755-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

In Striding RQ implementation, we used a single UMR
(User-Mode Memory Registration) memory key for all RQs.
When the product of RQs number*size gets high, we hit a
limitation of u16 field size in FW.

Here we move to using a UMR memory key per RQ, so we can
scale to any number of rings, with the maximum buffer
size in each.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       | 12 ++---
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 12 +----
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 53 ++++++++++++----------
 3 files changed, 35 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index f16f7fb..63dd639 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -77,9 +77,9 @@
 						 MLX5_MPWRQ_WQE_PAGE_ORDER)
 
 #define MLX5_MTT_OCTW(npages) (ALIGN(npages, 8) / 2)
-#define MLX5E_REQUIRED_MTTS(rqs, wqes)\
-	(rqs * wqes * ALIGN(MLX5_MPWRQ_PAGES_PER_WQE, 8))
-#define MLX5E_VALID_NUM_MTTS(num_mtts) (MLX5_MTT_OCTW(num_mtts) <= U16_MAX)
+#define MLX5E_REQUIRED_MTTS(wqes)		\
+	(wqes * ALIGN(MLX5_MPWRQ_PAGES_PER_WQE, 8))
+#define MLX5E_VALID_NUM_MTTS(num_mtts) (MLX5_MTT_OCTW(num_mtts) - 1 <= U16_MAX)
 
 #define MLX5_UMR_ALIGN				(2048)
 #define MLX5_MPWRQ_SMALL_PACKET_THRESHOLD	(128)
@@ -347,7 +347,6 @@ struct mlx5e_rq {
 		struct {
 			struct mlx5e_mpw_info *info;
 			void                  *mtt_no_align;
-			u32                    mtt_offset;
 		} mpwqe;
 	};
 	struct {
@@ -382,6 +381,7 @@ struct mlx5e_rq {
 	u32                    rqn;
 	struct mlx5e_channel  *channel;
 	struct mlx5e_priv     *priv;
+	struct mlx5_core_mkey  umr_mkey;
 } ____cacheline_aligned_in_smp;
 
 struct mlx5e_umr_dma_info {
@@ -689,7 +689,6 @@ struct mlx5e_priv {
 
 	unsigned long              state;
 	struct mutex               state_lock; /* Protects Interface state */
-	struct mlx5_core_mkey      umr_mkey;
 	struct mlx5e_rq            drop_rq;
 
 	struct mlx5e_channel     **channel;
@@ -838,8 +837,7 @@ static inline void mlx5e_cq_arm(struct mlx5e_cq *cq)
 
 static inline u32 mlx5e_get_wqe_mtt_offset(struct mlx5e_rq *rq, u16 wqe_ix)
 {
-	return rq->mpwqe.mtt_offset +
-		wqe_ix * ALIGN(MLX5_MPWRQ_PAGES_PER_WQE, 8);
+	return wqe_ix * ALIGN(MLX5_MPWRQ_PAGES_PER_WQE, 8);
 }
 
 static inline int mlx5e_get_max_num_channels(struct mlx5_core_dev *mdev)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index aa963d7..352462a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -499,8 +499,7 @@ static int mlx5e_set_ringparam(struct net_device *dev,
 		return -EINVAL;
 	}
 
-	num_mtts = MLX5E_REQUIRED_MTTS(priv->params.num_channels,
-				       rx_pending_wqes);
+	num_mtts = MLX5E_REQUIRED_MTTS(rx_pending_wqes);
 	if (priv->params.rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ &&
 	    !MLX5E_VALID_NUM_MTTS(num_mtts)) {
 		netdev_info(dev, "%s: rx_pending (%d) request can't be satisfied, try to reduce.\n",
@@ -565,7 +564,6 @@ static int mlx5e_set_channels(struct net_device *dev,
 	unsigned int count = ch->combined_count;
 	bool arfs_enabled;
 	bool was_opened;
-	u32 num_mtts;
 	int err = 0;
 
 	if (!count) {
@@ -584,14 +582,6 @@ static int mlx5e_set_channels(struct net_device *dev,
 		return -EINVAL;
 	}
 
-	num_mtts = MLX5E_REQUIRED_MTTS(count, BIT(priv->params.log_rq_size));
-	if (priv->params.rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ &&
-	    !MLX5E_VALID_NUM_MTTS(num_mtts)) {
-		netdev_info(dev, "%s: rx count (%d) request can't be satisfied, try to reduce.\n",
-			    __func__, count);
-		return -EINVAL;
-	}
-
 	if (priv->params.num_channels == count)
 		return 0;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 49ca30b..84a4adb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -471,24 +471,25 @@ static void mlx5e_rq_free_mpwqe_info(struct mlx5e_rq *rq)
 	kfree(rq->mpwqe.info);
 }
 
-static int mlx5e_create_umr_mkey(struct mlx5e_priv *priv)
+static int mlx5e_create_umr_mkey(struct mlx5e_priv *priv,
+				 u64 npages, u8 page_shift,
+				 struct mlx5_core_mkey *umr_mkey)
 {
 	struct mlx5_core_dev *mdev = priv->mdev;
-	u64 npages = MLX5E_REQUIRED_MTTS(priv->profile->max_nch(mdev),
-					 BIT(MLX5E_PARAMS_MAXIMUM_LOG_RQ_SIZE_MPW));
 	int inlen = MLX5_ST_SZ_BYTES(create_mkey_in);
 	void *mkc;
 	u32 *in;
 	int err;
 
+	if (!MLX5E_VALID_NUM_MTTS(npages))
+		return -EINVAL;
+
 	in = mlx5_vzalloc(inlen);
 	if (!in)
 		return -ENOMEM;
 
 	mkc = MLX5_ADDR_OF(create_mkey_in, in, memory_key_mkey_entry);
 
-	npages = min_t(u32, ALIGN(U16_MAX, 4) * 2, npages);
-
 	MLX5_SET(mkc, mkc, free, 1);
 	MLX5_SET(mkc, mkc, umr_en, 1);
 	MLX5_SET(mkc, mkc, lw, 1);
@@ -497,17 +498,25 @@ static int mlx5e_create_umr_mkey(struct mlx5e_priv *priv)
 
 	MLX5_SET(mkc, mkc, qpn, 0xffffff);
 	MLX5_SET(mkc, mkc, pd, mdev->mlx5e_res.pdn);
-	MLX5_SET64(mkc, mkc, len, npages << PAGE_SHIFT);
+	MLX5_SET64(mkc, mkc, len, npages << page_shift);
 	MLX5_SET(mkc, mkc, translations_octword_size,
 		 MLX5_MTT_OCTW(npages));
-	MLX5_SET(mkc, mkc, log_page_size, PAGE_SHIFT);
+	MLX5_SET(mkc, mkc, log_page_size, page_shift);
 
-	err = mlx5_core_create_mkey(mdev, &priv->umr_mkey, in, inlen);
+	err = mlx5_core_create_mkey(mdev, umr_mkey, in, inlen);
 
 	kvfree(in);
 	return err;
 }
 
+static int mlx5e_create_rq_umr_mkey(struct mlx5e_rq *rq)
+{
+	struct mlx5e_priv *priv = rq->priv;
+	u64 num_mtts = MLX5E_REQUIRED_MTTS(BIT(priv->params.log_rq_size));
+
+	return mlx5e_create_umr_mkey(priv, num_mtts, PAGE_SHIFT, &rq->umr_mkey);
+}
+
 static int mlx5e_create_rq(struct mlx5e_channel *c,
 			   struct mlx5e_rq_param *param,
 			   struct mlx5e_rq *rq)
@@ -564,18 +573,20 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 		rq->alloc_wqe = mlx5e_alloc_rx_mpwqe;
 		rq->dealloc_wqe = mlx5e_dealloc_rx_mpwqe;
 
-		rq->mpwqe.mtt_offset = c->ix *
-			MLX5E_REQUIRED_MTTS(1, BIT(priv->params.log_rq_size));
-
 		rq->mpwqe_stride_sz = BIT(priv->params.mpwqe_log_stride_sz);
 		rq->mpwqe_num_strides = BIT(priv->params.mpwqe_log_num_strides);
 
 		rq->buff.wqe_sz = rq->mpwqe_stride_sz * rq->mpwqe_num_strides;
 		byte_count = rq->buff.wqe_sz;
-		rq->mkey_be = cpu_to_be32(c->priv->umr_mkey.key);
-		err = mlx5e_rq_alloc_mpwqe_info(rq, c);
+
+		err = mlx5e_create_rq_umr_mkey(rq);
 		if (err)
 			goto err_rq_wq_destroy;
+		rq->mkey_be = cpu_to_be32(rq->umr_mkey.key);
+
+		err = mlx5e_rq_alloc_mpwqe_info(rq, c);
+		if (err)
+			goto err_destroy_umr_mkey;
 		break;
 	default: /* MLX5_WQ_TYPE_LINKED_LIST */
 		rq->dma_info = kzalloc_node(wq_sz * sizeof(*rq->dma_info),
@@ -626,6 +637,9 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 
 	return 0;
 
+err_destroy_umr_mkey:
+	mlx5_core_destroy_mkey(mdev, &rq->umr_mkey);
+
 err_rq_wq_destroy:
 	if (rq->xdp_prog)
 		bpf_prog_put(rq->xdp_prog);
@@ -644,6 +658,7 @@ static void mlx5e_destroy_rq(struct mlx5e_rq *rq)
 	switch (rq->wq_type) {
 	case MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ:
 		mlx5e_rq_free_mpwqe_info(rq);
+		mlx5_core_destroy_mkey(rq->priv->mdev, &rq->umr_mkey);
 		break;
 	default: /* MLX5_WQ_TYPE_LINKED_LIST */
 		kfree(rq->dma_info);
@@ -3868,15 +3883,9 @@ int mlx5e_attach_netdev(struct mlx5_core_dev *mdev, struct net_device *netdev)
 	profile = priv->profile;
 	clear_bit(MLX5E_STATE_DESTROYING, &priv->state);
 
-	err = mlx5e_create_umr_mkey(priv);
-	if (err) {
-		mlx5_core_err(mdev, "create umr mkey failed, %d\n", err);
-		goto out;
-	}
-
 	err = profile->init_tx(priv);
 	if (err)
-		goto err_destroy_umr_mkey;
+		goto out;
 
 	err = mlx5e_open_drop_rq(priv);
 	if (err) {
@@ -3916,9 +3925,6 @@ int mlx5e_attach_netdev(struct mlx5_core_dev *mdev, struct net_device *netdev)
 err_cleanup_tx:
 	profile->cleanup_tx(priv);
 
-err_destroy_umr_mkey:
-	mlx5_core_destroy_mkey(mdev, &priv->umr_mkey);
-
 out:
 	return err;
 }
@@ -3967,7 +3973,6 @@ void mlx5e_detach_netdev(struct mlx5_core_dev *mdev, struct net_device *netdev)
 	profile->cleanup_rx(priv);
 	mlx5e_close_drop_rq(priv);
 	profile->cleanup_tx(priv);
-	mlx5_core_destroy_mkey(priv->mdev, &priv->umr_mkey);
 	cancel_delayed_work_sync(&priv->update_stats_work);
 }
 
-- 
2.7.4
