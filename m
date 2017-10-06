From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 7/7] tcp: implement rb-tree based retransmit queue
Date: Thu,  5 Oct 2017 22:21:27 -0700
Message-ID: <20171006052127.19913-8-edumazet@google.com>
References: <20171006052127.19913-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:57153 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751833AbdJFFVu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 01:21:50 -0400
Received: by mail-pg0-f45.google.com with SMTP id m18so3317142pgd.13
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 22:21:50 -0700 (PDT)
In-Reply-To: <20171006052127.19913-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using a linear list to store all skbs in write queue has been okay
for quite a while : O(N) is not too bad when N < 500.

Things get messy when N is the order of 100,000 : Modern TCP stacks
want 10Gbit+ of throughput even with 200 ms RTT flows.

40 ns per cache line miss means a full scan can use 4 ms,
blowing away CPU caches.

SACK processing often can use various hints to avoid parsing
whole retransmit queue. But with high packet losses and/or high
reordering, hints no longer work.

Sender has to process thousands of unfriendly SACK, accumulating
a huge socket backlog, burning a cpu and massively dropping packets.

Using an rb-tree for retransmit queue has been avoided for years
because it added complexity and overhead, but now is the time
to be more resistant and say no to quadratic behavior.

1) RTX queue is no longer part of the write queue : already sent skbs
are stored in one rb-tree.

2) Since reaching the head of write queue no longer needs
sk->sk_send_head, we added an union of sk_send_head and tcp_rtx_queue

Tested:

 On receiver :
 netem on ingress : delay 150ms 200us loss 1
 GRO disabled to force stress and SACK storms.

for f in `seq 1 10`
do
 ./netperf -H lpaa6 -l30 -- -K bbr -o THROUGHPUT|tail -1
done | awk '{print $0} {sum += $0} END {printf "%7u\n",sum}'

Before patch :

323.87
351.48
339.59
338.62
306.72
204.07
304.93
291.88
202.47
176.88
   2840

After patch:

1700.83
2207.98
2070.17
1544.26
2114.76
2124.89
1693.14
1080.91
2216.82
1299.94
  18053

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sock.h    |   7 ++-
 include/net/tcp.h     |  89 ++++++++++++++++----------------
 net/ipv4/tcp.c        |  41 +++++++++++----
 net/ipv4/tcp_input.c  | 133 +++++++++++++++++++++++++-----------------------
 net/ipv4/tcp_ipv4.c   |   2 +-
 net/ipv4/tcp_output.c | 137 +++++++++++++++++++++++++++-----------------------
 net/ipv4/tcp_timer.c  |  24 +++++----
 7 files changed, 245 insertions(+), 188 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index a6b9a8d1a6df3f72df8f1aac0f577257fa6452d0..4827094f1db44fce1c044c6fb6a4a98f8dbd4b22 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -60,7 +60,7 @@
 #include <linux/sched.h>
 #include <linux/wait.h>
 #include <linux/cgroup-defs.h>
-
+#include <linux/rbtree.h>
 #include <linux/filter.h>
 #include <linux/rculist_nulls.h>
 #include <linux/poll.h>
@@ -397,7 +397,10 @@ struct sock {
 	int			sk_wmem_queued;
 	refcount_t		sk_wmem_alloc;
 	unsigned long		sk_tsq_flags;
-	struct sk_buff		*sk_send_head;
+	union {
+		struct sk_buff	*sk_send_head;
+		struct rb_root	tcp_rtx_queue;
+	};
 	struct sk_buff_head	sk_write_queue;
 	__s32			sk_peek_off;
 	int			sk_write_pending;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 744559b727847db79b9751e6c6bef57e83c141f8..5a95e5886b55e03e4a8bfeac3506c657a4f97dde 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -551,7 +551,13 @@ void tcp_xmit_retransmit_queue(struct sock *);
 void tcp_simple_retransmit(struct sock *);
 void tcp_enter_recovery(struct sock *sk, bool ece_ack);
 int tcp_trim_head(struct sock *, struct sk_buff *, u32);
-int tcp_fragment(struct sock *, struct sk_buff *, u32, unsigned int, gfp_t);
+enum tcp_queue {
+	TCP_FRAG_IN_WRITE_QUEUE,
+	TCP_FRAG_IN_RTX_QUEUE,
+};
+int tcp_fragment(struct sock *sk, enum tcp_queue tcp_queue,
+		 struct sk_buff *skb, u32 len,
+		 unsigned int mss_now, gfp_t gfp);
 
 void tcp_send_probe0(struct sock *);
 void tcp_send_partial(struct sock *);
@@ -1608,6 +1614,11 @@ static inline void tcp_skb_tsorted_anchor_cleanup(struct sk_buff *skb)
 
 void tcp_write_queue_purge(struct sock *sk);
 
+static inline struct sk_buff *tcp_rtx_queue_head(const struct sock *sk)
+{
+	return skb_rb_first(&sk->tcp_rtx_queue);
+}
+
 static inline struct sk_buff *tcp_write_queue_head(const struct sock *sk)
 {
 	return skb_peek(&sk->sk_write_queue);
@@ -1630,18 +1641,12 @@ static inline struct sk_buff *tcp_write_queue_prev(const struct sock *sk,
 	return skb_queue_prev(&sk->sk_write_queue, skb);
 }
 
-#define tcp_for_write_queue(skb, sk)					\
-	skb_queue_walk(&(sk)->sk_write_queue, skb)
-
-#define tcp_for_write_queue_from(skb, sk)				\
-	skb_queue_walk_from(&(sk)->sk_write_queue, skb)
-
 #define tcp_for_write_queue_from_safe(skb, tmp, sk)			\
 	skb_queue_walk_from_safe(&(sk)->sk_write_queue, skb, tmp)
 
 static inline struct sk_buff *tcp_send_head(const struct sock *sk)
 {
-	return sk->sk_send_head;
+	return skb_peek(&sk->sk_write_queue);
 }
 
 static inline bool tcp_skb_is_last(const struct sock *sk,
@@ -1650,29 +1655,30 @@ static inline bool tcp_skb_is_last(const struct sock *sk,
 	return skb_queue_is_last(&sk->sk_write_queue, skb);
 }
 
-static inline void tcp_advance_send_head(struct sock *sk, const struct sk_buff *skb)
+static inline bool tcp_write_queue_empty(const struct sock *sk)
 {
-	if (tcp_skb_is_last(sk, skb))
-		sk->sk_send_head = NULL;
-	else
-		sk->sk_send_head = tcp_write_queue_next(sk, skb);
+	return skb_queue_empty(&sk->sk_write_queue);
+}
+
+static inline bool tcp_rtx_queue_empty(const struct sock *sk)
+{
+	return RB_EMPTY_ROOT(&sk->tcp_rtx_queue);
+}
+
+static inline bool tcp_rtx_and_write_queues_empty(const struct sock *sk)
+{
+	return tcp_rtx_queue_empty(sk) && tcp_write_queue_empty(sk);
 }
 
 static inline void tcp_check_send_head(struct sock *sk, struct sk_buff *skb_unlinked)
 {
-	if (sk->sk_send_head == skb_unlinked) {
-		sk->sk_send_head = NULL;
+	if (tcp_write_queue_empty(sk))
 		tcp_chrono_stop(sk, TCP_CHRONO_BUSY);
-	}
+
 	if (tcp_sk(sk)->highest_sack == skb_unlinked)
 		tcp_sk(sk)->highest_sack = NULL;
 }
 
-static inline void tcp_init_send_head(struct sock *sk)
-{
-	sk->sk_send_head = NULL;
-}
-
 static inline void __tcp_add_write_queue_tail(struct sock *sk, struct sk_buff *skb)
 {
 	__skb_queue_tail(&sk->sk_write_queue, skb);
@@ -1683,8 +1689,7 @@ static inline void tcp_add_write_queue_tail(struct sock *sk, struct sk_buff *skb
 	__tcp_add_write_queue_tail(sk, skb);
 
 	/* Queue it, remembering where we must start sending. */
-	if (sk->sk_send_head == NULL) {
-		sk->sk_send_head = skb;
+	if (sk->sk_write_queue.next == skb) {
 		tcp_chrono_start(sk, TCP_CHRONO_BUSY);
 
 		if (tcp_sk(sk)->highest_sack == NULL)
@@ -1697,35 +1702,32 @@ static inline void __tcp_add_write_queue_head(struct sock *sk, struct sk_buff *s
 	__skb_queue_head(&sk->sk_write_queue, skb);
 }
 
-/* Insert buff after skb on the write queue of sk.  */
-static inline void tcp_insert_write_queue_after(struct sk_buff *skb,
-						struct sk_buff *buff,
-						struct sock *sk)
-{
-	__skb_queue_after(&sk->sk_write_queue, skb, buff);
-}
-
 /* Insert new before skb on the write queue of sk.  */
 static inline void tcp_insert_write_queue_before(struct sk_buff *new,
 						  struct sk_buff *skb,
 						  struct sock *sk)
 {
 	__skb_queue_before(&sk->sk_write_queue, skb, new);
-
-	if (sk->sk_send_head == skb)
-		sk->sk_send_head = new;
 }
 
 static inline void tcp_unlink_write_queue(struct sk_buff *skb, struct sock *sk)
 {
-	list_del(&skb->tcp_tsorted_anchor);
-	tcp_skb_tsorted_anchor_cleanup(skb);
 	__skb_unlink(skb, &sk->sk_write_queue);
 }
 
-static inline bool tcp_write_queue_empty(struct sock *sk)
+void tcp_rbtree_insert(struct rb_root *root, struct sk_buff *skb);
+
+static inline void tcp_rtx_queue_unlink(struct sk_buff *skb, struct sock *sk)
 {
-	return skb_queue_empty(&sk->sk_write_queue);
+	tcp_skb_tsorted_anchor_cleanup(skb);
+	rb_erase(&skb->rbnode, &sk->tcp_rtx_queue);
+}
+
+static inline void tcp_rtx_queue_unlink_and_free(struct sk_buff *skb, struct sock *sk)
+{
+	list_del(&skb->tcp_tsorted_anchor);
+	tcp_rtx_queue_unlink(skb, sk);
+	sk_wmem_free_skb(sk, skb);
 }
 
 static inline void tcp_push_pending_frames(struct sock *sk)
@@ -1754,8 +1756,9 @@ static inline u32 tcp_highest_sack_seq(struct tcp_sock *tp)
 
 static inline void tcp_advance_highest_sack(struct sock *sk, struct sk_buff *skb)
 {
-	tcp_sk(sk)->highest_sack = tcp_skb_is_last(sk, skb) ? NULL :
-						tcp_write_queue_next(sk, skb);
+	struct sk_buff *next = skb_rb_next(skb);
+
+	tcp_sk(sk)->highest_sack = next ?: tcp_send_head(sk);
 }
 
 static inline struct sk_buff *tcp_highest_sack(struct sock *sk)
@@ -1765,7 +1768,9 @@ static inline struct sk_buff *tcp_highest_sack(struct sock *sk)
 
 static inline void tcp_highest_sack_reset(struct sock *sk)
 {
-	tcp_sk(sk)->highest_sack = tcp_write_queue_head(sk);
+	struct sk_buff *skb = tcp_rtx_queue_head(sk);
+
+	tcp_sk(sk)->highest_sack = skb ?: tcp_send_head(sk);
 }
 
 /* Called when old skb is about to be deleted (to be combined with new skb) */
@@ -1935,7 +1940,7 @@ extern void tcp_rack_reo_timeout(struct sock *sk);
 /* At how many usecs into the future should the RTO fire? */
 static inline s64 tcp_rto_delta_us(const struct sock *sk)
 {
-	const struct sk_buff *skb = tcp_write_queue_head(sk);
+	const struct sk_buff *skb = tcp_rtx_queue_head(sk);
 	u32 rto = inet_csk(sk)->icsk_rto;
 	u64 rto_time_stamp_us = skb->skb_mstamp + jiffies_to_usecs(rto);
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index b8d379c8093661ccc4ef7fb82fa92828ab5f6918..3b34850d361fd20e59a42d56d398aea26bb8ecda 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -413,6 +413,7 @@ void tcp_init_sock(struct sock *sk)
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	tp->out_of_order_queue = RB_ROOT;
+	sk->tcp_rtx_queue = RB_ROOT;
 	tcp_init_xmit_timers(sk);
 	INIT_LIST_HEAD(&tp->tsq_node);
 	INIT_LIST_HEAD(&tp->tsorted_sent_queue);
@@ -701,10 +702,9 @@ static void tcp_push(struct sock *sk, int flags, int mss_now,
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
 
-	if (!tcp_send_head(sk))
-		return;
-
 	skb = tcp_write_queue_tail(sk);
+	if (!skb)
+		return;
 	if (!(flags & MSG_MORE) || forced_push(tp))
 		tcp_mark_push(tp, skb);
 
@@ -964,14 +964,14 @@ ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
 		int copy, i;
 		bool can_coalesce;
 
-		if (!tcp_send_head(sk) || (copy = size_goal - skb->len) <= 0 ||
+		if (!skb || (copy = size_goal - skb->len) <= 0 ||
 		    !tcp_skb_can_collapse_to(skb)) {
 new_segment:
 			if (!sk_stream_memory_free(sk))
 				goto wait_for_sndbuf;
 
 			skb = sk_stream_alloc_skb(sk, 0, sk->sk_allocation,
-						  skb_queue_empty(&sk->sk_write_queue));
+					tcp_rtx_and_write_queues_empty(sk));
 			if (!skb)
 				goto wait_for_memory;
 
@@ -1199,7 +1199,7 @@ int tcp_sendmsg_locked(struct sock *sk, struct msghdr *msg, size_t size)
 			goto out_err;
 		}
 
-		skb = tcp_send_head(sk) ? tcp_write_queue_tail(sk) : NULL;
+		skb = tcp_write_queue_tail(sk);
 		uarg = sock_zerocopy_realloc(sk, size, skb_zcopy(skb));
 		if (!uarg) {
 			err = -ENOBUFS;
@@ -1275,7 +1275,7 @@ int tcp_sendmsg_locked(struct sock *sk, struct msghdr *msg, size_t size)
 		int max = size_goal;
 
 		skb = tcp_write_queue_tail(sk);
-		if (tcp_send_head(sk)) {
+		if (skb) {
 			if (skb->ip_summed == CHECKSUM_NONE)
 				max = mss_now;
 			copy = max - skb->len;
@@ -1295,7 +1295,7 @@ int tcp_sendmsg_locked(struct sock *sk, struct msghdr *msg, size_t size)
 				process_backlog = false;
 				goto restart;
 			}
-			first_skb = skb_queue_empty(&sk->sk_write_queue);
+			first_skb = tcp_rtx_and_write_queues_empty(sk);
 			skb = sk_stream_alloc_skb(sk,
 						  select_size(sk, sg, first_skb),
 						  sk->sk_allocation,
@@ -1521,6 +1521,13 @@ static int tcp_peek_sndq(struct sock *sk, struct msghdr *msg, int len)
 
 	/* XXX -- need to support SO_PEEK_OFF */
 
+	skb_rbtree_walk(skb, &sk->tcp_rtx_queue) {
+		err = skb_copy_datagram_msg(skb, 0, msg, skb->len);
+		if (err)
+			return err;
+		copied += skb->len;
+	}
+
 	skb_queue_walk(&sk->sk_write_queue, skb) {
 		err = skb_copy_datagram_msg(skb, 0, msg, skb->len);
 		if (err)
@@ -2320,6 +2327,22 @@ static inline bool tcp_need_reset(int state)
 		TCPF_FIN_WAIT2 | TCPF_SYN_RECV);
 }
 
+static void tcp_rtx_queue_purge(struct sock *sk)
+{
+	struct rb_node *p = rb_first(&sk->tcp_rtx_queue);
+
+	while (p) {
+		struct sk_buff *skb = rb_to_skb(p);
+
+		p = rb_next(p);
+		/* Since we are deleting whole queue, no need to
+		 * list_del(&skb->tcp_tsorted_anchor)
+		 */
+		tcp_rtx_queue_unlink(skb, sk);
+		sk_wmem_free_skb(sk, skb);
+	}
+}
+
 void tcp_write_queue_purge(struct sock *sk)
 {
 	struct sk_buff *skb;
@@ -2329,6 +2352,7 @@ void tcp_write_queue_purge(struct sock *sk)
 		tcp_skb_tsorted_anchor_cleanup(skb);
 		sk_wmem_free_skb(sk, skb);
 	}
+	tcp_rtx_queue_purge(sk);
 	INIT_LIST_HEAD(&tcp_sk(sk)->tsorted_sent_queue);
 	sk_mem_reclaim(sk);
 	tcp_clear_all_retrans_hints(tcp_sk(sk));
@@ -2392,7 +2416,6 @@ int tcp_disconnect(struct sock *sk, int flags)
 	 * issue in __tcp_select_window()
 	 */
 	icsk->icsk_ack.rcv_mss = TCP_MIN_MSS;
-	tcp_init_send_head(sk);
 	memset(&tp->rx_opt, 0, sizeof(tp->rx_opt));
 	__sk_dst_reset(sk);
 	dst_release(sk->sk_rx_dst);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 72c4732ae2da122a878e4673ce56812055de1972..d0682ce2a5d67852ce52063f12c0506324aab984 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1142,6 +1142,7 @@ struct tcp_sacktag_state {
 	u64	last_sackt;
 	struct rate_sample *rate;
 	int	flag;
+	unsigned int mss_now;
 };
 
 /* Check if skb is fully within the SACK block. In presence of GSO skbs,
@@ -1191,7 +1192,8 @@ static int tcp_match_skb_to_sack(struct sock *sk, struct sk_buff *skb,
 		if (pkt_len >= skb->len && !in_sack)
 			return 0;
 
-		err = tcp_fragment(sk, skb, pkt_len, mss, GFP_ATOMIC);
+		err = tcp_fragment(sk, TCP_FRAG_IN_RTX_QUEUE, skb,
+				   pkt_len, mss, GFP_ATOMIC);
 		if (err < 0)
 			return err;
 	}
@@ -1363,8 +1365,7 @@ static bool tcp_shifted_skb(struct sock *sk, struct sk_buff *prev,
 	if (unlikely(TCP_SKB_CB(prev)->tx.delivered_mstamp))
 		TCP_SKB_CB(prev)->tx.delivered_mstamp = 0;
 
-	tcp_unlink_write_queue(skb, sk);
-	sk_wmem_free_skb(sk, skb);
+	tcp_rtx_queue_unlink_and_free(skb, sk);
 
 	NET_INC_STATS(sock_net(sk), LINUX_MIB_SACKMERGED);
 
@@ -1414,9 +1415,9 @@ static struct sk_buff *tcp_shift_skb_data(struct sock *sk, struct sk_buff *skb,
 		goto fallback;
 
 	/* Can only happen with delayed DSACK + discard craziness */
-	if (unlikely(skb == tcp_write_queue_head(sk)))
+	prev = skb_rb_prev(skb);
+	if (!prev)
 		goto fallback;
-	prev = tcp_write_queue_prev(sk, skb);
 
 	if ((TCP_SKB_CB(prev)->sacked & TCPCB_TAGBITS) != TCPCB_SACKED_ACKED)
 		goto fallback;
@@ -1501,12 +1502,11 @@ static struct sk_buff *tcp_shift_skb_data(struct sock *sk, struct sk_buff *skb,
 	/* Hole filled allows collapsing with the next as well, this is very
 	 * useful when hole on every nth skb pattern happens
 	 */
-	if (prev == tcp_write_queue_tail(sk))
+	skb = skb_rb_next(prev);
+	if (!skb)
 		goto out;
-	skb = tcp_write_queue_next(sk, prev);
 
 	if (!skb_can_shift(skb) ||
-	    (skb == tcp_send_head(sk)) ||
 	    ((TCP_SKB_CB(skb)->sacked & TCPCB_TAGBITS) != TCPCB_SACKED_ACKED) ||
 	    (mss != tcp_skb_seglen(skb)))
 		goto out;
@@ -1539,13 +1539,10 @@ static struct sk_buff *tcp_sacktag_walk(struct sk_buff *skb, struct sock *sk,
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *tmp;
 
-	tcp_for_write_queue_from(skb, sk) {
+	skb_rbtree_walk_from(skb) {
 		int in_sack = 0;
 		bool dup_sack = dup_sack_in;
 
-		if (skb == tcp_send_head(sk))
-			break;
-
 		/* queue is in-order => we can short-circuit the walk early */
 		if (!before(TCP_SKB_CB(skb)->seq, end_seq))
 			break;
@@ -1607,23 +1604,44 @@ static struct sk_buff *tcp_sacktag_walk(struct sk_buff *skb, struct sock *sk,
 	return skb;
 }
 
-/* Avoid all extra work that is being done by sacktag while walking in
- * a normal way
- */
+static struct sk_buff *tcp_sacktag_bsearch(struct sock *sk,
+					   struct tcp_sacktag_state *state,
+					   u32 seq)
+{
+	struct rb_node *parent, **p = &sk->tcp_rtx_queue.rb_node;
+	struct sk_buff *skb;
+	int unack_bytes;
+
+	while (*p) {
+		parent = *p;
+		skb = rb_to_skb(parent);
+		if (before(seq, TCP_SKB_CB(skb)->seq)) {
+			p = &parent->rb_left;
+			continue;
+		}
+		if (!before(seq, TCP_SKB_CB(skb)->end_seq)) {
+			p = &parent->rb_right;
+			continue;
+		}
+
+		state->fack_count = 0;
+		unack_bytes = TCP_SKB_CB(skb)->seq - tcp_sk(sk)->snd_una;
+		if (state->mss_now && unack_bytes > 0)
+			state->fack_count = unack_bytes / state->mss_now;
+
+		return skb;
+	}
+	return NULL;
+}
+
 static struct sk_buff *tcp_sacktag_skip(struct sk_buff *skb, struct sock *sk,
 					struct tcp_sacktag_state *state,
 					u32 skip_to_seq)
 {
-	tcp_for_write_queue_from(skb, sk) {
-		if (skb == tcp_send_head(sk))
-			break;
-
-		if (after(TCP_SKB_CB(skb)->end_seq, skip_to_seq))
-			break;
+	if (skb && after(TCP_SKB_CB(skb)->seq, skip_to_seq))
+		return skb;
 
-		state->fack_count += tcp_skb_pcount(skb);
-	}
-	return skb;
+	return tcp_sacktag_bsearch(sk, state, skip_to_seq);
 }
 
 static struct sk_buff *tcp_maybe_skipping_dsack(struct sk_buff *skb,
@@ -1745,8 +1763,9 @@ tcp_sacktag_write_queue(struct sock *sk, const struct sk_buff *ack_skb,
 		}
 	}
 
-	skb = tcp_write_queue_head(sk);
+	state->mss_now = tcp_current_mss(sk);
 	state->fack_count = 0;
+	skb = NULL;
 	i = 0;
 
 	if (!tp->sacked_out) {
@@ -1970,7 +1989,7 @@ void tcp_enter_loss(struct sock *sk)
 	if (tcp_is_reno(tp))
 		tcp_reset_reno_sack(tp);
 
-	skb = tcp_write_queue_head(sk);
+	skb = tcp_rtx_queue_head(sk);
 	is_reneg = skb && (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED);
 	if (is_reneg) {
 		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPSACKRENEGING);
@@ -1979,10 +1998,7 @@ void tcp_enter_loss(struct sock *sk)
 	}
 	tcp_clear_all_retrans_hints(tp);
 
-	tcp_for_write_queue(skb, sk) {
-		if (skb == tcp_send_head(sk))
-			break;
-
+	skb_rbtree_walk_from(skb) {
 		mark_lost = (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED) ||
 			     is_reneg);
 		if (mark_lost)
@@ -2215,13 +2231,11 @@ static void tcp_mark_head_lost(struct sock *sk, int packets, int mark_head)
 			return;
 		cnt = tp->lost_cnt_hint;
 	} else {
-		skb = tcp_write_queue_head(sk);
+		skb = tcp_rtx_queue_head(sk);
 		cnt = 0;
 	}
 
-	tcp_for_write_queue_from(skb, sk) {
-		if (skb == tcp_send_head(sk))
-			break;
+	skb_rbtree_walk_from(skb) {
 		/* TODO: do this better */
 		/* this is not the most efficient way to do this... */
 		tp->lost_skb_hint = skb;
@@ -2245,7 +2259,8 @@ static void tcp_mark_head_lost(struct sock *sk, int packets, int mark_head)
 			/* If needed, chop off the prefix to mark as lost. */
 			lost = (packets - oldcnt) * mss;
 			if (lost < skb->len &&
-			    tcp_fragment(sk, skb, lost, mss, GFP_ATOMIC) < 0)
+			    tcp_fragment(sk, TCP_FRAG_IN_RTX_QUEUE, skb,
+					 lost, mss, GFP_ATOMIC) < 0)
 				break;
 			cnt = packets;
 		}
@@ -2329,7 +2344,7 @@ static bool tcp_any_retrans_done(const struct sock *sk)
 	if (tp->retrans_out)
 		return true;
 
-	skb = tcp_write_queue_head(sk);
+	skb = tcp_rtx_queue_head(sk);
 	if (unlikely(skb && TCP_SKB_CB(skb)->sacked & TCPCB_EVER_RETRANS))
 		return true;
 
@@ -2370,9 +2385,7 @@ static void tcp_undo_cwnd_reduction(struct sock *sk, bool unmark_loss)
 	if (unmark_loss) {
 		struct sk_buff *skb;
 
-		tcp_for_write_queue(skb, sk) {
-			if (skb == tcp_send_head(sk))
-				break;
+		skb_rbtree_walk(skb, &sk->tcp_rtx_queue) {
 			TCP_SKB_CB(skb)->sacked &= ~TCPCB_LOST;
 		}
 		tp->lost_out = 0;
@@ -2617,9 +2630,7 @@ void tcp_simple_retransmit(struct sock *sk)
 	unsigned int mss = tcp_current_mss(sk);
 	u32 prior_lost = tp->lost_out;
 
-	tcp_for_write_queue(skb, sk) {
-		if (skb == tcp_send_head(sk))
-			break;
+	skb_rbtree_walk(skb, &sk->tcp_rtx_queue) {
 		if (tcp_skb_seglen(skb) > mss &&
 		    !(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)) {
 			if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS) {
@@ -2713,7 +2724,7 @@ static void tcp_process_loss(struct sock *sk, int flag, bool is_dupack,
 			 * is updated in tcp_ack()). Otherwise fall back to
 			 * the conventional recovery.
 			 */
-			if (tcp_send_head(sk) &&
+			if (!tcp_write_queue_empty(sk) &&
 			    after(tcp_wnd_end(tp), tp->snd_nxt)) {
 				*rexmit = REXMIT_NEW;
 				return;
@@ -3077,11 +3088,11 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 	struct tcp_sock *tp = tcp_sk(sk);
 	u32 prior_sacked = tp->sacked_out;
 	u32 reord = tp->packets_out;
+	struct sk_buff *skb, *next;
 	bool fully_acked = true;
 	long sack_rtt_us = -1L;
 	long seq_rtt_us = -1L;
 	long ca_rtt_us = -1L;
-	struct sk_buff *skb;
 	u32 pkts_acked = 0;
 	u32 last_in_flight = 0;
 	bool rtt_update;
@@ -3089,7 +3100,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 
 	first_ackt = 0;
 
-	while ((skb = tcp_write_queue_head(sk)) && skb != tcp_send_head(sk)) {
+	for (skb = skb_rb_first(&sk->tcp_rtx_queue); skb; skb = next) {
 		struct tcp_skb_cb *scb = TCP_SKB_CB(skb);
 		u8 sacked = scb->sacked;
 		u32 acked_pcount;
@@ -3107,8 +3118,6 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 				break;
 			fully_acked = false;
 		} else {
-			/* Speedup tcp_unlink_write_queue() and next loop */
-			prefetchw(skb->next);
 			acked_pcount = tcp_skb_pcount(skb);
 		}
 
@@ -3160,12 +3169,12 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 		if (!fully_acked)
 			break;
 
-		tcp_unlink_write_queue(skb, sk);
-		sk_wmem_free_skb(sk, skb);
+		next = skb_rb_next(skb);
 		if (unlikely(skb == tp->retransmit_skb_hint))
 			tp->retransmit_skb_hint = NULL;
 		if (unlikely(skb == tp->lost_skb_hint))
 			tp->lost_skb_hint = NULL;
+		tcp_rtx_queue_unlink_and_free(skb, sk);
 	}
 
 	if (!skb)
@@ -3257,12 +3266,14 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 
 static void tcp_ack_probe(struct sock *sk)
 {
-	const struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
+	struct sk_buff *head = tcp_send_head(sk);
+	const struct tcp_sock *tp = tcp_sk(sk);
 
 	/* Was it a usable window open? */
-
-	if (!after(TCP_SKB_CB(tcp_send_head(sk))->end_seq, tcp_wnd_end(tp))) {
+	if (!head)
+		return;
+	if (!after(TCP_SKB_CB(head)->end_seq, tcp_wnd_end(tp))) {
 		icsk->icsk_backoff = 0;
 		inet_csk_clear_xmit_timer(sk, ICSK_TIME_PROBE0);
 		/* Socket must be waked up by subsequent tcp_data_snd_check().
@@ -3382,7 +3393,7 @@ static int tcp_ack_update_window(struct sock *sk, const struct sk_buff *skb, u32
 			tp->pred_flags = 0;
 			tcp_fast_path_check(sk);
 
-			if (tcp_send_head(sk))
+			if (!tcp_write_queue_empty(sk))
 				tcp_slow_start_after_idle_check(sk);
 
 			if (nwin > tp->max_window) {
@@ -3567,8 +3578,8 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	sack_state.first_sackt = 0;
 	sack_state.rate = &rs;
 
-	/* We very likely will need to access write queue head. */
-	prefetchw(sk->sk_write_queue.next);
+	/* We very likely will need to access rtx queue. */
+	prefetch(sk->tcp_rtx_queue.rb_node);
 
 	/* If the ack is older than previous acks
 	 * then we can probably ignore it.
@@ -3682,8 +3693,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	 * being used to time the probes, and is probably far higher than
 	 * it needs to be for normal retransmission.
 	 */
-	if (tcp_send_head(sk))
-		tcp_ack_probe(sk);
+	tcp_ack_probe(sk);
 
 	if (tp->tlp_high_seq)
 		tcp_process_tlp_ack(sk, ack, flag);
@@ -4726,7 +4736,7 @@ static struct sk_buff *tcp_collapse_one(struct sock *sk, struct sk_buff *skb,
 }
 
 /* Insert skb into rb tree, ordered by TCP_SKB_CB(skb)->seq */
-static void tcp_rbtree_insert(struct rb_root *root, struct sk_buff *skb)
+void tcp_rbtree_insert(struct rb_root *root, struct sk_buff *skb)
 {
 	struct rb_node **p = &root->rb_node;
 	struct rb_node *parent = NULL;
@@ -5530,7 +5540,7 @@ static bool tcp_rcv_fastopen_synack(struct sock *sk, struct sk_buff *synack,
 				    struct tcp_fastopen_cookie *cookie)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct sk_buff *data = tp->syn_data ? tcp_write_queue_head(sk) : NULL;
+	struct sk_buff *data = tp->syn_data ? tcp_rtx_queue_head(sk) : NULL;
 	u16 mss = tp->rx_opt.mss_clamp, try_exp = 0;
 	bool syn_drop = false;
 
@@ -5565,9 +5575,8 @@ static bool tcp_rcv_fastopen_synack(struct sock *sk, struct sk_buff *synack,
 	tcp_fastopen_cache_set(sk, mss, cookie, syn_drop, try_exp);
 
 	if (data) { /* Retransmit unacked data in SYN */
-		tcp_for_write_queue_from(data, sk) {
-			if (data == tcp_send_head(sk) ||
-			    __tcp_retransmit_skb(sk, data, 1))
+		skb_rbtree_walk_from(data) {
+			if (__tcp_retransmit_skb(sk, data, 1))
 				break;
 		}
 		tcp_rearm_rto(sk);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index c7460fd90884c2f04ae135547836bcff5108fc13..5418ecf03b787a645b1b7ae32207a155f24b87b0 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -480,7 +480,7 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 					       TCP_TIMEOUT_INIT;
 		icsk->icsk_rto = inet_csk_rto_backoff(icsk, TCP_RTO_MAX);
 
-		skb = tcp_write_queue_head(sk);
+		skb = tcp_rtx_queue_head(sk);
 		BUG_ON(!skb);
 
 		tcp_mstamp_refresh(tp);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 8162e288017843fca2694c4e22b2e8981572256b..696b0a168f160a2c7242fcc1f76dfa5e071ef255 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -66,15 +66,17 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 			   int push_one, gfp_t gfp);
 
 /* Account for new data that has been sent to the network. */
-static void tcp_event_new_data_sent(struct sock *sk, const struct sk_buff *skb)
+static void tcp_event_new_data_sent(struct sock *sk, struct sk_buff *skb)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	unsigned int prior_packets = tp->packets_out;
 
-	tcp_advance_send_head(sk, skb);
 	tp->snd_nxt = TCP_SKB_CB(skb)->end_seq;
 
+	__skb_unlink(skb, &sk->sk_write_queue);
+	tcp_rbtree_insert(&sk->tcp_rtx_queue, skb);
+
 	tp->packets_out += tcp_skb_pcount(skb);
 	if (!prior_packets || icsk->icsk_pending == ICSK_TIME_LOSS_PROBE)
 		tcp_rearm_rto(sk);
@@ -1249,12 +1251,25 @@ static void tcp_skb_fragment_eor(struct sk_buff *skb, struct sk_buff *skb2)
 	TCP_SKB_CB(skb)->eor = 0;
 }
 
+/* Insert buff after skb on the write or rtx queue of sk.  */
+static void tcp_insert_write_queue_after(struct sk_buff *skb,
+					 struct sk_buff *buff,
+					 struct sock *sk,
+					 enum tcp_queue tcp_queue)
+{
+	if (tcp_queue == TCP_FRAG_IN_WRITE_QUEUE)
+		__skb_queue_after(&sk->sk_write_queue, skb, buff);
+	else
+		tcp_rbtree_insert(&sk->tcp_rtx_queue, buff);
+}
+
 /* Function to create two new TCP segments.  Shrinks the given segment
  * to the specified size and appends a new segment with the rest of the
  * packet to the list.  This won't be called frequently, I hope.
  * Remember, these are still headerless SKBs at this point.
  */
-int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len,
+int tcp_fragment(struct sock *sk, enum tcp_queue tcp_queue,
+		 struct sk_buff *skb, u32 len,
 		 unsigned int mss_now, gfp_t gfp)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -1337,7 +1352,7 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len,
 
 	/* Link BUFF into the send queue. */
 	__skb_header_release(buff);
-	tcp_insert_write_queue_after(skb, buff, sk);
+	tcp_insert_write_queue_after(skb, buff, sk, tcp_queue);
 	list_add(&buff->tcp_tsorted_anchor, &skb->tcp_tsorted_anchor);
 
 	return 0;
@@ -1625,10 +1640,10 @@ static void tcp_cwnd_validate(struct sock *sk, bool is_cwnd_limited)
 		 * is caused by insufficient sender buffer:
 		 * 1) just sent some data (see tcp_write_xmit)
 		 * 2) not cwnd limited (this else condition)
-		 * 3) no more data to send (null tcp_send_head )
+		 * 3) no more data to send (tcp_write_queue_empty())
 		 * 4) application is hitting buffer limit (SOCK_NOSPACE)
 		 */
-		if (!tcp_send_head(sk) && sk->sk_socket &&
+		if (tcp_write_queue_empty(sk) && sk->sk_socket &&
 		    test_bit(SOCK_NOSPACE, &sk->sk_socket->flags) &&
 		    (1 << sk->sk_state) & (TCPF_ESTABLISHED | TCPF_CLOSE_WAIT))
 			tcp_chrono_start(sk, TCP_CHRONO_SNDBUF_LIMITED);
@@ -1824,7 +1839,8 @@ static bool tcp_snd_wnd_test(const struct tcp_sock *tp,
  * know that all the data is in scatter-gather pages, and that the
  * packet has never been sent out before (and thus is not cloned).
  */
-static int tso_fragment(struct sock *sk, struct sk_buff *skb, unsigned int len,
+static int tso_fragment(struct sock *sk, enum tcp_queue tcp_queue,
+			struct sk_buff *skb, unsigned int len,
 			unsigned int mss_now, gfp_t gfp)
 {
 	struct sk_buff *buff;
@@ -1833,7 +1849,7 @@ static int tso_fragment(struct sock *sk, struct sk_buff *skb, unsigned int len,
 
 	/* All of a TSO frame must be composed of paged data.  */
 	if (skb->len != skb->data_len)
-		return tcp_fragment(sk, skb, len, mss_now, gfp);
+		return tcp_fragment(sk, tcp_queue, skb, len, mss_now, gfp);
 
 	buff = sk_stream_alloc_skb(sk, 0, gfp, true);
 	if (unlikely(!buff))
@@ -1869,7 +1885,7 @@ static int tso_fragment(struct sock *sk, struct sk_buff *skb, unsigned int len,
 
 	/* Link BUFF into the send queue. */
 	__skb_header_release(buff);
-	tcp_insert_write_queue_after(skb, buff, sk);
+	tcp_insert_write_queue_after(skb, buff, sk, tcp_queue);
 
 	return 0;
 }
@@ -1939,8 +1955,10 @@ static bool tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb,
 			goto send_now;
 	}
 
-	head = tcp_write_queue_head(sk);
-
+	/* TODO : use tsorted_sent_queue ? */
+	head = tcp_rtx_queue_head(sk);
+	if (!head)
+		goto send_now;
 	age = tcp_stamp_us_delta(tp->tcp_mstamp, head->skb_mstamp);
 	/* If next ACK is likely to come too late (half srtt), do not defer */
 	if (age < (tp->srtt_us >> 4))
@@ -2158,13 +2176,12 @@ static bool tcp_small_queue_check(struct sock *sk, const struct sk_buff *skb,
 	limit <<= factor;
 
 	if (refcount_read(&sk->sk_wmem_alloc) > limit) {
-		/* Always send the 1st or 2nd skb in write queue.
+		/* Always send skb if rtx queue is empty.
 		 * No need to wait for TX completion to call us back,
 		 * after softirq/tasklet schedule.
 		 * This helps when TX completions are delayed too much.
 		 */
-		if (skb == sk->sk_write_queue.next ||
-		    skb->prev == sk->sk_write_queue.next)
+		if (tcp_rtx_queue_empty(sk))
 			return false;
 
 		set_bit(TSQ_THROTTLED, &sk->sk_tsq_flags);
@@ -2215,7 +2232,7 @@ void tcp_chrono_stop(struct sock *sk, const enum tcp_chrono type)
 	 * it's the "most interesting" or current chrono we are
 	 * tracking and starts busy chrono if we have pending data.
 	 */
-	if (tcp_write_queue_empty(sk))
+	if (tcp_rtx_and_write_queues_empty(sk))
 		tcp_chrono_set(tp, TCP_CHRONO_UNSPEC);
 	else if (type == tp->chrono_type)
 		tcp_chrono_set(tp, TCP_CHRONO_BUSY);
@@ -2310,7 +2327,8 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 						    nonagle);
 
 		if (skb->len > limit &&
-		    unlikely(tso_fragment(sk, skb, limit, mss_now, gfp)))
+		    unlikely(tso_fragment(sk, TCP_FRAG_IN_WRITE_QUEUE,
+					  skb, limit, mss_now, gfp)))
 			break;
 
 		if (test_bit(TCP_TSQ_DEFERRED, &sk->sk_tsq_flags))
@@ -2350,7 +2368,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 		tcp_cwnd_validate(sk, is_cwnd_limited);
 		return false;
 	}
-	return !tp->packets_out && tcp_send_head(sk);
+	return !tp->packets_out && !tcp_write_queue_empty(sk);
 }
 
 bool tcp_schedule_loss_probe(struct sock *sk)
@@ -2374,7 +2392,7 @@ bool tcp_schedule_loss_probe(struct sock *sk)
 		return false;
 
 	if ((tp->snd_cwnd > tcp_packets_in_flight(tp)) &&
-	     tcp_send_head(sk))
+	     !tcp_write_queue_empty(sk))
 		return false;
 
 	/* Probe timeout is 2*rtt. Add minimum RTO to account
@@ -2427,18 +2445,14 @@ void tcp_send_loss_probe(struct sock *sk)
 	int mss = tcp_current_mss(sk);
 
 	skb = tcp_send_head(sk);
-	if (skb) {
-		if (tcp_snd_wnd_test(tp, skb, mss)) {
-			pcount = tp->packets_out;
-			tcp_write_xmit(sk, mss, TCP_NAGLE_OFF, 2, GFP_ATOMIC);
-			if (tp->packets_out > pcount)
-				goto probe_sent;
-			goto rearm_timer;
-		}
-		skb = tcp_write_queue_prev(sk, skb);
-	} else {
-		skb = tcp_write_queue_tail(sk);
+	if (skb && tcp_snd_wnd_test(tp, skb, mss)) {
+		pcount = tp->packets_out;
+		tcp_write_xmit(sk, mss, TCP_NAGLE_OFF, 2, GFP_ATOMIC);
+		if (tp->packets_out > pcount)
+			goto probe_sent;
+		goto rearm_timer;
 	}
+	skb = skb_rb_last(&sk->tcp_rtx_queue);
 
 	/* At most one outstanding TLP retransmission. */
 	if (tp->tlp_high_seq)
@@ -2456,10 +2470,11 @@ void tcp_send_loss_probe(struct sock *sk)
 		goto rearm_timer;
 
 	if ((pcount > 1) && (skb->len > (pcount - 1) * mss)) {
-		if (unlikely(tcp_fragment(sk, skb, (pcount - 1) * mss, mss,
+		if (unlikely(tcp_fragment(sk, TCP_FRAG_IN_RTX_QUEUE, skb,
+					  (pcount - 1) * mss, mss,
 					  GFP_ATOMIC)))
 			goto rearm_timer;
-		skb = tcp_write_queue_next(sk, skb);
+		skb = skb_rb_next(skb);
 	}
 
 	if (WARN_ON(!skb || !tcp_skb_pcount(skb)))
@@ -2659,7 +2674,7 @@ void tcp_skb_collapse_tstamp(struct sk_buff *skb,
 static bool tcp_collapse_retrans(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct sk_buff *next_skb = tcp_write_queue_next(sk, skb);
+	struct sk_buff *next_skb = skb_rb_next(skb);
 	int skb_size, next_skb_size;
 
 	skb_size = skb->len;
@@ -2676,8 +2691,6 @@ static bool tcp_collapse_retrans(struct sock *sk, struct sk_buff *skb)
 	}
 	tcp_highest_sack_combine(sk, next_skb, skb);
 
-	tcp_unlink_write_queue(next_skb, sk);
-
 	if (next_skb->ip_summed == CHECKSUM_PARTIAL)
 		skb->ip_summed = CHECKSUM_PARTIAL;
 
@@ -2705,7 +2718,7 @@ static bool tcp_collapse_retrans(struct sock *sk, struct sk_buff *skb)
 
 	tcp_skb_collapse_tstamp(skb, next_skb);
 
-	sk_wmem_free_skb(sk, next_skb);
+	tcp_rtx_queue_unlink_and_free(next_skb, sk);
 	return true;
 }
 
@@ -2716,8 +2729,6 @@ static bool tcp_can_collapse(const struct sock *sk, const struct sk_buff *skb)
 		return false;
 	if (skb_cloned(skb))
 		return false;
-	if (skb == tcp_send_head(sk))
-		return false;
 	/* Some heuristics for collapsing over SACK'd could be invented */
 	if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)
 		return false;
@@ -2740,7 +2751,7 @@ static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *to,
 	if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_SYN)
 		return;
 
-	tcp_for_write_queue_from_safe(skb, tmp, sk) {
+	skb_rbtree_walk_from_safe(skb, tmp) {
 		if (!tcp_can_collapse(sk, skb))
 			break;
 
@@ -2815,7 +2826,8 @@ int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb, int segs)
 
 	len = cur_mss * segs;
 	if (skb->len > len) {
-		if (tcp_fragment(sk, skb, len, cur_mss, GFP_ATOMIC))
+		if (tcp_fragment(sk, TCP_FRAG_IN_RTX_QUEUE, skb, len,
+				 cur_mss, GFP_ATOMIC))
 			return -ENOMEM; /* We'll try again later. */
 	} else {
 		if (skb_unclone(skb, GFP_ATOMIC))
@@ -2906,29 +2918,24 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb, int segs)
 void tcp_xmit_retransmit_queue(struct sock *sk)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
+	struct sk_buff *skb, *rtx_head = NULL, *hole = NULL;
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct sk_buff *skb;
-	struct sk_buff *hole = NULL;
 	u32 max_segs;
 	int mib_idx;
 
 	if (!tp->packets_out)
 		return;
 
-	if (tp->retransmit_skb_hint) {
-		skb = tp->retransmit_skb_hint;
-	} else {
-		skb = tcp_write_queue_head(sk);
+	skb = tp->retransmit_skb_hint;
+	if (!skb) {
+		rtx_head = tcp_rtx_queue_head(sk);
+		skb = rtx_head;
 	}
-
 	max_segs = tcp_tso_segs(sk, tcp_current_mss(sk));
-	tcp_for_write_queue_from(skb, sk) {
+	skb_rbtree_walk_from(skb) {
 		__u8 sacked;
 		int segs;
 
-		if (skb == tcp_send_head(sk))
-			break;
-
 		if (tcp_pacing_check(sk))
 			break;
 
@@ -2973,7 +2980,7 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 		if (tcp_in_cwnd_reduction(sk))
 			tp->prr_out += tcp_skb_pcount(skb);
 
-		if (skb == tcp_write_queue_head(sk) &&
+		if (skb == rtx_head &&
 		    icsk->icsk_pending != ICSK_TIME_REO_TIMEOUT)
 			inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
 						  inet_csk(sk)->icsk_rto,
@@ -3015,12 +3022,15 @@ void tcp_send_fin(struct sock *sk)
 	 * Note: in the latter case, FIN packet will be sent after a timeout,
 	 * as TCP stack thinks it has already been transmitted.
 	 */
-	if (tskb && (tcp_send_head(sk) || tcp_under_memory_pressure(sk))) {
+	if (!tskb && tcp_under_memory_pressure(sk))
+		tskb = skb_rb_last(&sk->tcp_rtx_queue);
+
+	if (tskb) {
 coalesce:
 		TCP_SKB_CB(tskb)->tcp_flags |= TCPHDR_FIN;
 		TCP_SKB_CB(tskb)->end_seq++;
 		tp->write_seq++;
-		if (!tcp_send_head(sk)) {
+		if (tcp_write_queue_empty(sk)) {
 			/* This means tskb was already sent.
 			 * Pretend we included the FIN on previous transmit.
 			 * We need to set tp->snd_nxt to the value it would have
@@ -3086,9 +3096,9 @@ int tcp_send_synack(struct sock *sk)
 {
 	struct sk_buff *skb;
 
-	skb = tcp_write_queue_head(sk);
+	skb = tcp_rtx_queue_head(sk);
 	if (!skb || !(TCP_SKB_CB(skb)->tcp_flags & TCPHDR_SYN)) {
-		pr_debug("%s: wrong queue state\n", __func__);
+		pr_err("%s: wrong queue state\n", __func__);
 		return -EFAULT;
 	}
 	if (!(TCP_SKB_CB(skb)->tcp_flags & TCPHDR_ACK)) {
@@ -3101,10 +3111,9 @@ int tcp_send_synack(struct sock *sk)
 			if (!nskb)
 				return -ENOMEM;
 			INIT_LIST_HEAD(&nskb->tcp_tsorted_anchor);
-			tcp_unlink_write_queue(skb, sk);
+			tcp_rtx_queue_unlink_and_free(skb, sk);
 			__skb_header_release(nskb);
-			__tcp_add_write_queue_head(sk, nskb);
-			sk_wmem_free_skb(sk, skb);
+			tcp_rbtree_insert(&sk->tcp_rtx_queue, nskb);
 			sk->sk_wmem_queued += nskb->truesize;
 			sk_mem_charge(sk, nskb->truesize);
 			skb = nskb;
@@ -3327,7 +3336,6 @@ static void tcp_connect_queue_skb(struct sock *sk, struct sk_buff *skb)
 
 	tcb->end_seq += skb->len;
 	__skb_header_release(skb);
-	__tcp_add_write_queue_tail(sk, skb);
 	sk->sk_wmem_queued += skb->truesize;
 	sk_mem_charge(sk, skb->truesize);
 	tp->write_seq = tcb->end_seq;
@@ -3405,12 +3413,13 @@ static int tcp_send_syn_data(struct sock *sk, struct sk_buff *syn)
 	TCP_SKB_CB(syn_data)->tcp_flags = TCPHDR_ACK | TCPHDR_PSH;
 	if (!err) {
 		tp->syn_data = (fo->copied > 0);
+		tcp_rbtree_insert(&sk->tcp_rtx_queue, syn_data);
 		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPORIGDATASENT);
 		goto done;
 	}
 
-	/* data was not sent, this is our new send_head */
-	sk->sk_send_head = syn_data;
+	/* data was not sent, put it in write_queue */
+	__skb_queue_tail(&sk->sk_write_queue, syn_data);
 	tp->packets_out -= tcp_skb_pcount(syn_data);
 
 fallback:
@@ -3453,6 +3462,7 @@ int tcp_connect(struct sock *sk)
 	tp->retrans_stamp = tcp_time_stamp(tp);
 	tcp_connect_queue_skb(sk, buff);
 	tcp_ecn_send_syn(sk, buff);
+	tcp_rbtree_insert(&sk->tcp_rtx_queue, buff);
 
 	/* Send off SYN; include data in Fast Open. */
 	err = tp->fastopen_req ? tcp_send_syn_data(sk, buff) :
@@ -3647,7 +3657,8 @@ int tcp_write_wakeup(struct sock *sk, int mib)
 		    skb->len > mss) {
 			seg_size = min(seg_size, mss);
 			TCP_SKB_CB(skb)->tcp_flags |= TCPHDR_PSH;
-			if (tcp_fragment(sk, skb, seg_size, mss, GFP_ATOMIC))
+			if (tcp_fragment(sk, TCP_FRAG_IN_WRITE_QUEUE,
+					 skb, seg_size, mss, GFP_ATOMIC))
 				return -1;
 		} else if (!tcp_skb_pcount(skb))
 			tcp_set_skb_tso_segs(skb, mss);
@@ -3677,7 +3688,7 @@ void tcp_send_probe0(struct sock *sk)
 
 	err = tcp_write_wakeup(sk, LINUX_MIB_TCPWINPROBE);
 
-	if (tp->packets_out || !tcp_send_head(sk)) {
+	if (tp->packets_out || tcp_write_queue_empty(sk)) {
 		/* Cancel probe timer, if it is not required. */
 		icsk->icsk_probes_out = 0;
 		icsk->icsk_backoff = 0;
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 655dd8d7f064f998f7caa323822dfffe9984ebdf..7014cc00c74c7107b8dd1ffcbdfeef8092792ba2 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -156,8 +156,13 @@ static bool retransmits_timed_out(struct sock *sk,
 		return false;
 
 	start_ts = tcp_sk(sk)->retrans_stamp;
-	if (unlikely(!start_ts))
-		start_ts = tcp_skb_timestamp(tcp_write_queue_head(sk));
+	if (unlikely(!start_ts)) {
+		struct sk_buff *head = tcp_rtx_queue_head(sk);
+
+		if (!head)
+			return false;
+		start_ts = tcp_skb_timestamp(head);
+	}
 
 	if (likely(timeout == 0)) {
 		linear_backoff_thresh = ilog2(TCP_RTO_MAX/rto_base);
@@ -304,11 +309,12 @@ static void tcp_delack_timer(unsigned long data)
 static void tcp_probe_timer(struct sock *sk)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
+	struct sk_buff *skb = tcp_send_head(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	int max_probes;
 	u32 start_ts;
 
-	if (tp->packets_out || !tcp_send_head(sk)) {
+	if (tp->packets_out || !skb) {
 		icsk->icsk_probes_out = 0;
 		return;
 	}
@@ -321,9 +327,9 @@ static void tcp_probe_timer(struct sock *sk)
 	 * corresponding system limit. We also implement similar policy when
 	 * we use RTO to probe window in tcp_retransmit_timer().
 	 */
-	start_ts = tcp_skb_timestamp(tcp_send_head(sk));
+	start_ts = tcp_skb_timestamp(skb);
 	if (!start_ts)
-		tcp_send_head(sk)->skb_mstamp = tp->tcp_mstamp;
+		skb->skb_mstamp = tp->tcp_mstamp;
 	else if (icsk->icsk_user_timeout &&
 		 (s32)(tcp_time_stamp(tp) - start_ts) >
 		 jiffies_to_msecs(icsk->icsk_user_timeout))
@@ -408,7 +414,7 @@ void tcp_retransmit_timer(struct sock *sk)
 	if (!tp->packets_out)
 		goto out;
 
-	WARN_ON(tcp_write_queue_empty(sk));
+	WARN_ON(tcp_rtx_queue_empty(sk));
 
 	tp->tlp_high_seq = 0;
 
@@ -441,7 +447,7 @@ void tcp_retransmit_timer(struct sock *sk)
 			goto out;
 		}
 		tcp_enter_loss(sk);
-		tcp_retransmit_skb(sk, tcp_write_queue_head(sk), 1);
+		tcp_retransmit_skb(sk, tcp_rtx_queue_head(sk), 1);
 		__sk_dst_reset(sk);
 		goto out_reset_timer;
 	}
@@ -473,7 +479,7 @@ void tcp_retransmit_timer(struct sock *sk)
 
 	tcp_enter_loss(sk);
 
-	if (tcp_retransmit_skb(sk, tcp_write_queue_head(sk), 1) > 0) {
+	if (tcp_retransmit_skb(sk, tcp_rtx_queue_head(sk), 1) > 0) {
 		/* Retransmission failed because of local congestion,
 		 * do not backoff.
 		 */
@@ -647,7 +653,7 @@ static void tcp_keepalive_timer (unsigned long data)
 	elapsed = keepalive_time_when(tp);
 
 	/* It is alive without keepalive 8) */
-	if (tp->packets_out || tcp_send_head(sk))
+	if (tp->packets_out || !tcp_write_queue_empty(sk))
 		goto resched;
 
 	elapsed = keepalive_time_elapsed(tp);
-- 
2.14.2.920.gcf0c67979c-goog
