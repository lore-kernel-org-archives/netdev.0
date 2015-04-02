From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 1/3] tipc: drop tunneled packet duplicates at reception
Date: Thu,  2 Apr 2015 09:33:00 -0400
Message-ID: <1427981582-30819-2-git-send-email-jon.maloy@ericsson.com>
References: <1427981582-30819-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.bf1.yahoo.com ([98.139.221.63]:29604 "EHLO
	smtp104.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753238AbbDBNdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 09:33:42 -0400
In-Reply-To: <1427981582-30819-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 8b4ed8634f8b3f9aacfc42b4a872d30c36b9e255
("tipc: eliminate race condition at dual link establishment")
we introduced a parallel link synchronization mechanism that
guarentees sequential delivery even for users switching from
an old to a newly established link. The new mechanism makes it
unnecessary to deliver the tunneled duplicate packets back to
the old link, as we are currently doing. It is now sufficient
to use the last tunneled packet's inner sequence number as
synchronization point between the two parallel links, whereafter
it can be dropped.

In this commit, we drop the duplicate packets arriving on the new
link, after updating the synchronization point at each new arrival.

Although it would now have been sufficient for the other endpoint
to only tunnel the last packet in its send queue, and not the
entire queue, we must still do this to maintain compatibility
with older nodes.

This commit makes it possible to get rid if some complex
interaction between the two parallel links.

Reviewed-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c | 132 ++++++++++++++++++++------------------------------------
 1 file changed, 47 insertions(+), 85 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 514466e..c697cf6 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -105,8 +105,6 @@ static void link_handle_out_of_seq_msg(struct tipc_link *link,
 				       struct sk_buff *skb);
 static void tipc_link_proto_rcv(struct tipc_link *link,
 				struct sk_buff *skb);
-static int  tipc_link_tunnel_rcv(struct tipc_node *node,
-				 struct sk_buff **skb);
 static void link_set_supervision_props(struct tipc_link *l_ptr, u32 tol);
 static void link_state_event(struct tipc_link *l_ptr, u32 event);
 static void link_reset_statistics(struct tipc_link *l_ptr);
@@ -115,7 +113,8 @@ static void tipc_link_sync_xmit(struct tipc_link *l);
 static void tipc_link_sync_rcv(struct tipc_node *n, struct sk_buff *buf);
 static void tipc_link_input(struct tipc_link *l, struct sk_buff *skb);
 static bool tipc_data_input(struct tipc_link *l, struct sk_buff *skb);
-
+static bool tipc_link_failover_rcv(struct tipc_node *node,
+				   struct sk_buff **skb);
 /*
  *  Simple link routines
  */
@@ -1274,8 +1273,10 @@ static void tipc_link_input(struct tipc_link *link, struct sk_buff *skb)
 		if (msg_dup(msg)) {
 			link->flags |= LINK_SYNCHING;
 			link->synch_point = msg_seqno(msg_get_wrapped(msg));
+			kfree_skb(skb);
+			break;
 		}
-		if (!tipc_link_tunnel_rcv(node, &skb))
+		if (!tipc_link_failover_rcv(node, &skb))
 			break;
 		if (msg_user(buf_msg(skb)) != MSG_BUNDLER) {
 			tipc_data_input(link, skb);
@@ -1755,101 +1756,62 @@ tunnel_queue:
 	goto tunnel_queue;
 }
 
-/* tipc_link_dup_rcv(): Receive a tunnelled DUPLICATE_MSG packet.
- * Owner node is locked.
- */
-static void tipc_link_dup_rcv(struct tipc_link *link,
-			      struct sk_buff *skb)
-{
-	struct sk_buff *iskb;
-	int pos = 0;
-
-	if (!tipc_link_is_up(link))
-		return;
-
-	if (!tipc_msg_extract(skb, &iskb, &pos)) {
-		pr_warn("%sfailed to extract inner dup pkt\n", link_co_err);
-		return;
-	}
-	/* Append buffer to deferred queue, if applicable: */
-	link_handle_out_of_seq_msg(link, iskb);
-}
-
 /*  tipc_link_failover_rcv(): Receive a tunnelled ORIGINAL_MSG packet
  *  Owner node is locked.
  */
-static struct sk_buff *tipc_link_failover_rcv(struct tipc_link *l_ptr,
-					      struct sk_buff *t_buf)
+static bool tipc_link_failover_rcv(struct tipc_node *node,
+				   struct sk_buff **skb)
 {
-	struct tipc_msg *t_msg = buf_msg(t_buf);
-	struct sk_buff *buf = NULL;
-	struct tipc_msg *msg;
+	struct tipc_msg *msg = buf_msg(*skb);
+	struct sk_buff *iskb = NULL;
+	struct tipc_link *link = NULL;
+	int bearer_id = msg_bearer_id(msg);
 	int pos = 0;
 
-	if (tipc_link_is_up(l_ptr))
-		tipc_link_reset(l_ptr);
-
-	/* First failover packet? */
-	if (l_ptr->exp_msg_count == START_CHANGEOVER)
-		l_ptr->exp_msg_count = msg_msgcnt(t_msg);
-
-	/* Should there be an inner packet? */
-	if (l_ptr->exp_msg_count) {
-		l_ptr->exp_msg_count--;
-		if (!tipc_msg_extract(t_buf, &buf, &pos)) {
-			pr_warn("%sno inner failover pkt\n", link_co_err);
-			goto exit;
-		}
-		msg = buf_msg(buf);
-
-		if (less(msg_seqno(msg), l_ptr->reset_checkpoint)) {
-			kfree_skb(buf);
-			buf = NULL;
-			goto exit;
-		}
-		if (msg_user(msg) == MSG_FRAGMENTER) {
-			l_ptr->stats.recv_fragments++;
-			tipc_buf_append(&l_ptr->reasm_buf, &buf);
-		}
+	if (msg_type(msg) != ORIGINAL_MSG) {
+		pr_warn("%sunknown tunnel pkt received\n", link_co_err);
+		goto exit;
 	}
-exit:
-	if ((!l_ptr->exp_msg_count) && (l_ptr->flags & LINK_STOPPED))
-		tipc_link_delete(l_ptr);
-	return buf;
-}
-
-/*  tipc_link_tunnel_rcv(): Receive a tunnelled packet, sent
- *  via other link as result of a failover (ORIGINAL_MSG) or
- *  a new active link (DUPLICATE_MSG). Failover packets are
- *  returned to the active link for delivery upwards.
- *  Owner node is locked.
- */
-static int tipc_link_tunnel_rcv(struct tipc_node *n_ptr,
-				struct sk_buff **buf)
-{
-	struct sk_buff *t_buf = *buf;
-	struct tipc_link *l_ptr;
-	struct tipc_msg *t_msg = buf_msg(t_buf);
-	u32 bearer_id = msg_bearer_id(t_msg);
+	if (bearer_id >= MAX_BEARERS)
+		goto exit;
+	link = node->links[bearer_id];
+	if (!link)
+		goto exit;
+	if (tipc_link_is_up(link))
+		tipc_link_reset(link);
 
-	*buf = NULL;
+	/* First failover packet? */
+	if (link->exp_msg_count == START_CHANGEOVER)
+		link->exp_msg_count = msg_msgcnt(msg);
 
-	if (bearer_id >= MAX_BEARERS)
+	/* Should we expect an inner packet? */
+	if (!link->exp_msg_count)
 		goto exit;
 
-	l_ptr = n_ptr->links[bearer_id];
-	if (!l_ptr)
+	if (!tipc_msg_extract(*skb, &iskb, &pos)) {
+		pr_warn("%sno inner failover pkt\n", link_co_err);
+		*skb = NULL;
 		goto exit;
+	}
+	link->exp_msg_count--;
+	*skb = NULL;
 
-	if (msg_type(t_msg) == DUPLICATE_MSG)
-		tipc_link_dup_rcv(l_ptr, t_buf);
-	else if (msg_type(t_msg) == ORIGINAL_MSG)
-		*buf = tipc_link_failover_rcv(l_ptr, t_buf);
-	else
-		pr_warn("%sunknown tunnel pkt received\n", link_co_err);
+	/* Was packet already delivered? */
+	if (less(buf_seqno(iskb), link->reset_checkpoint)) {
+		kfree_skb(iskb);
+		iskb = NULL;
+		goto exit;
+	}
+	if (msg_user(buf_msg(iskb)) == MSG_FRAGMENTER) {
+		link->stats.recv_fragments++;
+		tipc_buf_append(&link->reasm_buf, &iskb);
+	}
 exit:
-	kfree_skb(t_buf);
-	return *buf != NULL;
+	if (link && (!link->exp_msg_count) && (link->flags & LINK_STOPPED))
+		tipc_link_delete(link);
+	kfree_skb(*skb);
+	*skb = iskb;
+	return *skb;
 }
 
 static void link_set_supervision_props(struct tipc_link *l_ptr, u32 tol)
-- 
1.9.1
