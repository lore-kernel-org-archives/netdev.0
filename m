From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH net-2.6.22 1/3] [TCP]: Sed magic converts func(sk, tp,
 ...) -> func(sk, ...)
Date: Tue, 17 Apr 2007 14:54:11 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0704171449060.20491@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0704161758020.28337@kivilampi-30.cs.helsinki.fi>
 <462396F5.9030907@trash.net> <Pine.LNX.4.64.0704161913400.28337@kivilampi-30.cs.helsinki.fi>
 <20070416.171604.26532491.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1817580853-1176810851=:20491"
Cc: kaber@trash.net, hch@infradead.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39297 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753863AbXDQLyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 07:54:15 -0400
In-Reply-To: <20070416.171604.26532491.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1817580853-1176810851=:20491
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 16 Apr 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Mon, 16 Apr 2007 19:19:02 +0300 (EEST)
> 
> > [PATCH] [TCP]: Sed magic converts func(sk, tp, ...) -> func(sk, ...)
> 
> I was trying to spread out the net-2.6.22 tree from the tcp-2.6
> one so that we could do the experimental TCP stuff in the tcp-2.6
> tree and leave other networking changes for net-2.6.22
>
> Putting in TCP cleanups which touch a lot of code into net-2.6.22
> defeats that effort because now there will be all kinds of rejects and
> merge errors people will have to deal with if they clone a net-2.6.22
> tree then pull in tcp-2.6 to do some TCP hacking which is valid.

...to tcp-2.6 this time.

[PATCH] [TCP]: Sed magic converts func(sk, tp, ...) -> func(sk, ...)

This is (mostly) automated change using magic:

sed -e '/struct sock \*sk/ N' -e '/struct sock \*sk/ N'
    -e '/struct sock \*sk/ N' -e '/struct sock \*sk/ N'
    -e 's|struct sock \*sk,[\n\t ]*struct tcp_sock \*tp\([^{]*\n{\n\)|
	  struct sock \*sk\1\tstruct tcp_sock *tp = tcp_sk(sk);\n|g'
    -e 's|struct sock \*sk, struct tcp_sock \*tp|
	  struct sock \*sk|g' -e 's|sk, tp\([^-]\)|sk\1|g'

Fixed four unused variable (tp) warnings that were introduced.

In addition, manually added newlines after local variables and
tweaked function arguments positioning.

$ gcc --version
gcc (GCC) 4.1.1 20060525 (Red Hat 4.1.1-1)
...
$ codiff -fV built-in.o.old built-in.o.new
net/ipv4/tcp.c:
  tcp_setsockopt |   -5
  tcp_sendpage   |  -16
  tcp_sendmsg    |  -12
 3 functions changed, 33 bytes removed

net/ipv4/tcp_input.c:
  tcp_try_undo_recovery |   +3
  tcp_try_undo_dsack    |   +2
  tcp_send_dupack       |   +1
  tcp_ack               |  -10
  tcp_event_data_recv   |  -16
  tcp_rcv_state_process |  -10
  tcp_rcv_established   |  -19
 7 functions changed, 6 bytes added, 55 bytes removed, diff: -49

net/ipv4/tcp_output.c:
  update_send_head          |   -9
  tcp_cwnd_validate         |   +1
  tcp_write_wakeup          |  -17
  __tcp_push_pending_frames |  -25
  tcp_push_one              |   -8
  tcp_send_fin              |   -4
 6 functions changed, 1 bytes added, 63 bytes removed, diff: -62

built-in.o.new:
 16 functions changed, 7 bytes added, 151 bytes removed, diff: -144

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h     |   25 +++++----
 include/net/tcp_ecn.h |   11 +++-
 net/ipv4/tcp.c        |   39 ++++++++------
 net/ipv4/tcp_input.c  |  134 +++++++++++++++++++++++++++++--------------------
 net/ipv4/tcp_output.c |   54 +++++++++++---------
 5 files changed, 152 insertions(+), 111 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 809e392..29e5740 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -420,9 +420,9 @@ extern __u32 cookie_v4_init_sequence(str
 
 /* tcp_output.c */
 
-extern void __tcp_push_pending_frames(struct sock *sk, struct tcp_sock *tp,
-				      unsigned int cur_mss, int nonagle);
-extern int tcp_may_send_now(struct sock *sk, struct tcp_sock *tp);
+extern void __tcp_push_pending_frames(struct sock *sk, unsigned int cur_mss,
+				      int nonagle);
+extern int tcp_may_send_now(struct sock *sk);
 extern int tcp_retransmit_skb(struct sock *, struct sk_buff *);
 extern void tcp_xmit_retransmit_queue(struct sock *);
 extern void tcp_simple_retransmit(struct sock *);
@@ -479,8 +479,10 @@ static inline void tcp_fast_path_on(stru
 	__tcp_fast_path_on(tp, tp->snd_wnd >> tp->rx_opt.snd_wscale);
 }
 
-static inline void tcp_fast_path_check(struct sock *sk, struct tcp_sock *tp)
+static inline void tcp_fast_path_check(struct sock *sk)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
+
 	if (skb_queue_empty(&tp->out_of_order_queue) &&
 	    tp->rcv_wnd &&
 	    atomic_read(&sk->sk_rmem_alloc) < sk->sk_rcvbuf &&
@@ -591,10 +593,10 @@ static inline void tcp_dec_pcount_approx
 	}
 }
 
-static inline void tcp_packets_out_inc(struct sock *sk, 
-				       struct tcp_sock *tp,
+static inline void tcp_packets_out_inc(struct sock *sk,
 				       const struct sk_buff *skb)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
 	int orig = tp->packets_out;
 
 	tp->packets_out += tcp_skb_pcount(skb);
@@ -778,18 +780,21 @@ static inline void tcp_minshall_update(s
 		tp->snd_sml = TCP_SKB_CB(skb)->end_seq;
 }
 
-static inline void tcp_check_probe_timer(struct sock *sk, struct tcp_sock *tp)
+static inline void tcp_check_probe_timer(struct sock *sk)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_connection_sock *icsk = inet_csk(sk);
+
 	if (!tp->packets_out && !icsk->icsk_pending)
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_PROBE0,
 					  icsk->icsk_rto, TCP_RTO_MAX);
 }
 
-static inline void tcp_push_pending_frames(struct sock *sk,
-					   struct tcp_sock *tp)
+static inline void tcp_push_pending_frames(struct sock *sk)
 {
-	__tcp_push_pending_frames(sk, tp, tcp_current_mss(sk, 1), tp->nonagle);
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	__tcp_push_pending_frames(sk, tcp_current_mss(sk, 1), tp->nonagle);
 }
 
 static inline void tcp_init_wl(struct tcp_sock *tp, u32 ack, u32 seq)
diff --git a/include/net/tcp_ecn.h b/include/net/tcp_ecn.h
index b5f7c6a..89eb3e0 100644
--- a/include/net/tcp_ecn.h
+++ b/include/net/tcp_ecn.h
@@ -27,9 +27,10 @@ static inline void TCP_ECN_send_synack(s
 		TCP_SKB_CB(skb)->flags &= ~TCPCB_FLAG_ECE;
 }
 
-static inline void TCP_ECN_send_syn(struct sock *sk, struct tcp_sock *tp,
-				    struct sk_buff *skb)
+static inline void TCP_ECN_send_syn(struct sock *sk, struct sk_buff *skb)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
+
 	tp->ecn_flags = 0;
 	if (sysctl_tcp_ecn) {
 		TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_ECE|TCPCB_FLAG_CWR;
@@ -44,9 +45,11 @@ TCP_ECN_make_synack(struct request_sock 
 		th->ece = 1;
 }
 
-static inline void TCP_ECN_send(struct sock *sk, struct tcp_sock *tp,
-				struct sk_buff *skb, int tcp_header_len)
+static inline void TCP_ECN_send(struct sock *sk, struct sk_buff *skb,
+				int tcp_header_len)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
+
 	if (tp->ecn_flags & TCP_ECN_OK) {
 		/* Not-retransmitted data segment: set ECT and inject CWR. */
 		if (skb->len != tcp_header_len &&
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index bb9d91a..fa6db7f 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -460,9 +460,9 @@ static inline int forced_push(struct tcp
 	return after(tp->write_seq, tp->pushed_seq + (tp->max_window >> 1));
 }
 
-static inline void skb_entail(struct sock *sk, struct tcp_sock *tp,
-			      struct sk_buff *skb)
+static inline void skb_entail(struct sock *sk, struct sk_buff *skb)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_skb_cb *tcb = TCP_SKB_CB(skb);
 
 	skb->csum    = 0;
@@ -486,15 +486,17 @@ static inline void tcp_mark_urg(struct t
 	}
 }
 
-static inline void tcp_push(struct sock *sk, struct tcp_sock *tp, int flags,
-			    int mss_now, int nonagle)
+static inline void tcp_push(struct sock *sk, int flags, int mss_now,
+			    int nonagle)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
+
 	if (tcp_send_head(sk)) {
 		struct sk_buff *skb = tcp_write_queue_tail(sk);
 		if (!(flags & MSG_MORE) || forced_push(tp))
 			tcp_mark_push(tp, skb);
 		tcp_mark_urg(tp, flags, skb);
-		__tcp_push_pending_frames(sk, tp, mss_now,
+		__tcp_push_pending_frames(sk, mss_now,
 					  (flags & MSG_MORE) ? TCP_NAGLE_CORK : nonagle);
 	}
 }
@@ -540,7 +542,7 @@ new_segment:
 			if (!skb)
 				goto wait_for_memory;
 
-			skb_entail(sk, tp, skb);
+			skb_entail(sk, skb);
 			copy = size_goal;
 		}
 
@@ -586,7 +588,7 @@ new_segment:
 
 		if (forced_push(tp)) {
 			tcp_mark_push(tp, skb);
-			__tcp_push_pending_frames(sk, tp, mss_now, TCP_NAGLE_PUSH);
+			__tcp_push_pending_frames(sk, mss_now, TCP_NAGLE_PUSH);
 		} else if (skb == tcp_send_head(sk))
 			tcp_push_one(sk, mss_now);
 		continue;
@@ -595,7 +597,7 @@ wait_for_sndbuf:
 		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 wait_for_memory:
 		if (copied)
-			tcp_push(sk, tp, flags & ~MSG_MORE, mss_now, TCP_NAGLE_PUSH);
+			tcp_push(sk, flags & ~MSG_MORE, mss_now, TCP_NAGLE_PUSH);
 
 		if ((err = sk_stream_wait_memory(sk, &timeo)) != 0)
 			goto do_error;
@@ -606,7 +608,7 @@ wait_for_memory:
 
 out:
 	if (copied)
-		tcp_push(sk, tp, flags, mss_now, tp->nonagle);
+		tcp_push(sk, flags, mss_now, tp->nonagle);
 	return copied;
 
 do_error:
@@ -637,8 +639,9 @@ ssize_t tcp_sendpage(struct socket *sock
 #define TCP_PAGE(sk)	(sk->sk_sndmsg_page)
 #define TCP_OFF(sk)	(sk->sk_sndmsg_off)
 
-static inline int select_size(struct sock *sk, struct tcp_sock *tp)
+static inline int select_size(struct sock *sk)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
 	int tmp = tp->mss_cache;
 
 	if (sk->sk_route_caps & NETIF_F_SG) {
@@ -714,7 +717,7 @@ new_segment:
 				if (!sk_stream_memory_free(sk))
 					goto wait_for_sndbuf;
 
-				skb = sk_stream_alloc_pskb(sk, select_size(sk, tp),
+				skb = sk_stream_alloc_pskb(sk, select_size(sk),
 							   0, sk->sk_allocation);
 				if (!skb)
 					goto wait_for_memory;
@@ -725,7 +728,7 @@ new_segment:
 				if (sk->sk_route_caps & NETIF_F_ALL_CSUM)
 					skb->ip_summed = CHECKSUM_PARTIAL;
 
-				skb_entail(sk, tp, skb);
+				skb_entail(sk, skb);
 				copy = size_goal;
 			}
 
@@ -830,7 +833,7 @@ new_segment:
 
 			if (forced_push(tp)) {
 				tcp_mark_push(tp, skb);
-				__tcp_push_pending_frames(sk, tp, mss_now, TCP_NAGLE_PUSH);
+				__tcp_push_pending_frames(sk, mss_now, TCP_NAGLE_PUSH);
 			} else if (skb == tcp_send_head(sk))
 				tcp_push_one(sk, mss_now);
 			continue;
@@ -839,7 +842,7 @@ wait_for_sndbuf:
 			set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 wait_for_memory:
 			if (copied)
-				tcp_push(sk, tp, flags & ~MSG_MORE, mss_now, TCP_NAGLE_PUSH);
+				tcp_push(sk, flags & ~MSG_MORE, mss_now, TCP_NAGLE_PUSH);
 
 			if ((err = sk_stream_wait_memory(sk, &timeo)) != 0)
 				goto do_error;
@@ -851,7 +854,7 @@ wait_for_memory:
 
 out:
 	if (copied)
-		tcp_push(sk, tp, flags, mss_now, tp->nonagle);
+		tcp_push(sk, flags, mss_now, tp->nonagle);
 	TCP_CHECK_TIMER(sk);
 	release_sock(sk);
 	return copied;
@@ -1389,7 +1392,7 @@ #endif
 skip_copy:
 		if (tp->urg_data && after(tp->copied_seq, tp->urg_seq)) {
 			tp->urg_data = 0;
-			tcp_fast_path_check(sk, tp);
+			tcp_fast_path_check(sk);
 		}
 		if (used + offset < skb->len)
 			continue;
@@ -1830,7 +1833,7 @@ static int do_tcp_setsockopt(struct sock
 			 * for currently queued segments.
 			 */
 			tp->nonagle |= TCP_NAGLE_OFF|TCP_NAGLE_PUSH;
-			tcp_push_pending_frames(sk, tp);
+			tcp_push_pending_frames(sk);
 		} else {
 			tp->nonagle &= ~TCP_NAGLE_OFF;
 		}
@@ -1854,7 +1857,7 @@ static int do_tcp_setsockopt(struct sock
 			tp->nonagle &= ~TCP_NAGLE_CORK;
 			if (tp->nonagle&TCP_NAGLE_OFF)
 				tp->nonagle |= TCP_NAGLE_PUSH;
-			tcp_push_pending_frames(sk, tp);
+			tcp_push_pending_frames(sk);
 		}
 		break;
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 4f1f8b6..ee08723 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -236,9 +236,9 @@ static void tcp_fixup_sndbuf(struct sock
  */
 
 /* Slow part of check#2. */
-static int __tcp_grow_window(const struct sock *sk, struct tcp_sock *tp,
-			     const struct sk_buff *skb)
+static int __tcp_grow_window(const struct sock *sk, const struct sk_buff *skb)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
 	/* Optimize this! */
 	int truesize = tcp_win_from_space(skb->truesize)/2;
 	int window = tcp_win_from_space(sysctl_tcp_rmem[2])/2;
@@ -253,9 +253,11 @@ static int __tcp_grow_window(const struc
 	return 0;
 }
 
-static void tcp_grow_window(struct sock *sk, struct tcp_sock *tp,
+static void tcp_grow_window(struct sock *sk,
 			    struct sk_buff *skb)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
+
 	/* Check #1 */
 	if (tp->rcv_ssthresh < tp->window_clamp &&
 	    (int)tp->rcv_ssthresh < tcp_space(sk) &&
@@ -268,7 +270,7 @@ static void tcp_grow_window(struct sock 
 		if (tcp_win_from_space(skb->truesize) <= skb->len)
 			incr = 2*tp->advmss;
 		else
-			incr = __tcp_grow_window(sk, tp, skb);
+			incr = __tcp_grow_window(sk, skb);
 
 		if (incr) {
 			tp->rcv_ssthresh = min(tp->rcv_ssthresh + incr, tp->window_clamp);
@@ -331,8 +333,9 @@ static void tcp_init_buffer_space(struct
 }
 
 /* 5. Recalculate window clamp after socket hit its memory bounds. */
-static void tcp_clamp_window(struct sock *sk, struct tcp_sock *tp)
+static void tcp_clamp_window(struct sock *sk)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
 
 	icsk->icsk_ack.quick = 0;
@@ -504,8 +507,9 @@ new_measure:
  * each ACK we send, he increments snd_cwnd and transmits more of his
  * queue.  -DaveM
  */
-static void tcp_event_data_recv(struct sock *sk, struct tcp_sock *tp, struct sk_buff *skb)
+static void tcp_event_data_recv(struct sock *sk, struct sk_buff *skb)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	u32 now;
 
@@ -546,7 +550,7 @@ static void tcp_event_data_recv(struct s
 	TCP_ECN_check_ce(tp, skb);
 
 	if (skb->len >= 128)
-		tcp_grow_window(sk, tp, skb);
+		tcp_grow_window(sk, skb);
 }
 
 /* Called to compute a smoothed rtt estimate. The data fed to this
@@ -1593,8 +1597,10 @@ static inline int tcp_skb_timedout(struc
 	return (tcp_time_stamp - TCP_SKB_CB(skb)->when > inet_csk(sk)->icsk_rto);
 }
 
-static inline int tcp_head_timedout(struct sock *sk, struct tcp_sock *tp)
+static inline int tcp_head_timedout(struct sock *sk)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
+
 	return tp->packets_out &&
 	       tcp_skb_timedout(sk, tcp_write_queue_head(sk));
 }
@@ -1692,8 +1698,9 @@ static inline int tcp_head_timedout(stru
  * Main question: may we further continue forward transmission
  * with the same cwnd?
  */
-static int tcp_time_to_recover(struct sock *sk, struct tcp_sock *tp)
+static int tcp_time_to_recover(struct sock *sk)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
 	__u32 packets_out;
 
 	/* Do not perform any recovery during FRTO algorithm */
@@ -1711,7 +1718,7 @@ static int tcp_time_to_recover(struct so
 	/* Trick#3 : when we use RFC2988 timer restart, fast
 	 * retransmit can be triggered by timeout of queue head.
 	 */
-	if (IsFack(tp) && tcp_head_timedout(sk, tp))
+	if (IsFack(tp) && tcp_head_timedout(sk))
 		return 1;
 
 	/* Trick#4: It is still not OK... But will it be useful to delay
@@ -1720,7 +1727,7 @@ static int tcp_time_to_recover(struct so
 	packets_out = tp->packets_out;
 	if (packets_out <= tp->reordering &&
 	    tp->sacked_out >= max_t(__u32, packets_out/2, sysctl_tcp_reordering) &&
-	    !tcp_may_send_now(sk, tp)) {
+	    !tcp_may_send_now(sk)) {
 		/* We have nothing to send. This connection is limited
 		 * either by receiver window or by application.
 		 */
@@ -1760,8 +1767,10 @@ static void tcp_add_reno_sack(struct soc
 
 /* Account for ACK, ACKing some data in Reno Recovery phase. */
 
-static void tcp_remove_reno_sacks(struct sock *sk, struct tcp_sock *tp, int acked)
+static void tcp_remove_reno_sacks(struct sock *sk, int acked)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
+
 	if (acked > 0) {
 		/* One ACK acked hole. The rest eat duplicate ACKs. */
 		if (acked-1 >= tp->sacked_out)
@@ -1962,9 +1971,11 @@ backwards_walk_done:
 }
 
 /* Account newly detected lost packet(s) */
-static void tcp_update_scoreboard(struct sock *sk, struct tcp_sock *tp,
+static void tcp_update_scoreboard(struct sock *sk,
 				  u32 sack_entry_seq, int fast_rexmit)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
+
 	if (!IsReno(tp))
 		tcp_update_scoreboard_fack(sk, sack_entry_seq, fast_rexmit);
 	else
@@ -2020,9 +2031,11 @@ static inline int tcp_packet_delayed(str
 /* Undo procedures. */
 
 #if FASTRETRANS_DEBUG > 1
-static void DBGUNDO(struct sock *sk, struct tcp_sock *tp, const char *msg)
+static void DBGUNDO(struct sock *sk, const char *msg)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_sock *inet = inet_sk(sk);
+
 	printk(KERN_DEBUG "Undo %s %u.%u.%u.%u/%u c%u l%u ss%u/%u p%u\n",
 	       msg,
 	       NIPQUAD(inet->daddr), ntohs(inet->dport),
@@ -2068,13 +2081,15 @@ static inline int tcp_may_undo(struct tc
 }
 
 /* People celebrate: "We love our President!" */
-static int tcp_try_undo_recovery(struct sock *sk, struct tcp_sock *tp)
+static int tcp_try_undo_recovery(struct sock *sk)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
+
 	if (tcp_may_undo(tp)) {
 		/* Happy end! We did not retransmit anything
 		 * or our original transmission succeeded.
 		 */
-		DBGUNDO(sk, tp, inet_csk(sk)->icsk_ca_state == TCP_CA_Loss ? "loss" : "retrans");
+		DBGUNDO(sk, inet_csk(sk)->icsk_ca_state == TCP_CA_Loss ? "loss" : "retrans");
 		tcp_undo_cwr(sk, 1);
 		if (inet_csk(sk)->icsk_ca_state == TCP_CA_Loss)
 			NET_INC_STATS_BH(LINUX_MIB_TCPLOSSUNDO);
@@ -2094,10 +2109,12 @@ static int tcp_try_undo_recovery(struct 
 }
 
 /* Try to undo cwnd reduction, because D-SACKs acked all retransmitted data */
-static void tcp_try_undo_dsack(struct sock *sk, struct tcp_sock *tp)
+static void tcp_try_undo_dsack(struct sock *sk)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
+
 	if (tp->undo_marker && !tp->undo_retrans) {
-		DBGUNDO(sk, tp, "D-SACK");
+		DBGUNDO(sk, "D-SACK");
 		tcp_undo_cwr(sk, 1);
 		tp->undo_marker = 0;
 		NET_INC_STATS_BH(LINUX_MIB_TCPDSACKUNDO);
@@ -2106,9 +2123,9 @@ static void tcp_try_undo_dsack(struct so
 
 /* Undo during fast recovery after partial ACK. */
 
-static int tcp_try_undo_partial(struct sock *sk, struct tcp_sock *tp,
-				int acked)
+static int tcp_try_undo_partial(struct sock *sk, int acked)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
 	/* Partial ACK arrived. Force Hoe's retransmit. */
 	int failed = IsReno(tp) || (tcp_fackets_out(tp) > tp->reordering);
 
@@ -2121,7 +2138,7 @@ static int tcp_try_undo_partial(struct s
 
 		tcp_update_reordering(sk, tcp_fackets_out(tp) + acked, 1);
 
-		DBGUNDO(sk, tp, "Hoe");
+		DBGUNDO(sk, "Hoe");
 		tcp_undo_cwr(sk, 0);
 		NET_INC_STATS_BH(LINUX_MIB_TCPPARTIALUNDO);
 
@@ -2135,8 +2152,10 @@ static int tcp_try_undo_partial(struct s
 }
 
 /* Undo during loss recovery after partial ACK. */
-static int tcp_try_undo_loss(struct sock *sk, struct tcp_sock *tp)
+static int tcp_try_undo_loss(struct sock *sk)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
+
 	if (tcp_may_undo(tp)) {
 		struct sk_buff *skb;
 		tcp_for_write_queue(skb, sk) {
@@ -2147,7 +2166,7 @@ static int tcp_try_undo_loss(struct sock
 
 		clear_all_retrans_hints(tp);
 
-		DBGUNDO(sk, tp, "partial loss");
+		DBGUNDO(sk, "partial loss");
 		tp->lost_out = 0;
 		tp->left_out = tp->sacked_out;
 		tcp_undo_cwr(sk, 1);
@@ -2169,8 +2188,10 @@ static inline void tcp_complete_cwr(stru
 	tcp_ca_event(sk, CA_EVENT_COMPLETE_CWR);
 }
 
-static void tcp_try_to_open(struct sock *sk, struct tcp_sock *tp, int flag)
+static void tcp_try_to_open(struct sock *sk, int flag)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
+
 	tp->left_out = tp->sacked_out;
 
 	if (tp->retrans_out == 0)
@@ -2281,7 +2302,7 @@ tcp_fastretrans_alert(struct sock *sk, u
 		switch (icsk->icsk_ca_state) {
 		case TCP_CA_Loss:
 			icsk->icsk_retransmits = 0;
-			if (tcp_try_undo_recovery(sk, tp))
+			if (tcp_try_undo_recovery(sk))
 				return;
 			break;
 
@@ -2295,7 +2316,7 @@ tcp_fastretrans_alert(struct sock *sk, u
 			break;
 
 		case TCP_CA_Disorder:
-			tcp_try_undo_dsack(sk, tp);
+			tcp_try_undo_dsack(sk);
 			if (!tp->undo_marker ||
 			    /* For SACK case do not Open to allow to undo
 			     * catching for all duplicate ACKs. */
@@ -2308,7 +2329,7 @@ tcp_fastretrans_alert(struct sock *sk, u
 		case TCP_CA_Recovery:
 			if (IsReno(tp))
 				tcp_reset_reno_sack(tp);
-			if (tcp_try_undo_recovery(sk, tp))
+			if (tcp_try_undo_recovery(sk))
 				return;
 			tcp_complete_cwr(sk);
 			break;
@@ -2324,14 +2345,14 @@ tcp_fastretrans_alert(struct sock *sk, u
 		} else {
 			int acked = prior_packets - tp->packets_out;
 			if (IsReno(tp))
-				tcp_remove_reno_sacks(sk, tp, acked);
-			is_dupack = tcp_try_undo_partial(sk, tp, acked);
+				tcp_remove_reno_sacks(sk, acked);
+			is_dupack = tcp_try_undo_partial(sk, acked);
 		}
 		break;
 	case TCP_CA_Loss:
 		if (flag&FLAG_DATA_ACKED)
 			icsk->icsk_retransmits = 0;
-		if (!tcp_try_undo_loss(sk, tp)) {
+		if (!tcp_try_undo_loss(sk)) {
 			tcp_moderate_cwnd(tp);
 			tcp_xmit_retransmit_queue(sk);
 			return;
@@ -2348,10 +2369,10 @@ tcp_fastretrans_alert(struct sock *sk, u
 		}
 
 		if (icsk->icsk_ca_state == TCP_CA_Disorder)
-			tcp_try_undo_dsack(sk, tp);
+			tcp_try_undo_dsack(sk);
 
-		if (!tcp_time_to_recover(sk, tp)) {
-			tcp_try_to_open(sk, tp, flag);
+		if (!tcp_time_to_recover(sk)) {
+			tcp_try_to_open(sk, flag);
 			return;
 		}
 
@@ -2391,8 +2412,8 @@ tcp_fastretrans_alert(struct sock *sk, u
 		fast_rexmit = 1;
 	}
 
-	if (is_dupack || (IsFack(tp) && tcp_head_timedout(sk, tp)))
-		tcp_update_scoreboard(sk, tp, mark_lost_entry_seq, fast_rexmit);
+	if (is_dupack || (IsFack(tp) && tcp_head_timedout(sk)))
+		tcp_update_scoreboard(sk, mark_lost_entry_seq, fast_rexmit);
 	tcp_cwnd_down(sk);
 	tcp_xmit_retransmit_queue(sk);
 }
@@ -2468,8 +2489,10 @@ static void tcp_cong_avoid(struct sock *
  * RFC2988 recommends to restart timer to now+rto.
  */
 
-static void tcp_ack_packets_out(struct sock *sk, struct tcp_sock *tp)
+static void tcp_ack_packets_out(struct sock *sk)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
+
 	if (!tp->packets_out) {
 		inet_csk_clear_xmit_timer(sk, ICSK_TIME_RETRANS);
 	} else {
@@ -2626,7 +2649,7 @@ static int tcp_clean_rtx_queue(struct so
 
 	if (acked&FLAG_ACKED) {
 		tcp_ack_update_rtt(sk, acked, seq_rtt);
-		tcp_ack_packets_out(sk, tp);
+		tcp_ack_packets_out(sk);
 		if (rtt_sample && !(acked & FLAG_RETRANS_DATA_ACKED))
 			(*rtt_sample)(sk, tcp_usrtt(&tv));
 
@@ -2711,9 +2734,10 @@ static inline int tcp_may_update_window(
  * Window update algorithm, described in RFC793/RFC1122 (used in linux-2.2
  * and in FreeBSD. NetBSD's one is even worse.) is wrong.
  */
-static int tcp_ack_update_window(struct sock *sk, struct tcp_sock *tp,
-				 struct sk_buff *skb, u32 ack, u32 ack_seq)
+static int tcp_ack_update_window(struct sock *sk, struct sk_buff *skb, u32 ack,
+				 u32 ack_seq)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
 	int flag = 0;
 	u32 nwin = ntohs(tcp_hdr(skb)->window);
 
@@ -2731,7 +2755,7 @@ static int tcp_ack_update_window(struct 
 			 * fast path is recovered for sending TCP.
 			 */
 			tp->pred_flags = 0;
-			tcp_fast_path_check(sk, tp);
+			tcp_fast_path_check(sk);
 
 			if (nwin > tp->max_window) {
 				tp->max_window = nwin;
@@ -2918,7 +2942,7 @@ static int tcp_ack(struct sock *sk, stru
 		else
 			NET_INC_STATS_BH(LINUX_MIB_TCPPUREACKS);
 
-		flag |= tcp_ack_update_window(sk, tp, skb, ack, ack_seq);
+		flag |= tcp_ack_update_window(sk, skb, ack, ack_seq);
 
 		if (TCP_SKB_CB(skb)->sacked)
 			flag |= tcp_sacktag_write_queue(sk, skb, prior_snd_una,
@@ -3584,7 +3608,7 @@ queue_and_out:
 		}
 		tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
 		if (skb->len)
-			tcp_event_data_recv(sk, tp, skb);
+			tcp_event_data_recv(sk, skb);
 		if (th->fin)
 			tcp_fin(skb, sk, th);
 
@@ -3601,7 +3625,7 @@ queue_and_out:
 		if (tp->rx_opt.num_sacks)
 			tcp_sack_remove(tp);
 
-		tcp_fast_path_check(sk, tp);
+		tcp_fast_path_check(sk);
 
 		if (eaten > 0)
 			__kfree_skb(skb);
@@ -3892,7 +3916,7 @@ static int tcp_prune_queue(struct sock *
 	NET_INC_STATS_BH(LINUX_MIB_PRUNECALLED);
 
 	if (atomic_read(&sk->sk_rmem_alloc) >= sk->sk_rcvbuf)
-		tcp_clamp_window(sk, tp);
+		tcp_clamp_window(sk);
 	else if (tcp_memory_pressure)
 		tp->rcv_ssthresh = min(tp->rcv_ssthresh, 4U * tp->advmss);
 
@@ -3961,8 +3985,10 @@ void tcp_cwnd_application_limited(struct
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
-static int tcp_should_expand_sndbuf(struct sock *sk, struct tcp_sock *tp)
+static int tcp_should_expand_sndbuf(struct sock *sk)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
+
 	/* If the user specified a specific send buffer setting, do
 	 * not modify it.
 	 */
@@ -3994,7 +4020,7 @@ static void tcp_new_space(struct sock *s
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	if (tcp_should_expand_sndbuf(sk, tp)) {
+	if (tcp_should_expand_sndbuf(sk)) {
 		int sndmem = max_t(u32, tp->rx_opt.mss_clamp, tp->mss_cache) +
 			MAX_TCP_HEADER + 16 + sizeof(struct sk_buff),
 		    demanded = max_t(unsigned int, tp->snd_cwnd,
@@ -4018,9 +4044,9 @@ static void tcp_check_space(struct sock 
 	}
 }
 
-static inline void tcp_data_snd_check(struct sock *sk, struct tcp_sock *tp)
+static inline void tcp_data_snd_check(struct sock *sk)
 {
-	tcp_push_pending_frames(sk, tp);
+	tcp_push_pending_frames(sk);
 	tcp_check_space(sk);
 }
 
@@ -4354,7 +4380,7 @@ int tcp_rcv_established(struct sock *sk,
 				 */
 				tcp_ack(sk, skb, 0);
 				__kfree_skb(skb);
-				tcp_data_snd_check(sk, tp);
+				tcp_data_snd_check(sk);
 				return 0;
 			} else { /* Header too small */
 				TCP_INC_STATS_BH(TCP_MIB_INERRS);
@@ -4425,12 +4451,12 @@ #endif
 				tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
 			}
 
-			tcp_event_data_recv(sk, tp, skb);
+			tcp_event_data_recv(sk, skb);
 
 			if (TCP_SKB_CB(skb)->ack_seq != tp->snd_una) {
 				/* Well, only one small jumplet in fast path... */
 				tcp_ack(sk, skb, FLAG_DATA);
-				tcp_data_snd_check(sk, tp);
+				tcp_data_snd_check(sk);
 				if (!inet_csk_ack_scheduled(sk))
 					goto no_ack;
 			}
@@ -4513,7 +4539,7 @@ step5:
 	/* step 7: process the segment text */
 	tcp_data_queue(sk, skb);
 
-	tcp_data_snd_check(sk, tp);
+	tcp_data_snd_check(sk);
 	tcp_ack_snd_check(sk);
 	return 0;
 
@@ -4830,7 +4856,7 @@ int tcp_rcv_state_process(struct sock *s
 		/* Do step6 onward by hand. */
 		tcp_urg(sk, skb, th);
 		__kfree_skb(skb);
-		tcp_data_snd_check(sk, tp);
+		tcp_data_snd_check(sk);
 		return 0;
 	}
 
@@ -5022,7 +5048,7 @@ int tcp_rcv_state_process(struct sock *s
 
 	/* tcp_data could move socket to TIME-WAIT */
 	if (sk->sk_state != TCP_CLOSE) {
-		tcp_data_snd_check(sk, tp);
+		tcp_data_snd_check(sk);
 		tcp_ack_snd_check(sk);
 	}
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index a008424..cd20b38 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -62,12 +62,13 @@ int sysctl_tcp_base_mss __read_mostly = 
 /* By default, RFC2861 behavior.  */
 int sysctl_tcp_slow_start_after_idle __read_mostly = 1;
 
-static void update_send_head(struct sock *sk, struct tcp_sock *tp,
-			     struct sk_buff *skb)
+static void update_send_head(struct sock *sk, struct sk_buff *skb)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
+
 	tcp_advance_send_head(sk, skb);
 	tp->snd_nxt = TCP_SKB_CB(skb)->end_seq;
-	tcp_packets_out_inc(sk, tp, skb);
+	tcp_packets_out_inc(sk, skb);
 }
 
 /* SND.NXT, if window was not shrunk.
@@ -76,8 +77,10 @@ static void update_send_head(struct sock
  * Anything in between SND.UNA...SND.UNA+SND.WND also can be already
  * invalid. OK, let's make this for now:
  */
-static inline __u32 tcp_acceptable_seq(struct sock *sk, struct tcp_sock *tp)
+static inline __u32 tcp_acceptable_seq(struct sock *sk)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
+
 	if (!before(tp->snd_una+tp->snd_wnd, tp->snd_nxt))
 		return tp->snd_nxt;
 	else
@@ -516,7 +519,7 @@ #ifdef CONFIG_TCP_MD5SIG
 					     md5 ? &md5_hash_location :
 #endif
 					     NULL);
-		TCP_ECN_send(sk, tp, skb, tcp_header_size);
+		TCP_ECN_send(sk, skb, tcp_header_size);
 	}
 
 #ifdef CONFIG_TCP_MD5SIG
@@ -927,8 +930,9 @@ #endif
 
 /* Congestion window validation. (RFC2861) */
 
-static void tcp_cwnd_validate(struct sock *sk, struct tcp_sock *tp)
+static void tcp_cwnd_validate(struct sock *sk)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
 	__u32 packets_out = tp->packets_out;
 
 	if (packets_out >= tp->snd_cwnd) {
@@ -1076,8 +1080,9 @@ static unsigned int tcp_snd_test(struct 
 	return cwnd_quota;
 }
 
-int tcp_may_send_now(struct sock *sk, struct tcp_sock *tp)
+int tcp_may_send_now(struct sock *sk)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb = tcp_send_head(sk);
 
 	return (skb &&
@@ -1144,8 +1149,9 @@ static int tso_fragment(struct sock *sk,
  *
  * This algorithm is from John Heffner.
  */
-static int tcp_tso_should_defer(struct sock *sk, struct tcp_sock *tp, struct sk_buff *skb)
+static int tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb)
 {
+	struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	u32 send_win, cong_win, limit, in_flight;
 
@@ -1324,7 +1330,7 @@ static int tcp_mtu_probe(struct sock *sk
 		/* Decrement cwnd here because we are sending
 		* effectively two packets. */
 		tp->snd_cwnd--;
-		update_send_head(sk, tp, nskb);
+		update_send_head(sk, nskb);
 
 		icsk->icsk_mtup.probe_size = tcp_mss_to_mtu(sk, nskb->len);
 		tp->mtu_probe.probe_seq_start = TCP_SKB_CB(nskb)->seq;
@@ -1387,7 +1393,7 @@ static int tcp_write_xmit(struct sock *s
 						      nonagle : TCP_NAGLE_PUSH))))
 				break;
 		} else {
-			if (tcp_tso_should_defer(sk, tp, skb))
+			if (tcp_tso_should_defer(sk, skb))
 				break;
 		}
 
@@ -1416,14 +1422,14 @@ static int tcp_write_xmit(struct sock *s
 		/* Advance the send_head.  This one is sent out.
 		 * This call will increment packets_out.
 		 */
-		update_send_head(sk, tp, skb);
+		update_send_head(sk, skb);
 
 		tcp_minshall_update(tp, mss_now, skb);
 		sent_pkts++;
 	}
 
 	if (likely(sent_pkts)) {
-		tcp_cwnd_validate(sk, tp);
+		tcp_cwnd_validate(sk);
 		return 0;
 	}
 	return !tp->packets_out && tcp_send_head(sk);
@@ -1433,14 +1439,14 @@ static int tcp_write_xmit(struct sock *s
  * TCP_CORK or attempt at coalescing tiny packets.
  * The socket must be locked by the caller.
  */
-void __tcp_push_pending_frames(struct sock *sk, struct tcp_sock *tp,
-			       unsigned int cur_mss, int nonagle)
+void __tcp_push_pending_frames(struct sock *sk, unsigned int cur_mss,
+			       int nonagle)
 {
 	struct sk_buff *skb = tcp_send_head(sk);
 
 	if (skb) {
 		if (tcp_write_xmit(sk, cur_mss, nonagle))
-			tcp_check_probe_timer(sk, tp);
+			tcp_check_probe_timer(sk);
 	}
 }
 
@@ -1484,8 +1490,8 @@ void tcp_push_one(struct sock *sk, unsig
 		TCP_SKB_CB(skb)->when = tcp_time_stamp;
 
 		if (likely(!tcp_transmit_skb(sk, skb, 1, sk->sk_allocation))) {
-			update_send_head(sk, tp, skb);
-			tcp_cwnd_validate(sk, tp);
+			update_send_head(sk, skb);
+			tcp_cwnd_validate(sk);
 			return;
 		}
 	}
@@ -1933,7 +1939,7 @@ void tcp_xmit_retransmit_queue(struct so
 	 * segments to send.
 	 */
 
-	if (tcp_may_send_now(sk, tp))
+	if (tcp_may_send_now(sk))
 		return;
 
 	if (tp->forward_skb_hint) {
@@ -2023,7 +2029,7 @@ void tcp_send_fin(struct sock *sk)
 		TCP_SKB_CB(skb)->end_seq = TCP_SKB_CB(skb)->seq + 1;
 		tcp_queue_skb(sk, skb);
 	}
-	__tcp_push_pending_frames(sk, tp, mss_now, TCP_NAGLE_OFF);
+	__tcp_push_pending_frames(sk, mss_now, TCP_NAGLE_OFF);
 }
 
 /* We get here when a process closes a file descriptor (either due to
@@ -2033,7 +2039,6 @@ void tcp_send_fin(struct sock *sk)
  */
 void tcp_send_active_reset(struct sock *sk, gfp_t priority)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
 
 	/* NOTE: No TCP options attached and we never retransmit this. */
@@ -2053,7 +2058,7 @@ void tcp_send_active_reset(struct sock *
 	skb_shinfo(skb)->gso_type = 0;
 
 	/* Send it off. */
-	TCP_SKB_CB(skb)->seq = tcp_acceptable_seq(sk, tp);
+	TCP_SKB_CB(skb)->seq = tcp_acceptable_seq(sk);
 	TCP_SKB_CB(skb)->end_seq = TCP_SKB_CB(skb)->seq;
 	TCP_SKB_CB(skb)->when = tcp_time_stamp;
 	if (tcp_transmit_skb(sk, skb, 0, priority))
@@ -2271,7 +2276,7 @@ int tcp_connect(struct sock *sk)
 	skb_reserve(buff, MAX_TCP_HEADER);
 
 	TCP_SKB_CB(buff)->flags = TCPCB_FLAG_SYN;
-	TCP_ECN_send_syn(sk, tp, buff);
+	TCP_ECN_send_syn(sk, buff);
 	TCP_SKB_CB(buff)->sacked = 0;
 	skb_shinfo(buff)->gso_segs = 1;
 	skb_shinfo(buff)->gso_size = 0;
@@ -2363,7 +2368,6 @@ void tcp_send_ack(struct sock *sk)
 {
 	/* If we have been reset, we may not send again. */
 	if (sk->sk_state != TCP_CLOSE) {
-		struct tcp_sock *tp = tcp_sk(sk);
 		struct sk_buff *buff;
 
 		/* We are not putting this on the write queue, so
@@ -2389,7 +2393,7 @@ void tcp_send_ack(struct sock *sk)
 		skb_shinfo(buff)->gso_type = 0;
 
 		/* Send it off, this clears delayed acks for us. */
-		TCP_SKB_CB(buff)->seq = TCP_SKB_CB(buff)->end_seq = tcp_acceptable_seq(sk, tp);
+		TCP_SKB_CB(buff)->seq = TCP_SKB_CB(buff)->end_seq = tcp_acceptable_seq(sk);
 		TCP_SKB_CB(buff)->when = tcp_time_stamp;
 		tcp_transmit_skb(sk, buff, 0, GFP_ATOMIC);
 	}
@@ -2467,7 +2471,7 @@ int tcp_write_wakeup(struct sock *sk)
 			TCP_SKB_CB(skb)->when = tcp_time_stamp;
 			err = tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
 			if (!err) {
-				update_send_head(sk, tp, skb);
+				update_send_head(sk, skb);
 			}
 			return err;
 		} else {
-- 
1.4.2
---696243703-1817580853-1176810851=:20491--
