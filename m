From: <richard.alpe@ericsson.com>
Subject: [PATCH v3 net-next 11/14] tipc: add node get/dump
	to new netlink api
Date: Thu, 20 Nov 2014 10:29:17 +0100
Message-ID: <1416475760-18914-12-git-send-email-richard.alpe@ericsson.com>
References: <1416475760-18914-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1416475760-18914-1-git-send-email-richard.alpe@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Richard Alpe <richard.alpe@ericsson.com>

Add TIPC_NL_NODE_GET to the new tipc netlink API.

This command can dump the address and node status of all nodes in the
tipc cluster.

Netlink logical layout of returned node/address data:
-> node
    -> address
    -> up flag

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
---
 include/uapi/linux/tipc_netlink.h |   12 +++++
 net/tipc/netlink.c                |    7 +++
 net/tipc/node.c                   |   96 +++++++++++++++++++++++++++++++++++++
 net/tipc/node.h                   |    4 +-
 4 files changed, 118 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/tipc_netlink.h b/include/uapi/linux/tipc_netlink.h
index 43beef2..08a7933 100644
--- a/include/uapi/linux/tipc_netlink.h
+++ b/include/uapi/linux/tipc_netlink.h
@@ -52,6 +52,7 @@ enum {
 	TIPC_NL_LINK_RESET_STATS,
 	TIPC_NL_MEDIA_GET,
 	TIPC_NL_MEDIA_SET,
+	TIPC_NL_NODE_GET,
 
 	__TIPC_NL_CMD_MAX,
 	TIPC_NL_CMD_MAX = __TIPC_NL_CMD_MAX - 1
@@ -65,6 +66,7 @@ enum {
 	TIPC_NLA_PUBL,			/* nest */
 	TIPC_NLA_LINK,			/* nest */
 	TIPC_NLA_MEDIA,			/* nest */
+	TIPC_NLA_NODE,			/* nest */
 
 	__TIPC_NLA_MAX,
 	TIPC_NLA_MAX = __TIPC_NLA_MAX - 1
@@ -121,6 +123,16 @@ enum {
 	TIPC_NLA_MEDIA_MAX = __TIPC_NLA_MEDIA_MAX - 1
 };
 
+/* Node info */
+enum {
+	TIPC_NLA_NODE_UNSPEC,
+	TIPC_NLA_NODE_ADDR,		/* u32 */
+	TIPC_NLA_NODE_UP,		/* flag */
+
+	__TIPC_NLA_NODE_MAX,
+	TIPC_NLA_NODE_MAX = __TIPC_NLA_NODE_MAX - 1
+};
+
 /* Publication info */
 enum {
 	TIPC_NLA_PUBL_UNSPEC,
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index 8673e37..5b0e3c8 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -39,6 +39,7 @@
 #include "socket.h"
 #include "bearer.h"
 #include "link.h"
+#include "node.h"
 #include <net/genetlink.h>
 
 static int handle_cmd(struct sk_buff *skb, struct genl_info *info)
@@ -78,6 +79,7 @@ static const struct nla_policy tipc_nl_policy[TIPC_NLA_MAX + 1] = {
 	[TIPC_NLA_PUBL]		= { .type = NLA_NESTED, },
 	[TIPC_NLA_LINK]		= { .type = NLA_NESTED, },
 	[TIPC_NLA_MEDIA]	= { .type = NLA_NESTED, },
+	[TIPC_NLA_NODE]		= { .type = NLA_NESTED, }
 };
 
 /* Legacy ASCII API */
@@ -166,6 +168,11 @@ static const struct genl_ops tipc_genl_v2_ops[] = {
 		.cmd	= TIPC_NL_MEDIA_SET,
 		.doit	= tipc_nl_media_set,
 		.policy = tipc_nl_policy,
+	},
+	{
+		.cmd	= TIPC_NL_NODE_GET,
+		.dumpit	= tipc_nl_node_dump,
+		.policy = tipc_nl_policy,
 	}
 };
 
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 5781634..72a75d4 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -58,6 +58,12 @@ struct tipc_sock_conn {
 	struct list_head list;
 };
 
+static const struct nla_policy tipc_nl_node_policy[TIPC_NLA_NODE_MAX + 1] = {
+	[TIPC_NLA_NODE_UNSPEC]		= { .type = NLA_UNSPEC },
+	[TIPC_NLA_NODE_ADDR]		= { .type = NLA_U32 },
+	[TIPC_NLA_NODE_UP]		= { .type = NLA_FLAG }
+};
+
 /*
  * A trivial power-of-two bitmask technique is used for speed, since this
  * operation is done for every incoming TIPC packet. The number of hash table
@@ -601,3 +607,93 @@ void tipc_node_unlock(struct tipc_node *node)
 		tipc_nametbl_withdraw(TIPC_LINK_STATE, addr,
 				      link_id, addr);
 }
+
+/* Caller should hold node lock for the passed node */
+int __tipc_nl_add_node(struct tipc_nl_msg *msg, struct tipc_node *node)
+{
+	void *hdr;
+	struct nlattr *attrs;
+
+	hdr = genlmsg_put(msg->skb, msg->portid, msg->seq, &tipc_genl_v2_family,
+			  NLM_F_MULTI, TIPC_NL_NODE_GET);
+	if (!hdr)
+		return -EMSGSIZE;
+
+	attrs = nla_nest_start(msg->skb, TIPC_NLA_NODE);
+	if (!attrs)
+		goto msg_full;
+
+	if (nla_put_u32(msg->skb, TIPC_NLA_NODE_ADDR, node->addr))
+		goto attr_msg_full;
+	if (tipc_node_is_up(node))
+		if (nla_put_flag(msg->skb, TIPC_NLA_NODE_UP))
+			goto attr_msg_full;
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
+int tipc_nl_node_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	int err;
+	int done = cb->args[0];
+	int last_addr = cb->args[1];
+	struct tipc_node *node;
+	struct tipc_nl_msg msg;
+
+	if (done)
+		return 0;
+
+	msg.skb = skb;
+	msg.portid = NETLINK_CB(cb->skb).portid;
+	msg.seq = cb->nlh->nlmsg_seq;
+
+	rcu_read_lock();
+
+	if (last_addr && !tipc_node_find(last_addr)) {
+		rcu_read_unlock();
+		/* We never set seq or call nl_dump_check_consistent() this
+		 * means that setting prev_seq here will cause the consistence
+		 * check to fail in the netlink callback handler. Resulting in
+		 * the NLMSG_DONE message having the NLM_F_DUMP_INTR flag set if
+		 * the node state changed while we released the lock.
+		 */
+		cb->prev_seq = 1;
+		return -EPIPE;
+	}
+
+	list_for_each_entry_rcu(node, &tipc_node_list, list) {
+		if (last_addr) {
+			if (node->addr == last_addr)
+				last_addr = 0;
+			else
+				continue;
+		}
+
+		tipc_node_lock(node);
+		err = __tipc_nl_add_node(&msg, node);
+		if (err) {
+			last_addr = node->addr;
+			tipc_node_unlock(node);
+			goto out;
+		}
+
+		tipc_node_unlock(node);
+	}
+	done = 1;
+out:
+	cb->args[0] = done;
+	cb->args[1] = last_addr;
+	rcu_read_unlock();
+
+	return skb->len;
+}
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 04e9145..005fbce 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -1,7 +1,7 @@
 /*
  * net/tipc/node.h: Include file for TIPC node management routines
  *
- * Copyright (c) 2000-2006, Ericsson AB
+ * Copyright (c) 2000-2006, 2014, Ericsson AB
  * Copyright (c) 2005, 2010-2014, Wind River Systems
  * All rights reserved.
  *
@@ -145,6 +145,8 @@ void tipc_node_unlock(struct tipc_node *node);
 int tipc_node_add_conn(u32 dnode, u32 port, u32 peer_port);
 void tipc_node_remove_conn(u32 dnode, u32 port);
 
+int tipc_nl_node_dump(struct sk_buff *skb, struct netlink_callback *cb);
+
 static inline void tipc_node_lock(struct tipc_node *node)
 {
 	spin_lock_bh(&node->lock);
-- 
1.7.10.4


------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=157005751&iu=/4140/ostg.clktrk
