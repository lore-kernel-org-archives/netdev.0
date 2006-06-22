From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 7/32] [TIPC] Multicast link failure now resets all links to "nacking" node.
Date: Thu, 22 Jun 2006 15:59:20 +0200
Message-ID: <1150984785859-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw3.ericsson.se ([193.180.251.60]:42938 "EHLO
	mailgw3.ericsson.se") by vger.kernel.org with ESMTP
	id S1030639AbWFVN7u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:50 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

This fix prevents node from crashing.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/bcast.c |   32 +++++++++++---
 net/tipc/link.c  |  124 +++++++++++++++++++++++++++++++++++++++++++++---------
 2 files changed, 128 insertions(+), 28 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 2c4ecbe..00691b7 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -49,13 +49,19 @@ #include "bearer.h"
 #include "name_table.h"
 #include "bcast.h"
 
-
 #define MAX_PKT_DEFAULT_MCAST 1500	/* bcast link max packet size (fixed) */
 
 #define BCLINK_WIN_DEFAULT 20		/* bcast link window size (default) */
 
 #define BCLINK_LOG_BUF_SIZE 0
 
+/*
+ * Loss rate for incoming broadcast frames; used to test retransmission code.
+ * Set to N to cause every N'th frame to be discarded; 0 => don't discard any.
+ */
+ 
+#define TIPC_BCAST_LOSS_RATE 0
+
 /**
  * struct bcbearer_pair - a pair of bearers used by broadcast link
  * @primary: pointer to primary bearer
@@ -165,21 +171,18 @@ static int bclink_ack_allowed(u32 n)
  * @after: sequence number of last packet to *not* retransmit
  * @to: sequence number of last packet to retransmit
  * 
- * Called with 'node' locked, bc_lock unlocked
+ * Called with bc_lock locked
  */
 
 static void bclink_retransmit_pkt(u32 after, u32 to)
 {
 	struct sk_buff *buf;
 
-	spin_lock_bh(&bc_lock);
 	buf = bcl->first_out;
 	while (buf && less_eq(buf_seqno(buf), after)) {
 		buf = buf->next;                
 	}
-	if (buf != NULL)
-		tipc_link_retransmit(bcl, buf, mod(to - after));
-	spin_unlock_bh(&bc_lock);              
+	tipc_link_retransmit(bcl, buf, mod(to - after));
 }
 
 /** 
@@ -399,7 +402,10 @@ int tipc_bclink_send_msg(struct sk_buff 
  */
 
 void tipc_bclink_recv_pkt(struct sk_buff *buf)
-{        
+{
+#if (TIPC_BCAST_LOSS_RATE)
+	static int rx_count = 0;
+#endif
 	struct tipc_msg *msg = buf_msg(buf);
 	struct node* node = tipc_node_find(msg_prevnode(msg));
 	u32 next_in;
@@ -420,9 +426,13 @@ void tipc_bclink_recv_pkt(struct sk_buff
 			tipc_node_lock(node);
 			tipc_bclink_acknowledge(node, msg_bcast_ack(msg));
 			tipc_node_unlock(node);
+			spin_lock_bh(&bc_lock);
 			bcl->stats.recv_nacks++;
+			bcl->owner->next = node;   /* remember requestor */
 			bclink_retransmit_pkt(msg_bcgap_after(msg),
 					      msg_bcgap_to(msg));
+			bcl->owner->next = NULL;
+			spin_unlock_bh(&bc_lock);              
 		} else {
 			tipc_bclink_peek_nack(msg_destnode(msg),
 					      msg_bcast_tag(msg),
@@ -433,6 +443,14 @@ void tipc_bclink_recv_pkt(struct sk_buff
 		return;
 	}
 
+#if (TIPC_BCAST_LOSS_RATE)
+	if (++rx_count == TIPC_BCAST_LOSS_RATE) {
+		rx_count = 0;
+		buf_discard(buf);
+		return;
+	}
+#endif
+
 	tipc_node_lock(node);
 receive:
 	deferred = node->bclink.deferred_head;
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 955b87d..ba7d3f1 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1604,40 +1604,121 @@ void tipc_link_push_queue(struct link *l
 		tipc_bearer_schedule(l_ptr->b_ptr, l_ptr);
 }
 
+static void link_reset_all(unsigned long addr)
+{
+	struct node *n_ptr;
+	char addr_string[16];
+	u32 i;
+
+	read_lock_bh(&tipc_net_lock);
+	n_ptr = tipc_node_find((u32)addr);
+	if (!n_ptr) {
+		read_unlock_bh(&tipc_net_lock);
+		return;	/* node no longer exists */
+	}
+
+	tipc_node_lock(n_ptr);
+
+	warn("Resetting all links to %s\n", 
+	     addr_string_fill(addr_string, n_ptr->addr));
+
+	for (i = 0; i < MAX_BEARERS; i++) {
+		if (n_ptr->links[i]) {
+			link_print(n_ptr->links[i], TIPC_OUTPUT, 
+				   "Resetting link\n");
+			tipc_link_reset(n_ptr->links[i]);
+		}
+	}
+
+	tipc_node_unlock(n_ptr);
+	read_unlock_bh(&tipc_net_lock);
+}
+
+static void link_retransmit_failure(struct link *l_ptr, struct sk_buff *buf)
+{
+	struct tipc_msg *msg = buf_msg(buf);
+
+	warn("Retransmission failure on link <%s>\n", l_ptr->name);
+	tipc_msg_print(TIPC_OUTPUT, msg, ">RETR-FAIL>");
+
+	if (l_ptr->addr) {
+
+		/* Handle failure on standard link */
+
+		link_print(l_ptr, TIPC_OUTPUT, "Resetting link\n");
+		tipc_link_reset(l_ptr);
+
+	} else {
+
+		/* Handle failure on broadcast link */
+
+		struct node *n_ptr;
+		char addr_string[16];
+
+		tipc_printf(TIPC_OUTPUT, "Msg seq number: %u,  ", msg_seqno(msg));
+		tipc_printf(TIPC_OUTPUT, "Outstanding acks: %u\n", (u32)TIPC_SKB_CB(buf)->handle);
+		
+		n_ptr = l_ptr->owner->next;
+		tipc_node_lock(n_ptr);
+
+		addr_string_fill(addr_string, n_ptr->addr);
+		tipc_printf(TIPC_OUTPUT, "Multicast link info for %s\n", addr_string);
+		tipc_printf(TIPC_OUTPUT, "Supported: %d,  ", n_ptr->bclink.supported);
+		tipc_printf(TIPC_OUTPUT, "Acked: %u\n", n_ptr->bclink.acked);
+		tipc_printf(TIPC_OUTPUT, "Last in: %u,  ", n_ptr->bclink.last_in);
+		tipc_printf(TIPC_OUTPUT, "Gap after: %u,  ", n_ptr->bclink.gap_after);
+		tipc_printf(TIPC_OUTPUT, "Gap to: %u\n", n_ptr->bclink.gap_to);
+		tipc_printf(TIPC_OUTPUT, "Nack sync: %u\n\n", n_ptr->bclink.nack_sync);
+
+		tipc_k_signal((Handler)link_reset_all, (unsigned long)n_ptr->addr);
+
+		tipc_node_unlock(n_ptr);
+
+		l_ptr->stale_count = 0;
+	}
+}
+
 void tipc_link_retransmit(struct link *l_ptr, struct sk_buff *buf, 
 			  u32 retransmits)
 {
 	struct tipc_msg *msg;
 
+	if (!buf)
+		return;
+
+	msg = buf_msg(buf);
+	
 	dbg("Retransmitting %u in link %x\n", retransmits, l_ptr);
 
-	if (tipc_bearer_congested(l_ptr->b_ptr, l_ptr) && buf && !skb_cloned(buf)) {
-		msg_dbg(buf_msg(buf), ">NO_RETR->BCONG>");
-		dbg_print_link(l_ptr, "   ");
-		l_ptr->retransm_queue_head = msg_seqno(buf_msg(buf));
-		l_ptr->retransm_queue_size = retransmits;
-		return;
+	if (tipc_bearer_congested(l_ptr->b_ptr, l_ptr)) {
+		if (!skb_cloned(buf)) {
+			msg_dbg(msg, ">NO_RETR->BCONG>");
+			dbg_print_link(l_ptr, "   ");
+			l_ptr->retransm_queue_head = msg_seqno(msg);
+			l_ptr->retransm_queue_size = retransmits;
+			return;
+		} else {
+			/* Don't retransmit if driver already has the buffer */
+		}
+	} else {
+		/* Detect repeated retransmit failures on uncongested bearer */
+
+		if (l_ptr->last_retransmitted == msg_seqno(msg)) {
+			if (++l_ptr->stale_count > 100) {
+				link_retransmit_failure(l_ptr, buf);
+				return;
+			}
+		} else {
+			l_ptr->last_retransmitted = msg_seqno(msg);
+			l_ptr->stale_count = 1;
+		}
 	}
+
 	while (retransmits && (buf != l_ptr->next_out) && buf && !skb_cloned(buf)) {
 		msg = buf_msg(buf);
 		msg_set_ack(msg, mod(l_ptr->next_in_no - 1));
 		msg_set_bcast_ack(msg, l_ptr->owner->bclink.last_in); 
 		if (tipc_bearer_send(l_ptr->b_ptr, buf, &l_ptr->media_addr)) {
-                        /* Catch if retransmissions fail repeatedly: */
-                        if (l_ptr->last_retransmitted == msg_seqno(msg)) {
-                                if (++l_ptr->stale_count > 100) {
-                                        tipc_msg_print(TIPC_CONS, buf_msg(buf), ">RETR>");
-                                        info("...Retransmitted %u times\n",
-					     l_ptr->stale_count);
-                                        link_print(l_ptr, TIPC_CONS, "Resetting Link\n");
-                                        tipc_link_reset(l_ptr);
-                                        break;
-                                }
-                        } else {
-                                l_ptr->stale_count = 0;
-                        }
-                        l_ptr->last_retransmitted = msg_seqno(msg);
-
 			msg_dbg(buf_msg(buf), ">RETR>");
 			buf = buf->next;
 			retransmits--;
@@ -1650,6 +1731,7 @@ void tipc_link_retransmit(struct link *l
 			return;
 		}
 	}
+
 	l_ptr->retransm_queue_head = l_ptr->retransm_queue_size = 0;
 }
 
-- 
1.4.0

