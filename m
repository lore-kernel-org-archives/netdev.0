From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v2 3/5] tipc: get monitor threshold for the cluster
Date: Tue, 26 Jul 2016 08:47:20 +0200
Message-ID: <1469515642-9498-4-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1469515642-9498-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>, <jon.maloy@ericsson.com>,
	<maloy@donjonn.com>, <ying.xue@windriver.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:61053 "EHLO
	sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120AbcGZGrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 02:47:35 -0400
In-Reply-To: <1469515642-9498-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In this commit, we add support to fetch the configured
cluster monitoring threshold.

Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 include/uapi/linux/tipc_netlink.h |  1 +
 net/tipc/monitor.c                |  7 ++++++
 net/tipc/monitor.h                |  2 ++
 net/tipc/netlink.c                |  5 ++++
 net/tipc/node.c                   | 52 +++++++++++++++++++++++++++++++++++++++
 net/tipc/node.h                   |  1 +
 6 files changed, 68 insertions(+)

diff --git a/include/uapi/linux/tipc_netlink.h b/include/uapi/linux/tipc_netlink.h
index d387b65a0d97..d07c6ec76062 100644
--- a/include/uapi/linux/tipc_netlink.h
+++ b/include/uapi/linux/tipc_netlink.h
@@ -57,6 +57,7 @@ enum {
 	TIPC_NL_NET_SET,
 	TIPC_NL_NAME_TABLE_GET,
 	TIPC_NL_MON_SET,
+	TIPC_NL_MON_GET,
 
 	__TIPC_NL_CMD_MAX,
 	TIPC_NL_CMD_MAX = __TIPC_NL_CMD_MAX - 1
diff --git a/net/tipc/monitor.c b/net/tipc/monitor.c
index 3892d05b8b45..3579126e2ac8 100644
--- a/net/tipc/monitor.c
+++ b/net/tipc/monitor.c
@@ -661,3 +661,10 @@ int tipc_nl_monitor_set_threshold(struct net *net, u32 cluster_size)
 
 	return 0;
 }
+
+int tipc_nl_monitor_get_threshold(struct net *net)
+{
+	struct tipc_net *tn = tipc_net(net);
+
+	return tn->mon_threshold;
+}
diff --git a/net/tipc/monitor.h b/net/tipc/monitor.h
index 91f5dd09432b..aedf62c60bd3 100644
--- a/net/tipc/monitor.h
+++ b/net/tipc/monitor.h
@@ -70,5 +70,7 @@ void tipc_mon_get_state(struct net *net, u32 addr,
 void tipc_mon_remove_peer(struct net *net, u32 addr, int bearer_id);
 
 int tipc_nl_monitor_set_threshold(struct net *net, u32 cluster_size);
+int tipc_nl_monitor_get_threshold(struct net *net);
+
 extern const int tipc_max_domain_size;
 #endif
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index 1e43ac0200ed..2cfc5f7c6380 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -226,6 +226,11 @@ static const struct genl_ops tipc_genl_v2_ops[] = {
 		.doit	= tipc_nl_node_set_monitor,
 		.policy = tipc_nl_policy,
 	},
+	{
+		.cmd	= TIPC_NL_MON_GET,
+		.doit	= tipc_nl_node_get_monitor,
+		.policy = tipc_nl_policy,
+	},
 };
 
 int tipc_nlmsg_parse(const struct nlmsghdr *nlh, struct nlattr ***attr)
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 0fc531d0f709..2a7e74753f9f 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -1955,3 +1955,55 @@ int tipc_nl_node_set_monitor(struct sk_buff *skb, struct genl_info *info)
 
 	return 0;
 }
+
+static int __tipc_nl_add_monitor_prop(struct net *net, struct tipc_nl_msg *msg)
+{
+	struct nlattr *attrs;
+	void *hdr;
+	u32 val;
+
+	hdr = genlmsg_put(msg->skb, msg->portid, msg->seq, &tipc_genl_family,
+			  0, TIPC_NL_MON_GET);
+	if (!hdr)
+		return -EMSGSIZE;
+
+	attrs = nla_nest_start(msg->skb, TIPC_NLA_MON);
+	if (!attrs)
+		goto msg_full;
+
+	val = tipc_nl_monitor_get_threshold(net);
+
+	if (nla_put_u32(msg->skb, TIPC_NLA_MON_ACTIVATION_THRESHOLD, val))
+		goto attr_msg_full;
+
+	nla_nest_end(msg->skb, attrs);
+	genlmsg_end(msg->skb, hdr);
+
+	return 0;
+
+attr_msg_full:
+	nla_nest_cancel(msg->skb, attrs);
+msg_full:
+	genlmsg_cancel(msg->skb, hdr);
+
+	return -EMSGSIZE;
+}
+
+int tipc_nl_node_get_monitor(struct sk_buff *skb, struct genl_info *info)
+{
+	struct net *net = sock_net(skb->sk);
+	struct tipc_nl_msg msg;
+	int err;
+
+	msg.skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	msg.portid = info->snd_portid;
+	msg.seq = info->snd_seq;
+
+	err = __tipc_nl_add_monitor_prop(net, &msg);
+	if (err) {
+		nlmsg_free(msg.skb);
+		return err;
+	}
+
+	return genlmsg_reply(msg.skb, info);
+}
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 65aa12ede8a5..216f053b817f 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -79,4 +79,5 @@ int tipc_nl_node_get_link(struct sk_buff *skb, struct genl_info *info);
 int tipc_nl_node_set_link(struct sk_buff *skb, struct genl_info *info);
 
 int tipc_nl_node_set_monitor(struct sk_buff *skb, struct genl_info *info);
+int tipc_nl_node_get_monitor(struct sk_buff *skb, struct genl_info *info);
 #endif
-- 
2.1.4
