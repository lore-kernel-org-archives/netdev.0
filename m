From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 12/13] net/mlx5e: Add ndo_udp_tunnel_add to VF representors
Date: Mon,  7 Nov 2016 15:14:47 +0200
Message-ID: <1478524488-1377-13-git-send-email-saeedm@mellanox.com>
References: <1478524488-1377-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:39589 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753425AbcKGNPH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 08:15:07 -0500
In-Reply-To: <1478524488-1377-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

By implementing this ndo, the host stack will set the vxlan udp port
also to VF representor netdevices. This will allow the TC offload code
in the driver when it gets a tunnel key set action to identify the UDP
port as vxlan, and hence the rule will be a candidate for offloading.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      | 4 ++++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 8 ++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c  | 2 ++
 3 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index ea8af47..ac09767 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -893,5 +893,9 @@ void mlx5e_detach_netdev(struct mlx5_core_dev *mdev, struct net_device *netdev);
 struct rtnl_link_stats64 *
 mlx5e_get_stats(struct net_device *dev, struct rtnl_link_stats64 *stats);
 u32 mlx5e_choose_lro_timeout(struct mlx5_core_dev *mdev, u32 wanted_timeout);
+void mlx5e_add_vxlan_port(struct net_device *netdev,
+			  struct udp_tunnel_info *ti);
+void mlx5e_del_vxlan_port(struct net_device *netdev,
+			  struct udp_tunnel_info *ti);
 
 #endif /* __MLX5_EN_H__ */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index ba0c774..313b765 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2995,8 +2995,8 @@ static int mlx5e_get_vf_stats(struct net_device *dev,
 					    vf_stats);
 }
 
-static void mlx5e_add_vxlan_port(struct net_device *netdev,
-				 struct udp_tunnel_info *ti)
+void mlx5e_add_vxlan_port(struct net_device *netdev,
+			  struct udp_tunnel_info *ti)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 
@@ -3009,8 +3009,8 @@ static void mlx5e_add_vxlan_port(struct net_device *netdev,
 	mlx5e_vxlan_queue_work(priv, ti->sa_family, be16_to_cpu(ti->port), 1);
 }
 
-static void mlx5e_del_vxlan_port(struct net_device *netdev,
-				 struct udp_tunnel_info *ti)
+void mlx5e_del_vxlan_port(struct net_device *netdev,
+			  struct udp_tunnel_info *ti)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index c1a7b05..47dfd5b1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -256,6 +256,8 @@ static const struct net_device_ops mlx5e_netdev_ops_rep = {
 	.ndo_get_phys_port_name  = mlx5e_rep_get_phys_port_name,
 	.ndo_setup_tc            = mlx5e_rep_ndo_setup_tc,
 	.ndo_get_stats64         = mlx5e_get_stats,
+	.ndo_udp_tunnel_add	 = mlx5e_add_vxlan_port,
+	.ndo_udp_tunnel_del	 = mlx5e_del_vxlan_port,
 };
 
 static void mlx5e_build_rep_netdev_priv(struct mlx5_core_dev *mdev,
-- 
2.7.4
