From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 2/3] tipc: propagate peer node
	capabilities to socket layer
Date: Mon,  2 May 2016 10:22:35 -0400
Message-ID: <1462198956-30181-3-git-send-email-jon.maloy@ericsson.com>
References: <1462198956-30181-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1462198956-30181-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

During neighbor discovery, nodes advertise their capabilities as a bit
map in a dedicated 16-bit field in the discovery message header. This
bit map has so far only be stored in the node structure on the peer
nodes, but we now see the need to keep a copy even in the socket
structure.

This commit adds this functionality.

Acked-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/node.c   | 21 +++++++++++++++++++--
 net/tipc/node.h   |  1 +
 net/tipc/socket.c |  2 ++
 3 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index c299156..29cc853 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -1,7 +1,7 @@
 /*
  * net/tipc/node.c: TIPC node management routines
  *
- * Copyright (c) 2000-2006, 2012-2015, Ericsson AB
+ * Copyright (c) 2000-2006, 2012-2016, Ericsson AB
  * Copyright (c) 2005-2006, 2010-2014, Wind River Systems
  * All rights reserved.
  *
@@ -191,6 +191,20 @@ int tipc_node_get_mtu(struct net *net, u32 addr, u32 sel)
 	tipc_node_put(n);
 	return mtu;
 }
+
+u16 tipc_node_get_capabilities(struct net *net, u32 addr)
+{
+	struct tipc_node *n;
+	u16 caps;
+
+	n = tipc_node_find(net, addr);
+	if (unlikely(!n))
+		return TIPC_NODE_CAPABILITIES;
+	caps = n->capabilities;
+	tipc_node_put(n);
+	return caps;
+}
+
 /*
  * A trivial power-of-two bitmask technique is used for speed, since this
  * operation is done for every incoming TIPC packet. The number of hash table
@@ -304,8 +318,11 @@ struct tipc_node *tipc_node_create(struct net *net, u32 addr, u16 capabilities)
 
 	spin_lock_bh(&tn->node_list_lock);
 	n = tipc_node_find(net, addr);
-	if (n)
+	if (n) {
+		/* Same node may come back with new capabilities */
+		n->capabilities = capabilities;
 		goto exit;
+	}
 	n = kzalloc(sizeof(*n), GFP_ATOMIC);
 	if (!n) {
 		pr_warn("Node creation failed, no memory\n");
diff --git a/net/tipc/node.h b/net/tipc/node.h
index f39d9d0..1823768 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -70,6 +70,7 @@ void tipc_node_broadcast(struct net *net, struct sk_buff *skb);
 int tipc_node_add_conn(struct net *net, u32 dnode, u32 port, u32 peer_port);
 void tipc_node_remove_conn(struct net *net, u32 dnode, u32 port);
 int tipc_node_get_mtu(struct net *net, u32 addr, u32 sel);
+u16 tipc_node_get_capabilities(struct net *net, u32 addr);
 int tipc_nl_node_dump(struct sk_buff *skb, struct netlink_callback *cb);
 int tipc_nl_node_dump_link(struct sk_buff *skb, struct netlink_callback *cb);
 int tipc_nl_node_reset_link_stats(struct sk_buff *skb, struct genl_info *info);
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index d37a940..94bd286 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -98,6 +98,7 @@ struct tipc_sock {
 	bool link_cong;
 	uint sent_unacked;
 	uint rcv_unacked;
+	u16 peer_caps;
 	struct sockaddr_tipc remote;
 	struct rhash_head node;
 	struct rcu_head rcu;
@@ -1118,6 +1119,7 @@ static void tipc_sk_finish_conn(struct tipc_sock *tsk, u32 peer_port,
 	sk_reset_timer(sk, &sk->sk_timer, jiffies + tsk->probing_intv);
 	tipc_node_add_conn(net, peer_node, tsk->portid, peer_port);
 	tsk->max_pkt = tipc_node_get_mtu(net, peer_node, tsk->portid);
+	tsk->peer_caps = tipc_node_get_capabilities(net, peer_node);
 }
 
 /**
-- 
1.9.1


------------------------------------------------------------------------------
Find and fix application performance issues faster with Applications Manager
Applications Manager provides deep performance insights into multiple tiers of
your business applications. It resolves application problems quickly and
reduces your MTTR. Get your free trial!
https://ad.doubleclick.net/ddm/clk/302982198;130105516;z
