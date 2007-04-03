From: "Julian Shao Liu" <shaoliu@uiuc.edu>
Subject: RE: [PATCH] TCP Illinois congestion control
Date: Tue, 3 Apr 2007 16:13:31 -0500
Message-ID: <200704032113.l33LDVhp025035@expredir6.cites.uiuc.edu>
References: <20070403091656.769e5368@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <chaitanya_tk@tamu.edu>, <jgarrison@tamu.edu>,
	<srikant@ifp.uiuc.edu>, <tbasar@control.csl.uiuc.edu>,
	<jheffner@psc.edu>, <netdev@vger.kernel.org>
To: "'Stephen Hemminger'" <shemminger@linux-foundation.org>,
	"'David Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from expredir6.cites.uiuc.edu ([128.174.5.97]:35507 "EHLO
	expredir6.cites.uiuc.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945948AbXDCVOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2007 17:14:36 -0400
In-Reply-To: <20070403091656.769e5368@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

Thanks for the implementation. I have checked the codes, and I have the
following comments:

1, The math is basically correct in computing alpha and beta from da.

2, In the computation of da, you implicitly set d1=0. Setting d1=0 is a
conservative approach, although it also works well (it may lead to a longer
convergence time than a positive d1). The reason is that, even if far from
congestion, there are some burstiness in RTT measurements, and we get
da>d_min. This way, we have an alpha<alpha_max even if congestion is far
away. We choose d1 to be close to 0 in our simulations for conservativeness,
but we believe even if d1 is non-trivial positive, like 0.05*dm, it should
work, and it might work better.

3, There is one more feature in TCP-Illinois: to avoid setting alpha to be
alpha_max if actually the congestion level is high and the small queueing
delay is due to noise. We have explained that in our updated version of the
paper, available at 
http://www.ews.uiuc.edu/~shaoliu/papersandslides/liubassri06perf.pdf
We have also implemented this feature in our ns-2 code. The basic idea of
this feature is that, once da exceeds d1 and alpha<alpha_max, we know that
congestion level is not very low. Once this happen, the congestion level
should not drop unless some user has experienced a packet loss and backed
off its window size. If that is the case, da should drop to below d1 for a
long time. If, however, da drops to below d1 suddenly, but increases back to
above d1 soon, we predict that congestion is not alleviated, and the small
da measurement comes from noise. Under this case, we should not set
alpha=alpha_max, but should set it to be its previous legitimate value.

We believe that this feature is important if there is noise in delay
measurement and if d1 is set to be nonzero. Even if d1 is set to be zero, we
think this feature should be included if the noise is delay measurement is
significant. Under this case, we can modify the feature a little bit: alpha
is initially computed to be around alpha_max when congestion is far. As da
increases, alpha decreases. But alpha cannot be increased as soon as da
drops. Alpha can only be increased if the decrease trend of da last for a
certain period.

4, In your implementation, you set alpha_max=10 and alpha_min=0.1. Although
this parameter setting is chosen by our paper, we suggest you try some
different values, especially for alpha_min. An alpha_min from 0.2 to 0.5
might be a better choice, as this will make the convergence time faster.

Please feel free to tell me if you have any related questions.

Thanks!

Best regards!
 
Yours sincerely,
Shao Liu (Julian)
 
University of Illinois at Urbana Champaign
Coordinated Science Laboratory and Department of Electrical and Computer
Engineering
www.ews.uiuc.edu/~shaoliu

-----Original Message-----
From: Stephen Hemminger [mailto:shemminger@linux-foundation.org] 
Sent: Tuesday, April 03, 2007 11:17 AM
To: David Miller
Cc: shaoliu@uiuc.edu; chaitanya_tk@tamu.edu; jgarrison@tamu.edu;
srikant@ifp.uiuc.edu; tbasar@control.csl.uiuc.edu; jheffner@psc.edu;
netdev@vger.kernel.org
Subject: [PATCH] TCP Illinois congestion control

This is a new implementation of TCP Illinois invented by Shao Liu at
University of Illinois. It is a another variant of Reno which adapts the
alpha and beta parameters based on RTT. The basic idea is to increase window
less rapidly as delay approaches the maximum. See the papers and talks to
get a more complete description.

Please consider for 2.6.22.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 net/ipv4/Kconfig        |   13 +++
 net/ipv4/Makefile       |    1 +
 net/ipv4/tcp_illinois.c |  212
+++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 226 insertions(+), 0 deletions(-)  create mode 100644
net/ipv4/tcp_illinois.c

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig index dc61e66..e62aee0
100644
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
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile index eeb94d5..4ff6c15
100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -50,6 +50,7 @@ obj-$(CONFIG_TCP_CONG_VENO) += tcp_veno.o
 obj-$(CONFIG_TCP_CONG_SCALABLE) += tcp_scalable.o
 obj-$(CONFIG_TCP_CONG_LP) += tcp_lp.o
 obj-$(CONFIG_TCP_CONG_YEAH) += tcp_yeah.o
+obj-$(CONFIG_TCP_CONG_ILLINOIS) += tcp_illinois.o
 obj-$(CONFIG_NETLABEL) += cipso_ipv4.o
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \ diff
--git a/net/ipv4/tcp_illinois.c b/net/ipv4/tcp_illinois.c new file mode
100644 index 0000000..f7c0b76
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
+ *  
+http://www.ews.uiuc.edu/~shaoliu/papersandslides/tcpillinois_10pages.pd
+f
+ *
+ * Implemented from description in paper and ns-2 simulation.
+ * Copyright (C) 2007 Stephen Hemminger 
+<shemminger@linux-foundation.org>  */
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
+static int win_thresh __read_mostly = 15; module_param(win_thresh, int, 
+0644); MODULE_PARM_DESC(win_thresh, "Window threshold for starting 
+adaptive sizing");
+
+/* TCP Illinois Parameters */
+struct tcp_illinois {
+	u32	min_rtt;
+	u32	max_rtt;
+	u32	avg_rtt;
+};
+
+static void tcp_illinois_init(struct sock *sk) {
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
+static void tcp_illinois_rtt_calc(struct sock *sk, u32 rtt) {
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
+static inline u32 alpha(const struct sock *sk) {
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
+		(dm - (da  * (ALPHA_MAX - ALPHA_MIN)) / ALPHA_MIN); }
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
+		if ((tp->snd_cwnd_cnt * alpha(sk)) >> ALPHA_SHIFT >=
tp->snd_cwnd) {
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
+static inline u32 beta(const struct sock *sk) {
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
+static u32 tcp_illinois_ssthresh(struct sock *sk) {
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	/* Multiplicative decrease */
+	return max((tp->snd_cwnd * beta(sk)) >> BETA_SHIFT, 2U); }
+
+/* Extract info for TCP socket info provided via netlink. 
+ * We aren't really doing Vegas, but we can provide RTT info  */ static 
+void tcp_illinois_get_info(struct sock *sk, u32 ext,
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
+static int __init tcp_illinois_register(void) {
+	return tcp_register_congestion_control(&tcp_illinois);
+}
+
+static void __exit tcp_illinois_unregister(void) {
+	tcp_unregister_congestion_control(&tcp_illinois);
+}
+
+module_init(tcp_illinois_register);
+module_exit(tcp_illinois_unregister);
+
+MODULE_AUTHOR("Stephen Hemminger, Shao Liu"); MODULE_LICENSE("GPL"); 
+MODULE_DESCRIPTION("Illinois TCP");
--
1.5.0.5

