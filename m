From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 09/10] tipc: avoid to asynchronously reset all links
Date: Mon, 5 May 2014 08:56:17 +0800
Message-ID: <1399251378-23842-10-git-send-email-ying.xue@windriver.com>
References: <1399251378-23842-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <Paul.Gortmaker@windriver.com>,
	<erik.hugne@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:40137 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754161AbaEEA4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2014 20:56:54 -0400
In-Reply-To: <1399251378-23842-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Postpone the actions of resetting all links until after bclink
lock is released, avoiding to asynchronously reset all links.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bcast.c |   21 +++++++++++++++++++++
 net/tipc/bcast.h |    2 ++
 net/tipc/link.c  |   22 ++++++++--------------
 net/tipc/link.h  |    1 +
 4 files changed, 32 insertions(+), 14 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index ef8cff4..a0978d0 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -87,6 +87,7 @@ struct tipc_bcbearer {
  * @lock: spinlock governing access to structure
  * @link: (non-standard) broadcast link structure
  * @node: (non-standard) node structure representing b'cast link's peer node
+ * @flags: represent bclink states
  * @bcast_nodes: map of broadcast-capable nodes
  * @retransmit_to: node that most recently requested a retransmit
  *
@@ -96,6 +97,7 @@ struct tipc_bclink {
 	spinlock_t lock;
 	struct tipc_link link;
 	struct tipc_node node;
+	unsigned int flags;
 	struct tipc_node_map bcast_nodes;
 	struct tipc_node *retransmit_to;
 };
@@ -119,7 +121,26 @@ static void tipc_bclink_lock(void)
 
 static void tipc_bclink_unlock(void)
 {
+	struct tipc_node *node = NULL;
+
+	if (likely(!bclink->flags)) {
+		spin_unlock_bh(&bclink->lock);
+		return;
+	}
+
+	if (bclink->flags & TIPC_BCLINK_RESET) {
+		bclink->flags &= ~TIPC_BCLINK_RESET;
+		node = tipc_bclink_retransmit_to();
+	}
 	spin_unlock_bh(&bclink->lock);
+
+	if (node)
+		tipc_link_reset_all(node);
+}
+
+void tipc_bclink_set_flags(unsigned int flags)
+{
+	bclink->flags |= flags;
 }
 
 static u32 bcbuf_acks(struct sk_buff *buf)
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index ea162c7..00330c4 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -39,6 +39,7 @@
 
 #define MAX_NODES 4096
 #define WSIZE 32
+#define TIPC_BCLINK_RESET 1
 
 /**
  * struct tipc_node_map - set of node identifiers
@@ -83,6 +84,7 @@ void tipc_port_list_free(struct tipc_port_list *pl_ptr);
 
 int tipc_bclink_init(void);
 void tipc_bclink_stop(void);
+void tipc_bclink_set_flags(unsigned int flags);
 void tipc_bclink_add_node(u32 addr);
 void tipc_bclink_remove_node(u32 addr);
 struct tipc_node *tipc_bclink_retransmit_to(void);
diff --git a/net/tipc/link.c b/net/tipc/link.c
index ac074aa..dce2bef 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1259,29 +1259,24 @@ void tipc_link_push_queue(struct tipc_link *l_ptr)
 	} while (!res);
 }
 
-static void link_reset_all(unsigned long addr)
+void tipc_link_reset_all(struct tipc_node *node)
 {
-	struct tipc_node *n_ptr;
 	char addr_string[16];
 	u32 i;
 
-	n_ptr = tipc_node_find((u32)addr);
-	if (!n_ptr)
-		return;	/* node no longer exists */
-
-	tipc_node_lock(n_ptr);
+	tipc_node_lock(node);
 
 	pr_warn("Resetting all links to %s\n",
-		tipc_addr_string_fill(addr_string, n_ptr->addr));
+		tipc_addr_string_fill(addr_string, node->addr));
 
 	for (i = 0; i < MAX_BEARERS; i++) {
-		if (n_ptr->links[i]) {
-			link_print(n_ptr->links[i], "Resetting link\n");
-			tipc_link_reset(n_ptr->links[i]);
+		if (node->links[i]) {
+			link_print(node->links[i], "Resetting link\n");
+			tipc_link_reset(node->links[i]);
 		}
 	}
 
-	tipc_node_unlock(n_ptr);
+	tipc_node_unlock(node);
 }
 
 static void link_retransmit_failure(struct tipc_link *l_ptr,
@@ -1318,10 +1313,9 @@ static void link_retransmit_failure(struct tipc_link *l_ptr,
 			n_ptr->bclink.oos_state,
 			n_ptr->bclink.last_sent);
 
-		tipc_k_signal((Handler)link_reset_all, (unsigned long)n_ptr->addr);
-
 		tipc_node_unlock(n_ptr);
 
+		tipc_bclink_set_flags(TIPC_BCLINK_RESET);
 		l_ptr->stale_count = 0;
 	}
 }
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 4b556c1..7ba73fa 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -230,6 +230,7 @@ struct sk_buff *tipc_link_cmd_show_stats(const void *req_tlv_area,
 					 int req_tlv_space);
 struct sk_buff *tipc_link_cmd_reset_stats(const void *req_tlv_area,
 					  int req_tlv_space);
+void tipc_link_reset_all(struct tipc_node *node);
 void tipc_link_reset(struct tipc_link *l_ptr);
 void tipc_link_reset_list(unsigned int bearer_id);
 int tipc_link_xmit(struct sk_buff *buf, u32 dest, u32 selector);
-- 
1.7.9.5
