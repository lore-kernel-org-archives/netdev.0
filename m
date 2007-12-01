From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 13/21] [TCP]: Store retransmit queue packets in RB tree.
Date: Sun,  2 Dec 2007 00:48:08 +0200
Message-ID: <11965492973133-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11965492963603-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492964079-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296202-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296278-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492961750-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296588-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962509-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962214-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492963057-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296324-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962283-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492961234-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492963381-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46714 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753383AbXLAWsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 17:48:22 -0500
In-Reply-To: <11965492963381-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

This work was mostly done by David S. Miller.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/skbuff.h   |    3 ++
 include/linux/tcp.h      |    2 +
 include/net/tcp.h        |   62 ++++++++++++++++++++++++++++++++++++++=
++++++-
 net/ipv4/tcp_ipv4.c      |    1 +
 net/ipv4/tcp_minisocks.c |    1 +
 net/ipv6/tcp_ipv6.c      |    1 +
 6 files changed, 68 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d39f53e..b00e7e8 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -18,6 +18,7 @@
 #include <linux/compiler.h>
 #include <linux/time.h>
 #include <linux/cache.h>
+#include <linux/rbtree.h>
=20
 #include <asm/atomic.h>
 #include <asm/types.h>
@@ -253,6 +254,8 @@ struct sk_buff {
 	struct sk_buff		*next;
 	struct sk_buff		*prev;
=20
+	struct rb_node		rb;
+
 	struct sock		*sk;
 	ktime_t			tstamp;
 	struct net_device	*dev;
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 08027f1..c24fc06 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -174,6 +174,7 @@ struct tcp_md5sig {
=20
 #include <linux/skbuff.h>
 #include <linux/dmaengine.h>
+#include <linux/rbtree.h>
 #include <net/sock.h>
 #include <net/inet_connection_sock.h>
 #include <net/inet_timewait_sock.h>
@@ -320,6 +321,7 @@ struct tcp_sock {
 	u32	snd_cwnd_used;
 	u32	snd_cwnd_stamp;
=20
+	struct rb_root		write_queue_rb;
 	struct sk_buff_head	out_of_order_queue; /* Out of order segments go h=
ere */
=20
  	u32	rcv_wnd;	/* Current receiver window		*/
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 967f256..433c6a6 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1190,6 +1190,11 @@ static inline void		tcp_put_md5sig_pool(void)
 	put_cpu();
 }
=20
+static inline void tcp_write_queue_init(struct sock *sk)
+{
+	tcp_sk(sk)->write_queue_rb =3D RB_ROOT;
+}
+
 /* write queue abstraction */
 static inline void tcp_write_queue_purge(struct sock *sk)
 {
@@ -1197,6 +1202,7 @@ static inline void tcp_write_queue_purge(struct s=
ock *sk)
=20
 	while ((skb =3D __skb_dequeue(&sk->sk_write_queue)) !=3D NULL)
 		sk_stream_free_skb(sk, skb);
+	tcp_sk(sk)->write_queue_rb =3D RB_ROOT;
 	sk_stream_mem_reclaim(sk);
 }
=20
@@ -1252,7 +1258,7 @@ static inline void tcp_advance_send_head(struct s=
ock *sk, struct sk_buff *skb)
 	TCP_SKB_CB(skb)->fack_count =3D TCP_SKB_CB(prev)->fack_count +
 				      tcp_skb_pcount(prev);
=20
-	sk->sk_send_head =3D skb->next;
+	sk->sk_send_head =3D tcp_write_queue_next(sk, skb);
 	if (sk->sk_send_head =3D=3D (struct sk_buff *)&sk->sk_write_queue)
 		sk->sk_send_head =3D NULL;
 }
@@ -1268,10 +1274,58 @@ static inline void tcp_init_send_head(struct so=
ck *sk)
 	sk->sk_send_head =3D NULL;
 }
=20
+static inline struct sk_buff *tcp_write_queue_find(struct sock *sk, __=
u32 seq)
+{
+	struct rb_node *rb_node =3D tcp_sk(sk)->write_queue_rb.rb_node;
+	struct sk_buff *skb =3D NULL;
+
+	while (rb_node) {
+		struct sk_buff *tmp =3D rb_entry(rb_node,struct sk_buff,rb);
+		if (after(TCP_SKB_CB(tmp)->end_seq, seq)) {
+			skb =3D tmp;
+			if (!after(TCP_SKB_CB(tmp)->seq, seq))
+				break;
+			rb_node =3D rb_node->rb_left;
+		} else
+			rb_node =3D rb_node->rb_right;
+
+	}
+	return skb;
+}
+
+static inline void tcp_rb_insert(struct sk_buff *skb, struct rb_root *=
root)
+{
+	struct rb_node **rb_link, *rb_parent;
+	__u32 seq =3D TCP_SKB_CB(skb)->seq;
+
+	rb_link =3D &root->rb_node;
+	rb_parent =3D NULL;
+	while (*rb_link) {
+		struct sk_buff *tmp;
+
+		rb_parent =3D *rb_link;
+		tmp =3D rb_entry(rb_parent,struct sk_buff,rb);
+		if (after(TCP_SKB_CB(tmp)->end_seq, seq)) {
+			BUG_ON(!after(TCP_SKB_CB(tmp)->seq, seq));
+			rb_link =3D &rb_parent->rb_left;
+		} else {
+			rb_link =3D &rb_parent->rb_right;
+		}
+	}
+	rb_link_node(&skb->rb, rb_parent, rb_link);
+	rb_insert_color(&skb->rb, root);
+}
+
+static inline void tcp_rb_unlink(struct sk_buff *skb, struct rb_root *=
root)
+{
+	rb_erase(&skb->rb, root);
+}
+
 static inline void __tcp_add_write_queue_tail(struct sock *sk, struct =
sk_buff *skb)
 {
 	TCP_SKB_CB(skb)->fack_count =3D 0;
 	__skb_queue_tail(&sk->sk_write_queue, skb);
+	tcp_rb_insert(skb, &tcp_sk(sk)->write_queue_rb);
 }
=20
 static inline void tcp_add_write_queue_tail(struct sock *sk, struct sk=
_buff *skb)
@@ -1296,6 +1350,7 @@ static inline void __tcp_add_write_queue_head(str=
uct sock *sk, struct sk_buff *s
 	BUG_ON(!skb_queue_empty(&sk->sk_write_queue));
 	__skb_queue_head(&sk->sk_write_queue, skb);
 	TCP_SKB_CB(skb)->fack_count =3D 0;
+	tcp_rb_insert(skb, &tcp_sk(sk)->write_queue_rb);
 }
=20
 /* An insert into the middle of the write queue causes the fack
@@ -1326,15 +1381,17 @@ static inline void tcp_insert_write_queue_after=
(struct sk_buff *skb,
 {
 	__skb_append(skb, buff, &sk->sk_write_queue);
 	tcp_reset_fack_counts(sk, buff);
+	tcp_rb_insert(buff, &tcp_sk(sk)->write_queue_rb);
 }
=20
-/* Insert skb between prev and next on the write queue of sk.  */
+/* Insert new before skb on the write queue of sk.  */
 static inline void tcp_insert_write_queue_before(struct sk_buff *new,
 						  struct sk_buff *skb,
 						  struct sock *sk)
 {
 	__skb_insert(new, skb->prev, skb, &sk->sk_write_queue);
 	tcp_reset_fack_counts(sk, new);
+	tcp_rb_insert(new, &tcp_sk(sk)->write_queue_rb);
=20
 	if (sk->sk_send_head =3D=3D skb)
 		sk->sk_send_head =3D new;
@@ -1343,6 +1400,7 @@ static inline void tcp_insert_write_queue_before(=
struct sk_buff *new,
 static inline void tcp_unlink_write_queue(struct sk_buff *skb, struct =
sock *sk)
 {
 	__skb_unlink(skb, &sk->sk_write_queue);
+	tcp_rb_unlink(skb, &tcp_sk(sk)->write_queue_rb);
 }
=20
 static inline int tcp_skb_is_last(const struct sock *sk,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 652c323..5a27e42 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1849,6 +1849,7 @@ static int tcp_v4_init_sock(struct sock *sk)
 	struct inet_connection_sock *icsk =3D inet_csk(sk);
 	struct tcp_sock *tp =3D tcp_sk(sk);
=20
+	tcp_write_queue_init(sk);
 	skb_queue_head_init(&tp->out_of_order_queue);
 	tcp_init_xmit_timers(sk);
 	tcp_prequeue_init(tp);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index b61b768..e1a0e4a 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -426,6 +426,7 @@ struct sock *tcp_create_openreq_child(struct sock *=
sk, struct request_sock *req,
=20
 		tcp_set_ca_state(newsk, TCP_CA_Open);
 		tcp_init_xmit_timers(newsk);
+		tcp_write_queue_init(newsk);
 		skb_queue_head_init(&newtp->out_of_order_queue);
 		newtp->write_seq =3D treq->snt_isn + 1;
 		newtp->pushed_seq =3D newtp->write_seq;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 93980c3..f1294dc 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1886,6 +1886,7 @@ static int tcp_v6_init_sock(struct sock *sk)
 	struct inet_connection_sock *icsk =3D inet_csk(sk);
 	struct tcp_sock *tp =3D tcp_sk(sk);
=20
+	tcp_write_queue_init(sk);
 	skb_queue_head_init(&tp->out_of_order_queue);
 	tcp_init_xmit_timers(sk);
 	tcp_prequeue_init(tp);
--=20
1.5.0.6

