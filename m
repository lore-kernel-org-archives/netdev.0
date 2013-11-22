From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 5/8] openvswitch: Allow user space to announce ability to accept unaligned Netlink messages
Date: Fri, 22 Nov 2013 17:56:08 +0100
Message-ID: <9bee2b7d5d51ef74dbd148dfe0d41e63c5617f5a.1385137618.git.tgraf@suug.ch>
References: <cover.1385137618.git.tgraf@suug.ch>
Cc: dev@openvswitch.org, netdev@vger.kernel.org, dborkman@redhat.com,
	ffusco@redhat.com, fleitner@redhat.com, eric.dumazet@gmail.com,
	bhutchings@solarflare.com
To: jesse@nicira.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:51488 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755619Ab3KVQ43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 11:56:29 -0500
In-Reply-To: <cover.1385137618.git.tgraf@suug.ch>
In-Reply-To: <cover.1385137618.git.tgraf@suug.ch>
References: <cover.1385137618.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Reviewed-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/uapi/linux/openvswitch.h |  4 ++++
 net/openvswitch/datapath.c       | 14 ++++++++++++++
 net/openvswitch/datapath.h       |  2 ++
 3 files changed, 20 insertions(+)

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
index 0ac9cde..95d4424 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1067,6 +1067,7 @@ static const struct genl_ops dp_flow_genl_ops[] = {
 static const struct nla_policy datapath_policy[OVS_DP_ATTR_MAX + 1] = {
 	[OVS_DP_ATTR_NAME] = { .type = NLA_NUL_STRING, .len = IFNAMSIZ - 1 },
 	[OVS_DP_ATTR_UPCALL_PID] = { .type = NLA_U32 },
+	[OVS_DP_ATTR_USER_FEATURES] = { .type = NLA_U32 },
 };
 
 static struct genl_family dp_datapath_genl_family = {
@@ -1125,6 +1126,9 @@ static int ovs_dp_cmd_fill_info(struct datapath *dp, struct sk_buff *skb,
 			&dp_megaflow_stats))
 		goto nla_put_failure;
 
+	if (nla_put_u32(skb, OVS_DP_ATTR_USER_FEATURES, dp->user_features))
+		goto nla_put_failure;
+
 	return genlmsg_end(skb, ovs_header);
 
 nla_put_failure:
@@ -1171,6 +1175,12 @@ static struct datapath *lookup_datapath(struct net *net,
 	return dp ? dp : ERR_PTR(-ENODEV);
 }
 
+static void ovs_dp_change(struct datapath *dp, struct nlattr **a)
+{
+	if (a[OVS_DP_ATTR_USER_FEATURES])
+		dp->user_features = nla_get_u32(a[OVS_DP_ATTR_USER_FEATURES]);
+}
+
 static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 {
 	struct nlattr **a = info->attrs;
@@ -1229,6 +1239,8 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	parms.port_no = OVSP_LOCAL;
 	parms.upcall_portid = nla_get_u32(a[OVS_DP_ATTR_UPCALL_PID]);
 
+	ovs_dp_change(dp, a);
+
 	vport = new_vport(&parms);
 	if (IS_ERR(vport)) {
 		err = PTR_ERR(vport);
@@ -1332,6 +1344,8 @@ static int ovs_dp_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	if (IS_ERR(dp))
 		goto unlock;
 
+	ovs_dp_change(dp, info->attrs);
+
 	reply = ovs_dp_cmd_build_info(dp, info, OVS_DP_CMD_NEW);
 	if (IS_ERR(reply)) {
 		err = PTR_ERR(reply);
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 4067ea4..193e2e0 100644
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
