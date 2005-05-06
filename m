From: Baruch Even <baruch@ev-en.org>
Subject: [PATCH TCP 2/4] Implement H-TCP congestion control algorithm
Date: Fri,  6 May 2005 20:39:32 +0300 (IDT)
Message-ID: <20050506173932.20140.77512.44723@galon.ev-en.org>
References: <20050506173729.20140.93205.37072@galon.ev-en.org>
Cc: netdev@oss.sgi.com, Baruch Even <baruch@ev-en.org>,
        Douglas Leith <doug.leith@nuim.ie>,
        "David S.Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050506173729.20140.93205.37072@galon.ev-en.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

H-TCP is a congestion control algorithm developed at the Hamilton Institute, by
Douglas Leith and Robert Shorten. It is extending the standard Reno algorithm
with mode switching is thus a relatively simple modification.

H-TCP is defined in a layered manner as it is still a research platform. The
basic form includes the modification of beta according to the ratio of maxRTT
to min RTT and the alpha=2*factor*(1-beta) relation, where factor is dependant
on the time since last congestion.

The other layers improve convergence by adding appropriate factors to alpha.

The following patch implements the H-TCP algorithm in it's basic form.

Signed-Off-By: Baruch Even <baruch@ev-en.org>

---
 net/ipv4/Kconfig    |   10 ++
 net/ipv4/Makefile   |    1 
 net/ipv4/tcp_htcp.c |  198 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 209 insertions(+)

Index: 2.6.11-stephen-htcp/net/ipv4/tcp_htcp.c
===================================================================
--- /dev/null
+++ 2.6.11-stephen-htcp/net/ipv4/tcp_htcp.c
@@ -0,0 +1,198 @@
+/*
+ * H-TCP congestion control. The algorithm is detailed in:
+ * R.N.Shorten, D.J.Leith:
+ *   "H-TCP: TCP for high-speed and long-distance networks"
+ *   Proc. PFLDnet, Argonne, 2004.
+ * http://www.hamilton.ie/net/htcp3.pdf
+ */
+
+#include <linux/config.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <net/tcp.h>
+
+#define BETA_MIN	(1<<6)  /* 0.5 with shift << 7 */
+#define BETA_MAX	102	/* 0.8 with shift << 7 */
+
+struct htcp_ca {
+	u32	alpha;		/* Fixed point arith, << 7 */
+	u32	beta;           /* Fixed point arith, << 7 */
+	u32	modeswitch;     /* Delay modeswitch until we had at least one congestion event */
+	u32	ccount;		/* Number of RTTs since last congestion event */
+	u32	minRTT;
+	u32	maxRTT;
+
+	u32	undo_ccount;
+	u32	undo_maxRTT;
+};
+
+static inline void htcp_reset(struct htcp_ca *ca)
+{
+	ca->undo_ccount = ca->ccount;
+	ca->undo_maxRTT = ca->maxRTT;
+
+	ca->ccount = 0;
+}
+
+static u32 htcp_cwnd_undo(struct tcp_sock *tp)
+{
+	struct htcp_ca *ca = tcp_ca(tp);
+	ca->ccount = ca->undo_ccount;
+	ca->maxRTT = ca->undo_maxRTT;
+	return max(tp->snd_cwnd, (tp->snd_ssthresh<<7)/ca->beta);
+}
+
+static inline void measure_rtt(struct tcp_sock *tp)
+{
+	struct htcp_ca *ca = tcp_ca(tp);
+	u32 srtt = tp->srtt>>3;
+
+	/* keep track of minimum RTT seen so far, minRTT is zero at first */
+	if (ca->minRTT > srtt || !ca->minRTT)
+		ca->minRTT = srtt;
+
+	/* max RTT */
+	if (tp->ca_state == TCP_CA_Open && tp->snd_ssthresh < 0xFFFF && ca->ccount > 3) {
+		if (ca->maxRTT < ca->minRTT)
+			ca->maxRTT = ca->minRTT;
+		if (ca->maxRTT < srtt && srtt <= ca->maxRTT+HZ/50)
+			ca->maxRTT = srtt;
+	}
+}
+
+static inline void htcp_beta_update(struct htcp_ca *ca, u32 minRTT, u32 maxRTT)
+{
+	if (ca->modeswitch && minRTT > max(HZ/100, 1) && maxRTT) {
+		ca->beta = (minRTT<<7)/maxRTT;
+		if (ca->beta < BETA_MIN)
+			ca->beta = BETA_MIN;
+		else if (ca->beta > BETA_MAX)
+			ca->beta = BETA_MAX;
+	} else {
+		ca->beta = BETA_MIN;
+		ca->modeswitch = 1;
+	}
+}
+
+static inline void htcp_alpha_update(struct htcp_ca *ca, u32 minRTT)
+{
+	u32 factor = 1;
+	u32 diff = ca->ccount * minRTT; /* time since last backoff */
+
+	if (diff > HZ) {
+		diff -= HZ;
+		factor = 1+ ( 10*diff + ((diff/2)*(diff/2)/HZ) )/HZ;
+	}
+
+	ca->alpha = 2*factor*((1<<7)-ca->beta);
+	if (!ca->alpha)
+		ca->alpha = 1<<7;
+}
+
+/* After we have the rtt data to calculate beta, we'd still prefer to wait one
+ * rtt before we adjust our beta to ensure we are working from a consistent
+ * data.
+ *
+ * This function should be called when we hit a congestion event since only at
+ * that point do we really have a real sense of maxRTT (the queues en route
+ * were getting just too full now).
+ */
+static void htcp_param_update(struct tcp_sock *tp)
+{
+	struct htcp_ca *ca = tcp_ca(tp);
+	u32 minRTT = ca->minRTT;
+	u32 maxRTT = ca->maxRTT;
+
+	htcp_beta_update(ca, minRTT, maxRTT);
+	htcp_alpha_update(ca, minRTT);
+
+	/* add slowly fading memory for maxRTT to accommodate routing changes etc */
+	if (minRTT > 0 && maxRTT > minRTT)
+		ca->maxRTT = minRTT + ((maxRTT-minRTT)*95)/100;
+}
+
+static u32 htcp_recalc_ssthresh(struct tcp_sock *tp)
+{
+	struct htcp_ca *ca = tcp_ca(tp);
+	return max((tp->snd_cwnd * ca->beta) >> 7, 2U);
+}
+
+static void htcp_cong_avoid(struct tcp_sock *tp, u32 ack, u32 rtt, u32 in_flight)
+{
+	struct htcp_ca *ca = tcp_ca(tp);
+
+	if (in_flight < tp->snd_cwnd)
+		return;
+
+        if (tp->snd_cwnd <= tp->snd_ssthresh) {
+                /* In "safe" area, increase. */
+		if (tp->snd_cwnd < tp->snd_cwnd_clamp)
+			tp->snd_cwnd++;
+	} else {
+		measure_rtt(tp);
+
+                /* In dangerous area, increase slowly.
+		 * In theory this is tp->snd_cwnd += alpha / tp->snd_cwnd
+		 */
+		if (tp->snd_cwnd_cnt >= tp->snd_cwnd) {
+			if (tp->snd_cwnd < tp->snd_cwnd_clamp)
+				tp->snd_cwnd += ca->alpha;
+			tp->snd_cwnd_cnt = 0;
+			ca->ccount++;
+		} else
+			tp->snd_cwnd_cnt++;
+	}
+}
+
+static void htcp_start(struct tcp_sock *tp)
+{
+	struct htcp_ca *ca = tcp_ca(tp);
+	ca->alpha = 1<<7;
+	ca->beta = BETA_MIN;
+	ca->modeswitch = 0;
+	ca->ccount = 0;
+	ca->minRTT = 0;
+	ca->maxRTT = 0;
+}
+
+static void htcp_ca_state(struct tcp_sock *tp, u8 new_state)
+{
+	if (new_state == TCP_CA_CWR || new_state == TCP_CA_Recovery) {
+		htcp_param_update(tp);
+		htcp_reset(tcp_ca(tp));
+	} else if (new_state == TCP_CA_Loss) {
+		htcp_reset(tcp_ca(tp));
+	}
+}
+
+static struct tcp_ca_type htcp = {
+	.start		= htcp_start,
+	.ssthresh	= htcp_recalc_ssthresh,
+	.min_cwnd	= tcp_reno_cwnd_min,
+	.cong_avoid	= htcp_cong_avoid,
+	.set_state	= htcp_ca_state,
+	.undo_cwnd	= htcp_cwnd_undo,
+
+	.owner		= THIS_MODULE,
+	.name		= "htcp",
+};
+
+static int __init htcp_init(void)
+{
+	BUILD_BUG_ON(sizeof(struct htcp_ca) > TCP_CA_PRIV_SIZE);
+	BUILD_BUG_ON(BETA_MIN >= BETA_MAX);
+	tcp_ca_register(&htcp);
+	return 0;
+}
+
+static void __exit htcp_exit(void)
+{
+	tcp_ca_unregister(&htcp);
+}
+
+module_init(htcp_init);
+module_exit(htcp_exit);
+
+MODULE_AUTHOR("Baruch Even");
+MODULE_LICENSE("Unknown for now");
+MODULE_DESCRIPTION("H-TCP");
Index: 2.6.11-stephen-htcp/net/ipv4/Kconfig
===================================================================
--- 2.6.11-stephen-htcp.orig/net/ipv4/Kconfig
+++ 2.6.11-stephen-htcp/net/ipv4/Kconfig
@@ -405,6 +405,16 @@ config TCP_CONG_WESTWOOD
 	TCP Westwood+ significantly increases fairness wrt TCP Reno in 
 	wired networks and throughput over wireless links.   
 
+config TCP_CONG_HTCP
+	tristate "H-TCP"
+	default y
+	---help---
+	H-TCP is a send-side only modifications of the TCP Reno protocol stack
+	that optimizes the performance of TCP congestion control for high speed
+	network links. It uses a modeswitch to change the alpha and beta
+	parameters of TCP Reno based on network conditions and in a way so as
+	to be fair with other Reno and H-TCP flows.
+
 endmenu
 
 
Index: 2.6.11-stephen-htcp/net/ipv4/Makefile
===================================================================
--- 2.6.11-stephen-htcp.orig/net/ipv4/Makefile
+++ 2.6.11-stephen-htcp/net/ipv4/Makefile
@@ -24,6 +24,7 @@ obj-$(CONFIG_IP_PNP) += ipconfig.o
 obj-$(CONFIG_NETFILTER)	+= netfilter/
 obj-$(CONFIG_IP_VS) += ipvs/
 obj-$(CONFIG_IP_TCPDIAG) += tcp_diag.o 
+obj-$(CONFIG_TCP_CONG_HTCP) += tcp_htcp.o
 obj-$(CONFIG_TCP_CONG_VEGAS) += tcp_vegas.o
 obj-$(CONFIG_TCP_CONG_BIC) += tcp_bic.o
 obj-$(CONFIG_TCP_CONG_WESTWOOD) += tcp_westwood.o
