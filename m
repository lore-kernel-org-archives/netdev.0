From: "Angelo P. Castellani" <angelo.castellani@gmail.com>
Subject: Re: [PATCH 1/2][TCP] YeAH-TCP: algorithm implementation
Date: Mon, 19 Feb 2007 11:48:36 +0100
Message-ID: <45D98084.5030907@gmail.com>
References: <45D97FEA.1080006@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060604090908080503010801"
Cc: Andrea Baiocchi <andrea.baiocchi@uniroma1.it>,
	Francesco Vacirca <francesco@net.infocom.uniroma1.it>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:45150 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912AbXBSKsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 05:48:41 -0500
Received: by nf-out-0910.google.com with SMTP id o25so2388143nfa
        for <netdev@vger.kernel.org>; Mon, 19 Feb 2007 02:48:41 -0800 (PST)
In-Reply-To: <45D97FEA.1080006@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060604090908080503010801
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

The patch.

Angelo P. Castellani ha scritto:
> From: Angelo P. Castellani <angelo.castellani@gmail.con>
>
> YeAH-TCP is a sender-side high-speed enabled TCP congestion control
> algorithm, which uses a mixed loss/delay approach to compute the
> congestion window. It's design goals target high efficiency, internal,
> RTT and Reno fairness, resilience to link loss while keeping network
> elements load as low as possible.
>
> For further details look here:
>    http://wil.cs.caltech.edu/pfldnet2007/paper/YeAH_TCP.pdf
>
> Signed-off-by: Angelo P. Castellani <angelo.castellani@gmail.con>
>
> ---
>
> This is the YeAH-TCP implementation of the algorithm presented to
> PFLDnet2007 (http://wil.cs.caltech.edu/pfldnet2007/).
>
> Regards,
> Angelo P. Castellani
>
> Kconfig    |   14 ++
> Makefile   |    1
> tcp_yeah.c |  288
> +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
> tcp_yeah.h |  134 ++++++++++++++++++++++++++++
> 4 files changed, 437 insertions(+)
>
>


--------------060604090908080503010801
Content-Type: text/x-patch;
 name="tcp_yeah-1of2.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tcp_yeah-1of2.diff"

diff -uprN linux-2.6.20-a/net/ipv4/Kconfig linux-2.6.20-b/net/ipv4/Kconfig
--- linux-2.6.20-a/net/ipv4/Kconfig	2007-02-04 19:44:54.000000000 +0100
+++ linux-2.6.20-b/net/ipv4/Kconfig	2007-02-19 10:52:46.000000000 +0100
@@ -574,6 +574,20 @@ config TCP_CONG_VENO
 	loss packets.
 	See http://www.ntu.edu.sg/home5/ZHOU0022/papers/CPFu03a.pdf
 
+config TCP_CONG_YEAH
+	tristate "YeAH TCP"
+	depends on EXPERIMENTAL
+	default n
+	---help---
+	YeAH-TCP is a sender-side high-speed enabled TCP congestion control
+	algorithm, which uses a mixed loss/delay approach to compute the
+	congestion window. It's design goals target high efficiency,
+	internal, RTT and Reno fairness, resilience to link loss while
+	keeping network elements load as low as possible.
+	
+	For further details look here:
+	  http://wil.cs.caltech.edu/pfldnet2007/paper/YeAH_TCP.pdf
+
 choice
 	prompt "Default TCP congestion control"
 	default DEFAULT_CUBIC
diff -uprN linux-2.6.20-a/net/ipv4/Makefile linux-2.6.20-b/net/ipv4/Makefile
--- linux-2.6.20-a/net/ipv4/Makefile	2007-02-04 19:44:54.000000000 +0100
+++ linux-2.6.20-b/net/ipv4/Makefile	2007-02-19 10:52:46.000000000 +0100
@@ -49,6 +49,7 @@ obj-$(CONFIG_TCP_CONG_VEGAS) += tcp_vega
 obj-$(CONFIG_TCP_CONG_VENO) += tcp_veno.o
 obj-$(CONFIG_TCP_CONG_SCALABLE) += tcp_scalable.o
 obj-$(CONFIG_TCP_CONG_LP) += tcp_lp.o
+obj-$(CONFIG_TCP_CONG_YEAH) += tcp_yeah.o
 obj-$(CONFIG_NETLABEL) += cipso_ipv4.o
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
diff -uprN linux-2.6.20-a/net/ipv4/tcp_yeah.c linux-2.6.20-b/net/ipv4/tcp_yeah.c
--- linux-2.6.20-a/net/ipv4/tcp_yeah.c	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.20-b/net/ipv4/tcp_yeah.c	2007-02-19 10:52:46.000000000 +0100
@@ -0,0 +1,288 @@
+/*
+ *
+ *   YeAH TCP
+ *
+ * For further details look at:
+ *    http://wil.cs.caltech.edu/pfldnet2007/paper/YeAH_TCP.pdf
+ *
+ */
+
+#include "tcp_yeah.h"
+
+/* Default values of the Vegas variables, in fixed-point representation
+ * with V_PARAM_SHIFT bits to the right of the binary point.
+ */
+#define V_PARAM_SHIFT 1
+
+#define TCP_YEAH_ALPHA       80 //lin number of packets queued at the bottleneck
+#define TCP_YEAH_GAMMA        1 //lin fraction of queue to be removed per rtt
+#define TCP_YEAH_DELTA        3 //log minimum fraction of cwnd to be removed on loss
+#define TCP_YEAH_EPSILON      1 //log maximum fraction to be removed on early decongestion
+#define TCP_YEAH_PHY          8 //lin maximum delta from base
+#define TCP_YEAH_RHO         16 //lin minumum number of consecutive rtt to consider competition on loss
+#define TCP_YEAH_ZETA        50 //lin minimum number of state switchs to reset reno_count
+
+#define TCP_SCALABLE_AI_CNT	 100U
+
+/* YeAH variables */
+struct yeah {
+	/* Vegas */
+	u32	beg_snd_nxt;	/* right edge during last RTT */
+	u32	beg_snd_una;	/* left edge  during last RTT */
+	u32	beg_snd_cwnd;	/* saves the size of the cwnd */
+	u8	doing_vegas_now;/* if true, do vegas for this RTT */
+	u16	cntRTT;		/* # of RTTs measured within last RTT */
+	u32	minRTT;		/* min of RTTs measured within last RTT (in usec) */
+	u32	baseRTT;	/* the min of all Vegas RTT measurements seen (in usec) */
+	
+	/* YeAH */
+	u32 lastQ;
+	u32 doing_reno_now;
+
+	u32 reno_count;
+	u32 fast_count;
+
+	u32 pkts_acked;
+};
+
+static void tcp_yeah_init(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct yeah *yeah = inet_csk_ca(sk);
+
+	tcp_vegas_init(sk);
+
+	yeah->doing_reno_now = 0;
+	yeah->lastQ = 0;
+
+	yeah->reno_count = 2;
+
+	/* Ensure the MD arithmetic works.  This is somewhat pedantic,
+	 * since I don't think we will see a cwnd this large. :) */
+	tp->snd_cwnd_clamp = min_t(u32, tp->snd_cwnd_clamp, 0xffffffff/128);
+
+}
+
+
+static void tcp_yeah_pkts_acked(struct sock *sk, u32 pkts_acked)
+{
+	const struct inet_connection_sock *icsk = inet_csk(sk);
+	struct yeah *yeah = inet_csk_ca(sk);
+
+	if (icsk->icsk_ca_state == TCP_CA_Open)
+		yeah->pkts_acked = pkts_acked;	
+}
+
+/* 64bit divisor, dividend and result. dynamic precision */
+static inline u64 div64_64(u64 dividend, u64 divisor)
+{
+	u32 d = divisor;
+
+	if (divisor > 0xffffffffULL) {
+		unsigned int shift = fls(divisor >> 32);
+
+		d = divisor >> shift;
+		dividend >>= shift;
+	}
+
+	/* avoid 64 bit division if possible */
+	if (dividend >> 32)
+		do_div(dividend, d);
+	else
+		dividend = (u32) dividend / d;
+
+	return dividend;
+}
+
+static void tcp_yeah_cong_avoid(struct sock *sk, u32 ack,
+				 u32 seq_rtt, u32 in_flight, int flag)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct yeah *yeah = inet_csk_ca(sk);
+	
+	if (!tcp_is_cwnd_limited(sk, in_flight))
+		return;
+		
+	if (tp->snd_cwnd <= tp->snd_ssthresh) {
+		tcp_limited_slow_start(tp);
+	} else if (!yeah->doing_reno_now) {
+		/* Scalable */
+
+		tp->snd_cwnd_cnt+=yeah->pkts_acked;
+		if (tp->snd_cwnd_cnt > min(tp->snd_cwnd, TCP_SCALABLE_AI_CNT)){
+			if (tp->snd_cwnd < tp->snd_cwnd_clamp)
+				tp->snd_cwnd++;
+			tp->snd_cwnd_cnt = 0;
+		}
+
+		yeah->pkts_acked = 1;
+
+	} else {
+		/* Reno */
+
+		if (tp->snd_cwnd_cnt < tp->snd_cwnd)
+ 			tp->snd_cwnd_cnt++;
+
+		if (tp->snd_cwnd_cnt >= tp->snd_cwnd) {
+			tp->snd_cwnd++;
+			tp->snd_cwnd_cnt = 0;
+ 		}
+ 	}
+ 	 	
+	/* The key players are v_beg_snd_una and v_beg_snd_nxt.
+	 *
+	 * These are so named because they represent the approximate values
+	 * of snd_una and snd_nxt at the beginning of the current RTT. More
+	 * precisely, they represent the amount of data sent during the RTT.
+	 * At the end of the RTT, when we receive an ACK for v_beg_snd_nxt,
+	 * we will calculate that (v_beg_snd_nxt - v_beg_snd_una) outstanding
+	 * bytes of data have been ACKed during the course of the RTT, giving
+	 * an "actual" rate of:
+	 *
+	 *     (v_beg_snd_nxt - v_beg_snd_una) / (rtt duration)
+	 *
+	 * Unfortunately, v_beg_snd_una is not exactly equal to snd_una,
+	 * because delayed ACKs can cover more than one segment, so they
+	 * don't line up yeahly with the boundaries of RTTs.
+	 *
+	 * Another unfortunate fact of life is that delayed ACKs delay the
+	 * advance of the left edge of our send window, so that the number
+	 * of bytes we send in an RTT is often less than our cwnd will allow.
+	 * So we keep track of our cwnd separately, in v_beg_snd_cwnd.
+	 */
+
+	if (after(ack, yeah->beg_snd_nxt)) {
+
+		/* We do the Vegas calculations only if we got enough RTT
+		 * samples that we can be reasonably sure that we got
+		 * at least one RTT sample that wasn't from a delayed ACK.
+		 * If we only had 2 samples total,
+		 * then that means we're getting only 1 ACK per RTT, which
+		 * means they're almost certainly delayed ACKs.
+		 * If  we have 3 samples, we should be OK.
+		 */
+
+		if (yeah->cntRTT > 2) {
+			u32 rtt;
+			u32 queue, maxqueue;
+
+			/* We have enough RTT samples, so, using the Vegas
+			 * algorithm, we determine if we should increase or
+			 * decrease cwnd, and by how much.
+			 */
+
+			/* Pluck out the RTT we are using for the Vegas
+			 * calculations. This is the min RTT seen during the
+			 * last RTT. Taking the min filters out the effects
+			 * of delayed ACKs, at the cost of noticing congestion
+			 * a bit later.
+			 */
+			rtt = yeah->minRTT;
+			
+			queue = (u32)div64_64((u64)tp->snd_cwnd * (rtt - yeah->baseRTT), rtt);
+
+			maxqueue = TCP_YEAH_ALPHA;			
+
+			if (queue > maxqueue ||
+				    rtt - yeah->baseRTT > (yeah->baseRTT / TCP_YEAH_PHY)) {
+
+				if (queue > maxqueue && tp->snd_cwnd > yeah->reno_count) {
+					u32 reduction = min( queue / TCP_YEAH_GAMMA ,
+					                 tp->snd_cwnd >> TCP_YEAH_EPSILON );
+
+					tp->snd_cwnd -= reduction;
+
+					tp->snd_cwnd = max( tp->snd_cwnd, yeah->reno_count);
+
+					tp->snd_ssthresh = tp->snd_cwnd;
+	  		}
+
+				if (yeah->reno_count <= 2)
+					yeah->reno_count = max( tp->snd_cwnd>>1, 2U);
+				else
+					yeah->reno_count++;
+
+				yeah->doing_reno_now =
+					           min_t( u32, yeah->doing_reno_now + 1 , 0xffffff);
+			  
+			} else {
+				yeah->fast_count++;
+
+				if (yeah->fast_count > TCP_YEAH_ZETA) {
+					yeah->reno_count = 2;
+					yeah->fast_count = 0;
+				}
+
+				yeah->doing_reno_now = 0;
+			}
+
+			yeah->lastQ = queue;
+
+		}
+
+		/* Save the extent of the current window so we can use this
+		 * at the end of the next RTT.
+		 */
+		yeah->beg_snd_una  = yeah->beg_snd_nxt;
+		yeah->beg_snd_nxt  = tp->snd_nxt;
+		yeah->beg_snd_cwnd = tp->snd_cwnd;
+		
+		/* Wipe the slate clean for the next RTT. */
+		yeah->cntRTT = 0;
+		yeah->minRTT = 0x7fffffff;
+	}
+}
+
+static u32 tcp_yeah_ssthresh(struct sock *sk) {
+	const struct tcp_sock *tp = tcp_sk(sk);
+	struct yeah *yeah = inet_csk_ca(sk);
+	u32 reduction;
+
+	if (yeah->doing_reno_now < TCP_YEAH_RHO) {
+		reduction = yeah->lastQ;
+
+		reduction = min( reduction, max(tp->snd_cwnd>>1, 2U) );
+
+		reduction = max( reduction, tp->snd_cwnd >> TCP_YEAH_DELTA);
+	} else
+		reduction = max(tp->snd_cwnd>>1,2U);
+
+	yeah->fast_count = 0;
+	yeah->reno_count = max(yeah->reno_count>>1, 2U);
+
+	return tp->snd_cwnd - reduction;
+}
+
+static struct tcp_congestion_ops tcp_yeah = {
+	.init		= tcp_yeah_init,
+	.ssthresh	= tcp_yeah_ssthresh,
+	.cong_avoid	= tcp_yeah_cong_avoid,
+	.min_cwnd	= tcp_reno_min_cwnd,
+	.rtt_sample	= tcp_vegas_rtt_calc,
+	.set_state	= tcp_vegas_state,
+	.cwnd_event	= tcp_vegas_cwnd_event,
+	.get_info	= tcp_vegas_get_info,
+	.pkts_acked	= tcp_yeah_pkts_acked,
+
+	.owner		= THIS_MODULE,
+	.name		= "yeah",
+};
+
+static int __init tcp_yeah_register(void)
+{
+	BUG_ON(sizeof(struct yeah) > ICSK_CA_PRIV_SIZE);
+	tcp_register_congestion_control(&tcp_yeah);
+	return 0;
+}
+
+static void __exit tcp_yeah_unregister(void)
+{
+	tcp_unregister_congestion_control(&tcp_yeah);
+}
+
+module_init(tcp_yeah_register);
+module_exit(tcp_yeah_unregister);
+
+MODULE_AUTHOR("Angelo P. Castellani");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("YeAH TCP");
diff -uprN linux-2.6.20-a/net/ipv4/tcp_yeah.h linux-2.6.20-b/net/ipv4/tcp_yeah.h
--- linux-2.6.20-a/net/ipv4/tcp_yeah.h	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.20-b/net/ipv4/tcp_yeah.h	2007-02-19 10:52:46.000000000 +0100
@@ -0,0 +1,134 @@
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/inet_diag.h>
+
+#include <net/tcp.h>
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
+/* There are several situations when we must "re-start" Vegas:
+ *
+ *  o when a connection is established
+ *  o after an RTO
+ *  o after fast recovery
+ *  o when we send a packet and there is no outstanding
+ *    unacknowledged data (restarting an idle connection)
+ *
+ * In these circumstances we cannot do a Vegas calculation at the
+ * end of the first RTT, because any calculation we do is using
+ * stale info -- both the saved cwnd and congestion feedback are
+ * stale.
+ *
+ * Instead we must wait until the completion of an RTT during
+ * which we actually receive ACKs.
+ */
+static inline void vegas_enable(struct sock *sk)
+{
+	const struct tcp_sock *tp = tcp_sk(sk);
+	struct vegas *vegas = inet_csk_ca(sk);
+
+	/* Begin taking Vegas samples next time we send something. */
+	vegas->doing_vegas_now = 1;
+
+	/* Set the beginning of the next send window. */
+	vegas->beg_snd_nxt = tp->snd_nxt;
+
+	vegas->cntRTT = 0;
+	vegas->minRTT = 0x7fffffff;
+}
+
+/* Stop taking Vegas samples for now. */
+static inline void vegas_disable(struct sock *sk)
+{
+	struct vegas *vegas = inet_csk_ca(sk);
+
+	vegas->doing_vegas_now = 0;
+}
+
+static void tcp_vegas_init(struct sock *sk)
+{
+	struct vegas *vegas = inet_csk_ca(sk);
+
+	vegas->baseRTT = 0x7fffffff;
+	vegas_enable(sk);
+}
+
+static void tcp_vegas_state(struct sock *sk, u8 ca_state)
+{
+
+	if (ca_state == TCP_CA_Open)
+		vegas_enable(sk);
+	else
+		vegas_disable(sk);
+}
+
+/* Do RTT sampling needed for Vegas.
+ * Basically we:
+ *   o min-filter RTT samples from within an RTT to get the current
+ *     propagation delay + queuing delay (we are min-filtering to try to
+ *     avoid the effects of delayed ACKs)
+ *   o min-filter RTT samples from a much longer window (forever for now)
+ *     to find the propagation delay (baseRTT)
+ */
+static void tcp_vegas_rtt_calc(struct sock *sk, u32 usrtt)
+{
+	struct vegas *vegas = inet_csk_ca(sk);
+	u32 vrtt = usrtt + 1; /* Never allow zero rtt or baseRTT */
+
+	/* Filter to find propagation delay: */
+	if (vrtt < vegas->baseRTT)
+		vegas->baseRTT = vrtt;
+
+	/* Find the min RTT during the last RTT to find
+	 * the current prop. delay + queuing delay:
+	 */
+	vegas->minRTT = min(vegas->minRTT, vrtt);
+	vegas->cntRTT++;
+}
+
+/*
+ * If the connection is idle and we are restarting,
+ * then we don't want to do any Vegas calculations
+ * until we get fresh RTT samples.  So when we
+ * restart, we reset our Vegas state to a clean
+ * slate. After we get acks for this flight of
+ * packets, _then_ we can make Vegas calculations
+ * again.
+ */
+static void tcp_vegas_cwnd_event(struct sock *sk, enum tcp_ca_event event)
+{
+	if (event == CA_EVENT_CWND_RESTART ||
+	    event == CA_EVENT_TX_START)
+		tcp_vegas_init(sk);
+}
+
+/* Extract info for Tcp socket info provided via netlink. */
+static void tcp_vegas_get_info(struct sock *sk, u32 ext,
+			       struct sk_buff *skb)
+{
+	const struct vegas *ca = inet_csk_ca(sk);
+	if (ext & (1 << (INET_DIAG_VEGASINFO - 1))) {
+		struct tcpvegas_info *info;
+
+		info = RTA_DATA(__RTA_PUT(skb, INET_DIAG_VEGASINFO,
+					  sizeof(*info)));
+
+		info->tcpv_enabled = ca->doing_vegas_now;
+		info->tcpv_rttcnt = ca->cntRTT;
+		info->tcpv_rtt = ca->baseRTT;
+		info->tcpv_minrtt = ca->minRTT;
+	rtattr_failure:	;
+	}
+}
+
+

--------------060604090908080503010801--
