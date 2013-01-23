From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH 1/2] tcp: make tcp_timestamp dependent on tcp_sock
Date: Wed, 23 Jan 2013 19:01:53 +0400
Message-ID: <1358953314-12979-2-git-send-email-avagin@openvz.org>
References: <1358953314-12979-1-git-send-email-avagin@openvz.org>
Cc: criu@openvz.org, linux-kernel@vger.kernel.org,
	Andrey Vagin <avagin@openvz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Dave Jones <davej@redhat.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358953314-12979-1-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This will be used for setting timestamp offset.

This patch converts the macros tcp_timestamp to a function with one
argument "struct tcp_sock *tp" and nothing else.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Dave Jones <davej@redhat.com>
Cc: Michael Kerrisk <mtk.manpages@gmail.com>
Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 include/net/tcp.h       | 15 +++++++++-----
 net/ipv4/syncookies.c   |  4 ++--
 net/ipv4/tcp.c          |  2 +-
 net/ipv4/tcp_bic.c      | 10 +++++-----
 net/ipv4/tcp_cubic.c    | 14 ++++++-------
 net/ipv4/tcp_htcp.c     |  2 +-
 net/ipv4/tcp_input.c    | 53 ++++++++++++++++++++++++++-----------------------
 net/ipv4/tcp_ipv4.c     | 19 ++++++++++--------
 net/ipv4/tcp_lp.c       |  8 ++++----
 net/ipv4/tcp_metrics.c  |  2 +-
 net/ipv4/tcp_output.c   | 35 +++++++++++++++++---------------
 net/ipv4/tcp_timer.c    |  9 +++++----
 net/ipv4/tcp_westwood.c |  8 +++++---
 net/ipv6/tcp_ipv6.c     | 22 +++++++++++---------
 14 files changed, 112 insertions(+), 91 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index aed42c7..3e242ba 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -503,7 +503,7 @@ static inline __u32 cookie_v4_init_sequence(struct sock *sk,
 }
 #endif
 
-extern __u32 cookie_init_timestamp(struct request_sock *req);
+extern __u32 cookie_init_timestamp(struct tcp_sock *tp, struct request_sock *req);
 extern bool cookie_check_timestamp(struct tcp_options_received *opt, bool *);
 
 /* From net/ipv6/syncookies.c */
@@ -675,7 +675,10 @@ void tcp_send_window_probe(struct sock *sk);
  * to use only the low 32-bits of jiffies and hide the ugly
  * casts with the following macro.
  */
-#define tcp_time_stamp		((__u32)(jiffies))
+static inline u32 tcp_time_stamp(const struct tcp_sock *tp)
+{
+	return (__u32)jiffies;
+}
 
 #define tcp_flag_byte(th) (((u_int8_t *)th)[13])
 
@@ -1142,9 +1145,11 @@ static inline void tcp_openreq_init(struct request_sock *req,
 static inline void tcp_synack_rtt_meas(struct sock *sk,
 				       struct request_sock *req)
 {
+	const struct tcp_sock *tp = tcp_sk(sk);
+
 	if (tcp_rsk(req)->snt_synack)
 		tcp_valid_rtt_meas(sk,
-		    tcp_time_stamp - tcp_rsk(req)->snt_synack);
+		    tcp_time_stamp(tp) - tcp_rsk(req)->snt_synack);
 }
 
 extern void tcp_enter_memory_pressure(struct sock *sk);
@@ -1168,8 +1173,8 @@ static inline u32 keepalive_time_elapsed(const struct tcp_sock *tp)
 {
 	const struct inet_connection_sock *icsk = &tp->inet_conn;
 
-	return min_t(u32, tcp_time_stamp - icsk->icsk_ack.lrcvtime,
-			  tcp_time_stamp - tp->rcv_tstamp);
+	return min_t(u32, tcp_time_stamp(tp) - icsk->icsk_ack.lrcvtime,
+			  tcp_time_stamp(tp) - tp->rcv_tstamp);
 }
 
 static inline int tcp_fin_time(const struct sock *sk)
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index b236ef0..70e14fd 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -64,10 +64,10 @@ static u32 cookie_hash(__be32 saddr, __be32 daddr, __be16 sport, __be16 dport,
  * Since subsequent timestamps use the normal tcp_time_stamp value, we
  * must make sure that the resulting initial timestamp is <= tcp_time_stamp.
  */
-__u32 cookie_init_timestamp(struct request_sock *req)
+__u32 cookie_init_timestamp(struct tcp_sock *tp, struct request_sock *req)
 {
 	struct inet_request_sock *ireq;
-	u32 ts, ts_now = tcp_time_stamp;
+	u32 ts, ts_now = tcp_time_stamp(tp);
 	u32 options = 0;
 
 	ireq = inet_rsk(req);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1ca2536..086ceda 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2742,7 +2742,7 @@ void tcp_get_info(const struct sock *sk, struct tcp_info *info)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_connection_sock *icsk = inet_csk(sk);
-	u32 now = tcp_time_stamp;
+	u32 now = tcp_time_stamp(tp);
 
 	memset(info, 0, sizeof(*info));
 
diff --git a/net/ipv4/tcp_bic.c b/net/ipv4/tcp_bic.c
index f45e1c2..31faf6b 100644
--- a/net/ipv4/tcp_bic.c
+++ b/net/ipv4/tcp_bic.c
@@ -83,17 +83,17 @@ static void bictcp_init(struct sock *sk)
 /*
  * Compute congestion window to use.
  */
-static inline void bictcp_update(struct bictcp *ca, u32 cwnd)
+static inline void bictcp_update(struct tcp_sock *tp, struct bictcp *ca, u32 cwnd)
 {
 	if (ca->last_cwnd == cwnd &&
-	    (s32)(tcp_time_stamp - ca->last_time) <= HZ / 32)
+	    (s32)(tcp_time_stamp(tp) - ca->last_time) <= HZ / 32)
 		return;
 
 	ca->last_cwnd = cwnd;
-	ca->last_time = tcp_time_stamp;
+	ca->last_time = tcp_time_stamp(tp);
 
 	if (ca->epoch_start == 0) /* record the beginning of an epoch */
-		ca->epoch_start = tcp_time_stamp;
+		ca->epoch_start = tcp_time_stamp(tp);
 
 	/* start off normal */
 	if (cwnd <= low_window) {
@@ -151,7 +151,7 @@ static void bictcp_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
 	if (tp->snd_cwnd <= tp->snd_ssthresh)
 		tcp_slow_start(tp);
 	else {
-		bictcp_update(ca, tp->snd_cwnd);
+		bictcp_update(tp, ca, tp->snd_cwnd);
 		tcp_cong_avoid_ai(tp, ca->cnt);
 	}
 
diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
index a9077f4..31cfa5d 100644
--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -204,7 +204,7 @@ static u32 cubic_root(u64 a)
 /*
  * Compute congestion window to use.
  */
-static inline void bictcp_update(struct bictcp *ca, u32 cwnd)
+static inline void bictcp_update(struct tcp_sock *tp, struct bictcp *ca, u32 cwnd)
 {
 	u64 offs;
 	u32 delta, t, bic_target, max_cnt;
@@ -212,14 +212,14 @@ static inline void bictcp_update(struct bictcp *ca, u32 cwnd)
 	ca->ack_cnt++;	/* count the number of ACKs */
 
 	if (ca->last_cwnd == cwnd &&
-	    (s32)(tcp_time_stamp - ca->last_time) <= HZ / 32)
+	    (s32)(tcp_time_stamp(tp) - ca->last_time) <= HZ / 32)
 		return;
 
 	ca->last_cwnd = cwnd;
-	ca->last_time = tcp_time_stamp;
+	ca->last_time = tcp_time_stamp(tp);
 
 	if (ca->epoch_start == 0) {
-		ca->epoch_start = tcp_time_stamp;	/* record the beginning of an epoch */
+		ca->epoch_start = tcp_time_stamp(tp);	/* record the beginning of an epoch */
 		ca->ack_cnt = 1;			/* start counting */
 		ca->tcp_cwnd = cwnd;			/* syn with cubic */
 
@@ -251,7 +251,7 @@ static inline void bictcp_update(struct bictcp *ca, u32 cwnd)
 	 */
 
 	/* change the unit from HZ to bictcp_HZ */
-	t = ((tcp_time_stamp + msecs_to_jiffies(ca->delay_min>>3)
+	t = ((tcp_time_stamp(tp) + msecs_to_jiffies(ca->delay_min>>3)
 	      - ca->epoch_start) << BICTCP_HZ) / HZ;
 
 	if (t < ca->bic_K)		/* t - K */
@@ -315,7 +315,7 @@ static void bictcp_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
 			bictcp_hystart_reset(sk);
 		tcp_slow_start(tp);
 	} else {
-		bictcp_update(ca, tp->snd_cwnd);
+		bictcp_update(tp, ca, tp->snd_cwnd);
 		tcp_cong_avoid_ai(tp, ca->cnt);
 	}
 
@@ -414,7 +414,7 @@ static void bictcp_acked(struct sock *sk, u32 cnt, s32 rtt_us)
 		return;
 
 	/* Discard delay samples right after fast recovery */
-	if ((s32)(tcp_time_stamp - ca->epoch_start) < HZ)
+	if ((s32)(tcp_time_stamp(tp) - ca->epoch_start) < HZ)
 		return;
 
 	delay = (rtt_us << 3) / USEC_PER_MSEC;
diff --git a/net/ipv4/tcp_htcp.c b/net/ipv4/tcp_htcp.c
index c1a8175..5137e1b 100644
--- a/net/ipv4/tcp_htcp.c
+++ b/net/ipv4/tcp_htcp.c
@@ -103,7 +103,7 @@ static void measure_achieved_throughput(struct sock *sk, u32 pkts_acked, s32 rtt
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	const struct tcp_sock *tp = tcp_sk(sk);
 	struct htcp *ca = inet_csk_ca(sk);
-	u32 now = tcp_time_stamp;
+	u32 now = tcp_time_stamp(tp);
 
 	if (icsk->icsk_ca_state == TCP_CA_Open)
 		ca->pkts_acked = pkts_acked;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a28e4db..1bb2a7d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -408,7 +408,7 @@ void tcp_init_buffer_space(struct sock *sk)
 		tp->window_clamp = max(2 * tp->advmss, maxwin - tp->advmss);
 
 	tp->rcv_ssthresh = min(tp->rcv_ssthresh, tp->window_clamp);
-	tp->snd_cwnd_stamp = tcp_time_stamp;
+	tp->snd_cwnd_stamp = tcp_time_stamp(tp);
 }
 
 /* 5. Recalculate window clamp after socket hit its memory bounds. */
@@ -503,11 +503,11 @@ static inline void tcp_rcv_rtt_measure(struct tcp_sock *tp)
 		goto new_measure;
 	if (before(tp->rcv_nxt, tp->rcv_rtt_est.seq))
 		return;
-	tcp_rcv_rtt_update(tp, tcp_time_stamp - tp->rcv_rtt_est.time, 1);
+	tcp_rcv_rtt_update(tp, tcp_time_stamp(tp) - tp->rcv_rtt_est.time, 1);
 
 new_measure:
 	tp->rcv_rtt_est.seq = tp->rcv_nxt + tp->rcv_wnd;
-	tp->rcv_rtt_est.time = tcp_time_stamp;
+	tp->rcv_rtt_est.time = tcp_time_stamp(tp);
 }
 
 static inline void tcp_rcv_rtt_measure_ts(struct sock *sk,
@@ -517,7 +517,7 @@ static inline void tcp_rcv_rtt_measure_ts(struct sock *sk,
 	if (tp->rx_opt.rcv_tsecr &&
 	    (TCP_SKB_CB(skb)->end_seq -
 	     TCP_SKB_CB(skb)->seq >= inet_csk(sk)->icsk_ack.rcv_mss))
-		tcp_rcv_rtt_update(tp, tcp_time_stamp - tp->rx_opt.rcv_tsecr, 0);
+		tcp_rcv_rtt_update(tp, tcp_time_stamp(tp) - tp->rx_opt.rcv_tsecr, 0);
 }
 
 /*
@@ -533,7 +533,7 @@ void tcp_rcv_space_adjust(struct sock *sk)
 	if (tp->rcvq_space.time == 0)
 		goto new_measure;
 
-	time = tcp_time_stamp - tp->rcvq_space.time;
+	time = tcp_time_stamp(tp) - tp->rcvq_space.time;
 	if (time < (tp->rcv_rtt_est.rtt >> 3) || tp->rcv_rtt_est.rtt == 0)
 		return;
 
@@ -573,7 +573,7 @@ void tcp_rcv_space_adjust(struct sock *sk)
 
 new_measure:
 	tp->rcvq_space.seq = tp->copied_seq;
-	tp->rcvq_space.time = tcp_time_stamp;
+	tp->rcvq_space.time = tcp_time_stamp(tp);
 }
 
 /* There is something which you must keep in mind when you analyze the
@@ -598,7 +598,7 @@ static void tcp_event_data_recv(struct sock *sk, struct sk_buff *skb)
 
 	tcp_rcv_rtt_measure(tp);
 
-	now = tcp_time_stamp;
+	now = tcp_time_stamp(tp);
 
 	if (!icsk->icsk_ack.ato) {
 		/* The _first_ data packet received, initialize
@@ -2007,7 +2007,7 @@ static void tcp_enter_frto_loss(struct sock *sk, int allowed_segments, int flag)
 
 	tp->snd_cwnd = tcp_packets_in_flight(tp) + allowed_segments;
 	tp->snd_cwnd_cnt = 0;
-	tp->snd_cwnd_stamp = tcp_time_stamp;
+	tp->snd_cwnd_stamp = tcp_time_stamp(tp);
 	tp->frto_counter = 0;
 	tp->bytes_acked = 0;
 
@@ -2056,7 +2056,7 @@ void tcp_enter_loss(struct sock *sk, int how)
 	}
 	tp->snd_cwnd	   = 1;
 	tp->snd_cwnd_cnt   = 0;
-	tp->snd_cwnd_stamp = tcp_time_stamp;
+	tp->snd_cwnd_stamp = tcp_time_stamp(tp);
 
 	tp->bytes_acked = 0;
 	tcp_clear_retrans_partial(tp);
@@ -2170,7 +2170,9 @@ static bool tcp_pause_early_retransmit(struct sock *sk, int flag)
 static inline int tcp_skb_timedout(const struct sock *sk,
 				   const struct sk_buff *skb)
 {
-	return tcp_time_stamp - TCP_SKB_CB(skb)->when > inet_csk(sk)->icsk_rto;
+	const struct tcp_sock *tp = tcp_sk(sk);
+
+	return tcp_time_stamp(tp) - TCP_SKB_CB(skb)->when > inet_csk(sk)->icsk_rto;
 }
 
 static inline int tcp_head_timedout(const struct sock *sk)
@@ -2467,7 +2469,7 @@ static inline void tcp_moderate_cwnd(struct tcp_sock *tp)
 {
 	tp->snd_cwnd = min(tp->snd_cwnd,
 			   tcp_packets_in_flight(tp) + tcp_max_burst(tp));
-	tp->snd_cwnd_stamp = tcp_time_stamp;
+	tp->snd_cwnd_stamp = tcp_time_stamp(tp);
 }
 
 /* Nothing was retransmitted or returned timestamp is less
@@ -2531,7 +2533,7 @@ static void tcp_undo_cwr(struct sock *sk, const bool undo_ssthresh)
 	} else {
 		tp->snd_cwnd = max(tp->snd_cwnd, tp->snd_ssthresh);
 	}
-	tp->snd_cwnd_stamp = tcp_time_stamp;
+	tp->snd_cwnd_stamp = tcp_time_stamp(tp);
 }
 
 static inline bool tcp_may_undo(const struct tcp_sock *tp)
@@ -2726,7 +2728,7 @@ static inline void tcp_end_cwnd_reduction(struct sock *sk)
 	if (inet_csk(sk)->icsk_ca_state == TCP_CA_CWR ||
 	    (tp->undo_marker && tp->snd_ssthresh < TCP_INFINITE_SSTHRESH)) {
 		tp->snd_cwnd = tp->snd_ssthresh;
-		tp->snd_cwnd_stamp = tcp_time_stamp;
+		tp->snd_cwnd_stamp = tcp_time_stamp(tp);
 	}
 	tcp_ca_event(sk, CA_EVENT_COMPLETE_CWR);
 }
@@ -2799,7 +2801,7 @@ static void tcp_mtup_probe_success(struct sock *sk)
 		       tcp_mss_to_mtu(sk, tp->mss_cache) /
 		       icsk->icsk_mtup.probe_size;
 	tp->snd_cwnd_cnt = 0;
-	tp->snd_cwnd_stamp = tcp_time_stamp;
+	tp->snd_cwnd_stamp = tcp_time_stamp(tp);
 	tp->snd_ssthresh = tcp_current_ssthresh(sk);
 
 	icsk->icsk_mtup.search_low = icsk->icsk_mtup.probe_size;
@@ -3045,7 +3047,7 @@ static void tcp_ack_saw_tstamp(struct sock *sk, int flag)
 	 */
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	tcp_valid_rtt_meas(sk, tcp_time_stamp - tp->rx_opt.rcv_tsecr);
+	tcp_valid_rtt_meas(sk, tcp_time_stamp(tp) - tp->rx_opt.rcv_tsecr);
 }
 
 static void tcp_ack_no_tstamp(struct sock *sk, u32 seq_rtt, int flag)
@@ -3078,9 +3080,10 @@ static inline void tcp_ack_update_rtt(struct sock *sk, const int flag,
 
 static void tcp_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
 {
+	const struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	icsk->icsk_ca_ops->cong_avoid(sk, ack, in_flight);
-	tcp_sk(sk)->snd_cwnd_stamp = tcp_time_stamp;
+	tcp_sk(sk)->snd_cwnd_stamp = tcp_time_stamp(tp);
 }
 
 /* Restart timer after forward progress on connection.
@@ -3104,7 +3107,7 @@ void tcp_rearm_rto(struct sock *sk)
 		if (tp->early_retrans_delayed) {
 			struct sk_buff *skb = tcp_write_queue_head(sk);
 			const u32 rto_time_stamp = TCP_SKB_CB(skb)->when + rto;
-			s32 delta = (s32)(rto_time_stamp - tcp_time_stamp);
+			s32 delta = (s32)(rto_time_stamp - tcp_time_stamp(tp));
 			/* delta may not be positive if the socket is locked
 			 * when the delayed ER timer fires and is rescheduled.
 			 */
@@ -3166,7 +3169,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 	struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	struct sk_buff *skb;
-	u32 now = tcp_time_stamp;
+	u32 now = tcp_time_stamp(tp);
 	int fully_acked = true;
 	int flag = 0;
 	u32 pkts_acked = 0;
@@ -3656,7 +3659,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	 */
 	sk->sk_err_soft = 0;
 	icsk->icsk_probes_out = 0;
-	tp->rcv_tstamp = tcp_time_stamp;
+	tp->rcv_tstamp = tcp_time_stamp(tp);
 	prior_packets = tp->packets_out;
 	if (!prior_packets)
 		goto no_queue;
@@ -4971,7 +4974,7 @@ void tcp_cwnd_application_limited(struct sock *sk)
 		}
 		tp->snd_cwnd_used = 0;
 	}
-	tp->snd_cwnd_stamp = tcp_time_stamp;
+	tp->snd_cwnd_stamp = tcp_time_stamp(tp);
 }
 
 static bool tcp_should_expand_sndbuf(const struct sock *sk)
@@ -5019,7 +5022,7 @@ static void tcp_new_space(struct sock *sk)
 		sndmem *= 2 * demanded;
 		if (sndmem > sk->sk_sndbuf)
 			sk->sk_sndbuf = min(sndmem, sysctl_tcp_wmem[2]);
-		tp->snd_cwnd_stamp = tcp_time_stamp;
+		tp->snd_cwnd_stamp = tcp_time_stamp(tp);
 	}
 
 	sk->sk_write_space(sk);
@@ -5605,7 +5608,7 @@ void tcp_finish_connect(struct sock *sk, struct sk_buff *skb)
 	/* Prevent spurious tcp_cwnd_restart() on first data
 	 * packet.
 	 */
-	tp->lsndtime = tcp_time_stamp;
+	tp->lsndtime = tcp_time_stamp(tp);
 
 	tcp_init_buffer_space(sk);
 
@@ -5694,7 +5697,7 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 
 		if (tp->rx_opt.saw_tstamp && tp->rx_opt.rcv_tsecr &&
 		    !between(tp->rx_opt.rcv_tsecr, tp->retrans_stamp,
-			     tcp_time_stamp)) {
+			     tcp_time_stamp(tp))) {
 			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSACTIVEREJECTED);
 			goto reset_and_undo;
 		}
@@ -5815,7 +5818,7 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 			 * to stand against the temptation 8)     --ANK
 			 */
 			inet_csk_schedule_ack(sk);
-			icsk->icsk_ack.lrcvtime = tcp_time_stamp;
+			icsk->icsk_ack.lrcvtime = tcp_time_stamp(tp);
 			tcp_enter_quickack_mode(sk);
 			inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
 						  TCP_DELACK_MAX, TCP_RTO_MAX);
@@ -6059,7 +6062,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 				/* Prevent spurious tcp_cwnd_restart() on
 				 * first data packet.
 				 */
-				tp->lsndtime = tcp_time_stamp;
+				tp->lsndtime = tcp_time_stamp(tp);
 
 				tcp_initialize_rcv_mss(sk);
 				tcp_fast_path_on(tp);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 54139fa..7103540 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -442,7 +442,7 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 		BUG_ON(!skb);
 
 		remaining = icsk->icsk_rto - min(icsk->icsk_rto,
-				tcp_time_stamp - TCP_SKB_CB(skb)->when);
+				tcp_time_stamp(tp) - TCP_SKB_CB(skb)->when);
 
 		if (remaining) {
 			inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
@@ -724,11 +724,13 @@ release_sk1:
    outside socket context is ugly, certainly. What can I do?
  */
 
-static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
+static void tcp_v4_send_ack(struct sock *sk, struct sk_buff *skb,
+			    u32 seq, u32 ack,
 			    u32 win, u32 ts, int oif,
 			    struct tcp_md5sig_key *key,
 			    int reply_flags, u8 tos)
 {
+	const struct tcp_sock *tp = tcp_sk(sk);
 	const struct tcphdr *th = tcp_hdr(skb);
 	struct {
 		struct tcphdr th;
@@ -750,7 +752,7 @@ static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 		rep.opt[0] = htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16) |
 				   (TCPOPT_TIMESTAMP << 8) |
 				   TCPOLEN_TIMESTAMP);
-		rep.opt[1] = htonl(tcp_time_stamp);
+		rep.opt[1] = htonl(tcp_time_stamp(tp));
 		rep.opt[2] = htonl(ts);
 		arg.iov[0].iov_len += TCPOLEN_TSTAMP_ALIGNED;
 	}
@@ -799,7 +801,7 @@ static void tcp_v4_timewait_ack(struct sock *sk, struct sk_buff *skb)
 	struct inet_timewait_sock *tw = inet_twsk(sk);
 	struct tcp_timewait_sock *tcptw = tcp_twsk(sk);
 
-	tcp_v4_send_ack(skb, tcptw->tw_snd_nxt, tcptw->tw_rcv_nxt,
+	tcp_v4_send_ack(sk, skb, tcptw->tw_snd_nxt, tcptw->tw_rcv_nxt,
 			tcptw->tw_rcv_wnd >> tw->tw_rcv_wscale,
 			tcptw->tw_ts_recent,
 			tw->tw_bound_dev_if,
@@ -817,7 +819,7 @@ static void tcp_v4_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
 	/* sk->sk_state == TCP_LISTEN -> for regular TCP_SYN_RECV
 	 * sk->sk_state == TCP_SYN_RECV -> for Fast Open.
 	 */
-	tcp_v4_send_ack(skb, (sk->sk_state == TCP_LISTEN) ?
+	tcp_v4_send_ack(sk, skb, (sk->sk_state == TCP_LISTEN) ?
 			tcp_rsk(req)->snt_isn + 1 : tcp_sk(sk)->snd_nxt,
 			tcp_rsk(req)->rcv_nxt, req->rcv_wnd,
 			req->ts_recent,
@@ -839,6 +841,7 @@ static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
 			      u16 queue_mapping,
 			      bool nocache)
 {
+	const struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_request_sock *ireq = inet_rsk(req);
 	struct flowi4 fl4;
 	int err = -1;
@@ -859,7 +862,7 @@ static int tcp_v4_send_synack(struct sock *sk, struct dst_entry *dst,
 					    ireq->opt);
 		err = net_xmit_eval(err);
 		if (!tcp_rsk(req)->snt_synack && !err)
-			tcp_rsk(req)->snt_synack = tcp_time_stamp;
+			tcp_rsk(req)->snt_synack = tcp_time_stamp(tp);
 	}
 
 	return err;
@@ -1393,7 +1396,7 @@ static int tcp_v4_conn_req_fastopen(struct sock *sk,
 				    ireq->rmt_addr, ireq->opt);
 	err = net_xmit_eval(err);
 	if (!err)
-		tcp_rsk(req)->snt_synack = tcp_time_stamp;
+		tcp_rsk(req)->snt_synack = tcp_time_stamp(tp);
 	/* XXX (TFO) - is it ok to ignore error and continue? */
 
 	spin_lock(&queue->fastopenq->lock);
@@ -1649,7 +1652,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		if (err || want_cookie)
 			goto drop_and_free;
 
-		tcp_rsk(req)->snt_synack = tcp_time_stamp;
+		tcp_rsk(req)->snt_synack = tcp_time_stamp(tp);
 		tcp_rsk(req)->listener = NULL;
 		/* Add the request_sock to the SYN table */
 		inet_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
diff --git a/net/ipv4/tcp_lp.c b/net/ipv4/tcp_lp.c
index 72f7218..a86cc91 100644
--- a/net/ipv4/tcp_lp.c
+++ b/net/ipv4/tcp_lp.c
@@ -269,11 +269,11 @@ static void tcp_lp_pkts_acked(struct sock *sk, u32 num_acked, s32 rtt_us)
 		tcp_lp_rtt_sample(sk, rtt_us);
 
 	/* calc inference */
-	if (tcp_time_stamp > tp->rx_opt.rcv_tsecr)
-		lp->inference = 3 * (tcp_time_stamp - tp->rx_opt.rcv_tsecr);
+	if (tcp_time_stamp(tp) > tp->rx_opt.rcv_tsecr)
+		lp->inference = 3 * (tcp_time_stamp(tp) - tp->rx_opt.rcv_tsecr);
 
 	/* test if within inference */
-	if (lp->last_drop && (tcp_time_stamp - lp->last_drop < lp->inference))
+	if (lp->last_drop && (tcp_time_stamp(tp) - lp->last_drop < lp->inference))
 		lp->flag |= LP_WITHIN_INF;
 	else
 		lp->flag &= ~LP_WITHIN_INF;
@@ -310,7 +310,7 @@ static void tcp_lp_pkts_acked(struct sock *sk, u32 num_acked, s32 rtt_us)
 		tp->snd_cwnd = max(tp->snd_cwnd >> 1U, 1U);
 
 	/* record this drop time */
-	lp->last_drop = tcp_time_stamp;
+	lp->last_drop = tcp_time_stamp(tp);
 }
 
 static struct tcp_congestion_ops tcp_lp __read_mostly = {
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index f696d7c..1732e3e 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -527,7 +527,7 @@ reset:
 		tp->snd_cwnd = 1;
 	else
 		tp->snd_cwnd = tcp_init_cwnd(tp, dst);
-	tp->snd_cwnd_stamp = tcp_time_stamp;
+	tp->snd_cwnd_stamp = tcp_time_stamp(tp);
 }
 
 bool tcp_peer_is_proven(struct request_sock *req, struct dst_entry *dst, bool paws_check)
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 5d45159..0ac097c 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -142,7 +142,7 @@ static __u16 tcp_advertise_mss(struct sock *sk)
 static void tcp_cwnd_restart(struct sock *sk, const struct dst_entry *dst)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	s32 delta = tcp_time_stamp - tp->lsndtime;
+	s32 delta = tcp_time_stamp(tp) - tp->lsndtime;
 	u32 restart_cwnd = tcp_init_cwnd(tp, dst);
 	u32 cwnd = tp->snd_cwnd;
 
@@ -154,7 +154,7 @@ static void tcp_cwnd_restart(struct sock *sk, const struct dst_entry *dst)
 	while ((delta -= inet_csk(sk)->icsk_rto) > 0 && cwnd > restart_cwnd)
 		cwnd >>= 1;
 	tp->snd_cwnd = max(cwnd, restart_cwnd);
-	tp->snd_cwnd_stamp = tcp_time_stamp;
+	tp->snd_cwnd_stamp = tcp_time_stamp(tp);
 	tp->snd_cwnd_used = 0;
 }
 
@@ -163,7 +163,7 @@ static void tcp_event_data_sent(struct tcp_sock *tp,
 				struct sock *sk)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
-	const u32 now = tcp_time_stamp;
+	const u32 now = tcp_time_stamp(tp);
 
 	if (sysctl_tcp_slow_start_after_idle &&
 	    (!tp->packets_out && (s32)(now - tp->lsndtime) > icsk->icsk_rto))
@@ -1510,14 +1510,14 @@ static void tcp_cwnd_validate(struct sock *sk)
 	if (tp->packets_out >= tp->snd_cwnd) {
 		/* Network is feed fully. */
 		tp->snd_cwnd_used = 0;
-		tp->snd_cwnd_stamp = tcp_time_stamp;
+		tp->snd_cwnd_stamp = tcp_time_stamp(tp);
 	} else {
 		/* Network starves. */
 		if (tp->packets_out > tp->snd_cwnd_used)
 			tp->snd_cwnd_used = tp->packets_out;
 
 		if (sysctl_tcp_slow_start_after_idle &&
-		    (s32)(tcp_time_stamp - tp->snd_cwnd_stamp) >= inet_csk(sk)->icsk_rto)
+		    (s32)(tcp_time_stamp(tp) - tp->snd_cwnd_stamp) >= inet_csk(sk)->icsk_rto)
 			tcp_cwnd_application_limited(sk);
 	}
 }
@@ -1930,7 +1930,7 @@ static int tcp_mtu_probe(struct sock *sk)
 
 	/* We're ready to send.  If this fails, the probe will
 	 * be resegmented into mss-sized pieces by tcp_write_xmit(). */
-	TCP_SKB_CB(nskb)->when = tcp_time_stamp;
+	TCP_SKB_CB(nskb)->when = tcp_time_stamp(tp);
 	if (!tcp_transmit_skb(sk, nskb, 1, GFP_ATOMIC)) {
 		/* Decrement cwnd here because we are sending
 		 * effectively two packets. */
@@ -2024,7 +2024,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 		    unlikely(tso_fragment(sk, skb, limit, mss_now, gfp)))
 			break;
 
-		TCP_SKB_CB(skb)->when = tcp_time_stamp;
+		TCP_SKB_CB(skb)->when = tcp_time_stamp(tp);
 
 		if (unlikely(tcp_transmit_skb(sk, skb, 1, gfp)))
 			break;
@@ -2380,7 +2380,7 @@ int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	/* Make a copy, if the first transmission SKB clone we made
 	 * is still in somebody's hands, else make a clone.
 	 */
-	TCP_SKB_CB(skb)->when = tcp_time_stamp;
+	TCP_SKB_CB(skb)->when = tcp_time_stamp(tp);
 
 	/* make sure skb->data is aligned on arches that require it */
 	if (unlikely(NET_IP_ALIGN && ((unsigned long)skb->data & 3))) {
@@ -2607,6 +2607,7 @@ void tcp_send_fin(struct sock *sk)
  */
 void tcp_send_active_reset(struct sock *sk, gfp_t priority)
 {
+	const struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
 
 	/* NOTE: No TCP options attached and we never retransmit this. */
@@ -2621,7 +2622,7 @@ void tcp_send_active_reset(struct sock *sk, gfp_t priority)
 	tcp_init_nondata_skb(skb, tcp_acceptable_seq(sk),
 			     TCPHDR_ACK | TCPHDR_RST);
 	/* Send it off. */
-	TCP_SKB_CB(skb)->when = tcp_time_stamp;
+	TCP_SKB_CB(skb)->when = tcp_time_stamp(tp);
 	if (tcp_transmit_skb(sk, skb, 0, priority))
 		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPABORTFAILED);
 
@@ -2636,6 +2637,7 @@ void tcp_send_active_reset(struct sock *sk, gfp_t priority)
  */
 int tcp_send_synack(struct sock *sk)
 {
+	const struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
 
 	skb = tcp_write_queue_head(sk);
@@ -2660,7 +2662,7 @@ int tcp_send_synack(struct sock *sk)
 		TCP_SKB_CB(skb)->tcp_flags |= TCPHDR_ACK;
 		TCP_ECN_send_synack(tcp_sk(sk), skb);
 	}
-	TCP_SKB_CB(skb)->when = tcp_time_stamp;
+	TCP_SKB_CB(skb)->when = tcp_time_stamp(tp);
 	return tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
 }
 
@@ -2732,10 +2734,10 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	memset(&opts, 0, sizeof(opts));
 #ifdef CONFIG_SYN_COOKIES
 	if (unlikely(req->cookie_ts))
-		TCP_SKB_CB(skb)->when = cookie_init_timestamp(req);
+		TCP_SKB_CB(skb)->when = cookie_init_timestamp(tp, req);
 	else
 #endif
-	TCP_SKB_CB(skb)->when = tcp_time_stamp;
+	TCP_SKB_CB(skb)->when = tcp_time_stamp(tp);
 	tcp_header_size = tcp_synack_options(sk, req, mss,
 					     skb, &opts, &md5, xvp, foc)
 			+ sizeof(*th);
@@ -3005,7 +3007,7 @@ int tcp_connect(struct sock *sk)
 	skb_reserve(buff, MAX_TCP_HEADER);
 
 	tcp_init_nondata_skb(buff, tp->write_seq++, TCPHDR_SYN);
-	tp->retrans_stamp = TCP_SKB_CB(buff)->when = tcp_time_stamp;
+	tp->retrans_stamp = TCP_SKB_CB(buff)->when = tcp_time_stamp(tp);
 	tcp_connect_queue_skb(sk, buff);
 	TCP_ECN_send_syn(sk, buff);
 
@@ -3088,6 +3090,7 @@ void tcp_send_delayed_ack(struct sock *sk)
 /* This routine sends an ack and also updates the window. */
 void tcp_send_ack(struct sock *sk)
 {
+	const struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *buff;
 
 	/* If we have been reset, we may not send again. */
@@ -3112,7 +3115,7 @@ void tcp_send_ack(struct sock *sk)
 	tcp_init_nondata_skb(buff, tcp_acceptable_seq(sk), TCPHDR_ACK);
 
 	/* Send it off, this clears delayed acks for us. */
-	TCP_SKB_CB(buff)->when = tcp_time_stamp;
+	TCP_SKB_CB(buff)->when = tcp_time_stamp(tp);
 	tcp_transmit_skb(sk, buff, 0, sk_gfp_atomic(sk, GFP_ATOMIC));
 }
 
@@ -3144,7 +3147,7 @@ static int tcp_xmit_probe_skb(struct sock *sk, int urgent)
 	 * send it.
 	 */
 	tcp_init_nondata_skb(skb, tp->snd_una - !urgent, TCPHDR_ACK);
-	TCP_SKB_CB(skb)->when = tcp_time_stamp;
+	TCP_SKB_CB(skb)->when = tcp_time_stamp(tp);
 	return tcp_transmit_skb(sk, skb, 0, GFP_ATOMIC);
 }
 
@@ -3189,7 +3192,7 @@ int tcp_write_wakeup(struct sock *sk)
 			tcp_set_skb_tso_segs(sk, skb, mss);
 
 		TCP_SKB_CB(skb)->tcp_flags |= TCPHDR_PSH;
-		TCP_SKB_CB(skb)->when = tcp_time_stamp;
+		TCP_SKB_CB(skb)->when = tcp_time_stamp(tp);
 		err = tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
 		if (!err)
 			tcp_event_new_data_sent(sk, skb);
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index b78aac3..6be8aa0 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -59,7 +59,7 @@ static int tcp_out_of_resources(struct sock *sk, int do_reset)
 
 	/* If peer does not open window for long time, or did not transmit
 	 * anything for long time, penalize it. */
-	if ((s32)(tcp_time_stamp - tp->lsndtime) > 2*TCP_RTO_MAX || !do_reset)
+	if ((s32)(tcp_time_stamp(tp) - tp->lsndtime) > 2*TCP_RTO_MAX || !do_reset)
 		shift++;
 
 	/* If some dubious ICMP arrived, penalize even more. */
@@ -69,7 +69,7 @@ static int tcp_out_of_resources(struct sock *sk, int do_reset)
 	if (tcp_check_oom(sk, shift)) {
 		/* Catch exceptional cases, when connection requires reset.
 		 *      1. Last segment was sent recently. */
-		if ((s32)(tcp_time_stamp - tp->lsndtime) <= TCP_TIMEWAIT_LEN ||
+		if ((s32)(tcp_time_stamp(tp) - tp->lsndtime) <= TCP_TIMEWAIT_LEN ||
 		    /*  2. Window is closed. */
 		    (!tp->snd_wnd && !tp->packets_out))
 			do_reset = 1;
@@ -129,6 +129,7 @@ static bool retransmits_timed_out(struct sock *sk,
 				  unsigned int timeout,
 				  bool syn_set)
 {
+	const struct tcp_sock *tp = tcp_sk(sk);
 	unsigned int linear_backoff_thresh, start_ts;
 	unsigned int rto_base = syn_set ? TCP_TIMEOUT_INIT : TCP_RTO_MIN;
 
@@ -149,7 +150,7 @@ static bool retransmits_timed_out(struct sock *sk,
 			timeout = ((2 << linear_backoff_thresh) - 1) * rto_base +
 				(boundary - linear_backoff_thresh) * TCP_RTO_MAX;
 	}
-	return (tcp_time_stamp - start_ts) >= timeout;
+	return (tcp_time_stamp(tp) - start_ts) >= timeout;
 }
 
 /* A write timeout has occurred. Process the after effects. */
@@ -383,7 +384,7 @@ void tcp_retransmit_timer(struct sock *sk)
 				       tp->snd_una, tp->snd_nxt);
 		}
 #endif
-		if (tcp_time_stamp - tp->rcv_tstamp > TCP_RTO_MAX) {
+		if (tcp_time_stamp(tp) - tp->rcv_tstamp > TCP_RTO_MAX) {
 			tcp_write_err(sk);
 			goto out;
 		}
diff --git a/net/ipv4/tcp_westwood.c b/net/ipv4/tcp_westwood.c
index 1b91bf4..348db8d 100644
--- a/net/ipv4/tcp_westwood.c
+++ b/net/ipv4/tcp_westwood.c
@@ -60,6 +60,7 @@ struct westwood {
  */
 static void tcp_westwood_init(struct sock *sk)
 {
+	const struct tcp_sock *tp = tcp_sk(sk);
 	struct westwood *w = inet_csk_ca(sk);
 
 	w->bk = 0;
@@ -69,7 +70,7 @@ static void tcp_westwood_init(struct sock *sk)
 	w->cumul_ack = 0;
 	w->reset_rtt_min = 1;
 	w->rtt_min = w->rtt = TCP_WESTWOOD_INIT_RTT;
-	w->rtt_win_sx = tcp_time_stamp;
+	w->rtt_win_sx = tcp_time_stamp(tp);
 	w->snd_una = tcp_sk(sk)->snd_una;
 	w->first_ack = 1;
 }
@@ -115,8 +116,9 @@ static void tcp_westwood_pkts_acked(struct sock *sk, u32 cnt, s32 rtt)
  */
 static void westwood_update_window(struct sock *sk)
 {
+	const struct tcp_sock *tp = tcp_sk(sk);
 	struct westwood *w = inet_csk_ca(sk);
-	s32 delta = tcp_time_stamp - w->rtt_win_sx;
+	s32 delta = tcp_time_stamp(tp) - w->rtt_win_sx;
 
 	/* Initialize w->snd_una with the first acked sequence number in order
 	 * to fix mismatch between tp->snd_una and w->snd_una for the first
@@ -140,7 +142,7 @@ static void westwood_update_window(struct sock *sk)
 		westwood_filter(w, delta);
 
 		w->bk = 0;
-		w->rtt_win_sx = tcp_time_stamp;
+		w->rtt_win_sx = tcp_time_stamp(tp);
 	}
 }
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 93825dd..3f7a74d 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -711,9 +711,11 @@ static const struct tcp_request_sock_ops tcp_request_sock_ipv6_ops = {
 };
 #endif
 
-static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
-				 u32 ts, struct tcp_md5sig_key *key, int rst, u8 tclass)
+static void tcp_v6_send_response(struct sock *sk, struct sk_buff *skb,
+				 u32 seq, u32 ack, u32 win, u32 ts,
+				 struct tcp_md5sig_key *key, int rst, u8 tclass)
 {
+	const struct tcp_sock *tp = tcp_sk(sk);
 	const struct tcphdr *th = tcp_hdr(skb);
 	struct tcphdr *t1;
 	struct sk_buff *buff;
@@ -757,7 +759,7 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 	if (ts) {
 		*topt++ = htonl((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16) |
 				(TCPOPT_TIMESTAMP << 8) | TCPOLEN_TIMESTAMP);
-		*topt++ = htonl(tcp_time_stamp);
+		*topt++ = htonl(tcp_time_stamp(tp));
 		*topt++ = htonl(ts);
 	}
 
@@ -858,7 +860,7 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 		ack_seq = ntohl(th->seq) + th->syn + th->fin + skb->len -
 			  (th->doff << 2);
 
-	tcp_v6_send_response(skb, seq, ack_seq, 0, 0, key, 1, 0);
+	tcp_v6_send_response(sk, skb, seq, ack_seq, 0, 0, key, 1, 0);
 
 #ifdef CONFIG_TCP_MD5SIG
 release_sk1:
@@ -869,10 +871,11 @@ release_sk1:
 #endif
 }
 
-static void tcp_v6_send_ack(struct sk_buff *skb, u32 seq, u32 ack, u32 win, u32 ts,
+static void tcp_v6_send_ack(struct sock *sk, struct sk_buff *skb,
+			    u32 seq, u32 ack, u32 win, u32 ts,
 			    struct tcp_md5sig_key *key, u8 tclass)
 {
-	tcp_v6_send_response(skb, seq, ack, win, ts, key, 0, tclass);
+	tcp_v6_send_response(sk, skb, seq, ack, win, ts, key, 0, tclass);
 }
 
 static void tcp_v6_timewait_ack(struct sock *sk, struct sk_buff *skb)
@@ -880,7 +883,7 @@ static void tcp_v6_timewait_ack(struct sock *sk, struct sk_buff *skb)
 	struct inet_timewait_sock *tw = inet_twsk(sk);
 	struct tcp_timewait_sock *tcptw = tcp_twsk(sk);
 
-	tcp_v6_send_ack(skb, tcptw->tw_snd_nxt, tcptw->tw_rcv_nxt,
+	tcp_v6_send_ack(sk, skb, tcptw->tw_snd_nxt, tcptw->tw_rcv_nxt,
 			tcptw->tw_rcv_wnd >> tw->tw_rcv_wscale,
 			tcptw->tw_ts_recent, tcp_twsk_md5_key(tcptw),
 			tw->tw_tclass);
@@ -891,7 +894,8 @@ static void tcp_v6_timewait_ack(struct sock *sk, struct sk_buff *skb)
 static void tcp_v6_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
 				  struct request_sock *req)
 {
-	tcp_v6_send_ack(skb, tcp_rsk(req)->snt_isn + 1, tcp_rsk(req)->rcv_isn + 1, req->rcv_wnd, req->ts_recent,
+	tcp_v6_send_ack(sk, skb, tcp_rsk(req)->snt_isn + 1, tcp_rsk(req)->rcv_isn + 1,
+			req->rcv_wnd, req->ts_recent,
 			tcp_v6_md5_do_lookup(sk, &ipv6_hdr(skb)->daddr), 0);
 }
 
@@ -1098,7 +1102,7 @@ have_isn:
 	    want_cookie)
 		goto drop_and_free;
 
-	tcp_rsk(req)->snt_synack = tcp_time_stamp;
+	tcp_rsk(req)->snt_synack = tcp_time_stamp(tp);
 	tcp_rsk(req)->listener = NULL;
 	inet6_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
 	return 0;
-- 
1.7.11.7
