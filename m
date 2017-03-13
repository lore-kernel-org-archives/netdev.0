From: Erez Shitrit <erezsh@mellanox.com>
Subject: [RFC v1 for accelerated IPoIB 16/25] net/mlx5e: Change cleanup API in order to enable IB link
Date: Mon, 13 Mar 2017 20:31:27 +0200
Message-ID: <1489429896-10781-17-git-send-email-erezsh@mellanox.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        valex@mellanox.com, leonro@mellanox.com, saedm@mellanox.com,
        erezsh@dev.mellanox.co.il, Erez Shitrit <erezsh@mellanox.com>
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49781 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753182AbdCMScC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 14:32:02 -0400
In-Reply-To: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1. Change the mlx5e_detach_netdev api.
2. Let that function to be called after the rtnl_lock is already held,
like done in IB link.

Signed-off-by: Erez Shitrit <erezsh@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 18 +++++++++++-------
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c  |  4 ++--
 3 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 84db4761f09c..a10966df24f6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -921,7 +921,7 @@ struct net_device *mlx5e_create_netdev(struct mlx5_core_dev *mdev,
 				       void *ppriv);
 void mlx5e_destroy_netdev(struct mlx5_core_dev *mdev, struct mlx5e_priv *priv);
 int mlx5e_attach_netdev(struct mlx5_core_dev *mdev, struct mlx5e_priv *priv);
-void mlx5e_detach_netdev(struct mlx5_core_dev *mdev, struct net_device *netdev);
+void mlx5e_detach_netdev(struct mlx5_core_dev *mdev, struct mlx5e_priv *priv);
 u32 mlx5e_choose_lro_timeout(struct mlx5_core_dev *mdev, u32 wanted_timeout);
 void mlx5e_add_vxlan_port(struct net_device *netdev,
 			  struct udp_tunnel_info *ti);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 5b3c2e67607f..b91bd7a179fc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -4021,7 +4021,7 @@ void mlx5i_detach(struct mlx5_core_dev *mdev, void *vpriv)
 	if (!netif_device_present(netdev))
 		return;
 
-	mlx5e_detach_netdev(mdev, netdev);
+	mlx5e_detach_netdev(mdev, priv);
 	mlx5e_destroy_mdev_resources(mdev);
 }
 EXPORT_SYMBOL(mlx5i_detach);
@@ -4126,18 +4126,22 @@ static void mlx5e_register_vport_rep(struct mlx5_core_dev *mdev)
 	}
 }
 
-void mlx5e_detach_netdev(struct mlx5_core_dev *mdev, struct net_device *netdev)
+void mlx5e_detach_netdev(struct mlx5_core_dev *mdev, struct mlx5e_priv *priv)
 {
-	struct mlx5e_priv *priv = netdev_priv(netdev);
+	struct net_device *netdev = priv->netdev;
 	const struct mlx5e_profile *profile = priv->profile;
-
+	bool locked = false;
 	set_bit(MLX5E_STATE_DESTROYING, &priv->state);
 
-	rtnl_lock();
+	if (!rtnl_is_locked()) {
+		rtnl_lock();
+		locked = true;
+	}
 	if (netif_running(netdev))
 		mlx5e_close(netdev);
 	netif_device_detach(netdev);
-	rtnl_unlock();
+	if (locked)
+		rtnl_unlock();
 
 	if (profile->disable)
 		profile->disable(priv);
@@ -4183,7 +4187,7 @@ static void mlx5e_detach(struct mlx5_core_dev *mdev, void *vpriv)
 	if (!netif_device_present(netdev))
 		return;
 
-	mlx5e_detach_netdev(mdev, netdev);
+	mlx5e_detach_netdev(mdev, priv);
 	mlx5e_destroy_mdev_resources(mdev);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 0aad28da1638..21d3d8e0bab7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -586,7 +586,7 @@ int mlx5e_vport_rep_load(struct mlx5_eswitch *esw,
 	return 0;
 
 err_detach_netdev:
-	mlx5e_detach_netdev(esw->dev, netdev);
+	mlx5e_detach_netdev(esw->dev, priv);
 
 err_destroy_netdev:
 	mlx5e_destroy_netdev(esw->dev, netdev_priv(netdev));
@@ -601,6 +601,6 @@ void mlx5e_vport_rep_unload(struct mlx5_eswitch *esw,
 	struct net_device *netdev = rep->netdev;
 
 	unregister_netdev(netdev);
-	mlx5e_detach_netdev(esw->dev, netdev);
+	mlx5e_detach_netdev(esw->dev, netdev_priv(netdev));
 	mlx5e_destroy_netdev(esw->dev, netdev_priv(netdev));
 }
-- 
1.8.3.1
