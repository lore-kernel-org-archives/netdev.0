From: Baruch Even <baruch@ev-en.org>
Subject: [PATCH TCP 4/4] Switch out when bandwidth changes abruptly
Date: Fri,  6 May 2005 20:41:35 +0300 (IDT)
Message-ID: <20050506174135.20140.18257.52874@galon.ev-en.org>
References: <20050506173729.20140.93205.37072@galon.ev-en.org>
Cc: netdev@oss.sgi.com, Baruch Even <baruch@ev-en.org>,
        Douglas Leith <doug.leith@nuim.ie>,
        "David S.Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050506173729.20140.93205.37072@galon.ev-en.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is another H-TCP layer patch. This patch adds a bandwidth switcher so that
when a new stream joins we quickly yield bandwidth to it by going back to a
backoff factor of one-half.

For this to work we have a bandwidth estimator and need a new hook for
congestion control algorithms, this is in effect something that can be used
generally and is not necessarily specific to H-TCP. But H-TCP is the only user
for it at this time. A simple use for it is to export it to user-space for a
more accurate bandwidth estimation on the sender side.

Signed-Off-By: Baruch Even <baruch@ev-en.org>

---
 include/net/tcp.h    |    1 
 net/ipv4/tcp_htcp.c  |  138 +++++++++++++++++++++++++++++++++++++++------------
 net/ipv4/tcp_input.c |   10 +++
 3 files changed, 117 insertions(+), 32 deletions(-)

Index: 2.6.11-stephen-htcp/net/ipv4/tcp_htcp.c
===================================================================
--- 2.6.11-stephen-htcp.orig/net/ipv4/tcp_htcp.c
+++ 2.6.11-stephen-htcp/net/ipv4/tcp_htcp.c
@@ -9,6 +9,7 @@
 #include <linux/module.h>
 #include <net/tcp.h>
 
+#define ALPHA_BASE	(1<<7)  /* 1.0 with shift << 7 */
 #define BETA_MIN	(1<<6)  /* 0.5 with shift << 7 */
 #define BETA_MAX	102	/* 0.8 with shift << 7 */
 
@@ -16,24 +17,40 @@ static int use_rtt_scaling = 1;
 module_param(use_rtt_scaling, int, 0644);
 MODULE_PARM_DESC(use_rtt_scaling, "turn on/off RTT scaling");
 
+static int use_bandwidth_switch = 1;
+module_param(use_bandwidth_switch, int, 0644);
+MODULE_PARM_DESC(use_bandwidth_switch, "turn on/off bandwidth switcher");
+
 struct htcp_ca {
-	u32	alpha;		/* Fixed point arith, << 7 */
-	u32	beta;           /* Fixed point arith, << 7 */
-	u32	modeswitch;     /* Delay modeswitch until we had at least one congestion event */
-	u32	ccount;		/* Number of RTTs since last congestion event */
+	u16	alpha;		/* Fixed point arith, << 7 */
+	u8	beta;           /* Fixed point arith, << 7 */
+	u8	modeswitch;     /* Delay modeswitch until we had at least one congestion event */
+	u8	ccount;		/* Number of RTTs since last congestion event */
+	u8	undo_ccount;
+	u16	packetcount;
 	u32	minRTT;
 	u32	maxRTT;
+	u32	snd_cwnd_cnt2;
 
-	u32	undo_ccount;
 	u32	undo_maxRTT;
+	u32	undo_old_maxB;
+
+	/* Bandwidth estimation */
+	u32	minB;
+	u32	maxB;
+	u32	old_maxB;
+	u32	Bi;
+	u32	lasttime;
 };
 
 static inline void htcp_reset(struct htcp_ca *ca)
 {
 	ca->undo_ccount = ca->ccount;
 	ca->undo_maxRTT = ca->maxRTT;
+	ca->undo_old_maxB = ca->old_maxB;
 
 	ca->ccount = 0;
+	ca->snd_cwnd_cnt2 = 0;
 }
 
 static u32 htcp_cwnd_undo(struct tcp_sock *tp)
@@ -41,6 +58,7 @@ static u32 htcp_cwnd_undo(struct tcp_soc
 	struct htcp_ca *ca = tcp_ca(tp);
 	ca->ccount = ca->undo_ccount;
 	ca->maxRTT = ca->undo_maxRTT;
+	ca->old_maxB = ca->undo_old_maxB;
 	return max(tp->snd_cwnd, (tp->snd_ssthresh<<7)/ca->beta);
 }
 
@@ -62,8 +80,53 @@ static inline void measure_rtt(struct tc
 	}
 }
 
+static void measure_achieved_throughput(struct tcp_sock *tp, u32 pkts_acked)
+{
+	struct htcp_ca *ca = tcp_ca(tp);
+	u32 now = tcp_time_stamp;
+
+	/* achieved throughput calculations */
+	if (tp->ca_state != TCP_CA_Open && tp->ca_state != TCP_CA_Disorder) {
+		ca->packetcount = 0;
+		ca->lasttime = now;
+		return;
+	}
+
+	ca->packetcount += pkts_acked;
+
+	if (ca->packetcount >= tp->snd_cwnd - (ca->alpha>>7? : 1)
+			&& now - ca->lasttime >= ca->minRTT
+			&& ca->minRTT > 0) {
+		__u32 cur_Bi = ca->packetcount*HZ/(now - ca->lasttime);
+		if (ca->ccount <= 3) {
+			/* just after backoff */
+			ca->minB = ca->maxB = ca->Bi = cur_Bi;
+		} else {
+			ca->Bi = (3*ca->Bi + cur_Bi)/4;
+			if (ca->Bi > ca->maxB)
+				ca->maxB = ca->Bi;
+			if (ca->minB > ca->maxB)
+				ca->minB = ca->maxB;
+		}
+		ca->packetcount = 0;
+		ca->lasttime = now;
+	}
+}
+
 static inline void htcp_beta_update(struct htcp_ca *ca, u32 minRTT, u32 maxRTT)
 {
+	if (use_bandwidth_switch) {
+		u32 maxB = ca->maxB;
+		u32 old_maxB = ca->old_maxB;
+		ca->old_maxB = ca->maxB;
+
+		if (!between(5*maxB, 4*old_maxB, 6*old_maxB)) {
+			ca->beta = BETA_MIN;
+			ca->modeswitch = 0;
+			return;
+		}
+	}
+
 	if (ca->modeswitch && minRTT > max(HZ/100, 1) && maxRTT) {
 		ca->beta = (minRTT<<7)/maxRTT;
 		if (ca->beta < BETA_MIN)
@@ -76,8 +139,9 @@ static inline void htcp_beta_update(stru
 	}
 }
 
-static inline void htcp_alpha_update(struct htcp_ca *ca, u32 minRTT)
+static inline void htcp_alpha_update(struct htcp_ca *ca)
 {
+	u32 minRTT = ca->minRTT;
 	u32 factor = 1;
 	u32 diff = ca->ccount * minRTT; /* time since last backoff */
 
@@ -86,18 +150,17 @@ static inline void htcp_alpha_update(str
 		factor = 1+ ( 10*diff + ((diff/2)*(diff/2)/HZ) )/HZ;
 	}
 
-	ca->alpha = 2*factor*((1<<7)-ca->beta);
-	if (!ca->alpha)
-		ca->alpha = 1<<7;
-
 	if (use_rtt_scaling && minRTT) {
-		u32 scale;
-		scale = (HZ<<3)/(10*minRTT);
+		u32 scale = (HZ<<3)/(10*minRTT);
 		scale = min(max(scale, 1U<<2), 10U<<3); /* clamping ratio to interval [0.5,10]<<3 */
-		ca->alpha = (ca->alpha<<3)/scale;
-		if (!ca->alpha)
-			ca->alpha = 1<<7;
+		factor = (factor<<3)/scale;
+		if (!factor)
+			factor = 1;
 	}
+
+	ca->alpha = 2*factor*((1<<7)-ca->beta);
+	if (!ca->alpha)
+		ca->alpha = ALPHA_BASE;
 }
 
 /* After we have the rtt data to calculate beta, we'd still prefer to wait one
@@ -115,7 +178,7 @@ static void htcp_param_update(struct tcp
 	u32 maxRTT = ca->maxRTT;
 
 	htcp_beta_update(ca, minRTT, maxRTT);
-	htcp_alpha_update(ca, minRTT);
+	htcp_alpha_update(ca);
 
 	/* add slowly fading memory for maxRTT to accommodate routing changes etc */
 	if (minRTT > 0 && maxRTT > minRTT)
@@ -125,6 +188,7 @@ static void htcp_param_update(struct tcp
 static u32 htcp_recalc_ssthresh(struct tcp_sock *tp)
 {
 	struct htcp_ca *ca = tcp_ca(tp);
+	htcp_param_update(tp);
 	return max((tp->snd_cwnd * ca->beta) >> 7, 2U);
 }
 
@@ -142,47 +206,57 @@ static void htcp_cong_avoid(struct tcp_s
 	} else {
 		measure_rtt(tp);
 
+		/* keep track of number of round-trip times since last backoff event */
+		if (ca->snd_cwnd_cnt2++ > tp->snd_cwnd) {
+			ca->ccount++;
+			ca->snd_cwnd_cnt2 = 0;
+			htcp_alpha_update(ca);
+		}
+
                 /* In dangerous area, increase slowly.
 		 * In theory this is tp->snd_cwnd += alpha / tp->snd_cwnd
 		 */
-		if (tp->snd_cwnd_cnt >= tp->snd_cwnd) {
+		if ((tp->snd_cwnd_cnt++ * ca->alpha)>>7 >= tp->snd_cwnd) {
 			if (tp->snd_cwnd < tp->snd_cwnd_clamp)
-				tp->snd_cwnd += ca->alpha;
+				tp->snd_cwnd++;
 			tp->snd_cwnd_cnt = 0;
-			ca->ccount++;
-		} else
-			tp->snd_cwnd_cnt++;
+		}
 	}
 }
 
+static u32 htcp_cwnd_min(struct tcp_sock *tp)
+{
+	return tp->snd_ssthresh;
+}
+
 static void htcp_start(struct tcp_sock *tp)
 {
 	struct htcp_ca *ca = tcp_ca(tp);
-	ca->alpha = 1<<7;
+	memset(ca, 0, sizeof(struct htcp_ca));
+	ca->alpha = ALPHA_BASE;
 	ca->beta = BETA_MIN;
-	ca->modeswitch = 0;
-	ca->ccount = 0;
-	ca->minRTT = 0;
-	ca->maxRTT = 0;
+	printk(KERN_INFO "htcp started for %p/%p\n", tp, ca);
 }
 
 static void htcp_ca_state(struct tcp_sock *tp, u8 new_state)
 {
-	if (new_state == TCP_CA_CWR || new_state == TCP_CA_Recovery) {
-		htcp_param_update(tp);
-		htcp_reset(tcp_ca(tp));
-	} else if (new_state == TCP_CA_Loss) {
+	switch (new_state) {
+	case TCP_CA_CWR:
+	case TCP_CA_Recovery:
+	case TCP_CA_Loss:
 		htcp_reset(tcp_ca(tp));
+		break;
 	}
 }
 
 static struct tcp_ca_type htcp = {
 	.start		= htcp_start,
 	.ssthresh	= htcp_recalc_ssthresh,
-	.min_cwnd	= tcp_reno_cwnd_min,
+	.min_cwnd	= htcp_cwnd_min,
 	.cong_avoid	= htcp_cong_avoid,
 	.set_state	= htcp_ca_state,
 	.undo_cwnd	= htcp_cwnd_undo,
+	.pkts_acked	= measure_achieved_throughput,
 
 	.owner		= THIS_MODULE,
 	.name		= "htcp",
@@ -192,6 +266,8 @@ static int __init htcp_init(void)
 {
 	BUILD_BUG_ON(sizeof(struct htcp_ca) > TCP_CA_PRIV_SIZE);
 	BUILD_BUG_ON(BETA_MIN >= BETA_MAX);
+	if (!use_bandwidth_switch)
+		htcp.pkts_acked = NULL;
 	tcp_ca_register(&htcp);
 	return 0;
 }
Index: 2.6.11-stephen-htcp/include/net/tcp.h
===================================================================
--- 2.6.11-stephen-htcp.orig/include/net/tcp.h
+++ 2.6.11-stephen-htcp/include/net/tcp.h
@@ -1197,6 +1197,7 @@ struct tcp_ca_type {
 
 	void (*cwnd_event)(struct tcp_sock *tp, enum tcp_ca_event ev);
 	u32 (*undo_cwnd)(struct tcp_sock *tp);
+	void (*pkts_acked)(struct tcp_sock *tp, u32 num_acked);
 
 	struct list_head	list;
 	struct module 		*owner;
Index: 2.6.11-stephen-htcp/net/ipv4/tcp_input.c
===================================================================
--- 2.6.11-stephen-htcp.orig/net/ipv4/tcp_input.c
+++ 2.6.11-stephen-htcp/net/ipv4/tcp_input.c
@@ -2030,6 +2030,7 @@ static int tcp_clean_rtx_queue(struct so
 	__u32 now = tcp_time_stamp;
 	int acked = 0;
 	__s32 seq_rtt = -1;
+	u32 pkts_acked = 0;
 
 	while ((skb = skb_peek(&sk->sk_write_queue)) &&
 	       skb != sk->sk_send_head) {
@@ -2041,9 +2042,12 @@ static int tcp_clean_rtx_queue(struct so
 		 * the other end.
 		 */
 		if (after(scb->end_seq, tp->snd_una)) {
-			if (tcp_skb_pcount(skb) > 1)
+			if (tcp_skb_pcount(skb) > 1) {
+				u32 pkts = tcp_skb_pcount(skb);
 				acked |= tcp_tso_acked(sk, skb,
 						       now, &seq_rtt);
+				pkts_acked += pkts - tcp_skb_pcount(skb);
+			}
 			break;
 		}
 
@@ -2056,6 +2060,7 @@ static int tcp_clean_rtx_queue(struct so
 		 */
 		if (!(scb->flags & TCPCB_FLAG_SYN)) {
 			acked |= FLAG_DATA_ACKED;
+			pkts_acked += tcp_skb_pcount(skb);
 		} else {
 			acked |= FLAG_SYN_ACKED;
 			tp->retrans_stamp = 0;
@@ -2091,6 +2096,9 @@ static int tcp_clean_rtx_queue(struct so
 		tcp_ack_packets_out(sk, tp);
 	}
 
+	if (tp->ca_proto->pkts_acked)
+		tp->ca_proto->pkts_acked(tp, pkts_acked);
+
 #if FASTRETRANS_DEBUG > 0
 	BUG_TRAP((int)tp->sacked_out >= 0);
 	BUG_TRAP((int)tp->lost_out >= 0);
