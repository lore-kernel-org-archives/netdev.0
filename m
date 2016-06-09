From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 05/13] net/mlx5: Fix flow steering NIC capabilities check
Date: Fri, 10 Jun 2016 00:07:32 +0300
Message-ID: <1465506460-1854-6-git-send-email-saeedm@mellanox.com>
References: <1465506460-1854-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:34424 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752199AbcFIVIa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2016 17:08:30 -0400
In-Reply-To: <1465506460-1854-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Flow steering infrastructure is currently used only on link layer
ethernet, therefore the driver should initialize the flow steering
when the device link layer is ethernet.

In addition, add missing capability check before initializing the
namespace of NIC RX flow tables.

Fixes: 2530236303d9 ('net/mlx5_core: Flow steering tree initialization')
Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 10 +++++++++-
 include/linux/mlx5/device.h                       |  6 ++++++
 2 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index fa6fec1..c1efa55 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -1767,6 +1767,9 @@ static void cleanup_root_ns(struct mlx5_core_dev *dev)
 
 void mlx5_cleanup_fs(struct mlx5_core_dev *dev)
 {
+	if (MLX5_CAP_GEN(dev, port_type) != MLX5_CAP_PORT_TYPE_ETH)
+		return;
+
 	cleanup_root_ns(dev);
 	cleanup_single_prio_root_ns(dev, dev->priv.fdb_root_ns);
 	cleanup_single_prio_root_ns(dev, dev->priv.esw_egress_root_ns);
@@ -1828,15 +1831,20 @@ int mlx5_init_fs(struct mlx5_core_dev *dev)
 {
 	int err = 0;
 
+	if (MLX5_CAP_GEN(dev, port_type) != MLX5_CAP_PORT_TYPE_ETH)
+		return 0;
+
 	err = mlx5_init_fc_stats(dev);
 	if (err)
 		return err;
 
-	if (MLX5_CAP_GEN(dev, nic_flow_table)) {
+	if (MLX5_CAP_GEN(dev, nic_flow_table) &&
+	    MLX5_CAP_FLOWTABLE_NIC_RX(dev, ft_support)) {
 		err = init_root_ns(dev);
 		if (err)
 			goto err;
 	}
+
 	if (MLX5_CAP_GEN(dev, eswitch_flow_table)) {
 		err = init_fdb_root_ns(dev);
 		if (err)
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index 51f0caf..73a4847 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -1367,6 +1367,12 @@ enum mlx5_cap_type {
 #define MLX5_CAP_FLOWTABLE_MAX(mdev, cap) \
 	MLX5_GET(flow_table_nic_cap, mdev->hca_caps_max[MLX5_CAP_FLOW_TABLE], cap)
 
+#define MLX5_CAP_FLOWTABLE_NIC_RX(mdev, cap) \
+	MLX5_CAP_FLOWTABLE(mdev, flow_table_properties_nic_receive.cap)
+
+#define MLX5_CAP_FLOWTABLE_NIC_RX_MAX(mdev, cap) \
+	MLX5_CAP_FLOWTABLE_MAX(mdev, flow_table_properties_nic_receive.cap)
+
 #define MLX5_CAP_ESW_FLOWTABLE(mdev, cap) \
 	MLX5_GET(flow_table_eswitch_cap, \
 		 mdev->hca_caps_cur[MLX5_CAP_ESWITCH_FLOW_TABLE], cap)
-- 
2.8.0
