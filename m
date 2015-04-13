From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC net-next 4/4] rocker: allow forwarding of IPv4 by unicast routing table
Date: Mon, 13 Apr 2015 15:47:57 +0900
Message-ID: <1428907677-27204-5-git-send-email-simon.horman@netronome.com>
References: <1428907677-27204-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:35390 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753204AbbDMGsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 02:48:30 -0400
Received: by pddn5 with SMTP id n5so97249554pdd.2
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 23:48:30 -0700 (PDT)
In-Reply-To: <1428907677-27204-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This configures entries in the ACL and termination MAC tables of
a rocker switch to allow the use of IPv4 unicast routing entries.

This configuration is activated for a port when it is neither bridged or in
promiscuous mode.

The result is that unicast IPv4 forwarding may be performed by
the rocker switch as per its configuration by the kernel via the
rocker device driver.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/rocker/rocker.c | 33 ++++++++++++++++++++++++++++++---
 1 file changed, 30 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index d74d53cb59ab..74394ce86322 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -200,9 +200,11 @@ enum {
 	ROCKER_CTRL_LINK_LOCAL_MCAST,
 	ROCKER_CTRL_LOCAL_ARP,
 	ROCKER_CTRL_LOCAL_UNICAST,
+	ROCKER_CTRL_ROUTED_IPV4_UNICAST,
 	ROCKER_CTRL_PROMISC,
 	ROCKER_CTRL_IPV4_MCAST,
 	ROCKER_CTRL_IPV6_MCAST,
+	ROCKER_CTRL_IPV4_UNICAST,
 	ROCKER_CTRL_DFLT_BRIDGING,
 	ROCKER_CTRL_MAX,
 };
@@ -2583,7 +2585,8 @@ static int rocker_flow_tbl_acl(struct rocker_port *rocker_port,
 	if (eth_dst && eth_dst_mask) {
 		if (memcmp(eth_dst_mask, mcast_mac, ETH_ALEN) == 0)
 			priority = ROCKER_PRIORITY_ACL_DFLT;
-		else if (is_link_local_ether_addr(eth_dst))
+		else if (is_link_local_ether_addr(eth_dst) ||
+			 eth_type == htons(ETH_P_IP))
 			priority = ROCKER_PRIORITY_ACL_CTRL;
 	}
 
@@ -3117,6 +3120,7 @@ static struct rocker_ctrl {
 	bool bridge;
 	bool term;
 	bool copy_to_cpu;
+	bool no_group;
 } rocker_ctrls[] = {
 	[ROCKER_CTRL_LINK_LOCAL_MCAST] = {
 		/* pass link local multicast pkts up to CPU for filtering */
@@ -3136,6 +3140,13 @@ static struct rocker_ctrl {
 		.eth_dst_mask = ff_mac,
 		.acl = true,
 	},
+	[ROCKER_CTRL_ROUTED_IPV4_UNICAST] = {
+		/* allow unicast IPv4 pkts that have been routed */
+		.eth_dst_mask = ff_mac,
+		.eth_type = htons(ETH_P_IP),
+		.acl = true,
+		.no_group = true,
+	},
 	[ROCKER_CTRL_PROMISC] = {
 		/* pass all pkts up to CPU */
 		.eth_dst = zero_mac,
@@ -3158,6 +3169,13 @@ static struct rocker_ctrl {
 		.term  = true,
 		.copy_to_cpu = true,
 	},
+	[ROCKER_CTRL_IPV4_UNICAST] = {
+		/* pass IPv4 unicast packets to unicast routing table */
+		.eth_dst_mask = ff_mac,
+		.eth_type = htons(ETH_P_IP),
+		.term = true,
+		.copy_to_cpu = true,
+	},
 	[ROCKER_CTRL_DFLT_BRIDGING] = {
 		/* flood any pkts on vlan */
 		.bridge = true,
@@ -3181,9 +3199,14 @@ static int rocker_port_ctrl_vlan_acl(struct rocker_port *rocker_port,
 	u8 ip_proto_mask = 0;
 	u8 ip_tos = 0;
 	u8 ip_tos_mask = 0;
-	u32 group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_pport);
+	u32 group_id;
 	int err;
 
+	if (ctrl->no_group)
+		group_id = ROCKER_GROUP_NONE;
+	else
+		group_id = ROCKER_GROUP_L2_INTERFACE(vlan_id, out_pport);
+
 	err = rocker_flow_tbl_acl(rocker_port, flags,
 				  in_pport, in_pport_mask,
 				  eth_src, eth_src_mask,
@@ -3228,6 +3251,8 @@ static int rocker_port_ctrl_vlan_term(struct rocker_port *rocker_port,
 				      int flags, struct rocker_ctrl *ctrl,
 				      __be16 vlan_id)
 {
+	const u8 *eth_dst = ctrl->eth_dst ? :
+		rocker_port_uppermost_dev(rocker_port)->dev_addr;
 	u32 in_pport_mask = 0xffffffff;
 	__be16 vlan_id_mask = htons(0xffff);
 	int err;
@@ -3237,7 +3262,7 @@ static int rocker_port_ctrl_vlan_term(struct rocker_port *rocker_port,
 
 	err = rocker_flow_tbl_term_mac(rocker_port,
 				       rocker_port->pport, in_pport_mask,
-				       ctrl->eth_type, ctrl->eth_dst,
+				       ctrl->eth_type, eth_dst,
 				       ctrl->eth_dst_mask, vlan_id,
 				       vlan_id_mask, ctrl->copy_to_cpu,
 				       flags);
@@ -3657,6 +3682,8 @@ static int rocker_port_stp_update(struct rocker_port *rocker_port, u8 state)
 			} else {
 				want[ROCKER_CTRL_LOCAL_UNICAST] = true;
 				want[ROCKER_CTRL_LOCAL_ARP] = true;
+				want[ROCKER_CTRL_ROUTED_IPV4_UNICAST] = true;
+				want[ROCKER_CTRL_IPV4_UNICAST] = true;
 			}
 		}
 		break;
-- 
2.1.4
