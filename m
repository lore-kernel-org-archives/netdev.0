From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 03/16] net/mlx5: Enable flow-steering for IB link
Date: Thu, 13 Apr 2017 06:36:53 +0300
Message-ID: <20170413033706.19016-4-saeedm@mellanox.com>
References: <20170413033706.19016-1-saeedm@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Vishwanathapura Niranjana <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170413033706.19016-1-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Get the relevant capabilities if supports ipoib_enhanced_offloads and
init the flow steering table accordingly.

Signed-off-by: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 11 ++++-------
 drivers/net/ethernet/mellanox/mlx5/core/fw.c      |  3 ++-
 2 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 55182d0b06e8..b8a176503d38 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -1905,9 +1905,6 @@ void mlx5_cleanup_fs(struct mlx5_core_dev *dev)
 {
 	struct mlx5_flow_steering *steering = dev->priv.steering;
 
-	if (MLX5_CAP_GEN(dev, port_type) != MLX5_CAP_PORT_TYPE_ETH)
-		return;
-
 	cleanup_root_ns(steering->root_ns);
 	cleanup_root_ns(steering->esw_egress_root_ns);
 	cleanup_root_ns(steering->esw_ingress_root_ns);
@@ -2010,9 +2007,6 @@ int mlx5_init_fs(struct mlx5_core_dev *dev)
 	struct mlx5_flow_steering *steering;
 	int err = 0;
 
-	if (MLX5_CAP_GEN(dev, port_type) != MLX5_CAP_PORT_TYPE_ETH)
-		return 0;
-
 	err = mlx5_init_fc_stats(dev);
 	if (err)
 		return err;
@@ -2023,7 +2017,10 @@ int mlx5_init_fs(struct mlx5_core_dev *dev)
 	steering->dev = dev;
 	dev->priv.steering = steering;
 
-	if (MLX5_CAP_GEN(dev, nic_flow_table) &&
+	if ((((MLX5_CAP_GEN(dev, port_type) == MLX5_CAP_PORT_TYPE_ETH) &&
+	      (MLX5_CAP_GEN(dev, nic_flow_table))) ||
+	     ((MLX5_CAP_GEN(dev, port_type) == MLX5_CAP_PORT_TYPE_IB) &&
+	      MLX5_CAP_GEN(dev, ipoib_enhanced_offloads))) &&
 	    MLX5_CAP_FLOWTABLE_NIC_RX(dev, ft_support)) {
 		err = init_root_ns(steering);
 		if (err)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fw.c b/drivers/net/ethernet/mellanox/mlx5/core/fw.c
index d0bbefa08af7..1bc14d0fded8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fw.c
@@ -137,7 +137,8 @@ int mlx5_query_hca_caps(struct mlx5_core_dev *dev)
 			return err;
 	}
 
-	if (MLX5_CAP_GEN(dev, nic_flow_table)) {
+	if (MLX5_CAP_GEN(dev, nic_flow_table) ||
+	    MLX5_CAP_GEN(dev, ipoib_enhanced_offloads)) {
 		err = mlx5_core_get_caps(dev, MLX5_CAP_FLOW_TABLE);
 		if (err)
 			return err;
-- 
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
