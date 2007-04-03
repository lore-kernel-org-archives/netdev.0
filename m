From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFC] TCP Illinois preliminary version
Date: Mon, 2 Apr 2007 20:15:25 -0700
Message-ID: <20070402201525.3d18a080@localhost.localdomain>
References: <20070312164311.13b5fcec@freekitty>
	<200703142247.l2EMln1o000338@expredir5.cites.uiuc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <chaitanya_tk@tamu.edu>, <jgarrison@tamu.edu>,
	"'Rayadurgam Srikant'" <srikant@ifp.uiuc.edu>,
	"'Tamer Basar'" <tbasar@control.csl.uiuc.edu>,
	John Heffner <jheffner@psc.edu>, netdev@vger.kernel.org
To: "Julian Shao Liu" <shaoliu@uiuc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:59052 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751234AbXDCDQk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2007 23:16:40 -0400
In-Reply-To: <200703142247.l2EMln1o000338@expredir5.cites.uiuc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Preliminary version if TCP Illinois for 2.6.22.
It needs more testing and refinement but it captures the
basic concepts.

---
 net/ipv4/Kconfig        |   13 +++
 net/ipv4/Makefile       |    1 +
 net/ipv4/tcp_illinois.c |  238 +++++++++++++++++++++++++++++++++++++++=
++++++++
 3 files changed, 252 insertions(+), 0 deletions(-)
 create mode 100644 net/ipv4/tcp_illinois.c

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index dc61e66..e62aee0 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -588,6 +588,19 @@ config TCP_CONG_YEAH
 	For further details look here:
 	  http://wil.cs.caltech.edu/pfldnet2007/paper/YeAH_TCP.pdf
=20
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
@@ -50,6 +50,7 @@ obj-$(CONFIG_TCP_CONG_VENO) +=3D tcp_veno.o
 obj-$(CONFIG_TCP_CONG_SCALABLE) +=3D tcp_scalable.o
 obj-$(CONFIG_TCP_CONG_LP) +=3D tcp_lp.o
 obj-$(CONFIG_TCP_CONG_YEAH) +=3D tcp_yeah.o
+obj-$(CONFIG_TCP_CONG_ILLINOIS) +=3D tcp_illinois.o
 obj-$(CONFIG_NETLABEL) +=3D cipso_ipv4.o
=20
 obj-$(CONFIG_XFRM) +=3D xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
diff --git a/net/ipv4/tcp_illinois.c b/net/ipv4/tcp_illinois.c
new file mode 100644
index 0000000..3536089
--- /dev/null
+++ b/net/ipv4/tcp_illinois.c
@@ -0,0 +1,238 @@
+/*
+ * TCP Illinois congestion control.
+ * Home page:
+ *	http://www.ews.uiuc.edu/~shaoliu/tcpillinois/index.html
+ *
+ * The algorithm is described in:
+ * "TCP-Illinois: A Loss and Delay-Based Congestion Control Algorithm
+ *  for High-Speed Networks"
+ *  http://www.ews.uiuc.edu/~shaoliu/papersandslides/tcpillinois_10pag=
es.pdf
+ *
+ * This implementation uses same constants as the ns-2 simulation.
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
+static int win_thresh __read_mostly =3D 10;
+module_param(win_thresh, int, 0644);
+MODULE_PARM_DESC(win_thresh, "Window threshold for starting adaptive s=
izing");
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
+	struct tcp_illinois *ca =3D inet_csk_ca(sk);
+
+	ca->min_rtt =3D 0x7fffffff;
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
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	struct tcp_illinois *ca =3D inet_csk_ca(sk);
+
+	/* Compute sliding average over last N packets */
+	ca->avg_rtt =3D (ca->avg_rtt * (tp->snd_cwnd-1) + rtt) / tp->snd_cwnd=
;
+
+	if (rtt < ca->min_rtt)
+		ca->min_rtt =3D rtt;
+
+	if (rtt > ca->max_rtt)
+		ca->max_rtt =3D rtt;
+}
+
+/*
+ * Compute value of alpha used for additive increase.
+ * If small window then use 1.0, equivalent to Reno.
+ *
+ * For larger windows, adjust based on average delay.
+ * A. If average delay is at mininum (we are uncongested),
+ *    then use large alpha (10.0) to increase faster.
+ * B. If average delay is at maximum (getting congested)
+ *    then use small alpha (1.0)
+ *
+ * Given dm is max delay, and da is average delay
+ * and we assume d1 as zero.
+ *
+ *      dm * =CE=B1min * =CE=B1max
+ * =CE=BA1 =3D ---------------------
+ *       =CE=B1max =E2=88=92 =CE=B1min
+ *                       =20
+ *       dm * =CE=B1min
+ * =CE=BA2 =3D ------------
+ *	 =CE=B1max =E2=88=92 =CE=B1min
+ *
+ *       =CE=BA1
+ * =CE=B1 =3D --------
+ *     =CE=BA2 + da
+ *
+ * The result is a convex window growth curve.
+ *=20
+ * Scaling notes:  value (scaled) [bits]
+ * 	ALPHA_MAX =3D 10.0 (1280) [11]
+ *	ALPHA_MIN =3D ~0.1 (12)  [4]
+ * 	delay max =3D 2 * 10^6 [21]
+ */
+static inline u32 alpha(const struct sock *sk)
+{
+	const struct tcp_sock *tp =3D tcp_sk(sk);
+	const struct tcp_illinois *ca =3D inet_csk_ca(sk);
+	u32 dm, k2;
+	u64 k1;
+
+	if (tp->snd_cwnd < win_thresh)
+		return ALPHA_BASE;	/* same as Reno (1.0) */
+
+	dm =3D ca->max_rtt - ca->min_rtt;
+	k1 =3D (u64) dm * (u64)(ALPHA_MAX * ALPHA_MIN);
+	k2 =3D dm * ALPHA_MIN;
+	k2 +=3D (ca->avg_rtt - ca->min_rtt) * (ALPHA_MAX - ALPHA_MIN);
+
+	do_div(k1, k2);
+
+	return k1;
+}
+
+/*
+ * Increase window in response to successful acknowledgment.
+ */
+static void tcp_illinois_cong_avoid(struct sock *sk, u32 ack, u32 rtt,
+				    u32 in_flight, int flag)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+
+	/* RFC2861 only increase cwnd if fully utilized */
+	if (!tcp_is_cwnd_limited(sk, in_flight))
+		return;
+
+	/* In slow start */
+	if (tp->snd_cwnd <=3D tp->snd_ssthresh)
+		tcp_slow_start(tp);
+
+	else {
+		/* additive increase  cwnd +=3D alpha / cwnd */
+		if ((tp->snd_cwnd_cnt * alpha(sk)) >> ALPHA_SHIFT >=3D tp->snd_cwnd)=
 {
+			if (tp->snd_cwnd < tp->snd_cwnd_clamp)
+				tp->snd_cwnd++;
+			tp->snd_cwnd_cnt =3D 0;
+		} else
+			tp->snd_cwnd_cnt++;
+	}
+}
+
+/*
+ * Beta used for multiplicative decrease.
+ * For small window sizes returns same value as Reno (0.5)
+ *=20
+ * If delay is small (10% of max) then beta =3D 1/8
+ * If delay is up to 80% of max then beta =3D 1/2
+ * In between is a linear function
+ */
+static inline u32 beta(const struct sock *sk)
+{
+	const struct tcp_sock *tp =3D tcp_sk(sk);
+	const struct tcp_illinois *ca =3D inet_csk_ca(sk);
+	u32 dm, d2, d3, da;
+
+	if (tp->snd_cwnd < win_thresh)
+		return BETA_BASE;
+
+	/* max delay (ie most congested) */
+	dm =3D ca->max_rtt - ca->min_rtt;
+	/* average delay */
+	da =3D ca->avg_rtt - ca->min_rtt;
+
+	d2 =3D dm / 10;
+	if (da < d2)
+		return BETA_MIN;
+	d3 =3D (8 * dm) / 10;
+	if (da > d3)
+		return BETA_MAX;
+
+	return ((BETA_MIN * d3 - BETA_MAX * d2) + BETA_MAX - BETA_MIN) /
+		max(d3 - d2, 1U);
+
+}
+
+static u32 tcp_illinois_ssthresh(struct sock *sk)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+
+	/* Multiplicative decrease */
+	return max((tp->snd_cwnd * beta(sk)) >> BETA_SHIFT, 2U);
+}
+
+/* Extract info for Tcp socket info provided via netlink.=20
+ * We aren't really doing Vegas, but we can provide RTT info
+ */
+static void tcp_illinois_get_info(struct sock *sk, u32 ext,
+			       struct sk_buff *skb)
+{
+	const struct tcp_illinois *ca =3D inet_csk_ca(sk);
+
+	if (ext & (1 << (INET_DIAG_VEGASINFO - 1))) {
+		struct tcpvegas_info info =3D {
+			.tcpv_enabled =3D 1,
+			.tcpv_rtt =3D ca->avg_rtt,
+			.tcpv_minrtt =3D ca->min_rtt,
+		};
+
+		nla_put(skb, INET_DIAG_VEGASINFO, sizeof(info), &info);
+	}
+}
+
+static struct tcp_congestion_ops tcp_illinois =3D {
+	.init		=3D tcp_illinois_init,
+	.ssthresh	=3D tcp_illinois_ssthresh,
+	.min_cwnd	=3D tcp_reno_min_cwnd,
+	.cong_avoid	=3D tcp_illinois_cong_avoid,
+	.rtt_sample	=3D tcp_illinois_rtt_calc,
+	.get_info	=3D tcp_illinois_get_info,
+
+	.owner		=3D THIS_MODULE,
+	.name		=3D "illinois",
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
--=20
1.5.0.5

