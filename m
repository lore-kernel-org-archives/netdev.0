From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFC] TCP congestion schedulers
Date: Mon, 14 Mar 2005 15:17:26 -0800
Message-ID: <20050314151726.532af90d@dxpl.pdx.osdl.net>
References: <421CF5E5.1060606@ev-en.org>
	<20050223135732.39e62c6c.davem@davemloft.net>
	<421D1E66.5090301@osdl.org>
	<421D30FA.1060900@ev-en.org>
	<20050225120814.5fa77b13@dxpl.pdx.osdl.net>
	<20050309210442.3e9786a6.davem@davemloft.net>
	<4230288F.1030202@ev-en.org>
	<20050310182629.1eab09ec.davem@davemloft.net>
	<20050311120054.4bbf675a@dxpl.pdx.osdl.net>
	<20050311201011.360c00da.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: baruch@ev-en.org, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050311201011.360c00da.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Since developers want to experiment with different congestion
control mechanisms, and the kernel is getting bloated with overlapping
data structure and code for multiple algorithms; here is a patch to
split out the Reno, Vegas, Westwood, BIC congestion control stuff
into an infrastructure similar to the I/O schedulers.

Congestion control protocol is controlled by sysctl net.ipv4.tcp_congestion_control
and the boot parameter tcp_congestion_control.  The parameter is a lower case
string.  The congestion control is set when the socket is connected.
If you give a bogus value to the parameter, then it warns and falls back to using
TCP Reno. TCP Reno is still required, both as a fallback protocol and to allow
other code to use it. No attempt was made to do backward compatibility with
the old sysctl's (net.ipv4.tcp_bic, ...)

Individual protocols can have parameters but instead of being sysctl's they
are done as module parameters. Sysctl hooks are not ref counted so they can't be
safely used by modules. Parmeters can be changed via sysfs.

This is not complete and bugs were probably inserted when extracting out
the algorithms so more testing is needed.

---
diff -urNp -X dontdiff linux-2.6/include/linux/sysctl.h tcp-2.6/include/linux/sysctl.h
--- linux-2.6/include/linux/sysctl.h	2005-03-14 14:30:49.000000000 -0800
+++ tcp-2.6/include/linux/sysctl.h	2005-03-11 15:45:27.000000000 -0800
@@ -346,6 +346,7 @@ enum
 	NET_TCP_MODERATE_RCVBUF=106,
 	NET_TCP_TSO_WIN_DIVISOR=107,
 	NET_TCP_BIC_BETA=108,
+	NET_TCP_CONG_CONTROL=109,
 };
 
 enum {
diff -urNp -X dontdiff linux-2.6/include/linux/tcp.h tcp-2.6/include/linux/tcp.h
--- linux-2.6/include/linux/tcp.h	2005-03-14 14:30:49.000000000 -0800
+++ tcp-2.6/include/linux/tcp.h	2005-03-11 16:30:28.000000000 -0800
@@ -203,13 +203,6 @@ struct tcp_sack_block {
 	__u32	end_seq;
 };
 
-enum tcp_congestion_algo {
-	TCP_RENO=0,
-	TCP_VEGAS,
-	TCP_WESTWOOD,
-	TCP_BIC,
-};
-
 struct tcp_options_received {
 /*	PAWS/RTTM data	*/
 	long	ts_recent_stamp;/* Time we stored ts_recent (for aging) */
@@ -295,7 +288,7 @@ struct tcp_sock {
 	__u8	reordering;	/* Packet reordering metric.		*/
 	__u8	frto_counter;	/* Number of new acks after RTO */
 
-	__u8	adv_cong;	/* Using Vegas, Westwood, or BIC */
+	__u8	unused;
 	__u8	defer_accept;	/* User waits for some data after accept() */
 
 /* RTT measurement */
@@ -406,37 +399,10 @@ struct tcp_sock {
 		__u32	time;
 	} rcvq_space;
 
-/* TCP Westwood structure */
-        struct {
-                __u32    bw_ns_est;        /* first bandwidth estimation..not too smoothed 8) */
-                __u32    bw_est;           /* bandwidth estimate */
-                __u32    rtt_win_sx;       /* here starts a new evaluation... */
-                __u32    bk;
-                __u32    snd_una;          /* used for evaluating the number of acked bytes */
-                __u32    cumul_ack;
-                __u32    accounted;
-                __u32    rtt;
-                __u32    rtt_min;          /* minimum observed RTT */
-        } westwood;
-
-/* Vegas variables */
-	struct {
-		__u32	beg_snd_nxt;	/* right edge during last RTT */
-		__u32	beg_snd_una;	/* left edge  during last RTT */
-		__u32	beg_snd_cwnd;	/* saves the size of the cwnd */
-		__u8	doing_vegas_now;/* if true, do vegas for this RTT */
-		__u16	cntRTT;		/* # of RTTs measured within last RTT */
-		__u32	minRTT;		/* min of RTTs measured within last RTT (in usec) */
-		__u32	baseRTT;	/* the min of all Vegas RTT measurements seen (in usec) */
-	} vegas;
-
-	/* BI TCP Parameters */
-	struct {
-		__u32	cnt;		/* increase cwnd by 1 after this number of ACKs */
-		__u32 	last_max_cwnd;	/* last maximium snd_cwnd */
-		__u32	last_cwnd;	/* the last snd_cwnd */
-		__u32   last_stamp;     /* time when updated last_cwnd */
-	} bictcp;
+/* Hook for advanced congestion control */
+	struct tcp_ca_type *ca_proto;
+#define TCP_CA_PRIV_SIZE	48
+	u8	         *ca_priv[TCP_CA_PRIV_SIZE];
 };
 
 static inline struct tcp_sock *tcp_sk(const struct sock *sk)
@@ -444,6 +410,11 @@ static inline struct tcp_sock *tcp_sk(co
 	return (struct tcp_sock *)sk;
 }
 
+static inline void *tcp_ca(const struct tcp_sock *tp)
+{
+	return (void *) tp->ca_priv;
+}
+
 #endif
 
 #endif	/* _LINUX_TCP_H */
diff -urNp -X dontdiff linux-2.6/include/net/tcp.h tcp-2.6/include/net/tcp.h
--- linux-2.6/include/net/tcp.h	2005-03-14 14:30:50.000000000 -0800
+++ tcp-2.6/include/net/tcp.h	2005-03-11 16:26:17.000000000 -0800
@@ -504,25 +504,6 @@ static __inline__ int tcp_sk_listen_hash
 #else
 # define TCP_TW_RECYCLE_TICK (12+2-TCP_TW_RECYCLE_SLOTS_LOG)
 #endif
-
-#define BICTCP_BETA_SCALE    1024	/* Scale factor beta calculation
-					 * max_cwnd = snd_cwnd * beta
-					 */
-#define BICTCP_MAX_INCREMENT 32		/*
-					 * Limit on the amount of
-					 * increment allowed during
-					 * binary search.
-					 */
-#define BICTCP_FUNC_OF_MIN_INCR 11	/*
-					 * log(B/Smin)/log(B/(B-1))+1,
-					 * Smin:min increment
-					 * B:log factor
-					 */
-#define BICTCP_B		4	 /*
-					  * In binary search,
-					  * go to point (max+min)/N
-					  */
-
 /*
  *	TCP option
  */
@@ -596,16 +577,7 @@ extern int sysctl_tcp_adv_win_scale;
 extern int sysctl_tcp_tw_reuse;
 extern int sysctl_tcp_frto;
 extern int sysctl_tcp_low_latency;
-extern int sysctl_tcp_westwood;
-extern int sysctl_tcp_vegas_cong_avoid;
-extern int sysctl_tcp_vegas_alpha;
-extern int sysctl_tcp_vegas_beta;
-extern int sysctl_tcp_vegas_gamma;
 extern int sysctl_tcp_nometrics_save;
-extern int sysctl_tcp_bic;
-extern int sysctl_tcp_bic_fast_convergence;
-extern int sysctl_tcp_bic_low_window;
-extern int sysctl_tcp_bic_beta;
 extern int sysctl_tcp_moderate_rcvbuf;
 extern int sysctl_tcp_tso_win_divisor;
 
@@ -1203,6 +1175,61 @@ static inline void tcp_packets_out_dec(s
 	tp->packets_out -= tcp_skb_pcount(skb);
 }
 
+/*
+ * Hooks for TCP congestion control algorithms
+ */
+enum tcp_ca_event {
+	CA_EVENT_CWND_RESTART,
+	CA_EVENT_COMPLETE_CWR,
+	CA_EVENT_FRTO,
+	CA_EVENT_FAST_ACK,
+	CA_EVENT_SLOW_ACK,
+};
+
+struct tcp_ca_type {
+	void (*start)(struct tcp_sock *tp);
+	u32 (*ssthresh)(struct tcp_sock *tp);
+	u32 (*min_cwnd)(struct tcp_sock *tp);
+	void (*cong_avoid)(struct tcp_sock *tp, u32 ack, 
+			   u32 rtt, u32 in_flight);
+	void (*rtt_sample)(struct tcp_sock *tp, u32 rtt);
+	void (*set_state)(struct tcp_sock *tp, u8 new_state);
+
+	void (*cwnd_event)(struct tcp_sock *tp, enum tcp_ca_event ev);
+
+	struct list_head	list;
+	struct module 		*owner;
+	const char 		*name;
+};
+
+
+#define TCP_CA_NAME_MAX	32
+extern char sysctl_tcp_ca_protocol[TCP_CA_NAME_MAX];
+extern void tcp_ca_register(struct tcp_ca_type *type);
+extern void tcp_ca_unregister(struct tcp_ca_type *type);
+extern void tcp_ca_init(struct tcp_sock *tp);
+extern void tcp_ca_destroy(struct tcp_sock *tp);
+
+extern struct tcp_ca_type tcp_reno;
+extern void tcp_reno_cong_avoid(struct tcp_sock *tp, u32 ack, 
+				u32 rtt, u32 in_flight);
+extern u32 tcp_reno_cwnd_min(struct tcp_sock *tp);
+extern u32 tcp_reno_ssthresh(struct tcp_sock *tp);
+
+static inline void tcp_set_ca_state(struct tcp_sock *tp, u8 ca_state)
+{
+	if (tp->ca_proto->set_state)
+		tp->ca_proto->set_state(tp, ca_state);
+	tp->ca_state = ca_state;
+}
+
+static inline void tcp_ca_event(struct tcp_sock *tp, enum tcp_ca_event event)
+{
+	if (tp->ca_proto->cwnd_event)
+		tp->ca_proto->cwnd_event(tp, event);
+}
+
+
 /* This determines how many packets are "in the network" to the best
  * of our knowledge.  In many cases it is conservative, but where
  * detailed information is available from the receiver (via SACK
@@ -1222,91 +1249,6 @@ static __inline__ unsigned int tcp_packe
 	return (tp->packets_out - tp->left_out + tp->retrans_out);
 }
 
-/*
- * Which congestion algorithim is in use on the connection.
- */
-#define tcp_is_vegas(__tp)	((__tp)->adv_cong == TCP_VEGAS)
-#define tcp_is_westwood(__tp)	((__tp)->adv_cong == TCP_WESTWOOD)
-#define tcp_is_bic(__tp)	((__tp)->adv_cong == TCP_BIC)
-
-/* Recalculate snd_ssthresh, we want to set it to:
- *
- * Reno:
- * 	one half the current congestion window, but no
- *	less than two segments
- *
- * BIC:
- *	behave like Reno until low_window is reached,
- *	then increase congestion window slowly
- */
-static inline __u32 tcp_recalc_ssthresh(struct tcp_sock *tp)
-{
-	if (tcp_is_bic(tp)) {
-		if (sysctl_tcp_bic_fast_convergence &&
-		    tp->snd_cwnd < tp->bictcp.last_max_cwnd)
-			tp->bictcp.last_max_cwnd = (tp->snd_cwnd * 
-						    (BICTCP_BETA_SCALE
-						     + sysctl_tcp_bic_beta))
-				/ (2 * BICTCP_BETA_SCALE);
-		else
-			tp->bictcp.last_max_cwnd = tp->snd_cwnd;
-
-		if (tp->snd_cwnd > sysctl_tcp_bic_low_window)
-			return max((tp->snd_cwnd * sysctl_tcp_bic_beta)
-				   / BICTCP_BETA_SCALE, 2U);
-	}
-
-	return max(tp->snd_cwnd >> 1U, 2U);
-}
-
-/* Stop taking Vegas samples for now. */
-#define tcp_vegas_disable(__tp)	((__tp)->vegas.doing_vegas_now = 0)
-    
-static inline void tcp_vegas_enable(struct tcp_sock *tp)
-{
-	/* There are several situations when we must "re-start" Vegas:
-	 *
-	 *  o when a connection is established
-	 *  o after an RTO
-	 *  o after fast recovery
-	 *  o when we send a packet and there is no outstanding
-	 *    unacknowledged data (restarting an idle connection)
-	 *
-	 * In these circumstances we cannot do a Vegas calculation at the
-	 * end of the first RTT, because any calculation we do is using
-	 * stale info -- both the saved cwnd and congestion feedback are
-	 * stale.
-	 *
-	 * Instead we must wait until the completion of an RTT during
-	 * which we actually receive ACKs.
-	 */
-    
-	/* Begin taking Vegas samples next time we send something. */
-	tp->vegas.doing_vegas_now = 1;
-     
-	/* Set the beginning of the next send window. */
-	tp->vegas.beg_snd_nxt = tp->snd_nxt;
-
-	tp->vegas.cntRTT = 0;
-	tp->vegas.minRTT = 0x7fffffff;
-}
-
-/* Should we be taking Vegas samples right now? */
-#define tcp_vegas_enabled(__tp)	((__tp)->vegas.doing_vegas_now)
-
-extern void tcp_ca_init(struct tcp_sock *tp);
-
-static inline void tcp_set_ca_state(struct tcp_sock *tp, u8 ca_state)
-{
-	if (tcp_is_vegas(tp)) {
-		if (ca_state == TCP_CA_Open) 
-			tcp_vegas_enable(tp);
-		else
-			tcp_vegas_disable(tp);
-	}
-	tp->ca_state = ca_state;
-}
-
 /* If cwnd > ssthresh, we may raise ssthresh to be half-way to cwnd.
  * The exception is rate halving phase, when cwnd is decreasing towards
  * ssthresh.
@@ -1355,7 +1297,7 @@ static inline void tcp_cwnd_validate(str
 static inline void __tcp_enter_cwr(struct tcp_sock *tp)
 {
 	tp->undo_marker = 0;
-	tp->snd_ssthresh = tcp_recalc_ssthresh(tp);
+	tp->snd_ssthresh = tp->ca_proto->ssthresh(tp);
 	tp->snd_cwnd = min(tp->snd_cwnd,
 			   tcp_packets_in_flight(tp) + 1U);
 	tp->snd_cwnd_cnt = 0;
@@ -1970,52 +1912,4 @@ struct tcp_iter_state {
 extern int tcp_proc_register(struct tcp_seq_afinfo *afinfo);
 extern void tcp_proc_unregister(struct tcp_seq_afinfo *afinfo);
 
-/* TCP Westwood functions and constants */
-
-#define TCP_WESTWOOD_INIT_RTT  (20*HZ)           /* maybe too conservative?! */
-#define TCP_WESTWOOD_RTT_MIN   (HZ/20)           /* 50ms */
-
-static inline void tcp_westwood_update_rtt(struct tcp_sock *tp, __u32 rtt_seq)
-{
-        if (tcp_is_westwood(tp))
-                tp->westwood.rtt = rtt_seq;
-}
-
-static inline __u32 __tcp_westwood_bw_rttmin(const struct tcp_sock *tp)
-{
-        return max((tp->westwood.bw_est) * (tp->westwood.rtt_min) /
-		   (__u32) (tp->mss_cache_std),
-		   2U);
-}
-
-static inline __u32 tcp_westwood_bw_rttmin(const struct tcp_sock *tp)
-{
-	return tcp_is_westwood(tp) ? __tcp_westwood_bw_rttmin(tp) : 0;
-}
-
-static inline int tcp_westwood_ssthresh(struct tcp_sock *tp)
-{
-	__u32 ssthresh = 0;
-
-	if (tcp_is_westwood(tp)) {
-		ssthresh = __tcp_westwood_bw_rttmin(tp);
-		if (ssthresh)
-			tp->snd_ssthresh = ssthresh;  
-	}
-
-	return (ssthresh != 0);
-}
-
-static inline int tcp_westwood_cwnd(struct tcp_sock *tp)
-{
-	__u32 cwnd = 0;
-
-	if (tcp_is_westwood(tp)) {
-		cwnd = __tcp_westwood_bw_rttmin(tp);
-		if (cwnd)
-			tp->snd_cwnd = cwnd;
-	}
-
-	return (cwnd != 0);
-}
 #endif	/* _TCP_H */
diff -urNp -X dontdiff linux-2.6/net/ipv4/Kconfig tcp-2.6/net/ipv4/Kconfig
--- linux-2.6/net/ipv4/Kconfig	2005-03-14 14:30:52.000000000 -0800
+++ tcp-2.6/net/ipv4/Kconfig	2005-03-11 15:45:32.000000000 -0800
@@ -365,5 +365,48 @@ config IP_TCPDIAG
 config IP_TCPDIAG_IPV6
 	def_bool (IP_TCPDIAG=y && IPV6=y) || (IP_TCPDIAG=m && IPV6)
 
+menu "TCP congestion control"
+
+# Reno is required as fallback
+config TCP_CONG_VEGAS
+	tristate "TCP Vegas"
+	default n
+	---help---
+	TCP Vegas is a sender-side only change to TCP that anticipates
+	the onset of congestion by estimating the bandwidth. TCP Vegas
+	adjusts the sending rate by modifying the congestion
+	window. TCP Vegas should provide less packet loss, but it is
+	not as aggressive as TCP Reno.
+
+config TCP_CONG_BIC
+	tristate "Binary Increase Congestion (BIC) control"
+	default y
+	---help---
+	BIC-TCP is a sender-side only change that ensures a linear RTT
+	fairness under large windows while offering both scalability and
+	bounded TCP-friendliness. The protocol combines two schemes
+	called additive increase and binary search increase. When the
+	congestion window is large, additive increase with a large
+	increment ensures linear RTT fairness as well as good
+	scalability. Under small congestion windows, binary search
+	increase provides TCP friendliness.
+	
+config TCP_CONG_WESTWOOD
+	tristate "TCP Westwood+"
+	default y
+	---help---
+	TCP Westwood+ is a sender-side only modification of the TCP Reno 
+	protocol stack that optimizes the performance of TCP congestion 
+	control. It is based on end-to-end bandwidth estimation to set 
+	congestion window and slow start threshold after a congestion 
+	episode. Using this estimation, TCP Westwood+ adaptively sets a 
+	slow start threshold and a congestion window which takes into 
+	account the bandwidth used  at the time congestion is experienced. 
+	TCP Westwood+ significantly increases fairness wrt TCP Reno in 
+	wired networks and throughput over wireless links.   
+
+endmenu
+
+
 source "net/ipv4/ipvs/Kconfig"
 
diff -urNp -X dontdiff linux-2.6/net/ipv4/Makefile tcp-2.6/net/ipv4/Makefile
--- linux-2.6/net/ipv4/Makefile	2005-03-14 14:30:52.000000000 -0800
+++ tcp-2.6/net/ipv4/Makefile	2005-03-11 15:45:33.000000000 -0800
@@ -5,7 +5,8 @@
 obj-y     := utils.o route.o inetpeer.o protocol.o \
 	     ip_input.o ip_fragment.o ip_forward.o ip_options.o \
 	     ip_output.o ip_sockglue.o \
-	     tcp.o tcp_input.o tcp_output.o tcp_timer.o tcp_ipv4.o tcp_minisocks.o \
+	     tcp.o tcp_input.o tcp_output.o tcp_timer.o tcp_ipv4.o \
+	     tcp_minisocks.o tcp_cong.o tcp_reno.o \
 	     datagram.o raw.o udp.o arp.o icmp.o devinet.o af_inet.o igmp.o \
 	     sysctl_net_ipv4.o fib_frontend.o fib_semantics.o fib_hash.o
 
@@ -23,6 +24,9 @@ obj-$(CONFIG_IP_PNP) += ipconfig.o
 obj-$(CONFIG_NETFILTER)	+= netfilter/
 obj-$(CONFIG_IP_VS) += ipvs/
 obj-$(CONFIG_IP_TCPDIAG) += tcp_diag.o 
+obj-$(CONFIG_TCP_CONG_VEGAS) += tcp_vegas.o
+obj-$(CONFIG_TCP_CONG_BIC) += tcp_bic.o
+obj-$(CONFIG_TCP_CONG_WESTWOOD) += tcp_westwood.o
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
 		      xfrm4_output.o
diff -urNp -X dontdiff linux-2.6/net/ipv4/sysctl_net_ipv4.c tcp-2.6/net/ipv4/sysctl_net_ipv4.c
--- linux-2.6/net/ipv4/sysctl_net_ipv4.c	2005-03-14 14:30:52.000000000 -0800
+++ tcp-2.6/net/ipv4/sysctl_net_ipv4.c	2005-03-11 16:13:46.000000000 -0800
@@ -603,70 +603,6 @@ ctl_table ipv4_table[] = {
 		.proc_handler	= &proc_dointvec,
 	},
 	{
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
-	{
-		.ctl_name	= NET_TCP_VEGAS_ALPHA,
-		.procname	= "tcp_vegas_alpha",
-		.data		= &sysctl_tcp_vegas_alpha,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
-	},
-	{
-		.ctl_name	= NET_TCP_VEGAS_BETA,
-		.procname	= "tcp_vegas_beta",
-		.data		= &sysctl_tcp_vegas_beta,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
-	},
-	{
-		.ctl_name	= NET_TCP_VEGAS_GAMMA,
-		.procname	= "tcp_vegas_gamma",
-		.data		= &sysctl_tcp_vegas_gamma,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
-	},
-	{
-		.ctl_name	= NET_TCP_BIC,
-		.procname	= "tcp_bic",
-		.data		= &sysctl_tcp_bic,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
-	},
-	{
-		.ctl_name	= NET_TCP_BIC_FAST_CONVERGENCE,
-		.procname	= "tcp_bic_fast_convergence",
-		.data		= &sysctl_tcp_bic_fast_convergence,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
-	},
-	{
-		.ctl_name	= NET_TCP_BIC_LOW_WINDOW,
-		.procname	= "tcp_bic_low_window",
-		.data		= &sysctl_tcp_bic_low_window,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
-	},
-	{
 		.ctl_name	= NET_TCP_MODERATE_RCVBUF,
 		.procname	= "tcp_moderate_rcvbuf",
 		.data		= &sysctl_tcp_moderate_rcvbuf,
@@ -683,12 +619,13 @@ ctl_table ipv4_table[] = {
 		.proc_handler	= &proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_TCP_BIC_BETA,
-		.procname	= "tcp_bic_beta",
-		.data		= &sysctl_tcp_bic_beta,
-		.maxlen		= sizeof(int),
+		.ctl_name	= NET_TCP_CONG_CONTROL,
+		.procname	= "tcp_congestion_control",
+		.data		= &sysctl_tcp_ca_protocol,
+		.maxlen		= TCP_CA_NAME_MAX,
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= &proc_dostring,
+		.strategy	= &sysctl_string,
 	},
 	{ .ctl_name = 0 }
 };
diff -urNp -X dontdiff linux-2.6/net/ipv4/tcp_bic.c tcp-2.6/net/ipv4/tcp_bic.c
--- linux-2.6/net/ipv4/tcp_bic.c	1969-12-31 16:00:00.000000000 -0800
+++ tcp-2.6/net/ipv4/tcp_bic.c	2005-03-11 16:32:37.000000000 -0800
@@ -0,0 +1,194 @@
+/* 
+ * Binary Increase Congestion control for TCP
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
+
+#include <linux/config.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <net/tcp.h>
+
+
+#define BICTCP_BETA_SCALE    1024	/* Scale factor beta calculation
+					 * max_cwnd = snd_cwnd * beta
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
+static int fast_convergence = 1;
+static int low_window = 14;
+static int beta = 819;		/* = 819/1024 (BICTCP_BETA_SCALE) */
+
+module_param(fast_convergence, int, 0644);
+MODULE_PARM_DESC(fast_convergence, "turn on/off fast convergence");
+module_param(low_window, int, 0644);
+MODULE_PARM_DESC(low_window, "lower bound on cwind (for TCP friendliness)");
+module_param(beta, int, 0644);
+MODULE_PARM_DESC(beta, "beta for multiplictative increase");
+
+/* BIC TCP Parameters */
+struct bictcp_ca {
+	u32	cnt;		/* increase cwnd by 1 after ACKs */
+	u32 	last_max_cwnd;	/* last maximium snd_cwnd */
+	u32	last_cwnd;	/* the last snd_cwnd */
+	u32	last_stamp;     /* time when updated last_cwnd */
+};
+
+static void bictcp_start(struct tcp_sock *tp)
+{
+	struct bictcp_ca *ca = tcp_ca(tp);
+	ca->cnt = 0;
+	ca->last_max_cwnd = 0;
+	ca->last_cwnd = 0;
+	ca->last_stamp = 0;
+}
+
+/*
+ * Compute congestion window to use.
+ */
+static inline u32 bictcp_cwnd(struct tcp_sock *tp)
+{
+	struct bictcp_ca *ca = tcp_ca(tp);
+
+	if (ca->last_cwnd == tp->snd_cwnd &&
+	   (s32)(tcp_time_stamp - ca->last_stamp) <= (HZ>>5))
+		return ca->cnt;
+
+	ca->last_cwnd = tp->snd_cwnd;
+	ca->last_stamp = tcp_time_stamp;
+      
+	/* start off normal */
+	if (tp->snd_cwnd <= low_window)
+		ca->cnt = tp->snd_cwnd;
+
+	/* binary increase */
+	else if (tp->snd_cwnd < ca->last_max_cwnd) {
+		__u32 	dist = (ca->last_max_cwnd - tp->snd_cwnd)
+			/ BICTCP_B;
+
+		if (dist > BICTCP_MAX_INCREMENT)
+			/* linear increase */
+			ca->cnt = tp->snd_cwnd / BICTCP_MAX_INCREMENT;
+		else if (dist <= 1U)
+			/* binary search increase */
+			ca->cnt = tp->snd_cwnd * BICTCP_FUNC_OF_MIN_INCR
+				/ BICTCP_B;
+		else
+			/* binary search increase */
+			ca->cnt = tp->snd_cwnd / dist;
+	} else {
+		/* slow start amd linear increase */
+		if (tp->snd_cwnd < ca->last_max_cwnd + BICTCP_B)
+			/* slow start */
+			ca->cnt = tp->snd_cwnd * BICTCP_FUNC_OF_MIN_INCR
+				/ BICTCP_B;
+		else if (tp->snd_cwnd < ca->last_max_cwnd
+			 		+ BICTCP_MAX_INCREMENT*(BICTCP_B-1))
+			/* slow start */
+			ca->cnt = tp->snd_cwnd * (BICTCP_B-1)
+				/ (tp->snd_cwnd-ca->last_max_cwnd);
+		else
+			/* linear increase */
+			ca->cnt = tp->snd_cwnd / BICTCP_MAX_INCREMENT;
+	}
+
+	return ca->cnt;
+}
+
+static void bictcp_cong_avoid(struct tcp_sock *tp, u32 ack, 
+				 u32 seq_rtt, u32 in_flight)
+{
+	if (in_flight < tp->snd_cwnd)
+		return;
+
+        if (tp->snd_cwnd <= tp->snd_ssthresh) {
+                /* In "safe" area, increase. */
+		if (tp->snd_cwnd < tp->snd_cwnd_clamp)
+			tp->snd_cwnd++;
+	} else {
+		if (tp->snd_cwnd_cnt > (bictcp_cwnd(tp) << 3)) {
+			tp->snd_cwnd_cnt = 0;
+			tp->snd_cwnd++;
+		}
+	}
+}
+
+
+/*
+ *	behave like Reno until low_window is reached,
+ *	then increase congestion window slowly
+ */
+static u32 bictcp_recalc_ssthresh(struct tcp_sock *tp)
+{
+	struct bictcp_ca *ca = tcp_ca(tp);
+
+	if (fast_convergence && tp->snd_cwnd < ca->last_max_cwnd)
+		ca->last_max_cwnd = (tp->snd_cwnd * (BICTCP_BETA_SCALE + beta))
+			/ (2 * BICTCP_BETA_SCALE);
+	else
+		ca->last_max_cwnd = tp->snd_cwnd;
+
+	if (tp->snd_cwnd <= low_window)
+		return max(tp->snd_cwnd >> 1U, 2U);
+	else
+		return max((tp->snd_cwnd * beta) / BICTCP_BETA_SCALE, 2U);
+}
+
+static void bictcp_ca_state(struct tcp_sock *tp, u8 new_state)
+{
+	if (new_state == TCP_CA_Loss)
+		bictcp_start(tp);
+}
+
+static struct tcp_ca_type bictcp = {
+	.start		= bictcp_start,
+	.ssthresh	= bictcp_recalc_ssthresh,
+	.cong_avoid	= bictcp_cong_avoid,
+	.min_cwnd	= tcp_reno_cwnd_min,
+	.set_state	= bictcp_ca_state,
+
+	.owner		= THIS_MODULE,
+	.name		= "bic",
+};
+
+static int __init bictcp_init(void)
+{
+	BUILD_BUG_ON(sizeof(struct bictcp_ca) > TCP_CA_PRIV_SIZE);
+	tcp_ca_register(&bictcp);
+	return 0;
+}
+
+static void __exit bictcp_exit(void)
+{
+	tcp_ca_unregister(&bictcp);
+}
+
+module_init(bictcp_init);
+module_exit(bictcp_exit);
+
+MODULE_AUTHOR("Stephen Hemminger");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("BIC TCP");
+
+
diff -urNp -X dontdiff linux-2.6/net/ipv4/tcp.c tcp-2.6/net/ipv4/tcp.c
--- linux-2.6/net/ipv4/tcp.c	2005-03-14 14:30:52.000000000 -0800
+++ tcp-2.6/net/ipv4/tcp.c	2005-03-11 16:13:46.000000000 -0800
@@ -2366,6 +2366,8 @@ void __init tcp_init(void)
 	printk(KERN_INFO "TCP: Hash tables configured "
 	       "(established %d bind %d)\n",
 	       tcp_ehash_size << 1, tcp_bhash_size);
+
+	tcp_ca_register(&tcp_reno);
 }
 
 EXPORT_SYMBOL(tcp_accept);
diff -urNp -X dontdiff linux-2.6/net/ipv4/tcp_cong.c tcp-2.6/net/ipv4/tcp_cong.c
--- linux-2.6/net/ipv4/tcp_cong.c	1969-12-31 16:00:00.000000000 -0800
+++ tcp-2.6/net/ipv4/tcp_cong.c	2005-03-14 12:00:25.000000000 -0800
@@ -0,0 +1,112 @@
+/*
+ * Plugable TCP congestion control support.
+ *
+ * Based on ideas from I/O scheduler suport and Web100.
+ *
+ * Copyright (C) 2005 Stephen Hemminger <shemminger@osdl.org>
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/list.h>
+#include <net/tcp.h>
+
+static DEFINE_SPINLOCK(tcp_ca_list_lock);
+static LIST_HEAD(tcp_ca_list);
+
+char sysctl_tcp_ca_protocol[TCP_CA_NAME_MAX] = 
+#if defined(CONFIG_TCP_CONG_BIC)
+	"bic";
+#elif defined(CONFIG_TCP_CONG_WESTWOOD)
+	"westwood";
+#elif defined(CONFIG_TCP_CONG_VEGAS)
+	"vegas";
+#else
+	"reno";
+#endif
+
+static struct tcp_ca_type *tcp_ca_find(const char *name)
+{
+	struct tcp_ca_type *match = NULL;
+	struct list_head *entry;
+
+	rcu_read_lock();
+	list_for_each_rcu(entry, &tcp_ca_list) {
+		struct tcp_ca_type *ca 
+			= list_entry(entry, struct tcp_ca_type, list);
+
+		if (strcmp(ca->name, name) == 0) {
+			match = ca;
+			break;
+		}
+	}
+	rcu_read_unlock();
+	return match;
+}
+
+void tcp_ca_register(struct tcp_ca_type *ca)
+{
+	BUG_ON(tcp_ca_find(ca->name));
+
+	spin_lock_irq(&tcp_ca_list_lock);
+	list_add_tail_rcu(&ca->list, &tcp_ca_list);
+	spin_unlock_irq(&tcp_ca_list_lock);
+
+	printk(KERN_INFO "TCP %s registered\n", ca->name);
+}
+
+void tcp_ca_unregister(struct tcp_ca_type *ca)
+{
+	spin_lock(&tcp_ca_list_lock);
+	list_del_rcu(&ca->list);
+	spin_unlock(&tcp_ca_list_lock);
+}
+
+/* allow setting on boot cmdline */
+static int __init tcp_congestion_setup(char *str)
+{
+	strncpy(sysctl_tcp_ca_protocol, str, TCP_CA_NAME_MAX-1);
+	return 0;
+}
+__setup("tcp_congestion=", tcp_congestion_setup);
+
+/* When starting a new connection, pin down the current choice of 
+ * congestion algorithm.
+ * NB: this depends on tcp_reno being always available.
+ */
+void tcp_ca_init(struct tcp_sock *tp)
+{
+	struct tcp_ca_type *ca;
+
+	if (tp->ca_proto)
+		return;
+
+	ca = tcp_ca_find(sysctl_tcp_ca_protocol);
+
+	if (!ca && capable(CAP_SYS_MODULE)) {
+		request_module("tcp_%s",  sysctl_tcp_ca_protocol);
+		ca = tcp_ca_find(sysctl_tcp_ca_protocol);
+	}
+
+	if (!ca || !try_module_get(ca->owner)) {
+		if (net_ratelimit())
+			printk(KERN_WARNING "%s unavailable using TCP reno\n",
+			       sysctl_tcp_ca_protocol);
+		tp->ca_proto = &tcp_reno;
+	} else {
+		tp->ca_proto = ca;
+		ca->start(tp);
+	}
+}
+
+void tcp_ca_destroy(struct tcp_sock *tp)
+{
+	if (tp->ca_proto) {
+		module_put(tp->ca_proto->owner);
+		tp->ca_proto = NULL;
+	}
+}
+
+EXPORT_SYMBOL_GPL(tcp_ca_register);
+EXPORT_SYMBOL_GPL(tcp_ca_unregister);
diff -urNp -X dontdiff linux-2.6/net/ipv4/tcp_diag.c tcp-2.6/net/ipv4/tcp_diag.c
--- linux-2.6/net/ipv4/tcp_diag.c	2005-03-14 14:30:52.000000000 -0800
+++ tcp-2.6/net/ipv4/tcp_diag.c	2005-03-11 16:13:46.000000000 -0800
@@ -61,7 +61,6 @@ static int tcpdiag_fill(struct sk_buff *
 	struct nlmsghdr  *nlh;
 	struct tcp_info  *info = NULL;
 	struct tcpdiag_meminfo  *minfo = NULL;
-	struct tcpvegas_info *vinfo = NULL;
 	unsigned char	 *b = skb->tail;
 
 	nlh = NLMSG_PUT(skb, pid, seq, TCPDIAG_GETSOCK, sizeof(*r));
@@ -73,9 +72,6 @@ static int tcpdiag_fill(struct sk_buff *
 		if (ext & (1<<(TCPDIAG_INFO-1)))
 			info = TCPDIAG_PUT(skb, TCPDIAG_INFO, sizeof(*info));
 		
-		if ((tcp_is_westwood(tp) || tcp_is_vegas(tp))
-		    && (ext & (1<<(TCPDIAG_VEGASINFO-1))))
-			vinfo = TCPDIAG_PUT(skb, TCPDIAG_VEGASINFO, sizeof(*vinfo));
 	}
 	r->tcpdiag_family = sk->sk_family;
 	r->tcpdiag_state = sk->sk_state;
@@ -166,20 +162,6 @@ static int tcpdiag_fill(struct sk_buff *
 	if (info) 
 		tcp_get_info(sk, info);
 
-	if (vinfo) {
-		if (tcp_is_vegas(tp)) {
-			vinfo->tcpv_enabled = tp->vegas.doing_vegas_now;
-			vinfo->tcpv_rttcnt = tp->vegas.cntRTT;
-			vinfo->tcpv_rtt = jiffies_to_usecs(tp->vegas.baseRTT);
-			vinfo->tcpv_minrtt = jiffies_to_usecs(tp->vegas.minRTT);
-		} else {
-			vinfo->tcpv_enabled = 0;
-			vinfo->tcpv_rttcnt = 0;
-			vinfo->tcpv_rtt = jiffies_to_usecs(tp->westwood.rtt);
-			vinfo->tcpv_minrtt = jiffies_to_usecs(tp->westwood.rtt_min);
-		}
-	}
-
 	nlh->nlmsg_len = skb->tail - b;
 	return skb->len;
 
diff -urNp -X dontdiff linux-2.6/net/ipv4/tcp_input.c tcp-2.6/net/ipv4/tcp_input.c
--- linux-2.6/net/ipv4/tcp_input.c	2005-03-14 14:30:52.000000000 -0800
+++ tcp-2.6/net/ipv4/tcp_input.c	2005-03-11 16:13:46.000000000 -0800
@@ -61,7 +61,6 @@
  *		Panu Kuhlberg:		Experimental audit of TCP (re)transmission
  *					engine. Lots of bugs are found.
  *		Pasi Sarolahti:		F-RTO for dealing with spurious RTOs
- *		Angelo Dell'Aera:	TCP Westwood+ support
  */
 
 #include <linux/config.h>
@@ -87,23 +86,9 @@ int sysctl_tcp_rfc1337;
 int sysctl_tcp_max_orphans = NR_FILE;
 int sysctl_tcp_frto;
 int sysctl_tcp_nometrics_save;
-int sysctl_tcp_westwood;
-int sysctl_tcp_vegas_cong_avoid;
 
 int sysctl_tcp_moderate_rcvbuf = 1;
 
-/* Default values of the Vegas variables, in fixed-point representation
- * with V_PARAM_SHIFT bits to the right of the binary point.
- */
-#define V_PARAM_SHIFT 1
-int sysctl_tcp_vegas_alpha = 1<<V_PARAM_SHIFT;
-int sysctl_tcp_vegas_beta  = 3<<V_PARAM_SHIFT;
-int sysctl_tcp_vegas_gamma = 1<<V_PARAM_SHIFT;
-int sysctl_tcp_bic = 1;
-int sysctl_tcp_bic_fast_convergence = 1;
-int sysctl_tcp_bic_low_window = 14;
-int sysctl_tcp_bic_beta = 819;		/* = 819/1024 (BICTCP_BETA_SCALE) */
-
 #define FLAG_DATA		0x01 /* Incoming frame contained data.		*/
 #define FLAG_WIN_UPDATE		0x02 /* Incoming ACK was a window update.	*/
 #define FLAG_DATA_ACKED		0x04 /* This ACK acknowledged new data.		*/
@@ -332,15 +317,6 @@ static void tcp_init_buffer_space(struct
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
-static void init_bictcp(struct tcp_sock *tp)
-{
-	tp->bictcp.cnt = 0;
-
-	tp->bictcp.last_max_cwnd = 0;
-	tp->bictcp.last_cwnd = 0;
-	tp->bictcp.last_stamp = 0;
-}
-
 /* 5. Recalculate window clamp after socket hit its memory bounds. */
 static void tcp_clamp_window(struct sock *sk, struct tcp_sock *tp)
 {
@@ -557,45 +533,6 @@ static void tcp_event_data_recv(struct s
 		tcp_grow_window(sk, tp, skb);
 }
 
-/* When starting a new connection, pin down the current choice of 
- * congestion algorithm.
- */
-void tcp_ca_init(struct tcp_sock *tp)
-{
-	if (sysctl_tcp_westwood) 
-		tp->adv_cong = TCP_WESTWOOD;
-	else if (sysctl_tcp_bic)
-		tp->adv_cong = TCP_BIC;
-	else if (sysctl_tcp_vegas_cong_avoid) {
-		tp->adv_cong = TCP_VEGAS;
-		tp->vegas.baseRTT = 0x7fffffff;
-		tcp_vegas_enable(tp);
-	} 
-}
-
-/* Do RTT sampling needed for Vegas.
- * Basically we:
- *   o min-filter RTT samples from within an RTT to get the current
- *     propagation delay + queuing delay (we are min-filtering to try to
- *     avoid the effects of delayed ACKs)
- *   o min-filter RTT samples from a much longer window (forever for now)
- *     to find the propagation delay (baseRTT)
- */
-static inline void vegas_rtt_calc(struct tcp_sock *tp, __u32 rtt)
-{
-	__u32 vrtt = rtt + 1; /* Never allow zero rtt or baseRTT */
-
-	/* Filter to find propagation delay: */
-	if (vrtt < tp->vegas.baseRTT) 
-		tp->vegas.baseRTT = vrtt;
-
-	/* Find the min RTT during the last RTT to find
-	 * the current prop. delay + queuing delay:
-	 */
-	tp->vegas.minRTT = min(tp->vegas.minRTT, vrtt);
-	tp->vegas.cntRTT++;
-}
-
 /* Called to compute a smoothed rtt estimate. The data fed to this
  * routine either comes from timestamps, or from segments that were
  * known _not_ to have been retransmitted [see Karn/Partridge
@@ -609,9 +546,6 @@ static void tcp_rtt_estimator(struct tcp
 {
 	long m = mrtt; /* RTT */
 
-	if (tcp_vegas_enabled(tp))
-		vegas_rtt_calc(tp, mrtt);
-
 	/*	The following amusing code comes from Jacobson's
 	 *	article in SIGCOMM '88.  Note that rtt and mdev
 	 *	are scaled versions of rtt and mean deviation.
@@ -669,7 +603,8 @@ static void tcp_rtt_estimator(struct tcp
 		tp->rtt_seq = tp->snd_nxt;
 	}
 
-	tcp_westwood_update_rtt(tp, tp->srtt >> 3);
+	if (tp->ca_proto->rtt_sample)
+		tp->ca_proto->rtt_sample(tp, mrtt);
 }
 
 /* Calculate rto without backoff.  This is the second half of Van Jacobson's
@@ -1184,8 +1119,7 @@ void tcp_enter_frto(struct sock *sk)
             tp->snd_una == tp->high_seq ||
             (tp->ca_state == TCP_CA_Loss && !tp->retransmits)) {
 		tp->prior_ssthresh = tcp_current_ssthresh(tp);
-		if (!tcp_westwood_ssthresh(tp))
-			tp->snd_ssthresh = tcp_recalc_ssthresh(tp);
+		tcp_ca_event(tp, CA_EVENT_FRTO);
 	}
 
 	/* Have to clear retransmission markers here to keep the bookkeeping
@@ -1251,8 +1185,6 @@ static void tcp_enter_frto_loss(struct s
 	tcp_set_ca_state(tp, TCP_CA_Loss);
 	tp->high_seq = tp->frto_highmark;
 	TCP_ECN_queue_cwr(tp);
-
-	init_bictcp(tp);
 }
 
 void tcp_clear_retrans(struct tcp_sock *tp)
@@ -1282,7 +1214,7 @@ void tcp_enter_loss(struct sock *sk, int
 	if (tp->ca_state <= TCP_CA_Disorder || tp->snd_una == tp->high_seq ||
 	    (tp->ca_state == TCP_CA_Loss && !tp->retransmits)) {
 		tp->prior_ssthresh = tcp_current_ssthresh(tp);
-		tp->snd_ssthresh = tcp_recalc_ssthresh(tp);
+		tp->snd_ssthresh = tp->ca_proto->ssthresh(tp);
 	}
 	tp->snd_cwnd	   = 1;
 	tp->snd_cwnd_cnt   = 0;
@@ -1313,6 +1245,7 @@ void tcp_enter_loss(struct sock *sk, int
 
 	tp->reordering = min_t(unsigned int, tp->reordering,
 					     sysctl_tcp_reordering);
+
 	tcp_set_ca_state(tp, TCP_CA_Loss);
 	tp->high_seq = tp->snd_nxt;
 	TCP_ECN_queue_cwr(tp);
@@ -1599,24 +1532,11 @@ static inline void tcp_moderate_cwnd(str
 static void tcp_cwnd_down(struct tcp_sock *tp)
 {
 	int decr = tp->snd_cwnd_cnt + 1;
-	__u32 limit;
-
-	/*
-	 * TCP Westwood
-	 * Here limit is evaluated as BWestimation*RTTmin (for obtaining it
-	 * in packets we use mss_cache). If sysctl_tcp_westwood is off
-	 * tcp_westwood_bw_rttmin() returns 0. In such case snd_ssthresh is
-	 * still used as usual. It prevents other strange cases in which
-	 * BWE*RTTmin could assume value 0. It should not happen but...
-	 */
-
-	if (!(limit = tcp_westwood_bw_rttmin(tp)))
-		limit = tp->snd_ssthresh/2;
 
 	tp->snd_cwnd_cnt = decr&1;
 	decr >>= 1;
 
-	if (decr && tp->snd_cwnd > limit)
+	if (decr && tp->snd_cwnd > tp->ca_proto->min_cwnd(tp))
 		tp->snd_cwnd -= decr;
 
 	tp->snd_cwnd = min(tp->snd_cwnd, tcp_packets_in_flight(tp)+1);
@@ -1763,10 +1683,8 @@ static int tcp_try_undo_loss(struct sock
 
 static inline void tcp_complete_cwr(struct tcp_sock *tp)
 {
-	if (tcp_westwood_cwnd(tp)) 
-		tp->snd_ssthresh = tp->snd_cwnd;
-	else
-		tp->snd_cwnd = min(tp->snd_cwnd, tp->snd_ssthresh);
+	tcp_ca_event(tp, CA_EVENT_COMPLETE_CWR);
+	tp->snd_cwnd = min(tp->snd_cwnd, tp->snd_ssthresh);
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
@@ -1942,7 +1860,7 @@ tcp_fastretrans_alert(struct sock *sk, u
 		if (tp->ca_state < TCP_CA_CWR) {
 			if (!(flag&FLAG_ECE))
 				tp->prior_ssthresh = tcp_current_ssthresh(tp);
-			tp->snd_ssthresh = tcp_recalc_ssthresh(tp);
+			tp->snd_ssthresh = tp->ca_proto->ssthresh(tp);
 			TCP_ECN_queue_cwr(tp);
 		}
 
@@ -2015,322 +1933,13 @@ static inline void tcp_ack_update_rtt(st
 		tcp_ack_no_tstamp(tp, seq_rtt, flag);
 }
 
-/*
- * Compute congestion window to use.
- *
- * This is from the implementation of BICTCP in
- * Lison-Xu, Kahaled Harfoush, and Injog Rhee.
- *  "Binary Increase Congestion Control for Fast, Long Distance
- *  Networks" in InfoComm 2004
- * Available from:
- *  http://www.csc.ncsu.edu/faculty/rhee/export/bitcp.pdf
- *
- * Unless BIC is enabled and congestion window is large
- * this behaves the same as the original Reno.
- */
-static inline __u32 bictcp_cwnd(struct tcp_sock *tp)
-{
-	/* orignal Reno behaviour */
-	if (!tcp_is_bic(tp))
-		return tp->snd_cwnd;
-
-	if (tp->bictcp.last_cwnd == tp->snd_cwnd &&
-	   (s32)(tcp_time_stamp - tp->bictcp.last_stamp) <= (HZ>>5))
-		return tp->bictcp.cnt;
-
-	tp->bictcp.last_cwnd = tp->snd_cwnd;
-	tp->bictcp.last_stamp = tcp_time_stamp;
-      
-	/* start off normal */
-	if (tp->snd_cwnd <= sysctl_tcp_bic_low_window)
-		tp->bictcp.cnt = tp->snd_cwnd;
-
-	/* binary increase */
-	else if (tp->snd_cwnd < tp->bictcp.last_max_cwnd) {
-		__u32 	dist = (tp->bictcp.last_max_cwnd - tp->snd_cwnd)
-			/ BICTCP_B;
-
-		if (dist > BICTCP_MAX_INCREMENT)
-			/* linear increase */
-			tp->bictcp.cnt = tp->snd_cwnd / BICTCP_MAX_INCREMENT;
-		else if (dist <= 1U)
-			/* binary search increase */
-			tp->bictcp.cnt = tp->snd_cwnd * BICTCP_FUNC_OF_MIN_INCR
-				/ BICTCP_B;
-		else
-			/* binary search increase */
-			tp->bictcp.cnt = tp->snd_cwnd / dist;
-	} else {
-		/* slow start amd linear increase */
-		if (tp->snd_cwnd < tp->bictcp.last_max_cwnd + BICTCP_B)
-			/* slow start */
-			tp->bictcp.cnt = tp->snd_cwnd * BICTCP_FUNC_OF_MIN_INCR
-				/ BICTCP_B;
-		else if (tp->snd_cwnd < tp->bictcp.last_max_cwnd
-			 		+ BICTCP_MAX_INCREMENT*(BICTCP_B-1))
-			/* slow start */
-			tp->bictcp.cnt = tp->snd_cwnd * (BICTCP_B-1)
-				/ (tp->snd_cwnd-tp->bictcp.last_max_cwnd);
-		else
-			/* linear increase */
-			tp->bictcp.cnt = tp->snd_cwnd / BICTCP_MAX_INCREMENT;
-	}
-	return tp->bictcp.cnt;
-}
-
-/* This is Jacobson's slow start and congestion avoidance. 
- * SIGCOMM '88, p. 328.
- */
-static inline void reno_cong_avoid(struct tcp_sock *tp)
+static inline void tcp_cong_avoid(struct tcp_sock *tp, u32 ack, u32 seq_rtt, 
+				  u32 in_flight)
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
+	tp->ca_proto->cong_avoid(tp, ack, seq_rtt, in_flight);
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
-/* This is based on the congestion detection/avoidance scheme described in
- *    Lawrence S. Brakmo and Larry L. Peterson.
- *    "TCP Vegas: End to end congestion avoidance on a global internet."
- *    IEEE Journal on Selected Areas in Communication, 13(8):1465--1480,
- *    October 1995. Available from:
- *	ftp://ftp.cs.arizona.edu/xkernel/Papers/jsac.ps
- *
- * See http://www.cs.arizona.edu/xkernel/ for their implementation.
- * The main aspects that distinguish this implementation from the
- * Arizona Vegas implementation are:
- *   o We do not change the loss detection or recovery mechanisms of
- *     Linux in any way. Linux already recovers from losses quite well,
- *     using fine-grained timers, NewReno, and FACK.
- *   o To avoid the performance penalty imposed by increasing cwnd
- *     only every-other RTT during slow start, we increase during
- *     every RTT during slow start, just like Reno.
- *   o Largely to allow continuous cwnd growth during slow start,
- *     we use the rate at which ACKs come back as the "actual"
- *     rate, rather than the rate at which data is sent.
- *   o To speed convergence to the right rate, we set the cwnd
- *     to achieve the right ("actual") rate when we exit slow start.
- *   o To filter out the noise caused by delayed ACKs, we use the
- *     minimum RTT sample observed during the last RTT to calculate
- *     the actual rate.
- *   o When the sender re-starts from idle, it waits until it has
- *     received ACKs for an entire flight of new data before making
- *     a cwnd adjustment decision. The original Vegas implementation
- *     assumed senders never went idle.
- */
-static void vegas_cong_avoid(struct tcp_sock *tp, u32 ack, u32 seq_rtt)
-{
-	/* The key players are v_beg_snd_una and v_beg_snd_nxt.
-	 *
-	 * These are so named because they represent the approximate values
-	 * of snd_una and snd_nxt at the beginning of the current RTT. More
-	 * precisely, they represent the amount of data sent during the RTT.
-	 * At the end of the RTT, when we receive an ACK for v_beg_snd_nxt,
-	 * we will calculate that (v_beg_snd_nxt - v_beg_snd_una) outstanding
-	 * bytes of data have been ACKed during the course of the RTT, giving
-	 * an "actual" rate of:
-	 *
-	 *     (v_beg_snd_nxt - v_beg_snd_una) / (rtt duration)
-	 *
-	 * Unfortunately, v_beg_snd_una is not exactly equal to snd_una,
-	 * because delayed ACKs can cover more than one segment, so they
-	 * don't line up nicely with the boundaries of RTTs.
-	 *
-	 * Another unfortunate fact of life is that delayed ACKs delay the
-	 * advance of the left edge of our send window, so that the number
-	 * of bytes we send in an RTT is often less than our cwnd will allow.
-	 * So we keep track of our cwnd separately, in v_beg_snd_cwnd.
-	 */
-
-	if (after(ack, tp->vegas.beg_snd_nxt)) {
-		/* Do the Vegas once-per-RTT cwnd adjustment. */
-		u32 old_wnd, old_snd_cwnd;
-
-		
-		/* Here old_wnd is essentially the window of data that was
-		 * sent during the previous RTT, and has all
-		 * been acknowledged in the course of the RTT that ended
-		 * with the ACK we just received. Likewise, old_snd_cwnd
-		 * is the cwnd during the previous RTT.
-		 */
-		old_wnd = (tp->vegas.beg_snd_nxt - tp->vegas.beg_snd_una) /
-			tp->mss_cache_std;
-		old_snd_cwnd = tp->vegas.beg_snd_cwnd;
-
-		/* Save the extent of the current window so we can use this
-		 * at the end of the next RTT.
-		 */
-		tp->vegas.beg_snd_una  = tp->vegas.beg_snd_nxt;
-		tp->vegas.beg_snd_nxt  = tp->snd_nxt;
-		tp->vegas.beg_snd_cwnd = tp->snd_cwnd;
-
-		/* Take into account the current RTT sample too, to
-		 * decrease the impact of delayed acks. This double counts
-		 * this sample since we count it for the next window as well,
-		 * but that's not too awful, since we're taking the min,
-		 * rather than averaging.
-		 */
-		vegas_rtt_calc(tp, seq_rtt);
-
-		/* We do the Vegas calculations only if we got enough RTT
-		 * samples that we can be reasonably sure that we got
-		 * at least one RTT sample that wasn't from a delayed ACK.
-		 * If we only had 2 samples total,
-		 * then that means we're getting only 1 ACK per RTT, which
-		 * means they're almost certainly delayed ACKs.
-		 * If  we have 3 samples, we should be OK.
-		 */
-
-		if (tp->vegas.cntRTT <= 2) {
-			/* We don't have enough RTT samples to do the Vegas
-			 * calculation, so we'll behave like Reno.
-			 */
-			if (tp->snd_cwnd > tp->snd_ssthresh)
-				tp->snd_cwnd++;
-		} else {
-			u32 rtt, target_cwnd, diff;
-
-			/* We have enough RTT samples, so, using the Vegas
-			 * algorithm, we determine if we should increase or
-			 * decrease cwnd, and by how much.
-			 */
-
-			/* Pluck out the RTT we are using for the Vegas
-			 * calculations. This is the min RTT seen during the
-			 * last RTT. Taking the min filters out the effects
-			 * of delayed ACKs, at the cost of noticing congestion
-			 * a bit later.
-			 */
-			rtt = tp->vegas.minRTT;
-
-			/* Calculate the cwnd we should have, if we weren't
-			 * going too fast.
-			 *
-			 * This is:
-			 *     (actual rate in segments) * baseRTT
-			 * We keep it as a fixed point number with
-			 * V_PARAM_SHIFT bits to the right of the binary point.
-			 */
-			target_cwnd = ((old_wnd * tp->vegas.baseRTT)
-				       << V_PARAM_SHIFT) / rtt;
-
-			/* Calculate the difference between the window we had,
-			 * and the window we would like to have. This quantity
-			 * is the "Diff" from the Arizona Vegas papers.
-			 *
-			 * Again, this is a fixed point number with
-			 * V_PARAM_SHIFT bits to the right of the binary
-			 * point.
-			 */
-			diff = (old_wnd << V_PARAM_SHIFT) - target_cwnd;
-
-			if (tp->snd_cwnd < tp->snd_ssthresh) {
-				/* Slow start.  */
-				if (diff > sysctl_tcp_vegas_gamma) {
-					/* Going too fast. Time to slow down
-					 * and switch to congestion avoidance.
-					 */
-					tp->snd_ssthresh = 2;
-
-					/* Set cwnd to match the actual rate
-					 * exactly:
-					 *   cwnd = (actual rate) * baseRTT
-					 * Then we add 1 because the integer
-					 * truncation robs us of full link
-					 * utilization.
-					 */
-					tp->snd_cwnd = min(tp->snd_cwnd,
-							   (target_cwnd >>
-							    V_PARAM_SHIFT)+1);
-
-				}
-			} else {
-				/* Congestion avoidance. */
-				u32 next_snd_cwnd;
-
-				/* Figure out where we would like cwnd
-				 * to be.
-				 */
-				if (diff > sysctl_tcp_vegas_beta) {
-					/* The old window was too fast, so
-					 * we slow down.
-					 */
-					next_snd_cwnd = old_snd_cwnd - 1;
-				} else if (diff < sysctl_tcp_vegas_alpha) {
-					/* We don't have enough extra packets
-					 * in the network, so speed up.
-					 */
-					next_snd_cwnd = old_snd_cwnd + 1;
-				} else {
-					/* Sending just as fast as we
-					 * should be.
-					 */
-					next_snd_cwnd = old_snd_cwnd;
-				}
-
-				/* Adjust cwnd upward or downward, toward the
-				 * desired value.
-				 */
-				if (next_snd_cwnd > tp->snd_cwnd)
-					tp->snd_cwnd++;
-				else if (next_snd_cwnd < tp->snd_cwnd)
-					tp->snd_cwnd--;
-			}
-		}
-
-		/* Wipe the slate clean for the next RTT. */
-		tp->vegas.cntRTT = 0;
-		tp->vegas.minRTT = 0x7fffffff;
-	}
-
-	/* The following code is executed for every ack we receive,
-	 * except for conditions checked in should_advance_cwnd()
-	 * before the call to tcp_cong_avoid(). Mainly this means that
-	 * we only execute this code if the ack actually acked some
-	 * data.
-	 */
-
-	/* If we are in slow start, increase our cwnd in response to this ACK.
-	 * (If we are not in slow start then we are in congestion avoidance,
-	 * and adjust our congestion window only once per RTT. See the code
-	 * above.)
-	 */
-	if (tp->snd_cwnd <= tp->snd_ssthresh) 
-		tp->snd_cwnd++;
-
-	/* to keep cwnd from growing without bound */
-	tp->snd_cwnd = min_t(u32, tp->snd_cwnd, tp->snd_cwnd_clamp);
-
-	/* Make sure that we are never so timid as to reduce our cwnd below
-	 * 2 MSS.
-	 *
-	 * Going below 2 MSS would risk huge delayed ACKs from our receiver.
-	 */
-	tp->snd_cwnd = max(tp->snd_cwnd, 2U);
-
-	tp->snd_cwnd_stamp = tcp_time_stamp;
-}
-
-static inline void tcp_cong_avoid(struct tcp_sock *tp, u32 ack, u32 seq_rtt)
-{
-	if (tcp_vegas_enabled(tp))
-		vegas_cong_avoid(tp, ack, seq_rtt);
-	else
-		reno_cong_avoid(tp);
-}
-
 /* Restart timer after forward progress on connection.
  * RFC2988 recommends to restart timer to now+rto.
  */
@@ -2620,256 +2229,6 @@ static void tcp_process_frto(struct sock
 	tp->frto_counter = (tp->frto_counter + 1) % 3;
 }
 
-/*
- * TCP Westwood+
- */
-
-/*
- * @init_westwood
- * This function initializes fields used in TCP Westwood+. We can't
- * get no information about RTTmin at this time so we simply set it to
- * TCP_WESTWOOD_INIT_RTT. This value was chosen to be too conservative
- * since in this way we're sure it will be updated in a consistent
- * way as soon as possible. It will reasonably happen within the first
- * RTT period of the connection lifetime.
- */
-
-static void init_westwood(struct sock *sk)
-{
-        struct tcp_sock *tp = tcp_sk(sk);
-
-        tp->westwood.bw_ns_est = 0;
-        tp->westwood.bw_est = 0;
-        tp->westwood.accounted = 0;
-        tp->westwood.cumul_ack = 0;
-        tp->westwood.rtt_win_sx = tcp_time_stamp;
-        tp->westwood.rtt = TCP_WESTWOOD_INIT_RTT;
-        tp->westwood.rtt_min = TCP_WESTWOOD_INIT_RTT;
-        tp->westwood.snd_una = tp->snd_una;
-}
-
-/*
- * @westwood_do_filter
- * Low-pass filter. Implemented using constant coeffients.
- */
-
-static inline __u32 westwood_do_filter(__u32 a, __u32 b)
-{
-	return (((7 * a) + b) >> 3);
-}
-
-static void westwood_filter(struct sock *sk, __u32 delta)
-{
-	struct tcp_sock *tp = tcp_sk(sk);
-
-	tp->westwood.bw_ns_est =
-		westwood_do_filter(tp->westwood.bw_ns_est, 
-				   tp->westwood.bk / delta);
-	tp->westwood.bw_est =
-		westwood_do_filter(tp->westwood.bw_est,
-				   tp->westwood.bw_ns_est);
-}
-
-/* 
- * @westwood_update_rttmin
- * It is used to update RTTmin. In this case we MUST NOT use
- * WESTWOOD_RTT_MIN minimum bound since we could be on a LAN!
- */
-
-static inline __u32 westwood_update_rttmin(const struct sock *sk)
-{
-	const struct tcp_sock *tp = tcp_sk(sk);
-	__u32 rttmin = tp->westwood.rtt_min;
-
-	if (tp->westwood.rtt != 0 &&
-	    (tp->westwood.rtt < tp->westwood.rtt_min || !rttmin))
-		rttmin = tp->westwood.rtt;
-
-	return rttmin;
-}
-
-/*
- * @westwood_acked
- * Evaluate increases for dk. 
- */
-
-static inline __u32 westwood_acked(const struct sock *sk)
-{
-	const struct tcp_sock *tp = tcp_sk(sk);
-
-	return tp->snd_una - tp->westwood.snd_una;
-}
-
-/*
- * @westwood_new_window
- * It evaluates if we are receiving data inside the same RTT window as
- * when we started.
- * Return value:
- * It returns 0 if we are still evaluating samples in the same RTT
- * window, 1 if the sample has to be considered in the next window.
- */
-
-static int westwood_new_window(const struct sock *sk)
-{
-	const struct tcp_sock *tp = tcp_sk(sk);
-	__u32 left_bound;
-	__u32 rtt;
-	int ret = 0;
-
-	left_bound = tp->westwood.rtt_win_sx;
-	rtt = max(tp->westwood.rtt, (u32) TCP_WESTWOOD_RTT_MIN);
-
-	/*
-	 * A RTT-window has passed. Be careful since if RTT is less than
-	 * 50ms we don't filter but we continue 'building the sample'.
-	 * This minimum limit was choosen since an estimation on small
-	 * time intervals is better to avoid...
-	 * Obvioulsy on a LAN we reasonably will always have
-	 * right_bound = left_bound + WESTWOOD_RTT_MIN
-         */
-
-	if ((left_bound + rtt) < tcp_time_stamp)
-		ret = 1;
-
-	return ret;
-}
-
-/*
- * @westwood_update_window
- * It updates RTT evaluation window if it is the right moment to do
- * it. If so it calls filter for evaluating bandwidth. 
- */
-
-static void __westwood_update_window(struct sock *sk, __u32 now)
-{
-	struct tcp_sock *tp = tcp_sk(sk);
-	__u32 delta = now - tp->westwood.rtt_win_sx;
-
-        if (delta) {
-		if (tp->westwood.rtt)
-			westwood_filter(sk, delta);
-
-		tp->westwood.bk = 0;
-		tp->westwood.rtt_win_sx = tcp_time_stamp;
-	}
-}
-
-
-static void westwood_update_window(struct sock *sk, __u32 now)
-{
-	if (westwood_new_window(sk)) 
-		__westwood_update_window(sk, now);
-}
-
-/*
- * @__tcp_westwood_fast_bw
- * It is called when we are in fast path. In particular it is called when
- * header prediction is successfull. In such case infact update is
- * straight forward and doesn't need any particular care.
- */
-
-static void __tcp_westwood_fast_bw(struct sock *sk, struct sk_buff *skb)
-{
-	struct tcp_sock *tp = tcp_sk(sk);
-
-	westwood_update_window(sk, tcp_time_stamp);
-
-	tp->westwood.bk += westwood_acked(sk);
-	tp->westwood.snd_una = tp->snd_una;
-	tp->westwood.rtt_min = westwood_update_rttmin(sk);
-}
-
-static inline void tcp_westwood_fast_bw(struct sock *sk, struct sk_buff *skb)
-{
-        if (tcp_is_westwood(tcp_sk(sk)))
-                __tcp_westwood_fast_bw(sk, skb);
-}
-
-
-/*
- * @westwood_dupack_update
- * It updates accounted and cumul_ack when receiving a dupack.
- */
-
-static void westwood_dupack_update(struct sock *sk)
-{
-	struct tcp_sock *tp = tcp_sk(sk);
-
-	tp->westwood.accounted += tp->mss_cache_std;
-	tp->westwood.cumul_ack = tp->mss_cache_std;
-}
-
-static inline int westwood_may_change_cumul(struct tcp_sock *tp)
-{
-	return (tp->westwood.cumul_ack > tp->mss_cache_std);
-}
-
-static inline void westwood_partial_update(struct tcp_sock *tp)
-{
-	tp->westwood.accounted -= tp->westwood.cumul_ack;
-	tp->westwood.cumul_ack = tp->mss_cache_std;
-}
-
-static inline void westwood_complete_update(struct tcp_sock *tp)
-{
-	tp->westwood.cumul_ack -= tp->westwood.accounted;
-	tp->westwood.accounted = 0;
-}
-
-/*
- * @westwood_acked_count
- * This function evaluates cumul_ack for evaluating dk in case of
- * delayed or partial acks.
- */
-
-static inline __u32 westwood_acked_count(struct sock *sk)
-{
-	struct tcp_sock *tp = tcp_sk(sk);
-
-	tp->westwood.cumul_ack = westwood_acked(sk);
-
-        /* If cumul_ack is 0 this is a dupack since it's not moving
-         * tp->snd_una.
-         */
-        if (!(tp->westwood.cumul_ack))
-                westwood_dupack_update(sk);
-
-        if (westwood_may_change_cumul(tp)) {
-		/* Partial or delayed ack */
-		if (tp->westwood.accounted >= tp->westwood.cumul_ack)
-			westwood_partial_update(tp);
-		else
-			westwood_complete_update(tp);
-	}
-
-	tp->westwood.snd_una = tp->snd_una;
-
-	return tp->westwood.cumul_ack;
-}
-
-
-/*
- * @__tcp_westwood_slow_bw
- * It is called when something is going wrong..even if there could
- * be no problems! Infact a simple delayed packet may trigger a
- * dupack. But we need to be careful in such case.
- */
-
-static void __tcp_westwood_slow_bw(struct sock *sk, struct sk_buff *skb)
-{
-	struct tcp_sock *tp = tcp_sk(sk);
-
-	westwood_update_window(sk, tcp_time_stamp);
-
-	tp->westwood.bk += westwood_acked_count(sk);
-	tp->westwood.rtt_min = westwood_update_rttmin(sk);
-}
-
-static inline void tcp_westwood_slow_bw(struct sock *sk, struct sk_buff *skb)
-{
-        if (tcp_is_westwood(tcp_sk(sk)))
-                __tcp_westwood_slow_bw(sk, skb);
-}
 
 /* This routine deals with incoming acks, but not outgoing ones. */
 static int tcp_ack(struct sock *sk, struct sk_buff *skb, int flag)
@@ -2898,9 +2257,10 @@ static int tcp_ack(struct sock *sk, stru
 		 */
 		tcp_update_wl(tp, ack, ack_seq);
 		tp->snd_una = ack;
-		tcp_westwood_fast_bw(sk, skb);
 		flag |= FLAG_WIN_UPDATE;
 
+		tcp_ca_event(tp, CA_EVENT_FAST_ACK);
+
 		NET_INC_STATS_BH(LINUX_MIB_TCPHPACKS);
 	} else {
 		if (ack_seq != TCP_SKB_CB(skb)->end_seq)
@@ -2916,7 +2276,7 @@ static int tcp_ack(struct sock *sk, stru
 		if (TCP_ECN_rcv_ecn_echo(tp, skb->h.th))
 			flag |= FLAG_ECE;
 
-		tcp_westwood_slow_bw(sk,skb);
+		tcp_ca_event(tp, CA_EVENT_SLOW_ACK);
 	}
 
 	/* We passed data and got it acked, remove any soft error
@@ -2937,16 +2297,13 @@ static int tcp_ack(struct sock *sk, stru
 		tcp_process_frto(sk, prior_snd_una);
 
 	if (tcp_ack_is_dubious(tp, flag)) {
-		/* Advanve CWND, if state allows this. */
-		if ((flag & FLAG_DATA_ACKED) &&
-		    (tcp_vegas_enabled(tp) || prior_in_flight >= tp->snd_cwnd) &&
-		    tcp_may_raise_cwnd(tp, flag))
-			tcp_cong_avoid(tp, ack, seq_rtt);
+		/* Advance CWND, if state allows this. */
+		if ((flag & FLAG_DATA_ACKED) && tcp_may_raise_cwnd(tp, flag))
+			tcp_cong_avoid(tp, ack, seq_rtt, prior_in_flight);
 		tcp_fastretrans_alert(sk, prior_snd_una, prior_packets, flag);
 	} else {
-		if ((flag & FLAG_DATA_ACKED) && 
-		    (tcp_vegas_enabled(tp) || prior_in_flight >= tp->snd_cwnd))
-			tcp_cong_avoid(tp, ack, seq_rtt);
+		if ((flag & FLAG_DATA_ACKED))
+			tcp_cong_avoid(tp, ack, seq_rtt, prior_in_flight);
 	}
 
 	if ((flag & FLAG_FORWARD_PROGRESS) || !(flag&FLAG_NOT_DUP))
@@ -4713,8 +4070,7 @@ int tcp_rcv_state_process(struct sock *s
 			if(tp->af_specific->conn_request(sk, skb) < 0)
 				return 1;
 
-			init_westwood(sk);
-			init_bictcp(tp);
+			tcp_ca_init(tp);
 
 			/* Now we have several options: In theory there is 
 			 * nothing else in the frame. KA9Q has an option to 
@@ -4737,8 +4093,7 @@ int tcp_rcv_state_process(struct sock *s
 		goto discard;
 
 	case TCP_SYN_SENT:
-		init_westwood(sk);
-		init_bictcp(tp);
+		tcp_ca_init(tp);
 
 		queued = tcp_rcv_synsent_state_process(sk, skb, th, len);
 		if (queued >= 0)
diff -urNp -X dontdiff linux-2.6/net/ipv4/tcp_ipv4.c tcp-2.6/net/ipv4/tcp_ipv4.c
--- linux-2.6/net/ipv4/tcp_ipv4.c	2005-03-14 12:03:58.000000000 -0800
+++ tcp-2.6/net/ipv4/tcp_ipv4.c	2005-03-14 12:04:25.000000000 -0800
@@ -2058,7 +2058,6 @@ static int tcp_v4_init_sock(struct sock 
 	tp->snd_ssthresh = 0x7fffffff;	/* Infinity */
 	tp->snd_cwnd_clamp = ~0;
 	tp->mss_cache_std = tp->mss_cache = 536;
-
 	tp->reordering = sysctl_tcp_reordering;
 
 	sk->sk_state = TCP_CLOSE;
@@ -2082,6 +2081,8 @@ int tcp_v4_destroy_sock(struct sock *sk)
 
 	tcp_clear_xmit_timers(sk);
 
+	tcp_ca_destroy(tp);
+
 	/* Cleanup up the write buffer. */
   	sk_stream_writequeue_purge(sk);
 
diff -urNp -X dontdiff linux-2.6/net/ipv4/tcp_output.c tcp-2.6/net/ipv4/tcp_output.c
--- linux-2.6/net/ipv4/tcp_output.c	2005-03-14 14:30:52.000000000 -0800
+++ tcp-2.6/net/ipv4/tcp_output.c	2005-03-11 16:13:46.000000000 -0800
@@ -111,8 +111,7 @@ static void tcp_cwnd_restart(struct tcp_
 	u32 restart_cwnd = tcp_init_cwnd(tp, dst);
 	u32 cwnd = tp->snd_cwnd;
 
-	if (tcp_is_vegas(tp)) 
-		tcp_vegas_enable(tp);
+	tcp_ca_event(tp, CA_EVENT_CWND_RESTART);
 
 	tp->snd_ssthresh = tcp_current_ssthresh(tp);
 	restart_cwnd = min(restart_cwnd, cwnd);
@@ -304,18 +303,6 @@ static int tcp_transmit_skb(struct sock 
 					    (tp->rx_opt.eff_sacks * TCPOLEN_SACK_PERBLOCK));
 		}
 		
-		/*
-		 * If the connection is idle and we are restarting,
-		 * then we don't want to do any Vegas calculations
-		 * until we get fresh RTT samples.  So when we
-		 * restart, we reset our Vegas state to a clean
-		 * slate. After we get acks for this flight of
-		 * packets, _then_ we can make Vegas calculations
-		 * again.
-		 */
-		if (tcp_is_vegas(tp) && tcp_packets_in_flight(tp) == 0)
-			tcp_vegas_enable(tp);
-
 		th = (struct tcphdr *) skb_push(skb, tcp_header_size);
 		skb->h.th = th;
 		skb_set_owner_w(skb, sk);
diff -urNp -X dontdiff linux-2.6/net/ipv4/tcp_reno.c tcp-2.6/net/ipv4/tcp_reno.c
--- linux-2.6/net/ipv4/tcp_reno.c	1969-12-31 16:00:00.000000000 -0800
+++ tcp-2.6/net/ipv4/tcp_reno.c	2005-03-14 12:02:02.000000000 -0800
@@ -0,0 +1,63 @@
+/*
+ * TCP Reno congestion control
+ *
+ * This is special case used for fallback as well.
+ */
+
+#include <linux/config.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <net/tcp.h>
+
+/* This is Jacobson's slow start and congestion avoidance. 
+ * SIGCOMM '88, p. 328.
+ */
+u32 tcp_reno_ssthresh(struct tcp_sock *tp)
+{
+	return max(tp->snd_cwnd >> 1U, 2U);
+}
+EXPORT_SYMBOL_GPL(tcp_reno_ssthresh);
+
+void tcp_reno_cong_avoid(struct tcp_sock *tp, u32 ack, u32 rtt, u32 in_flight)
+{
+	if (in_flight < tp->snd_cwnd)
+		return;
+
+        if (tp->snd_cwnd <= tp->snd_ssthresh) {
+                /* In "safe" area, increase. */
+		if (tp->snd_cwnd < tp->snd_cwnd_clamp)
+			tp->snd_cwnd++;
+	} else {
+                /* In dangerous area, increase slowly.
+		 * In theory this is tp->snd_cwnd += 1 / tp->snd_cwnd
+		 */
+		if (tp->snd_cwnd_cnt >= tp->snd_cwnd) {
+			if (tp->snd_cwnd < tp->snd_cwnd_clamp)
+				tp->snd_cwnd++;
+			tp->snd_cwnd_cnt = 0;
+		} else
+			tp->snd_cwnd_cnt++;
+	}
+}
+EXPORT_SYMBOL_GPL(tcp_reno_cong_avoid);
+
+u32 tcp_reno_cwnd_min(struct tcp_sock *tp)
+{
+	return tp->snd_ssthresh/2;
+}
+EXPORT_SYMBOL_GPL(tcp_reno_cwnd_min);
+
+static void tcp_reno_start(struct tcp_sock *tp)
+{
+	return;
+}
+
+struct tcp_ca_type tcp_reno = {
+	.start		= tcp_reno_start,
+	.ssthresh	= tcp_reno_ssthresh,
+	.min_cwnd	= tcp_reno_cwnd_min,
+	.cong_avoid	= tcp_reno_cong_avoid,
+
+	.owner		= THIS_MODULE,
+	.name		= "reno",
+};
diff -urNp -X dontdiff linux-2.6/net/ipv4/tcp_vegas.c tcp-2.6/net/ipv4/tcp_vegas.c
--- linux-2.6/net/ipv4/tcp_vegas.c	1969-12-31 16:00:00.000000000 -0800
+++ tcp-2.6/net/ipv4/tcp_vegas.c	2005-03-14 11:46:52.000000000 -0800
@@ -0,0 +1,381 @@
+/*
+ * TCP Vegas congestion control
+ *
+ * This is based on the congestion detection/avoidance scheme described in
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
+
+#include <linux/config.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <net/tcp.h>
+
+/* Default values of the Vegas variables, in fixed-point representation
+ * with V_PARAM_SHIFT bits to the right of the binary point.
+ */
+#define V_PARAM_SHIFT 1
+static int alpha = 1<<V_PARAM_SHIFT;
+static int beta  = 3<<V_PARAM_SHIFT;
+static int gamma = 1<<V_PARAM_SHIFT;
+
+module_param(alpha, int, 0644);
+MODULE_PARM_DESC(alpha, "lower bound of packets in network (scale by 2)");
+module_param(beta, int, 0644);
+MODULE_PARM_DESC(beta, "upper bound of packets in network (scale by 2)");
+module_param(gamma, int, 0644);
+MODULE_PARM_DESC(gamma, "limit on increase (scale by 2)");
+
+
+/* Vegas variables */
+struct tcp_vegas_info {
+	u32	beg_snd_nxt;	/* right edge during last RTT */
+	u32	beg_snd_una;	/* left edge  during last RTT */
+	u32	beg_snd_cwnd;	/* saves the size of the cwnd */
+	u8	doing_vegas_now;/* if true, do vegas for this RTT */
+	u16	cntRTT;		/* # of RTTs measured within last RTT */
+	u32	minRTT;		/* min of RTTs measured within last RTT (in usec) */
+	u32	baseRTT;	/* the min of all Vegas RTT measurements seen (in usec) */
+};
+
+/* There are several situations when we must "re-start" Vegas:
+ *
+ *  o when a connection is established
+ *  o after an RTO
+ *  o after fast recovery
+ *  o when we send a packet and there is no outstanding
+ *    unacknowledged data (restarting an idle connection)
+ *
+ * In these circumstances we cannot do a Vegas calculation at the
+ * end of the first RTT, because any calculation we do is using
+ * stale info -- both the saved cwnd and congestion feedback are
+ * stale.
+ *
+ * Instead we must wait until the completion of an RTT during
+ * which we actually receive ACKs.
+ */
+static void tcp_vegas_enable(struct tcp_sock *tp)
+{
+	struct tcp_vegas_info *vegas = tcp_ca(tp);
+
+	/* Begin taking Vegas samples next time we send something. */
+	vegas->doing_vegas_now = 1;
+     
+	/* Set the beginning of the next send window. */
+	vegas->beg_snd_nxt = tp->snd_nxt;
+
+	vegas->cntRTT = 0;
+	vegas->minRTT = 0x7fffffff;
+}
+
+/* Stop taking Vegas samples for now. */
+static inline void tcp_vegas_disable(struct tcp_sock *tp)
+{
+	struct tcp_vegas_info *vegas = tcp_ca(tp);
+
+	vegas->doing_vegas_now = 0;
+}
+    
+static void tcp_vegas_start(struct tcp_sock *tp)
+{
+	struct tcp_vegas_info *vegas = tcp_ca(tp);
+	
+	vegas->baseRTT = 0x7fffffff;
+	tcp_vegas_enable(tp);
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
+static void tcp_vegas_rtt_calc(struct tcp_sock *tp, u32 rtt)
+{
+	struct tcp_vegas_info *vegas = tcp_ca(tp);
+	u32 vrtt = rtt + 1; /* Never allow zero rtt or baseRTT */
+
+	/* Filter to find propagation delay: */
+	if (vrtt < vegas->baseRTT) 
+		vegas->baseRTT = vrtt;
+
+	/* Find the min RTT during the last RTT to find
+	 * the current prop. delay + queuing delay:
+	 */
+	vegas->minRTT = min(vegas->minRTT, vrtt);
+	vegas->cntRTT++;
+}
+
+static void tcp_vegas_ca_state(struct tcp_sock *tp, u8 ca_state)
+{
+	if (ca_state == TCP_CA_Open) 
+		tcp_vegas_enable(tp);
+	else
+		tcp_vegas_disable(tp);
+}
+
+static void tcp_vegas_cwnd_event(struct tcp_sock *tp, enum tcp_ca_event event)
+{
+	if(event == CA_EVENT_CWND_RESTART) 
+		tcp_vegas_enable(tp);
+}
+
+static void tcp_vegas_cong_avoid(struct tcp_sock *tp, u32 ack, 
+				 u32 seq_rtt, u32 in_flight)
+{
+	struct tcp_vegas_info *vegas = tcp_ca(tp);
+
+	if (!vegas->doing_vegas_now) {
+		tcp_reno_cong_avoid(tp, ack, seq_rtt, in_flight);
+		return;
+	}
+
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
+	if (after(ack, vegas->beg_snd_nxt)) {
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
+		old_wnd = (vegas->beg_snd_nxt - vegas->beg_snd_una) /
+			tp->mss_cache_std;
+		old_snd_cwnd = vegas->beg_snd_cwnd;
+
+		/* Save the extent of the current window so we can use this
+		 * at the end of the next RTT.
+		 */
+		vegas->beg_snd_una  = vegas->beg_snd_nxt;
+		vegas->beg_snd_nxt  = tp->snd_nxt;
+		vegas->beg_snd_cwnd = tp->snd_cwnd;
+
+		/* Take into account the current RTT sample too, to
+		 * decrease the impact of delayed acks. This double counts
+		 * this sample since we count it for the next window as well,
+		 * but that's not too awful, since we're taking the min,
+		 * rather than averaging.
+		 */
+		tcp_vegas_rtt_calc(tp, seq_rtt);
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
+		if (vegas->cntRTT <= 2) {
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
+			rtt = vegas->minRTT;
+
+			/* Calculate the cwnd we should have, if we weren't
+			 * going too fast.
+			 *
+			 * This is:
+			 *     (actual rate in segments) * baseRTT
+			 * We keep it as a fixed point number with
+			 * V_PARAM_SHIFT bits to the right of the binary point.
+			 */
+			target_cwnd = ((old_wnd * vegas->baseRTT)
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
+				if (diff > gamma) {
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
+				if (diff > beta) {
+					/* The old window was too fast, so
+					 * we slow down.
+					 */
+					next_snd_cwnd = old_snd_cwnd - 1;
+				} else if (diff < alpha) {
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
+		vegas->cntRTT = 0;
+		vegas->minRTT = 0x7fffffff;
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
+}
+
+static struct tcp_ca_type tcp_vegas = {
+	.start		= tcp_vegas_start,
+	.ssthresh	= tcp_reno_ssthresh,
+	.min_cwnd	= tcp_reno_cwnd_min,
+	.cong_avoid	= tcp_vegas_cong_avoid,
+	.rtt_sample	= tcp_vegas_rtt_calc,
+	.set_state	= tcp_vegas_ca_state,
+	.cwnd_event	= tcp_vegas_cwnd_event,
+
+	.owner		= THIS_MODULE,
+	.name		= "vegas",
+};
+
+static int __init tcp_vegas_init(void)
+{
+	BUILD_BUG_ON(sizeof(struct tcp_vegas_info) > TCP_CA_PRIV_SIZE);
+	tcp_ca_register(&tcp_vegas);
+	return 0;
+}
+
+static void __exit tcp_vegas_exit(void)
+{
+	tcp_ca_unregister(&tcp_vegas);
+}
+
+module_init(tcp_vegas_init);
+module_exit(tcp_vegas_exit);
+
+MODULE_AUTHOR("Stephen Hemminger");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("TCP Vegas");
+
+
diff -urNp -X dontdiff linux-2.6/net/ipv4/tcp_westwood.c tcp-2.6/net/ipv4/tcp_westwood.c
--- linux-2.6/net/ipv4/tcp_westwood.c	1969-12-31 16:00:00.000000000 -0800
+++ tcp-2.6/net/ipv4/tcp_westwood.c	2005-03-14 11:48:01.000000000 -0800
@@ -0,0 +1,326 @@
+/*
+ * TCP Westwood+
+ *
+ *	Angelo Dell'Aera:	TCP Westwood+ support
+ */
+
+#include <linux/config.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <net/tcp.h>
+
+/* TCP Westwood structure */
+struct tcp_westwood_info {
+	u32    bw_ns_est;        /* first bandwidth estimation..not too smoothed 8) */
+	u32    bw_est;           /* bandwidth estimate */
+	u32    rtt_win_sx;       /* here starts a new evaluation... */
+	u32    bk;
+	u32    snd_una;          /* used for evaluating the number of acked bytes */
+	u32    cumul_ack;
+	u32    accounted;
+	u32    rtt;
+	u32    rtt_min;          /* minimum observed RTT */
+};
+
+
+/* TCP Westwood functions and constants */
+#define TCP_WESTWOOD_INIT_RTT  (20*HZ)           /* maybe too conservative?! */
+#define TCP_WESTWOOD_RTT_MIN   (HZ/20)           /* 50ms */
+
+/*
+ * @tcp_westwood_create
+ * This function initializes fields used in TCP Westwood+. We can't
+ * get no information about RTTmin at this time so we simply set it to
+ * TCP_WESTWOOD_INIT_RTT. This value was chosen to be too conservative
+ * since in this way we're sure it will be updated in a consistent
+ * way as soon as possible. It will reasonably happen within the first
+ * RTT period of the connection lifetime.
+ */
+static void tcp_westwood_start(struct tcp_sock *tp)
+{
+	struct tcp_westwood_info *w = tcp_ca(tp);
+
+        w->bw_ns_est = 0;
+        w->bw_est = 0;
+        w->accounted = 0;
+        w->cumul_ack = 0;
+        w->rtt_win_sx = tcp_time_stamp;
+        w->rtt = TCP_WESTWOOD_INIT_RTT;
+        w->rtt_min = TCP_WESTWOOD_INIT_RTT;
+        w->snd_una = tp->snd_una;
+}
+
+/*
+ * @westwood_do_filter
+ * Low-pass filter. Implemented using constant coefficents.
+ */
+static inline u32 westwood_do_filter(u32 a, u32 b)
+{
+	return (((7 * a) + b) >> 3);
+}
+
+static inline void westwood_filter(struct tcp_westwood_info *w, u32 delta)
+{
+	w->bw_ns_est = westwood_do_filter(w->bw_ns_est, w->bk / delta);
+	w->bw_est = westwood_do_filter(w->bw_est, w->bw_ns_est);
+}
+
+/* 
+ * @westwood_update_rttmin
+ * It is used to update RTTmin. In this case we MUST NOT use
+ * WESTWOOD_RTT_MIN minimum bound since we could be on a LAN!
+ */
+static inline u32 westwood_update_rttmin(const struct tcp_westwood_info *w)
+{
+	u32 rttmin = w->rtt_min;
+
+	if (w->rtt != 0 &&
+	    (w->rtt < w->rtt_min || !rttmin))
+		rttmin = w->rtt;
+
+	return rttmin;
+}
+
+static void tcp_westwood_sample_rtt(struct tcp_sock *tp, u32 rtt)
+{
+	struct tcp_westwood_info *w = tcp_ca(tp);
+	w->rtt = tp->srtt >> 3;
+}
+
+/*
+ * @westwood_acked
+ * Evaluate increases for dk. 
+ */
+static inline u32 westwood_acked(struct tcp_sock *tp)
+{
+	struct tcp_westwood_info *w = tcp_ca(tp);
+	return tp->snd_una - w->snd_una;
+}
+
+/*
+ * @westwood_new_window
+ * It evaluates if we are receiving data inside the same RTT window as
+ * when we started.
+ * Return value:
+ * It returns 0 if we are still evaluating samples in the same RTT
+ * window, 1 if the sample has to be considered in the next window.
+ */
+static inline int westwood_new_window(const struct tcp_sock *tp)
+{
+	struct tcp_westwood_info *w = tcp_ca(tp);
+	u32 left_bound;
+	u32 rtt;
+	int ret = 0;
+
+	left_bound = w->rtt_win_sx;
+	rtt = max(w->rtt, (u32) TCP_WESTWOOD_RTT_MIN);
+
+	/*
+	 * A RTT-window has passed. Be careful since if RTT is less than
+	 * 50ms we don't filter but we continue 'building the sample'.
+	 * This minimum limit was choosen since an estimation on small
+	 * time intervals is better to avoid...
+	 * Obvioulsy on a LAN we reasonably will always have
+	 * right_bound = left_bound + WESTWOOD_RTT_MIN
+         */
+
+	if ((left_bound + rtt) < tcp_time_stamp)
+		ret = 1;
+
+	return ret;
+}
+
+/*
+ * @westwood_update_window
+ * It updates RTT evaluation window if it is the right moment to do
+ * it. If so it calls filter for evaluating bandwidth. 
+ */
+static void westwood_update_window(struct tcp_sock *tp, u32 now)
+{
+	struct tcp_westwood_info *w = tcp_ca(tp);
+	if (westwood_new_window(tp)) {
+		u32 delta = now - w->rtt_win_sx;
+		
+		if (delta) {
+			if (w->rtt)
+				westwood_filter(w, delta);
+			
+			w->bk = 0;
+			w->rtt_win_sx = tcp_time_stamp;
+		}
+	}
+}
+
+/*
+ * @tcp_westwood_fast_bw
+ * It is called when we are in fast path. In particular it is called when
+ * header prediction is successfull. In such case infact update is
+ * straight forward and doesn't need any particular care.
+ */
+static void tcp_westwood_fast_bw(struct tcp_sock *tp)
+{
+	struct tcp_westwood_info *w = tcp_ca(tp);
+	westwood_update_window(tp, tcp_time_stamp);
+
+	w->bk += westwood_acked(tp);
+	w->snd_una = tp->snd_una;
+	w->rtt_min = westwood_update_rttmin(w);
+}
+
+/*
+ * @westwood_acked_count
+ * This function evaluates cumul_ack for evaluating dk in case of
+ * delayed or partial acks.
+ */
+static u32 westwood_acked_count(struct tcp_sock *tp)
+{
+	struct tcp_westwood_info *w = tcp_ca(tp);
+
+	w->cumul_ack = westwood_acked(tp);
+
+        /* If cumul_ack is 0 this is a dupack since it's not moving
+         * tp->snd_una.
+         */
+        if (!w->cumul_ack) {
+		w->accounted += tp->mss_cache_std;
+		w->cumul_ack = tp->mss_cache_std;
+	}
+
+        if (w->cumul_ack > tp->mss_cache_std) {
+		/* Partial or delayed ack */
+		if (w->accounted >= w->cumul_ack) {
+			w->accounted -= w->cumul_ack;
+			w->cumul_ack = tp->mss_cache_std;
+		} else {
+			w->cumul_ack -= w->accounted;
+			w->accounted = 0;
+		}
+	}
+
+	w->snd_una = tp->snd_una;
+
+	return w->cumul_ack;
+}
+
+
+/*
+ * @tcp_westwood_slow_bw
+ * It is called when something is going wrong..even if there could
+ * be no problems! Infact a simple delayed packet may trigger a
+ * dupack. But we need to be careful in such case.
+ */
+static void tcp_westwood_slow_bw(struct tcp_sock *tp)
+{
+	struct tcp_westwood_info *w = tcp_ca(tp);
+
+	westwood_update_window(tp, tcp_time_stamp);
+
+	w->bk += westwood_acked_count(tp);
+	w->rtt_min = westwood_update_rttmin(w);
+}
+
+static inline u32 tcp_westwood_bw_rttmin(const struct tcp_sock *tp)
+{
+	struct tcp_westwood_info *w = tcp_ca(tp);
+
+        return max((w->bw_est) * (w->rtt_min) / (u32) (tp->mss_cache_std),
+		   2U);
+}
+
+static inline u32 tcp_westwood_ssthresh(struct tcp_sock *tp)
+{
+	u32 ssthresh = tcp_westwood_bw_rttmin(tp);
+	if (ssthresh)
+		tp->snd_ssthresh = ssthresh;  
+
+	return (ssthresh != 0);
+}
+
+static inline int tcp_westwood_cwnd(struct tcp_sock *tp)
+{
+	u32 cwnd = 0;
+
+	cwnd = tcp_westwood_bw_rttmin(tp);
+	if (cwnd)
+		tp->snd_cwnd = cwnd;
+
+	return (cwnd != 0);
+}
+
+/*
+ * TCP Westwood
+ * Here limit is evaluated as BWestimation*RTTmin (for obtaining it
+ * in packets we use mss_cache). If sysctl_tcp_westwood is off
+ * tcp_westwood_bw_rttmin() returns 0. In such case snd_ssthresh is
+ * still used as usual. It prevents other strange cases in which
+ * BWE*RTTmin could assume value 0. It should not happen but...
+ */
+static u32 tcp_westwood_cwnd_min(struct tcp_sock *tp)
+{
+	u32 limit;
+
+	limit = tcp_westwood_bw_rttmin(tp);
+	if (limit == 0)
+		limit = tp->snd_ssthresh/2;
+	return limit;
+}
+
+static void tcp_westwood_event(struct tcp_sock *tp, enum tcp_ca_event event)
+{
+	switch(event) {
+	case CA_EVENT_CWND_RESTART:
+		break;
+
+	case CA_EVENT_COMPLETE_CWR:
+		if (tcp_westwood_cwnd(tp)) 
+			tp->snd_ssthresh = tp->snd_cwnd;
+		break;
+
+	case CA_EVENT_FRTO:
+		if (!tcp_westwood_ssthresh(tp))
+			tp->snd_ssthresh = tcp_westwood_ssthresh(tp);
+		break;
+
+	case CA_EVENT_FAST_ACK:
+		tcp_westwood_fast_bw(tp);
+		break;
+
+	case CA_EVENT_SLOW_ACK:
+		tcp_westwood_slow_bw(tp);
+		break;
+
+	}
+}
+
+static struct tcp_ca_type tcp_westwood = {
+	.start		= tcp_westwood_start,
+	.ssthresh	= tcp_reno_ssthresh,
+	.rtt_sample	= tcp_westwood_sample_rtt,
+	.cong_avoid	= tcp_reno_cong_avoid,
+	.min_cwnd	= tcp_westwood_cwnd_min,
+	.cwnd_event	= tcp_westwood_event,
+
+	.owner		= THIS_MODULE,
+	.name		= "westwood"
+};
+
+static int __init tcp_westwood_init(void)
+{
+	BUILD_BUG_ON(sizeof(struct tcp_westwood_info) > TCP_CA_PRIV_SIZE);
+	tcp_ca_register(&tcp_westwood);
+	return 0;
+}
+
+static void __exit tcp_westwood_exit(void)
+{
+	tcp_ca_unregister(&tcp_westwood);
+}
+
+module_init(tcp_westwood_init);
+module_exit(tcp_westwood_exit);
+
+MODULE_AUTHOR("Stephen Hemminger, Angelo Del'Aera");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("TCP Westwood+");
+
+
