From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next 5/8] net/mlx5_core: Firmware commands to support flow counters
Date: Fri, 13 May 2016 12:55:39 +0000
Message-ID: <1463144142-13810-6-git-send-email-amir@vadai.me>
References: <1463144142-13810-1-git-send-email-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amir@vadai.me>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:41806 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753093AbcEMM5z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2016 08:57:55 -0400
In-Reply-To: <1463144142-13810-1-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirva@mellanox.com>

Getting packet/byte statistics on flows is done through flow counters.
Implement the firmware commands to alloc, free and query flow counters.

Signed-off-by: Amir Vadai <amirva@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c    |  6 ++
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c | 66 ++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h |  5 ++
 include/linux/mlx5/mlx5_ifc.h                    | 99 +++++++++++++++++++++++-
 4 files changed, 173 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index 63cac84..dcd2df6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -294,6 +294,7 @@ static int mlx5_internal_err_ret_value(struct mlx5_core_dev *dev, u16 op,
 	case MLX5_CMD_OP_DESTROY_FLOW_TABLE:
 	case MLX5_CMD_OP_DESTROY_FLOW_GROUP:
 	case MLX5_CMD_OP_DELETE_FLOW_TABLE_ENTRY:
+	case MLX5_CMD_OP_DEALLOC_FLOW_COUNTER:
 		return MLX5_CMD_STAT_OK;
 
 	case MLX5_CMD_OP_QUERY_HCA_CAP:
@@ -395,6 +396,8 @@ static int mlx5_internal_err_ret_value(struct mlx5_core_dev *dev, u16 op,
 	case MLX5_CMD_OP_QUERY_FLOW_GROUP:
 	case MLX5_CMD_OP_SET_FLOW_TABLE_ENTRY:
 	case MLX5_CMD_OP_QUERY_FLOW_TABLE_ENTRY:
+	case MLX5_CMD_OP_ALLOC_FLOW_COUNTER:
+	case MLX5_CMD_OP_QUERY_FLOW_COUNTER:
 		*status = MLX5_DRIVER_STATUS_ABORTED;
 		*synd = MLX5_DRIVER_SYND;
 		return -EIO;
@@ -539,6 +542,9 @@ const char *mlx5_command_str(int command)
 	MLX5_COMMAND_STR_CASE(SET_FLOW_TABLE_ENTRY);
 	MLX5_COMMAND_STR_CASE(QUERY_FLOW_TABLE_ENTRY);
 	MLX5_COMMAND_STR_CASE(DELETE_FLOW_TABLE_ENTRY);
+	MLX5_COMMAND_STR_CASE(ALLOC_FLOW_COUNTER);
+	MLX5_COMMAND_STR_CASE(DEALLOC_FLOW_COUNTER);
+	MLX5_COMMAND_STR_CASE(QUERY_FLOW_COUNTER);
 	default: return "unknown command opcode";
 	}
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
index 9797768..ccb63a0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
@@ -323,3 +323,69 @@ int mlx5_cmd_delete_fte(struct mlx5_core_dev *dev,
 
 	return err;
 }
+
+int mlx5_cmd_fc_alloc(struct mlx5_core_dev *dev, u16 *id)
+{
+	u32 in[MLX5_ST_SZ_DW(alloc_flow_counter_in)];
+	u32 out[MLX5_ST_SZ_DW(alloc_flow_counter_out)];
+	int err;
+
+	memset(in, 0, sizeof(in));
+	memset(out, 0, sizeof(out));
+
+	MLX5_SET(alloc_flow_counter_in, in, opcode,
+		 MLX5_CMD_OP_ALLOC_FLOW_COUNTER);
+
+	err = mlx5_cmd_exec_check_status(dev, in, sizeof(in), out,
+					 sizeof(out));
+	if (err)
+		return err;
+
+	*id = MLX5_GET(alloc_flow_counter_out, out, flow_counter_id);
+
+	return 0;
+}
+
+int mlx5_cmd_fc_free(struct mlx5_core_dev *dev, u16 id)
+{
+	u32 in[MLX5_ST_SZ_DW(dealloc_flow_counter_in)];
+	u32 out[MLX5_ST_SZ_DW(dealloc_flow_counter_out)];
+
+	memset(in, 0, sizeof(in));
+	memset(out, 0, sizeof(out));
+
+	MLX5_SET(dealloc_flow_counter_in, in, opcode,
+		 MLX5_CMD_OP_DEALLOC_FLOW_COUNTER);
+	MLX5_SET(dealloc_flow_counter_in, in, flow_counter_id, id);
+
+	return mlx5_cmd_exec_check_status(dev, in, sizeof(in), out,
+					  sizeof(out));
+}
+
+int mlx5_cmd_fc_query(struct mlx5_core_dev *dev, u16 id,
+		      u64 *packets, u64 *bytes)
+{
+	u32 out[MLX5_ST_SZ_BYTES(query_flow_counter_out) +
+		MLX5_ST_SZ_BYTES(traffic_counter)];
+	u32 in[MLX5_ST_SZ_DW(query_flow_counter_in)];
+	void *stats;
+	int err = 0;
+
+	memset(in, 0, sizeof(in));
+	memset(out, 0, sizeof(out));
+
+	MLX5_SET(query_flow_counter_in, in, opcode,
+		 MLX5_CMD_OP_QUERY_FLOW_COUNTER);
+	MLX5_SET(query_flow_counter_in, in, op_mod, 0);
+	MLX5_SET(query_flow_counter_in, in, flow_counter_id, id);
+
+	err = mlx5_cmd_exec_check_status(dev, in, sizeof(in), out, sizeof(out));
+	if (err)
+		return err;
+
+	stats = MLX5_ADDR_OF(query_flow_counter_out, out, flow_statistics);
+	*packets = MLX5_GET64(traffic_counter, stats, packets);
+	*bytes = MLX5_GET64(traffic_counter, stats, octets);
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
index c97b4a0..18c111a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
@@ -70,4 +70,9 @@ int mlx5_cmd_delete_fte(struct mlx5_core_dev *dev,
 
 int mlx5_cmd_update_root_ft(struct mlx5_core_dev *dev,
 			    struct mlx5_flow_table *ft);
+
+int mlx5_cmd_fc_alloc(struct mlx5_core_dev *dev, u16 *id);
+int mlx5_cmd_fc_free(struct mlx5_core_dev *dev, u16 id);
+int mlx5_cmd_fc_query(struct mlx5_core_dev *dev, u16 id,
+		      u64 *packets, u64 *bytes);
 #endif
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 4ce4ea4..614c795 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -202,6 +202,9 @@ enum {
 	MLX5_CMD_OP_SET_FLOW_TABLE_ENTRY          = 0x936,
 	MLX5_CMD_OP_QUERY_FLOW_TABLE_ENTRY        = 0x937,
 	MLX5_CMD_OP_DELETE_FLOW_TABLE_ENTRY       = 0x938,
+	MLX5_CMD_OP_ALLOC_FLOW_COUNTER            = 0x939,
+	MLX5_CMD_OP_DEALLOC_FLOW_COUNTER          = 0x93a,
+	MLX5_CMD_OP_QUERY_FLOW_COUNTER            = 0x93b,
 	MLX5_CMD_OP_MODIFY_FLOW_TABLE             = 0x93c
 };
 
@@ -265,7 +268,8 @@ struct mlx5_ifc_flow_table_fields_supported_bits {
 
 struct mlx5_ifc_flow_table_prop_layout_bits {
 	u8         ft_support[0x1];
-	u8         reserved_at_1[0x2];
+	u8         reserved_at_1[0x1];
+	u8         flow_counter[0x1];
 	u8	   flow_modify_en[0x1];
 	u8         modify_root[0x1];
 	u8         identified_miss_table_mode[0x1];
@@ -941,6 +945,19 @@ struct mlx5_ifc_dest_format_struct_bits {
 	u8         reserved_at_20[0x20];
 };
 
+struct mlx5_ifc_flow_counter_list_bits {
+	u8         reserved_at_0[0x10];
+	u8         flow_counter_id[0x10];
+
+	u8         reserved_at_20[0x20];
+};
+
+union mlx5_ifc_dest_format_struct_flow_counter_list_auto_bits {
+	struct mlx5_ifc_dest_format_struct_bits dest_format_struct;
+	struct mlx5_ifc_flow_counter_list_bits flow_counter_list;
+	u8         reserved_at_0[0x40];
+};
+
 struct mlx5_ifc_fte_match_param_bits {
 	struct mlx5_ifc_fte_match_set_lyr_2_4_bits outer_headers;
 
@@ -2006,6 +2023,7 @@ enum {
 	MLX5_FLOW_CONTEXT_ACTION_ALLOW     = 0x1,
 	MLX5_FLOW_CONTEXT_ACTION_DROP      = 0x2,
 	MLX5_FLOW_CONTEXT_ACTION_FWD_DEST  = 0x4,
+	MLX5_FLOW_CONTEXT_ACTION_COUNT     = 0x8,
 };
 
 struct mlx5_ifc_flow_context_bits {
@@ -2022,13 +2040,16 @@ struct mlx5_ifc_flow_context_bits {
 	u8         reserved_at_80[0x8];
 	u8         destination_list_size[0x18];
 
-	u8         reserved_at_a0[0x160];
+	u8         reserved_at_a0[0x8];
+	u8         flow_counter_list_size[0x18];
+
+	u8         reserved_at_c0[0x140];
 
 	struct mlx5_ifc_fte_match_param_bits match_value;
 
 	u8         reserved_at_1200[0x600];
 
-	struct mlx5_ifc_dest_format_struct_bits destination[0];
+	union mlx5_ifc_dest_format_struct_flow_counter_list_auto_bits destination[0];
 };
 
 enum {
@@ -3937,6 +3958,34 @@ struct mlx5_ifc_query_flow_group_in_bits {
 	u8         reserved_at_e0[0x120];
 };
 
+struct mlx5_ifc_query_flow_counter_out_bits {
+	u8         status[0x8];
+	u8         reserved_at_8[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_at_40[0x40];
+
+	struct mlx5_ifc_traffic_counter_bits flow_statistics[0];
+};
+
+struct mlx5_ifc_query_flow_counter_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_at_10[0x10];
+
+	u8         reserved_at_20[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_at_40[0x80];
+
+	u8         clear[0x1];
+	u8         reserved_at_c1[0xf];
+	u8         num_of_counters[0x10];
+
+	u8         reserved_at_e0[0x10];
+	u8         flow_counter_id[0x10];
+};
+
 struct mlx5_ifc_query_esw_vport_context_out_bits {
 	u8         status[0x8];
 	u8         reserved_at_8[0x18];
@@ -5510,6 +5559,28 @@ struct mlx5_ifc_dealloc_pd_in_bits {
 	u8         reserved_at_60[0x20];
 };
 
+struct mlx5_ifc_dealloc_flow_counter_out_bits {
+	u8         status[0x8];
+	u8         reserved_at_8[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_at_40[0x40];
+};
+
+struct mlx5_ifc_dealloc_flow_counter_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_at_10[0x10];
+
+	u8         reserved_at_20[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_at_40[0x10];
+	u8         flow_counter_id[0x10];
+
+	u8         reserved_at_60[0x20];
+};
+
 struct mlx5_ifc_create_xrc_srq_out_bits {
 	u8         status[0x8];
 	u8         reserved_at_8[0x18];
@@ -6237,6 +6308,28 @@ struct mlx5_ifc_alloc_pd_in_bits {
 	u8         reserved_at_40[0x40];
 };
 
+struct mlx5_ifc_alloc_flow_counter_out_bits {
+	u8         status[0x8];
+	u8         reserved_at_8[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_at_40[0x10];
+	u8         flow_counter_id[0x10];
+
+	u8         reserved_at_60[0x20];
+};
+
+struct mlx5_ifc_alloc_flow_counter_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_at_10[0x10];
+
+	u8         reserved_at_20[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_at_40[0x40];
+};
+
 struct mlx5_ifc_add_vxlan_udp_dport_out_bits {
 	u8         status[0x8];
 	u8         reserved_at_8[0x18];
-- 
2.8.0
