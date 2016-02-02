From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net V1 2/3] net/mlx5e: Use static constant netdevice ndos
Date: Tue,  2 Feb 2016 17:26:20 +0200
Message-ID: <1454426781-7128-3-git-send-email-ogerlitz@mellanox.com>
References: <1454426781-7128-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:58059 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933177AbcBBP1F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 10:27:05 -0500
In-Reply-To: <1454426781-7128-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Currently our netdevice ops is a one static global variable which
is referenced by all mlx5e netdevice instances. This can be
problematic when different driver instances do not share same
HW capabilities (e.g SRIOV PF and VFs probed to the host).

Now we have two constant global netdevice ops variables, one
for basic netdevice ops and the other with extended SRIOV ops,
on netdevice construction we choose the one suitable for
current device capabilities.

Fixes: 66e49dedada6 ("net/mlx5e: Add support for SR-IOV ndos")
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 41 ++++++++++++++++-------
 1 file changed, 28 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index bca6e85..d4e1c30 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2024,18 +2024,37 @@ static int mlx5e_get_vf_stats(struct net_device *dev,
 					    vf_stats);
 }
 
-static struct net_device_ops mlx5e_netdev_ops = {
+static const struct net_device_ops mlx5e_netdev_ops_basic = {
 	.ndo_open                = mlx5e_open,
 	.ndo_stop                = mlx5e_close,
 	.ndo_start_xmit          = mlx5e_xmit,
 	.ndo_get_stats64         = mlx5e_get_stats,
 	.ndo_set_rx_mode         = mlx5e_set_rx_mode,
 	.ndo_set_mac_address     = mlx5e_set_mac,
-	.ndo_vlan_rx_add_vid	 = mlx5e_vlan_rx_add_vid,
-	.ndo_vlan_rx_kill_vid	 = mlx5e_vlan_rx_kill_vid,
+	.ndo_vlan_rx_add_vid     = mlx5e_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid    = mlx5e_vlan_rx_kill_vid,
 	.ndo_set_features        = mlx5e_set_features,
-	.ndo_change_mtu		 = mlx5e_change_mtu,
-	.ndo_do_ioctl		 = mlx5e_ioctl,
+	.ndo_change_mtu          = mlx5e_change_mtu,
+	.ndo_do_ioctl            = mlx5e_ioctl,
+};
+
+static const struct net_device_ops mlx5e_netdev_ops_sriov = {
+	.ndo_open                = mlx5e_open,
+	.ndo_stop                = mlx5e_close,
+	.ndo_start_xmit          = mlx5e_xmit,
+	.ndo_get_stats64         = mlx5e_get_stats,
+	.ndo_set_rx_mode         = mlx5e_set_rx_mode,
+	.ndo_set_mac_address     = mlx5e_set_mac,
+	.ndo_vlan_rx_add_vid     = mlx5e_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid    = mlx5e_vlan_rx_kill_vid,
+	.ndo_set_features        = mlx5e_set_features,
+	.ndo_change_mtu          = mlx5e_change_mtu,
+	.ndo_do_ioctl            = mlx5e_ioctl,
+	.ndo_set_vf_mac          = mlx5e_set_vf_mac,
+	.ndo_set_vf_vlan         = mlx5e_set_vf_vlan,
+	.ndo_get_vf_config       = mlx5e_get_vf_config,
+	.ndo_set_vf_link_state   = mlx5e_set_vf_link_state,
+	.ndo_get_vf_stats        = mlx5e_get_vf_stats,
 };
 
 static int mlx5e_check_required_hca_cap(struct mlx5_core_dev *mdev)
@@ -2137,15 +2156,11 @@ static void mlx5e_build_netdev(struct net_device *netdev)
 
 	SET_NETDEV_DEV(netdev, &mdev->pdev->dev);
 
-	if (MLX5_CAP_GEN(mdev, vport_group_manager)) {
-		mlx5e_netdev_ops.ndo_set_vf_mac = mlx5e_set_vf_mac;
-		mlx5e_netdev_ops.ndo_set_vf_vlan = mlx5e_set_vf_vlan;
-		mlx5e_netdev_ops.ndo_get_vf_config = mlx5e_get_vf_config;
-		mlx5e_netdev_ops.ndo_set_vf_link_state = mlx5e_set_vf_link_state;
-		mlx5e_netdev_ops.ndo_get_vf_stats = mlx5e_get_vf_stats;
-	}
+	if (MLX5_CAP_GEN(mdev, vport_group_manager))
+		netdev->netdev_ops = &mlx5e_netdev_ops_sriov;
+	else
+		netdev->netdev_ops = &mlx5e_netdev_ops_basic;
 
-	netdev->netdev_ops        = &mlx5e_netdev_ops;
 	netdev->watchdog_timeo    = 15 * HZ;
 
 	netdev->ethtool_ops	  = &mlx5e_ethtool_ops;
-- 
2.3.7
