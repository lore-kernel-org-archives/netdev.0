From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: remove in_flight parameter from cong_avoid()
 methods
Date: Fri, 02 May 2014 21:18:05 -0700
Message-ID: <1399090685.2140.12.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:47717 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702AbaECESJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 May 2014 00:18:09 -0400
Received: by mail-ig0-f177.google.com with SMTP id l13so242321iga.10
        for <netdev@vger.kernel.org>; Fri, 02 May 2014 21:18:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Commit e114a710aa505 ("tcp: fix cwnd limited checking to improve
congestion control") obsoleted in_flight parameter from
tcp_is_cwnd_limited() and its callers.

This patch does the removal as promised.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h        |    8 +++-----
 net/ipv4/tcp_bic.c       |    5 ++---
 net/ipv4/tcp_cong.c      |    4 ++--
 net/ipv4/tcp_cubic.c     |    5 ++---
 net/ipv4/tcp_highspeed.c |    4 ++--
 net/ipv4/tcp_htcp.c      |    4 ++--
 net/ipv4/tcp_hybla.c     |    7 +++----
 net/ipv4/tcp_illinois.c  |    5 ++---
 net/ipv4/tcp_input.c     |    9 ++++-----
 net/ipv4/tcp_lp.c        |    5 ++---
 net/ipv4/tcp_output.c    |    2 +-
 net/ipv4/tcp_scalable.c  |    5 ++---
 net/ipv4/tcp_vegas.c     |    7 +++----
 net/ipv4/tcp_veno.c      |    9 ++++-----
 net/ipv4/tcp_yeah.c      |    5 ++---
 15 files changed, 36 insertions(+), 48 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index a9fe7bc4f4bb..3c9418456640 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -796,7 +796,7 @@ struct tcp_congestion_ops {
 	/* return slow start threshold (required) */
 	u32 (*ssthresh)(struct sock *sk);
 	/* do new cwnd calculation (required) */
-	void (*cong_avoid)(struct sock *sk, u32 ack, u32 acked, u32 in_flight);
+	void (*cong_avoid)(struct sock *sk, u32 ack, u32 acked);
 	/* call before changing ca_state (optional) */
 	void (*set_state)(struct sock *sk, u8 new_state);
 	/* call when cwnd event occurs (optional) */
@@ -828,7 +828,7 @@ void tcp_cong_avoid_ai(struct tcp_sock *tp, u32 w);
 
 extern struct tcp_congestion_ops tcp_init_congestion_ops;
 u32 tcp_reno_ssthresh(struct sock *sk);
-void tcp_reno_cong_avoid(struct sock *sk, u32 ack, u32 acked, u32 in_flight);
+void tcp_reno_cong_avoid(struct sock *sk, u32 ack, u32 acked);
 extern struct tcp_congestion_ops tcp_reno;
 
 static inline void tcp_set_ca_state(struct sock *sk, const u8 ca_state)
@@ -986,10 +986,8 @@ static inline u32 tcp_wnd_end(const struct tcp_sock *tp)
  * risks 100% overshoot. The advantage is that we discourage application to
  * either send more filler packets or data to artificially blow up the cwnd
  * usage, and allow application-limited process to probe bw more aggressively.
- *
- * TODO: remove in_flight once we can fix all callers, and their callers...
  */
-static inline bool tcp_is_cwnd_limited(const struct sock *sk, u32 in_flight)
+static inline bool tcp_is_cwnd_limited(const struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 
diff --git a/net/ipv4/tcp_bic.c b/net/ipv4/tcp_bic.c
index 821846fb0a7e..d5de69bc04f5 100644
--- a/net/ipv4/tcp_bic.c
+++ b/net/ipv4/tcp_bic.c
@@ -140,13 +140,12 @@ static inline void bictcp_update(struct bictcp *ca, u32 cwnd)
 		ca->cnt = 1;
 }
 
-static void bictcp_cong_avoid(struct sock *sk, u32 ack, u32 acked,
-			      u32 in_flight)
+static void bictcp_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct bictcp *ca = inet_csk_ca(sk);
 
-	if (!tcp_is_cwnd_limited(sk, in_flight))
+	if (!tcp_is_cwnd_limited(sk))
 		return;
 
 	if (tp->snd_cwnd <= tp->snd_ssthresh)
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index a93b41ba05ff..7b09d8b49fa5 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -317,11 +317,11 @@ EXPORT_SYMBOL_GPL(tcp_cong_avoid_ai);
 /* This is Jacobson's slow start and congestion avoidance.
  * SIGCOMM '88, p. 328.
  */
-void tcp_reno_cong_avoid(struct sock *sk, u32 ack, u32 acked, u32 in_flight)
+void tcp_reno_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	if (!tcp_is_cwnd_limited(sk, in_flight))
+	if (!tcp_is_cwnd_limited(sk))
 		return;
 
 	/* In "safe" area, increase. */
diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
index 8bf224516ba2..ba2a4f3a6a1e 100644
--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -304,13 +304,12 @@ static inline void bictcp_update(struct bictcp *ca, u32 cwnd)
 		ca->cnt = 1;
 }
 
-static void bictcp_cong_avoid(struct sock *sk, u32 ack, u32 acked,
-			      u32 in_flight)
+static void bictcp_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct bictcp *ca = inet_csk_ca(sk);
 
-	if (!tcp_is_cwnd_limited(sk, in_flight))
+	if (!tcp_is_cwnd_limited(sk))
 		return;
 
 	if (tp->snd_cwnd <= tp->snd_ssthresh) {
diff --git a/net/ipv4/tcp_highspeed.c b/net/ipv4/tcp_highspeed.c
index 8b9e7bad77c0..1c4908280d92 100644
--- a/net/ipv4/tcp_highspeed.c
+++ b/net/ipv4/tcp_highspeed.c
@@ -109,12 +109,12 @@ static void hstcp_init(struct sock *sk)
 	tp->snd_cwnd_clamp = min_t(u32, tp->snd_cwnd_clamp, 0xffffffff/128);
 }
 
-static void hstcp_cong_avoid(struct sock *sk, u32 ack, u32 acked, u32 in_flight)
+static void hstcp_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct hstcp *ca = inet_csk_ca(sk);
 
-	if (!tcp_is_cwnd_limited(sk, in_flight))
+	if (!tcp_is_cwnd_limited(sk))
 		return;
 
 	if (tp->snd_cwnd <= tp->snd_ssthresh)
diff --git a/net/ipv4/tcp_htcp.c b/net/ipv4/tcp_htcp.c
index 4a194acfd923..031361311a8b 100644
--- a/net/ipv4/tcp_htcp.c
+++ b/net/ipv4/tcp_htcp.c
@@ -227,12 +227,12 @@ static u32 htcp_recalc_ssthresh(struct sock *sk)
 	return max((tp->snd_cwnd * ca->beta) >> 7, 2U);
 }
 
-static void htcp_cong_avoid(struct sock *sk, u32 ack, u32 acked, u32 in_flight)
+static void htcp_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct htcp *ca = inet_csk_ca(sk);
 
-	if (!tcp_is_cwnd_limited(sk, in_flight))
+	if (!tcp_is_cwnd_limited(sk))
 		return;
 
 	if (tp->snd_cwnd <= tp->snd_ssthresh)
diff --git a/net/ipv4/tcp_hybla.c b/net/ipv4/tcp_hybla.c
index a15a799bf768..d8f8f05a4951 100644
--- a/net/ipv4/tcp_hybla.c
+++ b/net/ipv4/tcp_hybla.c
@@ -87,8 +87,7 @@ static inline u32 hybla_fraction(u32 odds)
  *     o Give cwnd a new value based on the model proposed
  *     o remember increments <1
  */
-static void hybla_cong_avoid(struct sock *sk, u32 ack, u32 acked,
-			     u32 in_flight)
+static void hybla_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct hybla *ca = inet_csk_ca(sk);
@@ -101,11 +100,11 @@ static void hybla_cong_avoid(struct sock *sk, u32 ack, u32 acked,
 		ca->minrtt_us = tp->srtt_us;
 	}
 
-	if (!tcp_is_cwnd_limited(sk, in_flight))
+	if (!tcp_is_cwnd_limited(sk))
 		return;
 
 	if (!ca->hybla_en) {
-		tcp_reno_cong_avoid(sk, ack, acked, in_flight);
+		tcp_reno_cong_avoid(sk, ack, acked);
 		return;
 	}
 
diff --git a/net/ipv4/tcp_illinois.c b/net/ipv4/tcp_illinois.c
index 863d105e3015..5999b3972e64 100644
--- a/net/ipv4/tcp_illinois.c
+++ b/net/ipv4/tcp_illinois.c
@@ -255,8 +255,7 @@ static void tcp_illinois_state(struct sock *sk, u8 new_state)
 /*
  * Increase window in response to successful acknowledgment.
  */
-static void tcp_illinois_cong_avoid(struct sock *sk, u32 ack, u32 acked,
-				    u32 in_flight)
+static void tcp_illinois_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct illinois *ca = inet_csk_ca(sk);
@@ -265,7 +264,7 @@ static void tcp_illinois_cong_avoid(struct sock *sk, u32 ack, u32 acked,
 		update_params(sk);
 
 	/* RFC2861 only increase cwnd if fully utilized */
-	if (!tcp_is_cwnd_limited(sk, in_flight))
+	if (!tcp_is_cwnd_limited(sk))
 		return;
 
 	/* In slow start */
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 6efed134ab63..350b2072f0ab 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2938,10 +2938,11 @@ static void tcp_synack_rtt_meas(struct sock *sk, const u32 synack_stamp)
 		tcp_ack_update_rtt(sk, FLAG_SYN_ACKED, seq_rtt_us, -1L);
 }
 
-static void tcp_cong_avoid(struct sock *sk, u32 ack, u32 acked, u32 in_flight)
+static void tcp_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
-	icsk->icsk_ca_ops->cong_avoid(sk, ack, acked, in_flight);
+
+	icsk->icsk_ca_ops->cong_avoid(sk, ack, acked);
 	tcp_sk(sk)->snd_cwnd_stamp = tcp_time_stamp;
 }
 
@@ -3364,7 +3365,6 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	u32 ack_seq = TCP_SKB_CB(skb)->seq;
 	u32 ack = TCP_SKB_CB(skb)->ack_seq;
 	bool is_dupack = false;
-	u32 prior_in_flight;
 	u32 prior_fackets;
 	int prior_packets = tp->packets_out;
 	const int prior_unsacked = tp->packets_out - tp->sacked_out;
@@ -3397,7 +3397,6 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 		flag |= FLAG_SND_UNA_ADVANCED;
 
 	prior_fackets = tp->fackets_out;
-	prior_in_flight = tcp_packets_in_flight(tp);
 
 	/* ts_recent update must be made after we are sure that the packet
 	 * is in window.
@@ -3452,7 +3451,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 
 	/* Advance cwnd if state allows */
 	if (tcp_may_raise_cwnd(sk, flag))
-		tcp_cong_avoid(sk, ack, acked, prior_in_flight);
+		tcp_cong_avoid(sk, ack, acked);
 
 	if (tcp_ack_is_dubious(sk, flag)) {
 		is_dupack = !(flag & (FLAG_SND_UNA_ADVANCED | FLAG_NOT_DUP));
diff --git a/net/ipv4/tcp_lp.c b/net/ipv4/tcp_lp.c
index c9aecae31327..1e70fa8fa793 100644
--- a/net/ipv4/tcp_lp.c
+++ b/net/ipv4/tcp_lp.c
@@ -115,13 +115,12 @@ static void tcp_lp_init(struct sock *sk)
  * Will only call newReno CA when away from inference.
  * From TCP-LP's paper, this will be handled in additive increasement.
  */
-static void tcp_lp_cong_avoid(struct sock *sk, u32 ack, u32 acked,
-			      u32 in_flight)
+static void tcp_lp_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 {
 	struct lp *lp = inet_csk_ca(sk);
 
 	if (!(lp->flag & LP_WITHIN_INF))
-		tcp_reno_cong_avoid(sk, ack, acked, in_flight);
+		tcp_reno_cong_avoid(sk, ack, acked);
 }
 
 /**
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index f9181a133462..89277a34f2c9 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1408,7 +1408,7 @@ static void tcp_cwnd_validate(struct sock *sk, u32 unsent_segs)
 
 	tp->lsnd_pending = tp->packets_out + unsent_segs;
 
-	if (tcp_is_cwnd_limited(sk, 0)) {
+	if (tcp_is_cwnd_limited(sk)) {
 		/* Network is feed fully. */
 		tp->snd_cwnd_used = 0;
 		tp->snd_cwnd_stamp = tcp_time_stamp;
diff --git a/net/ipv4/tcp_scalable.c b/net/ipv4/tcp_scalable.c
index 0ac50836da4d..8250949b8853 100644
--- a/net/ipv4/tcp_scalable.c
+++ b/net/ipv4/tcp_scalable.c
@@ -15,12 +15,11 @@
 #define TCP_SCALABLE_AI_CNT	50U
 #define TCP_SCALABLE_MD_SCALE	3
 
-static void tcp_scalable_cong_avoid(struct sock *sk, u32 ack, u32 acked,
-				    u32 in_flight)
+static void tcp_scalable_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	if (!tcp_is_cwnd_limited(sk, in_flight))
+	if (!tcp_is_cwnd_limited(sk))
 		return;
 
 	if (tp->snd_cwnd <= tp->snd_ssthresh)
diff --git a/net/ipv4/tcp_vegas.c b/net/ipv4/tcp_vegas.c
index 48539fff6357..9a5e05f27f4f 100644
--- a/net/ipv4/tcp_vegas.c
+++ b/net/ipv4/tcp_vegas.c
@@ -163,14 +163,13 @@ static inline u32 tcp_vegas_ssthresh(struct tcp_sock *tp)
 	return  min(tp->snd_ssthresh, tp->snd_cwnd-1);
 }
 
-static void tcp_vegas_cong_avoid(struct sock *sk, u32 ack, u32 acked,
-				 u32 in_flight)
+static void tcp_vegas_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct vegas *vegas = inet_csk_ca(sk);
 
 	if (!vegas->doing_vegas_now) {
-		tcp_reno_cong_avoid(sk, ack, acked, in_flight);
+		tcp_reno_cong_avoid(sk, ack, acked);
 		return;
 	}
 
@@ -195,7 +194,7 @@ static void tcp_vegas_cong_avoid(struct sock *sk, u32 ack, u32 acked,
 			/* We don't have enough RTT samples to do the Vegas
 			 * calculation, so we'll behave like Reno.
 			 */
-			tcp_reno_cong_avoid(sk, ack, acked, in_flight);
+			tcp_reno_cong_avoid(sk, ack, acked);
 		} else {
 			u32 rtt, diff;
 			u64 target_cwnd;
diff --git a/net/ipv4/tcp_veno.c b/net/ipv4/tcp_veno.c
index 1b8e28fcd7e1..27b9825753d1 100644
--- a/net/ipv4/tcp_veno.c
+++ b/net/ipv4/tcp_veno.c
@@ -114,19 +114,18 @@ static void tcp_veno_cwnd_event(struct sock *sk, enum tcp_ca_event event)
 		tcp_veno_init(sk);
 }
 
-static void tcp_veno_cong_avoid(struct sock *sk, u32 ack, u32 acked,
-				u32 in_flight)
+static void tcp_veno_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct veno *veno = inet_csk_ca(sk);
 
 	if (!veno->doing_veno_now) {
-		tcp_reno_cong_avoid(sk, ack, acked, in_flight);
+		tcp_reno_cong_avoid(sk, ack, acked);
 		return;
 	}
 
 	/* limited by applications */
-	if (!tcp_is_cwnd_limited(sk, in_flight))
+	if (!tcp_is_cwnd_limited(sk))
 		return;
 
 	/* We do the Veno calculations only if we got enough rtt samples */
@@ -134,7 +133,7 @@ static void tcp_veno_cong_avoid(struct sock *sk, u32 ack, u32 acked,
 		/* We don't have enough rtt samples to do the Veno
 		 * calculation, so we'll behave like Reno.
 		 */
-		tcp_reno_cong_avoid(sk, ack, acked, in_flight);
+		tcp_reno_cong_avoid(sk, ack, acked);
 	} else {
 		u64 target_cwnd;
 		u32 rtt;
diff --git a/net/ipv4/tcp_yeah.c b/net/ipv4/tcp_yeah.c
index 5ede0e727945..599b79b8eac0 100644
--- a/net/ipv4/tcp_yeah.c
+++ b/net/ipv4/tcp_yeah.c
@@ -69,13 +69,12 @@ static void tcp_yeah_pkts_acked(struct sock *sk, u32 pkts_acked, s32 rtt_us)
 	tcp_vegas_pkts_acked(sk, pkts_acked, rtt_us);
 }
 
-static void tcp_yeah_cong_avoid(struct sock *sk, u32 ack, u32 acked,
-				u32 in_flight)
+static void tcp_yeah_cong_avoid(struct sock *sk, u32 ack, u32 acked)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct yeah *yeah = inet_csk_ca(sk);
 
-	if (!tcp_is_cwnd_limited(sk, in_flight))
+	if (!tcp_is_cwnd_limited(sk))
 		return;
 
 	if (tp->snd_cwnd <= tp->snd_ssthresh)
