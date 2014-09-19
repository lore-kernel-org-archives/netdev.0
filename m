From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: add coalescing attempt in tcp_ofo_queue()
Date: Fri, 19 Sep 2014 08:26:20 -0700
Message-ID: <1411140380.26859.28.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:38923 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756107AbaISP0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 11:26:23 -0400
Received: by mail-pa0-f48.google.com with SMTP id ey11so351579pad.7
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 08:26:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In order to make TCP more resilient in presence of reorders, we need
to allow coalescing to happen when skbs from out of order queue are
transferred into receive queue. LRO/GRO can be completely canceled
in some pathological cases, like per packet load balancing on aggregated
links.

I had to move tcp_try_coalesce() up in the file above tcp_ofo_queue()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---

Note: I am not sure we really need this part in tcp_try_coalesce(),
as I doubt we need ack_seq in the skbs stored in receive queues ?

	TCP_SKB_CB(to)->ack_seq = TCP_SKB_CB(from)->ack_seq;

 net/ipv4/tcp_input.c |   89 +++++++++++++++++++++--------------------
 1 file changed, 47 insertions(+), 42 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index ea92f23ffaf1..44ff50aac96c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4060,6 +4060,44 @@ static void tcp_sack_remove(struct tcp_sock *tp)
 	tp->rx_opt.num_sacks = num_sacks;
 }
 
+/**
+ * tcp_try_coalesce - try to merge skb to prior one
+ * @sk: socket
+ * @to: prior buffer
+ * @from: buffer to add in queue
+ * @fragstolen: pointer to boolean
+ *
+ * Before queueing skb @from after @to, try to merge them
+ * to reduce overall memory use and queue lengths, if cost is small.
+ * Packets in ofo or receive queues can stay a long time.
+ * Better try to coalesce them right now to avoid future collapses.
+ * Returns true if caller should free @from instead of queueing it
+ */
+static bool tcp_try_coalesce(struct sock *sk,
+			     struct sk_buff *to,
+			     struct sk_buff *from,
+			     bool *fragstolen)
+{
+	int delta;
+
+	*fragstolen = false;
+
+	/* Its possible this segment overlaps with prior segment in queue */
+	if (TCP_SKB_CB(from)->seq != TCP_SKB_CB(to)->end_seq)
+		return false;
+
+	if (!skb_try_coalesce(to, from, fragstolen, &delta))
+		return false;
+
+	atomic_add(delta, &sk->sk_rmem_alloc);
+	sk_mem_charge(sk, delta);
+	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPRCVCOALESCE);
+	TCP_SKB_CB(to)->end_seq = TCP_SKB_CB(from)->end_seq;
+	TCP_SKB_CB(to)->ack_seq = TCP_SKB_CB(from)->ack_seq;
+	TCP_SKB_CB(to)->tcp_flags |= TCP_SKB_CB(from)->tcp_flags;
+	return true;
+}
+
 /* This one checks to see if we can put data from the
  * out_of_order queue into the receive_queue.
  */
@@ -4067,7 +4105,8 @@ static void tcp_ofo_queue(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	__u32 dsack_high = tp->rcv_nxt;
-	struct sk_buff *skb;
+	struct sk_buff *skb, *tail;
+	bool fragstolen, eaten;
 
 	while ((skb = skb_peek(&tp->out_of_order_queue)) != NULL) {
 		if (after(TCP_SKB_CB(skb)->seq, tp->rcv_nxt))
@@ -4080,9 +4119,9 @@ static void tcp_ofo_queue(struct sock *sk)
 			tcp_dsack_extend(sk, TCP_SKB_CB(skb)->seq, dsack);
 		}
 
+		__skb_unlink(skb, &tp->out_of_order_queue);
 		if (!after(TCP_SKB_CB(skb)->end_seq, tp->rcv_nxt)) {
 			SOCK_DEBUG(sk, "ofo packet was already received\n");
-			__skb_unlink(skb, &tp->out_of_order_queue);
 			__kfree_skb(skb);
 			continue;
 		}
@@ -4090,11 +4129,15 @@ static void tcp_ofo_queue(struct sock *sk)
 			   tp->rcv_nxt, TCP_SKB_CB(skb)->seq,
 			   TCP_SKB_CB(skb)->end_seq);
 
-		__skb_unlink(skb, &tp->out_of_order_queue);
-		__skb_queue_tail(&sk->sk_receive_queue, skb);
+		tail = skb_peek_tail(&sk->sk_receive_queue);
+		eaten = tail && tcp_try_coalesce(sk, tail, skb, &fragstolen);
 		tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
+		if (!eaten)
+			__skb_queue_tail(&sk->sk_receive_queue, skb);
 		if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN)
 			tcp_fin(sk);
+		if (eaten)
+			kfree_skb_partial(skb, fragstolen);
 	}
 }
 
@@ -4121,44 +4164,6 @@ static int tcp_try_rmem_schedule(struct sock *sk, struct sk_buff *skb,
 	return 0;
 }
 
-/**
- * tcp_try_coalesce - try to merge skb to prior one
- * @sk: socket
- * @to: prior buffer
- * @from: buffer to add in queue
- * @fragstolen: pointer to boolean
- *
- * Before queueing skb @from after @to, try to merge them
- * to reduce overall memory use and queue lengths, if cost is small.
- * Packets in ofo or receive queues can stay a long time.
- * Better try to coalesce them right now to avoid future collapses.
- * Returns true if caller should free @from instead of queueing it
- */
-static bool tcp_try_coalesce(struct sock *sk,
-			     struct sk_buff *to,
-			     struct sk_buff *from,
-			     bool *fragstolen)
-{
-	int delta;
-
-	*fragstolen = false;
-
-	/* Its possible this segment overlaps with prior segment in queue */
-	if (TCP_SKB_CB(from)->seq != TCP_SKB_CB(to)->end_seq)
-		return false;
-
-	if (!skb_try_coalesce(to, from, fragstolen, &delta))
-		return false;
-
-	atomic_add(delta, &sk->sk_rmem_alloc);
-	sk_mem_charge(sk, delta);
-	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPRCVCOALESCE);
-	TCP_SKB_CB(to)->end_seq = TCP_SKB_CB(from)->end_seq;
-	TCP_SKB_CB(to)->ack_seq = TCP_SKB_CB(from)->ack_seq;
-	TCP_SKB_CB(to)->tcp_flags |= TCP_SKB_CB(from)->tcp_flags;
-	return true;
-}
-
 static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
