From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 5/8] tipc: rename and move
	message reassembly function
Date: Fri,  9 May 2014 09:13:26 -0400
Message-ID: <1399641209-26112-6-git-send-email-jon.maloy@ericsson.com>
References: <1399641209-26112-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1399641209-26112-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The function tipc_link_frag_rcv() is in reality a re-entrant generic
message reassemby function that has nothing in particular to do with
the link, where it is defined now. This becomes obvious when we see
the need to call the function from other places in the code.

In this commit rename it to tipc_buf_append() and move it to the file
msg.c. We also simplify its signature by moving the tail pointer to
the control block of the head buffer, hence making the head buffer
self-contained.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/bcast.c |   10 +++-----
 net/tipc/core.h  |    1 +
 net/tipc/link.c  |   67 ++++--------------------------------------------------
 net/tipc/link.h  |   14 ++----------
 net/tipc/msg.c   |   55 +++++++++++++++++++++++++++++++++++++++++++-
 net/tipc/msg.h   |    5 +++-
 net/tipc/node.c  |    7 +++---
 net/tipc/node.h  |    6 ++---
 8 files changed, 74 insertions(+), 91 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index a0978d0..671f981 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -506,18 +506,14 @@ receive:
 			tipc_node_unlock(node);
 			tipc_link_bundle_rcv(buf);
 		} else if (msg_user(msg) == MSG_FRAGMENTER) {
-			int ret;
-			ret = tipc_link_frag_rcv(&node->bclink.reasm_head,
-						 &node->bclink.reasm_tail,
-						 &buf);
-			if (ret == LINK_REASM_ERROR)
+			tipc_buf_append(&node->bclink.reasm_buf, &buf);
+			if (unlikely(!buf && !node->bclink.reasm_buf))
 				goto unlock;
 			tipc_bclink_lock();
 			bclink_accept_pkt(node, seqno);
 			bcl->stats.recv_fragments++;
-			if (ret == LINK_REASM_COMPLETE) {
+			if (buf) {
 				bcl->stats.recv_fragmented++;
-				/* Point msg to inner header */
 				msg = buf_msg(buf);
 				tipc_bclink_unlock();
 				goto receive;
diff --git a/net/tipc/core.h b/net/tipc/core.h
index ae55d37..2e00682 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -187,6 +187,7 @@ static inline void k_term_timer(struct timer_list *timer)
 struct tipc_skb_cb {
 	void *handle;
 	bool deferred;
+	struct sk_buff *tail;
 };
 
 #define TIPC_SKB_CB(__skb) ((struct tipc_skb_cb *)&((__skb)->cb[0]))
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 9272d4c..24d0587 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -398,9 +398,8 @@ static void link_release_outqueue(struct tipc_link *l_ptr)
  */
 void tipc_link_reset_fragments(struct tipc_link *l_ptr)
 {
-	kfree_skb(l_ptr->reasm_head);
-	l_ptr->reasm_head = NULL;
-	l_ptr->reasm_tail = NULL;
+	kfree_skb(l_ptr->reasm_buf);
+	l_ptr->reasm_buf = NULL;
 }
 
 /**
@@ -1573,17 +1572,12 @@ void tipc_rcv(struct sk_buff *head, struct tipc_bearer *b_ptr)
 			}
 			msg = buf_msg(buf);
 		} else if (msg_user(msg) == MSG_FRAGMENTER) {
-			int rc;
-
 			l_ptr->stats.recv_fragments++;
-			rc = tipc_link_frag_rcv(&l_ptr->reasm_head,
-						&l_ptr->reasm_tail,
-						&buf);
-			if (rc == LINK_REASM_COMPLETE) {
+			if (tipc_buf_append(&l_ptr->reasm_buf, &buf)) {
 				l_ptr->stats.recv_fragmented++;
 				msg = buf_msg(buf);
 			} else {
-				if (rc == LINK_REASM_ERROR)
+				if (!l_ptr->reasm_buf)
 					tipc_link_reset(l_ptr);
 				tipc_node_unlock(n_ptr);
 				continue;
@@ -2169,9 +2163,7 @@ static struct sk_buff *tipc_link_failover_rcv(struct tipc_link *l_ptr,
 		}
 		if (msg_user(msg) == MSG_FRAGMENTER) {
 			l_ptr->stats.recv_fragments++;
-			tipc_link_frag_rcv(&l_ptr->reasm_head,
-					   &l_ptr->reasm_tail,
-					   &buf);
+			tipc_buf_append(&l_ptr->reasm_buf, &buf);
 		}
 	}
 exit:
@@ -2309,55 +2301,6 @@ static int tipc_link_frag_xmit(struct tipc_link *l_ptr, struct sk_buff *buf)
 	return dsz;
 }
 
-/* tipc_link_frag_rcv(): Called with node lock on. Returns
- * the reassembled buffer if message is complete.
- */
-int tipc_link_frag_rcv(struct sk_buff **head, struct sk_buff **tail,
-		       struct sk_buff **fbuf)
-{
-	struct sk_buff *frag = *fbuf;
-	struct tipc_msg *msg = buf_msg(frag);
-	u32 fragid = msg_type(msg);
-	bool headstolen;
-	int delta;
-
-	skb_pull(frag, msg_hdr_sz(msg));
-	if (fragid == FIRST_FRAGMENT) {
-		if (*head || skb_unclone(frag, GFP_ATOMIC))
-			goto out_free;
-		*head = frag;
-		skb_frag_list_init(*head);
-		*fbuf = NULL;
-		return 0;
-	} else if (*head &&
-		   skb_try_coalesce(*head, frag, &headstolen, &delta)) {
-		kfree_skb_partial(frag, headstolen);
-	} else {
-		if (!*head)
-			goto out_free;
-		if (!skb_has_frag_list(*head))
-			skb_shinfo(*head)->frag_list = frag;
-		else
-			(*tail)->next = frag;
-		*tail = frag;
-		(*head)->truesize += frag->truesize;
-		(*head)->data_len += frag->len;
-		(*head)->len += frag->len;
-	}
-	if (fragid == LAST_FRAGMENT) {
-		*fbuf = *head;
-		*tail = *head = NULL;
-		return LINK_REASM_COMPLETE;
-	}
-	*fbuf = NULL;
-	return 0;
-out_free:
-	pr_warn_ratelimited("Link unable to reassemble fragmented message\n");
-	kfree_skb(*fbuf);
-	*fbuf = NULL;
-	return LINK_REASM_ERROR;
-}
-
 static void link_set_supervision_props(struct tipc_link *l_ptr, u32 tolerance)
 {
 	if ((tolerance < TIPC_MIN_LINK_TOL) || (tolerance > TIPC_MAX_LINK_TOL))
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 7ba73fa..200d518 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -40,11 +40,6 @@
 #include "msg.h"
 #include "node.h"
 
-/* Link reassembly status codes
- */
-#define LINK_REASM_ERROR	-1
-#define LINK_REASM_COMPLETE	1
-
 /* Out-of-range value for link sequence numbers
  */
 #define INVALID_LINK_SEQ 0x10000
@@ -140,8 +135,7 @@ struct tipc_stats {
  * @next_out: ptr to first unsent outbound message in queue
  * @waiting_ports: linked list of ports waiting for link congestion to abate
  * @long_msg_seq_no: next identifier to use for outbound fragmented messages
- * @reasm_head: list head of partially reassembled inbound message fragments
- * @reasm_tail: last fragment received
+ * @reasm_buf: head of partially reassembled inbound message fragments
  * @stats: collects statistics regarding link activity
  */
 struct tipc_link {
@@ -204,8 +198,7 @@ struct tipc_link {
 
 	/* Fragmentation/reassembly */
 	u32 long_msg_seq_no;
-	struct sk_buff *reasm_head;
-	struct sk_buff *reasm_tail;
+	struct sk_buff *reasm_buf;
 
 	/* Statistics */
 	struct tipc_stats stats;
@@ -242,9 +235,6 @@ int tipc_link_iovec_xmit_fast(struct tipc_port *sender,
 			      struct iovec const *msg_sect,
 			      unsigned int len, u32 destnode);
 void tipc_link_bundle_rcv(struct sk_buff *buf);
-int tipc_link_frag_rcv(struct sk_buff **reasm_head,
-		       struct sk_buff **reasm_tail,
-		       struct sk_buff **fbuf);
 void tipc_link_proto_xmit(struct tipc_link *l_ptr, u32 msg_typ, int prob,
 			  u32 gap, u32 tolerance, u32 priority, u32 acked_mtu);
 void tipc_link_push_queue(struct tipc_link *l_ptr);
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index e525f8c..8be6e94 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -1,7 +1,7 @@
 /*
  * net/tipc/msg.c: TIPC message header routines
  *
- * Copyright (c) 2000-2006, Ericsson AB
+ * Copyright (c) 2000-2006, 2014, Ericsson AB
  * Copyright (c) 2005, 2010-2011, Wind River Systems
  * All rights reserved.
  *
@@ -99,3 +99,56 @@ int tipc_msg_build(struct tipc_msg *hdr, struct iovec const *msg_sect,
 	}
 	return dsz;
 }
+
+/* tipc_buf_append(): Append a buffer to the fragment list of another buffer
+ * Let first buffer become head buffer
+ * Returns 1 and sets *buf to headbuf if chain is complete, otherwise 0
+ * Leaves headbuf pointer at NULL if failure
+ */
+int tipc_buf_append(struct sk_buff **headbuf, struct sk_buff **buf)
+{
+	struct sk_buff *head = *headbuf;
+	struct sk_buff *frag = *buf;
+	struct sk_buff *tail;
+	struct tipc_msg *msg = buf_msg(frag);
+	u32 fragid = msg_type(msg);
+	bool headstolen;
+	int delta;
+
+	skb_pull(frag, msg_hdr_sz(msg));
+
+	if (fragid == FIRST_FRAGMENT) {
+		if (head || skb_unclone(frag, GFP_ATOMIC))
+			goto out_free;
+		head = *headbuf = frag;
+		skb_frag_list_init(head);
+		return 0;
+	}
+	if (!head)
+		goto out_free;
+	tail = TIPC_SKB_CB(head)->tail;
+	if (skb_try_coalesce(head, frag, &headstolen, &delta)) {
+		kfree_skb_partial(frag, headstolen);
+	} else {
+		if (!skb_has_frag_list(head))
+			skb_shinfo(head)->frag_list = frag;
+		else
+			tail->next = frag;
+		head->truesize += frag->truesize;
+		head->data_len += frag->len;
+		head->len += frag->len;
+		TIPC_SKB_CB(head)->tail = frag;
+	}
+	if (fragid == LAST_FRAGMENT) {
+		*buf = head;
+		TIPC_SKB_CB(head)->tail = NULL;
+		*headbuf = NULL;
+		return 1;
+	}
+	*buf = NULL;
+	return 0;
+out_free:
+	pr_warn_ratelimited("Unable to build fragment list\n");
+	kfree_skb(*buf);
+	return 0;
+}
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 76d1269..5035119 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -1,7 +1,7 @@
 /*
  * net/tipc/msg.h: Include file for TIPC message header routines
  *
- * Copyright (c) 2000-2007, Ericsson AB
+ * Copyright (c) 2000-2007, 2014, Ericsson AB
  * Copyright (c) 2005-2008, 2010-2011, Wind River Systems
  * All rights reserved.
  *
@@ -711,4 +711,7 @@ void tipc_msg_init(struct tipc_msg *m, u32 user, u32 type, u32 hsize,
 		   u32 destnode);
 int tipc_msg_build(struct tipc_msg *hdr, struct iovec const *msg_sect,
 		   unsigned int len, int max_size, struct sk_buff **buf);
+
+int tipc_buf_append(struct sk_buff **headbuf, struct sk_buff **buf);
+
 #endif
diff --git a/net/tipc/node.c b/net/tipc/node.c
index facd561..5b44c30 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -286,10 +286,9 @@ static void node_lost_contact(struct tipc_node *n_ptr)
 		kfree_skb_list(n_ptr->bclink.deferred_head);
 		n_ptr->bclink.deferred_size = 0;
 
-		if (n_ptr->bclink.reasm_head) {
-			kfree_skb(n_ptr->bclink.reasm_head);
-			n_ptr->bclink.reasm_head = NULL;
-			n_ptr->bclink.reasm_tail = NULL;
+		if (n_ptr->bclink.reasm_buf) {
+			kfree_skb(n_ptr->bclink.reasm_buf);
+			n_ptr->bclink.reasm_buf = NULL;
 		}
 
 		tipc_bclink_remove_node(n_ptr->addr);
diff --git a/net/tipc/node.h b/net/tipc/node.h
index 5454edf..9087063 100644
--- a/net/tipc/node.h
+++ b/net/tipc/node.h
@@ -69,8 +69,7 @@ enum {
  * @deferred_size: number of OOS b'cast messages in deferred queue
  * @deferred_head: oldest OOS b'cast message received from node
  * @deferred_tail: newest OOS b'cast message received from node
- * @reasm_head: broadcast reassembly queue head from node
- * @reasm_tail: last broadcast fragment received from node
+ * @reasm_buf: broadcast reassembly queue head from node
  * @recv_permitted: true if node is allowed to receive b'cast messages
  */
 struct tipc_node_bclink {
@@ -81,8 +80,7 @@ struct tipc_node_bclink {
 	u32 deferred_size;
 	struct sk_buff *deferred_head;
 	struct sk_buff *deferred_tail;
-	struct sk_buff *reasm_head;
-	struct sk_buff *reasm_tail;
+	struct sk_buff *reasm_buf;
 	bool recv_permitted;
 };
 
-- 
1.7.9.5


------------------------------------------------------------------------------
Is your legacy SCM system holding you back? Join Perforce May 7 to find out:
&#149; 3 signs your SCM is hindering your productivity
&#149; Requirements for releasing software faster
&#149; Expert tips and advice for migrating your SCM now
http://p.sf.net/sfu/perforce
