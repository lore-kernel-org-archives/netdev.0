From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 15/16] net/mlx5: Add Representors registration API
Date: Thu, 30 Jun 2016 18:23:34 +0300
Message-ID: <1467300215-14199-16-git-send-email-saeedm@mellanox.com>
References: <1467300215-14199-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:43354 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752448AbcF3P0Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2016 11:26:25 -0400
In-Reply-To: <1467300215-14199-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

Introduce E-Switch registration/unregister representors functions.

Those functions are called by the mlx5e driver when the PF NIC is
created upon pci probe action regardless of the E-Switch mode (NONE,
LEGACY or OFFLOADS).

Adding basic E-Switch database that will hold the vport represntors
upon creation.

This patch doesn't add any new functionality.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  3 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 60 +++++++++++++++++++---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  | 10 ++++
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  | 12 +++++
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 19 +++++++
 5 files changed, 97 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 8d4d2b2..f61255c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -571,7 +571,7 @@ enum {
 struct mlx5e_profile {
 	void	(*init)(struct mlx5_core_dev *mdev,
 			struct net_device *netdev,
-			const struct mlx5e_profile *profile);
+			const struct mlx5e_profile *profile, void *ppriv);
 	void	(*cleanup)(struct mlx5e_priv *priv);
 	int	(*init_rx)(struct mlx5e_priv *priv);
 	void	(*cleanup_rx)(struct mlx5e_priv *priv);
@@ -618,6 +618,7 @@ struct mlx5e_priv {
 	struct mlx5e_tstamp        tstamp;
 	u16 q_counter;
 	const struct mlx5e_profile *profile;
+	void                      *ppriv;
 };
 
 enum mlx5e_link_mode {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 8ffe68b..bfe3a4c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2881,7 +2881,8 @@ void mlx5e_set_rx_cq_mode_params(struct mlx5e_params *params, u8 cq_period_mode)
 
 static void mlx5e_build_nic_netdev_priv(struct mlx5_core_dev *mdev,
 					struct net_device *netdev,
-					const struct mlx5e_profile *profile)
+					const struct mlx5e_profile *profile,
+					void *ppriv)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 	u32 link_speed = 0;
@@ -2963,6 +2964,7 @@ static void mlx5e_build_nic_netdev_priv(struct mlx5_core_dev *mdev,
 	priv->netdev                       = netdev;
 	priv->params.num_channels          = profile->max_nch(mdev);
 	priv->profile                      = profile;
+	priv->ppriv                        = ppriv;
 
 #ifdef CONFIG_MLX5_CORE_EN_DCB
 	mlx5e_ets_init(priv);
@@ -3127,18 +3129,25 @@ static int mlx5e_create_umr_mkey(struct mlx5e_priv *priv)
 
 static void mlx5e_nic_init(struct mlx5_core_dev *mdev,
 			   struct net_device *netdev,
-			   const struct mlx5e_profile *profile)
+			   const struct mlx5e_profile *profile,
+			   void *ppriv)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 
-	mlx5e_build_nic_netdev_priv(mdev, netdev, profile);
+	mlx5e_build_nic_netdev_priv(mdev, netdev, profile, ppriv);
 	mlx5e_build_nic_netdev(netdev);
 	mlx5e_vxlan_init(priv);
 }
 
 static void mlx5e_nic_cleanup(struct mlx5e_priv *priv)
 {
+	struct mlx5_core_dev *mdev = priv->mdev;
+	struct mlx5_eswitch *esw = mdev->priv.eswitch;
+
 	mlx5e_vxlan_cleanup(priv);
+
+	if (MLX5_CAP_GEN(mdev, vport_group_manager))
+		mlx5_eswitch_unregister_vport_rep(esw, 0);
 }
 
 static int mlx5e_init_nic_rx(struct mlx5e_priv *priv)
@@ -3230,6 +3239,8 @@ static void mlx5e_nic_enable(struct mlx5e_priv *priv)
 {
 	struct net_device *netdev = priv->netdev;
 	struct mlx5_core_dev *mdev = priv->mdev;
+	struct mlx5_eswitch *esw = mdev->priv.eswitch;
+	struct mlx5_eswitch_rep rep;
 
 	if (mlx5e_vxlan_allowed(mdev)) {
 		rtnl_lock();
@@ -3239,6 +3250,12 @@ static void mlx5e_nic_enable(struct mlx5e_priv *priv)
 
 	mlx5e_enable_async_events(priv);
 	queue_work(priv->wq, &priv->set_rx_mode_work);
+
+	if (MLX5_CAP_GEN(mdev, vport_group_manager)) {
+		rep.vport = 0;
+		rep.priv_data = priv;
+		mlx5_eswitch_register_vport_rep(esw, &rep);
+	}
 }
 
 static void mlx5e_nic_disable(struct mlx5e_priv *priv)
@@ -3262,7 +3279,7 @@ static const struct mlx5e_profile mlx5e_nic_profile = {
 };
 
 static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev,
-				 const struct mlx5e_profile *profile)
+				 const struct mlx5e_profile *profile, void *ppriv)
 {
 	struct net_device *netdev;
 	struct mlx5e_priv *priv;
@@ -3277,7 +3294,7 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev,
 		return NULL;
 	}
 
-	profile->init(mdev, netdev, profile);
+	profile->init(mdev, netdev, profile, ppriv);
 
 	netif_carrier_off(netdev);
 
@@ -3344,8 +3361,27 @@ err_free_netdev:
 	return NULL;
 }
 
+static void mlx5e_register_vport_rep(struct mlx5_core_dev *mdev)
+{
+	struct mlx5_eswitch *esw = mdev->priv.eswitch;
+	int total_vfs = MLX5_TOTAL_VPORTS(mdev);
+	int vport;
+
+	if (!MLX5_CAP_GEN(mdev, vport_group_manager))
+		return;
+
+	for (vport = 1; vport < total_vfs; vport++) {
+		struct mlx5_eswitch_rep rep;
+
+		rep.vport = vport;
+		mlx5_eswitch_register_vport_rep(esw, &rep);
+	}
+}
+
 static void *mlx5e_add(struct mlx5_core_dev *mdev)
 {
+	struct mlx5_eswitch *esw = mdev->priv.eswitch;
+	void *ppriv = NULL;
 	void *ret;
 
 	if (mlx5e_check_required_hca_cap(mdev))
@@ -3354,7 +3390,12 @@ static void *mlx5e_add(struct mlx5_core_dev *mdev)
 	if (mlx5e_create_mdev_resources(mdev))
 		return NULL;
 
-	ret = mlx5e_create_netdev(mdev, &mlx5e_nic_profile);
+	mlx5e_register_vport_rep(mdev);
+
+	if (MLX5_CAP_GEN(mdev, vport_group_manager))
+		ppriv = &esw->offloads.vport_reps[0];
+
+	ret = mlx5e_create_netdev(mdev, &mlx5e_nic_profile, ppriv);
 	if (!ret) {
 		mlx5e_destroy_mdev_resources(mdev);
 		return NULL;
@@ -3395,9 +3436,16 @@ static void mlx5e_destroy_netdev(struct mlx5_core_dev *mdev, struct mlx5e_priv *
 
 static void mlx5e_remove(struct mlx5_core_dev *mdev, void *vpriv)
 {
+	struct mlx5_eswitch *esw = mdev->priv.eswitch;
+	int total_vfs = MLX5_TOTAL_VPORTS(mdev);
 	struct mlx5e_priv *priv = vpriv;
+	int vport;
 
 	mlx5e_destroy_netdev(mdev, priv);
+
+	for (vport = 1; vport < total_vfs; vport++)
+		mlx5_eswitch_unregister_vport_rep(esw, vport);
+
 	mlx5e_destroy_mdev_resources(mdev);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index 12f509c..f0a9735 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -1663,6 +1663,14 @@ int mlx5_eswitch_init(struct mlx5_core_dev *dev)
 		goto abort;
 	}
 
+	esw->offloads.vport_reps =
+		kzalloc(total_vports * sizeof(struct mlx5_eswitch_rep),
+			GFP_KERNEL);
+	if (!esw->offloads.vport_reps) {
+		err = -ENOMEM;
+		goto abort;
+	}
+
 	mutex_init(&esw->state_lock);
 
 	for (vport_num = 0; vport_num < total_vports; vport_num++) {
@@ -1687,6 +1695,7 @@ abort:
 		destroy_workqueue(esw->work_queue);
 	kfree(esw->l2_table.bitmap);
 	kfree(esw->vports);
+	kfree(esw->offloads.vport_reps);
 	kfree(esw);
 	return err;
 }
@@ -1704,6 +1713,7 @@ void mlx5_eswitch_cleanup(struct mlx5_eswitch *esw)
 	destroy_workqueue(esw->work_queue);
 	kfree(esw->l2_table.bitmap);
 	kfree(esw->mc_promisc);
+	kfree(esw->offloads.vport_reps);
 	kfree(esw->vports);
 	kfree(esw);
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index 7843f98..ffe5eab 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -156,9 +156,17 @@ enum {
 	SRIOV_OFFLOADS
 };
 
+
+struct mlx5_eswitch_rep {
+	u16		       vport;
+	void		      *priv_data;
+	bool		       valid;
+};
+
 struct mlx5_esw_offload {
 	struct mlx5_flow_table *ft_offloads;
 	struct mlx5_flow_group *vport_rx_group;
+	struct mlx5_eswitch_rep *vport_reps;
 };
 
 struct mlx5_eswitch {
@@ -208,6 +216,10 @@ mlx5_eswitch_create_vport_rx_rule(struct mlx5_eswitch *esw, int vport, u32 tirn)
 
 int mlx5_devlink_eswitch_mode_set(struct devlink *devlink, u16 mode);
 int mlx5_devlink_eswitch_mode_get(struct devlink *devlink, u16 *mode);
+void mlx5_eswitch_register_vport_rep(struct mlx5_eswitch *esw,
+				     struct mlx5_eswitch_rep *rep);
+void mlx5_eswitch_unregister_vport_rep(struct mlx5_eswitch *esw,
+				       int vport);
 
 #define MLX5_DEBUG_ESWITCH_MASK BIT(3)
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index 312b6f3..f84aa79 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -451,3 +451,22 @@ int mlx5_devlink_eswitch_mode_get(struct devlink *devlink, u16 *mode)
 
 	return 0;
 }
+
+void mlx5_eswitch_register_vport_rep(struct mlx5_eswitch *esw,
+				     struct mlx5_eswitch_rep *rep)
+{
+	struct mlx5_esw_offload *offloads = &esw->offloads;
+
+	memcpy(&offloads->vport_reps[rep->vport], rep,
+	       sizeof(struct mlx5_eswitch_rep));
+
+	offloads->vport_reps[rep->vport].valid = true;
+}
+
+void mlx5_eswitch_unregister_vport_rep(struct mlx5_eswitch *esw,
+				       int vport)
+{
+	struct mlx5_esw_offload *offloads = &esw->offloads;
+
+	offloads->vport_reps[vport].valid = false;
+}
-- 
2.8.0
