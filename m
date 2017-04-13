From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 06/16] net/mlx5e: IPoIB, RX steering RSS RQTs and TIRs
Date: Thu, 13 Apr 2017 06:36:56 +0300
Message-ID: <20170413033706.19016-7-saeedm@mellanox.com>
References: <20170413033706.19016-1-saeedm@mellanox.com>
Cc: linux-rdma@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Erez Shitrit <erezsh@mellanox.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Vishwanathapura Niranjana <niranjana.vishwanathapura@intel.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41694 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755495AbdDMDhn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 23:37:43 -0400
In-Reply-To: <20170413033706.19016-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement IPoIB RX RSS (RQTs and TIRs) HW objects creation,
All we do here is simply reuse the mlx5e implementation to create
direct and indirect (RSS) steering HW objects.

For that we just expose
mlx5e_{create,destroy}_{direct,indirect}_{rqt,tir} functions into en.h
and call them from ipoib.c in init/cleanup_rx IPoIB netdevice profile
callbacks.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reviewed-by: Erez Shitrit <erezsh@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      | 12 ++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 56 ++++++++++++-----------
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c  | 17 ++-----
 drivers/net/ethernet/mellanox/mlx5/core/ipoib.c   | 42 +++++++++++++++--
 4 files changed, 83 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 02aa3cc59dc3..e5518536d56f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -999,10 +999,17 @@ int mlx5e_attr_get(struct net_device *dev, struct switchdev_attr *attr);
 void mlx5e_handle_rx_cqe_rep(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe);
 void mlx5e_update_hw_rep_counters(struct mlx5e_priv *priv);
 
+int mlx5e_create_indirect_rqt(struct mlx5e_priv *priv);
+
+int mlx5e_create_indirect_tirs(struct mlx5e_priv *priv);
+void mlx5e_destroy_indirect_tirs(struct mlx5e_priv *priv);
+
 int mlx5e_create_direct_rqts(struct mlx5e_priv *priv);
-void mlx5e_destroy_rqt(struct mlx5e_priv *priv, struct mlx5e_rqt *rqt);
+void mlx5e_destroy_direct_rqts(struct mlx5e_priv *priv);
 int mlx5e_create_direct_tirs(struct mlx5e_priv *priv);
 void mlx5e_destroy_direct_tirs(struct mlx5e_priv *priv);
+void mlx5e_destroy_rqt(struct mlx5e_priv *priv, struct mlx5e_rqt *rqt);
+
 int mlx5e_create_tises(struct mlx5e_priv *priv);
 void mlx5e_cleanup_nic_tx(struct mlx5e_priv *priv);
 int mlx5e_close(struct net_device *netdev);
@@ -1024,5 +1031,8 @@ mlx5e_create_netdev(struct mlx5_core_dev *mdev, const struct mlx5e_profile *prof
 int mlx5e_attach_netdev(struct mlx5e_priv *priv);
 void mlx5e_detach_netdev(struct mlx5e_priv *priv);
 void mlx5e_destroy_netdev(struct mlx5e_priv *priv);
+void mlx5e_build_nic_params(struct mlx5_core_dev *mdev,
+			    struct mlx5e_params *params,
+			    u16 max_channels);
 
 #endif /* __MLX5_EN_H__ */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 14c7452a6348..08b67aa24644 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2115,11 +2115,15 @@ void mlx5e_destroy_rqt(struct mlx5e_priv *priv, struct mlx5e_rqt *rqt)
 	mlx5_core_destroy_rqt(priv->mdev, rqt->rqtn);
 }
 
-static int mlx5e_create_indirect_rqts(struct mlx5e_priv *priv)
+int mlx5e_create_indirect_rqt(struct mlx5e_priv *priv)
 {
 	struct mlx5e_rqt *rqt = &priv->indir_rqt;
+	int err;
 
-	return mlx5e_create_rqt(priv, MLX5E_INDIR_RQT_SIZE, rqt);
+	err = mlx5e_create_rqt(priv, MLX5E_INDIR_RQT_SIZE, rqt);
+	if (err)
+		mlx5_core_warn(priv->mdev, "create indirect rqts failed, %d\n", err);
+	return err;
 }
 
 int mlx5e_create_direct_rqts(struct mlx5e_priv *priv)
@@ -2138,12 +2142,21 @@ int mlx5e_create_direct_rqts(struct mlx5e_priv *priv)
 	return 0;
 
 err_destroy_rqts:
+	mlx5_core_warn(priv->mdev, "create direct rqts failed, %d\n", err);
 	for (ix--; ix >= 0; ix--)
 		mlx5e_destroy_rqt(priv, &priv->direct_tir[ix].rqt);
 
 	return err;
 }
 
+void mlx5e_destroy_direct_rqts(struct mlx5e_priv *priv)
+{
+	int i;
+
+	for (i = 0; i < priv->profile->max_nch(priv->mdev); i++)
+		mlx5e_destroy_rqt(priv, &priv->direct_tir[i].rqt);
+}
+
 static int mlx5e_rx_hash_fn(int hfunc)
 {
 	return (hfunc == ETH_RSS_HASH_TOP) ?
@@ -2818,7 +2831,7 @@ static void mlx5e_build_direct_tir_ctx(struct mlx5e_priv *priv, u32 rqtn, u32 *t
 	MLX5_SET(tirc, tirc, rx_hash_fn, MLX5_RX_HASH_FN_INVERTED_XOR8);
 }
 
-static int mlx5e_create_indirect_tirs(struct mlx5e_priv *priv)
+int mlx5e_create_indirect_tirs(struct mlx5e_priv *priv)
 {
 	struct mlx5e_tir *tir;
 	void *tirc;
@@ -2847,6 +2860,7 @@ static int mlx5e_create_indirect_tirs(struct mlx5e_priv *priv)
 	return 0;
 
 err_destroy_tirs:
+	mlx5_core_warn(priv->mdev, "create indirect tirs failed, %d\n", err);
 	for (tt--; tt >= 0; tt--)
 		mlx5e_destroy_tir(priv->mdev, &priv->indir_tir[tt]);
 
@@ -2885,6 +2899,7 @@ int mlx5e_create_direct_tirs(struct mlx5e_priv *priv)
 	return 0;
 
 err_destroy_ch_tirs:
+	mlx5_core_warn(priv->mdev, "create direct tirs failed, %d\n", err);
 	for (ix--; ix >= 0; ix--)
 		mlx5e_destroy_tir(priv->mdev, &priv->direct_tir[ix]);
 
@@ -2893,7 +2908,7 @@ int mlx5e_create_direct_tirs(struct mlx5e_priv *priv)
 	return err;
 }
 
-static void mlx5e_destroy_indirect_tirs(struct mlx5e_priv *priv)
+void mlx5e_destroy_indirect_tirs(struct mlx5e_priv *priv)
 {
 	int i;
 
@@ -3794,9 +3809,9 @@ u32 mlx5e_choose_lro_timeout(struct mlx5_core_dev *mdev, u32 wanted_timeout)
 	return MLX5_CAP_ETH(mdev, lro_timer_supported_periods[i]);
 }
 
-static void mlx5e_build_nic_params(struct mlx5_core_dev *mdev,
-				   struct mlx5e_params *params,
-				   u16 max_channels)
+void mlx5e_build_nic_params(struct mlx5_core_dev *mdev,
+			    struct mlx5e_params *params,
+			    u16 max_channels)
 {
 	u8 cq_period_mode = 0;
 	u32 link_speed = 0;
@@ -4031,31 +4046,22 @@ static int mlx5e_init_nic_rx(struct mlx5e_priv *priv)
 {
 	struct mlx5_core_dev *mdev = priv->mdev;
 	int err;
-	int i;
 
-	err = mlx5e_create_indirect_rqts(priv);
-	if (err) {
-		mlx5_core_warn(mdev, "create indirect rqts failed, %d\n", err);
+	err = mlx5e_create_indirect_rqt(priv);
+	if (err)
 		return err;
-	}
 
 	err = mlx5e_create_direct_rqts(priv);
-	if (err) {
-		mlx5_core_warn(mdev, "create direct rqts failed, %d\n", err);
+	if (err)
 		goto err_destroy_indirect_rqts;
-	}
 
 	err = mlx5e_create_indirect_tirs(priv);
-	if (err) {
-		mlx5_core_warn(mdev, "create indirect tirs failed, %d\n", err);
+	if (err)
 		goto err_destroy_direct_rqts;
-	}
 
 	err = mlx5e_create_direct_tirs(priv);
-	if (err) {
-		mlx5_core_warn(mdev, "create direct tirs failed, %d\n", err);
+	if (err)
 		goto err_destroy_indirect_tirs;
-	}
 
 	err = mlx5e_create_flow_steering(priv);
 	if (err) {
@@ -4076,8 +4082,7 @@ static int mlx5e_init_nic_rx(struct mlx5e_priv *priv)
 err_destroy_indirect_tirs:
 	mlx5e_destroy_indirect_tirs(priv);
 err_destroy_direct_rqts:
-	for (i = 0; i < priv->profile->max_nch(mdev); i++)
-		mlx5e_destroy_rqt(priv, &priv->direct_tir[i].rqt);
+	mlx5e_destroy_direct_rqts(priv);
 err_destroy_indirect_rqts:
 	mlx5e_destroy_rqt(priv, &priv->indir_rqt);
 	return err;
@@ -4085,14 +4090,11 @@ static int mlx5e_init_nic_rx(struct mlx5e_priv *priv)
 
 static void mlx5e_cleanup_nic_rx(struct mlx5e_priv *priv)
 {
-	int i;
-
 	mlx5e_tc_cleanup(priv);
 	mlx5e_destroy_flow_steering(priv);
 	mlx5e_destroy_direct_tirs(priv);
 	mlx5e_destroy_indirect_tirs(priv);
-	for (i = 0; i < priv->profile->max_nch(priv->mdev); i++)
-		mlx5e_destroy_rqt(priv, &priv->direct_tir[i].rqt);
+	mlx5e_destroy_direct_rqts(priv);
 	mlx5e_destroy_rqt(priv, &priv->indir_rqt);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index d7664ff5c736..da85b0ad3e92 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -465,24 +465,18 @@ static int mlx5e_init_rep_rx(struct mlx5e_priv *priv)
 {
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
 	struct mlx5_eswitch_rep *rep = priv->ppriv;
-	struct mlx5_core_dev *mdev = priv->mdev;
 	struct mlx5_flow_handle *flow_rule;
 	int err;
-	int i;
 
 	mlx5e_init_l2_addr(priv);
 
 	err = mlx5e_create_direct_rqts(priv);
-	if (err) {
-		mlx5_core_warn(mdev, "create direct rqts failed, %d\n", err);
+	if (err)
 		return err;
-	}
 
 	err = mlx5e_create_direct_tirs(priv);
-	if (err) {
-		mlx5_core_warn(mdev, "create direct tirs failed, %d\n", err);
+	if (err)
 		goto err_destroy_direct_rqts;
-	}
 
 	flow_rule = mlx5_eswitch_create_vport_rx_rule(esw,
 						      rep->vport,
@@ -504,21 +498,18 @@ static int mlx5e_init_rep_rx(struct mlx5e_priv *priv)
 err_destroy_direct_tirs:
 	mlx5e_destroy_direct_tirs(priv);
 err_destroy_direct_rqts:
-	for (i = 0; i < priv->channels.params.num_channels; i++)
-		mlx5e_destroy_rqt(priv, &priv->direct_tir[i].rqt);
+	mlx5e_destroy_direct_rqts(priv);
 	return err;
 }
 
 static void mlx5e_cleanup_rep_rx(struct mlx5e_priv *priv)
 {
 	struct mlx5_eswitch_rep *rep = priv->ppriv;
-	int i;
 
 	mlx5e_tc_cleanup(priv);
 	mlx5_del_flow_rules(rep->vport_rx_rule);
 	mlx5e_destroy_direct_tirs(priv);
-	for (i = 0; i < priv->channels.params.num_channels; i++)
-		mlx5e_destroy_rqt(priv, &priv->direct_tir[i].rqt);
+	mlx5e_destroy_direct_rqts(priv);
 }
 
 static int mlx5e_init_rep_tx(struct mlx5e_priv *priv)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
index 2f65927a8d03..f0318920844e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
@@ -44,8 +44,15 @@ static void mlx5i_init(struct mlx5_core_dev *mdev,
 {
 	struct mlx5e_priv *priv  = mlx5i_epriv(netdev);
 
-	priv->ppriv = ppriv;
-	/*  TODO: init netdev and mlx5e_params here */
+	priv->mdev        = mdev;
+	priv->netdev      = netdev;
+	priv->profile     = profile;
+	priv->ppriv       = ppriv;
+
+	mlx5e_build_nic_params(mdev, &priv->channels.params, profile->max_nch(mdev));
+
+	mutex_init(&priv->state_lock);
+	/* TODO : init netdev features here */
 }
 
 /* Called directly before IPoIB netdevice is destroyed to cleanup SW structs */
@@ -67,12 +74,41 @@ static void mlx5i_cleanup_tx(struct mlx5e_priv *priv)
 
 static int mlx5i_init_rx(struct mlx5e_priv *priv)
 {
-	/* TODO: create IPoIB RX HW steering contexts */
+	int err;
+
+	err = mlx5e_create_indirect_rqt(priv);
+	if (err)
+		return err;
+
+	err = mlx5e_create_direct_rqts(priv);
+	if (err)
+		goto err_destroy_indirect_rqts;
+
+	err = mlx5e_create_indirect_tirs(priv);
+	if (err)
+		goto err_destroy_direct_rqts;
+
+	err = mlx5e_create_direct_tirs(priv);
+	if (err)
+		goto err_destroy_indirect_tirs;
+
 	return 0;
+
+err_destroy_indirect_tirs:
+	mlx5e_destroy_indirect_tirs(priv);
+err_destroy_direct_rqts:
+	mlx5e_destroy_direct_rqts(priv);
+err_destroy_indirect_rqts:
+	mlx5e_destroy_rqt(priv, &priv->indir_rqt);
+	return err;
 }
 
 static void mlx5i_cleanup_rx(struct mlx5e_priv *priv)
 {
+	mlx5e_destroy_direct_tirs(priv);
+	mlx5e_destroy_indirect_tirs(priv);
+	mlx5e_destroy_direct_rqts(priv);
+	mlx5e_destroy_rqt(priv, &priv->indir_rqt);
 }
 
 static const struct mlx5e_profile mlx5i_nic_profile = {
-- 
2.11.0
