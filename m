From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2 06/12] net: rocker: add pipeline model for
 rocker switch
Date: Tue, 13 Jan 2015 13:37:41 -0800
Message-ID: <20150113213739.13874.37091.stgit@nitbit.x32>
References: <20150113212941.13874.48692.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gerlitz.or@gmail.com, jhs@mojatatu.com,
	andy@greyhouse.net, davem@davemloft.net
To: tgraf@suug.ch, simon.horman@netronome.com, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:37334 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753609AbbAMVh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 16:37:58 -0500
Received: by mail-oi0-f52.google.com with SMTP id a3so4437301oib.11
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 13:37:57 -0800 (PST)
In-Reply-To: <20150113212941.13874.48692.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds rocker support for the net_flow_get_* operations. With this
we can interrogate rocker.

Here we see that for static configurations enabling the get operations
is simply a matter of defining a pipeline model and returning the
structures for the core infrastructure to encapsulate into netlink
messages.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/ethernet/rocker/rocker.c          |   65 ++++
 drivers/net/ethernet/rocker/rocker_pipeline.h |  451 +++++++++++++++++++++++++
 2 files changed, 516 insertions(+)
 create mode 100644 drivers/net/ethernet/rocker/rocker_pipeline.h

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 2f398fa..d2ea451 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -36,6 +36,7 @@
 #include <generated/utsrelease.h>
 
 #include "rocker.h"
+#include "rocker_pipeline.h"
 
 static const char rocker_driver_name[] = "rocker";
 
@@ -3781,6 +3782,56 @@ static int rocker_port_switch_port_stp_update(struct net_device *dev, u8 state)
 	return rocker_port_stp_update(rocker_port, state);
 }
 
+static void rocker_destroy_flow_tables(struct rocker_port *rocker_port)
+{
+	int i;
+
+	for (i = 0; rocker_table_list[i]; i++)
+		net_flow_destroy_cache(rocker_table_list[i]);
+}
+
+static int rocker_init_flow_tables(struct rocker_port *rocker_port)
+{
+	int i, err;
+
+	for (i = 0; rocker_table_list[i]; i++) {
+		err = net_flow_init_cache(rocker_table_list[i]);
+		if (err) {
+			rocker_destroy_flow_tables(rocker_port);
+			return err;
+		}
+	}
+
+	return 0;
+}
+
+#ifdef CONFIG_NET_FLOW_TABLES
+static struct net_flow_tbl **rocker_get_tables(struct net_device *d)
+{
+	return rocker_table_list;
+}
+
+static struct net_flow_hdr **rocker_get_headers(struct net_device *d)
+{
+	return rocker_header_list;
+}
+
+static struct net_flow_action **rocker_get_actions(struct net_device *d)
+{
+	return rocker_action_list;
+}
+
+static struct net_flow_tbl_node **rocker_get_tgraph(struct net_device *d)
+{
+	return rocker_table_nodes;
+}
+
+static struct net_flow_hdr_node **rocker_get_hgraph(struct net_device *d)
+{
+	return rocker_header_nodes;
+}
+#endif
+
 static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_open			= rocker_port_open,
 	.ndo_stop			= rocker_port_stop,
@@ -3795,6 +3846,13 @@ static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_bridge_getlink		= rocker_port_bridge_getlink,
 	.ndo_switch_parent_id_get	= rocker_port_switch_parent_id_get,
 	.ndo_switch_port_stp_update	= rocker_port_switch_port_stp_update,
+#ifdef CONFIG_NET_FLOW_TABLES
+	.ndo_flow_get_tbls		= rocker_get_tables,
+	.ndo_flow_get_hdrs		= rocker_get_headers,
+	.ndo_flow_get_actions		= rocker_get_actions,
+	.ndo_flow_get_tbl_graph		= rocker_get_tgraph,
+	.ndo_flow_get_hdr_graph		= rocker_get_hgraph,
+#endif
 };
 
 /********************
@@ -3960,6 +4018,7 @@ static void rocker_remove_ports(struct rocker *rocker)
 		rocker_port = rocker->ports[i];
 		rocker_port_ig_tbl(rocker_port, ROCKER_OP_FLAG_REMOVE);
 		unregister_netdev(rocker_port->dev);
+		rocker_destroy_flow_tables(rocker_port);
 	}
 	kfree(rocker->ports);
 }
@@ -4023,6 +4082,12 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 		goto err_port_ig_tbl;
 	}
 
+	err = rocker_init_flow_tables(rocker_port);
+	if (err) {
+		dev_err(&pdev->dev, "install flow table failed\n");
+		goto err_port_ig_tbl;
+	}
+
 	return 0;
 
 err_port_ig_tbl:
diff --git a/drivers/net/ethernet/rocker/rocker_pipeline.h b/drivers/net/ethernet/rocker/rocker_pipeline.h
new file mode 100644
index 0000000..7136380
--- /dev/null
+++ b/drivers/net/ethernet/rocker/rocker_pipeline.h
@@ -0,0 +1,451 @@
+/*
+ * drivers/net/ethernet/rocker/rocker_pipeline.h - Rocker switch device driver
+ * Copyright (c) 2014 John Fastabend <john.r.fastabend@intel.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _ROCKER_PIPELINE_H_
+#define _ROCKER_PIPELINE_H_
+
+#include <linux/if_flow.h>
+#include <linux/if_flow_common.h>
+
+enum rocker_header_ids {
+	ROCKER_HEADER_UNSPEC = HEADER_MAX_UID,
+	ROCKER_HEADER_METADATA,
+};
+
+enum rocker_header_metadata_fields {
+	ROCKER_HEADER_METADATA_UNSPEC,
+	ROCKER_HEADER_METADATA_IN_LPORT,
+	ROCKER_HEADER_METADATA_GOTO_TBL,
+	ROCKER_HEADER_METADATA_GROUP_ID,
+};
+
+struct net_flow_field rocker_metadata_fields[] = {
+	{ .name = "in_lport",
+	  .uid = ROCKER_HEADER_METADATA_IN_LPORT,
+	  .bitwidth = 32,},
+	{ .name = "goto_tbl",
+	  .uid = ROCKER_HEADER_METADATA_GOTO_TBL,
+	  .bitwidth = 16,},
+	{ .name = "group_id",
+	  .uid = ROCKER_HEADER_METADATA_GROUP_ID,
+	  .bitwidth = 32,},
+};
+
+struct net_flow_hdr rocker_metadata_t = {
+	.name = "metadata_t",
+	.uid = ROCKER_HEADER_METADATA,
+	.field_sz = ARRAY_SIZE(rocker_metadata_fields),
+	.fields = rocker_metadata_fields,
+};
+
+struct net_flow_hdr *rocker_header_list[] = {
+	&net_flow_ethernet,
+	&net_flow_vlan,
+	&net_flow_ipv4,
+	&rocker_metadata_t,
+	NULL,
+};
+
+/* rocker specific action definitions */
+struct net_flow_action_arg rocker_set_group_id_args[] = {
+	{
+		.name = "group_id",
+		.type = NFL_ACTION_ARG_TYPE_U32,
+		.value_u32 = 0,
+	},
+	{
+		.name = "",
+		.type = NFL_ACTION_ARG_TYPE_NULL,
+	},
+};
+
+enum rocker_action_ids {
+	ROCKER_ACTION_UNSPEC = ACTION_MAX_UID,
+	ROCKER_ACTION_SET_GROUP_ID,
+};
+
+struct net_flow_action rocker_set_group_id = {
+	.name = "set_group_id",
+	.uid = ROCKER_ACTION_SET_GROUP_ID,
+	.args = rocker_set_group_id_args,
+};
+
+struct net_flow_action *rocker_action_list[] = {
+	&net_flow_set_vlan_id,
+	&net_flow_copy_to_cpu,
+	&rocker_set_group_id,
+	&net_flow_pop_vlan,
+	&net_flow_set_eth_src,
+	&net_flow_set_eth_dst,
+	NULL,
+};
+
+/* headers graph */
+enum rocker_header_instance_ids {
+	ROCKER_HEADER_INSTANCE_UNSPEC,
+	ROCKER_HEADER_INSTANCE_ETHERNET,
+	ROCKER_HEADER_INSTANCE_VLAN_OUTER,
+	ROCKER_HEADER_INSTANCE_IPV4,
+	ROCKER_HEADER_INSTANCE_IN_LPORT,
+	ROCKER_HEADER_INSTANCE_GOTO_TABLE,
+	ROCKER_HEADER_INSTANCE_GROUP_ID,
+};
+
+struct net_flow_jump_table rocker_parse_ethernet[] = {
+	{
+		.field = {
+		   .header = HEADER_ETHERNET,
+		   .field = HEADER_ETHERNET_ETHERTYPE,
+		   .type = NFL_FIELD_REF_ATTR_TYPE_U16,
+		   .value_u16 = ETH_P_IP,
+		},
+		.node = ROCKER_HEADER_INSTANCE_IPV4,
+	},
+	{
+		.field = {
+		   .header = HEADER_ETHERNET,
+		   .field = HEADER_ETHERNET_ETHERTYPE,
+		   .type = NFL_FIELD_REF_ATTR_TYPE_U16,
+		   .value_u16 = ETH_P_8021Q,
+		},
+		.node = ROCKER_HEADER_INSTANCE_VLAN_OUTER,
+	},
+	{
+		.field = {0},
+		.node = 0,
+	},
+};
+
+int rocker_ethernet_headers[] = {HEADER_ETHERNET, 0};
+
+struct net_flow_hdr_node rocker_ethernet_header_node = {
+	.name = "ethernet",
+	.uid = ROCKER_HEADER_INSTANCE_ETHERNET,
+	.hdrs = rocker_ethernet_headers,
+	.jump = rocker_parse_ethernet,
+};
+
+struct net_flow_jump_table rocker_parse_vlan[] = {
+	{
+		.field = {
+		   .header = HEADER_VLAN,
+		   .field = HEADER_VLAN_ETHERTYPE,
+		   .type = NFL_FIELD_REF_ATTR_TYPE_U16,
+		   .value_u16 = ETH_P_IP,
+		},
+		.node = ROCKER_HEADER_INSTANCE_IPV4,
+	},
+	{
+		.field = {0},
+		.node = 0,
+	},
+};
+
+int rocker_vlan_headers[] = {HEADER_VLAN, 0};
+struct net_flow_hdr_node rocker_vlan_header_node = {
+	.name = "vlan",
+	.uid = ROCKER_HEADER_INSTANCE_VLAN_OUTER,
+	.hdrs = rocker_vlan_headers,
+	.jump = rocker_parse_vlan,
+};
+
+struct net_flow_jump_table rocker_terminal_headers[] = {
+	{
+		.field = {0},
+		.node = NFL_JUMP_TABLE_DONE,
+	},
+	{
+		.field = {0},
+		.node = 0,
+	},
+};
+
+int rocker_ipv4_headers[] = {HEADER_IPV4, 0};
+struct net_flow_hdr_node rocker_ipv4_header_node = {
+	.name = "ipv4",
+	.uid = ROCKER_HEADER_INSTANCE_IPV4,
+	.hdrs = rocker_ipv4_headers,
+	.jump = rocker_terminal_headers,
+};
+
+int rocker_metadata_headers[] = {ROCKER_HEADER_METADATA, 0};
+struct net_flow_hdr_node rocker_in_lport_header_node = {
+	.name = "in_lport",
+	.uid = ROCKER_HEADER_INSTANCE_IN_LPORT,
+	.hdrs = rocker_metadata_headers,
+	.jump = rocker_terminal_headers,
+};
+
+struct net_flow_hdr_node rocker_group_id_header_node = {
+	.name = "group_id",
+	.uid = ROCKER_HEADER_INSTANCE_GROUP_ID,
+	.hdrs = rocker_metadata_headers,
+	.jump = rocker_terminal_headers,
+};
+
+struct net_flow_hdr_node *rocker_header_nodes[] = {
+	&rocker_ethernet_header_node,
+	&rocker_vlan_header_node,
+	&rocker_ipv4_header_node,
+	&rocker_in_lport_header_node,
+	&rocker_group_id_header_node,
+	NULL,
+};
+
+/* table definition */
+struct net_flow_field_ref rocker_matches_ig_port[] = {
+	{ .instance = ROCKER_HEADER_INSTANCE_IN_LPORT,
+	  .header = ROCKER_HEADER_METADATA,
+	  .field = ROCKER_HEADER_METADATA_IN_LPORT,
+	  .mask_type = NFL_MASK_TYPE_MASK},
+	{ .instance = 0, .field = 0},
+};
+
+struct net_flow_field_ref rocker_matches_vlan[] = {
+	{ .instance = ROCKER_HEADER_INSTANCE_IN_LPORT,
+	  .header = ROCKER_HEADER_METADATA,
+	  .field = ROCKER_HEADER_METADATA_IN_LPORT,
+	  .mask_type = NFL_MASK_TYPE_MASK},
+	{ .instance = ROCKER_HEADER_INSTANCE_VLAN_OUTER,
+	  .header = HEADER_VLAN,
+	  .field = HEADER_VLAN_VID,
+	  .mask_type = NFL_MASK_TYPE_MASK},
+	{ .instance = 0, .field = 0},
+};
+
+struct net_flow_field_ref rocker_matches_term_mac[] = {
+	{ .instance = ROCKER_HEADER_INSTANCE_IN_LPORT,
+	  .header = ROCKER_HEADER_METADATA,
+	  .field = ROCKER_HEADER_METADATA_IN_LPORT,
+	  .mask_type = NFL_MASK_TYPE_MASK},
+	{ .instance = ROCKER_HEADER_INSTANCE_ETHERNET,
+	  .header = HEADER_ETHERNET,
+	  .field = HEADER_ETHERNET_ETHERTYPE,
+	  .mask_type = NFL_MASK_TYPE_EXACT},
+	{ .instance = ROCKER_HEADER_INSTANCE_ETHERNET,
+	  .header = HEADER_ETHERNET,
+	  .field = HEADER_ETHERNET_DST_MAC,
+	  .mask_type = NFL_MASK_TYPE_MASK},
+	{ .instance = ROCKER_HEADER_INSTANCE_VLAN_OUTER,
+	  .header = HEADER_VLAN,
+	  .field = HEADER_VLAN_VID,
+	  .mask_type = NFL_MASK_TYPE_MASK},
+	{ .instance = 0, .field = 0},
+};
+
+struct net_flow_field_ref rocker_matches_ucast_routing[] = {
+	{ .instance = ROCKER_HEADER_INSTANCE_ETHERNET,
+	  .header = HEADER_ETHERNET,
+	  .field = HEADER_ETHERNET_ETHERTYPE,
+	  .mask_type = NFL_MASK_TYPE_EXACT},
+	{ .instance = ROCKER_HEADER_INSTANCE_IPV4,
+	  .header = HEADER_IPV4,
+	  .field = HEADER_IPV4_DST_IP,
+	  .mask_type = NFL_MASK_TYPE_LPM},
+	{ .instance = 0, .field = 0},
+};
+
+struct net_flow_field_ref rocker_matches_bridge[] = {
+	{ .instance = ROCKER_HEADER_INSTANCE_ETHERNET,
+	  .header = HEADER_ETHERNET,
+	  .field = HEADER_ETHERNET_DST_MAC,
+	  .mask_type = NFL_MASK_TYPE_MASK},
+	{ .instance = ROCKER_HEADER_INSTANCE_VLAN_OUTER,
+	  .header = HEADER_VLAN,
+	  .field = HEADER_VLAN_VID,
+	  .mask_type = NFL_MASK_TYPE_MASK},
+	{ .instance = 0, .field = 0},
+};
+
+struct net_flow_field_ref rocker_matches_acl[] = {
+	{ .instance = ROCKER_HEADER_INSTANCE_IN_LPORT,
+	  .header = ROCKER_HEADER_METADATA,
+	  .field = ROCKER_HEADER_METADATA_IN_LPORT,
+	  .mask_type = NFL_MASK_TYPE_MASK},
+	{ .instance = ROCKER_HEADER_INSTANCE_ETHERNET,
+	  .header = HEADER_ETHERNET,
+	  .field = HEADER_ETHERNET_SRC_MAC,
+	  .mask_type = NFL_MASK_TYPE_MASK},
+	{ .instance = ROCKER_HEADER_INSTANCE_ETHERNET,
+	  .header = HEADER_ETHERNET,
+	  .field = HEADER_ETHERNET_DST_MAC,
+	  .mask_type = NFL_MASK_TYPE_MASK},
+	{ .instance = ROCKER_HEADER_INSTANCE_ETHERNET,
+	  .header = HEADER_ETHERNET,
+	  .field = HEADER_ETHERNET_ETHERTYPE,
+	  .mask_type = NFL_MASK_TYPE_EXACT},
+	{ .instance = ROCKER_HEADER_INSTANCE_VLAN_OUTER,
+	  .header = HEADER_VLAN,
+	  .field = HEADER_VLAN_VID,
+	  .mask_type = NFL_MASK_TYPE_MASK},
+	{ .instance = ROCKER_HEADER_INSTANCE_IPV4,
+	  .header = HEADER_IPV4,
+	  .field = HEADER_IPV4_PROTOCOL,
+	  .mask_type = NFL_MASK_TYPE_MASK},
+	{ .instance = ROCKER_HEADER_INSTANCE_IPV4,
+	  .header = HEADER_IPV4,
+	  .field = HEADER_IPV4_DSCP,
+	  .mask_type = NFL_MASK_TYPE_MASK},
+	{ .instance = 0, .field = 0},
+};
+
+int rocker_actions_ig_port[] = {0};
+int rocker_actions_vlan[] = {ACTION_SET_VLAN_ID, 0};
+int rocker_actions_term_mac[] = {ACTION_COPY_TO_CPU, 0};
+int rocker_actions_ucast_routing[] = {ROCKER_ACTION_SET_GROUP_ID, 0};
+int rocker_actions_bridge[] = {ROCKER_ACTION_SET_GROUP_ID,
+			       ACTION_COPY_TO_CPU, 0};
+int rocker_actions_acl[] = {ROCKER_ACTION_SET_GROUP_ID, 0};
+
+enum rocker_flow_table_id_space {
+	ROCKER_FLOW_TABLE_NULL,
+	ROCKER_FLOW_TABLE_ID_INGRESS_PORT,
+	ROCKER_FLOW_TABLE_ID_VLAN,
+	ROCKER_FLOW_TABLE_ID_TERMINATION_MAC,
+	ROCKER_FLOW_TABLE_ID_UNICAST_ROUTING,
+	ROCKER_FLOW_TABLE_ID_MULTICAST_ROUTING,
+	ROCKER_FLOW_TABLE_ID_BRIDGING,
+	ROCKER_FLOW_TABLE_ID_ACL_POLICY,
+};
+
+struct net_flow_tbl rocker_ingress_port_table = {
+	.name = "ingress_port",
+	.uid = ROCKER_FLOW_TABLE_ID_INGRESS_PORT,
+	.source = 1,
+	.size = -1,
+	.matches = rocker_matches_ig_port,
+	.actions = rocker_actions_ig_port,
+	.cache = {0},
+};
+
+struct net_flow_tbl rocker_vlan_table = {
+	.name = "vlan",
+	.uid = ROCKER_FLOW_TABLE_ID_VLAN,
+	.source = 1,
+	.size = -1,
+	.matches = rocker_matches_vlan,
+	.actions = rocker_actions_vlan,
+	.cache = {0},
+};
+
+struct net_flow_tbl rocker_term_mac_table = {
+	.name = "term_mac",
+	.uid = ROCKER_FLOW_TABLE_ID_TERMINATION_MAC,
+	.source = 1,
+	.size = -1,
+	.matches = rocker_matches_term_mac,
+	.actions = rocker_actions_term_mac,
+	.cache = {0},
+};
+
+struct net_flow_tbl rocker_ucast_routing_table = {
+	.name = "ucast_routing",
+	.uid = ROCKER_FLOW_TABLE_ID_UNICAST_ROUTING,
+	.source = 1,
+	.size = -1,
+	.matches = rocker_matches_ucast_routing,
+	.actions = rocker_actions_ucast_routing,
+	.cache = {0},
+};
+
+struct net_flow_tbl rocker_bridge_table = {
+	.name = "bridge",
+	.uid = ROCKER_FLOW_TABLE_ID_BRIDGING,
+	.source = 1,
+	.size = -1,
+	.matches = rocker_matches_bridge,
+	.actions = rocker_actions_bridge,
+	.cache = {0},
+};
+
+struct net_flow_tbl rocker_acl_table = {
+	.name = "acl",
+	.uid = ROCKER_FLOW_TABLE_ID_ACL_POLICY,
+	.source = 1,
+	.size = -1,
+	.matches = rocker_matches_acl,
+	.actions = rocker_actions_acl,
+	.cache = {0},
+};
+
+struct net_flow_tbl *rocker_table_list[] = {
+	&rocker_ingress_port_table,
+	&rocker_vlan_table,
+	&rocker_term_mac_table,
+	&rocker_ucast_routing_table,
+	&rocker_bridge_table,
+	&rocker_acl_table,
+	NULL,
+};
+
+/* Define the table graph layout */
+struct net_flow_jump_table rocker_table_node_ig_port_next[] = {
+	{ .field = {0}, .node = ROCKER_FLOW_TABLE_ID_VLAN},
+	{ .field = {0}, .node = 0},
+};
+
+struct net_flow_tbl_node rocker_table_node_ingress_port = {
+	.uid = ROCKER_FLOW_TABLE_ID_INGRESS_PORT,
+	.jump = rocker_table_node_ig_port_next};
+
+struct net_flow_jump_table rocker_table_node_vlan_next[] = {
+	{ .field = {0}, .node = ROCKER_FLOW_TABLE_ID_TERMINATION_MAC},
+	{ .field = {0}, .node = 0},
+};
+
+struct net_flow_tbl_node rocker_table_node_vlan = {
+	.uid = ROCKER_FLOW_TABLE_ID_VLAN,
+	.jump = rocker_table_node_vlan_next};
+
+struct net_flow_jump_table rocker_table_node_term_mac_next[] = {
+	{ .field = {0}, .node = ROCKER_FLOW_TABLE_ID_UNICAST_ROUTING},
+	{ .field = {0}, .node = 0},
+};
+
+struct net_flow_tbl_node rocker_table_node_term_mac = {
+	.uid = ROCKER_FLOW_TABLE_ID_TERMINATION_MAC,
+	.jump = rocker_table_node_term_mac_next};
+
+struct net_flow_jump_table rocker_table_node_bridge_next[] = {
+	{ .field = {0}, .node = ROCKER_FLOW_TABLE_ID_ACL_POLICY},
+	{ .field = {0}, .node = 0},
+};
+
+struct net_flow_tbl_node rocker_table_node_bridge = {
+	.uid = ROCKER_FLOW_TABLE_ID_BRIDGING,
+	.jump = rocker_table_node_bridge_next};
+
+struct net_flow_jump_table rocker_table_node_ucast_routing_next[] = {
+	{ .field = {0}, .node = ROCKER_FLOW_TABLE_ID_ACL_POLICY},
+	{ .field = {0}, .node = 0},
+};
+
+struct net_flow_tbl_node rocker_table_node_ucast_routing = {
+	.uid = ROCKER_FLOW_TABLE_ID_UNICAST_ROUTING,
+	.jump = rocker_table_node_ucast_routing_next};
+
+struct net_flow_jump_table rocker_table_node_acl_next[] = {
+	{ .field = {0}, .node = 0},
+};
+
+struct net_flow_tbl_node rocker_table_node_acl = {
+	.uid = ROCKER_FLOW_TABLE_ID_ACL_POLICY,
+	.jump = rocker_table_node_acl_next};
+
+struct net_flow_tbl_node *rocker_table_nodes[] = {
+	&rocker_table_node_ingress_port,
+	&rocker_table_node_vlan,
+	&rocker_table_node_term_mac,
+	&rocker_table_node_ucast_routing,
+	&rocker_table_node_bridge,
+	&rocker_table_node_acl,
+	NULL,
+};
+#endif /*_ROCKER_PIPELINE_H_*/
