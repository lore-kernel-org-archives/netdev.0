From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/5] TCP BIC 1.1 support
Date: Fri, 18 Mar 2005 16:22:11 -0800
Message-ID: <20050318162211.366ca490@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Injong Rhee <rhee@eos.ncsu.edu>
To: Andrew Morton <akpm@digeo.com>, "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch adds TCP BIC back in as a pluggable TCP congestion mechanism.
This version is closer to the TCP BIC 1.1 released for Web100.
The changes from 2.6.11 are:
	* congestion window undo fix
	* delayed ack compensation
	* low utilization detection
	* more parameter (less hardcoded constants)

The parts that are in the Web100 version are missing are general (not BIC specific):
	* burst moderation
	* network device throttling drop tail behaviour
They will be addressed later.


Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/ipv4/Kconfig b/net/ipv4/Kconfig
--- a/net/ipv4/Kconfig	2005-03-18 16:09:40 -08:00
+++ b/net/ipv4/Kconfig	2005-03-18 16:09:40 -08:00
@@ -368,6 +368,20 @@
 
 menu "TCP congestion control"
 
+config TCP_CONG_BIC
+	tristate "Binary Increase Congestion (BIC) control"
+	default y
+	---help---
+	BIC-TCP is a sender-side only change that ensures a linear RTT
+	fairness under large windows while offering both scalability and
+	bounded TCP-friendliness. The protocol combines two schemes
+	called additive increase and binary search increase. When the
+	congestion window is large, additive increase with a large
+	increment ensures linear RTT fairness as well as good
+	scalability. Under small congestion windows, binary search
+	increase provides TCP friendliness.
+	See http://www.csc.ncsu.edu/faculty/rhee/export/bitcp/
+
 endmenu
 
 source "net/ipv4/ipvs/Kconfig"
diff -Nru a/net/ipv4/Makefile b/net/ipv4/Makefile
--- a/net/ipv4/Makefile	2005-03-18 16:09:40 -08:00
+++ b/net/ipv4/Makefile	2005-03-18 16:09:40 -08:00
@@ -24,6 +24,7 @@
 obj-$(CONFIG_NETFILTER)	+= netfilter/
 obj-$(CONFIG_IP_VS) += ipvs/
 obj-$(CONFIG_IP_TCPDIAG) += tcp_diag.o 
+obj-$(CONFIG_TCP_CONG_BIC) += tcp_bic.o
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
 		      xfrm4_output.o
diff -Nru a/net/ipv4/tcp_bic.c b/net/ipv4/tcp_bic.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/net/ipv4/tcp_bic.c	2005-03-18 16:09:40 -08:00
@@ -0,0 +1,293 @@
+/*
+ * Binary Increase Congestion control for TCP
+ *
+ * This is from the implementation of BICTCP in
+ * Lison-Xu, Kahaled Harfoush, and Injong Rhee.
+ *  "Binary Increase Congestion Control for Fast, Long Distance
+ *  Networks" in InfoComm 2004
+ * Available from:
+ *  http://www.csc.ncsu.edu/faculty/rhee/export/bitcp.pdf
+ *
+ * Unless BIC is enabled and congestion window is large
+ * this behaves the same as the original Reno.
+ */
+
+#include <linux/config.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <net/tcp.h>
+
+
+#define BICTCP_BETA_SCALE    1024	/* Scale factor beta calculation
+					 * max_cwnd = snd_cwnd * beta
+					 */
+#define BICTCP_B		4	 /*
+					  * In binary search,
+					  * go to point (max+min)/N
+					  */
+
+static int fast_convergence = 1;
+static int max_increment = 32;
+static int low_window = 14;
+static int beta = 819;		/* = 819/1024 (BICTCP_BETA_SCALE) */
+static int low_utilization_threshold = 153;
+static int low_utilization_period = 2;
+static int initial_ssthresh = 100;
+static int smooth_part = 20;
+
+module_param(fast_convergence, int, 0644);
+MODULE_PARM_DESC(fast_convergence, "turn on/off fast convergence");
+module_param(max_increment, int, 0644);
+MODULE_PARM_DESC(max_increment, "Limit on increment allowed during binary search");
+module_param(low_window, int, 0644);
+MODULE_PARM_DESC(low_window, "lower bound on congestion window (for TCP friendliness)");
+module_param(beta, int, 0644);
+MODULE_PARM_DESC(beta, "beta for multiplicative increase");
+module_param(low_utilization_threshold, int, 0644);
+MODULE_PARM_DESC(low_utilization_threshold, "percent (scaled by 1024) for low utilization mode");
+module_param(low_utilization_period, int, 0644);
+MODULE_PARM_DESC(low_utilization_period, "if average delay exceeds then goto to low utilization mode (seconds)");
+module_param(initial_ssthresh, int, 0644);
+MODULE_PARM_DESC(initial_ssthresh, "initial value of slow start threshold");
+module_param(smooth_part, int, 0644);
+MODULE_PARM_DESC(smooth_part, "log(B/(B*Smin))/log(B/(B-1))+B, # of RTT from Wmax-B to Wmax");
+
+
+/* BIC TCP Parameters */
+struct bictcp_ca {
+	u32	cnt;		/* increase cwnd by 1 after ACKs */
+	u32 	last_max_cwnd;	/* last maximum snd_cwnd */
+	u32	loss_cwnd;	/* congestion window at last loss */
+	u32	last_cwnd;	/* the last snd_cwnd */
+	u32	last_time;	/* time when updated last_cwnd */
+	u32	delay_min;	/* min delay */
+	u32	delay_max;	/* max delay */
+	u32	last_delay;
+	u8	low_utilization;/* 0: high; 1: low */
+	u32	low_utilization_start;	/* starting time of low utilization detection*/
+	u32	epoch_start;	/* beginning of an epoch */
+};
+
+static inline void bictcp_init(struct bictcp_ca *ca)
+{
+	memset(ca, 0, sizeof(*ca));
+}
+	
+static void bictcp_start(struct tcp_sock *tp)
+{
+	bictcp_init(tcp_ca(tp));
+	if (initial_ssthresh)
+		tp->snd_ssthresh = initial_ssthresh;
+}
+
+/*
+ * Compute congestion window to use.
+ */
+static inline u32 bictcp_cwnd(struct tcp_sock *tp)
+{
+	struct bictcp_ca *ca = tcp_ca(tp);
+
+	if (ca->last_cwnd == tp->snd_cwnd &&
+	   (s32)(tcp_time_stamp - ca->last_time) <= (HZ>>5))
+		return ca->cnt;
+
+	ca->last_cwnd = tp->snd_cwnd;
+	ca->last_time = tcp_time_stamp;
+
+	if (ca->epoch_start == 0)	/* record the beginning of an epoch */
+		ca->epoch_start = tcp_time_stamp;
+
+	/* start off normal */
+	if (tp->snd_cwnd <= low_window) {
+		ca->cnt = tp->snd_cwnd;
+		return ca->cnt;
+	}
+
+	/* binary increase */
+	if (tp->snd_cwnd < ca->last_max_cwnd) {
+		__u32 	dist = (ca->last_max_cwnd - tp->snd_cwnd)
+			/ BICTCP_B;
+
+		if (dist > max_increment)
+			/* linear increase */
+			ca->cnt = tp->snd_cwnd / max_increment;
+		else if (dist <= 1U)
+			/* binary search increase */
+			ca->cnt = (tp->snd_cwnd * smooth_part) / BICTCP_B;
+		else
+			/* binary search increase */
+			ca->cnt = tp->snd_cwnd / dist;
+	} else {
+		/* slow start AMD linear increase */
+		if (tp->snd_cwnd < ca->last_max_cwnd + BICTCP_B)
+			/* slow start */
+			ca->cnt = (tp->snd_cwnd * smooth_part) / BICTCP_B;
+		else if (tp->snd_cwnd < ca->last_max_cwnd + max_increment*(BICTCP_B-1))
+			/* slow start */
+			ca->cnt = (tp->snd_cwnd * (BICTCP_B-1))
+				/ tp->snd_cwnd-ca->last_max_cwnd;
+		else
+			/* linear increase */
+			ca->cnt = tp->snd_cwnd / max_increment;
+	}
+
+	/* if in slow start or link utilization is very low */
+	if ( ca->loss_cwnd == 0 ||
+	     (tp->snd_cwnd > ca->loss_cwnd && ca->low_utilization)) {
+		if (ca->cnt > 20) /* increase cwnd 5% per RTT */
+			ca->cnt = 20;
+	}
+
+	ca->cnt = (ca->cnt << 3) / tp->ack_ratio;
+	if (ca->cnt == 0)			/* cannot be zero */
+		ca->cnt = 1;
+
+	return ca->cnt;
+}
+
+
+/* Detect low utilization in congestion avoidance */
+static inline void bictcp_low_utilization(struct tcp_sock *tp, int flag)
+{
+	struct bictcp_ca *ca = tcp_ca(tp);
+	u32 dist, delay;
+
+	/* No time stamp */
+	if (!(tp->rx_opt.saw_tstamp && tp->rx_opt.rcv_tsecr) ||
+	     /* Discard delay samples right after fast recovery */
+	     tcp_time_stamp < ca->epoch_start + HZ ||	
+	     /* this delay samples may not be accurate */
+	     flag == 0) {				
+		ca->last_delay = 0;
+		goto notlow;
+	}
+
+	delay = ca->last_delay<<3;	/* use the same scale as tp->srtt*/
+	ca->last_delay = tcp_time_stamp - tp->rx_opt.rcv_tsecr;
+	if (delay == 0) 		/* no previous delay sample */
+		goto notlow;
+
+	/* first time call or link delay decreases */
+	if (ca->delay_min == 0 || ca->delay_min > delay) {
+		ca->delay_min = ca->delay_max = delay;
+		goto notlow;
+	}
+
+	if (ca->delay_max < delay)
+		ca->delay_max = delay;
+
+	/* utilization is low, if avg delay < dist*threshold 
+	   for checking_period time */
+	dist = ca->delay_max - ca->delay_min;
+	if (dist <= ca->delay_min>>6 ||
+	    tp->srtt - ca->delay_min >=  (dist*low_utilization_threshold)>>10)
+		goto notlow;
+
+	if (ca->low_utilization_start == 0) {
+		ca->low_utilization = 0;
+		ca->low_utilization_start = tcp_time_stamp;
+	} else if (after(tcp_time_stamp, 
+			 ca->low_utilization_start + low_utilization_period*HZ))
+		ca->low_utilization = 1;
+
+	return;
+
+ notlow:
+	ca->low_utilization = 0;
+	ca->low_utilization_start = 0;
+
+}
+
+static void bictcp_cong_avoid(struct tcp_sock *tp, u32 ack,
+				 u32 seq_rtt, u32 in_flight, int good)
+{
+	bictcp_low_utilization(tp, good);
+
+	if (in_flight < tp->snd_cwnd)
+		return;
+
+	if (tp->snd_cwnd <= tp->snd_ssthresh) {
+		/* In "safe" area, increase. */
+		if (tp->snd_cwnd < tp->snd_cwnd_clamp)
+			tp->snd_cwnd++;
+	} else {
+		if (tp->snd_cwnd_cnt > (bictcp_cwnd(tp) << 3)) {
+			tp->snd_cwnd_cnt = 0;
+			tp->snd_cwnd++;
+		}
+	}
+
+}
+
+/*
+ *	behave like Reno until low_window is reached,
+ *	then increase congestion window slowly
+ */
+static u32 bictcp_recalc_ssthresh(struct tcp_sock *tp)
+{
+	struct bictcp_ca *ca = tcp_ca(tp);
+
+	ca->epoch_start = 0;	/* end of epoch */
+
+	/* in case of wrong delay_max*/
+	if (ca->delay_min > 0 && ca->delay_max > ca->delay_min)
+		ca->delay_max = ca->delay_min
+			+ ((ca->delay_max - ca->delay_min)* 90) / 100;
+
+	/* Wmax and fast convergence */
+	if (tp->snd_cwnd < ca->last_max_cwnd && fast_convergence)
+		ca->last_max_cwnd = (tp->snd_cwnd * (BICTCP_BETA_SCALE + beta))
+			/ (2 * BICTCP_BETA_SCALE);
+	else
+		ca->last_max_cwnd = tp->snd_cwnd;
+
+	ca->loss_cwnd = tp->snd_cwnd;
+
+	if (tp->snd_cwnd <= low_window)
+		return max(tp->snd_cwnd >> 1U, 2U);
+	else
+		return max((tp->snd_cwnd * beta) / BICTCP_BETA_SCALE, 2U);
+}
+
+static u32 bictcp_undo_cwnd(struct tcp_sock *tp)
+{
+	struct bictcp_ca *ca = tcp_ca(tp);
+	return max(tp->snd_cwnd, ca->last_max_cwnd);
+}
+
+static void bictcp_ca_state(struct tcp_sock *tp, u8 new_state)
+{
+	if (new_state == TCP_CA_Loss)
+		bictcp_init(tcp_ca(tp));
+}
+
+static struct tcp_ca_type bictcp = {
+	.start		= bictcp_start,
+	.ssthresh	= bictcp_recalc_ssthresh,
+	.cong_avoid	= bictcp_cong_avoid,
+	.min_cwnd	= tcp_reno_cwnd_min,
+	.set_state	= bictcp_ca_state,
+	.undo_cwnd	= bictcp_undo_cwnd,
+
+	.owner		= THIS_MODULE,
+	.name		= "bic",
+};
+
+static int __init bictcp_register(void)
+{
+	BUG_ON(sizeof(struct bictcp_ca) > TCP_CA_PRIV_SIZE);
+	tcp_ca_register(&bictcp);
+	return 0;
+}
+
+static void __exit bictcp_unregister(void)
+{
+	tcp_ca_unregister(&bictcp);
+}
+
+module_init(bictcp_register);
+module_exit(bictcp_unregister);
+
+MODULE_AUTHOR("Stephen Hemminger");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("BIC TCP");
