From: Richard Alpe <richard.alpe@ericsson.com>
Subject: [PATCH net-next v1 2/2] tipc: add peer removal
	functionality
Date: Tue, 5 Jan 2016 10:56:17 +0100
Message-ID: <1451987777-17421-2-git-send-email-richard.alpe@ericsson.com>
References: <1451987777-17421-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1451987777-17421-1-git-send-email-richard.alpe@ericsson.com>
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
 net/tipc/net.c                    |  2 +-
 net/tipc/netlink.c                |  5 ++++
 net/tipc/node.c                   | 60 +++++++++++++++++++++++++++++++++++----
 net/tipc/node.h                   |  3 +-
 5 files changed, 63 insertions(+), 8 deletions(-)

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
index d7a5c11..bc6b4a6 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -135,7 +135,7 @@ void tipc_net_stop(struct net *net)
 			      tn->own_addr);
 	rtnl_lock();
 	tipc_bearer_stop(net);
-	tipc_node_stop(net);
+	tipc_node_stop_net(net);
 	rtnl_unlock();
 
 	pr_info("Left network mode\n");
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index 234cb93..87c3ffa 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -134,6 +134,11 @@ static const struct genl_ops tipc_genl_v2_ops[] = {
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
index ee6f93c..7334547 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -378,17 +378,21 @@ static void tipc_node_delete(struct tipc_node *node)
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
 
@@ -1508,6 +1512,50 @@ discard:
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
