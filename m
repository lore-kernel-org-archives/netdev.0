From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for-next 05/15] net/mlx5: Add HW interfaces used by LAG
Date: Wed, 24 Aug 2016 13:39:04 +0300
Message-ID: <1472035154-14517-6-git-send-email-saeedm@mellanox.com>
References: <1472035154-14517-1-git-send-email-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Majd Dibbiny <majd-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Aviv Heller <avivh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1472035154-14517-1-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Aviv Heller <avivh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Exposed LAG commands enum and layouts:
- CREATE_LAG
  HW enters LAG mode:
  RoCE traffic from port two is received on PF0 core dev.
  Allows to set tx_affinity (tx port) for QPs and TISes.
  Allows to port remap QPs and TISes, overriding their
  tx_affinity behavior.

- MODIFY_LAG
  Remap QPs and TISes to another port.

- QUERY_LAG
  Query whether LAG mode is active.

- DESTROY_LAG
  HW exits LAG mode, returning to non-LAG behavior.

- CREATE_VPORT_LAG
  Merge Ethernet flow steering, such that traffic received on port
  two jumps to PF0 root flow table.

  Available only in LAG mode.

- DESTROY_VPORT_LAG
  Ethernet flow steering returns to non-LAG behavior.

Caps added:
- lag_master
  Driver is in charge of managing the LAG.
  This is currently the only option.

- num_lag_ports
  LAG is supported only if this field's value is 2.

Other fields:
- QP/TIS tx port affinity
  During LAG, this field controls on which port a QP or TIS resides.

- TIS strict tx affinity
  When this field is set, the TIS will not be subject to port remap by
  CREATE_LAG/MODIFY_LAG.

- LAG demux flow table
  Flow table used for redirecting non user-space traffic back to
  PF1 root flow table, if the packet was received on port two.

Signed-off-by: Aviv Heller <avivh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c |  12 ++
 include/linux/mlx5/mlx5_ifc.h                 | 166 ++++++++++++++++++++++++--
 2 files changed, 171 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index 00bec60..6388bc0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -285,6 +285,8 @@ static int mlx5_internal_err_ret_value(struct mlx5_core_dev *dev, u16 op,
 	case MLX5_CMD_OP_DEALLOC_TRANSPORT_DOMAIN:
 	case MLX5_CMD_OP_DELETE_VXLAN_UDP_DPORT:
 	case MLX5_CMD_OP_DELETE_L2_TABLE_ENTRY:
+	case MLX5_CMD_OP_DESTROY_LAG:
+	case MLX5_CMD_OP_DESTROY_VPORT_LAG:
 	case MLX5_CMD_OP_DESTROY_TIR:
 	case MLX5_CMD_OP_DESTROY_SQ:
 	case MLX5_CMD_OP_DESTROY_RQ:
@@ -376,6 +378,10 @@ static int mlx5_internal_err_ret_value(struct mlx5_core_dev *dev, u16 op,
 	case MLX5_CMD_OP_ADD_VXLAN_UDP_DPORT:
 	case MLX5_CMD_OP_SET_L2_TABLE_ENTRY:
 	case MLX5_CMD_OP_QUERY_L2_TABLE_ENTRY:
+	case MLX5_CMD_OP_CREATE_LAG:
+	case MLX5_CMD_OP_MODIFY_LAG:
+	case MLX5_CMD_OP_QUERY_LAG:
+	case MLX5_CMD_OP_CREATE_VPORT_LAG:
 	case MLX5_CMD_OP_CREATE_TIR:
 	case MLX5_CMD_OP_MODIFY_TIR:
 	case MLX5_CMD_OP_QUERY_TIR:
@@ -514,6 +520,12 @@ const char *mlx5_command_str(int command)
 	MLX5_COMMAND_STR_CASE(DELETE_L2_TABLE_ENTRY);
 	MLX5_COMMAND_STR_CASE(SET_WOL_ROL);
 	MLX5_COMMAND_STR_CASE(QUERY_WOL_ROL);
+	MLX5_COMMAND_STR_CASE(CREATE_LAG);
+	MLX5_COMMAND_STR_CASE(MODIFY_LAG);
+	MLX5_COMMAND_STR_CASE(QUERY_LAG);
+	MLX5_COMMAND_STR_CASE(DESTROY_LAG);
+	MLX5_COMMAND_STR_CASE(CREATE_VPORT_LAG);
+	MLX5_COMMAND_STR_CASE(DESTROY_VPORT_LAG);
 	MLX5_COMMAND_STR_CASE(CREATE_TIR);
 	MLX5_COMMAND_STR_CASE(MODIFY_TIR);
 	MLX5_COMMAND_STR_CASE(DESTROY_TIR);
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 5f150c8..043d525 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -174,6 +174,12 @@ enum {
 	MLX5_CMD_OP_DELETE_L2_TABLE_ENTRY         = 0x82b,
 	MLX5_CMD_OP_SET_WOL_ROL                   = 0x830,
 	MLX5_CMD_OP_QUERY_WOL_ROL                 = 0x831,
+	MLX5_CMD_OP_CREATE_LAG                    = 0x840,
+	MLX5_CMD_OP_MODIFY_LAG                    = 0x841,
+	MLX5_CMD_OP_QUERY_LAG                     = 0x842,
+	MLX5_CMD_OP_DESTROY_LAG                   = 0x843,
+	MLX5_CMD_OP_CREATE_VPORT_LAG              = 0x844,
+	MLX5_CMD_OP_DESTROY_VPORT_LAG             = 0x845,
 	MLX5_CMD_OP_CREATE_TIR                    = 0x900,
 	MLX5_CMD_OP_MODIFY_TIR                    = 0x901,
 	MLX5_CMD_OP_DESTROY_TIR                   = 0x902,
@@ -884,7 +890,10 @@ struct mlx5_ifc_cmd_hca_cap_bits {
 	u8         pad_tx_eth_packet[0x1];
 	u8         reserved_at_263[0x8];
 	u8         log_bf_reg_size[0x5];
-	u8         reserved_at_270[0x10];
+
+	u8         reserved_at_270[0xb];
+	u8         lag_master[0x1];
+	u8         num_lag_ports[0x4];
 
 	u8         reserved_at_280[0x10];
 	u8         max_wqe_sz_sq[0x10];
@@ -1918,7 +1927,7 @@ enum {
 
 struct mlx5_ifc_qpc_bits {
 	u8         state[0x4];
-	u8         reserved_at_4[0x4];
+	u8         lag_tx_port_affinity[0x4];
 	u8         st[0x8];
 	u8         reserved_at_10[0x3];
 	u8         pm_state[0x2];
@@ -2167,7 +2176,11 @@ struct mlx5_ifc_traffic_counter_bits {
 };
 
 struct mlx5_ifc_tisc_bits {
-	u8         reserved_at_0[0xc];
+	u8         strict_lag_tx_port_affinity[0x1];
+	u8         reserved_at_1[0x3];
+	u8         lag_tx_port_affinity[0x04];
+
+	u8         reserved_at_8[0x4];
 	u8         prio[0x4];
 	u8         reserved_at_10[0x10];
 
@@ -4617,7 +4630,9 @@ struct mlx5_ifc_modify_tis_out_bits {
 struct mlx5_ifc_modify_tis_bitmask_bits {
 	u8         reserved_at_0[0x20];
 
-	u8         reserved_at_20[0x1f];
+	u8         reserved_at_20[0x1d];
+	u8         lag_tx_port_affinity[0x1];
+	u8         strict_lag_tx_port_affinity[0x1];
 	u8         prio[0x1];
 };
 
@@ -6215,7 +6230,10 @@ struct mlx5_ifc_create_flow_table_in_bits {
 	u8         reserved_at_e0[0x8];
 	u8         table_miss_id[0x18];
 
-	u8         reserved_at_100[0x100];
+	u8         reserved_at_100[0x8];
+	u8         lag_master_next_table_id[0x18];
+
+	u8         reserved_at_120[0x80];
 };
 
 struct mlx5_ifc_create_flow_group_out_bits {
@@ -7669,7 +7687,8 @@ struct mlx5_ifc_set_flow_table_root_in_bits {
 };
 
 enum {
-	MLX5_MODIFY_FLOW_TABLE_MISS_TABLE_ID = 0x1,
+	MLX5_MODIFY_FLOW_TABLE_MISS_TABLE_ID     = (1UL << 0),
+	MLX5_MODIFY_FLOW_TABLE_LAG_NEXT_TABLE_ID = (1UL << 15),
 };
 
 struct mlx5_ifc_modify_flow_table_out_bits {
@@ -7708,7 +7727,10 @@ struct mlx5_ifc_modify_flow_table_in_bits {
 	u8         reserved_at_e0[0x8];
 	u8         table_miss_id[0x18];
 
-	u8         reserved_at_100[0x100];
+	u8         reserved_at_100[0x8];
+	u8         lag_master_next_table_id[0x18];
+
+	u8         reserved_at_120[0x80];
 };
 
 struct mlx5_ifc_ets_tcn_config_reg_bits {
@@ -7816,4 +7838,134 @@ struct mlx5_ifc_dcbx_param_bits {
 	u8         error[0x8];
 	u8         reserved_at_a0[0x160];
 };
+
+struct mlx5_ifc_lagc_bits {
+	u8         reserved_at_0[0x1d];
+	u8         lag_state[0x3];
+
+	u8         reserved_at_20[0x14];
+	u8         tx_remap_affinity_2[0x4];
+	u8         reserved_at_38[0x4];
+	u8         tx_remap_affinity_1[0x4];
+};
+
+struct mlx5_ifc_create_lag_out_bits {
+	u8         status[0x8];
+	u8         reserved_at_8[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_at_40[0x40];
+};
+
+struct mlx5_ifc_create_lag_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_at_10[0x10];
+
+	u8         reserved_at_20[0x10];
+	u8         op_mod[0x10];
+
+	struct mlx5_ifc_lagc_bits ctx;
+};
+
+struct mlx5_ifc_modify_lag_out_bits {
+	u8         status[0x8];
+	u8         reserved_at_8[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_at_40[0x40];
+};
+
+struct mlx5_ifc_modify_lag_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_at_10[0x10];
+
+	u8         reserved_at_20[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_at_40[0x20];
+	u8         field_select[0x20];
+
+	struct mlx5_ifc_lagc_bits ctx;
+};
+
+struct mlx5_ifc_query_lag_out_bits {
+	u8         status[0x8];
+	u8         reserved_at_8[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_at_40[0x40];
+
+	struct mlx5_ifc_lagc_bits ctx;
+};
+
+struct mlx5_ifc_query_lag_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_at_10[0x10];
+
+	u8         reserved_at_20[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_at_40[0x40];
+};
+
+struct mlx5_ifc_destroy_lag_out_bits {
+	u8         status[0x8];
+	u8         reserved_at_8[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_at_40[0x40];
+};
+
+struct mlx5_ifc_destroy_lag_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_at_10[0x10];
+
+	u8         reserved_at_20[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_at_40[0x40];
+};
+
+struct mlx5_ifc_create_vport_lag_out_bits {
+	u8         status[0x8];
+	u8         reserved_at_8[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_at_40[0x40];
+};
+
+struct mlx5_ifc_create_vport_lag_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_at_10[0x10];
+
+	u8         reserved_at_20[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_at_40[0x40];
+};
+
+struct mlx5_ifc_destroy_vport_lag_out_bits {
+	u8         status[0x8];
+	u8         reserved_at_8[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_at_40[0x40];
+};
+
+struct mlx5_ifc_destroy_vport_lag_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_at_10[0x10];
+
+	u8         reserved_at_20[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_at_40[0x40];
+};
+
 #endif /* MLX5_IFC_H */
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
