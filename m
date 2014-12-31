From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v1 09/11] net: rocker: add cookie to group acls and
 use flow_id to set cookie
Date: Wed, 31 Dec 2014 11:49:21 -0800
Message-ID: <20141231194919.31070.47552.stgit@nitbit.x32>
References: <20141231194057.31070.5244.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net
To: tgraf@suug.ch, sfeldma@gmail.com, jiri@resnulli.us,
	jhs@mojatatu.com, simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:38279 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026AbaLaTts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 14:49:48 -0500
Received: by mail-ob0-f174.google.com with SMTP id nt9so54542880obb.5
        for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 11:49:47 -0800 (PST)
In-Reply-To: <20141231194057.31070.5244.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rocker uses a cookie value to identify flows however the flow API
already has a unique id for each flow. To help the translation
add support to set the cookie value through the internal rocker
flow API and then use the unique id in the cases where it is
available.

This patch extends the internal code paths to support the new
cookie value.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/ethernet/rocker/rocker.c |   64 ++++++++++++++++++++++------------
 1 file changed, 42 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 997beb9..4d2d292 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -120,6 +120,7 @@ struct rocker_flow_tbl_entry {
 
 struct rocker_group_tbl_entry {
 	struct hlist_node entry;
+	u64 cookie;
 	u32 cmd;
 	u32 group_id; /* key */
 	u16 group_count;
@@ -2216,7 +2217,8 @@ static int rocker_flow_tbl_add(struct rocker_port *rocker_port,
 		kfree(match);
 	} else {
 		found = match;
-		found->cookie = rocker->flow_tbl_next_cookie++;
+		if (!found->cookie)
+			found->cookie = rocker->flow_tbl_next_cookie++;
 		hash_add(rocker->flow_tbl, &found->entry, found->key_crc32);
 		add_to_hw = true;
 	}
@@ -2294,7 +2296,7 @@ static int rocker_flow_tbl_do(struct rocker_port *rocker_port,
 		return rocker_flow_tbl_add(rocker_port, entry, nowait);
 }
 
-static int rocker_flow_tbl_ig_port(struct rocker_port *rocker_port,
+static int rocker_flow_tbl_ig_port(struct rocker_port *rocker_port, u64 flow_id,
 				   int flags, u32 in_lport, u32 in_lport_mask,
 				   enum rocker_of_dpa_table_id goto_tbl)
 {
@@ -2310,11 +2312,14 @@ static int rocker_flow_tbl_ig_port(struct rocker_port *rocker_port,
 	entry->key.ig_port.in_lport_mask = in_lport_mask;
 	entry->key.ig_port.goto_tbl = goto_tbl;
 
+	if (flow_id)
+		entry->cookie = flow_id;
+
 	return rocker_flow_tbl_do(rocker_port, flags, entry);
 }
 
 static int rocker_flow_tbl_vlan(struct rocker_port *rocker_port,
-				int flags, u32 in_lport,
+				int flags, u64 flow_id, u32 in_lport,
 				__be16 vlan_id, __be16 vlan_id_mask,
 				enum rocker_of_dpa_table_id goto_tbl,
 				bool untagged, __be16 new_vlan_id)
@@ -2335,10 +2340,14 @@ static int rocker_flow_tbl_vlan(struct rocker_port *rocker_port,
 	entry->key.vlan.untagged = untagged;
 	entry->key.vlan.new_vlan_id = new_vlan_id;
 
+	if (flow_id)
+		entry->cookie = flow_id;
+
 	return rocker_flow_tbl_do(rocker_port, flags, entry);
 }
 
 static int rocker_flow_tbl_term_mac(struct rocker_port *rocker_port,
+				    u64 flow_id,
 				    u32 in_lport, u32 in_lport_mask,
 				    __be16 eth_type, const u8 *eth_dst,
 				    const u8 *eth_dst_mask, __be16 vlan_id,
@@ -2371,11 +2380,14 @@ static int rocker_flow_tbl_term_mac(struct rocker_port *rocker_port,
 	entry->key.term_mac.vlan_id_mask = vlan_id_mask;
 	entry->key.term_mac.copy_to_cpu = copy_to_cpu;
 
+	if (flow_id)
+		entry->cookie = flow_id;
+
 	return rocker_flow_tbl_do(rocker_port, flags, entry);
 }
 
 static int rocker_flow_tbl_bridge(struct rocker_port *rocker_port,
-				  int flags,
+				  int flags, u64 flow_id,
 				  const u8 *eth_dst, const u8 *eth_dst_mask,
 				  __be16 vlan_id, u32 tunnel_id,
 				  enum rocker_of_dpa_table_id goto_tbl,
@@ -2425,11 +2437,14 @@ static int rocker_flow_tbl_bridge(struct rocker_port *rocker_port,
 	entry->key.bridge.group_id = group_id;
 	entry->key.bridge.copy_to_cpu = copy_to_cpu;
 
+	if (flow_id)
+		entry->cookie = flow_id;
+
 	return rocker_flow_tbl_do(rocker_port, flags, entry);
 }
 
 static int rocker_flow_tbl_acl(struct rocker_port *rocker_port,
-			       int flags, u32 in_lport,
+			       int flags, u64 flow_id, u32 in_lport,
 			       u32 in_lport_mask,
 			       const u8 *eth_src, const u8 *eth_src_mask,
 			       const u8 *eth_dst, const u8 *eth_dst_mask,
@@ -2477,6 +2492,9 @@ static int rocker_flow_tbl_acl(struct rocker_port *rocker_port,
 	entry->key.acl.ip_tos_mask = ip_tos_mask;
 	entry->key.acl.group_id = group_id;
 
+	if (flow_id)
+		entry->cookie = flow_id;
+
 	return rocker_flow_tbl_do(rocker_port, flags, entry);
 }
 
@@ -2587,7 +2605,7 @@ static int rocker_group_tbl_do(struct rocker_port *rocker_port,
 }
 
 static int rocker_group_l2_interface(struct rocker_port *rocker_port,
-				     int flags, __be16 vlan_id,
+				     int flags, int flow_id, __be16 vlan_id,
 				     u32 out_lport, int pop_vlan)
 {
 	struct rocker_group_tbl_entry *entry;
@@ -2598,6 +2616,7 @@ static int rocker_group_l2_interface(struct rocker_port *rocker_port,
 
 	entry->group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_lport);
 	entry->l2_interface.pop_vlan = pop_vlan;
+	entry->cookie = flow_id;
 
 	return rocker_group_tbl_do(rocker_port, flags, entry);
 }
@@ -2696,7 +2715,7 @@ static int rocker_port_vlan_l2_groups(struct rocker_port *rocker_port,
 	if (rocker_port->stp_state == BR_STATE_LEARNING ||
 	    rocker_port->stp_state == BR_STATE_FORWARDING) {
 		out_lport = rocker_port->lport;
-		err = rocker_group_l2_interface(rocker_port, flags,
+		err = rocker_group_l2_interface(rocker_port, flags, 0,
 						vlan_id, out_lport,
 						pop_vlan);
 		if (err) {
@@ -2722,7 +2741,7 @@ static int rocker_port_vlan_l2_groups(struct rocker_port *rocker_port,
 		return 0;
 
 	out_lport = 0;
-	err = rocker_group_l2_interface(rocker_port, flags,
+	err = rocker_group_l2_interface(rocker_port, flags, 0,
 					vlan_id, out_lport,
 					pop_vlan);
 	if (err) {
@@ -2796,7 +2815,7 @@ static int rocker_port_ctrl_vlan_acl(struct rocker_port *rocker_port,
 	u32 group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_lport);
 	int err;
 
-	err = rocker_flow_tbl_acl(rocker_port, flags,
+	err = rocker_flow_tbl_acl(rocker_port, flags, 0,
 				  in_lport, in_lport_mask,
 				  eth_src, eth_src_mask,
 				  ctrl->eth_dst, ctrl->eth_dst_mask,
@@ -2825,7 +2844,7 @@ static int rocker_port_ctrl_vlan_bridge(struct rocker_port *rocker_port,
 	if (!rocker_port_is_bridged(rocker_port))
 		return 0;
 
-	err = rocker_flow_tbl_bridge(rocker_port, flags,
+	err = rocker_flow_tbl_bridge(rocker_port, flags, 0,
 				     ctrl->eth_dst, ctrl->eth_dst_mask,
 				     vlan_id, tunnel_id,
 				     goto_tbl, group_id, ctrl->copy_to_cpu);
@@ -2847,7 +2866,7 @@ static int rocker_port_ctrl_vlan_term(struct rocker_port *rocker_port,
 	if (ntohs(vlan_id) == 0)
 		vlan_id = rocker_port->internal_vlan_id;
 
-	err = rocker_flow_tbl_term_mac(rocker_port,
+	err = rocker_flow_tbl_term_mac(rocker_port, 0,
 				       rocker_port->lport, in_lport_mask,
 				       ctrl->eth_type, ctrl->eth_dst,
 				       ctrl->eth_dst_mask, vlan_id,
@@ -2961,7 +2980,7 @@ static int rocker_port_vlan(struct rocker_port *rocker_port, int flags,
 		return err;
 	}
 
-	err = rocker_flow_tbl_vlan(rocker_port, flags,
+	err = rocker_flow_tbl_vlan(rocker_port, flags, 0,
 				   in_lport, vlan_id, vlan_id_mask,
 				   goto_tbl, untagged, internal_vlan_id);
 	if (err)
@@ -2986,7 +3005,7 @@ static int rocker_port_ig_tbl(struct rocker_port *rocker_port, int flags)
 	in_lport_mask = 0xffff0000;
 	goto_tbl = ROCKER_OF_DPA_TABLE_ID_VLAN;
 
-	err = rocker_flow_tbl_ig_port(rocker_port, flags,
+	err = rocker_flow_tbl_ig_port(rocker_port, flags, 0,
 				      in_lport, in_lport_mask,
 				      goto_tbl);
 	if (err)
@@ -3036,7 +3055,7 @@ static int rocker_port_fdb_learn(struct rocker_port *rocker_port,
 		group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_lport);
 
 	if (!(flags & ROCKER_OP_FLAG_REFRESH)) {
-		err = rocker_flow_tbl_bridge(rocker_port, flags, addr, NULL,
+		err = rocker_flow_tbl_bridge(rocker_port, flags, 0, addr, NULL,
 					     vlan_id, tunnel_id, goto_tbl,
 					     group_id, copy_to_cpu);
 		if (err)
@@ -3171,7 +3190,7 @@ static int rocker_port_router_mac(struct rocker_port *rocker_port,
 		vlan_id = rocker_port->internal_vlan_id;
 
 	eth_type = htons(ETH_P_IP);
-	err = rocker_flow_tbl_term_mac(rocker_port,
+	err = rocker_flow_tbl_term_mac(rocker_port, 0,
 				       rocker_port->lport, in_lport_mask,
 				       eth_type, rocker_port->dev->dev_addr,
 				       dst_mac_mask, vlan_id, vlan_id_mask,
@@ -3180,7 +3199,7 @@ static int rocker_port_router_mac(struct rocker_port *rocker_port,
 		return err;
 
 	eth_type = htons(ETH_P_IPV6);
-	err = rocker_flow_tbl_term_mac(rocker_port,
+	err = rocker_flow_tbl_term_mac(rocker_port, 0,
 				       rocker_port->lport, in_lport_mask,
 				       eth_type, rocker_port->dev->dev_addr,
 				       dst_mac_mask, vlan_id, vlan_id_mask,
@@ -3215,7 +3234,7 @@ static int rocker_port_fwding(struct rocker_port *rocker_port)
 			continue;
 		vlan_id = htons(vid);
 		pop_vlan = rocker_vlan_id_is_internal(vlan_id);
-		err = rocker_group_l2_interface(rocker_port, flags,
+		err = rocker_group_l2_interface(rocker_port, flags, 0,
 						vlan_id, out_lport,
 						pop_vlan);
 		if (err) {
@@ -3919,7 +3938,7 @@ static int rocker_flow_set_ig_port(struct net_device *dev,
 	in_lport_mask = flow->matches[0].mask_u32;
 	goto_tbl = rocker_goto_value(flow->actions[0].args[0].value_u16);
 
-	err = rocker_flow_tbl_ig_port(rocker_port, flags,
+	err = rocker_flow_tbl_ig_port(rocker_port, flags, 0,
 				      in_lport, in_lport_mask,
 				      goto_tbl);
 	return err;
@@ -3981,7 +4000,7 @@ static int rocker_flow_set_vlan(struct net_device *dev,
 	if (!have_in_lport)
 		return -EINVAL;
 
-	err = rocker_flow_tbl_vlan(rocker_port, flags, in_lport,
+	err = rocker_flow_tbl_vlan(rocker_port, flags, 0, in_lport,
 				   vlan_id, vlan_id_mask, goto_tbl,
 				   untagged, new_vlan_id);
 	return err;
@@ -4063,7 +4082,8 @@ static int rocker_flow_set_term_mac(struct net_device *dev,
 		}
 	}
 
-	err = rocker_flow_tbl_term_mac(rocker_port, in_lport, in_lport_mask,
+	err = rocker_flow_tbl_term_mac(rocker_port, 0,
+				       in_lport, in_lport_mask,
 				       ethtype, eth_dst, eth_dst_mask,
 				       vlan_id, vlan_id_mask,
 				       copy_to_cpu, flags);
@@ -4162,7 +4182,7 @@ static int rocker_flow_set_bridge(struct net_device *dev,
 	}
 
 	/* Ignoring eth_dst_mask it seems to cause a EINVAL return code */
-	err = rocker_flow_tbl_bridge(rocker_port, flags,
+	err = rocker_flow_tbl_bridge(rocker_port, flags, 0,
 				     eth_dst, eth_dst_mask,
 				     vlan_id, tunnel_id,
 				     goto_tbl, group_id, copy_to_cpu);
@@ -4269,7 +4289,7 @@ static int rocker_flow_set_acl(struct net_device *dev,
 		}
 	}
 
-	err = rocker_flow_tbl_acl(rocker_port, flags,
+	err = rocker_flow_tbl_acl(rocker_port, flags, 0,
 				  in_lport, in_lport_mask,
 				  eth_src, eth_src_mask,
 				  eth_dst, eth_dst_mask, ethtype,
