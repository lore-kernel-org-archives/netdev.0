From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] Scalable TCP (cleaned)
Date: Thu, 2 Jun 2005 10:52:38 -0700
Message-ID: <20050602105238.69b6bcb3@dxpl.pdx.osdl.net>
References: <200505251550.42252.jheffner@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: John Heffner <jheffner@psc.edu>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@digeo.com>
In-Reply-To: <200505251550.42252.jheffner@psc.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here is a whitespace cleaned up version of John's scaleable TCP patch
to go with the other TCP congestion algorithms, to put in -mm.
--------
This patch implements Tom Kelly's Scalable TCP congestion control algorithm 
for the modular framework.

The algorithm has some nice scaling properties, and has been used a fair bit 
in research, though is known to have significant fairness issues, so it's not 
really suitable for general purpose use.

Signed-off-by: John Heffner <jheffner@psc.edu>


Index: 2.6.12-rc5-tcp3/net/ipv4/Makefile
===================================================================
--- 2.6.12-rc5-tcp3.orig/net/ipv4/Makefile
+++ 2.6.12-rc5-tcp3/net/ipv4/Makefile
@@ -35,6 +35,7 @@ obj-$(CONFIG_TCP_CONG_HSTCP) += tcp_high
 obj-$(CONFIG_TCP_CONG_HYBLA) += tcp_hybla.o
 obj-$(CONFIG_TCP_CONG_HTCP) += tcp_htcp.o
 obj-$(CONFIG_TCP_CONG_VEGAS) += tcp_vegas.o
+obj-$(CONFIG_TCP_CONG_SCALABLE) += tcp_scalable.o
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
 		      xfrm4_output.o
Index: 2.6.12-rc5-tcp3/net/ipv4/tcp_scalable.c
===================================================================
--- /dev/null
+++ 2.6.12-rc5-tcp3/net/ipv4/tcp_scalable.c
@@ -0,0 +1,68 @@
+/* Tom Kelly's Scalable TCP
+ *
+ * See htt://www-lce.eng.cam.ac.uk/~ctk21/scalable/
+ *
+ * John Heffner <jheffner@sc.edu>
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <net/tcp.h>
+
+/* These factors derived from the recommended values in the paper:
+ * .01 and and 7/8. We use 50 instead of 100 to account for
+ * delayed ack.
+ */
+#define TCP_SCALABLE_AI_CNT	50U
+#define TCP_SCALABLE_MD_SCALE	3
+
+static void tcp_scalable_cong_avoid(struct tcp_sock *tp, u32 ack, u32 rtt,
+				    u32 in_flight, int flag)
+{
+	if (in_flight < tp->snd_cwnd)
+		return;
+
+	if (tp->snd_cwnd <= tp->snd_ssthresh) {
+		tp->snd_cwnd++;
+	} else {
+		tp->snd_cwnd_cnt++;
+		if (tp->snd_cwnd_cnt > min(tp->snd_cwnd, TCP_SCALABLE_AI_CNT)){
+			tp->snd_cwnd++;
+			tp->snd_cwnd_cnt = 0;
+		}
+	}
+	tp->snd_cwnd = min_t(u32, tp->snd_cwnd, tp->snd_cwnd_clamp);
+	tp->snd_cwnd_stamp = tcp_time_stamp;
+}
+
+static u32 tcp_scalable_ssthresh(struct tcp_sock *tp)
+{
+	return max(tp->snd_cwnd - (tp->snd_cwnd>>TCP_SCALABLE_MD_SCALE), 2U);
+}
+
+
+static struct tcp_congestion_ops tcp_scalable = {
+	.ssthresh	= tcp_scalable_ssthresh,
+	.cong_avoid	= tcp_scalable_cong_avoid,
+	.min_cwnd	= tcp_reno_min_cwnd,
+
+	.owner		= THIS_MODULE,
+	.name		= "scalable",
+};
+
+static int __init tcp_scalable_register(void)
+{
+	return tcp_register_congestion_control(&tcp_scalable);
+}
+
+static void __exit tcp_scalable_unregister(void)
+{
+	tcp_unregister_congestion_control(&tcp_scalable);
+}
+
+module_init(tcp_scalable_register);
+module_exit(tcp_scalable_unregister);
+
+MODULE_AUTHOR("John Heffner");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("Scalable TCP");
Index: 2.6.12-rc5-tcp3/net/ipv4/Kconfig
===================================================================
--- 2.6.12-rc5-tcp3.orig/net/ipv4/Kconfig
+++ 2.6.12-rc5-tcp3/net/ipv4/Kconfig
@@ -481,6 +481,15 @@ config TCP_CONG_VEGAS
 	window. TCP Vegas should provide less packet loss, but it is
 	not as aggressive as TCP Reno.
 
+config TCP_CONG_SCALABLE
+	tristate "Scalable TCP"
+	depends on EXPERIMENTAL
+	default n
+	---help---
+	Scalable TCP is a sender-side only change to TCP which uses a
+	MIMD congestion control algorithm which has some nice scaling
+	properties, though is known to have fairness issues.
+	See http://www-lce.eng.cam.ac.uk/~ctk21/scalable/
 
 endmenu
 
