From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for-next 13/14] net/mlx5: Introduce TSAR manipulation firmware commands
Date: Tue, 25 Oct 2016 18:00:16 +0300
Message-ID: <1477407617-20745-14-git-send-email-saeedm@mellanox.com>
References: <1477407617-20745-1-git-send-email-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Mohamad Haj Yahia <mohamad-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1477407617-20745-1-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Mohamad Haj Yahia <mohamad-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

TSAR (stands for Transmit Scheduling ARbiter) is a hardware component
that is responsible for selecting the next entity to serve on the
transmit path.
The arbitration defines the QoS policy between the agents connected to
the TSAR.
The TSAR is a consist two main features:
1) BW Allocation between agents:
The TSAR implements a defecit weighted round robin between the agents.
Each agent attached to the TSAR is assigned with a weight and it is
awarded transmission tokens according to this weight.
2) Rate limer per agent:
Each agent attached to the TSAR is (optionally) assigned with a rate
limit.
TSAR will not allow scheduling for an agent exceeding its defined rate
limit.

In this patch we implement the API of manipulating the TSAR.

Signed-off-by: Mohamad Haj Yahia <mohamad-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      |  13 +-
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |   7 +
 drivers/net/ethernet/mellanox/mlx5/core/rl.c       |  65 +++++++
 include/linux/mlx5/mlx5_ifc.h                      | 199 ++++++++++++++++++++-
 4 files changed, 279 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index 1e639f8..8561102 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -318,6 +318,8 @@ static int mlx5_internal_err_ret_value(struct mlx5_core_dev *dev, u16 op,
 	case MLX5_CMD_OP_SET_FLOW_TABLE_ENTRY:
 	case MLX5_CMD_OP_SET_FLOW_TABLE_ROOT:
 	case MLX5_CMD_OP_DEALLOC_ENCAP_HEADER:
+	case MLX5_CMD_OP_DESTROY_SCHEDULING_ELEMENT:
+	case MLX5_CMD_OP_DESTROY_QOS_PARA_VPORT:
 		return MLX5_CMD_STAT_OK;
 
 	case MLX5_CMD_OP_QUERY_HCA_CAP:
@@ -419,11 +421,14 @@ static int mlx5_internal_err_ret_value(struct mlx5_core_dev *dev, u16 op,
 	case MLX5_CMD_OP_QUERY_FLOW_TABLE:
 	case MLX5_CMD_OP_CREATE_FLOW_GROUP:
 	case MLX5_CMD_OP_QUERY_FLOW_GROUP:
-
 	case MLX5_CMD_OP_QUERY_FLOW_TABLE_ENTRY:
 	case MLX5_CMD_OP_ALLOC_FLOW_COUNTER:
 	case MLX5_CMD_OP_QUERY_FLOW_COUNTER:
 	case MLX5_CMD_OP_ALLOC_ENCAP_HEADER:
+	case MLX5_CMD_OP_CREATE_SCHEDULING_ELEMENT:
+	case MLX5_CMD_OP_QUERY_SCHEDULING_ELEMENT:
+	case MLX5_CMD_OP_MODIFY_SCHEDULING_ELEMENT:
+	case MLX5_CMD_OP_CREATE_QOS_PARA_VPORT:
 		*status = MLX5_DRIVER_STATUS_ABORTED;
 		*synd = MLX5_DRIVER_SYND;
 		return -EIO;
@@ -580,6 +585,12 @@ const char *mlx5_command_str(int command)
 	MLX5_COMMAND_STR_CASE(MODIFY_FLOW_TABLE);
 	MLX5_COMMAND_STR_CASE(ALLOC_ENCAP_HEADER);
 	MLX5_COMMAND_STR_CASE(DEALLOC_ENCAP_HEADER);
+	MLX5_COMMAND_STR_CASE(CREATE_SCHEDULING_ELEMENT);
+	MLX5_COMMAND_STR_CASE(DESTROY_SCHEDULING_ELEMENT);
+	MLX5_COMMAND_STR_CASE(QUERY_SCHEDULING_ELEMENT);
+	MLX5_COMMAND_STR_CASE(MODIFY_SCHEDULING_ELEMENT);
+	MLX5_COMMAND_STR_CASE(CREATE_QOS_PARA_VPORT);
+	MLX5_COMMAND_STR_CASE(DESTROY_QOS_PARA_VPORT);
 	default: return "unknown command opcode";
 	}
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index 3d0cfb9..bf43171 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -91,6 +91,13 @@ int mlx5_core_sriov_configure(struct pci_dev *dev, int num_vfs);
 bool mlx5_sriov_is_enabled(struct mlx5_core_dev *dev);
 int mlx5_core_enable_hca(struct mlx5_core_dev *dev, u16 func_id);
 int mlx5_core_disable_hca(struct mlx5_core_dev *dev, u16 func_id);
+int mlx5_create_scheduling_element_cmd(struct mlx5_core_dev *dev, u8 hierarchy,
+				       void *context, u32 *element_id);
+int mlx5_modify_scheduling_element_cmd(struct mlx5_core_dev *dev, u8 hierarchy,
+				       void *context, u32 element_id,
+				       u32 modify_bitmask);
+int mlx5_destroy_scheduling_element_cmd(struct mlx5_core_dev *dev, u8 hierarchy,
+					u32 element_id);
 int mlx5_wait_for_vf_pages(struct mlx5_core_dev *dev);
 cycle_t mlx5_read_internal_timer(struct mlx5_core_dev *dev);
 u32 mlx5_get_msix_vec(struct mlx5_core_dev *dev, int vecidx);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/rl.c b/drivers/net/ethernet/mellanox/mlx5/core/rl.c
index 104902a..e651e4c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/rl.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/rl.c
@@ -36,6 +36,71 @@
 #include <linux/mlx5/cmd.h>
 #include "mlx5_core.h"
 
+/* Scheduling element fw management */
+int mlx5_create_scheduling_element_cmd(struct mlx5_core_dev *dev, u8 hierarchy,
+				       void *ctx, u32 *element_id)
+{
+	u32 in[MLX5_ST_SZ_DW(create_scheduling_element_in)]  = {0};
+	u32 out[MLX5_ST_SZ_DW(create_scheduling_element_in)] = {0};
+	void *schedc;
+	int err;
+
+	schedc = MLX5_ADDR_OF(create_scheduling_element_in, in,
+			      scheduling_context);
+	MLX5_SET(create_scheduling_element_in, in, opcode,
+		 MLX5_CMD_OP_CREATE_SCHEDULING_ELEMENT);
+	MLX5_SET(create_scheduling_element_in, in, scheduling_hierarchy,
+		 hierarchy);
+	memcpy(schedc, ctx, MLX5_ST_SZ_BYTES(scheduling_context));
+
+	err = mlx5_cmd_exec(dev, in, sizeof(in), out, sizeof(out));
+	if (err)
+		return err;
+
+	*element_id = MLX5_GET(create_scheduling_element_out, out,
+			       scheduling_element_id);
+	return 0;
+}
+
+int mlx5_modify_scheduling_element_cmd(struct mlx5_core_dev *dev, u8 hierarchy,
+				       void *ctx, u32 element_id,
+				       u32 modify_bitmask)
+{
+	u32 in[MLX5_ST_SZ_DW(modify_scheduling_element_in)]  = {0};
+	u32 out[MLX5_ST_SZ_DW(modify_scheduling_element_in)] = {0};
+	void *schedc;
+
+	schedc = MLX5_ADDR_OF(modify_scheduling_element_in, in,
+			      scheduling_context);
+	MLX5_SET(modify_scheduling_element_in, in, opcode,
+		 MLX5_CMD_OP_MODIFY_SCHEDULING_ELEMENT);
+	MLX5_SET(modify_scheduling_element_in, in, scheduling_element_id,
+		 element_id);
+	MLX5_SET(modify_scheduling_element_in, in, modify_bitmask,
+		 modify_bitmask);
+	MLX5_SET(modify_scheduling_element_in, in, scheduling_hierarchy,
+		 hierarchy);
+	memcpy(schedc, ctx, MLX5_ST_SZ_BYTES(scheduling_context));
+
+	return mlx5_cmd_exec(dev, in, sizeof(in), out, sizeof(out));
+}
+
+int mlx5_destroy_scheduling_element_cmd(struct mlx5_core_dev *dev, u8 hierarchy,
+					u32 element_id)
+{
+	u32 in[MLX5_ST_SZ_DW(destroy_scheduling_element_in)]  = {0};
+	u32 out[MLX5_ST_SZ_DW(destroy_scheduling_element_in)] = {0};
+
+	MLX5_SET(destroy_scheduling_element_in, in, opcode,
+		 MLX5_CMD_OP_DESTROY_SCHEDULING_ELEMENT);
+	MLX5_SET(destroy_scheduling_element_in, in, scheduling_element_id,
+		 element_id);
+	MLX5_SET(destroy_scheduling_element_in, in, scheduling_hierarchy,
+		 hierarchy);
+
+	return mlx5_cmd_exec(dev, in, sizeof(in), out, sizeof(out));
+}
+
 /* Finds an entry where we can register the given rate
  * If the rate already exists, return the entry where it is registered,
  * otherwise return the first available entry.
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 0ac751f..0961c77 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -146,6 +146,12 @@ enum {
 	MLX5_CMD_OP_QUERY_Q_COUNTER               = 0x773,
 	MLX5_CMD_OP_SET_RATE_LIMIT                = 0x780,
 	MLX5_CMD_OP_QUERY_RATE_LIMIT              = 0x781,
+	MLX5_CMD_OP_CREATE_SCHEDULING_ELEMENT      = 0x782,
+	MLX5_CMD_OP_DESTROY_SCHEDULING_ELEMENT     = 0x783,
+	MLX5_CMD_OP_QUERY_SCHEDULING_ELEMENT       = 0x784,
+	MLX5_CMD_OP_MODIFY_SCHEDULING_ELEMENT      = 0x785,
+	MLX5_CMD_OP_CREATE_QOS_PARA_VPORT         = 0x786,
+	MLX5_CMD_OP_DESTROY_QOS_PARA_VPORT        = 0x787,
 	MLX5_CMD_OP_ALLOC_PD                      = 0x800,
 	MLX5_CMD_OP_DEALLOC_PD                    = 0x801,
 	MLX5_CMD_OP_ALLOC_UAR                     = 0x802,
@@ -540,13 +546,27 @@ struct mlx5_ifc_e_switch_cap_bits {
 
 struct mlx5_ifc_qos_cap_bits {
 	u8         packet_pacing[0x1];
-	u8         reserved_0[0x1f];
-	u8         reserved_1[0x20];
+	u8         esw_scheduling[0x1];
+	u8         reserved_at_2[0x1e];
+
+	u8         reserved_at_20[0x20];
+
 	u8         packet_pacing_max_rate[0x20];
+
 	u8         packet_pacing_min_rate[0x20];
-	u8         reserved_2[0x10];
+
+	u8         reserved_at_80[0x10];
 	u8         packet_pacing_rate_table_size[0x10];
-	u8         reserved_3[0x760];
+
+	u8         esw_element_type[0x10];
+	u8         esw_tsar_type[0x10];
+
+	u8         reserved_at_c0[0x10];
+	u8         max_qos_para_vport[0x10];
+
+	u8         max_tsar_bw_share[0x20];
+
+	u8         reserved_at_100[0x700];
 };
 
 struct mlx5_ifc_per_protocol_networking_offload_caps_bits {
@@ -2450,6 +2470,30 @@ struct mlx5_ifc_sqc_bits {
 	struct mlx5_ifc_wq_bits wq;
 };
 
+enum {
+	SCHEDULING_CONTEXT_ELEMENT_TYPE_TSAR = 0x0,
+	SCHEDULING_CONTEXT_ELEMENT_TYPE_VPORT = 0x1,
+	SCHEDULING_CONTEXT_ELEMENT_TYPE_VPORT_TC = 0x2,
+	SCHEDULING_CONTEXT_ELEMENT_TYPE_PARA_VPORT_TC = 0x3,
+};
+
+struct mlx5_ifc_scheduling_context_bits {
+	u8         element_type[0x8];
+	u8         reserved_at_8[0x18];
+
+	u8         element_attributes[0x20];
+
+	u8         parent_element_id[0x20];
+
+	u8         reserved_at_60[0x40];
+
+	u8         bw_share[0x20];
+
+	u8         max_average_bw[0x20];
+
+	u8         reserved_at_e0[0x120];
+};
+
 struct mlx5_ifc_rqtc_bits {
 	u8         reserved_at_0[0xa0];
 
@@ -3045,6 +3089,29 @@ struct mlx5_ifc_register_loopback_control_bits {
 	u8         reserved_at_20[0x60];
 };
 
+struct mlx5_ifc_vport_tc_element_bits {
+	u8         traffic_class[0x4];
+	u8         reserved_at_4[0xc];
+	u8         vport_number[0x10];
+};
+
+struct mlx5_ifc_vport_element_bits {
+	u8         reserved_at_0[0x10];
+	u8         vport_number[0x10];
+};
+
+enum {
+	TSAR_ELEMENT_TSAR_TYPE_DWRR = 0x0,
+	TSAR_ELEMENT_TSAR_TYPE_ROUND_ROBIN = 0x1,
+	TSAR_ELEMENT_TSAR_TYPE_ETS = 0x2,
+};
+
+struct mlx5_ifc_tsar_element_bits {
+	u8         reserved_at_0[0x8];
+	u8         tsar_type[0x8];
+	u8         reserved_at_10[0x10];
+};
+
 struct mlx5_ifc_teardown_hca_out_bits {
 	u8         status[0x8];
 	u8         reserved_at_8[0x18];
@@ -3669,6 +3736,39 @@ struct mlx5_ifc_query_special_contexts_in_bits {
 	u8         reserved_at_40[0x40];
 };
 
+struct mlx5_ifc_query_scheduling_element_out_bits {
+	u8         opcode[0x10];
+	u8         reserved_at_10[0x10];
+
+	u8         reserved_at_20[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_at_40[0xc0];
+
+	struct mlx5_ifc_scheduling_context_bits scheduling_context;
+
+	u8         reserved_at_300[0x100];
+};
+
+enum {
+	SCHEDULING_HIERARCHY_E_SWITCH = 0x2,
+};
+
+struct mlx5_ifc_query_scheduling_element_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_at_10[0x10];
+
+	u8         reserved_at_20[0x10];
+	u8         op_mod[0x10];
+
+	u8         scheduling_hierarchy[0x8];
+	u8         reserved_at_48[0x18];
+
+	u8         scheduling_element_id[0x20];
+
+	u8         reserved_at_80[0x180];
+};
+
 struct mlx5_ifc_query_rqt_out_bits {
 	u8         status[0x8];
 	u8         reserved_at_8[0x18];
@@ -4873,6 +4973,43 @@ struct mlx5_ifc_modify_sq_in_bits {
 	struct mlx5_ifc_sqc_bits ctx;
 };
 
+struct mlx5_ifc_modify_scheduling_element_out_bits {
+	u8         status[0x8];
+	u8         reserved_at_8[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_at_40[0x1c0];
+};
+
+enum {
+	MODIFY_SCHEDULING_ELEMENT_IN_MODIFY_BITMASK_BW_SHARE = 0x1,
+	MODIFY_SCHEDULING_ELEMENT_IN_MODIFY_BITMASK_MAX_AVERAGE_BW = 0x2,
+};
+
+struct mlx5_ifc_modify_scheduling_element_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_at_10[0x10];
+
+	u8         reserved_at_20[0x10];
+	u8         op_mod[0x10];
+
+	u8         scheduling_hierarchy[0x8];
+	u8         reserved_at_48[0x18];
+
+	u8         scheduling_element_id[0x20];
+
+	u8         reserved_at_80[0x20];
+
+	u8         modify_bitmask[0x20];
+
+	u8         reserved_at_c0[0x40];
+
+	struct mlx5_ifc_scheduling_context_bits scheduling_context;
+
+	u8         reserved_at_300[0x100];
+};
+
 struct mlx5_ifc_modify_rqt_out_bits {
 	u8         status[0x8];
 	u8         reserved_at_8[0x18];
@@ -5538,6 +5675,30 @@ struct mlx5_ifc_destroy_sq_in_bits {
 	u8         reserved_at_60[0x20];
 };
 
+struct mlx5_ifc_destroy_scheduling_element_out_bits {
+	u8         status[0x8];
+	u8         reserved_at_8[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_at_40[0x1c0];
+};
+
+struct mlx5_ifc_destroy_scheduling_element_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_at_10[0x10];
+
+	u8         reserved_at_20[0x10];
+	u8         op_mod[0x10];
+
+	u8         scheduling_hierarchy[0x8];
+	u8         reserved_at_48[0x18];
+
+	u8         scheduling_element_id[0x20];
+
+	u8         reserved_at_80[0x180];
+};
+
 struct mlx5_ifc_destroy_rqt_out_bits {
 	u8         status[0x8];
 	u8         reserved_at_8[0x18];
@@ -6165,6 +6326,36 @@ struct mlx5_ifc_create_sq_in_bits {
 	struct mlx5_ifc_sqc_bits ctx;
 };
 
+struct mlx5_ifc_create_scheduling_element_out_bits {
+	u8         status[0x8];
+	u8         reserved_at_8[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_at_40[0x40];
+
+	u8         scheduling_element_id[0x20];
+
+	u8         reserved_at_a0[0x160];
+};
+
+struct mlx5_ifc_create_scheduling_element_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_at_10[0x10];
+
+	u8         reserved_at_20[0x10];
+	u8         op_mod[0x10];
+
+	u8         scheduling_hierarchy[0x8];
+	u8         reserved_at_48[0x18];
+
+	u8         reserved_at_60[0xa0];
+
+	struct mlx5_ifc_scheduling_context_bits scheduling_context;
+
+	u8         reserved_at_300[0x100];
+};
+
 struct mlx5_ifc_create_rqt_out_bits {
 	u8         status[0x8];
 	u8         reserved_at_8[0x18];
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
