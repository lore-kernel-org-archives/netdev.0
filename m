From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/4]: Store retransmit queue packets in RB tree.
Date: Wed, 28 Feb 2007 11:49:12 -0800 (PST)
Message-ID: <20070228.114912.89063615.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48286
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751816AbXB1TtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Feb 2007 14:49:13 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 775DAAE426D
	for <netdev@vger.kernel.org>; Wed, 28 Feb 2007 11:49:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


commit c387760826bd71103220e06ca7b0bf90a785567e
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Tue Feb 27 16:44:42 2007 -0800

    [TCP]: Store retransmit queue packets in RB tree.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4ff3940..b70fd21 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -18,6 +18,7 @@
 #include <linux/compiler.h>
 #include <linux/time.h>
 #include <linux/cache.h>
+#include <linux/rbtree.h>
 
 #include <asm/atomic.h>
 #include <asm/types.h>
@@ -232,6 +233,8 @@ struct sk_buff {
 	struct sk_buff		*next;
 	struct sk_buff		*prev;
 
+	struct rb_node		rb;
+
 	struct sock		*sk;
 	struct skb_timeval	tstamp;
 	struct net_device	*dev;
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 18a468d..b73687a 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -174,6 +174,7 @@ struct tcp_md5sig {
 
 #include <linux/skbuff.h>
 #include <linux/dmaengine.h>
+#include <linux/rbtree.h>
 #include <net/sock.h>
 #include <net/inet_connection_sock.h>
 #include <net/inet_timewait_sock.h>
@@ -306,6 +307,7 @@ struct tcp_sock {
 	u32	snd_cwnd_used;
 	u32	snd_cwnd_stamp;
 
+	struct rb_root		write_queue_rb;
 	struct sk_buff_head	out_of_order_queue; /* Out of order segments go here */
 
  	u32	rcv_wnd;	/* Current receiver window		*/
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 571faa1..cce6b0e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1169,6 +1169,7 @@ static inline void tcp_write_queue_purge(struct sock *sk)
 
 	while ((skb = __skb_dequeue(&sk->sk_write_queue)) != NULL)
 		sk_stream_free_skb(sk, skb);
+	tcp_sk(sk)->write_queue_rb = RB_ROOT;
 	sk_stream_mem_reclaim(sk);
 }
 
@@ -1193,16 +1194,14 @@ static inline struct sk_buff *tcp_write_queue_next(struct sock *sk, struct sk_bu
 	return skb->next;
 }
 
-#define tcp_for_write_queue(skb, sk)					\
-		for (skb = (sk)->sk_write_queue.next;			\
-		     (skb != (sk)->sk_send_head) &&			\
-		     (skb != (struct sk_buff *)&(sk)->sk_write_queue);	\
-		     skb = skb->next)
+#define tcp_for_write_queue(skb, sk)				\
+	for (skb = (sk)->sk_write_queue.next;			\
+	     (skb != (struct sk_buff *)&(sk)->sk_write_queue);	\
+	     skb = skb->next)
 
-#define tcp_for_write_queue_from(skb, sk)				\
-		for (; (skb != (sk)->sk_send_head) &&                   \
-		     (skb != (struct sk_buff *)&(sk)->sk_write_queue);	\
-		     skb = skb->next)
+#define tcp_for_write_queue_from(skb, sk)			\
+	for (; (skb != (struct sk_buff *)&(sk)->sk_write_queue);\
+	     skb = skb->next)
 
 static inline struct sk_buff *tcp_send_head(struct sock *sk)
 {
@@ -1211,7 +1210,7 @@ static inline struct sk_buff *tcp_send_head(struct sock *sk)
 
 static inline void tcp_advance_send_head(struct sock *sk, struct sk_buff *skb)
 {
-	sk->sk_send_head = skb->next;
+	sk->sk_send_head = tcp_write_queue_next(sk, skb);
 	if (sk->sk_send_head == (struct sk_buff *)&sk->sk_write_queue)
 		sk->sk_send_head = NULL;
 }
@@ -1227,9 +1226,54 @@ static inline void tcp_init_send_head(struct sock *sk)
 	sk->sk_send_head = NULL;
 }
 
+static inline struct sk_buff *tcp_write_queue_find(struct sock *sk, __u32 seq)
+{
+	struct rb_node *rb_node = tcp_sk(sk)->write_queue_rb.rb_node;
+	struct sk_buff *skb = NULL;
+
+	while (rb_node) {
+		struct sk_buff *tmp = rb_entry(rb_node,struct sk_buff,rb);
+		if (TCP_SKB_CB(tmp)->end_seq > seq) {
+			skb = tmp;
+			if (TCP_SKB_CB(tmp)->seq <= seq)
+				break;
+			rb_node = rb_node->rb_left;
+		} else
+			rb_node = rb_node->rb_right;
+
+	}
+	return skb;
+}
+
+static inline void tcp_rb_insert(struct sk_buff *skb, struct rb_root *root)
+{
+	struct rb_node **rb_link, *rb_parent;
+	__u32 seq = TCP_SKB_CB(skb)->seq;
+
+	rb_link = &root->rb_node;
+	rb_parent = NULL;
+	while ((rb_parent = *rb_link) != NULL) {
+		struct sk_buff *tmp = rb_entry(rb_parent,struct sk_buff,rb);
+		if (TCP_SKB_CB(tmp)->end_seq > seq) {
+			BUG_ON(TCP_SKB_CB(tmp)->seq <= seq);
+			rb_link = &rb_parent->rb_left;
+		} else {
+			rb_link = &rb_parent->rb_right;
+		}
+	}
+	rb_link_node(&skb->rb, rb_parent, rb_link);
+	rb_insert_color(&skb->rb, root);
+}
+
+static inline void tcp_rb_unlink(struct sk_buff *skb, struct rb_root *root)
+{
+	rb_erase(&skb->rb, root);
+}
+
 static inline void __tcp_add_write_queue_tail(struct sock *sk, struct sk_buff *skb)
 {
 	__skb_queue_tail(&sk->sk_write_queue, skb);
+	tcp_rb_insert(skb, &tcp_sk(sk)->write_queue_rb);
 }
 
 static inline void tcp_add_write_queue_tail(struct sock *sk, struct sk_buff *skb)
@@ -1244,6 +1288,7 @@ static inline void tcp_add_write_queue_tail(struct sock *sk, struct sk_buff *skb
 static inline void __tcp_add_write_queue_head(struct sock *sk, struct sk_buff *skb)
 {
 	__skb_queue_head(&sk->sk_write_queue, skb);
+	tcp_rb_insert(skb, &tcp_sk(sk)->write_queue_rb);
 }
 
 /* Insert buff after skb on the write queue of sk.  */
@@ -1252,19 +1297,22 @@ static inline void tcp_insert_write_queue_after(struct sk_buff *skb,
 						struct sock *sk)
 {
 	__skb_append(skb, buff, &sk->sk_write_queue);
+	tcp_rb_insert(skb, &tcp_sk(sk)->write_queue_rb);
 }
 
-/* Insert skb between prev and next on the write queue of sk.  */
+/* Insert new before skb on the write queue of sk.  */
 static inline void tcp_insert_write_queue_before(struct sk_buff *new,
 						  struct sk_buff *skb,
 						  struct sock *sk)
 {
 	__skb_insert(new, skb->prev, skb, &sk->sk_write_queue);
+	tcp_rb_insert(skb, &tcp_sk(sk)->write_queue_rb);
 }
 
 static inline void tcp_unlink_write_queue(struct sk_buff *skb, struct sock *sk)
 {
 	__skb_unlink(skb, &sk->sk_write_queue);
+	tcp_rb_unlink(skb, &tcp_sk(sk)->write_queue_rb);
 }
 
 static inline int tcp_skb_is_last(const struct sock *sk,
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 219255f..b919cd7 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1065,6 +1065,9 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 			int in_sack, pcount;
 			u8 sacked;
 
+			if (skb == tcp_send_head(sk))
+				break;
+
 			cached_skb = skb;
 			cached_fack_count = fack_count;
 			if (i == first_sack_index) {
@@ -1214,6 +1217,8 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 		struct sk_buff *skb;
 
 		tcp_for_write_queue(skb, sk) {
+			if (skb == tcp_send_head(sk))
+				break;
 			if (after(TCP_SKB_CB(skb)->seq, lost_retrans))
 				break;
 			if (!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una))
@@ -1281,6 +1286,8 @@ int tcp_use_frto(struct sock *sk)
 	skb = tcp_write_queue_head(sk);
 	skb = tcp_write_queue_next(sk, skb);	/* Skips head */
 	tcp_for_write_queue_from(skb, sk) {
+		if (skb == tcp_send_head(sk))
+			break;
 		if (TCP_SKB_CB(skb)->sacked&TCPCB_RETRANS)
 			return 0;
 		/* Short-circuit when first non-SACKed skb has been checked */
@@ -1382,6 +1389,8 @@ static void tcp_enter_frto_loss(struct sock *sk, int allowed_segments, int flag)
 	tp->retrans_out = 0;
 
 	tcp_for_write_queue(skb, sk) {
+		if (skb == tcp_send_head(sk))
+			break;
 		cnt += tcp_skb_pcount(skb);
 		/*
 		 * Count the retransmission made on RTO correctly (only when
@@ -1470,6 +1479,8 @@ void tcp_enter_loss(struct sock *sk, int how)
 		tp->undo_marker = tp->snd_una;
 
 	tcp_for_write_queue(skb, sk) {
+		if (skb == tcp_send_head(sk))
+			break;
 		cnt += tcp_skb_pcount(skb);
 		if (TCP_SKB_CB(skb)->sacked&TCPCB_RETRANS)
 			tp->undo_marker = 0;
@@ -1732,6 +1743,8 @@ static void tcp_mark_head_lost(struct sock *sk, struct tcp_sock *tp,
 	}
 
 	tcp_for_write_queue_from(skb, sk) {
+		if (skb == tcp_send_head(sk))
+			break;
 		/* TODO: do this better */
 		/* this is not the most efficient way to do this... */
 		tp->lost_skb_hint = skb;
@@ -1781,6 +1794,8 @@ static void tcp_update_scoreboard(struct sock *sk, struct tcp_sock *tp)
 			: tcp_write_queue_head(sk);
 
 		tcp_for_write_queue_from(skb, sk) {
+			if (skb == tcp_send_head(sk))
+				break;
 			if (!tcp_skb_timedout(sk, skb))
 				break;
 
@@ -1972,6 +1987,8 @@ static int tcp_try_undo_loss(struct sock *sk, struct tcp_sock *tp)
 	if (tcp_may_undo(tp)) {
 		struct sk_buff *skb;
 		tcp_for_write_queue(skb, sk) {
+			if (skb == tcp_send_head(sk))
+				break;
 			TCP_SKB_CB(skb)->sacked &= ~TCPCB_LOST;
 		}
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 19ba048..1343e2f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1838,6 +1838,7 @@ static int tcp_v4_init_sock(struct sock *sk)
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 
+	tp->write_queue_rb = RB_ROOT;
 	skb_queue_head_init(&tp->out_of_order_queue);
 	tcp_init_xmit_timers(sk);
 	tcp_prequeue_init(tp);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 1d25565..d5e3cbe 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -421,6 +421,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 
 		tcp_set_ca_state(newsk, TCP_CA_Open);
 		tcp_init_xmit_timers(newsk);
+		newtp->write_queue_rb = RB_ROOT;
 		skb_queue_head_init(&newtp->out_of_order_queue);
 		newtp->write_seq = treq->snt_isn + 1;
 		newtp->pushed_seq = newtp->write_seq;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 0adef4a..bc2d477 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1267,11 +1267,11 @@ static int tcp_mtu_probe(struct sock *sk)
 	sk_charge_skb(sk, nskb);
 
 	skb = tcp_send_head(sk);
+	TCP_SKB_CB(nskb)->seq = TCP_SKB_CB(skb)->seq;
+	TCP_SKB_CB(nskb)->end_seq = TCP_SKB_CB(skb)->seq + probe_size;
 	tcp_insert_write_queue_before(nskb, skb, sk);
 	tcp_advance_send_head(sk, skb);
 
-	TCP_SKB_CB(nskb)->seq = TCP_SKB_CB(skb)->seq;
-	TCP_SKB_CB(nskb)->end_seq = TCP_SKB_CB(skb)->seq + probe_size;
 	TCP_SKB_CB(nskb)->flags = TCPCB_FLAG_ACK;
 	TCP_SKB_CB(nskb)->sacked = 0;
 	nskb->csum = 0;
@@ -1691,6 +1691,8 @@ void tcp_simple_retransmit(struct sock *sk)
 	int lost = 0;
 
 	tcp_for_write_queue(skb, sk) {
+		if (skb == tcp_send_head(sk))
+			break;
 		if (skb->len > mss &&
 		    !(TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_ACKED)) {
 			if (TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_RETRANS) {
@@ -1865,6 +1867,8 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 		tcp_for_write_queue_from(skb, sk) {
 			__u8 sacked = TCP_SKB_CB(skb)->sacked;
 
+			if (skb == tcp_send_head(sk))
+				break;
 			/* we could do better than to assign each time */
 			tp->retransmit_skb_hint = skb;
 			tp->retransmit_cnt_hint = packet_cnt;
@@ -1932,6 +1936,8 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 	}
 
 	tcp_for_write_queue_from(skb, sk) {
+		if (skb == tcp_send_head(sk))
+			break;
 		tp->forward_cnt_hint = packet_cnt;
 		tp->forward_skb_hint = skb;
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index f57a9ba..21706a1 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1890,6 +1890,7 @@ static int tcp_v6_init_sock(struct sock *sk)
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 
+	tp->write_queue_rb = RB_ROOT;
 	skb_queue_head_init(&tp->out_of_order_queue);
 	tcp_init_xmit_timers(sk);
 	tcp_prequeue_init(tp);
