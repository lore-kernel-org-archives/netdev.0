From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFC] Vegas and tcp parameters per route
Date: Fri, 12 Mar 2004 15:17:29 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040312151729.25d9c696@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is the second more complete version of TCP Vegas that allows setting
the options based on route.  Reused the RTAX_FEATURE metric which got
defined but never used, to provide the ability to select vegas, westwood,
and/or frto per route.

There is an modified version of iproute2 available at
	http://developer.osdl.org/shemminger/tcp/iproute2-exp.tar.bz2
With this it is possible to setup options per route with ip.
	ip route add to 10.0.0.1 features vegas/frto

This is intended for comment and testing, please don't put it into 2.6 yet.

P.s: the netdevice.h change is to make building iproute2 less painful.

diff -urNp -X dontdiff linux-2.6/include/linux/netdevice.h tcp-vegas-2.6/include/linux/netdevice.h
--- linux-2.6/include/linux/netdevice.h	2004-03-12 14:22:19.000000000 -0800
+++ tcp-vegas-2.6/include/linux/netdevice.h	2004-03-12 14:36:07.000000000 -0800
@@ -29,11 +29,11 @@
 #include <linux/if_ether.h>
 #include <linux/if_packet.h>
 
+#ifdef __KERNEL__
 #include <asm/atomic.h>
 #include <asm/cache.h>
 #include <asm/byteorder.h>
 
-#ifdef __KERNEL__
 #include <linux/config.h>
 #include <linux/device.h>
 #include <linux/percpu.h>
diff -urNp -X dontdiff linux-2.6/include/linux/rtnetlink.h tcp-vegas-2.6/include/linux/rtnetlink.h
--- linux-2.6/include/linux/rtnetlink.h	2004-01-23 09:39:20.000000000 -0800
+++ tcp-vegas-2.6/include/linux/rtnetlink.h	2004-03-12 09:54:06.000000000 -0800
@@ -294,9 +294,10 @@ enum
 
 #define RTAX_MAX RTAX_FEATURES
 
-#define RTAX_FEATURE_ECN	0x00000001
-#define RTAX_FEATURE_SACK	0x00000002
-#define RTAX_FEATURE_TIMESTAMP	0x00000004
+#define RTAX_FEATURE_NOMETRIC	0x00000001
+#define RTAX_FEATURE_FRTO	0x00000002
+#define RTAX_FEATURE_VEGAS	0x00000004
+#define RTAX_FEATURE_WESTWOOD	0x00000008
 
 struct rta_session
 {
diff -urNp -X dontdiff linux-2.6/include/linux/sysctl.h tcp-vegas-2.6/include/linux/sysctl.h
--- linux-2.6/include/linux/sysctl.h	2004-03-09 16:24:23.000000000 -0800
+++ tcp-vegas-2.6/include/linux/sysctl.h	2004-03-12 14:20:25.000000000 -0800
@@ -317,11 +317,12 @@ enum
 	NET_IPV4_ICMP_RATELIMIT=89,
 	NET_IPV4_ICMP_RATEMASK=90,
 	NET_TCP_TW_REUSE=91,
-	NET_TCP_FRTO=92,
-	NET_TCP_LOW_LATENCY=93,
-	NET_IPV4_IPFRAG_SECRET_INTERVAL=94,
-	NET_TCP_WESTWOOD=95,
-	NET_IPV4_IGMP_MAX_MSF=96,
+	NET_TCP_LOW_LATENCY=92,
+	NET_IPV4_IPFRAG_SECRET_INTERVAL=93,
+	NET_IPV4_IGMP_MAX_MSF=94,
+	NET_TCP_VEGAS_ALPHA=95,
+	NET_TCP_VEGAS_BETA=96,
+	NET_TCP_VEGAS_GAMMA=97,
 };
 
 enum {
diff -urNp -X dontdiff linux-2.6/include/linux/tcp.h tcp-vegas-2.6/include/linux/tcp.h
--- linux-2.6/include/linux/tcp.h	2004-02-05 14:44:29.000000000 -0800
+++ tcp-vegas-2.6/include/linux/tcp.h	2004-03-12 14:37:18.000000000 -0800
@@ -253,6 +253,8 @@ struct tcp_opt {
 	__u16	ext2_header_len;/* Options depending on route */
 	__u8	ca_state;	/* State of fast-retransmit machine 	*/
 	__u8	retransmits;	/* Number of unrecovered RTO timeouts.	*/
+	__u8	frto_counter;   /* Number of new acks after RTO */
+	__u8	features;	/* Feature (vegas, frto, ...) metric    */
 
 	__u8	reordering;	/* Packet reordering metric.		*/
 	__u8	queue_shrunk;	/* Write queue has been shrunk recently.*/
@@ -370,7 +372,6 @@ struct tcp_opt {
 	unsigned int		keepalive_intvl;  /* time interval between keep alive probes */
 	int			linger2;
 
-	int                     frto_counter; /* Number of new acks after RTO */
 	__u32                   frto_highmark; /* snd_nxt when RTO occurred */
 
 	unsigned long last_synq_overflow; 
@@ -388,6 +389,16 @@ struct tcp_opt {
                 __u32    rtt;
                 __u32    rtt_min;          /* minimum observed RTT */
         } westwood;
+/* Vegas variables */
+	struct {
+		__u32	beg_snd_nxt;	/* right edge during last RTT */
+		__u32	beg_snd_una;	/* left edge  during last RTT */
+		__u32	beg_snd_cwnd;	/* saves the size of the cwnd */
+		__u8	doing_vegas_now;/* if true, do vegas for this RTT */
+		__u16	cntRTT;		/* # of RTTs measured within last RTT */
+		__u32	minRTT;		/* min of RTTs measured within last RTT (in usec) */
+		__u32	baseRTT;	/* the min of all Vegas RTT measurements seen (in usec) */
+	} vegas;
 };
 
 /* WARNING: don't change the layout of the members in tcp_sock! */
diff -urNp -X dontdiff linux-2.6/include/net/tcp.h tcp-vegas-2.6/include/net/tcp.h
--- linux-2.6/include/net/tcp.h	2004-03-01 08:55:47.000000000 -0800
+++ tcp-vegas-2.6/include/net/tcp.h	2004-03-12 14:19:13.000000000 -0800
@@ -580,9 +580,10 @@ extern int sysctl_tcp_rmem[3];
 extern int sysctl_tcp_app_win;
 extern int sysctl_tcp_adv_win_scale;
 extern int sysctl_tcp_tw_reuse;
-extern int sysctl_tcp_frto;
 extern int sysctl_tcp_low_latency;
-extern int sysctl_tcp_westwood;
+extern int sysctl_tcp_vegas_alpha;
+extern int sysctl_tcp_vegas_beta;
+extern int sysctl_tcp_vegas_gamma;
 
 extern atomic_t tcp_memory_allocated;
 extern atomic_t tcp_sockets_allocated;
@@ -1211,6 +1212,59 @@ static inline __u32 tcp_recalc_ssthresh(
 	return max(tp->snd_cwnd >> 1U, 2U);
 }
 
+/* Stop taking Vegas samples for now. */
+#define tcp_vegas_disable(__tp)	((__tp)->vegas.doing_vegas_now = 0)
+
+/* Is this TCP connection using Vegas (regardless of whether it is taking
+ * Vegas measurements at the current time)?
+ */
+#define tcp_is_vegas(__tp)	((__tp)->features & RTAX_FEATURE_VEGAS)
+    
+static inline void tcp_vegas_enable(struct tcp_opt *tp)
+{
+	/* There are several situations when we must "re-start" Vegas:
+	 *
+	 *  o when a connection is established
+	 *  o after an RTO
+	 *  o after fast recovery
+	 *  o when we send a packet and there is no outstanding
+	 *    unacknowledged data (restarting an idle connection)
+	 *
+	 * In these circumstances we cannot do a Vegas calculation at the
+	 * end of the first RTT, because any calculation we do is using
+	 * stale info -- both the saved cwnd and congestion feedback are
+	 * stale.
+	 *
+	 * Instead we must wait until the completion of an RTT during
+	 * which we actually receive ACKs.
+	 */
+    
+	/* Begin taking Vegas samples next time we send something. */
+	tp->vegas.doing_vegas_now = 1;
+     
+	/* Set the beginning of the next send window. */
+	tp->vegas.beg_snd_nxt = tp->snd_nxt;
+
+	tp->vegas.cntRTT = 0;
+	tp->vegas.minRTT = 0x7fffffff;
+}
+
+static inline void tcp_set_ca_state(struct tcp_opt *tp, u8 ca_state)
+{
+	if (tcp_is_vegas(tp)) {
+		if (ca_state == TCP_CA_Open) 
+			tcp_vegas_enable(tp);
+		else
+			tcp_vegas_disable(tp);
+	}
+	tp->ca_state = ca_state;
+}
+
+/* Should we be taking Vegas samples right now? */
+#define tcp_vegas_enabled(__tp)	((__tp)->vegas.doing_vegas_now)
+
+extern void tcp_vegas_init(struct tcp_opt *tp);
+
 /* If cwnd > ssthresh, we may raise ssthresh to be half-way to cwnd.
  * The exception is rate halving phase, when cwnd is decreasing towards
  * ssthresh.
@@ -1270,7 +1324,7 @@ static inline void tcp_enter_cwr(struct 
 	tp->prior_ssthresh = 0;
 	if (tp->ca_state < TCP_CA_CWR) {
 		__tcp_enter_cwr(tp);
-		tp->ca_state = TCP_CA_CWR;
+		tcp_set_ca_state(tp, TCP_CA_CWR);
 	}
 }
 
@@ -1974,6 +2028,8 @@ static inline void tcp_v4_setup_caps(str
 
 #define TCP_CHECK_TIMER(sk) do { } while (0)
 
+#define tcp_is_frto(__tp)	((__tp)->features & RTAX_FEATURE_FRTO)
+
 static inline int tcp_use_frto(const struct sock *sk)
 {
 	const struct tcp_opt *tp = tcp_sk(sk);
@@ -1982,7 +2038,7 @@ static inline int tcp_use_frto(const str
 	 * unsent new data, and the advertised window should allow
 	 * sending it.
 	 */
-	return (sysctl_tcp_frto && tp->send_head &&
+	return (tcp_is_frto(tp) && tp->send_head &&
 		!after(TCP_SKB_CB(tp->send_head)->end_seq,
 		       tp->snd_una + tp->snd_wnd));
 }
@@ -2028,9 +2084,11 @@ extern void tcp_proc_unregister(struct t
 #define TCP_WESTWOOD_INIT_RTT  (20*HZ)           /* maybe too conservative?! */
 #define TCP_WESTWOOD_RTT_MIN   (HZ/20)           /* 50ms */
 
+#define tcp_is_westwood(__tp) ((__tp)->features & RTAX_FEATURE_WESTWOOD)
+
 static inline void tcp_westwood_update_rtt(struct tcp_opt *tp, __u32 rtt_seq)
 {
-        if (sysctl_tcp_westwood)
+        if (tcp_is_westwood(tp))
                 tp->westwood.rtt = rtt_seq;
 }
 
@@ -2039,13 +2097,13 @@ void __tcp_westwood_slow_bw(struct sock 
 
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
 
@@ -2058,14 +2116,14 @@ static inline __u32 __tcp_westwood_bw_rt
 
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
@@ -2078,7 +2136,7 @@ static inline int tcp_westwood_cwnd(stru
 {
 	__u32 cwnd = 0;
 
-	if (sysctl_tcp_westwood) {
+	if (tcp_is_westwood(tp)) {
 		cwnd = __tcp_westwood_bw_rttmin(tp);
 		if (cwnd)
 			tp->snd_cwnd = cwnd;
@@ -2086,4 +2144,5 @@ static inline int tcp_westwood_cwnd(stru
 
 	return (cwnd != 0);
 }
+ 
 #endif	/* _TCP_H */
diff -urNp -X dontdiff linux-2.6/net/ipv4/sysctl_net_ipv4.c tcp-vegas-2.6/net/ipv4/sysctl_net_ipv4.c
--- linux-2.6/net/ipv4/sysctl_net_ipv4.c	2004-03-08 08:32:59.000000000 -0800
+++ tcp-vegas-2.6/net/ipv4/sysctl_net_ipv4.c	2004-03-12 14:20:50.000000000 -0800
@@ -569,14 +569,6 @@ ctl_table ipv4_table[] = {
 		.proc_handler	= &proc_dointvec
 	},
 	{
-		.ctl_name	= NET_TCP_FRTO,
-		.procname	= "tcp_frto",
-		.data		= &sysctl_tcp_frto,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
-	},
-	{
 		.ctl_name	= NET_TCP_LOW_LATENCY,
 		.procname	= "tcp_low_latency",
 		.data		= &sysctl_tcp_low_latency,
@@ -594,9 +586,25 @@ ctl_table ipv4_table[] = {
 		.strategy	= &sysctl_jiffies
 	},
 	{
-		.ctl_name	= NET_TCP_WESTWOOD, 
-		.procname	= "tcp_westwood",
-		.data		= &sysctl_tcp_westwood,
+		.ctl_name	= NET_TCP_VEGAS_ALPHA,
+		.procname	= "tcp_vegas_alpha",
+		.data		= &sysctl_tcp_vegas_alpha,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+	{
+		.ctl_name	= NET_TCP_VEGAS_BETA,
+		.procname	= "tcp_vegas_beta",
+		.data		= &sysctl_tcp_vegas_beta,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+	{
+		.ctl_name	= NET_TCP_VEGAS_GAMMA,
+		.procname	= "tcp_vegas_gamma",
+		.data		= &sysctl_tcp_vegas_gamma,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
diff -urNp -X dontdiff linux-2.6/net/ipv4/tcp.c tcp-vegas-2.6/net/ipv4/tcp.c
--- linux-2.6/net/ipv4/tcp.c	2004-03-02 08:59:43.000000000 -0800
+++ tcp-vegas-2.6/net/ipv4/tcp.c	2004-03-09 16:37:21.000000000 -0800
@@ -2158,7 +2158,7 @@ int tcp_disconnect(struct sock *sk, int 
 	tp->packets_out = 0;
 	tp->snd_ssthresh = 0x7fffffff;
 	tp->snd_cwnd_cnt = 0;
-	tp->ca_state = TCP_CA_Open;
+	tcp_set_ca_state(tp, TCP_CA_Open);
 	tcp_clear_retrans(tp);
 	tcp_delack_init(tp);
 	tp->send_head = NULL;
diff -urNp -X dontdiff linux-2.6/net/ipv4/tcp_input.c tcp-vegas-2.6/net/ipv4/tcp_input.c
--- linux-2.6/net/ipv4/tcp_input.c	2004-02-05 14:44:30.000000000 -0800
+++ tcp-vegas-2.6/net/ipv4/tcp_input.c	2004-03-12 14:25:47.000000000 -0800
@@ -89,8 +89,14 @@ int sysctl_tcp_adv_win_scale = 2;
 int sysctl_tcp_stdurg;
 int sysctl_tcp_rfc1337;
 int sysctl_tcp_max_orphans = NR_FILE;
-int sysctl_tcp_frto;
-int sysctl_tcp_westwood;
+
+/* Default values of the Vegas variables, in fixed-point representation
+ * with V_PARAM_SHIFT bits to the right of the binary point.
+ */
+#define V_PARAM_SHIFT 1
+int sysctl_tcp_vegas_alpha = 1<<V_PARAM_SHIFT;
+int sysctl_tcp_vegas_beta  = 3<<V_PARAM_SHIFT;
+int sysctl_tcp_vegas_gamma = 1<<V_PARAM_SHIFT;
 
 #define FLAG_DATA		0x01 /* Incoming frame contained data.		*/
 #define FLAG_WIN_UPDATE		0x02 /* Incoming ACK was a window update.	*/
@@ -407,6 +413,41 @@ static void tcp_event_data_recv(struct s
 		tcp_grow_window(sk, tp, skb);
 }
 
+/* Set up a new TCP connection, depending on whether it should be
+ * using Vegas or not.
+ */    
+void tcp_vegas_init(struct tcp_opt *tp)
+{
+	if (tcp_is_vegas(tp)) {
+		tp->vegas.baseRTT = 0x7fffffff;
+		tcp_vegas_enable(tp);
+	} else 
+		tcp_vegas_disable(tp);
+}
+
+/* Do RTT sampling needed for Vegas.
+ * Basically we:
+ *   o min-filter RTT samples from within an RTT to get the current
+ *     propagation delay + queuing delay (we are min-filtering to try to
+ *     avoid the effects of delayed ACKs)
+ *   o min-filter RTT samples from a much longer window (forever for now)
+ *     to find the propagation delay (baseRTT)
+ */
+static inline void vegas_rtt_calc(struct tcp_opt *tp, __u32 rtt)
+{
+	__u32 vrtt = rtt + 1; /* Never allow zero rtt or baseRTT */
+
+	/* Filter to find propagation delay: */
+	if (vrtt < tp->vegas.baseRTT) 
+		tp->vegas.baseRTT = vrtt;
+
+	/* Find the min RTT during the last RTT to find
+	 * the current prop. delay + queuing delay:
+	 */
+	tp->vegas.minRTT = min(tp->vegas.minRTT, vrtt);
+	tp->vegas.cntRTT++;
+}
+
 /* Called to compute a smoothed rtt estimate. The data fed to this
  * routine either comes from timestamps, or from segments that were
  * known _not_ to have been retransmitted [see Karn/Partridge
@@ -420,6 +461,9 @@ static void tcp_rtt_estimator(struct tcp
 {
 	long m = mrtt; /* RTT */
 
+	if (tcp_vegas_enabled(tp))
+		vegas_rtt_calc(tp, mrtt);
+
 	/*	The following amusing code comes from Jacobson's
 	 *	article in SIGCOMM '88.  Note that rtt and mdev
 	 *	are scaled versions of rtt and mean deviation.
@@ -537,6 +581,10 @@ void tcp_update_metrics(struct sock *sk)
 			return;
 		}
 
+		/* don't want to store metrics */
+		if (tp->features & RTAX_FEATURE_NOMETRIC)
+			return;
+
 		m = dst_metric(dst, RTAX_RTT) - tp->srtt;
 
 		/* If newly calculated rtt larger than stored one,
@@ -629,6 +677,12 @@ static void tcp_init_metrics(struct sock
 
 	dst_confirm(dst);
 
+	tp->features = dst_metric(dst, RTAX_FEATURES);
+	if (tp->features & RTAX_FEATURE_NOMETRIC) {
+		printk(KERN_DEBUG "skipping initial metric setup\n");
+		goto reset;
+	}
+
 	if (dst_metric_locked(dst, RTAX_CWND))
 		tp->snd_cwnd_clamp = dst_metric(dst, RTAX_CWND);
 	if (dst_metric(dst, RTAX_SSTHRESH)) {
@@ -1003,7 +1057,7 @@ void tcp_enter_frto(struct sock *sk)
 	}
 	tcp_sync_left_out(tp);
 
-	tp->ca_state = TCP_CA_Open;
+	tcp_set_ca_state(tp, TCP_CA_Open);
 	tp->frto_highmark = tp->snd_nxt;
 }
 
@@ -1049,7 +1103,7 @@ void tcp_enter_frto_loss(struct sock *sk
 
 	tp->reordering = min_t(unsigned int, tp->reordering,
 					     sysctl_tcp_reordering);
-	tp->ca_state = TCP_CA_Loss;
+	tcp_set_ca_state(tp, TCP_CA_Loss);
 	tp->high_seq = tp->frto_highmark;
 	TCP_ECN_queue_cwr(tp);
 }
@@ -1112,7 +1166,7 @@ void tcp_enter_loss(struct sock *sk, int
 
 	tp->reordering = min_t(unsigned int, tp->reordering,
 					     sysctl_tcp_reordering);
-	tp->ca_state = TCP_CA_Loss;
+	tcp_set_ca_state(tp, TCP_CA_Loss);
 	tp->high_seq = tp->snd_nxt;
 	TCP_ECN_queue_cwr(tp);
 }
@@ -1489,7 +1543,7 @@ static int tcp_try_undo_recovery(struct 
 		tcp_moderate_cwnd(tp);
 		return 1;
 	}
-	tp->ca_state = TCP_CA_Open;
+	tcp_set_ca_state(tp, TCP_CA_Open);
 	return 0;
 }
 
@@ -1549,7 +1603,7 @@ static int tcp_try_undo_loss(struct sock
 		tp->retransmits = 0;
 		tp->undo_marker = 0;
 		if (!IsReno(tp))
-			tp->ca_state = TCP_CA_Open;
+			tcp_set_ca_state(tp, TCP_CA_Open);
 		return 1;
 	}
 	return 0;
@@ -1583,7 +1637,7 @@ static void tcp_try_to_open(struct sock 
 			state = TCP_CA_Disorder;
 
 		if (tp->ca_state != state) {
-			tp->ca_state = state;
+			tcp_set_ca_state(tp, state);
 			tp->high_seq = tp->snd_nxt;
 		}
 		tcp_moderate_cwnd(tp);
@@ -1642,7 +1696,7 @@ tcp_fastretrans_alert(struct sock *sk, u
 	/* E. Check state exit conditions. State can be terminated
 	 *    when high_seq is ACKed. */
 	if (tp->ca_state == TCP_CA_Open) {
-		if (!sysctl_tcp_frto)
+		if (!tcp_is_frto(tp))
 			BUG_TRAP(tp->retrans_out == 0);
 		tp->retrans_stamp = 0;
 	} else if (!before(tp->snd_una, tp->high_seq)) {
@@ -1658,7 +1712,7 @@ tcp_fastretrans_alert(struct sock *sk, u
 			 * is ACKed for CWR bit to reach receiver. */
 			if (tp->snd_una != tp->high_seq) {
 				tcp_complete_cwr(tp);
-				tp->ca_state = TCP_CA_Open;
+				tcp_set_ca_state(tp, TCP_CA_Open);
 			}
 			break;
 
@@ -1669,7 +1723,7 @@ tcp_fastretrans_alert(struct sock *sk, u
 			     * catching for all duplicate ACKs. */
 			    IsReno(tp) || tp->snd_una != tp->high_seq) {
 				tp->undo_marker = 0;
-				tp->ca_state = TCP_CA_Open;
+				tcp_set_ca_state(tp, TCP_CA_Open);
 			}
 			break;
 
@@ -1743,7 +1797,7 @@ tcp_fastretrans_alert(struct sock *sk, u
 		}
 
 		tp->snd_cwnd_cnt = 0;
-		tp->ca_state = TCP_CA_Recovery;
+		tcp_set_ca_state(tp, TCP_CA_Recovery);
 	}
 
 	if (is_dupack || tcp_head_timedout(sk, tp))
@@ -1814,7 +1868,7 @@ tcp_ack_update_rtt(struct tcp_opt *tp, i
 /* This is Jacobson's slow start and congestion avoidance. 
  * SIGCOMM '88, p. 328.
  */
-static __inline__ void tcp_cong_avoid(struct tcp_opt *tp)
+static __inline__ void reno_cong_avoid(struct tcp_opt *tp)
 {
         if (tp->snd_cwnd <= tp->snd_ssthresh) {
                 /* In "safe" area, increase. */
@@ -1834,6 +1888,236 @@ static __inline__ void tcp_cong_avoid(st
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
+/* This is based on the congestion detection/avoidance scheme described in
+ *    Lawrence S. Brakmo and Larry L. Peterson.
+ *    "TCP Vegas: End to end congestion avoidance on a global internet."
+ *    IEEE Journal on Selected Areas in Communication, 13(8):1465--1480,
+ *    October 1995. Available from:
+ *	ftp://ftp.cs.arizona.edu/xkernel/Papers/jsac.ps
+ *
+ * See http://www.cs.arizona.edu/xkernel/ for their implementation.
+ * The main aspects that distinguish this implementation from the
+ * Arizona Vegas implementation are:
+ *   o We do not change the loss detection or recovery mechanisms of
+ *     Linux in any way. Linux already recovers from losses quite well,
+ *     using fine-grained timers, NewReno, and FACK.
+ *   o To avoid the performance penalty imposed by increasing cwnd
+ *     only every-other RTT during slow start, we increase during
+ *     every RTT during slow start, just like Reno.
+ *   o Largely to allow continuous cwnd growth during slow start,
+ *     we use the rate at which ACKs come back as the "actual"
+ *     rate, rather than the rate at which data is sent.
+ *   o To speed convergence to the right rate, we set the cwnd
+ *     to achieve the right ("actual") rate when we exit slow start.
+ *   o To filter out the noise caused by delayed ACKs, we use the
+ *     minimum RTT sample observed during the last RTT to calculate
+ *     the actual rate.
+ *   o When the sender re-starts from idle, it waits until it has
+ *     received ACKs for an entire flight of new data before making
+ *     a cwnd adjustment decision. The original Vegas implementation
+ *     assumed senders never went idle.
+ */
+static void vegas_cong_avoid(struct tcp_opt *tp, u32 ack, u32 seq_rtt)
+{
+	/* The key players are v_beg_snd_una and v_beg_snd_nxt.
+	 *
+	 * These are so named because they represent the approximate values
+	 * of snd_una and snd_nxt at the beginning of the current RTT. More
+	 * precisely, they represent the amount of data sent during the RTT.
+	 * At the end of the RTT, when we receive an ACK for v_beg_snd_nxt,
+	 * we will calculate that (v_beg_snd_nxt - v_beg_snd_una) outstanding
+	 * bytes of data have been ACKed during the course of the RTT, giving
+	 * an "actual" rate of:
+	 *
+	 *     (v_beg_snd_nxt - v_beg_snd_una) / (rtt duration)
+	 *
+	 * Unfortunately, v_beg_snd_una is not exactly equal to snd_una,
+	 * because delayed ACKs can cover more than one segment, so they
+	 * don't line up nicely with the boundaries of RTTs.
+	 *
+	 * Another unfortunate fact of life is that delayed ACKs delay the
+	 * advance of the left edge of our send window, so that the number
+	 * of bytes we send in an RTT is often less than our cwnd will allow.
+	 * So we keep track of our cwnd separately, in v_beg_snd_cwnd.
+	 */
+
+	if (after(ack, tp->vegas.beg_snd_nxt)) {
+		/* Do the Vegas once-per-RTT cwnd adjustment. */
+		u32 old_wnd, old_snd_cwnd;
+
+		
+		/* Here old_wnd is essentially the window of data that was
+		 * sent during the previous RTT, and has all
+		 * been acknowledged in the course of the RTT that ended
+		 * with the ACK we just received. Likewise, old_snd_cwnd
+		 * is the cwnd during the previous RTT.
+		 */
+		old_wnd = (tp->vegas.beg_snd_nxt - tp->vegas.beg_snd_una) /
+			tp->mss_cache;
+		old_snd_cwnd = tp->vegas.beg_snd_cwnd;
+
+		/* Save the extent of the current window so we can use this
+		 * at the end of the next RTT.
+		 */
+		tp->vegas.beg_snd_una  = tp->vegas.beg_snd_nxt;
+		tp->vegas.beg_snd_nxt  = tp->snd_nxt;
+		tp->vegas.beg_snd_cwnd = tp->snd_cwnd;
+
+		/* Take into account the current RTT sample too, to
+		 * decrease the impact of delayed acks. This double counts
+		 * this sample since we count it for the next window as well,
+		 * but that's not too awful, since we're taking the min,
+		 * rather than averaging.
+		 */
+		vegas_rtt_calc(tp, seq_rtt);
+
+		/* We do the Vegas calculations only if we got enough RTT
+		 * samples that we can be reasonably sure that we got
+		 * at least one RTT sample that wasn't from a delayed ACK.
+		 * If we only had 2 samples total,
+		 * then that means we're getting only 1 ACK per RTT, which
+		 * means they're almost certainly delayed ACKs.
+		 * If  we have 3 samples, we should be OK.
+		 */
+
+		if (tp->vegas.cntRTT <= 2) {
+			/* We don't have enough RTT samples to do the Vegas
+			 * calculation, so we'll behave like Reno.
+			 */
+			if (tp->snd_cwnd > tp->snd_ssthresh)
+				tp->snd_cwnd++;
+		} else {
+			u32 rtt, target_cwnd, diff;
+
+			/* We have enough RTT samples, so, using the Vegas
+			 * algorithm, we determine if we should increase or
+			 * decrease cwnd, and by how much.
+			 */
+
+			/* Pluck out the RTT we are using for the Vegas
+			 * calculations. This is the min RTT seen during the
+			 * last RTT. Taking the min filters out the effects
+			 * of delayed ACKs, at the cost of noticing congestion
+			 * a bit later.
+			 */
+			rtt = tp->vegas.minRTT;
+
+			/* Calculate the cwnd we should have, if we weren't
+			 * going too fast.
+			 *
+			 * This is:
+			 *     (actual rate in segments) * baseRTT
+			 * We keep it as a fixed point number with
+			 * V_PARAM_SHIFT bits to the right of the binary point.
+			 */
+			target_cwnd = ((old_wnd * tp->vegas.baseRTT)
+				       << V_PARAM_SHIFT) / rtt;
+
+			/* Calculate the difference between the window we had,
+			 * and the window we would like to have. This quantity
+			 * is the "Diff" from the Arizona Vegas papers.
+			 *
+			 * Again, this is a fixed point number with
+			 * V_PARAM_SHIFT bits to the right of the binary
+			 * point.
+			 */
+			diff = (old_wnd << V_PARAM_SHIFT) - target_cwnd;
+
+			if (tp->snd_cwnd < tp->snd_ssthresh) {
+				/* Slow start.  */
+				if (diff > sysctl_tcp_vegas_gamma) {
+					/* Going too fast. Time to slow down
+					 * and switch to congestion avoidance.
+					 */
+					tp->snd_ssthresh = 2;
+
+					/* Set cwnd to match the actual rate
+					 * exactly:
+					 *   cwnd = (actual rate) * baseRTT
+					 * Then we add 1 because the integer
+					 * truncation robs us of full link
+					 * utilization.
+					 */
+					tp->snd_cwnd = min(tp->snd_cwnd,
+							   (target_cwnd >>
+							    V_PARAM_SHIFT)+1);
+
+				}
+			} else {
+				/* Congestion avoidance. */
+				u32 next_snd_cwnd;
+
+				/* Figure out where we would like cwnd
+				 * to be.
+				 */
+				if (diff > sysctl_tcp_vegas_beta) {
+					/* The old window was too fast, so
+					 * we slow down.
+					 */
+					next_snd_cwnd = old_snd_cwnd - 1;
+				} else if (diff < sysctl_tcp_vegas_alpha) {
+					/* We don't have enough extra packets
+					 * in the network, so speed up.
+					 */
+					next_snd_cwnd = old_snd_cwnd + 1;
+				} else {
+					/* Sending just as fast as we
+					 * should be.
+					 */
+					next_snd_cwnd = old_snd_cwnd;
+				}
+
+				/* Adjust cwnd upward or downward, toward the
+				 * desired value.
+				 */
+				if (next_snd_cwnd > tp->snd_cwnd)
+					tp->snd_cwnd++;
+				else if (next_snd_cwnd < tp->snd_cwnd)
+					tp->snd_cwnd--;
+			}
+		}
+
+		/* Wipe the slate clean for the next RTT. */
+		tp->vegas.cntRTT = 0;
+		tp->vegas.minRTT = 0x7fffffff;
+	}
+
+	/* The following code is executed for every ack we receive,
+	 * except for conditions checked in should_advance_cwnd()
+	 * before the call to tcp_cong_avoid(). Mainly this means that
+	 * we only execute this code if the ack actually acked some
+	 * data.
+	 */
+
+	/* If we are in slow start, increase our cwnd in response to this ACK.
+	 * (If we are not in slow start then we are in congestion avoidance,
+	 * and adjust our congestion window only once per RTT. See the code
+	 * above.)
+	 */
+	if (tp->snd_cwnd <= tp->snd_ssthresh) 
+		tp->snd_cwnd++;
+
+	/* to keep cwnd from growing without bound */
+	tp->snd_cwnd = min_t(u32, tp->snd_cwnd, tp->snd_cwnd_clamp);
+
+	/* Make sure that we are never so timid as to reduce our cwnd below
+	 * 2 MSS.
+	 *
+	 * Going below 2 MSS would risk huge delayed ACKs from our receiver.
+	 */
+	tp->snd_cwnd = max(tp->snd_cwnd, 2U);
+
+	tp->snd_cwnd_stamp = tcp_time_stamp;
+}
+
+static inline void tcp_cong_avoid(struct tcp_opt *tp, u32 ack, u32 seq_rtt)
+{
+	if (tcp_vegas_enabled(tp))
+		vegas_cong_avoid(tp, ack, seq_rtt);
+	else
+		reno_cong_avoid(tp);
+}
+
 /* Restart timer after forward progress on connection.
  * RFC2988 recommends to restart timer to now+rto.
  */
@@ -1848,7 +2132,7 @@ static __inline__ void tcp_ack_packets_o
 }
 
 /* Remove acknowledged frames from the retransmission queue. */
-static int tcp_clean_rtx_queue(struct sock *sk)
+static int tcp_clean_rtx_queue(struct sock *sk, __s32 *seq_rtt_p)
 {
 	struct tcp_opt *tp = tcp_sk(sk);
 	struct sk_buff *skb;
@@ -1934,6 +2218,7 @@ static int tcp_clean_rtx_queue(struct so
 		}
 	}
 #endif
+	*seq_rtt_p = seq_rtt;
 	return acked;
 }
 
@@ -2294,6 +2579,7 @@ static int tcp_ack(struct sock *sk, stru
 	u32 ack_seq = TCP_SKB_CB(skb)->seq;
 	u32 ack = TCP_SKB_CB(skb)->ack_seq;
 	u32 prior_in_flight;
+	s32 seq_rtt;
 	int prior_packets;
 
 	/* If the ack is newer than sent or older than previous acks
@@ -2345,7 +2631,7 @@ static int tcp_ack(struct sock *sk, stru
 	prior_in_flight = tcp_packets_in_flight(tp);
 
 	/* See if we can take anything off of the retransmit queue. */
-	flag |= tcp_clean_rtx_queue(sk);
+	flag |= tcp_clean_rtx_queue(sk, &seq_rtt);
 
 	if (tp->frto_counter)
 		tcp_process_frto(sk, prior_snd_una);
@@ -2353,13 +2639,14 @@ static int tcp_ack(struct sock *sk, stru
 	if (tcp_ack_is_dubious(tp, flag)) {
 		/* Advanve CWND, if state allows this. */
 		if ((flag & FLAG_DATA_ACKED) &&
-		    prior_in_flight >= tp->snd_cwnd &&
+		    (tcp_vegas_enabled(tp) || prior_in_flight >= tp->snd_cwnd) &&
 		    tcp_may_raise_cwnd(tp, flag))
-			tcp_cong_avoid(tp);
+			tcp_cong_avoid(tp, ack, seq_rtt);
 		tcp_fastretrans_alert(sk, prior_snd_una, prior_packets, flag);
 	} else {
-		if ((flag & FLAG_DATA_ACKED) && prior_in_flight >= tp->snd_cwnd)
-			tcp_cong_avoid(tp);
+		if ((flag & FLAG_DATA_ACKED) && 
+		    (tcp_vegas_enabled(tp) || prior_in_flight >= tp->snd_cwnd))
+			tcp_cong_avoid(tp, ack, seq_rtt);
 	}
 
 	if ((flag & FLAG_FORWARD_PROGRESS) || !(flag&FLAG_NOT_DUP))
diff -urNp -X dontdiff linux-2.6/net/ipv4/tcp_minisocks.c tcp-vegas-2.6/net/ipv4/tcp_minisocks.c
--- linux-2.6/net/ipv4/tcp_minisocks.c	2004-03-01 08:55:47.000000000 -0800
+++ tcp-vegas-2.6/net/ipv4/tcp_minisocks.c	2004-03-08 09:33:16.000000000 -0800
@@ -769,7 +769,7 @@ struct sock *tcp_create_openreq_child(st
 		newtp->frto_counter = 0;
 		newtp->frto_highmark = 0;
 
-		newtp->ca_state = TCP_CA_Open;
+		tcp_set_ca_state(newtp, TCP_CA_Open);
 		tcp_init_xmit_timers(newsk);
 		skb_queue_head_init(&newtp->out_of_order_queue);
 		newtp->send_head = NULL;
@@ -841,6 +841,8 @@ struct sock *tcp_create_openreq_child(st
 		if (newtp->ecn_flags&TCP_ECN_OK)
 			newsk->sk_no_largesend = 1;
 
+		tcp_vegas_init(newtp);
+
 		TCP_INC_STATS_BH(TcpPassiveOpens);
 	}
 	return newsk;
diff -urNp -X dontdiff linux-2.6/net/ipv4/tcp_output.c tcp-vegas-2.6/net/ipv4/tcp_output.c
--- linux-2.6/net/ipv4/tcp_output.c	2004-01-23 09:39:28.000000000 -0800
+++ tcp-vegas-2.6/net/ipv4/tcp_output.c	2004-03-09 14:05:56.000000000 -0800
@@ -105,7 +105,9 @@ static void tcp_cwnd_restart(struct tcp_
 	s32 delta = tcp_time_stamp - tp->lsndtime;
 	u32 restart_cwnd = tcp_init_cwnd(tp, dst);
 	u32 cwnd = tp->snd_cwnd;
-
+	
+	if (tcp_is_vegas(tp)) 
+		tcp_vegas_enable(tp);
 	tp->snd_ssthresh = tcp_current_ssthresh(tp);
 	restart_cwnd = min(restart_cwnd, cwnd);
 
@@ -225,6 +227,19 @@ int tcp_transmit_skb(struct sock *sk, st
 			tcp_header_size += (TCPOLEN_SACK_BASE_ALIGNED +
 					    (tp->eff_sacks * TCPOLEN_SACK_PERBLOCK));
 		}
+		
+		/*
+		 * If the connection is idle and we are restarting,
+		 * then we don't want to do any Vegas calculations
+		 * until we get fresh RTT samples.  So when we
+		 * restart, we reset our Vegas state to a clean
+		 * slate. After we get acks for this flight of
+		 * packets, _then_ we can make Vegas calculations
+		 * again.
+		 */
+		if (tcp_is_vegas(tp) && tcp_packets_in_flight(tp) == 0)
+			tcp_vegas_enable(tp);
+
 		th = (struct tcphdr *) skb_push(skb, tcp_header_size);
 		skb->h.th = th;
 		skb_set_owner_w(skb, sk);
@@ -869,7 +884,7 @@ void tcp_simple_retransmit(struct sock *
 		tp->snd_ssthresh = tcp_current_ssthresh(tp);
 		tp->prior_ssthresh = 0;
 		tp->undo_marker = 0;
-		tp->ca_state = TCP_CA_Loss;
+		tcp_set_ca_state(tp, TCP_CA_Loss);
 	}
 	tcp_xmit_retransmit_queue(sk);
 }
@@ -1268,6 +1283,7 @@ static inline void tcp_connect_init(stru
 		tp->window_clamp = dst_metric(dst, RTAX_WINDOW);
 	tp->advmss = dst_metric(dst, RTAX_ADVMSS);
 	tcp_initialize_rcv_mss(sk);
+	tcp_vegas_init(tp);
 
 	tcp_select_initial_window(tcp_full_space(sk),
 				  tp->advmss - (tp->ts_recent_stamp ? tp->tcp_header_len - sizeof(struct tcphdr) : 0),
@@ -1318,6 +1334,7 @@ int tcp_connect(struct sock *sk)
 	TCP_SKB_CB(buff)->end_seq = tp->write_seq;
 	tp->snd_nxt = tp->write_seq;
 	tp->pushed_seq = tp->write_seq;
+	tcp_vegas_init(tp);
 
 	/* Send it off. */
 	TCP_SKB_CB(buff)->when = tcp_time_stamp;
