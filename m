From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 3/7] net/mlx4_en: Move statistics bitmap setting to the Ethernet driver
Date: Mon, 30 Mar 2015 17:45:22 +0300
Message-ID: <1427726726-27516-4-git-send-email-ogerlitz@mellanox.com>
References: <1427726726-27516-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Hadar Har-Zion <hadarh@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:50777 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753454AbbC3Opo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2015 10:45:44 -0400
In-Reply-To: <1427726726-27516-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

The statistics bitmap belongs to the Ethernet driver, move it there.

Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   22 +++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    2 ++
 drivers/net/ethernet/mellanox/mlx4/port.c      |   21 ---------------------
 include/linux/mlx4/device.h                    |    1 -
 4 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index ebc93a1..9556230 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -49,6 +49,11 @@
 #include "mlx4_en.h"
 #include "en_port.h"
 
+#define MLX4_STATS_TRAFFIC_COUNTERS_MASK	0xfULL
+#define MLX4_STATS_TRAFFIC_DROPS_MASK		0xc0ULL
+#define MLX4_STATS_ERROR_COUNTERS_MASK		0x1ffc30ULL
+#define MLX4_STATS_PORT_COUNTERS_MASK		0x7fe00000ULL
+
 int mlx4_en_setup_tc(struct net_device *dev, u8 up)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
@@ -2648,6 +2653,21 @@ int mlx4_en_netdev_event(struct notifier_block *this,
 	return NOTIFY_DONE;
 }
 
+void mlx4_en_set_stats_bitmap(struct mlx4_dev *dev, u64 *stats_bitmap)
+{
+	if (!mlx4_is_mfunc(dev)) {
+		*stats_bitmap = 0;
+		return;
+	}
+
+	*stats_bitmap = (MLX4_STATS_TRAFFIC_COUNTERS_MASK |
+			 MLX4_STATS_TRAFFIC_DROPS_MASK |
+			 MLX4_STATS_PORT_COUNTERS_MASK);
+
+	if (mlx4_is_master(dev))
+		*stats_bitmap |= MLX4_STATS_ERROR_COUNTERS_MASK;
+}
+
 int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 			struct mlx4_en_port_profile *prof)
 {
@@ -2881,7 +2901,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 		queue_delayed_work(mdev->workqueue, &priv->service_task,
 				   SERVICE_TASK_DELAY);
 
-	mlx4_set_stats_bitmap(mdev->dev, &priv->stats_bitmap);
+	mlx4_en_set_stats_bitmap(mdev->dev, &priv->stats_bitmap);
 
 	return 0;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 6b379a2..af3d9b7 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -730,6 +730,8 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 int mlx4_en_start_port(struct net_device *dev);
 void mlx4_en_stop_port(struct net_device *dev, int detach);
 
+void mlx4_en_set_stats_bitmap(struct mlx4_dev *dev, u64 *stats_bitmap);
+
 void mlx4_en_free_resources(struct mlx4_en_priv *priv);
 int mlx4_en_alloc_resources(struct mlx4_en_priv *priv);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index 3f6f771..b97f173 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -45,11 +45,6 @@
 #define MLX4_VLAN_VALID		(1u << 31)
 #define MLX4_VLAN_MASK		0xfff
 
-#define MLX4_STATS_TRAFFIC_COUNTERS_MASK	0xfULL
-#define MLX4_STATS_TRAFFIC_DROPS_MASK		0xc0ULL
-#define MLX4_STATS_ERROR_COUNTERS_MASK		0x1ffc30ULL
-#define MLX4_STATS_PORT_COUNTERS_MASK		0x7fe00000ULL
-
 void mlx4_init_mac_table(struct mlx4_dev *dev, struct mlx4_mac_table *table)
 {
 	int i;
@@ -1185,22 +1180,6 @@ int mlx4_DUMP_ETH_STATS_wrapper(struct mlx4_dev *dev, int slave,
 					  vhcr->in_modifier, outbox);
 }
 
-void mlx4_set_stats_bitmap(struct mlx4_dev *dev, u64 *stats_bitmap)
-{
-	if (!mlx4_is_mfunc(dev)) {
-		*stats_bitmap = 0;
-		return;
-	}
-
-	*stats_bitmap = (MLX4_STATS_TRAFFIC_COUNTERS_MASK |
-			 MLX4_STATS_TRAFFIC_DROPS_MASK |
-			 MLX4_STATS_PORT_COUNTERS_MASK);
-
-	if (mlx4_is_master(dev))
-		*stats_bitmap |= MLX4_STATS_ERROR_COUNTERS_MASK;
-}
-EXPORT_SYMBOL(mlx4_set_stats_bitmap);
-
 int mlx4_get_slave_from_roce_gid(struct mlx4_dev *dev, int port, u8 *gid,
 				 int *slave_id)
 {
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 4550c67..49abbe2 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -1300,7 +1300,6 @@ int mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac);
 void mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, u64 mac);
 int mlx4_get_base_qpn(struct mlx4_dev *dev, u8 port);
 int __mlx4_replace_mac(struct mlx4_dev *dev, u8 port, int qpn, u64 new_mac);
-void mlx4_set_stats_bitmap(struct mlx4_dev *dev, u64 *stats_bitmap);
 int mlx4_SET_PORT_general(struct mlx4_dev *dev, u8 port, int mtu,
 			  u8 pptx, u8 pfctx, u8 pprx, u8 pfcrx);
 int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
-- 
1.7.1
