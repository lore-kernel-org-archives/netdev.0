From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/5] TCP infrastructure split out
Date: Fri, 18 Mar 2005 16:22:21 -0800
Message-ID: <20050318162221.501ff05a@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Injong Rhee <rhee@eos.ncsu.edu>
To: Andrew Morton <akpm@digeo.com>, "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Since developers want to experiment with different congestion
control mechanisms, and the kernel is getting bloated with overlapping
data structure and code for multiple algorithms; here is a patch to
split out the Reno, Vegas, Westwood, BIC congestion control stuff
into an infrastructure similar to the I/O schedulers.

Here is the more cleaned up version of the TCP congestion algorithm splitout
This first patch removes everything but Reno and puts in the infrastructure.
It also adds tracking of the average acks per packet ratio for TCP BIC, because
other algorithms might want it.

Given the possibility for major screwup, let's put it in the -mm tree until
2.6.13.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


diff -Nru a/include/linux/sysctl.h b/include/linux/sysctl.h
--- a/include/linux/sysctl.h	2005-03-18 16:09:08 -08:00
+++ b/include/linux/sysctl.h	2005-03-18 16:09:08 -08:00
@@ -346,6 +346,7 @@
 	NET_TCP_MODERATE_RCVBUF=106,
 	NET_TCP_TSO_WIN_DIVISOR=107,
 	NET_TCP_BIC_BETA=108,
+	NET_TCP_CONG_CONTROL=109,
 };
 
 enum {
diff -Nru a/include/linux/tcp.h b/include/linux/tcp.h
--- a/include/linux/tcp.h	2005-03-18 16:09:08 -08:00
+++ b/include/linux/tcp.h	2005-03-18 16:09:08 -08:00
@@ -203,13 +203,6 @@
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
@@ -294,7 +287,7 @@
 	__u8	reordering;	/* Packet reordering metric.		*/
 	__u8	frto_counter;	/* Number of new acks after RTO */
 
-	__u8	adv_cong;	/* Using Vegas, Westwood, or BIC */
+	__u8	unused;
 	__u8	defer_accept;	/* User waits for some data after accept() */
 
 /* RTT measurement */
@@ -316,6 +309,7 @@
 	__u8	keepalive_probes; /* num of allowed keep alive probes	*/
 
 	__u8	probes_out;	/* unanswered 0 window probes		*/
+	__u32	ack_ratio;	/* estimate the ratio of Packets/ACKs << 3 */
 	struct tcp_options_received rx_opt;
 
 /*
@@ -405,42 +399,21 @@
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
+/* Hook for advanced congestion control */
+	struct tcp_ca_type *ca_proto;
 
-	/* BI TCP Parameters */
-	struct {
-		__u32	cnt;		/* increase cwnd by 1 after this number of ACKs */
-		__u32 	last_max_cwnd;	/* last maximium snd_cwnd */
-		__u32	last_cwnd;	/* the last snd_cwnd */
-		__u32   last_stamp;     /* time when updated last_cwnd */
-	} bictcp;
+#define TCP_CA_PRIV_SIZE   48
+	u32	ca_priv[TCP_CA_PRIV_SIZE/sizeof(u32)];
 };
 
 static inline struct tcp_sock *tcp_sk(const struct sock *sk)
 {
 	return (struct tcp_sock *)sk;
+}
+
+static inline void *tcp_ca(const struct tcp_sock *tp)
+{
+	return (void *) tp->ca_priv;
 }
 
 #endif
diff -Nru a/include/linux/tcp_diag.h b/include/linux/tcp_diag.h
--- a/include/linux/tcp_diag.h	2005-03-18 16:09:08 -08:00
+++ b/include/linux/tcp_diag.h	2005-03-18 16:09:08 -08:00
@@ -123,5 +123,9 @@
 	__u32	tcpv_minrtt;
 };
 
+#ifdef __KERNEL__
+extern void *tcpdiag_put(struct sk_buff *skb, int attrtype, size_t len);
+#endif
+
 
 #endif /* _TCP_DIAG_H_ */
diff -Nru a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h	2005-03-18 16:09:08 -08:00
+++ b/include/net/tcp.h	2005-03-18 16:09:08 -08:00
@@ -504,25 +504,6 @@
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
@@ -596,16 +577,7 @@
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
 
@@ -1204,6 +1176,64 @@
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
+	CA_EVENT_TX_START,
+};
+
+struct tcp_ca_type {
+	void (*start)(struct tcp_sock *tp);
+	u32 (*ssthresh)(struct tcp_sock *tp);
+	u32 (*min_cwnd)(struct tcp_sock *tp);
+	void (*cong_avoid)(struct tcp_sock *tp, u32 ack, 
+			   u32 rtt, u32 in_flight, int good);
+	void (*rtt_sample)(struct tcp_sock *tp, u32 rtt);
+	void (*set_state)(struct tcp_sock *tp, u8 new_state);
+
+	void (*cwnd_event)(struct tcp_sock *tp, enum tcp_ca_event ev);
+	u32  (*undo_cwnd)(struct tcp_sock *tp);
+	void (*get_info)(struct tcp_sock *tp, u32 ext, struct sk_buff *skb);
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
+				u32 rtt, u32 in_flight, int flag);
+extern u32 tcp_reno_cwnd_min(struct tcp_sock *tp);
+extern u32 tcp_reno_ssthresh(struct tcp_sock *tp);
+
+static inline void tcp_set_ca_state(struct tcp_sock *tp, u8 ca_state)
+{
+	if (tp->ca_proto && tp->ca_proto->set_state)
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
@@ -1223,91 +1253,6 @@
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
@@ -1356,7 +1301,7 @@
 static inline void __tcp_enter_cwr(struct tcp_sock *tp)
 {
 	tp->undo_marker = 0;
-	tp->snd_ssthresh = tcp_recalc_ssthresh(tp);
+	tp->snd_ssthresh = tp->ca_proto->ssthresh(tp);
 	tp->snd_cwnd = min(tp->snd_cwnd,
 			   tcp_packets_in_flight(tp) + 1U);
 	tp->snd_cwnd_cnt = 0;
@@ -1971,52 +1916,4 @@
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
diff -Nru a/net/ipv4/Kconfig b/net/ipv4/Kconfig
--- a/net/ipv4/Kconfig	2005-03-18 16:09:08 -08:00
+++ b/net/ipv4/Kconfig	2005-03-18 16:09:08 -08:00
@@ -365,5 +365,10 @@
 config IP_TCPDIAG_IPV6
 	def_bool (IP_TCPDIAG=y && IPV6=y) || (IP_TCPDIAG=m && IPV6)
 
+
+menu "TCP congestion control"
+
+endmenu
+
 source "net/ipv4/ipvs/Kconfig"
 
diff -Nru a/net/ipv4/Makefile b/net/ipv4/Makefile
--- a/net/ipv4/Makefile	2005-03-18 16:09:08 -08:00
+++ b/net/ipv4/Makefile	2005-03-18 16:09:08 -08:00
@@ -5,7 +5,8 @@
 obj-y     := utils.o route.o inetpeer.o protocol.o \
 	     ip_input.o ip_fragment.o ip_forward.o ip_options.o \
 	     ip_output.o ip_sockglue.o \
-	     tcp.o tcp_input.o tcp_output.o tcp_timer.o tcp_ipv4.o tcp_minisocks.o \
+	     tcp.o tcp_input.o tcp_output.o tcp_timer.o tcp_ipv4.o \
+	     tcp_minisocks.o tcp_cong.o tcp_reno.o \
 	     datagram.o raw.o udp.o arp.o icmp.o devinet.o af_inet.o igmp.o \
 	     sysctl_net_ipv4.o fib_frontend.o fib_semantics.o fib_hash.o
 
diff -Nru a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
--- a/net/ipv4/sysctl_net_ipv4.c	2005-03-18 16:09:08 -08:00
+++ b/net/ipv4/sysctl_net_ipv4.c	2005-03-18 16:09:08 -08:00
@@ -603,70 +603,6 @@
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
@@ -683,12 +619,13 @@
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
diff -Nru a/net/ipv4/tcp.c b/net/ipv4/tcp.c
--- a/net/ipv4/tcp.c	2005-03-18 16:09:08 -08:00
+++ b/net/ipv4/tcp.c	2005-03-18 16:09:08 -08:00
@@ -2366,6 +2366,8 @@
 	printk(KERN_INFO "TCP: Hash tables configured "
 	       "(established %d bind %d)\n",
 	       tcp_ehash_size << 1, tcp_bhash_size);
+
+	tcp_ca_register(&tcp_reno);
 }
 
 EXPORT_SYMBOL(tcp_accept);
diff -Nru a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/net/ipv4/tcp_cong.c	2005-03-18 16:09:08 -08:00
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
diff -Nru a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
--- a/net/ipv4/tcp_diag.c	2005-03-18 16:09:08 -08:00
+++ b/net/ipv4/tcp_diag.c	2005-03-18 16:09:08 -08:00
@@ -42,18 +42,24 @@
 
 static struct sock *tcpnl;
 
+void *tcpdiag_put(struct sk_buff *skb, int attrtype, size_t attrlen)
+{
+	int rtalen = RTA_LENGTH(attrlen);
+	struct rtattr *rta;
+
+	if (skb_tailroom(skb) < RTA_ALIGN(rtalen))
+		return NULL;
 
-#define TCPDIAG_PUT(skb, attrtype, attrlen) \
-({ int rtalen = RTA_LENGTH(attrlen);        \
-   struct rtattr *rta;                      \
-   if (skb_tailroom(skb) < RTA_ALIGN(rtalen)) goto nlmsg_failure; \
-   rta = (void*)__skb_put(skb, RTA_ALIGN(rtalen)); \
-   rta->rta_type = attrtype;                \
-   rta->rta_len = rtalen;                   \
-   RTA_DATA(rta); })
+	rta = (void *)__skb_put(skb, RTA_ALIGN(rtalen));
+	rta->rta_type = attrtype;
+	rta->rta_len = rtalen;
+	
+	return RTA_DATA(rta);
+}
+EXPORT_SYMBOL(tcpdiag_put);
 
 static int tcpdiag_fill(struct sk_buff *skb, struct sock *sk,
-			int ext, u32 pid, u32 seq, u16 nlmsg_flags)
+			u32 ext, u32 pid, u32 seq, u16 nlmsg_flags)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -61,7 +67,6 @@
 	struct nlmsghdr  *nlh;
 	struct tcp_info  *info = NULL;
 	struct tcpdiag_meminfo  *minfo = NULL;
-	struct tcpvegas_info *vinfo = NULL;
 	unsigned char	 *b = skb->tail;
 
 	nlh = NLMSG_PUT(skb, pid, seq, TCPDIAG_GETSOCK, sizeof(*r));
@@ -69,13 +74,10 @@
 	r = NLMSG_DATA(nlh);
 	if (sk->sk_state != TCP_TIME_WAIT) {
 		if (ext & (1<<(TCPDIAG_MEMINFO-1)))
-			minfo = TCPDIAG_PUT(skb, TCPDIAG_MEMINFO, sizeof(*minfo));
+			minfo = tcpdiag_put(skb, TCPDIAG_MEMINFO, sizeof(*minfo));
 		if (ext & (1<<(TCPDIAG_INFO-1)))
-			info = TCPDIAG_PUT(skb, TCPDIAG_INFO, sizeof(*info));
+			info = tcpdiag_put(skb, TCPDIAG_INFO, sizeof(*info));
 		
-		if ((tcp_is_westwood(tp) || tcp_is_vegas(tp))
-		    && (ext & (1<<(TCPDIAG_VEGASINFO-1))))
-			vinfo = TCPDIAG_PUT(skb, TCPDIAG_VEGASINFO, sizeof(*vinfo));
 	}
 	r->tcpdiag_family = sk->sk_family;
 	r->tcpdiag_state = sk->sk_state;
@@ -166,20 +168,10 @@
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
+	if (sk->sk_state != TCP_TIME_WAIT && 
+	    tp->ca_proto && tp->ca_proto->get_info)
+		tp->ca_proto->get_info(tp, ext, skb);
+		
 	nlh->nlmsg_len = skb->tail - b;
 	return skb->len;
 
diff -Nru a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c	2005-03-18 16:09:08 -08:00
+++ b/net/ipv4/tcp_input.c	2005-03-18 16:09:08 -08:00
@@ -61,7 +61,6 @@
  *		Panu Kuhlberg:		Experimental audit of TCP (re)transmission
  *					engine. Lots of bugs are found.
  *		Pasi Sarolahti:		F-RTO for dealing with spurious RTOs
- *		Angelo Dell'Aera:	TCP Westwood+ support
  */
 
 #include <linux/config.h>
@@ -88,23 +87,9 @@
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
@@ -333,15 +318,6 @@
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
@@ -558,45 +534,6 @@
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
@@ -610,9 +547,6 @@
 {
 	long m = mrtt; /* RTT */
 
-	if (tcp_vegas_enabled(tp))
-		vegas_rtt_calc(tp, mrtt);
-
 	/*	The following amusing code comes from Jacobson's
 	 *	article in SIGCOMM '88.  Note that rtt and mdev
 	 *	are scaled versions of rtt and mean deviation.
@@ -670,7 +604,8 @@
 		tp->rtt_seq = tp->snd_nxt;
 	}
 
-	tcp_westwood_update_rtt(tp, tp->srtt >> 3);
+	if (tp->ca_proto->rtt_sample)
+		tp->ca_proto->rtt_sample(tp, mrtt);
 }
 
 /* Calculate rto without backoff.  This is the second half of Van Jacobson's
@@ -1185,8 +1120,7 @@
             tp->snd_una == tp->high_seq ||
             (tp->ca_state == TCP_CA_Loss && !tp->retransmits)) {
 		tp->prior_ssthresh = tcp_current_ssthresh(tp);
-		if (!tcp_westwood_ssthresh(tp))
-			tp->snd_ssthresh = tcp_recalc_ssthresh(tp);
+		tcp_ca_event(tp, CA_EVENT_FRTO);
 	}
 
 	/* Have to clear retransmission markers here to keep the bookkeeping
@@ -1252,8 +1186,6 @@
 	tcp_set_ca_state(tp, TCP_CA_Loss);
 	tp->high_seq = tp->frto_highmark;
 	TCP_ECN_queue_cwr(tp);
-
-	init_bictcp(tp);
 }
 
 void tcp_clear_retrans(struct tcp_sock *tp)
@@ -1283,7 +1215,7 @@
 	if (tp->ca_state <= TCP_CA_Disorder || tp->snd_una == tp->high_seq ||
 	    (tp->ca_state == TCP_CA_Loss && !tp->retransmits)) {
 		tp->prior_ssthresh = tcp_current_ssthresh(tp);
-		tp->snd_ssthresh = tcp_recalc_ssthresh(tp);
+		tp->snd_ssthresh = tp->ca_proto->ssthresh(tp);
 	}
 	tp->snd_cwnd	   = 1;
 	tp->snd_cwnd_cnt   = 0;
@@ -1314,6 +1246,7 @@
 
 	tp->reordering = min_t(unsigned int, tp->reordering,
 					     sysctl_tcp_reordering);
+
 	tcp_set_ca_state(tp, TCP_CA_Loss);
 	tp->high_seq = tp->snd_nxt;
 	TCP_ECN_queue_cwr(tp);
@@ -1600,24 +1533,11 @@
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
@@ -1654,7 +1574,10 @@
 static void tcp_undo_cwr(struct tcp_sock *tp, int undo)
 {
 	if (tp->prior_ssthresh) {
-		tp->snd_cwnd = max(tp->snd_cwnd, tp->snd_ssthresh<<1);
+		if (tp->ca_proto->undo_cwnd)
+			tp->snd_cwnd = tp->ca_proto->undo_cwnd(tp);
+		else
+			tp->snd_cwnd = max(tp->snd_cwnd, tp->snd_ssthresh<<1);
 
 		if (undo && tp->prior_ssthresh > tp->snd_ssthresh) {
 			tp->snd_ssthresh = tp->prior_ssthresh;
@@ -1764,10 +1687,8 @@
 
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
 
@@ -1943,7 +1864,7 @@
 		if (tp->ca_state < TCP_CA_CWR) {
 			if (!(flag&FLAG_ECE))
 				tp->prior_ssthresh = tcp_current_ssthresh(tp);
-			tp->snd_ssthresh = tcp_recalc_ssthresh(tp);
+			tp->snd_ssthresh = tp->ca_proto->ssthresh(tp);
 			TCP_ECN_queue_cwr(tp);
 		}
 
@@ -2016,322 +1937,13 @@
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
+				  u32 in_flight, int good)
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
+	tp->ca_proto->cong_avoid(tp, ack, seq_rtt, in_flight, good);
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
@@ -2419,6 +2031,7 @@
 	__u32 now = tcp_time_stamp;
 	int acked = 0;
 	__s32 seq_rtt = -1;
+	int cnt = 0;
 
 	while ((skb = skb_peek(&sk->sk_write_queue)) &&
 	       skb != sk->sk_send_head) {
@@ -2473,6 +2086,7 @@
 		tcp_packets_out_dec(tp, skb);
 		__skb_unlink(skb, skb->list);
 		sk_stream_free_skb(sk, skb);
+		cnt += 1<<3;
 	}
 
 	if (acked&FLAG_ACKED) {
@@ -2480,6 +2094,10 @@
 		tcp_ack_packets_out(sk, tp);
 	}
 
+	/* smoothed average of # packets per ack */
+	cnt -= tp->ack_ratio >> 3;
+	tp->ack_ratio += cnt;
+
 #if FASTRETRANS_DEBUG > 0
 	BUG_TRAP((int)tp->sacked_out >= 0);
 	BUG_TRAP((int)tp->lost_out >= 0);
@@ -2621,256 +2239,6 @@
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
@@ -2899,9 +2267,10 @@
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
@@ -2917,7 +2286,7 @@
 		if (TCP_ECN_rcv_ecn_echo(tp, skb->h.th))
 			flag |= FLAG_ECE;
 
-		tcp_westwood_slow_bw(sk,skb);
+		tcp_ca_event(tp, CA_EVENT_SLOW_ACK);
 	}
 
 	/* We passed data and got it acked, remove any soft error
@@ -2938,16 +2307,13 @@
 		tcp_process_frto(sk, prior_snd_una);
 
 	if (tcp_ack_is_dubious(tp, flag)) {
-		/* Advanve CWND, if state allows this. */
-		if ((flag & FLAG_DATA_ACKED) &&
-		    (tcp_vegas_enabled(tp) || prior_in_flight >= tp->snd_cwnd) &&
-		    tcp_may_raise_cwnd(tp, flag))
-			tcp_cong_avoid(tp, ack, seq_rtt);
+		/* Advance CWND, if state allows this. */
+		if ((flag & FLAG_DATA_ACKED) && tcp_may_raise_cwnd(tp, flag))
+			tcp_cong_avoid(tp, ack, seq_rtt, prior_in_flight, 0);
 		tcp_fastretrans_alert(sk, prior_snd_una, prior_packets, flag);
 	} else {
-		if ((flag & FLAG_DATA_ACKED) && 
-		    (tcp_vegas_enabled(tp) || prior_in_flight >= tp->snd_cwnd))
-			tcp_cong_avoid(tp, ack, seq_rtt);
+		if ((flag & FLAG_DATA_ACKED))
+			tcp_cong_avoid(tp, ack, seq_rtt, prior_in_flight, 1);
 	}
 
 	if ((flag & FLAG_FORWARD_PROGRESS) || !(flag&FLAG_NOT_DUP))
@@ -4715,8 +4081,7 @@
 			if(tp->af_specific->conn_request(sk, skb) < 0)
 				return 1;
 
-			init_westwood(sk);
-			init_bictcp(tp);
+			tcp_ca_init(tp);
 
 			/* Now we have several options: In theory there is 
 			 * nothing else in the frame. KA9Q has an option to 
@@ -4739,8 +4104,7 @@
 		goto discard;
 
 	case TCP_SYN_SENT:
-		init_westwood(sk);
-		init_bictcp(tp);
+		tcp_ca_init(tp);
 
 		queued = tcp_rcv_synsent_state_process(sk, skb, th, len);
 		if (queued >= 0)
diff -Nru a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c	2005-03-18 16:09:08 -08:00
+++ b/net/ipv4/tcp_ipv4.c	2005-03-18 16:09:08 -08:00
@@ -2058,7 +2058,6 @@
 	tp->snd_ssthresh = 0x7fffffff;	/* Infinity */
 	tp->snd_cwnd_clamp = ~0;
 	tp->mss_cache_std = tp->mss_cache = 536;
-
 	tp->reordering = sysctl_tcp_reordering;
 
 	sk->sk_state = TCP_CLOSE;
@@ -2081,6 +2080,8 @@
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	tcp_clear_xmit_timers(sk);
+
+	tcp_ca_destroy(tp);
 
 	/* Cleanup up the write buffer. */
   	sk_stream_writequeue_purge(sk);
diff -Nru a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c	2005-03-18 16:09:08 -08:00
+++ b/net/ipv4/tcp_output.c	2005-03-18 16:09:08 -08:00
@@ -111,8 +111,7 @@
 	u32 restart_cwnd = tcp_init_cwnd(tp, dst);
 	u32 cwnd = tp->snd_cwnd;
 
-	if (tcp_is_vegas(tp)) 
-		tcp_vegas_enable(tp);
+	tcp_ca_event(tp, CA_EVENT_CWND_RESTART);
 
 	tp->snd_ssthresh = tcp_current_ssthresh(tp);
 	restart_cwnd = min(restart_cwnd, cwnd);
@@ -304,17 +303,9 @@
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
+		if (tcp_packets_in_flight(tp) == 0 &&
+		    tp->ca_proto && tp->ca_proto->cwnd_event)
+			tp->ca_proto->cwnd_event(tp, CA_EVENT_TX_START);
 
 		th = (struct tcphdr *) skb_push(skb, tcp_header_size);
 		skb->h.th = th;
diff -Nru a/net/ipv4/tcp_reno.c b/net/ipv4/tcp_reno.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/net/ipv4/tcp_reno.c	2005-03-18 16:09:08 -08:00
@@ -0,0 +1,64 @@
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
+void tcp_reno_cong_avoid(struct tcp_sock *tp, u32 ack, u32 rtt, u32 in_flight,
+			 int flag)
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
