From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6.25] Revert recent TCP work
Date: Fri, 14 Dec 2007 22:14:29 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712141946060.1400@kivilampi-30.cs.helsinki.fi>
References: <20071204211701.994dfce6.akpm@linux-foundation.org>
 <47616FA6.1010607@fr.ibm.com> <Pine.LNX.4.64.0712140024360.12376@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-881831566-1197655752=:1400"
Cc: Cedric Le Goater <clg@fr.ibm.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Reuben Farrelly <reuben-linuxkernel@reub.net>,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>,
	Rik van Riel <riel@redhat.com>,
	Dhaval Giani <dhaval@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53308 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753017AbXLNUOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 15:14:33 -0500
In-Reply-To: <Pine.LNX.4.64.0712140024360.12376@kivilampi-30.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0712142208070.1400@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-881831566-1197655752=:1400
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0712142009271.1400@kivilampi-30.cs.helsinki.fi>

On Fri, 14 Dec 2007, Ilpo Järvinen wrote:

> So, I might soon prepare a revert patch for most of the questionable 
> TCP parts and ask Dave to apply it (and drop them fully during next 
> rebase) unless I suddently figure something out soon which explains 
> all/most of the problems, then return to drawing board. ...As it seems 
> that the cumulative ACK processing problem discovered later on (having 
> rather cumbersome solution with skbs only) will make part of the work 
> that's currently in net-2.6.25 quite useless/duplicate effort. But thanks 
> anyway for reporting these.

Hi Dave,

Could you either drop my recent patches (+one fix to them from Herbert
Xu == "[TCP]: Fix crash in tcp_advance_send_head"), all mine after "[TCP]: 
Abstract tp->highest_sack accessing & point to next skb" from net-2.6.25 
or just apply the revert from below and do the removal during next rebase. 
I think it could even be automated by something like this (untested):
for i in $(cat commits | cut -d ' ' -f 1); do git-rebase --onto $i^ $i; done 
(I've attached the commits list).

I'll resend small bits that are still useful but get removed in this kind 
of straightforward operation (I guess it's easier for you to track this 
way and makes conflicts a non-problem).

...It was buggy as well, I've tried to Cc all bug reporters that I've
noticed so far... Related bugs include at least these cases:

These are completely removed by this revert:
	__tcp_rb_insert
	(__|)tcp_reset_fack_counts
May still trigger later due to other, genuine bugs:
	tcp_sacktag_one (I'll rework & resend this soon)
	tcp_fastretrans_alert (fackets_out trap)
	BUG_TRAP(packets <= tp->packets_out); in tcp_mark_head_lost

-- 
 i.


[PATCH net-2.6.25] Revert recent TCP work

It was recently discovered that there's yet another processing
aspect to consider related to cumulative ACK processing. This
solution wasn't enough to handle that but "(arguably) complex"
and intrusive changes were still necessary in addition to the
complexity this already introduced. Another approach is on the
drawing board.

This was somehow buggy as well, a lot of reports against it
were filed already :-), but hunting the cause doesn't seem so
beneficial anymore.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/skbuff.h   |    3 -
 include/linux/tcp.h      |    4 -
 include/net/tcp.h        |  362 ++++------------------------------------------
 net/ipv4/tcp_input.c     |  341 ++++++++++++++++++++-----------------------
 net/ipv4/tcp_ipv4.c      |    1 -
 net/ipv4/tcp_minisocks.c |    1 -
 net/ipv4/tcp_output.c    |   13 +-
 net/ipv6/tcp_ipv6.c      |    1 -
 8 files changed, 196 insertions(+), 530 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f21fee6..c618fbf 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -18,7 +18,6 @@
 #include <linux/compiler.h>
 #include <linux/time.h>
 #include <linux/cache.h>
-#include <linux/rbtree.h>
 
 #include <asm/atomic.h>
 #include <asm/types.h>
@@ -254,8 +253,6 @@ struct sk_buff {
 	struct sk_buff		*next;
 	struct sk_buff		*prev;
 
-	struct rb_node		rb;
-
 	struct sock		*sk;
 	ktime_t			tstamp;
 	struct net_device	*dev;
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 56342c3..08027f1 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -174,7 +174,6 @@ struct tcp_md5sig {
 
 #include <linux/skbuff.h>
 #include <linux/dmaengine.h>
-#include <linux/rbtree.h>
 #include <net/sock.h>
 #include <net/inet_connection_sock.h>
 #include <net/inet_timewait_sock.h>
@@ -321,9 +320,6 @@ struct tcp_sock {
 	u32	snd_cwnd_used;
 	u32	snd_cwnd_stamp;
 
-	struct rb_root		write_queue_rb;
-	struct rb_root		sacked_queue_rb;
-	struct sk_buff_head	sacked_queue;
 	struct sk_buff_head	out_of_order_queue; /* Out of order segments go here */
 
  	u32	rcv_wnd;	/* Current receiver window		*/
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 5e6c433..5ec1cac 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -555,7 +555,6 @@ struct tcp_skb_cb {
 	__u32		seq;		/* Starting sequence number	*/
 	__u32		end_seq;	/* SEQ + FIN + SYN + datalen	*/
 	__u32		when;		/* used to compute rtt's	*/
-	unsigned int	fack_count;	/* speed up SACK processing	*/
 	__u8		flags;		/* TCP header flags.		*/
 
 	/* NOTE: These must match up to the flags byte in a
@@ -1191,112 +1190,29 @@ static inline void		tcp_put_md5sig_pool(void)
 }
 
 /* write queue abstraction */
-#define TCP_WQ_SACKED	1
-
-static inline struct sk_buff_head *__tcp_list_select(struct sock *sk, const int queue)
-{
-	if (queue == TCP_WQ_SACKED)
-		return &tcp_sk(sk)->sacked_queue;
-	else
-		return &sk->sk_write_queue;
-}
-
-static inline struct rb_root *__tcp_tree_select(struct sock *sk, const int tree)
-{
-	if (tree == TCP_WQ_SACKED)
-		return &tcp_sk(sk)->sacked_queue_rb;
-	else
-		return &tcp_sk(sk)->write_queue_rb;
-}
-
-/* All SACKed except S|R go to a separate skb space */
-static inline int __tcp_skb_queue_select(const struct sk_buff *skb)
-{
-	if ((TCP_SKB_CB(skb)->sacked &
-			(TCPCB_SACKED_ACKED|TCPCB_SACKED_RETRANS)) ==
-			TCPCB_SACKED_ACKED)
-		return TCP_WQ_SACKED;
-	else
-		return 0;
-}
-
-static inline void tcp_write_queue_init(struct sock *sk)
-{
-	tcp_sk(sk)->write_queue_rb = RB_ROOT;
-	tcp_sk(sk)->sacked_queue_rb = RB_ROOT;
-	skb_queue_head_init(&tcp_sk(sk)->sacked_queue);
-}
-
-static inline void __tcp_write_queue_purge(struct sock *sk, int queue)
+static inline void tcp_write_queue_purge(struct sock *sk)
 {
 	struct sk_buff *skb;
 
-	while ((skb = __skb_dequeue(__tcp_list_select(sk, queue))) != NULL)
+	while ((skb = __skb_dequeue(&sk->sk_write_queue)) != NULL)
 		sk_stream_free_skb(sk, skb);
-	*__tcp_tree_select(sk, queue) = RB_ROOT;
-}
-
-static inline void tcp_write_queue_purge(struct sock *sk)
-{
-	__tcp_write_queue_purge(sk, 0);
-	__tcp_write_queue_purge(sk, TCP_WQ_SACKED);
 	sk_stream_mem_reclaim(sk);
 }
 
-static inline struct sk_buff *__tcp_write_queue_head(struct sock *sk, int queue)
-{
-	struct sk_buff *skb = __tcp_list_select(sk, queue)->next;
-	if (skb == (struct sk_buff *)__tcp_list_select(sk, queue))
-		return NULL;
-	return skb;
-}
-
 static inline struct sk_buff *tcp_write_queue_head(struct sock *sk)
 {
-	return __tcp_write_queue_head(sk, 0);
-}
-
-/* FIXME, this should eventually vanish because callers likely benefit
- * from scanning the non-SACKed and SACKed spaces separately.
- */
-static inline struct sk_buff *tcp_real_queue_head(struct sock *sk)
-{
-	struct sk_buff *skb, *sacked;
-
-	skb = tcp_write_queue_head(sk);
-	sacked = __tcp_write_queue_head(sk, TCP_WQ_SACKED);
-
-	if (skb == NULL)
-		return sacked;
-	if (sacked == NULL)
-		return skb;
-
-	if (after(TCP_SKB_CB(skb)->seq, TCP_SKB_CB(sacked)->seq))
-		return sacked;
-	return skb;
-}
-
-static inline struct sk_buff *__tcp_write_queue_tail(struct sock *sk, int queue)
-{
-	struct sk_buff *skb = __tcp_list_select(sk, queue)->prev;
-	if (skb == (struct sk_buff *)__tcp_list_select(sk, queue))
+	struct sk_buff *skb = sk->sk_write_queue.next;
+	if (skb == (struct sk_buff *) &sk->sk_write_queue)
 		return NULL;
 	return skb;
 }
 
 static inline struct sk_buff *tcp_write_queue_tail(struct sock *sk)
 {
-	return __tcp_write_queue_tail(sk, 0);
-}
-
-static inline int __tcp_write_queue_empty(struct sock *sk, int queue)
-{
-	return skb_queue_empty(__tcp_list_select(sk, queue));
-}
-
-static inline int tcp_write_queue_empty(struct sock *sk)
-{
-	return __tcp_write_queue_empty(sk, 0);
+	struct sk_buff *skb = sk->sk_write_queue.prev;
+	if (skb == (struct sk_buff *) &sk->sk_write_queue)
+		return NULL;
+	return skb;
 }
 
 static inline struct sk_buff *tcp_write_queue_next(struct sock *sk, struct sk_buff *skb)
@@ -1304,29 +1220,18 @@ static inline struct sk_buff *tcp_write_queue_next(struct sock *sk, struct sk_bu
 	return skb->next;
 }
 
-static inline struct sk_buff *tcp_write_queue_prev(struct sock *sk, struct sk_buff *skb)
-{
-	return skb->prev;
-}
-
-static inline int tcp_skb_adjacent(struct sock *sk, struct sk_buff *skb,
-				   struct sk_buff *next)
-{
-	return TCP_SKB_CB(skb)->end_seq == TCP_SKB_CB(next)->seq;
-}
-
-#define tcp_for_write_queue(skb, sk, queue)				\
-		for (skb = __tcp_list_select(sk, queue)->next;		\
-		     (skb != (struct sk_buff *)__tcp_list_select(sk, queue));\
+#define tcp_for_write_queue(skb, sk)					\
+		for (skb = (sk)->sk_write_queue.next;			\
+		     (skb != (struct sk_buff *)&(sk)->sk_write_queue);	\
 		     skb = skb->next)
 
-#define tcp_for_write_queue_from(skb, sk, queue)			\
-		for (; (skb != (struct sk_buff *)__tcp_list_select(sk, queue));\
+#define tcp_for_write_queue_from(skb, sk)				\
+		for (; (skb != (struct sk_buff *)&(sk)->sk_write_queue);\
 		     skb = skb->next)
 
-#define tcp_for_write_queue_from_safe(skb, tmp, sk, queue)		\
+#define tcp_for_write_queue_from_safe(skb, tmp, sk)			\
 		for (tmp = skb->next;					\
-		     (skb != (struct sk_buff *)__tcp_list_select(sk, queue));\
+		     (skb != (struct sk_buff *)&(sk)->sk_write_queue);	\
 		     skb = tmp, tmp = skb->next)
 
 static inline struct sk_buff *tcp_send_head(struct sock *sk)
@@ -1336,23 +1241,7 @@ static inline struct sk_buff *tcp_send_head(struct sock *sk)
 
 static inline void tcp_advance_send_head(struct sock *sk, struct sk_buff *skb)
 {
-	struct sk_buff *prev = tcp_write_queue_prev(sk, skb);
-	unsigned int fc = 0;
-
-	if (prev == (struct sk_buff *)&sk->sk_write_queue)
-		prev = NULL;
-	else if (!tcp_skb_adjacent(sk, prev, skb))
-		prev = NULL;
-
-	if ((prev == NULL) && !__tcp_write_queue_empty(sk, TCP_WQ_SACKED))
-		prev = __tcp_write_queue_tail(sk, TCP_WQ_SACKED);
-
-	if (prev != NULL)
-		fc = TCP_SKB_CB(prev)->fack_count + tcp_skb_pcount(prev);
-
-	TCP_SKB_CB(skb)->fack_count = fc;
-
-	sk->sk_send_head = tcp_write_queue_next(sk, skb);
+	sk->sk_send_head = skb->next;
 	if (sk->sk_send_head == (struct sk_buff *)&sk->sk_write_queue)
 		sk->sk_send_head = NULL;
 }
@@ -1368,78 +1257,9 @@ static inline void tcp_init_send_head(struct sock *sk)
 	sk->sk_send_head = NULL;
 }
 
-static inline struct sk_buff *__tcp_write_queue_find(struct rb_node *rb_node,
-						     __u32 seq)
-{
-	struct sk_buff *skb = NULL;
-
-	while (rb_node) {
-		struct sk_buff *tmp = rb_entry(rb_node,struct sk_buff,rb);
-		if (after(TCP_SKB_CB(tmp)->end_seq, seq)) {
-			skb = tmp;
-			if (!after(TCP_SKB_CB(tmp)->seq, seq))
-				break;
-			rb_node = rb_node->rb_left;
-		} else
-			rb_node = rb_node->rb_right;
-
-	}
-	return skb;
-}
-
-static inline struct sk_buff *tcp_write_queue_find(struct sock *sk, __u32 seq, int tree)
-{
-	return __tcp_write_queue_find(__tcp_tree_select(sk, tree)->rb_node, seq);
-}
-
-/* Inserts skb into RB-tree root, prev node (ie., the skb before the inserted
- * one) is returned, which is available as a side-effect from  parent of the
- * last rb_right edge. If no rb_right edge is walked, NULL is returned (tree
- * does not contain a smaller node).
- */
-static struct sk_buff *__tcp_rb_insert(struct sk_buff *skb,
-				       struct rb_root *root)
-{
-	struct rb_node **rb_link, *rb_parent;
-	struct sk_buff *prev = NULL;
-	__u32 seq = TCP_SKB_CB(skb)->seq;
-
-	rb_link = &root->rb_node;
-	rb_parent = NULL;
-	while (*rb_link) {
-		struct sk_buff *tmp;
-
-		rb_parent = *rb_link;
-		tmp = rb_entry(rb_parent,struct sk_buff,rb);
-		if (after(TCP_SKB_CB(tmp)->end_seq, seq)) {
-			BUG_ON(!after(TCP_SKB_CB(tmp)->seq, seq));
-			rb_link = &rb_parent->rb_left;
-		} else {
-			rb_link = &rb_parent->rb_right;
-			prev = tmp;
-		}
-	}
-	rb_link_node(&skb->rb, rb_parent, rb_link);
-	rb_insert_color(&skb->rb, root);
-
-	return prev;
-}
-
-static inline void tcp_rb_insert(struct sk_buff *skb, struct rb_root *root)
-{
-	__tcp_rb_insert(skb, root);
-}
-
-static inline void tcp_rb_unlink(struct sk_buff *skb, struct rb_root *root)
-{
-	rb_erase(&skb->rb, root);
-}
-
 static inline void __tcp_add_write_queue_tail(struct sock *sk, struct sk_buff *skb)
 {
-	TCP_SKB_CB(skb)->fack_count = 0;
 	__skb_queue_tail(&sk->sk_write_queue, skb);
-	tcp_rb_insert(skb, &tcp_sk(sk)->write_queue_rb);
 }
 
 static inline void tcp_add_write_queue_tail(struct sock *sk, struct sk_buff *skb)
@@ -1455,90 +1275,9 @@ static inline void tcp_add_write_queue_tail(struct sock *sk, struct sk_buff *skb
 	}
 }
 
-/* This is only used for tcp_send_synack(), so the write queue should
- * be empty.  If that stops being true, the fack_count assignment
- * will need to be more elaborate.
- */
 static inline void __tcp_add_write_queue_head(struct sock *sk, struct sk_buff *skb)
 {
-	BUG_ON(!skb_queue_empty(&sk->sk_write_queue));
 	__skb_queue_head(&sk->sk_write_queue, skb);
-	TCP_SKB_CB(skb)->fack_count = 0;
-	tcp_rb_insert(skb, &tcp_sk(sk)->write_queue_rb);
-}
-
-/* An insert into the middle of the write queue causes the fack
- * counts in subsequent packets to become invalid, fix them up.
- *
- * FIXME, this definately could be improved!
- */
-static inline void tcp_reset_fack_counts(struct sock *sk, struct sk_buff *inskb)
-{
-	struct sk_buff *prev;
-	struct sk_buff *skb[2] = {NULL, NULL};
-	int queue;
-	unsigned int fc = 0;
-
-	if (!before(TCP_SKB_CB(inskb)->seq, tcp_sk(sk)->snd_nxt))
-		return;
-
-	queue = __tcp_skb_queue_select(inskb);
-	skb[queue] = inskb;
-
-	prev = inskb->prev;
-	if (inskb == __tcp_write_queue_head(sk, queue))
-		prev = NULL;
-
-	if (((prev != NULL) && !tcp_skb_adjacent(sk, prev, inskb)) ||
-	    ((prev == NULL) && (TCP_SKB_CB(inskb)->seq != tcp_sk(sk)->snd_una))) {
-		int otherq = queue ^ TCP_WQ_SACKED;
-
-		BUG_ON (__tcp_write_queue_empty(sk, otherq));
-		prev = tcp_write_queue_find(sk, TCP_SKB_CB(inskb)->seq - 1,
-					    otherq);
-		BUG_ON (prev == NULL || prev == tcp_send_head(sk));
-		skb[otherq] = prev->next;
-	}
-
-	if (prev != NULL)
-		fc = TCP_SKB_CB(prev)->fack_count + tcp_skb_pcount(prev);
-
-	while (skb[queue] != (struct sk_buff *)__tcp_list_select(sk, queue)) {
-		/* Lazy find for the other queue */
-		if (skb[queue] == NULL) {
-			skb[queue] = tcp_write_queue_find(sk, TCP_SKB_CB(prev)->seq,
-						          queue);
-			if (skb[queue] == NULL)
-				break;
-		}
-
-		BUG_ON((prev != NULL) && !tcp_skb_adjacent(sk, prev, skb[queue]));
-
-		tcp_for_write_queue_from(skb[queue], sk, queue) {
-			if ((prev != NULL) && !tcp_skb_adjacent(sk, prev, skb[queue]))
-				break;
-
-			if (!before(TCP_SKB_CB(skb[queue])->seq, tcp_sk(sk)->snd_nxt) ||
-			    TCP_SKB_CB(skb[queue])->fack_count == fc)
-				return;
-
-			TCP_SKB_CB(skb[queue])->fack_count = fc;
-			fc += tcp_skb_pcount(skb[queue]);
-
-			prev = skb[queue];
-		}
-
-		queue ^= TCP_WQ_SACKED;
-	}
-}
-
-static inline void __tcp_insert_write_queue_after(struct sk_buff *skb,
-						  struct sk_buff *buff,
-						  struct sock *sk,
-						  int queue)
-{
-	__skb_append(skb, buff, __tcp_list_select(sk, queue));
-	tcp_rb_insert(buff, __tcp_tree_select(sk, queue));
 }
 
 /* Insert buff after skb on the write queue of sk.  */
@@ -1546,74 +1285,36 @@ static inline void tcp_insert_write_queue_after(struct sk_buff *skb,
 						struct sk_buff *buff,
 						struct sock *sk)
 {
-	__tcp_insert_write_queue_after(skb, buff, sk, __tcp_skb_queue_select(buff));
-	tcp_reset_fack_counts(sk, buff);
+	__skb_append(skb, buff, &sk->sk_write_queue);
 }
 
-/* Insert new before skb on the write queue of sk.
- *
- * This is only used for tcp_mtu_probe() new send_head injection. If that
- * stops being true, needs to consider fack_counts and TCP_WQ_SACKED.
- */
-static inline void __tcp_insert_write_queue_before(struct sk_buff *new,
-						   struct sk_buff *skb,
-						   struct sock *sk)
+/* Insert skb between prev and next on the write queue of sk.  */
+static inline void tcp_insert_write_queue_before(struct sk_buff *new,
+						  struct sk_buff *skb,
+						  struct sock *sk)
 {
-	BUG_ON(sk->sk_send_head != skb);
-
 	__skb_insert(new, skb->prev, skb, &sk->sk_write_queue);
-	tcp_rb_insert(new, &tcp_sk(sk)->write_queue_rb);
-	sk->sk_send_head = new;
-}
 
-static inline void tcp_unlink_write_queue(struct sk_buff *skb, struct sock *sk)
-{
-	int queue = __tcp_skb_queue_select(skb);
-
-	__skb_unlink(skb, __tcp_list_select(sk, queue));
-	tcp_rb_unlink(skb, __tcp_tree_select(sk, queue));
+	if (sk->sk_send_head == skb)
+		sk->sk_send_head = new;
 }
 
-/* Moves skb to queue part of the skb space, a bit fragile, call must be made
- * prior (important) sacked changes (= ->S and &~R)
- */
-static inline void tcp_write_queue_requeue(struct sk_buff *skb,
-					   struct sock *sk, int queue)
+static inline void tcp_unlink_write_queue(struct sk_buff *skb, struct sock *sk)
 {
-	struct sk_buff *prev;
-
-	/* FIXME, most of hints are to be dropped soon... */
-	if (tcp_sk(sk)->scoreboard_skb_hint == skb)
-		tcp_sk(sk)->scoreboard_skb_hint = skb->next;
-	if (tcp_sk(sk)->forward_skb_hint == skb)
-		tcp_sk(sk)->forward_skb_hint = skb->next;
-	/* ...These have related cnt */
-	if (tcp_sk(sk)->lost_skb_hint == skb)
-		tcp_sk(sk)->lost_skb_hint = NULL;
-	if (tcp_sk(sk)->retransmit_skb_hint == skb)
-		tcp_sk(sk)->retransmit_skb_hint = NULL;
-
-	/* S|R must not be in SACKed space because of mark_lost_retrans walk */
-	if ((queue == TCP_WQ_SACKED) &&
-	    (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS))
-		return;
-
-	tcp_unlink_write_queue(skb, sk);
-
-	prev = __tcp_rb_insert(skb, __tcp_tree_select(sk, queue));
-	if (prev == NULL)
-		prev = (struct sk_buff *)__tcp_list_select(sk, queue);
-	__skb_append(prev, skb, __tcp_list_select(sk, queue));
+	__skb_unlink(skb, &sk->sk_write_queue);
 }
 
 static inline int tcp_skb_is_last(const struct sock *sk,
 				  const struct sk_buff *skb)
 {
-	BUG_ON(__tcp_skb_queue_select(skb) == TCP_WQ_SACKED);
-
 	return skb->next == (struct sk_buff *)&sk->sk_write_queue;
 }
 
+static inline int tcp_write_queue_empty(struct sock *sk)
+{
+	return skb_queue_empty(&sk->sk_write_queue);
+}
+
 /* Start sequence of the highest skb with SACKed bit, valid only if
  * sacked > 0 or when the caller has ensured validity by itself.
  */
@@ -1628,9 +1329,6 @@ static inline u32 tcp_highest_sack_seq(struct tcp_sock *tp)
 	return TCP_SKB_CB(tp->highest_sack)->seq;
 }
 
-/* This is somewhat dangerous now, because skb must still be in non-sacked
- * space
- */
 static inline void tcp_advance_highest_sack(struct sock *sk, struct sk_buff *skb)
 {
 	tcp_sk(sk)->highest_sack = tcp_skb_is_last(sk, skb) ? NULL :
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 218754b..616bbcb 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1072,7 +1072,7 @@ static void tcp_update_reordering(struct sock *sk, const int metric,
  * the exact amount is rather hard to quantify. However, tp->max_window can
  * be used as an exaggerated estimate.
  */
-static int tcp_is_sackblock_valid(struct tcp_sock *tp,
+static int tcp_is_sackblock_valid(struct tcp_sock *tp, int is_dsack,
 				  u32 start_seq, u32 end_seq)
 {
 	/* Too far in future, or reversed (interpretation is ambiguous) */
@@ -1089,16 +1089,10 @@ static int tcp_is_sackblock_valid(struct tcp_sock *tp,
 	if (after(start_seq, tp->snd_una))
 		return 1;
 
-	return 0;
-}
-
-static int tcp_is_past_dsack_useful(struct tcp_sock *tp,
-				    u32 start_seq, u32 end_seq)
-{
-	if (!tp->undo_marker)
+	if (!is_dsack || !tp->undo_marker)
 		return 0;
 
-	/* ...Past D-SACK must reside below snd_una completely */
+	/* ...Then it's D-SACK, and must reside below snd_una completely */
 	if (!after(end_seq, tp->snd_una))
 		return 0;
 
@@ -1138,7 +1132,7 @@ static void tcp_mark_lost_retrans(struct sock *sk)
 	    icsk->icsk_ca_state != TCP_CA_Recovery)
 		return;
 
-	tcp_for_write_queue(skb, sk, 0) {
+	tcp_for_write_queue(skb, sk) {
 		u32 ack_seq = TCP_SKB_CB(skb)->ack_seq;
 
 		if (skb == tcp_send_head(sk))
@@ -1155,10 +1149,6 @@ static void tcp_mark_lost_retrans(struct sock *sk)
 		    (tcp_is_fack(tp) ||
 		     !before(received_upto,
 			     ack_seq + tp->reordering * tp->mss_cache))) {
-
-			if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)
-				tcp_write_queue_requeue(skb, sk, TCP_WQ_SACKED);
-
 			TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_RETRANS;
 			tp->retrans_out -= tcp_skb_pcount(skb);
 
@@ -1181,6 +1171,39 @@ static void tcp_mark_lost_retrans(struct sock *sk)
 		tp->lost_retrans_low = new_low_seq;
 }
 
+static int tcp_check_dsack(struct tcp_sock *tp, struct sk_buff *ack_skb,
+			   struct tcp_sack_block_wire *sp, int num_sacks,
+			   u32 prior_snd_una)
+{
+	u32 start_seq_0 = ntohl(get_unaligned(&sp[0].start_seq));
+	u32 end_seq_0 = ntohl(get_unaligned(&sp[0].end_seq));
+	int dup_sack = 0;
+
+	if (before(start_seq_0, TCP_SKB_CB(ack_skb)->ack_seq)) {
+		dup_sack = 1;
+		tcp_dsack_seen(tp);
+		NET_INC_STATS_BH(LINUX_MIB_TCPDSACKRECV);
+	} else if (num_sacks > 1) {
+		u32 end_seq_1 = ntohl(get_unaligned(&sp[1].end_seq));
+		u32 start_seq_1 = ntohl(get_unaligned(&sp[1].start_seq));
+
+		if (!after(end_seq_0, end_seq_1) &&
+		    !before(start_seq_0, start_seq_1)) {
+			dup_sack = 1;
+			tcp_dsack_seen(tp);
+			NET_INC_STATS_BH(LINUX_MIB_TCPDSACKOFORECV);
+		}
+	}
+
+	/* D-SACK for already forgotten data... Do dumb counting. */
+	if (dup_sack &&
+	    !after(end_seq_0, prior_snd_una) &&
+	    after(end_seq_0, tp->undo_marker))
+		tp->undo_retrans--;
+
+	return dup_sack;
+}
+
 /* Check if skb is fully within the SACK block. In presence of GSO skbs,
  * the incoming SACK may not exactly match but we can find smaller MSS
  * aligned portion of it that matches. Therefore we might need to fragment
@@ -1214,15 +1237,11 @@ static int tcp_match_skb_to_sack(struct sock *sk, struct sk_buff *skb,
 }
 
 static int tcp_sacktag_one(struct sk_buff *skb, struct sock *sk,
-			   int *reord, int dup_sack)
+			   int *reord, int dup_sack, int fack_count)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	u8 sacked = TCP_SKB_CB(skb)->sacked;
 	int flag = 0;
-	int fack_count;
-
-	fack_count = TCP_SKB_CB(skb)->fack_count -
-			TCP_SKB_CB(tcp_write_queue_head(sk))->fack_count;
 
 	/* Account D-SACK for retransmitted packet. */
 	if (dup_sack && (sacked & TCPCB_RETRANS)) {
@@ -1274,28 +1293,23 @@ static int tcp_sacktag_one(struct sk_buff *skb, struct sock *sk,
 			}
 		}
 
-		fack_count += tcp_skb_pcount(skb);
-		if (!before(TCP_SKB_CB(skb)->seq, tcp_highest_sack_seq(tp))) {
-			WARN_ON((fack_count <= tp->fackets_out) ||
-				(fack_count > tp->packets_out));
-
-			tcp_advance_highest_sack(sk, skb);
-			tp->fackets_out = fack_count;
-		} else
-			WARN_ON(fack_count > tp->fackets_out);
-
-		tcp_write_queue_requeue(skb, sk, TCP_WQ_SACKED);
-
 		TCP_SKB_CB(skb)->sacked |= TCPCB_SACKED_ACKED;
 		flag |= FLAG_DATA_SACKED;
 		tp->sacked_out += tcp_skb_pcount(skb);
 
+		fack_count += tcp_skb_pcount(skb);
+
 		/* Lost marker hint past SACKed? Tweak RFC3517 cnt */
 		if (!tcp_is_fack(tp) && (tp->lost_skb_hint != NULL) &&
 		    before(TCP_SKB_CB(skb)->seq,
 			   TCP_SKB_CB(tp->lost_skb_hint)->seq))
 			tp->lost_cnt_hint += tcp_skb_pcount(skb);
 
+		if (fack_count > tp->fackets_out)
+			tp->fackets_out = fack_count;
+
+		if (!before(TCP_SKB_CB(skb)->seq, tcp_highest_sack_seq(tp)))
+			tcp_advance_highest_sack(sk, skb);
 	}
 
 	/* D-SACK. We can detect redundant retransmission in S|R and plain R
@@ -1303,8 +1317,6 @@ static int tcp_sacktag_one(struct sk_buff *skb, struct sock *sk,
 	 * are accounted above as well.
 	 */
 	if (dup_sack && (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS)) {
-		tcp_write_queue_requeue(skb, sk, TCP_WQ_SACKED);
-
 		TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_RETRANS;
 		tp->retrans_out -= tcp_skb_pcount(skb);
 		tp->retransmit_skb_hint = NULL;
@@ -1314,14 +1326,14 @@ static int tcp_sacktag_one(struct sk_buff *skb, struct sock *sk,
 }
 
 static struct sk_buff *tcp_sacktag_walk(struct sk_buff *skb, struct sock *sk,
+					struct tcp_sack_block *next_dup,
 					u32 start_seq, u32 end_seq,
-					int dup_sack, int *reord, int *flag,
-					int queue)
+					int dup_sack_in, int *fack_count,
+					int *reord, int *flag)
 {
-	struct sk_buff *next;
-
-	tcp_for_write_queue_from_safe(skb, next, sk, queue) {
+	tcp_for_write_queue_from(skb, sk) {
 		int in_sack = 0;
+		int dup_sack = dup_sack_in;
 
 		if (skb == tcp_send_head(sk))
 			break;
@@ -1330,12 +1342,24 @@ static struct sk_buff *tcp_sacktag_walk(struct sk_buff *skb, struct sock *sk,
 		if (!before(TCP_SKB_CB(skb)->seq, end_seq))
 			break;
 
-		in_sack = tcp_match_skb_to_sack(sk, skb, start_seq, end_seq);
+		if ((next_dup != NULL) &&
+		    before(TCP_SKB_CB(skb)->seq, next_dup->end_seq)) {
+			in_sack = tcp_match_skb_to_sack(sk, skb,
+							next_dup->start_seq,
+							next_dup->end_seq);
+			if (in_sack > 0)
+				dup_sack = 1;
+		}
+
+		if (in_sack <= 0)
+			in_sack = tcp_match_skb_to_sack(sk, skb, start_seq, end_seq);
 		if (unlikely(in_sack < 0))
 			break;
 
 		if (in_sack)
-			*flag |= tcp_sacktag_one(skb, sk, reord, dup_sack);
+			*flag |= tcp_sacktag_one(skb, sk, reord, dup_sack, *fack_count);
+
+		*fack_count += tcp_skb_pcount(skb);
 	}
 	return skb;
 }
@@ -1343,72 +1367,37 @@ static struct sk_buff *tcp_sacktag_walk(struct sk_buff *skb, struct sock *sk,
 /* Avoid all extra work that is being done by sacktag while walking in
  * a normal way
  */
-static struct sk_buff *tcp_sacktag_skip(struct sock *sk, u32 skip_to_seq)
+static struct sk_buff *tcp_sacktag_skip(struct sk_buff *skb, struct sock *sk,
+					u32 skip_to_seq)
 {
-	struct sk_buff *skb;
+	tcp_for_write_queue_from(skb, sk) {
+		if (skb == tcp_send_head(sk))
+			break;
 
-	skb = tcp_write_queue_find(sk, skip_to_seq, 0);
-	if (skb == tcp_write_queue_head(sk))
-		skb = NULL;
+		if (!before(TCP_SKB_CB(skb)->end_seq, skip_to_seq))
+			break;
+	}
 	return skb;
 }
 
-static int tcp_handle_dsack(struct sock *sk, struct sk_buff *ack_skb,
-			    struct tcp_sack_block_wire *sp, u32 *reord,
-			    int num_sacks, u32 prior_snd_una)
+static struct sk_buff *tcp_maybe_skipping_dsack(struct sk_buff *skb,
+						struct sock *sk,
+						struct tcp_sack_block *next_dup,
+						u32 skip_to_seq,
+						int *fack_count, int *reord,
+						int *flag)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
-	struct sk_buff *skb;
-	u32 start_seq_0 = ntohl(get_unaligned(&sp[0].start_seq));
-	u32 end_seq_0 = ntohl(get_unaligned(&sp[0].end_seq));
-	int flag = 0;
+	if (next_dup == NULL)
+		return skb;
 
-	if (before(start_seq_0, TCP_SKB_CB(ack_skb)->ack_seq)) {
-		flag |= FLAG_DSACKING_ACK;
-		tcp_dsack_seen(tp);
-		NET_INC_STATS_BH(LINUX_MIB_TCPDSACKRECV);
-
-		if (!tcp_is_past_dsack_useful(tp, start_seq_0, end_seq_0)) {
-			if (!tp->undo_marker)
-				NET_INC_STATS_BH(LINUX_MIB_TCPDSACKIGNOREDNOUNDO);
-			else
-				NET_INC_STATS_BH(LINUX_MIB_TCPDSACKIGNOREDOLD);
-
-			return flag;
-		}
-
-		/* D-SACK for already forgotten data... Do dumb counting. */
-		if (!after(end_seq_0, prior_snd_una))
-			tp->undo_retrans--;
-
-	} else if (num_sacks > 1) {
-		u32 end_seq_1 = ntohl(get_unaligned(&sp[1].end_seq));
-		u32 start_seq_1 = ntohl(get_unaligned(&sp[1].start_seq));
-
-		if (!after(end_seq_0, end_seq_1) &&
-		    !before(start_seq_0, start_seq_1)) {
-			flag |= FLAG_DSACKING_ACK;
-			tcp_dsack_seen(tp);
-			NET_INC_STATS_BH(LINUX_MIB_TCPDSACKOFORECV);
-			if (!tcp_is_sackblock_valid(tp, start_seq_0, end_seq_0)) {
-				/* FIXME, reordering check like in the other place! */
-				NET_INC_STATS_BH(LINUX_MIB_TCPSACKDISCARD);
-				return flag;
-			}
-		}
+	if (before(next_dup->start_seq, skip_to_seq)) {
+		skb = tcp_sacktag_skip(skb, sk, next_dup->start_seq);
+		tcp_sacktag_walk(skb, sk, NULL,
+				 next_dup->start_seq, next_dup->end_seq,
+				 1, fack_count, reord, flag);
 	}
 
-	if ((flag & FLAG_DSACKING_ACK) && after(end_seq_0, prior_snd_una)) {
-		skb = tcp_write_queue_find(sk, start_seq_0, TCP_WQ_SACKED);
-		if (skb != NULL)
-			tcp_sacktag_walk(skb, sk, start_seq_0, end_seq_0, 1, reord, &flag, TCP_WQ_SACKED);
-
-		skb = tcp_write_queue_find(sk, start_seq_0, 0);
-		if (skb != NULL)
-			tcp_sacktag_walk(skb, sk, start_seq_0, end_seq_0, 1, reord, &flag, 0);
-	}
-
-	return flag;
+	return skb;
 }
 
 static int tcp_sack_cache_ok(struct tcp_sock *tp, struct tcp_sack_block *cache)
@@ -1431,7 +1420,10 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 	int used_sacks;
 	int reord = tp->packets_out;
 	int flag = 0;
+	int found_dup_sack = 0;
+	int fack_count;
 	int i, j;
+	int first_sack_index;
 
 	if (!tp->sacked_out) {
 		if (WARN_ON(tp->fackets_out))
@@ -1439,7 +1431,10 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 		tcp_highest_sack_reset(sk);
 	}
 
-	flag |= tcp_handle_dsack(sk, ack_skb, sp_wire, &reord, num_sacks, prior_snd_una);
+	found_dup_sack = tcp_check_dsack(tp, ack_skb, sp_wire,
+					 num_sacks, prior_snd_una);
+	if (found_dup_sack)
+		flag |= FLAG_DSACKING_ACK;
 
 	/* Eliminate too old ACKs, but take into
 	 * account more or less fresh ones, they can
@@ -1452,17 +1447,30 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 		goto out;
 
 	used_sacks = 0;
-	for (i = (flag & FLAG_DSACKING_ACK) ? 1 : 0; i < num_sacks; i++) {
+	first_sack_index = 0;
+	for (i = 0; i < num_sacks; i++) {
+		int dup_sack = !i && found_dup_sack;
+
 		sp[used_sacks].start_seq = ntohl(get_unaligned(&sp_wire[i].start_seq));
 		sp[used_sacks].end_seq = ntohl(get_unaligned(&sp_wire[i].end_seq));
 
-		if (!tcp_is_sackblock_valid(tp, sp[used_sacks].start_seq,
+		if (!tcp_is_sackblock_valid(tp, dup_sack,
+					    sp[used_sacks].start_seq,
 					    sp[used_sacks].end_seq)) {
-			/* Don't count olds caused by ACK reordering */
-			if ((TCP_SKB_CB(ack_skb)->ack_seq != tp->snd_una) &&
-			    !after(sp[used_sacks].end_seq, tp->snd_una))
-				continue;
-			NET_INC_STATS_BH(LINUX_MIB_TCPSACKDISCARD);
+			if (dup_sack) {
+				if (!tp->undo_marker)
+					NET_INC_STATS_BH(LINUX_MIB_TCPDSACKIGNOREDNOUNDO);
+				else
+					NET_INC_STATS_BH(LINUX_MIB_TCPDSACKIGNOREDOLD);
+			} else {
+				/* Don't count olds caused by ACK reordering */
+				if ((TCP_SKB_CB(ack_skb)->ack_seq != tp->snd_una) &&
+				    !after(sp[used_sacks].end_seq, tp->snd_una))
+					continue;
+				NET_INC_STATS_BH(LINUX_MIB_TCPSACKDISCARD);
+			}
+			if (i == 0)
+				first_sack_index = -1;
 			continue;
 		}
 
@@ -1482,11 +1490,16 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 				tmp = sp[j];
 				sp[j] = sp[j+1];
 				sp[j+1] = tmp;
+
+				/* Track where the first SACK block goes to */
+				if (j == first_sack_index)
+					first_sack_index = j+1;
 			}
 		}
 	}
 
 	skb = tcp_write_queue_head(sk);
+	fack_count = 0;
 	i = 0;
 
 	if (!tp->sacked_out) {
@@ -1503,6 +1516,11 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 	while (i < used_sacks) {
 		u32 start_seq = sp[i].start_seq;
 		u32 end_seq = sp[i].end_seq;
+		int dup_sack = (found_dup_sack && (i == first_sack_index));
+		struct tcp_sack_block *next_dup = NULL;
+
+		if (found_dup_sack && ((i + 1) == first_sack_index))
+			next_dup = &sp[i + 1];
 
 		/* Event "B" in the comment above. */
 		if (after(end_seq, tp->high_seq))
@@ -1514,36 +1532,36 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 			cache++;
 
 		/* Can skip some work by looking recv_sack_cache? */
-		if (tcp_sack_cache_ok(tp, cache) &&
+		if (tcp_sack_cache_ok(tp, cache) && !dup_sack &&
 		    after(end_seq, cache->start_seq)) {
 
 			/* Head todo? */
 			if (before(start_seq, cache->start_seq)) {
-				skb = tcp_sacktag_skip(sk, start_seq);
-				if (skb == NULL)
-					break;
-				skb = tcp_sacktag_walk(skb, sk, start_seq,
-						       cache->start_seq, 0,
-						       &reord, &flag, 0);
+				skb = tcp_sacktag_skip(skb, sk, start_seq);
+				skb = tcp_sacktag_walk(skb, sk, next_dup, start_seq,
+						       cache->start_seq, dup_sack,
+						       &fack_count, &reord, &flag);
 			}
 
 			/* Rest of the block already fully processed? */
 			if (!after(end_seq, cache->end_seq))
 				goto advance_sp;
 
+			skb = tcp_maybe_skipping_dsack(skb, sk, next_dup, cache->end_seq,
+						       &fack_count, &reord, &flag);
+
 			/* ...tail remains todo... */
 			if (tcp_highest_sack_seq(tp) == cache->end_seq) {
 				/* ...but better entrypoint exists! */
 				skb = tcp_highest_sack(sk);
 				if (skb == NULL)
 					break;
+				fack_count = tp->fackets_out;
 				cache++;
 				goto walk;
 			}
 
-			skb = tcp_sacktag_skip(sk, cache->end_seq);
-			if (skb == NULL)
-				break;
+			skb = tcp_sacktag_skip(skb, sk, cache->end_seq);
 			/* Check overlap against next cached too (past this one already) */
 			cache++;
 			continue;
@@ -1553,14 +1571,13 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 			skb = tcp_highest_sack(sk);
 			if (skb == NULL)
 				break;
+			fack_count = tp->fackets_out;
 		}
-		skb = tcp_sacktag_skip(sk, start_seq);
-		if (skb == NULL)
-			break;
+		skb = tcp_sacktag_skip(skb, sk, start_seq);
 
 walk:
-		skb = tcp_sacktag_walk(skb, sk, start_seq, end_seq,
-				       0, &reord, &flag, 0);
+		skb = tcp_sacktag_walk(skb, sk, next_dup, start_seq, end_seq,
+				       dup_sack, &fack_count, &reord, &flag);
 
 advance_sp:
 		/* SACK enhanced FRTO (RFC4138, Appendix B): Clearing correct
@@ -1657,7 +1674,6 @@ int tcp_use_frto(struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
-	struct sk_buff *notsacked;	/* Or S|R => deny basic F-RTO */
 
 	if (!sysctl_tcp_frto)
 		return 0;
@@ -1669,19 +1685,15 @@ int tcp_use_frto(struct sock *sk)
 	if (tp->retrans_out > 1)
 		return 0;
 
-	notsacked = tcp_write_queue_head(sk);
-	/* Not interested in head skb here because F-RTO is reentrable if only
-	 * head skb has been retransmitted (equals to multiple RTOs case)
-	 */
-	notsacked = tcp_write_queue_next(sk, notsacked);
-	if ((notsacked != NULL) && TCP_SKB_CB(notsacked)->sacked & TCPCB_RETRANS)
-		return 0;
-
-	tcp_for_write_queue(skb, sk, TCP_WQ_SACKED) {
+	skb = tcp_write_queue_head(sk);
+	skb = tcp_write_queue_next(sk, skb);	/* Skips head */
+	tcp_for_write_queue_from(skb, sk) {
+		if (skb == tcp_send_head(sk))
+			break;
 		if (TCP_SKB_CB(skb)->sacked&TCPCB_RETRANS)
 			return 0;
-		/* Short-circuit when past first non-SACKed skb */
-		if (after(TCP_SKB_CB(skb)->seq, TCP_SKB_CB(notsacked)->seq))
+		/* Short-circuit when first non-SACKed skb has been checked */
+		if (!(TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_ACKED))
 			break;
 	}
 	return 1;
@@ -1782,7 +1794,7 @@ static void tcp_enter_frto_loss(struct sock *sk, int allowed_segments, int flag)
 	if (tcp_is_reno(tp))
 		tcp_reset_reno_sack(tp);
 
-	tcp_for_write_queue(skb, sk, 0) {
+	tcp_for_write_queue(skb, sk) {
 		if (skb == tcp_send_head(sk))
 			break;
 
@@ -1880,16 +1892,9 @@ void tcp_enter_loss(struct sock *sk, int how)
 		tp->sacked_out = 0;
 		tp->fackets_out = 0;
 		tcp_clear_all_retrans_hints(tp);
-
-		tcp_for_write_queue(skb, sk, TCP_WQ_SACKED) {
-			/* FIXME, this could be optimized by avoiding tree
-			 * deletes
-			 */
-			tcp_write_queue_requeue(skb, sk, 0);
-		}
 	}
 
-	tcp_for_write_queue(skb, sk, 0) {
+	tcp_for_write_queue(skb, sk) {
 		if (skb == tcp_send_head(sk))
 			break;
 
@@ -1923,7 +1928,7 @@ static int tcp_check_sack_reneging(struct sock *sk)
 	 * receiver _host_ is heavily congested (or buggy).
 	 * Do processing similar to RTO timeout.
 	 */
-	if ((skb = tcp_real_queue_head(sk)) != NULL &&
+	if ((skb = tcp_write_queue_head(sk)) != NULL &&
 	    (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)) {
 		struct inet_connection_sock *icsk = inet_csk(sk);
 		NET_INC_STATS_BH(LINUX_MIB_TCPSACKRENEGING);
@@ -2122,21 +2127,6 @@ static void tcp_verify_retransmit_hint(struct tcp_sock *tp,
 		tp->retransmit_skb_hint = NULL;
 }
 
-/* Simple NewReno thing: Mark head LOST if it wasn't yet and it's below
- * high_seq, stop. That's all.
- */
-static void tcp_mark_head_lost_single(struct sock *sk)
-{
-	struct tcp_sock *tp = tcp_sk(sk);
-	struct sk_buff *skb = tcp_write_queue_head(sk);
-
-	if (!(TCP_SKB_CB(skb)->sacked & TCPCB_LOST) &&
-	    before(tp->snd_una, tp->high_seq)) {
-		TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
-		tp->lost_out += tcp_skb_pcount(skb);
-	}
-}
-
 /* Mark head of queue up as lost. With RFC3517 SACK, the packets is
  * is against sacked "cnt", otherwise it's against facked "cnt"
  */
@@ -2145,10 +2135,6 @@ static void tcp_mark_head_lost(struct sock *sk, int packets, int fast_rexmit)
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
 	int cnt;
-	unsigned int fc;
-	unsigned int fack_count_base;
-
-	fack_count_base = TCP_SKB_CB(tcp_write_queue_head(sk))->fack_count;
 
 	BUG_TRAP(packets <= tp->packets_out);
 	if (tp->lost_skb_hint) {
@@ -2159,7 +2145,7 @@ static void tcp_mark_head_lost(struct sock *sk, int packets, int fast_rexmit)
 		cnt = 0;
 	}
 
-	tcp_for_write_queue_from(skb, sk, 0) {
+	tcp_for_write_queue_from(skb, sk) {
 		if (skb == tcp_send_head(sk))
 			break;
 		/* TODO: do this better */
@@ -2167,18 +2153,9 @@ static void tcp_mark_head_lost(struct sock *sk, int packets, int fast_rexmit)
 		tp->lost_skb_hint = skb;
 		tp->lost_cnt_hint = cnt;
 
-		fc = TCP_SKB_CB(skb)->fack_count;
-		if (tcp_is_fack(tp)) {
-			cnt = fc - fack_count_base + tcp_skb_pcount(skb);
-		} else {
-			if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)
-				cnt += tcp_skb_pcount(skb);
-			/* Add SACK blocks between this and skb->prev */
-			if ((skb != tcp_write_queue_head(sk)) &&
-			    !tcp_skb_adjacent(sk, skb->prev, skb))
-				cnt += fc - TCP_SKB_CB(skb->prev)->fack_count -
-						tcp_skb_pcount(skb->prev);
-		}
+		if (tcp_is_fack(tp) ||
+		    (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
+			cnt += tcp_skb_pcount(skb);
 
 		if (((!fast_rexmit || (tp->lost_out > 0)) && (cnt > packets)) ||
 		     after(TCP_SKB_CB(skb)->end_seq, tp->high_seq))
@@ -2189,6 +2166,7 @@ static void tcp_mark_head_lost(struct sock *sk, int packets, int fast_rexmit)
 			tcp_verify_retransmit_hint(tp, skb);
 		}
 	}
+	tcp_verify_left_out(tp);
 }
 
 /* Account newly detected lost packet(s) */
@@ -2198,7 +2176,7 @@ static void tcp_update_scoreboard(struct sock *sk, int fast_rexmit)
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	if (tcp_is_reno(tp)) {
-		tcp_mark_head_lost_single(sk);
+		tcp_mark_head_lost(sk, 1, fast_rexmit);
 	} else if (tcp_is_fack(tp)) {
 		int lost = tp->fackets_out - tp->reordering;
 		if (lost <= 0)
@@ -2211,8 +2189,6 @@ static void tcp_update_scoreboard(struct sock *sk, int fast_rexmit)
 		tcp_mark_head_lost(sk, sacked_upto, fast_rexmit);
 	}
 
-	tcp_verify_left_out(tp);
-
 	/* New heuristics: it is possible only after we switched
 	 * to restart timer each time when something is ACKed.
 	 * Hence, we can detect timed out packets during fast
@@ -2224,7 +2200,7 @@ static void tcp_update_scoreboard(struct sock *sk, int fast_rexmit)
 		skb = tp->scoreboard_skb_hint ? tp->scoreboard_skb_hint
 			: tcp_write_queue_head(sk);
 
-		tcp_for_write_queue_from(skb, sk, 0) {
+		tcp_for_write_queue_from(skb, sk) {
 			if (skb == tcp_send_head(sk))
 				break;
 			if (!tcp_skb_timedout(sk, skb))
@@ -2422,7 +2398,7 @@ static int tcp_try_undo_loss(struct sock *sk)
 
 	if (tcp_may_undo(tp)) {
 		struct sk_buff *skb;
-		tcp_for_write_queue(skb, sk, 0) {
+		tcp_for_write_queue(skb, sk) {
 			if (skb == tcp_send_head(sk))
 				break;
 			TCP_SKB_CB(skb)->sacked &= ~TCPCB_LOST;
@@ -2528,8 +2504,11 @@ tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 				    (tcp_fackets_out(tp) > tp->reordering));
 	int fast_rexmit = 0;
 
-	if (WARN_ON(!tp->packets_out && tp->sacked_out))
+	/* Some technical things:
+	 * 1. Reno does not count dupacks (sacked_out) automatically. */
+	if (!tp->packets_out)
 		tp->sacked_out = 0;
+
 	if (WARN_ON(!tp->sacked_out && tp->fackets_out))
 		tp->fackets_out = 0;
 
@@ -2794,7 +2773,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p,
 	s32 seq_rtt = -1;
 	ktime_t last_ackt = net_invalid_timestamp();
 
-	while ((skb = tcp_real_queue_head(sk)) && skb != tcp_send_head(sk)) {
+	while ((skb = tcp_write_queue_head(sk)) && skb != tcp_send_head(sk)) {
 		struct tcp_skb_cb *scb = TCP_SKB_CB(skb);
 		u32 end_seq;
 		u32 acked_pcount;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 5a27e42..652c323 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1849,7 +1849,6 @@ static int tcp_v4_init_sock(struct sock *sk)
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	tcp_write_queue_init(sk);
 	skb_queue_head_init(&tp->out_of_order_queue);
 	tcp_init_xmit_timers(sk);
 	tcp_prequeue_init(tp);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index e1a0e4a..b61b768 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -426,7 +426,6 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 
 		tcp_set_ca_state(newsk, TCP_CA_Open);
 		tcp_init_xmit_timers(newsk);
-		tcp_write_queue_init(newsk);
 		skb_queue_head_init(&newtp->out_of_order_queue);
 		newtp->write_seq = treq->snt_isn + 1;
 		newtp->pushed_seq = newtp->write_seq;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 6110459..9a985b5 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1207,7 +1207,7 @@ static int tso_fragment(struct sock *sk, struct sk_buff *skb, unsigned int len,
 
 	/* Link BUFF into the send queue. */
 	skb_header_release(buff);
-	__tcp_insert_write_queue_after(skb, buff, sk, 0);
+	tcp_insert_write_queue_after(skb, buff, sk);
 
 	return 0;
 }
@@ -1344,10 +1344,10 @@ static int tcp_mtu_probe(struct sock *sk)
 	nskb->csum = 0;
 	nskb->ip_summed = skb->ip_summed;
 
-	__tcp_insert_write_queue_before(nskb, skb, sk);
+	tcp_insert_write_queue_before(nskb, skb, sk);
 
 	len = 0;
-	tcp_for_write_queue_from_safe(skb, next, sk, 0) {
+	tcp_for_write_queue_from_safe(skb, next, sk) {
 		copy = min_t(int, skb->len, probe_size - len);
 		if (nskb->ip_summed)
 			skb_copy_bits(skb, 0, skb_put(nskb, copy), copy);
@@ -1760,7 +1760,7 @@ void tcp_simple_retransmit(struct sock *sk)
 	unsigned int mss = tcp_current_mss(sk, 0);
 	int lost = 0;
 
-	tcp_for_write_queue(skb, sk, 0) {
+	tcp_for_write_queue(skb, sk) {
 		if (skb == tcp_send_head(sk))
 			break;
 		if (skb->len > mss &&
@@ -1848,7 +1848,6 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	    (skb->len < (cur_mss >> 1)) &&
 	    (tcp_write_queue_next(sk, skb) != tcp_send_head(sk)) &&
 	    (!tcp_skb_is_last(sk, skb)) &&
-	    (tcp_skb_adjacent(sk, skb, tcp_write_queue_next(sk, skb))) &&
 	    (skb_shinfo(skb)->nr_frags == 0 && skb_shinfo(tcp_write_queue_next(sk, skb))->nr_frags == 0) &&
 	    (tcp_skb_pcount(skb) == 1 && tcp_skb_pcount(tcp_write_queue_next(sk, skb)) == 1) &&
 	    (sysctl_tcp_retrans_collapse != 0))
@@ -1937,7 +1936,7 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 
 	/* First pass: retransmit lost packets. */
 	if (tp->lost_out) {
-		tcp_for_write_queue_from(skb, sk, 0) {
+		tcp_for_write_queue_from(skb, sk) {
 			__u8 sacked = TCP_SKB_CB(skb)->sacked;
 
 			if (skb == tcp_send_head(sk))
@@ -2010,7 +2009,7 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 	else
 		skb = tcp_write_queue_head(sk);
 
-	tcp_for_write_queue_from(skb, sk, 0) {
+	tcp_for_write_queue_from(skb, sk) {
 		if (skb == tcp_send_head(sk))
 			break;
 		tp->forward_skb_hint = skb;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index d576833..0ef9986 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1886,7 +1886,6 @@ static int tcp_v6_init_sock(struct sock *sk)
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	tcp_write_queue_init(sk);
 	skb_queue_head_init(&tp->out_of_order_queue);
 	tcp_init_xmit_timers(sk);
 	tcp_prequeue_init(tp);
-- 
1.5.0.6
---696243703-881831566-1197655752=:1400
Content-Type: TEXT/PLAIN; charset=us-ascii; name=commits
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.64.0712142009120.1400@kivilampi-30.cs.helsinki.fi>
Content-Description: 
Content-Disposition: attachment; filename=commits

ZTU5NWNlMmY5NWE0ZjZlNzU2Y2Q1ZThmNmZjODk2ZmIyZTYxZGEyNSBSZXZl
cnQgcmVjZW50IFRDUCB3b3JrDQo2MDZjMGQwYTkzZDc2NTE1ZjA5NzYwNTE1
NGE1YjM3NGZlYTYzMDJiIFtUQ1BdOiBJbmNsdWRlIF9fdGNwX3Jlc2V0X2Zh
Y2tfY291bnRzIHRvIG5vbi1fXyB2ZXJzaW9uDQpjNTQ0YWZiMDk5NzE0MGI2
NWZhOWJmNzdhYmI2OTQ5ZjJmMWNlNjFkIFtUQ1BdOiBQdXNoIGZhY2tfY291
bnQgY2FsY3VsYXRpb24gZGVlcGVyIGludG8gZnVuY3Rpb25zDQpjODk2Mjgw
OTc4ODllYmM3YzhlYWM3MTAwMDRmMTVhNjk0ODRlYmVkIFtUQ1BdOiBmYWNr
X2NvdW50cyBtb3JlIGZpeGVzICh0aGUgcHJldmlvdXMgb25lcyB3ZXJlIGlu
Y29tcGxldGUpDQo2YzlkMDViZGNkYTRmZTNmYmJlMTA1M2IzOWUwYzk2OTc4
MWY3MTk2IFtQQVRDSF0gW1RDUF06IEZpeCBmYWNrX2NvdW50IG1pc2NvdW50
aW5ncyAobXVsdGlwbGUgcGxhY2VzKQ0KODExNTYwYjAzNDUzMGY3ZWY2Yjgw
Y2RlNmMwOTcxNTE3YmE5ZTkyMCBbVENQXTogQmluZCBmYWNrZXRzX291dCBz
dGF0ZSB0byBoaWdoZXN0X3NhY2sgbW9yZSB0aWdodGx5DQo4MjIwN2Y2NTI1
YTYwYzZjNDhiMDBjNjM1MzJlZmUxODM3NTRhMDExIFtUQ1BdOiBNYWtlIGlu
dmFyaWFudCBjaGVjayBjb21wbGFpbiBhYm91dCBpbnZhbGlkIHNhY2tlZF9v
dXQNCjUwMjZjMjI5OTZmMzYzN2ZjZTIyZjFjN2ViYmRlM2MzYmFlZmZlYzEg
W1RDUF06IENyZWF0ZSB0Y3BfbWFya19oZWFkX2xvc3Rfc2luZ2xlIGZvciBO
ZXdSZW5vDQpkN2I5YTY0NDliYzBlMDViNWE4MGFjMDk0OGJmNzIxY2UxNDc5
YzRmIFtUQ1BdOiBGaXggY29weS1wYXN0ZSBlcnJvciBpbiB0Y3BfcmVzZXRf
ZmFja19jb3VudHMNCjNkZjYzMGI2MjEzMzQ5MTU0ZGEzMmIwYjE1ZWM4MWQz
OTg1ODU0MTMgW1RDUF06IEZpeCBjcmFzaCBpbiB0Y3BfYWR2YW5jZV9zZW5k
X2hlYWQNCmQ3MmQ0YzJiZmJlOTA3NTk5NDdkYWUzZjhlMDE2OWU1ZGNkNzZi
MGEgW1RDUF06IFNwbGl0IHdyaXRlIHF1ZXVlIGludG8gdHdvIHBhcnRzIChT
QUNLZWQgYW5kIG5vdCkNCjZhMzUwNmNlNjQyMjczYWYyMDU3OTUzMTAxNDQy
ZDY1YjFmMGZkNjAgW1RDUF06IEludHJvZHVjZSB0Y3Bfc2tiX2FkamFjZW50
IHRvIGRldGVjdCBob2xlcyBpbiB3cQ0KNGNhNWJjNDg2ODE1Y2UxNTkxNWE5
NWY2Mjg5NTllMWQyMWYyNTI4YSBbVENQXTogSW50cm9kdWNlIHRjcF9yZWFs
X3F1ZXVlX2hlYWQoc2spDQowMDEwZTA0NTJmZmUyYzc3MjE1NjcyNjA2YzZl
MTQ2N2RkODEwMzllIFtUQ1BdOiBNb3ZlIHRjcF9hZHZhbmNlX2hpZ2hlc3Rf
c2FjayBjYWxsIGVhcmx5IGVub3VnaA0KODUxMWQ3ZjI3MDAxMGI0MWE0MzQ5
Yzc2MjkwODk2MjYwNjhlNjQ0ZCBbVENQXTogTW92ZSB0Y3Bfd3JpdGVfcXVl
dWVfZW1wdHkNCjk5YjEyYzE1MzA3OTZlOTUzODMwOTlhZTQ5ZTE5NzJhNWU0
MmYxMGIgW1RDUF06IE1vdmUgdGNwX2NoZWNrX2RzYWNrDQoxZjMzODkyOGM2
N2UyODFiMjk1ZDU2NmFkNGVjMzdkYmQxYjI1MjRmIFtUQ1BdOiBVc2UgcGVy
IHNrYiBmYWNrIGNvdW50IGluc3RlYWQgb2YgZnVuY3Rpb24gYXJndW1lbnQN
CmQ4Y2U3MTYxZWM0M2RjMjNkMzNjYzQzODM3OTQ1ZmQ5MjNlODRkYjAgW1RD
UF06IEFkZGVkIHF1ZXVlIHBhcmFtZXRlciB0byBfZm9yX3dyaXRlX3F1ZXVl
IGhlbHBlcnMNCmZkY2Y2N2YzMGM4NWVkMGFjMmRiYzMxYjgzM2IyYzYyMjJj
NjRiOWMgW1RDUF06IFN0b3JlIHJldHJhbnNtaXQgcXVldWUgcGFja2V0cyBp
biBSQiB0cmVlLg0KMzA1ZDdkZDVkZDlhYTVjNTczZWMxNzJiYjQ4NjE4OGVk
ZTk0NDUzYSBbVENQXTogSW50cm9kdWNlIHBlciBza2IgZmFja19jb3VudHMg
dG8gcmV0cmFuc21pdCBxdWV1ZQ0K

---696243703-881831566-1197655752=:1400--
