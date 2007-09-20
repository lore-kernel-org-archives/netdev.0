From: Tom Quetchenbach <virtualphtn@gmail.com>
Subject: [PATCH 1/2] David Miller's rbtree patches for 2.6.22.6
Date: Wed, 19 Sep 2007 18:42:35 -0700
Message-ID: <46F1D00B.6030108@gmail.com>
References: <46F1CF35.3030606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outgoing-mail.its.caltech.edu ([131.215.239.19]:40822 "EHLO
	outgoing-mail.its.caltech.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751330AbXITBu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 21:50:58 -0400
Received: from water-dog.its.caltech.edu (water-dog [192.168.1.26])
	by water-ox-postvirus (Postfix) with ESMTP id 521171BACE
	for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 18:42:39 -0700 (PDT)
Received: from [10.1.234.14] (mystic.caltech.edu [131.215.220.112])
	(Authenticated sender: quetchen)
	by earth-ox.its.caltech.edu (Postfix) with ESMTP id 1F74F1BD69
	for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 18:42:35 -0700 (PDT)
In-Reply-To: <46F1CF35.3030606@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patch 1: David Miller's red-black tree code, tweaked for 2.6.22.6,
with some bugfixes

-Tom

---
diff -ur linux-2.6.22.6/include/linux/skbuff.h linux-2.6.22.6-rbtree-davem-fixed/include/linux/skbuff.h
--- linux-2.6.22.6/include/linux/skbuff.h	2007-08-30 23:21:01.000000000 -0700
+++ linux-2.6.22.6-rbtree-davem-fixed/include/linux/skbuff.h	2007-09-13 18:23:16.000000000 -0700
@@ -18,6 +18,7 @@
 #include <linux/compiler.h>
 #include <linux/time.h>
 #include <linux/cache.h>
+#include <linux/rbtree.h>
 
 #include <asm/atomic.h>
 #include <asm/types.h>
@@ -242,6 +243,8 @@
 	struct sk_buff		*next;
 	struct sk_buff		*prev;
 
+	struct rb_node		rb;
+
 	struct sock		*sk;
 	ktime_t			tstamp;
 	struct net_device	*dev;
diff -ur linux-2.6.22.6/include/linux/tcp.h linux-2.6.22.6-rbtree-davem-fixed/include/linux/tcp.h
--- linux-2.6.22.6/include/linux/tcp.h	2007-08-30 23:21:01.000000000 -0700
+++ linux-2.6.22.6-rbtree-davem-fixed/include/linux/tcp.h	2007-09-13 18:23:16.000000000 -0700
@@ -174,6 +174,7 @@
 
 #include <linux/skbuff.h>
 #include <linux/dmaengine.h>
+#include <linux/rbtree.h>
 #include <net/sock.h>
 #include <net/inet_connection_sock.h>
 #include <net/inet_timewait_sock.h>
@@ -321,6 +322,7 @@
 	u32	snd_cwnd_used;
 	u32	snd_cwnd_stamp;
 
+	struct rb_root		write_queue_rb;
 	struct sk_buff_head	out_of_order_queue; /* Out of order segments go here */
 
  	u32	rcv_wnd;	/* Current receiver window		*/
@@ -339,9 +341,7 @@
 	struct sk_buff *scoreboard_skb_hint;
 	struct sk_buff *retransmit_skb_hint;
 	struct sk_buff *forward_skb_hint;
-	struct sk_buff *fastpath_skb_hint;
 
-	int     fastpath_cnt_hint;
 	int     lost_cnt_hint;
 	int     retransmit_cnt_hint;
 	int     forward_cnt_hint;
diff -ur linux-2.6.22.6/include/net/tcp.h linux-2.6.22.6-rbtree-davem-fixed/include/net/tcp.h
--- linux-2.6.22.6/include/net/tcp.h	2007-08-30 23:21:01.000000000 -0700
+++ linux-2.6.22.6-rbtree-davem-fixed/include/net/tcp.h	2007-09-19 17:36:07.000000000 -0700
@@ -540,6 +540,7 @@
 	__u32		seq;		/* Starting sequence number	*/
 	__u32		end_seq;	/* SEQ + FIN + SYN + datalen	*/
 	__u32		when;		/* used to compute rtt's	*/
+	unsigned int	fack_count;	/* speed up SACK processing	*/
 	__u8		flags;		/* TCP header flags.		*/
 
 	/* NOTE: These must match up to the flags byte in a
@@ -1043,12 +1044,12 @@
 }
 
 /*from STCP */
-static inline void clear_all_retrans_hints(struct tcp_sock *tp){
+static inline void clear_all_retrans_hints(struct tcp_sock *tp)
+{
 	tp->lost_skb_hint = NULL;
 	tp->scoreboard_skb_hint = NULL;
 	tp->retransmit_skb_hint = NULL;
 	tp->forward_skb_hint = NULL;
-	tp->fastpath_skb_hint = NULL;
 }
 
 /* MD5 Signature */
@@ -1166,6 +1167,7 @@
 
 	while ((skb = __skb_dequeue(&sk->sk_write_queue)) != NULL)
 		sk_stream_free_skb(sk, skb);
+	tcp_sk(sk)->write_queue_rb = RB_ROOT;
 	sk_stream_mem_reclaim(sk);
 }
 
@@ -1208,7 +1210,7 @@
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	sk->sk_send_head = skb->next;
+	sk->sk_send_head = tcp_write_queue_next(sk, skb);
 	if (sk->sk_send_head == (struct sk_buff *)&sk->sk_write_queue)
 		sk->sk_send_head = NULL;
 	/* Don't override Nagle indefinately with F-RTO */
@@ -1227,9 +1229,61 @@
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
+	while (*rb_link != NULL) {
+		struct sk_buff *tmp = rb_entry(*rb_link,struct sk_buff,rb);
+		rb_parent = *rb_link;
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
+	struct sk_buff *tail = tcp_write_queue_tail(sk);
+	unsigned int fc = 0;
+
+	if (tail)
+		fc = TCP_SKB_CB(tail)->fack_count + tcp_skb_pcount(tail);
+	TCP_SKB_CB(skb)->fack_count = fc;
 	__skb_queue_tail(&sk->sk_write_queue, skb);
+	tcp_rb_insert(skb, &tcp_sk(sk)->write_queue_rb);
 }
 
 static inline void tcp_add_write_queue_tail(struct sock *sk, struct sk_buff *skb)
@@ -1241,9 +1295,35 @@
 		sk->sk_send_head = skb;
 }
 
+/* This is only used for tcp_send_synack(), so the write queue should
+ * be empty.  If that stops being true, the fack_count assignment
+ * will need to be more elaborate.
+ */
 static inline void __tcp_add_write_queue_head(struct sock *sk, struct sk_buff *skb)
 {
+	BUG_ON(!skb_queue_empty(&sk->sk_write_queue));
 	__skb_queue_head(&sk->sk_write_queue, skb);
+	TCP_SKB_CB(skb)->fack_count = 0;
+	tcp_rb_insert(skb, &tcp_sk(sk)->write_queue_rb);
+}
+
+/* An insert into the middle of the write queue causes the fack
+ * counts in subsequent packets to become invalid, fix them up.
+ */
+static inline void tcp_reset_fack_counts(struct sock *sk, struct sk_buff *first)
+{
+	struct sk_buff *prev = first->prev;
+	unsigned int fc = 0;
+
+	if (prev != (struct sk_buff *) &sk->sk_write_queue)
+		fc = TCP_SKB_CB(prev)->fack_count + tcp_skb_pcount(prev);
+
+	while (first != (struct sk_buff *)&sk->sk_write_queue) {
+		TCP_SKB_CB(first)->fack_count = fc;
+
+		fc += tcp_skb_pcount(first);
+		first = first->next;
+	}
 }
 
 /* Insert buff after skb on the write queue of sk.  */
@@ -1252,19 +1332,24 @@
 						struct sock *sk)
 {
 	__skb_append(skb, buff, &sk->sk_write_queue);
+	tcp_reset_fack_counts(sk, buff);
+	tcp_rb_insert(buff, &tcp_sk(sk)->write_queue_rb);
 }
 
-/* Insert skb between prev and next on the write queue of sk.  */
+/* Insert new before skb on the write queue of sk.  */
 static inline void tcp_insert_write_queue_before(struct sk_buff *new,
 						  struct sk_buff *skb,
 						  struct sock *sk)
 {
 	__skb_insert(new, skb->prev, skb, &sk->sk_write_queue);
+	tcp_reset_fack_counts(sk, new);
+	tcp_rb_insert(new, &tcp_sk(sk)->write_queue_rb);
 }
 
 static inline void tcp_unlink_write_queue(struct sk_buff *skb, struct sock *sk)
 {
 	__skb_unlink(skb, &sk->sk_write_queue);
+	tcp_rb_unlink(skb, &tcp_sk(sk)->write_queue_rb);
 }
 
 static inline int tcp_skb_is_last(const struct sock *sk,
diff -ur linux-2.6.22.6/net/ipv4/tcp_input.c linux-2.6.22.6-rbtree-davem-fixed/net/ipv4/tcp_input.c
--- linux-2.6.22.6/net/ipv4/tcp_input.c	2007-08-30 23:21:01.000000000 -0700
+++ linux-2.6.22.6-rbtree-davem-fixed/net/ipv4/tcp_input.c	2007-09-13 18:23:16.000000000 -0700
@@ -947,14 +947,13 @@
 	unsigned char *ptr = (skb_transport_header(ack_skb) +
 			      TCP_SKB_CB(ack_skb)->sacked);
 	struct tcp_sack_block_wire *sp = (struct tcp_sack_block_wire *)(ptr+2);
-	struct sk_buff *cached_skb;
 	int num_sacks = (ptr[1] - TCPOLEN_SACK_BASE)>>3;
 	int reord = tp->packets_out;
 	int prior_fackets;
 	u32 lost_retrans = 0;
 	int flag = 0;
 	int found_dup_sack = 0;
-	int cached_fack_count;
+	int fack_count_base;
 	int i;
 	int first_sack_index;
 
@@ -1020,7 +1019,6 @@
 		num_sacks = 1;
 	else {
 		int j;
-		tp->fastpath_skb_hint = NULL;
 
 		/* order SACK blocks to allow in order walk of the retrans queue */
 		for (i = num_sacks-1; i > 0; i--) {
@@ -1045,14 +1043,7 @@
 	/* clear flag as used for different purpose in following code */
 	flag = 0;
 
-	/* Use SACK fastpath hint if valid */
-	cached_skb = tp->fastpath_skb_hint;
-	cached_fack_count = tp->fastpath_cnt_hint;
-	if (!cached_skb) {
-		cached_skb = tcp_write_queue_head(sk);
-		cached_fack_count = 0;
-	}
-
+	fack_count_base = TCP_SKB_CB(tcp_write_queue_head(sk))->fack_count;
 	for (i=0; i<num_sacks; i++, sp++) {
 		struct sk_buff *skb;
 		__u32 start_seq = ntohl(sp->start_seq);
@@ -1060,8 +1051,10 @@
 		int fack_count;
 		int dup_sack = (found_dup_sack && (i == first_sack_index));
 
-		skb = cached_skb;
-		fack_count = cached_fack_count;
+		skb = tcp_write_queue_find(sk, start_seq);
+		if (!skb)
+			continue;
+		fack_count = TCP_SKB_CB(skb)->fack_count - fack_count_base;
 
 		/* Event "B" in the comment above. */
 		if (after(end_seq, tp->high_seq))
@@ -1074,13 +1067,6 @@
 			if (skb == tcp_send_head(sk))
 				break;
 
-			cached_skb = skb;
-			cached_fack_count = fack_count;
-			if (i == first_sack_index) {
-				tp->fastpath_skb_hint = skb;
-				tp->fastpath_cnt_hint = fack_count;
-			}
-
 			/* The retransmission queue is always in order, so
 			 * we can short-circuit the walk early.
 			 */
diff -ur linux-2.6.22.6/net/ipv4/tcp_ipv4.c linux-2.6.22.6-rbtree-davem-fixed/net/ipv4/tcp_ipv4.c
--- linux-2.6.22.6/net/ipv4/tcp_ipv4.c	2007-08-30 23:21:01.000000000 -0700
+++ linux-2.6.22.6-rbtree-davem-fixed/net/ipv4/tcp_ipv4.c	2007-09-13 18:23:16.000000000 -0700
@@ -1845,6 +1845,7 @@
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 
+	tp->write_queue_rb = RB_ROOT;
 	skb_queue_head_init(&tp->out_of_order_queue);
 	tcp_init_xmit_timers(sk);
 	tcp_prequeue_init(tp);
diff -ur linux-2.6.22.6/net/ipv4/tcp_minisocks.c linux-2.6.22.6-rbtree-davem-fixed/net/ipv4/tcp_minisocks.c
--- linux-2.6.22.6/net/ipv4/tcp_minisocks.c	2007-08-30 23:21:01.000000000 -0700
+++ linux-2.6.22.6-rbtree-davem-fixed/net/ipv4/tcp_minisocks.c	2007-09-13 18:23:16.000000000 -0700
@@ -421,6 +421,7 @@
 
 		tcp_set_ca_state(newsk, TCP_CA_Open);
 		tcp_init_xmit_timers(newsk);
+		newtp->write_queue_rb = RB_ROOT;
 		skb_queue_head_init(&newtp->out_of_order_queue);
 		newtp->write_seq = treq->snt_isn + 1;
 		newtp->pushed_seq = newtp->write_seq;
diff -ur linux-2.6.22.6/net/ipv4/tcp_output.c linux-2.6.22.6-rbtree-davem-fixed/net/ipv4/tcp_output.c
--- linux-2.6.22.6/net/ipv4/tcp_output.c	2007-08-30 23:21:01.000000000 -0700
+++ linux-2.6.22.6-rbtree-davem-fixed/net/ipv4/tcp_output.c	2007-09-13 18:23:16.000000000 -0700
@@ -1278,11 +1278,11 @@
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
diff -ur linux-2.6.22.6/net/ipv6/tcp_ipv6.c linux-2.6.22.6-rbtree-davem-fixed/net/ipv6/tcp_ipv6.c
--- linux-2.6.22.6/net/ipv6/tcp_ipv6.c	2007-08-30 23:21:01.000000000 -0700
+++ linux-2.6.22.6-rbtree-davem-fixed/net/ipv6/tcp_ipv6.c	2007-09-13 18:23:16.000000000 -0700
@@ -1900,6 +1900,7 @@
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 
+	tp->write_queue_rb = RB_ROOT;
 	skb_queue_head_init(&tp->out_of_order_queue);
 	tcp_init_xmit_timers(sk);
 	tcp_prequeue_init(tp);
