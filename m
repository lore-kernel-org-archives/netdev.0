From: mohamedalrshah <mohamed.a.alrshah@ieee.org>
Subject: [PATCH] Adding-Agile-SD-TCP-module-and-modifying-Kconfig-and-makefile
Date: Tue, 15 Aug 2017 21:08:06 +0800
Message-ID: <20170815130806.25168-1-mohamed.a.alrshah@ieee.org>
Cc: netdev@vger.kernel.org, torvalds@linux-foundation.org,
        linux-kernel@vger.kernel.org,
        "Mohamed A . Alrshah" <mohamed.a.alrshah@ieee.org>,
        Mohamed Othman <mothman@upm.edu.my>,
        Borhanuddin Ali <borhan@upm.edu.my>,
        Zurina Hanapi <zurinamh@upm.edu.my>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This commit implements a new TCP congestion control algorithm, namely Agile-SD. 
A detailed description of Agile-SD is published in the following 2 articles:

[1] "Agile-SD: a Linux-based TCP congestion control algorithm for supporting high-speed and short-distance networks",
Alrshah, M.A., Othman, M., Ali, B. and Hanapi, Z.M. Journal of Network and Computer Applications, Vol. 55, pages.181-190, May-June 2015. 

[2] "Modeling the Throughput of the Linux-Based Agile-SD Transmission Control Protocol",
Alrshah, M.A., Othman, M., Ali, B. and Hanapi, Z.M.
IEEE Access journal, Vol. 4, pages.9724-9732, Jan 2017.

The Internet has predominantly used Reno or CUBIC, relying on packet loss as the 
signal to slow down. While this worked well for many years, these congestion control 
algorithms are unfortunately unable to present an acceptable bandwidth utilization 
over today's networks. On today's Internet, data losses are very common and the 
existing congestion control algorithms are very sensitive to packet losses causing 
unwanted delay and retransmission of data. Also, the existing congestion control 
algorithms shows long epochs which affect the general performance of TCP.

Agile-SD has significantly increased throughput, reduced sensitivity to packet loss, 
and improved the ability to work with small and large buffers. Agile-SD shrinks the 
needed epoch time to recover after data loss, which improves throughput up to 50% in 
many cases, see [1,2]. 

Agile-SD is a Congestion Control Algorithm for High-speed Networks. Agile-SD is a 
loss-based and RTT-independent TCP congestion control algorithm designed to support 
high-speed networks. Agile-SD requires only changes on the sender side, not in the 
network or the receiver side. So, it can be incrementally deployed on today's Internet 
and/or in datacenters. Agile-SD introduces the Agility Factor Mechanism (AFM), which 
allows Agile-SD to deal with small buffer sizes while reducing its sensitivity to packet 
loss. Due to the use of this mechanism, Agile-SD improves the throughput of TCP up to 50% 
compared to Cubic-TCP and Compound-TCP in many cases, especially when the buffer is small 
and the data loss is common. Its performance was evaluated using simulation and testbed 
to measure the average throughput, loss ratio, and fairness.

Our long-term goal is to improve the congestion control algorithms used on the Internet. 
We are hopeful that Agile-SD can help advance the efforts toward this goal, and motivate 
the community to do further research.

Signed-off-by: Mohamed A. Alrshah <mohamed.a.alrshah@ieee.org>
Signed-off-by: Mohamed Othman <mothman@upm.edu.my>
Signed-off-by: Borhanuddin Ali <borhan@upm.edu.my>
Signed-off-by: Zurina Hanapi <zurinamh@upm.edu.my>

---
 net/ipv4/Kconfig       |  15 ++++
 net/ipv4/Makefile      |   1 +
 net/ipv4/tcp_agilesd.c | 193 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 209 insertions(+)
 create mode 100755 net/ipv4/tcp_agilesd.c

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 91a2557..474f72c 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -677,6 +677,17 @@ config TCP_CONG_BBR
 	bufferbloat, policers, or AQM schemes that do not provide a delay
 	signal. It requires the fq ("Fair Queue") pacing packet scheduler.
 
+config TCP_CONG_AGILESD
+        tristate "Agile-SD Congestion control"
+        default n
+        ---help---
+        
+        This is version 1.0 of Agile-SD TCP. It is a sender-side only. 
+        It contributes the Agility Factor (AF) to shorten the epoch time 
+        and to make TCP independent from RTT. AF reduces the sensitivity 
+        to packet losses, which in turn Agile-SD to achieve better throughput 
+        over high-speed networks.
+
 choice
 	prompt "Default TCP congestion control"
 	default DEFAULT_CUBIC
@@ -713,6 +724,9 @@ choice
 
 	config DEFAULT_BBR
 		bool "BBR" if TCP_CONG_BBR=y
+        
+        config DEFAULT_AGILESD
+		bool "AGILESD" if TCP_CONG_AGILESD=y
 
 	config DEFAULT_RENO
 		bool "Reno"
@@ -738,6 +752,7 @@ config DEFAULT_TCP_CONG
 	default "dctcp" if DEFAULT_DCTCP
 	default "cdg" if DEFAULT_CDG
 	default "bbr" if DEFAULT_BBR
+        default "agilesd" if DEFAULT_AGILESD
 	default "cubic"
 
 config TCP_MD5SIG
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index f83de23..33d398b 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -44,6 +44,7 @@ obj-$(CONFIG_INET_UDP_DIAG) += udp_diag.o
 obj-$(CONFIG_INET_RAW_DIAG) += raw_diag.o
 obj-$(CONFIG_NET_TCPPROBE) += tcp_probe.o
 obj-$(CONFIG_TCP_CONG_BBR) += tcp_bbr.o
+obj-$(CONFIG_TCP_CONG_AGILESD) += tcp_agilesd.o
 obj-$(CONFIG_TCP_CONG_BIC) += tcp_bic.o
 obj-$(CONFIG_TCP_CONG_CDG) += tcp_cdg.o
 obj-$(CONFIG_TCP_CONG_CUBIC) += tcp_cubic.o
diff --git a/net/ipv4/tcp_agilesd.c b/net/ipv4/tcp_agilesd.c
new file mode 100755
index 0000000..5de4779
--- /dev/null
+++ b/net/ipv4/tcp_agilesd.c
@@ -0,0 +1,193 @@
+/* Agile-SD is a Loss-Based Congestion Control Algorithm for High-speed Networks. 
+ * Agile-SD is a new loss-based and RTT-independent TCP congestion control algorithm 
+ * designed to support high-speed networks. It introduces the Agility Factor Mechanism (AFM), 
+ * which allows Agile-SD to deal with small buffer sizes while reducing its sensitivity to 
+ * packet loss. Due to the use of this mechanism, Agile-SD improves the throughput of TCP 
+ * up to 50% compared to Cubic-TCP and Compound-TCP in many cases, especially when the buffer 
+ * is small and the data loss is common. Its performance was evaluated using simulation and 
+ * testbed to measure the average throughput, loss ratio, and fairness.
+ * 
+ * Agile-SD is described in detail in: 
+ * "Agile-SD: a Linux-based TCP congestion control algorithm for supporting high-speed and short-distance networks",
+ * Alrshah, M.A., Othman, M., Ali, B. and Hanapi, Z.M. 
+ * Journal of Network and Computer Applications, Vol. 55, pages.181-190, May-June 2015. 
+ * 
+ * Moreover, Agile-SD performance has been mathematically proven in:
+ * "Modeling the Throughput of the Linux-Based Agile-SD Transmission Control Protocol",
+ * Alrshah, M.A., Othman, M., Ali, B. and Hanapi, Z.M.
+ * IEEE Access journal, Vol. 4, pages.9724-9732, Jan 2017.
+ */
+
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/math64.h>
+#include <net/tcp.h>
+
+#define SCALE   1000                    /* Scale factor to avoid fractions */
+#define Double_SCALE 1000000            /* Double_SCALE must be equal to SCALE^2 */
+#define beta    900                     /* beta for multiplicative decrease */
+
+/* Agile-SD Parameters */
+struct agilesdtcp {
+	u32	loss_cwnd;             /* congestion window at last loss.*/
+	u32	frac_tracer;           /* This is to trace the fractions of the increment.*/
+	u32	degraded_loss_cwnd;    /* loss_cwnd after degradation.*/
+	enum	dystate{SS=0, CA=1} agilesd_tcp_status;
+};
+
+/* To reset the parameters if needed*/
+static inline void agilesdtcp_reset(struct sock *sk)
+{
+
+}
+
+/* This function is called after the first acknowledgment is received and before the congestion
+ * control algorithm will be called for the first time. If the congestion control algorithm has
+ * private data, it should initialize its private date here. */
+static void agilesdtcp_init(struct sock *sk)
+{
+	struct agilesdtcp *ca = inet_csk_ca(sk);
+
+	/* The value of initial_ssthresh parameter is not used here, thus, snd_ssthresh is initialized by a large value.*/
+	tcp_sk(sk)->snd_ssthresh = 0x7fffffff;
+        
+	ca->loss_cwnd 		= 0;
+	ca->frac_tracer		= 0;
+	ca->agilesd_tcp_status 	= SS;
+}
+
+/* This function is called whenever an ack is received and the congestion window can be increased.
+ * This is equivalent to opencwnd in tcp.cc.
+ * ack is the number of bytes that are acknowledged in the latest acknowledgment;
+ * rtt is the the rtt measured by the latest acknowledgment;
+ * in_flight is the packet in flight before the latest acknowledgment;
+ * good_ack is an indicator whether the current situation is normal (no duplicate ack, no loss and no SACK). */
+static void agilesdtcp_cong_avoid(struct sock *sk, u32 ack, u32 in_flight)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	struct agilesdtcp *ca = inet_csk_ca(sk);
+	u32 inc_factor;
+	u32 ca_inc;
+	u32 current_gap, total_gap;
+	/* The value of inc_factor is limited by lower_fl and upper_fl.
+	 * The lower_fl must be always = 1. The greater the upper_fl the higher the aggressiveness.
+	 * But, if upper_fl set to 1, Agile-SD will work exactly as newreno.
+	 * We have already designed an equation to calculate the optimum upper_fl based on the given beta.
+	 * This equation will be revealed once its article is published*/
+	u32 lower_fl = 1 * SCALE;
+	u32 upper_fl = 3 * SCALE;
+
+	if (!tcp_is_cwnd_limited(sk)) return;
+	
+	if (tp->snd_cwnd < tp->snd_ssthresh){
+		ca->agilesd_tcp_status = SS;
+		tcp_slow_start(tp, in_flight);
+	}
+	else {
+		ca->agilesd_tcp_status = CA;
+
+		if (ca->loss_cwnd > ca->degraded_loss_cwnd)
+			total_gap = ca->loss_cwnd - ca->degraded_loss_cwnd;
+		else
+			total_gap = 1;
+
+		if (ca->loss_cwnd >  tp->snd_cwnd)
+			current_gap = ca->loss_cwnd - tp->snd_cwnd;
+		else
+			current_gap = 0;
+
+		inc_factor = min(max(((upper_fl * current_gap) / total_gap), lower_fl), upper_fl);
+
+		ca_inc = ((inc_factor * SCALE) / tp->snd_cwnd);   /* SCALE is used to avoid fractions*/
+
+		ca->frac_tracer += ca_inc;                        /* This in order to take the fraction increase into account */
+		if (ca->frac_tracer >= Double_SCALE)              /* To take factor scale into account */
+		{
+			tp->snd_cwnd += 1;
+			ca->frac_tracer -= Double_SCALE;
+		}
+	}
+}
+
+/* This function is called when the TCP flow detects a loss.
+ * It returns the slow start threshold of a flow, after a packet loss is detected. */
+static u32 agilesdtcp_recalc_ssthresh(struct sock *sk)
+{
+	const struct tcp_sock *tp = tcp_sk(sk);
+	struct agilesdtcp *ca = inet_csk_ca(sk);
+
+	ca->loss_cwnd = tp->snd_cwnd;
+
+	if (ca->agilesd_tcp_status == CA)
+		ca->degraded_loss_cwnd = max((tp->snd_cwnd * beta) / SCALE, 2U);
+	else
+		ca->degraded_loss_cwnd = max((tp->snd_cwnd * beta) / SCALE, 2U);
+
+	ca->frac_tracer = 0;
+
+	return ca->degraded_loss_cwnd;
+}
+
+static u32 agilesdtcp_undo_cwnd(struct sock *sk)
+{
+	const struct tcp_sock *tp = tcp_sk(sk);
+	const struct agilesdtcp *ca = inet_csk_ca(sk);
+	return max(tp->snd_cwnd, ca->loss_cwnd);
+}
+
+/* This function is called when the congestion state of the TCP is changed.
+ * newstate is the state code for the state that TCP is going to be in.
+ * The possible states are listed below:
+ * The current congestion control state, which can be one of the followings:
+ * TCP_CA_Open: normal state
+ * TCP_CA_Recovery: Loss Recovery after a Fast Transmission
+ * TCP_CA_Loss: Loss Recovery after a  Timeout
+ * (The following two states are not effective in TCP-Linux but is effective in Linux)
+ * TCP_CA_Disorder: duplicate packets detected, but haven't reach the threshold. So TCP  shall assume that  packet reordering is happening.
+ * TCP_CA_CWR: the state that congestion window is decreasing (after local congestion in NIC, or ECN and etc).
+ * It is to notify the congestion control algorithm and is used by some
+ * algorithms which turn off their special control during loss recovery. */
+static void agilesdtcp_state(struct sock *sk, u8 new_state)
+{
+	if (new_state == TCP_CA_Loss)
+		agilesdtcp_reset(inet_csk_ca(sk));
+}
+
+/* This function is called when there is an acknowledgment that acknowledges some new packets.
+ * num_acked is the number of packets that are acknowledged by this acknowledgments. */
+static void agilesdtcp_acked(struct sock *sk, u32 num_acked, s32 rtt_us)
+{
+
+}
+
+static struct tcp_congestion_ops agilesdtcp __read_mostly = {
+	.init		= agilesdtcp_init,
+	.ssthresh	= agilesdtcp_recalc_ssthresh,
+	.cong_avoid	= agilesdtcp_cong_avoid,
+	.set_state	= agilesdtcp_state,
+	.undo_cwnd	= agilesdtcp_undo_cwnd,
+	.pkts_acked	= agilesdtcp_acked,
+	.owner		= THIS_MODULE,
+	.name		= "agilesd",
+};
+
+static int __init agilesdtcp_register(void)
+{
+	BUILD_BUG_ON(sizeof(struct agilesdtcp) > ICSK_CA_PRIV_SIZE);
+	return tcp_register_congestion_control(&agilesdtcp);
+}
+
+static void __exit agilesdtcp_unregister(void)
+{
+	tcp_unregister_congestion_control(&agilesdtcp);
+}
+
+module_init(agilesdtcp_register);
+module_exit(agilesdtcp_unregister);
+
+MODULE_AUTHOR("Mohamed A. Alrshah <mohamed.a.alrshah@ieee.org>");
+MODULE_AUTHOR("Mohamed Othman");
+MODULE_AUTHOR("Borhanuddin Ali");
+MODULE_AUTHOR("Zurina Hanapi");
+MODULE_LICENSE("Dual BSD/GPL");
+MODULE_DESCRIPTION("Agile-SD is a Loss-Based Congestion Control Algorithm for High-speed Networks");
-- 
2.12.3
