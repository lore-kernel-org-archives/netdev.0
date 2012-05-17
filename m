From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: bool conversions
Date: Thu, 17 May 2012 11:15:34 +0200
Message-ID: <1337246134.4740.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:64650 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760824Ab2EQJPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 05:15:40 -0400
Received: by eaak11 with SMTP id k11so443513eaa.19
        for <netdev@vger.kernel.org>; Thu, 17 May 2012 02:15:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

bool conversions where possible.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h        |   56 ++++-----
 net/ipv4/tcp.c           |   20 +--
 net/ipv4/tcp_cong.c      |    6 -
 net/ipv4/tcp_hybla.c     |   10 -
 net/ipv4/tcp_input.c     |  214 ++++++++++++++++++-------------------
 net/ipv4/tcp_ipv4.c      |   26 ++--
 net/ipv4/tcp_minisocks.c |   24 ++--
 net/ipv4/tcp_output.c    |   75 ++++++------
 net/ipv6/tcp_ipv6.c      |    4 
 9 files changed, 219 insertions(+), 216 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index aaf5de9..e79aa48 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -263,14 +263,14 @@ extern int tcp_memory_pressure;
  * and worry about wraparound (automatic with unsigned arithmetic).
  */
 
-static inline int before(__u32 seq1, __u32 seq2)
+static inline bool before(__u32 seq1, __u32 seq2)
 {
         return (__s32)(seq1-seq2) < 0;
 }
 #define after(seq2, seq1) 	before(seq1, seq2)
 
 /* is s2<=s1<=s3 ? */
-static inline int between(__u32 seq1, __u32 seq2, __u32 seq3)
+static inline bool between(__u32 seq1, __u32 seq2, __u32 seq3)
 {
 	return seq3 - seq2 >= seq1 - seq2;
 }
@@ -305,7 +305,7 @@ static inline void tcp_synq_overflow(struct sock *sk)
 }
 
 /* syncookies: no recent synqueue overflow on this listening socket? */
-static inline int tcp_synq_no_recent_overflow(const struct sock *sk)
+static inline bool tcp_synq_no_recent_overflow(const struct sock *sk)
 {
 	unsigned long last_overflow = tcp_sk(sk)->rx_opt.ts_recent_stamp;
 	return time_after(jiffies, last_overflow + TCP_TIMEOUT_FALLBACK);
@@ -383,7 +383,7 @@ extern struct sock * tcp_check_req(struct sock *sk,struct sk_buff *skb,
 				   struct request_sock **prev);
 extern int tcp_child_process(struct sock *parent, struct sock *child,
 			     struct sk_buff *skb);
-extern int tcp_use_frto(struct sock *sk);
+extern bool tcp_use_frto(struct sock *sk);
 extern void tcp_enter_frto(struct sock *sk);
 extern void tcp_enter_loss(struct sock *sk, int how);
 extern void tcp_clear_retrans(struct tcp_sock *tp);
@@ -470,7 +470,7 @@ static inline __u32 cookie_v6_init_sequence(struct sock *sk,
 
 extern void __tcp_push_pending_frames(struct sock *sk, unsigned int cur_mss,
 				      int nonagle);
-extern int tcp_may_send_now(struct sock *sk);
+extern bool tcp_may_send_now(struct sock *sk);
 extern int tcp_retransmit_skb(struct sock *, struct sk_buff *);
 extern void tcp_retransmit_timer(struct sock *sk);
 extern void tcp_xmit_retransmit_queue(struct sock *);
@@ -484,9 +484,9 @@ extern int tcp_write_wakeup(struct sock *);
 extern void tcp_send_fin(struct sock *sk);
 extern void tcp_send_active_reset(struct sock *sk, gfp_t priority);
 extern int tcp_send_synack(struct sock *);
-extern int tcp_syn_flood_action(struct sock *sk,
-				const struct sk_buff *skb,
-				const char *proto);
+extern bool tcp_syn_flood_action(struct sock *sk,
+				 const struct sk_buff *skb,
+				 const char *proto);
 extern void tcp_push_one(struct sock *, unsigned int mss_now);
 extern void tcp_send_ack(struct sock *sk);
 extern void tcp_send_delayed_ack(struct sock *sk);
@@ -794,12 +794,12 @@ static inline int tcp_is_sack(const struct tcp_sock *tp)
 	return tp->rx_opt.sack_ok;
 }
 
-static inline int tcp_is_reno(const struct tcp_sock *tp)
+static inline bool tcp_is_reno(const struct tcp_sock *tp)
 {
 	return !tcp_is_sack(tp);
 }
 
-static inline int tcp_is_fack(const struct tcp_sock *tp)
+static inline bool tcp_is_fack(const struct tcp_sock *tp)
 {
 	return tp->rx_opt.sack_ok & TCP_FACK_ENABLED;
 }
@@ -901,7 +901,7 @@ static inline u32 tcp_wnd_end(const struct tcp_sock *tp)
 {
 	return tp->snd_una + tp->snd_wnd;
 }
-extern int tcp_is_cwnd_limited(const struct sock *sk, u32 in_flight);
+extern bool tcp_is_cwnd_limited(const struct sock *sk, u32 in_flight);
 
 static inline void tcp_minshall_update(struct tcp_sock *tp, unsigned int mss,
 				       const struct sk_buff *skb)
@@ -944,7 +944,7 @@ static inline __sum16 __tcp_checksum_complete(struct sk_buff *skb)
 	return __skb_checksum_complete(skb);
 }
 
-static inline int tcp_checksum_complete(struct sk_buff *skb)
+static inline bool tcp_checksum_complete(struct sk_buff *skb)
 {
 	return !skb_csum_unnecessary(skb) &&
 		__tcp_checksum_complete(skb);
@@ -974,12 +974,12 @@ static inline void tcp_prequeue_init(struct tcp_sock *tp)
  *
  * NOTE: is this not too big to inline?
  */
-static inline int tcp_prequeue(struct sock *sk, struct sk_buff *skb)
+static inline bool tcp_prequeue(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	if (sysctl_tcp_low_latency || !tp->ucopy.task)
-		return 0;
+		return false;
 
 	__skb_queue_tail(&tp->ucopy.prequeue, skb);
 	tp->ucopy.memory += skb->truesize;
@@ -1003,7 +1003,7 @@ static inline int tcp_prequeue(struct sock *sk, struct sk_buff *skb)
 						  (3 * tcp_rto_min(sk)) / 4,
 						  TCP_RTO_MAX);
 	}
-	return 1;
+	return true;
 }
 
 
@@ -1108,28 +1108,28 @@ static inline int tcp_fin_time(const struct sock *sk)
 	return fin_timeout;
 }
 
-static inline int tcp_paws_check(const struct tcp_options_received *rx_opt,
-				 int paws_win)
+static inline bool tcp_paws_check(const struct tcp_options_received *rx_opt,
+				  int paws_win)
 {
 	if ((s32)(rx_opt->ts_recent - rx_opt->rcv_tsval) <= paws_win)
-		return 1;
+		return true;
 	if (unlikely(get_seconds() >= rx_opt->ts_recent_stamp + TCP_PAWS_24DAYS))
-		return 1;
+		return true;
 	/*
 	 * Some OSes send SYN and SYNACK messages with tsval=0 tsecr=0,
 	 * then following tcp messages have valid values. Ignore 0 value,
 	 * or else 'negative' tsval might forbid us to accept their packets.
 	 */
 	if (!rx_opt->ts_recent)
-		return 1;
-	return 0;
+		return true;
+	return false;
 }
 
-static inline int tcp_paws_reject(const struct tcp_options_received *rx_opt,
-				  int rst)
+static inline bool tcp_paws_reject(const struct tcp_options_received *rx_opt,
+				   int rst)
 {
 	if (tcp_paws_check(rx_opt, 0))
-		return 0;
+		return false;
 
 	/* RST segments are not recommended to carry timestamp,
 	   and, if they do, it is recommended to ignore PAWS because
@@ -1144,8 +1144,8 @@ static inline int tcp_paws_reject(const struct tcp_options_received *rx_opt,
 	   However, we can relax time bounds for RST segments to MSL.
 	 */
 	if (rst && get_seconds() >= rx_opt->ts_recent_stamp + TCP_PAWS_MSL)
-		return 0;
-	return 1;
+		return false;
+	return true;
 }
 
 static inline void tcp_mib_init(struct net *net)
@@ -1383,7 +1383,7 @@ static inline void tcp_unlink_write_queue(struct sk_buff *skb, struct sock *sk)
 	__skb_unlink(skb, &sk->sk_write_queue);
 }
 
-static inline int tcp_write_queue_empty(struct sock *sk)
+static inline bool tcp_write_queue_empty(struct sock *sk)
 {
 	return skb_queue_empty(&sk->sk_write_queue);
 }
@@ -1440,7 +1440,7 @@ static inline void tcp_highest_sack_combine(struct sock *sk,
 /* Determines whether this is a thin stream (which may suffer from
  * increased latency). Used to trigger latency-reducing mechanisms.
  */
-static inline unsigned int tcp_stream_is_thin(struct tcp_sock *tp)
+static inline bool tcp_stream_is_thin(struct tcp_sock *tp)
 {
 	return tp->packets_out < 4 && !tcp_in_initial_slowstart(tp);
 }
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index e8a80d0..63ddaee 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -593,7 +593,7 @@ static inline void tcp_mark_push(struct tcp_sock *tp, struct sk_buff *skb)
 	tp->pushed_seq = tp->write_seq;
 }
 
-static inline int forced_push(const struct tcp_sock *tp)
+static inline bool forced_push(const struct tcp_sock *tp)
 {
 	return after(tp->write_seq, tp->pushed_seq + (tp->max_window >> 1));
 }
@@ -1082,7 +1082,7 @@ new_segment:
 				if (err)
 					goto do_fault;
 			} else {
-				int merge = 0;
+				bool merge = false;
 				int i = skb_shinfo(skb)->nr_frags;
 				struct page *page = sk->sk_sndmsg_page;
 				int off;
@@ -1096,7 +1096,7 @@ new_segment:
 				    off != PAGE_SIZE) {
 					/* We can extend the last page
 					 * fragment. */
-					merge = 1;
+					merge = true;
 				} else if (i == MAX_SKB_FRAGS || !sg) {
 					/* Need to add new fragment and cannot
 					 * do this because interface is non-SG,
@@ -1293,7 +1293,7 @@ static int tcp_peek_sndq(struct sock *sk, struct msghdr *msg, int len)
 void tcp_cleanup_rbuf(struct sock *sk, int copied)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	int time_to_ack = 0;
+	bool time_to_ack = false;
 
 	struct sk_buff *skb = skb_peek(&sk->sk_receive_queue);
 
@@ -1319,7 +1319,7 @@ void tcp_cleanup_rbuf(struct sock *sk, int copied)
 		      ((icsk->icsk_ack.pending & ICSK_ACK_PUSHED) &&
 		       !icsk->icsk_ack.pingpong)) &&
 		      !atomic_read(&sk->sk_rmem_alloc)))
-			time_to_ack = 1;
+			time_to_ack = true;
 	}
 
 	/* We send an ACK if we can now advertise a non-zero window
@@ -1341,7 +1341,7 @@ void tcp_cleanup_rbuf(struct sock *sk, int copied)
 			 * "Lots" means "at least twice" here.
 			 */
 			if (new_window && new_window >= 2 * rcv_window_now)
-				time_to_ack = 1;
+				time_to_ack = true;
 		}
 	}
 	if (time_to_ack)
@@ -2171,7 +2171,7 @@ EXPORT_SYMBOL(tcp_close);
 
 /* These states need RST on ABORT according to RFC793 */
 
-static inline int tcp_need_reset(int state)
+static inline bool tcp_need_reset(int state)
 {
 	return (1 << state) &
 	       (TCPF_ESTABLISHED | TCPF_CLOSE_WAIT | TCPF_FIN_WAIT1 |
@@ -2245,7 +2245,7 @@ int tcp_disconnect(struct sock *sk, int flags)
 }
 EXPORT_SYMBOL(tcp_disconnect);
 
-static inline int tcp_can_repair_sock(struct sock *sk)
+static inline bool tcp_can_repair_sock(const struct sock *sk)
 {
 	return capable(CAP_NET_ADMIN) &&
 		((1 << sk->sk_state) & (TCPF_CLOSE | TCPF_ESTABLISHED));
@@ -3172,13 +3172,13 @@ out_free:
 struct tcp_md5sig_pool __percpu *tcp_alloc_md5sig_pool(struct sock *sk)
 {
 	struct tcp_md5sig_pool __percpu *pool;
-	int alloc = 0;
+	bool alloc = false;
 
 retry:
 	spin_lock_bh(&tcp_md5sig_pool_lock);
 	pool = tcp_md5sig_pool;
 	if (tcp_md5sig_users++ == 0) {
-		alloc = 1;
+		alloc = true;
 		spin_unlock_bh(&tcp_md5sig_pool_lock);
 	} else if (!pool) {
 		tcp_md5sig_users--;
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 272a845..04dbd7a 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -280,19 +280,19 @@ int tcp_set_congestion_control(struct sock *sk, const char *name)
 /* RFC2861 Check whether we are limited by application or congestion window
  * This is the inverse of cwnd check in tcp_tso_should_defer
  */
-int tcp_is_cwnd_limited(const struct sock *sk, u32 in_flight)
+bool tcp_is_cwnd_limited(const struct sock *sk, u32 in_flight)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	u32 left;
 
 	if (in_flight >= tp->snd_cwnd)
-		return 1;
+		return true;
 
 	left = tp->snd_cwnd - in_flight;
 	if (sk_can_gso(sk) &&
 	    left * sysctl_tcp_tso_win_divisor < tp->snd_cwnd &&
 	    left * tp->mss_cache < sk->sk_gso_max_size)
-		return 1;
+		return true;
 	return left <= tcp_max_tso_deferred_mss(tp);
 }
 EXPORT_SYMBOL_GPL(tcp_is_cwnd_limited);
diff --git a/net/ipv4/tcp_hybla.c b/net/ipv4/tcp_hybla.c
index fe3ecf4..57bdd17 100644
--- a/net/ipv4/tcp_hybla.c
+++ b/net/ipv4/tcp_hybla.c
@@ -15,7 +15,7 @@
 
 /* Tcp Hybla structure. */
 struct hybla {
-	u8    hybla_en;
+	bool  hybla_en;
 	u32   snd_cwnd_cents; /* Keeps increment values when it is <1, <<7 */
 	u32   rho;	      /* Rho parameter, integer part  */
 	u32   rho2;	      /* Rho * Rho, integer part */
@@ -24,8 +24,7 @@ struct hybla {
 	u32   minrtt;	      /* Minimum smoothed round trip time value seen */
 };
 
-/* Hybla reference round trip time (default= 1/40 sec = 25 ms),
-   expressed in jiffies */
+/* Hybla reference round trip time (default= 1/40 sec = 25 ms), in ms */
 static int rtt0 = 25;
 module_param(rtt0, int, 0644);
 MODULE_PARM_DESC(rtt0, "reference rout trip time (ms)");
@@ -39,7 +38,7 @@ static inline void hybla_recalc_param (struct sock *sk)
 	ca->rho_3ls = max_t(u32, tcp_sk(sk)->srtt / msecs_to_jiffies(rtt0), 8);
 	ca->rho = ca->rho_3ls >> 3;
 	ca->rho2_7ls = (ca->rho_3ls * ca->rho_3ls) << 1;
-	ca->rho2 = ca->rho2_7ls >>7;
+	ca->rho2 = ca->rho2_7ls >> 7;
 }
 
 static void hybla_init(struct sock *sk)
@@ -52,7 +51,7 @@ static void hybla_init(struct sock *sk)
 	ca->rho_3ls = 0;
 	ca->rho2_7ls = 0;
 	ca->snd_cwnd_cents = 0;
-	ca->hybla_en = 1;
+	ca->hybla_en = true;
 	tp->snd_cwnd = 2;
 	tp->snd_cwnd_clamp = 65535;
 
@@ -67,6 +66,7 @@ static void hybla_init(struct sock *sk)
 static void hybla_state(struct sock *sk, u8 ca_state)
 {
 	struct hybla *ca = inet_csk_ca(sk);
+
 	ca->hybla_en = (ca_state == TCP_CA_Open);
 }
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index eb97787..b961ef5 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -196,9 +196,10 @@ static void tcp_enter_quickack_mode(struct sock *sk)
  * and the session is not interactive.
  */
 
-static inline int tcp_in_quickack_mode(const struct sock *sk)
+static inline bool tcp_in_quickack_mode(const struct sock *sk)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
+
 	return icsk->icsk_ack.quick && !icsk->icsk_ack.pingpong;
 }
 
@@ -253,11 +254,11 @@ static inline void TCP_ECN_rcv_syn(struct tcp_sock *tp, const struct tcphdr *th)
 		tp->ecn_flags &= ~TCP_ECN_OK;
 }
 
-static inline int TCP_ECN_rcv_ecn_echo(const struct tcp_sock *tp, const struct tcphdr *th)
+static bool TCP_ECN_rcv_ecn_echo(const struct tcp_sock *tp, const struct tcphdr *th)
 {
 	if (th->ece && !th->syn && (tp->ecn_flags & TCP_ECN_OK))
-		return 1;
-	return 0;
+		return true;
+	return false;
 }
 
 /* Buffer size and advertised window tuning.
@@ -1123,36 +1124,36 @@ static void tcp_skb_mark_lost_uncond_verify(struct tcp_sock *tp,
  * the exact amount is rather hard to quantify. However, tp->max_window can
  * be used as an exaggerated estimate.
  */
-static int tcp_is_sackblock_valid(struct tcp_sock *tp, int is_dsack,
-				  u32 start_seq, u32 end_seq)
+static bool tcp_is_sackblock_valid(struct tcp_sock *tp, bool is_dsack,
+				   u32 start_seq, u32 end_seq)
 {
 	/* Too far in future, or reversed (interpretation is ambiguous) */
 	if (after(end_seq, tp->snd_nxt) || !before(start_seq, end_seq))
-		return 0;
+		return false;
 
 	/* Nasty start_seq wrap-around check (see comments above) */
 	if (!before(start_seq, tp->snd_nxt))
-		return 0;
+		return false;
 
 	/* In outstanding window? ...This is valid exit for D-SACKs too.
 	 * start_seq == snd_una is non-sensical (see comments above)
 	 */
 	if (after(start_seq, tp->snd_una))
-		return 1;
+		return true;
 
 	if (!is_dsack || !tp->undo_marker)
-		return 0;
+		return false;
 
 	/* ...Then it's D-SACK, and must reside below snd_una completely */
 	if (after(end_seq, tp->snd_una))
-		return 0;
+		return false;
 
 	if (!before(start_seq, tp->undo_marker))
-		return 1;
+		return true;
 
 	/* Too old */
 	if (!after(end_seq, tp->undo_marker))
-		return 0;
+		return false;
 
 	/* Undo_marker boundary crossing (overestimates a lot). Known already:
 	 *   start_seq < undo_marker and end_seq >= undo_marker.
@@ -1224,17 +1225,17 @@ static void tcp_mark_lost_retrans(struct sock *sk)
 		tp->lost_retrans_low = new_low_seq;
 }
 
-static int tcp_check_dsack(struct sock *sk, const struct sk_buff *ack_skb,
-			   struct tcp_sack_block_wire *sp, int num_sacks,
-			   u32 prior_snd_una)
+static bool tcp_check_dsack(struct sock *sk, const struct sk_buff *ack_skb,
+			    struct tcp_sack_block_wire *sp, int num_sacks,
+			    u32 prior_snd_una)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	u32 start_seq_0 = get_unaligned_be32(&sp[0].start_seq);
 	u32 end_seq_0 = get_unaligned_be32(&sp[0].end_seq);
-	int dup_sack = 0;
+	bool dup_sack = false;
 
 	if (before(start_seq_0, TCP_SKB_CB(ack_skb)->ack_seq)) {
-		dup_sack = 1;
+		dup_sack = true;
 		tcp_dsack_seen(tp);
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPDSACKRECV);
 	} else if (num_sacks > 1) {
@@ -1243,7 +1244,7 @@ static int tcp_check_dsack(struct sock *sk, const struct sk_buff *ack_skb,
 
 		if (!after(end_seq_0, end_seq_1) &&
 		    !before(start_seq_0, start_seq_1)) {
-			dup_sack = 1;
+			dup_sack = true;
 			tcp_dsack_seen(tp);
 			NET_INC_STATS_BH(sock_net(sk),
 					LINUX_MIB_TCPDSACKOFORECV);
@@ -1274,9 +1275,10 @@ struct tcp_sacktag_state {
  * FIXME: this could be merged to shift decision code
  */
 static int tcp_match_skb_to_sack(struct sock *sk, struct sk_buff *skb,
-				 u32 start_seq, u32 end_seq)
+				  u32 start_seq, u32 end_seq)
 {
-	int in_sack, err;
+	int err;
+	bool in_sack;
 	unsigned int pkt_len;
 	unsigned int mss;
 
@@ -1322,7 +1324,7 @@ static int tcp_match_skb_to_sack(struct sock *sk, struct sk_buff *skb,
 static u8 tcp_sacktag_one(struct sock *sk,
 			  struct tcp_sacktag_state *state, u8 sacked,
 			  u32 start_seq, u32 end_seq,
-			  int dup_sack, int pcount)
+			  bool dup_sack, int pcount)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int fack_count = state->fack_count;
@@ -1402,10 +1404,10 @@ static u8 tcp_sacktag_one(struct sock *sk,
 /* Shift newly-SACKed bytes from this skb to the immediately previous
  * already-SACKed sk_buff. Mark the newly-SACKed bytes as such.
  */
-static int tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
-			   struct tcp_sacktag_state *state,
-			   unsigned int pcount, int shifted, int mss,
-			   int dup_sack)
+static bool tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
+			    struct tcp_sacktag_state *state,
+			    unsigned int pcount, int shifted, int mss,
+			    bool dup_sack)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *prev = tcp_write_queue_prev(sk, skb);
@@ -1455,7 +1457,7 @@ static int tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
 	if (skb->len > 0) {
 		BUG_ON(!tcp_skb_pcount(skb));
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SACKSHIFTED);
-		return 0;
+		return false;
 	}
 
 	/* Whole SKB was eaten :-) */
@@ -1478,7 +1480,7 @@ static int tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
 
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SACKMERGED);
 
-	return 1;
+	return true;
 }
 
 /* I wish gso_size would have a bit more sane initialization than
@@ -1501,7 +1503,7 @@ static int skb_can_shift(const struct sk_buff *skb)
 static struct sk_buff *tcp_shift_skb_data(struct sock *sk, struct sk_buff *skb,
 					  struct tcp_sacktag_state *state,
 					  u32 start_seq, u32 end_seq,
-					  int dup_sack)
+					  bool dup_sack)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *prev;
@@ -1640,14 +1642,14 @@ static struct sk_buff *tcp_sacktag_walk(struct sk_buff *skb, struct sock *sk,
 					struct tcp_sack_block *next_dup,
 					struct tcp_sacktag_state *state,
 					u32 start_seq, u32 end_seq,
-					int dup_sack_in)
+					bool dup_sack_in)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *tmp;
 
 	tcp_for_write_queue_from(skb, sk) {
 		int in_sack = 0;
-		int dup_sack = dup_sack_in;
+		bool dup_sack = dup_sack_in;
 
 		if (skb == tcp_send_head(sk))
 			break;
@@ -1662,7 +1664,7 @@ static struct sk_buff *tcp_sacktag_walk(struct sk_buff *skb, struct sock *sk,
 							next_dup->start_seq,
 							next_dup->end_seq);
 			if (in_sack > 0)
-				dup_sack = 1;
+				dup_sack = true;
 		}
 
 		/* skb reference here is a bit tricky to get right, since
@@ -1767,7 +1769,7 @@ tcp_sacktag_write_queue(struct sock *sk, const struct sk_buff *ack_skb,
 	struct sk_buff *skb;
 	int num_sacks = min(TCP_NUM_SACKS, (ptr[1] - TCPOLEN_SACK_BASE) >> 3);
 	int used_sacks;
-	int found_dup_sack = 0;
+	bool found_dup_sack = false;
 	int i, j;
 	int first_sack_index;
 
@@ -1798,7 +1800,7 @@ tcp_sacktag_write_queue(struct sock *sk, const struct sk_buff *ack_skb,
 	used_sacks = 0;
 	first_sack_index = 0;
 	for (i = 0; i < num_sacks; i++) {
-		int dup_sack = !i && found_dup_sack;
+		bool dup_sack = !i && found_dup_sack;
 
 		sp[used_sacks].start_seq = get_unaligned_be32(&sp_wire[i].start_seq);
 		sp[used_sacks].end_seq = get_unaligned_be32(&sp_wire[i].end_seq);
@@ -1865,7 +1867,7 @@ tcp_sacktag_write_queue(struct sock *sk, const struct sk_buff *ack_skb,
 	while (i < used_sacks) {
 		u32 start_seq = sp[i].start_seq;
 		u32 end_seq = sp[i].end_seq;
-		int dup_sack = (found_dup_sack && (i == first_sack_index));
+		bool dup_sack = (found_dup_sack && (i == first_sack_index));
 		struct tcp_sack_block *next_dup = NULL;
 
 		if (found_dup_sack && ((i + 1) == first_sack_index))
@@ -1967,9 +1969,9 @@ out:
 }
 
 /* Limits sacked_out so that sum with lost_out isn't ever larger than
- * packets_out. Returns zero if sacked_out adjustement wasn't necessary.
+ * packets_out. Returns false if sacked_out adjustement wasn't necessary.
  */
-static int tcp_limit_reno_sacked(struct tcp_sock *tp)
+static bool tcp_limit_reno_sacked(struct tcp_sock *tp)
 {
 	u32 holes;
 
@@ -1978,9 +1980,9 @@ static int tcp_limit_reno_sacked(struct tcp_sock *tp)
 
 	if ((tp->sacked_out + holes) > tp->packets_out) {
 		tp->sacked_out = tp->packets_out - holes;
-		return 1;
+		return true;
 	}
-	return 0;
+	return false;
 }
 
 /* If we receive more dupacks than we expected counting segments
@@ -2034,40 +2036,40 @@ static int tcp_is_sackfrto(const struct tcp_sock *tp)
 /* F-RTO can only be used if TCP has never retransmitted anything other than
  * head (SACK enhanced variant from Appendix B of RFC4138 is more robust here)
  */
-int tcp_use_frto(struct sock *sk)
+bool tcp_use_frto(struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	struct sk_buff *skb;
 
 	if (!sysctl_tcp_frto)
-		return 0;
+		return false;
 
 	/* MTU probe and F-RTO won't really play nicely along currently */
 	if (icsk->icsk_mtup.probe_size)
-		return 0;
+		return false;
 
 	if (tcp_is_sackfrto(tp))
-		return 1;
+		return true;
 
 	/* Avoid expensive walking of rexmit queue if possible */
 	if (tp->retrans_out > 1)
-		return 0;
+		return false;
 
 	skb = tcp_write_queue_head(sk);
 	if (tcp_skb_is_last(sk, skb))
-		return 1;
+		return true;
 	skb = tcp_write_queue_next(sk, skb);	/* Skips head */
 	tcp_for_write_queue_from(skb, sk) {
 		if (skb == tcp_send_head(sk))
 			break;
 		if (TCP_SKB_CB(skb)->sacked & TCPCB_RETRANS)
-			return 0;
+			return false;
 		/* Short-circuit when first non-SACKed skb has been checked */
 		if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
 			break;
 	}
-	return 1;
+	return true;
 }
 
 /* RTO occurred, but do not yet enter Loss state. Instead, defer RTO
@@ -2303,7 +2305,7 @@ void tcp_enter_loss(struct sock *sk, int how)
  *
  * Do processing similar to RTO timeout.
  */
-static int tcp_check_sack_reneging(struct sock *sk, int flag)
+static bool tcp_check_sack_reneging(struct sock *sk, int flag)
 {
 	if (flag & FLAG_SACK_RENEGING) {
 		struct inet_connection_sock *icsk = inet_csk(sk);
@@ -2314,9 +2316,9 @@ static int tcp_check_sack_reneging(struct sock *sk, int flag)
 		tcp_retransmit_skb(sk, tcp_write_queue_head(sk));
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
 					  icsk->icsk_rto, TCP_RTO_MAX);
-		return 1;
+		return true;
 	}
-	return 0;
+	return false;
 }
 
 static inline int tcp_fackets_out(const struct tcp_sock *tp)
@@ -2472,28 +2474,28 @@ static inline int tcp_head_timedout(const struct sock *sk)
  * Main question: may we further continue forward transmission
  * with the same cwnd?
  */
-static int tcp_time_to_recover(struct sock *sk, int flag)
+static bool tcp_time_to_recover(struct sock *sk, int flag)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	__u32 packets_out;
 
 	/* Do not perform any recovery during F-RTO algorithm */
 	if (tp->frto_counter)
-		return 0;
+		return false;
 
 	/* Trick#1: The loss is proven. */
 	if (tp->lost_out)
-		return 1;
+		return true;
 
 	/* Not-A-Trick#2 : Classic rule... */
 	if (tcp_dupack_heuristics(tp) > tp->reordering)
-		return 1;
+		return true;
 
 	/* Trick#3 : when we use RFC2988 timer restart, fast
 	 * retransmit can be triggered by timeout of queue head.
 	 */
 	if (tcp_is_fack(tp) && tcp_head_timedout(sk))
-		return 1;
+		return true;
 
 	/* Trick#4: It is still not OK... But will it be useful to delay
 	 * recovery more?
@@ -2505,7 +2507,7 @@ static int tcp_time_to_recover(struct sock *sk, int flag)
 		/* We have nothing to send. This connection is limited
 		 * either by receiver window or by application.
 		 */
-		return 1;
+		return true;
 	}
 
 	/* If a thin stream is detected, retransmit after first
@@ -2516,7 +2518,7 @@ static int tcp_time_to_recover(struct sock *sk, int flag)
 	if ((tp->thin_dupack || sysctl_tcp_thin_dupack) &&
 	    tcp_stream_is_thin(tp) && tcp_dupack_heuristics(tp) > 1 &&
 	    tcp_is_sack(tp) && !tcp_send_head(sk))
-		return 1;
+		return true;
 
 	/* Trick#6: TCP early retransmit, per RFC5827.  To avoid spurious
 	 * retransmissions due to small network reorderings, we implement
@@ -2528,7 +2530,7 @@ static int tcp_time_to_recover(struct sock *sk, int flag)
 	    !tcp_may_send_now(sk))
 		return !tcp_pause_early_retransmit(sk, flag);
 
-	return 0;
+	return false;
 }
 
 /* New heuristics: it is possible only after we switched to restart timer
@@ -2767,7 +2769,7 @@ static inline int tcp_may_undo(const struct tcp_sock *tp)
 }
 
 /* People celebrate: "We love our President!" */
-static int tcp_try_undo_recovery(struct sock *sk)
+static bool tcp_try_undo_recovery(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
@@ -2792,10 +2794,10 @@ static int tcp_try_undo_recovery(struct sock *sk)
 		 * is ACKed. For Reno it is MUST to prevent false
 		 * fast retransmits (RFC2582). SACK TCP is safe. */
 		tcp_moderate_cwnd(tp);
-		return 1;
+		return true;
 	}
 	tcp_set_ca_state(sk, TCP_CA_Open);
-	return 0;
+	return false;
 }
 
 /* Try to undo cwnd reduction, because D-SACKs acked all retransmitted data */
@@ -2825,19 +2827,19 @@ static void tcp_try_undo_dsack(struct sock *sk)
  * that successive retransmissions of a segment must not advance
  * retrans_stamp under any conditions.
  */
-static int tcp_any_retrans_done(const struct sock *sk)
+static bool tcp_any_retrans_done(const struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
 
 	if (tp->retrans_out)
-		return 1;
+		return true;
 
 	skb = tcp_write_queue_head(sk);
 	if (unlikely(skb && TCP_SKB_CB(skb)->sacked & TCPCB_EVER_RETRANS))
-		return 1;
+		return true;
 
-	return 0;
+	return false;
 }
 
 /* Undo during fast recovery after partial ACK. */
@@ -2871,7 +2873,7 @@ static int tcp_try_undo_partial(struct sock *sk, int acked)
 }
 
 /* Undo during loss recovery after partial ACK. */
-static int tcp_try_undo_loss(struct sock *sk)
+static bool tcp_try_undo_loss(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
@@ -2893,9 +2895,9 @@ static int tcp_try_undo_loss(struct sock *sk)
 		tp->undo_marker = 0;
 		if (tcp_is_sack(tp))
 			tcp_set_ca_state(sk, TCP_CA_Open);
-		return 1;
+		return true;
 	}
-	return 0;
+	return false;
 }
 
 static inline void tcp_complete_cwr(struct sock *sk)
@@ -3370,7 +3372,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	struct sk_buff *skb;
 	u32 now = tcp_time_stamp;
-	int fully_acked = 1;
+	int fully_acked = true;
 	int flag = 0;
 	u32 pkts_acked = 0;
 	u32 reord = tp->packets_out;
@@ -3394,7 +3396,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 			if (!acked_pcount)
 				break;
 
-			fully_acked = 0;
+			fully_acked = false;
 		} else {
 			acked_pcount = tcp_skb_pcount(skb);
 		}
@@ -3673,7 +3675,7 @@ static void tcp_undo_spur_to_response(struct sock *sk, int flag)
  *     to prove that the RTO is indeed spurious. It transfers the control
  *     from F-RTO to the conventional RTO recovery
  */
-static int tcp_process_frto(struct sock *sk, int flag)
+static bool tcp_process_frto(struct sock *sk, int flag)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
@@ -3689,7 +3691,7 @@ static int tcp_process_frto(struct sock *sk, int flag)
 
 	if (!before(tp->snd_una, tp->frto_highmark)) {
 		tcp_enter_frto_loss(sk, (tp->frto_counter == 1 ? 2 : 3), flag);
-		return 1;
+		return true;
 	}
 
 	if (!tcp_is_sackfrto(tp)) {
@@ -3698,19 +3700,19 @@ static int tcp_process_frto(struct sock *sk, int flag)
 		 * data, winupdate
 		 */
 		if (!(flag & FLAG_ANY_PROGRESS) && (flag & FLAG_NOT_DUP))
-			return 1;
+			return true;
 
 		if (!(flag & FLAG_DATA_ACKED)) {
 			tcp_enter_frto_loss(sk, (tp->frto_counter == 1 ? 0 : 3),
 					    flag);
-			return 1;
+			return true;
 		}
 	} else {
 		if (!(flag & FLAG_DATA_ACKED) && (tp->frto_counter == 1)) {
 			/* Prevent sending of new data. */
 			tp->snd_cwnd = min(tp->snd_cwnd,
 					   tcp_packets_in_flight(tp));
-			return 1;
+			return true;
 		}
 
 		if ((tp->frto_counter >= 2) &&
@@ -3720,10 +3722,10 @@ static int tcp_process_frto(struct sock *sk, int flag)
 			/* RFC4138 shortcoming (see comment above) */
 			if (!(flag & FLAG_FORWARD_PROGRESS) &&
 			    (flag & FLAG_NOT_DUP))
-				return 1;
+				return true;
 
 			tcp_enter_frto_loss(sk, 3, flag);
-			return 1;
+			return true;
 		}
 	}
 
@@ -3735,7 +3737,7 @@ static int tcp_process_frto(struct sock *sk, int flag)
 		if (!tcp_may_send_now(sk))
 			tcp_enter_frto_loss(sk, 2, flag);
 
-		return 1;
+		return true;
 	} else {
 		switch (sysctl_tcp_frto_response) {
 		case 2:
@@ -3752,7 +3754,7 @@ static int tcp_process_frto(struct sock *sk, int flag)
 		tp->undo_marker = 0;
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPSPURIOUSRTOS);
 	}
-	return 0;
+	return false;
 }
 
 /* This routine deals with incoming acks, but not outgoing ones. */
@@ -3770,7 +3772,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	int prior_sacked = tp->sacked_out;
 	int pkts_acked = 0;
 	int newly_acked_sacked = 0;
-	int frto_cwnd = 0;
+	bool frto_cwnd = false;
 
 	/* If the ack is older than previous acks
 	 * then we can probably ignore it.
@@ -4025,7 +4027,7 @@ void tcp_parse_options(const struct sk_buff *skb, struct tcp_options_received *o
 }
 EXPORT_SYMBOL(tcp_parse_options);
 
-static int tcp_parse_aligned_timestamp(struct tcp_sock *tp, const struct tcphdr *th)
+static bool tcp_parse_aligned_timestamp(struct tcp_sock *tp, const struct tcphdr *th)
 {
 	const __be32 *ptr = (const __be32 *)(th + 1);
 
@@ -4036,31 +4038,31 @@ static int tcp_parse_aligned_timestamp(struct tcp_sock *tp, const struct tcphdr
 		tp->rx_opt.rcv_tsval = ntohl(*ptr);
 		++ptr;
 		tp->rx_opt.rcv_tsecr = ntohl(*ptr);
-		return 1;
+		return true;
 	}
-	return 0;
+	return false;
 }
 
 /* Fast parse options. This hopes to only see timestamps.
  * If it is wrong it falls back on tcp_parse_options().
  */
-static int tcp_fast_parse_options(const struct sk_buff *skb,
-				  const struct tcphdr *th,
-				  struct tcp_sock *tp, const u8 **hvpp)
+static bool tcp_fast_parse_options(const struct sk_buff *skb,
+				   const struct tcphdr *th,
+				   struct tcp_sock *tp, const u8 **hvpp)
 {
 	/* In the spirit of fast parsing, compare doff directly to constant
 	 * values.  Because equality is used, short doff can be ignored here.
 	 */
 	if (th->doff == (sizeof(*th) / 4)) {
 		tp->rx_opt.saw_tstamp = 0;
-		return 0;
+		return false;
 	} else if (tp->rx_opt.tstamp_ok &&
 		   th->doff == ((sizeof(*th) + TCPOLEN_TSTAMP_ALIGNED) / 4)) {
 		if (tcp_parse_aligned_timestamp(tp, th))
-			return 1;
+			return true;
 	}
 	tcp_parse_options(skb, &tp->rx_opt, hvpp, 1);
-	return 1;
+	return true;
 }
 
 #ifdef CONFIG_TCP_MD5SIG
@@ -4301,7 +4303,7 @@ static void tcp_fin(struct sock *sk)
 	}
 }
 
-static inline int tcp_sack_extend(struct tcp_sack_block *sp, u32 seq,
+static inline bool tcp_sack_extend(struct tcp_sack_block *sp, u32 seq,
 				  u32 end_seq)
 {
 	if (!after(seq, sp->end_seq) && !after(sp->start_seq, end_seq)) {
@@ -4309,9 +4311,9 @@ static inline int tcp_sack_extend(struct tcp_sack_block *sp, u32 seq,
 			sp->start_seq = seq;
 		if (after(end_seq, sp->end_seq))
 			sp->end_seq = end_seq;
-		return 1;
+		return true;
 	}
-	return 0;
+	return false;
 }
 
 static void tcp_dsack_set(struct sock *sk, u32 seq, u32 end_seq)
@@ -4507,7 +4509,7 @@ static void tcp_ofo_queue(struct sock *sk)
 	}
 }
 
-static int tcp_prune_ofo_queue(struct sock *sk);
+static bool tcp_prune_ofo_queue(struct sock *sk);
 static int tcp_prune_queue(struct sock *sk);
 
 static int tcp_try_rmem_schedule(struct sock *sk, unsigned int size)
@@ -5092,10 +5094,10 @@ static void tcp_collapse_ofo_queue(struct sock *sk)
  * Purge the out-of-order queue.
  * Return true if queue was pruned.
  */
-static int tcp_prune_ofo_queue(struct sock *sk)
+static bool tcp_prune_ofo_queue(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	int res = 0;
+	bool res = false;
 
 	if (!skb_queue_empty(&tp->out_of_order_queue)) {
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_OFOPRUNED);
@@ -5109,7 +5111,7 @@ static int tcp_prune_ofo_queue(struct sock *sk)
 		if (tp->rx_opt.sack_ok)
 			tcp_sack_reset(&tp->rx_opt);
 		sk_mem_reclaim(sk);
-		res = 1;
+		res = true;
 	}
 	return res;
 }
@@ -5186,7 +5188,7 @@ void tcp_cwnd_application_limited(struct sock *sk)
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
-static int tcp_should_expand_sndbuf(const struct sock *sk)
+static bool tcp_should_expand_sndbuf(const struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 
@@ -5194,21 +5196,21 @@ static int tcp_should_expand_sndbuf(const struct sock *sk)
 	 * not modify it.
 	 */
 	if (sk->sk_userlocks & SOCK_SNDBUF_LOCK)
-		return 0;
+		return false;
 
 	/* If we are under global TCP memory pressure, do not expand.  */
 	if (sk_under_memory_pressure(sk))
-		return 0;
+		return false;
 
 	/* If we are under soft global TCP memory pressure, do not expand.  */
 	if (sk_memory_allocated(sk) >= sk_prot_mem_limits(sk, 0))
-		return 0;
+		return false;
 
 	/* If we filled the congestion window, do not expand.  */
 	if (tp->packets_out >= tp->snd_cwnd)
-		return 0;
+		return false;
 
-	return 1;
+	return true;
 }
 
 /* When incoming ACK allowed to free some skb from write_queue,
@@ -5434,16 +5436,16 @@ static inline int tcp_checksum_complete_user(struct sock *sk,
 }
 
 #ifdef CONFIG_NET_DMA
-static int tcp_dma_try_early_copy(struct sock *sk, struct sk_buff *skb,
+static bool tcp_dma_try_early_copy(struct sock *sk, struct sk_buff *skb,
 				  int hlen)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int chunk = skb->len - hlen;
 	int dma_cookie;
-	int copied_early = 0;
+	bool copied_early = false;
 
 	if (tp->ucopy.wakeup)
-		return 0;
+		return false;
 
 	if (!tp->ucopy.dma_chan && tp->ucopy.pinned_list)
 		tp->ucopy.dma_chan = net_dma_find_channel();
@@ -5459,7 +5461,7 @@ static int tcp_dma_try_early_copy(struct sock *sk, struct sk_buff *skb,
 			goto out;
 
 		tp->ucopy.dma_cookie = dma_cookie;
-		copied_early = 1;
+		copied_early = true;
 
 		tp->ucopy.len -= chunk;
 		tp->copied_seq += chunk;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 2e76ffb..a43b87d 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -866,14 +866,14 @@ static void tcp_v4_reqsk_destructor(struct request_sock *req)
 }
 
 /*
- * Return 1 if a syncookie should be sent
+ * Return true if a syncookie should be sent
  */
-int tcp_syn_flood_action(struct sock *sk,
+bool tcp_syn_flood_action(struct sock *sk,
 			 const struct sk_buff *skb,
 			 const char *proto)
 {
 	const char *msg = "Dropping request";
-	int want_cookie = 0;
+	bool want_cookie = false;
 	struct listen_sock *lopt;
 
 
@@ -881,7 +881,7 @@ int tcp_syn_flood_action(struct sock *sk,
 #ifdef CONFIG_SYN_COOKIES
 	if (sysctl_tcp_syncookies) {
 		msg = "Sending cookies";
-		want_cookie = 1;
+		want_cookie = true;
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPREQQFULLDOCOOKIES);
 	} else
 #endif
@@ -1196,7 +1196,7 @@ clear_hash_noput:
 }
 EXPORT_SYMBOL(tcp_v4_md5_hash_skb);
 
-static int tcp_v4_inbound_md5_hash(struct sock *sk, const struct sk_buff *skb)
+static bool tcp_v4_inbound_md5_hash(struct sock *sk, const struct sk_buff *skb)
 {
 	/*
 	 * This gets called for each TCP segment that arrives
@@ -1219,16 +1219,16 @@ static int tcp_v4_inbound_md5_hash(struct sock *sk, const struct sk_buff *skb)
 
 	/* We've parsed the options - do we have a hash? */
 	if (!hash_expected && !hash_location)
-		return 0;
+		return false;
 
 	if (hash_expected && !hash_location) {
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPMD5NOTFOUND);
-		return 1;
+		return true;
 	}
 
 	if (!hash_expected && hash_location) {
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPMD5UNEXPECTED);
-		return 1;
+		return true;
 	}
 
 	/* Okay, so this is hash_expected and hash_location -
@@ -1244,9 +1244,9 @@ static int tcp_v4_inbound_md5_hash(struct sock *sk, const struct sk_buff *skb)
 				     &iph->daddr, ntohs(th->dest),
 				     genhash ? " tcp_v4_calc_md5_hash failed"
 				     : "");
-		return 1;
+		return true;
 	}
-	return 0;
+	return false;
 }
 
 #endif
@@ -1280,7 +1280,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	__be32 saddr = ip_hdr(skb)->saddr;
 	__be32 daddr = ip_hdr(skb)->daddr;
 	__u32 isn = TCP_SKB_CB(skb)->when;
-	int want_cookie = 0;
+	bool want_cookie = false;
 
 	/* Never answer to SYNs send to broadcast or multicast */
 	if (skb_rtable(skb)->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST))
@@ -1339,7 +1339,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		while (l-- > 0)
 			*c++ ^= *hash_location++;
 
-		want_cookie = 0;	/* not our kind of cookie */
+		want_cookie = false;	/* not our kind of cookie */
 		tmp_ext.cookie_out_never = 0; /* false */
 		tmp_ext.cookie_plus = tmp_opt.cookie_plus;
 	} else if (!tp->rx_opt.cookie_in_always) {
@@ -2073,7 +2073,7 @@ static void *listening_get_idx(struct seq_file *seq, loff_t *pos)
 	return rc;
 }
 
-static inline int empty_bucket(struct tcp_iter_state *st)
+static inline bool empty_bucket(struct tcp_iter_state *st)
 {
 	return hlist_nulls_empty(&tcp_hashinfo.ehash[st->bucket].chain) &&
 		hlist_nulls_empty(&tcp_hashinfo.ehash[st->bucket].twchain);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 6f6a918..b85d9fe 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -55,7 +55,7 @@ EXPORT_SYMBOL_GPL(tcp_death_row);
  * state.
  */
 
-static int tcp_remember_stamp(struct sock *sk)
+static bool tcp_remember_stamp(struct sock *sk)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -72,13 +72,13 @@ static int tcp_remember_stamp(struct sock *sk)
 		}
 		if (release_it)
 			inet_putpeer(peer);
-		return 1;
+		return true;
 	}
 
-	return 0;
+	return false;
 }
 
-static int tcp_tw_remember_stamp(struct inet_timewait_sock *tw)
+static bool tcp_tw_remember_stamp(struct inet_timewait_sock *tw)
 {
 	struct sock *sk = (struct sock *) tw;
 	struct inet_peer *peer;
@@ -94,17 +94,17 @@ static int tcp_tw_remember_stamp(struct inet_timewait_sock *tw)
 			peer->tcp_ts	   = tcptw->tw_ts_recent;
 		}
 		inet_putpeer(peer);
-		return 1;
+		return true;
 	}
-	return 0;
+	return false;
 }
 
-static __inline__ int tcp_in_window(u32 seq, u32 end_seq, u32 s_win, u32 e_win)
+static bool tcp_in_window(u32 seq, u32 end_seq, u32 s_win, u32 e_win)
 {
 	if (seq == s_win)
-		return 1;
+		return true;
 	if (after(end_seq, s_win) && before(seq, e_win))
-		return 1;
+		return true;
 	return seq == e_win && seq == end_seq;
 }
 
@@ -143,7 +143,7 @@ tcp_timewait_state_process(struct inet_timewait_sock *tw, struct sk_buff *skb,
 	struct tcp_options_received tmp_opt;
 	const u8 *hash_location;
 	struct tcp_timewait_sock *tcptw = tcp_twsk((struct sock *)tw);
-	int paws_reject = 0;
+	bool paws_reject = false;
 
 	tmp_opt.saw_tstamp = 0;
 	if (th->doff > (sizeof(*th) >> 2) && tcptw->tw_ts_recent_stamp) {
@@ -316,7 +316,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 	struct inet_timewait_sock *tw = NULL;
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	const struct tcp_sock *tp = tcp_sk(sk);
-	int recycle_ok = 0;
+	bool recycle_ok = false;
 
 	if (tcp_death_row.sysctl_tw_recycle && tp->rx_opt.ts_recent_stamp)
 		recycle_ok = tcp_remember_stamp(sk);
@@ -575,7 +575,7 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 	struct sock *child;
 	const struct tcphdr *th = tcp_hdr(skb);
 	__be32 flg = tcp_flag_word(th) & (TCP_FLAG_RST|TCP_FLAG_SYN|TCP_FLAG_ACK);
-	int paws_reject = 0;
+	bool paws_reject = false;
 
 	tmp_opt.saw_tstamp = 0;
 	if (th->doff > (sizeof(struct tcphdr)>>2)) {
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 1a63082..803cbfe 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -370,7 +370,7 @@ static void tcp_init_nondata_skb(struct sk_buff *skb, u32 seq, u8 flags)
 	TCP_SKB_CB(skb)->end_seq = seq;
 }
 
-static inline int tcp_urg_mode(const struct tcp_sock *tp)
+static inline bool tcp_urg_mode(const struct tcp_sock *tp)
 {
 	return tp->snd_una != tp->snd_up;
 }
@@ -1391,20 +1391,20 @@ static int tcp_init_tso_segs(const struct sock *sk, struct sk_buff *skb,
 }
 
 /* Minshall's variant of the Nagle send check. */
-static inline int tcp_minshall_check(const struct tcp_sock *tp)
+static inline bool tcp_minshall_check(const struct tcp_sock *tp)
 {
 	return after(tp->snd_sml, tp->snd_una) &&
 		!after(tp->snd_sml, tp->snd_nxt);
 }
 
-/* Return 0, if packet can be sent now without violation Nagle's rules:
+/* Return false, if packet can be sent now without violation Nagle's rules:
  * 1. It is full sized.
  * 2. Or it contains FIN. (already checked by caller)
  * 3. Or TCP_CORK is not set, and TCP_NODELAY is set.
  * 4. Or TCP_CORK is not set, and all sent packets are ACKed.
  *    With Minshall's modification: all sent small packets are ACKed.
  */
-static inline int tcp_nagle_check(const struct tcp_sock *tp,
+static inline bool tcp_nagle_check(const struct tcp_sock *tp,
 				  const struct sk_buff *skb,
 				  unsigned int mss_now, int nonagle)
 {
@@ -1413,11 +1413,11 @@ static inline int tcp_nagle_check(const struct tcp_sock *tp,
 		 (!nonagle && tp->packets_out && tcp_minshall_check(tp)));
 }
 
-/* Return non-zero if the Nagle test allows this packet to be
+/* Return true if the Nagle test allows this packet to be
  * sent now.
  */
-static inline int tcp_nagle_test(const struct tcp_sock *tp, const struct sk_buff *skb,
-				 unsigned int cur_mss, int nonagle)
+static inline bool tcp_nagle_test(const struct tcp_sock *tp, const struct sk_buff *skb,
+				  unsigned int cur_mss, int nonagle)
 {
 	/* Nagle rule does not apply to frames, which sit in the middle of the
 	 * write_queue (they have no chances to get new data).
@@ -1426,24 +1426,25 @@ static inline int tcp_nagle_test(const struct tcp_sock *tp, const struct sk_buff
 	 * argument based upon the location of SKB in the send queue.
 	 */
 	if (nonagle & TCP_NAGLE_PUSH)
-		return 1;
+		return true;
 
 	/* Don't use the nagle rule for urgent data (or for the final FIN).
 	 * Nagle can be ignored during F-RTO too (see RFC4138).
 	 */
 	if (tcp_urg_mode(tp) || (tp->frto_counter == 2) ||
 	    (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN))
-		return 1;
+		return true;
 
 	if (!tcp_nagle_check(tp, skb, cur_mss, nonagle))
-		return 1;
+		return true;
 
-	return 0;
+	return false;
 }
 
 /* Does at least the first segment of SKB fit into the send window? */
-static inline int tcp_snd_wnd_test(const struct tcp_sock *tp, const struct sk_buff *skb,
-				   unsigned int cur_mss)
+static bool tcp_snd_wnd_test(const struct tcp_sock *tp,
+			     const struct sk_buff *skb,
+			     unsigned int cur_mss)
 {
 	u32 end_seq = TCP_SKB_CB(skb)->end_seq;
 
@@ -1476,7 +1477,7 @@ static unsigned int tcp_snd_test(const struct sock *sk, struct sk_buff *skb,
 }
 
 /* Test if sending is allowed right now. */
-int tcp_may_send_now(struct sock *sk)
+bool tcp_may_send_now(struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb = tcp_send_head(sk);
@@ -1546,7 +1547,7 @@ static int tso_fragment(struct sock *sk, struct sk_buff *skb, unsigned int len,
  *
  * This algorithm is from John Heffner.
  */
-static int tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb)
+static bool tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_connection_sock *icsk = inet_csk(sk);
@@ -1606,11 +1607,11 @@ static int tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb)
 	/* Ok, it looks like it is advisable to defer.  */
 	tp->tso_deferred = 1 | (jiffies << 1);
 
-	return 1;
+	return true;
 
 send_now:
 	tp->tso_deferred = 0;
-	return 0;
+	return false;
 }
 
 /* Create a new MTU probe if we are ready.
@@ -1752,11 +1753,11 @@ static int tcp_mtu_probe(struct sock *sk)
  * snd_up-64k-mss .. snd_up cannot be large. However, taking into
  * account rare use of URG, this is not a big flaw.
  *
- * Returns 1, if no segments are in flight and we have queued segments, but
- * cannot send anything now because of SWS or another problem.
+ * Returns true, if no segments are in flight and we have queued segments,
+ * but cannot send anything now because of SWS or another problem.
  */
-static int tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
-			  int push_one, gfp_t gfp)
+static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
+			   int push_one, gfp_t gfp)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
@@ -1770,7 +1771,7 @@ static int tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 		/* Do MTU probing. */
 		result = tcp_mtu_probe(sk);
 		if (!result) {
-			return 0;
+			return false;
 		} else if (result > 0) {
 			sent_pkts = 1;
 		}
@@ -1829,7 +1830,7 @@ static int tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 
 	if (likely(sent_pkts)) {
 		tcp_cwnd_validate(sk);
-		return 0;
+		return false;
 	}
 	return !tp->packets_out && tcp_send_head(sk);
 }
@@ -2028,22 +2029,22 @@ static void tcp_collapse_retrans(struct sock *sk, struct sk_buff *skb)
 }
 
 /* Check if coalescing SKBs is legal. */
-static int tcp_can_collapse(const struct sock *sk, const struct sk_buff *skb)
+static bool tcp_can_collapse(const struct sock *sk, const struct sk_buff *skb)
 {
 	if (tcp_skb_pcount(skb) > 1)
-		return 0;
+		return false;
 	/* TODO: SACK collapsing could be used to remove this condition */
 	if (skb_shinfo(skb)->nr_frags != 0)
-		return 0;
+		return false;
 	if (skb_cloned(skb))
-		return 0;
+		return false;
 	if (skb == tcp_send_head(sk))
-		return 0;
+		return false;
 	/* Some heurestics for collapsing over SACK'd could be invented */
 	if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)
-		return 0;
+		return false;
 
-	return 1;
+	return true;
 }
 
 /* Collapse packets in the retransmit queue to make to create
@@ -2054,7 +2055,7 @@ static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *to,
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb = to, *tmp;
-	int first = 1;
+	bool first = true;
 
 	if (!sysctl_tcp_retrans_collapse)
 		return;
@@ -2068,7 +2069,7 @@ static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *to,
 		space -= skb->len;
 
 		if (first) {
-			first = 0;
+			first = false;
 			continue;
 		}
 
@@ -2208,18 +2209,18 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 /* Check if we forward retransmits are possible in the current
  * window/congestion state.
  */
-static int tcp_can_forward_retransmit(struct sock *sk)
+static bool tcp_can_forward_retransmit(struct sock *sk)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	const struct tcp_sock *tp = tcp_sk(sk);
 
 	/* Forward retransmissions are possible only during Recovery. */
 	if (icsk->icsk_ca_state != TCP_CA_Recovery)
-		return 0;
+		return false;
 
 	/* No forward retransmissions in Reno are possible. */
 	if (tcp_is_reno(tp))
-		return 0;
+		return false;
 
 	/* Yeah, we have to make difficult choice between forward transmission
 	 * and retransmission... Both ways have their merits...
@@ -2230,9 +2231,9 @@ static int tcp_can_forward_retransmit(struct sock *sk)
 	 */
 
 	if (tcp_may_send_now(sk))
-		return 0;
+		return false;
 
-	return 1;
+	return true;
 }
 
 /* This gets called after a retransmit timeout, and the initially
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 4cf55ae..554d599 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1055,7 +1055,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	struct tcp_sock *tp = tcp_sk(sk);
 	__u32 isn = TCP_SKB_CB(skb)->when;
 	struct dst_entry *dst = NULL;
-	int want_cookie = 0;
+	bool want_cookie = false;
 
 	if (skb->protocol == htons(ETH_P_IP))
 		return tcp_v4_conn_request(sk, skb);
@@ -1116,7 +1116,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 		while (l-- > 0)
 			*c++ ^= *hash_location++;
 
-		want_cookie = 0;	/* not our kind of cookie */
+		want_cookie = false;	/* not our kind of cookie */
 		tmp_ext.cookie_out_never = 0; /* false */
 		tmp_ext.cookie_plus = tmp_opt.cookie_plus;
 	} else if (!tp->rx_opt.cookie_in_always) {
