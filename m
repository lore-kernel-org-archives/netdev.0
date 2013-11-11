From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/3 net-next] openvswitch: Allow user space to announce ability to accept unaligned Netlink messages
Date: Mon, 11 Nov 2013 16:47:43 +0100
Message-ID: <ffad251a6d593180b81ad123d659716492fc4693.1384184208.git.tgraf@suug.ch>
References: <cover.1384184208.git.tgraf@suug.ch>
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, dborkman@redhat.com,
	bhutchings@solarflare.com
To: jesse@nicira.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:37131 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753833Ab3KKPr4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 10:47:56 -0500
In-Reply-To: <cover.1384184208.git.tgraf@suug.ch>
In-Reply-To: <cover.1384184208.git.tgraf@suug.ch>
References: <cover.1384184208.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/uapi/linux/openvswitch.h | 4 ++++
 net/openvswitch/datapath.c       | 4 ++++
 net/openvswitch/datapath.h       | 2 ++
 3 files changed, 10 insertions(+)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index d120f9f..07ef2c3 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -75,6 +75,7 @@ enum ovs_datapath_attr {
 	OVS_DP_ATTR_UPCALL_PID,		/* Netlink PID to receive upcalls */
 	OVS_DP_ATTR_STATS,		/* struct ovs_dp_stats */
 	OVS_DP_ATTR_MEGAFLOW_STATS,	/* struct ovs_dp_megaflow_stats */
+	OVS_DP_ATTR_USER_FEATURES,	/* OVS_DP_F_*  */
 	__OVS_DP_ATTR_MAX
 };
 
@@ -106,6 +107,9 @@ struct ovs_vport_stats {
 	__u64   tx_dropped;		/* no space available in linux  */
 };
 
+/* Allow last Netlink attribute to be unaligned */
+#define OVS_DP_F_UNALIGNED	(1 << 0)
+
 /* Fixed logical ports. */
 #define OVSP_LOCAL      ((__u32)0)
 
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 1408adc..0a50574 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1061,6 +1061,7 @@ static struct genl_ops dp_flow_genl_ops[] = {
 static const struct nla_policy datapath_policy[OVS_DP_ATTR_MAX + 1] = {
 	[OVS_DP_ATTR_NAME] = { .type = NLA_NUL_STRING, .len = IFNAMSIZ - 1 },
 	[OVS_DP_ATTR_UPCALL_PID] = { .type = NLA_U32 },
+	[OVS_DP_ATTR_USER_FEATURES] = { .type = NLA_U32 },
 };
 
 static struct genl_family dp_datapath_genl_family = {
@@ -1217,6 +1218,9 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	parms.port_no = OVSP_LOCAL;
 	parms.upcall_portid = nla_get_u32(a[OVS_DP_ATTR_UPCALL_PID]);
 
+	if (a[OVS_DP_ATTR_USER_FEATURES])
+		dp->user_features = nla_get_u32(a[OVS_DP_ATTR_USER_FEATURES]);
+
 	vport = new_vport(&parms);
 	if (IS_ERR(vport)) {
 		err = PTR_ERR(vport);
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index d3d14a58..ecdf44c 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -88,6 +88,8 @@ struct datapath {
 	/* Network namespace ref. */
 	struct net *net;
 #endif
+
+	u32 user_features;
 };
 
 /**
-- 
1.8.3.1
