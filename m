From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v3 10/12] net: rocker: add cookie to group acls and
 use flow_id to set cookie
Date: Tue, 20 Jan 2015 12:30:38 -0800
Message-ID: <20150120203036.1741.96969.stgit@nitbit.x32>
References: <20150120202404.1741.8658.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, davem@davemloft.net,
	gerlitz.or@gmail.com, andy@greyhouse.net, ast@plumgrid.com
To: tgraf@suug.ch, simon.horman@netronome.com, sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:48101 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753386AbbATUa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 15:30:58 -0500
Received: by mail-ob0-f178.google.com with SMTP id nt9so5025531obb.9
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 12:30:58 -0800 (PST)
In-Reply-To: <20150120202404.1741.8658.stgit@nitbit.x32>
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
index 2be8f61..5ba46f6 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -120,6 +120,7 @@ struct rocker_flow_tbl_entry {
 
 struct rocker_group_tbl_entry {
 	struct hlist_node entry;
+	u64 cookie;
 	u32 cmd;
 	u32 group_id; /* key */
 	u16 group_count;
@@ -2233,7 +2234,8 @@ static int rocker_flow_tbl_add(struct rocker_port *rocker_port,
 		kfree(match);
 	} else {
 		found = match;
-		found->cookie = rocker->flow_tbl_next_cookie++;
+		if (!found->cookie)
+			found->cookie = rocker->flow_tbl_next_cookie++;
 		hash_add(rocker->flow_tbl, &found->entry, found->key_crc32);
 		add_to_hw = true;
 	}
@@ -2311,7 +2313,7 @@ static int rocker_flow_tbl_do(struct rocker_port *rocker_port,
 		return rocker_flow_tbl_add(rocker_port, entry, nowait);
 }
 
-static int rocker_flow_tbl_ig_port(struct rocker_port *rocker_port,
+static int rocker_flow_tbl_ig_port(struct rocker_port *rocker_port, u64 flow_id,
 				   int flags, u32 in_lport, u32 in_lport_mask,
 				   enum rocker_of_dpa_table_id goto_tbl)
 {
@@ -2327,11 +2329,14 @@ static int rocker_flow_tbl_ig_port(struct rocker_port *rocker_port,
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
@@ -2352,10 +2357,14 @@ static int rocker_flow_tbl_vlan(struct rocker_port *rocker_port,
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
@@ -2388,11 +2397,14 @@ static int rocker_flow_tbl_term_mac(struct rocker_port *rocker_port,
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
@@ -2442,11 +2454,14 @@ static int rocker_flow_tbl_bridge(struct rocker_port *rocker_port,
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
@@ -2494,6 +2509,9 @@ static int rocker_flow_tbl_acl(struct rocker_port *rocker_port,
 	entry->key.acl.ip_tos_mask = ip_tos_mask;
 	entry->key.acl.group_id = group_id;
 
+	if (flow_id)
+		entry->cookie = flow_id;
+
 	return rocker_flow_tbl_do(rocker_port, flags, entry);
 }
 
@@ -2604,7 +2622,7 @@ static int rocker_group_tbl_do(struct rocker_port *rocker_port,
 }
 
 static int rocker_group_l2_interface(struct rocker_port *rocker_port,
-				     int flags, __be16 vlan_id,
+				     int flags, int flow_id, __be16 vlan_id,
 				     u32 out_lport, int pop_vlan)
 {
 	struct rocker_group_tbl_entry *entry;
@@ -2615,6 +2633,7 @@ static int rocker_group_l2_interface(struct rocker_port *rocker_port,
 
 	entry->group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_lport);
 	entry->l2_interface.pop_vlan = pop_vlan;
+	entry->cookie = flow_id;
 
 	return rocker_group_tbl_do(rocker_port, flags, entry);
 }
@@ -2713,7 +2732,7 @@ static int rocker_port_vlan_l2_groups(struct rocker_port *rocker_port,
 	if (rocker_port->stp_state == BR_STATE_LEARNING ||
 	    rocker_port->stp_state == BR_STATE_FORWARDING) {
 		out_lport = rocker_port->lport;
-		err = rocker_group_l2_interface(rocker_port, flags,
+		err = rocker_group_l2_interface(rocker_port, flags, 0,
 						vlan_id, out_lport,
 						pop_vlan);
 		if (err) {
@@ -2739,7 +2758,7 @@ static int rocker_port_vlan_l2_groups(struct rocker_port *rocker_port,
 		return 0;
 
 	out_lport = 0;
-	err = rocker_group_l2_interface(rocker_port, flags,
+	err = rocker_group_l2_interface(rocker_port, flags, 0,
 					vlan_id, out_lport,
 					pop_vlan);
 	if (err) {
@@ -2813,7 +2832,7 @@ static int rocker_port_ctrl_vlan_acl(struct rocker_port *rocker_port,
 	u32 group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_lport);
 	int err;
 
-	err = rocker_flow_tbl_acl(rocker_port, flags,
+	err = rocker_flow_tbl_acl(rocker_port, flags, 0,
 				  in_lport, in_lport_mask,
 				  eth_src, eth_src_mask,
 				  ctrl->eth_dst, ctrl->eth_dst_mask,
@@ -2842,7 +2861,7 @@ static int rocker_port_ctrl_vlan_bridge(struct rocker_port *rocker_port,
 	if (!rocker_port_is_bridged(rocker_port))
 		return 0;
 
-	err = rocker_flow_tbl_bridge(rocker_port, flags,
+	err = rocker_flow_tbl_bridge(rocker_port, flags, 0,
 				     ctrl->eth_dst, ctrl->eth_dst_mask,
 				     vlan_id, tunnel_id,
 				     goto_tbl, group_id, ctrl->copy_to_cpu);
@@ -2864,7 +2883,7 @@ static int rocker_port_ctrl_vlan_term(struct rocker_port *rocker_port,
 	if (ntohs(vlan_id) == 0)
 		vlan_id = rocker_port->internal_vlan_id;
 
-	err = rocker_flow_tbl_term_mac(rocker_port,
+	err = rocker_flow_tbl_term_mac(rocker_port, 0,
 				       rocker_port->lport, in_lport_mask,
 				       ctrl->eth_type, ctrl->eth_dst,
 				       ctrl->eth_dst_mask, vlan_id,
@@ -2978,7 +2997,7 @@ static int rocker_port_vlan(struct rocker_port *rocker_port, int flags,
 		return err;
 	}
 
-	err = rocker_flow_tbl_vlan(rocker_port, flags,
+	err = rocker_flow_tbl_vlan(rocker_port, flags, 0,
 				   in_lport, vlan_id, vlan_id_mask,
 				   goto_tbl, untagged, internal_vlan_id);
 	if (err)
@@ -3003,7 +3022,7 @@ static int rocker_port_ig_tbl(struct rocker_port *rocker_port, int flags)
 	in_lport_mask = 0xffff0000;
 	goto_tbl = ROCKER_OF_DPA_TABLE_ID_VLAN;
 
-	err = rocker_flow_tbl_ig_port(rocker_port, flags,
+	err = rocker_flow_tbl_ig_port(rocker_port, flags, 0,
 				      in_lport, in_lport_mask,
 				      goto_tbl);
 	if (err)
@@ -3053,7 +3072,7 @@ static int rocker_port_fdb_learn(struct rocker_port *rocker_port,
 		group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_lport);
 
 	if (!(flags & ROCKER_OP_FLAG_REFRESH)) {
-		err = rocker_flow_tbl_bridge(rocker_port, flags, addr, NULL,
+		err = rocker_flow_tbl_bridge(rocker_port, flags, 0, addr, NULL,
 					     vlan_id, tunnel_id, goto_tbl,
 					     group_id, copy_to_cpu);
 		if (err)
@@ -3188,7 +3207,7 @@ static int rocker_port_router_mac(struct rocker_port *rocker_port,
 		vlan_id = rocker_port->internal_vlan_id;
 
 	eth_type = htons(ETH_P_IP);
-	err = rocker_flow_tbl_term_mac(rocker_port,
+	err = rocker_flow_tbl_term_mac(rocker_port, 0,
 				       rocker_port->lport, in_lport_mask,
 				       eth_type, rocker_port->dev->dev_addr,
 				       dst_mac_mask, vlan_id, vlan_id_mask,
@@ -3197,7 +3216,7 @@ static int rocker_port_router_mac(struct rocker_port *rocker_port,
 		return err;
 
 	eth_type = htons(ETH_P_IPV6);
-	err = rocker_flow_tbl_term_mac(rocker_port,
+	err = rocker_flow_tbl_term_mac(rocker_port, 0,
 				       rocker_port->lport, in_lport_mask,
 				       eth_type, rocker_port->dev->dev_addr,
 				       dst_mac_mask, vlan_id, vlan_id_mask,
@@ -3232,7 +3251,7 @@ static int rocker_port_fwding(struct rocker_port *rocker_port)
 			continue;
 		vlan_id = htons(vid);
 		pop_vlan = rocker_vlan_id_is_internal(vlan_id);
-		err = rocker_group_l2_interface(rocker_port, flags,
+		err = rocker_group_l2_interface(rocker_port, flags, 0,
 						vlan_id, out_lport,
 						pop_vlan);
 		if (err) {
@@ -3872,7 +3891,7 @@ static int rocker_flow_set_ig_port(struct net_device *dev,
 	in_lport_mask = rule->matches[0].mask_u32;
 	goto_tbl = rocker_goto_value(rule->actions[0].args[0].value_u16);
 
-	return rocker_flow_tbl_ig_port(rocker_port, flags,
+	return rocker_flow_tbl_ig_port(rocker_port, flags, 0,
 				       in_lport, in_lport_mask,
 				       goto_tbl);
 }
@@ -3929,7 +3948,7 @@ static int rocker_flow_set_vlan(struct net_device *dev,
 		}
 	}
 
-	return rocker_flow_tbl_vlan(rocker_port, flags, in_lport,
+	return rocker_flow_tbl_vlan(rocker_port, flags, 0, in_lport,
 				    vlan_id, vlan_id_mask, goto_tbl,
 				    untagged, new_vlan_id);
 }
@@ -4003,7 +4022,8 @@ static int rocker_flow_set_term_mac(struct net_device *dev,
 		}
 	}
 
-	return rocker_flow_tbl_term_mac(rocker_port, in_lport, in_lport_mask,
+	return rocker_flow_tbl_term_mac(rocker_port, 0,
+					in_lport, in_lport_mask,
 					ethtype, eth_dst, eth_dst_mask,
 					vlan_id, vlan_id_mask,
 					copy_to_cpu, flags);
@@ -4097,7 +4117,7 @@ static int rocker_flow_set_bridge(struct net_device *dev,
 	}
 
 	/* Ignoring eth_dst_mask it seems to cause a EINVAL return code */
-	return rocker_flow_tbl_bridge(rocker_port, flags,
+	return rocker_flow_tbl_bridge(rocker_port, flags, 0,
 				      eth_dst, eth_dst_mask,
 				      vlan_id, tunnel_id,
 				      goto_tbl, group_id, copy_to_cpu);
@@ -4199,7 +4219,7 @@ static int rocker_flow_set_acl(struct net_device *dev,
 		}
 	}
 
-	return rocker_flow_tbl_acl(rocker_port, flags,
+	return rocker_flow_tbl_acl(rocker_port, flags, 0,
 				   in_lport, in_lport_mask,
 				   eth_src, eth_src_mask,
 				   eth_dst, eth_dst_mask, ethtype,
