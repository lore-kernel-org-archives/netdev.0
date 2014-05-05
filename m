From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 03/10] tipc: rename setup_blocked variable of node struct to flags
Date: Mon, 5 May 2014 08:56:11 +0800
Message-ID: <1399251378-23842-4-git-send-email-ying.xue@windriver.com>
References: <1399251378-23842-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <Paul.Gortmaker@windriver.com>,
	<erik.hugne@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:40118 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754034AbaEEA4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2014 20:56:41 -0400
In-Reply-To: <1399251378-23842-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename setup_blocked variable of node struct to a more common
name called "flags", which will be used to represent kinds of
node states.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c |   20 ++++++++++----------
 net/tipc/node.c |    6 +++---
 net/tipc/node.h |   24 ++++++++++++++++++------
 3 files changed, 31 insertions(+), 19 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 3a80145..ac074aa 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1495,14 +1495,14 @@ void tipc_rcv(struct sk_buff *head, struct tipc_bearer *b_ptr)
 			goto unlock_discard;
 
 		/* Verify that communication with node is currently allowed */
-		if ((n_ptr->block_setup & WAIT_PEER_DOWN) &&
-			msg_user(msg) == LINK_PROTOCOL &&
-			(msg_type(msg) == RESET_MSG ||
-			 msg_type(msg) == ACTIVATE_MSG) &&
-			!msg_redundant_link(msg))
-			n_ptr->block_setup &= ~WAIT_PEER_DOWN;
-
-		if (n_ptr->block_setup)
+		if ((n_ptr->flags & TIPC_NODE_DOWN) &&
+		    msg_user(msg) == LINK_PROTOCOL &&
+		    (msg_type(msg) == RESET_MSG ||
+		    msg_type(msg) == ACTIVATE_MSG) &&
+		    !msg_redundant_link(msg))
+			n_ptr->flags &= ~TIPC_NODE_DOWN;
+
+		if (tipc_node_blocked(n_ptr))
 			goto unlock_discard;
 
 		/* Validate message sequence number info */
@@ -1744,7 +1744,7 @@ void tipc_link_proto_xmit(struct tipc_link *l_ptr, u32 msg_typ, int probe_msg,
 		return;
 
 	/* Abort non-RESET send if communication with node is prohibited */
-	if ((l_ptr->owner->block_setup) && (msg_typ != RESET_MSG))
+	if ((tipc_node_blocked(l_ptr->owner)) && (msg_typ != RESET_MSG))
 		return;
 
 	/* Create protocol message with "out-of-sequence" sequence number */
@@ -1859,7 +1859,7 @@ static void tipc_link_proto_rcv(struct tipc_link *l_ptr, struct sk_buff *buf)
 			 * peer has lost contact -- don't allow peer's links
 			 * to reactivate before we recognize loss & clean up
 			 */
-			l_ptr->owner->block_setup = WAIT_NODE_DOWN;
+			l_ptr->owner->flags = TIPC_NODE_RESET;
 		}
 
 		link_state_event(l_ptr, RESET_MSG);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 6d6543e..2b0a084 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -108,7 +108,7 @@ struct tipc_node *tipc_node_create(u32 addr)
 			break;
 	}
 	list_add_tail_rcu(&n_ptr->list, &temp_node->list);
-	n_ptr->block_setup = WAIT_PEER_DOWN;
+	n_ptr->flags = TIPC_NODE_DOWN;
 	n_ptr->signature = INVALID_NODE_SIG;
 
 	tipc_num_nodes++;
@@ -280,7 +280,7 @@ static void node_name_purge_complete(unsigned long node_addr)
 	n_ptr = tipc_node_find(node_addr);
 	if (n_ptr) {
 		tipc_node_lock(n_ptr);
-		n_ptr->block_setup &= ~WAIT_NAMES_GONE;
+		n_ptr->flags &= ~TIPC_NAMES_GONE;
 		tipc_node_unlock(n_ptr);
 	}
 }
@@ -324,7 +324,7 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 	tipc_nodesub_notify(n_ptr);
 
 	/* Prevent re-contact with node until cleanup is done */
-	n_ptr->block_setup = WAIT_PEER_DOWN | WAIT_NAMES_GONE;
+	n_ptr->flags = TIPC_NODE_DOWN | TIPC_NAMES_GONE;
 	tipc_k_signal((Handler)node_name_purge_complete, n_ptr->addr);
 }
 
diff --git a/net/tipc/node.h b/net/tipc/node.h
index bb7f708..242b918 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -47,10 +47,16 @@
  */
 #define INVALID_NODE_SIG 0x10000
 
-/* Flags used to block (re)establishment of contact with a neighboring node */
-#define WAIT_PEER_DOWN	0x0001	/* wait to see that peer's links are down */
-#define WAIT_NAMES_GONE	0x0002	/* wait for peer's publications to be purged */
-#define WAIT_NODE_DOWN	0x0004	/* wait until peer node is declared down */
+/* Flags used to block (re)establishment of contact with a neighboring node
+ * TIPC_NODE_DOWN: indicate node is down
+ * TIPC_NAMES_GONE: indicate the node's publications are purged
+ * TIPC_NODE_RESET: indicate node is reset
+ */
+enum {
+	TIPC_NODE_DOWN	= (1 << 1),
+	TIPC_NAMES_GONE	= (1 << 2),
+	TIPC_NODE_RESET	= (1 << 3)
+};
 
 /**
  * struct tipc_node_bclink - TIPC node bclink structure
@@ -85,7 +91,7 @@ struct tipc_node_bclink {
  * @hash: links to adjacent nodes in unsorted hash chain
  * @active_links: pointers to active links to node
  * @links: pointers to all links to node
- * @block_setup: bit mask of conditions preventing link establishment to node
+ * @flags: bit mask of conditions preventing link establishment to node
  * @bclink: broadcast-related info
  * @list: links to adjacent nodes in sorted list of cluster's nodes
  * @working_links: number of working links to node (both active and standby)
@@ -100,7 +106,7 @@ struct tipc_node {
 	struct hlist_node hash;
 	struct tipc_link *active_links[2];
 	struct tipc_link *links[MAX_BEARERS];
-	int block_setup;
+	unsigned int flags;
 	struct tipc_node_bclink bclink;
 	struct list_head list;
 	int link_cnt;
@@ -135,4 +141,10 @@ static inline void tipc_node_unlock(struct tipc_node *n_ptr)
 	spin_unlock_bh(&n_ptr->lock);
 }
 
+static inline bool tipc_node_blocked(struct tipc_node *node)
+{
+	return (node->flags & (TIPC_NODE_DOWN | TIPC_NAMES_GONE |
+		TIPC_NODE_RESET));
+}
+
 #endif
-- 
1.7.9.5
