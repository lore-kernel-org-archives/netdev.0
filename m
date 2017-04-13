From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 04/16] net/mlx5e: More generic netdev management API
Date: Thu, 13 Apr 2017 06:36:54 +0300
Message-ID: <20170413033706.19016-5-saeedm@mellanox.com>
References: <20170413033706.19016-1-saeedm@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Vishwanathapura Niranjana <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170413033706.19016-1-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In preparation for mlx5e RDMA net_device support, here we generalize
mlx5e_attach/detach in a way that those functions will be agnostic
to link type.  For that we move ethernet specific NIC net device logic out
of those functions into {nic,rep}_{enable/disable} mlx5e NIC and
representor profiles callbacks.

Also some of the logic was moved only to NIC profile since it is not right
to have this logic for representor net device (e.g. set port MTU).

Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Reviewed-by: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  15 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 160 +++++++++++-----------
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c  |  12 +-
 3 files changed, 96 insertions(+), 91 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index b7feecfbb5a5..ced31906b8fd 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -999,12 +999,6 @@ void mlx5e_cleanup_nic_tx(struct mlx5e_priv *priv);
 int mlx5e_close(struct net_device *netdev);
 int mlx5e_open(struct net_device *netdev);
 void mlx5e_update_stats_work(struct work_struct *work);
-struct net_device *mlx5e_create_netdev(struct mlx5_core_dev *mdev,
-				       const struct mlx5e_profile *profile,
-				       void *ppriv);
-void mlx5e_destroy_netdev(struct mlx5_core_dev *mdev, struct mlx5e_priv *priv);
-int mlx5e_attach_netdev(struct mlx5_core_dev *mdev, struct net_device *netdev);
-void mlx5e_detach_netdev(struct mlx5_core_dev *mdev, struct net_device *netdev);
 u32 mlx5e_choose_lro_timeout(struct mlx5_core_dev *mdev, u32 wanted_timeout);
 
 int mlx5e_get_offload_stats(int attr_id, const struct net_device *dev,
@@ -1013,4 +1007,13 @@ bool mlx5e_has_offload_stats(const struct net_device *dev, int attr_id);
 
 bool mlx5e_is_uplink_rep(struct mlx5e_priv *priv);
 bool mlx5e_is_vf_vport_rep(struct mlx5e_priv *priv);
+
+/* mlx5e generic netdev management API */
+struct net_device*
+mlx5e_create_netdev(struct mlx5_core_dev *mdev, const struct mlx5e_profile *profile,
+		    void *ppriv);
+int mlx5e_attach_netdev(struct mlx5e_priv *priv);
+void mlx5e_detach_netdev(struct mlx5e_priv *priv);
+void mlx5e_destroy_netdev(struct mlx5e_priv *priv);
+
 #endif /* __MLX5_EN_H__ */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 8b7b7e604ea0..cdc34ba354c8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -4121,12 +4121,57 @@ static int mlx5e_init_nic_tx(struct mlx5e_priv *priv)
 	return 0;
 }
 
+static void mlx5e_register_vport_rep(struct mlx5_core_dev *mdev)
+{
+	struct mlx5_eswitch *esw = mdev->priv.eswitch;
+	int total_vfs = MLX5_TOTAL_VPORTS(mdev);
+	int vport;
+	u8 mac[ETH_ALEN];
+
+	if (!MLX5_CAP_GEN(mdev, vport_group_manager))
+		return;
+
+	mlx5_query_nic_vport_mac_address(mdev, 0, mac);
+
+	for (vport = 1; vport < total_vfs; vport++) {
+		struct mlx5_eswitch_rep rep;
+
+		rep.load = mlx5e_vport_rep_load;
+		rep.unload = mlx5e_vport_rep_unload;
+		rep.vport = vport;
+		ether_addr_copy(rep.hw_id, mac);
+		mlx5_eswitch_register_vport_rep(esw, vport, &rep);
+	}
+}
+
+static void mlx5e_unregister_vport_rep(struct mlx5_core_dev *mdev)
+{
+	struct mlx5_eswitch *esw = mdev->priv.eswitch;
+	int total_vfs = MLX5_TOTAL_VPORTS(mdev);
+	int vport;
+
+	if (!MLX5_CAP_GEN(mdev, vport_group_manager))
+		return;
+
+	for (vport = 1; vport < total_vfs; vport++)
+		mlx5_eswitch_unregister_vport_rep(esw, vport);
+}
+
 static void mlx5e_nic_enable(struct mlx5e_priv *priv)
 {
 	struct net_device *netdev = priv->netdev;
 	struct mlx5_core_dev *mdev = priv->mdev;
 	struct mlx5_eswitch *esw = mdev->priv.eswitch;
 	struct mlx5_eswitch_rep rep;
+	u16 max_mtu;
+
+	mlx5e_init_l2_addr(priv);
+
+	/* MTU range: 68 - hw-specific max */
+	netdev->min_mtu = ETH_MIN_MTU;
+	mlx5_query_port_max_mtu(priv->mdev, &max_mtu, 1);
+	netdev->max_mtu = MLX5E_HW2SW_MTU(max_mtu);
+	mlx5e_set_dev_port_mtu(priv);
 
 	mlx5_lag_add(mdev, netdev);
 
@@ -4141,6 +4186,8 @@ static void mlx5e_nic_enable(struct mlx5e_priv *priv)
 		mlx5_eswitch_register_vport_rep(esw, 0, &rep);
 	}
 
+	mlx5e_register_vport_rep(mdev);
+
 	if (netdev->reg_state != NETREG_REGISTERED)
 		return;
 
@@ -4152,6 +4199,12 @@ static void mlx5e_nic_enable(struct mlx5e_priv *priv)
 	}
 
 	queue_work(priv->wq, &priv->set_rx_mode_work);
+
+	rtnl_lock();
+	if (netif_running(netdev))
+		mlx5e_open(netdev);
+	netif_device_attach(netdev);
+	rtnl_unlock();
 }
 
 static void mlx5e_nic_disable(struct mlx5e_priv *priv)
@@ -4159,7 +4212,14 @@ static void mlx5e_nic_disable(struct mlx5e_priv *priv)
 	struct mlx5_core_dev *mdev = priv->mdev;
 	struct mlx5_eswitch *esw = mdev->priv.eswitch;
 
+	rtnl_lock();
+	if (netif_running(priv->netdev))
+		mlx5e_close(priv->netdev);
+	netif_device_detach(priv->netdev);
+	rtnl_unlock();
+
 	queue_work(priv->wq, &priv->set_rx_mode_work);
+	mlx5e_unregister_vport_rep(mdev);
 	if (MLX5_CAP_GEN(mdev, vport_group_manager))
 		mlx5_eswitch_unregister_vport_rep(esw, 0);
 	mlx5e_disable_async_events(priv);
@@ -4180,6 +4240,8 @@ static const struct mlx5e_profile mlx5e_nic_profile = {
 	.max_tc		   = MLX5E_MAX_NUM_TC,
 };
 
+/* mlx5e generic netdev management API (move to en_common.c) */
+
 struct net_device *mlx5e_create_netdev(struct mlx5_core_dev *mdev,
 				       const struct mlx5e_profile *profile,
 				       void *ppriv)
@@ -4219,14 +4281,12 @@ struct net_device *mlx5e_create_netdev(struct mlx5_core_dev *mdev,
 	return NULL;
 }
 
-int mlx5e_attach_netdev(struct mlx5_core_dev *mdev, struct net_device *netdev)
+int mlx5e_attach_netdev(struct mlx5e_priv *priv)
 {
+	struct mlx5_core_dev *mdev = priv->mdev;
 	const struct mlx5e_profile *profile;
-	struct mlx5e_priv *priv;
-	u16 max_mtu;
 	int err;
 
-	priv = netdev_priv(netdev);
 	profile = priv->profile;
 	clear_bit(MLX5E_STATE_DESTROYING, &priv->state);
 
@@ -4246,24 +4306,9 @@ int mlx5e_attach_netdev(struct mlx5_core_dev *mdev, struct net_device *netdev)
 
 	mlx5e_create_q_counter(priv);
 
-	mlx5e_init_l2_addr(priv);
-
-	/* MTU range: 68 - hw-specific max */
-	netdev->min_mtu = ETH_MIN_MTU;
-	mlx5_query_port_max_mtu(priv->mdev, &max_mtu, 1);
-	netdev->max_mtu = MLX5E_HW2SW_MTU(max_mtu);
-
-	mlx5e_set_dev_port_mtu(priv);
-
 	if (profile->enable)
 		profile->enable(priv);
 
-	rtnl_lock();
-	if (netif_running(netdev))
-		mlx5e_open(netdev);
-	netif_device_attach(netdev);
-	rtnl_unlock();
-
 	return 0;
 
 err_close_drop_rq:
@@ -4276,55 +4321,12 @@ int mlx5e_attach_netdev(struct mlx5_core_dev *mdev, struct net_device *netdev)
 	return err;
 }
 
-static void mlx5e_register_vport_rep(struct mlx5_core_dev *mdev)
-{
-	struct mlx5_eswitch *esw = mdev->priv.eswitch;
-	int total_vfs = MLX5_TOTAL_VPORTS(mdev);
-	int vport;
-	u8 mac[ETH_ALEN];
-
-	if (!MLX5_CAP_GEN(mdev, vport_group_manager))
-		return;
-
-	mlx5_query_nic_vport_mac_address(mdev, 0, mac);
-
-	for (vport = 1; vport < total_vfs; vport++) {
-		struct mlx5_eswitch_rep rep;
-
-		rep.load = mlx5e_vport_rep_load;
-		rep.unload = mlx5e_vport_rep_unload;
-		rep.vport = vport;
-		ether_addr_copy(rep.hw_id, mac);
-		mlx5_eswitch_register_vport_rep(esw, vport, &rep);
-	}
-}
-
-static void mlx5e_unregister_vport_rep(struct mlx5_core_dev *mdev)
-{
-	struct mlx5_eswitch *esw = mdev->priv.eswitch;
-	int total_vfs = MLX5_TOTAL_VPORTS(mdev);
-	int vport;
-
-	if (!MLX5_CAP_GEN(mdev, vport_group_manager))
-		return;
-
-	for (vport = 1; vport < total_vfs; vport++)
-		mlx5_eswitch_unregister_vport_rep(esw, vport);
-}
-
-void mlx5e_detach_netdev(struct mlx5_core_dev *mdev, struct net_device *netdev)
+void mlx5e_detach_netdev(struct mlx5e_priv *priv)
 {
-	struct mlx5e_priv *priv = netdev_priv(netdev);
 	const struct mlx5e_profile *profile = priv->profile;
 
 	set_bit(MLX5E_STATE_DESTROYING, &priv->state);
 
-	rtnl_lock();
-	if (netif_running(netdev))
-		mlx5e_close(netdev);
-	netif_device_detach(netdev);
-	rtnl_unlock();
-
 	if (profile->disable)
 		profile->disable(priv);
 	flush_workqueue(priv->wq);
@@ -4336,6 +4338,17 @@ void mlx5e_detach_netdev(struct mlx5_core_dev *mdev, struct net_device *netdev)
 	cancel_delayed_work_sync(&priv->update_stats_work);
 }
 
+void mlx5e_destroy_netdev(struct mlx5e_priv *priv)
+{
+	const struct mlx5e_profile *profile = priv->profile;
+	struct net_device *netdev = priv->netdev;
+
+	destroy_workqueue(priv->wq);
+	if (profile->cleanup)
+		profile->cleanup(priv);
+	free_netdev(netdev);
+}
+
 /* mlx5e_attach and mlx5e_detach scope should be only creating/destroying
  * hardware contexts and to connect it to the current netdev.
  */
@@ -4352,13 +4365,12 @@ static int mlx5e_attach(struct mlx5_core_dev *mdev, void *vpriv)
 	if (err)
 		return err;
 
-	err = mlx5e_attach_netdev(mdev, netdev);
+	err = mlx5e_attach_netdev(priv);
 	if (err) {
 		mlx5e_destroy_mdev_resources(mdev);
 		return err;
 	}
 
-	mlx5e_register_vport_rep(mdev);
 	return 0;
 }
 
@@ -4370,8 +4382,7 @@ static void mlx5e_detach(struct mlx5_core_dev *mdev, void *vpriv)
 	if (!netif_device_present(netdev))
 		return;
 
-	mlx5e_unregister_vport_rep(mdev);
-	mlx5e_detach_netdev(mdev, netdev);
+	mlx5e_detach_netdev(priv);
 	mlx5e_destroy_mdev_resources(mdev);
 }
 
@@ -4418,7 +4429,7 @@ static void *mlx5e_add(struct mlx5_core_dev *mdev)
 	mlx5e_detach(mdev, priv);
 
 err_destroy_netdev:
-	mlx5e_destroy_netdev(mdev, priv);
+	mlx5e_destroy_netdev(priv);
 
 err_unregister_reps:
 	for (vport = 1; vport < total_vfs; vport++)
@@ -4427,24 +4438,13 @@ static void *mlx5e_add(struct mlx5_core_dev *mdev)
 	return NULL;
 }
 
-void mlx5e_destroy_netdev(struct mlx5_core_dev *mdev, struct mlx5e_priv *priv)
-{
-	const struct mlx5e_profile *profile = priv->profile;
-	struct net_device *netdev = priv->netdev;
-
-	destroy_workqueue(priv->wq);
-	if (profile->cleanup)
-		profile->cleanup(priv);
-	free_netdev(netdev);
-}
-
 static void mlx5e_remove(struct mlx5_core_dev *mdev, void *vpriv)
 {
 	struct mlx5e_priv *priv = vpriv;
 
 	unregister_netdev(priv->netdev);
 	mlx5e_detach(mdev, vpriv);
-	mlx5e_destroy_netdev(mdev, priv);
+	mlx5e_destroy_netdev(priv);
 }
 
 static void *mlx5e_get_netdev(void *vpriv)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 53db5ec2c122..d7664ff5c736 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -470,6 +470,8 @@ static int mlx5e_init_rep_rx(struct mlx5e_priv *priv)
 	int err;
 	int i;
 
+	mlx5e_init_l2_addr(priv);
+
 	err = mlx5e_create_direct_rqts(priv);
 	if (err) {
 		mlx5_core_warn(mdev, "create direct rqts failed, %d\n", err);
@@ -563,7 +565,7 @@ int mlx5e_vport_rep_load(struct mlx5_eswitch *esw,
 
 	rep->netdev = netdev;
 
-	err = mlx5e_attach_netdev(esw->dev, netdev);
+	err = mlx5e_attach_netdev(netdev_priv(netdev));
 	if (err) {
 		pr_warn("Failed to attach representor netdev for vport %d\n",
 			rep->vport);
@@ -580,10 +582,10 @@ int mlx5e_vport_rep_load(struct mlx5_eswitch *esw,
 	return 0;
 
 err_detach_netdev:
-	mlx5e_detach_netdev(esw->dev, netdev);
+	mlx5e_detach_netdev(netdev_priv(netdev));
 
 err_destroy_netdev:
-	mlx5e_destroy_netdev(esw->dev, netdev_priv(netdev));
+	mlx5e_destroy_netdev(netdev_priv(netdev));
 
 	return err;
 
@@ -595,6 +597,6 @@ void mlx5e_vport_rep_unload(struct mlx5_eswitch *esw,
 	struct net_device *netdev = rep->netdev;
 
 	unregister_netdev(netdev);
-	mlx5e_detach_netdev(esw->dev, netdev);
-	mlx5e_destroy_netdev(esw->dev, netdev_priv(netdev));
+	mlx5e_detach_netdev(netdev_priv(netdev));
+	mlx5e_destroy_netdev(netdev_priv(netdev));
 }
-- 
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
