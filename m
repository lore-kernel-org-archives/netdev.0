From: Baruch Even <baruch@ev-en.org>
Subject: [PATCH] select congestion control with one sysctl
Date: Wed, 23 Feb 2005 21:30:13 +0000
Message-ID: <421CF5E5.1060606@ev-en.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010108020005060401030407"
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org,
        Yee-Ting Li <yee-ting.li@nuim.ie>, Doug Leith <doug.leith@nuim.ie>
To: "David S. Miller" <davem@davemloft.net>,
        Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010108020005060401030407
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch makes selection of congestion control algorithm simpler by 
using a single sysctl for that purpose, rather than a cascade of sysctls.

The patch also does some minor cleanups to avoid cascade actions between
algorithms so that flow control is cleaner.

Possible improvements:
  - Use a string when reading/writing from sysctl to make it more
    friendly to humans.
  - And/Or, provide a list of all available congestion control
    algorithms.

The patch is against 2.6.11-rc4-bk9.

Signed-Off-By: Yee-Ting Li <yee-ting.li@nuim.ie>
Signed-Off-By: Baruch Even <baruch@ev-en.org>


--------------010108020005060401030407
Content-Type: text/x-patch;
 name="cong_control_change.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="cong_control_change.patch"

This patch makes selection of congestion control algorithm simpler by using a
single sysctl for that purpose, rather than a cascade of sysctls.

The patch also does some minor cleanups to avoid cascade actions between
algorithms so that flow control is cleaner.

Possible improvements:
 - Use a string when reading/writing from sysctl to make it more friendly to humans
 - And/Or, provide a list of all available congestion control algorithms

The patch is against 2.6.11-rc4-bk9.

Signed-Off-By: Yee-Ting Li <yee-ting.li@nuim.ie>
Signed-Off-By: Baruch Even <baruch@ev-en.org>

Index: 2.6.11-select/include/linux/sysctl.h
===================================================================
--- 2.6.11-select.orig/include/linux/sysctl.h
+++ 2.6.11-select/include/linux/sysctl.h
@@ -344,6 +344,7 @@ enum
 	NET_TCP_DEFAULT_WIN_SCALE=105,
 	NET_TCP_MODERATE_RCVBUF=106,
 	NET_TCP_TSO_WIN_DIVISOR=107,
+	NET_TCP_ADV_CONG=108,
 };
 
 enum {
Index: 2.6.11-select/include/net/tcp.h
===================================================================
--- 2.6.11-select.orig/include/net/tcp.h
+++ 2.6.11-select/include/net/tcp.h
@@ -597,13 +597,11 @@ extern int sysctl_tcp_adv_win_scale;
 extern int sysctl_tcp_tw_reuse;
 extern int sysctl_tcp_frto;
 extern int sysctl_tcp_low_latency;
-extern int sysctl_tcp_westwood;
-extern int sysctl_tcp_vegas_cong_avoid;
 extern int sysctl_tcp_vegas_alpha;
 extern int sysctl_tcp_vegas_beta;
 extern int sysctl_tcp_vegas_gamma;
 extern int sysctl_tcp_nometrics_save;
-extern int sysctl_tcp_bic;
+extern int sysctl_tcp_adv_cong;
 extern int sysctl_tcp_bic_fast_convergence;
 extern int sysctl_tcp_bic_low_window;
 extern int sysctl_tcp_moderate_rcvbuf;
@@ -1241,7 +1239,8 @@ static __inline__ unsigned int tcp_packe
  */
 static inline __u32 tcp_recalc_ssthresh(struct tcp_sock *tp)
 {
-	if (tcp_is_bic(tp)) {
+	switch (tp->adv_cong) {
+	case TCP_BIC:
 		if (sysctl_tcp_bic_fast_convergence &&
 		    tp->snd_cwnd < tp->bictcp.last_max_cwnd)
 			tp->bictcp.last_max_cwnd
@@ -1253,9 +1252,11 @@ static inline __u32 tcp_recalc_ssthresh(
 		if (tp->snd_cwnd > sysctl_tcp_bic_low_window)
 			return max(tp->snd_cwnd - (tp->snd_cwnd/BICTCP_1_OVER_BETA),
 				   2U);
-	}
+		break;
 
-	return max(tp->snd_cwnd >> 1U, 2U);
+	default:
+		return max(tp->snd_cwnd >> 1U, 2U);
+	}
 }
 
 /* Stop taking Vegas samples for now. */
@@ -1980,24 +1981,19 @@ static inline void tcp_westwood_update_r
                 tp->westwood.rtt = rtt_seq;
 }
 
-static inline __u32 __tcp_westwood_bw_rttmin(const struct tcp_sock *tp)
+static inline __u32 tcp_westwood_bw_rttmin(const struct tcp_sock *tp)
 {
         return max((tp->westwood.bw_est) * (tp->westwood.rtt_min) /
 		   (__u32) (tp->mss_cache_std),
 		   2U);
 }
 
-static inline __u32 tcp_westwood_bw_rttmin(const struct tcp_sock *tp)
-{
-	return tcp_is_westwood(tp) ? __tcp_westwood_bw_rttmin(tp) : 0;
-}
-
 static inline int tcp_westwood_ssthresh(struct tcp_sock *tp)
 {
 	__u32 ssthresh = 0;
 
 	if (tcp_is_westwood(tp)) {
-		ssthresh = __tcp_westwood_bw_rttmin(tp);
+		ssthresh = tcp_westwood_bw_rttmin(tp);
 		if (ssthresh)
 			tp->snd_ssthresh = ssthresh;  
 	}
@@ -2010,7 +2006,7 @@ static inline int tcp_westwood_cwnd(stru
 	__u32 cwnd = 0;
 
 	if (tcp_is_westwood(tp)) {
-		cwnd = __tcp_westwood_bw_rttmin(tp);
+		cwnd = tcp_westwood_bw_rttmin(tp);
 		if (cwnd)
 			tp->snd_cwnd = cwnd;
 	}
Index: 2.6.11-select/net/ipv4/sysctl_net_ipv4.c
===================================================================
--- 2.6.11-select.orig/net/ipv4/sysctl_net_ipv4.c
+++ 2.6.11-select/net/ipv4/sysctl_net_ipv4.c
@@ -602,22 +602,14 @@ ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
-	{
-		.ctl_name	= NET_TCP_WESTWOOD, 
-		.procname	= "tcp_westwood",
-		.data		= &sysctl_tcp_westwood,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
-	},
-	{
-		.ctl_name	= NET_TCP_VEGAS,
-		.procname	= "tcp_vegas_cong_avoid",
-		.data		= &sysctl_tcp_vegas_cong_avoid,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
-	},
+ 	{
+		.ctl_name	= NET_TCP_ADV_CONG,
+ 		.procname	= "tcp_adv_cong",
+ 		.data		= &sysctl_tcp_adv_cong,
+ 		.maxlen		= sizeof(int),
+ 		.mode		= 0644,
+ 		.proc_handler	= &proc_dointvec,
+ 	},
 	{
 		.ctl_name	= NET_TCP_VEGAS_ALPHA,
 		.procname	= "tcp_vegas_alpha",
@@ -643,14 +635,6 @@ ctl_table ipv4_table[] = {
 		.proc_handler	= &proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_TCP_BIC,
-		.procname	= "tcp_bic",
-		.data		= &sysctl_tcp_bic,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
-	},
-	{
 		.ctl_name	= NET_TCP_BIC_FAST_CONVERGENCE,
 		.procname	= "tcp_bic_fast_convergence",
 		.data		= &sysctl_tcp_bic_fast_convergence,
Index: 2.6.11-select/net/ipv4/tcp_input.c
===================================================================
--- 2.6.11-select.orig/net/ipv4/tcp_input.c
+++ 2.6.11-select/net/ipv4/tcp_input.c
@@ -87,8 +87,6 @@ int sysctl_tcp_rfc1337;
 int sysctl_tcp_max_orphans = NR_FILE;
 int sysctl_tcp_frto;
 int sysctl_tcp_nometrics_save;
-int sysctl_tcp_westwood;
-int sysctl_tcp_vegas_cong_avoid;
 
 int sysctl_tcp_moderate_rcvbuf = 1;
 
@@ -99,10 +97,11 @@ int sysctl_tcp_moderate_rcvbuf = 1;
 int sysctl_tcp_vegas_alpha = 1<<V_PARAM_SHIFT;
 int sysctl_tcp_vegas_beta  = 3<<V_PARAM_SHIFT;
 int sysctl_tcp_vegas_gamma = 1<<V_PARAM_SHIFT;
-int sysctl_tcp_bic = 1;
 int sysctl_tcp_bic_fast_convergence = 1;
 int sysctl_tcp_bic_low_window = 14;
 
+int sysctl_tcp_adv_cong;
+
 #define FLAG_DATA		0x01 /* Incoming frame contained data.		*/
 #define FLAG_WIN_UPDATE		0x02 /* Incoming ACK was a window update.	*/
 #define FLAG_DATA_ACKED		0x04 /* This ACK acknowledged new data.		*/
@@ -561,15 +560,18 @@ static void tcp_event_data_recv(struct s
  */
 void tcp_ca_init(struct tcp_sock *tp)
 {
-	if (sysctl_tcp_westwood) 
-		tp->adv_cong = TCP_WESTWOOD;
-	else if (sysctl_tcp_bic)
-		tp->adv_cong = TCP_BIC;
-	else if (sysctl_tcp_vegas_cong_avoid) {
-		tp->adv_cong = TCP_VEGAS;
-		tp->vegas.baseRTT = 0x7fffffff;
-		tcp_vegas_enable(tp);
-	} 
+	switch (sysctl_tcp_adv_cong) {
+		case TCP_VEGAS:
+			tp->vegas.baseRTT = 0x7fffffff;
+			tcp_vegas_enable(tp);
+			/* Fallthrough */
+		case TCP_BIC:
+		case TCP_WESTWOOD:
+			tp->adv_cong = sysctl_tcp_adv_cong;
+			break;
+		default:
+			tp->adv_cong = TCP_RENO;
+	}
 }
 
 /* Do RTT sampling needed for Vegas.
@@ -1600,18 +1602,25 @@ static void tcp_cwnd_down(struct tcp_soc
 	int decr = tp->snd_cwnd_cnt + 1;
 	__u32 limit;
 
-	/*
-	 * TCP Westwood
-	 * Here limit is evaluated as BWestimation*RTTmin (for obtaining it
-	 * in packets we use mss_cache). If sysctl_tcp_westwood is off
-	 * tcp_westwood_bw_rttmin() returns 0. In such case snd_ssthresh is
-	 * still used as usual. It prevents other strange cases in which
-	 * BWE*RTTmin could assume value 0. It should not happen but...
-	 */
+	switch (tp->adv_cong) {
+		case TCP_WESTWOOD:
+			/*
+			 * TCP Westwood
+			 * Here limit is evaluated as BWestimation*RTTmin (for obtaining it
+			 * in packets we use mss_cache). The guard is against
+			 * strange cases in which BWE*RTTmin could assume value
+			 * 0. It should not happen but...
+			 */
 
-	if (!(limit = tcp_westwood_bw_rttmin(tp)))
-		limit = tp->snd_ssthresh/2;
+			if (!(limit = tcp_westwood_bw_rttmin(tp)))
+				limit = tp->snd_ssthresh/2;
+			break;
 
+		default:
+			limit = tp->snd_ssthresh/2;
+			break;
+	}
+	
 	tp->snd_cwnd_cnt = decr&1;
 	decr >>= 1;
 
@@ -2014,6 +2023,27 @@ static inline void tcp_ack_update_rtt(st
 		tcp_ack_no_tstamp(tp, seq_rtt, flag);
 }
 
+static inline void tcp_slow_start(struct tcp_sock *tp)
+{
+	/* In "safe" area, increase. */
+	if (tp->snd_cwnd < tp->snd_cwnd_clamp)
+		tp->snd_cwnd++;
+}
+
+static inline void tcp_increase_cwnd(struct tcp_sock *tp, __u32 window)
+{
+	/* In dangerous area, increase slowly.
+	 * In theory, for standard tcp, this is tp->snd_cwnd += 1 / window
+	 * (snd_cwnd for Reno)
+	 */
+	if (tp->snd_cwnd_cnt >= window) {
+		if (tp->snd_cwnd < tp->snd_cwnd_clamp)
+			tp->snd_cwnd++;
+		tp->snd_cwnd_cnt = 0;
+	} else
+		tp->snd_cwnd_cnt++;		
+}
+
 /*
  * Compute congestion window to use.
  *
@@ -2029,10 +2059,6 @@ static inline void tcp_ack_update_rtt(st
  */
 static inline __u32 bictcp_cwnd(struct tcp_sock *tp)
 {
-	/* orignal Reno behaviour */
-	if (!tcp_is_bic(tp))
-		return tp->snd_cwnd;
-
 	if (tp->bictcp.last_cwnd == tp->snd_cwnd &&
 	   (s32)(tcp_time_stamp - tp->bictcp.last_stamp) <= (HZ>>5))
 		return tp->bictcp.cnt;
@@ -2080,23 +2106,13 @@ static inline __u32 bictcp_cwnd(struct t
 /* This is Jacobson's slow start and congestion avoidance. 
  * SIGCOMM '88, p. 328.
  */
-static inline void reno_cong_avoid(struct tcp_sock *tp)
+static inline void reno_cong_avoid(struct tcp_sock *tp, u32 snd_cwnd)
 {
-        if (tp->snd_cwnd <= tp->snd_ssthresh) {
-                /* In "safe" area, increase. */
-		if (tp->snd_cwnd < tp->snd_cwnd_clamp)
-			tp->snd_cwnd++;
-	} else {
-                /* In dangerous area, increase slowly.
-		 * In theory this is tp->snd_cwnd += 1 / tp->snd_cwnd
-		 */
-		if (tp->snd_cwnd_cnt >= bictcp_cwnd(tp)) {
-			if (tp->snd_cwnd < tp->snd_cwnd_clamp)
-				tp->snd_cwnd++;
-			tp->snd_cwnd_cnt=0;
-		} else
-			tp->snd_cwnd_cnt++;
-        }
+        if (tp->snd_cwnd <= tp->snd_ssthresh)
+		tcp_slow_start(tp);
+	else
+		tcp_increase_cwnd(tp, snd_cwnd);
+
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
@@ -2324,10 +2340,22 @@ static void vegas_cong_avoid(struct tcp_
 
 static inline void tcp_cong_avoid(struct tcp_sock *tp, u32 ack, u32 seq_rtt)
 {
-	if (tcp_vegas_enabled(tp))
-		vegas_cong_avoid(tp, ack, seq_rtt);
-	else
-		reno_cong_avoid(tp);
+	if (tp->snd_cwnd >= tp->snd_cwnd_clamp)
+		return;
+
+	switch (sysctl_tcp_adv_cong) {
+		case TCP_VEGAS:
+			vegas_cong_avoid(tp, ack, seq_rtt);
+			break;
+
+		case TCP_BIC:
+			reno_cong_avoid(tp, bictcp_cwnd(tp));
+			break;
+
+		default:
+			reno_cong_avoid(tp, tp->snd_cwnd);
+			break;
+	}
 }
 
 /* Restart timer after forward progress on connection.

--------------010108020005060401030407--
