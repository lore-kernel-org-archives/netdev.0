From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] BIC TCP for Linux 2.6.6
Date: Fri, 7 May 2004 16:09:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040507160957.22d46527@dell_ss3.pdx.osdl.net>
References: <00b601c42638$04ecac20$96330e98@VALUED66329DCC>
	<01d101c4263a$2a51d060$8c330e98@nanegrc>
	<20040429153811.56d410e3@dell_ss3.pdx.osdl.net>
	<003b01c42e52$6e317ef0$20339804@Nannan>
	<20040505155538.0d414cae@dell_ss3.pdx.osdl.net>
	<000701c43383$2f6bc1e0$8c330e98@nanegrc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Lisong Xu" <lxu2@unity.ncsu.edu>, "Injong Rhee" <rhee@csc.ncsu.edu>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <000701c43383$2f6bc1e0$8c330e98@nanegrc>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a version of Binary Increase Control (BIC) TCP
developed by NCSU.   It is yet another TCP congestion control
algorithm for handling big fat pipes. For normal size congestion
windows it behaves the same as existing TCP Reno, but when window
is large it uses additive increase to ensure fairness and when
window is small it uses binary search increase.

For more details see the BIC TCP web page
 http://www.csc.ncsu.edu/faculty/rhee/export/bitcp/

The original code was for web100 (2.4); this version is pretty
much the same but targeted for 2.6 with less sysctl parameters 
and more constants.

I don't have a real high speed long haul network to test, but
when running over 1G links with delays, the performance is more stable
(ie tests are repeatable) and as fast as existing Reno.


diff -Nru a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
--- a/Documentation/networking/ip-sysctl.txt	Fri May  7 15:56:15 2004
+++ b/Documentation/networking/ip-sysctl.txt	Fri May  7 15:56:15 2004
@@ -316,6 +316,30 @@
 	not as aggressive as TCP Reno.
 	Default:0
 
+tcp_bic - BOOLEAN
+	Enable BIC TCP congestion control algorithm.
+	BIC-TCP is a sender-side only change that ensures a linear RTT
+	fairness under large windows while offering both scalability and
+	bounded TCP-friendliness. The protocol combines two schemes
+	called additive increase and binary search increase. When the
+	congestion window is large, additive increase with a large
+	increment ensures linear RTT fairness as well as good
+	scalability. Under small congestion windows, binary search
+	increase provides TCP friendliness.
+	Default: 0
+
+tcp_bic_low_window - INTEGER
+	Sets the threshold window (in packets) where BIC TCP starts to
+	adjust the congestion window. Below this threshold BIC TCP behaves
+	the same as the default TCP Reno. 
+	Default: 14
+
+tcp_bic_fast_convergence - BOOLEAN
+	Forces BIC TCP to more quickly respond to changes in congestion
+	window. Allows two flows sharing the same connection to converge
+	more rapidly.
+	Default: 1
+
 ip_local_port_range - 2 INTEGERS
 	Defines the local port range that is used by TCP and UDP to
 	choose the local port. The first number is the first, the 
diff -Nru a/include/linux/sysctl.h b/include/linux/sysctl.h
--- a/include/linux/sysctl.h	Fri May  7 15:56:15 2004
+++ b/include/linux/sysctl.h	Fri May  7 15:56:15 2004
@@ -332,6 +332,9 @@
 	NET_TCP_VEGAS_ALPHA=99,
 	NET_TCP_VEGAS_BETA=100,
 	NET_TCP_VEGAS_GAMMA=101,
+ 	NET_TCP_BIC=102,
+ 	NET_TCP_BIC_FAST_CONVERGENCE=103,
+	NET_TCP_BIC_LOW_WINDOW=104,
 };
 
 enum {
diff -Nru a/include/linux/tcp.h b/include/linux/tcp.h
--- a/include/linux/tcp.h	Fri May  7 15:56:15 2004
+++ b/include/linux/tcp.h	Fri May  7 15:56:15 2004
@@ -400,6 +400,13 @@
 		__u32	minRTT;		/* min of RTTs measured within last RTT (in usec) */
 		__u32	baseRTT;	/* the min of all Vegas RTT measurements seen (in usec) */
 	} vegas;
+
+	/* BI TCP Parameters */
+	struct {
+		__u32	cnt;		/* increase cwnd by 1 after this number of ACKs */
+		__u32 	last_max_cwnd;	/* last maximium snd_cwnd */
+		__u32	last_cwnd;	/* the last snd_cwnd */
+	} bictcp;
 };
 
 /* WARNING: don't change the layout of the members in tcp_sock! */
diff -Nru a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h	Fri May  7 15:56:15 2004
+++ b/include/net/tcp.h	Fri May  7 15:56:15 2004
@@ -509,6 +509,25 @@
 # define TCP_TW_RECYCLE_TICK (12+2-TCP_TW_RECYCLE_SLOTS_LOG)
 #endif
 
+#define BICTCP_1_OVER_BETA	8	/*
+					 * Fast recovery
+					 * multiplicative decrease factor
+					 */
+#define BICTCP_MAX_INCREMENT 32		/*
+					 * Limit on the amount of
+					 * increment allowed during
+					 * binary search.
+					 */
+#define BICTCP_FUNC_OF_MIN_INCR 11	/*
+					 * log(B/Smin)/log(B/(B-1))+1,
+					 * Smin:min increment
+					 * B:log factor
+					 */
+#define BICTCP_B		4	 /*
+					  * In binary search,
+					  * go to point (max+min)/N
+					  */
+
 /*
  *	TCP option
  */
@@ -588,6 +607,9 @@
 extern int sysctl_tcp_vegas_beta;
 extern int sysctl_tcp_vegas_gamma;
 extern int sysctl_tcp_nometrics_save;
+extern int sysctl_tcp_bic;
+extern int sysctl_tcp_bic_fast_convergence;
+extern int sysctl_tcp_bic_low_window;
 
 extern atomic_t tcp_memory_allocated;
 extern atomic_t tcp_sockets_allocated;
@@ -1207,11 +1229,30 @@
 
 /* Recalculate snd_ssthresh, we want to set it to:
  *
+ * Reno:
  * 	one half the current congestion window, but no
  *	less than two segments
+ *
+ * BIC:
+ *	behave like Reno until low_window is reached,
+ *	then increase congestion window slowly
  */
 static inline __u32 tcp_recalc_ssthresh(struct tcp_opt *tp)
 {
+	if (sysctl_tcp_bic) {
+		if (sysctl_tcp_bic_fast_convergence &&
+		    tp->snd_cwnd < tp->bictcp.last_max_cwnd)
+			tp->bictcp.last_max_cwnd
+				= (tp->snd_cwnd * (2*BICTCP_1_OVER_BETA-1))
+				/ (BICTCP_1_OVER_BETA/2);
+		else
+			tp->bictcp.last_max_cwnd = tp->snd_cwnd;
+
+		if (tp->snd_cwnd > sysctl_tcp_bic_low_window)
+			return max(tp->snd_cwnd - (tp->snd_cwnd/BICTCP_1_OVER_BETA),
+				   2U);
+	}
+
 	return max(tp->snd_cwnd >> 1U, 2U);
 }
 
diff -Nru a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
--- a/net/ipv4/sysctl_net_ipv4.c	Fri May  7 15:56:15 2004
+++ b/net/ipv4/sysctl_net_ipv4.c	Fri May  7 15:56:15 2004
@@ -641,6 +641,30 @@
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
+	{
+		.ctl_name	= NET_TCP_BIC,
+		.procname	= "tcp_bic",
+		.data		= &sysctl_tcp_bic,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+	{
+		.ctl_name	= NET_TCP_BIC_FAST_CONVERGENCE,
+		.procname	= "tcp_bic_fast_convergence",
+		.data		= &sysctl_tcp_bic_fast_convergence,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+	{
+		.ctl_name	= NET_TCP_BIC_LOW_WINDOW,
+		.procname	= "tcp_bic_low_window",
+		.data		= &sysctl_tcp_bic_low_window,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 	{ .ctl_name = 0 }
 };
 
diff -Nru a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c	Fri May  7 15:56:15 2004
+++ b/net/ipv4/tcp_input.c	Fri May  7 15:56:15 2004
@@ -97,6 +97,9 @@
 int sysctl_tcp_vegas_alpha = 1<<V_PARAM_SHIFT;
 int sysctl_tcp_vegas_beta  = 3<<V_PARAM_SHIFT;
 int sysctl_tcp_vegas_gamma = 1<<V_PARAM_SHIFT;
+int sysctl_tcp_bic;
+int sysctl_tcp_bic_fast_convergence = 1;
+int sysctl_tcp_bic_low_window = 14;
 
 #define FLAG_DATA		0x01 /* Incoming frame contained data.		*/
 #define FLAG_WIN_UPDATE		0x02 /* Incoming ACK was a window update.	*/
@@ -1858,6 +1861,68 @@
 	else if (seq_rtt >= 0)
 		tcp_ack_no_tstamp(tp, seq_rtt, flag);
 }
+
+/*
+ * Compute congestion window to use.
+ *
+ * This is from the implementation of BICTCP in
+ * Lison-Xu, Kahaled Harfoush, and Injog Rhee.
+ *  "Binary Increase Congestion Control for Fast, Long Distance
+ *  Networks" in InfoComm 2004
+ * Available from:
+ *  http://www.csc.ncsu.edu/faculty/rhee/export/bitcp.pdf
+ *
+ * Unless BIC is enabled and congestion window is large
+ * this behaves the same as the original Reno.
+ */
+static inline __u32 bictcp_cwnd(struct tcp_opt *tp)
+{
+	/* orignal Reno behaviour */
+	if (!sysctl_tcp_bic)
+		return tp->snd_cwnd;
+
+	if (tp->bictcp.last_cwnd == tp->snd_cwnd)
+		return tp->bictcp.cnt; /*  same cwnd, no update */
+      
+	tp->bictcp.last_cwnd = tp->snd_cwnd;
+      
+	/* start off normal */
+	if (tp->snd_cwnd <= sysctl_tcp_bic_low_window)
+		tp->bictcp.cnt = tp->snd_cwnd;
+
+	/* binary increase */
+	else if (tp->snd_cwnd < tp->bictcp.last_max_cwnd) {
+		__u32 	dist = (tp->bictcp.last_max_cwnd - tp->snd_cwnd)
+			/ BICTCP_B;
+
+		if (dist > BICTCP_MAX_INCREMENT)
+			/* linear increase */
+			tp->bictcp.cnt = tp->snd_cwnd / BICTCP_MAX_INCREMENT;
+		else if (dist <= 1U)
+			/* binary search increase */
+			tp->bictcp.cnt = tp->snd_cwnd * BICTCP_FUNC_OF_MIN_INCR
+				/ BICTCP_B;
+		else
+			/* binary search increase */
+			tp->bictcp.cnt = tp->snd_cwnd / dist;
+	} else {
+		/* slow start amd linear increase */
+		if (tp->snd_cwnd < tp->bictcp.last_max_cwnd + BICTCP_B)
+			/* slow start */
+			tp->bictcp.cnt = tp->snd_cwnd * BICTCP_FUNC_OF_MIN_INCR
+				/ BICTCP_B;
+		else if (tp->snd_cwnd < tp->bictcp.last_max_cwnd
+			 		+ BICTCP_MAX_INCREMENT*(BICTCP_B-1))
+			/* slow start */
+			tp->bictcp.cnt = tp->snd_cwnd * (BICTCP_B-1)
+				/ (tp->snd_cwnd-tp->bictcp.last_max_cwnd);
+		else
+			/* linear increase */
+			tp->bictcp.cnt = tp->snd_cwnd / BICTCP_MAX_INCREMENT;
+	}
+	return tp->bictcp.cnt;
+}
+
 /* This is Jacobson's slow start and congestion avoidance. 
  * SIGCOMM '88, p. 328.
  */
@@ -1871,7 +1936,7 @@
                 /* In dangerous area, increase slowly.
 		 * In theory this is tp->snd_cwnd += 1 / tp->snd_cwnd
 		 */
-		if (tp->snd_cwnd_cnt >= tp->snd_cwnd) {
+		if (tp->snd_cwnd_cnt >= bictcp_cwnd(tp)) {
 			if (tp->snd_cwnd < tp->snd_cwnd_clamp)
 				tp->snd_cwnd++;
 			tp->snd_cwnd_cnt=0;
diff -Nru a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
--- a/net/ipv4/tcp_minisocks.c	Fri May  7 15:56:15 2004
+++ b/net/ipv4/tcp_minisocks.c	Fri May  7 15:56:15 2004
@@ -766,6 +766,9 @@
 		newtp->snd_cwnd = 2;
 		newtp->snd_cwnd_cnt = 0;
 
+		newtp->bictcp.cnt = 0;
+		newtp->bictcp.last_max_cwnd = newtp->bictcp.last_cwnd = 0;
+
 		newtp->frto_counter = 0;
 		newtp->frto_highmark = 0;
 
