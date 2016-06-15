From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v2 12/17] mlx5_en: Replace ndo_add/del_vxlan_port
 with ndo_add/del_udp_enc_port
Date: Wed, 15 Jun 2016 15:08:33 -0700
Message-ID: <20160615220833.15575.23529.stgit@localhost.localdomain>
References: <20160615220449.15575.17031.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hannes@redhat.com, jesse@kernel.org, eugenia@mellanox.com,
	jbenc@redhat.com, alexander.duyck@gmail.com, saeedm@mellanox.com,
	ariel.elior@qlogic.com, tom@herbertland.com,
	michael.chan@broadcom.com, Dept-GELinuxNICDev@qlogic.com,
	davem@davemloft.net
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34226 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933061AbcFOWIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 18:08:35 -0400
Received: by mail-pa0-f44.google.com with SMTP id bz2so11245411pad.1
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 15:08:35 -0700 (PDT)
In-Reply-To: <20160615220449.15575.17031.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change replaces the network device operations for adding or removing a
VXLAN port with operations that are more generically defined to be used for
any UDP offload port but provide a type.  As such by just adding a line to
verify that the offload type is VXLAN we can maintain the same
functionality.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index f5c8d5db25a8..8b7c6f381706 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2520,25 +2520,31 @@ static int mlx5e_get_vf_stats(struct net_device *dev,
 }
 
 static void mlx5e_add_vxlan_port(struct net_device *netdev,
-				 sa_family_t sa_family, __be16 port)
+				 struct udp_tunnel_info *ti)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 
+	if (ti->type != UDP_TUNNEL_TYPE_VXLAN)
+		return;
+
 	if (!mlx5e_vxlan_allowed(priv->mdev))
 		return;
 
-	mlx5e_vxlan_queue_work(priv, sa_family, be16_to_cpu(port), 1);
+	mlx5e_vxlan_queue_work(priv, ti->sa_family, be16_to_cpu(ti->port), 1);
 }
 
 static void mlx5e_del_vxlan_port(struct net_device *netdev,
-				 sa_family_t sa_family, __be16 port)
+				 struct udp_tunnel_info *ti)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 
+	if (ti->type != UDP_TUNNEL_TYPE_VXLAN)
+		return;
+
 	if (!mlx5e_vxlan_allowed(priv->mdev))
 		return;
 
-	mlx5e_vxlan_queue_work(priv, sa_family, be16_to_cpu(port), 0);
+	mlx5e_vxlan_queue_work(priv, ti->sa_family, be16_to_cpu(ti->port), 0);
 }
 
 static netdev_features_t mlx5e_vxlan_features_check(struct mlx5e_priv *priv,
@@ -2624,8 +2630,8 @@ static const struct net_device_ops mlx5e_netdev_ops_sriov = {
 	.ndo_set_features        = mlx5e_set_features,
 	.ndo_change_mtu          = mlx5e_change_mtu,
 	.ndo_do_ioctl            = mlx5e_ioctl,
-	.ndo_add_vxlan_port      = mlx5e_add_vxlan_port,
-	.ndo_del_vxlan_port      = mlx5e_del_vxlan_port,
+	.ndo_udp_tunnel_add	 = mlx5e_add_vxlan_port,
+	.ndo_udp_tunnel_del	 = mlx5e_del_vxlan_port,
 	.ndo_features_check      = mlx5e_features_check,
 #ifdef CONFIG_RFS_ACCEL
 	.ndo_rx_flow_steer	 = mlx5e_rx_flow_steer,
@@ -3128,7 +3134,7 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 
 	if (mlx5e_vxlan_allowed(mdev)) {
 		rtnl_lock();
-		vxlan_get_rx_port(netdev);
+		udp_tunnel_get_rx_info(netdev);
 		rtnl_unlock();
 	}
 
