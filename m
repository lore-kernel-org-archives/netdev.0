From: Richard Alpe <richard.alpe@ericsson.com>
Subject: [PATCH net-next v2] tipc: add peer removal
	functionality
Date: Tue, 12 Jan 2016 15:08:16 +0100
Message-ID: <1452607696-24216-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Add TIPC_NL_PEER_REMOVE netlink command. This command can remove
an offline peer node from the internal data structures.

This will be supported by the tipc user space tool in iproute2.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
---
 include/uapi/linux/tipc_netlink.h |  1 +
 net/tipc/net.c                    |  4 +--
 net/tipc/net.h                    |  2 ++
 net/tipc/netlink.c                |  5 ++++
 net/tipc/node.c                   | 60 +++++++++++++++++++++++++++++++++++----
 net/tipc/node.h                   |  3 +-
 6 files changed, 66 insertions(+), 9 deletions(-)

diff --git a/include/uapi/linux/tipc_netlink.h b/include/uapi/linux/tipc_netlink.h
index d4c8f14..25eb645 100644
--- a/include/uapi/linux/tipc_netlink.h
+++ b/include/uapi/linux/tipc_netlink.h
@@ -56,6 +56,7 @@ enum {
 	TIPC_NL_NET_GET,
 	TIPC_NL_NET_SET,
 	TIPC_NL_NAME_TABLE_GET,
+	TIPC_NL_PEER_REMOVE,
 
 	__TIPC_NL_CMD_MAX,
 	TIPC_NL_CMD_MAX = __TIPC_NL_CMD_MAX - 1
diff --git a/net/tipc/net.c b/net/tipc/net.c
index 77bf911..042d4ce 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -42,7 +42,7 @@
 #include "node.h"
 #include "bcast.h"
 
-static const struct nla_policy tipc_nl_net_policy[TIPC_NLA_NET_MAX + 1] = {
+const struct nla_policy tipc_nl_net_policy[TIPC_NLA_NET_MAX + 1] = {
 	[TIPC_NLA_NET_UNSPEC]	= { .type = NLA_UNSPEC },
 	[TIPC_NLA_NET_ID]	= { .type = NLA_U32 }
 };
@@ -139,7 +139,7 @@ void tipc_net_stop(struct net *net)
 			      tn->own_addr);
 	rtnl_lock();
 	tipc_bearer_stop(net);
-	tipc_node_stop(net);
+	tipc_node_stop_net(net);
 	rtnl_unlock();
 
 	pr_info("Left network mode\n");
diff --git a/net/tipc/net.h b/net/tipc/net.h
index 77a7a11..c7c2549 100644
--- a/net/tipc/net.h
+++ b/net/tipc/net.h
@@ -39,6 +39,8 @@
 
 #include <net/genetlink.h>
 
+extern const struct nla_policy tipc_nl_net_policy[];
+
 int tipc_net_start(struct net *net, u32 addr);
 
 void tipc_net_stop(struct net *net);
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index 8975b01..9019df8 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -145,6 +145,11 @@ static const struct genl_ops tipc_genl_v2_ops[] = {
 		.cmd	= TIPC_NL_NAME_TABLE_GET,
 		.dumpit	= tipc_nl_name_table_dump,
 		.policy = tipc_nl_policy,
+	},
+	{
+		.cmd	= TIPC_NL_PEER_REMOVE,
+		.doit	= tipc_nl_peer_rm,
+		.policy = tipc_nl_policy,
 	}
 };
 
diff --git a/net/tipc/node.c b/net/tipc/node.c
index fa97d96..988cdd9 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -399,17 +399,21 @@ static void tipc_node_delete(struct tipc_node *node)
 	kfree_rcu(node, rcu);
 }
 
-void tipc_node_stop(struct net *net)
+static void tipc_node_stop(struct tipc_node *node)
+{
+	if (del_timer(&node->timer))
+		tipc_node_put(node);
+	tipc_node_put(node);
+}
+
+void tipc_node_stop_net(struct net *net)
 {
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_node *node, *t_node;
 
 	spin_lock_bh(&tn->node_list_lock);
-	list_for_each_entry_safe(node, t_node, &tn->node_list, list) {
-		if (del_timer(&node->timer))
-			tipc_node_put(node);
-		tipc_node_put(node);
-	}
+	list_for_each_entry_safe(node, t_node, &tn->node_list, list)
+		tipc_node_stop(node);
 	spin_unlock_bh(&tn->node_list_lock);
 }
 
@@ -1529,6 +1533,50 @@ discard:
 	kfree_skb(skb);
 }
 
+int tipc_nl_peer_rm(struct sk_buff *skb, struct genl_info *info)
+{
+	int err;
+	u32 addr;
+	struct net *net = sock_net(skb->sk);
+	struct nlattr *attrs[TIPC_NLA_NET_MAX + 1];
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
+	struct tipc_node *peer;
+
+	/* We identify the peer by its net */
+	if (!info->attrs[TIPC_NLA_NET])
+		return -EINVAL;
+
+	err = nla_parse_nested(attrs, TIPC_NLA_NET_MAX,
+			       info->attrs[TIPC_NLA_NET],
+			       tipc_nl_net_policy);
+	if (err)
+		return err;
+
+	if (!attrs[TIPC_NLA_NET_ADDR])
+		return -EINVAL;
+
+	addr = nla_get_u32(attrs[TIPC_NLA_NET_ADDR]);
+
+	spin_lock_bh(&tn->node_list_lock);
+	list_for_each_entry_rcu(peer, &tn->node_list, list) {
+		if (peer->addr != addr)
+			continue;
+
+		if (peer->state == SELF_DOWN_PEER_DOWN ||
+		    peer->state == SELF_DOWN_PEER_LEAVING) {
+			tipc_node_stop(peer);
+
+			spin_unlock_bh(&tn->node_list_lock);
+			return 0;
+		}
+		spin_unlock_bh(&tn->node_list_lock);
+		return -EBUSY;
+	}
+	spin_unlock_bh(&tn->node_list_lock);
+
+	return -ENXIO;
+}
+
 int tipc_nl_node_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	int err;
diff --git a/net/tipc/node.h b/net/tipc/node.h
index f39d9d0..8dfb6ba 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -51,7 +51,7 @@ enum {
 #define TIPC_NODE_CAPABILITIES TIPC_BCAST_SYNCH
 #define INVALID_BEARER_ID -1
 
-void tipc_node_stop(struct net *net);
+void tipc_node_stop_net(struct net *net);
 void tipc_node_check_dest(struct net *net, u32 onode,
 			  struct tipc_bearer *bearer,
 			  u16 capabilities, u32 signature,
@@ -75,5 +75,6 @@ int tipc_nl_node_dump_link(struct sk_buff *skb, struct netlink_callback *cb);
 int tipc_nl_node_reset_link_stats(struct sk_buff *skb, struct genl_info *info);
 int tipc_nl_node_get_link(struct sk_buff *skb, struct genl_info *info);
 int tipc_nl_node_set_link(struct sk_buff *skb, struct genl_info *info);
+int tipc_nl_peer_rm(struct sk_buff *skb, struct genl_info *info);
 
 #endif
-- 
2.1.4


------------------------------------------------------------------------------
Site24x7 APM Insight: Get Deep Visibility into Application Performance
APM + Mobile APM + RUM: Monitor 3 App instances at just $35/Month
Monitor end-to-end web transactions and take corrective actions now
Troubleshoot faster and improve end-user experience. Signup Now!
http://pubads.g.doubleclick.net/gampad/clk?id=267308311&iu=/4140
