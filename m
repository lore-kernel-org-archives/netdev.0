From: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [RFC v1 for accelerated IPoIB 13/25] net/mlx5e: Export resource creation function to be used in IB link
Date: Mon, 13 Mar 2017 20:31:24 +0200
Message-ID: <1489429896-10781-14-git-send-email-erezsh@mellanox.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        valex-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, saedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        erezsh-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org, Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1489429896-10781-1-git-send-email-erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


mlx5i_attach that creates the resources of IB network device.
mlx5i_detach cleans resources for IB device.

Signed-off-by: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 122 +++++++++++++++-------
 1 file changed, 87 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 87881f9ddf35..5b3c2e67607f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3844,6 +3844,54 @@ static void mlx5e_nic_disable(struct mlx5e_priv *priv)
 	mlx5_lag_remove(mdev);
 }
 
+static int mlx5n_attach_netdev_common(struct mlx5_core_dev *mdev,
+				      struct mlx5e_priv *priv)
+{
+	const struct mlx5e_profile *profile;
+	struct net_device *netdev;
+	int err;
+
+	netdev = priv->netdev;
+	profile = priv->profile;
+	clear_bit(MLX5E_STATE_DESTROYING, &priv->state);
+
+	err = profile->init_tx(priv);
+	if (err)
+		goto out;
+
+	err = mlx5e_open_drop_rq(priv);
+	if (err) {
+		mlx5_core_err(mdev, "open drop rq failed, %d\n", err);
+		goto err_cleanup_tx;
+	}
+
+	err = profile->init_rx(priv);
+	if (err)
+		goto err_close_drop_rq;
+
+	mlx5e_create_q_counter(priv);
+
+	if (profile->enable)
+		profile->enable(priv);
+
+	rtnl_lock();
+	if (netif_running(netdev))
+		mlx5e_open(netdev);
+	netif_device_attach(netdev);
+	rtnl_unlock();
+
+	return 0;
+
+err_close_drop_rq:
+	mlx5e_close_drop_rq(priv);
+
+err_cleanup_tx:
+	profile->cleanup_tx(priv);
+
+out:
+	return err;
+}
+
 static void mlx5i_nic_init(struct mlx5_core_dev *mdev,
 			   struct net_device *netdev,
 			   const struct mlx5e_profile *profile,
@@ -3942,6 +3990,42 @@ struct net_device *mlx5i_create_netdev(struct mlx5_core_dev *mdev,
 }
 EXPORT_SYMBOL(mlx5i_create_netdev);
 
+int mlx5i_attach(struct mlx5_core_dev *mdev, void *vpriv)
+{
+	struct mlx5e_priv *priv = vpriv;
+	struct net_device *netdev = priv->netdev;
+	int err;
+
+	if (netif_device_present(netdev))
+		return 0;
+
+	err = mlx5e_create_mdev_resources(mdev);
+	if (err)
+		return err;
+
+	err = mlx5n_attach_netdev_common(mdev, priv);
+	if (err) {
+		mlx5e_destroy_mdev_resources(mdev);
+		return err;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(mlx5i_attach);
+
+void mlx5i_detach(struct mlx5_core_dev *mdev, void *vpriv)
+{
+	struct mlx5e_priv *priv = vpriv;
+	struct net_device *netdev = priv->netdev;
+
+	if (!netif_device_present(netdev))
+		return;
+
+	mlx5e_detach_netdev(mdev, netdev);
+	mlx5e_destroy_mdev_resources(mdev);
+}
+EXPORT_SYMBOL(mlx5i_detach);
+
 static const struct mlx5e_profile mlx5e_nic_profile = {
 	.init		   = mlx5e_nic_init,
 	.cleanup	   = mlx5e_nic_cleanup,
@@ -3996,31 +4080,17 @@ struct net_device *mlx5e_create_netdev(struct mlx5_core_dev *mdev,
 
 int mlx5e_attach_netdev(struct mlx5_core_dev *mdev, struct mlx5e_priv *priv)
 {
-	const struct mlx5e_profile *profile;
 	struct net_device *netdev;
 	u16 max_mtu;
 	int err;
 
 	netdev = priv->netdev;
-	profile = priv->profile;
-	clear_bit(MLX5E_STATE_DESTROYING, &priv->state);
-
-	err = profile->init_tx(priv);
-	if (err)
-		goto out;
 
-	err = mlx5e_open_drop_rq(priv);
+	err = mlx5n_attach_netdev_common(mdev, priv);
 	if (err) {
-		mlx5_core_err(mdev, "open drop rq failed, %d\n", err);
-		goto err_cleanup_tx;
+		mlx5_core_err(mdev, "failed attach netdev %d\n", err);
+		return err;
 	}
-
-	err = profile->init_rx(priv);
-	if (err)
-		goto err_close_drop_rq;
-
-	mlx5e_create_q_counter(priv);
-	//TBD do i need to change that?
 	mlx5e_init_l2_addr(priv);
 
 	/* MTU range: 68 - hw-specific max */
@@ -4030,25 +4100,7 @@ int mlx5e_attach_netdev(struct mlx5_core_dev *mdev, struct mlx5e_priv *priv)
 
 	mlx5e_set_dev_port_mtu(netdev);
 
-	if (profile->enable)
-		profile->enable(priv);
-
-	rtnl_lock();
-	if (netif_running(netdev))
-		mlx5e_open(netdev);
-	netif_device_attach(netdev);
-	rtnl_unlock();
-
 	return 0;
-
-err_close_drop_rq:
-	mlx5e_close_drop_rq(priv);
-
-err_cleanup_tx:
-	profile->cleanup_tx(priv);
-
-out:
-	return err;
 }
 
 static void mlx5e_register_vport_rep(struct mlx5_core_dev *mdev)
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
