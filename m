From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFC 1/3] TCP: congestion control API pass RTT in microseconds
Date: Thu, 19 Jul 2007 08:41:30 +0100
Message-ID: <20070719074906.458899848@linux-foundation.org>
References: <20070719074129.670215301@linux-foundation.org>
Cc: Sangtae Ha <sha2@ncsu.edu>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42162 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763838AbXGSIYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 04:24:38 -0400
Cc: Luca De Cicco <ldecicco@gmail.com>
Cc: Gavin McCullagh <gavin.mccullagh@nuim.ie>
Cc: netdev@vger.kernel.org
Content-Disposition: inline; filename=tcp-cong-rtt.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch changes the API for the callback that is done after an ACK is
received. It solves a couple of issues:

  * Some congestion controls want higher resolution value of RTT
    (controlled by TCP_CONG_RTT_SAMPLE flag). These don't really want a ktime, but
    all compute a RTT in microseconds.

  * Other congestion control could use RTT at jiffies resolution.

To keep API consistent the units should be the same for both cases, just the
resolution should change.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/include/net/tcp.h	2007-07-19 08:12:13.000000000 +0100
+++ b/include/net/tcp.h	2007-07-19 08:12:23.000000000 +0100
@@ -661,7 +661,7 @@ struct tcp_congestion_ops {
 	/* new value of cwnd after loss (optional) */
 	u32  (*undo_cwnd)(struct sock *sk);
 	/* hook for packet ack accounting (optional) */
-	void (*pkts_acked)(struct sock *sk, u32 num_acked, ktime_t last);
+	void (*pkts_acked)(struct sock *sk, u32 num_acked, s32 rtt_us);
 	/* get info for inet_diag (optional) */
 	void (*get_info)(struct sock *sk, u32 ext, struct sk_buff *skb);
 
--- a/net/ipv4/tcp_input.c	2007-07-19 08:12:13.000000000 +0100
+++ b/net/ipv4/tcp_input.c	2007-07-19 08:12:23.000000000 +0100
@@ -2490,12 +2490,23 @@ static int tcp_clean_rtx_queue(struct so
 		tcp_ack_update_rtt(sk, acked, seq_rtt);
 		tcp_ack_packets_out(sk);
 
-		/* Is the ACK triggering packet unambiguous? */
-		if (acked & FLAG_RETRANS_DATA_ACKED)
-			last_ackt = net_invalid_timestamp();
+		if (ca_ops->pkts_acked) {
+			s32 rtt_us = -1;
 
-		if (ca_ops->pkts_acked)
-			ca_ops->pkts_acked(sk, pkts_acked, last_ackt);
+			/* Is the ACK triggering packet unambiguous? */
+			if (!(acked & FLAG_RETRANS_DATA_ACKED)) {
+				/* High resolution needed and available? */
+				if (ca_ops->flags & TCP_CONG_RTT_STAMP &&
+				    !ktime_equal(last_ackt,
+						 net_invalid_timestamp()))
+					rtt_us = ktime_us_delta(ktime_get_real(),
+								last_ackt);
+				else if (seq_rtt > 0)
+					rtt_us = jiffies_to_usecs(seq_rtt);
+			}
+
+			ca_ops->pkts_acked(sk, pkts_acked, rtt_us);
+		}
 	}
 
 #if FASTRETRANS_DEBUG > 0
--- a/net/ipv4/tcp_bic.c	2007-07-17 10:01:51.000000000 +0100
+++ b/net/ipv4/tcp_bic.c	2007-07-19 08:16:35.000000000 +0100
@@ -206,7 +206,7 @@ static void bictcp_state(struct sock *sk
 /* Track delayed acknowledgment ratio using sliding window
  * ratio = (15*ratio + sample) / 16
  */
-static void bictcp_acked(struct sock *sk, u32 cnt, ktime_t last)
+static void bictcp_acked(struct sock *sk, u32 cnt, s32 rtt)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 
--- a/net/ipv4/tcp_cubic.c	2007-07-18 22:28:38.000000000 +0100
+++ b/net/ipv4/tcp_cubic.c	2007-07-19 08:21:42.000000000 +0100
@@ -334,7 +334,7 @@ static void bictcp_state(struct sock *sk
 /* Track delayed acknowledgment ratio using sliding window
  * ratio = (15*ratio + sample) / 16
  */
-static void bictcp_acked(struct sock *sk, u32 cnt, ktime_t last)
+static void bictcp_acked(struct sock *sk, u32 cnt, s32 rtt_us)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 
--- a/net/ipv4/tcp_htcp.c	2007-07-18 22:28:38.000000000 +0100
+++ b/net/ipv4/tcp_htcp.c	2007-07-19 08:18:38.000000000 +0100
@@ -98,7 +98,7 @@ static inline void measure_rtt(struct so
 	}
 }
 
-static void measure_achieved_throughput(struct sock *sk, u32 pkts_acked, ktime_t last)
+static void measure_achieved_throughput(struct sock *sk, u32 pkts_acked, s32 rtt)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	const struct tcp_sock *tp = tcp_sk(sk);
--- a/net/ipv4/tcp_illinois.c	2007-07-19 07:08:45.000000000 +0100
+++ b/net/ipv4/tcp_illinois.c	2007-07-19 08:16:13.000000000 +0100
@@ -83,18 +83,16 @@ static void tcp_illinois_init(struct soc
 }
 
 /* Measure RTT for each ack. */
-static void tcp_illinois_acked(struct sock *sk, u32 pkts_acked, ktime_t last)
+static void tcp_illinois_acked(struct sock *sk, u32 pkts_acked, s32 rtt)
 {
 	struct illinois *ca = inet_csk_ca(sk);
-	u32 rtt;
 
 	ca->acked = pkts_acked;
 
-	if (ktime_equal(last, net_invalid_timestamp()))
+	/* dup ack, no rtt sample */
+	if (rtt < 0)
 		return;
 
-	rtt = ktime_to_us(net_timedelta(last));
-
 	/* ignore bogus values, this prevents wraparound in alpha math */
 	if (rtt > RTT_MAX)
 		rtt = RTT_MAX;
--- a/net/ipv4/tcp_lp.c	2007-07-19 07:08:45.000000000 +0100
+++ b/net/ipv4/tcp_lp.c	2007-07-19 08:20:12.000000000 +0100
@@ -261,13 +261,13 @@ static void tcp_lp_rtt_sample(struct soc
  * newReno in increase case.
  * We work it out by following the idea from TCP-LP's paper directly
  */
-static void tcp_lp_pkts_acked(struct sock *sk, u32 num_acked, ktime_t last)
+static void tcp_lp_pkts_acked(struct sock *sk, u32 num_acked, s32 rtt_us)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct lp *lp = inet_csk_ca(sk);
 
-	if (!ktime_equal(last, net_invalid_timestamp()))
-		tcp_lp_rtt_sample(sk,  ktime_to_us(net_timedelta(last)));
+	if (rtt_us > 0)
+		tcp_lp_rtt_sample(sk, rtt_us);
 
 	/* calc inference */
 	if (tcp_time_stamp > tp->rx_opt.rcv_tsecr)
--- a/net/ipv4/tcp_vegas.c	2007-07-19 07:08:45.000000000 +0100
+++ b/net/ipv4/tcp_vegas.c	2007-07-19 08:14:49.000000000 +0100
@@ -112,16 +112,16 @@ EXPORT_SYMBOL_GPL(tcp_vegas_init);
  *   o min-filter RTT samples from a much longer window (forever for now)
  *     to find the propagation delay (baseRTT)
  */
-void tcp_vegas_pkts_acked(struct sock *sk, u32 cnt, ktime_t last)
+void tcp_vegas_pkts_acked(struct sock *sk, u32 cnt, s32 rtt_us)
 {
 	struct vegas *vegas = inet_csk_ca(sk);
 	u32 vrtt;
 
-	if (ktime_equal(last, net_invalid_timestamp()))
+	if (rtt_us < 0)
 		return;
 
 	/* Never allow zero rtt or baseRTT */
-	vrtt = ktime_to_us(net_timedelta(last)) + 1;
+	vrtt = rtt_us + 1;
 
 	/* Filter to find propagation delay: */
 	if (vrtt < vegas->baseRTT)
--- a/net/ipv4/tcp_vegas.h	2007-07-16 14:25:41.000000000 +0100
+++ b/net/ipv4/tcp_vegas.h	2007-07-19 08:22:33.000000000 +0100
@@ -17,7 +17,7 @@ struct vegas {
 
 extern void tcp_vegas_init(struct sock *sk);
 extern void tcp_vegas_state(struct sock *sk, u8 ca_state);
-extern void tcp_vegas_pkts_acked(struct sock *sk, u32 cnt, ktime_t last);
+extern void tcp_vegas_pkts_acked(struct sock *sk, u32 cnt, s32 rtt_us);
 extern void tcp_vegas_cwnd_event(struct sock *sk, enum tcp_ca_event event);
 extern void tcp_vegas_get_info(struct sock *sk, u32 ext, struct sk_buff *skb);
 
--- a/net/ipv4/tcp_veno.c	2007-07-19 07:08:45.000000000 +0100
+++ b/net/ipv4/tcp_veno.c	2007-07-19 08:19:37.000000000 +0100
@@ -69,16 +69,16 @@ static void tcp_veno_init(struct sock *s
 }
 
 /* Do rtt sampling needed for Veno. */
-static void tcp_veno_pkts_acked(struct sock *sk, u32 cnt, ktime_t last)
+static void tcp_veno_pkts_acked(struct sock *sk, u32 cnt, s32 rtt_us)
 {
 	struct veno *veno = inet_csk_ca(sk);
 	u32 vrtt;
 
-	if (ktime_equal(last, net_invalid_timestamp()))
+	if (rtt_us < 0)
 		return;
 
 	/* Never allow zero rtt or baseRTT */
-	vrtt = ktime_to_us(net_timedelta(last)) + 1;
+	vrtt = rtt_us + 1;
 
 	/* Filter to find propagation delay: */
 	if (vrtt < veno->basertt)
--- a/net/ipv4/tcp_westwood.c	2007-07-18 22:28:38.000000000 +0100
+++ b/net/ipv4/tcp_westwood.c	2007-07-19 08:17:43.000000000 +0100
@@ -100,11 +100,12 @@ static void westwood_filter(struct westw
  * Called after processing group of packets.
  * but all westwood needs is the last sample of srtt.
  */
-static void tcp_westwood_pkts_acked(struct sock *sk, u32 cnt, ktime_t last)
+static void tcp_westwood_pkts_acked(struct sock *sk, u32 cnt, s32 rtt)
 {
 	struct westwood *w = inet_csk_ca(sk);
-	if (cnt > 0)
-		w->rtt = tcp_sk(sk)->srtt >> 3;
+
+	if (rtt > 0)
+		w->rtt = usecs_to_jiffies(rtt);
 }
 
 /*
--- a/net/ipv4/tcp_yeah.c	2007-07-19 07:08:45.000000000 +0100
+++ b/net/ipv4/tcp_yeah.c	2007-07-19 08:23:08.000000000 +0100
@@ -58,7 +58,7 @@ static void tcp_yeah_init(struct sock *s
 }
 
 
-static void tcp_yeah_pkts_acked(struct sock *sk, u32 pkts_acked, ktime_t last)
+static void tcp_yeah_pkts_acked(struct sock *sk, u32 pkts_acked, s32 rtt_us)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	struct yeah *yeah = inet_csk_ca(sk);
@@ -66,7 +66,7 @@ static void tcp_yeah_pkts_acked(struct s
 	if (icsk->icsk_ca_state == TCP_CA_Open)
 		yeah->pkts_acked = pkts_acked;
 
-	tcp_vegas_pkts_acked(sk, pkts_acked, last);
+	tcp_vegas_pkts_acked(sk, pkts_acked, rtt_us);
 }
 
 static void tcp_yeah_cong_avoid(struct sock *sk, u32 ack,

-- 

