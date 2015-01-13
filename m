From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2 08/12] net: rocker: add group_id slices and drop
 explicit goto
Date: Tue, 13 Jan 2015 13:38:30 -0800
Message-ID: <20150113213828.13874.82883.stgit@nitbit.x32>
References: <20150113212941.13874.48692.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gerlitz.or@gmail.com, jhs@mojatatu.com,
	andy@greyhouse.net, davem@davemloft.net
To: tgraf@suug.ch, simon.horman@netronome.com, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:41478 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751974AbbAMViv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 16:38:51 -0500
Received: by mail-ob0-f169.google.com with SMTP id vb8so4900859obc.0
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 13:38:50 -0800 (PST)
In-Reply-To: <20150113212941.13874.48692.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds the group tables for l3_unicast, l2_rewrite and l2. In
addition to adding the tables we extend the metadata fields to
support three different group id lookups. One for each table and
drop the more generic one previously being used.

Finally we can also drop the goto action as it is not used anymore.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/ethernet/rocker/rocker.c          |  174 ++++++++++++++++++++++++
 drivers/net/ethernet/rocker/rocker_pipeline.h |  180 ++++++++++++++++++++++---
 2 files changed, 328 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 08efd8b..de4c58e 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4088,8 +4088,8 @@ static int rocker_flow_set_bridge(struct net_device *dev,
 		case ACTION_COPY_TO_CPU:
 			copy_to_cpu = true;
 			break;
-		case ROCKER_ACTION_SET_GROUP_ID:
-			group_id = arg->value_u32;
+		case ROCKER_ACTION_SET_L3_UNICAST_GID:
+			group_id = ROCKER_GROUP_L3_UNICAST(arg->value_u32);
 			break;
 		default:
 			return -EINVAL;
@@ -4188,9 +4188,11 @@ static int rocker_flow_set_acl(struct net_device *dev,
 	group_id = ROCKER_GROUP_NONE;
 
 	for (i = 0; flow->actions && flow->actions[i].uid; i++) {
+		struct net_flow_action_arg *arg = &flow->actions[i].args[0];
+
 		switch (flow->actions[i].uid) {
-		case ROCKER_ACTION_SET_GROUP_ID:
-			group_id = flow->actions[i].args[0].value_u32;
+		case ROCKER_ACTION_SET_L3_UNICAST_GID:
+			group_id = ROCKER_GROUP_L3_UNICAST(arg->value_u32);
 			break;
 		default:
 			return -EINVAL;
@@ -4207,6 +4209,161 @@ static int rocker_flow_set_acl(struct net_device *dev,
 				   group_id);
 }
 
+static int rocker_flow_set_group_slice_l3_unicast(struct net_device *dev,
+						  struct net_flow_rule *flow)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	struct rocker_group_tbl_entry *entry;
+	int i, flags = 0;
+
+	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	if (!entry)
+		return -ENOMEM;
+
+	for (i = 0; flow->matches && flow->matches[i].instance; i++) {
+		struct net_flow_field_ref *r = &flow->matches[i];
+
+		switch (r->instance) {
+		case ROCKER_HEADER_INSTANCE_L3_UNICAST_GID:
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
+		case ROCKER_ACTION_SET_L2_REWRITE_GID:
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
+						  struct net_flow_rule *flow)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	struct rocker_group_tbl_entry *entry;
+	int i, flags = 0;
+
+	entry = kzalloc(sizeof(*entry), rocker_op_flags_gfp(flags));
+	if (!entry)
+		return -ENOMEM;
+
+	for (i = 0; flow->matches && flow->matches[i].instance; i++) {
+		struct net_flow_field_ref *r = &flow->matches[i];
+
+		switch (r->instance) {
+		case ROCKER_HEADER_INSTANCE_L2_REWRITE_GID:
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
+		case ROCKER_ACTION_SET_L2_GID:
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
+					  struct net_flow_rule *flow)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	struct rocker_group_tbl_entry *entry;
+	int i, flags = 0;
+	u32 lport;
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
+		case ROCKER_HEADER_METADATA_IN_LPORT:
+			lport = flow->matches[i].value_u32;
+		}
+	}
+
+	for (i = 0; flow->matches && flow->matches[i].instance; i++) {
+		struct net_flow_field_ref *r = &flow->matches[i];
+
+		switch (r->instance) {
+		case ROCKER_HEADER_INSTANCE_L2_GID:
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
 			    struct net_flow_rule *flow)
 {
@@ -4237,6 +4394,15 @@ static int rocker_set_flows(struct net_device *dev,
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
index 7136380..6d1e2ee 100644
--- a/drivers/net/ethernet/rocker/rocker_pipeline.h
+++ b/drivers/net/ethernet/rocker/rocker_pipeline.h
@@ -22,19 +22,23 @@ enum rocker_header_ids {
 enum rocker_header_metadata_fields {
 	ROCKER_HEADER_METADATA_UNSPEC,
 	ROCKER_HEADER_METADATA_IN_LPORT,
-	ROCKER_HEADER_METADATA_GOTO_TBL,
-	ROCKER_HEADER_METADATA_GROUP_ID,
+	ROCKER_HEADER_METADATA_L3_UNICAST_GID,
+	ROCKER_HEADER_METADATA_L2_REWRITE_GID,
+	ROCKER_HEADER_METADATA_L2_GID,
 };
 
 struct net_flow_field rocker_metadata_fields[] = {
 	{ .name = "in_lport",
 	  .uid = ROCKER_HEADER_METADATA_IN_LPORT,
 	  .bitwidth = 32,},
-	{ .name = "goto_tbl",
-	  .uid = ROCKER_HEADER_METADATA_GOTO_TBL,
-	  .bitwidth = 16,},
-	{ .name = "group_id",
-	  .uid = ROCKER_HEADER_METADATA_GROUP_ID,
+	{ .name = "l3_unicast_group_id",
+	  .uid = ROCKER_HEADER_METADATA_L3_UNICAST_GID,
+	  .bitwidth = 32,},
+	{ .name = "l2_rewrite_group_id",
+	  .uid = ROCKER_HEADER_METADATA_L2_REWRITE_GID,
+	  .bitwidth = 32,},
+	{ .name = "l2_group_id",
+	  .uid = ROCKER_HEADER_METADATA_L2_GID,
 	  .bitwidth = 32,},
 };
 
@@ -68,22 +72,39 @@ struct net_flow_action_arg rocker_set_group_id_args[] = {
 
 enum rocker_action_ids {
 	ROCKER_ACTION_UNSPEC = ACTION_MAX_UID,
-	ROCKER_ACTION_SET_GROUP_ID,
+	ROCKER_ACTION_SET_L3_UNICAST_GID,
+	ROCKER_ACTION_SET_L2_REWRITE_GID,
+	ROCKER_ACTION_SET_L2_GID,
+};
+
+struct net_flow_action rocker_set_l3_unicast_group_id = {
+	.name = "set_l3_unicast_group_id",
+	.uid = ROCKER_ACTION_SET_L3_UNICAST_GID,
+	.args = rocker_set_group_id_args,
+};
+
+struct net_flow_action rocker_set_l2_rewrite_group_id = {
+	.name = "set_l2_rewrite_group_id",
+	.uid = ROCKER_ACTION_SET_L2_REWRITE_GID,
+	.args = rocker_set_group_id_args,
 };
 
-struct net_flow_action rocker_set_group_id = {
-	.name = "set_group_id",
-	.uid = ROCKER_ACTION_SET_GROUP_ID,
+struct net_flow_action rocker_set_l2_group_id = {
+	.name = "set_l2_group_id",
+	.uid = ROCKER_ACTION_SET_L2_GID,
 	.args = rocker_set_group_id_args,
 };
 
 struct net_flow_action *rocker_action_list[] = {
 	&net_flow_set_vlan_id,
 	&net_flow_copy_to_cpu,
-	&rocker_set_group_id,
+	&rocker_set_l3_unicast_group_id,
+	&rocker_set_l2_rewrite_group_id,
+	&rocker_set_l2_group_id,
 	&net_flow_pop_vlan,
 	&net_flow_set_eth_src,
 	&net_flow_set_eth_dst,
+	&net_flow_check_ttl_drop,
 	NULL,
 };
 
@@ -94,8 +115,9 @@ enum rocker_header_instance_ids {
 	ROCKER_HEADER_INSTANCE_VLAN_OUTER,
 	ROCKER_HEADER_INSTANCE_IPV4,
 	ROCKER_HEADER_INSTANCE_IN_LPORT,
-	ROCKER_HEADER_INSTANCE_GOTO_TABLE,
-	ROCKER_HEADER_INSTANCE_GROUP_ID,
+	ROCKER_HEADER_INSTANCE_L3_UNICAST_GID,
+	ROCKER_HEADER_INSTANCE_L2_REWRITE_GID,
+	ROCKER_HEADER_INSTANCE_L2_GID,
 };
 
 struct net_flow_jump_table rocker_parse_ethernet[] = {
@@ -183,9 +205,23 @@ struct net_flow_hdr_node rocker_in_lport_header_node = {
 	.jump = rocker_terminal_headers,
 };
 
-struct net_flow_hdr_node rocker_group_id_header_node = {
-	.name = "group_id",
-	.uid = ROCKER_HEADER_INSTANCE_GROUP_ID,
+struct net_flow_hdr_node rocker_l2_group_id_header_node = {
+	.name = "l2_group_id",
+	.uid = ROCKER_HEADER_INSTANCE_L2_GID,
+	.hdrs = rocker_metadata_headers,
+	.jump = rocker_terminal_headers,
+};
+
+struct net_flow_hdr_node rocker_l2_rewrite_group_id_header_node = {
+	.name = "l2_rewrite_group_id",
+	.uid = ROCKER_HEADER_INSTANCE_L2_REWRITE_GID,
+	.hdrs = rocker_metadata_headers,
+	.jump = rocker_terminal_headers,
+};
+
+struct net_flow_hdr_node rocker_l3_unicast_group_id_header_node = {
+	.name = "l3_uniscast_group_id",
+	.uid = ROCKER_HEADER_INSTANCE_L3_UNICAST_GID,
 	.hdrs = rocker_metadata_headers,
 	.jump = rocker_terminal_headers,
 };
@@ -195,7 +231,9 @@ struct net_flow_hdr_node *rocker_header_nodes[] = {
 	&rocker_vlan_header_node,
 	&rocker_ipv4_header_node,
 	&rocker_in_lport_header_node,
-	&rocker_group_id_header_node,
+	&rocker_l3_unicast_group_id_header_node,
+	&rocker_l2_rewrite_group_id_header_node,
+	&rocker_l2_group_id_header_node,
 	NULL,
 };
 
@@ -296,13 +334,48 @@ struct net_flow_field_ref rocker_matches_acl[] = {
 	{ .instance = 0, .field = 0},
 };
 
+struct net_flow_field_ref rocker_matches_l3_unicast_group_slice[2] = {
+	{ .instance = ROCKER_HEADER_INSTANCE_L3_UNICAST_GID,
+	  .header = ROCKER_HEADER_METADATA,
+	  .field = ROCKER_HEADER_METADATA_L3_UNICAST_GID,
+	  .mask_type = NFL_MASK_TYPE_EXACT},
+	{ .instance = 0, .field = 0},
+};
+
+struct net_flow_field_ref rocker_matches_l2_rewrite_group_slice[2] = {
+	{ .instance = ROCKER_HEADER_INSTANCE_L2_REWRITE_GID,
+	  .header = ROCKER_HEADER_METADATA,
+	  .field = ROCKER_HEADER_METADATA_L2_REWRITE_GID,
+	  .mask_type = NFL_MASK_TYPE_EXACT},
+	{ .instance = 0, .field = 0},
+};
+
+struct net_flow_field_ref rocker_matches_l2_group_slice[2] = {
+	{ .instance = ROCKER_HEADER_INSTANCE_L2_GID,
+	  .header = ROCKER_HEADER_METADATA,
+	  .field = ROCKER_HEADER_METADATA_L2_GID,
+	  .mask_type = NFL_MASK_TYPE_EXACT},
+	{ .instance = 0, .field = 0},
+};
+
 int rocker_actions_ig_port[] = {0};
 int rocker_actions_vlan[] = {ACTION_SET_VLAN_ID, 0};
 int rocker_actions_term_mac[] = {ACTION_COPY_TO_CPU, 0};
-int rocker_actions_ucast_routing[] = {ROCKER_ACTION_SET_GROUP_ID, 0};
-int rocker_actions_bridge[] = {ROCKER_ACTION_SET_GROUP_ID,
+int rocker_actions_ucast_routing[] = {ROCKER_ACTION_SET_L3_UNICAST_GID, 0};
+int rocker_actions_bridge[] = {ROCKER_ACTION_SET_L3_UNICAST_GID,
 			       ACTION_COPY_TO_CPU, 0};
-int rocker_actions_acl[] = {ROCKER_ACTION_SET_GROUP_ID, 0};
+int rocker_actions_acl[] = {ROCKER_ACTION_SET_L3_UNICAST_GID, 0};
+int rocker_actions_group_slice_l3_unicast[] = {ACTION_SET_ETH_SRC,
+					       ACTION_SET_ETH_DST,
+					       ACTION_SET_VLAN_ID,
+					       ROCKER_ACTION_SET_L2_REWRITE_GID,
+					       ACTION_CHECK_TTL_DROP, 0};
+int rocker_actions_group_slice_l2_rewrite[] = {ACTION_SET_ETH_SRC,
+					       ACTION_SET_ETH_DST,
+					       ACTION_SET_VLAN_ID,
+					       ROCKER_ACTION_SET_L2_GID,
+					       0};
+int rocker_actions_group_slice_l2[] = {ACTION_POP_VLAN, 0};
 
 enum rocker_flow_table_id_space {
 	ROCKER_FLOW_TABLE_NULL,
@@ -313,6 +386,9 @@ enum rocker_flow_table_id_space {
 	ROCKER_FLOW_TABLE_ID_MULTICAST_ROUTING,
 	ROCKER_FLOW_TABLE_ID_BRIDGING,
 	ROCKER_FLOW_TABLE_ID_ACL_POLICY,
+	ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L3_UNICAST,
+	ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L2_REWRITE,
+	ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L2,
 };
 
 struct net_flow_tbl rocker_ingress_port_table = {
@@ -375,6 +451,33 @@ struct net_flow_tbl rocker_acl_table = {
 	.cache = {0},
 };
 
+struct net_flow_tbl rocker_group_slice_l3_unicast_table = {
+	.name = "group_slice_l3_unicast",
+	.uid = ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L3_UNICAST,
+	.source = 1,
+	.size = -1,
+	.matches = rocker_matches_l3_unicast_group_slice,
+	.actions = rocker_actions_group_slice_l3_unicast,
+};
+
+struct net_flow_tbl rocker_group_slice_l2_rewrite_table = {
+	.name = "group_slice_l2_rewrite",
+	.uid = ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L2_REWRITE,
+	.source = 1,
+	.size = -1,
+	.matches = rocker_matches_l2_rewrite_group_slice,
+	.actions = rocker_actions_group_slice_l2_rewrite,
+};
+
+struct net_flow_tbl rocker_group_slice_l2_table = {
+	.name = "group_slice_l2",
+	.uid = ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L2,
+	.source = 1,
+	.size = -1,
+	.matches = rocker_matches_l2_group_slice,
+	.actions = rocker_actions_group_slice_l2,
+};
+
 struct net_flow_tbl *rocker_table_list[] = {
 	&rocker_ingress_port_table,
 	&rocker_vlan_table,
@@ -382,6 +485,9 @@ struct net_flow_tbl *rocker_table_list[] = {
 	&rocker_ucast_routing_table,
 	&rocker_bridge_table,
 	&rocker_acl_table,
+	&rocker_group_slice_l3_unicast_table,
+	&rocker_group_slice_l2_rewrite_table,
+	&rocker_group_slice_l2_table,
 	NULL,
 };
 
@@ -432,6 +538,7 @@ struct net_flow_tbl_node rocker_table_node_ucast_routing = {
 	.jump = rocker_table_node_ucast_routing_next};
 
 struct net_flow_jump_table rocker_table_node_acl_next[] = {
+	{ .field = {0}, .node = ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L3_UNICAST},
 	{ .field = {0}, .node = 0},
 };
 
@@ -439,6 +546,32 @@ struct net_flow_tbl_node rocker_table_node_acl = {
 	.uid = ROCKER_FLOW_TABLE_ID_ACL_POLICY,
 	.jump = rocker_table_node_acl_next};
 
+struct net_flow_jump_table rocker_table_node_group_l3_unicast_next[1] = {
+	{ .field = {0}, .node = ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L2_REWRITE},
+};
+
+struct net_flow_tbl_node rocker_table_node_group_l3_unicast = {
+	.uid = ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L3_UNICAST,
+	.jump = rocker_table_node_group_l3_unicast_next};
+
+struct net_flow_jump_table rocker_table_node_group_l2_rewrite_next[1] = {
+	{ .field = {0}, .node = ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L2},
+};
+
+struct net_flow_tbl_node rocker_table_node_group_l2_rewrite = {
+	.uid = ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L2_REWRITE,
+	.jump = rocker_table_node_group_l2_rewrite_next};
+
+struct net_flow_jump_table rocker_table_node_group_l2_next[1] = {
+	{ .field = {0}, .node = 0},
+};
+
+struct net_flow_tbl_node rocker_table_node_group_l2 = {
+	.uid = ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L2,
+	.jump = rocker_table_node_group_l2_next};
+
+struct net_flow_tbl_node rocker_table_node_nil = {.uid = 0, .jump = NULL};
+
 struct net_flow_tbl_node *rocker_table_nodes[] = {
 	&rocker_table_node_ingress_port,
 	&rocker_table_node_vlan,
@@ -446,6 +579,9 @@ struct net_flow_tbl_node *rocker_table_nodes[] = {
 	&rocker_table_node_ucast_routing,
 	&rocker_table_node_bridge,
 	&rocker_table_node_acl,
-	NULL,
+	&rocker_table_node_group_l3_unicast,
+	&rocker_table_node_group_l2_rewrite,
+	&rocker_table_node_group_l2,
+	NULL
 };
 #endif /*_ROCKER_PIPELINE_H_*/
