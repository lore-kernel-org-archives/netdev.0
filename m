From: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [RFC v1 for accelerated IPoIB 18/25] net/mlx5e: Export open/close api for IB link
Date: Mon, 13 Mar 2017 20:31:29 +0200
Message-ID: <1489429896-10781-19-git-send-email-erezsh@mellanox.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        valex-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, saedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        erezsh-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org, Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1489429896-10781-1-git-send-email-erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Now IB device is able to call open or close for its net device.

TBD:
There is one change that is waiting for the new channels api, till then
used an "if" in the code.

Signed-off-by: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 23 +++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c  | 13 ++++++++++++-
 include/linux/mlx5/driver.h                       |  3 +++
 4 files changed, 37 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 2f9242ae06f3..154cab2a301b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -934,4 +934,5 @@ int mlx5e_get_offload_stats(int attr_id, const struct net_device *dev,
 
 bool mlx5e_is_uplink_rep(struct mlx5e_priv *priv);
 bool mlx5e_is_vf_vport_rep(struct mlx5e_priv *priv);
+bool mlx5e_is_eswitch_vport_mngr(struct mlx5_core_dev *mdev);
 #endif /* __MLX5_EN_H__ */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index ca1867cdce48..24efc8ccc075 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2269,7 +2269,9 @@ int mlx5e_open_locked(struct mlx5e_priv *priv)
 	}
 
 	mlx5e_redirect_rqts(priv);
-	mlx5e_update_carrier(priv);
+	/* only for the RFC, will use channels api when available */
+	if (MLX5_CAP_GEN(mdev, port_type) == MLX5_CAP_PORT_TYPE_ETH)
+		mlx5e_update_carrier(priv);
 	mlx5e_timestamp_init(priv);
 #ifdef CONFIG_RFS_ACCEL
 	priv->netdev->rx_cpu_rmap = priv->mdev->rmap;
@@ -2277,7 +2279,7 @@ int mlx5e_open_locked(struct mlx5e_priv *priv)
 	if (priv->profile->update_stats)
 		queue_delayed_work(priv->wq, &priv->update_stats_work, 0);
 
-	if (MLX5_CAP_GEN(mdev, vport_group_manager)) {
+	if (mlx5e_is_eswitch_vport_mngr(mdev)) {
 		err = mlx5e_add_sqs_fwd_rules(priv);
 		if (err)
 			goto err_close_channels;
@@ -3899,6 +3901,7 @@ static void mlx5i_nic_init(struct mlx5_core_dev *mdev,
 	struct mlx5e_priv *priv = ipoib_dev_priv(netdev);
 
 	mlx5n_build_nic_netdev_priv_common(mdev, netdev, priv, profile, ppriv);
+	priv->ppriv = NULL;
 }
 
 static int mlx5i_init_nic_rx(struct mlx5e_priv *priv)
@@ -4025,6 +4028,22 @@ void mlx5i_detach(struct mlx5_core_dev *mdev, void *vpriv)
 }
 EXPORT_SYMBOL(mlx5i_detach);
 
+int mlx5i_open(void *vpriv)
+{
+	struct mlx5e_priv *priv = vpriv;
+
+	return mlx5e_open_locked(priv);
+}
+EXPORT_SYMBOL(mlx5i_open);
+
+int mlx5i_close(void *vpriv)
+{
+	struct mlx5e_priv *priv = vpriv;
+
+	return mlx5e_close_locked(priv);
+}
+EXPORT_SYMBOL(mlx5i_close);
+
 static const struct mlx5e_profile mlx5e_nic_profile = {
 	.init		   = mlx5e_nic_init,
 	.cleanup	   = mlx5e_nic_cleanup,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 21d3d8e0bab7..cbb1092dddd4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -219,7 +219,12 @@ int mlx5e_nic_rep_load(struct mlx5_eswitch *esw, struct mlx5_eswitch_rep *rep)
 void mlx5e_remove_sqs_fwd_rules(struct mlx5e_priv *priv)
 {
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
-	struct mlx5_eswitch_rep *rep = priv->ppriv;
+	struct mlx5_eswitch_rep *rep;
+
+	if (!priv->ppriv)
+		return;
+
+	rep = priv->ppriv;
 
 	mlx5_eswitch_sqs2vport_stop(esw, rep);
 }
@@ -323,6 +328,12 @@ bool mlx5e_is_uplink_rep(struct mlx5e_priv *priv)
 	return false;
 }
 
+bool mlx5e_is_eswitch_vport_mngr(struct mlx5_core_dev *mdev)
+{
+	return (MLX5_CAP_GEN(mdev, vport_group_manager) &&
+		MLX5_CAP_GEN(mdev, port_type) == MLX5_CAP_PORT_TYPE_ETH);
+}
+
 bool mlx5e_is_vf_vport_rep(struct mlx5e_priv *priv)
 {
 	struct mlx5_eswitch_rep *rep = (struct mlx5_eswitch_rep *)priv->ppriv;
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index d0060cfb2a4f..c18be51287e7 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -1139,4 +1139,7 @@ struct net_device *mlx5i_create_netdev(struct mlx5_core_dev *mdev,
 				       struct mlx5i_create_ext_param *param);
 int mlx5i_attach(struct mlx5_core_dev *mdev, void *vpriv);
 void mlx5i_detach(struct mlx5_core_dev *mdev, void *vpriv);
+int mlx5i_close(void *vpriv);
+int mlx5i_open(void *vpriv);
+
 #endif /* MLX5_DRIVER_H */
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
