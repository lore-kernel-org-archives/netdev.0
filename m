From: Daniele Lacamera <mlists@danielinux.net>
Subject: Re: [PATCH] TCP Hybla
Date: Mon, 21 Mar 2005 12:50:07 +0100
Message-ID: <200503211250.07814.mlists@danielinux.net>
References: <20050318163123.14969084@dxpl.pdx.osdl.net>
Reply-To: mlists@danielinux.net
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_vTrPCXRNYzoQLAt"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050318163123.14969084@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--Boundary-00=_vTrPCXRNYzoQLAt
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Saturday 19 March 2005 01:31, Stephen Hemminger wrote:
> Here is a version of TCP Hybla based on the new split out of TCP
> algorithms. It doesn't work right, I probably broke something.
> 
> Original code for RTT0 was wrong because HZ=1000 on 2.6, so I changed
> it to be a parameter explicitly in ms.
> 
> Don't put it into production system till worked out.

This one is working. I've also made some changes. The cong_avoid checks 
for a flightsize not smaller than actual cwnd before giving the 
increment. Also, the tcp_reno_cong_avoid is called when not in 
TCP_CA_Open, as happens in vegas too. 

-- 
Signed-off by: Daniele Lacamera (root at danielinux.net)


--Boundary-00=_vTrPCXRNYzoQLAt
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="SH_tcpsplit_hybla.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="SH_tcpsplit_hybla.patch"

diff -ruN a/net/ipv4/Kconfig b/net/ipv4/Kconfig
--- a/net/ipv4/Kconfig	2005-03-21 12:17:59.000000000 +0100
+++ b/net/ipv4/Kconfig	2005-03-21 12:15:05.000000000 +0100
@@ -405,6 +405,16 @@
 	TCP Westwood+ significantly increases fairness wrt TCP Reno in 
 	wired networks and throughput over wireless links.   
 
+config TCP_CONG_HYBLA
+       tristate "TCP-Hybla congestion control algorithm"
+       depends on EXPERIMENTAL
+       default n
+       ---help---
+       TCP-Hybla is a sender-side only change that eliminates penalization of
+       long-RTT, large-bandwidth connections, like when satellite legs are
+       involved, expecially when sharing a common bottleneck with normal 
+       terrestrial connections.
+
 endmenu
 
 
diff -ruN a/net/ipv4/Makefile b/net/ipv4/Makefile
--- a/net/ipv4/Makefile	2005-03-21 12:17:37.000000000 +0100
+++ b/net/ipv4/Makefile	2005-03-21 12:15:05.000000000 +0100
@@ -27,6 +27,7 @@
 obj-$(CONFIG_TCP_CONG_VEGAS) += tcp_vegas.o
 obj-$(CONFIG_TCP_CONG_BIC) += tcp_bic.o
 obj-$(CONFIG_TCP_CONG_WESTWOOD) += tcp_westwood.o
+obj-$(CONFIG_TCP_CONG_HYBLA) += tcp_hybla.o
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
 		      xfrm4_output.o
diff -ruN a/net/ipv4/tcp_hybla.c b/net/ipv4/tcp_hybla.c
--- a/net/ipv4/tcp_hybla.c	1970-01-01 01:00:00.000000000 +0100
+++ b/net/ipv4/tcp_hybla.c	2005-03-21 12:15:06.000000000 +0100
@@ -0,0 +1,207 @@
+/*
+ * TCP HYBLA
+ *
+ * TCP-HYBLA Congestion control algorithm, based on:
+ *   C.Caini, R.Firrincieli, "TCP-Hybla: A TCP Enhancement
+ *   for Heterogeneous Networks",
+ *   International Journal on satellite Communications,
+ *                                     September 2004
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
+	u8    hybla_en;
+	u32   snd_cwnd_cents; /* Keeps increment values when it is <1, <<7 */
+	u32   rho;            /* Rho parameter, integer part  */
+	u32   rho2;           /* Rho * Rho, integer part */
+	u32   rho_3ls;        /* Rho parameter, <<3 */
+	u32   rho2_7ls;       /* Rho^2, <<7     */
+	u32   minrtt;         /* Minimum smoothed round trip time value seen */
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
+       struct hybla_ca *ca = tcp_ca(tp);
+
+	ca->rho_3ls = max_t(u32, tp->srtt / msecs_to_jiffies(rtt0), 8);
+	ca->rho = ca->rho_3ls >> 3;
+	ca->rho2_7ls = (ca->rho_3ls * ca->rho_3ls) << 1;
+	ca->rho2 = ca->rho2_7ls >>7;
+}
+
+
+static void hybla_start(struct tcp_sock *tp)
+{
+       struct hybla_ca *ca = tcp_ca(tp);
+
+       ca->rho = 0;
+       ca->rho2 = 0;
+       ca->rho_3ls = 0;
+       ca->rho2_7ls = 0;
+       ca->snd_cwnd_cents = 0;
+       ca->hybla_en = 1;
+
+       tp->snd_cwnd = 2;
+       tp->snd_cwnd_clamp=65535;
+}
+
+
+static void hybla_ca_state(struct tcp_sock *tp, u8 ca_state)
+{
+       struct hybla_ca *ca = tcp_ca(tp);
+	if (ca_state == TCP_CA_Open)
+		ca->hybla_en=1;
+	else
+		ca->hybla_en=0;
+}
+
+static inline u32 hybla_fraction(u32 odds)
+{
+       static const u32 fractions[] = {
+               128, 139, 152, 165, 181, 197, 215, 234,
+       };
+       
+       return (odds < ARRAY_SIZE(fractions)) ? fractions[odds] : 128;
+}
+
+/* TCP Hybla main routine.
+ * This is the algorithm behavior:
+ *     o Recalc Hybla parameters if min_rtt has changed
+ *     o Give cwnd a new value based on the model proposed
+ *     o remember increments <1        
+ */
+static void hybla_cong_avoid(struct tcp_sock *tp, u32 ack, u32 rtt, 
+                            u32 in_flight)
+{
+       struct hybla_ca *ca = tcp_ca(tp);
+       u32 increment, odd, rho_fractions;
+       int is_slowstart = 0;
+      
+	if(!ca->hybla_en)
+		return tcp_reno_cong_avoid(tp,ack,rtt,in_flight);
+	if (in_flight < tp->snd_cwnd)
+		return;
+       
+       if (ca->rho==0)
+               hybla_recalc_param(tp);
+       
+       rho_fractions = ca->rho_3ls - (ca->rho << 3);
+       
+       if (tp->snd_cwnd < tp->snd_ssthresh) {
+               /*
+                * slow start   
+                *      INC = 2^RHO - 1 
+                * This is done by splitting the rho parameter
+                * into 2 parts: an integer part and a fraction part.
+                * Inrement<<7 is estimated by doing:
+                *              [2^(int+fract)]<<7
+                * that is equal to:
+                *              (2^int)  *  [(2^fract) <<7]
+                * 2^int is straightly computed as 1<<int,
+                * while we will use hybla_slowstart_fraction_increment() to 
+                * calculate 2^fract in a <<7 value.
+                */
+               is_slowstart = 1;
+               increment = ((1 << ca->rho) * hybla_fraction(rho_fractions))
+                       - 128;
+       } else {
+               /*
+                * congestion avoidance         
+                * INC = RHO^2 / W              
+                * as long as increment is estimated as (rho<<7)/window
+                * it already is <<7 and we can easily count its fractions.
+                */     
+               increment = ca->rho2_7ls / tp->snd_cwnd;
+               if (increment < 128)
+                       tp->snd_cwnd_cnt++;
+       }
+
+       odd = increment % 128;
+       tp->snd_cwnd += increment >> 7;
+       ca->snd_cwnd_cents += odd;
+       
+       /* check when fractions goes >=128 and increase cwnd by 1. */
+       while(ca->snd_cwnd_cents >= 128) {
+               tp->snd_cwnd++;
+               ca->snd_cwnd_cents -= 128;
+               tp->snd_cwnd_cnt = 0;
+       }
+
+       /*clamp down slowstart cwnd to ssthresh value. */
+       if (is_slowstart)
+               tp->snd_cwnd = min(tp->snd_cwnd, tp->snd_ssthresh);
+       
+       tp->snd_cwnd = min_t(u32, tp->snd_cwnd, tp->snd_cwnd_clamp);
+}
+
+/*
+ * Update Values, if necessary, when a new
+ * smoothed RTT Estimation becomes available
+ */
+static void hybla_update_rtt(struct tcp_sock *tp, u32 m)
+{
+       struct hybla_ca *ca = tcp_ca(tp);
+
+       /* This sets rho to the smallest RTT received. */
+       if (tp->srtt) {
+               /*  Recalculate rho only if this srtt is the lowest */
+               if (tp->srtt < ca->minrtt){
+                       hybla_recalc_param(tp);
+                       ca->minrtt = tp->srtt;
+               }
+       } else {
+               /* 1st Rho measurement */
+               hybla_recalc_param(tp);
+
+               /* set minimum rtt as this is the 1st ever seen */
+               ca->minrtt = tp->srtt;
+               tp->snd_cwnd = ca->rho;
+       }
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
+	.set_state	= hybla_ca_state,
+
+	.owner		= THIS_MODULE,
+	.name		= "hybla"
+};
+
+static int __init hybla_init(void)
+{
+       BUG_ON(sizeof(struct hybla_ca) > TCP_CA_PRIV_SIZE);
+       tcp_ca_register(&tcp_hybla);
+       return 0;
+}
+
+static void __exit hybla_exit(void)
+{
+       tcp_ca_unregister(&tcp_hybla);
+}
+
+module_init(hybla_init);
+module_exit(hybla_exit);
+
+MODULE_AUTHOR("Daniele Lacamera");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("TCP Hybla");

--Boundary-00=_vTrPCXRNYzoQLAt--
