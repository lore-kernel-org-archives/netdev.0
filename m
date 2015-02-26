From: sfeldma@gmail.com
Subject: [PATCH net-next 2/3] rocker: rename lport to pport
Date: Wed, 25 Feb 2015 20:15:37 -0800
Message-ID: <1424924138-15928-3-git-send-email-sfeldma@gmail.com>
References: <1424924138-15928-1-git-send-email-sfeldma@gmail.com>
To: netdev@vger.kernel.org, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:34273 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753089AbbBZEPO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 23:15:14 -0500
Received: by pdjg10 with SMTP id g10so10017043pdj.1
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 20:15:14 -0800 (PST)
In-Reply-To: <1424924138-15928-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

This is just a rename of physical ports from "lport" to "pport".  Not a
functional change.  OF-DPA uses logical ports (lport) for tunnels, but the
driver (and device) were using "lport" for physical ports.  Renaming physical
ports references to "pport", freeing up "lport" for use later with tunnels.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |  191 +++++++++++++++++-----------------
 drivers/net/ethernet/rocker/rocker.h |   16 +--
 2 files changed, 103 insertions(+), 104 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 61f2ef4..db3e364 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -49,12 +49,12 @@ struct rocker_flow_tbl_key {
 	enum rocker_of_dpa_table_id tbl_id;
 	union {
 		struct {
-			u32 in_lport;
-			u32 in_lport_mask;
+			u32 in_pport;
+			u32 in_pport_mask;
 			enum rocker_of_dpa_table_id goto_tbl;
 		} ig_port;
 		struct {
-			u32 in_lport;
+			u32 in_pport;
 			__be16 vlan_id;
 			__be16 vlan_id_mask;
 			enum rocker_of_dpa_table_id goto_tbl;
@@ -62,8 +62,8 @@ struct rocker_flow_tbl_key {
 			__be16 new_vlan_id;
 		} vlan;
 		struct {
-			u32 in_lport;
-			u32 in_lport_mask;
+			u32 in_pport;
+			u32 in_pport_mask;
 			__be16 eth_type;
 			u8 eth_dst[ETH_ALEN];
 			u8 eth_dst_mask[ETH_ALEN];
@@ -91,8 +91,8 @@ struct rocker_flow_tbl_key {
 			bool copy_to_cpu;
 		} bridge;
 		struct {
-			u32 in_lport;
-			u32 in_lport_mask;
+			u32 in_pport;
+			u32 in_pport_mask;
 			u8 eth_src[ETH_ALEN];
 			u8 eth_src_mask[ETH_ALEN];
 			u8 eth_dst[ETH_ALEN];
@@ -148,7 +148,7 @@ struct rocker_fdb_tbl_entry {
 	u32 key_crc32; /* key */
 	bool learned;
 	struct rocker_fdb_tbl_key {
-		u32 lport;
+		u32 pport;
 		u8 addr[ETH_ALEN];
 		__be16 vlan_id;
 	} key;
@@ -200,7 +200,7 @@ struct rocker_port {
 	struct net_device *bridge_dev;
 	struct rocker *rocker;
 	unsigned int port_number;
-	u32 lport;
+	u32 pport;
 	__be16 internal_vlan_id;
 	int stp_state;
 	u32 brport_flags;
@@ -1280,9 +1280,9 @@ static void rocker_port_set_enable(struct rocker_port *rocker_port, bool enable)
 	u64 val = rocker_read64(rocker_port->rocker, PORT_PHYS_ENABLE);
 
 	if (enable)
-		val |= 1 << rocker_port->lport;
+		val |= 1 << rocker_port->pport;
 	else
-		val &= ~(1 << rocker_port->lport);
+		val &= ~(1 << rocker_port->pport);
 	rocker_write64(rocker_port->rocker, PORT_PHYS_ENABLE, val);
 }
 
@@ -1335,11 +1335,11 @@ static int rocker_event_link_change(struct rocker *rocker,
 	struct rocker_port *rocker_port;
 
 	rocker_tlv_parse_nested(attrs, ROCKER_TLV_EVENT_LINK_CHANGED_MAX, info);
-	if (!attrs[ROCKER_TLV_EVENT_LINK_CHANGED_LPORT] ||
+	if (!attrs[ROCKER_TLV_EVENT_LINK_CHANGED_PPORT] ||
 	    !attrs[ROCKER_TLV_EVENT_LINK_CHANGED_LINKUP])
 		return -EIO;
 	port_number =
-		rocker_tlv_get_u32(attrs[ROCKER_TLV_EVENT_LINK_CHANGED_LPORT]) - 1;
+		rocker_tlv_get_u32(attrs[ROCKER_TLV_EVENT_LINK_CHANGED_PPORT]) - 1;
 	link_up = rocker_tlv_get_u8(attrs[ROCKER_TLV_EVENT_LINK_CHANGED_LINKUP]);
 
 	if (port_number >= rocker->port_count)
@@ -1376,12 +1376,12 @@ static int rocker_event_mac_vlan_seen(struct rocker *rocker,
 	__be16 vlan_id;
 
 	rocker_tlv_parse_nested(attrs, ROCKER_TLV_EVENT_MAC_VLAN_MAX, info);
-	if (!attrs[ROCKER_TLV_EVENT_MAC_VLAN_LPORT] ||
+	if (!attrs[ROCKER_TLV_EVENT_MAC_VLAN_PPORT] ||
 	    !attrs[ROCKER_TLV_EVENT_MAC_VLAN_MAC] ||
 	    !attrs[ROCKER_TLV_EVENT_MAC_VLAN_VLAN_ID])
 		return -EIO;
 	port_number =
-		rocker_tlv_get_u32(attrs[ROCKER_TLV_EVENT_MAC_VLAN_LPORT]) - 1;
+		rocker_tlv_get_u32(attrs[ROCKER_TLV_EVENT_MAC_VLAN_PPORT]) - 1;
 	addr = rocker_tlv_data(attrs[ROCKER_TLV_EVENT_MAC_VLAN_MAC]);
 	vlan_id = rocker_tlv_get_be16(attrs[ROCKER_TLV_EVENT_MAC_VLAN_VLAN_ID]);
 
@@ -1540,8 +1540,8 @@ rocker_cmd_get_port_settings_prep(struct rocker *rocker,
 	cmd_info = rocker_tlv_nest_start(desc_info, ROCKER_TLV_CMD_INFO);
 	if (!cmd_info)
 		return -EMSGSIZE;
-	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_CMD_PORT_SETTINGS_LPORT,
-			       rocker_port->lport))
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_CMD_PORT_SETTINGS_PPORT,
+			       rocker_port->pport))
 		return -EMSGSIZE;
 	rocker_tlv_nest_end(desc_info, cmd_info);
 	return 0;
@@ -1629,8 +1629,8 @@ rocker_cmd_set_port_settings_ethtool_prep(struct rocker *rocker,
 	cmd_info = rocker_tlv_nest_start(desc_info, ROCKER_TLV_CMD_INFO);
 	if (!cmd_info)
 		return -EMSGSIZE;
-	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_CMD_PORT_SETTINGS_LPORT,
-			       rocker_port->lport))
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_CMD_PORT_SETTINGS_PPORT,
+			       rocker_port->pport))
 		return -EMSGSIZE;
 	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_CMD_PORT_SETTINGS_SPEED,
 			       ethtool_cmd_speed(ecmd)))
@@ -1660,8 +1660,8 @@ rocker_cmd_set_port_settings_macaddr_prep(struct rocker *rocker,
 	cmd_info = rocker_tlv_nest_start(desc_info, ROCKER_TLV_CMD_INFO);
 	if (!cmd_info)
 		return -EMSGSIZE;
-	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_CMD_PORT_SETTINGS_LPORT,
-			       rocker_port->lport))
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_CMD_PORT_SETTINGS_PPORT,
+			       rocker_port->pport))
 		return -EMSGSIZE;
 	if (rocker_tlv_put(desc_info, ROCKER_TLV_CMD_PORT_SETTINGS_MACADDR,
 			   ETH_ALEN, macaddr))
@@ -1684,8 +1684,8 @@ rocker_cmd_set_port_learning_prep(struct rocker *rocker,
 	cmd_info = rocker_tlv_nest_start(desc_info, ROCKER_TLV_CMD_INFO);
 	if (!cmd_info)
 		return -EMSGSIZE;
-	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_CMD_PORT_SETTINGS_LPORT,
-			       rocker_port->lport))
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_CMD_PORT_SETTINGS_PPORT,
+			       rocker_port->pport))
 		return -EMSGSIZE;
 	if (rocker_tlv_put_u8(desc_info, ROCKER_TLV_CMD_PORT_SETTINGS_LEARNING,
 			      !!(rocker_port->brport_flags & BR_LEARNING)))
@@ -1738,11 +1738,11 @@ static int rocker_port_set_learning(struct rocker_port *rocker_port)
 static int rocker_cmd_flow_tbl_add_ig_port(struct rocker_desc_info *desc_info,
 					   struct rocker_flow_tbl_entry *entry)
 {
-	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_LPORT,
-			       entry->key.ig_port.in_lport))
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_PPORT,
+			       entry->key.ig_port.in_pport))
 		return -EMSGSIZE;
-	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_LPORT_MASK,
-			       entry->key.ig_port.in_lport_mask))
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_PPORT_MASK,
+			       entry->key.ig_port.in_pport_mask))
 		return -EMSGSIZE;
 	if (rocker_tlv_put_u16(desc_info, ROCKER_TLV_OF_DPA_GOTO_TABLE_ID,
 			       entry->key.ig_port.goto_tbl))
@@ -1754,8 +1754,8 @@ static int rocker_cmd_flow_tbl_add_ig_port(struct rocker_desc_info *desc_info,
 static int rocker_cmd_flow_tbl_add_vlan(struct rocker_desc_info *desc_info,
 					struct rocker_flow_tbl_entry *entry)
 {
-	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_LPORT,
-			       entry->key.vlan.in_lport))
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_PPORT,
+			       entry->key.vlan.in_pport))
 		return -EMSGSIZE;
 	if (rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_VLAN_ID,
 				entry->key.vlan.vlan_id))
@@ -1777,11 +1777,11 @@ static int rocker_cmd_flow_tbl_add_vlan(struct rocker_desc_info *desc_info,
 static int rocker_cmd_flow_tbl_add_term_mac(struct rocker_desc_info *desc_info,
 					    struct rocker_flow_tbl_entry *entry)
 {
-	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_LPORT,
-			       entry->key.term_mac.in_lport))
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_PPORT,
+			       entry->key.term_mac.in_pport))
 		return -EMSGSIZE;
-	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_LPORT_MASK,
-			       entry->key.term_mac.in_lport_mask))
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_PPORT_MASK,
+			       entry->key.term_mac.in_pport_mask))
 		return -EMSGSIZE;
 	if (rocker_tlv_put_be16(desc_info, ROCKER_TLV_OF_DPA_ETHERTYPE,
 				entry->key.term_mac.eth_type))
@@ -1868,11 +1868,11 @@ static int rocker_cmd_flow_tbl_add_bridge(struct rocker_desc_info *desc_info,
 static int rocker_cmd_flow_tbl_add_acl(struct rocker_desc_info *desc_info,
 				       struct rocker_flow_tbl_entry *entry)
 {
-	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_LPORT,
-			       entry->key.acl.in_lport))
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_PPORT,
+			       entry->key.acl.in_pport))
 		return -EMSGSIZE;
-	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_LPORT_MASK,
-			       entry->key.acl.in_lport_mask))
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_IN_PPORT_MASK,
+			       entry->key.acl.in_pport_mask))
 		return -EMSGSIZE;
 	if (rocker_tlv_put(desc_info, ROCKER_TLV_OF_DPA_SRC_MAC,
 			   ETH_ALEN, entry->key.acl.eth_src))
@@ -2016,7 +2016,7 @@ static int
 rocker_cmd_group_tbl_add_l2_interface(struct rocker_desc_info *desc_info,
 				      struct rocker_group_tbl_entry *entry)
 {
-	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_OUT_LPORT,
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_OF_DPA_OUT_PPORT,
 			       ROCKER_GROUP_PORT_GET(entry->group_id)))
 		return -EMSGSIZE;
 	if (rocker_tlv_put_u8(desc_info, ROCKER_TLV_OF_DPA_POP_VLAN,
@@ -2334,7 +2334,7 @@ static int rocker_flow_tbl_do(struct rocker_port *rocker_port,
 }
 
 static int rocker_flow_tbl_ig_port(struct rocker_port *rocker_port,
-				   int flags, u32 in_lport, u32 in_lport_mask,
+				   int flags, u32 in_pport, u32 in_pport_mask,
 				   enum rocker_of_dpa_table_id goto_tbl)
 {
 	struct rocker_flow_tbl_entry *entry;
@@ -2345,15 +2345,15 @@ static int rocker_flow_tbl_ig_port(struct rocker_port *rocker_port,
 
 	entry->key.priority = ROCKER_PRIORITY_IG_PORT;
 	entry->key.tbl_id = ROCKER_OF_DPA_TABLE_ID_INGRESS_PORT;
-	entry->key.ig_port.in_lport = in_lport;
-	entry->key.ig_port.in_lport_mask = in_lport_mask;
+	entry->key.ig_port.in_pport = in_pport;
+	entry->key.ig_port.in_pport_mask = in_pport_mask;
 	entry->key.ig_port.goto_tbl = goto_tbl;
 
 	return rocker_flow_tbl_do(rocker_port, flags, entry);
 }
 
 static int rocker_flow_tbl_vlan(struct rocker_port *rocker_port,
-				int flags, u32 in_lport,
+				int flags, u32 in_pport,
 				__be16 vlan_id, __be16 vlan_id_mask,
 				enum rocker_of_dpa_table_id goto_tbl,
 				bool untagged, __be16 new_vlan_id)
@@ -2366,7 +2366,7 @@ static int rocker_flow_tbl_vlan(struct rocker_port *rocker_port,
 
 	entry->key.priority = ROCKER_PRIORITY_VLAN;
 	entry->key.tbl_id = ROCKER_OF_DPA_TABLE_ID_VLAN;
-	entry->key.vlan.in_lport = in_lport;
+	entry->key.vlan.in_pport = in_pport;
 	entry->key.vlan.vlan_id = vlan_id;
 	entry->key.vlan.vlan_id_mask = vlan_id_mask;
 	entry->key.vlan.goto_tbl = goto_tbl;
@@ -2378,7 +2378,7 @@ static int rocker_flow_tbl_vlan(struct rocker_port *rocker_port,
 }
 
 static int rocker_flow_tbl_term_mac(struct rocker_port *rocker_port,
-				    u32 in_lport, u32 in_lport_mask,
+				    u32 in_pport, u32 in_pport_mask,
 				    __be16 eth_type, const u8 *eth_dst,
 				    const u8 *eth_dst_mask, __be16 vlan_id,
 				    __be16 vlan_id_mask, bool copy_to_cpu,
@@ -2401,8 +2401,8 @@ static int rocker_flow_tbl_term_mac(struct rocker_port *rocker_port,
 	}
 
 	entry->key.tbl_id = ROCKER_OF_DPA_TABLE_ID_TERMINATION_MAC;
-	entry->key.term_mac.in_lport = in_lport;
-	entry->key.term_mac.in_lport_mask = in_lport_mask;
+	entry->key.term_mac.in_pport = in_pport;
+	entry->key.term_mac.in_pport_mask = in_pport_mask;
 	entry->key.term_mac.eth_type = eth_type;
 	ether_addr_copy(entry->key.term_mac.eth_dst, eth_dst);
 	ether_addr_copy(entry->key.term_mac.eth_dst_mask, eth_dst_mask);
@@ -2468,8 +2468,8 @@ static int rocker_flow_tbl_bridge(struct rocker_port *rocker_port,
 }
 
 static int rocker_flow_tbl_acl(struct rocker_port *rocker_port,
-			       int flags, u32 in_lport,
-			       u32 in_lport_mask,
+			       int flags, u32 in_pport,
+			       u32 in_pport_mask,
 			       const u8 *eth_src, const u8 *eth_src_mask,
 			       const u8 *eth_dst, const u8 *eth_dst_mask,
 			       __be16 eth_type,
@@ -2495,8 +2495,8 @@ static int rocker_flow_tbl_acl(struct rocker_port *rocker_port,
 
 	entry->key.priority = priority;
 	entry->key.tbl_id = ROCKER_OF_DPA_TABLE_ID_ACL_POLICY;
-	entry->key.acl.in_lport = in_lport;
-	entry->key.acl.in_lport_mask = in_lport_mask;
+	entry->key.acl.in_pport = in_pport;
+	entry->key.acl.in_pport_mask = in_pport_mask;
 
 	if (eth_src)
 		ether_addr_copy(entry->key.acl.eth_src, eth_src);
@@ -2627,7 +2627,7 @@ static int rocker_group_tbl_do(struct rocker_port *rocker_port,
 
 static int rocker_group_l2_interface(struct rocker_port *rocker_port,
 				     int flags, __be16 vlan_id,
-				     u32 out_lport, int pop_vlan)
+				     u32 out_pport, int pop_vlan)
 {
 	struct rocker_group_tbl_entry *entry;
 
@@ -2635,7 +2635,7 @@ static int rocker_group_l2_interface(struct rocker_port *rocker_port,
 	if (!entry)
 		return -ENOMEM;
 
-	entry->group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_lport);
+	entry->group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_pport);
 	entry->l2_interface.pop_vlan = pop_vlan;
 
 	return rocker_group_tbl_do(rocker_port, flags, entry);
@@ -2697,8 +2697,7 @@ static int rocker_port_vlan_flood_group(struct rocker_port *rocker_port,
 			continue;
 		if (test_bit(ntohs(vlan_id), p->vlan_bitmap)) {
 			group_ids[group_count++] =
-				ROCKER_GROUP_L2_INTERFACE(vlan_id,
-							  p->lport);
+				ROCKER_GROUP_L2_INTERFACE(vlan_id, p->pport);
 		}
 	}
 
@@ -2723,7 +2722,7 @@ static int rocker_port_vlan_l2_groups(struct rocker_port *rocker_port,
 	struct rocker *rocker = rocker_port->rocker;
 	struct rocker_port *p;
 	bool adding = !(flags & ROCKER_OP_FLAG_REMOVE);
-	u32 out_lport;
+	u32 out_pport;
 	int ref = 0;
 	int err;
 	int i;
@@ -2734,14 +2733,14 @@ static int rocker_port_vlan_l2_groups(struct rocker_port *rocker_port,
 
 	if (rocker_port->stp_state == BR_STATE_LEARNING ||
 	    rocker_port->stp_state == BR_STATE_FORWARDING) {
-		out_lport = rocker_port->lport;
+		out_pport = rocker_port->pport;
 		err = rocker_group_l2_interface(rocker_port, flags,
-						vlan_id, out_lport,
+						vlan_id, out_pport,
 						pop_vlan);
 		if (err) {
 			netdev_err(rocker_port->dev,
-				   "Error (%d) port VLAN l2 group for lport %d\n",
-				   err, out_lport);
+				   "Error (%d) port VLAN l2 group for pport %d\n",
+				   err, out_pport);
 			return err;
 		}
 	}
@@ -2760,9 +2759,9 @@ static int rocker_port_vlan_l2_groups(struct rocker_port *rocker_port,
 	if ((!adding || ref != 1) && (adding || ref != 0))
 		return 0;
 
-	out_lport = 0;
+	out_pport = 0;
 	err = rocker_group_l2_interface(rocker_port, flags,
-					vlan_id, out_lport,
+					vlan_id, out_pport,
 					pop_vlan);
 	if (err) {
 		netdev_err(rocker_port->dev,
@@ -2822,9 +2821,9 @@ static int rocker_port_ctrl_vlan_acl(struct rocker_port *rocker_port,
 				     int flags, struct rocker_ctrl *ctrl,
 				     __be16 vlan_id)
 {
-	u32 in_lport = rocker_port->lport;
-	u32 in_lport_mask = 0xffffffff;
-	u32 out_lport = 0;
+	u32 in_pport = rocker_port->pport;
+	u32 in_pport_mask = 0xffffffff;
+	u32 out_pport = 0;
 	u8 *eth_src = NULL;
 	u8 *eth_src_mask = NULL;
 	__be16 vlan_id_mask = htons(0xffff);
@@ -2832,11 +2831,11 @@ static int rocker_port_ctrl_vlan_acl(struct rocker_port *rocker_port,
 	u8 ip_proto_mask = 0;
 	u8 ip_tos = 0;
 	u8 ip_tos_mask = 0;
-	u32 group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_lport);
+	u32 group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_pport);
 	int err;
 
 	err = rocker_flow_tbl_acl(rocker_port, flags,
-				  in_lport, in_lport_mask,
+				  in_pport, in_pport_mask,
 				  eth_src, eth_src_mask,
 				  ctrl->eth_dst, ctrl->eth_dst_mask,
 				  ctrl->eth_type,
@@ -2879,7 +2878,7 @@ static int rocker_port_ctrl_vlan_term(struct rocker_port *rocker_port,
 				      int flags, struct rocker_ctrl *ctrl,
 				      __be16 vlan_id)
 {
-	u32 in_lport_mask = 0xffffffff;
+	u32 in_pport_mask = 0xffffffff;
 	__be16 vlan_id_mask = htons(0xffff);
 	int err;
 
@@ -2887,7 +2886,7 @@ static int rocker_port_ctrl_vlan_term(struct rocker_port *rocker_port,
 		vlan_id = rocker_port->internal_vlan_id;
 
 	err = rocker_flow_tbl_term_mac(rocker_port,
-				       rocker_port->lport, in_lport_mask,
+				       rocker_port->pport, in_pport_mask,
 				       ctrl->eth_type, ctrl->eth_dst,
 				       ctrl->eth_dst_mask, vlan_id,
 				       vlan_id_mask, ctrl->copy_to_cpu,
@@ -2957,7 +2956,7 @@ static int rocker_port_vlan(struct rocker_port *rocker_port, int flags,
 {
 	enum rocker_of_dpa_table_id goto_tbl =
 		ROCKER_OF_DPA_TABLE_ID_TERMINATION_MAC;
-	u32 in_lport = rocker_port->lport;
+	u32 in_pport = rocker_port->pport;
 	__be16 vlan_id = htons(vid);
 	__be16 vlan_id_mask = htons(0xffff);
 	__be16 internal_vlan_id;
@@ -3001,7 +3000,7 @@ static int rocker_port_vlan(struct rocker_port *rocker_port, int flags,
 	}
 
 	err = rocker_flow_tbl_vlan(rocker_port, flags,
-				   in_lport, vlan_id, vlan_id_mask,
+				   in_pport, vlan_id, vlan_id_mask,
 				   goto_tbl, untagged, internal_vlan_id);
 	if (err)
 		netdev_err(rocker_port->dev,
@@ -3013,20 +3012,20 @@ static int rocker_port_vlan(struct rocker_port *rocker_port, int flags,
 static int rocker_port_ig_tbl(struct rocker_port *rocker_port, int flags)
 {
 	enum rocker_of_dpa_table_id goto_tbl;
-	u32 in_lport;
-	u32 in_lport_mask;
+	u32 in_pport;
+	u32 in_pport_mask;
 	int err;
 
 	/* Normal Ethernet Frames.  Matches pkts from any local physical
 	 * ports.  Goto VLAN tbl.
 	 */
 
-	in_lport = 0;
-	in_lport_mask = 0xffff0000;
+	in_pport = 0;
+	in_pport_mask = 0xffff0000;
 	goto_tbl = ROCKER_OF_DPA_TABLE_ID_VLAN;
 
 	err = rocker_flow_tbl_ig_port(rocker_port, flags,
-				      in_lport, in_lport_mask,
+				      in_pport, in_pport_mask,
 				      goto_tbl);
 	if (err)
 		netdev_err(rocker_port->dev,
@@ -3070,7 +3069,7 @@ static int rocker_port_fdb_learn(struct rocker_port *rocker_port,
 	struct rocker_fdb_learn_work *lw;
 	enum rocker_of_dpa_table_id goto_tbl =
 		ROCKER_OF_DPA_TABLE_ID_ACL_POLICY;
-	u32 out_lport = rocker_port->lport;
+	u32 out_pport = rocker_port->pport;
 	u32 tunnel_id = 0;
 	u32 group_id = ROCKER_GROUP_NONE;
 	bool syncing = !!(rocker_port->brport_flags & BR_LEARNING_SYNC);
@@ -3078,7 +3077,7 @@ static int rocker_port_fdb_learn(struct rocker_port *rocker_port,
 	int err;
 
 	if (rocker_port_is_bridged(rocker_port))
-		group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_lport);
+		group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_pport);
 
 	if (!(flags & ROCKER_OP_FLAG_REFRESH)) {
 		err = rocker_flow_tbl_bridge(rocker_port, flags, addr, NULL,
@@ -3137,7 +3136,7 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 		return -ENOMEM;
 
 	fdb->learned = (flags & ROCKER_OP_FLAG_LEARNED);
-	fdb->key.lport = rocker_port->lport;
+	fdb->key.pport = rocker_port->pport;
 	ether_addr_copy(fdb->key.addr, addr);
 	fdb->key.vlan_id = vlan_id;
 	fdb->key_crc32 = crc32(~0, &fdb->key, sizeof(fdb->key));
@@ -3184,7 +3183,7 @@ static int rocker_port_fdb_flush(struct rocker_port *rocker_port)
 	spin_lock_irqsave(&rocker->fdb_tbl_lock, lock_flags);
 
 	hash_for_each_safe(rocker->fdb_tbl, bkt, tmp, found, entry) {
-		if (found->key.lport != rocker_port->lport)
+		if (found->key.pport != rocker_port->pport)
 			continue;
 		if (!found->learned)
 			continue;
@@ -3205,7 +3204,7 @@ err_out:
 static int rocker_port_router_mac(struct rocker_port *rocker_port,
 				  int flags, __be16 vlan_id)
 {
-	u32 in_lport_mask = 0xffffffff;
+	u32 in_pport_mask = 0xffffffff;
 	__be16 eth_type;
 	const u8 *dst_mac_mask = ff_mac;
 	__be16 vlan_id_mask = htons(0xffff);
@@ -3217,7 +3216,7 @@ static int rocker_port_router_mac(struct rocker_port *rocker_port,
 
 	eth_type = htons(ETH_P_IP);
 	err = rocker_flow_tbl_term_mac(rocker_port,
-				       rocker_port->lport, in_lport_mask,
+				       rocker_port->pport, in_pport_mask,
 				       eth_type, rocker_port->dev->dev_addr,
 				       dst_mac_mask, vlan_id, vlan_id_mask,
 				       copy_to_cpu, flags);
@@ -3226,7 +3225,7 @@ static int rocker_port_router_mac(struct rocker_port *rocker_port,
 
 	eth_type = htons(ETH_P_IPV6);
 	err = rocker_flow_tbl_term_mac(rocker_port,
-				       rocker_port->lport, in_lport_mask,
+				       rocker_port->pport, in_pport_mask,
 				       eth_type, rocker_port->dev->dev_addr,
 				       dst_mac_mask, vlan_id, vlan_id_mask,
 				       copy_to_cpu, flags);
@@ -3237,7 +3236,7 @@ static int rocker_port_router_mac(struct rocker_port *rocker_port,
 static int rocker_port_fwding(struct rocker_port *rocker_port)
 {
 	bool pop_vlan;
-	u32 out_lport;
+	u32 out_pport;
 	__be16 vlan_id;
 	u16 vid;
 	int flags = ROCKER_OP_FLAG_NOWAIT;
@@ -3254,19 +3253,19 @@ static int rocker_port_fwding(struct rocker_port *rocker_port)
 	    rocker_port->stp_state != BR_STATE_FORWARDING)
 		flags |= ROCKER_OP_FLAG_REMOVE;
 
-	out_lport = rocker_port->lport;
+	out_pport = rocker_port->pport;
 	for (vid = 1; vid < VLAN_N_VID; vid++) {
 		if (!test_bit(vid, rocker_port->vlan_bitmap))
 			continue;
 		vlan_id = htons(vid);
 		pop_vlan = rocker_vlan_id_is_internal(vlan_id);
 		err = rocker_group_l2_interface(rocker_port, flags,
-						vlan_id, out_lport,
+						vlan_id, out_pport,
 						pop_vlan);
 		if (err) {
 			netdev_err(rocker_port->dev,
-				   "Error (%d) port VLAN l2 group for lport %d\n",
-				   err, out_lport);
+				   "Error (%d) port VLAN l2 group for pport %d\n",
+				   err, out_pport);
 			return err;
 		}
 	}
@@ -3725,7 +3724,7 @@ static int rocker_port_fdb_dump(struct sk_buff *skb,
 
 	spin_lock_irqsave(&rocker->fdb_tbl_lock, lock_flags);
 	hash_for_each_safe(rocker->fdb_tbl, bkt, tmp, found, entry) {
-		if (found->key.lport != rocker_port->lport)
+		if (found->key.pport != rocker_port->pport)
 			continue;
 		if (idx < cb->args[0])
 			goto skip;
@@ -3905,8 +3904,8 @@ rocker_cmd_get_port_stats_prep(struct rocker *rocker,
 	if (!cmd_stats)
 		return -EMSGSIZE;
 
-	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_CMD_PORT_STATS_LPORT,
-			       rocker_port->lport))
+	if (rocker_tlv_put_u32(desc_info, ROCKER_TLV_CMD_PORT_STATS_PPORT,
+			       rocker_port->pport))
 		return -EMSGSIZE;
 
 	rocker_tlv_nest_end(desc_info, cmd_stats);
@@ -3923,7 +3922,7 @@ rocker_cmd_get_port_stats_ethtool_proc(struct rocker *rocker,
 	struct rocker_tlv *attrs[ROCKER_TLV_CMD_MAX + 1];
 	struct rocker_tlv *stats_attrs[ROCKER_TLV_CMD_PORT_STATS_MAX + 1];
 	struct rocker_tlv *pattr;
-	u32 lport;
+	u32 pport;
 	u64 *data = priv;
 	int i;
 
@@ -3935,11 +3934,11 @@ rocker_cmd_get_port_stats_ethtool_proc(struct rocker *rocker,
 	rocker_tlv_parse_nested(stats_attrs, ROCKER_TLV_CMD_PORT_STATS_MAX,
 				attrs[ROCKER_TLV_CMD_INFO]);
 
-	if (!stats_attrs[ROCKER_TLV_CMD_PORT_STATS_LPORT])
+	if (!stats_attrs[ROCKER_TLV_CMD_PORT_STATS_PPORT])
 		return -EIO;
 
-	lport = rocker_tlv_get_u32(stats_attrs[ROCKER_TLV_CMD_PORT_STATS_LPORT]);
-	if (lport != rocker_port->lport)
+	pport = rocker_tlv_get_u32(stats_attrs[ROCKER_TLV_CMD_PORT_STATS_PPORT]);
+	if (pport != rocker_port->pport)
 		return -EIO;
 
 	for (i = 0; i < ARRAY_SIZE(rocker_port_stats); i++) {
@@ -4127,7 +4126,7 @@ static void rocker_carrier_init(struct rocker_port *rocker_port)
 	u64 link_status = rocker_read64(rocker, PORT_PHYS_LINK_STATUS);
 	bool link_up;
 
-	link_up = link_status & (1 << rocker_port->lport);
+	link_up = link_status & (1 << rocker_port->pport);
 	if (link_up)
 		netif_carrier_on(rocker_port->dev);
 	else
@@ -4175,7 +4174,7 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	rocker_port->dev = dev;
 	rocker_port->rocker = rocker;
 	rocker_port->port_number = port_number;
-	rocker_port->lport = port_number + 1;
+	rocker_port->pport = port_number + 1;
 	rocker_port->brport_flags = BR_LEARNING | BR_LEARNING_SYNC;
 
 	rocker_port_dev_addr_init(rocker, rocker_port);
diff --git a/drivers/net/ethernet/rocker/rocker.h b/drivers/net/ethernet/rocker/rocker.h
index 76e79ed..0a94b7c 100644
--- a/drivers/net/ethernet/rocker/rocker.h
+++ b/drivers/net/ethernet/rocker/rocker.h
@@ -149,7 +149,7 @@ enum {
 
 enum {
 	ROCKER_TLV_CMD_PORT_SETTINGS_UNSPEC,
-	ROCKER_TLV_CMD_PORT_SETTINGS_LPORT,		/* u32 */
+	ROCKER_TLV_CMD_PORT_SETTINGS_PPORT,		/* u32 */
 	ROCKER_TLV_CMD_PORT_SETTINGS_SPEED,		/* u32 */
 	ROCKER_TLV_CMD_PORT_SETTINGS_DUPLEX,		/* u8 */
 	ROCKER_TLV_CMD_PORT_SETTINGS_AUTONEG,		/* u8 */
@@ -164,7 +164,7 @@ enum {
 
 enum {
 	ROCKER_TLV_CMD_PORT_STATS_UNSPEC,
-	ROCKER_TLV_CMD_PORT_STATS_LPORT,            /* u32 */
+	ROCKER_TLV_CMD_PORT_STATS_PPORT,            /* u32 */
 
 	ROCKER_TLV_CMD_PORT_STATS_RX_PKTS,          /* u64 */
 	ROCKER_TLV_CMD_PORT_STATS_RX_BYTES,         /* u64 */
@@ -204,7 +204,7 @@ enum {
 
 enum {
 	ROCKER_TLV_EVENT_LINK_CHANGED_UNSPEC,
-	ROCKER_TLV_EVENT_LINK_CHANGED_LPORT,	/* u32 */
+	ROCKER_TLV_EVENT_LINK_CHANGED_PPORT,	/* u32 */
 	ROCKER_TLV_EVENT_LINK_CHANGED_LINKUP,	/* u8 */
 
 	__ROCKER_TLV_EVENT_LINK_CHANGED_MAX,
@@ -214,7 +214,7 @@ enum {
 
 enum {
 	ROCKER_TLV_EVENT_MAC_VLAN_UNSPEC,
-	ROCKER_TLV_EVENT_MAC_VLAN_LPORT,	/* u32 */
+	ROCKER_TLV_EVENT_MAC_VLAN_PPORT,	/* u32 */
 	ROCKER_TLV_EVENT_MAC_VLAN_MAC,		/* binary */
 	ROCKER_TLV_EVENT_MAC_VLAN_VLAN_ID,	/* __be16 */
 
@@ -288,9 +288,9 @@ enum {
 	ROCKER_TLV_OF_DPA_HARDTIME,		/* u32 */
 	ROCKER_TLV_OF_DPA_IDLETIME,		/* u32 */
 	ROCKER_TLV_OF_DPA_COOKIE,		/* u64 */
-	ROCKER_TLV_OF_DPA_IN_LPORT,		/* u32 */
-	ROCKER_TLV_OF_DPA_IN_LPORT_MASK,	/* u32 */
-	ROCKER_TLV_OF_DPA_OUT_LPORT,		/* u32 */
+	ROCKER_TLV_OF_DPA_IN_PPORT,		/* u32 */
+	ROCKER_TLV_OF_DPA_IN_PPORT_MASK,	/* u32 */
+	ROCKER_TLV_OF_DPA_OUT_PPORT,		/* u32 */
 	ROCKER_TLV_OF_DPA_GOTO_TABLE_ID,	/* u16 */
 	ROCKER_TLV_OF_DPA_GROUP_ID,		/* u32 */
 	ROCKER_TLV_OF_DPA_GROUP_ID_LOWER,	/* u32 */
@@ -304,7 +304,7 @@ enum {
 	ROCKER_TLV_OF_DPA_NEW_VLAN_ID,		/* __be16 */
 	ROCKER_TLV_OF_DPA_NEW_VLAN_PCP,		/* u8 */
 	ROCKER_TLV_OF_DPA_TUNNEL_ID,		/* u32 */
-	ROCKER_TLV_OF_DPA_TUN_LOG_LPORT,	/* u32 */
+	ROCKER_TLV_OF_DPA_TUNNEL_LPORT,		/* u32 */
 	ROCKER_TLV_OF_DPA_ETHERTYPE,		/* __be16 */
 	ROCKER_TLV_OF_DPA_DST_MAC,		/* binary */
 	ROCKER_TLV_OF_DPA_DST_MAC_MASK,		/* binary */
-- 
1.7.10.4
