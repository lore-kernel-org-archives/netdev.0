From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] TCP Hybla
Date: Fri, 18 Mar 2005 16:31:23 -0800
Message-ID: <20050318163123.14969084@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>,
        Daniele Lacamera
 <mlists@danielinux.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here is a version of TCP Hybla based on the new split out of TCP
algorithms. It doesn't work right, I probably broke something.

Original code for RTT0 was wrong because HZ=1000 on 2.6, so I changed
it to be a parameter explicitly in ms.

Don't put it into production system till worked out.


diff -Nru a/net/ipv4/Kconfig b/net/ipv4/Kconfig
--- a/net/ipv4/Kconfig	2005-03-18 16:11:27 -08:00
+++ b/net/ipv4/Kconfig	2005-03-18 16:11:27 -08:00
@@ -417,6 +417,16 @@
 	increase the congestion window by when an ACK is received.
  	For more detail	see http://www.icir.org/floyd/hstcp.html
 
+config TCP_CONG_HYBLA
+	tristate "TCP-Hybla congestion control algorithm"
+	depends on EXPERIMENTAL
+	default n
+	---help---
+	TCP-Hybla is a sender-side only change that eliminates penalization of
+	long-RTT, large-bandwidth connections, like when satellite legs are
+	involved, expecially when sharing a common bottleneck with normal 
+	terrestrial connections.
+
 endmenu
 
 source "net/ipv4/ipvs/Kconfig"
diff -Nru a/net/ipv4/Makefile b/net/ipv4/Makefile
--- a/net/ipv4/Makefile	2005-03-18 16:11:27 -08:00
+++ b/net/ipv4/Makefile	2005-03-18 16:11:27 -08:00
@@ -28,6 +28,7 @@
 obj-$(CONFIG_TCP_CONG_WESTWOOD) += tcp_westwood.o
 obj-$(CONFIG_TCP_CONG_VEGAS) += tcp_vegas.o
 obj-$(CONFIG_TCP_CONG_HSTCP) += tcp_hstcp.o
+obj-$(CONFIG_TCP_CONG_HYBLA) += tcp_hybla.o
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
 		      xfrm4_output.o
diff -Nru a/net/ipv4/tcp_hybla.c b/net/ipv4/tcp_hybla.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/net/ipv4/tcp_hybla.c	2005-03-18 16:11:27 -08:00
@@ -0,0 +1,191 @@
+/*
+ * TCP HYBLA
+ *
+ * TCP-HYBLA Congestion control algorithm, based on:
+ *   C.Caini, R.Firrincieli, "TCP-Hybla: A TCP Enhancement
+ *   for Heterogeneous Networks",
+ *   International Journal on satellite Communications,
+ *					September 2004
+ *    Daniele Lacamera
+ *    root at danielinux.net
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <net/tcp.h>
+
+/* Tcp Hybla structure. */
+struct hybla_ca {
+	u32   snd_cwnd_cents; /* Keeps increment values when it is <1, <<7 */
+	u32   rho;	      /* Rho parameter, integer part  */
+	u32   rho2;	      /* Rho * Rho, integer part */
+	u32   rho_3ls;	      /* Rho parameter, <<3 */
+	u32   rho2_7ls;	      /* Rho^2, <<7	*/
+	u32   minrtt;	      /* Minimum smoothed round trip time value seen */
+};
+
+/* Hybla reference round trip time (default= 1/40 sec = 25 ms), 
+   expressed in jiffies */
+static int rtt0 = 25;
+module_param(rtt0, int, 0644);
+MODULE_PARM_DESC(rtt0, "reference rout trip time (ms)");
+
+
+/* This is called to refresh values for hybla parameters */
+static inline void hybla_recalc_param (struct tcp_sock *tp)
+{
+	struct hybla_ca *ca = tcp_ca(tp);
+
+	ca->rho_3ls = max_t(u32, tp->srtt / msecs_to_jiffies(rtt0), 8);
+	ca->rho = ca->rho_3ls >> 3;
+	ca->rho2_7ls = (ca->rho_3ls * ca->rho_3ls) << 1;
+	ca->rho2 = ca->rho2_7ls >>7;
+
+	tp->snd_cwnd_clamp = min_t(u16, tp->snd_cwnd_clamp, ca->rho << 16);
+}
+
+
+static void hybla_start(struct tcp_sock *tp)
+{
+	struct hybla_ca *ca = tcp_ca(tp);
+
+	ca->rho = 0;
+	ca->rho2 = 0;
+	ca->rho_3ls = 0;
+	ca->rho2_7ls = 0;
+	ca->snd_cwnd_cents = 0;
+
+	tp->snd_cwnd = 2;
+}
+
+
+static inline u32 hybla_fraction(u32 odds)
+{
+	static const u32 fractions[] = {
+		128, 139, 152, 165, 181, 197, 215, 234,
+	};
+	
+	return (odds < ARRAY_SIZE(fractions)) ? fractions[odds] : 128;
+}
+
+/* TCP Hybla main routine.
+ * This is the algorithm behavior:
+ *	o Recalc Hybla parameters if min_rtt has changed
+ *	o Give cwnd a new value based on the model proposed
+ *	o remember increments <1	
+ */
+static void hybla_cong_avoid(struct tcp_sock *tp, u32 ack, u32 rtt, 
+			     u32 in_flight, int good)
+{
+	struct hybla_ca *ca = tcp_ca(tp);
+	u32 increment, odd, rho_fractions;
+	int is_slowstart = 0;
+	
+	if (ca->rho==0)
+		hybla_recalc_param(tp);
+	
+	rho_fractions = ca->rho_3ls - (ca->rho << 3);
+	
+	if (tp->snd_cwnd < tp->snd_ssthresh) {
+		/*
+		 * slow start	
+		 *	INC = 2^RHO - 1 
+		 * This is done by splitting the rho parameter
+		 * into 2 parts: an integer part and a fraction part.
+		 * Inrement<<7 is estimated by doing:
+		 *		[2^(int+fract)]<<7
+		 * that is equal to:
+		 *		(2^int)	 *  [(2^fract) <<7]
+		 * 2^int is straightly computed as 1<<int,
+		 * while we will use hybla_slowstart_fraction_increment() to 
+		 * calculate 2^fract in a <<7 value.
+		 */
+		is_slowstart = 1;
+		increment = ((1 << ca->rho) * hybla_fraction(rho_fractions))
+			- 128;
+	} else {
+		/*
+		 * congestion avoidance		
+		 * INC = RHO^2 / W		
+		 * as long as increment is estimated as (rho<<7)/window
+		 * it already is <<7 and we can easily count its fractions.
+		 */	
+		increment = ca->rho2_7ls / tp->snd_cwnd;
+		if (increment < 128)
+			tp->snd_cwnd_cnt++;
+	}
+
+	odd = increment % 128;
+	tp->snd_cwnd += increment >> 7;
+	ca->snd_cwnd_cents += odd;
+	
+	/* check when fractions goes >=128 and increase cwnd by 1. */
+	while(ca->snd_cwnd_cents >= 128) {
+		tp->snd_cwnd++;
+		ca->snd_cwnd_cents -= 128;
+		tp->snd_cwnd_cnt = 0;
+	}
+
+	/*clamp down slowstart cwnd to ssthresh value. */
+	if (is_slowstart)
+		tp->snd_cwnd = min(tp->snd_cwnd, tp->snd_ssthresh);
+	
+	tp->snd_cwnd = min_t(u32, tp->snd_cwnd, tp->snd_cwnd_clamp);
+}
+
+/*
+ * Update Values, if necessary, when a new
+ * smoothed RTT Estimation becomes available
+ */
+static void hybla_update_rtt(struct tcp_sock *tp, u32 m)
+{
+	struct hybla_ca *ca = tcp_ca(tp);
+
+	/* This sets rho to the smallest RTT received. */
+	if (tp->srtt) {
+		/*  Recalculate rho only if this srtt is the lowest */
+		if (tp->srtt < ca->minrtt){
+			hybla_recalc_param(tp);
+			ca->minrtt = tp->srtt;
+		}
+	} else {
+		/* 1st Rho measurement */
+		hybla_recalc_param(tp);
+
+		/* set minimum rtt as this is the 1st ever seen */
+		ca->minrtt = tp->srtt;
+		tp->snd_cwnd = ca->rho;
+	}
+}
+
+
+
+static struct tcp_ca_type tcp_hybla = {
+	.start		= hybla_start,
+	.ssthresh	= tcp_reno_ssthresh,
+	.min_cwnd	= tcp_reno_cwnd_min,
+	.cong_avoid	= hybla_cong_avoid,
+	.rtt_sample	= hybla_update_rtt,
+
+	.owner		= THIS_MODULE,
+	.name		= "hybla"
+};
+
+static int __init hybla_init(void)
+{
+	BUG_ON(sizeof(struct hybla_ca) > TCP_CA_PRIV_SIZE);
+	tcp_ca_register(&tcp_hybla);
+	return 0;
+}
+
+static void __exit hybla_exit(void)
+{
+	tcp_ca_unregister(&tcp_hybla);
+}
+
+module_init(hybla_init);
+module_exit(hybla_exit);
+
+MODULE_AUTHOR("Daniele Lacmera");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("High Speed TCP");
