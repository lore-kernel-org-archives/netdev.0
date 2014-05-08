From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 1/2] tipc: rename enum names of node flags
Date: Thu, 8 May 2014 08:54:39 +0800
Message-ID: <1399510480-29558-2-git-send-email-ying.xue@windriver.com>
References: <1399510480-29558-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <Paul.Gortmaker@windriver.com>,
	<erik.hugne@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:41318 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752530AbaEHAzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 20:55:00 -0400
In-Reply-To: <1399510480-29558-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename node flags to action_flags as well as its enum names so
that they can reflect its real meanings.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c |    6 +++---
 net/tipc/node.c |   17 +++++++++--------
 net/tipc/node.h |   29 +++++++++++++----------------
 3 files changed, 25 insertions(+), 27 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index dce2bef..26abb16 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1489,12 +1489,12 @@ void tipc_rcv(struct sk_buff *head, struct tipc_bearer *b_ptr)
 			goto unlock_discard;
 
 		/* Verify that communication with node is currently allowed */
-		if ((n_ptr->flags & TIPC_NODE_DOWN) &&
+		if ((n_ptr->action_flags & TIPC_WAIT_PEER_LINKS_DOWN) &&
 		    msg_user(msg) == LINK_PROTOCOL &&
 		    (msg_type(msg) == RESET_MSG ||
 		    msg_type(msg) == ACTIVATE_MSG) &&
 		    !msg_redundant_link(msg))
-			n_ptr->flags &= ~TIPC_NODE_DOWN;
+			n_ptr->action_flags &= ~TIPC_WAIT_PEER_LINKS_DOWN;
 
 		if (tipc_node_blocked(n_ptr))
 			goto unlock_discard;
@@ -1853,7 +1853,7 @@ static void tipc_link_proto_rcv(struct tipc_link *l_ptr, struct sk_buff *buf)
 			 * peer has lost contact -- don't allow peer's links
 			 * to reactivate before we recognize loss & clean up
 			 */
-			l_ptr->owner->flags = TIPC_NODE_RESET;
+			l_ptr->owner->action_flags = TIPC_WAIT_OWN_LINKS_DOWN;
 		}
 
 		link_state_event(l_ptr, RESET_MSG);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 74efebc..bb66a26 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -108,7 +108,7 @@ struct tipc_node *tipc_node_create(u32 addr)
 			break;
 	}
 	list_add_tail_rcu(&n_ptr->list, &temp_node->list);
-	n_ptr->flags = TIPC_NODE_DOWN;
+	n_ptr->action_flags = TIPC_WAIT_PEER_LINKS_DOWN;
 	n_ptr->signature = INVALID_NODE_SIG;
 
 	tipc_num_nodes++;
@@ -267,7 +267,7 @@ void tipc_node_detach_link(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 
 static void node_established_contact(struct tipc_node *n_ptr)
 {
-	n_ptr->flags |= TIPC_NODE_UP;
+	n_ptr->action_flags |= TIPC_NOTIFY_NODE_UP;
 	n_ptr->bclink.oos_state = 0;
 	n_ptr->bclink.acked = tipc_bclink_get_last_sent();
 	tipc_bclink_add_node(n_ptr->addr);
@@ -311,7 +311,8 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 	/* Notify subscribers and prevent re-contact with node until
 	 * cleanup is done.
 	 */
-	n_ptr->flags = TIPC_NODE_DOWN | TIPC_NODE_LOST;
+	n_ptr->action_flags = TIPC_WAIT_PEER_LINKS_DOWN |
+			      TIPC_NOTIFY_NODE_DOWN;
 }
 
 struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
@@ -459,18 +460,18 @@ void tipc_node_unlock(struct tipc_node *node)
 	int pkt_sz = 0;
 	u32 addr = 0;
 
-	if (likely(!node->flags)) {
+	if (likely(!node->action_flags)) {
 		spin_unlock_bh(&node->lock);
 		return;
 	}
 
-	if (node->flags & TIPC_NODE_LOST) {
+	if (node->action_flags & TIPC_NOTIFY_NODE_DOWN) {
 		list_replace_init(&node->nsub, &nsub_list);
-		node->flags &= ~TIPC_NODE_LOST;
+		node->action_flags &= ~TIPC_NOTIFY_NODE_DOWN;
 	}
-	if (node->flags & TIPC_NODE_UP) {
+	if (node->action_flags & TIPC_NOTIFY_NODE_UP) {
 		link = node->active_links[0];
-		node->flags &= ~TIPC_NODE_UP;
+		node->action_flags &= ~TIPC_NOTIFY_NODE_UP;
 		if (link) {
 			pkt_sz = ((link->max_pkt - INT_H_SIZE) / ITEM_SIZE) *
 				  ITEM_SIZE;
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 38f710f..3c19113 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -47,20 +47,17 @@
  */
 #define INVALID_NODE_SIG 0x10000
 
-/* Flags used to block (re)establishment of contact with a neighboring node
- * TIPC_NODE_DOWN: indicate node is down and it's used to block the node's
- *                 links until RESET or ACTIVE message arrives
- * TIPC_NODE_RESET: indicate node is reset
- * TIPC_NODE_LOST: indicate node is lost and it's used to notify subscriptions
- *                 when node lock is released
- * TIPC_NODE_UP: indicate node is up and it's used to deliver local name table
- *               when node lock is released
+/* Flags used to take different actions according to flag type
+ * TIPC_WAIT_PEER_LINKS_DOWN: wait to see that peer's links are down
+ * TIPC_WAIT_OWN_LINKS_DOWN: wait until peer node is declared down
+ * TIPC_NOTIFY_NODE_DOWN: notify node is down
+ * TIPC_NOTIFY_NODE_UP: notify node is up
  */
 enum {
-	TIPC_NODE_DOWN	= (1 << 1),
-	TIPC_NODE_RESET	= (1 << 2),
-	TIPC_NODE_LOST	= (1 << 3),
-	TIPC_NODE_UP	= (1 << 4)
+	TIPC_WAIT_PEER_LINKS_DOWN	= (1 << 1),
+	TIPC_WAIT_OWN_LINKS_DOWN	= (1 << 2),
+	TIPC_NOTIFY_NODE_DOWN		= (1 << 3),
+	TIPC_NOTIFY_NODE_UP		= (1 << 4)
 };
 
 /**
@@ -96,7 +93,7 @@ struct tipc_node_bclink {
  * @hash: links to adjacent nodes in unsorted hash chain
  * @active_links: pointers to active links to node
  * @links: pointers to all links to node
- * @flags: bit mask of conditions preventing link establishment to node
+ * @action_flags: bit mask of different types of node actions
  * @bclink: broadcast-related info
  * @list: links to adjacent nodes in sorted list of cluster's nodes
  * @working_links: number of working links to node (both active and standby)
@@ -111,7 +108,7 @@ struct tipc_node {
 	struct hlist_node hash;
 	struct tipc_link *active_links[2];
 	struct tipc_link *links[MAX_BEARERS];
-	unsigned int flags;
+	unsigned int action_flags;
 	struct tipc_node_bclink bclink;
 	struct list_head list;
 	int link_cnt;
@@ -144,8 +141,8 @@ static inline void tipc_node_lock(struct tipc_node *node)
 
 static inline bool tipc_node_blocked(struct tipc_node *node)
 {
-	return (node->flags & (TIPC_NODE_DOWN | TIPC_NODE_LOST |
-		TIPC_NODE_RESET));
+	return (node->action_flags & (TIPC_WAIT_PEER_LINKS_DOWN |
+		TIPC_NOTIFY_NODE_DOWN | TIPC_WAIT_OWN_LINKS_DOWN));
 }
 
 #endif
-- 
1.7.9.5
