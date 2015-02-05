From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 7/9] tipc: simplify connection
	abort notifications when links break
Date: Thu,  5 Feb 2015 08:36:42 -0500
Message-ID: <1423143404-23322-8-git-send-email-jon.maloy@ericsson.com>
References: <1423143404-23322-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1423143404-23322-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The new input message queue in struct tipc_link can be used for
delivering connection abort messages to subscribing sockets. This
makes it possible to simplify the code for such cases.

This commit removes the temporary list in tipc_node_unlock()
used for transforming abort subscriptions to messages. Instead, the
abort messages are now created at the moment of lost contact, and
then added to the last failed link's generic input queue for delivery
to the sockets concerned.

Reviewed-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/node.c | 69 ++++++++++++++++++++++++---------------------------------
 1 file changed, 29 insertions(+), 40 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index dcb83d9..c7fdf3d 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -194,28 +194,6 @@ void tipc_node_remove_conn(struct net *net, u32 dnode, u32 port)
 	tipc_node_unlock(node);
 }
 
-void tipc_node_abort_sock_conns(struct net *net, struct list_head *conns)
-{
-	struct tipc_net *tn = net_generic(net, tipc_net_id);
-	struct tipc_sock_conn *conn, *safe;
-	struct sk_buff *skb;
-	struct sk_buff_head skbs;
-
-	skb_queue_head_init(&skbs);
-	list_for_each_entry_safe(conn, safe, conns, list) {
-		skb = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE,
-				      TIPC_CONN_MSG, SHORT_H_SIZE, 0,
-				      tn->own_addr, conn->peer_node,
-				      conn->port, conn->peer_port,
-				      TIPC_ERR_NO_NODE);
-		if (likely(skb))
-			skb_queue_tail(&skbs, skb);
-		list_del(&conn->list);
-		kfree(conn);
-	}
-	tipc_sk_rcv(net, &skbs);
-}
-
 /**
  * tipc_node_link_up - handle addition of link
  *
@@ -377,7 +355,11 @@ static void node_established_contact(struct tipc_node *n_ptr)
 static void node_lost_contact(struct tipc_node *n_ptr)
 {
 	char addr_string[16];
-	u32 i;
+	struct tipc_sock_conn *conn, *safe;
+	struct list_head *conns = &n_ptr->conn_sks;
+	struct sk_buff *skb;
+	struct tipc_net *tn = net_generic(n_ptr->net, tipc_net_id);
+	uint i;
 
 	pr_debug("Lost contact with %s\n",
 		 tipc_addr_string_fill(addr_string, n_ptr->addr));
@@ -413,11 +395,25 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 
 	n_ptr->action_flags &= ~TIPC_WAIT_OWN_LINKS_DOWN;
 
-	/* Notify subscribers and prevent re-contact with node until
-	 * cleanup is done.
-	 */
-	n_ptr->action_flags |= TIPC_WAIT_PEER_LINKS_DOWN |
-			       TIPC_NOTIFY_NODE_DOWN;
+	/* Prevent re-contact with node until cleanup is done */
+	n_ptr->action_flags |= TIPC_WAIT_PEER_LINKS_DOWN;
+
+	/* Notify publications from this node */
+	n_ptr->action_flags |= TIPC_NOTIFY_NODE_DOWN;
+
+	/* Notify sockets connected to node */
+	list_for_each_entry_safe(conn, safe, conns, list) {
+		skb = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE, TIPC_CONN_MSG,
+				      SHORT_H_SIZE, 0, tn->own_addr,
+				      conn->peer_node, conn->port,
+				      conn->peer_port, TIPC_ERR_NO_NODE);
+		if (likely(skb)) {
+			skb_queue_tail(n_ptr->inputq, skb);
+			n_ptr->action_flags |= TIPC_MSG_EVT;
+		}
+		list_del(&conn->list);
+		kfree(conn);
+	}
 }
 
 struct sk_buff *tipc_node_get_nodes(struct net *net, const void *req_tlv_area,
@@ -566,13 +562,12 @@ int tipc_node_get_linkname(struct net *net, u32 bearer_id, u32 addr,
 void tipc_node_unlock(struct tipc_node *node)
 {
 	struct net *net = node->net;
-	LIST_HEAD(nsub_list);
-	LIST_HEAD(conn_sks);
 	u32 addr = 0;
 	u32 flags = node->action_flags;
 	u32 link_id = 0;
+	struct list_head *publ_list;
 	struct sk_buff_head *inputq = node->inputq;
-	struct sk_buff_head *namedq = node->inputq;
+	struct sk_buff_head *namedq;
 
 	if (likely(!flags || (flags == TIPC_MSG_EVT))) {
 		node->action_flags = 0;
@@ -585,11 +580,8 @@ void tipc_node_unlock(struct tipc_node *node)
 	addr = node->addr;
 	link_id = node->link_id;
 	namedq = node->namedq;
+	publ_list = &node->publ_list;
 
-	if (flags & TIPC_NOTIFY_NODE_DOWN) {
-		list_replace_init(&node->publ_list, &nsub_list);
-		list_replace_init(&node->conn_sks, &conn_sks);
-	}
 	node->action_flags &= ~(TIPC_MSG_EVT | TIPC_NOTIFY_NODE_DOWN |
 				TIPC_NOTIFY_NODE_UP | TIPC_NOTIFY_LINK_UP |
 				TIPC_NOTIFY_LINK_DOWN |
@@ -598,11 +590,8 @@ void tipc_node_unlock(struct tipc_node *node)
 
 	spin_unlock_bh(&node->lock);
 
-	if (!list_empty(&conn_sks))
-		tipc_node_abort_sock_conns(net, &conn_sks);
-
-	if (!list_empty(&nsub_list))
-		tipc_publ_notify(net, &nsub_list, addr);
+	if (flags & TIPC_NOTIFY_NODE_DOWN)
+		tipc_publ_notify(net, publ_list, addr);
 
 	if (flags & TIPC_WAKEUP_BCAST_USERS)
 		tipc_bclink_wakeup_users(net);
-- 
1.9.1


------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
