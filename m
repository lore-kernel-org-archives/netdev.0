From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 22/23] tipc: Ignore broadcast acknowledgements that are out-of-range
Date: Tue, 27 Dec 2011 12:39:41 -0500
Message-ID: <1325007582-31610-23-git-send-email-paul.gortmaker@windriver.com>
References: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39516 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754857Ab1L0RkN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 12:40:13 -0500
In-Reply-To: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Adds checks to TIPC's broadcast link so that it ignores any
acknowledgement message containing a sequence number that does not
correspond to an unacknowledged message currently in the broadcast
link's transmit queue.

This change prevents the broadcast link from becoming stalled if a
newly booted node receives stale broadcast link acknowledgement
information from another node that has not yet fully synchronized
its end of the broadcast link to reflect the current state of the
new node's end.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |   35 ++++++++++++++++++++++++++++-------
 net/tipc/link.c  |    6 ++----
 net/tipc/link.h  |    6 ++++++
 net/tipc/node.c  |    3 +--
 4 files changed, 37 insertions(+), 13 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 4609819..15eb744 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -237,14 +237,36 @@ void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked)
 	struct sk_buff *next;
 	unsigned int released = 0;
 
-	if (less_eq(acked, n_ptr->bclink.acked))
-		return;
-
 	spin_lock_bh(&bc_lock);
 
-	/* Skip over packets that node has previously acknowledged */
-
+	/* Bail out if tx queue is empty (no clean up is required) */
 	crs = bcl->first_out;
+	if (!crs)
+		goto exit;
+
+	/* Determine which messages need to be acknowledged */
+	if (acked == INVALID_LINK_SEQ) {
+		/*
+		 * Contact with specified node has been lost, so need to
+		 * acknowledge sent messages only (if other nodes still exist)
+		 * or both sent and unsent messages (otherwise)
+		 */
+		if (bclink->bcast_nodes.count)
+			acked = bcl->fsm_msg_cnt;
+		else
+			acked = bcl->next_out_no;
+	} else {
+		/*
+		 * Bail out if specified sequence number does not correspond
+		 * to a message that has been sent and not yet acknowledged
+		 */
+		if (less(acked, buf_seqno(crs)) ||
+		    less(bcl->fsm_msg_cnt, acked) ||
+		    less_eq(acked, n_ptr->bclink.acked))
+			goto exit;
+	}
+
+	/* Skip over packets that node has previously acknowledged */
 	while (crs && less_eq(buf_seqno(crs), n_ptr->bclink.acked))
 		crs = crs->next;
 
@@ -255,8 +277,6 @@ void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked)
 
 		if (crs != bcl->next_out)
 			bcbuf_decr_acks(crs);
-		else if (bclink->bcast_nodes.count)
-			break;
 		else {
 			bcbuf_set_acks(crs, 0);
 			bcl->next_out = next;
@@ -281,6 +301,7 @@ void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked)
 	}
 	if (unlikely(released && !list_empty(&bcl->waiting_ports)))
 		tipc_link_wakeup_ports(bcl, 0);
+exit:
 	spin_unlock_bh(&bc_lock);
 }
 
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 332915e..4eff342 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1733,10 +1733,8 @@ void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *b_ptr)
 
 		/* Release acked messages */
 
-		if (less(n_ptr->bclink.acked, msg_bcast_ack(msg))) {
-			if (tipc_node_is_up(n_ptr) && n_ptr->bclink.supported)
-				tipc_bclink_acknowledge(n_ptr, msg_bcast_ack(msg));
-		}
+		if (tipc_node_is_up(n_ptr) && n_ptr->bclink.supported)
+			tipc_bclink_acknowledge(n_ptr, msg_bcast_ack(msg));
 
 		crs = l_ptr->first_out;
 		while ((crs != l_ptr->next_out) &&
diff --git a/net/tipc/link.h b/net/tipc/link.h
index e56cb53..7879239 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -45,6 +45,12 @@
 #define PUSH_FINISHED 2
 
 /*
+ * Out-of-range value for link sequence numbers
+ */
+
+#define INVALID_LINK_SEQ 0x10000
+
+/*
  * Link states
  */
 
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 1861ae9..e530de2 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -351,8 +351,7 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 		}
 
 		tipc_bclink_remove_node(n_ptr->addr);
-		tipc_bclink_acknowledge(n_ptr,
-					mod(n_ptr->bclink.acked + 10000));
+		tipc_bclink_acknowledge(n_ptr, INVALID_LINK_SEQ);
 		if (n_ptr->addr < tipc_own_addr)
 			tipc_own_tag--;
 
-- 
1.7.4.4
