From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] TCP changes for 2.6.18
Date: Mon, 5 Jun 2006 11:03:31 -0700
Message-ID: <20060605110331.0f058738@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:60381 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751259AbWFESD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2006 14:03:29 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave, please consider adding these for the 2.6.18.


The following changes since commit 672c6108a51bf559d19595d9f8193dfd81f0f752:
  Linus Torvalds:
        Merge master.kernel.org:/.../jejb/scsi-rc-fixes-2.6

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/tcp-2.6.git

Angelo P. Castellani:
      TCP Compound congestion control

Bin Zhou:
      TCP Veno congestion control

Stephen Hemminger:
      TCP Compound quad root function
      TCP minimum congestion window consolidation
      TCP Probe congestion window tracing
      TCP Limited slow start for Highspeed TCP

Wong Edison:
      TCP Low Priority congestion control

 include/net/tcp.h        |    4 
 net/Kconfig              |   15 ++
 net/ipv4/Kconfig         |   32 +++
 net/ipv4/Makefile        |    4 
 net/ipv4/tcp_bic.c       |    7 -
 net/ipv4/tcp_compound.c  |  448 ++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_cong.c      |    6 -
 net/ipv4/tcp_cubic.c     |    6 -
 net/ipv4/tcp_highspeed.c |   24 ++
 net/ipv4/tcp_htcp.c      |    9 -
 net/ipv4/tcp_input.c     |   13 +
 net/ipv4/tcp_lp.c        |  338 +++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_probe.c     |  179 ++++++++++++++++++
 net/ipv4/tcp_veno.c      |  231 ++++++++++++++++++++++++
 net/ipv4/tcp_westwood.c  |   18 +-
 15 files changed, 1291 insertions(+), 43 deletions(-)
 create mode 100644 net/ipv4/tcp_compound.c
 create mode 100644 net/ipv4/tcp_lp.c
 create mode 100644 net/ipv4/tcp_probe.c
 create mode 100644 net/ipv4/tcp_veno.c



diff --git a/include/net/tcp.h b/include/net/tcp.h
index 3c989db..575636f 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -628,7 +628,7 @@ struct tcp_congestion_ops {
 	/* return slow start threshold (required) */
 	u32 (*ssthresh)(struct sock *sk);
 	/* lower bound for congestion window (optional) */
-	u32 (*min_cwnd)(struct sock *sk);
+	u32 (*min_cwnd)(const struct sock *sk);
 	/* do new cwnd calculation (required) */
 	void (*cong_avoid)(struct sock *sk, u32 ack,
 			   u32 rtt, u32 in_flight, int good_ack);
@@ -663,7 +663,7 @@ extern struct tcp_congestion_ops tcp_ini
 extern u32 tcp_reno_ssthresh(struct sock *sk);
 extern void tcp_reno_cong_avoid(struct sock *sk, u32 ack,
 				u32 rtt, u32 in_flight, int flag);
-extern u32 tcp_reno_min_cwnd(struct sock *sk);
+extern u32 tcp_reno_min_cwnd(const struct sock *sk);
 extern struct tcp_congestion_ops tcp_reno;
 
 static inline void tcp_set_ca_state(struct sock *sk, const u8 ca_state)
diff --git a/net/Kconfig b/net/Kconfig
index 4193cdc..ff0db80 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -215,6 +215,21 @@ config NET_PKTGEN
 	  To compile this code as a module, choose M here: the
 	  module will be called pktgen.
 
+config NET_TCPPROBE
+	tristate "TCP connection probing"
+	depends on INET && EXPERIMENTAL && PROC_FS && KPROBES
+	---help---
+	This module allows for capturing the changes to TCP connection
+	state in response to incoming patckets. It is used for debugging
+	TCP congestion avoidance modules. If you don't understand
+	what was just said, you don't need it: say N.
+
+	Documentation on how to use the packet generator can be found
+	at http://linux-net.osdl.org/index.php/TcpProbe
+
+	To compile this code as a module, choose M here: the
+	module will be called tcp_probe.
+
 endmenu
 
 endmenu
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index e40f753..2032411 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -532,6 +532,38 @@ config TCP_CONG_SCALABLE
 	properties, though is known to have fairness issues.
 	See http://www-lce.eng.cam.ac.uk/~ctk21/scalable/
 
+config TCP_CONG_LP
+	tristate "TCP Low Priority"
+	depends on EXPERIMENTAL
+	default n
+	---help---
+	TCP Low Priority (TCP-LP), a distributed algorithm whose goal is
+	to utiliza only the excess network bandwidth as compared to the
+	``fair share`` of bandwidth as targeted by TCP.
+	See http://www-ece.rice.edu/networks/TCP-LP/
+
+config TCP_CONG_VENO
+	tristate "TCP Veno"
+	depends on EXPERIMENTAL
+	default n
+	---help---
+	TCP Veno is a sender-side only enhancement of TCP to obtain better
+	throughput over wireless networks. TCP Veno makes use of state
+	distinguishing to circumvent the difficult judgment of the packet loss
+	type. TCP Veno cuts down less congestion window in response to random
+	loss packets.
+	See http://www.ntu.edu.sg/home5/ZHOU0022/papers/CPFu03a.pdf
+
+config TCP_CONG_COMPOUND
+	tristate "TCP Compound"
+	depends on EXPERIMENTAL
+	default n
+	---help---
+	TCP Compound is a sender-side only change to TCP that uses
+	a mixed Reno/Vegas approach to calculate the cwnd.
+	For further details look here:
+	  ftp://ftp.research.microsoft.com/pub/tr/TR-2005-86.pdf
+
 endmenu
 
 config TCP_CONG_BIC
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 9ef50a0..ac7eb0e 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -34,6 +34,7 @@ obj-$(CONFIG_IP_VS) += ipvs/
 obj-$(CONFIG_INET_DIAG) += inet_diag.o 
 obj-$(CONFIG_IP_ROUTE_MULTIPATH_CACHED) += multipath.o
 obj-$(CONFIG_INET_TCP_DIAG) += tcp_diag.o
+obj-$(CONFIG_NET_TCPPROBE) += tcp_probe.o
 obj-$(CONFIG_TCP_CONG_BIC) += tcp_bic.o
 obj-$(CONFIG_TCP_CONG_CUBIC) += tcp_cubic.o
 obj-$(CONFIG_TCP_CONG_WESTWOOD) += tcp_westwood.o
@@ -41,7 +42,10 @@ obj-$(CONFIG_TCP_CONG_HSTCP) += tcp_high
 obj-$(CONFIG_TCP_CONG_HYBLA) += tcp_hybla.o
 obj-$(CONFIG_TCP_CONG_HTCP) += tcp_htcp.o
 obj-$(CONFIG_TCP_CONG_VEGAS) += tcp_vegas.o
+obj-$(CONFIG_TCP_CONG_VENO) += tcp_veno.o
 obj-$(CONFIG_TCP_CONG_SCALABLE) += tcp_scalable.o
+obj-$(CONFIG_TCP_CONG_LP) += tcp_lp.o
+obj-$(CONFIG_TCP_CONG_COMPOUND) += tcp_compound.o
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
 		      xfrm4_output.o
diff --git a/net/ipv4/tcp_bic.c b/net/ipv4/tcp_bic.c
index 035f209..b2d9021 100644
--- a/net/ipv4/tcp_bic.c
+++ b/net/ipv4/tcp_bic.c
@@ -198,12 +198,6 @@ static u32 bictcp_undo_cwnd(struct sock 
 	return max(tp->snd_cwnd, ca->last_max_cwnd);
 }
 
-static u32 bictcp_min_cwnd(struct sock *sk)
-{
-	const struct tcp_sock *tp = tcp_sk(sk);
-	return tp->snd_ssthresh;
-}
-
 static void bictcp_state(struct sock *sk, u8 new_state)
 {
 	if (new_state == TCP_CA_Loss)
@@ -231,7 +225,6 @@ static struct tcp_congestion_ops bictcp 
 	.cong_avoid	= bictcp_cong_avoid,
 	.set_state	= bictcp_state,
 	.undo_cwnd	= bictcp_undo_cwnd,
-	.min_cwnd	= bictcp_min_cwnd,
 	.pkts_acked     = bictcp_acked,
 	.owner		= THIS_MODULE,
 	.name		= "bic",
diff --git a/net/ipv4/tcp_compound.c b/net/ipv4/tcp_compound.c
new file mode 100644
index 0000000..bc54f7e
--- /dev/null
+++ b/net/ipv4/tcp_compound.c
@@ -0,0 +1,448 @@
+/*
+ * TCP Vegas congestion control
+ *
+ * This is based on the congestion detection/avoidance scheme described in
+ *    Lawrence S. Brakmo and Larry L. Peterson.
+ *    "TCP Vegas: End to end congestion avoidance on a global internet."
+ *    IEEE Journal on Selected Areas in Communication, 13(8):1465--1480,
+ *    October 1995. Available from:
+ *	ftp://ftp.cs.arizona.edu/xkernel/Papers/jsac.ps
+ *
+ * See http://www.cs.arizona.edu/xkernel/ for their implementation.
+ * The main aspects that distinguish this implementation from the
+ * Arizona Vegas implementation are:
+ *   o We do not change the loss detection or recovery mechanisms of
+ *     Linux in any way. Linux already recovers from losses quite well,
+ *     using fine-grained timers, NewReno, and FACK.
+ *   o To avoid the performance penalty imposed by increasing cwnd
+ *     only every-other RTT during slow start, we increase during
+ *     every RTT during slow start, just like Reno.
+ *   o Largely to allow continuous cwnd growth during slow start,
+ *     we use the rate at which ACKs come back as the "actual"
+ *     rate, rather than the rate at which data is sent.
+ *   o To speed convergence to the right rate, we set the cwnd
+ *     to achieve the right ("actual") rate when we exit slow start.
+ *   o To filter out the noise caused by delayed ACKs, we use the
+ *     minimum RTT sample observed during the last RTT to calculate
+ *     the actual rate.
+ *   o When the sender re-starts from idle, it waits until it has
+ *     received ACKs for an entire flight of new data before making
+ *     a cwnd adjustment decision. The original Vegas implementation
+ *     assumed senders never went idle.
+ *
+ *
+ *   TCP Compound based on TCP Vegas
+ *
+ *   further details can be found here:
+ *      ftp://ftp.research.microsoft.com/pub/tr/TR-2005-86.pdf
+ */
+
+#include <linux/config.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/inet_diag.h>
+
+#include <net/tcp.h>
+
+/* Default values of the Vegas variables, in fixed-point representation
+ * with V_PARAM_SHIFT bits to the right of the binary point.
+ */
+#define V_PARAM_SHIFT 1
+
+#define TCP_COMPOUND_ALPHA          3U
+#define TCP_COMPOUND_BETA           1U
+#define TCP_COMPOUND_GAMMA         30
+#define TCP_COMPOUND_ZETA           1
+
+/* TCP compound variables */
+struct compound {
+	u32 beg_snd_nxt;	/* right edge during last RTT */
+	u32 beg_snd_una;	/* left edge  during last RTT */
+	u32 beg_snd_cwnd;	/* saves the size of the cwnd */
+	u8 doing_vegas_now;	/* if true, do vegas for this RTT */
+	u16 cntRTT;		/* # of RTTs measured within last RTT */
+	u32 minRTT;		/* min of RTTs measured within last RTT (in usec) */
+	u32 baseRTT;		/* the min of all Vegas RTT measurements seen (in usec) */
+
+	u32 cwnd;
+	u32 dwnd;
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
+	struct compound *vegas = inet_csk_ca(sk);
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
+	struct compound *vegas = inet_csk_ca(sk);
+
+	vegas->doing_vegas_now = 0;
+}
+
+static void tcp_compound_init(struct sock *sk)
+{
+	struct compound *vegas = inet_csk_ca(sk);
+	const struct tcp_sock *tp = tcp_sk(sk);
+
+	vegas->baseRTT = 0x7fffffff;
+	vegas_enable(sk);
+
+	vegas->dwnd = 0;
+	vegas->cwnd = tp->snd_cwnd;
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
+static void tcp_compound_rtt_calc(struct sock *sk, u32 usrtt)
+{
+	struct compound *vegas = inet_csk_ca(sk);
+	u32 vrtt = usrtt + 1;	/* Never allow zero rtt or baseRTT */
+
+	/* Filter to find propagation delay: */
+	if (vrtt < vegas->baseRTT)
+		vegas->baseRTT = vrtt;
+
+	/* Find the min RTT during the last RTT to find
+	 * the current prop. delay + queuing delay:
+	 */
+
+	vegas->minRTT = min(vegas->minRTT, vrtt);
+	vegas->cntRTT++;
+}
+
+static void tcp_compound_state(struct sock *sk, u8 ca_state)
+{
+
+	if (ca_state == TCP_CA_Open)
+		vegas_enable(sk);
+	else
+		vegas_disable(sk);
+}
+
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
+/* calculate the quartic root of "a" using Newton-Raphson */
+static u32 qroot(u64 a)
+{
+	u32 x, x1;
+
+	/* Initial estimate is based on:
+	 * qrt(x) = exp(log(x) / 4)
+	 */
+	x = 1u << (fls64(a) >> 2);
+
+	/*
+	 * Iteration based on:
+	 *                         3
+	 * x    = ( 3 * x  +  a / x  ) / 4
+	 *  k+1          k         k
+	 */
+	do {
+		u64 x3 = x;
+
+		x1 = x;
+		x3 *= x;
+		x3 *= x;
+
+		x = (3 * x + (u32) div64_64(a, x3)) / 4;
+	} while (abs(x1 - x) > 1);
+
+	return x;
+}
+
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
+static void tcp_compound_cwnd_event(struct sock *sk, enum tcp_ca_event event)
+{
+	if (event == CA_EVENT_CWND_RESTART || event == CA_EVENT_TX_START)
+		tcp_compound_init(sk);
+}
+
+static void tcp_compound_cong_avoid(struct sock *sk, u32 ack,
+				    u32 seq_rtt, u32 in_flight, int flag)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct compound *vegas = inet_csk_ca(sk);
+	u8 inc = 0;
+
+	if (vegas->cwnd + vegas->dwnd > tp->snd_cwnd) {
+		if (vegas->cwnd > tp->snd_cwnd || vegas->dwnd > tp->snd_cwnd) {
+			vegas->cwnd = tp->snd_cwnd;
+			vegas->dwnd = 0;
+		} else
+			vegas->cwnd = tp->snd_cwnd - vegas->dwnd;
+
+	}
+
+	if (!tcp_is_cwnd_limited(sk, in_flight))
+		return;
+
+	if (vegas->cwnd <= tp->snd_ssthresh)
+		inc = 1;
+	else if (tp->snd_cwnd_cnt < tp->snd_cwnd)
+		tp->snd_cwnd_cnt++;
+
+	if (tp->snd_cwnd_cnt >= tp->snd_cwnd) {
+		inc = 1;
+		tp->snd_cwnd_cnt = 0;
+	}
+
+	if (inc && tp->snd_cwnd < tp->snd_cwnd_clamp)
+		vegas->cwnd++;
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
+	 * don't line up nicely with the boundaries of RTTs.
+	 *
+	 * Another unfortunate fact of life is that delayed ACKs delay the
+	 * advance of the left edge of our send window, so that the number
+	 * of bytes we send in an RTT is often less than our cwnd will allow.
+	 * So we keep track of our cwnd separately, in v_beg_snd_cwnd.
+	 */
+
+	if (after(ack, vegas->beg_snd_nxt)) {
+		/* Do the Vegas once-per-RTT cwnd adjustment. */
+		u32 old_wnd, old_snd_cwnd;
+
+		/* Here old_wnd is essentially the window of data that was
+		 * sent during the previous RTT, and has all
+		 * been acknowledged in the course of the RTT that ended
+		 * with the ACK we just received. Likewise, old_snd_cwnd
+		 * is the cwnd during the previous RTT.
+		 */
+		if (!tp->mss_cache)
+			return;
+
+		old_wnd = (vegas->beg_snd_nxt - vegas->beg_snd_una) /
+		    tp->mss_cache;
+		old_snd_cwnd = vegas->beg_snd_cwnd;
+
+		/* Save the extent of the current window so we can use this
+		 * at the end of the next RTT.
+		 */
+		vegas->beg_snd_una = vegas->beg_snd_nxt;
+		vegas->beg_snd_nxt = tp->snd_nxt;
+		vegas->beg_snd_cwnd = tp->snd_cwnd;
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
+		if (vegas->cntRTT > 2) {
+			u32 rtt, target_cwnd, diff;
+			u32 brtt, dwnd;
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
+			rtt = vegas->minRTT;
+
+			/* Calculate the cwnd we should have, if we weren't
+			 * going too fast.
+			 *
+			 * This is:
+			 *     (actual rate in segments) * baseRTT
+			 * We keep it as a fixed point number with
+			 * V_PARAM_SHIFT bits to the right of the binary point.
+			 */
+			if (!rtt)
+				return;
+
+			brtt = vegas->baseRTT;
+			target_cwnd = ((old_wnd * brtt)
+				       << V_PARAM_SHIFT) / rtt;
+
+			/* Calculate the difference between the window we had,
+			 * and the window we would like to have. This quantity
+			 * is the "Diff" from the Arizona Vegas papers.
+			 *
+			 * Again, this is a fixed point number with
+			 * V_PARAM_SHIFT bits to the right of the binary
+			 * point.
+			 */
+
+			diff = (old_wnd << V_PARAM_SHIFT) - target_cwnd;
+
+			dwnd = vegas->dwnd;
+
+			if (diff < (TCP_COMPOUND_GAMMA << V_PARAM_SHIFT)) {
+				u64 v;
+				u32 x;
+
+				/*
+				 * The TCP Compound paper describes the choice
+				 * of "k" determines the agressiveness,
+				 * ie. slope of the response function.
+				 *
+				 * For same value as HSTCP would be 0.8
+				 * but for computaional reasons, both the
+				 * original authors and this implementation
+				 * use 0.75.
+				 */
+				v = old_wnd;
+				x = qroot(v * v * v) >> TCP_COMPOUND_ALPHA;
+				if (x > 1)
+					dwnd = x - 1;
+				else
+					dwnd = 0;
+
+				dwnd += vegas->dwnd;
+
+			} else if ((dwnd << V_PARAM_SHIFT) <
+				   (diff * TCP_COMPOUND_BETA))
+				dwnd = 0;
+			else
+				dwnd =
+				    ((dwnd << V_PARAM_SHIFT) -
+				     (diff *
+				      TCP_COMPOUND_BETA)) >> V_PARAM_SHIFT;
+
+			vegas->dwnd = dwnd;
+
+		}
+
+		/* Wipe the slate clean for the next RTT. */
+		vegas->cntRTT = 0;
+		vegas->minRTT = 0x7fffffff;
+	}
+
+	tp->snd_cwnd = vegas->cwnd + vegas->dwnd;
+}
+
+/* Extract info for Tcp socket info provided via netlink. */
+static void tcp_compound_get_info(struct sock *sk, u32 ext, struct sk_buff *skb)
+{
+	const struct compound *ca = inet_csk_ca(sk);
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
+	rtattr_failure:;
+	}
+}
+
+static struct tcp_congestion_ops tcp_compound = {
+	.init		= tcp_compound_init,
+	.ssthresh	= tcp_reno_ssthresh,
+	.cong_avoid	= tcp_compound_cong_avoid,
+	.rtt_sample	= tcp_compound_rtt_calc,
+	.set_state	= tcp_compound_state,
+	.cwnd_event	= tcp_compound_cwnd_event,
+	.get_info	= tcp_compound_get_info,
+
+	.owner		= THIS_MODULE,
+	.name		= "compound",
+};
+
+static int __init tcp_compound_register(void)
+{
+	BUG_ON(sizeof(struct compound) > ICSK_CA_PRIV_SIZE);
+	tcp_register_congestion_control(&tcp_compound);
+	return 0;
+}
+
+static void __exit tcp_compound_unregister(void)
+{
+	tcp_unregister_congestion_control(&tcp_compound);
+}
+
+module_init(tcp_compound_register);
+module_exit(tcp_compound_unregister);
+
+MODULE_AUTHOR("Angelo P. Castellani, Stephen Hemminger");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("TCP Compound");
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 91c2f41..857eefc 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -38,7 +38,7 @@ int tcp_register_congestion_control(stru
 	int ret = 0;
 
 	/* all algorithms must implement ssthresh and cong_avoid ops */
-	if (!ca->ssthresh || !ca->cong_avoid || !ca->min_cwnd) {
+	if (!ca->ssthresh || !ca->cong_avoid) {
 		printk(KERN_ERR "TCP %s does not implement required ops\n",
 		       ca->name);
 		return -EINVAL;
@@ -251,8 +251,8 @@ u32 tcp_reno_ssthresh(struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(tcp_reno_ssthresh);
 
-/* Lower bound on congestion window. */
-u32 tcp_reno_min_cwnd(struct sock *sk)
+/* Lower bound on congestion window with halving. */
+u32 tcp_reno_min_cwnd(const struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	return tp->snd_ssthresh/2;
diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
index 31a4986..78b7a6b 100644
--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -325,11 +325,6 @@ static u32 bictcp_undo_cwnd(struct sock 
 	return max(tcp_sk(sk)->snd_cwnd, ca->last_max_cwnd);
 }
 
-static u32 bictcp_min_cwnd(struct sock *sk)
-{
-	return tcp_sk(sk)->snd_ssthresh;
-}
-
 static void bictcp_state(struct sock *sk, u8 new_state)
 {
 	if (new_state == TCP_CA_Loss)
@@ -357,7 +352,6 @@ static struct tcp_congestion_ops cubictc
 	.cong_avoid	= bictcp_cong_avoid,
 	.set_state	= bictcp_state,
 	.undo_cwnd	= bictcp_undo_cwnd,
-	.min_cwnd	= bictcp_min_cwnd,
 	.pkts_acked     = bictcp_acked,
 	.owner		= THIS_MODULE,
 	.name		= "cubic",
diff --git a/net/ipv4/tcp_highspeed.c b/net/ipv4/tcp_highspeed.c
index ba7c63c..1120245 100644
--- a/net/ipv4/tcp_highspeed.c
+++ b/net/ipv4/tcp_highspeed.c
@@ -98,6 +98,10 @@ struct hstcp {
 	u32	ai;
 };
 
+static int max_ssthresh = 100;
+module_param(max_ssthresh, int, 0644);
+MODULE_PARM_DESC(max_ssthresh, "limited slow start threshold (RFC3742)");
+
 static void hstcp_init(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -119,9 +123,23 @@ static void hstcp_cong_avoid(struct sock
 	if (!tcp_is_cwnd_limited(sk, in_flight))
 		return;
 
-	if (tp->snd_cwnd <= tp->snd_ssthresh)
-		tcp_slow_start(tp);
-	else {
+	if (tp->snd_cwnd <= tp->snd_ssthresh) {
+		/* RFC3742: limited slow start
+		 * the window is increased by 1/K MSS for each arriving ACK,
+		 * for K = int(cwnd/(0.5 max_ssthresh))
+		 */
+		if (max_ssthresh > 0 && tp->snd_cwnd > max_ssthresh) {
+			u32 k = max(tp->snd_cwnd / (max_ssthresh >> 1), 1U);
+			if (++tp->snd_cwnd_cnt >= k) {
+				if (tp->snd_cwnd < tp->snd_cwnd_clamp)
+					tp->snd_cwnd++;
+				tp->snd_cwnd_cnt = 0;
+			}
+		} else {
+			if (tp->snd_cwnd < tp->snd_cwnd_clamp)
+				tp->snd_cwnd++;
+		}
+	} else {
 		/* Update AIMD parameters */
 		if (tp->snd_cwnd > hstcp_aimd_vals[ca->ai].cwnd) {
 			while (tp->snd_cwnd > hstcp_aimd_vals[ca->ai].cwnd &&
diff --git a/net/ipv4/tcp_htcp.c b/net/ipv4/tcp_htcp.c
index 1b2ff53..3d92c18 100644
--- a/net/ipv4/tcp_htcp.c
+++ b/net/ipv4/tcp_htcp.c
@@ -246,14 +246,6 @@ static void htcp_cong_avoid(struct sock 
 	}
 }
 
-/* Lower bound on congestion window. */
-static u32 htcp_min_cwnd(struct sock *sk)
-{
-	const struct tcp_sock *tp = tcp_sk(sk);
-	return tp->snd_ssthresh;
-}
-
-
 static void htcp_init(struct sock *sk)
 {
 	struct htcp *ca = inet_csk_ca(sk);
@@ -285,7 +277,6 @@ static void htcp_state(struct sock *sk, 
 static struct tcp_congestion_ops htcp = {
 	.init		= htcp_init,
 	.ssthresh	= htcp_recalc_ssthresh,
-	.min_cwnd	= htcp_min_cwnd,
 	.cong_avoid	= htcp_cong_avoid,
 	.set_state	= htcp_state,
 	.undo_cwnd	= htcp_cwnd_undo,
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 4a538bc..718d0f2 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1690,17 +1690,26 @@ static inline void tcp_moderate_cwnd(str
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
+/* Lower bound on congestion window is slow start threshold
+ * unless congestion avoidance choice decides to overide it.
+ */
+static inline u32 tcp_cwnd_min(const struct sock *sk)
+{
+	const struct tcp_congestion_ops *ca_ops = inet_csk(sk)->icsk_ca_ops;
+
+	return ca_ops->min_cwnd ? ca_ops->min_cwnd(sk) : tcp_sk(sk)->snd_ssthresh;
+}
+
 /* Decrease cwnd each second ack. */
 static void tcp_cwnd_down(struct sock *sk)
 {
-	const struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	int decr = tp->snd_cwnd_cnt + 1;
 
 	tp->snd_cwnd_cnt = decr&1;
 	decr >>= 1;
 
-	if (decr && tp->snd_cwnd > icsk->icsk_ca_ops->min_cwnd(sk))
+	if (decr && tp->snd_cwnd > tcp_cwnd_min(sk))
 		tp->snd_cwnd -= decr;
 
 	tp->snd_cwnd = min(tp->snd_cwnd, tcp_packets_in_flight(tp)+1);
diff --git a/net/ipv4/tcp_lp.c b/net/ipv4/tcp_lp.c
new file mode 100644
index 0000000..1f977b6
--- /dev/null
+++ b/net/ipv4/tcp_lp.c
@@ -0,0 +1,338 @@
+/*
+ * TCP Low Priority (TCP-LP)
+ *
+ * TCP Low Priority is a distributed algorithm whose goal is to utilize only
+ *   the excess network bandwidth as compared to the ``fair share`` of
+ *   bandwidth as targeted by TCP. Available from:
+ *     http://www.ece.rice.edu/~akuzma/Doc/akuzma/TCP-LP.pdf
+ *
+ * Original Author:
+ *   Aleksandar Kuzmanovic <akuzma@northwestern.edu>
+ *
+ * See http://www-ece.rice.edu/networks/TCP-LP/ for their implementation.
+ * As of 2.6.13, Linux supports pluggable congestion control algorithms.
+ * Due to the limitation of the API, we take the following changes from
+ * the original TCP-LP implementation:
+ *   o We use newReno in most core CA handling. Only add some checking
+ *     within cong_avoid.
+ *   o Error correcting in remote HZ, therefore remote HZ will be keeped
+ *     on checking and updating.
+ *   o Handling calculation of One-Way-Delay (OWD) within rtt_sample, sicne
+ *     OWD have a similar meaning as RTT. Also correct the buggy formular.
+ *   o Handle reaction for Early Congestion Indication (ECI) within
+ *     pkts_acked, as mentioned within pseudo code.
+ *   o OWD is handled in relative format, where local time stamp will in
+ *     tcp_time_stamp format.
+ *
+ * Port from 2.4.19 to 2.6.16 as module by:
+ *   Wong Hoi Sing Edison <hswong3i@gmail.com>
+ *   Hung Hing Lun <hlhung3i@gmail.com>
+ *
+ * Version: $Id: tcp_lp.c,v 1.22 2006-05-02 18:18:19 hswong3i Exp $
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <net/tcp.h>
+
+/* resolution of owd */
+#define LP_RESOL       1000
+
+/**
+ * enum tcp_lp_state
+ * @LP_VALID_RHZ: is remote HZ valid?
+ * @LP_VALID_OWD: is OWD valid?
+ * @LP_WITHIN_THR: are we within threshold?
+ * @LP_WITHIN_INF: are we within inference?
+ *
+ * TCP-LP's state flags.
+ * We create this set of state flag mainly for debugging.
+ */
+enum tcp_lp_state {
+	LP_VALID_RHZ = (1 << 0),
+	LP_VALID_OWD = (1 << 1),
+	LP_WITHIN_THR = (1 << 3),
+	LP_WITHIN_INF = (1 << 4),
+};
+
+/**
+ * struct lp
+ * @flag: TCP-LP state flag
+ * @sowd: smoothed OWD << 3
+ * @owd_min: min OWD
+ * @owd_max: max OWD
+ * @owd_max_rsv: resrved max owd
+ * @remote_hz: estimated remote HZ
+ * @remote_ref_time: remote reference time
+ * @local_ref_time: local reference time
+ * @last_drop: time for last active drop
+ * @inference: current inference
+ *
+ * TCP-LP's private struct.
+ * We get the idea from original TCP-LP implementation where only left those we
+ * found are really useful.
+ */
+struct lp {
+	u32 flag;
+	u32 sowd;
+	u32 owd_min;
+	u32 owd_max;
+	u32 owd_max_rsv;
+	u32 remote_hz;
+	u32 remote_ref_time;
+	u32 local_ref_time;
+	u32 last_drop;
+	u32 inference;
+};
+
+/**
+ * tcp_lp_init
+ *
+ * Init all required variables.
+ * Clone the handling from Vegas module implementation.
+ */
+static void tcp_lp_init(struct sock *sk)
+{
+	struct lp *lp = inet_csk_ca(sk);
+
+	lp->flag = 0;
+	lp->sowd = 0;
+	lp->owd_min = 0xffffffff;
+	lp->owd_max = 0;
+	lp->owd_max_rsv = 0;
+	lp->remote_hz = 0;
+	lp->remote_ref_time = 0;
+	lp->local_ref_time = 0;
+	lp->last_drop = 0;
+	lp->inference = 0;
+}
+
+/**
+ * tcp_lp_cong_avoid
+ *
+ * Implementation of cong_avoid.
+ * Will only call newReno CA when away from inference.
+ * From TCP-LP's paper, this will be handled in additive increasement.
+ */
+static void tcp_lp_cong_avoid(struct sock *sk, u32 ack, u32 rtt, u32 in_flight,
+			      int flag)
+{
+	struct lp *lp = inet_csk_ca(sk);
+
+	if (!(lp->flag & LP_WITHIN_INF))
+		tcp_reno_cong_avoid(sk, ack, rtt, in_flight, flag);
+}
+
+/**
+ * tcp_lp_remote_hz_estimator
+ *
+ * Estimate remote HZ.
+ * We keep on updating the estimated value, where original TCP-LP
+ * implementation only guest it for once and use forever.
+ */
+static u32 tcp_lp_remote_hz_estimator(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct lp *lp = inet_csk_ca(sk);
+	s64 rhz = lp->remote_hz << 6;	/* remote HZ << 6 */
+	s64 m = 0;
+
+	/* not yet record reference time
+	 * go away!! record it before come back!! */
+	if (lp->remote_ref_time == 0 || lp->local_ref_time == 0)
+		goto out;
+
+	/* we can't calc remote HZ with no different!! */
+	if (tp->rx_opt.rcv_tsval == lp->remote_ref_time
+	    || tp->rx_opt.rcv_tsecr == lp->local_ref_time)
+		goto out;
+
+	m = HZ * (tp->rx_opt.rcv_tsval -
+		  lp->remote_ref_time) / (tp->rx_opt.rcv_tsecr -
+					  lp->local_ref_time);
+	if (m < 0)
+		m = -m;
+
+	if (rhz != 0) {
+		m -= rhz >> 6;	/* m is now error in remote HZ est */
+		rhz += m;	/* 63/64 old + 1/64 new */
+	} else
+		rhz = m << 6;
+
+	/* record time for successful remote HZ calc */
+	lp->flag |= LP_VALID_RHZ;
+
+ out:
+	/* record reference time stamp */
+	lp->remote_ref_time = tp->rx_opt.rcv_tsval;
+	lp->local_ref_time = tp->rx_opt.rcv_tsecr;
+
+	return rhz >> 6;
+}
+
+/**
+ * tcp_lp_owd_calculator
+ *
+ * Calculate one way delay (in relative format).
+ * Original implement OWD as minus of remote time difference to local time
+ * difference directly. As this time difference just simply equal to RTT, when
+ * the network status is stable, remote RTT will equal to local RTT, and result
+ * OWD into zero.
+ * It seems to be a bug and so we fixed it.
+ */
+static u32 tcp_lp_owd_calculator(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct lp *lp = inet_csk_ca(sk);
+	s64 owd = 0;
+
+	lp->remote_hz = tcp_lp_remote_hz_estimator(sk);
+
+	if (lp->flag & LP_VALID_RHZ) {
+		owd =
+		    tp->rx_opt.rcv_tsval * (LP_RESOL / lp->remote_hz) -
+		    tp->rx_opt.rcv_tsecr * (LP_RESOL / HZ);
+		if (owd < 0)
+			owd = -owd;
+	}
+
+	if (owd > 0)
+		lp->flag |= LP_VALID_OWD;
+	else
+		lp->flag &= ~LP_VALID_OWD;
+
+	return owd;
+}
+
+/**
+ * tcp_lp_rtt_sample
+ *
+ * Implementation or rtt_sample.
+ * Will take the following action,
+ *   1. calc OWD,
+ *   2. record the min/max OWD,
+ *   3. calc smoothed OWD (SOWD).
+ * Most ideas come from the original TCP-LP implementation.
+ */
+static void tcp_lp_rtt_sample(struct sock *sk, u32 usrtt)
+{
+	struct lp *lp = inet_csk_ca(sk);
+	s64 mowd = tcp_lp_owd_calculator(sk);
+
+	/* sorry that we don't have valid data */
+	if (!(lp->flag & LP_VALID_RHZ) || !(lp->flag & LP_VALID_OWD))
+		return;
+
+	/* record the next min owd */
+	if (mowd < lp->owd_min)
+		lp->owd_min = mowd;
+
+	/* always forget the max of the max
+	 * we just set owd_max as one below it */
+	if (mowd > lp->owd_max) {
+		if (mowd > lp->owd_max_rsv) {
+			if (lp->owd_max_rsv == 0)
+				lp->owd_max = mowd;
+			else
+				lp->owd_max = lp->owd_max_rsv;
+			lp->owd_max_rsv = mowd;
+		} else
+			lp->owd_max = mowd;
+	}
+
+	/* calc for smoothed owd */
+	if (lp->sowd != 0) {
+		mowd -= lp->sowd >> 3;	/* m is now error in owd est */
+		lp->sowd += mowd;	/* owd = 7/8 owd + 1/8 new */
+	} else
+		lp->sowd = mowd << 3;	/* take the measured time be owd */
+}
+
+/**
+ * tcp_lp_pkts_acked
+ *
+ * Implementation of pkts_acked.
+ * Deal with active drop under Early Congestion Indication.
+ * Only drop to half and 1 will be handle, because we hope to use back
+ * newReno in increase case.
+ * We work it out by following the idea from TCP-LP's paper directly
+ */
+static void tcp_lp_pkts_acked(struct sock *sk, u32 num_acked)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct lp *lp = inet_csk_ca(sk);
+
+	/* calc inference */
+	if (tcp_time_stamp > tp->rx_opt.rcv_tsecr)
+		lp->inference = 3 * (tcp_time_stamp - tp->rx_opt.rcv_tsecr);
+
+	/* test if within inference */
+	if (lp->last_drop && (tcp_time_stamp - lp->last_drop < lp->inference))
+		lp->flag |= LP_WITHIN_INF;
+	else
+		lp->flag &= ~LP_WITHIN_INF;
+
+	/* test if within threshold */
+	if (lp->sowd >> 3 <
+	    lp->owd_min + 15 * (lp->owd_max - lp->owd_min) / 100)
+		lp->flag |= LP_WITHIN_THR;
+	else
+		lp->flag &= ~LP_WITHIN_THR;
+
+	pr_debug("TCP-LP: %05o|%5u|%5u|%15u|%15u|%15u\n", lp->flag,
+		 tp->snd_cwnd, lp->remote_hz, lp->owd_min, lp->owd_max,
+		 lp->sowd >> 3);
+
+	if (lp->flag & LP_WITHIN_THR)
+		return;
+
+	/* FIXME: try to reset owd_min and owd_max here
+	 * so decrease the chance the min/max is no longer suitable
+	 * and will usually within threshold when whithin inference */
+	lp->owd_min = lp->sowd >> 3;
+	lp->owd_max = lp->sowd >> 2;
+	lp->owd_max_rsv = lp->sowd >> 2;
+
+	/* happened within inference
+	 * drop snd_cwnd into 1 */
+	if (lp->flag & LP_WITHIN_INF)
+		tp->snd_cwnd = 1U;
+
+	/* happened after inference
+	 * cut snd_cwnd into half */
+	else
+		tp->snd_cwnd = max(tp->snd_cwnd >> 1U, 1U);
+
+	/* record this drop time */
+	lp->last_drop = tcp_time_stamp;
+}
+
+static struct tcp_congestion_ops tcp_lp = {
+	.init = tcp_lp_init,
+	.ssthresh = tcp_reno_ssthresh,
+	.cong_avoid = tcp_lp_cong_avoid,
+	.min_cwnd = tcp_reno_min_cwnd,
+	.rtt_sample = tcp_lp_rtt_sample,
+	.pkts_acked = tcp_lp_pkts_acked,
+
+	.owner = THIS_MODULE,
+	.name = "lp"
+};
+
+static int __init tcp_lp_register(void)
+{
+	BUG_ON(sizeof(struct lp) > ICSK_CA_PRIV_SIZE);
+	return tcp_register_congestion_control(&tcp_lp);
+}
+
+static void __exit tcp_lp_unregister(void)
+{
+	tcp_unregister_congestion_control(&tcp_lp);
+}
+
+module_init(tcp_lp_register);
+module_exit(tcp_lp_unregister);
+
+MODULE_AUTHOR("Wong Hoi Sing Edison, Hung Hing Lun");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("TCP Low Priority");
diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
new file mode 100644
index 0000000..be94d52
--- /dev/null
+++ b/net/ipv4/tcp_probe.c
@@ -0,0 +1,179 @@
+/*
+ * tcpprobe - Observe the TCP flow with kprobes.
+ *
+ * The idea for this came from Werner Almesberger's umlsim
+ * Copyright (C) 2004, Stephen Hemminger <shemminger@osdl.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#include <linux/kernel.h>
+#include <linux/kprobes.h>
+#include <linux/socket.h>
+#include <linux/tcp.h>
+#include <linux/proc_fs.h>
+#include <linux/module.h>
+#include <linux/kfifo.h>
+#include <linux/vmalloc.h>
+
+#include <net/tcp.h>
+
+MODULE_AUTHOR("Stephen Hemminger <shemminger@osdl.org>");
+MODULE_DESCRIPTION("TCP cwnd snooper");
+MODULE_LICENSE("GPL");
+
+static int port = 0;
+MODULE_PARM_DESC(port, "Port to match (0=all)");
+module_param(port, int, 0);
+
+static int bufsize = 64*1024;
+MODULE_PARM_DESC(bufsize, "Log buffer size (default 64k)");
+module_param(bufsize, int, 0);
+
+static const char procname[] = "tcpprobe";
+
+struct {
+	struct kfifo  *fifo;
+	spinlock_t    lock;
+	wait_queue_head_t wait;
+	struct timeval tstart;
+} tcpw;
+
+static void printl(const char *fmt, ...)
+{
+	va_list args;
+	int len;
+	struct timeval now;
+	char tbuf[256];
+
+	va_start(args, fmt);
+	do_gettimeofday(&now);
+
+	now.tv_sec -= tcpw.tstart.tv_sec;
+	now.tv_usec -= tcpw.tstart.tv_usec;
+	if (now.tv_usec < 0) {
+		--now.tv_sec;
+		now.tv_usec += 1000000;
+	}
+
+	len = sprintf(tbuf, "%lu.%06lu ", now.tv_sec, now.tv_usec);
+	len += vscnprintf(tbuf+len, sizeof(tbuf)-len, fmt, args);
+	va_end(args);
+
+	kfifo_put(tcpw.fifo, tbuf, len);
+	wake_up(&tcpw.wait);
+}
+
+static int jtcp_sendmsg(struct kiocb *iocb, struct sock *sk,
+			struct msghdr *msg, size_t size)
+{
+	const struct tcp_sock *tp = tcp_sk(sk);
+	const struct inet_sock *inet = inet_sk(sk);
+
+	if (port == 0 || ntohs(inet->dport) == port ||
+	    ntohs(inet->sport) == port) {
+		printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d %#x %#x %u %u %u\n",
+		       NIPQUAD(inet->saddr), ntohs(inet->sport),
+		       NIPQUAD(inet->daddr), ntohs(inet->dport),
+		       size, tp->snd_nxt, tp->snd_una,
+		       tp->snd_cwnd, tcp_current_ssthresh(sk),
+		       tp->snd_wnd);
+	}
+
+	jprobe_return();
+	return 0;
+}
+
+static struct jprobe tcp_send_probe = {
+	.kp = { .addr = (kprobe_opcode_t *) &tcp_sendmsg, },
+	.entry = (kprobe_opcode_t *) &jtcp_sendmsg,
+};
+
+
+static int tcpprobe_open(struct inode * inode, struct file * file)
+{
+	kfifo_reset(tcpw.fifo);
+	do_gettimeofday(&tcpw.tstart);
+	return 0;
+}
+
+static ssize_t tcpprobe_read(struct file *file, char __user *buf,
+			     size_t len, loff_t *ppos)
+{
+	int error = 0, cnt;
+	unsigned char *tbuf;
+
+	if (!buf || len < 0)
+		return -EINVAL;
+
+	if (len == 0)
+		return 0;
+
+	tbuf = vmalloc(len);
+	if (!tbuf)
+		return -ENOMEM;
+
+	error = wait_event_interruptible(tcpw.wait,
+					 __kfifo_len(tcpw.fifo) != 0);
+	if (error)
+		return error;
+
+	cnt = kfifo_get(tcpw.fifo, tbuf, len);
+	error = copy_to_user(buf, tbuf, cnt);
+
+	vfree(tbuf);
+
+	return error ? error : cnt;
+}
+
+static struct file_operations tcpprobe_fops = {
+	.owner	 = THIS_MODULE,
+	.open	 = tcpprobe_open,
+	.read    = tcpprobe_read,
+};
+
+static __init int tcpprobe_init(void)
+{
+	int ret = -ENOMEM;
+
+	init_waitqueue_head(&tcpw.wait);
+	spin_lock_init(&tcpw.lock);
+	tcpw.fifo = kfifo_alloc(bufsize, GFP_KERNEL, &tcpw.lock);
+
+	if (!proc_net_fops_create(procname, S_IRUSR, &tcpprobe_fops))
+		goto err0;
+
+	ret = register_jprobe(&tcp_send_probe);
+	if (ret)
+		goto err1;
+
+	pr_info("TCP watch registered (port=%d)\n", port);
+	return 0;
+ err1:
+	proc_net_remove(procname);
+ err0:
+	kfifo_free(tcpw.fifo);
+	return ret;
+}
+module_init(tcpprobe_init);
+
+static __exit void tcpprobe_exit(void)
+{
+	kfifo_free(tcpw.fifo);
+	proc_net_remove(procname);
+	unregister_jprobe(&tcp_send_probe);
+
+}
+module_exit(tcpprobe_exit);
diff --git a/net/ipv4/tcp_veno.c b/net/ipv4/tcp_veno.c
new file mode 100644
index 0000000..11b42a7
--- /dev/null
+++ b/net/ipv4/tcp_veno.c
@@ -0,0 +1,231 @@
+/*
+ * TCP Veno congestion control
+ *
+ * This is based on the congestion detection/avoidance scheme described in
+ *    C. P. Fu, S. C. Liew.
+ *    "TCP Veno: TCP Enhancement for Transmission over Wireless Access Networks."
+ *    IEEE Journal on Selected Areas in Communication,
+ *    Feb. 2003.
+ * 	See http://www.ntu.edu.sg/home5/ZHOU0022/papers/CPFu03a.pdf
+ */
+
+#include <linux/config.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/inet_diag.h>
+
+#include <net/tcp.h>
+
+/* Default values of the Veno variables, in fixed-point representation
+ * with V_PARAM_SHIFT bits to the right of the binary point.
+ */
+#define V_PARAM_SHIFT 1
+static const int beta = 3 << V_PARAM_SHIFT;
+
+/* Veno variables */
+struct veno {
+	u8 doing_veno_now;	/* if true, do veno for this rtt */
+	u16 cntrtt;		/* # of rtts measured within last rtt */
+	u32 minrtt;		/* min of rtts measured within last rtt (in usec) */
+	u32 basertt;		/* the min of all Veno rtt measurements seen (in usec) */
+	u32 inc;		/* decide whether to increase cwnd */
+	u32 diff;		/* calculate the diff rate */
+};
+
+/* There are several situations when we must "re-start" Veno:
+ *
+ *  o when a connection is established
+ *  o after an RTO
+ *  o after fast recovery
+ *  o when we send a packet and there is no outstanding
+ *    unacknowledged data (restarting an idle connection)
+ *
+ */
+static inline void veno_enable(struct sock *sk)
+{
+	struct veno *veno = inet_csk_ca(sk);
+
+	/* turn on Veno */
+	veno->doing_veno_now = 1;
+
+	veno->minrtt = 0x7fffffff;
+}
+
+static inline void veno_disable(struct sock *sk)
+{
+	struct veno *veno = inet_csk_ca(sk);
+
+	/* turn off Veno */
+	veno->doing_veno_now = 0;
+}
+
+static void tcp_veno_init(struct sock *sk)
+{
+	struct veno *veno = inet_csk_ca(sk);
+
+	veno->basertt = 0x7fffffff;
+	veno->inc = 1;
+	veno_enable(sk);
+}
+
+/* Do rtt sampling needed for Veno. */
+static void tcp_veno_rtt_calc(struct sock *sk, u32 usrtt)
+{
+	struct veno *veno = inet_csk_ca(sk);
+	u32 vrtt = usrtt + 1;	/* Never allow zero rtt or basertt */
+
+	/* Filter to find propagation delay: */
+	if (vrtt < veno->basertt)
+		veno->basertt = vrtt;
+
+	/* Find the min rtt during the last rtt to find
+	 * the current prop. delay + queuing delay:
+	 */
+	veno->minrtt = min(veno->minrtt, vrtt);
+	veno->cntrtt++;
+}
+
+static void tcp_veno_state(struct sock *sk, u8 ca_state)
+{
+	if (ca_state == TCP_CA_Open)
+		veno_enable(sk);
+	else
+		veno_disable(sk);
+}
+
+/*
+ * If the connection is idle and we are restarting,
+ * then we don't want to do any Veno calculations
+ * until we get fresh rtt samples.  So when we
+ * restart, we reset our Veno state to a clean
+ * state. After we get acks for this flight of
+ * packets, _then_ we can make Veno calculations
+ * again.
+ */
+static void tcp_veno_cwnd_event(struct sock *sk, enum tcp_ca_event event)
+{
+	if (event == CA_EVENT_CWND_RESTART || event == CA_EVENT_TX_START)
+		tcp_veno_init(sk);
+}
+
+static void tcp_veno_cong_avoid(struct sock *sk, u32 ack,
+				u32 seq_rtt, u32 in_flight, int flag)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct veno *veno = inet_csk_ca(sk);
+
+	if (!veno->doing_veno_now)
+		return tcp_reno_cong_avoid(sk, ack, seq_rtt, in_flight, flag);
+
+	/* limited by applications */
+	if (!tcp_is_cwnd_limited(sk, in_flight))
+		return;
+
+	/* We do the Veno calculations only if we got enough rtt samples */
+	if (veno->cntrtt <= 2) {
+		/* We don't have enough rtt samples to do the Veno
+		 * calculation, so we'll behave like Reno.
+		 */
+		tcp_reno_cong_avoid(sk, ack, seq_rtt, in_flight, flag);
+	} else {
+		u32 rtt, target_cwnd;
+
+		/* We have enough rtt samples, so, using the Veno
+		 * algorithm, we determine the state of the network.
+		 */
+
+		rtt = veno->minrtt;
+
+		target_cwnd = ((tp->snd_cwnd * veno->basertt)
+			       << V_PARAM_SHIFT) / rtt;
+
+		veno->diff = (tp->snd_cwnd << V_PARAM_SHIFT) - target_cwnd;
+
+		if (tp->snd_cwnd <= tp->snd_ssthresh) {
+			/* Slow start.  */
+			tcp_slow_start(tp);
+		} else {
+			/* Congestion avoidance. */
+			if (veno->diff < beta) {
+				/* In the "non-congestive state", increase cwnd
+				 *  every rtt.
+				 */
+				if (tp->snd_cwnd_cnt >= tp->snd_cwnd) {
+					if (tp->snd_cwnd < tp->snd_cwnd_clamp)
+						tp->snd_cwnd++;
+					tp->snd_cwnd_cnt = 0;
+				} else
+					tp->snd_cwnd_cnt++;
+			} else {
+				/* In the "congestive state", increase cwnd
+				 * every other rtt.
+				 */
+				if (tp->snd_cwnd_cnt >= tp->snd_cwnd) {
+					if (veno->inc
+					    && tp->snd_cwnd <
+					    tp->snd_cwnd_clamp) {
+						tp->snd_cwnd++;
+						veno->inc = 0;
+					} else
+						veno->inc = 1;
+					tp->snd_cwnd_cnt = 0;
+				} else
+					tp->snd_cwnd_cnt++;
+			}
+
+		}
+		if (tp->snd_cwnd < 2)
+			tp->snd_cwnd = 2;
+		else if (tp->snd_cwnd > tp->snd_cwnd_clamp)
+			tp->snd_cwnd = tp->snd_cwnd_clamp;
+	}
+	/* Wipe the slate clean for the next rtt. */
+	/* veno->cntrtt = 0; */
+	veno->minrtt = 0x7fffffff;
+}
+
+/* Veno MD phase */
+static u32 tcp_veno_ssthresh(struct sock *sk)
+{
+	const struct tcp_sock *tp = tcp_sk(sk);
+	struct veno *veno = inet_csk_ca(sk);
+
+	if (veno->diff < beta)
+		/* in "non-congestive state", cut cwnd by 1/5 */
+		return max(tp->snd_cwnd * 4 / 5, 2U);
+	else
+		/* in "congestive state", cut cwnd by 1/2 */
+		return max(tp->snd_cwnd >> 1U, 2U);
+}
+
+static struct tcp_congestion_ops tcp_veno = {
+	.init		= tcp_veno_init,
+	.ssthresh	= tcp_veno_ssthresh,
+	.cong_avoid	= tcp_veno_cong_avoid,
+	.rtt_sample	= tcp_veno_rtt_calc,
+	.set_state	= tcp_veno_state,
+	.cwnd_event	= tcp_veno_cwnd_event,
+
+	.owner		= THIS_MODULE,
+	.name		= "veno",
+};
+
+static int __init tcp_veno_register(void)
+{
+	BUG_ON(sizeof(struct veno) > ICSK_CA_PRIV_SIZE);
+	tcp_register_congestion_control(&tcp_veno);
+	return 0;
+}
+
+static void __exit tcp_veno_unregister(void)
+{
+	tcp_unregister_congestion_control(&tcp_veno);
+}
+
+module_init(tcp_veno_register);
+module_exit(tcp_veno_unregister);
+
+MODULE_AUTHOR("Bin Zhou, Cheng Peng Fu");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("TCP Veno");
diff --git a/net/ipv4/tcp_westwood.c b/net/ipv4/tcp_westwood.c
index 0c340c3..29eb258 100644
--- a/net/ipv4/tcp_westwood.c
+++ b/net/ipv4/tcp_westwood.c
@@ -162,12 +162,6 @@ static inline u32 westwood_acked_count(s
 	return w->cumul_ack;
 }
 
-static inline u32 westwood_bw_rttmin(const struct sock *sk)
-{
-	const struct tcp_sock *tp = tcp_sk(sk);
-	const struct westwood *w = inet_csk_ca(sk);
-	return max_t(u32, (w->bw_est * w->rtt_min) / tp->mss_cache, 2);
-}
 
 /*
  * TCP Westwood
@@ -175,9 +169,11 @@ static inline u32 westwood_bw_rttmin(con
  * in packets we use mss_cache). Rttmin is guaranteed to be >= 2
  * so avoids ever returning 0.
  */
-static u32 tcp_westwood_cwnd_min(struct sock *sk)
+static u32 tcp_westwood_bw_rttmin(const struct sock *sk)
 {
-	return westwood_bw_rttmin(sk);
+	const struct tcp_sock *tp = tcp_sk(sk);
+	const struct westwood *w = inet_csk_ca(sk);
+	return max_t(u32, (w->bw_est * w->rtt_min) / tp->mss_cache, 2);
 }
 
 static void tcp_westwood_event(struct sock *sk, enum tcp_ca_event event)
@@ -191,11 +187,11 @@ static void tcp_westwood_event(struct so
 		break;
 
 	case CA_EVENT_COMPLETE_CWR:
-		tp->snd_cwnd = tp->snd_ssthresh = westwood_bw_rttmin(sk);
+		tp->snd_cwnd = tp->snd_ssthresh = tcp_westwood_bw_rttmin(sk);
 		break;
 
 	case CA_EVENT_FRTO:
-		tp->snd_ssthresh = westwood_bw_rttmin(sk);
+		tp->snd_ssthresh = tcp_westwood_bw_rttmin(sk);
 		break;
 
 	case CA_EVENT_SLOW_ACK:
@@ -235,7 +231,7 @@ static struct tcp_congestion_ops tcp_wes
 	.init		= tcp_westwood_init,
 	.ssthresh	= tcp_reno_ssthresh,
 	.cong_avoid	= tcp_reno_cong_avoid,
-	.min_cwnd	= tcp_westwood_cwnd_min,
+	.min_cwnd	= tcp_westwood_bw_rttmin,
 	.cwnd_event	= tcp_westwood_event,
 	.get_info	= tcp_westwood_info,
 	.pkts_acked	= tcp_westwood_pkts_acked,
