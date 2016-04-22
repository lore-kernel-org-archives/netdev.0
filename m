From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 10/12] net/mlx5e: Add ethtool support for rxvlan-offload (vlan stripping)
Date: Fri, 22 Apr 2016 22:00:45 +0300
Message-ID: <1461351647-27412-11-git-send-email-saeedm@mellanox.com>
References: <1461351647-27412-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Gal Pressman <galp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:36956 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752004AbcDVTCd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 15:02:33 -0400
In-Reply-To: <1461351647-27412-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Use ethtool -K <interface> rxvlan <on/off> to enable/disable
C-TAG vlan stripping by hardware.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |    3 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   74 ++++++++++++++++++++-
 include/linux/mlx5/driver.h                       |    4 +
 3 files changed, 78 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index e903eff..8abc289 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -166,6 +166,7 @@ struct mlx5e_params {
 	u8  rss_hfunc;
 	u8  toeplitz_hash_key[40];
 	u32 indirection_rqt[MLX5E_INDIR_RQT_SIZE];
+	bool vlan_strip_disable;
 #ifdef CONFIG_MLX5_CORE_EN_DCB
 	struct ieee_ets ets;
 #endif
@@ -575,6 +576,8 @@ int mlx5e_vlan_rx_kill_vid(struct net_device *dev, __always_unused __be16 proto,
 void mlx5e_enable_vlan_filter(struct mlx5e_priv *priv);
 void mlx5e_disable_vlan_filter(struct mlx5e_priv *priv);
 
+int mlx5e_modify_rqs_vsd(struct mlx5e_priv *priv, bool vsd);
+
 int mlx5e_redirect_rqt(struct mlx5e_priv *priv, enum mlx5e_rqt_ix rqt_ix);
 void mlx5e_build_tir_ctx_hash(void *tirc, struct mlx5e_priv *priv);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index ad0cb4a..6c9c10c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -388,6 +388,7 @@ static int mlx5e_enable_rq(struct mlx5e_rq *rq, struct mlx5e_rq_param *param)
 	MLX5_SET(rqc,  rqc, cqn,		rq->cq.mcq.cqn);
 	MLX5_SET(rqc,  rqc, state,		MLX5_RQC_STATE_RST);
 	MLX5_SET(rqc,  rqc, flush_in_error_en,	1);
+	MLX5_SET(rqc,  rqc, vsd, priv->params.vlan_strip_disable);
 	MLX5_SET(wq,   wq,  log_wq_pg_sz,	rq->wq_ctrl.buf.page_shift -
 						MLX5_ADAPTER_PAGE_SHIFT);
 	MLX5_SET64(wq, wq,  dbr_addr,		rq->wq_ctrl.db.dma);
@@ -402,7 +403,8 @@ static int mlx5e_enable_rq(struct mlx5e_rq *rq, struct mlx5e_rq_param *param)
 	return err;
 }
 
-static int mlx5e_modify_rq(struct mlx5e_rq *rq, int curr_state, int next_state)
+static int mlx5e_modify_rq_state(struct mlx5e_rq *rq, int curr_state,
+				 int next_state)
 {
 	struct mlx5e_channel *c = rq->channel;
 	struct mlx5e_priv *priv = c->priv;
@@ -430,6 +432,36 @@ static int mlx5e_modify_rq(struct mlx5e_rq *rq, int curr_state, int next_state)
 	return err;
 }
 
+static int mlx5e_modify_rq_vsd(struct mlx5e_rq *rq, bool vsd)
+{
+	struct mlx5e_channel *c = rq->channel;
+	struct mlx5e_priv *priv = c->priv;
+	struct mlx5_core_dev *mdev = priv->mdev;
+
+	void *in;
+	void *rqc;
+	int inlen;
+	int err;
+
+	inlen = MLX5_ST_SZ_BYTES(modify_rq_in);
+	in = mlx5_vzalloc(inlen);
+	if (!in)
+		return -ENOMEM;
+
+	rqc = MLX5_ADDR_OF(modify_rq_in, in, ctx);
+
+	MLX5_SET(modify_rq_in, in, rq_state, MLX5_RQC_STATE_RDY);
+	MLX5_SET64(modify_rq_in, in, modify_bitmask, MLX5_RQ_BITMASK_VSD);
+	MLX5_SET(rqc, rqc, vsd, vsd);
+	MLX5_SET(rqc, rqc, state, MLX5_RQC_STATE_RDY);
+
+	err = mlx5_core_modify_rq(mdev, rq->rqn, in, inlen);
+
+	kvfree(in);
+
+	return err;
+}
+
 static void mlx5e_disable_rq(struct mlx5e_rq *rq)
 {
 	mlx5_core_destroy_rq(rq->priv->mdev, rq->rqn);
@@ -468,7 +500,7 @@ static int mlx5e_open_rq(struct mlx5e_channel *c,
 	if (err)
 		goto err_destroy_rq;
 
-	err = mlx5e_modify_rq(rq, MLX5_RQC_STATE_RST, MLX5_RQC_STATE_RDY);
+	err = mlx5e_modify_rq_state(rq, MLX5_RQC_STATE_RST, MLX5_RQC_STATE_RDY);
 	if (err)
 		goto err_disable_rq;
 
@@ -493,7 +525,7 @@ static void mlx5e_close_rq(struct mlx5e_rq *rq)
 	clear_bit(MLX5E_RQ_STATE_POST_WQES_ENABLE, &rq->state);
 	napi_synchronize(&rq->channel->napi); /* prevent mlx5e_post_rx_wqes */
 
-	mlx5e_modify_rq(rq, MLX5_RQC_STATE_RDY, MLX5_RQC_STATE_ERR);
+	mlx5e_modify_rq_state(rq, MLX5_RQC_STATE_RDY, MLX5_RQC_STATE_ERR);
 	while (!mlx5_wq_ll_is_empty(&rq->wq))
 		msleep(20);
 
@@ -1963,6 +1995,23 @@ static void mlx5e_destroy_tirs(struct mlx5e_priv *priv)
 		mlx5e_destroy_tir(priv, i);
 }
 
+int mlx5e_modify_rqs_vsd(struct mlx5e_priv *priv, bool vsd)
+{
+	int err = 0;
+	int i;
+
+	if (!test_bit(MLX5E_STATE_OPENED, &priv->state))
+		return 0;
+
+	for (i = 0; i < priv->params.num_channels; i++) {
+		err = mlx5e_modify_rq_vsd(&priv->channel[i]->rq, vsd);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
 static int mlx5e_setup_tc(struct net_device *netdev, u8 tc)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
@@ -2147,6 +2196,23 @@ static int set_feature_rx_all(struct net_device *netdev, bool enable)
 	return mlx5_set_port_fcs(mdev, !enable);
 }
 
+static int set_feature_rx_vlan(struct net_device *netdev, bool enable)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+	int err;
+
+	mutex_lock(&priv->state_lock);
+
+	priv->params.vlan_strip_disable = !enable;
+	err = mlx5e_modify_rqs_vsd(priv, !enable);
+	if (err)
+		priv->params.vlan_strip_disable = enable;
+
+	mutex_unlock(&priv->state_lock);
+
+	return err;
+}
+
 static int mlx5e_handle_feature(struct net_device *netdev,
 				netdev_features_t wanted_features,
 				netdev_features_t feature,
@@ -2184,6 +2250,8 @@ static int mlx5e_set_features(struct net_device *netdev,
 				    set_feature_tc_num_filters);
 	err |= mlx5e_handle_feature(netdev, features, NETIF_F_RXALL,
 				    set_feature_rx_all);
+	err |= mlx5e_handle_feature(netdev, features, NETIF_F_HW_VLAN_CTAG_RX,
+				    set_feature_rx_vlan);
 
 	return err ? -EINVAL : 0;
 }
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 1a17067..2cc5e9f 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -46,6 +46,10 @@
 #include <linux/mlx5/doorbell.h>
 
 enum {
+	MLX5_RQ_BITMASK_VSD = 1 << 1,
+};
+
+enum {
 	MLX5_BOARD_ID_LEN = 64,
 	MLX5_MAX_NAME_LEN = 16,
 };
-- 
1.7.1
