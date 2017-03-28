From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 07/12] net/mlx5: Introduce modify header structures, commands and steering action definitions
Date: Wed, 29 Mar 2017 02:27:08 +0300
Message-ID: <20170328232713.29894-8-saeedm@mellanox.com>
References: <20170328232713.29894-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amir@vadai.me>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42864 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932571AbdC1X2V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 19:28:21 -0400
In-Reply-To: <20170328232713.29894-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Add the definitions related to creation/deletion of a modify header
context and the modify header steering action which are used for HW
packet header modify (re-write) as part of steering. Add as well the
modify header id into two intermediate structs and set it to the FTE.

Note that as the push/pop vlan steering actions are emulated by the
ewitch management code, we're not breaking any compatibility while
changing their values to make room for the modify header action which
is not emulated and whose value is part of the FW API. The new bit
values for the emulated actions are at the end of the possible range.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c  |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h |   1 +
 include/linux/mlx5/fs.h                           |   3 +-
 include/linux/mlx5/mlx5_ifc.h                     | 113 +++++++++++++++++++++-
 6 files changed, 118 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index ad329b1680b4..cd9240c3a7f0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -285,8 +285,8 @@ enum {
 	SET_VLAN_INSERT	= BIT(1)
 };
 
-#define MLX5_FLOW_CONTEXT_ACTION_VLAN_POP  0x40
-#define MLX5_FLOW_CONTEXT_ACTION_VLAN_PUSH 0x80
+#define MLX5_FLOW_CONTEXT_ACTION_VLAN_POP  0x4000
+#define MLX5_FLOW_CONTEXT_ACTION_VLAN_PUSH 0x8000
 
 struct mlx5_encap_entry {
 	struct hlist_node encap_hlist;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
index b64a781c7e85..20d1fd516d03 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
@@ -249,6 +249,7 @@ static int mlx5_cmd_set_fte(struct mlx5_core_dev *dev,
 	MLX5_SET(flow_context, in_flow_context, flow_tag, fte->flow_tag);
 	MLX5_SET(flow_context, in_flow_context, action, fte->action);
 	MLX5_SET(flow_context, in_flow_context, encap_id, fte->encap_id);
+	MLX5_SET(flow_context, in_flow_context, modify_header_id, fte->modify_id);
 	in_match_value = MLX5_ADDR_OF(flow_context, in_flow_context,
 				      match_value);
 	memcpy(in_match_value, &fte->val, MLX5_ST_SZ_BYTES(fte_match_param));
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index ded27bb9a3b6..27ff815600f7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -476,6 +476,7 @@ static struct fs_fte *alloc_fte(struct mlx5_flow_act *flow_act,
 	fte->index = index;
 	fte->action = flow_act->action;
 	fte->encap_id = flow_act->encap_id;
+	fte->modify_id = flow_act->modify_id;
 
 	return fte;
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index 8e668c63f69e..03af2e7989f3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
@@ -152,6 +152,7 @@ struct fs_fte {
 	u32				index;
 	u32				action;
 	u32				encap_id;
+	u32				modify_id;
 	enum fs_fte_status		status;
 	struct mlx5_fc			*counter;
 };
diff --git a/include/linux/mlx5/fs.h b/include/linux/mlx5/fs.h
index 5eea1ba2e593..ae91a4bda1a3 100644
--- a/include/linux/mlx5/fs.h
+++ b/include/linux/mlx5/fs.h
@@ -134,11 +134,12 @@ struct mlx5_flow_act {
 	u32 action;
 	u32 flow_tag;
 	u32 encap_id;
+	u32 modify_id;
 };
 
 #define MLX5_DECLARE_FLOW_ACT(name) \
 	struct mlx5_flow_act name = {MLX5_FLOW_CONTEXT_ACTION_FWD_DEST,\
-				     MLX5_FS_DEFAULT_FLOW_TAG, 0}
+				     MLX5_FS_DEFAULT_FLOW_TAG, 0, 0}
 
 /* Single destination per rule.
  * Group ID is implied by the match criteria.
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 838242697541..56bc842b0620 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -227,6 +227,8 @@ enum {
 	MLX5_CMD_OP_MODIFY_FLOW_TABLE             = 0x93c,
 	MLX5_CMD_OP_ALLOC_ENCAP_HEADER            = 0x93d,
 	MLX5_CMD_OP_DEALLOC_ENCAP_HEADER          = 0x93e,
+	MLX5_CMD_OP_ALLOC_MODIFY_HEADER_CONTEXT   = 0x940,
+	MLX5_CMD_OP_DEALLOC_MODIFY_HEADER_CONTEXT = 0x941,
 	MLX5_CMD_OP_MAX
 };
 
@@ -302,7 +304,8 @@ struct mlx5_ifc_flow_table_prop_layout_bits {
 
 	u8         reserved_at_20[0x2];
 	u8         log_max_ft_size[0x6];
-	u8         reserved_at_28[0x10];
+	u8         log_max_modify_header_context[0x8];
+	u8         max_modify_header_actions[0x8];
 	u8         max_ft_level[0x8];
 
 	u8         reserved_at_40[0x20];
@@ -2190,6 +2193,7 @@ enum {
 	MLX5_FLOW_CONTEXT_ACTION_COUNT     = 0x8,
 	MLX5_FLOW_CONTEXT_ACTION_ENCAP     = 0x10,
 	MLX5_FLOW_CONTEXT_ACTION_DECAP     = 0x20,
+	MLX5_FLOW_CONTEXT_ACTION_MOD_HDR   = 0x40,
 };
 
 struct mlx5_ifc_flow_context_bits {
@@ -2211,7 +2215,9 @@ struct mlx5_ifc_flow_context_bits {
 
 	u8         encap_id[0x20];
 
-	u8         reserved_at_e0[0x120];
+	u8         modify_header_id[0x20];
+
+	u8         reserved_at_100[0x100];
 
 	struct mlx5_ifc_fte_match_param_bits match_value;
 
@@ -4534,6 +4540,109 @@ struct mlx5_ifc_dealloc_encap_header_in_bits {
 	u8         reserved_60[0x20];
 };
 
+struct mlx5_ifc_set_action_in_bits {
+	u8         action_type[0x4];
+	u8         field[0xc];
+	u8         reserved_at_10[0x3];
+	u8         offset[0x5];
+	u8         reserved_at_18[0x3];
+	u8         length[0x5];
+
+	u8         data[0x20];
+};
+
+struct mlx5_ifc_add_action_in_bits {
+	u8         action_type[0x4];
+	u8         field[0xc];
+	u8         reserved_at_10[0x10];
+
+	u8         data[0x20];
+};
+
+union mlx5_ifc_set_action_in_add_action_in_auto_bits {
+	struct mlx5_ifc_set_action_in_bits set_action_in;
+	struct mlx5_ifc_add_action_in_bits add_action_in;
+	u8         reserved_at_0[0x40];
+};
+
+enum {
+	MLX5_ACTION_TYPE_SET   = 0x1,
+	MLX5_ACTION_TYPE_ADD   = 0x2,
+};
+
+enum {
+	MLX5_ACTION_IN_FIELD_OUT_SMAC_47_16    = 0x1,
+	MLX5_ACTION_IN_FIELD_OUT_SMAC_15_0     = 0x2,
+	MLX5_ACTION_IN_FIELD_OUT_ETHERTYPE     = 0x3,
+	MLX5_ACTION_IN_FIELD_OUT_DMAC_47_16    = 0x4,
+	MLX5_ACTION_IN_FIELD_OUT_DMAC_15_0     = 0x5,
+	MLX5_ACTION_IN_FIELD_OUT_IP_DSCP       = 0x6,
+	MLX5_ACTION_IN_FIELD_OUT_TCP_FLAGS     = 0x7,
+	MLX5_ACTION_IN_FIELD_OUT_TCP_SPORT     = 0x8,
+	MLX5_ACTION_IN_FIELD_OUT_TCP_DPORT     = 0x9,
+	MLX5_ACTION_IN_FIELD_OUT_IP_TTL        = 0xa,
+	MLX5_ACTION_IN_FIELD_OUT_UDP_SPORT     = 0xb,
+	MLX5_ACTION_IN_FIELD_OUT_UDP_DPORT     = 0xc,
+	MLX5_ACTION_IN_FIELD_OUT_SIPV6_127_96  = 0xd,
+	MLX5_ACTION_IN_FIELD_OUT_SIPV6_95_64   = 0xe,
+	MLX5_ACTION_IN_FIELD_OUT_SIPV6_63_32   = 0xf,
+	MLX5_ACTION_IN_FIELD_OUT_SIPV6_31_0    = 0x10,
+	MLX5_ACTION_IN_FIELD_OUT_DIPV6_127_96  = 0x11,
+	MLX5_ACTION_IN_FIELD_OUT_DIPV6_95_64   = 0x12,
+	MLX5_ACTION_IN_FIELD_OUT_DIPV6_63_32   = 0x13,
+	MLX5_ACTION_IN_FIELD_OUT_DIPV6_31_0    = 0x14,
+	MLX5_ACTION_IN_FIELD_OUT_SIPV4         = 0x15,
+	MLX5_ACTION_IN_FIELD_OUT_DIPV4         = 0x16,
+};
+
+struct mlx5_ifc_alloc_modify_header_context_out_bits {
+	u8         status[0x8];
+	u8         reserved_at_8[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         modify_header_id[0x20];
+
+	u8         reserved_at_60[0x20];
+};
+
+struct mlx5_ifc_alloc_modify_header_context_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_at_10[0x10];
+
+	u8         reserved_at_20[0x10];
+	u8         op_mod[0x10];
+
+	u8         reserved_at_40[0x20];
+
+	u8         table_type[0x8];
+	u8         reserved_at_68[0x10];
+	u8         num_of_actions[0x8];
+
+	union mlx5_ifc_set_action_in_add_action_in_auto_bits actions[0];
+};
+
+struct mlx5_ifc_dealloc_modify_header_context_out_bits {
+	u8         status[0x8];
+	u8         reserved_at_8[0x18];
+
+	u8         syndrome[0x20];
+
+	u8         reserved_at_40[0x40];
+};
+
+struct mlx5_ifc_dealloc_modify_header_context_in_bits {
+	u8         opcode[0x10];
+	u8         reserved_at_10[0x10];
+
+	u8         reserved_at_20[0x10];
+	u8         op_mod[0x10];
+
+	u8         modify_header_id[0x20];
+
+	u8         reserved_at_60[0x20];
+};
+
 struct mlx5_ifc_query_dct_out_bits {
 	u8         status[0x8];
 	u8         reserved_at_8[0x18];
-- 
2.11.0
