From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] (1/3) tcp - choose congestion algorithm at
 initialization
Date: Fri, 1 Oct 2004 15:55:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041001155554.51763dc0@zqx3.pdx.osdl.net>
References: <20040927111834.48c7baab@zqx3.pdx.osdl.net>
	<20040927121610.68f942a4.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040927121610.68f942a4.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here is the 2.4 version of the change to store congest algorithm
per socket.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/include/net/sock.h b/include/net/sock.h
--- a/include/net/sock.h	2004-10-01 15:51:48 -07:00
+++ b/include/net/sock.h	2004-10-01 15:51:48 -07:00
@@ -256,6 +256,13 @@
 	__u32	end_seq;
 };
 
+enum tcp_congestion_algo {
+ 	TCP_RENO=0,
+ 	TCP_VEGAS,
+ 	TCP_WESTWOOD,
+ 	TCP_BIC,
+};
+ 
 struct tcp_opt {
 	int	tcp_header_len;	/* Bytes of tcp header to send		*/
 
@@ -428,7 +435,8 @@
 	unsigned int		keepalive_intvl;  /* time interval between keep alive probes */
 	int			linger2;
 
-	int                     frto_counter; /* Number of new acks after RTO */
+	__u8			adv_cong;    /* Using Vegas, Westwood, or BIC */
+	__u8                    frto_counter; /* Number of new acks after RTO */
 	__u32                   frto_highmark; /* snd_nxt when RTO occurred */
 
 	unsigned long last_synq_overflow; 
@@ -465,7 +473,6 @@
 		__u32	beg_snd_nxt;	/* right edge during last RTT */
 		__u32	beg_snd_una;	/* left edge  during last RTT */
 		__u32	beg_snd_cwnd;	/* saves the size of the cwnd */
-		__u8	do_vegas;	/* do vegas for this connection */
 		__u8	doing_vegas_now;/* if true, do vegas for this RTT */
 		__u16	cntRTT;		/* # of RTTs measured within last RTT */
 		__u32	minRTT;		/* min of RTTs measured within last RTT (in usec) */
diff -Nru a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h	2004-10-01 15:51:48 -07:00
+++ b/include/net/tcp.h	2004-10-01 15:51:48 -07:00
@@ -1110,6 +1110,13 @@
 	return tp->packets_out - tp->left_out + tp->retrans_out;
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
@@ -1122,7 +1129,7 @@
  */
 static inline __u32 tcp_recalc_ssthresh(struct tcp_opt *tp)
 {
-	if (sysctl_tcp_bic) {
+	if (tcp_is_bic(tp)) {
 		if (sysctl_tcp_bic_fast_convergence &&
 		    tp->snd_cwnd < tp->bictcp.last_max_cwnd)
 			tp->bictcp.last_max_cwnd
@@ -1141,11 +1148,6 @@
 
 /* Stop taking Vegas samples for now. */
 #define tcp_vegas_disable(__tp)	((__tp)->vegas.doing_vegas_now = 0)
-
-/* Is this TCP connection using Vegas (regardless of whether it is taking
- * Vegas measurements at the current time)?
- */
-#define tcp_is_vegas(__tp)	((__tp)->vegas.do_vegas)
     
 static inline void tcp_vegas_enable(struct tcp_opt *tp)
 {
@@ -1179,7 +1181,7 @@
 /* Should we be taking Vegas samples right now? */
 #define tcp_vegas_enabled(__tp)	((__tp)->vegas.doing_vegas_now)
 
-extern void tcp_vegas_init(struct tcp_opt *tp);
+extern void tcp_ca_init(struct tcp_opt *tp);
 
 static inline void tcp_set_ca_state(struct tcp_opt *tp, u8 ca_state)
 {
@@ -1978,7 +1980,7 @@
 
 static inline void tcp_westwood_update_rtt(struct tcp_opt *tp, __u32 rtt_seq)
 {
-	if (sysctl_tcp_westwood)
+	if (tcp_is_westwood(tp))
 		tp->westwood.rtt = rtt_seq;
 }
 
@@ -2015,13 +2017,13 @@
 
 static inline void tcp_westwood_fast_bw(struct sock *sk, struct sk_buff *skb)
 {
-	if (sysctl_tcp_westwood)
+	if (tcp_is_westwood(&(sk->tp_pinfo.af_tcp)))
 		__tcp_westwood_fast_bw(sk, skb);
 }
 
 static inline void tcp_westwood_slow_bw(struct sock *sk, struct sk_buff *skb)
 {
-	if (sysctl_tcp_westwood)
+	if (tcp_is_westwood(&(sk->tp_pinfo.af_tcp)))
 		__tcp_westwood_slow_bw(sk, skb);
 }
 
@@ -2035,7 +2037,7 @@
 {
 	__u32 ret = 0;
 
-	if (sysctl_tcp_westwood)
+	if (tcp_is_westwood(tp))
 		ret = (__u32) (max(__tcp_westwood_bw_rttmin(tp), 2U));
 
 	return ret;
@@ -2046,7 +2048,7 @@
 	int ret = 0;
 	__u32 ssthresh;
 
-	if (sysctl_tcp_westwood) {
+	if (tcp_is_westwood(tp)) {
 		if (!(ssthresh = tcp_westwood_bw_rttmin(tp)))
 			return ret;
 
@@ -2062,7 +2064,7 @@
 	int ret = 0;
 	__u32 cwnd;
 
-	if (sysctl_tcp_westwood) {
+	if (tcp_is_westwood(tp)) {
 		if (!(cwnd = tcp_westwood_bw_rttmin(tp)))
 			return ret;
 
@@ -2077,7 +2079,7 @@
 {
 	int ret = 0;
 
-	if (sysctl_tcp_westwood) {
+	if (tcp_is_westwood(tp)) {
 		if (tcp_westwood_cwnd(tp)) {
 			tp->snd_ssthresh = tp->snd_cwnd;
 			ret = 1;
diff -Nru a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c	2004-10-01 15:51:48 -07:00
+++ b/net/ipv4/tcp_input.c	2004-10-01 15:51:48 -07:00
@@ -549,17 +549,20 @@
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
@@ -2007,7 +2010,7 @@
 static inline __u32 bictcp_cwnd(struct tcp_opt *tp)
 {
 	/* orignal Reno behaviour */
-	if (!sysctl_tcp_bic)
+	if (!tcp_is_bic(tp))
 		return tp->snd_cwnd;
 
 	if (tp->bictcp.last_cwnd == tp->snd_cwnd &&
diff -Nru a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
--- a/net/ipv4/tcp_minisocks.c	2004-10-01 15:51:48 -07:00
+++ b/net/ipv4/tcp_minisocks.c	2004-10-01 15:51:48 -07:00
@@ -788,7 +788,7 @@
 		newtp->mss_clamp = req->mss;
 		TCP_ECN_openreq_child(newtp, req);
 
-		tcp_vegas_init(newtp);
+		tcp_ca_init(newtp);
 		TCP_INC_STATS_BH(TcpPassiveOpens);
 	}
 	return newsk;
diff -Nru a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c	2004-10-01 15:51:48 -07:00
+++ b/net/ipv4/tcp_output.c	2004-10-01 15:51:48 -07:00
@@ -1197,7 +1197,7 @@
 		tp->window_clamp = dst->window;
 	tp->advmss = dst->advmss;
 	tcp_initialize_rcv_mss(sk);
-	tcp_vegas_init(tp);
+	tcp_ca_init(tp);
 
 	tcp_select_initial_window(tcp_full_space(sk),
 				  tp->advmss - (tp->ts_recent_stamp ? tp->tcp_header_len - sizeof(struct tcphdr) : 0),
@@ -1248,7 +1248,7 @@
 	TCP_SKB_CB(buff)->end_seq = tp->write_seq;
 	tp->snd_nxt = tp->write_seq;
 	tp->pushed_seq = tp->write_seq;
-	tcp_vegas_init(tp);
+	tcp_ca_init(tp);
 
 	/* Send it off. */
 	TCP_SKB_CB(buff)->when = tcp_time_stamp;
