From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/4]: Abstract out TCP write queue operations.
Date: Wed, 28 Feb 2007 11:48:52 -0800 (PST)
Message-ID: <20070228.114852.130845957.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48284
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751814AbXB1Tsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Feb 2007 14:48:54 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id E71F9AE426D
	for <netdev@vger.kernel.org>; Wed, 28 Feb 2007 11:48:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


commit 677417ba04ad2ce616a8199e337c8c9bb28f0692
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Tue Feb 27 14:24:25 2007 -0800

    [TCP]: Abstract out all write queue operations.
    
    This allows the write queue implementation to be changed,
    for example, to one which allows fast interval searching.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/sock.h b/include/net/sock.h
index 03684e7..c4023b7 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -710,15 +710,6 @@ static inline void sk_stream_mem_reclaim(struct sock *sk)
 		__sk_stream_mem_reclaim(sk);
 }
 
-static inline void sk_stream_writequeue_purge(struct sock *sk)
-{
-	struct sk_buff *skb;
-
-	while ((skb = __skb_dequeue(&sk->sk_write_queue)) != NULL)
-		sk_stream_free_skb(sk, skb);
-	sk_stream_mem_reclaim(sk);
-}
-
 static inline int sk_stream_rmem_schedule(struct sock *sk, struct sk_buff *skb)
 {
 	return (int)skb->truesize <= sk->sk_forward_alloc ||
@@ -1256,18 +1247,6 @@ static inline struct page *sk_stream_alloc_page(struct sock *sk)
 	return page;
 }
 
-#define sk_stream_for_retrans_queue(skb, sk)				\
-		for (skb = (sk)->sk_write_queue.next;			\
-		     (skb != (sk)->sk_send_head) &&			\
-		     (skb != (struct sk_buff *)&(sk)->sk_write_queue);	\
-		     skb = skb->next)
-
-/*from STCP for fast SACK Process*/
-#define sk_stream_for_retrans_queue_from(skb, sk)			\
-		for (; (skb != (sk)->sk_send_head) &&                   \
-		     (skb != (struct sk_buff *)&(sk)->sk_write_queue);	\
-		     skb = skb->next)
-
 /*
  *	Default write policy as shown to user space via poll/select/SIGIO
  */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index f0c9e34..571faa1 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1162,6 +1162,122 @@ static inline void		tcp_put_md5sig_pool(void)
 	put_cpu();
 }
 
+/* write queue abstraction */
+static inline void tcp_write_queue_purge(struct sock *sk)
+{
+	struct sk_buff *skb;
+
+	while ((skb = __skb_dequeue(&sk->sk_write_queue)) != NULL)
+		sk_stream_free_skb(sk, skb);
+	sk_stream_mem_reclaim(sk);
+}
+
+static inline struct sk_buff *tcp_write_queue_head(struct sock *sk)
+{
+	struct sk_buff *skb = sk->sk_write_queue.next;
+	if (skb == (struct sk_buff *) &sk->sk_write_queue)
+		return NULL;
+	return skb;
+}
+
+static inline struct sk_buff *tcp_write_queue_tail(struct sock *sk)
+{
+	struct sk_buff *skb = sk->sk_write_queue.prev;
+	if (skb == (struct sk_buff *) &sk->sk_write_queue)
+		return NULL;
+	return skb;
+}
+
+static inline struct sk_buff *tcp_write_queue_next(struct sock *sk, struct sk_buff *skb)
+{
+	return skb->next;
+}
+
+#define tcp_for_write_queue(skb, sk)					\
+		for (skb = (sk)->sk_write_queue.next;			\
+		     (skb != (sk)->sk_send_head) &&			\
+		     (skb != (struct sk_buff *)&(sk)->sk_write_queue);	\
+		     skb = skb->next)
+
+#define tcp_for_write_queue_from(skb, sk)				\
+		for (; (skb != (sk)->sk_send_head) &&                   \
+		     (skb != (struct sk_buff *)&(sk)->sk_write_queue);	\
+		     skb = skb->next)
+
+static inline struct sk_buff *tcp_send_head(struct sock *sk)
+{
+	return sk->sk_send_head;
+}
+
+static inline void tcp_advance_send_head(struct sock *sk, struct sk_buff *skb)
+{
+	sk->sk_send_head = skb->next;
+	if (sk->sk_send_head == (struct sk_buff *)&sk->sk_write_queue)
+		sk->sk_send_head = NULL;
+}
+
+static inline void tcp_check_send_head(struct sock *sk, struct sk_buff *skb_unlinked)
+{
+	if (sk->sk_send_head == skb_unlinked)
+		sk->sk_send_head = NULL;
+}
+
+static inline void tcp_init_send_head(struct sock *sk)
+{
+	sk->sk_send_head = NULL;
+}
+
+static inline void __tcp_add_write_queue_tail(struct sock *sk, struct sk_buff *skb)
+{
+	__skb_queue_tail(&sk->sk_write_queue, skb);
+}
+
+static inline void tcp_add_write_queue_tail(struct sock *sk, struct sk_buff *skb)
+{
+	__tcp_add_write_queue_tail(sk, skb);
+
+	/* Queue it, remembering where we must start sending. */
+	if (sk->sk_send_head == NULL)
+		sk->sk_send_head = skb;
+}
+
+static inline void __tcp_add_write_queue_head(struct sock *sk, struct sk_buff *skb)
+{
+	__skb_queue_head(&sk->sk_write_queue, skb);
+}
+
+/* Insert buff after skb on the write queue of sk.  */
+static inline void tcp_insert_write_queue_after(struct sk_buff *skb,
+						struct sk_buff *buff,
+						struct sock *sk)
+{
+	__skb_append(skb, buff, &sk->sk_write_queue);
+}
+
+/* Insert skb between prev and next on the write queue of sk.  */
+static inline void tcp_insert_write_queue_before(struct sk_buff *new,
+						  struct sk_buff *skb,
+						  struct sock *sk)
+{
+	__skb_insert(new, skb->prev, skb, &sk->sk_write_queue);
+}
+
+static inline void tcp_unlink_write_queue(struct sk_buff *skb, struct sock *sk)
+{
+	__skb_unlink(skb, &sk->sk_write_queue);
+}
+
+static inline int tcp_skb_is_last(const struct sock *sk,
+				  const struct sk_buff *skb)
+{
+	return skb->next == (struct sk_buff *)&sk->sk_write_queue;
+}
+
+static inline int tcp_write_queue_empty(struct sock *sk)
+{
+	return skb_queue_empty(&sk->sk_write_queue);
+}
+
 /* /proc */
 enum tcp_seq_states {
 	TCP_SEQ_STATE_LISTENING,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index ac6516c..327d1bd 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -470,10 +470,8 @@ static inline void skb_entail(struct sock *sk, struct tcp_sock *tp,
 	tcb->flags   = TCPCB_FLAG_ACK;
 	tcb->sacked  = 0;
 	skb_header_release(skb);
-	__skb_queue_tail(&sk->sk_write_queue, skb);
+	tcp_add_write_queue_tail(sk, skb);
 	sk_charge_skb(sk, skb);
-	if (!sk->sk_send_head)
-		sk->sk_send_head = skb;
 	if (tp->nonagle & TCP_NAGLE_PUSH)
 		tp->nonagle &= ~TCP_NAGLE_PUSH;
 }
@@ -491,8 +489,8 @@ static inline void tcp_mark_urg(struct tcp_sock *tp, int flags,
 static inline void tcp_push(struct sock *sk, struct tcp_sock *tp, int flags,
 			    int mss_now, int nonagle)
 {
-	if (sk->sk_send_head) {
-		struct sk_buff *skb = sk->sk_write_queue.prev;
+	if (tcp_send_head(sk)) {
+		struct sk_buff *skb = tcp_write_queue_tail(sk);
 		if (!(flags & MSG_MORE) || forced_push(tp))
 			tcp_mark_push(tp, skb);
 		tcp_mark_urg(tp, flags, skb);
@@ -526,13 +524,13 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffse
 		goto do_error;
 
 	while (psize > 0) {
-		struct sk_buff *skb = sk->sk_write_queue.prev;
+		struct sk_buff *skb = tcp_write_queue_tail(sk);
 		struct page *page = pages[poffset / PAGE_SIZE];
 		int copy, i, can_coalesce;
 		int offset = poffset % PAGE_SIZE;
 		int size = min_t(size_t, psize, PAGE_SIZE - offset);
 
-		if (!sk->sk_send_head || (copy = size_goal - skb->len) <= 0) {
+		if (!tcp_send_head(sk) || (copy = size_goal - skb->len) <= 0) {
 new_segment:
 			if (!sk_stream_memory_free(sk))
 				goto wait_for_sndbuf;
@@ -589,7 +587,7 @@ new_segment:
 		if (forced_push(tp)) {
 			tcp_mark_push(tp, skb);
 			__tcp_push_pending_frames(sk, tp, mss_now, TCP_NAGLE_PUSH);
-		} else if (skb == sk->sk_send_head)
+		} else if (skb == tcp_send_head(sk))
 			tcp_push_one(sk, mss_now);
 		continue;
 
@@ -704,9 +702,9 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		while (seglen > 0) {
 			int copy;
 
-			skb = sk->sk_write_queue.prev;
+			skb = tcp_write_queue_tail(sk);
 
-			if (!sk->sk_send_head ||
+			if (!tcp_send_head(sk) ||
 			    (copy = size_goal - skb->len) <= 0) {
 
 new_segment:
@@ -833,7 +831,7 @@ new_segment:
 			if (forced_push(tp)) {
 				tcp_mark_push(tp, skb);
 				__tcp_push_pending_frames(sk, tp, mss_now, TCP_NAGLE_PUSH);
-			} else if (skb == sk->sk_send_head)
+			} else if (skb == tcp_send_head(sk))
 				tcp_push_one(sk, mss_now);
 			continue;
 
@@ -860,9 +858,11 @@ out:
 
 do_fault:
 	if (!skb->len) {
-		if (sk->sk_send_head == skb)
-			sk->sk_send_head = NULL;
-		__skb_unlink(skb, &sk->sk_write_queue);
+		tcp_unlink_write_queue(skb, sk);
+		/* It is the one place in all of TCP, except connection
+		 * reset, where we can be unlinking the send_head.
+		 */
+		tcp_check_send_head(sk, skb);
 		sk_stream_free_skb(sk, skb);
 	}
 
@@ -1732,7 +1732,7 @@ int tcp_disconnect(struct sock *sk, int flags)
 
 	tcp_clear_xmit_timers(sk);
 	__skb_queue_purge(&sk->sk_receive_queue);
-	sk_stream_writequeue_purge(sk);
+	tcp_write_queue_purge(sk);
 	__skb_queue_purge(&tp->out_of_order_queue);
 #ifdef CONFIG_NET_DMA
 	__skb_queue_purge(&sk->sk_async_wait_queue);
@@ -1758,7 +1758,7 @@ int tcp_disconnect(struct sock *sk, int flags)
 	tcp_set_ca_state(sk, TCP_CA_Open);
 	tcp_clear_retrans(tp);
 	inet_csk_delack_init(sk);
-	sk->sk_send_head = NULL;
+	tcp_init_send_head(sk);
 	tp->rx_opt.saw_tstamp = 0;
 	tcp_sack_reset(&tp->rx_opt);
 	__sk_dst_reset(sk);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 322e43c..219255f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1044,7 +1044,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 	cached_skb = tp->fastpath_skb_hint;
 	cached_fack_count = tp->fastpath_cnt_hint;
 	if (!cached_skb) {
-		cached_skb = sk->sk_write_queue.next;
+		cached_skb = tcp_write_queue_head(sk);
 		cached_fack_count = 0;
 	}
 
@@ -1061,7 +1061,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 		if (after(end_seq, tp->high_seq))
 			flag |= FLAG_DATA_LOST;
 
-		sk_stream_for_retrans_queue_from(skb, sk) {
+		tcp_for_write_queue_from(skb, sk) {
 			int in_sack, pcount;
 			u8 sacked;
 
@@ -1213,7 +1213,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 	if (lost_retrans && icsk->icsk_ca_state == TCP_CA_Recovery) {
 		struct sk_buff *skb;
 
-		sk_stream_for_retrans_queue(skb, sk) {
+		tcp_for_write_queue(skb, sk) {
 			if (after(TCP_SKB_CB(skb)->seq, lost_retrans))
 				break;
 			if (!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una))
@@ -1266,8 +1266,8 @@ int tcp_use_frto(struct sock *sk)
 	const struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
 
-	if (!sysctl_tcp_frto || !sk->sk_send_head ||
-		after(TCP_SKB_CB(sk->sk_send_head)->end_seq,
+	if (!sysctl_tcp_frto || !tcp_send_head(sk) ||
+		after(TCP_SKB_CB(tcp_send_head(sk))->end_seq,
 		      tp->snd_una + tp->snd_wnd))
 		return 0;
 
@@ -1278,8 +1278,9 @@ int tcp_use_frto(struct sock *sk)
 	if (tp->retrans_out > 1)
 		return 0;
 
-	skb = skb_peek(&sk->sk_write_queue)->next;	/* Skips head */
-	sk_stream_for_retrans_queue_from(skb, sk) {
+	skb = tcp_write_queue_head(sk);
+	skb = tcp_write_queue_next(sk, skb);	/* Skips head */
+	tcp_for_write_queue_from(skb, sk) {
 		if (TCP_SKB_CB(skb)->sacked&TCPCB_RETRANS)
 			return 0;
 		/* Short-circuit when first non-SACKed skb has been checked */
@@ -1343,7 +1344,7 @@ void tcp_enter_frto(struct sock *sk)
 	tp->undo_marker = tp->snd_una;
 	tp->undo_retrans = 0;
 
-	skb = skb_peek(&sk->sk_write_queue);
+	skb = tcp_write_queue_head(sk);
 	if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS) {
 		TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_RETRANS;
 		tp->retrans_out -= tcp_skb_pcount(skb);
@@ -1380,7 +1381,7 @@ static void tcp_enter_frto_loss(struct sock *sk, int allowed_segments, int flag)
 	tp->fackets_out = 0;
 	tp->retrans_out = 0;
 
-	sk_stream_for_retrans_queue(skb, sk) {
+	tcp_for_write_queue(skb, sk) {
 		cnt += tcp_skb_pcount(skb);
 		/*
 		 * Count the retransmission made on RTO correctly (only when
@@ -1468,7 +1469,7 @@ void tcp_enter_loss(struct sock *sk, int how)
 	if (!how)
 		tp->undo_marker = tp->snd_una;
 
-	sk_stream_for_retrans_queue(skb, sk) {
+	tcp_for_write_queue(skb, sk) {
 		cnt += tcp_skb_pcount(skb);
 		if (TCP_SKB_CB(skb)->sacked&TCPCB_RETRANS)
 			tp->undo_marker = 0;
@@ -1503,14 +1504,14 @@ static int tcp_check_sack_reneging(struct sock *sk)
 	 * receiver _host_ is heavily congested (or buggy).
 	 * Do processing similar to RTO timeout.
 	 */
-	if ((skb = skb_peek(&sk->sk_write_queue)) != NULL &&
+	if ((skb = tcp_write_queue_head(sk)) != NULL &&
 	    (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)) {
 		struct inet_connection_sock *icsk = inet_csk(sk);
 		NET_INC_STATS_BH(LINUX_MIB_TCPSACKRENEGING);
 
 		tcp_enter_loss(sk, 1);
 		icsk->icsk_retransmits++;
-		tcp_retransmit_skb(sk, skb_peek(&sk->sk_write_queue));
+		tcp_retransmit_skb(sk, tcp_write_queue_head(sk));
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
 					  icsk->icsk_rto, TCP_RTO_MAX);
 		return 1;
@@ -1531,7 +1532,7 @@ static inline int tcp_skb_timedout(struct sock *sk, struct sk_buff *skb)
 static inline int tcp_head_timedout(struct sock *sk, struct tcp_sock *tp)
 {
 	return tp->packets_out &&
-	       tcp_skb_timedout(sk, skb_peek(&sk->sk_write_queue));
+	       tcp_skb_timedout(sk, tcp_write_queue_head(sk));
 }
 
 /* Linux NewReno/SACK/FACK/ECN state machine.
@@ -1726,11 +1727,11 @@ static void tcp_mark_head_lost(struct sock *sk, struct tcp_sock *tp,
 		skb = tp->lost_skb_hint;
 		cnt = tp->lost_cnt_hint;
 	} else {
-		skb = sk->sk_write_queue.next;
+		skb = tcp_write_queue_head(sk);
 		cnt = 0;
 	}
 
-	sk_stream_for_retrans_queue_from(skb, sk) {
+	tcp_for_write_queue_from(skb, sk) {
 		/* TODO: do this better */
 		/* this is not the most efficient way to do this... */
 		tp->lost_skb_hint = skb;
@@ -1777,9 +1778,9 @@ static void tcp_update_scoreboard(struct sock *sk, struct tcp_sock *tp)
 		struct sk_buff *skb;
 
 		skb = tp->scoreboard_skb_hint ? tp->scoreboard_skb_hint
-			: sk->sk_write_queue.next;
+			: tcp_write_queue_head(sk);
 
-		sk_stream_for_retrans_queue_from(skb, sk) {
+		tcp_for_write_queue_from(skb, sk) {
 			if (!tcp_skb_timedout(sk, skb))
 				break;
 
@@ -1970,7 +1971,7 @@ static int tcp_try_undo_loss(struct sock *sk, struct tcp_sock *tp)
 {
 	if (tcp_may_undo(tp)) {
 		struct sk_buff *skb;
-		sk_stream_for_retrans_queue(skb, sk) {
+		tcp_for_write_queue(skb, sk) {
 			TCP_SKB_CB(skb)->sacked &= ~TCPCB_LOST;
 		}
 
@@ -2382,8 +2383,8 @@ static int tcp_clean_rtx_queue(struct sock *sk, __s32 *seq_rtt_p)
 		= icsk->icsk_ca_ops->rtt_sample;
 	struct timeval tv = { .tv_sec = 0, .tv_usec = 0 };
 
-	while ((skb = skb_peek(&sk->sk_write_queue)) &&
-	       skb != sk->sk_send_head) {
+	while ((skb = tcp_write_queue_head(sk)) &&
+	       skb != tcp_send_head(sk)) {
 		struct tcp_skb_cb *scb = TCP_SKB_CB(skb);
 		__u8 sacked = scb->sacked;
 
@@ -2446,7 +2447,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, __s32 *seq_rtt_p)
 		}
 		tcp_dec_pcount_approx(&tp->fackets_out, skb);
 		tcp_packets_out_dec(tp, skb);
-		__skb_unlink(skb, &sk->sk_write_queue);
+		tcp_unlink_write_queue(skb, sk);
 		sk_stream_free_skb(sk, skb);
 		clear_all_retrans_hints(tp);
 	}
@@ -2495,7 +2496,7 @@ static void tcp_ack_probe(struct sock *sk)
 
 	/* Was it a usable window open? */
 
-	if (!after(TCP_SKB_CB(sk->sk_send_head)->end_seq,
+	if (!after(TCP_SKB_CB(tcp_send_head(sk))->end_seq,
 		   tp->snd_una + tp->snd_wnd)) {
 		icsk->icsk_backoff = 0;
 		inet_csk_clear_xmit_timer(sk, ICSK_TIME_PROBE0);
@@ -2794,7 +2795,7 @@ no_queue:
 	 * being used to time the probes, and is probably far higher than
 	 * it needs to be for normal retransmission.
 	 */
-	if (sk->sk_send_head)
+	if (tcp_send_head(sk))
 		tcp_ack_probe(sk);
 	return 1;
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index f6793b4..19ba048 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1890,7 +1890,7 @@ int tcp_v4_destroy_sock(struct sock *sk)
 	tcp_cleanup_congestion_control(sk);
 
 	/* Cleanup up the write buffer. */
-	sk_stream_writequeue_purge(sk);
+	tcp_write_queue_purge(sk);
 
 	/* Cleans up our, hopefully empty, out_of_order_queue. */
 	__skb_queue_purge(&tp->out_of_order_queue);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index c9c912a..0adef4a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -65,9 +65,7 @@ int sysctl_tcp_slow_start_after_idle __read_mostly = 1;
 static void update_send_head(struct sock *sk, struct tcp_sock *tp,
 			     struct sk_buff *skb)
 {
-	sk->sk_send_head = skb->next;
-	if (sk->sk_send_head == (struct sk_buff *)&sk->sk_write_queue)
-		sk->sk_send_head = NULL;
+	tcp_advance_send_head(sk, skb);
 	tp->snd_nxt = TCP_SKB_CB(skb)->end_seq;
 	tcp_packets_out_inc(sk, tp, skb);
 }
@@ -567,12 +565,8 @@ static void tcp_queue_skb(struct sock *sk, struct sk_buff *skb)
 	/* Advance write_seq and place onto the write_queue. */
 	tp->write_seq = TCP_SKB_CB(skb)->end_seq;
 	skb_header_release(skb);
-	__skb_queue_tail(&sk->sk_write_queue, skb);
+	tcp_add_write_queue_tail(sk, skb);
 	sk_charge_skb(sk, skb);
-
-	/* Queue it, remembering where we must start sending. */
-	if (sk->sk_send_head == NULL)
-		sk->sk_send_head = skb;
 }
 
 static void tcp_set_skb_tso_segs(struct sock *sk, struct sk_buff *skb, unsigned int mss_now)
@@ -705,7 +699,7 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len, unsigned int mss
 
 	/* Link BUFF into the send queue. */
 	skb_header_release(buff);
-	__skb_append(skb, buff, &sk->sk_write_queue);
+	tcp_insert_write_queue_after(skb, buff, sk);
 
 	return 0;
 }
@@ -1055,7 +1049,7 @@ static inline int tcp_snd_wnd_test(struct tcp_sock *tp, struct sk_buff *skb, uns
 	return !after(end_seq, tp->snd_una + tp->snd_wnd);
 }
 
-/* This checks if the data bearing packet SKB (usually sk->sk_send_head)
+/* This checks if the data bearing packet SKB (usually tcp_send_head(sk))
  * should be put on the wire right now.  If so, it returns the number of
  * packets allowed by the congestion window.
  */
@@ -1078,15 +1072,9 @@ static unsigned int tcp_snd_test(struct sock *sk, struct sk_buff *skb,
 	return cwnd_quota;
 }
 
-static inline int tcp_skb_is_last(const struct sock *sk,
-				  const struct sk_buff *skb)
-{
-	return skb->next == (struct sk_buff *)&sk->sk_write_queue;
-}
-
 int tcp_may_send_now(struct sock *sk, struct tcp_sock *tp)
 {
-	struct sk_buff *skb = sk->sk_send_head;
+	struct sk_buff *skb = tcp_send_head(sk);
 
 	return (skb &&
 		tcp_snd_test(sk, skb, tcp_current_mss(sk, 1),
@@ -1142,7 +1130,7 @@ static int tso_fragment(struct sock *sk, struct sk_buff *skb, unsigned int len,
 
 	/* Link BUFF into the send queue. */
 	skb_header_release(buff);
-	__skb_append(skb, buff, &sk->sk_write_queue);
+	tcp_insert_write_queue_after(skb, buff, sk);
 
 	return 0;
 }
@@ -1248,10 +1236,10 @@ static int tcp_mtu_probe(struct sock *sk)
 
 	/* Have enough data in the send queue to probe? */
 	len = 0;
-	if ((skb = sk->sk_send_head) == NULL)
+	if ((skb = tcp_send_head(sk)) == NULL)
 		return -1;
 	while ((len += skb->len) < probe_size && !tcp_skb_is_last(sk, skb))
-		skb = skb->next;
+		skb = tcp_write_queue_next(sk, skb);
 	if (len < probe_size)
 		return -1;
 
@@ -1278,9 +1266,9 @@ static int tcp_mtu_probe(struct sock *sk)
 		return -1;
 	sk_charge_skb(sk, nskb);
 
-	skb = sk->sk_send_head;
-	__skb_insert(nskb, skb->prev, skb, &sk->sk_write_queue);
-	sk->sk_send_head = nskb;
+	skb = tcp_send_head(sk);
+	tcp_insert_write_queue_before(nskb, skb, sk);
+	tcp_advance_send_head(sk, skb);
 
 	TCP_SKB_CB(nskb)->seq = TCP_SKB_CB(skb)->seq;
 	TCP_SKB_CB(nskb)->end_seq = TCP_SKB_CB(skb)->seq + probe_size;
@@ -1291,7 +1279,7 @@ static int tcp_mtu_probe(struct sock *sk)
 
 	len = 0;
 	while (len < probe_size) {
-		next = skb->next;
+		next = tcp_write_queue_next(sk, skb);
 
 		copy = min_t(int, skb->len, probe_size - len);
 		if (nskb->ip_summed)
@@ -1304,7 +1292,7 @@ static int tcp_mtu_probe(struct sock *sk)
 			/* We've eaten all the data from this skb.
 			 * Throw it away. */
 			TCP_SKB_CB(nskb)->flags |= TCP_SKB_CB(skb)->flags;
-			__skb_unlink(skb, &sk->sk_write_queue);
+			tcp_unlink_write_queue(skb, sk);
 			sk_stream_free_skb(sk, skb);
 		} else {
 			TCP_SKB_CB(nskb)->flags |= TCP_SKB_CB(skb)->flags &
@@ -1376,7 +1364,7 @@ static int tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle)
 		sent_pkts = 1;
 	}
 
-	while ((skb = sk->sk_send_head)) {
+	while ((skb = tcp_send_head(sk))) {
 		unsigned int limit;
 
 		tso_segs = tcp_init_tso_segs(sk, skb, mss_now);
@@ -1434,7 +1422,7 @@ static int tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle)
 		tcp_cwnd_validate(sk, tp);
 		return 0;
 	}
-	return !tp->packets_out && sk->sk_send_head;
+	return !tp->packets_out && tcp_send_head(sk);
 }
 
 /* Push out any pending frames which were held back due to
@@ -1444,7 +1432,7 @@ static int tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle)
 void __tcp_push_pending_frames(struct sock *sk, struct tcp_sock *tp,
 			       unsigned int cur_mss, int nonagle)
 {
-	struct sk_buff *skb = sk->sk_send_head;
+	struct sk_buff *skb = tcp_send_head(sk);
 
 	if (skb) {
 		if (tcp_write_xmit(sk, cur_mss, nonagle))
@@ -1458,7 +1446,7 @@ void __tcp_push_pending_frames(struct sock *sk, struct tcp_sock *tp,
 void tcp_push_one(struct sock *sk, unsigned int mss_now)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct sk_buff *skb = sk->sk_send_head;
+	struct sk_buff *skb = tcp_send_head(sk);
 	unsigned int tso_segs, cwnd_quota;
 
 	BUG_ON(!skb || skb->len < mss_now);
@@ -1616,7 +1604,7 @@ u32 __tcp_select_window(struct sock *sk)
 static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *skb, int mss_now)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct sk_buff *next_skb = skb->next;
+	struct sk_buff *next_skb = tcp_write_queue_next(sk, skb);
 
 	/* The first test we must make is that neither of these two
 	 * SKB's are still referenced by someone else.
@@ -1648,7 +1636,7 @@ static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *skb, int m
 		clear_all_retrans_hints(tp);
 
 		/* Ok.	We will be able to collapse the packet. */
-		__skb_unlink(next_skb, &sk->sk_write_queue);
+		tcp_unlink_write_queue(next_skb, sk);
 
 		memcpy(skb_put(skb, next_skb_size), next_skb->data, next_skb_size);
 
@@ -1702,7 +1690,7 @@ void tcp_simple_retransmit(struct sock *sk)
 	unsigned int mss = tcp_current_mss(sk, 0);
 	int lost = 0;
 
-	sk_stream_for_retrans_queue(skb, sk) {
+	tcp_for_write_queue(skb, sk) {
 		if (skb->len > mss &&
 		    !(TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_ACKED)) {
 			if (TCP_SKB_CB(skb)->sacked&TCPCB_SACKED_RETRANS) {
@@ -1786,10 +1774,10 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	/* Collapse two adjacent packets if worthwhile and we can. */
 	if(!(TCP_SKB_CB(skb)->flags & TCPCB_FLAG_SYN) &&
 	   (skb->len < (cur_mss >> 1)) &&
-	   (skb->next != sk->sk_send_head) &&
-	   (skb->next != (struct sk_buff *)&sk->sk_write_queue) &&
-	   (skb_shinfo(skb)->nr_frags == 0 && skb_shinfo(skb->next)->nr_frags == 0) &&
-	   (tcp_skb_pcount(skb) == 1 && tcp_skb_pcount(skb->next) == 1) &&
+	   (tcp_write_queue_next(sk, skb) != tcp_send_head(sk)) &&
+	   (!tcp_skb_is_last(sk, skb)) &&
+	   (skb_shinfo(skb)->nr_frags == 0 && skb_shinfo(tcp_write_queue_next(sk, skb))->nr_frags == 0) &&
+	   (tcp_skb_pcount(skb) == 1 && tcp_skb_pcount(tcp_write_queue_next(sk, skb)) == 1) &&
 	   (sysctl_tcp_retrans_collapse != 0))
 		tcp_retrans_try_collapse(sk, skb, cur_mss);
 
@@ -1868,13 +1856,13 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 		skb = tp->retransmit_skb_hint;
 		packet_cnt = tp->retransmit_cnt_hint;
 	}else{
-		skb = sk->sk_write_queue.next;
+		skb = tcp_write_queue_head(sk);
 		packet_cnt = 0;
 	}
 
 	/* First pass: retransmit lost packets. */
 	if (tp->lost_out) {
-		sk_stream_for_retrans_queue_from(skb, sk) {
+		tcp_for_write_queue_from(skb, sk) {
 			__u8 sacked = TCP_SKB_CB(skb)->sacked;
 
 			/* we could do better than to assign each time */
@@ -1902,8 +1890,7 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 					else
 						NET_INC_STATS_BH(LINUX_MIB_TCPSLOWSTARTRETRANS);
 
-					if (skb ==
-					    skb_peek(&sk->sk_write_queue))
+					if (skb == tcp_write_queue_head(sk))
 						inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
 									  inet_csk(sk)->icsk_rto,
 									  TCP_RTO_MAX);
@@ -1940,11 +1927,11 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 		skb = tp->forward_skb_hint;
 		packet_cnt = tp->forward_cnt_hint;
 	} else{
-		skb = sk->sk_write_queue.next;
+		skb = tcp_write_queue_head(sk);
 		packet_cnt = 0;
 	}
 
-	sk_stream_for_retrans_queue_from(skb, sk) {
+	tcp_for_write_queue_from(skb, sk) {
 		tp->forward_cnt_hint = packet_cnt;
 		tp->forward_skb_hint = skb;
 
@@ -1969,7 +1956,7 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 			break;
 		}
 
-		if (skb == skb_peek(&sk->sk_write_queue))
+		if (skb == tcp_write_queue_head(sk))
 			inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
 						  inet_csk(sk)->icsk_rto,
 						  TCP_RTO_MAX);
@@ -1985,7 +1972,7 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 void tcp_send_fin(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct sk_buff *skb = skb_peek_tail(&sk->sk_write_queue);
+	struct sk_buff *skb = tcp_write_queue_tail(sk);
 	int mss_now;
 
 	/* Optimization, tack on the FIN if we have a queue of
@@ -1994,7 +1981,7 @@ void tcp_send_fin(struct sock *sk)
 	 */
 	mss_now = tcp_current_mss(sk, 1);
 
-	if (sk->sk_send_head != NULL) {
+	if (tcp_send_head(sk) != NULL) {
 		TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_FIN;
 		TCP_SKB_CB(skb)->end_seq++;
 		tp->write_seq++;
@@ -2067,7 +2054,7 @@ int tcp_send_synack(struct sock *sk)
 {
 	struct sk_buff* skb;
 
-	skb = skb_peek(&sk->sk_write_queue);
+	skb = tcp_write_queue_head(sk);
 	if (skb == NULL || !(TCP_SKB_CB(skb)->flags&TCPCB_FLAG_SYN)) {
 		printk(KERN_DEBUG "tcp_send_synack: wrong queue state\n");
 		return -EFAULT;
@@ -2077,9 +2064,9 @@ int tcp_send_synack(struct sock *sk)
 			struct sk_buff *nskb = skb_copy(skb, GFP_ATOMIC);
 			if (nskb == NULL)
 				return -ENOMEM;
-			__skb_unlink(skb, &sk->sk_write_queue);
+			tcp_unlink_write_queue(skb, sk);
 			skb_header_release(nskb);
-			__skb_queue_head(&sk->sk_write_queue, nskb);
+			__tcp_add_write_queue_head(sk, nskb);
 			sk_stream_free_skb(sk, skb);
 			sk_charge_skb(sk, nskb);
 			skb = nskb;
@@ -2281,7 +2268,7 @@ int tcp_connect(struct sock *sk)
 	TCP_SKB_CB(buff)->when = tcp_time_stamp;
 	tp->retrans_stamp = TCP_SKB_CB(buff)->when;
 	skb_header_release(buff);
-	__skb_queue_tail(&sk->sk_write_queue, buff);
+	__tcp_add_write_queue_tail(sk, buff);
 	sk_charge_skb(sk, buff);
 	tp->packets_out += tcp_skb_pcount(buff);
 	tcp_transmit_skb(sk, buff, 1, GFP_KERNEL);
@@ -2437,7 +2424,7 @@ int tcp_write_wakeup(struct sock *sk)
 		struct tcp_sock *tp = tcp_sk(sk);
 		struct sk_buff *skb;
 
-		if ((skb = sk->sk_send_head) != NULL &&
+		if ((skb = tcp_send_head(sk)) != NULL &&
 		    before(TCP_SKB_CB(skb)->seq, tp->snd_una+tp->snd_wnd)) {
 			int err;
 			unsigned int mss = tcp_current_mss(sk, 0);
@@ -2487,7 +2474,7 @@ void tcp_send_probe0(struct sock *sk)
 
 	err = tcp_write_wakeup(sk);
 
-	if (tp->packets_out || !sk->sk_send_head) {
+	if (tp->packets_out || !tcp_send_head(sk)) {
 		/* Cancel probe timer, if it is not required. */
 		icsk->icsk_probes_out = 0;
 		icsk->icsk_backoff = 0;
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index a9243cf..2ca97b2 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -233,7 +233,7 @@ static void tcp_probe_timer(struct sock *sk)
 	struct tcp_sock *tp = tcp_sk(sk);
 	int max_probes;
 
-	if (tp->packets_out || !sk->sk_send_head) {
+	if (tp->packets_out || !tcp_send_head(sk)) {
 		icsk->icsk_probes_out = 0;
 		return;
 	}
@@ -284,7 +284,7 @@ static void tcp_retransmit_timer(struct sock *sk)
 	if (!tp->packets_out)
 		goto out;
 
-	BUG_TRAP(!skb_queue_empty(&sk->sk_write_queue));
+	BUG_TRAP(!tcp_write_queue_empty(sk));
 
 	if (!tp->snd_wnd && !sock_flag(sk, SOCK_DEAD) &&
 	    !((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV))) {
@@ -306,7 +306,7 @@ static void tcp_retransmit_timer(struct sock *sk)
 			goto out;
 		}
 		tcp_enter_loss(sk, 0);
-		tcp_retransmit_skb(sk, skb_peek(&sk->sk_write_queue));
+		tcp_retransmit_skb(sk, tcp_write_queue_head(sk));
 		__sk_dst_reset(sk);
 		goto out_reset_timer;
 	}
@@ -341,7 +341,7 @@ static void tcp_retransmit_timer(struct sock *sk)
 		tcp_enter_loss(sk, 0);
 	}
 
-	if (tcp_retransmit_skb(sk, skb_peek(&sk->sk_write_queue)) > 0) {
+	if (tcp_retransmit_skb(sk, tcp_write_queue_head(sk)) > 0) {
 		/* Retransmission failed because of local congestion,
 		 * do not backoff.
 		 */
@@ -482,7 +482,7 @@ static void tcp_keepalive_timer (unsigned long data)
 	elapsed = keepalive_time_when(tp);
 
 	/* It is alive without keepalive 8) */
-	if (tp->packets_out || sk->sk_send_head)
+	if (tp->packets_out || tcp_send_head(sk))
 		goto resched;
 
 	elapsed = tcp_time_stamp - tp->rcv_tstamp;
