From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v2 07/12] net: rocker: add set flow rules
Date: Tue, 13 Jan 2015 13:38:05 -0800
Message-ID: <20150113213803.13874.81365.stgit@nitbit.x32>
References: <20150113212941.13874.48692.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gerlitz.or@gmail.com, jhs@mojatatu.com,
	andy@greyhouse.net, davem@davemloft.net
To: tgraf@suug.ch, simon.horman@netronome.com, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:52441 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753788AbbAMViX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 16:38:23 -0500
Received: by mail-oi0-f54.google.com with SMTP id u20so4419380oif.13
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 13:38:22 -0800 (PST)
In-Reply-To: <20150113212941.13874.48692.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement set flow operations for existing rocker tables.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/ethernet/rocker/rocker.c |  422 ++++++++++++++++++++++++++++++++++
 1 file changed, 422 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index d2ea451..08efd8b 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3830,6 +3830,425 @@ static struct net_flow_hdr_node **rocker_get_hgraph(struct net_device *d)
 {
 	return rocker_header_nodes;
 }
+
+static u32 rocker_goto_value(u32 id)
+{
+	switch (id) {
+	case ROCKER_FLOW_TABLE_ID_INGRESS_PORT:
+		return ROCKER_OF_DPA_TABLE_ID_INGRESS_PORT;
+	case ROCKER_FLOW_TABLE_ID_VLAN:
+		return ROCKER_OF_DPA_TABLE_ID_VLAN;
+	case ROCKER_FLOW_TABLE_ID_TERMINATION_MAC:
+		return ROCKER_OF_DPA_TABLE_ID_TERMINATION_MAC;
+	case ROCKER_FLOW_TABLE_ID_UNICAST_ROUTING:
+		return ROCKER_OF_DPA_TABLE_ID_UNICAST_ROUTING;
+	case ROCKER_FLOW_TABLE_ID_MULTICAST_ROUTING:
+		return ROCKER_OF_DPA_TABLE_ID_MULTICAST_ROUTING;
+	case ROCKER_FLOW_TABLE_ID_BRIDGING:
+		return ROCKER_OF_DPA_TABLE_ID_BRIDGING;
+	case ROCKER_FLOW_TABLE_ID_ACL_POLICY:
+		return ROCKER_OF_DPA_TABLE_ID_ACL_POLICY;
+	default:
+		return 0;
+	}
+}
+
+static int rocker_flow_set_ig_port(struct net_device *dev,
+				   struct net_flow_rule *flow)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	enum rocker_of_dpa_table_id goto_tbl;
+	u32 in_lport_mask, in_lport;
+	int flags = 0;
+
+	/* ingress port table only supports one field/mask/action this
+	 * simplifies the key construction and we can assume the values
+	 * are the correct types/mask/action by valid check above. The
+	 * user could pass multiple match/actions in a message with the
+	 * same field multiple times currently the valid test does not
+	 * catch this and we just use the first specified.
+	 */
+	in_lport = flow->matches[0].value_u32;
+	in_lport_mask = flow->matches[0].mask_u32;
+	goto_tbl = rocker_goto_value(flow->actions[0].args[0].value_u16);
+
+	return rocker_flow_tbl_ig_port(rocker_port, flags,
+				       in_lport, in_lport_mask,
+				       goto_tbl);
+}
+
+static int rocker_flow_set_vlan(struct net_device *dev,
+				struct net_flow_rule *flow)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	__be16 vlan_id, vlan_id_mask, new_vlan_id;
+	bool untagged, have_in_lport = false;
+	enum rocker_of_dpa_table_id goto_tbl;
+	int i, flags = 0;
+	u32 in_lport;
+
+	goto_tbl = ROCKER_OF_DPA_TABLE_ID_TERMINATION_MAC;
+
+	/* If user does not specify vid match default to any */
+	vlan_id = htons(1);
+	vlan_id_mask = 0;
+
+	for (i = 0; flow->matches && flow->matches[i].instance; i++) {
+		switch (flow->matches[i].instance) {
+		case ROCKER_HEADER_INSTANCE_IN_LPORT:
+			in_lport = flow->matches[i].value_u32;
+			have_in_lport = true;
+			break;
+		case ROCKER_HEADER_INSTANCE_VLAN_OUTER:
+			if (flow->matches[i].field != HEADER_VLAN_VID)
+				break;
+
+			vlan_id = htons(flow->matches[i].value_u16);
+			vlan_id_mask = htons(flow->matches[i].mask_u16);
+			break;
+		default:
+			return -EINVAL;
+		}
+	}
+
+	if (!have_in_lport)
+		return -EINVAL;
+
+	/* If user does not specify a new vlan id use default vlan id */
+	new_vlan_id = rocker_port_vid_to_vlan(rocker_port, vlan_id, &untagged);
+
+	for (i = 0; flow->actions && flow->actions[i].uid; i++) {
+		struct net_flow_action_arg *arg = &flow->actions[i].args[0];
+
+		switch (flow->actions[i].uid) {
+		case ACTION_SET_VLAN_ID:
+			new_vlan_id = htons(arg->value_u16);
+			if (new_vlan_id)
+				untagged = false;
+			break;
+		}
+	}
+
+	return rocker_flow_tbl_vlan(rocker_port, flags, in_lport,
+				    vlan_id, vlan_id_mask, goto_tbl,
+				    untagged, new_vlan_id);
+}
+
+static int rocker_flow_set_term_mac(struct net_device *dev,
+				    struct net_flow_rule *flow)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	__be16 vlan_id, vlan_id_mask, ethtype = 0;
+	const u8 *eth_dst, *eth_dst_mask;
+	u32 in_lport, in_lport_mask;
+	int i, flags = 0;
+	bool copy_to_cpu;
+
+	/* If user does not specify vid match default to any */
+	vlan_id = rocker_port->internal_vlan_id;
+	vlan_id_mask = 0;
+
+	/* If user does not specify in_lport match default to any */
+	in_lport = rocker_port->lport;
+	in_lport_mask = 0;
+
+	/* If user does not specify a mac address match any */
+	eth_dst = rocker_port->dev->dev_addr;
+	eth_dst_mask = zero_mac;
+
+	for (i = 0; flow->matches && flow->matches[i].instance; i++) {
+		switch (flow->matches[i].instance) {
+		case ROCKER_HEADER_INSTANCE_IN_LPORT:
+			in_lport = flow->matches[i].value_u32;
+			in_lport_mask = flow->matches[i].mask_u32;
+			break;
+		case ROCKER_HEADER_INSTANCE_VLAN_OUTER:
+			if (flow->matches[i].field != HEADER_VLAN_VID)
+				break;
+
+			vlan_id = htons(flow->matches[i].value_u16);
+			vlan_id_mask = htons(flow->matches[i].mask_u16);
+			break;
+		case ROCKER_HEADER_INSTANCE_ETHERNET:
+			switch (flow->matches[i].field) {
+			case HEADER_ETHERNET_DST_MAC:
+				eth_dst = (u8 *)&flow->matches[i].value_u64;
+				eth_dst_mask = (u8 *)&flow->matches[i].mask_u64;
+				break;
+			case HEADER_ETHERNET_ETHERTYPE:
+				ethtype = htons(flow->matches[i].value_u16);
+				break;
+			default:
+				return -EINVAL;
+			}
+			break;
+		default:
+			return -EINVAL;
+		}
+	}
+
+	if (!ethtype)
+		return -EINVAL;
+
+	/* By default do not copy to cpu */
+	copy_to_cpu = false;
+
+	for (i = 0; flow->actions && flow->actions[i].uid; i++) {
+		switch (flow->actions[i].uid) {
+		case ACTION_COPY_TO_CPU:
+			copy_to_cpu = true;
+			break;
+		default:
+			return -EINVAL;
+		}
+	}
+
+	return rocker_flow_tbl_term_mac(rocker_port, in_lport, in_lport_mask,
+					ethtype, eth_dst, eth_dst_mask,
+					vlan_id, vlan_id_mask,
+					copy_to_cpu, flags);
+}
+
+static int rocker_flow_set_ucast_routing(struct net_device *dev,
+					 struct net_flow_rule *flow)
+{
+	return -EOPNOTSUPP;
+}
+
+static int rocker_flow_set_mcast_routing(struct net_device *dev,
+					 struct net_flow_rule *flow)
+{
+	return -EOPNOTSUPP;
+}
+
+static int rocker_flow_set_bridge(struct net_device *dev,
+				  struct net_flow_rule *flow)
+{
+	enum rocker_of_dpa_table_id goto_tbl;
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	u32 in_lport, in_lport_mask, group_id, tunnel_id;
+	__be16 vlan_id, vlan_id_mask;
+	const u8 *eth_dst, *eth_dst_mask;
+	int i, flags = 0;
+	bool copy_to_cpu;
+
+	goto_tbl = ROCKER_OF_DPA_TABLE_ID_ACL_POLICY;
+
+	/* If user does not specify vid match default to any */
+	vlan_id = rocker_port->internal_vlan_id;
+	vlan_id_mask = 0;
+
+	/* If user does not specify in_lport match default to any */
+	in_lport = rocker_port->lport;
+	in_lport_mask = 0;
+
+	/* If user does not specify a mac address match any */
+	eth_dst = rocker_port->dev->dev_addr;
+	eth_dst_mask = NULL;
+
+	/* Do not support for tunnel_id yet. */
+	tunnel_id = 0;
+
+	for (i = 0; flow->matches && flow->matches[i].instance; i++) {
+		switch (flow->matches[i].instance) {
+		case ROCKER_HEADER_INSTANCE_IN_LPORT:
+			in_lport = flow->matches[i].value_u32;
+			in_lport_mask = flow->matches[i].mask_u32;
+			break;
+		case ROCKER_HEADER_INSTANCE_VLAN_OUTER:
+			if (flow->matches[i].field != HEADER_VLAN_VID)
+				break;
+
+			vlan_id = htons(flow->matches[i].value_u16);
+			vlan_id_mask = htons(flow->matches[i].mask_u16);
+			break;
+		case ROCKER_HEADER_INSTANCE_ETHERNET:
+			switch (flow->matches[i].field) {
+			case HEADER_ETHERNET_DST_MAC:
+				eth_dst = (u8 *)&flow->matches[i].value_u64;
+				eth_dst_mask = (u8 *)&flow->matches[i].mask_u64;
+				break;
+			default:
+				return -EINVAL;
+			}
+			break;
+		default:
+			return -EINVAL;
+		}
+	}
+
+	/* By default do not copy to cpu and skip group assignment */
+	copy_to_cpu = false;
+	group_id = ROCKER_GROUP_NONE;
+
+	for (i = 0; flow->actions && flow->actions[i].uid; i++) {
+		struct net_flow_action_arg *arg = &flow->actions[i].args[0];
+
+		switch (flow->actions[i].uid) {
+		case ACTION_COPY_TO_CPU:
+			copy_to_cpu = true;
+			break;
+		case ROCKER_ACTION_SET_GROUP_ID:
+			group_id = arg->value_u32;
+			break;
+		default:
+			return -EINVAL;
+		}
+	}
+
+	/* Ignoring eth_dst_mask it seems to cause a EINVAL return code */
+	return rocker_flow_tbl_bridge(rocker_port, flags,
+				      eth_dst, eth_dst_mask,
+				      vlan_id, tunnel_id,
+				      goto_tbl, group_id, copy_to_cpu);
+}
+
+static int rocker_flow_set_acl(struct net_device *dev,
+			       struct net_flow_rule *flow)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	u32 in_lport, in_lport_mask, group_id, tunnel_id;
+	__be16 vlan_id, vlan_id_mask, ethtype = 0;
+	const u8 *eth_dst, *eth_src, *eth_dst_mask, *eth_src_mask;
+	u8 protocol, protocol_mask, dscp, dscp_mask;
+	int i, flags = 0;
+
+	/* If user does not specify vid match default to any */
+	vlan_id = rocker_port->internal_vlan_id;
+	vlan_id_mask = 0;
+
+	/* If user does not specify in_lport match default to any */
+	in_lport = rocker_port->lport;
+	in_lport_mask = 0;
+
+	/* If user does not specify a mac address match any */
+	eth_dst = rocker_port->dev->dev_addr;
+	eth_src = zero_mac;
+	eth_dst_mask = NULL;
+	eth_src_mask = NULL;
+
+	/* If user does not set protocol/dscp mask them out */
+	protocol = 0;
+	dscp = 0;
+	protocol_mask = 0;
+	dscp_mask = 0;
+
+	/* Do not support for tunnel_id yet. */
+	tunnel_id = 0;
+
+	for (i = 0; flow->matches && flow->matches[i].instance; i++) {
+		switch (flow->matches[i].instance) {
+		case ROCKER_HEADER_INSTANCE_IN_LPORT:
+			in_lport = flow->matches[i].value_u32;
+			in_lport_mask = flow->matches[i].mask_u32;
+			break;
+		case ROCKER_HEADER_INSTANCE_VLAN_OUTER:
+			if (flow->matches[i].field != HEADER_VLAN_VID)
+				break;
+
+			vlan_id = htons(flow->matches[i].value_u16);
+			vlan_id_mask = htons(flow->matches[i].mask_u16);
+			break;
+		case ROCKER_HEADER_INSTANCE_ETHERNET:
+			switch (flow->matches[i].field) {
+			case HEADER_ETHERNET_SRC_MAC:
+				eth_src = (u8 *)&flow->matches[i].value_u64;
+				eth_src_mask = (u8 *)&flow->matches[i].mask_u64;
+				break;
+			case HEADER_ETHERNET_DST_MAC:
+				eth_dst = (u8 *)&flow->matches[i].value_u64;
+				eth_dst_mask = (u8 *)&flow->matches[i].mask_u64;
+				break;
+			case HEADER_ETHERNET_ETHERTYPE:
+				ethtype = htons(flow->matches[i].value_u16);
+				break;
+			default:
+				return -EINVAL;
+			}
+			break;
+		case ROCKER_HEADER_INSTANCE_IPV4:
+			switch (flow->matches[i].field) {
+			case HEADER_IPV4_PROTOCOL:
+				protocol = flow->matches[i].value_u8;
+				protocol_mask = flow->matches[i].mask_u8;
+				break;
+			case HEADER_IPV4_DSCP:
+				dscp = flow->matches[i].value_u8;
+				dscp_mask = flow->matches[i].mask_u8;
+				break;
+			default:
+				return -EINVAL;
+			}
+		default:
+			return -EINVAL;
+		}
+	}
+
+	/* By default do not copy to cpu and skip group assignment */
+	group_id = ROCKER_GROUP_NONE;
+
+	for (i = 0; flow->actions && flow->actions[i].uid; i++) {
+		switch (flow->actions[i].uid) {
+		case ROCKER_ACTION_SET_GROUP_ID:
+			group_id = flow->actions[i].args[0].value_u32;
+			break;
+		default:
+			return -EINVAL;
+		}
+	}
+
+	return rocker_flow_tbl_acl(rocker_port, flags,
+				   in_lport, in_lport_mask,
+				   eth_src, eth_src_mask,
+				   eth_dst, eth_dst_mask, ethtype,
+				   vlan_id, vlan_id_mask,
+				   protocol, protocol_mask,
+				   dscp, dscp_mask,
+				   group_id);
+}
+
+static int rocker_set_flows(struct net_device *dev,
+			    struct net_flow_rule *flow)
+{
+	int err = -EINVAL;
+
+	if (!flow->matches || !flow->actions)
+		return -EINVAL;
+
+	switch (flow->table_id) {
+	case ROCKER_FLOW_TABLE_ID_INGRESS_PORT:
+		err = rocker_flow_set_ig_port(dev, flow);
+		break;
+	case ROCKER_FLOW_TABLE_ID_VLAN:
+		err = rocker_flow_set_vlan(dev, flow);
+		break;
+	case ROCKER_FLOW_TABLE_ID_TERMINATION_MAC:
+		err = rocker_flow_set_term_mac(dev, flow);
+		break;
+	case ROCKER_FLOW_TABLE_ID_UNICAST_ROUTING:
+		err = rocker_flow_set_ucast_routing(dev, flow);
+		break;
+	case ROCKER_FLOW_TABLE_ID_MULTICAST_ROUTING:
+		err = rocker_flow_set_mcast_routing(dev, flow);
+		break;
+	case ROCKER_FLOW_TABLE_ID_BRIDGING:
+		err = rocker_flow_set_bridge(dev, flow);
+		break;
+	case ROCKER_FLOW_TABLE_ID_ACL_POLICY:
+		err = rocker_flow_set_acl(dev, flow);
+		break;
+	default:
+		break;
+	}
+
+	return err;
+}
+
+static int rocker_del_flows(struct net_device *dev,
+			    struct net_flow_rule *flow)
+{
+	return -EOPNOTSUPP;
+}
 #endif
 
 static const struct net_device_ops rocker_port_netdev_ops = {
@@ -3852,6 +4271,9 @@ static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_flow_get_actions		= rocker_get_actions,
 	.ndo_flow_get_tbl_graph		= rocker_get_tgraph,
 	.ndo_flow_get_hdr_graph		= rocker_get_hgraph,
+
+	.ndo_flow_set_rule		= rocker_set_flows,
+	.ndo_flow_del_rule		= rocker_del_flows,
 #endif
 };
 
