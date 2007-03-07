From: David Miller <davem@davemloft.net>
Subject: [PATCH]: TCP RB tree core v2.
Date: Wed, 07 Mar 2007 12:37:43 -0800 (PST)
Message-ID: <20070307.123743.74748673.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41615
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965641AbXCGUho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2007 15:37:44 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 62F09AE55EA
	for <netdev@vger.kernel.org>; Wed,  7 Mar 2007 12:37:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I checked the TCP write queue abstraction patch into the net-2.6.22
GIT tree at:

	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.22.git

And below is the current version of the second patch which actually
does the RB tree stuff.

This infrastructure is necessary for the SKB hinting elimination
work various folks are doing.  I'm hesitent to check this into
the net-2.6.22 tree until it's been running on my workstation for
a little while without any crashes.

My plane is to check it in after it survives some testing of mine,
and if the RB tree business turns out to be too costly for the
gains we get I'll rip it out before I merge this tree to Linus.

[TCP]: Store retransmit queue packets in RB tree.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 0d5351a..c76e194 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -18,6 +18,7 @@
 #include <linux/compiler.h>
 #include <linux/time.h>
 #include <linux/cache.h>
+#include <linux/rbtree.h>
 
 #include <asm/atomic.h>
 #include <asm/types.h>
@@ -230,6 +231,8 @@ struct sk_buff {
 	struct sk_buff		*next;
 	struct sk_buff		*prev;
 
+	struct rb_node		rb;
+
 	struct sock		*sk;
 	ktime_t			tstamp;
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
index 6dacc35..3dcd0b9 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1169,6 +1169,7 @@ static inline void tcp_write_queue_purge(struct sock *sk)
 
 	while ((skb = __skb_dequeue(&sk->sk_write_queue)) != NULL)
 		sk_stream_free_skb(sk, skb);
+	tcp_sk(sk)->write_queue_rb = RB_ROOT;
 	sk_stream_mem_reclaim(sk);
 }
 
@@ -1209,7 +1210,7 @@ static inline struct sk_buff *tcp_send_head(struct sock *sk)
 
 static inline void tcp_advance_send_head(struct sock *sk, struct sk_buff *skb)
 {
-	sk->sk_send_head = skb->next;
+	sk->sk_send_head = tcp_write_queue_next(sk, skb);
 	if (sk->sk_send_head == (struct sk_buff *)&sk->sk_write_queue)
 		sk->sk_send_head = NULL;
 }
@@ -1225,9 +1226,54 @@ static inline void tcp_init_send_head(struct sock *sk)
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
@@ -1242,6 +1288,7 @@ static inline void tcp_add_write_queue_tail(struct sock *sk, struct sk_buff *skb
 static inline void __tcp_add_write_queue_head(struct sock *sk, struct sk_buff *skb)
 {
 	__skb_queue_head(&sk->sk_write_queue, skb);
+	tcp_rb_insert(skb, &tcp_sk(sk)->write_queue_rb);
 }
 
 /* Insert buff after skb on the write queue of sk.  */
@@ -1250,19 +1297,22 @@ static inline void tcp_insert_write_queue_after(struct sk_buff *skb,
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
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 3326681..bf5f139 100644
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
index ac4ce48..0a57c36 100644
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
index 26c16d1..bc2d477 100644
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
