From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6.22 1/3] [TCP]: Sed magic converts func(sk, tp, ...) -> func(sk, ...)
Date: Mon, 16 Apr 2007 15:48:46 +0300
Message-ID: <1176727728729-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33750 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030517AbXDPMsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 08:48:51 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is fully automated change using this magic:

sed -e '/struct sock \*sk/ N' -e '/struct sock \*sk/ N'
    -e '/struct sock \*sk/ N' -e '/struct sock \*sk/ N'
    -e 's|struct sock \*sk,[\n\t ]*struct tcp_sock \*tp\([^{]*\n{\n\)|
	  struct sock \*sk\1\tstruct tcp_sock *tp =3D tcp_sk(sk);\n|g'
    -e 's|struct sock \*sk, struct tcp_sock \*tp|
	  struct sock \*sk|g' -e 's|sk, tp\([^-]\)|sk\1|g'

Introduces four warnings that are fixed manually by the
following patch.

$ gcc --version
gcc (GCC) 4.1.1 20060525 (Red Hat 4.1.1-1)
=2E..
$ codiff -fV built-in.o.old built-in.o.new
net/ipv4/route.c:
  rt_cache_flush |  +14
 1 function changed, 14 bytes added

net/ipv4/tcp.c:
  tcp_setsockopt |   -5
  tcp_sendpage   |  -25
  tcp_sendmsg    |  -16
 3 functions changed, 46 bytes removed

net/ipv4/tcp_input.c:
  tcp_try_undo_recovery |   +3
  tcp_try_undo_dsack    |   +2
  tcp_mark_head_lost    |  -12
  tcp_ack               |  -15
  tcp_event_data_recv   |  -32
  tcp_rcv_state_process |  -10
  tcp_rcv_established   |   +1
 7 functions changed, 6 bytes added, 69 bytes removed, diff: -63

net/ipv4/tcp_output.c:
  update_send_head          |   -9
  tcp_transmit_skb          |  +19
  tcp_cwnd_validate         |   +1
  tcp_write_wakeup          |  -17
  __tcp_push_pending_frames |  -25
  tcp_push_one              |   -8
  tcp_send_fin              |   -4
 7 functions changed, 20 bytes added, 63 bytes removed, diff: -43

built-in.o.new:
 18 functions changed, 40 bytes added, 178 bytes removed, diff: -138

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h     |   20 ++++---
 include/net/tcp_ecn.h |    6 +-
 net/ipv4/tcp.c        |   35 +++++++------
 net/ipv4/tcp_input.c  |  131 ++++++++++++++++++++++++++++-------------=
--------
 net/ipv4/tcp_output.c |   48 ++++++++++--------
 5 files changed, 136 insertions(+), 104 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 07f724e..19cf5d5 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -420,9 +420,9 @@ extern __u32 cookie_v4_init_sequence(str
=20
 /* tcp_output.c */
=20
-extern void __tcp_push_pending_frames(struct sock *sk, struct tcp_sock=
 *tp,
+extern void __tcp_push_pending_frames(struct sock *sk,
 				      unsigned int cur_mss, int nonagle);
-extern int tcp_may_send_now(struct sock *sk, struct tcp_sock *tp);
+extern int tcp_may_send_now(struct sock *sk);
 extern int tcp_retransmit_skb(struct sock *, struct sk_buff *);
 extern void tcp_xmit_retransmit_queue(struct sock *);
 extern void tcp_simple_retransmit(struct sock *);
@@ -479,8 +479,9 @@ static inline void tcp_fast_path_on(stru
 	__tcp_fast_path_on(tp, tp->snd_wnd >> tp->rx_opt.snd_wscale);
 }
=20
-static inline void tcp_fast_path_check(struct sock *sk, struct tcp_soc=
k *tp)
+static inline void tcp_fast_path_check(struct sock *sk)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	if (skb_queue_empty(&tp->out_of_order_queue) &&
 	    tp->rcv_wnd &&
 	    atomic_read(&sk->sk_rmem_alloc) < sk->sk_rcvbuf &&
@@ -591,10 +592,10 @@ static inline void tcp_dec_pcount_approx
 	}
 }
=20
-static inline void tcp_packets_out_inc(struct sock *sk,=20
-				       struct tcp_sock *tp,
+static inline void tcp_packets_out_inc(struct sock *sk,
 				       const struct sk_buff *skb)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	int orig =3D tp->packets_out;
=20
 	tp->packets_out +=3D tcp_skb_pcount(skb);
@@ -778,18 +779,19 @@ static inline void tcp_minshall_update(s
 		tp->snd_sml =3D TCP_SKB_CB(skb)->end_seq;
 }
=20
-static inline void tcp_check_probe_timer(struct sock *sk, struct tcp_s=
ock *tp)
+static inline void tcp_check_probe_timer(struct sock *sk)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	const struct inet_connection_sock *icsk =3D inet_csk(sk);
 	if (!tp->packets_out && !icsk->icsk_pending)
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_PROBE0,
 					  icsk->icsk_rto, TCP_RTO_MAX);
 }
=20
-static inline void tcp_push_pending_frames(struct sock *sk,
-					   struct tcp_sock *tp)
+static inline void tcp_push_pending_frames(struct sock *sk)
 {
-	__tcp_push_pending_frames(sk, tp, tcp_current_mss(sk, 1), tp->nonagle=
);
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	__tcp_push_pending_frames(sk, tcp_current_mss(sk, 1), tp->nonagle);
 }
=20
 static inline void tcp_init_wl(struct tcp_sock *tp, u32 ack, u32 seq)
diff --git a/include/net/tcp_ecn.h b/include/net/tcp_ecn.h
index b5f7c6a..f3043d2 100644
--- a/include/net/tcp_ecn.h
+++ b/include/net/tcp_ecn.h
@@ -27,9 +27,10 @@ static inline void TCP_ECN_send_synack(s
 		TCP_SKB_CB(skb)->flags &=3D ~TCPCB_FLAG_ECE;
 }
=20
-static inline void TCP_ECN_send_syn(struct sock *sk, struct tcp_sock *=
tp,
+static inline void TCP_ECN_send_syn(struct sock *sk,
 				    struct sk_buff *skb)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	tp->ecn_flags =3D 0;
 	if (sysctl_tcp_ecn) {
 		TCP_SKB_CB(skb)->flags |=3D TCPCB_FLAG_ECE|TCPCB_FLAG_CWR;
@@ -44,9 +45,10 @@ TCP_ECN_make_synack(struct request_sock=20
 		th->ece =3D 1;
 }
=20
-static inline void TCP_ECN_send(struct sock *sk, struct tcp_sock *tp,
+static inline void TCP_ECN_send(struct sock *sk,
 				struct sk_buff *skb, int tcp_header_len)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	if (tp->ecn_flags & TCP_ECN_OK) {
 		/* Not-retransmitted data segment: set ECT and inject CWR. */
 		if (skb->len !=3D tcp_header_len &&
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index bb9d91a..4d690dd 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -460,9 +460,10 @@ static inline int forced_push(struct tcp
 	return after(tp->write_seq, tp->pushed_seq + (tp->max_window >> 1));
 }
=20
-static inline void skb_entail(struct sock *sk, struct tcp_sock *tp,
+static inline void skb_entail(struct sock *sk,
 			      struct sk_buff *skb)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct tcp_skb_cb *tcb =3D TCP_SKB_CB(skb);
=20
 	skb->csum    =3D 0;
@@ -486,15 +487,16 @@ static inline void tcp_mark_urg(struct t
 	}
 }
=20
-static inline void tcp_push(struct sock *sk, struct tcp_sock *tp, int =
flags,
+static inline void tcp_push(struct sock *sk, int flags,
 			    int mss_now, int nonagle)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	if (tcp_send_head(sk)) {
 		struct sk_buff *skb =3D tcp_write_queue_tail(sk);
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
=20
-			skb_entail(sk, tp, skb);
+			skb_entail(sk, skb);
 			copy =3D size_goal;
 		}
=20
@@ -586,7 +588,7 @@ new_segment:
=20
 		if (forced_push(tp)) {
 			tcp_mark_push(tp, skb);
-			__tcp_push_pending_frames(sk, tp, mss_now, TCP_NAGLE_PUSH);
+			__tcp_push_pending_frames(sk, mss_now, TCP_NAGLE_PUSH);
 		} else if (skb =3D=3D tcp_send_head(sk))
 			tcp_push_one(sk, mss_now);
 		continue;
@@ -595,7 +597,7 @@ wait_for_sndbuf:
 		set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 wait_for_memory:
 		if (copied)
-			tcp_push(sk, tp, flags & ~MSG_MORE, mss_now, TCP_NAGLE_PUSH);
+			tcp_push(sk, flags & ~MSG_MORE, mss_now, TCP_NAGLE_PUSH);
=20
 		if ((err =3D sk_stream_wait_memory(sk, &timeo)) !=3D 0)
 			goto do_error;
@@ -606,7 +608,7 @@ wait_for_memory:
=20
 out:
 	if (copied)
-		tcp_push(sk, tp, flags, mss_now, tp->nonagle);
+		tcp_push(sk, flags, mss_now, tp->nonagle);
 	return copied;
=20
 do_error:
@@ -637,8 +639,9 @@ ssize_t tcp_sendpage(struct socket *sock
 #define TCP_PAGE(sk)	(sk->sk_sndmsg_page)
 #define TCP_OFF(sk)	(sk->sk_sndmsg_off)
=20
-static inline int select_size(struct sock *sk, struct tcp_sock *tp)
+static inline int select_size(struct sock *sk)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	int tmp =3D tp->mss_cache;
=20
 	if (sk->sk_route_caps & NETIF_F_SG) {
@@ -714,7 +717,7 @@ new_segment:
 				if (!sk_stream_memory_free(sk))
 					goto wait_for_sndbuf;
=20
-				skb =3D sk_stream_alloc_pskb(sk, select_size(sk, tp),
+				skb =3D sk_stream_alloc_pskb(sk, select_size(sk),
 							   0, sk->sk_allocation);
 				if (!skb)
 					goto wait_for_memory;
@@ -725,7 +728,7 @@ new_segment:
 				if (sk->sk_route_caps & NETIF_F_ALL_CSUM)
 					skb->ip_summed =3D CHECKSUM_PARTIAL;
=20
-				skb_entail(sk, tp, skb);
+				skb_entail(sk, skb);
 				copy =3D size_goal;
 			}
=20
@@ -830,7 +833,7 @@ new_segment:
=20
 			if (forced_push(tp)) {
 				tcp_mark_push(tp, skb);
-				__tcp_push_pending_frames(sk, tp, mss_now, TCP_NAGLE_PUSH);
+				__tcp_push_pending_frames(sk, mss_now, TCP_NAGLE_PUSH);
 			} else if (skb =3D=3D tcp_send_head(sk))
 				tcp_push_one(sk, mss_now);
 			continue;
@@ -839,7 +842,7 @@ wait_for_sndbuf:
 			set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 wait_for_memory:
 			if (copied)
-				tcp_push(sk, tp, flags & ~MSG_MORE, mss_now, TCP_NAGLE_PUSH);
+				tcp_push(sk, flags & ~MSG_MORE, mss_now, TCP_NAGLE_PUSH);
=20
 			if ((err =3D sk_stream_wait_memory(sk, &timeo)) !=3D 0)
 				goto do_error;
@@ -851,7 +854,7 @@ wait_for_memory:
=20
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
 			tp->urg_data =3D 0;
-			tcp_fast_path_check(sk, tp);
+			tcp_fast_path_check(sk);
 		}
 		if (used + offset < skb->len)
 			continue;
@@ -1830,7 +1833,7 @@ static int do_tcp_setsockopt(struct sock
 			 * for currently queued segments.
 			 */
 			tp->nonagle |=3D TCP_NAGLE_OFF|TCP_NAGLE_PUSH;
-			tcp_push_pending_frames(sk, tp);
+			tcp_push_pending_frames(sk);
 		} else {
 			tp->nonagle &=3D ~TCP_NAGLE_OFF;
 		}
@@ -1854,7 +1857,7 @@ static int do_tcp_setsockopt(struct sock
 			tp->nonagle &=3D ~TCP_NAGLE_CORK;
 			if (tp->nonagle&TCP_NAGLE_OFF)
 				tp->nonagle |=3D TCP_NAGLE_PUSH;
-			tcp_push_pending_frames(sk, tp);
+			tcp_push_pending_frames(sk);
 		}
 		break;
=20
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d1604f5..cd167a5 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -235,9 +235,10 @@ static void tcp_fixup_sndbuf(struct sock
  */
=20
 /* Slow part of check#2. */
-static int __tcp_grow_window(const struct sock *sk, struct tcp_sock *t=
p,
+static int __tcp_grow_window(const struct sock *sk,
 			     const struct sk_buff *skb)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	/* Optimize this! */
 	int truesize =3D tcp_win_from_space(skb->truesize)/2;
 	int window =3D tcp_win_from_space(sysctl_tcp_rmem[2])/2;
@@ -252,9 +253,10 @@ static int __tcp_grow_window(const struc
 	return 0;
 }
=20
-static void tcp_grow_window(struct sock *sk, struct tcp_sock *tp,
+static void tcp_grow_window(struct sock *sk,
 			    struct sk_buff *skb)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	/* Check #1 */
 	if (tp->rcv_ssthresh < tp->window_clamp &&
 	    (int)tp->rcv_ssthresh < tcp_space(sk) &&
@@ -267,7 +269,7 @@ static void tcp_grow_window(struct sock=20
 		if (tcp_win_from_space(skb->truesize) <=3D skb->len)
 			incr =3D 2*tp->advmss;
 		else
-			incr =3D __tcp_grow_window(sk, tp, skb);
+			incr =3D __tcp_grow_window(sk, skb);
=20
 		if (incr) {
 			tp->rcv_ssthresh =3D min(tp->rcv_ssthresh + incr, tp->window_clamp)=
;
@@ -330,8 +332,9 @@ static void tcp_init_buffer_space(struct
 }
=20
 /* 5. Recalculate window clamp after socket hit its memory bounds. */
-static void tcp_clamp_window(struct sock *sk, struct tcp_sock *tp)
+static void tcp_clamp_window(struct sock *sk)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct inet_connection_sock *icsk =3D inet_csk(sk);
=20
 	icsk->icsk_ack.quick =3D 0;
@@ -503,8 +506,9 @@ new_measure:
  * each ACK we send, he increments snd_cwnd and transmits more of his
  * queue.  -DaveM
  */
-static void tcp_event_data_recv(struct sock *sk, struct tcp_sock *tp, =
struct sk_buff *skb)
+static void tcp_event_data_recv(struct sock *sk, struct sk_buff *skb)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct inet_connection_sock *icsk =3D inet_csk(sk);
 	u32 now;
=20
@@ -545,7 +549,7 @@ static void tcp_event_data_recv(struct s
 	TCP_ECN_check_ce(tp, skb);
=20
 	if (skb->len >=3D 128)
-		tcp_grow_window(sk, tp, skb);
+		tcp_grow_window(sk, skb);
 }
=20
 /* Called to compute a smoothed rtt estimate. The data fed to this
@@ -1541,8 +1545,9 @@ static inline int tcp_skb_timedout(struc
 	return (tcp_time_stamp - TCP_SKB_CB(skb)->when > inet_csk(sk)->icsk_r=
to);
 }
=20
-static inline int tcp_head_timedout(struct sock *sk, struct tcp_sock *=
tp)
+static inline int tcp_head_timedout(struct sock *sk)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	return tp->packets_out &&
 	       tcp_skb_timedout(sk, tcp_write_queue_head(sk));
 }
@@ -1640,8 +1645,9 @@ static inline int tcp_head_timedout(stru
  * Main question: may we further continue forward transmission
  * with the same cwnd?
  */
-static int tcp_time_to_recover(struct sock *sk, struct tcp_sock *tp)
+static int tcp_time_to_recover(struct sock *sk)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	__u32 packets_out;
=20
 	/* Do not perform any recovery during FRTO algorithm */
@@ -1659,7 +1665,7 @@ static int tcp_time_to_recover(struct so
 	/* Trick#3 : when we use RFC2988 timer restart, fast
 	 * retransmit can be triggered by timeout of queue head.
 	 */
-	if (tcp_head_timedout(sk, tp))
+	if (tcp_head_timedout(sk))
 		return 1;
=20
 	/* Trick#4: It is still not OK... But will it be useful to delay
@@ -1668,7 +1674,7 @@ static int tcp_time_to_recover(struct so
 	packets_out =3D tp->packets_out;
 	if (packets_out <=3D tp->reordering &&
 	    tp->sacked_out >=3D max_t(__u32, packets_out/2, sysctl_tcp_reorde=
ring) &&
-	    !tcp_may_send_now(sk, tp)) {
+	    !tcp_may_send_now(sk)) {
 		/* We have nothing to send. This connection is limited
 		 * either by receiver window or by application.
 		 */
@@ -1708,8 +1714,9 @@ static void tcp_add_reno_sack(struct soc
=20
 /* Account for ACK, ACKing some data in Reno Recovery phase. */
=20
-static void tcp_remove_reno_sacks(struct sock *sk, struct tcp_sock *tp=
, int acked)
+static void tcp_remove_reno_sacks(struct sock *sk, int acked)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	if (acked > 0) {
 		/* One ACK acked hole. The rest eat duplicate ACKs. */
 		if (acked-1 >=3D tp->sacked_out)
@@ -1728,9 +1735,10 @@ static inline void tcp_reset_reno_sack(s
 }
=20
 /* Mark head of queue up as lost. */
-static void tcp_mark_head_lost(struct sock *sk, struct tcp_sock *tp,
+static void tcp_mark_head_lost(struct sock *sk,
 			       int packets, u32 high_seq)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *skb;
 	int cnt;
=20
@@ -1771,15 +1779,16 @@ static void tcp_mark_head_lost(struct so
=20
 /* Account newly detected lost packet(s) */
=20
-static void tcp_update_scoreboard(struct sock *sk, struct tcp_sock *tp=
)
+static void tcp_update_scoreboard(struct sock *sk)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	if (IsFack(tp)) {
 		int lost =3D tp->fackets_out - tp->reordering;
 		if (lost <=3D 0)
 			lost =3D 1;
-		tcp_mark_head_lost(sk, tp, lost, tp->high_seq);
+		tcp_mark_head_lost(sk, lost, tp->high_seq);
 	} else {
-		tcp_mark_head_lost(sk, tp, 1, tp->high_seq);
+		tcp_mark_head_lost(sk, 1, tp->high_seq);
 	}
=20
 	/* New heuristics: it is possible only after we switched
@@ -1787,7 +1796,7 @@ static void tcp_update_scoreboard(struct
 	 * Hence, we can detect timed out packets during fast
 	 * retransmit without falling to slow start.
 	 */
-	if (!IsReno(tp) && tcp_head_timedout(sk, tp)) {
+	if (!IsReno(tp) && tcp_head_timedout(sk)) {
 		struct sk_buff *skb;
=20
 		skb =3D tp->scoreboard_skb_hint ? tp->scoreboard_skb_hint
@@ -1867,8 +1876,9 @@ static inline int tcp_packet_delayed(str
 /* Undo procedures. */
=20
 #if FASTRETRANS_DEBUG > 1
-static void DBGUNDO(struct sock *sk, struct tcp_sock *tp, const char *=
msg)
+static void DBGUNDO(struct sock *sk, const char *msg)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct inet_sock *inet =3D inet_sk(sk);
 	printk(KERN_DEBUG "Undo %s %u.%u.%u.%u/%u c%u l%u ss%u/%u p%u\n",
 	       msg,
@@ -1915,13 +1925,14 @@ static inline int tcp_may_undo(struct tc
 }
=20
 /* People celebrate: "We love our President!" */
-static int tcp_try_undo_recovery(struct sock *sk, struct tcp_sock *tp)
+static int tcp_try_undo_recovery(struct sock *sk)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	if (tcp_may_undo(tp)) {
 		/* Happy end! We did not retransmit anything
 		 * or our original transmission succeeded.
 		 */
-		DBGUNDO(sk, tp, inet_csk(sk)->icsk_ca_state =3D=3D TCP_CA_Loss ? "lo=
ss" : "retrans");
+		DBGUNDO(sk, inet_csk(sk)->icsk_ca_state =3D=3D TCP_CA_Loss ? "loss" =
: "retrans");
 		tcp_undo_cwr(sk, 1);
 		if (inet_csk(sk)->icsk_ca_state =3D=3D TCP_CA_Loss)
 			NET_INC_STATS_BH(LINUX_MIB_TCPLOSSUNDO);
@@ -1941,10 +1952,11 @@ static int tcp_try_undo_recovery(struct=20
 }
=20
 /* Try to undo cwnd reduction, because D-SACKs acked all retransmitted=
 data */
-static void tcp_try_undo_dsack(struct sock *sk, struct tcp_sock *tp)
+static void tcp_try_undo_dsack(struct sock *sk)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	if (tp->undo_marker && !tp->undo_retrans) {
-		DBGUNDO(sk, tp, "D-SACK");
+		DBGUNDO(sk, "D-SACK");
 		tcp_undo_cwr(sk, 1);
 		tp->undo_marker =3D 0;
 		NET_INC_STATS_BH(LINUX_MIB_TCPDSACKUNDO);
@@ -1953,9 +1965,10 @@ static void tcp_try_undo_dsack(struct so
=20
 /* Undo during fast recovery after partial ACK. */
=20
-static int tcp_try_undo_partial(struct sock *sk, struct tcp_sock *tp,
+static int tcp_try_undo_partial(struct sock *sk,
 				int acked)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	/* Partial ACK arrived. Force Hoe's retransmit. */
 	int failed =3D IsReno(tp) || tp->fackets_out>tp->reordering;
=20
@@ -1968,7 +1981,7 @@ static int tcp_try_undo_partial(struct s
=20
 		tcp_update_reordering(sk, tcp_fackets_out(tp) + acked, 1);
=20
-		DBGUNDO(sk, tp, "Hoe");
+		DBGUNDO(sk, "Hoe");
 		tcp_undo_cwr(sk, 0);
 		NET_INC_STATS_BH(LINUX_MIB_TCPPARTIALUNDO);
=20
@@ -1982,8 +1995,9 @@ static int tcp_try_undo_partial(struct s
 }
=20
 /* Undo during loss recovery after partial ACK. */
-static int tcp_try_undo_loss(struct sock *sk, struct tcp_sock *tp)
+static int tcp_try_undo_loss(struct sock *sk)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	if (tcp_may_undo(tp)) {
 		struct sk_buff *skb;
 		tcp_for_write_queue(skb, sk) {
@@ -1994,7 +2008,7 @@ static int tcp_try_undo_loss(struct sock
=20
 		clear_all_retrans_hints(tp);
=20
-		DBGUNDO(sk, tp, "partial loss");
+		DBGUNDO(sk, "partial loss");
 		tp->lost_out =3D 0;
 		tp->left_out =3D tp->sacked_out;
 		tcp_undo_cwr(sk, 1);
@@ -2016,8 +2030,9 @@ static inline void tcp_complete_cwr(stru
 	tcp_ca_event(sk, CA_EVENT_COMPLETE_CWR);
 }
=20
-static void tcp_try_to_open(struct sock *sk, struct tcp_sock *tp, int =
flag)
+static void tcp_try_to_open(struct sock *sk, int flag)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	tp->left_out =3D tp->sacked_out;
=20
 	if (tp->retrans_out =3D=3D 0)
@@ -2111,7 +2126,7 @@ tcp_fastretrans_alert(struct sock *sk, u
 	    before(tp->snd_una, tp->high_seq) &&
 	    icsk->icsk_ca_state !=3D TCP_CA_Open &&
 	    tp->fackets_out > tp->reordering) {
-		tcp_mark_head_lost(sk, tp, tp->fackets_out-tp->reordering, tp->high_=
seq);
+		tcp_mark_head_lost(sk, tp->fackets_out-tp->reordering, tp->high_seq)=
;
 		NET_INC_STATS_BH(LINUX_MIB_TCPLOSS);
 	}
=20
@@ -2127,7 +2142,7 @@ tcp_fastretrans_alert(struct sock *sk, u
 		switch (icsk->icsk_ca_state) {
 		case TCP_CA_Loss:
 			icsk->icsk_retransmits =3D 0;
-			if (tcp_try_undo_recovery(sk, tp))
+			if (tcp_try_undo_recovery(sk))
 				return;
 			break;
=20
@@ -2141,7 +2156,7 @@ tcp_fastretrans_alert(struct sock *sk, u
 			break;
=20
 		case TCP_CA_Disorder:
-			tcp_try_undo_dsack(sk, tp);
+			tcp_try_undo_dsack(sk);
 			if (!tp->undo_marker ||
 			    /* For SACK case do not Open to allow to undo
 			     * catching for all duplicate ACKs. */
@@ -2154,7 +2169,7 @@ tcp_fastretrans_alert(struct sock *sk, u
 		case TCP_CA_Recovery:
 			if (IsReno(tp))
 				tcp_reset_reno_sack(tp);
-			if (tcp_try_undo_recovery(sk, tp))
+			if (tcp_try_undo_recovery(sk))
 				return;
 			tcp_complete_cwr(sk);
 			break;
@@ -2170,14 +2185,14 @@ tcp_fastretrans_alert(struct sock *sk, u
 		} else {
 			int acked =3D prior_packets - tp->packets_out;
 			if (IsReno(tp))
-				tcp_remove_reno_sacks(sk, tp, acked);
-			is_dupack =3D tcp_try_undo_partial(sk, tp, acked);
+				tcp_remove_reno_sacks(sk, acked);
+			is_dupack =3D tcp_try_undo_partial(sk, acked);
 		}
 		break;
 	case TCP_CA_Loss:
 		if (flag&FLAG_DATA_ACKED)
 			icsk->icsk_retransmits =3D 0;
-		if (!tcp_try_undo_loss(sk, tp)) {
+		if (!tcp_try_undo_loss(sk)) {
 			tcp_moderate_cwnd(tp);
 			tcp_xmit_retransmit_queue(sk);
 			return;
@@ -2194,10 +2209,10 @@ tcp_fastretrans_alert(struct sock *sk, u
 		}
=20
 		if (icsk->icsk_ca_state =3D=3D TCP_CA_Disorder)
-			tcp_try_undo_dsack(sk, tp);
+			tcp_try_undo_dsack(sk);
=20
-		if (!tcp_time_to_recover(sk, tp)) {
-			tcp_try_to_open(sk, tp, flag);
+		if (!tcp_time_to_recover(sk)) {
+			tcp_try_to_open(sk, flag);
 			return;
 		}
=20
@@ -2236,8 +2251,8 @@ tcp_fastretrans_alert(struct sock *sk, u
 		tcp_set_ca_state(sk, TCP_CA_Recovery);
 	}
=20
-	if (is_dupack || tcp_head_timedout(sk, tp))
-		tcp_update_scoreboard(sk, tp);
+	if (is_dupack || tcp_head_timedout(sk))
+		tcp_update_scoreboard(sk);
 	tcp_cwnd_down(sk);
 	tcp_xmit_retransmit_queue(sk);
 }
@@ -2313,8 +2328,9 @@ static void tcp_cong_avoid(struct sock *
  * RFC2988 recommends to restart timer to now+rto.
  */
=20
-static void tcp_ack_packets_out(struct sock *sk, struct tcp_sock *tp)
+static void tcp_ack_packets_out(struct sock *sk)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	if (!tp->packets_out) {
 		inet_csk_clear_xmit_timer(sk, ICSK_TIME_RETRANS);
 	} else {
@@ -2471,7 +2487,7 @@ static int tcp_clean_rtx_queue(struct so
=20
 	if (acked&FLAG_ACKED) {
 		tcp_ack_update_rtt(sk, acked, seq_rtt);
-		tcp_ack_packets_out(sk, tp);
+		tcp_ack_packets_out(sk);
 		if (rtt_sample && !(acked & FLAG_RETRANS_DATA_ACKED))
 			(*rtt_sample)(sk, tcp_usrtt(&tv));
=20
@@ -2556,9 +2572,10 @@ static inline int tcp_may_update_window(
  * Window update algorithm, described in RFC793/RFC1122 (used in linux=
-2.2
  * and in FreeBSD. NetBSD's one is even worse.) is wrong.
  */
-static int tcp_ack_update_window(struct sock *sk, struct tcp_sock *tp,
+static int tcp_ack_update_window(struct sock *sk,
 				 struct sk_buff *skb, u32 ack, u32 ack_seq)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	int flag =3D 0;
 	u32 nwin =3D ntohs(tcp_hdr(skb)->window);
=20
@@ -2576,7 +2593,7 @@ static int tcp_ack_update_window(struct=20
 			 * fast path is recovered for sending TCP.
 			 */
 			tp->pred_flags =3D 0;
-			tcp_fast_path_check(sk, tp);
+			tcp_fast_path_check(sk);
=20
 			if (nwin > tp->max_window) {
 				tp->max_window =3D nwin;
@@ -2762,7 +2779,7 @@ static int tcp_ack(struct sock *sk, stru
 		else
 			NET_INC_STATS_BH(LINUX_MIB_TCPPUREACKS);
=20
-		flag |=3D tcp_ack_update_window(sk, tp, skb, ack, ack_seq);
+		flag |=3D tcp_ack_update_window(sk, skb, ack, ack_seq);
=20
 		if (TCP_SKB_CB(skb)->sacked)
 			flag |=3D tcp_sacktag_write_queue(sk, skb, prior_snd_una);
@@ -3425,7 +3442,7 @@ queue_and_out:
 		}
 		tp->rcv_nxt =3D TCP_SKB_CB(skb)->end_seq;
 		if (skb->len)
-			tcp_event_data_recv(sk, tp, skb);
+			tcp_event_data_recv(sk, skb);
 		if (th->fin)
 			tcp_fin(skb, sk, th);
=20
@@ -3442,7 +3459,7 @@ queue_and_out:
 		if (tp->rx_opt.num_sacks)
 			tcp_sack_remove(tp);
=20
-		tcp_fast_path_check(sk, tp);
+		tcp_fast_path_check(sk);
=20
 		if (eaten > 0)
 			__kfree_skb(skb);
@@ -3733,7 +3750,7 @@ static int tcp_prune_queue(struct sock *
 	NET_INC_STATS_BH(LINUX_MIB_PRUNECALLED);
=20
 	if (atomic_read(&sk->sk_rmem_alloc) >=3D sk->sk_rcvbuf)
-		tcp_clamp_window(sk, tp);
+		tcp_clamp_window(sk);
 	else if (tcp_memory_pressure)
 		tp->rcv_ssthresh =3D min(tp->rcv_ssthresh, 4U * tp->advmss);
=20
@@ -3802,8 +3819,9 @@ void tcp_cwnd_application_limited(struct
 	tp->snd_cwnd_stamp =3D tcp_time_stamp;
 }
=20
-static int tcp_should_expand_sndbuf(struct sock *sk, struct tcp_sock *=
tp)
+static int tcp_should_expand_sndbuf(struct sock *sk)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	/* If the user specified a specific send buffer setting, do
 	 * not modify it.
 	 */
@@ -3835,7 +3853,7 @@ static void tcp_new_space(struct sock *s
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
=20
-	if (tcp_should_expand_sndbuf(sk, tp)) {
+	if (tcp_should_expand_sndbuf(sk)) {
 		int sndmem =3D max_t(u32, tp->rx_opt.mss_clamp, tp->mss_cache) +
 			MAX_TCP_HEADER + 16 + sizeof(struct sk_buff),
 		    demanded =3D max_t(unsigned int, tp->snd_cwnd,
@@ -3859,9 +3877,10 @@ static void tcp_check_space(struct sock=20
 	}
 }
=20
-static inline void tcp_data_snd_check(struct sock *sk, struct tcp_sock=
 *tp)
+static inline void tcp_data_snd_check(struct sock *sk)
 {
-	tcp_push_pending_frames(sk, tp);
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	tcp_push_pending_frames(sk);
 	tcp_check_space(sk);
 }
=20
@@ -4195,7 +4214,7 @@ int tcp_rcv_established(struct sock *sk,
 				 */
 				tcp_ack(sk, skb, 0);
 				__kfree_skb(skb);
-				tcp_data_snd_check(sk, tp);
+				tcp_data_snd_check(sk);
 				return 0;
 			} else { /* Header too small */
 				TCP_INC_STATS_BH(TCP_MIB_INERRS);
@@ -4266,12 +4285,12 @@ #endif
 				tp->rcv_nxt =3D TCP_SKB_CB(skb)->end_seq;
 			}
=20
-			tcp_event_data_recv(sk, tp, skb);
+			tcp_event_data_recv(sk, skb);
=20
 			if (TCP_SKB_CB(skb)->ack_seq !=3D tp->snd_una) {
 				/* Well, only one small jumplet in fast path... */
 				tcp_ack(sk, skb, FLAG_DATA);
-				tcp_data_snd_check(sk, tp);
+				tcp_data_snd_check(sk);
 				if (!inet_csk_ack_scheduled(sk))
 					goto no_ack;
 			}
@@ -4354,7 +4373,7 @@ step5:
 	/* step 7: process the segment text */
 	tcp_data_queue(sk, skb);
=20
-	tcp_data_snd_check(sk, tp);
+	tcp_data_snd_check(sk);
 	tcp_ack_snd_check(sk);
 	return 0;
=20
@@ -4671,7 +4690,7 @@ int tcp_rcv_state_process(struct sock *s
 		/* Do step6 onward by hand. */
 		tcp_urg(sk, skb, th);
 		__kfree_skb(skb);
-		tcp_data_snd_check(sk, tp);
+		tcp_data_snd_check(sk);
 		return 0;
 	}
=20
@@ -4863,7 +4882,7 @@ int tcp_rcv_state_process(struct sock *s
=20
 	/* tcp_data could move socket to TIME-WAIT */
 	if (sk->sk_state !=3D TCP_CLOSE) {
-		tcp_data_snd_check(sk, tp);
+		tcp_data_snd_check(sk);
 		tcp_ack_snd_check(sk);
 	}
=20
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 94d9f0c..473ec06 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -62,12 +62,13 @@ int sysctl_tcp_base_mss __read_mostly =3D=20
 /* By default, RFC2861 behavior.  */
 int sysctl_tcp_slow_start_after_idle __read_mostly =3D 1;
=20
-static void update_send_head(struct sock *sk, struct tcp_sock *tp,
+static void update_send_head(struct sock *sk,
 			     struct sk_buff *skb)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	tcp_advance_send_head(sk, skb);
 	tp->snd_nxt =3D TCP_SKB_CB(skb)->end_seq;
-	tcp_packets_out_inc(sk, tp, skb);
+	tcp_packets_out_inc(sk, skb);
 }
=20
 /* SND.NXT, if window was not shrunk.
@@ -76,8 +77,9 @@ static void update_send_head(struct sock
  * Anything in between SND.UNA...SND.UNA+SND.WND also can be already
  * invalid. OK, let's make this for now:
  */
-static inline __u32 tcp_acceptable_seq(struct sock *sk, struct tcp_soc=
k *tp)
+static inline __u32 tcp_acceptable_seq(struct sock *sk)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	if (!before(tp->snd_una+tp->snd_wnd, tp->snd_nxt))
 		return tp->snd_nxt;
 	else
@@ -516,7 +518,7 @@ #ifdef CONFIG_TCP_MD5SIG
 					     md5 ? &md5_hash_location :
 #endif
 					     NULL);
-		TCP_ECN_send(sk, tp, skb, tcp_header_size);
+		TCP_ECN_send(sk, skb, tcp_header_size);
 	}
=20
 #ifdef CONFIG_TCP_MD5SIG
@@ -927,8 +929,9 @@ #endif
=20
 /* Congestion window validation. (RFC2861) */
=20
-static void tcp_cwnd_validate(struct sock *sk, struct tcp_sock *tp)
+static void tcp_cwnd_validate(struct sock *sk)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	__u32 packets_out =3D tp->packets_out;
=20
 	if (packets_out >=3D tp->snd_cwnd) {
@@ -1076,8 +1079,9 @@ static unsigned int tcp_snd_test(struct=20
 	return cwnd_quota;
 }
=20
-int tcp_may_send_now(struct sock *sk, struct tcp_sock *tp)
+int tcp_may_send_now(struct sock *sk)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *skb =3D tcp_send_head(sk);
=20
 	return (skb &&
@@ -1144,8 +1148,9 @@ static int tso_fragment(struct sock *sk,
  *
  * This algorithm is from John Heffner.
  */
-static int tcp_tso_should_defer(struct sock *sk, struct tcp_sock *tp, =
struct sk_buff *skb)
+static int tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	const struct inet_connection_sock *icsk =3D inet_csk(sk);
 	u32 send_win, cong_win, limit, in_flight;
=20
@@ -1324,7 +1329,7 @@ static int tcp_mtu_probe(struct sock *sk
 		/* Decrement cwnd here because we are sending
 		* effectively two packets. */
 		tp->snd_cwnd--;
-		update_send_head(sk, tp, nskb);
+		update_send_head(sk, nskb);
=20
 		icsk->icsk_mtup.probe_size =3D tcp_mss_to_mtu(sk, nskb->len);
 		tp->mtu_probe.probe_seq_start =3D TCP_SKB_CB(nskb)->seq;
@@ -1387,7 +1392,7 @@ static int tcp_write_xmit(struct sock *s
 						      nonagle : TCP_NAGLE_PUSH))))
 				break;
 		} else {
-			if (tcp_tso_should_defer(sk, tp, skb))
+			if (tcp_tso_should_defer(sk, skb))
 				break;
 		}
=20
@@ -1416,14 +1421,14 @@ static int tcp_write_xmit(struct sock *s
 		/* Advance the send_head.  This one is sent out.
 		 * This call will increment packets_out.
 		 */
-		update_send_head(sk, tp, skb);
+		update_send_head(sk, skb);
=20
 		tcp_minshall_update(tp, mss_now, skb);
 		sent_pkts++;
 	}
=20
 	if (likely(sent_pkts)) {
-		tcp_cwnd_validate(sk, tp);
+		tcp_cwnd_validate(sk);
 		return 0;
 	}
 	return !tp->packets_out && tcp_send_head(sk);
@@ -1433,14 +1438,15 @@ static int tcp_write_xmit(struct sock *s
  * TCP_CORK or attempt at coalescing tiny packets.
  * The socket must be locked by the caller.
  */
-void __tcp_push_pending_frames(struct sock *sk, struct tcp_sock *tp,
+void __tcp_push_pending_frames(struct sock *sk,
 			       unsigned int cur_mss, int nonagle)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *skb =3D tcp_send_head(sk);
=20
 	if (skb) {
 		if (tcp_write_xmit(sk, cur_mss, nonagle))
-			tcp_check_probe_timer(sk, tp);
+			tcp_check_probe_timer(sk);
 	}
 }
=20
@@ -1484,8 +1490,8 @@ void tcp_push_one(struct sock *sk, unsig
 		TCP_SKB_CB(skb)->when =3D tcp_time_stamp;
=20
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
=20
-	if (tcp_may_send_now(sk, tp))
+	if (tcp_may_send_now(sk))
 		return;
=20
 	if (tp->forward_skb_hint) {
@@ -2023,7 +2029,7 @@ void tcp_send_fin(struct sock *sk)
 		TCP_SKB_CB(skb)->end_seq =3D TCP_SKB_CB(skb)->seq + 1;
 		tcp_queue_skb(sk, skb);
 	}
-	__tcp_push_pending_frames(sk, tp, mss_now, TCP_NAGLE_OFF);
+	__tcp_push_pending_frames(sk, mss_now, TCP_NAGLE_OFF);
 }
=20
 /* We get here when a process closes a file descriptor (either due to
@@ -2053,7 +2059,7 @@ void tcp_send_active_reset(struct sock *
 	skb_shinfo(skb)->gso_type =3D 0;
=20
 	/* Send it off. */
-	TCP_SKB_CB(skb)->seq =3D tcp_acceptable_seq(sk, tp);
+	TCP_SKB_CB(skb)->seq =3D tcp_acceptable_seq(sk);
 	TCP_SKB_CB(skb)->end_seq =3D TCP_SKB_CB(skb)->seq;
 	TCP_SKB_CB(skb)->when =3D tcp_time_stamp;
 	if (tcp_transmit_skb(sk, skb, 0, priority))
@@ -2271,7 +2277,7 @@ int tcp_connect(struct sock *sk)
 	skb_reserve(buff, MAX_TCP_HEADER);
=20
 	TCP_SKB_CB(buff)->flags =3D TCPCB_FLAG_SYN;
-	TCP_ECN_send_syn(sk, tp, buff);
+	TCP_ECN_send_syn(sk, buff);
 	TCP_SKB_CB(buff)->sacked =3D 0;
 	skb_shinfo(buff)->gso_segs =3D 1;
 	skb_shinfo(buff)->gso_size =3D 0;
@@ -2389,7 +2395,7 @@ void tcp_send_ack(struct sock *sk)
 		skb_shinfo(buff)->gso_type =3D 0;
=20
 		/* Send it off, this clears delayed acks for us. */
-		TCP_SKB_CB(buff)->seq =3D TCP_SKB_CB(buff)->end_seq =3D tcp_acceptab=
le_seq(sk, tp);
+		TCP_SKB_CB(buff)->seq =3D TCP_SKB_CB(buff)->end_seq =3D tcp_acceptab=
le_seq(sk);
 		TCP_SKB_CB(buff)->when =3D tcp_time_stamp;
 		tcp_transmit_skb(sk, buff, 0, GFP_ATOMIC);
 	}
@@ -2467,7 +2473,7 @@ int tcp_write_wakeup(struct sock *sk)
 			TCP_SKB_CB(skb)->when =3D tcp_time_stamp;
 			err =3D tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
 			if (!err) {
-				update_send_head(sk, tp, skb);
+				update_send_head(sk, skb);
 			}
 			return err;
 		} else {
--=20
1.4.2

