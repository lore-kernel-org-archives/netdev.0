From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 1/3] l2tp: do data sequence number handling in a separate func
Date: Tue,  2 Jul 2013 11:00:27 +0100
Message-ID: <1372759229-15178-2-git-send-email-jchapman@katalix.com>
References: <1372759229-15178-1-git-send-email-jchapman@katalix.com>
Cc: James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:42619 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755046Ab3GBKJ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jul 2013 06:09:58 -0400
In-Reply-To: <1372759229-15178-1-git-send-email-jchapman@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change moves some code handling data sequence numbers into a
separate function to avoid too much indentation. This is to prepare
for some changes to data sequence number handling in subsequent
patches.

Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_core.c |   55 +++++++++++++++++++++++++++++++------------------
 1 files changed, 35 insertions(+), 20 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 6984c3a..b2389fe 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -542,6 +542,39 @@ static inline int l2tp_verify_udp_checksum(struct sock *sk,
 	return __skb_checksum_complete(skb);
 }
 
+/* If packet has sequence numbers, queue it if acceptable. Returns 0 if
+ * acceptable, else non-zero.
+ */
+static int l2tp_recv_data_seq(struct l2tp_session *session, struct sk_buff *skb)
+{
+	if (session->reorder_timeout != 0) {
+		/* Packet reordering enabled. Add skb to session's
+		 * reorder queue, in order of ns.
+		 */
+		l2tp_recv_queue_skb(session, skb);
+	} else {
+		/* Packet reordering disabled. Discard out-of-sequence
+		 * packets
+		 */
+		if (L2TP_SKB_CB(skb)->ns != session->nr) {
+			atomic_long_inc(&session->stats.rx_seq_discards);
+			l2tp_dbg(session, L2TP_MSG_SEQ,
+				 "%s: oos pkt %u len %d discarded, "
+				 "waiting for %u, reorder_q_len=%d\n",
+				 session->name, L2TP_SKB_CB(skb)->ns,
+				 L2TP_SKB_CB(skb)->length, session->nr,
+				 skb_queue_len(&session->reorder_q));
+			goto discard;
+		}
+		skb_queue_tail(&session->reorder_q, skb);
+	}
+
+	return 0;
+
+discard:
+	return 1;
+}
+
 /* Do receive processing of L2TP data frames. We handle both L2TPv2
  * and L2TPv3 data frames here.
  *
@@ -757,26 +790,8 @@ void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb,
 	 * enabled. Saved L2TP protocol info is stored in skb->sb[].
 	 */
 	if (L2TP_SKB_CB(skb)->has_seq) {
-		if (session->reorder_timeout != 0) {
-			/* Packet reordering enabled. Add skb to session's
-			 * reorder queue, in order of ns.
-			 */
-			l2tp_recv_queue_skb(session, skb);
-		} else {
-			/* Packet reordering disabled. Discard out-of-sequence
-			 * packets
-			 */
-			if (L2TP_SKB_CB(skb)->ns != session->nr) {
-				atomic_long_inc(&session->stats.rx_seq_discards);
-				l2tp_dbg(session, L2TP_MSG_SEQ,
-					 "%s: oos pkt %u len %d discarded, waiting for %u, reorder_q_len=%d\n",
-					 session->name, L2TP_SKB_CB(skb)->ns,
-					 L2TP_SKB_CB(skb)->length, session->nr,
-					 skb_queue_len(&session->reorder_q));
-				goto discard;
-			}
-			skb_queue_tail(&session->reorder_q, skb);
-		}
+		if (l2tp_recv_data_seq(session, skb))
+			goto discard;
 	} else {
 		/* No sequence numbers. Add the skb to the tail of the
 		 * reorder queue. This ensures that it will be
-- 
1.7.0.4
