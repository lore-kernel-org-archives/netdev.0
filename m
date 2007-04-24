From: Stephen Hemminger <shemminger@linux-founsation.org>
Subject: [PATCH 4/4] TCP YEAH: use vegas dont copy it
Date: Mon, 23 Apr 2007 20:31:21 -0700
Message-ID: <20070424033317.201165857@linux-foundation.org>
References: <20070424033117.873984872@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:48117 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161577AbXDXDg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2007 23:36:26 -0400
Content-Disposition: inline; filename=tcp-yeah-clean.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rather than using a copy of vegas code, the YEAH code should just
have it exported so there is common code.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


---
 net/ipv4/tcp_vegas.c |   31 +++++-------
 net/ipv4/tcp_vegas.h |   24 +++++++++
 net/ipv4/tcp_yeah.c  |   53 +++++++++-----------
 net/ipv4/tcp_yeah.h  |  131 ---------------------------------------------------
 4 files changed, 61 insertions(+), 178 deletions(-)

--- net-2.6.22.orig/net/ipv4/tcp_vegas.c
+++ net-2.6.22/net/ipv4/tcp_vegas.c
@@ -38,6 +38,8 @@
 
 #include <net/tcp.h>
 
+#include "tcp_vegas.h"
+
 /* Default values of the Vegas variables, in fixed-point representation
  * with V_PARAM_SHIFT bits to the right of the binary point.
  */
@@ -54,17 +56,6 @@ module_param(gamma, int, 0644);
 MODULE_PARM_DESC(gamma, "limit on increase (scale by 2)");
 
 
-/* Vegas variables */
-struct vegas {
-	u32	beg_snd_nxt;	/* right edge during last RTT */
-	u32	beg_snd_una;	/* left edge  during last RTT */
-	u32	beg_snd_cwnd;	/* saves the size of the cwnd */
-	u8	doing_vegas_now;/* if true, do vegas for this RTT */
-	u16	cntRTT;		/* # of RTTs measured within last RTT */
-	u32	minRTT;		/* min of RTTs measured within last RTT (in usec) */
-	u32	baseRTT;	/* the min of all Vegas RTT measurements seen (in usec) */
-};
-
 /* There are several situations when we must "re-start" Vegas:
  *
  *  o when a connection is established
@@ -81,7 +72,7 @@ struct vegas {
  * Instead we must wait until the completion of an RTT during
  * which we actually receive ACKs.
  */
-static inline void vegas_enable(struct sock *sk)
+static void vegas_enable(struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	struct vegas *vegas = inet_csk_ca(sk);
@@ -104,13 +95,14 @@ static inline void vegas_disable(struct 
 	vegas->doing_vegas_now = 0;
 }
 
-static void tcp_vegas_init(struct sock *sk)
+void tcp_vegas_init(struct sock *sk)
 {
 	struct vegas *vegas = inet_csk_ca(sk);
 
 	vegas->baseRTT = 0x7fffffff;
 	vegas_enable(sk);
 }
+EXPORT_SYMBOL_GPL(tcp_vegas_init);
 
 /* Do RTT sampling needed for Vegas.
  * Basically we:
@@ -120,7 +112,7 @@ static void tcp_vegas_init(struct sock *
  *   o min-filter RTT samples from a much longer window (forever for now)
  *     to find the propagation delay (baseRTT)
  */
-static void tcp_vegas_pkts_acked(struct sock *sk, u32 cnt, ktime_t last)
+void tcp_vegas_pkts_acked(struct sock *sk, u32 cnt, ktime_t last)
 {
 	struct vegas *vegas = inet_csk_ca(sk);
 	u32 vrtt;
@@ -138,8 +130,9 @@ static void tcp_vegas_pkts_acked(struct 
 	vegas->minRTT = min(vegas->minRTT, vrtt);
 	vegas->cntRTT++;
 }
+EXPORT_SYMBOL_GPL(tcp_vegas_pkts_acked);
 
-static void tcp_vegas_state(struct sock *sk, u8 ca_state)
+void tcp_vegas_state(struct sock *sk, u8 ca_state)
 {
 
 	if (ca_state == TCP_CA_Open)
@@ -147,6 +140,7 @@ static void tcp_vegas_state(struct sock 
 	else
 		vegas_disable(sk);
 }
+EXPORT_SYMBOL_GPL(tcp_vegas_state);
 
 /*
  * If the connection is idle and we are restarting,
@@ -157,12 +151,13 @@ static void tcp_vegas_state(struct sock 
  * packets, _then_ we can make Vegas calculations
  * again.
  */
-static void tcp_vegas_cwnd_event(struct sock *sk, enum tcp_ca_event event)
+void tcp_vegas_cwnd_event(struct sock *sk, enum tcp_ca_event event)
 {
 	if (event == CA_EVENT_CWND_RESTART ||
 	    event == CA_EVENT_TX_START)
 		tcp_vegas_init(sk);
 }
+EXPORT_SYMBOL_GPL(tcp_vegas_cwnd_event);
 
 static void tcp_vegas_cong_avoid(struct sock *sk, u32 ack,
 				 u32 seq_rtt, u32 in_flight, int flag)
@@ -339,8 +334,7 @@ static void tcp_vegas_cong_avoid(struct 
 }
 
 /* Extract info for Tcp socket info provided via netlink. */
-static void tcp_vegas_get_info(struct sock *sk, u32 ext,
-			       struct sk_buff *skb)
+void tcp_vegas_get_info(struct sock *sk, u32 ext, struct sk_buff *skb)
 {
 	const struct vegas *ca = inet_csk_ca(sk);
 	if (ext & (1 << (INET_DIAG_VEGASINFO - 1))) {
@@ -354,6 +348,7 @@ static void tcp_vegas_get_info(struct so
 		nla_put(skb, INET_DIAG_VEGASINFO, sizeof(info), &info);
 	}
 }
+EXPORT_SYMBOL_GPL(tcp_vegas_get_info);
 
 static struct tcp_congestion_ops tcp_vegas = {
 	.flags		= TCP_CONG_RTT_STAMP,
--- /dev/null
+++ net-2.6.22/net/ipv4/tcp_vegas.h
@@ -0,0 +1,24 @@
+/*
+ * TCP Vegas congestion control interface
+ */
+#ifndef __TCP_VEGAS_H
+#define __TCP_VEGAS_H 1
+
+/* Vegas variables */
+struct vegas {
+	u32	beg_snd_nxt;	/* right edge during last RTT */
+	u32	beg_snd_una;	/* left edge  during last RTT */
+	u32	beg_snd_cwnd;	/* saves the size of the cwnd */
+	u8	doing_vegas_now;/* if true, do vegas for this RTT */
+	u16	cntRTT;		/* # of RTTs measured within last RTT */
+	u32	minRTT;		/* min of RTTs measured within last RTT (in usec) */
+	u32	baseRTT;	/* the min of all Vegas RTT measurements seen (in usec) */
+};
+
+extern void tcp_vegas_init(struct sock *sk);
+extern void tcp_vegas_state(struct sock *sk, u8 ca_state);
+extern void tcp_vegas_pkts_acked(struct sock *sk, u32 cnt, ktime_t last);
+extern void tcp_vegas_cwnd_event(struct sock *sk, enum tcp_ca_event event);
+extern void tcp_vegas_get_info(struct sock *sk, u32 ext, struct sk_buff *skb);
+
+#endif	/* __TCP_VEGAS_H */
--- net-2.6.22.orig/net/ipv4/tcp_yeah.c
+++ net-2.6.22/net/ipv4/tcp_yeah.c
@@ -6,13 +6,14 @@
  *    http://wil.cs.caltech.edu/pfldnet2007/paper/YeAH_TCP.pdf
  *
  */
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/inet_diag.h>
 
-#include "tcp_yeah.h"
+#include <net/tcp.h>
 
-/* Default values of the Vegas variables, in fixed-point representation
- * with V_PARAM_SHIFT bits to the right of the binary point.
- */
-#define V_PARAM_SHIFT 1
+#include "tcp_vegas.h"
 
 #define TCP_YEAH_ALPHA       80 //lin number of packets queued at the bottleneck
 #define TCP_YEAH_GAMMA        1 //lin fraction of queue to be removed per rtt
@@ -26,14 +27,7 @@
 
 /* YeAH variables */
 struct yeah {
-	/* Vegas */
-	u32	beg_snd_nxt;	/* right edge during last RTT */
-	u32	beg_snd_una;	/* left edge  during last RTT */
-	u32	beg_snd_cwnd;	/* saves the size of the cwnd */
-	u8	doing_vegas_now;/* if true, do vegas for this RTT */
-	u16	cntRTT;		/* # of RTTs measured within last RTT */
-	u32	minRTT;		/* min of RTTs measured within last RTT (in usec) */
-	u32	baseRTT;	/* the min of all Vegas RTT measurements seen (in usec) */
+	struct vegas vegas;	/* must be first */
 
 	/* YeAH */
 	u32 lastQ;
@@ -84,9 +78,10 @@ static void tcp_yeah_cong_avoid(struct s
 	if (!tcp_is_cwnd_limited(sk, in_flight))
 		return;
 
-	if (tp->snd_cwnd <= tp->snd_ssthresh) {
+	if (tp->snd_cwnd <= tp->snd_ssthresh)
 		tcp_slow_start(tp);
-	} else if (!yeah->doing_reno_now) {
+
+	else if (!yeah->doing_reno_now) {
 		/* Scalable */
 
 		tp->snd_cwnd_cnt+=yeah->pkts_acked;
@@ -110,19 +105,19 @@ static void tcp_yeah_cong_avoid(struct s
 		}
 	}
 
-	/* The key players are v_beg_snd_una and v_beg_snd_nxt.
+	/* The key players are v_vegas.beg_snd_una and v_beg_snd_nxt.
 	 *
 	 * These are so named because they represent the approximate values
 	 * of snd_una and snd_nxt at the beginning of the current RTT. More
 	 * precisely, they represent the amount of data sent during the RTT.
 	 * At the end of the RTT, when we receive an ACK for v_beg_snd_nxt,
-	 * we will calculate that (v_beg_snd_nxt - v_beg_snd_una) outstanding
+	 * we will calculate that (v_beg_snd_nxt - v_vegas.beg_snd_una) outstanding
 	 * bytes of data have been ACKed during the course of the RTT, giving
 	 * an "actual" rate of:
 	 *
-	 *     (v_beg_snd_nxt - v_beg_snd_una) / (rtt duration)
+	 *     (v_beg_snd_nxt - v_vegas.beg_snd_una) / (rtt duration)
 	 *
-	 * Unfortunately, v_beg_snd_una is not exactly equal to snd_una,
+	 * Unfortunately, v_vegas.beg_snd_una is not exactly equal to snd_una,
 	 * because delayed ACKs can cover more than one segment, so they
 	 * don't line up yeahly with the boundaries of RTTs.
 	 *
@@ -132,7 +127,7 @@ static void tcp_yeah_cong_avoid(struct s
 	 * So we keep track of our cwnd separately, in v_beg_snd_cwnd.
 	 */
 
-	if (after(ack, yeah->beg_snd_nxt)) {
+	if (after(ack, yeah->vegas.beg_snd_nxt)) {
 
 		/* We do the Vegas calculations only if we got enough RTT
 		 * samples that we can be reasonably sure that we got
@@ -143,7 +138,7 @@ static void tcp_yeah_cong_avoid(struct s
 		 * If  we have 3 samples, we should be OK.
 		 */
 
-		if (yeah->cntRTT > 2) {
+		if (yeah->vegas.cntRTT > 2) {
 			u32 rtt, queue;
 			u64 bw;
 
@@ -158,18 +153,18 @@ static void tcp_yeah_cong_avoid(struct s
 			 * of delayed ACKs, at the cost of noticing congestion
 			 * a bit later.
 			 */
-			rtt = yeah->minRTT;
+			rtt = yeah->vegas.minRTT;
 
 			/* Compute excess number of packets above bandwidth
 			 * Avoid doing full 64 bit divide.
 			 */
 			bw = tp->snd_cwnd;
-			bw *= rtt - yeah->baseRTT;
+			bw *= rtt - yeah->vegas.baseRTT;
 			do_div(bw, rtt);
 			queue = bw;
 
 			if (queue > TCP_YEAH_ALPHA ||
-			    rtt - yeah->baseRTT > (yeah->baseRTT / TCP_YEAH_PHY)) {
+			    rtt - yeah->vegas.baseRTT > (yeah->vegas.baseRTT / TCP_YEAH_PHY)) {
 				if (queue > TCP_YEAH_ALPHA
 				    && tp->snd_cwnd > yeah->reno_count) {
 					u32 reduction = min(queue / TCP_YEAH_GAMMA ,
@@ -208,13 +203,13 @@ static void tcp_yeah_cong_avoid(struct s
 		/* Save the extent of the current window so we can use this
 		 * at the end of the next RTT.
 		 */
-		yeah->beg_snd_una  = yeah->beg_snd_nxt;
-		yeah->beg_snd_nxt  = tp->snd_nxt;
-		yeah->beg_snd_cwnd = tp->snd_cwnd;
+		yeah->vegas.beg_snd_una  = yeah->vegas.beg_snd_nxt;
+		yeah->vegas.beg_snd_nxt  = tp->snd_nxt;
+		yeah->vegas.beg_snd_cwnd = tp->snd_cwnd;
 
 		/* Wipe the slate clean for the next RTT. */
-		yeah->cntRTT = 0;
-		yeah->minRTT = 0x7fffffff;
+		yeah->vegas.cntRTT = 0;
+		yeah->vegas.minRTT = 0x7fffffff;
 	}
 }
 
--- net-2.6.22.orig/net/ipv4/tcp_yeah.h
+++ net-2.6.22/net/ipv4/tcp_yeah.h
@@ -5,134 +5,3 @@
 #include <asm/div64.h>
 
 #include <net/tcp.h>
-
-/* Vegas variables */
-struct vegas {
-	u32	beg_snd_nxt;	/* right edge during last RTT */
-	u32	beg_snd_una;	/* left edge  during last RTT */
-	u32	beg_snd_cwnd;	/* saves the size of the cwnd */
-	u8	doing_vegas_now;/* if true, do vegas for this RTT */
-	u16	cntRTT;		/* # of RTTs measured within last RTT */
-	u32	minRTT;		/* min of RTTs measured within last RTT (in usec) */
-	u32	baseRTT;	/* the min of all Vegas RTT measurements seen (in usec) */
-};
-
-/* There are several situations when we must "re-start" Vegas:
- *
- *  o when a connection is established
- *  o after an RTO
- *  o after fast recovery
- *  o when we send a packet and there is no outstanding
- *    unacknowledged data (restarting an idle connection)
- *
- * In these circumstances we cannot do a Vegas calculation at the
- * end of the first RTT, because any calculation we do is using
- * stale info -- both the saved cwnd and congestion feedback are
- * stale.
- *
- * Instead we must wait until the completion of an RTT during
- * which we actually receive ACKs.
- */
-static inline void vegas_enable(struct sock *sk)
-{
-	const struct tcp_sock *tp = tcp_sk(sk);
-	struct vegas *vegas = inet_csk_ca(sk);
-
-	/* Begin taking Vegas samples next time we send something. */
-	vegas->doing_vegas_now = 1;
-
-	/* Set the beginning of the next send window. */
-	vegas->beg_snd_nxt = tp->snd_nxt;
-
-	vegas->cntRTT = 0;
-	vegas->minRTT = 0x7fffffff;
-}
-
-/* Stop taking Vegas samples for now. */
-static inline void vegas_disable(struct sock *sk)
-{
-	struct vegas *vegas = inet_csk_ca(sk);
-
-	vegas->doing_vegas_now = 0;
-}
-
-static void tcp_vegas_init(struct sock *sk)
-{
-	struct vegas *vegas = inet_csk_ca(sk);
-
-	vegas->baseRTT = 0x7fffffff;
-	vegas_enable(sk);
-}
-
-static void tcp_vegas_state(struct sock *sk, u8 ca_state)
-{
-
-	if (ca_state == TCP_CA_Open)
-		vegas_enable(sk);
-	else
-		vegas_disable(sk);
-}
-
-/* Do RTT sampling needed for Vegas.
- * Basically we:
- *   o min-filter RTT samples from within an RTT to get the current
- *     propagation delay + queuing delay (we are min-filtering to try to
- *     avoid the effects of delayed ACKs)
- *   o min-filter RTT samples from a much longer window (forever for now)
- *     to find the propagation delay (baseRTT)
- */
-static void tcp_vegas_pkts_acked(struct sock *sk, u32 cnt, ktime_t last)
-{
-	struct vegas *vegas = inet_csk_ca(sk);
-	u32 vrtt;
-
-	/* Never allow zero rtt or baseRTT */
-	vrtt = (ktime_to_ns(net_timedelta(last)) / NSEC_PER_USEC) + 1;
-
-	/* Filter to find propagation delay: */
-	if (vrtt < vegas->baseRTT)
-		vegas->baseRTT = vrtt;
-
-	/* Find the min RTT during the last RTT to find
-	 * the current prop. delay + queuing delay:
-	 */
-	vegas->minRTT = min(vegas->minRTT, vrtt);
-	vegas->cntRTT++;
-}
-
-/*
- * If the connection is idle and we are restarting,
- * then we don't want to do any Vegas calculations
- * until we get fresh RTT samples.  So when we
- * restart, we reset our Vegas state to a clean
- * slate. After we get acks for this flight of
- * packets, _then_ we can make Vegas calculations
- * again.
- */
-static void tcp_vegas_cwnd_event(struct sock *sk, enum tcp_ca_event event)
-{
-	if (event == CA_EVENT_CWND_RESTART ||
-	    event == CA_EVENT_TX_START)
-		tcp_vegas_init(sk);
-}
-
-/* Extract info for Tcp socket info provided via netlink. */
-static void tcp_vegas_get_info(struct sock *sk, u32 ext,
-			       struct sk_buff *skb)
-{
-	const struct vegas *ca = inet_csk_ca(sk);
-	if (ext & (1 << (INET_DIAG_VEGASINFO - 1))) {
-		struct tcpvegas_info *info;
-
-		info = RTA_DATA(__RTA_PUT(skb, INET_DIAG_VEGASINFO,
-					  sizeof(*info)));
-
-		info->tcpv_enabled = ca->doing_vegas_now;
-		info->tcpv_rttcnt = ca->cntRTT;
-		info->tcpv_rtt = ca->baseRTT;
-		info->tcpv_minrtt = ca->minRTT;
-	rtattr_failure:	;
-	}
-}
-
-

-- 

