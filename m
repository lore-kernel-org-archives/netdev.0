From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/3) tcp - choose congestion algorithm at initialization
Date: Mon, 27 Sep 2004 11:18:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927111834.48c7baab@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Miller <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The choice of congestion algorithm needs to be made when connection
is setup to avoid problems when the sysctl values change later and the
necessary data hasn't been collected.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/include/linux/tcp.h b/include/linux/tcp.h
--- a/include/linux/tcp.h	2004-09-27 10:56:46 -07:00
+++ b/include/linux/tcp.h	2004-09-27 10:56:46 -07:00
@@ -205,6 +205,13 @@
 	__u32	val;
 } tcp_pcount_t;
 
+enum tcp_congestion_algo {
+	TCP_RENO=0,
+	TCP_VEGAS,
+	TCP_WESTWOOD,
+	TCP_BIC,
+};
+
 struct tcp_opt {
 	int	tcp_header_len;	/* Bytes of tcp header to send		*/
 
@@ -265,7 +272,7 @@
 	__u8	frto_counter;	/* Number of new acks after RTO */
 	__u32	frto_highmark;	/* snd_nxt when RTO occurred */
 
-	__u8	unused_pad;
+	__u8	adv_cong;	/* Using Vegas, Westwood, or BIC */
 	__u8	defer_accept;	/* User waits for some data after accept() */
 	/* one byte hole, try to pack */
 
@@ -412,7 +419,6 @@
 		__u32	beg_snd_nxt;	/* right edge during last RTT */
 		__u32	beg_snd_una;	/* left edge  during last RTT */
 		__u32	beg_snd_cwnd;	/* saves the size of the cwnd */
-		__u8	do_vegas;	/* do vegas for this connection */
 		__u8	doing_vegas_now;/* if true, do vegas for this RTT */
 		__u16	cntRTT;		/* # of RTTs measured within last RTT */
 		__u32	minRTT;		/* min of RTTs measured within last RTT (in usec) */
diff -Nru a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h	2004-09-27 10:56:46 -07:00
+++ b/include/net/tcp.h	2004-09-27 10:56:46 -07:00
@@ -1271,6 +1271,13 @@
 		tcp_get_pcount(&tp->retrans_out));
 }
 
+/*
+ * Which congestion algorithim is in use on the connection.
+ */
+#define tcp_is_vegas(__tp)	((__tp)->adv_cong == TCP_VEGAS)
+#define tcp_is_westwood(__tp)	((__tp)->adv_cong == TCP_WESTWOOD)
+#define tcp_is_bic(__tp)	((__tp)->adv_cong == TCP_BIC)
+
 /* Recalculate snd_ssthresh, we want to set it to:
  *
  * Reno:
@@ -1283,7 +1290,7 @@
  */
 static inline __u32 tcp_recalc_ssthresh(struct tcp_opt *tp)
 {
-	if (sysctl_tcp_bic) {
+	if (tcp_is_bic(tp)) {
 		if (sysctl_tcp_bic_fast_convergence &&
 		    tp->snd_cwnd < tp->bictcp.last_max_cwnd)
 			tp->bictcp.last_max_cwnd
@@ -1302,11 +1309,6 @@
 
 /* Stop taking Vegas samples for now. */
 #define tcp_vegas_disable(__tp)	((__tp)->vegas.doing_vegas_now = 0)
-
-/* Is this TCP connection using Vegas (regardless of whether it is taking
- * Vegas measurements at the current time)?
- */
-#define tcp_is_vegas(__tp)	((__tp)->vegas.do_vegas)
     
 static inline void tcp_vegas_enable(struct tcp_opt *tp)
 {
@@ -1340,7 +1342,7 @@
 /* Should we be taking Vegas samples right now? */
 #define tcp_vegas_enabled(__tp)	((__tp)->vegas.doing_vegas_now)
 
-extern void tcp_vegas_init(struct tcp_opt *tp);
+extern void tcp_ca_init(struct tcp_opt *tp);
 
 static inline void tcp_set_ca_state(struct tcp_opt *tp, u8 ca_state)
 {
@@ -2024,7 +2026,7 @@
 
 static inline void tcp_westwood_update_rtt(struct tcp_opt *tp, __u32 rtt_seq)
 {
-        if (sysctl_tcp_westwood)
+        if (tcp_is_westwood(tp))
                 tp->westwood.rtt = rtt_seq;
 }
 
@@ -2033,13 +2035,13 @@
 
 static inline void tcp_westwood_fast_bw(struct sock *sk, struct sk_buff *skb)
 {
-        if (sysctl_tcp_westwood)
+        if (tcp_is_westwood(tcp_sk(sk)))
                 __tcp_westwood_fast_bw(sk, skb);
 }
 
 static inline void tcp_westwood_slow_bw(struct sock *sk, struct sk_buff *skb)
 {
-        if (sysctl_tcp_westwood)
+        if (tcp_is_westwood(tcp_sk(sk)))
                 __tcp_westwood_slow_bw(sk, skb);
 }
 
@@ -2052,14 +2054,14 @@
 
 static inline __u32 tcp_westwood_bw_rttmin(const struct tcp_opt *tp)
 {
-	return sysctl_tcp_westwood ? __tcp_westwood_bw_rttmin(tp) : 0;
+	return tcp_is_westwood(tp) ? __tcp_westwood_bw_rttmin(tp) : 0;
 }
 
 static inline int tcp_westwood_ssthresh(struct tcp_opt *tp)
 {
 	__u32 ssthresh = 0;
 
-	if (sysctl_tcp_westwood) {
+	if (tcp_is_westwood(tp)) {
 		ssthresh = __tcp_westwood_bw_rttmin(tp);
 		if (ssthresh)
 			tp->snd_ssthresh = ssthresh;  
@@ -2072,7 +2074,7 @@
 {
 	__u32 cwnd = 0;
 
-	if (sysctl_tcp_westwood) {
+	if (tcp_is_westwood(tp)) {
 		cwnd = __tcp_westwood_bw_rttmin(tp);
 		if (cwnd)
 			tp->snd_cwnd = cwnd;
diff -Nru a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c	2004-09-27 10:56:46 -07:00
+++ b/net/ipv4/tcp_input.c	2004-09-27 10:56:46 -07:00
@@ -555,17 +555,20 @@
 		tcp_grow_window(sk, tp, skb);
 }
 
-/* Set up a new TCP connection, depending on whether it should be
- * using Vegas or not.
- */    
-void tcp_vegas_init(struct tcp_opt *tp)
+/* When starting a new connection, pin down the current choice of 
+ * congestion algorithm.
+ */
+void tcp_ca_init(struct tcp_opt *tp)
 {
-	if (sysctl_tcp_vegas_cong_avoid) {
-		tp->vegas.do_vegas = 1;
+	if (sysctl_tcp_westwood) 
+		tp->adv_cong = TCP_WESTWOOD;
+	else if (sysctl_tcp_bic)
+		tp->adv_cong = TCP_BIC;
+	else if (sysctl_tcp_vegas_cong_avoid) {
+		tp->adv_cong = TCP_VEGAS;
 		tp->vegas.baseRTT = 0x7fffffff;
 		tcp_vegas_enable(tp);
-	} else 
-		tcp_vegas_disable(tp);
+	} 
 }
 
 /* Do RTT sampling needed for Vegas.
@@ -2039,7 +2042,7 @@
 static inline __u32 bictcp_cwnd(struct tcp_opt *tp)
 {
 	/* orignal Reno behaviour */
-	if (!sysctl_tcp_bic)
+	if (!tcp_is_bic(tp))
 		return tp->snd_cwnd;
 
 	if (tp->bictcp.last_cwnd == tp->snd_cwnd &&
diff -Nru a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
--- a/net/ipv4/tcp_minisocks.c	2004-09-27 10:56:46 -07:00
+++ b/net/ipv4/tcp_minisocks.c	2004-09-27 10:56:46 -07:00
@@ -841,7 +841,8 @@
 		if (newtp->ecn_flags&TCP_ECN_OK)
 			newsk->sk_no_largesend = 1;
 
-		tcp_vegas_init(newtp);
+		tcp_ca_init(newtp);
+
 		TCP_INC_STATS_BH(TCP_MIB_PASSIVEOPENS);
 	}
 	return newsk;
diff -Nru a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c	2004-09-27 10:56:46 -07:00
+++ b/net/ipv4/tcp_output.c	2004-09-27 10:56:46 -07:00
@@ -1359,7 +1359,7 @@
 		tp->window_clamp = dst_metric(dst, RTAX_WINDOW);
 	tp->advmss = dst_metric(dst, RTAX_ADVMSS);
 	tcp_initialize_rcv_mss(sk);
-	tcp_vegas_init(tp);
+	tcp_ca_init(tp);
 
 	tcp_select_initial_window(tcp_full_space(sk),
 				  tp->advmss - (tp->ts_recent_stamp ? tp->tcp_header_len - sizeof(struct tcphdr) : 0),
@@ -1411,7 +1411,7 @@
 	TCP_SKB_CB(buff)->end_seq = tp->write_seq;
 	tp->snd_nxt = tp->write_seq;
 	tp->pushed_seq = tp->write_seq;
-	tcp_vegas_init(tp);
+	tcp_ca_init(tp);
 
 	/* Send it off. */
 	TCP_SKB_CB(buff)->when = tcp_time_stamp;
