From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/7]: net: Remove __skb_insert() calls outside of skbuff
 internals.
Date: Mon, 22 Sep 2008 19:12:32 -0700 (PDT)
Message-ID: <20080922.191232.240003968.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37171
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754043AbYIWCMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 22:12:44 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id A3876C8C181
	for <netdev@vger.kernel.org>; Mon, 22 Sep 2008 19:12:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


net: Remove __skb_insert() calls outside of skbuff internals.

This minor cleanup simplifies later changes which will convert
struct sk_buff and friends over to using struct list_head.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/cassini.c     |    2 +-
 drivers/net/ppp_generic.c |    2 +-
 drivers/net/pppol2tp.c    |    2 +-
 include/net/tcp.h         |    4 ++--
 net/ipv4/tcp_input.c      |    4 ++--
 net/sctp/ulpqueue.c       |    5 ++---
 6 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index f1936d5..40ff6a9 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -2182,7 +2182,7 @@ static inline void cas_rx_flow_pkt(struct cas *cp, const u64 *words,
 	 * do any additional locking here. stick the buffer
 	 * at the end.
 	 */
-	__skb_insert(skb, flow->prev, (struct sk_buff *) flow, flow);
+	__skb_queue_tail(flow, skb);
 	if (words[0] & RX_COMP1_RELEASE_FLOW) {
 		while ((skb = __skb_dequeue(flow))) {
 			cas_skb_release(skb);
diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index ddccc07..98e0495 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -1864,7 +1864,7 @@ ppp_mp_insert(struct ppp *ppp, struct sk_buff *skb)
 	for (p = list->next; p != (struct sk_buff *)list; p = p->next)
 		if (seq_before(seq, p->sequence))
 			break;
-	__skb_insert(skb, p->prev, p, list);
+	__skb_queue_before(list, p, skb);
 }
 
 /*
diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
index ff175e8..185b1df 100644
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -353,7 +353,7 @@ static void pppol2tp_recv_queue_skb(struct pppol2tp_session *session, struct sk_
 	spin_lock_bh(&session->reorder_q.lock);
 	skb_queue_walk_safe(&session->reorder_q, skbp, tmp) {
 		if (PPPOL2TP_SKB_CB(skbp)->ns > ns) {
-			__skb_insert(skb, skbp->prev, skbp, &session->reorder_q);
+			__skb_queue_before(&session->reorder_q, skbp, skb);
 			PRINTK(session->debug, PPPOL2TP_MSG_SEQ, KERN_DEBUG,
 			       "%s: pkt %hu, inserted before %hu, reorder_q len=%d\n",
 			       session->name, ns, PPPOL2TP_SKB_CB(skbp)->ns,
diff --git a/include/net/tcp.h b/include/net/tcp.h
index ea81572..f857c3e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1268,12 +1268,12 @@ static inline void tcp_insert_write_queue_after(struct sk_buff *skb,
 	__skb_queue_after(&sk->sk_write_queue, skb, buff);
 }
 
-/* Insert skb between prev and next on the write queue of sk.  */
+/* Insert new before skb on the write queue of sk.  */
 static inline void tcp_insert_write_queue_before(struct sk_buff *new,
 						  struct sk_buff *skb,
 						  struct sock *sk)
 {
-	__skb_insert(new, skb->prev, skb, &sk->sk_write_queue);
+	__skb_queue_before(&sk->sk_write_queue, skb, new);
 
 	if (sk->sk_send_head == skb)
 		sk->sk_send_head = new;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 85627f8..cbfe13d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4156,7 +4156,7 @@ drop:
 				skb1 = skb1->prev;
 			}
 		}
-		__skb_insert(skb, skb1, skb1->next, &tp->out_of_order_queue);
+		__skb_queue_after(&tp->out_of_order_queue, skb1, skb);
 
 		/* And clean segments covered by new one as whole. */
 		while ((skb1 = skb->next) !=
@@ -4254,7 +4254,7 @@ tcp_collapse(struct sock *sk, struct sk_buff_head *list,
 		memcpy(nskb->head, skb->head, header);
 		memcpy(nskb->cb, skb->cb, sizeof(skb->cb));
 		TCP_SKB_CB(nskb)->seq = TCP_SKB_CB(nskb)->end_seq = start;
-		__skb_insert(nskb, skb->prev, skb, list);
+		__skb_queue_before(list, skb, nskb);
 		skb_set_owner_r(nskb, sk);
 
 		/* Copy data, releasing collapsed skbs. */
diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index 5061a26..7b23803 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -317,7 +317,7 @@ static void sctp_ulpq_store_reasm(struct sctp_ulpq *ulpq,
 	}
 
 	/* Insert before pos. */
-	__skb_insert(sctp_event2skb(event), pos->prev, pos, &ulpq->reasm);
+	__skb_queue_before(&ulpq->reasm, pos, sctp_event2skb(event));
 
 }
 
@@ -825,8 +825,7 @@ static void sctp_ulpq_store_ordered(struct sctp_ulpq *ulpq,
 
 
 	/* Insert before pos. */
-	__skb_insert(sctp_event2skb(event), pos->prev, pos, &ulpq->lobby);
-
+	__skb_queue_before(&ulpq->lobby, pos, sctp_event2skb(event));
 }
 
 static struct sctp_ulpevent *sctp_ulpq_order(struct sctp_ulpq *ulpq,
-- 
1.5.6.5

