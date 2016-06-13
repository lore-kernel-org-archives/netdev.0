From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 09/15] mlx4_en: Replace ndo_add/del_vxlan_port with
 ndo_add/del_udp_enc_port
Date: Mon, 13 Jun 2016 10:49:12 -0700
Message-ID: <20160613174912.15186.33016.stgit@localhost.localdomain>
References: <20160613173750.15186.24381.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hannes@redhat.com, jesse@kernel.org, jbenc@redhat.com,
	alexander.duyck@gmail.com, saeedm@mellanox.com,
	ariel.elior@qlogic.com, tom@herbertland.com,
	Dept-GELinuxNICDev@qlogic.com, davem@davemloft.net,
	eugenia@mellanox.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34962 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423248AbcFMRtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 13:49:14 -0400
Received: by mail-pf0-f181.google.com with SMTP id c2so48341215pfa.2
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 10:49:14 -0700 (PDT)
In-Reply-To: <20160613173750.15186.24381.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change replaces the network device operations for adding or removing a
VXLAN port with operations that are more generically defined to be used for
any UDP offload port but provide a type.  As such by just adding a line to
verify that the offload type is VXLAN we can maintain the same
functionality.

In addition I updated the socket address family check so that instead of
excluding IPv6 we instead abort of type is not IPv4.  This makes much more
sense as we should only be supporting IPv4 outer addresses on this
hardware.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   30 +++++++++++++++---------
 1 file changed, 19 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 973391bfe286..d4d5fdffbcee 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1694,7 +1694,7 @@ int mlx4_en_start_port(struct net_device *dev)
 
 #ifdef CONFIG_MLX4_EN_VXLAN
 	if (priv->mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)
-		vxlan_get_rx_port(dev);
+		udp_tunnel_get_rx_port(dev);
 #endif
 	priv->port_up = true;
 	netif_tx_start_all_queues(dev);
@@ -2392,15 +2392,19 @@ static void mlx4_en_del_vxlan_offloads(struct work_struct *work)
 }
 
 static void mlx4_en_add_vxlan_port(struct  net_device *dev,
-				   sa_family_t sa_family, __be16 port)
+				   sa_family_t sa_family, __be16 port,
+				   unsigned int type)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	__be16 current_port;
 
-	if (priv->mdev->dev->caps.tunnel_offload_mode != MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)
+	if (type != UDP_ENC_OFFLOAD_TYPE_VXLAN)
+		return;
+
+	if (sa_family != AF_INET)
 		return;
 
-	if (sa_family == AF_INET6)
+	if (priv->mdev->dev->caps.tunnel_offload_mode != MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)
 		return;
 
 	current_port = priv->vxlan_port;
@@ -2415,15 +2419,19 @@ static void mlx4_en_add_vxlan_port(struct  net_device *dev,
 }
 
 static void mlx4_en_del_vxlan_port(struct  net_device *dev,
-				   sa_family_t sa_family, __be16 port)
+				   sa_family_t sa_family, __be16 port,
+				   unsigned int type)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	__be16 current_port;
 
-	if (priv->mdev->dev->caps.tunnel_offload_mode != MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)
+	if (type != UDP_ENC_OFFLOAD_TYPE_VXLAN)
+		return;
+
+	if (sa_family != AF_INET)
 		return;
 
-	if (sa_family == AF_INET6)
+	if (priv->mdev->dev->caps.tunnel_offload_mode != MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)
 		return;
 
 	current_port = priv->vxlan_port;
@@ -2507,8 +2515,8 @@ static const struct net_device_ops mlx4_netdev_ops = {
 #endif
 	.ndo_get_phys_port_id	= mlx4_en_get_phys_port_id,
 #ifdef CONFIG_MLX4_EN_VXLAN
-	.ndo_add_vxlan_port	= mlx4_en_add_vxlan_port,
-	.ndo_del_vxlan_port	= mlx4_en_del_vxlan_port,
+	.ndo_add_udp_enc_port	= mlx4_en_add_vxlan_port,
+	.ndo_del_udp_enc_port	= mlx4_en_del_vxlan_port,
 	.ndo_features_check	= mlx4_en_features_check,
 #endif
 	.ndo_set_tx_maxrate	= mlx4_en_set_tx_maxrate,
@@ -2545,8 +2553,8 @@ static const struct net_device_ops mlx4_netdev_ops_master = {
 #endif
 	.ndo_get_phys_port_id	= mlx4_en_get_phys_port_id,
 #ifdef CONFIG_MLX4_EN_VXLAN
-	.ndo_add_vxlan_port	= mlx4_en_add_vxlan_port,
-	.ndo_del_vxlan_port	= mlx4_en_del_vxlan_port,
+	.ndo_add_udp_enc_port	= mlx4_en_add_vxlan_port,
+	.ndo_del_udp_enc_port	= mlx4_en_del_vxlan_port,
 	.ndo_features_check	= mlx4_en_features_check,
 #endif
 	.ndo_set_tx_maxrate	= mlx4_en_set_tx_maxrate,
