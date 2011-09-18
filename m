From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 11/28] tipc: Fix node lock problems during broadcast message reception
Date: Sat, 17 Sep 2011 23:32:07 -0400
Message-ID: <1316316744-29514-12-git-send-email-paul.gortmaker@windriver.com>
References: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49977 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756259Ab1IRDct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 23:32:49 -0400
In-Reply-To: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Modifies TIPC's incoming broadcast packet handler to ensure that the
node lock associated with the sender of the packet is held whenever
node-related data structure fields are accessed. The routine is also
restructured with a single exit point, making it easier to ensure
the node lock is properly released and the incoming packet is properly
disposed of.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |   36 +++++++++++++++++++++++-------------
 1 files changed, 23 insertions(+), 13 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 5200457..bc01ca6 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -426,20 +426,26 @@ int tipc_bclink_send_msg(struct sk_buff *buf)
 void tipc_bclink_recv_pkt(struct sk_buff *buf)
 {
 	struct tipc_msg *msg = buf_msg(buf);
-	struct tipc_node *node = tipc_node_find(msg_prevnode(msg));
+	struct tipc_node *node;
 	u32 next_in;
 	u32 seqno;
 	struct sk_buff *deferred;
 
-	if (unlikely(!node || !tipc_node_is_up(node) || !node->bclink.supported ||
-		     (msg_mc_netid(msg) != tipc_net_id))) {
-		buf_discard(buf);
-		return;
-	}
+	/* Screen out unwanted broadcast messages */
+
+	if (msg_mc_netid(msg) != tipc_net_id)
+		goto exit;
+
+	node = tipc_node_find(msg_prevnode(msg));
+	if (unlikely(!node))
+		goto exit;
+
+	tipc_node_lock(node);
+	if (unlikely(!node->bclink.supported))
+		goto unlock;
 
 	if (unlikely(msg_user(msg) == BCAST_PROTOCOL)) {
 		if (msg_destnode(msg) == tipc_own_addr) {
-			tipc_node_lock(node);
 			tipc_bclink_acknowledge(node, msg_bcast_ack(msg));
 			tipc_node_unlock(node);
 			spin_lock_bh(&bc_lock);
@@ -449,16 +455,17 @@ void tipc_bclink_recv_pkt(struct sk_buff *buf)
 					      msg_bcgap_to(msg));
 			spin_unlock_bh(&bc_lock);
 		} else {
+			tipc_node_unlock(node);
 			tipc_bclink_peek_nack(msg_destnode(msg),
 					      msg_bcast_tag(msg),
 					      msg_bcgap_after(msg),
 					      msg_bcgap_to(msg));
 		}
-		buf_discard(buf);
-		return;
+		goto exit;
 	}
 
-	tipc_node_lock(node);
+	/* Handle in-sequence broadcast message */
+
 receive:
 	deferred = node->bclink.deferred_head;
 	next_in = mod(node->bclink.last_in + 1);
@@ -491,14 +498,14 @@ receive:
 			tipc_node_unlock(node);
 			tipc_net_route_msg(buf);
 		}
+		buf = NULL;
+		tipc_node_lock(node);
 		if (deferred && (buf_seqno(deferred) == mod(next_in + 1))) {
-			tipc_node_lock(node);
 			buf = deferred;
 			msg = buf_msg(buf);
 			node->bclink.deferred_head = deferred->next;
 			goto receive;
 		}
-		return;
 	} else if (less(next_in, seqno)) {
 		u32 gap_after = node->bclink.gap_after;
 		u32 gap_to = node->bclink.gap_to;
@@ -513,6 +520,7 @@ receive:
 			else if (less(gap_after, seqno) && less(seqno, gap_to))
 				node->bclink.gap_to = seqno;
 		}
+		buf = NULL;
 		if (bclink_ack_allowed(node->bclink.nack_sync)) {
 			if (gap_to != gap_after)
 				bclink_send_nack(node);
@@ -520,9 +528,11 @@ receive:
 		}
 	} else {
 		bcl->stats.duplicates++;
-		buf_discard(buf);
 	}
+unlock:
 	tipc_node_unlock(node);
+exit:
+	buf_discard(buf);
 }
 
 u32 tipc_bclink_acks_missing(struct tipc_node *n_ptr)
-- 
1.7.4.4
