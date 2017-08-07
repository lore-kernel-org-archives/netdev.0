From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [for-next 3/8] net/mlx5: Unify vport manager capability check
Date: Mon,  7 Aug 2017 13:18:03 +0300
Message-ID: <20170807101808.22924-4-saeedm@mellanox.com>
References: <20170807101808.22924-1-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170807101808.22924-1-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Expose MLX5_VPORT_MANAGER macro to check for strict vport manager
E-switch and MPFS (Multi Physical Function Switch) abilities.

VPORT manager must be a PF with an ethernet link and with FW advertised
vport group manager capability

Replace older checks with the new macro and use it where needed in
eswitch.c and mlx5e netdev eswitch related flows.

The same macro will be reused in MPFS separation downstream patch.

Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 18 ++++++-----------
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |  4 +---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  | 23 ++++++++--------------
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |  4 ++++
 4 files changed, 19 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index b44d6f677845..e3c858c44532 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2581,12 +2581,6 @@ static void mlx5e_build_channels_tx_maps(struct mlx5e_priv *priv)
 	}
 }
 
-static bool mlx5e_is_eswitch_vport_mngr(struct mlx5_core_dev *mdev)
-{
-	return (MLX5_CAP_GEN(mdev, vport_group_manager) &&
-		MLX5_CAP_GEN(mdev, port_type) == MLX5_CAP_PORT_TYPE_ETH);
-}
-
 void mlx5e_activate_priv_channels(struct mlx5e_priv *priv)
 {
 	int num_txqs = priv->channels.num * priv->channels.params.num_tc;
@@ -2600,7 +2594,7 @@ void mlx5e_activate_priv_channels(struct mlx5e_priv *priv)
 	mlx5e_activate_channels(&priv->channels);
 	netif_tx_start_all_queues(priv->netdev);
 
-	if (mlx5e_is_eswitch_vport_mngr(priv->mdev))
+	if (MLX5_VPORT_MANAGER(priv->mdev))
 		mlx5e_add_sqs_fwd_rules(priv);
 
 	mlx5e_wait_channels_min_rx_wqes(&priv->channels);
@@ -2611,7 +2605,7 @@ void mlx5e_deactivate_priv_channels(struct mlx5e_priv *priv)
 {
 	mlx5e_redirect_rqts_to_drop(priv);
 
-	if (mlx5e_is_eswitch_vport_mngr(priv->mdev))
+	if (MLX5_VPORT_MANAGER(priv->mdev))
 		mlx5e_remove_sqs_fwd_rules(priv);
 
 	/* FIXME: This is a W/A only for tx timeout watch dog false alarm when
@@ -4079,7 +4073,7 @@ static void mlx5e_build_nic_netdev(struct net_device *netdev)
 	mlx5e_set_netdev_dev_addr(netdev);
 
 #ifdef CONFIG_NET_SWITCHDEV
-	if (MLX5_CAP_GEN(mdev, vport_group_manager))
+	if (MLX5_VPORT_MANAGER(mdev))
 		netdev->switchdev_ops = &mlx5e_switchdev_ops;
 #endif
 
@@ -4221,7 +4215,7 @@ static void mlx5e_nic_enable(struct mlx5e_priv *priv)
 
 	mlx5e_enable_async_events(priv);
 
-	if (MLX5_CAP_GEN(mdev, vport_group_manager))
+	if (MLX5_VPORT_MANAGER(priv->mdev))
 		mlx5e_register_vport_reps(priv);
 
 	if (netdev->reg_state != NETREG_REGISTERED)
@@ -4255,7 +4249,7 @@ static void mlx5e_nic_disable(struct mlx5e_priv *priv)
 
 	queue_work(priv->wq, &priv->set_rx_mode_work);
 
-	if (MLX5_CAP_GEN(mdev, vport_group_manager))
+	if (MLX5_VPORT_MANAGER(priv->mdev))
 		mlx5e_unregister_vport_reps(priv);
 
 	mlx5e_disable_async_events(priv);
@@ -4437,7 +4431,7 @@ static void *mlx5e_add(struct mlx5_core_dev *mdev)
 	if (err)
 		return NULL;
 
-	if (MLX5_CAP_GEN(mdev, vport_group_manager)) {
+	if (MLX5_VPORT_MANAGER(mdev)) {
 		rpriv = mlx5e_alloc_nic_rep_priv(mdev);
 		if (!rpriv) {
 			mlx5_core_warn(mdev, "Failed to alloc NIC rep priv data\n");
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
index 52b9a64cd3a2..24d2f707fdfc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
@@ -688,9 +688,7 @@ int mlx5_start_eqs(struct mlx5_core_dev *dev)
 	u64 async_event_mask = MLX5_ASYNC_EVENT_MASK;
 	int err;
 
-	if (MLX5_CAP_GEN(dev, port_type) == MLX5_CAP_PORT_TYPE_ETH &&
-	    MLX5_CAP_GEN(dev, vport_group_manager) &&
-	    mlx5_core_is_pf(dev))
+	if (MLX5_VPORT_MANAGER(dev))
 		async_event_mask |= (1ull << MLX5_EVENT_TYPE_NIC_VPORT_CHANGE);
 
 	if (MLX5_CAP_GEN(dev, port_module_event))
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index 8b18cc9ec026..5c001b61d04a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -1611,13 +1611,14 @@ static void esw_disable_vport(struct mlx5_eswitch *esw, int vport_num)
 }
 
 /* Public E-Switch API */
+#define ESW_ALLOWED(esw) ((esw) && MLX5_VPORT_MANAGER((esw)->dev))
+
 int mlx5_eswitch_enable_sriov(struct mlx5_eswitch *esw, int nvfs, int mode)
 {
 	int err;
 	int i, enabled_events;
 
-	if (!esw || !MLX5_CAP_GEN(esw->dev, vport_group_manager) ||
-	    MLX5_CAP_GEN(esw->dev, port_type) != MLX5_CAP_PORT_TYPE_ETH)
+	if (!ESW_ALLOWED(esw))
 		return 0;
 
 	if (!MLX5_CAP_GEN(esw->dev, eswitch_flow_table) ||
@@ -1667,9 +1668,7 @@ void mlx5_eswitch_disable_sriov(struct mlx5_eswitch *esw)
 	int nvports;
 	int i;
 
-	if (!esw || !MLX5_CAP_GEN(esw->dev, vport_group_manager) ||
-	    MLX5_CAP_GEN(esw->dev, port_type) != MLX5_CAP_PORT_TYPE_ETH ||
-	    esw->mode == SRIOV_NONE)
+	if (!ESW_ALLOWED(esw) || esw->mode == SRIOV_NONE)
 		return;
 
 	esw_info(esw->dev, "disable SRIOV: active vports(%d) mode(%d)\n",
@@ -1698,8 +1697,7 @@ void mlx5_eswitch_disable_sriov(struct mlx5_eswitch *esw)
 
 void mlx5_eswitch_attach(struct mlx5_eswitch *esw)
 {
-	if (!esw || !MLX5_CAP_GEN(esw->dev, vport_group_manager) ||
-	    MLX5_CAP_GEN(esw->dev, port_type) != MLX5_CAP_PORT_TYPE_ETH)
+	if (!ESW_ALLOWED(esw))
 		return;
 
 	esw_enable_vport(esw, 0, UC_ADDR_CHANGE);
@@ -1708,8 +1706,7 @@ void mlx5_eswitch_attach(struct mlx5_eswitch *esw)
 
 void mlx5_eswitch_detach(struct mlx5_eswitch *esw)
 {
-	if (!esw || !MLX5_CAP_GEN(esw->dev, vport_group_manager) ||
-	    MLX5_CAP_GEN(esw->dev, port_type) != MLX5_CAP_PORT_TYPE_ETH)
+	if (!ESW_ALLOWED(esw))
 		return;
 
 	esw_disable_vport(esw, 0);
@@ -1723,8 +1720,7 @@ int mlx5_eswitch_init(struct mlx5_core_dev *dev)
 	int vport_num;
 	int err;
 
-	if (!MLX5_CAP_GEN(dev, vport_group_manager) ||
-	    MLX5_CAP_GEN(dev, port_type) != MLX5_CAP_PORT_TYPE_ETH)
+	if (!MLX5_VPORT_MANAGER(dev))
 		return 0;
 
 	esw_info(dev,
@@ -1806,8 +1802,7 @@ int mlx5_eswitch_init(struct mlx5_core_dev *dev)
 
 void mlx5_eswitch_cleanup(struct mlx5_eswitch *esw)
 {
-	if (!esw || !MLX5_CAP_GEN(esw->dev, vport_group_manager) ||
-	    MLX5_CAP_GEN(esw->dev, port_type) != MLX5_CAP_PORT_TYPE_ETH)
+	if (!esw || !MLX5_VPORT_MANAGER(esw->dev))
 		return;
 
 	esw_info(esw->dev, "cleanup\n");
@@ -1838,8 +1833,6 @@ void mlx5_eswitch_vport_event(struct mlx5_eswitch *esw, struct mlx5_eqe *eqe)
 }
 
 /* Vport Administration */
-#define ESW_ALLOWED(esw) \
-	(esw && MLX5_CAP_GEN(esw->dev, vport_group_manager) && mlx5_core_is_pf(esw->dev))
 #define LEGAL_VPORT(esw, vport) (vport >= 0 && vport < esw->total_vports)
 
 int mlx5_eswitch_set_vport_mac(struct mlx5_eswitch *esw,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index 6a263e8d883a..d8da9240a00b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -43,6 +43,10 @@
 #define DRIVER_VERSION "5.0-0"
 
 #define MLX5_TOTAL_VPORTS(mdev) (1 + pci_sriov_get_totalvfs(mdev->pdev))
+#define MLX5_VPORT_MANAGER(mdev) \
+	(MLX5_CAP_GEN(mdev, vport_group_manager) && \
+	(MLX5_CAP_GEN(mdev, port_type) == MLX5_CAP_PORT_TYPE_ETH) && \
+	 mlx5_core_is_pf(mdev))
 
 extern uint mlx5_core_debug_mask;
 
-- 
2.13.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
