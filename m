From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 2/2] net/mlx5e: Use a private copy of netdev ops
Date: Wed, 27 Jan 2016 17:02:25 +0200
Message-ID: <1453906945-25414-3-git-send-email-ogerlitz@mellanox.com>
References: <1453906945-25414-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:49146 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933054AbcA0PC6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jan 2016 10:02:58 -0500
In-Reply-To: <1453906945-25414-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Currently our netdevice ops is a static global variable which
is referenced by all mlx5e netdevice instances. This can be
problematic when different driver instances do not share same
HW capabilities (e.g SRIOV PF and VFs probed to the host).

Remove the global variable and add a private net_device_ops
field in netdevice private data, which is initialized at
netdev construction.

Fixes: 66e49dedada6 ("net/mlx5e: Add support for SR-IOV ndos")
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  2 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 52 ++++++++++++-----------
 2 files changed, 30 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 9ea49a8..4e7d339 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -510,6 +510,8 @@ struct mlx5e_priv {
 	int channeltc_to_txq_map[MLX5E_MAX_NUM_CHANNELS][MLX5E_MAX_NUM_TC];
 	/* priv data path fields - end */
 
+	struct net_device_ops      netdev_ops;
+
 	unsigned long              state;
 	struct mutex               state_lock; /* Protects Interface state */
 	struct mlx5_uar            cq_uar;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index c56d91a..49fe2e6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2024,20 +2024,6 @@ static int mlx5e_get_vf_stats(struct net_device *dev,
 					    vf_stats);
 }
 
-static struct net_device_ops mlx5e_netdev_ops = {
-	.ndo_open                = mlx5e_open,
-	.ndo_stop                = mlx5e_close,
-	.ndo_start_xmit          = mlx5e_xmit,
-	.ndo_get_stats64         = mlx5e_get_stats,
-	.ndo_set_rx_mode         = mlx5e_set_rx_mode,
-	.ndo_set_mac_address     = mlx5e_set_mac,
-	.ndo_vlan_rx_add_vid	 = mlx5e_vlan_rx_add_vid,
-	.ndo_vlan_rx_kill_vid	 = mlx5e_vlan_rx_kill_vid,
-	.ndo_set_features        = mlx5e_set_features,
-	.ndo_change_mtu		 = mlx5e_change_mtu,
-	.ndo_do_ioctl		 = mlx5e_ioctl,
-};
-
 static int mlx5e_check_required_hca_cap(struct mlx5_core_dev *mdev)
 {
 	if (MLX5_CAP_GEN(mdev, port_type) != MLX5_CAP_PORT_TYPE_ETH)
@@ -2130,25 +2116,43 @@ static void mlx5e_set_netdev_dev_addr(struct net_device *netdev)
 	}
 }
 
-static void mlx5e_build_netdev(struct net_device *netdev)
+static void mlx5e_build_priv_netdev_ops(struct mlx5e_priv *priv)
 {
-	struct mlx5e_priv *priv = netdev_priv(netdev);
 	struct mlx5_core_dev *mdev = priv->mdev;
 
-	SET_NETDEV_DEV(netdev, &mdev->pdev->dev);
+	priv->netdev_ops.ndo_open                = mlx5e_open;
+	priv->netdev_ops.ndo_stop                = mlx5e_close;
+	priv->netdev_ops.ndo_start_xmit          = mlx5e_xmit;
+	priv->netdev_ops.ndo_get_stats64         = mlx5e_get_stats;
+	priv->netdev_ops.ndo_set_rx_mode         = mlx5e_set_rx_mode;
+	priv->netdev_ops.ndo_set_mac_address     = mlx5e_set_mac;
+	priv->netdev_ops.ndo_vlan_rx_add_vid     = mlx5e_vlan_rx_add_vid;
+	priv->netdev_ops.ndo_vlan_rx_kill_vid    = mlx5e_vlan_rx_kill_vid;
+	priv->netdev_ops.ndo_set_features        = mlx5e_set_features;
+	priv->netdev_ops.ndo_change_mtu          = mlx5e_change_mtu;
+	priv->netdev_ops.ndo_do_ioctl            = mlx5e_ioctl;
 
 	if (priv->params.num_tc > 1)
-		mlx5e_netdev_ops.ndo_select_queue = mlx5e_select_queue;
+		priv->netdev_ops.ndo_select_queue = mlx5e_select_queue;
 
 	if (MLX5_CAP_GEN(mdev, vport_group_manager)) {
-		mlx5e_netdev_ops.ndo_set_vf_mac = mlx5e_set_vf_mac;
-		mlx5e_netdev_ops.ndo_set_vf_vlan = mlx5e_set_vf_vlan;
-		mlx5e_netdev_ops.ndo_get_vf_config = mlx5e_get_vf_config;
-		mlx5e_netdev_ops.ndo_set_vf_link_state = mlx5e_set_vf_link_state;
-		mlx5e_netdev_ops.ndo_get_vf_stats = mlx5e_get_vf_stats;
+		priv->netdev_ops.ndo_set_vf_mac = mlx5e_set_vf_mac;
+		priv->netdev_ops.ndo_set_vf_vlan = mlx5e_set_vf_vlan;
+		priv->netdev_ops.ndo_get_vf_config = mlx5e_get_vf_config;
+		priv->netdev_ops.ndo_set_vf_link_state = mlx5e_set_vf_link_state;
+		priv->netdev_ops.ndo_get_vf_stats = mlx5e_get_vf_stats;
 	}
+}
+
+static void mlx5e_build_netdev(struct net_device *netdev)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+	struct mlx5_core_dev *mdev = priv->mdev;
+
+	SET_NETDEV_DEV(netdev, &mdev->pdev->dev);
 
-	netdev->netdev_ops        = &mlx5e_netdev_ops;
+	mlx5e_build_priv_netdev_ops(priv);
+	netdev->netdev_ops        = &priv->netdev_ops;
 	netdev->watchdog_timeo    = 15 * HZ;
 
 	netdev->ethtool_ops	  = &mlx5e_ethtool_ops;
-- 
2.3.7
