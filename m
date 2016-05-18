From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH net-next 2/2] tcp: add NV congestion control
Date: Tue, 17 May 2016 18:25:36 -0700
Message-ID: <1463534736-2739015-3-git-send-email-brakmo@fb.com>
References: <1463534736-2739015-1-git-send-email-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:18807 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752513AbcERB0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 21:26:00 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u4I1LPbH010483
	for <netdev@vger.kernel.org>; Tue, 17 May 2016 18:25:59 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 230e0gr5dv-2
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 17 May 2016 18:25:59 -0700
Received: from facebook.com (2401:db00:11:d037:face:0:33:0)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 787950041c9711e6840624be0595f910-cb8c3c50 for <netdev@vger.kernel.org>;	Tue,
 17 May 2016 18:25:57 -0700
In-Reply-To: <1463534736-2739015-1-git-send-email-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP-NV (New Vegas) is a major update to TCP-Vegas.
An earlier version of NV was presented at 2010's LPC.
It is a delayed based congestion avoidance for the
data center. This version has been tested within a
10G rack where the HW RTTs are 20-50us.

A description of TCP-NV, including implementation
details as well as experimental results, can be found at:
http://www.brakmo.org/networking/tcp-nv/TCPNV.html

The current version includes many module parameters to support
experimentation with the parameters.

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
---
 net/ipv4/Kconfig  |  16 ++
 net/ipv4/Makefile |   1 +
 net/ipv4/tcp_nv.c | 592 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 609 insertions(+)
 create mode 100644 net/ipv4/tcp_nv.c

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 238225b..50d6a9b 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -532,6 +532,22 @@ config TCP_CONG_VEGAS
 	window. TCP Vegas should provide less packet loss, but it is
 	not as aggressive as TCP Reno.
 
+config TCP_CONG_NV
+       tristate "TCP NV"
+       default n
+       ---help---
+       TCP NV is a follow up to TCP Vegas. It has been modified to deal with
+       10G networks, measurement noise introduced by LRO, GRO and interrupt
+       coalescence. In addition, it will decrease its cwnd multiplicatively
+       instead of linearly.
+
+       Note that in general congestion avoidance (cwnd decreased when # packets
+       queued grows) cannot coexist with congestion control (cwnd decreased only
+       when there is packet loss) due to fairness issues. One scenario when they
+       can coexist safely is when the CA flows have RTTs << CC flows RTTs.
+
+       For further details see http://www.brakmo.org/networking/tcp-nv/
+
 config TCP_CONG_SCALABLE
 	tristate "Scalable TCP"
 	default n
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index bfa1336..24629b6 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -50,6 +50,7 @@ obj-$(CONFIG_TCP_CONG_HSTCP) += tcp_highspeed.o
 obj-$(CONFIG_TCP_CONG_HYBLA) += tcp_hybla.o
 obj-$(CONFIG_TCP_CONG_HTCP) += tcp_htcp.o
 obj-$(CONFIG_TCP_CONG_VEGAS) += tcp_vegas.o
+obj-$(CONFIG_TCP_CONG_NV) += tcp_nv.o
 obj-$(CONFIG_TCP_CONG_VENO) += tcp_veno.o
 obj-$(CONFIG_TCP_CONG_SCALABLE) += tcp_scalable.o
 obj-$(CONFIG_TCP_CONG_LP) += tcp_lp.o
diff --git a/net/ipv4/tcp_nv.c b/net/ipv4/tcp_nv.c
new file mode 100644
index 0000000..f658947
--- /dev/null
+++ b/net/ipv4/tcp_nv.c
@@ -0,0 +1,592 @@
+/*
+ * TCP NV: TCP with Congestion Avoidance
+ *
+ * TCP-NV is a successor of TCP-Vegas that has been developed to
+ * deal with the issues that occur in modern networks.
+ * Like TCP-Vegas, TCP-NV supports true congestion avoidance,
+ * the ability to detect congestion before packet losses occur.
+ * When congestion (queue buildup) starts to occur, TCP-NV
+ * predicts what the cwnd size should be for the current
+ * throughput and it reduces the cwnd proportionally to
+ * the difference between the current cwnd and the predicted cwnd.
+ * TCP-NV behaves like Reno when no congestion is detected, or when
+ * recovering from packet losses.
+ *
+ * Note: High NIC coalescence values may lower the performance of NV
+ * due to the increased noise in RTT values. In particular, we have
+ * seen issues with rx-frames values greater than 8.
+ *
+ * TODO:
+ * 1) Add mechanism to deal with reverse congestion.
+ */
+
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/math64.h>
+#include <net/tcp.h>
+#include <linux/inet_diag.h>
+
+/* TCP NV parameters
+ *
+ * nv_enable		Behaves like Reno if disabled
+ * nv_pad		Packets queued to trigger congestion detection
+ * nv_pad_buffer	Below this packets queued trigger cwnd growth
+ * nv_reset_period	Who often (in) seconds)to reset min_rtt
+ * nv_min_cwnd		Don't decrease cwnd below this if there are no losses
+ * nv_cong_dec_mult	Decrease cwnd by X% (30%) of congestion when detected
+ * nv_ssthresh_factor	On congestion set ssthresh to this * <desired cwnd> / 8
+ * nv_rtt_factor	RTT averaging factor
+ * nv_rtt_cnt_dec_delta Periodically decrease cwnd for this many RTTs
+ * nv_dec_factor	  and this factor (temp cwnd = cwnd * this / 8)
+ * nv_loss_dec_factor	Decrease cwnd by this (50%) when losses occur
+ * nv_dec_eval_min_calls	Wait this many RTT measurements before dec cwnd
+ * nv_inc_eval_min_calls	Wait this many RTT measurements before inc cwnd
+ * nv_ssthresh_eval_min_calls	Wait this many RTT measurements before stopping
+ *				slow-start due to congestion
+ * nv_stop_rtt_cnt	Only grow cwnd for this many RTTs after non-congestion
+ * nv_rtt_min_cnt	Wait these many RTTs before making congesion decision
+ * nv_min_min_rtt	Lower bound for min_rtt
+ * nv_max_min_rtt	Upper bound for min_rtt
+ *	How quickly to double growth rate (not rate) of cwnd when not congested.
+ *	One value (nv_cwnd_growth_rate_neg) for when rate < 1 pkt/RTT (losses)
+ *	the other (nv_cwnd_growth_rate_pos) otherwise.
+ * nv_cwnd_growth_rate_neg
+ * nv_cwnd_growth_rate_pos
+ */
+
+static int nv_enable __read_mostly = 1;
+static int nv_pad __read_mostly = 10;
+static int nv_pad_buffer __read_mostly = 2;
+static int nv_reset_period __read_mostly = 5; /* in seconds */
+static int nv_min_cwnd __read_mostly = 2;
+static int nv_cong_dec_mult __read_mostly = 30 * 128 / 100; /* = 30% */
+static int nv_ssthresh_factor __read_mostly = 8; /* = 1 */
+static int nv_rtt_factor __read_mostly = 128; /* = 1/2*old + 1/2*new */
+static int nv_rtt_cnt_dec_delta __read_mostly; /* 0 => off */
+static int nv_dec_factor __read_mostly = 8;  /* tmp cwnd = cwnd * factor / 8 */
+static int nv_loss_dec_factor __read_mostly = 512; /* => 50% */
+static int nv_cwnd_growth_rate_neg __read_mostly = 8;
+static int nv_cwnd_growth_rate_pos __read_mostly; /* 0 => fixed like Reno */
+static int nv_dec_eval_min_calls __read_mostly = 60;
+static int nv_inc_eval_min_calls __read_mostly = 20;
+static int nv_ssthresh_eval_min_calls __read_mostly = 30;
+static int nv_stop_rtt_cnt __read_mostly = 10;
+static int nv_rtt_min_cnt __read_mostly = 2;
+static int nv_min_min_rtt __read_mostly; /* 0 => none */
+static int nv_max_min_rtt __read_mostly; /* 0 => none */
+
+module_param(nv_enable, int, 0644);
+MODULE_PARM_DESC(nv_enable, "enable NV (congestion avoidance) behavior");
+module_param(nv_pad, int, 0644);
+MODULE_PARM_DESC(nv_pad, "extra packets above congestion level");
+module_param(nv_pad_buffer, int, 0644);
+MODULE_PARM_DESC(nv_pad_buffer, "no growth buffer zone");
+module_param(nv_reset_period, int, 0644);
+MODULE_PARM_DESC(nv_reset_period, "nv_min_rtt reset period (secs)");
+module_param(nv_min_cwnd, int, 0644);
+MODULE_PARM_DESC(nv_min_cwnd, "NV will not decrease cwnd below this value"
+		 " without losses");
+module_param(nv_dec_eval_min_calls, int, 0644);
+MODULE_PARM_DESC(nv_dec_eval_min_calls, "Wait for this many data points"
+		 " before declaring congestion");
+module_param(nv_inc_eval_min_calls, int, 0644);
+MODULE_PARM_DESC(nv_inc_eval_min_calls, "Wait for this many data points"
+		 " before allowing cwnd growth");
+module_param(nv_stop_rtt_cnt, int, 0644);
+MODULE_PARM_DESC(nv_stop_rtt_cnt, "Wait for this many RTTs before stopping"
+		 " cwnd growth");
+module_param(nv_ssthresh_eval_min_calls, int, 0644);
+MODULE_PARM_DESC(nv_ssthresh_eval_min_calls, "Wait for this many data points"
+		 " before declaring congestion during initial slow-start");
+module_param(nv_rtt_min_cnt, int, 0644);
+MODULE_PARM_DESC(nv_rtt_min_cnt, "Wait for this many RTTs before declaring"
+		 " congestion");
+module_param(nv_cong_dec_mult, int, 0644);
+MODULE_PARM_DESC(nv_cong_dec_mult, "Congestion decrease factor");
+module_param(nv_ssthresh_factor, int, 0644);
+MODULE_PARM_DESC(nv_ssthresh_factor, "ssthresh factor");
+module_param(nv_rtt_factor, int, 0644);
+MODULE_PARM_DESC(nv_rtt_factor, "rtt averaging factor");
+module_param(nv_rtt_cnt_dec_delta, int, 0644);
+MODULE_PARM_DESC(nv_rtt_cnt_dec_delta, "decrease cwnd for this many RTTs"
+		 " every 100 RTTs");
+module_param(nv_dec_factor, int, 0644);
+MODULE_PARM_DESC(nv_dec_factor, "decrease cwnd every ~192 RTTS by factor/8");
+module_param(nv_loss_dec_factor, int, 0644);
+MODULE_PARM_DESC(nv_loss_dec_factor, "on loss new cwnd = cwnd * this / 1024");
+module_param(nv_cwnd_growth_rate_neg, int, 0644);
+MODULE_PARM_DESC(nv_cwnd_growth_rate_neg, "Applies when current cwnd growth"
+		 " rate < Reno");
+module_param(nv_cwnd_growth_rate_pos, int, 0644);
+MODULE_PARM_DESC(nv_cwnd_growth_rate_pos, "Applies when current cwnd growth"
+		 " rate >= Reno");
+module_param(nv_min_min_rtt, int, 0644);
+MODULE_PARM_DESC(nv_min_min_rtt, "lower bound for ca->nv_min_rtt");
+module_param(nv_max_min_rtt, int, 0644);
+MODULE_PARM_DESC(nv_max_min_rtt, "upper bound for ca->nv_min_rtt");
+
+/* TCP NV Parameters */
+struct tcpnv {
+	unsigned long nv_min_rtt_reset_jiffies;  /* when to switch to
+						  * nv_min_rtt_new */
+	s8  cwnd_growth_factor;	/* Current cwnd growth factor,
+				 * < 0 => less than 1 packet/RTT */
+	u8  available8;
+	u16 available16;
+	u32 loss_cwnd;	/* cwnd at last loss */
+	u8  nv_allow_cwnd_growth:1, /* whether cwnd can grow */
+		nv_reset:1,	    /* whether to reset values */
+		nv_catchup:1;	    /* whether we are growing because
+				     * of temporary cwnd decrease */
+	u8  nv_eval_call_cnt;	/* call count since last eval */
+	u8  nv_min_cwnd;	/* nv won't make a ca decision if cwnd is
+				 * smaller than this. It may grow to handle
+				 * TSO, LRO and interrupt coalescence because
+				 * with these a small cwnd cannot saturate
+				 * the link. Note that this is different from
+				 * the file local nv_min_cwnd */
+	u8  nv_rtt_cnt;		/* RTTs without making ca decision */;
+	u32 nv_last_rtt;	/* last rtt */
+	u32 nv_min_rtt;		/* active min rtt. Used to determine slope */
+	u32 nv_min_rtt_new;	/* min rtt for future use */
+	u32 nv_rtt_max_rate;	/* max rate seen during current RTT */
+	u32 nv_rtt_start_seq;	/* current RTT ends when packet arrives
+				 * acking beyond nv_rtt_start_seq */
+	u32 nv_last_snd_una;	/* Previous value of tp->snd_una. It is
+				 * used to determine bytes acked since last
+				 * call to bictcp_acked */
+	u32 nv_no_cong_cnt;	/* Consecutive no congestion decisions */
+	u32 nv_rtt_cnt_dec;	/* RTTs since last temporary cwnd decrease */
+};
+
+#define NV_INIT_RTT	  U32_MAX
+#define NV_MIN_CWND	  4
+#define NV_MIN_CWND_GROW  2
+#define NV_TSO_CWND_BOUND 80
+
+static inline void tcpnv_reset(struct tcpnv *ca, struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	ca->nv_reset = 0;
+	ca->loss_cwnd = 0;
+	ca->nv_no_cong_cnt = 0;
+	ca->nv_rtt_cnt = 0;
+	ca->nv_rtt_cnt_dec = 0;
+	ca->nv_last_rtt = 0;
+	ca->nv_rtt_max_rate = 0;
+	ca->nv_rtt_start_seq = tp->snd_una;
+	ca->nv_eval_call_cnt = 0;
+	ca->nv_last_snd_una = tp->snd_una;
+}
+
+inline u32 get_nv_min_rtt(u32 val)
+{
+	if (nv_min_min_rtt > 0 && val < nv_min_min_rtt)
+		return nv_min_min_rtt;
+	else if (nv_max_min_rtt > 0 && val > nv_max_min_rtt)
+		return nv_max_min_rtt;
+	else
+		return val;
+}
+
+static void tcpnv_init(struct sock *sk)
+{
+	struct tcpnv *ca = inet_csk_ca(sk);
+
+	tcpnv_reset(ca, sk);
+
+	ca->nv_allow_cwnd_growth = 1;
+	ca->nv_min_rtt_reset_jiffies = jiffies + 2 * HZ;
+	ca->nv_min_rtt = NV_INIT_RTT;
+	ca->nv_min_rtt_new = NV_INIT_RTT;
+	ca->nv_min_cwnd = NV_MIN_CWND;
+	ca->nv_catchup = 0;
+	ca->cwnd_growth_factor = 0;
+}
+
+static void tcpnv_cong_avoid(struct sock *sk, u32 ack, u32 acked)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct tcpnv *ca = inet_csk_ca(sk);
+	u32 cnt;
+
+	if (!tcp_is_cwnd_limited(sk))
+		return;
+
+	/* Only grow cwnd if NV has not detected congestion */
+	if (nv_enable && !ca->nv_allow_cwnd_growth)
+		return;
+
+	if (tcp_in_slow_start(tp)) {
+		acked = tcp_slow_start(tp, acked);
+		if (!acked)
+			return;
+	}
+	if (!nv_enable)
+		ca->cwnd_growth_factor = 0;
+
+	if (ca->cwnd_growth_factor < 0) {
+		cnt = tp->snd_cwnd << -ca->cwnd_growth_factor;
+		tcp_cong_avoid_ai(tp, cnt, acked);
+	} else {
+		cnt = max(4U, tp->snd_cwnd >> ca->cwnd_growth_factor);
+		tcp_cong_avoid_ai(tp, cnt, acked);
+	}
+}
+
+static u32 tcpnv_recalc_ssthresh(struct sock *sk)
+{
+	const struct tcp_sock *tp = tcp_sk(sk);
+	struct tcpnv *ca = inet_csk_ca(sk);
+
+	ca->loss_cwnd = tp->snd_cwnd;
+	return max((tp->snd_cwnd * nv_loss_dec_factor) >> 10, 2U);
+}
+
+static u32 tcpnv_undo_cwnd(struct sock *sk)
+{
+	struct tcpnv *ca = inet_csk_ca(sk);
+
+	return max(tcp_sk(sk)->snd_cwnd, ca->loss_cwnd);
+}
+
+static void tcpnv_state(struct sock *sk, u8 new_state)
+{
+	struct tcpnv *ca = inet_csk_ca(sk);
+
+	if (new_state == TCP_CA_Open && ca->nv_reset) {
+		tcpnv_reset(ca, sk);
+	} else if (new_state == TCP_CA_Loss || new_state == TCP_CA_CWR ||
+		new_state == TCP_CA_Recovery) {
+		ca->nv_reset = 1;
+		ca->nv_allow_cwnd_growth = 0;
+		if (new_state == TCP_CA_Loss) {
+			/* Reset cwnd growth factor to Reno value */
+			if (ca->cwnd_growth_factor > 0)
+				ca->cwnd_growth_factor = 0;
+			/* Decrease growth rate if allowed */
+			if (nv_cwnd_growth_rate_neg > 0 &&
+			    ca->cwnd_growth_factor > -8)
+				ca->cwnd_growth_factor--;
+		}
+	}
+}
+
+/* Do congestion avoidance calculations for TCP-NV
+ */
+static void tcpnv_acked(struct sock *sk, const struct ack_sample *sample)
+{
+	const struct inet_connection_sock *icsk = inet_csk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct tcpnv *ca = inet_csk_ca(sk);
+	unsigned long now = jiffies;
+	s64 rate64 = 0;
+	u32 rate, max_win, cwnd_by_slope;
+	u32 avg_rtt;
+	u32 bytes_acked = 0;
+
+	/* Some calls are for duplicates without timetamps */
+	if (sample->rtt_us < 0)
+		return;
+
+	/* If not in TCP_CA_Open or TCP_CA_Disorder states, skip. */
+	if (icsk->icsk_ca_state != TCP_CA_Open &&
+	    icsk->icsk_ca_state != TCP_CA_Disorder)
+		return;
+
+	/* If NV mode is not enabled, behave like Reno */
+	if (!nv_enable) {
+		ca->nv_allow_cwnd_growth = 1;
+		return;
+	}
+
+	/* Stop cwnd growth if we were in catch up mode */
+	if (ca->nv_catchup && tp->snd_cwnd >= nv_min_cwnd) {
+		ca->nv_catchup = 0;
+		ca->nv_allow_cwnd_growth = 0;
+	}
+
+	bytes_acked = tp->snd_una - ca->nv_last_snd_una;
+	ca->nv_last_snd_una = tp->snd_una;
+
+	if (sample->in_flight == 0)
+		return;
+
+	/* Calculate moving average of RTT */
+	if (nv_rtt_factor > 0) {
+		if (ca->nv_last_rtt > 0) {
+			avg_rtt = (((u64)sample->rtt_us) * nv_rtt_factor +
+				   ((u64)ca->nv_last_rtt)
+				   * (256 - nv_rtt_factor)) >> 8;
+		} else {
+			avg_rtt = sample->rtt_us;
+			ca->nv_min_rtt = get_nv_min_rtt(avg_rtt << 1);
+		}
+		ca->nv_last_rtt = avg_rtt;
+	} else {
+		avg_rtt = sample->rtt_us;
+	}
+
+	/* rate in 100's bits per second */
+	rate64 = ((u64)sample->in_flight) * 8000000;
+	rate = (u32)div64_u64(rate64, (u64)(avg_rtt * 100));
+
+	/* Remember the maximum rate seen during this RTT
+	 * Note: It may be more than one RTT. This function should be
+	 *       called at least nv_dec_eval_min_calls times.
+	 */
+	if (ca->nv_rtt_max_rate < rate)
+		ca->nv_rtt_max_rate = rate;
+
+	/* We have valid information, increment counter */
+	if (ca->nv_eval_call_cnt < 255)
+		ca->nv_eval_call_cnt++;
+
+	/* Apply bounds to rtt */
+	avg_rtt = get_nv_min_rtt(avg_rtt);
+
+	/* update min rtt if necessary */
+	if (avg_rtt < ca->nv_min_rtt)
+		ca->nv_min_rtt = avg_rtt;
+
+	/* update future min_rtt if necessary */
+	if (avg_rtt < ca->nv_min_rtt_new)
+		ca->nv_min_rtt_new = avg_rtt;
+
+	/* nv_min_rtt is updated with the minimum (possibley averaged) rtt
+	 * seen in the last sysctl_tcp_nv_reset_period seconds (i.e. a
+	 * warm reset). This new nv_min_rtt will be continued to be updated
+	 * and be used for another sysctl_tcp_nv_reset_period seconds,
+	 * when it will be updated again.
+	 * In practice we introduce some randomness, so the actual period used
+	 * is chosen randomly from the range:
+	 *   [sysctl_tcp_nv_reset_period*3/4, sysctl_tcp_nv_reset_period*5/4)
+	 */
+	if (time_after_eq(now, ca->nv_min_rtt_reset_jiffies)) {
+		unsigned char rand;
+
+		ca->nv_min_rtt = ca->nv_min_rtt_new;
+		ca->nv_min_rtt_new = NV_INIT_RTT;
+		get_random_bytes(&rand, 1);
+		ca->nv_min_rtt_reset_jiffies =
+			now + ((nv_reset_period * (384 + rand) * HZ) >> 9);
+		/* Every so often we decrease nv_min_cwnd in case previous
+		 *  value is no longer accurate.
+		 */
+		ca->nv_min_cwnd = max(ca->nv_min_cwnd / 2, NV_MIN_CWND);
+	}
+
+	/* Once per RTT check if we need to do congestion avoidance */
+	if (before(ca->nv_rtt_start_seq, tp->snd_una)) {
+		ca->nv_rtt_start_seq = tp->snd_nxt;
+		if (ca->nv_rtt_cnt < 0xff)
+			/* Increase counter for RTTs without CA decision */
+			ca->nv_rtt_cnt++;
+		if (ca->nv_rtt_cnt_dec < 0xffff)
+			/* Increase counter for temporary cwnd decrease */
+			ca->nv_rtt_cnt_dec++;
+
+		/* If this function is only called once within an RTT
+		 * the cwnd is probably too small (in some cases due to
+		 * tso, lro or interrupt coalescence), so we increase
+		 * nv_min_cwnd.
+		 */
+		if (ca->nv_eval_call_cnt == 1 &&
+		    bytes_acked >= (ca->nv_min_cwnd - 1) * tp->mss_cache &&
+		    ca->nv_min_cwnd < (NV_TSO_CWND_BOUND + 1) &&
+		    ca->nv_rtt_cnt_dec < 192) {
+			ca->nv_min_cwnd = min(ca->nv_min_cwnd
+					      + NV_MIN_CWND_GROW,
+					      NV_TSO_CWND_BOUND + 1);
+			ca->nv_rtt_start_seq = tp->snd_nxt +
+				ca->nv_min_cwnd * tp->mss_cache;
+			ca->nv_eval_call_cnt = 0;
+			ca->nv_allow_cwnd_growth = 1;
+			return;
+		}
+
+		/* Every 192 to 320 RTTs decrease cwnd to get better min RTT
+		 * measurement. In practice we accomplish this by initializing
+		 * nv_rtt_cnd_dec randomly form the range [0, 128) and
+		 * stopping at 320.
+		 * We keep the value low for nv_rtt_cnt_dec_delta RTTs and then
+		 * we restore cwnd to its previous value (by setting
+		 * ssthresh to the previous value).
+		 */
+		if (ca->nv_rtt_cnt_dec < 320 && tp->snd_cwnd < nv_min_cwnd) {
+			ca->nv_allow_cwnd_growth = 1;
+			ca->nv_catchup = 1;
+			return;
+		} else if (ca->nv_rtt_cnt_dec == 320) {
+			if (nv_rtt_cnt_dec_delta == 0) {
+				ca->nv_rtt_cnt_dec = 0;
+			} else {
+				/* decrease cwnd and ssthresh */
+				tp->snd_cwnd = max((unsigned int)nv_min_cwnd,
+						   ((tp->snd_cwnd *
+						     nv_dec_factor) >> 3));
+				tp->snd_ssthresh =
+					max(tp->snd_cwnd,
+					    ((tp->snd_ssthresh * nv_dec_factor)
+					     >> 3));
+				ca->nv_allow_cwnd_growth = 0;
+				return;
+			}
+		} else if (ca->nv_rtt_cnt_dec > 320) {
+			if (ca->nv_rtt_cnt_dec - 320 >= nv_rtt_cnt_dec_delta) {
+				/* Restore ssthresh to restore cwnd */
+				unsigned char rand;
+
+				get_random_bytes(&rand, 1);
+				ca->nv_rtt_cnt_dec = rand >> 1;
+				tp->snd_ssthresh = (tp->snd_ssthresh << 3)
+					/ nv_dec_factor;
+				ca->nv_allow_cwnd_growth = 1;
+				ca->nv_no_cong_cnt = 0;
+			}
+			return;
+		}
+
+		/* Find the ideal cwnd for current rate from slope
+		 * slope = 80000.0 * mss / nv_min_rtt
+		 * cwnd_by_slope = nv_rtt_max_rate / slope
+		 */
+		cwnd_by_slope = (u32)
+			div64_u64(((u64)ca->nv_rtt_max_rate) * ca->nv_min_rtt,
+				  (u64)(80000 * tp->mss_cache));
+		max_win = cwnd_by_slope + nv_pad;
+
+		/* If cwnd > max_win, decrease cwnd
+		 * if cwnd < max_win, grow cwnd
+		 * else leave the same
+		 */
+		if (tp->snd_cwnd > max_win) {
+			/* there is congestion, check that it is ok
+			 * to make a CA decision
+			 * 1. We should have at least nv_dec_eval_min_calls
+			 *    data points before making a CA  decision
+			 * 2. We only make a congesion decision after
+			 *    nv_rtt_min_cnt RTTs
+			 */
+			if (ca->nv_rtt_cnt < nv_rtt_min_cnt) {
+				return;
+			} else if (tp->snd_ssthresh == TCP_INFINITE_SSTHRESH) {
+				if (ca->nv_eval_call_cnt <
+				    nv_ssthresh_eval_min_calls)
+					return;
+				/* otherwise we will decrease cwnd */
+			} else if (ca->nv_eval_call_cnt <
+				   nv_dec_eval_min_calls) {
+				if (ca->nv_allow_cwnd_growth &&
+				    ca->nv_rtt_cnt > nv_stop_rtt_cnt)
+					ca->nv_allow_cwnd_growth = 0;
+				return;
+			}
+
+			/* We have enough data to determine we are congested */
+			ca->nv_allow_cwnd_growth = 0;
+			tp->snd_ssthresh =
+				(nv_ssthresh_factor * max_win) >> 3;
+			if (tp->snd_cwnd - max_win > 2) {
+				/* gap > 2, we do exponential cwnd decrease */
+				int dec;
+
+				dec = max(2U, ((tp->snd_cwnd - max_win) *
+					       nv_cong_dec_mult) >> 7);
+				tp->snd_cwnd -= dec;
+			} else if (nv_cong_dec_mult > 0) {
+				tp->snd_cwnd = max_win;
+			}
+			if (ca->cwnd_growth_factor > 0)
+				ca->cwnd_growth_factor = 0;
+			ca->nv_no_cong_cnt = 0;
+		} else if (tp->snd_cwnd <= max_win - nv_pad_buffer) {
+			/* There is no congestion, wait before growing cwnd */
+			if (ca->nv_eval_call_cnt < nv_inc_eval_min_calls)
+				return;
+
+			ca->nv_allow_cwnd_growth = 1;
+			ca->nv_no_cong_cnt++;
+			if (ca->cwnd_growth_factor < 0 &&
+			    nv_cwnd_growth_rate_neg > 0 &&
+			    ca->nv_no_cong_cnt > nv_cwnd_growth_rate_neg) {
+				ca->cwnd_growth_factor++;
+				ca->nv_no_cong_cnt = 0;
+			} else if (ca->cwnd_growth_factor >= 0 &&
+				   nv_cwnd_growth_rate_pos > 0 &&
+				   ca->nv_no_cong_cnt >
+				   nv_cwnd_growth_rate_pos) {
+				ca->cwnd_growth_factor++;
+				ca->nv_no_cong_cnt = 0;
+			}
+		} else {
+			/* cwnd is in-between, so do nothing */
+			return;
+		}
+
+		/* update state */
+		ca->nv_eval_call_cnt = 0;
+		ca->nv_rtt_cnt = 0;
+		ca->nv_rtt_max_rate = 0;
+
+		/* Don't want to make cwnd < nv_min_cwnd
+		 * (it wasn't before, if it is now is because nv
+		 *  decreased it).
+		 */
+		if (tp->snd_cwnd < nv_min_cwnd)
+			tp->snd_cwnd = nv_min_cwnd;
+	}
+}
+
+/* Extract info for Tcp socket info provided via netlink */
+size_t tcpnv_get_info(struct sock *sk, u32 ext, int *attr,
+		      union tcp_cc_info *info)
+{
+	const struct tcpnv *ca = inet_csk_ca(sk);
+
+	if (ext & (1 << (INET_DIAG_VEGASINFO - 1))) {
+		info->vegas.tcpv_enabled = nv_enable;
+		info->vegas.tcpv_rttcnt = ca->nv_rtt_cnt;
+		info->vegas.tcpv_rtt = ca->nv_last_rtt;
+		info->vegas.tcpv_minrtt = ca->nv_min_rtt;
+
+		*attr = INET_DIAG_VEGASINFO;
+		return sizeof(struct tcpvegas_info);
+	}
+	return 0;
+}
+EXPORT_SYMBOL_GPL(tcpnv_get_info);
+
+static struct tcp_congestion_ops tcpnv __read_mostly = {
+	.init		= tcpnv_init,
+	.ssthresh	= tcpnv_recalc_ssthresh,
+	.cong_avoid	= tcpnv_cong_avoid,
+	.set_state	= tcpnv_state,
+	.undo_cwnd	= tcpnv_undo_cwnd,
+	.pkts_acked     = tcpnv_acked,
+	.get_info	= tcpnv_get_info,
+
+	.owner		= THIS_MODULE,
+	.name		= "nv",
+};
+
+static int __init tcpnv_register(void)
+{
+	BUILD_BUG_ON(sizeof(struct tcpnv) > ICSK_CA_PRIV_SIZE);
+
+	return tcp_register_congestion_control(&tcpnv);
+}
+
+static void __exit tcpnv_unregister(void)
+{
+	tcp_unregister_congestion_control(&tcpnv);
+}
+
+module_init(tcpnv_register);
+module_exit(tcpnv_unregister);
+
+MODULE_AUTHOR("Lawrence Brakmo");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("TCP NV");
+MODULE_VERSION("1.0");
-- 
2.8.0.rc2
