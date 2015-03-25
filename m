From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 3/3] tipc: eliminate race condition at dual link establishment
Date: Wed, 25 Mar 2015 12:07:26 -0400
Message-ID: <1427299646-31680-4-git-send-email-jon.maloy@ericsson.com>
References: <1427299646-31680-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.biz.mail.bf1.yahoo.com ([98.139.221.43]:23613 "EHLO
	smtp105.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753166AbbCYQHm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 12:07:42 -0400
In-Reply-To: <1427299646-31680-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Despite recent improvements, the establishment of dual parallel
links still has a small glitch where messages can bypass each
other. When the second link in a dual-link configuration is
established, part of the first link's traffic will be steered over
to the new link. Although we do have a mechanism to ensure that
packets sent before and after the establishment of the new link
arrive in sequence to the destination node, this is not enough.
The arriving messages will still be delivered upwards in different
threads, something entailing a risk of message disordering during
the transition phase.

To fix this, we introduce a synchronization mechanism between the
two parallel links, so that traffic arriving on the new link cannot
be added to its input queue until we are guaranteed that all
pre-establishment messages have been delivered on the old, parallel
link.

This problem seems to always have been around, but its occurrence is
so rare that it has not been noticed until recent intensive testing.

Reviewed-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c | 45 +++++++++++++++++++++++++++++++++++++++++++++
 net/tipc/link.h |  2 ++
 net/tipc/msg.h  |  8 ++++++++
 3 files changed, 55 insertions(+)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 58e2460..1287161 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -139,6 +139,13 @@ static void tipc_link_put(struct tipc_link *l_ptr)
 	kref_put(&l_ptr->ref, tipc_link_release);
 }
 
+static struct tipc_link *tipc_parallel_link(struct tipc_link *l)
+{
+	if (l->owner->active_links[0] != l)
+		return l->owner->active_links[0];
+	return l->owner->active_links[1];
+}
+
 static void link_init_max_pkt(struct tipc_link *l_ptr)
 {
 	struct tipc_node *node = l_ptr->owner;
@@ -1026,6 +1033,32 @@ void tipc_link_retransmit(struct tipc_link *l_ptr, struct sk_buff *skb,
 	}
 }
 
+/* link_synch(): check if all packets arrived before the synch
+ *               point have been consumed
+ * Returns true if the parallel links are synched, otherwise false
+ */
+static bool link_synch(struct tipc_link *l)
+{
+	unsigned int post_synch;
+	struct tipc_link *pl;
+
+	pl  = tipc_parallel_link(l);
+	if (pl == l)
+		goto synched;
+
+	/* Was last pre-synch packet added to input queue ? */
+	if (less_eq(pl->next_in_no, l->synch_point))
+		return false;
+
+	/* Is it still in the input queue ? */
+	post_synch = mod(pl->next_in_no - l->synch_point) - 1;
+	if (skb_queue_len(&pl->inputq) > post_synch)
+		return false;
+synched:
+	l->flags &= ~LINK_SYNCHING;
+	return true;
+}
+
 static void link_retrieve_defq(struct tipc_link *link,
 			       struct sk_buff_head *list)
 {
@@ -1156,6 +1189,14 @@ void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b_ptr)
 			skb = NULL;
 			goto unlock;
 		}
+		/* Synchronize with parallel link if applicable */
+		if (unlikely((l_ptr->flags & LINK_SYNCHING) && !msg_dup(msg))) {
+			link_handle_out_of_seq_msg(l_ptr, skb);
+			if (link_synch(l_ptr))
+				link_retrieve_defq(l_ptr, &head);
+			skb = NULL;
+			goto unlock;
+		}
 		l_ptr->next_in_no++;
 		if (unlikely(!skb_queue_empty(&l_ptr->deferdq)))
 			link_retrieve_defq(l_ptr, &head);
@@ -1231,6 +1272,10 @@ static void tipc_link_input(struct tipc_link *link, struct sk_buff *skb)
 
 	switch (msg_user(msg)) {
 	case CHANGEOVER_PROTOCOL:
+		if (msg_dup(msg)) {
+			link->flags |= LINK_SYNCHING;
+			link->synch_point = msg_seqno(msg_get_wrapped(msg));
+		}
 		if (!tipc_link_tunnel_rcv(node, &skb))
 			break;
 		if (msg_user(buf_msg(skb)) != MSG_BUNDLER) {
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 99543a4..d2b5663 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -60,6 +60,7 @@
  */
 #define LINK_STARTED    0x0001
 #define LINK_STOPPED    0x0002
+#define LINK_SYNCHING   0x0004
 
 /* Starting value for maximum packet size negotiation on unicast links
  * (unless bearer MTU is less)
@@ -170,6 +171,7 @@ struct tipc_link {
 	/* Changeover */
 	u32 exp_msg_count;
 	u32 reset_checkpoint;
+	u32 synch_point;
 
 	/* Max packet negotiation */
 	u32 max_pkt;
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 6445db0..d273207 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -554,6 +554,14 @@ static inline void msg_set_node_capabilities(struct tipc_msg *m, u32 n)
 	msg_set_bits(m, 1, 15, 0x1fff, n);
 }
 
+static inline bool msg_dup(struct tipc_msg *m)
+{
+	if (likely(msg_user(m) != CHANGEOVER_PROTOCOL))
+		return false;
+	if (msg_type(m) != DUPLICATE_MSG)
+		return false;
+	return true;
+}
 
 /*
  * Word 2
-- 
1.9.1
