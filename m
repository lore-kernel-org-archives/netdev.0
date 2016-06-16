From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v3 11/17] mlx4_en: Replace ndo_add/del_vxlan_port
 with ndo_add/del_udp_enc_port
Date: Thu, 16 Jun 2016 12:22:30 -0700
Message-ID: <20160616192230.20872.32549.stgit@localhost.localdomain>
References: <20160616191851.20872.67154.stgit@localhost.localdomain>
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
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33001 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754089AbcFPTWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 15:22:34 -0400
Received: by mail-pf0-f169.google.com with SMTP id i123so18933530pfg.0
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 12:22:34 -0700 (PDT)
In-Reply-To: <20160616191851.20872.67154.stgit@localhost.localdomain>
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
 drivers/net/ethernet/mellanox/mlx4/Kconfig     |    7 ----
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   41 ++++++++++++------------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    2 -
 3 files changed, 20 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/Kconfig b/drivers/net/ethernet/mellanox/mlx4/Kconfig
index 9ca3734ebb6b..5098e7f21987 100644
--- a/drivers/net/ethernet/mellanox/mlx4/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx4/Kconfig
@@ -24,13 +24,6 @@ config MLX4_EN_DCB
 
 	  If unsure, set to Y
 
-config MLX4_EN_VXLAN
-	bool "VXLAN offloads Support"
-	default y
-	depends on MLX4_EN && VXLAN && !(MLX4_EN=y && VXLAN=m)
-	---help---
-	  Say Y here if you want to use VXLAN offloads in the driver.
-
 config MLX4_CORE
 	tristate
 	depends on PCI
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 2221403b65e4..17e3349b99f2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1692,10 +1692,9 @@ int mlx4_en_start_port(struct net_device *dev)
 	/* Schedule multicast task to populate multicast list */
 	queue_work(mdev->workqueue, &priv->rx_mode_task);
 
-#ifdef CONFIG_MLX4_EN_VXLAN
 	if (priv->mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)
-		vxlan_get_rx_port(dev);
-#endif
+		udp_tunnel_get_rx_info(dev);
+
 	priv->port_up = true;
 	netif_tx_start_all_queues(dev);
 	netif_device_attach(dev);
@@ -2342,7 +2341,6 @@ static int mlx4_en_get_phys_port_id(struct net_device *dev,
 	return 0;
 }
 
-#ifdef CONFIG_MLX4_EN_VXLAN
 static void mlx4_en_add_vxlan_offloads(struct work_struct *work)
 {
 	int ret;
@@ -2392,15 +2390,19 @@ static void mlx4_en_del_vxlan_offloads(struct work_struct *work)
 }
 
 static void mlx4_en_add_vxlan_port(struct  net_device *dev,
-				   sa_family_t sa_family, __be16 port)
+				   struct udp_tunnel_info *ti)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
+	__be16 port = ti->port;
 	__be16 current_port;
 
-	if (priv->mdev->dev->caps.tunnel_offload_mode != MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)
+	if (ti->type != UDP_TUNNEL_TYPE_VXLAN)
 		return;
 
-	if (sa_family == AF_INET6)
+	if (ti->sa_family != AF_INET)
+		return;
+
+	if (priv->mdev->dev->caps.tunnel_offload_mode != MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)
 		return;
 
 	current_port = priv->vxlan_port;
@@ -2415,15 +2417,19 @@ static void mlx4_en_add_vxlan_port(struct  net_device *dev,
 }
 
 static void mlx4_en_del_vxlan_port(struct  net_device *dev,
-				   sa_family_t sa_family, __be16 port)
+				   struct udp_tunnel_info *ti)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
+	__be16 port = ti->port;
 	__be16 current_port;
 
-	if (priv->mdev->dev->caps.tunnel_offload_mode != MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)
+	if (ti->type != UDP_TUNNEL_TYPE_VXLAN)
 		return;
 
-	if (sa_family == AF_INET6)
+	if (ti->sa_family != AF_INET)
+		return;
+
+	if (priv->mdev->dev->caps.tunnel_offload_mode != MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)
 		return;
 
 	current_port = priv->vxlan_port;
@@ -2458,7 +2464,6 @@ static netdev_features_t mlx4_en_features_check(struct sk_buff *skb,
 
 	return features;
 }
-#endif
 
 static int mlx4_en_set_tx_maxrate(struct net_device *dev, int queue_index, u32 maxrate)
 {
@@ -2511,11 +2516,9 @@ static const struct net_device_ops mlx4_netdev_ops = {
 	.ndo_rx_flow_steer	= mlx4_en_filter_rfs,
 #endif
 	.ndo_get_phys_port_id	= mlx4_en_get_phys_port_id,
-#ifdef CONFIG_MLX4_EN_VXLAN
-	.ndo_add_vxlan_port	= mlx4_en_add_vxlan_port,
-	.ndo_del_vxlan_port	= mlx4_en_del_vxlan_port,
+	.ndo_udp_tunnel_add	= mlx4_en_add_vxlan_port,
+	.ndo_udp_tunnel_del	= mlx4_en_del_vxlan_port,
 	.ndo_features_check	= mlx4_en_features_check,
-#endif
 	.ndo_set_tx_maxrate	= mlx4_en_set_tx_maxrate,
 };
 
@@ -2549,11 +2552,9 @@ static const struct net_device_ops mlx4_netdev_ops_master = {
 	.ndo_rx_flow_steer	= mlx4_en_filter_rfs,
 #endif
 	.ndo_get_phys_port_id	= mlx4_en_get_phys_port_id,
-#ifdef CONFIG_MLX4_EN_VXLAN
-	.ndo_add_vxlan_port	= mlx4_en_add_vxlan_port,
-	.ndo_del_vxlan_port	= mlx4_en_del_vxlan_port,
+	.ndo_udp_tunnel_add	= mlx4_en_add_vxlan_port,
+	.ndo_udp_tunnel_del	= mlx4_en_del_vxlan_port,
 	.ndo_features_check	= mlx4_en_features_check,
-#endif
 	.ndo_set_tx_maxrate	= mlx4_en_set_tx_maxrate,
 };
 
@@ -2844,10 +2845,8 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	INIT_WORK(&priv->linkstate_task, mlx4_en_linkstate);
 	INIT_DELAYED_WORK(&priv->stats_task, mlx4_en_do_get_stats);
 	INIT_DELAYED_WORK(&priv->service_task, mlx4_en_service_task);
-#ifdef CONFIG_MLX4_EN_VXLAN
 	INIT_WORK(&priv->vxlan_add_task, mlx4_en_add_vxlan_offloads);
 	INIT_WORK(&priv->vxlan_del_task, mlx4_en_del_vxlan_offloads);
-#endif
 #ifdef CONFIG_RFS_ACCEL
 	INIT_LIST_HEAD(&priv->filters);
 	spin_lock_init(&priv->filters_lock);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 467d47ed2c39..6b3b0fefabad 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -545,10 +545,8 @@ struct mlx4_en_priv {
 	struct work_struct linkstate_task;
 	struct delayed_work stats_task;
 	struct delayed_work service_task;
-#ifdef CONFIG_MLX4_EN_VXLAN
 	struct work_struct vxlan_add_task;
 	struct work_struct vxlan_del_task;
-#endif
 	struct mlx4_en_perf_stats pstats;
 	struct mlx4_en_pkt_stats pkstats;
 	struct mlx4_en_counter_stats pf_stats;
