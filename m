From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 5/5] TCP High speed support
Date: Fri, 18 Mar 2005 16:28:28 -0800
Message-ID: <20050318162828.29c52d5a@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Andrew Morton <akpm@digeo.com>, "David S. Miller" <davem@davemloft.net>,
        John Heffner <jheffner@psc.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

John Heffner ported the High speed TCP algorithm from Web100 to the
new pluggable infrastructure.  I just cleaned it up slightly.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/ipv4/Kconfig b/net/ipv4/Kconfig
--- a/net/ipv4/Kconfig	2005-03-18 16:11:16 -08:00
+++ b/net/ipv4/Kconfig	2005-03-18 16:11:16 -08:00
@@ -406,6 +406,17 @@
 	window. TCP Vegas should provide less packet loss, but it is
 	not as aggressive as TCP Reno.
 
+config TCP_CONG_HSTCP
+	tristate "High Speed TCP"
+	depends on EXPERIMENTAL
+	default n
+	---help---
+	Sally Floyd's High Speed TCP (RFC 3649) congestion control.
+	A modification to TCP's congestion control mechanism for use 
+	with large congestion windows. A table indicates how much to 
+	increase the congestion window by when an ACK is received.
+ 	For more detail	see http://www.icir.org/floyd/hstcp.html
+
 endmenu
 
 source "net/ipv4/ipvs/Kconfig"
diff -Nru a/net/ipv4/Makefile b/net/ipv4/Makefile
--- a/net/ipv4/Makefile	2005-03-18 16:11:16 -08:00
+++ b/net/ipv4/Makefile	2005-03-18 16:11:16 -08:00
@@ -27,6 +27,7 @@
 obj-$(CONFIG_TCP_CONG_BIC) += tcp_bic.o
 obj-$(CONFIG_TCP_CONG_WESTWOOD) += tcp_westwood.o
 obj-$(CONFIG_TCP_CONG_VEGAS) += tcp_vegas.o
+obj-$(CONFIG_TCP_CONG_HSTCP) += tcp_hstcp.o
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
 		      xfrm4_output.o
diff -Nru a/net/ipv4/tcp_hstcp.c b/net/ipv4/tcp_hstcp.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/net/ipv4/tcp_hstcp.c	2005-03-18 16:11:16 -08:00
@@ -0,0 +1,181 @@
+/*
+ * Sally Floyd's High Speed TCP (RFC 3649) congestion control
+ *
+ * See http://www.icir.org/floyd/hstcp.html
+ *
+ * John Heffner <jheffner@psc.edu>
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <net/tcp.h>
+
+
+/* From AIMD tables from RFC 3649 appendix B,
+ * with fixed-point MD scaled <<8.
+ */
+static const struct hstcp_aimd_val {
+        unsigned int cwnd;
+        unsigned int md;
+} hstcp_aimd_vals[] = {
+ {     38,  128, /*  0.50 */ },
+ {    118,  112, /*  0.44 */ },
+ {    221,  104, /*  0.41 */ },
+ {    347,   98, /*  0.38 */ },
+ {    495,   93, /*  0.37 */ },
+ {    663,   89, /*  0.35 */ },
+ {    851,   86, /*  0.34 */ },
+ {   1058,   83, /*  0.33 */ },
+ {   1284,   81, /*  0.32 */ },
+ {   1529,   78, /*  0.31 */ },
+ {   1793,   76, /*  0.30 */ },
+ {   2076,   74, /*  0.29 */ },
+ {   2378,   72, /*  0.28 */ },
+ {   2699,   71, /*  0.28 */ },
+ {   3039,   69, /*  0.27 */ },
+ {   3399,   68, /*  0.27 */ },
+ {   3778,   66, /*  0.26 */ },
+ {   4177,   65, /*  0.26 */ },
+ {   4596,   64, /*  0.25 */ },
+ {   5036,   62, /*  0.25 */ },
+ {   5497,   61, /*  0.24 */ },
+ {   5979,   60, /*  0.24 */ },
+ {   6483,   59, /*  0.23 */ },
+ {   7009,   58, /*  0.23 */ },
+ {   7558,   57, /*  0.22 */ },
+ {   8130,   56, /*  0.22 */ },
+ {   8726,   55, /*  0.22 */ },
+ {   9346,   54, /*  0.21 */ },
+ {   9991,   53, /*  0.21 */ },
+ {  10661,   52, /*  0.21 */ },
+ {  11358,   52, /*  0.20 */ },
+ {  12082,   51, /*  0.20 */ },
+ {  12834,   50, /*  0.20 */ },
+ {  13614,   49, /*  0.19 */ },
+ {  14424,   48, /*  0.19 */ },
+ {  15265,   48, /*  0.19 */ },
+ {  16137,   47, /*  0.19 */ },
+ {  17042,   46, /*  0.18 */ },
+ {  17981,   45, /*  0.18 */ },
+ {  18955,   45, /*  0.18 */ },
+ {  19965,   44, /*  0.17 */ },
+ {  21013,   43, /*  0.17 */ },
+ {  22101,   43, /*  0.17 */ },
+ {  23230,   42, /*  0.17 */ },
+ {  24402,   41, /*  0.16 */ },
+ {  25618,   41, /*  0.16 */ },
+ {  26881,   40, /*  0.16 */ },
+ {  28193,   39, /*  0.16 */ },
+ {  29557,   39, /*  0.15 */ },
+ {  30975,   38, /*  0.15 */ },
+ {  32450,   38, /*  0.15 */ },
+ {  33986,   37, /*  0.15 */ },
+ {  35586,   36, /*  0.14 */ },
+ {  37253,   36, /*  0.14 */ },
+ {  38992,   35, /*  0.14 */ },
+ {  40808,   35, /*  0.14 */ },
+ {  42707,   34, /*  0.13 */ },
+ {  44694,   33, /*  0.13 */ },
+ {  46776,   33, /*  0.13 */ },
+ {  48961,   32, /*  0.13 */ },
+ {  51258,   32, /*  0.13 */ },
+ {  53677,   31, /*  0.12 */ },
+ {  56230,   30, /*  0.12 */ },
+ {  58932,   30, /*  0.12 */ },
+ {  61799,   29, /*  0.12 */ },
+ {  64851,   28, /*  0.11 */ },
+ {  68113,   28, /*  0.11 */ },
+ {  71617,   27, /*  0.11 */ },
+ {  75401,   26, /*  0.10 */ },
+ {  79517,   26, /*  0.10 */ },
+ {  84035,   25, /*  0.10 */ },
+ {  89053,   24, /*  0.10 */ },
+};
+
+#define HSTCP_AIMD_MAX	ARRAY_SIZE(hstcp_aimd_vals)
+
+struct hstcp_ca {
+	u32	ai;
+};
+
+static void hstcp_start(struct tcp_sock *tp)
+{
+	struct hstcp_ca *ca = tcp_ca(tp);
+
+	ca->ai = 0;
+
+	/* Ensure the MD arithmetic works.  This is somewhat pedantic,
+	 * since I don't think we will see a cwnd this large. :) */
+	tp->snd_cwnd_clamp = min_t(u32, tp->snd_cwnd_clamp, 0xffffffff/128);
+}
+
+static void hstcp_cong_avoid(struct tcp_sock *tp, u32 adk, u32 rtt,
+			     u32 in_flight, int good)
+{
+	struct hstcp_ca *ca = tcp_ca(tp);
+
+	if (in_flight < tp->snd_cwnd)
+		return;
+
+	if (tp->snd_cwnd <= tp->snd_ssthresh) {
+		if (tp->snd_cwnd < tp->snd_cwnd_clamp)
+			tp->snd_cwnd++;
+	} else {
+		/* Update AIMD parameters */
+		if (tp->snd_cwnd > hstcp_aimd_vals[ca->ai].cwnd) {
+			while (tp->snd_cwnd > hstcp_aimd_vals[ca->ai].cwnd &&
+			       ca->ai < HSTCP_AIMD_MAX)
+				ca->ai++;
+		} else if (tp->snd_cwnd < hstcp_aimd_vals[ca->ai].cwnd) {
+			while (tp->snd_cwnd > hstcp_aimd_vals[ca->ai].cwnd &&
+			       ca->ai > 0)
+				ca->ai--;
+		}
+
+		/* Do additive increase */
+		if (tp->snd_cwnd < tp->snd_cwnd_clamp) {
+			tp->snd_cwnd_cnt += ca->ai;
+			if (tp->snd_cwnd_cnt >= tp->snd_cwnd) {
+				tp->snd_cwnd++;
+				tp->snd_cwnd_cnt -= tp->snd_cwnd;
+			}
+		}
+	}
+}
+
+static u32 hstcp_ssthresh(struct tcp_sock *tp)
+{
+	struct hstcp_ca *ca = tcp_ca(tp);
+
+	/* Do multiplicative decrease */
+	return max(tp->snd_cwnd - ((tp->snd_cwnd * hstcp_aimd_vals[ca->ai].md) >> 8), 2U);
+}
+
+static struct tcp_ca_type tcp_highspeed = {
+	.start		= hstcp_start,
+	.ssthresh	= hstcp_ssthresh,
+	.min_cwnd	= tcp_reno_cwnd_min,
+	.cong_avoid	= hstcp_cong_avoid,
+
+	.owner		= THIS_MODULE,
+	.name		= "highspeed"
+};
+
+static int __init hstcp_init(void)
+{
+	BUILD_BUG_ON(sizeof(struct hstcp_ca) > TCP_CA_PRIV_SIZE);
+	tcp_ca_register(&tcp_highspeed);
+	return 0;
+}
+
+static void __exit hstcp_exit(void)
+{
+	tcp_ca_unregister(&tcp_highspeed);
+}
+
+module_init(hstcp_init);
+module_exit(hstcp_exit);
+
+MODULE_AUTHOR("John Heffner");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("High Speed TCP");
