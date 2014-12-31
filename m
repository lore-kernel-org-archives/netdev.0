From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v1 08/11] net: rocker: add get flow API operation
Date: Wed, 31 Dec 2014 11:48:54 -0800
Message-ID: <20141231194852.31070.72727.stgit@nitbit.x32>
References: <20141231194057.31070.5244.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net
To: tgraf@suug.ch, sfeldma@gmail.com, jiri@resnulli.us,
	jhs@mojatatu.com, simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:36538 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751171AbaLaTtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 14:49:14 -0500
Received: by mail-oi0-f50.google.com with SMTP id x69so36666482oia.9
        for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 11:49:13 -0800 (PST)
In-Reply-To: <20141231194057.31070.5244.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add operations to get flows. I wouldn't mind cleaning this code
up a bit but my first attempt to do this used macros which shortered
the code up but when I was done I decided it just made the code
unreadable and unmaintainable.

I might think about it a bit more but this implementation albeit
a bit long and repeatative is easier to understand IMO.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/ethernet/rocker/rocker.c |  819 ++++++++++++++++++++++++++++++++++
 1 file changed, 819 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 8ce9933..997beb9 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3884,6 +3884,12 @@ static u32 rocker_goto_value(u32 id)
 		return ROCKER_OF_DPA_TABLE_ID_BRIDGING;
 	case ROCKER_FLOW_TABLE_ID_ACL_POLICY:
 		return ROCKER_OF_DPA_TABLE_ID_ACL_POLICY;
+	case ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L3_UNICAST:
+		return ROCKER_OF_DPA_GROUP_TYPE_L3_UCAST;
+	case ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L2_REWRITE:
+		return ROCKER_OF_DPA_GROUP_TYPE_L2_REWRITE;
+	case ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L2:
+		return ROCKER_OF_DPA_GROUP_TYPE_L2_INTERFACE;
 	default:
 		return 0;
 	}
@@ -4492,6 +4498,818 @@ static int rocker_del_flows(struct net_device *dev,
 {
 	return -EOPNOTSUPP;
 }
+
+static int rocker_ig_port_to_flow(struct rocker_flow_tbl_key *key,
+				  struct net_flow_flow *flow)
+{
+	flow->matches = kcalloc(2, sizeof(struct net_flow_field_ref),
+				GFP_KERNEL);
+	if (!flow->matches)
+		return -ENOMEM;
+
+	flow->matches[0].instance = HEADER_INSTANCE_IN_LPORT;
+	flow->matches[0].header = HEADER_METADATA;
+	flow->matches[0].field = HEADER_METADATA_IN_LPORT;
+	flow->matches[0].mask_type = NET_FLOW_MASK_TYPE_LPM;
+	flow->matches[0].type = NET_FLOW_FIELD_REF_ATTR_TYPE_U32;
+	flow->matches[0].value_u32 = key->ig_port.in_lport;
+	flow->matches[0].mask_u32 = key->ig_port.in_lport_mask;
+	memset(&flow->matches[1], 0, sizeof(flow->matches[1]));
+	return 0;
+}
+
+static int rocker_vlan_to_flow(struct rocker_flow_tbl_key *key,
+			       struct net_flow_flow *flow)
+{
+	int cnt = 0;
+
+	if (key->vlan.in_lport)
+		cnt++;
+	if (key->vlan.vlan_id)
+		cnt++;
+
+	flow->matches = kcalloc((cnt + 1),
+				sizeof(struct net_flow_field_ref),
+				GFP_KERNEL);
+	if (!flow->matches)
+		return -ENOMEM;
+
+	cnt = 0;
+	if (key->vlan.in_lport) {
+		flow->matches[cnt].instance = HEADER_INSTANCE_IN_LPORT;
+		flow->matches[cnt].header = HEADER_METADATA;
+		flow->matches[cnt].field = HEADER_METADATA_IN_LPORT;
+		flow->matches[cnt].mask_type = NET_FLOW_MASK_TYPE_EXACT;
+		flow->matches[cnt].type = NET_FLOW_FIELD_REF_ATTR_TYPE_U32;
+		flow->matches[cnt].value_u32 = key->vlan.in_lport;
+		cnt++;
+	}
+
+	if (key->vlan.vlan_id) {
+		flow->matches[cnt].instance = HEADER_INSTANCE_VLAN_OUTER;
+		flow->matches[cnt].header = HEADER_VLAN;
+		flow->matches[cnt].field = HEADER_VLAN_VID;
+		flow->matches[cnt].mask_type = NET_FLOW_MASK_TYPE_LPM;
+		flow->matches[cnt].type = NET_FLOW_FIELD_REF_ATTR_TYPE_U16;
+		flow->matches[cnt].value_u16 = ntohs(key->vlan.vlan_id);
+		flow->matches[cnt].mask_u16 = ntohs(key->vlan.vlan_id_mask);
+		cnt++;
+	}
+	memset(&flow->matches[cnt], 0, sizeof(flow->matches[cnt]));
+
+	flow->actions = kcalloc(2,
+				sizeof(struct net_flow_action),
+				GFP_KERNEL);
+	if (!flow->actions) {
+		kfree(flow->matches);
+		return -ENOMEM;
+	}
+
+	flow->actions[0].args = kcalloc(2, sizeof(struct net_flow_action_arg),
+					GFP_KERNEL);
+	if (!flow->actions[0].args) {
+		kfree(flow->matches);
+		kfree(flow->actions);
+		return -ENOMEM;
+	}
+
+	flow->actions[0].uid = ACTION_SET_VLAN_ID;
+	flow->actions[0].args[0].type = NET_FLOW_ACTION_ARG_TYPE_U16;
+	flow->actions[0].args[0].value_u16 = ntohs(key->vlan.new_vlan_id);
+
+	memset(&flow->actions[1], 0, sizeof(flow->actions[1]));
+	memset(&flow->actions[0].args[1], 0,
+	       sizeof(struct net_flow_action_arg));
+
+	return 0;
+}
+
+static int rocker_term_to_flow(struct rocker_flow_tbl_key *key,
+			       struct net_flow_flow *flow)
+{
+	int cnt = 0;
+
+	if (key->term_mac.in_lport)
+		cnt++;
+	if (key->term_mac.eth_type)
+		cnt++;
+	if (key->term_mac.eth_dst)
+		cnt++;
+	if (key->term_mac.vlan_id)
+		cnt++;
+
+	flow->matches = kcalloc((cnt + 1), sizeof(struct net_flow_field_ref),
+				GFP_KERNEL);
+	if (!flow->matches)
+		return -ENOMEM;
+
+	cnt = 0;
+	if (key->term_mac.in_lport) {
+		flow->matches[cnt].instance = HEADER_INSTANCE_IN_LPORT;
+		flow->matches[cnt].header = HEADER_METADATA;
+		flow->matches[cnt].field = HEADER_METADATA_IN_LPORT;
+		flow->matches[cnt].mask_type = NET_FLOW_MASK_TYPE_LPM;
+		flow->matches[cnt].type = NET_FLOW_FIELD_REF_ATTR_TYPE_U32;
+		flow->matches[cnt].value_u32 = key->term_mac.in_lport;
+		flow->matches[cnt].mask_u32 = key->term_mac.in_lport;
+		cnt++;
+	}
+
+	if (key->term_mac.eth_type) {
+		flow->matches[cnt].instance = HEADER_INSTANCE_ETHERNET;
+		flow->matches[cnt].header = HEADER_ETHERNET;
+		flow->matches[cnt].field = HEADER_ETHERNET_ETHERTYPE;
+		flow->matches[cnt].mask_type = NET_FLOW_MASK_TYPE_EXACT;
+		flow->matches[cnt].type = NET_FLOW_FIELD_REF_ATTR_TYPE_U16;
+		flow->matches[cnt].value_u16 = ntohs(key->term_mac.eth_type);
+		cnt++;
+	}
+
+	if (key->term_mac.eth_dst) {
+		flow->matches[cnt].instance = HEADER_INSTANCE_ETHERNET;
+		flow->matches[cnt].header = HEADER_ETHERNET;
+		flow->matches[cnt].field = HEADER_ETHERNET_DST_MAC;
+		flow->matches[cnt].mask_type = NET_FLOW_MASK_TYPE_LPM;
+		flow->matches[cnt].type = NET_FLOW_FIELD_REF_ATTR_TYPE_U64;
+		memcpy(&flow->matches[cnt].value_u64,
+		       key->term_mac.eth_dst, ETH_ALEN);
+		memcpy(&flow->matches[cnt].mask_u64,
+		       key->term_mac.eth_dst_mask, ETH_ALEN);
+		cnt++;
+	}
+
+	if (key->term_mac.vlan_id) {
+		flow->matches[cnt].instance = HEADER_INSTANCE_VLAN_OUTER;
+		flow->matches[cnt].header = HEADER_VLAN;
+		flow->matches[cnt].field = HEADER_VLAN_VID;
+		flow->matches[cnt].mask_type = NET_FLOW_MASK_TYPE_LPM;
+		flow->matches[cnt].type = NET_FLOW_FIELD_REF_ATTR_TYPE_U16;
+		flow->matches[cnt].value_u16 = ntohs(key->term_mac.vlan_id);
+		flow->matches[cnt].mask_u16 = ntohs(key->term_mac.vlan_id_mask);
+		cnt++;
+	}
+
+	memset(&flow->matches[cnt], 0, sizeof(flow->matches[cnt]));
+
+	flow->actions = kmalloc(2 * sizeof(struct net_flow_action), GFP_KERNEL);
+	if (!flow->actions) {
+		kfree(flow->matches);
+		return -ENOMEM;
+	}
+
+	flow->actions[0].args = NULL;
+	flow->actions[0].uid = ACTION_COPY_TO_CPU;
+	memset(&flow->actions[1], 0, sizeof(flow->actions[1]));
+
+	return 0;
+}
+
+static int rocker_ucast_to_flow(struct rocker_flow_tbl_key *key,
+				struct net_flow_flow *flow)
+{
+	int cnt = 0;
+
+	if (key->ucast_routing.eth_type)
+		cnt++;
+	if (key->ucast_routing.dst4)
+		cnt++;
+
+	flow->matches = kcalloc((cnt + 1), sizeof(struct net_flow_field_ref),
+				GFP_KERNEL);
+	if (!flow->matches)
+		return -ENOMEM;
+
+	cnt = 0;
+
+	if (key->ucast_routing.eth_type) {
+		flow->matches[cnt].instance = HEADER_INSTANCE_ETHERNET;
+		flow->matches[cnt].header = HEADER_ETHERNET;
+		flow->matches[cnt].field = HEADER_ETHERNET_ETHERTYPE;
+		flow->matches[cnt].mask_type = NET_FLOW_MASK_TYPE_EXACT;
+		flow->matches[cnt].type = NET_FLOW_FIELD_REF_ATTR_TYPE_U16;
+		flow->matches[cnt].value_u16 =
+				ntohs(key->ucast_routing.eth_type);
+		cnt++;
+	}
+
+	if (key->ucast_routing.dst4) {
+		flow->matches[cnt].instance = HEADER_INSTANCE_IPV4;
+		flow->matches[cnt].header = HEADER_IPV4;
+		flow->matches[cnt].field = HEADER_IPV4_DST_IP;
+		flow->matches[cnt].mask_type = NET_FLOW_MASK_TYPE_LPM;
+		flow->matches[cnt].type = NET_FLOW_FIELD_REF_ATTR_TYPE_U32;
+		flow->matches[cnt].value_u32 = key->ucast_routing.dst4;
+		flow->matches[cnt].mask_u32 = key->ucast_routing.dst4_mask;
+		cnt++;
+	}
+
+	memset(&flow->matches[cnt], 0, sizeof(flow->matches[cnt]));
+
+	flow->actions = kmalloc(2 * sizeof(struct net_flow_action), GFP_KERNEL);
+	if (!flow->actions) {
+		kfree(flow->matches);
+		return -ENOMEM;
+	}
+
+	flow->actions[0].args = kcalloc(2, sizeof(struct net_flow_action_arg),
+					GFP_KERNEL);
+	if (!flow->actions[0].args) {
+		kfree(flow->matches);
+		kfree(flow->actions);
+		return -ENOMEM;
+	}
+
+	flow->actions[0].uid = ACTION_SET_L3_UNICAST_GROUP_ID;
+	flow->actions[0].args[0].type = NET_FLOW_ACTION_ARG_TYPE_U32;
+	flow->actions[0].args[0].value_u32 = key->ucast_routing.group_id;
+
+	memset(&flow->actions[1], 0, sizeof(flow->actions[1]));
+	memset(&flow->actions[0].args[1], 0,
+	       sizeof(struct net_flow_action_arg));
+
+	return 0;
+}
+
+static int rocker_bridge_to_flow(struct rocker_flow_tbl_key *key,
+				 struct net_flow_flow *flow)
+{
+	int cnt = 0;
+
+	if (key->bridge.eth_dst)
+		cnt++;
+	if (key->bridge.vlan_id)
+		cnt++;
+
+	flow->matches = kcalloc((cnt + 1), sizeof(struct net_flow_field_ref),
+				GFP_KERNEL);
+	if (!flow->matches)
+		return -ENOMEM;
+
+	cnt = 0;
+
+	if (key->bridge.eth_dst) {
+		flow->matches[cnt].instance = HEADER_INSTANCE_ETHERNET;
+		flow->matches[cnt].header = HEADER_ETHERNET;
+		flow->matches[cnt].field = HEADER_ETHERNET_DST_MAC;
+		flow->matches[cnt].mask_type = NET_FLOW_MASK_TYPE_LPM;
+		flow->matches[cnt].type = NET_FLOW_FIELD_REF_ATTR_TYPE_U64;
+		memcpy(&flow->matches[cnt].value_u64,
+		       key->bridge.eth_dst, ETH_ALEN);
+		memcpy(&flow->matches[cnt].mask_u64,
+		       key->bridge.eth_dst_mask, ETH_ALEN);
+		cnt++;
+	}
+
+	if (key->bridge.vlan_id) {
+		flow->matches[cnt].instance = HEADER_INSTANCE_VLAN_OUTER;
+		flow->matches[cnt].header = HEADER_VLAN;
+		flow->matches[cnt].field = HEADER_VLAN_VID;
+		flow->matches[cnt].mask_type = NET_FLOW_MASK_TYPE_EXACT;
+		flow->matches[cnt].type = NET_FLOW_FIELD_REF_ATTR_TYPE_U16;
+		flow->matches[cnt].value_u16 = ntohs(key->bridge.vlan_id);
+		cnt++;
+	}
+
+	memset(&flow->matches[cnt], 0, sizeof(flow->matches[cnt]));
+
+	cnt = 0;
+	if (key->bridge.group_id)
+		cnt++;
+	if (key->bridge.copy_to_cpu)
+		cnt++;
+
+	flow->actions = kcalloc((cnt + 1), sizeof(struct net_flow_action),
+				GFP_KERNEL);
+	if (!flow->actions) {
+		kfree(flow->matches);
+		return -ENOMEM;
+	}
+
+	cnt = 0;
+	if (key->bridge.group_id) {
+		flow->actions[cnt].args =
+				kcalloc(2,
+					sizeof(struct net_flow_action_arg),
+					GFP_KERNEL);
+		if (!flow->actions[cnt].args) {
+			kfree(flow->matches);
+			kfree(flow->actions);
+			return -ENOMEM;
+		}
+
+		flow->actions[cnt].uid = ACTION_SET_L3_UNICAST_GROUP_ID;
+		flow->actions[cnt].args[0].type = NET_FLOW_ACTION_ARG_TYPE_U32;
+		flow->actions[cnt].args[0].value_u32 = key->bridge.group_id;
+		cnt++;
+	}
+
+	if (key->bridge.copy_to_cpu) {
+		flow->actions[cnt].uid = ACTION_COPY_TO_CPU;
+		flow->actions[cnt].args = NULL;
+		cnt++;
+	}
+
+	memset(&flow->actions[cnt], 0, sizeof(flow->actions[1]));
+	return 0;
+}
+
+static int rocker_acl_to_flow(struct rocker_flow_tbl_key *key,
+			      struct net_flow_flow *flow)
+{
+	int cnt = 0;
+
+	if (key->acl.in_lport)
+		cnt++;
+	if (key->acl.eth_src)
+		cnt++;
+	if (key->acl.eth_dst)
+		cnt++;
+	if (key->acl.eth_type)
+		cnt++;
+	if (key->acl.vlan_id)
+		cnt++;
+	if (key->acl.ip_proto)
+		cnt++;
+	if (key->acl.ip_tos)
+		cnt++;
+
+	flow->matches = kcalloc((cnt + 1), sizeof(struct net_flow_field_ref),
+				GFP_KERNEL);
+	if (!flow->matches)
+		return -ENOMEM;
+
+	cnt = 0;
+
+	if (key->acl.in_lport) {
+		flow->matches[cnt].instance = HEADER_INSTANCE_IN_LPORT;
+		flow->matches[cnt].header = HEADER_METADATA;
+		flow->matches[cnt].field = HEADER_METADATA_IN_LPORT;
+		flow->matches[cnt].mask_type = NET_FLOW_MASK_TYPE_LPM;
+		flow->matches[cnt].type = NET_FLOW_FIELD_REF_ATTR_TYPE_U32;
+		flow->matches[cnt].value_u32 = key->acl.in_lport;
+		flow->matches[cnt].mask_u32 = key->acl.in_lport_mask;
+		cnt++;
+	}
+
+	if (key->acl.eth_src) {
+		flow->matches[cnt].instance = HEADER_INSTANCE_ETHERNET;
+		flow->matches[cnt].header = HEADER_ETHERNET;
+		flow->matches[cnt].field = HEADER_ETHERNET_SRC_MAC;
+		flow->matches[cnt].mask_type = NET_FLOW_MASK_TYPE_LPM;
+		flow->matches[cnt].type = NET_FLOW_FIELD_REF_ATTR_TYPE_U64;
+		flow->matches[cnt].value_u64 = *key->acl.eth_src;
+		flow->matches[cnt].mask_u64 = *key->acl.eth_src_mask;
+		cnt++;
+	}
+
+	if (key->acl.eth_dst) {
+		flow->matches[cnt].instance = HEADER_INSTANCE_ETHERNET;
+		flow->matches[cnt].header = HEADER_ETHERNET;
+		flow->matches[cnt].field = HEADER_ETHERNET_DST_MAC;
+		flow->matches[cnt].mask_type = NET_FLOW_MASK_TYPE_LPM;
+		flow->matches[cnt].type = NET_FLOW_FIELD_REF_ATTR_TYPE_U64;
+		memcpy(&flow->matches[cnt].value_u64,
+		       key->acl.eth_dst, ETH_ALEN);
+		memcpy(&flow->matches[cnt].mask_u64,
+		       key->acl.eth_dst_mask, ETH_ALEN);
+		cnt++;
+	}
+
+	if (key->acl.eth_type) {
+		flow->matches[cnt].instance = HEADER_INSTANCE_ETHERNET;
+		flow->matches[cnt].header = HEADER_ETHERNET;
+		flow->matches[cnt].field = HEADER_ETHERNET_ETHERTYPE;
+		flow->matches[cnt].mask_type = NET_FLOW_MASK_TYPE_EXACT;
+		flow->matches[cnt].type = NET_FLOW_FIELD_REF_ATTR_TYPE_U16;
+		flow->matches[cnt].value_u16 = ntohs(key->acl.eth_type);
+		cnt++;
+	}
+
+	if (key->acl.vlan_id) {
+		flow->matches[cnt].instance = HEADER_INSTANCE_VLAN_OUTER;
+		flow->matches[cnt].header = HEADER_VLAN;
+		flow->matches[cnt].field = HEADER_VLAN_VID;
+		flow->matches[cnt].mask_type = NET_FLOW_MASK_TYPE_EXACT;
+		flow->matches[cnt].type = NET_FLOW_FIELD_REF_ATTR_TYPE_U16;
+		flow->matches[cnt].value_u16 = ntohs(key->acl.vlan_id);
+		cnt++;
+	}
+
+	if (key->acl.ip_proto) {
+		flow->matches[cnt].instance = HEADER_INSTANCE_IPV4;
+		flow->matches[cnt].header = HEADER_IPV4;
+		flow->matches[cnt].field = HEADER_IPV4_PROTOCOL;
+		flow->matches[cnt].mask_type = NET_FLOW_MASK_TYPE_LPM;
+		flow->matches[cnt].type = NET_FLOW_FIELD_REF_ATTR_TYPE_U8;
+		flow->matches[cnt].value_u8 = key->acl.ip_proto;
+		flow->matches[cnt].mask_u8 = key->acl.ip_proto_mask;
+		cnt++;
+	}
+
+	if (key->acl.ip_tos) {
+		flow->matches[cnt].instance = HEADER_INSTANCE_IPV4;
+		flow->matches[cnt].header = HEADER_IPV4;
+		flow->matches[cnt].field = HEADER_IPV4_DSCP;
+		flow->matches[cnt].mask_type = NET_FLOW_MASK_TYPE_LPM;
+		flow->matches[cnt].type = NET_FLOW_FIELD_REF_ATTR_TYPE_U8;
+		flow->matches[cnt].value_u8 = key->acl.ip_tos;
+		flow->matches[cnt].mask_u8 = key->acl.ip_tos_mask;
+		cnt++;
+	}
+
+	memset(&flow->matches[cnt], 0, sizeof(flow->matches[cnt]));
+
+	flow->actions = kcalloc(2,
+				sizeof(struct net_flow_action),
+				GFP_KERNEL);
+	if (!flow->actions) {
+		kfree(flow->matches);
+		return -ENOMEM;
+	}
+
+	flow->actions[0].args = kcalloc(2,
+					sizeof(struct net_flow_action_arg),
+					GFP_KERNEL);
+	if (!flow->actions[0].args) {
+		kfree(flow->matches);
+		kfree(flow->actions);
+		return -ENOMEM;
+	}
+
+	flow->actions[0].uid = ACTION_SET_L3_UNICAST_GROUP_ID;
+	flow->actions[0].args[0].type = NET_FLOW_ACTION_ARG_TYPE_U32;
+	flow->actions[0].args[0].value_u32 = key->acl.group_id;
+
+	memset(&flow->actions[0].args[1], 0,
+	       sizeof(struct net_flow_action_arg));
+	memset(&flow->actions[1], 0, sizeof(flow->actions[1]));
+	return 0;
+}
+
+static int rocker_l3_unicast_to_flow(struct rocker_group_tbl_entry *entry,
+				     struct net_flow_flow *flow)
+{
+	int cnt = 0;
+
+	flow->matches = kcalloc(2, sizeof(struct net_flow_field_ref),
+				GFP_KERNEL);
+	if (!flow->matches)
+		return -ENOMEM;
+
+	flow->matches[0].instance = HEADER_INSTANCE_L3_UNICAST_GROUP_ID;
+	flow->matches[0].header = HEADER_METADATA;
+	flow->matches[0].field = HEADER_METADATA_L3_UNICAST_GROUP_ID;
+	flow->matches[0].mask_type = NET_FLOW_MASK_TYPE_EXACT;
+	flow->matches[0].type = NET_FLOW_FIELD_REF_ATTR_TYPE_U32;
+	flow->matches[0].value_u32 = ~ROCKER_GROUP_TYPE_MASK & entry->group_id;
+
+	memset(&flow->matches[1], 0, sizeof(flow->matches[cnt]));
+
+	if (entry->l3_unicast.eth_src)
+		cnt++;
+	if (entry->l3_unicast.eth_dst)
+		cnt++;
+	if (entry->l3_unicast.vlan_id)
+		cnt++;
+	if (entry->l3_unicast.ttl_check)
+		cnt++;
+	if (entry->l3_unicast.group_id)
+		cnt++;
+
+	flow->actions = kcalloc(cnt, sizeof(struct net_flow_action),
+				GFP_KERNEL);
+	if (!flow->actions) {
+		kfree(flow->matches);
+		return -ENOMEM;
+	}
+
+	cnt = 0;
+
+	if (entry->l3_unicast.eth_src) {
+		flow->actions[cnt].args =
+				kcalloc(2,
+					sizeof(struct net_flow_action_arg),
+					GFP_KERNEL);
+
+		if (!flow->actions[cnt].args)
+			goto unwind_args;
+
+		flow->actions[cnt].uid = ACTION_SET_ETH_SRC;
+		flow->actions[cnt].args[0].type = NET_FLOW_ACTION_ARG_TYPE_U64;
+		ether_addr_copy(flow->actions[cnt].args[0].value_u64,
+				entry->l3_unicast.eth_src);
+		memset(&flow->actions[0].args[1], 0,
+		       sizeof(struct net_flow_action_arg));
+		cnt++;
+	}
+
+	if (entry->l3_unicast.eth_dst) {
+		flow->actions[cnt].args =
+			kcalloc(2,
+				sizeof(struct net_flow_action_arg),
+				GFP_KERNEL);
+
+		if (!flow->actions[cnt].args)
+			goto unwind_args;
+
+		flow->actions[cnt].uid = ACTION_SET_ETH_DST;
+		flow->actions[cnt].args[0].type = NET_FLOW_ACTION_ARG_TYPE_U64;
+		ether_addr_copy(&flow->actions[cnt].args[0].value_u64,
+				entry->l3_unicast.eth_dst);
+		memset(&flow->actions[0].args[1], 0,
+		       sizeof(struct net_flow_action_arg));
+		cnt++;
+	}
+
+	if (entry->l3_unicast.vlan_id) {
+		flow->actions[cnt].args =
+				kcalloc(2,
+					sizeof(struct net_flow_action_arg),
+					GFP_KERNEL);
+
+		if (!flow->actions[cnt].args)
+			goto unwind_args;
+
+		flow->actions[cnt].uid = ACTION_SET_VLAN_ID;
+		flow->actions[cnt].args[0].type = NET_FLOW_ACTION_ARG_TYPE_U16;
+		flow->actions[cnt].args[0].value_u16 =
+					ntohs(entry->l3_unicast.vlan_id);
+		memset(&flow->actions[0].args[1], 0,
+		       sizeof(struct net_flow_action_arg));
+		cnt++;
+	}
+
+	if (entry->l3_unicast.ttl_check) {
+		flow->actions[cnt].uid = ACTION_CHECK_TTL_DROP;
+		flow->actions[cnt].args = NULL;
+		cnt++;
+	}
+
+	if (entry->l3_unicast.group_id) {
+		flow->actions[cnt].args =
+				kcalloc(2,
+					sizeof(struct net_flow_action_arg),
+					GFP_KERNEL);
+
+		if (!flow->actions[cnt].args)
+			goto unwind_args;
+
+		flow->actions[cnt].uid = ACTION_SET_L2_GROUP_ID;
+		flow->actions[cnt].args[0].type = NET_FLOW_ACTION_ARG_TYPE_U32;
+		flow->actions[cnt].args[0].value_u32 =
+						entry->l3_unicast.group_id;
+		memset(&flow->actions[0].args[1], 0,
+		       sizeof(struct net_flow_action_arg));
+		cnt++;
+	}
+
+	memset(&flow->actions[cnt], 0, sizeof(flow->actions[cnt]));
+	return 0;
+unwind_args:
+	kfree(flow->matches);
+	for (cnt--; cnt >= 0; cnt--)
+		kfree(flow->actions[cnt].args);
+	kfree(flow->actions);
+	return -ENOMEM;
+}
+
+static int rocker_l2_rewrite_to_flow(struct rocker_group_tbl_entry *entry,
+				     struct net_flow_flow *flow)
+{
+	int cnt = 0;
+
+	flow->matches = kcalloc(2, sizeof(struct net_flow_field_ref),
+				GFP_KERNEL);
+	if (!flow->matches)
+		return -ENOMEM;
+
+	flow->matches[0].instance = HEADER_INSTANCE_L2_REWRITE_GROUP_ID;
+	flow->matches[0].header = HEADER_METADATA;
+	flow->matches[0].field = HEADER_METADATA_L2_REWRITE_GROUP_ID;
+	flow->matches[0].mask_type = NET_FLOW_MASK_TYPE_EXACT;
+	flow->matches[0].type = NET_FLOW_FIELD_REF_ATTR_TYPE_U32;
+	flow->matches[0].value_u32 = ~ROCKER_GROUP_TYPE_MASK & entry->group_id;
+
+	memset(&flow->matches[1], 0, sizeof(flow->matches[cnt]));
+
+	if (entry->l2_rewrite.eth_src)
+		cnt++;
+	if (entry->l2_rewrite.eth_dst)
+		cnt++;
+	if (entry->l2_rewrite.vlan_id)
+		cnt++;
+	if (entry->l2_rewrite.group_id)
+		cnt++;
+
+	flow->actions = kcalloc(cnt, sizeof(struct net_flow_action),
+				GFP_KERNEL);
+	if (!flow->actions) {
+		kfree(flow->matches);
+		return -ENOMEM;
+	}
+
+	cnt = 0;
+
+	if (entry->l2_rewrite.eth_src) {
+		flow->actions[cnt].args =
+			kmalloc(2 * sizeof(struct net_flow_action_arg),
+				GFP_KERNEL);
+
+		if (!flow->actions[cnt].args)
+			goto unwind_args;
+
+		flow->actions[cnt].uid = ACTION_SET_ETH_SRC;
+		flow->actions[cnt].args[0].type = NET_FLOW_ACTION_ARG_TYPE_U64;
+		ether_addr_copy(flow->actions[cnt].args[0].value_u64,
+				entry->l2_rewrite.eth_src);
+		memset(&flow->actions[0].args[1], 0,
+		       sizeof(struct net_flow_action_arg));
+		cnt++;
+	}
+
+	if (entry->l2_rewrite.eth_dst) {
+		flow->actions[cnt].args =
+			kmalloc(2 * sizeof(struct net_flow_action_arg),
+				GFP_KERNEL);
+
+		if (!flow->actions[cnt].args)
+			goto unwind_args;
+
+		flow->actions[cnt].uid = ACTION_SET_ETH_DST;
+		flow->actions[cnt].args[0].type = NET_FLOW_ACTION_ARG_TYPE_U64;
+		ether_addr_copy(&flow->actions[cnt].args[0].value_u64,
+				entry->l2_rewrite.eth_dst);
+		memset(&flow->actions[0].args[1], 0,
+		       sizeof(struct net_flow_action_arg));
+		cnt++;
+	}
+
+	if (entry->l2_rewrite.vlan_id) {
+		flow->actions[cnt].args =
+			kmalloc(2 * sizeof(struct net_flow_action_arg),
+				GFP_KERNEL);
+
+		if (!flow->actions[cnt].args)
+			goto unwind_args;
+
+		flow->actions[cnt].uid = ACTION_SET_VLAN_ID;
+		flow->actions[cnt].args[0].type = NET_FLOW_ACTION_ARG_TYPE_U16;
+		flow->actions[cnt].args[0].value_u16 =
+					ntohs(entry->l2_rewrite.vlan_id);
+		memset(&flow->actions[0].args[1], 0,
+		       sizeof(struct net_flow_action_arg));
+		cnt++;
+	}
+
+	if (entry->l2_rewrite.group_id) {
+		flow->actions[cnt].args =
+			kmalloc(2 * sizeof(struct net_flow_action_arg),
+				GFP_KERNEL);
+
+		if (!flow->actions[cnt].args)
+			goto unwind_args;
+
+		flow->actions[cnt].uid = ACTION_SET_L2_GROUP_ID;
+		flow->actions[cnt].args[0].type = NET_FLOW_ACTION_ARG_TYPE_U32;
+		flow->actions[cnt].args[0].value_u32 =
+			entry->l2_rewrite.group_id;
+		memset(&flow->actions[0].args[1], 0,
+		       sizeof(struct net_flow_action_arg));
+		cnt++;
+	}
+
+	memset(&flow->actions[cnt], 0, sizeof(flow->actions[cnt]));
+	return 0;
+unwind_args:
+	kfree(flow->matches);
+	for (cnt--; cnt >= 0; cnt--)
+		kfree(flow->actions[cnt].args);
+	kfree(flow->actions);
+	return -ENOMEM;
+}
+
+static int rocker_l2_interface_to_flow(struct rocker_group_tbl_entry *entry,
+				       struct net_flow_flow *flow)
+{
+	flow->matches = kmalloc(2 * sizeof(struct net_flow_field_ref),
+				GFP_KERNEL);
+	if (!flow->matches)
+		return -ENOMEM;
+
+	flow->matches[0].instance = HEADER_INSTANCE_L2_GROUP_ID;
+	flow->matches[0].header = HEADER_METADATA;
+	flow->matches[0].field = HEADER_METADATA_L2_GROUP_ID;
+	flow->matches[0].mask_type = NET_FLOW_MASK_TYPE_EXACT;
+	flow->matches[0].type = NET_FLOW_FIELD_REF_ATTR_TYPE_U32;
+	flow->matches[0].value_u32 = ~ROCKER_GROUP_TYPE_MASK & entry->group_id;
+
+	memset(&flow->matches[1], 0, sizeof(flow->matches[1]));
+
+	if (!entry->l2_interface.pop_vlan) {
+		flow->actions = NULL;
+		return 0;
+	}
+
+	flow->actions = kmalloc(2 * sizeof(struct net_flow_action), GFP_KERNEL);
+	if (!flow->actions) {
+		kfree(flow->matches);
+		return -ENOMEM;
+	}
+
+	if (entry->l2_interface.pop_vlan) {
+		flow->actions[0].uid = ACTION_POP_VLAN;
+		flow->actions[0].args = NULL;
+	}
+
+	memset(&flow->actions[1], 0, sizeof(flow->actions[1]));
+	return 0;
+}
+
+static int rocker_get_flows(struct sk_buff *skb, struct net_device *dev,
+			    int table, int min, int max)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	struct net_flow_flow flow;
+	struct rocker_flow_tbl_entry *entry;
+	struct rocker_group_tbl_entry *group;
+	struct hlist_node *tmp;
+	unsigned long flags;
+	int bkt, err;
+
+	spin_lock_irqsave(&rocker_port->rocker->flow_tbl_lock, flags);
+	hash_for_each_safe(rocker_port->rocker->flow_tbl,
+			   bkt, tmp, entry, entry) {
+		struct rocker_flow_tbl_key *key = &entry->key;
+
+		if (rocker_goto_value(table) != key->tbl_id)
+			continue;
+
+		flow.table_id = table;
+		flow.uid = entry->cookie;
+		flow.priority = key->priority;
+
+		switch (table) {
+		case ROCKER_FLOW_TABLE_ID_INGRESS_PORT:
+			err = rocker_ig_port_to_flow(key, &flow);
+			if (err)
+				return err;
+			break;
+		case ROCKER_FLOW_TABLE_ID_VLAN:
+			err = rocker_vlan_to_flow(key, &flow);
+			if (err)
+				return err;
+			break;
+		case ROCKER_FLOW_TABLE_ID_TERMINATION_MAC:
+			err = rocker_term_to_flow(key, &flow);
+			break;
+		case ROCKER_FLOW_TABLE_ID_UNICAST_ROUTING:
+			err = rocker_ucast_to_flow(key, &flow);
+			break;
+		case ROCKER_FLOW_TABLE_ID_BRIDGING:
+			err = rocker_bridge_to_flow(key, &flow);
+			break;
+		case ROCKER_FLOW_TABLE_ID_ACL_POLICY:
+			err = rocker_acl_to_flow(key, &flow);
+			break;
+		default:
+			continue;
+		}
+
+		net_flow_put_flow(skb, &flow);
+	}
+	spin_unlock_irqrestore(&rocker_port->rocker->flow_tbl_lock, flags);
+
+	spin_lock_irqsave(&rocker_port->rocker->group_tbl_lock, flags);
+	hash_for_each_safe(rocker_port->rocker->group_tbl,
+			   bkt, tmp, group, entry) {
+		if (rocker_goto_value(table) !=
+			ROCKER_GROUP_TYPE_GET(group->group_id))
+			continue;
+
+		flow.table_id = table;
+		flow.uid = group->group_id;
+		flow.priority = 1;
+
+		switch (table) {
+		case ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L3_UNICAST:
+			err = rocker_l3_unicast_to_flow(group, &flow);
+			break;
+		case ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L2_REWRITE:
+			err = rocker_l2_rewrite_to_flow(group, &flow);
+			break;
+		case ROCKER_FLOW_TABLE_ID_GROUP_SLICE_L2:
+			err = rocker_l2_interface_to_flow(group, &flow);
+			break;
+		default:
+			continue;
+		}
+
+		net_flow_put_flow(skb, &flow);
+	}
+	spin_unlock_irqrestore(&rocker_port->rocker->group_tbl_lock, flags);
+
+	return 0;
+}
 #endif
 
 static const struct net_device_ops rocker_port_netdev_ops = {
@@ -4517,6 +5335,7 @@ static const struct net_device_ops rocker_port_netdev_ops = {
 
 	.ndo_flow_set_flows		= rocker_set_flows,
 	.ndo_flow_del_flows		= rocker_del_flows,
+	.ndo_flow_get_flows		= rocker_get_flows,
 #endif
 };
 
