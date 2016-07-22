From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v1 5/5] tipc: dump monitor attributes
Date: Fri, 22 Jul 2016 08:42:48 +0200
Message-ID: <1469169768-9214-6-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1469169768-9214-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>, <jon.maloy@ericsson.com>,
	<maloy@donjonn.com>, <ying.xue@windriver.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:53766 "EHLO
	sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753097AbcGVGnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2016 02:43:07 -0400
In-Reply-To: <1469169768-9214-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In this commit, we dump the monitor attributes when queried.
The link monitor attributes are separated into two kinds:
1. general attributes per bearer
2. specific attributes per node/peer
This style resembles the socket attributes and the nametable
publications per socket.

Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 include/uapi/linux/tipc_netlink.h |  25 +++++++
 net/tipc/monitor.c                | 133 ++++++++++++++++++++++++++++++++++++++
 net/tipc/monitor.h                |   6 ++
 net/tipc/netlink.c                |   7 ++
 net/tipc/node.c                   |  86 ++++++++++++++++++++++++
 net/tipc/node.h                   |   3 +
 6 files changed, 260 insertions(+)

diff --git a/include/uapi/linux/tipc_netlink.h b/include/uapi/linux/tipc_netlink.h
index d07c6ec76062..5f3f6d09fb79 100644
--- a/include/uapi/linux/tipc_netlink.h
+++ b/include/uapi/linux/tipc_netlink.h
@@ -58,6 +58,7 @@ enum {
 	TIPC_NL_NAME_TABLE_GET,
 	TIPC_NL_MON_SET,
 	TIPC_NL_MON_GET,
+	TIPC_NL_MON_PEER_GET,
 
 	__TIPC_NL_CMD_MAX,
 	TIPC_NL_CMD_MAX = __TIPC_NL_CMD_MAX - 1
@@ -75,6 +76,7 @@ enum {
 	TIPC_NLA_NET,			/* nest */
 	TIPC_NLA_NAME_TABLE,		/* nest */
 	TIPC_NLA_MON,			/* nest */
+	TIPC_NLA_MON_PEER,		/* nest */
 
 	__TIPC_NLA_MAX,
 	TIPC_NLA_MAX = __TIPC_NLA_MAX - 1
@@ -173,6 +175,11 @@ enum {
 enum {
 	TIPC_NLA_MON_UNSPEC,
 	TIPC_NLA_MON_ACTIVATION_THRESHOLD,	/* u32 */
+	TIPC_NLA_MON_REF,			/* u32 */
+	TIPC_NLA_MON_ACTIVE,			/* flag */
+	TIPC_NLA_MON_BEARER_NAME,		/* string */
+	TIPC_NLA_MON_PEERCNT,			/* u32 */
+	TIPC_NLA_MON_LISTGEN,			/* u32 */
 
 	__TIPC_NLA_MON_MAX,
 	TIPC_NLA_MON_MAX = __TIPC_NLA_MON_MAX - 1
@@ -194,6 +201,24 @@ enum {
 	TIPC_NLA_PUBL_MAX = __TIPC_NLA_PUBL_MAX - 1
 };
 
+/* Monitor peer info */
+enum {
+	TIPC_NLA_MON_PEER_UNSPEC,
+
+	TIPC_NLA_MON_PEER_ADDR,			/* u32 */
+	TIPC_NLA_MON_PEER_DOMGEN,		/* u32 */
+	TIPC_NLA_MON_PEER_APPLIED,		/* u32 */
+	TIPC_NLA_MON_PEER_UPMAP,		/* u64 */
+	TIPC_NLA_MON_PEER_MEMBERS,		/* tlv */
+	TIPC_NLA_MON_PEER_UP,			/* flag */
+	TIPC_NLA_MON_PEER_HEAD,			/* flag */
+	TIPC_NLA_MON_PEER_LOCAL,		/* flag */
+	TIPC_NLA_MON_PEER_PAD,			/* flag */
+
+	__TIPC_NLA_MON_PEER_MAX,
+	TIPC_NLA_MON_PEER_MAX = __TIPC_NLA_MON_PEER_MAX - 1
+};
+
 /* Nest, connection info */
 enum {
 	TIPC_NLA_CON_UNSPEC,
diff --git a/net/tipc/monitor.c b/net/tipc/monitor.c
index 3579126e2ac8..be70a57c1ff9 100644
--- a/net/tipc/monitor.c
+++ b/net/tipc/monitor.c
@@ -33,9 +33,11 @@
  * POSSIBILITY OF SUCH DAMAGE.
  */
 
+#include <net/genetlink.h>
 #include "core.h"
 #include "addr.h"
 #include "monitor.h"
+#include "bearer.h"
 
 #define MAX_MON_DOMAIN       64
 #define MON_TIMEOUT          120000
@@ -668,3 +670,134 @@ int tipc_nl_monitor_get_threshold(struct net *net)
 
 	return tn->mon_threshold;
 }
+
+int __tipc_nl_add_monitor_peer(struct tipc_peer *peer, struct tipc_nl_msg *msg)
+{
+	struct tipc_mon_domain *dom = peer->domain;
+	struct nlattr *attrs;
+	void *hdr;
+
+	hdr = genlmsg_put(msg->skb, msg->portid, msg->seq, &tipc_genl_family,
+			  NLM_F_MULTI, TIPC_NL_MON_PEER_GET);
+	if (!hdr)
+		return -EMSGSIZE;
+
+	attrs = nla_nest_start(msg->skb, TIPC_NLA_MON_PEER);
+	if (!attrs)
+		goto msg_full;
+
+	if (nla_put_u32(msg->skb, TIPC_NLA_MON_PEER_ADDR, peer->addr))
+		goto attr_msg_full;
+	if (nla_put_u32(msg->skb, TIPC_NLA_MON_PEER_APPLIED, peer->applied))
+		goto attr_msg_full;
+
+	if (peer->is_up)
+		if (nla_put_flag(msg->skb, TIPC_NLA_MON_PEER_UP))
+			goto attr_msg_full;
+	if (peer->is_local)
+		if (nla_put_flag(msg->skb, TIPC_NLA_MON_PEER_LOCAL))
+			goto attr_msg_full;
+	if (peer->is_head)
+		if (nla_put_flag(msg->skb, TIPC_NLA_MON_PEER_HEAD))
+			goto attr_msg_full;
+
+	if (dom) {
+		if (nla_put_u32(msg->skb, TIPC_NLA_MON_PEER_DOMGEN, dom->gen))
+			goto attr_msg_full;
+		if (nla_put_u64_64bit(msg->skb, TIPC_NLA_MON_PEER_UPMAP,
+				      dom->up_map, TIPC_NLA_MON_PEER_PAD))
+			goto attr_msg_full;
+		if (nla_put(msg->skb, TIPC_NLA_MON_PEER_MEMBERS,
+			    dom->member_cnt * sizeof(u32), &dom->members))
+			goto attr_msg_full;
+	}
+
+	nla_nest_end(msg->skb, attrs);
+	genlmsg_end(msg->skb, hdr);
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
+int tipc_nl_add_monitor_peer(struct net *net, struct tipc_nl_msg *msg,
+			     u32 bearer_id, u32 *prev_node)
+{
+	struct tipc_monitor *mon = tipc_monitor(net, bearer_id);
+	struct tipc_peer *peer = mon->self;
+
+	if (!mon)
+		return -EINVAL;
+
+	read_lock_bh(&mon->lock);
+	do {
+		if (*prev_node) {
+			if (peer->addr == *prev_node)
+				*prev_node = 0;
+			else
+				continue;
+		}
+		if (__tipc_nl_add_monitor_peer(peer, msg)) {
+			*prev_node = peer->addr;
+			read_unlock_bh(&mon->lock);
+			return -EMSGSIZE;
+		}
+	} while ((peer = peer_nxt(peer)) != mon->self);
+	read_unlock_bh(&mon->lock);
+
+	return 0;
+}
+
+int __tipc_nl_add_monitor(struct net *net, struct tipc_nl_msg *msg,
+			  u32 bearer_id)
+{
+	struct tipc_monitor *mon = tipc_monitor(net, bearer_id);
+	char bearer_name[TIPC_MAX_BEARER_NAME];
+	struct nlattr *attrs;
+	void *hdr;
+	int ret;
+
+	ret = tipc_bearer_get_name(net, bearer_name, bearer_id);
+	if (ret || !mon)
+		return -EINVAL;
+
+	hdr = genlmsg_put(msg->skb, msg->portid, msg->seq, &tipc_genl_family,
+			  NLM_F_MULTI, TIPC_NL_MON_GET);
+	if (!hdr)
+		return -EMSGSIZE;
+
+	attrs = nla_nest_start(msg->skb, TIPC_NLA_MON);
+	if (!attrs)
+		goto msg_full;
+
+	read_lock_bh(&mon->lock);
+	if (nla_put_u32(msg->skb, TIPC_NLA_MON_REF, bearer_id))
+		goto attr_msg_full;
+	if (tipc_mon_is_active(net, mon))
+		if (nla_put_flag(msg->skb, TIPC_NLA_MON_ACTIVE))
+			goto attr_msg_full;
+	if (nla_put_string(msg->skb, TIPC_NLA_MON_BEARER_NAME, bearer_name))
+		goto attr_msg_full;
+	if (nla_put_u32(msg->skb, TIPC_NLA_MON_PEERCNT, mon->peer_cnt))
+		goto attr_msg_full;
+	if (nla_put_u32(msg->skb, TIPC_NLA_MON_LISTGEN, mon->list_gen))
+		goto attr_msg_full;
+
+	read_unlock_bh(&mon->lock);
+	nla_nest_end(msg->skb, attrs);
+	genlmsg_end(msg->skb, hdr);
+
+	return 0;
+
+attr_msg_full:
+	nla_nest_cancel(msg->skb, attrs);
+msg_full:
+	genlmsg_cancel(msg->skb, hdr);
+	read_unlock_bh(&mon->lock);
+
+	return -EMSGSIZE;
+}
diff --git a/net/tipc/monitor.h b/net/tipc/monitor.h
index aedf62c60bd3..2a21b93e0d04 100644
--- a/net/tipc/monitor.h
+++ b/net/tipc/monitor.h
@@ -36,6 +36,8 @@
 #ifndef _TIPC_MONITOR_H
 #define _TIPC_MONITOR_H
 
+#include "netlink.h"
+
 /* struct tipc_mon_state: link instance's cache of monitor list and domain state
  * @list_gen: current generation of this node's monitor list
  * @gen: current generation of this node's local domain
@@ -71,6 +73,10 @@ void tipc_mon_remove_peer(struct net *net, u32 addr, int bearer_id);
 
 int tipc_nl_monitor_set_threshold(struct net *net, u32 cluster_size);
 int tipc_nl_monitor_get_threshold(struct net *net);
+int __tipc_nl_add_monitor(struct net *net, struct tipc_nl_msg *msg,
+			  u32 bearer_id);
+int tipc_nl_add_monitor_peer(struct net *net, struct tipc_nl_msg *msg,
+			     u32 bearer_id, u32 *prev_node);
 
 extern const int tipc_max_domain_size;
 #endif
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index 2cfc5f7c6380..a84daec0afe9 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -64,6 +64,7 @@ tipc_nl_name_table_policy[TIPC_NLA_NAME_TABLE_MAX + 1] = {
 
 const struct nla_policy tipc_nl_monitor_policy[TIPC_NLA_MON_MAX + 1] = {
 	[TIPC_NLA_MON_UNSPEC]			= { .type = NLA_UNSPEC },
+	[TIPC_NLA_MON_REF]			= { .type = NLA_U32 },
 	[TIPC_NLA_MON_ACTIVATION_THRESHOLD]	= { .type = NLA_U32 },
 };
 
@@ -229,6 +230,12 @@ static const struct genl_ops tipc_genl_v2_ops[] = {
 	{
 		.cmd	= TIPC_NL_MON_GET,
 		.doit	= tipc_nl_node_get_monitor,
+		.dumpit	= tipc_nl_node_dump_monitor,
+		.policy = tipc_nl_policy,
+	},
+	{
+		.cmd	= TIPC_NL_MON_PEER_GET,
+		.dumpit	= tipc_nl_node_dump_monitor_peer,
 		.policy = tipc_nl_policy,
 	},
 };
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 4a817daa9f6f..efaef5530d01 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -2000,3 +2000,89 @@ int tipc_nl_node_get_monitor(struct sk_buff *skb, struct genl_info *info)
 
 	return genlmsg_reply(msg.skb, info);
 }
+
+int tipc_nl_node_dump_monitor(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct net *net = sock_net(skb->sk);
+	u32 prev_bearer = cb->args[0];
+	struct tipc_nl_msg msg;
+	int err;
+	int i;
+
+	if (prev_bearer == MAX_BEARERS)
+		return 0;
+
+	msg.skb = skb;
+	msg.portid = NETLINK_CB(cb->skb).portid;
+	msg.seq = cb->nlh->nlmsg_seq;
+
+	rtnl_lock();
+	for (i = prev_bearer; i < MAX_BEARERS; i++) {
+		prev_bearer = i;
+		err = __tipc_nl_add_monitor(net, &msg, prev_bearer);
+		if (err)
+			goto out;
+	}
+
+out:
+	rtnl_unlock();
+	cb->args[0] = prev_bearer;
+
+	return skb->len;
+}
+
+int tipc_nl_node_dump_monitor_peer(struct sk_buff *skb,
+				   struct netlink_callback *cb)
+{
+	struct net *net = sock_net(skb->sk);
+	u32 prev_node = cb->args[1];
+	u32 bearer_id = cb->args[2];
+	int done = cb->args[0];
+	struct tipc_nl_msg msg;
+	int err;
+
+	if (!prev_node) {
+		struct nlattr **attrs;
+		struct nlattr *mon[TIPC_NLA_MON_MAX + 1];
+
+		err = tipc_nlmsg_parse(cb->nlh, &attrs);
+		if (err)
+			return err;
+
+		if (!attrs[TIPC_NLA_MON])
+			return -EINVAL;
+
+		err = nla_parse_nested(mon, TIPC_NLA_MON_MAX,
+				       attrs[TIPC_NLA_MON],
+				       tipc_nl_monitor_policy);
+		if (err)
+			return err;
+
+		if (!mon[TIPC_NLA_MON_REF])
+			return -EINVAL;
+
+		bearer_id = nla_get_u32(mon[TIPC_NLA_MON_REF]);
+
+		if (bearer_id >= MAX_BEARERS)
+			return -EINVAL;
+	}
+
+	if (done)
+		return 0;
+
+	msg.skb = skb;
+	msg.portid = NETLINK_CB(cb->skb).portid;
+	msg.seq = cb->nlh->nlmsg_seq;
+
+	rtnl_lock();
+	err = tipc_nl_add_monitor_peer(net, &msg, bearer_id, &prev_node);
+	if (!err)
+		done = 1;
+
+	rtnl_unlock();
+	cb->args[0] = done;
+	cb->args[1] = prev_node;
+	cb->args[2] = bearer_id;
+
+	return skb->len;
+}
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 216f053b817f..d69fdfcc0ec9 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -80,4 +80,7 @@ int tipc_nl_node_set_link(struct sk_buff *skb, struct genl_info *info);
 
 int tipc_nl_node_set_monitor(struct sk_buff *skb, struct genl_info *info);
 int tipc_nl_node_get_monitor(struct sk_buff *skb, struct genl_info *info);
+int tipc_nl_node_dump_monitor(struct sk_buff *skb, struct netlink_callback *cb);
+int tipc_nl_node_dump_monitor_peer(struct sk_buff *skb,
+				   struct netlink_callback *cb);
 #endif
-- 
2.1.4
