From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] TCP: remove unused argument to cong_avoid op
Date: Mon, 16 Jul 2007 16:19:51 +0100
Message-ID: <20070716161951.65453706@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:45336 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756577AbXGPPVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 11:21:01 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

None of the existing TCP congestion controls use the rtt value pased
in the ca_ops->cong_avoid interface.  Which is lucky because seq_rtt
could have been -1 when handling a duplicate ack.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/include/net/tcp.h	2007-07-16 14:25:36.000000000 +0100
+++ b/include/net/tcp.h	2007-07-16 15:33:42.000000000 +0100
@@ -652,8 +652,7 @@ struct tcp_congestion_ops {
 	/* lower bound for congestion window (optional) */
 	u32 (*min_cwnd)(const struct sock *sk);
 	/* do new cwnd calculation (required) */
-	void (*cong_avoid)(struct sock *sk, u32 ack,
-			   u32 rtt, u32 in_flight, int good_ack);
+	void (*cong_avoid)(struct sock *sk, u32 ack, u32 in_flight, int good_ack);
 	/* call before changing ca_state (optional) */
 	void (*set_state)(struct sock *sk, u8 new_state);
 	/* call when cwnd event occurs (optional) */
@@ -684,8 +683,7 @@ extern void tcp_slow_start(struct tcp_so
 
 extern struct tcp_congestion_ops tcp_init_congestion_ops;
 extern u32 tcp_reno_ssthresh(struct sock *sk);
-extern void tcp_reno_cong_avoid(struct sock *sk, u32 ack,
-				u32 rtt, u32 in_flight, int flag);
+extern void tcp_reno_cong_avoid(struct sock *sk, u32 ack, u32 in_flight, int flag);
 extern u32 tcp_reno_min_cwnd(const struct sock *sk);
 extern struct tcp_congestion_ops tcp_reno;
 
--- a/net/ipv4/tcp_bic.c	2007-07-16 14:25:41.000000000 +0100
+++ b/net/ipv4/tcp_bic.c	2007-07-16 15:35:47.000000000 +0100
@@ -137,7 +137,7 @@ static inline void bictcp_update(struct 
 }
 
 static void bictcp_cong_avoid(struct sock *sk, u32 ack,
-			      u32 seq_rtt, u32 in_flight, int data_acked)
+			      u32 in_flight, int data_acked)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct bictcp *ca = inet_csk_ca(sk);
--- a/net/ipv4/tcp_cong.c	2007-07-16 14:25:41.000000000 +0100
+++ b/net/ipv4/tcp_cong.c	2007-07-16 15:35:17.000000000 +0100
@@ -324,8 +324,7 @@ EXPORT_SYMBOL_GPL(tcp_slow_start);
 /* This is Jacobson's slow start and congestion avoidance.
  * SIGCOMM '88, p. 328.
  */
-void tcp_reno_cong_avoid(struct sock *sk, u32 ack, u32 rtt, u32 in_flight,
-			 int flag)
+void tcp_reno_cong_avoid(struct sock *sk, u32 ack, u32 in_flight, int flag)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
--- a/net/ipv4/tcp_cubic.c	2007-07-16 15:18:34.000000000 +0100
+++ b/net/ipv4/tcp_cubic.c	2007-07-16 15:35:37.000000000 +0100
@@ -270,7 +270,7 @@ static inline void measure_delay(struct 
 }
 
 static void bictcp_cong_avoid(struct sock *sk, u32 ack,
-			      u32 seq_rtt, u32 in_flight, int data_acked)
+			      u32 in_flight, int data_acked)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct bictcp *ca = inet_csk_ca(sk);
--- a/net/ipv4/tcp_highspeed.c	2007-07-16 14:25:41.000000000 +0100
+++ b/net/ipv4/tcp_highspeed.c	2007-07-16 15:36:08.000000000 +0100
@@ -109,7 +109,7 @@ static void hstcp_init(struct sock *sk)
 	tp->snd_cwnd_clamp = min_t(u32, tp->snd_cwnd_clamp, 0xffffffff/128);
 }
 
-static void hstcp_cong_avoid(struct sock *sk, u32 adk, u32 rtt,
+static void hstcp_cong_avoid(struct sock *sk, u32 adk,
 			     u32 in_flight, int data_acked)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
--- a/net/ipv4/tcp_htcp.c	2007-07-16 14:25:41.000000000 +0100
+++ b/net/ipv4/tcp_htcp.c	2007-07-16 15:22:28.000000000 +0100
@@ -225,7 +225,7 @@ static u32 htcp_recalc_ssthresh(struct s
 	return max((tp->snd_cwnd * ca->beta) >> 7, 2U);
 }
 
-static void htcp_cong_avoid(struct sock *sk, u32 ack, u32 rtt,
+static void htcp_cong_avoid(struct sock *sk, u32 ack, s32 rtt,
 			    u32 in_flight, int data_acked)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
--- a/net/ipv4/tcp_hybla.c	2007-07-16 14:25:41.000000000 +0100
+++ b/net/ipv4/tcp_hybla.c	2007-07-16 15:38:15.000000000 +0100
@@ -85,7 +85,7 @@ static inline u32 hybla_fraction(u32 odd
  *     o Give cwnd a new value based on the model proposed
  *     o remember increments <1
  */
-static void hybla_cong_avoid(struct sock *sk, u32 ack, u32 rtt,
+static void hybla_cong_avoid(struct sock *sk, u32 ack,
 			    u32 in_flight, int flag)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -103,7 +103,7 @@ static void hybla_cong_avoid(struct sock
 		return;
 
 	if (!ca->hybla_en)
-		return tcp_reno_cong_avoid(sk, ack, rtt, in_flight, flag);
+		return tcp_reno_cong_avoid(sk, ack, in_flight, flag);
 
 	if (ca->rho == 0)
 		hybla_recalc_param(sk);
--- a/net/ipv4/tcp_illinois.c	2007-07-16 14:25:41.000000000 +0100
+++ b/net/ipv4/tcp_illinois.c	2007-07-16 15:35:59.000000000 +0100
@@ -258,7 +258,7 @@ static void tcp_illinois_state(struct so
 /*
  * Increase window in response to successful acknowledgment.
  */
-static void tcp_illinois_cong_avoid(struct sock *sk, u32 ack, u32 rtt,
+static void tcp_illinois_cong_avoid(struct sock *sk, u32 ack,
 				    u32 in_flight, int flag)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
--- a/net/ipv4/tcp_input.c	2007-07-16 14:25:41.000000000 +0100
+++ b/net/ipv4/tcp_input.c	2007-07-16 15:33:08.000000000 +0100
@@ -2321,11 +2321,11 @@ static inline void tcp_ack_update_rtt(st
 		tcp_ack_no_tstamp(sk, seq_rtt, flag);
 }
 
-static void tcp_cong_avoid(struct sock *sk, u32 ack, u32 rtt,
+static void tcp_cong_avoid(struct sock *sk, u32 ack,
 			   u32 in_flight, int good)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
-	icsk->icsk_ca_ops->cong_avoid(sk, ack, rtt, in_flight, good);
+	icsk->icsk_ca_ops->cong_avoid(sk, ack, in_flight, good);
 	tcp_sk(sk)->snd_cwnd_stamp = tcp_time_stamp;
 }
 
@@ -2824,11 +2824,11 @@ static int tcp_ack(struct sock *sk, stru
 		/* Advance CWND, if state allows this. */
 		if ((flag & FLAG_DATA_ACKED) && !frto_cwnd &&
 		    tcp_may_raise_cwnd(sk, flag))
-			tcp_cong_avoid(sk, ack,  seq_rtt, prior_in_flight, 0);
+			tcp_cong_avoid(sk, ack, prior_in_flight, 0);
 		tcp_fastretrans_alert(sk, prior_snd_una, prior_packets, flag);
 	} else {
 		if ((flag & FLAG_DATA_ACKED) && !frto_cwnd)
-			tcp_cong_avoid(sk, ack, seq_rtt, prior_in_flight, 1);
+			tcp_cong_avoid(sk, ack, prior_in_flight, 1);
 	}
 
 	if ((flag & FLAG_FORWARD_PROGRESS) || !(flag&FLAG_NOT_DUP))
--- a/net/ipv4/tcp_lp.c	2007-07-16 14:25:41.000000000 +0100
+++ b/net/ipv4/tcp_lp.c	2007-07-16 15:37:39.000000000 +0100
@@ -115,13 +115,12 @@ static void tcp_lp_init(struct sock *sk)
  * Will only call newReno CA when away from inference.
  * From TCP-LP's paper, this will be handled in additive increasement.
  */
-static void tcp_lp_cong_avoid(struct sock *sk, u32 ack, u32 rtt, u32 in_flight,
-			      int flag)
+static void tcp_lp_cong_avoid(struct sock *sk, u32 ack, u32 in_flight, int flag)
 {
 	struct lp *lp = inet_csk_ca(sk);
 
 	if (!(lp->flag & LP_WITHIN_INF))
-		tcp_reno_cong_avoid(sk, ack, rtt, in_flight, flag);
+		tcp_reno_cong_avoid(sk, ack, in_flight, flag);
 }
 
 /**
--- a/net/ipv4/tcp_scalable.c	2007-07-16 14:25:41.000000000 +0100
+++ b/net/ipv4/tcp_scalable.c	2007-07-16 15:37:23.000000000 +0100
@@ -15,7 +15,7 @@
 #define TCP_SCALABLE_AI_CNT	50U
 #define TCP_SCALABLE_MD_SCALE	3
 
-static void tcp_scalable_cong_avoid(struct sock *sk, u32 ack, u32 rtt,
+static void tcp_scalable_cong_avoid(struct sock *sk, u32 ack,
 				    u32 in_flight, int flag)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
--- a/net/ipv4/tcp_vegas.c	2007-07-16 14:25:41.000000000 +0100
+++ b/net/ipv4/tcp_vegas.c	2007-07-16 15:36:44.000000000 +0100
@@ -163,13 +163,13 @@ void tcp_vegas_cwnd_event(struct sock *s
 EXPORT_SYMBOL_GPL(tcp_vegas_cwnd_event);
 
 static void tcp_vegas_cong_avoid(struct sock *sk, u32 ack,
-				 u32 seq_rtt, u32 in_flight, int flag)
+				 u32 in_flight, int flag)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct vegas *vegas = inet_csk_ca(sk);
 
 	if (!vegas->doing_vegas_now)
-		return tcp_reno_cong_avoid(sk, ack, seq_rtt, in_flight, flag);
+		return tcp_reno_cong_avoid(sk, ack, in_flight, flag);
 
 	/* The key players are v_beg_snd_una and v_beg_snd_nxt.
 	 *
@@ -228,7 +228,7 @@ static void tcp_vegas_cong_avoid(struct 
 			/* We don't have enough RTT samples to do the Vegas
 			 * calculation, so we'll behave like Reno.
 			 */
-			tcp_reno_cong_avoid(sk, ack, seq_rtt, in_flight, flag);
+			tcp_reno_cong_avoid(sk, ack, in_flight, flag);
 		} else {
 			u32 rtt, target_cwnd, diff;
 
--- a/net/ipv4/tcp_veno.c	2007-07-16 14:25:41.000000000 +0100
+++ b/net/ipv4/tcp_veno.c	2007-07-16 15:37:06.000000000 +0100
@@ -115,13 +115,13 @@ static void tcp_veno_cwnd_event(struct s
 }
 
 static void tcp_veno_cong_avoid(struct sock *sk, u32 ack,
-				u32 seq_rtt, u32 in_flight, int flag)
+				u32 in_flight, int flag)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct veno *veno = inet_csk_ca(sk);
 
 	if (!veno->doing_veno_now)
-		return tcp_reno_cong_avoid(sk, ack, seq_rtt, in_flight, flag);
+		return tcp_reno_cong_avoid(sk, ack, in_flight, flag);
 
 	/* limited by applications */
 	if (!tcp_is_cwnd_limited(sk, in_flight))
@@ -132,7 +132,7 @@ static void tcp_veno_cong_avoid(struct s
 		/* We don't have enough rtt samples to do the Veno
 		 * calculation, so we'll behave like Reno.
 		 */
-		tcp_reno_cong_avoid(sk, ack, seq_rtt, in_flight, flag);
+		tcp_reno_cong_avoid(sk, ack, in_flight, flag);
 	} else {
 		u32 rtt, target_cwnd;
 
--- a/net/ipv4/tcp_yeah.c	2007-07-16 14:25:41.000000000 +0100
+++ b/net/ipv4/tcp_yeah.c	2007-07-16 15:37:52.000000000 +0100
@@ -70,7 +70,7 @@ static void tcp_yeah_pkts_acked(struct s
 }
 
 static void tcp_yeah_cong_avoid(struct sock *sk, u32 ack,
-				u32 seq_rtt, u32 in_flight, int flag)
+				u32 in_flight, int flag)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct yeah *yeah = inet_csk_ca(sk);
