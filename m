From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 3/3] l2tp: make datapath resilient to packet loss when sequence numbers enabled
Date: Tue,  2 Jul 2013 11:00:29 +0100
Message-ID: <1372759229-15178-4-git-send-email-jchapman@katalix.com>
References: <1372759229-15178-1-git-send-email-jchapman@katalix.com>
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:42617 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753623Ab3GBKJ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jul 2013 06:09:58 -0400
In-Reply-To: <1372759229-15178-1-git-send-email-jchapman@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If L2TP data sequence numbers are enabled and reordering is not
enabled, data reception stops if a packet is lost since the kernel
waits for a sequence number that is never resent. (When reordering is
enabled, data reception restarts when the reorder timeout expires.) If
no reorder timeout is set, we should count the number of in-sequence
packets after the out-of-sequence (OOS) condition is detected, and reset
sequence number state after a number of such packets are received.

For now, the number of in-sequence packets while in OOS state which
cause the sequence number state to be reset is hard-coded to 5. This
could be configurable later.

Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_core.c |   37 ++++++++++++++++++++++++++++++++-----
 net/l2tp/l2tp_core.h |    3 +++
 2 files changed, 35 insertions(+), 5 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index cc7ece9..f572e93 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -572,12 +572,34 @@ static int l2tp_recv_data_seq(struct l2tp_session *session, struct sk_buff *skb)
 		 * reorder queue, in order of ns.
 		 */
 		l2tp_recv_queue_skb(session, skb);
+		goto out;
+	}
+
+	/* Packet reordering disabled. Discard out-of-sequence packets, while
+	 * tracking the number if in-sequence packets after the first OOS packet
+	 * is seen. After nr_oos_count_max in-sequence packets, reset the
+	 * sequence number to re-enable packet reception.
+	 */
+	if (L2TP_SKB_CB(skb)->ns == session->nr) {
+		skb_queue_tail(&session->reorder_q, skb);
 	} else {
-		/* Packet reordering disabled. Discard out-of-sequence
-		 * packets
-		 */
-		if ((L2TP_SKB_CB(skb)->ns != session->nr) &&
-		    (!session->reorder_skip)) {
+		u32 nr_oos = L2TP_SKB_CB(skb)->ns;
+		u32 nr_next = (session->nr_oos + 1) & session->nr_max;
+
+		if (nr_oos == nr_next)
+			session->nr_oos_count++;
+		else
+			session->nr_oos_count = 0;
+
+		session->nr_oos = nr_oos;
+		if (session->nr_oos_count > session->nr_oos_count_max) {
+			session->reorder_skip = 1;
+			l2tp_dbg(session, L2TP_MSG_SEQ,
+				 "%s: %d oos packets received. "
+				 "Resetting sequence numbers\n",
+				 session->name, session->nr_oos_count);
+		}
+		if (!session->reorder_skip) {
 			atomic_long_inc(&session->stats.rx_seq_discards);
 			l2tp_dbg(session, L2TP_MSG_SEQ,
 				 "%s: oos pkt %u len %d discarded, "
@@ -590,6 +612,7 @@ static int l2tp_recv_data_seq(struct l2tp_session *session, struct sk_buff *skb)
 		skb_queue_tail(&session->reorder_q, skb);
 	}
 
+out:
 	return 0;
 
 discard:
@@ -1853,6 +1876,10 @@ struct l2tp_session *l2tp_session_create(int priv_size, struct l2tp_tunnel *tunn
 		else
 			session->nr_max = 0xffffff;
 		session->nr_window_size = session->nr_max / 2;
+		session->nr_oos_count_max = 4;
+
+		/* Use NR of first received packet */
+		session->reorder_skip = 1;
 
 		sprintf(&session->name[0], "sess %u/%u",
 			tunnel->tunnel_id, session->session_id);
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index 4b9a3b7..66a559b 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -104,6 +104,9 @@ struct l2tp_session {
 	struct sk_buff_head	reorder_q;	/* receive reorder queue */
 	u32			nr_max;		/* max NR. Depends on tunnel */
 	u32			nr_window_size;	/* NR window size */
+	u32			nr_oos;		/* NR of last OOS packet */
+	int			nr_oos_count;	/* For OOS recovery */
+	int			nr_oos_count_max;
 	struct hlist_node	hlist;		/* Hash list node */
 	atomic_t		ref_count;
 
-- 
1.7.0.4
