From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 3/5] TCP Westwood+ support
Date: Fri, 18 Mar 2005 16:24:12 -0800
Message-ID: <20050318162412.189ccf9c@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Andrew Morton <akpm@digeo.com>, "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add TCP Westwood+ support back in as a separate pluggable algorithm.
The mechanism and policy is unchanged from existing code.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


diff -Nru a/net/ipv4/Kconfig b/net/ipv4/Kconfig
--- a/net/ipv4/Kconfig	2005-03-18 16:10:43 -08:00
+++ b/net/ipv4/Kconfig	2005-03-18 16:10:43 -08:00
@@ -382,6 +382,20 @@
 	increase provides TCP friendliness.
 	See http://www.csc.ncsu.edu/faculty/rhee/export/bitcp/
 
+config TCP_CONG_WESTWOOD
+	tristate "TCP Westwood+"
+	default y
+	---help---
+	TCP Westwood+ is a sender-side only modification of the TCP Reno 
+	protocol stack that optimizes the performance of TCP congestion 
+	control. It is based on end-to-end bandwidth estimation to set 
+	congestion window and slow start threshold after a congestion 
+	episode. Using this estimation, TCP Westwood+ adaptively sets a 
+	slow start threshold and a congestion window which takes into 
+	account the bandwidth used  at the time congestion is experienced. 
+	TCP Westwood+ significantly increases fairness wrt TCP Reno in 
+	wired networks and throughput over wireless links.   
+
 endmenu
 
 source "net/ipv4/ipvs/Kconfig"
diff -Nru a/net/ipv4/Makefile b/net/ipv4/Makefile
--- a/net/ipv4/Makefile	2005-03-18 16:10:43 -08:00
+++ b/net/ipv4/Makefile	2005-03-18 16:10:43 -08:00
@@ -25,6 +25,7 @@
 obj-$(CONFIG_IP_VS) += ipvs/
 obj-$(CONFIG_IP_TCPDIAG) += tcp_diag.o 
 obj-$(CONFIG_TCP_CONG_BIC) += tcp_bic.o
+obj-$(CONFIG_TCP_CONG_WESTWOOD) += tcp_westwood.o
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
 		      xfrm4_output.o
diff -Nru a/net/ipv4/tcp_westwood.c b/net/ipv4/tcp_westwood.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/net/ipv4/tcp_westwood.c	2005-03-18 16:10:43 -08:00
@@ -0,0 +1,349 @@
+/*
+ * TCP Westwood+
+ *
+ *	Angelo Dell'Aera:	TCP Westwood+ support
+ */
+
+#include <linux/config.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/tcp_diag.h>
+#include <net/tcp.h>
+
+/* TCP Westwood structure */
+struct westwood_ca {
+	u32    bw_ns_est;        /* first bandwidth estimation..not too smoothed 8) */
+	u32    bw_est;           /* bandwidth estimate */
+	u32    rtt_win_sx;       /* here starts a new evaluation... */
+	u32    bk;
+	u32    snd_una;          /* used for evaluating the number of acked bytes */
+	u32    cumul_ack;
+	u32    accounted;
+	u32    rtt;
+	u32    rtt_min;          /* minimum observed RTT */
+};
+
+
+/* TCP Westwood functions and constants */
+#define TCP_WESTWOOD_INIT_RTT  (20*HZ)           /* maybe too conservative?! */
+#define TCP_WESTWOOD_RTT_MIN   (HZ/20)           /* 50ms */
+
+/*
+ * @tcp_westwood_create
+ * This function initializes fields used in TCP Westwood+. We can't
+ * get no information about RTTmin at this time so we simply set it to
+ * TCP_WESTWOOD_INIT_RTT. This value was chosen to be too conservative
+ * since in this way we're sure it will be updated in a consistent
+ * way as soon as possible. It will reasonably happen within the first
+ * RTT period of the connection lifetime.
+ */
+static void tcp_westwood_start(struct tcp_sock *tp)
+{
+	struct westwood_ca *w = tcp_ca(tp);
+
+        w->bw_ns_est = 0;
+        w->bw_est = 0;
+        w->accounted = 0;
+        w->cumul_ack = 0;
+        w->rtt_win_sx = tcp_time_stamp;
+        w->rtt = TCP_WESTWOOD_INIT_RTT;
+        w->rtt_min = TCP_WESTWOOD_INIT_RTT;
+        w->snd_una = tp->snd_una;
+}
+
+/*
+ * @westwood_do_filter
+ * Low-pass filter. Implemented using constant coefficents.
+ */
+static inline u32 westwood_do_filter(u32 a, u32 b)
+{
+	return (((7 * a) + b) >> 3);
+}
+
+static inline void westwood_filter(struct westwood_ca *w, u32 delta)
+{
+	w->bw_ns_est = westwood_do_filter(w->bw_ns_est, w->bk / delta);
+	w->bw_est = westwood_do_filter(w->bw_est, w->bw_ns_est);
+}
+
+/*
+ * @westwood_update_rttmin
+ * It is used to update RTTmin. In this case we MUST NOT use
+ * WESTWOOD_RTT_MIN minimum bound since we could be on a LAN!
+ */
+static inline u32 westwood_update_rttmin(const struct westwood_ca *w)
+{
+	u32 rttmin = w->rtt_min;
+
+	if (w->rtt != 0 &&
+	    (w->rtt < w->rtt_min || !rttmin))
+		rttmin = w->rtt;
+
+	return rttmin;
+}
+
+static void tcp_westwood_sample_rtt(struct tcp_sock *tp, u32 rtt)
+{
+	struct westwood_ca *w = tcp_ca(tp);
+	w->rtt = tp->srtt >> 3;
+}
+
+/*
+ * @westwood_acked
+ * Evaluate increases for dk.
+ */
+static inline u32 westwood_acked(struct tcp_sock *tp)
+{
+	struct westwood_ca *w = tcp_ca(tp);
+	return tp->snd_una - w->snd_una;
+}
+
+/*
+ * @westwood_new_window
+ * It evaluates if we are receiving data inside the same RTT window as
+ * when we started.
+ * Return value:
+ * It returns 0 if we are still evaluating samples in the same RTT
+ * window, 1 if the sample has to be considered in the next window.
+ */
+static inline int westwood_new_window(const struct tcp_sock *tp)
+{
+	struct westwood_ca *w = tcp_ca(tp);
+	u32 left_bound;
+	u32 rtt;
+	int ret = 0;
+
+	left_bound = w->rtt_win_sx;
+	rtt = max(w->rtt, (u32) TCP_WESTWOOD_RTT_MIN);
+
+	/*
+	 * A RTT-window has passed. Be careful since if RTT is less than
+	 * 50ms we don't filter but we continue 'building the sample'.
+	 * This minimum limit was choosen since an estimation on small
+	 * time intervals is better to avoid...
+	 * Obvioulsy on a LAN we reasonably will always have
+	 * right_bound = left_bound + WESTWOOD_RTT_MIN
+         */
+
+	if ((left_bound + rtt) < tcp_time_stamp)
+		ret = 1;
+
+	return ret;
+}
+
+/*
+ * @westwood_update_window
+ * It updates RTT evaluation window if it is the right moment to do
+ * it. If so it calls filter for evaluating bandwidth.
+ */
+static void westwood_update_window(struct tcp_sock *tp, u32 now)
+{
+	struct westwood_ca *w = tcp_ca(tp);
+	if (westwood_new_window(tp)) {
+		u32 delta = now - w->rtt_win_sx;
+
+		if (delta) {
+			if (w->rtt)
+				westwood_filter(w, delta);
+
+			w->bk = 0;
+			w->rtt_win_sx = tcp_time_stamp;
+		}
+	}
+}
+
+/*
+ * @tcp_westwood_fast_bw
+ * It is called when we are in fast path. In particular it is called when
+ * header prediction is successfull. In such case infact update is
+ * straight forward and doesn't need any particular care.
+ */
+static void tcp_westwood_fast_bw(struct tcp_sock *tp)
+{
+	struct westwood_ca *w = tcp_ca(tp);
+	westwood_update_window(tp, tcp_time_stamp);
+
+	w->bk += westwood_acked(tp);
+	w->snd_una = tp->snd_una;
+	w->rtt_min = westwood_update_rttmin(w);
+}
+
+/*
+ * @westwood_acked_count
+ * This function evaluates cumul_ack for evaluating dk in case of
+ * delayed or partial acks.
+ */
+static u32 westwood_acked_count(struct tcp_sock *tp)
+{
+	struct westwood_ca *w = tcp_ca(tp);
+
+	w->cumul_ack = westwood_acked(tp);
+
+        /* If cumul_ack is 0 this is a dupack since it's not moving
+         * tp->snd_una.
+         */
+        if (!w->cumul_ack) {
+		w->accounted += tp->mss_cache_std;
+		w->cumul_ack = tp->mss_cache_std;
+	}
+
+        if (w->cumul_ack > tp->mss_cache_std) {
+		/* Partial or delayed ack */
+		if (w->accounted >= w->cumul_ack) {
+			w->accounted -= w->cumul_ack;
+			w->cumul_ack = tp->mss_cache_std;
+		} else {
+			w->cumul_ack -= w->accounted;
+			w->accounted = 0;
+		}
+	}
+
+	w->snd_una = tp->snd_una;
+
+	return w->cumul_ack;
+}
+
+
+/*
+ * @tcp_westwood_slow_bw
+ * It is called when something is going wrong..even if there could
+ * be no problems! Infact a simple delayed packet may trigger a
+ * dupack. But we need to be careful in such case.
+ */
+static void tcp_westwood_slow_bw(struct tcp_sock *tp)
+{
+	struct westwood_ca *w = tcp_ca(tp);
+
+	westwood_update_window(tp, tcp_time_stamp);
+
+	w->bk += westwood_acked_count(tp);
+	w->rtt_min = westwood_update_rttmin(w);
+}
+
+static inline u32 tcp_westwood_bw_rttmin(const struct tcp_sock *tp)
+{
+	struct westwood_ca *w = tcp_ca(tp);
+
+        return max((w->bw_est) * (w->rtt_min) / (u32) (tp->mss_cache_std),
+		   2U);
+}
+
+static inline u32 tcp_westwood_ssthresh(struct tcp_sock *tp)
+{
+	u32 ssthresh = tcp_westwood_bw_rttmin(tp);
+	if (ssthresh)
+		tp->snd_ssthresh = ssthresh;
+
+	return (ssthresh != 0);
+}
+
+static inline int tcp_westwood_cwnd(struct tcp_sock *tp)
+{
+	u32 cwnd = 0;
+
+	cwnd = tcp_westwood_bw_rttmin(tp);
+	if (cwnd)
+		tp->snd_cwnd = cwnd;
+
+	return (cwnd != 0);
+}
+
+/*
+ * TCP Westwood
+ * Here limit is evaluated as BWestimation*RTTmin (for obtaining it
+ * in packets we use mss_cache). If sysctl_tcp_westwood is off
+ * tcp_westwood_bw_rttmin() returns 0. In such case snd_ssthresh is
+ * still used as usual. It prevents other strange cases in which
+ * BWE*RTTmin could assume value 0. It should not happen but...
+ */
+static u32 tcp_westwood_cwnd_min(struct tcp_sock *tp)
+{
+	u32 limit;
+
+	limit = tcp_westwood_bw_rttmin(tp);
+	if (limit == 0)
+		limit = tp->snd_ssthresh/2;
+	return limit;
+}
+
+static void tcp_westwood_event(struct tcp_sock *tp, enum tcp_ca_event event)
+{
+	switch(event) {
+	case CA_EVENT_CWND_RESTART:
+		break;
+
+	case CA_EVENT_COMPLETE_CWR:
+		if (tcp_westwood_cwnd(tp))
+			tp->snd_ssthresh = tp->snd_cwnd;
+		break;
+
+	case CA_EVENT_FRTO:
+		if (!tcp_westwood_ssthresh(tp))
+			tp->snd_ssthresh = tcp_westwood_ssthresh(tp);
+		break;
+
+	case CA_EVENT_FAST_ACK:
+		tcp_westwood_fast_bw(tp);
+		break;
+
+	case CA_EVENT_SLOW_ACK:
+		tcp_westwood_slow_bw(tp);
+		break;
+
+	default:
+		break;
+	}
+}
+
+
+/* Extract info for Tcp socket info provided via netlink. */
+static void tcp_westwood_info(struct tcp_sock *tp, u32 ext,
+			      struct sk_buff *skb)
+{
+
+	if (ext & (1<<(TCPDIAG_VEGASINFO-1))) {
+		struct tcpvegas_info *info
+			= tcpdiag_put(skb, TCPDIAG_VEGASINFO, sizeof(*info));
+		if (info) {
+			struct westwood_ca *ca = tcp_ca(tp);
+			info->tcpv_enabled = 1;
+			info->tcpv_rttcnt = 0;
+			info->tcpv_rtt = jiffies_to_usecs(ca->rtt);
+			info->tcpv_minrtt = jiffies_to_usecs(ca->rtt_min);
+		}
+	}
+}
+
+
+static struct tcp_ca_type tcp_westwood = {
+	.start		= tcp_westwood_start,
+	.ssthresh	= tcp_reno_ssthresh,
+	.rtt_sample	= tcp_westwood_sample_rtt,
+	.cong_avoid	= tcp_reno_cong_avoid,
+	.min_cwnd	= tcp_westwood_cwnd_min,
+	.cwnd_event	= tcp_westwood_event,
+	.get_info	= tcp_westwood_info,
+
+	.owner		= THIS_MODULE,
+	.name		= "westwood"
+};
+
+static int __init tcp_westwood_init(void)
+{
+	BUG_ON(sizeof(struct westwood_ca) > TCP_CA_PRIV_SIZE);
+	tcp_ca_register(&tcp_westwood);
+	return 0;
+}
+
+static void __exit tcp_westwood_exit(void)
+{
+	tcp_ca_unregister(&tcp_westwood);
+}
+
+module_init(tcp_westwood_init);
+module_exit(tcp_westwood_exit);
+
+MODULE_AUTHOR("Stephen Hemminger, Angelo Del'Aera");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("TCP Westwood+");
