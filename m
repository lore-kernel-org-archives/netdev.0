From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [net-next 03/18] tipc: add ability to obtain node availability status from other files
Date: Thu, 12 Oct 2017 16:02:24 +0200
Message-ID: <1507816959-31787-4-git-send-email-jon.maloy@ericsson.com>
References: <1507816959-31787-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <parthasarathy.bhuvaragan@ericsson.com>, <ying.xue@windriver.com>,
        <tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:59245 "EHLO
        sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750964AbdJLOCw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 10:02:52 -0400
In-Reply-To: <1507816959-31787-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the coming commits, functions at the socket level will need the
ability to read the availability status of a given node. We therefore
introduce a new function for this purpose, while renaming the existing
static function currently having the wanted name.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/node.c | 26 +++++++++++++++++++++-----
 net/tipc/node.h |  1 +
 2 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index 198dbc7..6cc1ae6 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -157,7 +157,7 @@ static void tipc_node_timeout(unsigned long data);
 static void tipc_node_fsm_evt(struct tipc_node *n, int evt);
 static struct tipc_node *tipc_node_find(struct net *net, u32 addr);
 static void tipc_node_put(struct tipc_node *node);
-static bool tipc_node_is_up(struct tipc_node *n);
+static bool node_is_up(struct tipc_node *n);
 
 struct tipc_sock_conn {
 	u32 port;
@@ -657,7 +657,7 @@ static void __tipc_node_link_down(struct tipc_node *n, int *bearer_id,
 		*slot1 = i;
 	}
 
-	if (!tipc_node_is_up(n)) {
+	if (!node_is_up(n)) {
 		if (tipc_link_peer_is_down(l))
 			tipc_node_fsm_evt(n, PEER_LOST_CONTACT_EVT);
 		tipc_node_fsm_evt(n, SELF_LOST_CONTACT_EVT);
@@ -717,11 +717,27 @@ static void tipc_node_link_down(struct tipc_node *n, int bearer_id, bool delete)
 	tipc_sk_rcv(n->net, &le->inputq);
 }
 
-static bool tipc_node_is_up(struct tipc_node *n)
+static bool node_is_up(struct tipc_node *n)
 {
 	return n->active_links[0] != INVALID_BEARER_ID;
 }
 
+bool tipc_node_is_up(struct net *net, u32 addr)
+{
+	struct tipc_node *n;
+	bool retval = false;
+
+	if (in_own_node(net, addr))
+		return true;
+
+	n = tipc_node_find(net, addr);
+	if (!n)
+		return false;
+	retval = node_is_up(n);
+	tipc_node_put(n);
+	return retval;
+}
+
 void tipc_node_check_dest(struct net *net, u32 onode,
 			  struct tipc_bearer *b,
 			  u16 capabilities, u32 signature,
@@ -1149,7 +1165,7 @@ static int __tipc_nl_add_node(struct tipc_nl_msg *msg, struct tipc_node *node)
 
 	if (nla_put_u32(msg->skb, TIPC_NLA_NODE_ADDR, node->addr))
 		goto attr_msg_full;
-	if (tipc_node_is_up(node))
+	if (node_is_up(node))
 		if (nla_put_flag(msg->skb, TIPC_NLA_NODE_UP))
 			goto attr_msg_full;
 
@@ -1249,7 +1265,7 @@ void tipc_node_broadcast(struct net *net, struct sk_buff *skb)
 		dst = n->addr;
 		if (in_own_node(net, dst))
 			continue;
-		if (!tipc_node_is_up(n))
+		if (!node_is_up(n))
 			continue;
 		txskb = pskb_copy(skb, GFP_ATOMIC);
 		if (!txskb)
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 898c229..8db59fe 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -76,6 +76,7 @@ void tipc_node_broadcast(struct net *net, struct sk_buff *skb);
 int tipc_node_add_conn(struct net *net, u32 dnode, u32 port, u32 peer_port);
 void tipc_node_remove_conn(struct net *net, u32 dnode, u32 port);
 int tipc_node_get_mtu(struct net *net, u32 addr, u32 sel);
+bool tipc_node_is_up(struct net *net, u32 addr);
 u16 tipc_node_get_capabilities(struct net *net, u32 addr);
 int tipc_nl_node_dump(struct sk_buff *skb, struct netlink_callback *cb);
 int tipc_nl_node_dump_link(struct sk_buff *skb, struct netlink_callback *cb);
-- 
2.1.4
