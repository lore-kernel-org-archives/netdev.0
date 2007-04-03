From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] TCP Illinois congestion control
Date: Tue, 3 Apr 2007 09:16:56 -0700
Message-ID: <20070403091656.769e5368@localhost.localdomain>
References: <20070312164311.13b5fcec@freekitty>
	<200703142247.l2EMln1o000338@expredir5.cites.uiuc.edu>
	<20070402201525.3d18a080@localhost.localdomain>
	<20070402.203937.59657200.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shaoliu@uiuc.edu, chaitanya_tk@tamu.edu, jgarrison@tamu.edu,
	srikant@ifp.uiuc.edu, tbasar@control.csl.uiuc.edu,
	jheffner@psc.edu, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:59724 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932985AbXDCQpe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2007 12:45:34 -0400
In-Reply-To: <20070402.203937.59657200.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a new implementation of TCP Illinois invented by Shao Liu
at University of Illinois. It is a another variant of Reno which adapts
the alpha and beta parameters based on RTT. The basic idea is to increase
window less rapidly as delay approaches the maximum. See the papers
and talks to get a more complete description.

Please consider for 2.6.22.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 net/ipv4/Kconfig        |   13 +++
 net/ipv4/Makefile       |    1 +
 net/ipv4/tcp_illinois.c |  212 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 226 insertions(+), 0 deletions(-)
 create mode 100644 net/ipv4/tcp_illinois.c

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index dc61e66..e62aee0 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -588,6 +588,19 @@ config TCP_CONG_YEAH
 	For further details look here:
 	  http://wil.cs.caltech.edu/pfldnet2007/paper/YeAH_TCP.pdf
 
+config TCP_CONG_ILLINOIS
+	tristate "TCP Illinois"
+	depends on EXPERIMENTAL
+	default n
+	---help---
+	TCP-Illinois is a sender-side modificatio of TCP Reno for
+	high speed long delay links. It uses round-trip-time to
+	adjust the alpha and beta parameters to achieve a higher average
+	throughput and maintain fairness.
+
+	For further details see:
+	  http://www.ews.uiuc.edu/~shaoliu/tcpillinois/index.html
+
 choice
 	prompt "Default TCP congestion control"
 	default DEFAULT_CUBIC
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index eeb94d5..4ff6c15 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -50,6 +50,7 @@ obj-$(CONFIG_TCP_CONG_VENO) += tcp_veno.o
 obj-$(CONFIG_TCP_CONG_SCALABLE) += tcp_scalable.o
 obj-$(CONFIG_TCP_CONG_LP) += tcp_lp.o
 obj-$(CONFIG_TCP_CONG_YEAH) += tcp_yeah.o
+obj-$(CONFIG_TCP_CONG_ILLINOIS) += tcp_illinois.o
 obj-$(CONFIG_NETLABEL) += cipso_ipv4.o
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
diff --git a/net/ipv4/tcp_illinois.c b/net/ipv4/tcp_illinois.c
new file mode 100644
index 0000000..f7c0b76
--- /dev/null
+++ b/net/ipv4/tcp_illinois.c
@@ -0,0 +1,212 @@
+/*
+ * TCP Illinois congestion control.
+ * Home page:
+ *	http://www.ews.uiuc.edu/~shaoliu/tcpillinois/index.html
+ *
+ * The algorithm is described in:
+ * "TCP-Illinois: A Loss and Delay-Based Congestion Control Algorithm
+ *  for High-Speed Networks"
+ *  http://www.ews.uiuc.edu/~shaoliu/papersandslides/tcpillinois_10pages.pdf
+ *
+ * Implemented from description in paper and ns-2 simulation.
+ * Copyright (C) 2007 Stephen Hemminger <shemminger@linux-foundation.org>
+ */
+
+#include <linux/module.h>
+#include <net/tcp.h>
+#include <linux/skbuff.h>
+#include <linux/inet_diag.h>
+
+#define ALPHA_SHIFT	7
+#define ALPHA_SCALE	(1u<<ALPHA_SHIFT)
+#define ALPHA_MIN	(ALPHA_SCALE/10)
+#define ALPHA_MAX	(10*ALPHA_SCALE)
+#define ALPHA_BASE	ALPHA_SCALE		/* 1.0 */
+
+#define BETA_SHIFT	6
+#define BETA_SCALE	(1u<<BETA_SHIFT)
+#define BETA_MIN	(BETA_SCALE/8)
+#define BETA_MAX	(BETA_SCALE/2)
+#define BETA_BASE	BETA_MAX		/* 0.5 */
+
+static int win_thresh __read_mostly = 15;
+module_param(win_thresh, int, 0644);
+MODULE_PARM_DESC(win_thresh, "Window threshold for starting adaptive sizing");
+
+/* TCP Illinois Parameters */
+struct tcp_illinois {
+	u32	min_rtt;
+	u32	max_rtt;
+	u32	avg_rtt;
+};
+
+static void tcp_illinois_init(struct sock *sk)
+{
+	struct tcp_illinois *ca = inet_csk_ca(sk);
+
+	ca->min_rtt = 0x7fffffff;
+}
+
+/*
+ * Keep track of min, max and average RTT
+ *
+ * In the paper, it implies that they want average of RTT over
+ * last window of packets. Doing that exactly would require too much
+ * memory (W samples). So we use a sliding average.
+ */
+static void tcp_illinois_rtt_calc(struct sock *sk, u32 rtt)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct tcp_illinois *ca = inet_csk_ca(sk);
+
+	/* Compute sliding average over last N packets */
+	ca->avg_rtt = (ca->avg_rtt * (tp->snd_cwnd-1) + rtt) / tp->snd_cwnd;
+
+	if (rtt < ca->min_rtt)
+		ca->min_rtt = rtt;
+
+	if (rtt > ca->max_rtt)
+		ca->max_rtt = rtt;
+}
+
+/*
+ * Compute value of alpha used for additive increase.
+ * If small window then use 1.0, equivalent to Reno.
+ *
+ * For larger windows, adjust based on average delay.
+ * A. If average delay is at minimum (we are uncongested),
+ *    then use large alpha (10.0) to increase faster.
+ * B. If average delay is at maximum (getting congested)
+ *    then use small alpha (1.0)
+ *
+ * The result is a convex window growth curve.
+ */
+static inline u32 alpha(const struct sock *sk)
+{
+	const struct tcp_sock *tp = tcp_sk(sk);
+	const struct tcp_illinois *ca = inet_csk_ca(sk);
+	u32 dm, da;
+
+	if (tp->snd_cwnd < win_thresh)
+		return ALPHA_BASE;	/* same as Reno (1.0) */
+
+	dm = ca->max_rtt - ca->min_rtt;	/* max queuing delay */
+	da = ca->avg_rtt - ca->min_rtt; /* avg queuing delay */
+
+	return (dm * ALPHA_MAX) /
+		(dm - (da  * (ALPHA_MAX - ALPHA_MIN)) / ALPHA_MIN);
+}
+
+/*
+ * Increase window in response to successful acknowledgment.
+ */
+static void tcp_illinois_cong_avoid(struct sock *sk, u32 ack, u32 rtt,
+				    u32 in_flight, int flag)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	/* RFC2861 only increase cwnd if fully utilized */
+	if (!tcp_is_cwnd_limited(sk, in_flight))
+		return;
+
+	/* In slow start */
+	if (tp->snd_cwnd <= tp->snd_ssthresh)
+		tcp_slow_start(tp);
+
+	else {
+		/* additive increase  cwnd += alpha / cwnd */
+		if ((tp->snd_cwnd_cnt * alpha(sk)) >> ALPHA_SHIFT >= tp->snd_cwnd) {
+			if (tp->snd_cwnd < tp->snd_cwnd_clamp)
+				tp->snd_cwnd++;
+			tp->snd_cwnd_cnt = 0;
+		} else
+			tp->snd_cwnd_cnt++;
+	}
+}
+
+/*
+ * Beta used for multiplicative decrease.
+ * For small window sizes returns same value as Reno (0.5)
+ * 
+ * If delay is small (10% of max) then beta = 1/8
+ * If delay is up to 80% of max then beta = 1/2
+ * In between is a linear function
+ */
+static inline u32 beta(const struct sock *sk)
+{
+	const struct tcp_sock *tp = tcp_sk(sk);
+	const struct tcp_illinois *ca = inet_csk_ca(sk);
+	u32 dm, d2, d3, da;
+
+	if (tp->snd_cwnd < win_thresh)
+		return BETA_BASE;
+
+	dm = ca->max_rtt - ca->min_rtt;
+	da = ca->avg_rtt - ca->min_rtt;
+
+	d2 = dm / 10;
+	if (da <= d2)
+		return BETA_MIN;
+	d3 = (8 * dm) / 10;
+	if (da >= d3 || d3 <= d2)
+		return BETA_MAX;
+
+	return (BETA_MIN * d3 - BETA_MAX * d2 + (BETA_MAX - BETA_MIN) * da)
+		/ (d3 - d2);
+}
+
+static u32 tcp_illinois_ssthresh(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	/* Multiplicative decrease */
+	return max((tp->snd_cwnd * beta(sk)) >> BETA_SHIFT, 2U);
+}
+
+/* Extract info for TCP socket info provided via netlink. 
+ * We aren't really doing Vegas, but we can provide RTT info
+ */
+static void tcp_illinois_get_info(struct sock *sk, u32 ext,
+			       struct sk_buff *skb)
+{
+	const struct tcp_illinois *ca = inet_csk_ca(sk);
+
+	if (ext & (1 << (INET_DIAG_VEGASINFO - 1))) {
+		struct tcpvegas_info info = {
+			.tcpv_enabled = 1,
+			.tcpv_rtt = ca->avg_rtt,
+			.tcpv_minrtt = ca->min_rtt,
+		};
+
+		nla_put(skb, INET_DIAG_VEGASINFO, sizeof(info), &info);
+	}
+}
+
+static struct tcp_congestion_ops tcp_illinois = {
+	.init		= tcp_illinois_init,
+	.ssthresh	= tcp_illinois_ssthresh,
+	.min_cwnd	= tcp_reno_min_cwnd,
+	.cong_avoid	= tcp_illinois_cong_avoid,
+	.rtt_sample	= tcp_illinois_rtt_calc,
+	.get_info	= tcp_illinois_get_info,
+
+	.owner		= THIS_MODULE,
+	.name		= "illinois",
+};
+
+static int __init tcp_illinois_register(void)
+{
+	return tcp_register_congestion_control(&tcp_illinois);
+}
+
+static void __exit tcp_illinois_unregister(void)
+{
+	tcp_unregister_congestion_control(&tcp_illinois);
+}
+
+module_init(tcp_illinois_register);
+module_exit(tcp_illinois_unregister);
+
+MODULE_AUTHOR("Stephen Hemminger, Shao Liu");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("Illinois TCP");
-- 
1.5.0.5

