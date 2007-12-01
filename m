From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 21/21] [TCP]: Split write queue into two parts (SACKed and not)
Date: Sun,  2 Dec 2007 00:48:16 +0200
Message-ID: <11965492972277-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11965492963603-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492964079-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296202-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296278-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492961750-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296588-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962509-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962214-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492963057-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296324-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962283-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492961234-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492963381-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492973133-git-send-email-ilpo.ja
 rvinen@helsinki.fi> <11965492972855-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549297779-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492971864-git-send-email-ilpo.jarvinen@helsinki.f
 i> <11965492972309-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492971718-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492972550-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492971669-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47544 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752693AbXLAWs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 17:48:27 -0500
In-Reply-To: <11965492971669-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

Due to linked list implementation, which must occasionally spend
huge effort to locate the correct skb, tagging per skb scoreboard
information is all the time becoming heavier operation because the
window sizes are growing. This processing takes considerable
amount of time and is seriously degraging throughput of a large
windowed TCP because in the worst case RTOs occur due to SACK
latencies.

Another thing to be considered, which is the main motivation for
this work, is a malicious peer who intentionally forces TCP to
do such heavy processing per ACK. Currently there's very little
being done to prevent such resource consumption. We would like
to bound processing to O(outstanding skbs) per outstanding
window.

Problem with scoreboard was/is two-fold:

1) Does O(outstanding skbs) walk per ACK when finding beginning
   of a SACK block
2) Does O(outstanding skbs) walk per ACK when marking the new
   information

Sadly enough there's one more thing, the DSACKs may point to
already SACKed area. Again this is currently thing that forces
to do O(outstanding skbs) processing (3).

Without RB-tree at all (or other log(n) search structure),
properties 1 and 3 are our obstable. A single skb space for
all skbs fails to meet desired bound because of property 2.
This was the current situation though we optimized the typical
case by the help of recv_sack_cache and highest_sack skb
fast-forward reference quite well.

We introduced RB-tree in earlier patch making searching for
the skb fast (fixes 1 and 3). To combat property 2, we separate
new SACK info and DSACK problem spaces. Just removing SACKed
items from RB-tree fails because DSACKs are no longer fast
searchable which malicious peers can take advantage of. For
a fast search and O(new work only) walk the RB-tree must return
an skb that belongs to new work, otherwise walking may do extra
work equal to property 2. Therefore a separate RB-trees for
non-SACKed and SACKed space is required.

=2E..well, that's a short introduction.

This is somewhat costly but simple approach to do it. It can
be optimized later.

The non-SACKed space will contain also S|R skbs because
mark_lost_retrans loop must be able to find them efficiently.

RB-tree insertion had a nice side-effect we take advantage of.
The insertion point for sacked list is found without additional
cost (we still maintain linked list parallel with RB-tree,
this may change in future though).

Minor changes in tcp_input.c had to performed to fix assumption
that are no longer valid because tcp_for_write_queue won't
necessarily return every item like previously.

recv_sack_cache and tp->highest_sack may be obsolete after
this. At least the highest item of recv_sack_cache is very
likely redundant.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/tcp.h   |    2 +
 include/net/tcp.h     |  276 +++++++++++++++++++++++++++++++++++++++++=
-------
 net/ipv4/tcp_input.c  |  236 +++++++++++++++++++++--------------------
 net/ipv4/tcp_output.c |    4 +-
 4 files changed, 360 insertions(+), 158 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index c24fc06..56342c3 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -322,6 +322,8 @@ struct tcp_sock {
 	u32	snd_cwnd_stamp;
=20
 	struct rb_root		write_queue_rb;
+	struct rb_root		sacked_queue_rb;
+	struct sk_buff_head	sacked_queue;
 	struct sk_buff_head	out_of_order_queue; /* Out of order segments go h=
ere */
=20
  	u32	rcv_wnd;	/* Current receiver window		*/
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 688ccca..7ae72c3 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1190,49 +1190,113 @@ static inline void		tcp_put_md5sig_pool(void)
 	put_cpu();
 }
=20
+/* write queue abstraction */
+#define TCP_WQ_SACKED	1
+
+static inline struct sk_buff_head *__tcp_list_select(struct sock *sk, =
const int queue)
+{
+	if (queue =3D=3D TCP_WQ_SACKED)
+		return &tcp_sk(sk)->sacked_queue;
+	else
+		return &sk->sk_write_queue;
+}
+
+static inline struct rb_root *__tcp_tree_select(struct sock *sk, const=
 int tree)
+{
+	if (tree =3D=3D TCP_WQ_SACKED)
+		return &tcp_sk(sk)->sacked_queue_rb;
+	else
+		return &tcp_sk(sk)->write_queue_rb;
+}
+
+/* All SACKed except S|R go to a separate skb space */
+static inline int __tcp_skb_queue_select(const struct sk_buff *skb)
+{
+	if ((TCP_SKB_CB(skb)->sacked &
+			(TCPCB_SACKED_ACKED|TCPCB_SACKED_RETRANS)) =3D=3D
+			TCPCB_SACKED_ACKED)
+		return TCP_WQ_SACKED;
+	else
+		return 0;
+}
+
 static inline void tcp_write_queue_init(struct sock *sk)
 {
 	tcp_sk(sk)->write_queue_rb =3D RB_ROOT;
+	tcp_sk(sk)->sacked_queue_rb =3D RB_ROOT;
+	skb_queue_head_init(&tcp_sk(sk)->sacked_queue);
 }
=20
-/* write queue abstraction */
-static inline void tcp_write_queue_purge(struct sock *sk)
+static inline void __tcp_write_queue_purge(struct sock *sk, int queue)
 {
 	struct sk_buff *skb;
=20
-	while ((skb =3D __skb_dequeue(&sk->sk_write_queue)) !=3D NULL)
+	while ((skb =3D __skb_dequeue(__tcp_list_select(sk, queue))) !=3D NUL=
L)
 		sk_stream_free_skb(sk, skb);
-	tcp_sk(sk)->write_queue_rb =3D RB_ROOT;
+	*__tcp_tree_select(sk, queue) =3D RB_ROOT;
+}
+
+static inline void tcp_write_queue_purge(struct sock *sk)
+{
+	__tcp_write_queue_purge(sk, 0);
+	__tcp_write_queue_purge(sk, TCP_WQ_SACKED);
 	sk_stream_mem_reclaim(sk);
 }
=20
-static inline struct sk_buff *tcp_write_queue_head(struct sock *sk)
+static inline struct sk_buff *__tcp_write_queue_head(struct sock *sk, =
int queue)
 {
-	struct sk_buff *skb =3D sk->sk_write_queue.next;
-	if (skb =3D=3D (struct sk_buff *) &sk->sk_write_queue)
+	struct sk_buff *skb =3D __tcp_list_select(sk, queue)->next;
+	if (skb =3D=3D (struct sk_buff *)__tcp_list_select(sk, queue))
 		return NULL;
 	return skb;
 }
=20
+static inline struct sk_buff *tcp_write_queue_head(struct sock *sk)
+{
+	return __tcp_write_queue_head(sk, 0);
+}
+
 /* FIXME, this should eventually vanish because callers likely benefit
  * from scanning the non-SACKed and SACKed spaces separately.
  */
 static inline struct sk_buff *tcp_real_queue_head(struct sock *sk)
 {
-	return tcp_write_queue_head(sk);
+	struct sk_buff *skb, *sacked;
+
+	skb =3D tcp_write_queue_head(sk);
+	sacked =3D __tcp_write_queue_head(sk, TCP_WQ_SACKED);
+
+	if (skb =3D=3D NULL)
+		return sacked;
+	if (sacked =3D=3D NULL)
+		return skb;
+
+	if (after(TCP_SKB_CB(skb)->seq, TCP_SKB_CB(sacked)->seq))
+		return sacked;
+	return skb;
 }
=20
-static inline struct sk_buff *tcp_write_queue_tail(struct sock *sk)
+static inline struct sk_buff *__tcp_write_queue_tail(struct sock *sk, =
int queue)
 {
-	struct sk_buff *skb =3D sk->sk_write_queue.prev;
-	if (skb =3D=3D (struct sk_buff *) &sk->sk_write_queue)
+	struct sk_buff *skb =3D __tcp_list_select(sk, queue)->prev;
+	if (skb =3D=3D (struct sk_buff *)__tcp_list_select(sk, queue))
 		return NULL;
 	return skb;
 }
=20
+static inline struct sk_buff *tcp_write_queue_tail(struct sock *sk)
+{
+	return __tcp_write_queue_tail(sk, 0);
+}
+
+static inline int __tcp_write_queue_empty(struct sock *sk, int queue)
+{
+	return skb_queue_empty(__tcp_list_select(sk, queue));
+}
+
 static inline int tcp_write_queue_empty(struct sock *sk)
 {
-	return skb_queue_empty(&sk->sk_write_queue);
+	return __tcp_write_queue_empty(sk, 0);
 }
=20
 static inline struct sk_buff *tcp_write_queue_next(struct sock *sk, st=
ruct sk_buff *skb)
@@ -1252,17 +1316,17 @@ static inline int tcp_skb_adjacent(struct sock =
*sk, struct sk_buff *skb,
 }
=20
 #define tcp_for_write_queue(skb, sk, queue)				\
-		for (skb =3D (sk)->sk_write_queue.next;			\
-		     (skb !=3D (struct sk_buff *)&(sk)->sk_write_queue);	\
+		for (skb =3D __tcp_list_select(sk, queue)->next;		\
+		     (skb !=3D (struct sk_buff *)__tcp_list_select(sk, queue));\
 		     skb =3D skb->next)
=20
 #define tcp_for_write_queue_from(skb, sk, queue)			\
-		for (; (skb !=3D (struct sk_buff *)&(sk)->sk_write_queue);\
+		for (; (skb !=3D (struct sk_buff *)__tcp_list_select(sk, queue));\
 		     skb =3D skb->next)
=20
 #define tcp_for_write_queue_from_safe(skb, tmp, sk, queue)		\
 		for (tmp =3D skb->next;					\
-		     (skb !=3D (struct sk_buff *)&(sk)->sk_write_queue);	\
+		     (skb !=3D (struct sk_buff *)__tcp_list_select(sk, queue));\
 		     skb =3D tmp, tmp =3D skb->next)
=20
 static inline struct sk_buff *tcp_send_head(struct sock *sk)
@@ -1293,9 +1357,9 @@ static inline void tcp_init_send_head(struct sock=
 *sk)
 	sk->sk_send_head =3D NULL;
 }
=20
-static inline struct sk_buff *tcp_write_queue_find(struct sock *sk, __=
u32 seq)
+static inline struct sk_buff *__tcp_write_queue_find(struct rb_node *r=
b_node,
+						     __u32 seq)
 {
-	struct rb_node *rb_node =3D tcp_sk(sk)->write_queue_rb.rb_node;
 	struct sk_buff *skb =3D NULL;
=20
 	while (rb_node) {
@@ -1312,9 +1376,21 @@ static inline struct sk_buff *tcp_write_queue_fi=
nd(struct sock *sk, __u32 seq)
 	return skb;
 }
=20
-static inline void tcp_rb_insert(struct sk_buff *skb, struct rb_root *=
root)
+static inline struct sk_buff *tcp_write_queue_find(struct sock *sk, __=
u32 seq, int tree)
+{
+	return __tcp_write_queue_find(__tcp_tree_select(sk, tree)->rb_node, s=
eq);
+}
+
+/* Inserts skb into RB-tree root, prev node (ie., the skb before the i=
nserted
+ * one) is returned, which is available as a side-effect from  parent =
of the
+ * last rb_right edge. If no rb_right edge is walked, NULL is returned=
 (tree
+ * does not contain a smaller node).
+ */
+static struct sk_buff *__tcp_rb_insert(struct sk_buff *skb,
+				       struct rb_root *root)
 {
 	struct rb_node **rb_link, *rb_parent;
+	struct sk_buff *prev =3D NULL;
 	__u32 seq =3D TCP_SKB_CB(skb)->seq;
=20
 	rb_link =3D &root->rb_node;
@@ -1329,10 +1405,18 @@ static inline void tcp_rb_insert(struct sk_buff=
 *skb, struct rb_root *root)
 			rb_link =3D &rb_parent->rb_left;
 		} else {
 			rb_link =3D &rb_parent->rb_right;
+			prev =3D tmp;
 		}
 	}
 	rb_link_node(&skb->rb, rb_parent, rb_link);
 	rb_insert_color(&skb->rb, root);
+
+	return prev;
+}
+
+static inline void tcp_rb_insert(struct sk_buff *skb, struct rb_root *=
root)
+{
+	__tcp_rb_insert(skb, root);
 }
=20
 static inline void tcp_rb_unlink(struct sk_buff *skb, struct rb_root *=
root)
@@ -1372,59 +1456,166 @@ static inline void __tcp_add_write_queue_head(=
struct sock *sk, struct sk_buff *s
 	tcp_rb_insert(skb, &tcp_sk(sk)->write_queue_rb);
 }
=20
-/* An insert into the middle of the write queue causes the fack
- * counts in subsequent packets to become invalid, fix them up.
- */
-static inline void tcp_reset_fack_counts(struct sock *sk, struct sk_bu=
ff *skb)
+static inline struct sk_buff *__tcp_reset_fack_counts(struct sock *sk,
+						      struct sk_buff *skb,
+						      struct sk_buff **prev,
+						      int queue)
 {
-	struct sk_buff *prev =3D skb->prev;
 	unsigned int fc =3D 0;
=20
-	if (prev !=3D (struct sk_buff *) &sk->sk_write_queue)
-		fc =3D TCP_SKB_CB(prev)->fack_count + tcp_skb_pcount(prev);
+	if (prev =3D=3D NULL)
+		fc =3D TCP_SKB_CB(*prev)->fack_count + tcp_skb_pcount(*prev);
=20
-	tcp_for_write_queue_from(skb, sk, 0) {
-		if (!before(TCP_SKB_CB(skb)->seq, tcp_sk(sk)->snd_nxt) ||
-		    TCP_SKB_CB(skb)->fack_count =3D=3D fc)
+	BUG_ON((*prev !=3D NULL) && !tcp_skb_adjacent(sk, *prev, skb));
+
+	tcp_for_write_queue_from(skb, sk, queue) {
+		if ((*prev !=3D NULL) && !tcp_skb_adjacent(sk, *prev, skb))
 			break;
=20
+		/* Terminate whole search? */
+		if (!before(TCP_SKB_CB(skb)->seq, tcp_sk(sk)->snd_nxt) ||
+		    TCP_SKB_CB(skb)->fack_count =3D=3D fc) {
+			*prev =3D NULL;
+			return NULL;
+		}
+
 		TCP_SKB_CB(skb)->fack_count =3D fc;
 		fc +=3D tcp_skb_pcount(skb);
+
+		*prev =3D skb;
+	}
+
+	return skb;
+}
+
+/* An insert into the middle of the write queue causes the fack
+ * counts in subsequent packets to become invalid, fix them up.
+ *
+ * FIXME, this definately could be improved!
+ */
+static inline void tcp_reset_fack_counts(struct sock *sk, struct sk_bu=
ff *inskb)
+{
+	struct sk_buff *prev;
+	struct sk_buff *skb[2] =3D {NULL, NULL};
+	int queue;
+
+	if (!before(TCP_SKB_CB(inskb)->seq, tcp_sk(sk)->snd_nxt))
+		return;
+
+	queue =3D __tcp_skb_queue_select(inskb);
+	skb[queue] =3D inskb;
+
+	prev =3D inskb->prev;
+	if (inskb =3D=3D __tcp_write_queue_head(sk, queue))
+		prev =3D NULL;
+
+	if (((prev !=3D NULL) && !tcp_skb_adjacent(sk, prev, inskb)) ||
+	    ((prev =3D=3D NULL) && (TCP_SKB_CB(inskb)->seq !=3D tcp_sk(sk)->s=
nd_una))) {
+		int otherq =3D queue ^ TCP_WQ_SACKED;
+
+		BUG_ON (__tcp_write_queue_empty(sk, otherq));
+		prev =3D tcp_write_queue_find(sk, TCP_SKB_CB(inskb)->seq - 1,
+					    otherq);
+		BUG_ON (prev =3D=3D NULL || prev =3D=3D tcp_send_head(sk));
+		skb[otherq] =3D prev->next;
+	}
+
+	while (skb[queue] !=3D __tcp_write_queue_tail(sk, queue)) {
+		/* Lazy find for the other queue */
+		if (skb[queue] =3D=3D NULL) {
+			skb[queue] =3D tcp_write_queue_find(sk, TCP_SKB_CB(prev)->seq,
+						          queue ^ TCP_WQ_SACKED);
+			if (skb[queue] =3D=3D NULL)
+				break;
+		}
+
+		skb[queue] =3D __tcp_reset_fack_counts(sk, skb[queue], &prev, queue)=
;
+		if (skb[queue] =3D=3D NULL)
+			break;
+
+		queue ^=3D TCP_WQ_SACKED;
 	}
 }
=20
+static inline void __tcp_insert_write_queue_after(struct sk_buff *skb,
+						  struct sk_buff *buff,
+						  struct sock *sk,
+						  int queue)
+{
+	__skb_append(skb, buff, __tcp_list_select(sk, queue));
+	tcp_rb_insert(buff, __tcp_tree_select(sk, queue));
+}
+
 /* Insert buff after skb on the write queue of sk.  */
 static inline void tcp_insert_write_queue_after(struct sk_buff *skb,
 						struct sk_buff *buff,
 						struct sock *sk)
 {
-	__skb_append(skb, buff, &sk->sk_write_queue);
+	__tcp_insert_write_queue_after(skb, buff, sk, __tcp_skb_queue_select(=
buff));
 	tcp_reset_fack_counts(sk, buff);
-	tcp_rb_insert(buff, &tcp_sk(sk)->write_queue_rb);
 }
=20
-/* Insert new before skb on the write queue of sk.  */
-static inline void tcp_insert_write_queue_before(struct sk_buff *new,
-						  struct sk_buff *skb,
-						  struct sock *sk)
+/* Insert new before skb on the write queue of sk.
+ *
+ * This is only used for tcp_mtu_probe() new send_head injection. If t=
hat
+ * stops being true, needs to consider fack_counts and TCP_WQ_SACKED.
+ */
+static inline void __tcp_insert_write_queue_before(struct sk_buff *new=
,
+						   struct sk_buff *skb,
+						   struct sock *sk)
 {
+	BUG_ON(sk->sk_send_head !=3D skb);
+
 	__skb_insert(new, skb->prev, skb, &sk->sk_write_queue);
-	tcp_reset_fack_counts(sk, new);
 	tcp_rb_insert(new, &tcp_sk(sk)->write_queue_rb);
-
-	if (sk->sk_send_head =3D=3D skb)
-		sk->sk_send_head =3D new;
+	sk->sk_send_head =3D new;
 }
=20
 static inline void tcp_unlink_write_queue(struct sk_buff *skb, struct =
sock *sk)
 {
-	__skb_unlink(skb, &sk->sk_write_queue);
-	tcp_rb_unlink(skb, &tcp_sk(sk)->write_queue_rb);
+	int queue =3D __tcp_skb_queue_select(skb);
+
+	__skb_unlink(skb, __tcp_list_select(sk, queue));
+	tcp_rb_unlink(skb, __tcp_tree_select(sk, queue));
+}
+
+/* Moves skb to queue part of the skb space, a bit fragile, call must =
be made
+ * prior (important) sacked changes (=3D ->S and &~R)
+ */
+static inline void tcp_write_queue_requeue(struct sk_buff *skb,
+					   struct sock *sk, int queue)
+{
+	struct sk_buff *prev;
+
+	/* FIXME, most of hints are to be dropped soon... */
+	if (tcp_sk(sk)->scoreboard_skb_hint =3D=3D skb)
+		tcp_sk(sk)->scoreboard_skb_hint =3D skb->next;
+	if (tcp_sk(sk)->forward_skb_hint =3D=3D skb)
+		tcp_sk(sk)->forward_skb_hint =3D skb->next;
+	/* ...These have related cnt */
+	if (tcp_sk(sk)->lost_skb_hint =3D=3D skb)
+		tcp_sk(sk)->lost_skb_hint =3D NULL;
+	if (tcp_sk(sk)->retransmit_skb_hint =3D=3D skb)
+		tcp_sk(sk)->retransmit_skb_hint =3D NULL;
+
+	/* S|R must not be in SACKed space because of mark_lost_retrans walk =
*/
+	if ((queue =3D=3D TCP_WQ_SACKED) &&
+	    (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS))
+		return;
+
+	tcp_unlink_write_queue(skb, sk);
+
+	prev =3D __tcp_rb_insert(skb, __tcp_tree_select(sk, queue));
+	if (prev =3D=3D NULL)
+		prev =3D (struct sk_buff *)__tcp_list_select(sk, queue);
+	__skb_append(prev, skb, __tcp_list_select(sk, queue));
 }
=20
 static inline int tcp_skb_is_last(const struct sock *sk,
 				  const struct sk_buff *skb)
 {
+	BUG_ON(__tcp_skb_queue_select(skb) =3D=3D TCP_WQ_SACKED);
+
 	return skb->next =3D=3D (struct sk_buff *)&sk->sk_write_queue;
 }
=20
@@ -1442,6 +1633,9 @@ static inline u32 tcp_highest_sack_seq(struct tcp=
_sock *tp)
 	return TCP_SKB_CB(tp->highest_sack)->seq;
 }
=20
+/* This is somewhat dangerous now, because skb must still be in non-sa=
cked
+ * space
+ */
 static inline void tcp_advance_highest_sack(struct sock *sk, struct sk=
_buff *skb)
 {
 	tcp_sk(sk)->highest_sack =3D tcp_skb_is_last(sk, skb) ? NULL :
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1187dfa..227977d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1072,7 +1072,7 @@ static void tcp_update_reordering(struct sock *sk=
, const int metric,
  * the exact amount is rather hard to quantify. However, tp->max_windo=
w can
  * be used as an exaggerated estimate.
  */
-static int tcp_is_sackblock_valid(struct tcp_sock *tp, int is_dsack,
+static int tcp_is_sackblock_valid(struct tcp_sock *tp,
 				  u32 start_seq, u32 end_seq)
 {
 	/* Too far in future, or reversed (interpretation is ambiguous) */
@@ -1089,10 +1089,16 @@ static int tcp_is_sackblock_valid(struct tcp_so=
ck *tp, int is_dsack,
 	if (after(start_seq, tp->snd_una))
 		return 1;
=20
-	if (!is_dsack || !tp->undo_marker)
+	return 0;
+}
+
+static int tcp_is_past_dsack_useful(struct tcp_sock *tp,
+				    u32 start_seq, u32 end_seq)
+{
+	if (!tp->undo_marker)
 		return 0;
=20
-	/* ...Then it's D-SACK, and must reside below snd_una completely */
+	/* ...Past D-SACK must reside below snd_una completely */
 	if (!after(end_seq, tp->snd_una))
 		return 0;
=20
@@ -1149,6 +1155,10 @@ static void tcp_mark_lost_retrans(struct sock *s=
k)
 		    (tcp_is_fack(tp) ||
 		     !before(received_upto,
 			     ack_seq + tp->reordering * tp->mss_cache))) {
+
+			if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)
+				tcp_write_queue_requeue(skb, sk, TCP_WQ_SACKED);
+
 			TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_SACKED_RETRANS;
 			tp->retrans_out -=3D tcp_skb_pcount(skb);
=20
@@ -1262,6 +1272,7 @@ static int tcp_sacktag_one(struct sk_buff *skb, s=
truct sock *sk,
=20
 		if (!before(TCP_SKB_CB(skb)->seq, tcp_highest_sack_seq(tp)))
 			tcp_advance_highest_sack(sk, skb);
+		tcp_write_queue_requeue(skb, sk, TCP_WQ_SACKED);
=20
 		TCP_SKB_CB(skb)->sacked |=3D TCPCB_SACKED_ACKED;
 		flag |=3D FLAG_DATA_SACKED;
@@ -1284,6 +1295,8 @@ static int tcp_sacktag_one(struct sk_buff *skb, s=
truct sock *sk,
 	 * are accounted above as well.
 	 */
 	if (dup_sack && (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS)) {
+		tcp_write_queue_requeue(skb, sk, TCP_WQ_SACKED);
+
 		TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_SACKED_RETRANS;
 		tp->retrans_out -=3D tcp_skb_pcount(skb);
 		tp->retransmit_skb_hint =3D NULL;
@@ -1293,17 +1306,17 @@ static int tcp_sacktag_one(struct sk_buff *skb,=
 struct sock *sk,
 }
=20
 static struct sk_buff *tcp_sacktag_walk(struct sk_buff *skb, struct so=
ck *sk,
-					struct tcp_sack_block *next_dup,
 					u32 start_seq, u32 end_seq,
-					int dup_sack_in, int *reord, int *flag)
+					int dup_sack, int *reord, int *flag,
+					int queue)
 {
+	struct sk_buff *next;
 	unsigned int fack_count_base;
=20
 	fack_count_base =3D TCP_SKB_CB(tcp_write_queue_head(sk))->fack_count;
=20
-	tcp_for_write_queue_from(skb, sk, 0) {
+	tcp_for_write_queue_from_safe(skb, next, sk, queue) {
 		int in_sack =3D 0;
-		int dup_sack =3D dup_sack_in;
 		unsigned int fack_count;
=20
 		if (skb =3D=3D tcp_send_head(sk))
@@ -1313,17 +1326,7 @@ static struct sk_buff *tcp_sacktag_walk(struct s=
k_buff *skb, struct sock *sk,
 		if (!before(TCP_SKB_CB(skb)->seq, end_seq))
 			break;
=20
-		if ((next_dup !=3D NULL) &&
-		    before(TCP_SKB_CB(skb)->seq, next_dup->end_seq)) {
-			in_sack =3D tcp_match_skb_to_sack(sk, skb,
-							next_dup->start_seq,
-							next_dup->end_seq);
-			if (in_sack > 0)
-				dup_sack =3D 1;
-		}
-
-		if (in_sack <=3D 0)
-			in_sack =3D tcp_match_skb_to_sack(sk, skb, start_seq, end_seq);
+		in_sack =3D tcp_match_skb_to_sack(sk, skb, start_seq, end_seq);
 		if (unlikely(in_sack < 0))
 			break;
=20
@@ -1338,70 +1341,72 @@ static struct sk_buff *tcp_sacktag_walk(struct =
sk_buff *skb, struct sock *sk,
 /* Avoid all extra work that is being done by sacktag while walking in
  * a normal way
  */
-static struct sk_buff *tcp_sacktag_skip(struct sk_buff *skb, struct so=
ck *sk,
-					u32 skip_to_seq)
+static struct sk_buff *tcp_sacktag_skip(struct sock *sk, u32 skip_to_s=
eq)
 {
-	tcp_for_write_queue_from(skb, sk, 0) {
-		if (skb =3D=3D tcp_send_head(sk))
-			break;
-
-		if (!before(TCP_SKB_CB(skb)->end_seq, skip_to_seq))
-			break;
-	}
-	return skb;
-}
-
-static struct sk_buff *tcp_maybe_skipping_dsack(struct sk_buff *skb,
-						struct sock *sk,
-						struct tcp_sack_block *next_dup,
-						u32 skip_to_seq,
-						int *reord,
-						int *flag)
-{
-	if (next_dup =3D=3D NULL)
-		return skb;
-
-	if (before(next_dup->start_seq, skip_to_seq)) {
-		skb =3D tcp_sacktag_skip(skb, sk, next_dup->start_seq);
-		tcp_sacktag_walk(skb, sk, NULL,
-				 next_dup->start_seq, next_dup->end_seq,
-				 1, reord, flag);
-	}
+	struct sk_buff *skb;
=20
+	skb =3D tcp_write_queue_find(sk, skip_to_seq, 0);
+	if (skb =3D=3D tcp_write_queue_head(sk))
+		skb =3D NULL;
 	return skb;
 }
=20
-static int tcp_check_dsack(struct tcp_sock *tp, struct sk_buff *ack_sk=
b,
-			   struct tcp_sack_block_wire *sp, int num_sacks,
-			   u32 prior_snd_una)
+static int tcp_handle_dsack(struct sock *sk, struct sk_buff *ack_skb,
+			    struct tcp_sack_block_wire *sp, u32 *reord,
+			    int num_sacks, u32 prior_snd_una)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	struct sk_buff *skb;
 	u32 start_seq_0 =3D ntohl(get_unaligned(&sp[0].start_seq));
 	u32 end_seq_0 =3D ntohl(get_unaligned(&sp[0].end_seq));
-	int dup_sack =3D 0;
+	int flag =3D 0;
=20
 	if (before(start_seq_0, TCP_SKB_CB(ack_skb)->ack_seq)) {
-		dup_sack =3D 1;
+		flag |=3D FLAG_DSACKING_ACK;
 		tcp_dsack_seen(tp);
 		NET_INC_STATS_BH(LINUX_MIB_TCPDSACKRECV);
+
+		if (!tcp_is_past_dsack_useful(tp, start_seq_0, end_seq_0)) {
+			if (!tp->undo_marker)
+				NET_INC_STATS_BH(LINUX_MIB_TCPDSACKIGNOREDNOUNDO);
+			else
+				NET_INC_STATS_BH(LINUX_MIB_TCPDSACKIGNOREDOLD);
+
+			return flag;
+		}
+
+		/* D-SACK for already forgotten data... Do dumb counting. */
+		if (!after(end_seq_0, prior_snd_una))
+			tp->undo_retrans--;
+
 	} else if (num_sacks > 1) {
 		u32 end_seq_1 =3D ntohl(get_unaligned(&sp[1].end_seq));
 		u32 start_seq_1 =3D ntohl(get_unaligned(&sp[1].start_seq));
=20
 		if (!after(end_seq_0, end_seq_1) &&
 		    !before(start_seq_0, start_seq_1)) {
-			dup_sack =3D 1;
+			flag |=3D FLAG_DSACKING_ACK;
 			tcp_dsack_seen(tp);
 			NET_INC_STATS_BH(LINUX_MIB_TCPDSACKOFORECV);
+			if (!tcp_is_sackblock_valid(tp, start_seq_0, end_seq_0)) {
+				/* FIXME, reordering check like in the other place! */
+				NET_INC_STATS_BH(LINUX_MIB_TCPSACKDISCARD);
+				return flag;
+			}
 		}
 	}
=20
-	/* D-SACK for already forgotten data... Do dumb counting. */
-	if (dup_sack &&
-	    !after(end_seq_0, prior_snd_una) &&
-	    after(end_seq_0, tp->undo_marker))
-		tp->undo_retrans--;
+	if ((flag & FLAG_DSACKING_ACK) && after(end_seq_0, prior_snd_una)) {
+		skb =3D tcp_write_queue_find(sk, start_seq_0, TCP_WQ_SACKED);
+		if (skb !=3D NULL)
+			tcp_sacktag_walk(skb, sk, start_seq_0, end_seq_0, 1, reord, &flag, =
TCP_WQ_SACKED);
+
+		skb =3D tcp_write_queue_find(sk, start_seq_0, 0);
+		if (skb !=3D NULL)
+			tcp_sacktag_walk(skb, sk, start_seq_0, end_seq_0, 1, reord, &flag, =
0);
+	}
=20
-	return dup_sack;
+	return flag;
 }
=20
 static int tcp_sack_cache_ok(struct tcp_sock *tp, struct tcp_sack_bloc=
k *cache)
@@ -1424,9 +1429,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 	int used_sacks;
 	int reord =3D tp->packets_out;
 	int flag =3D 0;
-	int found_dup_sack =3D 0;
 	int i, j;
-	int first_sack_index;
=20
 	if (!tp->sacked_out) {
 		if (WARN_ON(tp->fackets_out))
@@ -1434,10 +1437,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct =
sk_buff *ack_skb, u32 prior_snd_
 		tcp_highest_sack_reset(sk);
 	}
=20
-	found_dup_sack =3D tcp_check_dsack(tp, ack_skb, sp_wire,
-					 num_sacks, prior_snd_una);
-	if (found_dup_sack)
-		flag |=3D FLAG_DSACKING_ACK;
+	flag |=3D tcp_handle_dsack(sk, ack_skb, sp_wire, &reord, num_sacks, p=
rior_snd_una);
=20
 	/* Eliminate too old ACKs, but take into
 	 * account more or less fresh ones, they can
@@ -1450,30 +1450,17 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
 		goto out;
=20
 	used_sacks =3D 0;
-	first_sack_index =3D 0;
-	for (i =3D 0; i < num_sacks; i++) {
-		int dup_sack =3D !i && found_dup_sack;
-
+	for (i =3D (flag & FLAG_DSACKING_ACK) ? 1 : 0; i < num_sacks; i++) {
 		sp[used_sacks].start_seq =3D ntohl(get_unaligned(&sp_wire[i].start_s=
eq));
 		sp[used_sacks].end_seq =3D ntohl(get_unaligned(&sp_wire[i].end_seq))=
;
=20
-		if (!tcp_is_sackblock_valid(tp, dup_sack,
-					    sp[used_sacks].start_seq,
+		if (!tcp_is_sackblock_valid(tp, sp[used_sacks].start_seq,
 					    sp[used_sacks].end_seq)) {
-			if (dup_sack) {
-				if (!tp->undo_marker)
-					NET_INC_STATS_BH(LINUX_MIB_TCPDSACKIGNOREDNOUNDO);
-				else
-					NET_INC_STATS_BH(LINUX_MIB_TCPDSACKIGNOREDOLD);
-			} else {
-				/* Don't count olds caused by ACK reordering */
-				if ((TCP_SKB_CB(ack_skb)->ack_seq !=3D tp->snd_una) &&
-				    !after(sp[used_sacks].end_seq, tp->snd_una))
-					continue;
-				NET_INC_STATS_BH(LINUX_MIB_TCPSACKDISCARD);
-			}
-			if (i =3D=3D 0)
-				first_sack_index =3D -1;
+			/* Don't count olds caused by ACK reordering */
+			if ((TCP_SKB_CB(ack_skb)->ack_seq !=3D tp->snd_una) &&
+			    !after(sp[used_sacks].end_seq, tp->snd_una))
+				continue;
+			NET_INC_STATS_BH(LINUX_MIB_TCPSACKDISCARD);
 			continue;
 		}
=20
@@ -1493,10 +1480,6 @@ tcp_sacktag_write_queue(struct sock *sk, struct =
sk_buff *ack_skb, u32 prior_snd_
 				tmp =3D sp[j];
 				sp[j] =3D sp[j+1];
 				sp[j+1] =3D tmp;
-
-				/* Track where the first SACK block goes to */
-				if (j =3D=3D first_sack_index)
-					first_sack_index =3D j+1;
 			}
 		}
 	}
@@ -1518,11 +1501,6 @@ tcp_sacktag_write_queue(struct sock *sk, struct =
sk_buff *ack_skb, u32 prior_snd_
 	while (i < used_sacks) {
 		u32 start_seq =3D sp[i].start_seq;
 		u32 end_seq =3D sp[i].end_seq;
-		int dup_sack =3D (found_dup_sack && (i =3D=3D first_sack_index));
-		struct tcp_sack_block *next_dup =3D NULL;
-
-		if (found_dup_sack && ((i + 1) =3D=3D first_sack_index))
-			next_dup =3D &sp[i + 1];
=20
 		/* Event "B" in the comment above. */
 		if (after(end_seq, tp->high_seq))
@@ -1534,24 +1512,23 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
 			cache++;
=20
 		/* Can skip some work by looking recv_sack_cache? */
-		if (tcp_sack_cache_ok(tp, cache) && !dup_sack &&
+		if (tcp_sack_cache_ok(tp, cache) &&
 		    after(end_seq, cache->start_seq)) {
=20
 			/* Head todo? */
 			if (before(start_seq, cache->start_seq)) {
-				skb =3D tcp_sacktag_skip(skb, sk, start_seq);
-				skb =3D tcp_sacktag_walk(skb, sk, next_dup, start_seq,
-						       cache->start_seq, dup_sack,
-						       &reord, &flag);
+				skb =3D tcp_sacktag_skip(sk, start_seq);
+				if (skb =3D=3D NULL)
+					break;
+				skb =3D tcp_sacktag_walk(skb, sk, start_seq,
+						       cache->start_seq, 0,
+						       &reord, &flag, 0);
 			}
=20
 			/* Rest of the block already fully processed? */
 			if (!after(end_seq, cache->end_seq))
 				goto advance_sp;
=20
-			skb =3D tcp_maybe_skipping_dsack(skb, sk, next_dup, cache->end_seq,
-						       &reord, &flag);
-
 			/* ...tail remains todo... */
 			if (tcp_highest_sack_seq(tp) =3D=3D cache->end_seq) {
 				/* ...but better entrypoint exists! */
@@ -1562,7 +1539,9 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 				goto walk;
 			}
=20
-			skb =3D tcp_sacktag_skip(skb, sk, cache->end_seq);
+			skb =3D tcp_sacktag_skip(sk, cache->end_seq);
+			if (skb =3D=3D NULL)
+				break;
 			/* Check overlap against next cached too (past this one already) */
 			cache++;
 			continue;
@@ -1573,11 +1552,13 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
 			if (skb =3D=3D NULL)
 				break;
 		}
-		skb =3D tcp_sacktag_skip(skb, sk, start_seq);
+		skb =3D tcp_sacktag_skip(sk, start_seq);
+		if (skb =3D=3D NULL)
+			break;
=20
 walk:
-		skb =3D tcp_sacktag_walk(skb, sk, next_dup, start_seq, end_seq,
-				       dup_sack, &reord, &flag);
+		skb =3D tcp_sacktag_walk(skb, sk, start_seq, end_seq,
+				       0, &reord, &flag, 0);
=20
 advance_sp:
 		/* SACK enhanced FRTO (RFC4138, Appendix B): Clearing correct
@@ -1674,6 +1655,7 @@ int tcp_use_frto(struct sock *sk)
 {
 	const struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *skb;
+	struct sk_buff *notsacked;	/* Or S|R =3D> deny basic F-RTO */
=20
 	if (!sysctl_tcp_frto)
 		return 0;
@@ -1685,15 +1667,19 @@ int tcp_use_frto(struct sock *sk)
 	if (tp->retrans_out > 1)
 		return 0;
=20
-	skb =3D tcp_write_queue_head(sk);
-	skb =3D tcp_write_queue_next(sk, skb);	/* Skips head */
-	tcp_for_write_queue_from(skb, sk, 0) {
-		if (skb =3D=3D tcp_send_head(sk))
-			break;
+	notsacked =3D tcp_write_queue_head(sk);
+	/* Not interested in head skb here because F-RTO is reentrable if onl=
y
+	 * head skb has been retransmitted (equals to multiple RTOs case)
+	 */
+	notsacked =3D tcp_write_queue_next(sk, notsacked);
+	if ((notsacked !=3D NULL) && TCP_SKB_CB(notsacked)->sacked & TCPCB_RE=
TRANS)
+		return 0;
+
+	tcp_for_write_queue(skb, sk, TCP_WQ_SACKED) {
 		if (TCP_SKB_CB(skb)->sacked&TCPCB_RETRANS)
 			return 0;
-		/* Short-circuit when first non-SACKed skb has been checked */
-		if (!(TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_ACKED))
+		/* Short-circuit when past first non-SACKed skb */
+		if (after(TCP_SKB_CB(skb)->seq, TCP_SKB_CB(notsacked)->seq))
 			break;
 	}
 	return 1;
@@ -1892,6 +1878,13 @@ void tcp_enter_loss(struct sock *sk, int how)
 		tp->sacked_out =3D 0;
 		tp->fackets_out =3D 0;
 		tcp_clear_all_retrans_hints(tp);
+
+		tcp_for_write_queue(skb, sk, TCP_WQ_SACKED) {
+			/* FIXME, this could be optimized by avoiding tree
+			 * deletes
+			 */
+			tcp_write_queue_requeue(skb, sk, 0);
+		}
 	}
=20
 	tcp_for_write_queue(skb, sk, 0) {
@@ -2135,6 +2128,10 @@ static void tcp_mark_head_lost(struct sock *sk, =
int packets, int fast_rexmit)
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *skb;
 	int cnt;
+	unsigned int fc;
+	unsigned int fack_count_base;
+
+	fack_count_base =3D TCP_SKB_CB(tcp_write_queue_head(sk))->fack_count;
=20
 	BUG_TRAP(packets <=3D tp->packets_out);
 	if (tp->lost_skb_hint) {
@@ -2153,9 +2150,18 @@ static void tcp_mark_head_lost(struct sock *sk, =
int packets, int fast_rexmit)
 		tp->lost_skb_hint =3D skb;
 		tp->lost_cnt_hint =3D cnt;
=20
-		if (tcp_is_fack(tp) ||
-		    (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
-			cnt +=3D tcp_skb_pcount(skb);
+		fc =3D TCP_SKB_CB(skb)->fack_count;
+		if (tcp_is_fack(tp)) {
+			cnt =3D fc - fack_count_base + tcp_skb_pcount(skb);
+		} else {
+			if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)
+				cnt +=3D tcp_skb_pcount(skb);
+			/* Add SACK blocks between this and skb->prev */
+			if ((skb !=3D tcp_write_queue_head(sk)) &&
+			    !tcp_skb_adjacent(sk, skb->prev, skb))
+				cnt +=3D fc - TCP_SKB_CB(skb->prev)->fack_count -
+						tcp_skb_pcount(skb->prev);
+		}
=20
 		if (((!fast_rexmit || (tp->lost_out > 0)) && (cnt > packets)) ||
 		     after(TCP_SKB_CB(skb)->end_seq, tp->high_seq))
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index b81284a..1d83c65 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1208,7 +1208,7 @@ static int tso_fragment(struct sock *sk, struct s=
k_buff *skb, unsigned int len,
=20
 	/* Link BUFF into the send queue. */
 	skb_header_release(buff);
-	tcp_insert_write_queue_after(skb, buff, sk);
+	__tcp_insert_write_queue_after(skb, buff, sk, 0);
=20
 	return 0;
 }
@@ -1345,7 +1345,7 @@ static int tcp_mtu_probe(struct sock *sk)
 	nskb->csum =3D 0;
 	nskb->ip_summed =3D skb->ip_summed;
=20
-	tcp_insert_write_queue_before(nskb, skb, sk);
+	__tcp_insert_write_queue_before(nskb, skb, sk);
=20
 	len =3D 0;
 	tcp_for_write_queue_from_safe(skb, next, sk, 0) {
--=20
1.5.0.6

