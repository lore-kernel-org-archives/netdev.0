From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 10/11] tipc: use generic SKB list
	APIs to manage link receive queue
Date: Wed, 26 Nov 2014 11:41:54 +0800
Message-ID: <1416973315-6047-11-git-send-email-ying.xue@windriver.com>
References: <1416973315-6047-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com, tipc-discussion@lists.sourceforge.net
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1416973315-6047-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Use standard SKB list APIs associated with struct sk_buff_head to
manage link's receive queue to simplify its relevant code cemplexity.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bearer.h |    2 +-
 net/tipc/link.c   |   85 +++++++++++++++++++++++------------------------------
 2 files changed, 37 insertions(+), 50 deletions(-)

diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index b1d9052..2c1230a 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -165,7 +165,7 @@ extern struct tipc_bearer __rcu *bearer_list[];
  * TIPC routines available to supported media types
  */
 
-void tipc_rcv(struct sk_buff *buf, struct tipc_bearer *tb_ptr);
+void tipc_rcv(struct sk_buff *skb, struct tipc_bearer *tb_ptr);
 int tipc_enable_bearer(const char *bearer_name, u32 disc_domain, u32 priority);
 int tipc_disable_bearer(const char *name);
 
diff --git a/net/tipc/link.c b/net/tipc/link.c
index d9c2310..0e04508 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -966,29 +966,17 @@ void tipc_link_retransmit(struct tipc_link *l_ptr, struct sk_buff *skb,
 	}
 }
 
-/**
- * link_insert_deferred_queue - insert deferred messages back into receive chain
- */
-static struct sk_buff *link_insert_deferred_queue(struct tipc_link *l_ptr,
-						  struct sk_buff *buf)
+static void link_retrieve_defq(struct tipc_link *link,
+			       struct sk_buff_head *list)
 {
-	struct sk_buff_head head;
-	struct sk_buff *skb = NULL;
 	u32 seq_no;
 
-	if (skb_queue_empty(&l_ptr->deferred_queue))
-		return buf;
-
-	seq_no = buf_seqno(skb_peek(&l_ptr->deferred_queue));
-	if (seq_no == mod(l_ptr->next_in_no)) {
-		__skb_queue_head_init(&head);
-		skb_queue_splice_tail_init(&l_ptr->deferred_queue, &head);
-		skb = head.next;
-		skb->prev = NULL;
-		head.prev->next = buf;
-		head.prev->prev = NULL;
-	}
-	return skb;
+	if (skb_queue_empty(&link->deferred_queue))
+		return;
+
+	seq_no = buf_seqno(skb_peek(&link->deferred_queue));
+	if (seq_no == mod(link->next_in_no))
+		skb_queue_splice_tail_init(&link->deferred_queue, list);
 }
 
 /**
@@ -1048,43 +1036,43 @@ static int link_recv_buf_validate(struct sk_buff *buf)
 
 /**
  * tipc_rcv - process TIPC packets/messages arriving from off-node
- * @head: pointer to message buffer chain
+ * @skb: TIPC packet
  * @b_ptr: pointer to bearer message arrived on
  *
  * Invoked with no locks held.  Bearer pointer must point to a valid bearer
  * structure (i.e. cannot be NULL), but bearer can be inactive.
  */
-void tipc_rcv(struct sk_buff *head, struct tipc_bearer *b_ptr)
+void tipc_rcv(struct sk_buff *skb, struct tipc_bearer *b_ptr)
 {
-	while (head) {
-		struct tipc_node *n_ptr;
-		struct tipc_link *l_ptr;
-		struct sk_buff *buf = head;
-		struct sk_buff *skb1, *tmp;
-		struct tipc_msg *msg;
-		u32 seq_no;
-		u32 ackd;
-		u32 released;
+	struct sk_buff_head head;
+	struct tipc_node *n_ptr;
+	struct tipc_link *l_ptr;
+	struct sk_buff *skb1, *tmp;
+	struct tipc_msg *msg;
+	u32 seq_no;
+	u32 ackd;
+	u32 released;
 
-		head = head->next;
-		buf->next = NULL;
+	__skb_queue_head_init(&head);
+	__skb_queue_tail(&head, skb);
 
+	while ((skb = __skb_dequeue(&head))) {
 		/* Ensure message is well-formed */
-		if (unlikely(!link_recv_buf_validate(buf)))
+		if (unlikely(!link_recv_buf_validate(skb)))
 			goto discard;
 
 		/* Ensure message data is a single contiguous unit */
-		if (unlikely(skb_linearize(buf)))
+		if (unlikely(skb_linearize(skb)))
 			goto discard;
 
 		/* Handle arrival of a non-unicast link message */
-		msg = buf_msg(buf);
+		msg = buf_msg(skb);
 
 		if (unlikely(msg_non_seq(msg))) {
 			if (msg_user(msg) ==  LINK_CONFIG)
-				tipc_disc_rcv(buf, b_ptr);
+				tipc_disc_rcv(skb, b_ptr);
 			else
-				tipc_bclink_rcv(buf);
+				tipc_bclink_rcv(skb);
 			continue;
 		}
 
@@ -1145,8 +1133,8 @@ void tipc_rcv(struct sk_buff *head, struct tipc_bearer *b_ptr)
 		/* Process the incoming packet */
 		if (unlikely(!link_working_working(l_ptr))) {
 			if (msg_user(msg) == LINK_PROTOCOL) {
-				tipc_link_proto_rcv(l_ptr, buf);
-				head = link_insert_deferred_queue(l_ptr, head);
+				tipc_link_proto_rcv(l_ptr, skb);
+				link_retrieve_defq(l_ptr, &head);
 				tipc_node_unlock(n_ptr);
 				continue;
 			}
@@ -1156,8 +1144,7 @@ void tipc_rcv(struct sk_buff *head, struct tipc_bearer *b_ptr)
 
 			if (link_working_working(l_ptr)) {
 				/* Re-insert buffer in front of queue */
-				buf->next = head;
-				head = buf;
+				__skb_queue_head(&head, skb);
 				tipc_node_unlock(n_ptr);
 				continue;
 			}
@@ -1166,33 +1153,33 @@ void tipc_rcv(struct sk_buff *head, struct tipc_bearer *b_ptr)
 
 		/* Link is now in state WORKING_WORKING */
 		if (unlikely(seq_no != mod(l_ptr->next_in_no))) {
-			link_handle_out_of_seq_msg(l_ptr, buf);
-			head = link_insert_deferred_queue(l_ptr, head);
+			link_handle_out_of_seq_msg(l_ptr, skb);
+			link_retrieve_defq(l_ptr, &head);
 			tipc_node_unlock(n_ptr);
 			continue;
 		}
 		l_ptr->next_in_no++;
 		if (unlikely(!skb_queue_empty(&l_ptr->deferred_queue)))
-			head = link_insert_deferred_queue(l_ptr, head);
+			link_retrieve_defq(l_ptr, &head);
 
 		if (unlikely(++l_ptr->unacked_window >= TIPC_MIN_LINK_WIN)) {
 			l_ptr->stats.sent_acks++;
 			tipc_link_proto_xmit(l_ptr, STATE_MSG, 0, 0, 0, 0, 0);
 		}
 
-		if (tipc_link_prepare_input(l_ptr, &buf)) {
+		if (tipc_link_prepare_input(l_ptr, &skb)) {
 			tipc_node_unlock(n_ptr);
 			continue;
 		}
 		tipc_node_unlock(n_ptr);
-		msg = buf_msg(buf);
-		if (tipc_link_input(l_ptr, buf) != 0)
+
+		if (tipc_link_input(l_ptr, skb) != 0)
 			goto discard;
 		continue;
 unlock_discard:
 		tipc_node_unlock(n_ptr);
 discard:
-		kfree_skb(buf);
+		kfree_skb(skb);
 	}
 }
 
-- 
1.7.9.5


------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=157005751&iu=/4140/ostg.clktrk
