From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 05/10] tipc: remove TIPC_NAMES_GONE node flag
Date: Mon, 5 May 2014 08:56:13 +0800
Message-ID: <1399251378-23842-6-git-send-email-ying.xue@windriver.com>
References: <1399251378-23842-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <Paul.Gortmaker@windriver.com>,
	<erik.hugne@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:40125 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754018AbaEEA4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2014 20:56:45 -0400
In-Reply-To: <1399251378-23842-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since previously what all publications pertaining to the lost node
were removed from name table was finished in tasklet context
asynchronously, we need to TIPC_NAMES_GONE flag indicating whether
the node cleanup work is finished or not. But now as the cleanup work
has been finished when node lock is released, the flag becomes
meaningless for us.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/node.c |   22 ++++------------------
 net/tipc/node.h |    8 +++-----
 2 files changed, 7 insertions(+), 23 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index befbcc9..c3a36bb 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -273,18 +273,6 @@ static void node_established_contact(struct tipc_node *n_ptr)
 	tipc_bclink_add_node(n_ptr->addr);
 }
 
-static void node_name_purge_complete(unsigned long node_addr)
-{
-	struct tipc_node *n_ptr;
-
-	n_ptr = tipc_node_find(node_addr);
-	if (n_ptr) {
-		tipc_node_lock(n_ptr);
-		n_ptr->flags &= ~TIPC_NAMES_GONE;
-		tipc_node_unlock(n_ptr);
-	}
-}
-
 static void node_lost_contact(struct tipc_node *n_ptr)
 {
 	char addr_string[16];
@@ -320,12 +308,10 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 		tipc_link_reset_fragments(l_ptr);
 	}
 
-	/* Notify subscribers */
-	n_ptr->flags = TIPC_NODE_LOST;
-
-	/* Prevent re-contact with node until cleanup is done */
-	n_ptr->flags |= TIPC_NODE_DOWN | TIPC_NAMES_GONE;
-	tipc_k_signal((Handler)node_name_purge_complete, n_ptr->addr);
+	/* Notify subscribers and prevent re-contact with node until
+	 * cleanup is done.
+	 */
+	n_ptr->flags = TIPC_NODE_DOWN | TIPC_NODE_LOST;
 }
 
 struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
diff --git a/net/tipc/node.h b/net/tipc/node.h
index fd86726..4bd5eff 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -49,16 +49,14 @@
 
 /* Flags used to block (re)establishment of contact with a neighboring node
  * TIPC_NODE_DOWN: indicate node is down
- * TIPC_NAMES_GONE: indicate the node's publications are purged
  * TIPC_NODE_RESET: indicate node is reset
  * TIPC_NODE_LOST: indicate node is lost and it's used to notify subscriptions
  *                 when node lock is released
  */
 enum {
 	TIPC_NODE_DOWN	= (1 << 1),
-	TIPC_NAMES_GONE	= (1 << 2),
-	TIPC_NODE_RESET	= (1 << 3),
-	TIPC_NODE_LOST	= (1 << 4)
+	TIPC_NODE_RESET	= (1 << 2),
+	TIPC_NODE_LOST	= (1 << 3)
 };
 
 /**
@@ -142,7 +140,7 @@ static inline void tipc_node_lock(struct tipc_node *node)
 
 static inline bool tipc_node_blocked(struct tipc_node *node)
 {
-	return (node->flags & (TIPC_NODE_DOWN | TIPC_NAMES_GONE |
+	return (node->flags & (TIPC_NODE_DOWN | TIPC_NODE_LOST |
 		TIPC_NODE_RESET));
 }
 
-- 
1.7.9.5
