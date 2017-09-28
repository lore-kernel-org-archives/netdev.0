From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 03/11] net/mlx5: Check device capability for maximum flow counters
Date: Thu, 28 Sep 2017 07:41:24 +0300
Message-ID: <20170928044132.30940-4-saeedm@mellanox.com>
References: <20170928044132.30940-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Raed Salem <raeds@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54364 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751042AbdI1EmF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 00:42:05 -0400
In-Reply-To: <20170928044132.30940-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raed Salem <raeds@mellanox.com>

Added check for the maximal number of flow counters attached
to rule (FTE).

Fixes: bd5251dbf156b ('net/mlx5_core: Introduce flow steering destination of type counter')
Signed-off-by: Raed Salem <raeds@mellanox.com>
Reviewed-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c  |  8 ++++++++
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h | 11 +++++++++++
 include/linux/mlx5/mlx5_ifc.h                     |  3 ++-
 3 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
index e0d0efd903bc..36ecc2b2e187 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
@@ -293,6 +293,9 @@ static int mlx5_cmd_set_fte(struct mlx5_core_dev *dev,
 	}
 
 	if (fte->action & MLX5_FLOW_CONTEXT_ACTION_COUNT) {
+		int max_list_size = BIT(MLX5_CAP_FLOWTABLE_TYPE(dev,
+					log_max_flow_counter,
+					ft->type));
 		int list_size = 0;
 
 		list_for_each_entry(dst, &fte->node.children, node.list) {
@@ -305,12 +308,17 @@ static int mlx5_cmd_set_fte(struct mlx5_core_dev *dev,
 			in_dests += MLX5_ST_SZ_BYTES(dest_format_struct);
 			list_size++;
 		}
+		if (list_size > max_list_size) {
+			err = -EINVAL;
+			goto err_out;
+		}
 
 		MLX5_SET(flow_context, in_flow_context, flow_counter_list_size,
 			 list_size);
 	}
 
 	err = mlx5_cmd_exec(dev, in, inlen, out, sizeof(out));
+err_out:
 	kvfree(in);
 	return err;
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index 5509a752f98e..48dd78975062 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
@@ -52,6 +52,7 @@ enum fs_flow_table_type {
 	FS_FT_FDB             = 0X4,
 	FS_FT_SNIFFER_RX	= 0X5,
 	FS_FT_SNIFFER_TX	= 0X6,
+	FS_FT_MAX_TYPE = FS_FT_SNIFFER_TX,
 };
 
 enum fs_flow_table_op_mod {
@@ -260,4 +261,14 @@ void mlx5_cleanup_fs(struct mlx5_core_dev *dev);
 #define fs_for_each_dst(pos, fte)			\
 	fs_list_for_each_entry(pos, &(fte)->node.children)
 
+#define MLX5_CAP_FLOWTABLE_TYPE(mdev, cap, type) (		\
+	(type == FS_FT_NIC_RX) ? MLX5_CAP_FLOWTABLE_NIC_RX(mdev, cap) :		\
+	(type == FS_FT_ESW_EGRESS_ACL) ? MLX5_CAP_ESW_EGRESS_ACL(mdev, cap) :		\
+	(type == FS_FT_ESW_INGRESS_ACL) ? MLX5_CAP_ESW_INGRESS_ACL(mdev, cap) :		\
+	(type == FS_FT_FDB) ? MLX5_CAP_ESW_FLOWTABLE_FDB(mdev, cap) :		\
+	(type == FS_FT_SNIFFER_RX) ? MLX5_CAP_FLOWTABLE_SNIFFER_RX(mdev, cap) :		\
+	(type == FS_FT_SNIFFER_TX) ? MLX5_CAP_FLOWTABLE_SNIFFER_TX(mdev, cap) :		\
+	(BUILD_BUG_ON_ZERO(FS_FT_SNIFFER_TX != FS_FT_MAX_TYPE))\
+	)
+
 #endif
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index a528b35a022e..69772347f866 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -327,7 +327,8 @@ struct mlx5_ifc_flow_table_prop_layout_bits {
 	u8         reserved_at_80[0x18];
 	u8         log_max_destination[0x8];
 
-	u8         reserved_at_a0[0x18];
+	u8         log_max_flow_counter[0x8];
+	u8         reserved_at_a8[0x10];
 	u8         log_max_flow[0x8];
 
 	u8         reserved_at_c0[0x40];
-- 
2.13.0
