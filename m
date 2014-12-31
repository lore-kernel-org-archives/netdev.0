From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v1 06/11] net: rocker: add group_id slices and drop
 explicit goto
Date: Wed, 31 Dec 2014 11:48:03 -0800
Message-ID: <20141231194801.31070.34363.stgit@nitbit.x32>
References: <20141231194057.31070.5244.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net
To: tgraf@suug.ch, sfeldma@gmail.com, jiri@resnulli.us,
	jhs@mojatatu.com, simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:56282 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751337AbaLaTsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 14:48:22 -0500
Received: by mail-ob0-f175.google.com with SMTP id wp4so49357750obc.6
        for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 11:48:22 -0800 (PST)
In-Reply-To: <20141231194057.31070.5244.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds the group tables for l3_unicast, l2_rewrite and l2. In
addition to adding the tables we extend the metadata fields to
support three different group id lookups. One for each table and
drop the more generic one previously being used.

Finally we can also drop the goto action as it is not used anymore.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/ethernet/rocker/rocker.c          |  192 +++++++++++++++++++-
 drivers/net/ethernet/rocker/rocker_pipeline.h |  235 ++++++++++++++++++-------
 2 files changed, 355 insertions(+), 72 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index c40c58d..8ce9933 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3964,9 +3964,6 @@ static int rocker_flow_set_vlan(struct net_device *dev,
 		struct net_flow_action_arg *arg = &flow->actions[i].args[0];
 
 		switch (flow->actions[i].uid) {
-		case ACTION_SET_GOTO_TABLE:
-			goto_tbl = rocker_goto_value(arg->value_u16);
-			break;
 		case ACTION_SET_VLAN_ID:
 			new_vlan_id = htons(arg->value_u16);
 			if (new_vlan_id)
@@ -4147,14 +4144,11 @@ static int rocker_flow_set_bridge(struct net_device *dev,
 		struct net_flow_action_arg *arg = &flow->actions[i].args[0];
 
 		switch (flow->actions[i].uid) {
-		case ACTION_SET_GOTO_TABLE:
-			goto_tbl = rocker_goto_value(arg->value_u16);
-			break;
 		case ACTION_COPY_TO_CPU:
 			copy_to_cpu = true;
 			break;
-		case ACTION_SET_GROUP_ID:
-			group_id = arg->value_u32;
+		case ACTION_SET_L3_UNICAST_GROUP_ID:
+			group_id = ROCKER_GROUP_L3_UNICAST(arg->value_u32);
 			break;
 		default:
 			return -EINVAL;
@@ -4258,9 +4252,11 @@ static int rocker_flow_set_acl(struct net_device *dev,
 	group_id = ROCKER_GROUP_NONE;
 
 	for (i = 0; flow->actions && flow->actions[i].uid; i++) {
+		struct net_flow_action_arg *arg = &flow->actions[i].args[0];
+
 		switch (flow->actions[i].uid) {
-		case ACTION_SET_GROUP_ID:
-			group_id = flow->actions[i].args[0].value_u32;
+		case ACTION_SET_L3_UNICAST_GROUP_ID:
+			group_id = ROCKER_GROUP_L3_UNICAST(arg->value_u32);
 			break;
 		default:
 			return -EINVAL;
@@ -4278,6 +4274,173 @@ static int rocker_flow_set_acl(struct net_device *dev,
 	return err;
 }
 
+static int rocker_flow_set_group_slice_l3_unicast(struct net_device *dev,
+						  struct net_flow_flow *flow)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	struct rocker_group_tbl_entry *entry;
+	int i, flags = 0, err = 0;
+
+	err = is_valid_net_flow(&group_slice_l3_unicast_table, flow);
+	if (err)
+		return err;
+
+	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	if (!entry)
+		return -ENOMEM;
+
+	for (i = 0; flow->matches && flow->matches[i].instance; i++) {
+		struct net_flow_field_ref *r = &flow->matches[i];
+
+		switch (r->instance) {
+		case HEADER_INSTANCE_L3_UNICAST_GROUP_ID:
+			entry->group_id = ROCKER_GROUP_L3_UNICAST(r->value_u32);
+			break;
+		default:
+			return -EINVAL;
+		}
+	}
+
+	for (i = 0; flow->actions && flow->actions[i].uid; i++) {
+		struct net_flow_action_arg *arg = &flow->actions[i].args[0];
+
+		switch (flow->actions[i].uid) {
+		case ACTION_SET_ETH_SRC:
+			ether_addr_copy(entry->l3_unicast.eth_src,
+					(u8 *)&arg->value_u64);
+			break;
+		case ACTION_SET_ETH_DST:
+			ether_addr_copy(entry->l3_unicast.eth_dst,
+					(u8 *)&arg->value_u64);
+			break;
+		case ACTION_SET_VLAN_ID:
+			entry->l3_unicast.vlan_id = htons(arg->value_u16);
+			break;
+		case ACTION_CHECK_TTL_DROP:
+			entry->l3_unicast.ttl_check = true;
+			break;
+		case ACTION_SET_L2_REWRITE_GROUP_ID:
+			entry->l3_unicast.group_id =
+				ROCKER_GROUP_L2_REWRITE(arg->value_u32);
+			break;
+		default:
+			return -EINVAL;
+		}
+	}
+
+	return rocker_group_tbl_do(rocker_port, flags, entry);
+}
+
+static int rocker_flow_set_group_slice_l2_rewrite(struct net_device *dev,
+						  struct net_flow_flow *flow)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	struct rocker_group_tbl_entry *entry;
+	int i, flags = 0, err = 0;
+
+	err = is_valid_net_flow(&group_slice_l2_rewrite_table, flow);
+	if (err)
+		return err;
+
+	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	if (!entry)
+		return -ENOMEM;
+
+	for (i = 0; flow->matches && flow->matches[i].instance; i++) {
+		struct net_flow_field_ref *r = &flow->matches[i];
+
+		switch (r->instance) {
+		case HEADER_INSTANCE_L2_REWRITE_GROUP_ID:
+			entry->group_id = ROCKER_GROUP_L2_REWRITE(r->value_u32);
+			break;
+		default:
+			return -EINVAL;
+		}
+	}
+
+	for (i = 0; flow->actions && flow->actions[i].uid; i++) {
+		struct net_flow_action_arg *arg = &flow->actions[i].args[0];
+
+		switch (flow->actions[i].uid) {
+		case ACTION_SET_ETH_SRC:
+			ether_addr_copy(entry->l2_rewrite.eth_src,
+					(u8 *)&arg->value_u64);
+			break;
+		case ACTION_SET_ETH_DST:
+			ether_addr_copy(entry->l2_rewrite.eth_dst,
+					(u8 *)&arg->value_u64);
+			break;
+		case ACTION_SET_VLAN_ID:
+			entry->l2_rewrite.vlan_id = htons(arg->value_u16);
+			break;
+		case ACTION_SET_L2_GROUP_ID:
+			entry->l2_rewrite.group_id =
+				ROCKER_GROUP_L2_INTERFACE(arg->value_u32,
+							  rocker_port->lport);
+			break;
+		default:
+			return -EINVAL;
+		}
+	}
+
+	return rocker_group_tbl_do(rocker_port, flags, entry);
+}
+
+static int rocker_flow_set_group_slice_l2(struct net_device *dev,
+					  struct net_flow_flow *flow)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	struct rocker_group_tbl_entry *entry;
+	int i, flags = 0, err = 0;
+	u32 lport;
+
+	err = is_valid_net_flow(&group_slice_l2_table, flow);
+	if (err)
+		return err;
+
+	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	if (!entry)
+		return -ENOMEM;
+
+	lport = rocker_port->lport;
+
+	/* Use the dev lport if we don't have a specified lport instance
+	 * from the user. We need to walk the list once before to extract
+	 * any lport attribute.
+	 */
+	for (i = 0; flow->matches && flow->matches[i].instance; i++) {
+		switch (flow->matches[i].instance) {
+		case HEADER_METADATA_IN_LPORT:
+			lport = flow->matches[i].value_u32;
+		}
+	}
+
+	for (i = 0; flow->matches && flow->matches[i].instance; i++) {
+		struct net_flow_field_ref *r = &flow->matches[i];
+
+		switch (r->instance) {
+		case HEADER_INSTANCE_L2_GROUP_ID:
+			entry->group_id =
+				ROCKER_GROUP_L2_INTERFACE(r->value_u32, lport);
+			break;
+		default:
+			return -EINVAL;
+		}
+	}
+
+	for (i = 0; flow->actions && flow->actions[i].uid; i++) {
+		switch (flow->actions[i].uid) {
+		case ACTION_POP_VLAN:
+			entry->l2_interface.pop_vlan = true;
+			break;
+		default:
+			return -EINVAL;
+		}
+	}
+
+	return rocker_group_tbl_do(rocker_port, flags, entry);
+}
+
 static int rocker_set_flows(struct net_device *dev,
 			    struct net_flow_flow *flow)
 {
@@ -4308,6 +4471,15 @@ static int rocker_set_flows(struct net_device *dev,
 	case ROCKER_FLOW_TABLE_ID_ACL_POLICY:
 		err = rocker_flow_set_acl(dev, flow);
 		break;
+	case ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L3_UNICAST:
+		err = rocker_flow_set_group_slice_l3_unicast(dev, flow);
+		break;
+	case ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L2_REWRITE:
+		err = rocker_flow_set_group_slice_l2_rewrite(dev, flow);
+		break;
+	case ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L2:
+		err = rocker_flow_set_group_slice_l2(dev, flow);
+		break;
 	default:
 		break;
 	}
diff --git a/drivers/net/ethernet/rocker/rocker_pipeline.h b/drivers/net/ethernet/rocker/rocker_pipeline.h
index 701e139..7e689c0 100644
--- a/drivers/net/ethernet/rocker/rocker_pipeline.h
+++ b/drivers/net/ethernet/rocker/rocker_pipeline.h
@@ -111,16 +111,21 @@ struct net_flow_header ipv4 = {
 
 #define HEADER_METADATA_IN_LPORT 1
 #define HEADER_METADATA_GOTO_TBL 2
-#define HEADER_METADATA_GROUP_ID 3
-struct net_flow_field metadata_fields[3] = {
+#define HEADER_METADATA_L3_UNICAST_GROUP_ID	3
+#define HEADER_METADATA_L2_REWRITE_GROUP_ID	4
+#define HEADER_METADATA_L2_GROUP_ID		5
+struct net_flow_field metadata_fields[5] = {
 	{ .name = "in_lport",
 	  .uid = HEADER_METADATA_IN_LPORT,
 	  .bitwidth = 32,},
-	{ .name = "goto_tbl",
-	  .uid = HEADER_METADATA_GOTO_TBL,
-	  .bitwidth = 16,},
-	{ .name = "group_id",
-	  .uid = HEADER_METADATA_GROUP_ID,
+	{ .name = "l3_unicast_group_id",
+	  .uid = HEADER_METADATA_L3_UNICAST_GROUP_ID,
+	  .bitwidth = 32,},
+	{ .name = "l2_rewrite_group_id",
+	  .uid = HEADER_METADATA_L2_REWRITE_GROUP_ID,
+	  .bitwidth = 32,},
+	{ .name = "l2_group_id",
+	  .uid = HEADER_METADATA_L2_GROUP_ID,
 	  .bitwidth = 32,},
 };
 
@@ -128,7 +133,7 @@ struct net_flow_field metadata_fields[3] = {
 struct net_flow_header metadata_t = {
 	.name = "metadata_t",
 	.uid = HEADER_METADATA,
-	.field_sz = 3,
+	.field_sz = 5,
 	.fields = metadata_fields,
 };
 
@@ -157,25 +162,6 @@ struct net_flow_action null_action = {
 	.name = "", .uid = 0, .args = NULL,
 };
 
-struct net_flow_action_arg set_goto_table_args[2] = {
-	{
-		.name = "table",
-		.type = NET_FLOW_ACTION_ARG_TYPE_U16,
-		.value_u16 = 0,
-	},
-	{
-		.name = "",
-		.type = NET_FLOW_ACTION_ARG_TYPE_NULL,
-	},
-};
-
-#define ACTION_SET_GOTO_TABLE 1
-struct net_flow_action set_goto_table = {
-	.name = "set_goto_table",
-	.uid = ACTION_SET_GOTO_TABLE,
-	.args = set_goto_table_args,
-};
-
 struct net_flow_action_arg set_vlan_id_args[2] = {
 	{
 		.name = "vlan_id",
@@ -188,7 +174,7 @@ struct net_flow_action_arg set_vlan_id_args[2] = {
 	},
 };
 
-#define ACTION_SET_VLAN_ID 2
+#define ACTION_SET_VLAN_ID 1
 struct net_flow_action set_vlan_id = {
 	.name = "set_vlan_id",
 	.uid = ACTION_SET_VLAN_ID,
@@ -196,7 +182,7 @@ struct net_flow_action set_vlan_id = {
 };
 
 /* TBD: what is the untagged bool about in vlan table */
-#define ACTION_COPY_TO_CPU 3
+#define ACTION_COPY_TO_CPU 2
 struct net_flow_action copy_to_cpu = {
 	.name = "copy_to_cpu",
 	.uid = ACTION_COPY_TO_CPU,
@@ -215,14 +201,28 @@ struct net_flow_action_arg set_group_id_args[2] = {
 	},
 };
 
-#define ACTION_SET_GROUP_ID 4
-struct net_flow_action set_group_id = {
-	.name = "set_group_id",
-	.uid = ACTION_SET_GROUP_ID,
+#define ACTION_SET_L3_UNICAST_GROUP_ID 3
+struct net_flow_action set_l3_unicast_group_id = {
+	.name = "set_l3_unicast_group_id",
+	.uid = ACTION_SET_L3_UNICAST_GROUP_ID,
 	.args = set_group_id_args,
 };
 
-#define ACTION_POP_VLAN 5
+#define ACTION_SET_L2_REWRITE_GROUP_ID 4
+struct net_flow_action set_l2_rewrite_group_id = {
+	.name = "set_l2_rewrite_group_id",
+	.uid = ACTION_SET_L2_REWRITE_GROUP_ID,
+	.args = set_group_id_args,
+};
+
+#define ACTION_SET_L2_GROUP_ID 5
+struct net_flow_action set_l2_group_id = {
+	.name = "set_l2_group_id",
+	.uid = ACTION_SET_L2_GROUP_ID,
+	.args = set_group_id_args,
+};
+
+#define ACTION_POP_VLAN 6
 struct net_flow_action pop_vlan = {
 	.name = "pop_vlan",
 	.uid = ACTION_POP_VLAN,
@@ -241,7 +241,7 @@ struct net_flow_action_arg set_eth_src_args[2] = {
 	},
 };
 
-#define ACTION_SET_ETH_SRC 6
+#define ACTION_SET_ETH_SRC 7
 struct net_flow_action set_eth_src = {
 	.name = "set_eth_src",
 	.uid = ACTION_SET_ETH_SRC,
@@ -260,7 +260,7 @@ struct net_flow_action_arg set_eth_dst_args[2] = {
 	},
 };
 
-#define ACTION_SET_ETH_DST 7
+#define ACTION_SET_ETH_DST 8
 struct net_flow_action set_eth_dst = {
 	.name = "set_eth_dst",
 	.uid = ACTION_SET_ETH_DST,
@@ -279,21 +279,30 @@ struct net_flow_action_arg set_out_port_args[2] = {
 	},
 };
 
-#define ACTION_SET_OUT_PORT 8
+#define ACTION_SET_OUT_PORT 9
 struct net_flow_action set_out_port = {
 	.name = "set_out_port",
 	.uid = ACTION_SET_OUT_PORT,
 	.args = set_out_port_args,
 };
 
-struct net_flow_action *rocker_action_list[8] = {
-	&set_goto_table,
+#define ACTION_CHECK_TTL_DROP 10
+struct net_flow_action check_ttl_drop = {
+	.name = "check_ttl_drop",
+	.uid = ACTION_CHECK_TTL_DROP,
+	.args = null_args,
+};
+
+struct net_flow_action *rocker_action_list[10] = {
 	&set_vlan_id,
 	&copy_to_cpu,
-	&set_group_id,
+	&set_l3_unicast_group_id,
+	&set_l2_rewrite_group_id,
+	&set_l2_group_id,
 	&pop_vlan,
 	&set_eth_src,
 	&set_eth_dst,
+	&check_ttl_drop,
 	&null_action,
 };
 
@@ -302,8 +311,9 @@ struct net_flow_action *rocker_action_list[8] = {
 #define HEADER_INSTANCE_VLAN_OUTER 2
 #define HEADER_INSTANCE_IPV4 3
 #define HEADER_INSTANCE_IN_LPORT 4
-#define HEADER_INSTANCE_GOTO_TABLE 5
-#define HEADER_INSTANCE_GROUP_ID 6
+#define HEADER_INSTANCE_L3_UNICAST_GROUP_ID 5
+#define HEADER_INSTANCE_L2_REWRITE_GROUP_ID 6
+#define HEADER_INSTANCE_L2_GROUP_ID 7
 
 struct net_flow_jump_table parse_ethernet[3] = {
 	{
@@ -390,29 +400,37 @@ struct net_flow_hdr_node in_lport_header_node = {
 	.jump = terminal_headers,
 };
 
-struct net_flow_hdr_node goto_table_header_node = {
-	.name = "goto_table",
-	.uid = HEADER_INSTANCE_GOTO_TABLE,
+struct net_flow_hdr_node l2_group_id_header_node = {
+	.name = "l2_group_id",
+	.uid = HEADER_INSTANCE_L2_GROUP_ID,
+	.hdrs = metadata_headers,
+	.jump = terminal_headers,
+};
+
+struct net_flow_hdr_node l2_rewrite_group_id_header_node = {
+	.name = "l2_rewrite_group_id",
+	.uid = HEADER_INSTANCE_L2_REWRITE_GROUP_ID,
 	.hdrs = metadata_headers,
 	.jump = terminal_headers,
 };
 
-struct net_flow_hdr_node group_id_header_node = {
-	.name = "group_id",
-	.uid = HEADER_INSTANCE_GROUP_ID,
+struct net_flow_hdr_node l3_unicast_group_id_header_node = {
+	.name = "l3_uniscast_group_id",
+	.uid = HEADER_INSTANCE_L3_UNICAST_GROUP_ID,
 	.hdrs = metadata_headers,
 	.jump = terminal_headers,
 };
 
 struct net_flow_hdr_node null_header = {.name = "", .uid = 0,};
 
-struct net_flow_hdr_node *rocker_header_nodes[7] = {
+struct net_flow_hdr_node *rocker_header_nodes[] = {
 	&ethernet_header_node,
 	&vlan_header_node,
 	&ipv4_header_node,
 	&in_lport_header_node,
-	&goto_table_header_node,
-	&group_id_header_node,
+	&l3_unicast_group_id_header_node,
+	&l2_rewrite_group_id_header_node,
+	&l2_group_id_header_node,
 	&null_header,
 };
 
@@ -513,14 +531,46 @@ struct net_flow_field_ref matches_acl[8] = {
 	{ .instance = 0, .field = 0},
 };
 
-int actions_ig_port[2] = {ACTION_SET_GOTO_TABLE, 0};
-int actions_vlan[3] = {ACTION_SET_GOTO_TABLE, ACTION_SET_VLAN_ID, 0};
-int actions_term_mac[3] = {ACTION_SET_GOTO_TABLE, ACTION_COPY_TO_CPU, 0};
-int actions_ucast_routing[3] = {ACTION_SET_GOTO_TABLE, ACTION_SET_GROUP_ID, 0};
-int actions_bridge[4] = {ACTION_SET_GOTO_TABLE,
-			 ACTION_SET_GROUP_ID,
-			 ACTION_COPY_TO_CPU, 0};
-int actions_acl[2] = {ACTION_SET_GROUP_ID, 0};
+struct net_flow_field_ref matches_l3_unicast_group_slice[2] = {
+	{ .instance = HEADER_INSTANCE_L3_UNICAST_GROUP_ID,
+	  .header = HEADER_METADATA,
+	  .field = HEADER_METADATA_L3_UNICAST_GROUP_ID,
+	  .mask_type = NET_FLOW_MASK_TYPE_EXACT},
+	{ .instance = 0, .field = 0},
+};
+
+struct net_flow_field_ref matches_l2_rewrite_group_slice[2] = {
+	{ .instance = HEADER_INSTANCE_L2_REWRITE_GROUP_ID,
+	  .header = HEADER_METADATA,
+	  .field = HEADER_METADATA_L2_REWRITE_GROUP_ID,
+	  .mask_type = NET_FLOW_MASK_TYPE_EXACT},
+	{ .instance = 0, .field = 0},
+};
+
+struct net_flow_field_ref matches_l2_group_slice[2] = {
+	{ .instance = HEADER_INSTANCE_L2_GROUP_ID,
+	  .header = HEADER_METADATA,
+	  .field = HEADER_METADATA_L2_GROUP_ID,
+	  .mask_type = NET_FLOW_MASK_TYPE_EXACT},
+	{ .instance = 0, .field = 0},
+};
+
+int actions_ig_port[] = {0};
+int actions_vlan[] = {ACTION_SET_VLAN_ID, 0};
+int actions_term_mac[] = {ACTION_COPY_TO_CPU, 0};
+int actions_ucast_routing[] = {ACTION_SET_L3_UNICAST_GROUP_ID, 0};
+int actions_bridge[] = {ACTION_SET_L2_GROUP_ID, ACTION_COPY_TO_CPU, 0};
+int actions_acl[] = {ACTION_SET_L3_UNICAST_GROUP_ID, 0};
+int actions_group_slice_l3_unicast[] = {ACTION_SET_ETH_SRC,
+					ACTION_SET_ETH_DST,
+					ACTION_SET_VLAN_ID,
+					ACTION_SET_L2_REWRITE_GROUP_ID,
+					ACTION_CHECK_TTL_DROP, 0};
+int actions_group_slice_l2_rewrite[] = {ACTION_SET_ETH_SRC,
+					ACTION_SET_ETH_DST,
+					ACTION_SET_VLAN_ID,
+					ACTION_SET_L2_GROUP_ID, 0};
+int actions_group_slice_l2[] = {ACTION_POP_VLAN, 0};
 
 enum rocker_flow_table_id_space {
 	ROCKER_FLOW_TABLE_ID_INGRESS_PORT = 1,
@@ -530,6 +580,9 @@ enum rocker_flow_table_id_space {
 	ROCKER_FLOW_TABLE_ID_MULTICAST_ROUTING,
 	ROCKER_FLOW_TABLE_ID_BRIDGING,
 	ROCKER_FLOW_TABLE_ID_ACL_POLICY,
+	ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L3_UNICAST,
+	ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L2_REWRITE,
+	ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L2,
 	ROCKER_FLOW_TABLE_NULL = 0,
 };
 
@@ -587,6 +640,33 @@ struct net_flow_table acl_table = {
 	.actions = actions_acl,
 };
 
+struct net_flow_table group_slice_l3_unicast_table = {
+	.name = "group_slice_l3_unicast",
+	.uid = ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L3_UNICAST,
+	.source = 1,
+	.size = -1,
+	.matches = matches_l3_unicast_group_slice,
+	.actions = actions_group_slice_l3_unicast,
+};
+
+struct net_flow_table group_slice_l2_rewrite_table = {
+	.name = "group_slice_l2_rewrite",
+	.uid = ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L2_REWRITE,
+	.source = 1,
+	.size = -1,
+	.matches = matches_l2_rewrite_group_slice,
+	.actions = actions_group_slice_l2_rewrite,
+};
+
+struct net_flow_table group_slice_l2_table = {
+	.name = "group_slice_l2",
+	.uid = ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L2,
+	.source = 1,
+	.size = -1,
+	.matches = matches_l2_group_slice,
+	.actions = actions_group_slice_l2,
+};
+
 struct net_flow_table null_table = {
 	.name = "",
 	.uid = ROCKER_FLOW_TABLE_NULL,
@@ -596,13 +676,16 @@ struct net_flow_table null_table = {
 	.actions = NULL,
 };
 
-struct net_flow_table *rocker_table_list[7] = {
+struct net_flow_table *rocker_table_list[10] = {
 	&ingress_port_table,
 	&vlan_table,
 	&term_mac_table,
 	&ucast_routing_table,
 	&bridge_table,
 	&acl_table,
+	&group_slice_l3_unicast_table,
+	&group_slice_l2_rewrite_table,
+	&group_slice_l2_table,
 	&null_table,
 };
 
@@ -652,7 +735,8 @@ struct net_flow_tbl_node table_node_ucast_routing = {
 	.uid = ROCKER_FLOW_TABLE_ID_UNICAST_ROUTING,
 	.jump = table_node_ucast_routing_next};
 
-struct net_flow_jump_table table_node_acl_next[1] = {
+struct net_flow_jump_table table_node_acl_next[2] = {
+	{ .field = {0}, .node = ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L3_UNICAST},
 	{ .field = {0}, .node = 0},
 };
 
@@ -660,15 +744,42 @@ struct net_flow_tbl_node table_node_acl = {
 	.uid = ROCKER_FLOW_TABLE_ID_ACL_POLICY,
 	.jump = table_node_acl_next};
 
+struct net_flow_jump_table table_node_group_l3_unicast_next[1] = {
+	{ .field = {0}, .node = ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L2_REWRITE},
+};
+
+struct net_flow_tbl_node table_node_group_l3_unicast = {
+	.uid = ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L3_UNICAST,
+	.jump = table_node_group_l3_unicast_next};
+
+struct net_flow_jump_table table_node_group_l2_rewrite_next[1] = {
+	{ .field = {0}, .node = ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L2},
+};
+
+struct net_flow_tbl_node table_node_group_l2_rewrite = {
+	.uid = ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L2_REWRITE,
+	.jump = table_node_group_l2_rewrite_next};
+
+struct net_flow_jump_table table_node_group_l2_next[1] = {
+	{ .field = {0}, .node = 0},
+};
+
+struct net_flow_tbl_node table_node_group_l2 = {
+	.uid = ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L2,
+	.jump = table_node_group_l2_next};
+
 struct net_flow_tbl_node table_node_nil = {.uid = 0, .jump = NULL};
 
-struct net_flow_tbl_node *rocker_table_nodes[7] = {
+struct net_flow_tbl_node *rocker_table_nodes[10] = {
 	&table_node_ingress_port,
 	&table_node_vlan,
 	&table_node_term_mac,
 	&table_node_ucast_routing,
 	&table_node_bridge,
 	&table_node_acl,
+	&table_node_group_l3_unicast,
+	&table_node_group_l2_rewrite,
+	&table_node_group_l2,
 	&table_node_nil,
 };
 #endif /*_MY_PIPELINE_H*/
