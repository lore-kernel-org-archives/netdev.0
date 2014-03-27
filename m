From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 3/3] net/mlx4: Implement vxlan ndo calls
Date: Thu, 27 Mar 2014 14:02:04 +0200
Message-ID: <1395921724-2244-4-git-send-email-ogerlitz@mellanox.com>
References: <1395921724-2244-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:49798 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756498AbaC0MDE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2014 08:03:04 -0400
In-Reply-To: <1395921724-2244-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add implementation for the add/del vxlan port ndo calls, using the
CONFIG_DEV firmware command.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   86 +++++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    3 +
 drivers/net/ethernet/mellanox/mlx4/port.c      |    5 +-
 include/linux/mlx4/device.h                    |    2 +-
 4 files changed, 91 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index fa5ee71..82d7eb5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -39,6 +39,7 @@
 #include <linux/hash.h>
 #include <net/ip.h>
 #include <net/busy_poll.h>
+#include <net/vxlan.h>
 
 #include <linux/mlx4/driver.h>
 #include <linux/mlx4/device.h>
@@ -1665,7 +1666,7 @@ int mlx4_en_start_port(struct net_device *dev)
 	}
 
 	if (mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN) {
-		err = mlx4_SET_PORT_VXLAN(mdev->dev, priv->port, VXLAN_STEER_BY_OUTER_MAC);
+		err = mlx4_SET_PORT_VXLAN(mdev->dev, priv->port, VXLAN_STEER_BY_OUTER_MAC, 1);
 		if (err) {
 			en_err(priv, "Failed setting port L2 tunnel configuration, err %d\n",
 			       err);
@@ -1697,6 +1698,8 @@ int mlx4_en_start_port(struct net_device *dev)
 
 	mlx4_set_stats_bitmap(mdev->dev, &priv->stats_bitmap);
 
+	if (priv->mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_VXLAN_OFFLOADS)
+		vxlan_get_rx_port(dev);
 	priv->port_up = true;
 	netif_tx_start_all_queues(dev);
 	netif_device_attach(dev);
@@ -2264,6 +2267,81 @@ static int mlx4_en_get_phys_port_id(struct net_device *dev,
 	return 0;
 }
 
+static void mlx4_en_add_vxlan_offloads(struct work_struct *work)
+{
+	int ret;
+	struct mlx4_en_priv *priv = container_of(work, struct mlx4_en_priv,
+						 vxlan_add_task);
+
+	ret = mlx4_config_vxlan_port(priv->mdev->dev, priv->vxlan_port);
+	if (ret)
+		goto out;
+
+	ret = mlx4_SET_PORT_VXLAN(priv->mdev->dev, priv->port,
+				  VXLAN_STEER_BY_OUTER_MAC, 1);
+out:
+	if (ret)
+		en_err(priv, "failed setting L2 tunnel configuration ret %d\n", ret);
+}
+
+static void mlx4_en_del_vxlan_offloads(struct work_struct *work)
+{
+	int ret;
+	struct mlx4_en_priv *priv = container_of(work, struct mlx4_en_priv,
+						 vxlan_del_task);
+
+	ret = mlx4_SET_PORT_VXLAN(priv->mdev->dev, priv->port,
+				  VXLAN_STEER_BY_OUTER_MAC, 0);
+	if (ret)
+		en_err(priv, "failed setting L2 tunnel configuration ret %d\n", ret);
+
+	priv->vxlan_port = 0;
+}
+
+static void mlx4_en_add_vxlan_port(struct  net_device *dev,
+				   sa_family_t sa_family, __be16 port)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	__be16 current_port;
+
+	if (!(priv->mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_VXLAN_OFFLOADS))
+		return;
+
+	if (sa_family == AF_INET6)
+		return;
+
+	current_port = priv->vxlan_port;
+	if (current_port && current_port != port) {
+		en_warn(priv, "vxlan port %d configured, can't add port %d\n",
+			ntohs(current_port), ntohs(port));
+		return;
+	}
+
+	priv->vxlan_port = port;
+	queue_work(priv->mdev->workqueue, &priv->vxlan_add_task);
+}
+
+static void mlx4_en_del_vxlan_port(struct  net_device *dev,
+				   sa_family_t sa_family, __be16 port)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	__be16 current_port;
+
+	if (priv->mdev->dev->caps.tunnel_offload_mode != MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)
+		return;
+
+	if (sa_family == AF_INET6)
+		return;
+
+	current_port = priv->vxlan_port;
+	if (current_port != port) {
+		en_dbg(DRV, priv, "vxlan port %d isn't configured, ignoring\n", ntohs(port));
+		return;
+	}
+
+	queue_work(priv->mdev->workqueue, &priv->vxlan_del_task);
+}
+
 static const struct net_device_ops mlx4_netdev_ops = {
 	.ndo_open		= mlx4_en_open,
 	.ndo_stop		= mlx4_en_close,
@@ -2290,6 +2368,8 @@ static const struct net_device_ops mlx4_netdev_ops = {
 	.ndo_busy_poll		= mlx4_en_low_latency_recv,
 #endif
 	.ndo_get_phys_port_id	= mlx4_en_get_phys_port_id,
+	.ndo_add_vxlan_port	= mlx4_en_add_vxlan_port,
+	.ndo_del_vxlan_port	= mlx4_en_del_vxlan_port,
 };
 
 static const struct net_device_ops mlx4_netdev_ops_master = {
@@ -2381,6 +2461,8 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	INIT_WORK(&priv->linkstate_task, mlx4_en_linkstate);
 	INIT_DELAYED_WORK(&priv->stats_task, mlx4_en_do_get_stats);
 	INIT_DELAYED_WORK(&priv->service_task, mlx4_en_service_task);
+	INIT_WORK(&priv->vxlan_add_task, mlx4_en_add_vxlan_offloads);
+	INIT_WORK(&priv->vxlan_del_task, mlx4_en_del_vxlan_offloads);
 #ifdef CONFIG_MLX4_EN_DCB
 	if (!mlx4_is_slave(priv->mdev->dev)) {
 		if (mdev->dev->caps.flags & MLX4_DEV_CAP_FLAG_SET_ETH_SCHED) {
@@ -2514,7 +2596,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	}
 
 	if (mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN) {
-		err = mlx4_SET_PORT_VXLAN(mdev->dev, priv->port, VXLAN_STEER_BY_OUTER_MAC);
+		err = mlx4_SET_PORT_VXLAN(mdev->dev, priv->port, VXLAN_STEER_BY_OUTER_MAC, 1);
 		if (err) {
 			en_err(priv, "Failed setting port L2 tunnel configuration, err %d\n",
 			       err);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 69e1f36..36fc2a2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -559,6 +559,8 @@ struct mlx4_en_priv {
 	struct work_struct linkstate_task;
 	struct delayed_work stats_task;
 	struct delayed_work service_task;
+	struct work_struct vxlan_add_task;
+	struct work_struct vxlan_del_task;
 	struct mlx4_en_perf_stats pstats;
 	struct mlx4_en_pkt_stats pkstats;
 	struct mlx4_en_port_stats port_stats;
@@ -585,6 +587,7 @@ struct mlx4_en_priv {
 	struct hlist_head filter_hash[1 << MLX4_EN_FILTER_HASH_SHIFT];
 #endif
 	u64 tunnel_reg_id;
+	__be16 vxlan_port;
 };
 
 enum mlx4_en_wol {
diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index 2705b9a..cfcad26 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -988,7 +988,7 @@ struct mlx4_set_port_vxlan_context {
 	u8	steering;
 };
 
-int mlx4_SET_PORT_VXLAN(struct mlx4_dev *dev, u8 port, u8 steering)
+int mlx4_SET_PORT_VXLAN(struct mlx4_dev *dev, u8 port, u8 steering, int enable)
 {
 	int err;
 	u32 in_mod;
@@ -1002,7 +1002,8 @@ int mlx4_SET_PORT_VXLAN(struct mlx4_dev *dev, u8 port, u8 steering)
 	memset(context, 0, sizeof(*context));
 
 	context->modify_flags = VXLAN_ENABLE_MODIFY | VXLAN_STEERING_MODIFY;
-	context->enable_flags = VXLAN_ENABLE;
+	if (enable)
+		context->enable_flags = VXLAN_ENABLE;
 	context->steering  = steering;
 
 	in_mod = MLX4_SET_PORT_VXLAN << 8 | port;
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index d986c97..ba87bd2 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -1142,7 +1142,7 @@ int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
 int mlx4_SET_PORT_PRIO2TC(struct mlx4_dev *dev, u8 port, u8 *prio2tc);
 int mlx4_SET_PORT_SCHEDULER(struct mlx4_dev *dev, u8 port, u8 *tc_tx_bw,
 		u8 *pg, u16 *ratelimit);
-int mlx4_SET_PORT_VXLAN(struct mlx4_dev *dev, u8 port, u8 steering);
+int mlx4_SET_PORT_VXLAN(struct mlx4_dev *dev, u8 port, u8 steering, int enable);
 int mlx4_find_cached_mac(struct mlx4_dev *dev, u8 port, u64 mac, int *idx);
 int mlx4_find_cached_vlan(struct mlx4_dev *dev, u8 port, u16 vid, int *idx);
 int mlx4_register_vlan(struct mlx4_dev *dev, u8 port, u16 vlan, int *index);
-- 
1.7.1
