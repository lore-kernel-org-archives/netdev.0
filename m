From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 14/14] tipc: Prevent missing name table entries when link flip-flops rapidly
Date: Tue, 17 Aug 2010 17:00:16 -0400
Message-ID: <1282078816-11844-15-git-send-email-paul.gortmaker@windriver.com>
References: <1282078816-11844-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57157 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751262Ab0HQVAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 17:00:30 -0400
In-Reply-To: <1282078816-11844-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Ensure that TIPC does not re-establish communication with a
neighboring node until it has finished updating all data structures
containing information about that node to reflect the earlier loss of
contact.  Previously, it was possible for TIPC to perform its purge of
name table entries relating to the node once contact had already been
re-established, resulting in the unwanted removal of valid name table
entries.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/discover.c |    8 ++++++++
 net/tipc/link.c     |   11 ++++++++++-
 net/tipc/node.c     |   19 +++++++++++++++++++
 net/tipc/node.h     |    2 ++
 4 files changed, 39 insertions(+), 1 deletions(-)

diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index fc1fcf5..f28d1ae 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -203,6 +203,14 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct bearer *b_ptr)
 				return;
 		}
 		spin_lock_bh(&n_ptr->lock);
+
+		/* Don't talk to neighbor during cleanup after last session */
+
+		if (n_ptr->cleanup_required) {
+			spin_unlock_bh(&n_ptr->lock);
+			return;
+		}
+
 		link = n_ptr->links[b_ptr->identity];
 		if (!link) {
 			dbg("creating link\n");
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 9d18c9b..a6a3102 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1869,13 +1869,22 @@ void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *tb_ptr)
 				goto cont;
 		}
 
-		/* Locate unicast link endpoint that should handle message */
+		/* Locate neighboring node that sent message */
 
 		n_ptr = tipc_node_find(msg_prevnode(msg));
 		if (unlikely(!n_ptr))
 			goto cont;
 		tipc_node_lock(n_ptr);
 
+		/* Don't talk to neighbor during cleanup after last session */
+
+		if (n_ptr->cleanup_required) {
+			tipc_node_unlock(n_ptr);
+			goto cont;
+		}
+
+		/* Locate unicast link endpoint that should handle message */
+
 		l_ptr = n_ptr->links[b_ptr->identity];
 		if (unlikely(!l_ptr)) {
 			tipc_node_unlock(n_ptr);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 9408517..b702c7b 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -383,6 +383,20 @@ static void node_established_contact(struct tipc_node *n_ptr)
 				  tipc_highest_allowed_slave);
 }
 
+static void node_cleanup_finished(unsigned long node_addr)
+{
+	struct tipc_node *n_ptr;
+
+	read_lock_bh(&tipc_net_lock);
+	n_ptr = tipc_node_find(node_addr);
+	if (n_ptr) {
+		tipc_node_lock(n_ptr);
+		n_ptr->cleanup_required = 0;
+		tipc_node_unlock(n_ptr);
+	}
+	read_unlock_bh(&tipc_net_lock);
+}
+
 static void node_lost_contact(struct tipc_node *n_ptr)
 {
 	struct cluster *c_ptr;
@@ -457,6 +471,11 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 		tipc_k_signal((Handler)ns->handle_node_down,
 			      (unsigned long)ns->usr_handle);
 	}
+
+	/* Prevent re-contact with node until all cleanup is done */
+
+	n_ptr->cleanup_required = 1;
+	tipc_k_signal((Handler)node_cleanup_finished, n_ptr->addr);
 }
 
 /**
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 6f990da..45f3db3 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -52,6 +52,7 @@
  * @active_links: pointers to active links to node
  * @links: pointers to all links to node
  * @working_links: number of working links to node (both active and standby)
+ * @cleanup_required: non-zero if cleaning up after a prior loss of contact
  * @link_cnt: number of links to node
  * @permit_changeover: non-zero if node has redundant links to this system
  * @routers: bitmap (used for multicluster communication)
@@ -78,6 +79,7 @@ struct tipc_node {
 	struct link *links[MAX_BEARERS];
 	int link_cnt;
 	int working_links;
+	int cleanup_required;
 	int permit_changeover;
 	u32 routers[512/32];
 	int last_router;
-- 
1.7.2.1

