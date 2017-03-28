From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 08/12] net/mlx5: Introduce alloc/dealloc modify header context commands
Date: Wed, 29 Mar 2017 02:27:09 +0300
Message-ID: <20170328232713.29894-9-saeedm@mellanox.com>
References: <20170328232713.29894-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amir@vadai.me>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42845 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753952AbdC1X2R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 19:28:17 -0400
In-Reply-To: <20170328232713.29894-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Implement the low-level commands to support packet header re-write.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      |  4 ++
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   | 66 ++++++++++++++++++++++
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |  5 ++
 3 files changed, 75 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index c3c6e931cc35..5bdaf3d545b2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -307,6 +307,7 @@ static int mlx5_internal_err_ret_value(struct mlx5_core_dev *dev, u16 op,
 	case MLX5_CMD_OP_SET_FLOW_TABLE_ENTRY:
 	case MLX5_CMD_OP_SET_FLOW_TABLE_ROOT:
 	case MLX5_CMD_OP_DEALLOC_ENCAP_HEADER:
+	case MLX5_CMD_OP_DEALLOC_MODIFY_HEADER_CONTEXT:
 		return MLX5_CMD_STAT_OK;
 
 	case MLX5_CMD_OP_QUERY_HCA_CAP:
@@ -418,6 +419,7 @@ static int mlx5_internal_err_ret_value(struct mlx5_core_dev *dev, u16 op,
 	case MLX5_CMD_OP_ALLOC_FLOW_COUNTER:
 	case MLX5_CMD_OP_QUERY_FLOW_COUNTER:
 	case MLX5_CMD_OP_ALLOC_ENCAP_HEADER:
+	case MLX5_CMD_OP_ALLOC_MODIFY_HEADER_CONTEXT:
 		*status = MLX5_DRIVER_STATUS_ABORTED;
 		*synd = MLX5_DRIVER_SYND;
 		return -EIO;
@@ -582,6 +584,8 @@ const char *mlx5_command_str(int command)
 	MLX5_COMMAND_STR_CASE(MODIFY_FLOW_TABLE);
 	MLX5_COMMAND_STR_CASE(ALLOC_ENCAP_HEADER);
 	MLX5_COMMAND_STR_CASE(DEALLOC_ENCAP_HEADER);
+	MLX5_COMMAND_STR_CASE(ALLOC_MODIFY_HEADER_CONTEXT);
+	MLX5_COMMAND_STR_CASE(DEALLOC_MODIFY_HEADER_CONTEXT);
 	default: return "unknown command opcode";
 	}
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
index 20d1fd516d03..c6178ea1a461 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
@@ -516,3 +516,69 @@ void mlx5_encap_dealloc(struct mlx5_core_dev *dev, u32 encap_id)
 
 	mlx5_cmd_exec(dev, in, sizeof(in), out, sizeof(out));
 }
+
+int mlx5_modify_header_alloc(struct mlx5_core_dev *dev,
+			     u8 namespace, u8 num_actions,
+			     void *modify_actions, u32 *modify_header_id)
+{
+	u32 out[MLX5_ST_SZ_DW(alloc_modify_header_context_out)];
+	int max_actions, actions_size, inlen, err;
+	void *actions_in;
+	u8 table_type;
+	u32 *in;
+
+	switch (namespace) {
+	case MLX5_FLOW_NAMESPACE_FDB:
+		max_actions = MLX5_CAP_ESW_FLOWTABLE_FDB(dev, max_modify_header_actions);
+		table_type = FS_FT_FDB;
+		break;
+	case MLX5_FLOW_NAMESPACE_KERNEL:
+		max_actions = MLX5_CAP_FLOWTABLE_NIC_RX(dev, max_modify_header_actions);
+		table_type = FS_FT_NIC_RX;
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	if (num_actions > max_actions) {
+		mlx5_core_warn(dev, "too many modify header actions %d, max supported %d\n",
+			       num_actions, max_actions);
+		return -EOPNOTSUPP;
+	}
+
+	actions_size = MLX5_UN_SZ_BYTES(set_action_in_add_action_in_auto) * num_actions;
+	inlen = MLX5_ST_SZ_BYTES(alloc_modify_header_context_in) + actions_size;
+
+	in = kzalloc(inlen, GFP_KERNEL);
+	if (!in)
+		return -ENOMEM;
+
+	MLX5_SET(alloc_modify_header_context_in, in, opcode,
+		 MLX5_CMD_OP_ALLOC_MODIFY_HEADER_CONTEXT);
+	MLX5_SET(alloc_modify_header_context_in, in, table_type, table_type);
+	MLX5_SET(alloc_modify_header_context_in, in, num_of_actions, num_actions);
+
+	actions_in = MLX5_ADDR_OF(alloc_modify_header_context_in, in, actions);
+	memcpy(actions_in, modify_actions, actions_size);
+
+	memset(out, 0, sizeof(out));
+	err = mlx5_cmd_exec(dev, in, inlen, out, sizeof(out));
+
+	*modify_header_id = MLX5_GET(alloc_modify_header_context_out, out, modify_header_id);
+	kfree(in);
+	return err;
+}
+
+void mlx5_modify_header_dealloc(struct mlx5_core_dev *dev, u32 modify_header_id)
+{
+	u32 in[MLX5_ST_SZ_DW(dealloc_modify_header_context_in)];
+	u32 out[MLX5_ST_SZ_DW(dealloc_modify_header_context_out)];
+
+	memset(in, 0, sizeof(in));
+	MLX5_SET(dealloc_modify_header_context_in, in, opcode,
+		 MLX5_CMD_OP_DEALLOC_MODIFY_HEADER_CONTEXT);
+	MLX5_SET(dealloc_modify_header_context_in, in, modify_header_id,
+		 modify_header_id);
+
+	mlx5_cmd_exec(dev, in, sizeof(in), out, sizeof(out));
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index b3dabe6e8836..fbc6e9e9e305 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -141,6 +141,11 @@ int mlx5_encap_alloc(struct mlx5_core_dev *dev,
 		     u32 *encap_id);
 void mlx5_encap_dealloc(struct mlx5_core_dev *dev, u32 encap_id);
 
+int mlx5_modify_header_alloc(struct mlx5_core_dev *dev,
+			     u8 namespace, u8 num_actions,
+			     void *modify_actions, u32 *modify_header_id);
+void mlx5_modify_header_dealloc(struct mlx5_core_dev *dev, u32 modify_header_id);
+
 bool mlx5_lag_intf_add(struct mlx5_interface *intf, struct mlx5_priv *priv);
 
 int mlx5_query_mtpps(struct mlx5_core_dev *dev, u32 *mtpps, u32 mtpps_size);
-- 
2.11.0
