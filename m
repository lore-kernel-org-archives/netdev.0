From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 18/28] tipc: Ensure both nodes recognize loss of contact between them
Date: Sat, 17 Sep 2011 23:32:14 -0400
Message-ID: <1316316744-29514-19-git-send-email-paul.gortmaker@windriver.com>
References: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49991 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756336Ab1IRDcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 23:32:55 -0400
In-Reply-To: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Enhances TIPC to ensure that a node that loses contact with a
neighboring node does not allow contact to be re-established until
it sees that its peer has also recognized the loss of contact.

Previously, nodes that were connected by two or more links could
encounter a situation in which node A would lose contact with node B
on all of its links, purge its name table of names published by B,
and then fail to repopulate those names once contact with B was restored.
This would happen because B was able to re-establish one or more links
so quickly that it never reached a point where it had no links to A --
meaning that B never saw a loss of contact with A, and consequently
didn't re-publish its names to A.

This problem is now prevented by enhancing the cleanup done by TIPC
following a loss of contact with a neighboring node to ensure that
node A ignores all messages sent by B until it receives a LINK_PROTOCOL
message that indicates B has lost contact with A, thereby preventing
the (re)establishment of links between the nodes. The loss of contact
is recognized when a RESET or ACTIVATE message is received that has
a "redundant link exists" field of 0, indicating that B's sending link
endpoint is in a reset state and that B has no other working links.

Additionally, TIPC now suppresses the sending of (most) link protocol
messages to a neighboring node while it is cleaning up after an earlier
loss of contact with that node. This stops the peer node from prematurely
activating its link endpoint, which would prevent TIPC from later
activating its own end. TIPC still allows outgoing RESET messages to
occur during cleanup, to avoid problems if its own node recognizes
the loss of contact first and tries to notify the peer of the situation.

Finally, TIPC now recognizes an impending loss of contact with a peer node
as soon as it receives a RESET message on a working link that is the
peer's only link to the node, and ensures that the link protocol
suppression mentioned above goes into effect right away -- that is,
even before its own link endpoints have failed. This is necessary to
ensure correct operation when there are redundant links between the nodes,
since otherwise TIPC would send an ACTIVATE message upon receiving a RESET
on its first link and only begin suppressing when a RESET on its second
link was received, instead of initiating suppression with the first RESET
message as it needs to.

Note: The reworked cleanup code also eliminates a check that prevented
a link endpoint's discovery object from responding to incoming messages
while stale name table entries are being purged. This check is now
unnecessary and would have slowed down re-establishment of communication
between the nodes in some situations.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/discover.c |    6 ------
 net/tipc/link.c     |   33 ++++++++++++++++++++++++++++-----
 net/tipc/node.c     |   11 ++++++-----
 net/tipc/node.h     |   10 ++++++++--
 4 files changed, 42 insertions(+), 18 deletions(-)

diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 0987933..f2fb96e 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -159,12 +159,6 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr)
 	}
 	tipc_node_lock(n_ptr);
 
-	/* Don't talk to neighbor during cleanup after last session */
-	if (n_ptr->cleanup_required) {
-		tipc_node_unlock(n_ptr);
-		return;
-	}
-
 	link = n_ptr->links[b_ptr->identity];
 
 	/* Create a link endpoint for this bearer, if necessary */
diff --git a/net/tipc/link.c b/net/tipc/link.c
index bc655f4..74126db 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1669,17 +1669,24 @@ void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *b_ptr)
 			goto cont;
 		tipc_node_lock(n_ptr);
 
-		/* Don't talk to neighbor during cleanup after last session */
+		/* Locate unicast link endpoint that should handle message */
 
-		if (n_ptr->cleanup_required) {
+		l_ptr = n_ptr->links[b_ptr->identity];
+		if (unlikely(!l_ptr)) {
 			tipc_node_unlock(n_ptr);
 			goto cont;
 		}
 
-		/* Locate unicast link endpoint that should handle message */
+		/* Verify that communication with node is currently allowed */
 
-		l_ptr = n_ptr->links[b_ptr->identity];
-		if (unlikely(!l_ptr)) {
+		if ((n_ptr->block_setup & WAIT_PEER_DOWN) &&
+			msg_user(msg) == LINK_PROTOCOL &&
+			(msg_type(msg) == RESET_MSG ||
+					msg_type(msg) == ACTIVATE_MSG) &&
+			!msg_redundant_link(msg))
+			n_ptr->block_setup &= ~WAIT_PEER_DOWN;
+
+		if (n_ptr->block_setup) {
 			tipc_node_unlock(n_ptr);
 			goto cont;
 		}
@@ -1914,6 +1921,12 @@ void tipc_link_send_proto_msg(struct link *l_ptr, u32 msg_typ, int probe_msg,
 
 	if (link_blocked(l_ptr))
 		return;
+
+	/* Abort non-RESET send if communication with node is prohibited */
+
+	if ((l_ptr->owner->block_setup) && (msg_typ != RESET_MSG))
+		return;
+
 	msg_set_type(msg, msg_typ);
 	msg_set_net_plane(msg, l_ptr->b_ptr->net_plane);
 	msg_set_bcast_ack(msg, mod(l_ptr->owner->bclink.last_in));
@@ -2045,6 +2058,16 @@ static void link_recv_proto_msg(struct link *l_ptr, struct sk_buff *buf)
 			if (less_eq(msg_session(msg), l_ptr->peer_session))
 				break; /* duplicate or old reset: ignore */
 		}
+
+		if (!msg_redundant_link(msg) && (link_working_working(l_ptr) ||
+				link_working_unknown(l_ptr))) {
+			/*
+			 * peer has lost contact -- don't allow peer's links
+			 * to reactivate before we recognize loss & clean up
+			 */
+			l_ptr->owner->block_setup = WAIT_NODE_DOWN;
+		}
+
 		/* fall thru' */
 	case ACTIVATE_MSG:
 		/* Update link settings according other endpoint's values */
diff --git a/net/tipc/node.c b/net/tipc/node.c
index d75432f..27b4bb0 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -112,6 +112,7 @@ struct tipc_node *tipc_node_create(u32 addr)
 			break;
 	}
 	list_add_tail(&n_ptr->list, &temp_node->list);
+	n_ptr->block_setup = WAIT_PEER_DOWN;
 
 	tipc_num_nodes++;
 
@@ -312,7 +313,7 @@ static void node_established_contact(struct tipc_node *n_ptr)
 	}
 }
 
-static void node_cleanup_finished(unsigned long node_addr)
+static void node_name_purge_complete(unsigned long node_addr)
 {
 	struct tipc_node *n_ptr;
 
@@ -320,7 +321,7 @@ static void node_cleanup_finished(unsigned long node_addr)
 	n_ptr = tipc_node_find(node_addr);
 	if (n_ptr) {
 		tipc_node_lock(n_ptr);
-		n_ptr->cleanup_required = 0;
+		n_ptr->block_setup &= ~WAIT_NAMES_GONE;
 		tipc_node_unlock(n_ptr);
 	}
 	read_unlock_bh(&tipc_net_lock);
@@ -371,10 +372,10 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 	/* Notify subscribers */
 	tipc_nodesub_notify(n_ptr);
 
-	/* Prevent re-contact with node until all cleanup is done */
+	/* Prevent re-contact with node until cleanup is done */
 
-	n_ptr->cleanup_required = 1;
-	tipc_k_signal((Handler)node_cleanup_finished, n_ptr->addr);
+	n_ptr->block_setup = WAIT_PEER_DOWN | WAIT_NAMES_GONE;
+	tipc_k_signal((Handler)node_name_purge_complete, n_ptr->addr);
 }
 
 struct sk_buff *tipc_node_get_nodes(const void *req_tlv_area, int req_tlv_space)
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 5c61afc..4f15cb4 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -42,6 +42,12 @@
 #include "net.h"
 #include "bearer.h"
 
+/* Flags used to block (re)establishment of contact with a neighboring node */
+
+#define WAIT_PEER_DOWN	0x0001	/* wait to see that peer's links are down */
+#define WAIT_NAMES_GONE	0x0002	/* wait for peer's publications to be purged */
+#define WAIT_NODE_DOWN	0x0004	/* wait until peer node is declared down */
+
 /**
  * struct tipc_node - TIPC node structure
  * @addr: network address of node
@@ -52,7 +58,7 @@
  * @active_links: pointers to active links to node
  * @links: pointers to all links to node
  * @working_links: number of working links to node (both active and standby)
- * @cleanup_required: non-zero if cleaning up after a prior loss of contact
+ * @block_setup: bit mask of conditions preventing link establishment to node
  * @link_cnt: number of links to node
  * @permit_changeover: non-zero if node has redundant links to this system
  * @bclink: broadcast-related info
@@ -77,7 +83,7 @@ struct tipc_node {
 	struct link *links[MAX_BEARERS];
 	int link_cnt;
 	int working_links;
-	int cleanup_required;
+	int block_setup;
 	int permit_changeover;
 	struct {
 		int supported;
-- 
1.7.4.4
