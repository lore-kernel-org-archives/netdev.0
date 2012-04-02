From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 06/51] openvswitch: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:57:56 -0400
Message-ID: <1333335521-1348-7-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46710 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754259Ab2DBC7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 22:59:35 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/openvswitch/datapath.c |   34 ++++++++++++++++++++--------------
 net/openvswitch/flow.c     |   18 +++++++++++-------
 2 files changed, 31 insertions(+), 21 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 2c03050..f5ca125 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -779,15 +779,18 @@ static int ovs_flow_cmd_fill_info(struct sw_flow *flow, struct datapath *dp,
 	tcp_flags = flow->tcp_flags;
 	spin_unlock_bh(&flow->lock);
 
-	if (used)
-		NLA_PUT_U64(skb, OVS_FLOW_ATTR_USED, ovs_flow_used_time(used));
+	if (used &&
+	    nla_put_u64(skb, OVS_FLOW_ATTR_USED, ovs_flow_used_time(used)))
+		goto nla_put_failure;
 
-	if (stats.n_packets)
-		NLA_PUT(skb, OVS_FLOW_ATTR_STATS,
-			sizeof(struct ovs_flow_stats), &stats);
+	if (stats.n_packets &&
+	    nla_put(skb, OVS_FLOW_ATTR_STATS,
+		    sizeof(struct ovs_flow_stats), &stats))
+		goto nla_put_failure;
 
-	if (tcp_flags)
-		NLA_PUT_U8(skb, OVS_FLOW_ATTR_TCP_FLAGS, tcp_flags);
+	if (tcp_flags &&
+	    nla_put_u8(skb, OVS_FLOW_ATTR_TCP_FLAGS, tcp_flags))
+		goto nla_put_failure;
 
 	/* If OVS_FLOW_ATTR_ACTIONS doesn't fit, skip dumping the actions if
 	 * this is the first flow to be dumped into 'skb'.  This is unusual for
@@ -1169,7 +1172,8 @@ static int ovs_dp_cmd_fill_info(struct datapath *dp, struct sk_buff *skb,
 		goto nla_put_failure;
 
 	get_dp_stats(dp, &dp_stats);
-	NLA_PUT(skb, OVS_DP_ATTR_STATS, sizeof(struct ovs_dp_stats), &dp_stats);
+	if (nla_put(skb, OVS_DP_ATTR_STATS, sizeof(struct ovs_dp_stats), &dp_stats))
+		goto nla_put_failure;
 
 	return genlmsg_end(skb, ovs_header);
 
@@ -1469,14 +1473,16 @@ static int ovs_vport_cmd_fill_info(struct vport *vport, struct sk_buff *skb,
 
 	ovs_header->dp_ifindex = get_dpifindex(vport->dp);
 
-	NLA_PUT_U32(skb, OVS_VPORT_ATTR_PORT_NO, vport->port_no);
-	NLA_PUT_U32(skb, OVS_VPORT_ATTR_TYPE, vport->ops->type);
-	NLA_PUT_STRING(skb, OVS_VPORT_ATTR_NAME, vport->ops->get_name(vport));
-	NLA_PUT_U32(skb, OVS_VPORT_ATTR_UPCALL_PID, vport->upcall_pid);
+	if (nla_put_u32(skb, OVS_VPORT_ATTR_PORT_NO, vport->port_no) ||
+	    nla_put_u32(skb, OVS_VPORT_ATTR_TYPE, vport->ops->type) ||
+	    nla_put_string(skb, OVS_VPORT_ATTR_NAME, vport->ops->get_name(vport)) ||
+	    nla_put_u32(skb, OVS_VPORT_ATTR_UPCALL_PID, vport->upcall_pid))
+		goto nla_put_failure;
 
 	ovs_vport_get_stats(vport, &vport_stats);
-	NLA_PUT(skb, OVS_VPORT_ATTR_STATS, sizeof(struct ovs_vport_stats),
-		&vport_stats);
+	if (nla_put(skb, OVS_VPORT_ATTR_STATS, sizeof(struct ovs_vport_stats),
+		    &vport_stats))
+		goto nla_put_failure;
 
 	err = ovs_vport_get_options(vport, skb);
 	if (err == -EMSGSIZE)
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 1252c30..7cb4163 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -1174,11 +1174,13 @@ int ovs_flow_to_nlattrs(const struct sw_flow_key *swkey, struct sk_buff *skb)
 	struct ovs_key_ethernet *eth_key;
 	struct nlattr *nla, *encap;
 
-	if (swkey->phy.priority)
-		NLA_PUT_U32(skb, OVS_KEY_ATTR_PRIORITY, swkey->phy.priority);
+	if (swkey->phy.priority &&
+	    nla_put_u32(skb, OVS_KEY_ATTR_PRIORITY, swkey->phy.priority))
+		goto nla_put_failure;
 
-	if (swkey->phy.in_port != USHRT_MAX)
-		NLA_PUT_U32(skb, OVS_KEY_ATTR_IN_PORT, swkey->phy.in_port);
+	if (swkey->phy.in_port != USHRT_MAX &&
+	    nla_put_u32(skb, OVS_KEY_ATTR_IN_PORT, swkey->phy.in_port))
+		goto nla_put_failure;
 
 	nla = nla_reserve(skb, OVS_KEY_ATTR_ETHERNET, sizeof(*eth_key));
 	if (!nla)
@@ -1188,8 +1190,9 @@ int ovs_flow_to_nlattrs(const struct sw_flow_key *swkey, struct sk_buff *skb)
 	memcpy(eth_key->eth_dst, swkey->eth.dst, ETH_ALEN);
 
 	if (swkey->eth.tci || swkey->eth.type == htons(ETH_P_8021Q)) {
-		NLA_PUT_BE16(skb, OVS_KEY_ATTR_ETHERTYPE, htons(ETH_P_8021Q));
-		NLA_PUT_BE16(skb, OVS_KEY_ATTR_VLAN, swkey->eth.tci);
+		if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, htons(ETH_P_8021Q)) ||
+		    nla_put_be16(skb, OVS_KEY_ATTR_VLAN, swkey->eth.tci))
+			goto nla_put_failure;
 		encap = nla_nest_start(skb, OVS_KEY_ATTR_ENCAP);
 		if (!swkey->eth.tci)
 			goto unencap;
@@ -1200,7 +1203,8 @@ int ovs_flow_to_nlattrs(const struct sw_flow_key *swkey, struct sk_buff *skb)
 	if (swkey->eth.type == htons(ETH_P_802_2))
 		goto unencap;
 
-	NLA_PUT_BE16(skb, OVS_KEY_ATTR_ETHERTYPE, swkey->eth.type);
+	if (nla_put_be16(skb, OVS_KEY_ATTR_ETHERTYPE, swkey->eth.type))
+		goto nla_put_failure;
 
 	if (swkey->eth.type == htons(ETH_P_IP)) {
 		struct ovs_key_ipv4 *ipv4_key;
-- 
1.7.7.6
