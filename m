From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 07/15] tipc: Fix node lock reclamation issues in broadcast link reception
Date: Mon,  6 Feb 2012 19:52:40 -0500
Message-ID: <1328575968-20643-8-git-send-email-paul.gortmaker@windriver.com>
References: <1328575968-20643-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50184 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756230Ab2BGAxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 19:53:14 -0500
In-Reply-To: <1328575968-20643-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Fixes a pair of problems in broadcast link message reception code
relating to the reclamation of the node lock after consuming an
in-sequence message.

1) Now retests to see if the sending node is still up after reclaiming
   the node lock, and bails out if it is non-operational.

2) Now manipulates the node's deferred message queue only after
   reclaiming the node lock, rather than using queue head pointer
   information that was cached previously.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |   58 +++++++++++++++++++++++++++++++++++++----------------
 1 files changed, 40 insertions(+), 18 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 7342abc..e7df313 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -474,7 +474,7 @@ void tipc_bclink_recv_pkt(struct sk_buff *buf)
 	struct tipc_node *node;
 	u32 next_in;
 	u32 seqno;
-	struct sk_buff *deferred;
+	int deferred;
 
 	/* Screen out unwanted broadcast messages */
 
@@ -489,6 +489,8 @@ void tipc_bclink_recv_pkt(struct sk_buff *buf)
 	if (unlikely(!node->bclink.supported))
 		goto unlock;
 
+	/* Handle broadcast protocol message */
+
 	if (unlikely(msg_user(msg) == BCAST_PROTOCOL)) {
 		if (msg_type(msg) != STATE_MSG)
 			goto unlock;
@@ -513,11 +515,11 @@ void tipc_bclink_recv_pkt(struct sk_buff *buf)
 
 	/* Handle in-sequence broadcast message */
 
-receive:
-	next_in = mod(node->bclink.last_in + 1);
 	seqno = msg_seqno(msg);
+	next_in = mod(node->bclink.last_in + 1);
 
 	if (likely(seqno == next_in)) {
+receive:
 		bcl->stats.recv_info++;
 		node->bclink.last_in++;
 		bclink_set_gap(node);
@@ -551,23 +553,40 @@ receive:
 			buf_discard(buf);
 		}
 		buf = NULL;
+
+		/* Determine new synchronization state */
+
 		tipc_node_lock(node);
-		deferred = node->bclink.deferred_head;
-		if (deferred && (buf_seqno(deferred) == mod(next_in + 1))) {
-			buf = deferred;
-			msg = buf_msg(buf);
-			node->bclink.deferred_head = deferred->next;
-			goto receive;
-		}
-	} else if (less(next_in, seqno)) {
+		if (unlikely(!tipc_node_is_up(node)))
+			goto unlock;
+
+		if (!node->bclink.deferred_head)
+			goto unlock;
+
+		msg = buf_msg(node->bclink.deferred_head);
+		seqno = msg_seqno(msg);
+		next_in = mod(next_in + 1);
+		if (seqno != next_in)
+			goto unlock;
+
+		/* Take in-sequence message from deferred queue & deliver it */
+
+		buf = node->bclink.deferred_head;
+		node->bclink.deferred_head = buf->next;
+		goto receive;
+	}
+
+	/* Handle out-of-sequence broadcast message */
+
+	if (less(next_in, seqno)) {
 		u32 gap_after = node->bclink.gap_after;
 		u32 gap_to = node->bclink.gap_to;
 
-		if (tipc_link_defer_pkt(&node->bclink.deferred_head,
-					&node->bclink.deferred_tail,
-					buf)) {
+		deferred = tipc_link_defer_pkt(&node->bclink.deferred_head,
+					       &node->bclink.deferred_tail,
+					       buf);
+		if (deferred) {
 			node->bclink.nack_sync++;
-			bcl->stats.deferred_recv++;
 			if (seqno == mod(gap_after + 1))
 				node->bclink.gap_after = seqno;
 			else if (less(gap_after, seqno) && less(seqno, gap_to))
@@ -579,9 +598,12 @@ receive:
 				bclink_send_nack(node);
 			bclink_set_gap(node);
 		}
-	} else {
-		bcl->stats.duplicates++;
-	}
+	} else
+		deferred = 0;
+
+	if (deferred)
+		bcl->stats.deferred_recv++;
+
 unlock:
 	tipc_node_unlock(node);
 exit:
-- 
1.7.9
