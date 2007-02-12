From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 1/3] tcp: cleanup of htcp (resend)
Date: Mon, 12 Feb 2007 13:28:22 -0800
Message-ID: <20070212132822.673aecdc@freekitty>
References: <20070212160317.545906075@linux-foundation.org>
	<20070212160336.337425153@linux-foundation.org>
	<20070212.131439.48527906.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:42348 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965378AbXBLV21 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Feb 2007 16:28:27 -0500
In-Reply-To: <20070212.131439.48527906.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Minor non-invasive cleanups:
 * white space around operators and line wrapping
 * use const
 * use __read_mostly

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 net/ipv4/tcp_htcp.c |   65 +++++++++++++++++++++++++++++-----------------------
 1 file changed, 37 insertions(+), 28 deletions(-)

--- tcp.orig/net/ipv4/tcp_htcp.c	2007-02-12 12:32:55.000000000 -0800
+++ tcp/net/ipv4/tcp_htcp.c	2007-02-12 12:46:48.000000000 -0800
@@ -10,22 +10,23 @@
 #include <linux/module.h>
 #include <net/tcp.h>
 
-#define ALPHA_BASE	(1<<7)  /* 1.0 with shift << 7 */
-#define BETA_MIN	(1<<6)  /* 0.5 with shift << 7 */
+#define ALPHA_BASE	(1<<7)	/* 1.0 with shift << 7 */
+#define BETA_MIN	(1<<6)	/* 0.5 with shift << 7 */
 #define BETA_MAX	102	/* 0.8 with shift << 7 */
 
-static int use_rtt_scaling = 1;
+static int use_rtt_scaling __read_mostly = 1;
 module_param(use_rtt_scaling, int, 0644);
 MODULE_PARM_DESC(use_rtt_scaling, "turn on/off RTT scaling");
 
-static int use_bandwidth_switch = 1;
+static int use_bandwidth_switch __read_mostly = 1;
 module_param(use_bandwidth_switch, int, 0644);
 MODULE_PARM_DESC(use_bandwidth_switch, "turn on/off bandwidth switcher");
 
 struct htcp {
 	u32	alpha;		/* Fixed point arith, << 7 */
 	u8	beta;           /* Fixed point arith, << 7 */
-	u8	modeswitch;     /* Delay modeswitch until we had at least one congestion event */
+	u8	modeswitch;	/* Delay modeswitch
+				   until we had at least one congestion event */
 	u16	pkts_acked;
 	u32	packetcount;
 	u32	minRTT;
@@ -44,14 +45,14 @@
 	u32	lasttime;
 };
 
-static inline u32 htcp_cong_time(struct htcp *ca)
+static inline u32 htcp_cong_time(const struct htcp *ca)
 {
 	return jiffies - ca->last_cong;
 }
 
-static inline u32 htcp_ccount(struct htcp *ca)
+static inline u32 htcp_ccount(const struct htcp *ca)
 {
-	return htcp_cong_time(ca)/ca->minRTT;
+	return htcp_cong_time(ca) / ca->minRTT;
 }
 
 static inline void htcp_reset(struct htcp *ca)
@@ -67,10 +68,12 @@
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	struct htcp *ca = inet_csk_ca(sk);
+
 	ca->last_cong = ca->undo_last_cong;
 	ca->maxRTT = ca->undo_maxRTT;
 	ca->old_maxB = ca->undo_old_maxB;
-	return max(tp->snd_cwnd, (tp->snd_ssthresh<<7)/ca->beta);
+
+	return max(tp->snd_cwnd, (tp->snd_ssthresh << 7) / ca->beta);
 }
 
 static inline void measure_rtt(struct sock *sk)
@@ -78,17 +81,19 @@
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	const struct tcp_sock *tp = tcp_sk(sk);
 	struct htcp *ca = inet_csk_ca(sk);
-	u32 srtt = tp->srtt>>3;
+	u32 srtt = tp->srtt >> 3;
 
 	/* keep track of minimum RTT seen so far, minRTT is zero at first */
 	if (ca->minRTT > srtt || !ca->minRTT)
 		ca->minRTT = srtt;
 
 	/* max RTT */
-	if (icsk->icsk_ca_state == TCP_CA_Open && tp->snd_ssthresh < 0xFFFF && htcp_ccount(ca) > 3) {
+	if (icsk->icsk_ca_state == TCP_CA_Open
+	    && tp->snd_ssthresh < 0xFFFF && htcp_ccount(ca) > 3) {
 		if (ca->maxRTT < ca->minRTT)
 			ca->maxRTT = ca->minRTT;
-		if (ca->maxRTT < srtt && srtt <= ca->maxRTT+msecs_to_jiffies(20))
+		if (ca->maxRTT < srtt
+		    && srtt <= ca->maxRTT + msecs_to_jiffies(20))
 			ca->maxRTT = srtt;
 	}
 }
@@ -116,15 +121,16 @@
 
 	ca->packetcount += pkts_acked;
 
-	if (ca->packetcount >= tp->snd_cwnd - (ca->alpha>>7? : 1)
-			&& now - ca->lasttime >= ca->minRTT
-			&& ca->minRTT > 0) {
-		__u32 cur_Bi = ca->packetcount*HZ/(now - ca->lasttime);
+	if (ca->packetcount >= tp->snd_cwnd - (ca->alpha >> 7 ? : 1)
+	    && now - ca->lasttime >= ca->minRTT
+	    && ca->minRTT > 0) {
+		__u32 cur_Bi = ca->packetcount * HZ / (now - ca->lasttime);
+
 		if (htcp_ccount(ca) <= 3) {
 			/* just after backoff */
 			ca->minB = ca->maxB = ca->Bi = cur_Bi;
 		} else {
-			ca->Bi = (3*ca->Bi + cur_Bi)/4;
+			ca->Bi = (3 * ca->Bi + cur_Bi) / 4;
 			if (ca->Bi > ca->maxB)
 				ca->maxB = ca->Bi;
 			if (ca->minB > ca->maxB)
@@ -142,7 +148,7 @@
 		u32 old_maxB = ca->old_maxB;
 		ca->old_maxB = ca->maxB;
 
-		if (!between(5*maxB, 4*old_maxB, 6*old_maxB)) {
+		if (!between(5 * maxB, 4 * old_maxB, 6 * old_maxB)) {
 			ca->beta = BETA_MIN;
 			ca->modeswitch = 0;
 			return;
@@ -150,7 +156,7 @@
 	}
 
 	if (ca->modeswitch && minRTT > msecs_to_jiffies(10) && maxRTT) {
-		ca->beta = (minRTT<<7)/maxRTT;
+		ca->beta = (minRTT << 7) / maxRTT;
 		if (ca->beta < BETA_MIN)
 			ca->beta = BETA_MIN;
 		else if (ca->beta > BETA_MAX)
@@ -169,23 +175,26 @@
 
 	if (diff > HZ) {
 		diff -= HZ;
-		factor = 1+ ( 10*diff + ((diff/2)*(diff/2)/HZ) )/HZ;
+		factor = 1 + (10 * diff + ((diff / 2) * (diff / 2) / HZ)) / HZ;
 	}
 
 	if (use_rtt_scaling && minRTT) {
-		u32 scale = (HZ<<3)/(10*minRTT);
-		scale = min(max(scale, 1U<<2), 10U<<3); /* clamping ratio to interval [0.5,10]<<3 */
-		factor = (factor<<3)/scale;
+		u32 scale = (HZ << 3) / (10 * minRTT);
+
+		/* clamping ratio to interval [0.5,10]<<3 */
+		scale = min(max(scale, 1U << 2), 10U << 3);
+		factor = (factor << 3) / scale;
 		if (!factor)
 			factor = 1;
 	}
 
-	ca->alpha = 2*factor*((1<<7)-ca->beta);
+	ca->alpha = 2 * factor * ((1 << 7) - ca->beta);
 	if (!ca->alpha)
 		ca->alpha = ALPHA_BASE;
 }
 
-/* After we have the rtt data to calculate beta, we'd still prefer to wait one
+/*
+ * After we have the rtt data to calculate beta, we'd still prefer to wait one
  * rtt before we adjust our beta to ensure we are working from a consistent
  * data.
  *
@@ -202,15 +211,16 @@
 	htcp_beta_update(ca, minRTT, maxRTT);
 	htcp_alpha_update(ca);
 
-	/* add slowly fading memory for maxRTT to accommodate routing changes etc */
+	/* add slowly fading memory for maxRTT to accommodate routing changes */
 	if (minRTT > 0 && maxRTT > minRTT)
-		ca->maxRTT = minRTT + ((maxRTT-minRTT)*95)/100;
+		ca->maxRTT = minRTT + ((maxRTT - minRTT) * 95) / 100;
 }
 
 static u32 htcp_recalc_ssthresh(struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	const struct htcp *ca = inet_csk_ca(sk);
+
 	htcp_param_update(sk);
 	return max((tp->snd_cwnd * ca->beta) >> 7, 2U);
 }
@@ -227,7 +237,6 @@
 	if (tp->snd_cwnd <= tp->snd_ssthresh)
 		tcp_slow_start(tp);
 	else {
-
 		measure_rtt(sk);
 
 		/* In dangerous area, increase slowly.
