From: Baruch Even <baruch@ev-en.org>
Subject: [RFC PATCH 1/5] Implement H-TCP congestion control algorithm
Date: Fri, 11 Mar 2005 18:08:35 +0200 (IST)
Message-ID: <20050311160835.30424.23960.13323@galon.ev-en.org>
References: <20050311160734.30424.67955.65942@galon.ev-en.org>
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com,
        Baruch Even <baruch@ev-en.org>, Douglas Leith <doug.leith@nuim.ie>,
        Stephen Hemminger <shemminger@osdl.org>
To: "David S.Miller" <davem@davemloft.net>
In-Reply-To: <20050311160734.30424.67955.65942@galon.ev-en.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

H-TCP implementation.

H-TCP is an improved congestion control algorithm for TCP which aims to work on
the regular networks and high-speed networks, and provide maximum bandwidth
utilization while maintaining relative fairness between TCP and H-TCP streams.

You can find more information on H-TCP at http://hamilton.ie/net/

Signed-Off-By: Douglas Leith <doug.leith@nuim.ie>
Signed-Off-By: Baruch Even <baruch@ev-en.org>

Index: 2.6.12-rc/include/linux/sysctl.h
===================================================================
--- 2.6.12-rc.orig/include/linux/sysctl.h
+++ 2.6.12-rc/include/linux/sysctl.h
@@ -346,6 +346,8 @@ enum
 	NET_TCP_MODERATE_RCVBUF=106,
 	NET_TCP_TSO_WIN_DIVISOR=107,
 	NET_TCP_BIC_BETA=108,
+	NET_TCP_HTCP=109,
+	NET_TCP_HTCP_MODESWITCH=110,
 };
 
 enum {
Index: 2.6.12-rc/include/linux/tcp.h
===================================================================
--- 2.6.12-rc.orig/include/linux/tcp.h
+++ 2.6.12-rc/include/linux/tcp.h
@@ -208,6 +208,7 @@ enum tcp_congestion_algo {
 	TCP_VEGAS,
 	TCP_WESTWOOD,
 	TCP_BIC,
+	TCP_HTCP,
 };
 
 struct tcp_options_received {
@@ -437,6 +438,27 @@ struct tcp_sock {
 		__u32	last_cwnd;	/* the last snd_cwnd */
 		__u32   last_stamp;     /* time when updated last_cwnd */
 	} bictcp;
+
+	/* HTCP variables */
+	struct {
+		__u16	snd_ccount;	/* number of RTT's since last back-off */
+		__u16	snd_cwnd_cnt2;	/* counter used as part of snd_ccount calculation */
+		__u32	snd_minRTT;	/* minimum RTT */
+		__u32	snd_maxRTT;	/* max RTT */
+		__u32	snd_packetcount;/* number of packets acked since snd_lasttime */
+		__u32	snd_lasttime;
+		__u32	snd_minB;	/* throughput just after a backoff event */
+		__u32	snd_maxB;	/* max throughput achieved in current congestion epoch */
+		__u32	snd_oldmaxB;	/* max throughput achieved in previous congestion epoch */
+		__u32	snd_Bi; 	/* current achieved throughput */
+		__u32	snd_modecount;
+		__u32	snd_alpha;	/* current cwnd increase rate */
+		__u32	undo_modecount;
+		__u32	undo_oldmaxB;
+		__u32	undo_maxRTT;
+		__u16	undo_ccount;
+		__u8	snd_beta;	/* current backoff factor <<7 */
+	} htcp;
 };
 
 static inline struct tcp_sock *tcp_sk(const struct sock *sk)
Index: 2.6.12-rc/include/net/tcp.h
===================================================================
--- 2.6.12-rc.orig/include/net/tcp.h
+++ 2.6.12-rc/include/net/tcp.h
@@ -562,6 +562,10 @@ static __inline__ int tcp_sk_listen_hash
 #define TCP_NAGLE_CORK		2	/* Socket is corked	    */
 #define TCP_NAGLE_PUSH		4	/* Cork is overriden for already queued data */
 
+/* HTCP constants */
+#define HTCP_BETA_MIN	(1<<6)  /* 0.5 with shift << 7 */
+#define HTCP_BETA_MAX	102	/* 0.8 with shift << 7 */
+
 /* sysctl variables for tcp */
 extern int sysctl_max_syn_backlog;
 extern int sysctl_tcp_timestamps;
@@ -608,6 +612,8 @@ extern int sysctl_tcp_bic_low_window;
 extern int sysctl_tcp_bic_beta;
 extern int sysctl_tcp_moderate_rcvbuf;
 extern int sysctl_tcp_tso_win_divisor;
+extern int sysctl_tcp_htcp;
+extern int sysctl_tcp_htcp_modeswitch;
 
 extern atomic_t tcp_memory_allocated;
 extern atomic_t tcp_sockets_allocated;
@@ -930,6 +936,124 @@ extern void			tcp_unhash(struct sock *sk
 
 extern int			tcp_v4_hash_connecting(struct sock *sk);
 
+/* TCP timestamps are only 32-bits, this causes a slight
+ * complication on 64-bit systems since we store a snapshot
+ * of jiffies in the buffer control blocks below.  We decidely
+ * only use of the low 32-bits of jiffies and hide the ugly
+ * casts with the following macro.
+ */
+#define tcp_time_stamp		((__u32)(jiffies))
+
+/*
+ * Which congestion algorithim is in use on the connection.
+ */
+#define tcp_is_vegas(__tp)	((__tp)->adv_cong == TCP_VEGAS)
+#define tcp_is_westwood(__tp)	((__tp)->adv_cong == TCP_WESTWOOD)
+#define tcp_is_bic(__tp)	((__tp)->adv_cong == TCP_BIC)
+#define tcp_is_htcp(__tp)	((__tp)->adv_cong == TCP_HTCP)
+
+static inline void htcp_reset(struct tcp_sock *tp)
+{
+	BUG_TRAP(tp!=NULL);
+
+	tp->htcp.undo_ccount = tp->htcp.snd_ccount;
+	tp->htcp.undo_oldmaxB = tp->htcp.snd_oldmaxB;
+	tp->htcp.undo_modecount = tp->htcp.snd_modecount;
+	tp->htcp.undo_maxRTT = tp->htcp.snd_maxRTT;
+
+	tp->htcp.snd_ccount = 0;
+	tp->htcp.snd_cwnd_cnt2 = 0;
+}
+
+static inline void htcp_beta_check(struct tcp_sock *tp)
+{
+	if (tp->htcp.snd_beta < HTCP_BETA_MIN)
+		tp->htcp.snd_beta = HTCP_BETA_MIN;
+	if (tp->htcp.snd_beta > HTCP_BETA_MAX)
+		tp->htcp.snd_beta = HTCP_BETA_MAX;
+}
+
+static inline void htcp_beta_update(struct tcp_sock *tp)
+{
+	if (!tcp_is_htcp(tp))
+		return;
+	
+	tp->htcp.snd_oldmaxB = tp->htcp.snd_maxB;
+
+	if (sysctl_tcp_htcp_modeswitch) {
+		if (tp->htcp.snd_modecount && tp->htcp.snd_minRTT>HZ/100 && tp->htcp.snd_maxRTT>0)
+			tp->htcp.snd_beta = (tp->htcp.snd_minRTT<<7)/tp->htcp.snd_maxRTT;
+		else
+			tp->htcp.snd_beta = HTCP_BETA_MIN;
+		tp->htcp.snd_modecount++;
+	} else {
+		tp->htcp.snd_modecount = 0;
+		tp->htcp.snd_beta = HTCP_BETA_MIN;
+	}
+	htcp_beta_check(tp);
+
+	/* add slowly fading memory for maxRTT to accommodate routing changes etc */
+	if (tp->htcp.snd_minRTT > 0 && tp->htcp.snd_maxRTT > tp->htcp.snd_minRTT)
+		tp->htcp.snd_maxRTT = tp->htcp.snd_minRTT + ((tp->htcp.snd_maxRTT-tp->htcp.snd_minRTT)*95)/100;
+}
+
+static inline void undo_htcp_reset(struct tcp_sock *tp)
+{
+	BUG_TRAP(tp!=NULL);
+
+	tp->htcp.snd_modecount = tp->htcp.undo_modecount;
+	tp->htcp.snd_oldmaxB = tp->htcp.undo_oldmaxB;
+	tp->htcp.snd_ccount = tp->htcp.undo_ccount;
+	tp->htcp.snd_maxRTT = tp->htcp.undo_maxRTT;
+}
+
+static inline void measure_minRTT(struct tcp_sock *tp)
+{
+	/* keep track of minimum RTT seen so far, minRTT is zero at first */
+	if (tp->htcp.snd_minRTT > tp->srtt>>3 || tp->htcp.snd_minRTT == 0)
+		tp->htcp.snd_minRTT = tp->srtt>>3;
+	if (tp->htcp.snd_minRTT == 0)
+		tp->htcp.snd_minRTT = 1; /* Avoid divide by zero */
+
+	/* max RTT */
+	if (tp->ca_state == TCP_CA_Open && tp->snd_ssthresh < 0xFFFF && tp->htcp.snd_ccount > 3) {
+		if (tp->htcp.snd_maxRTT < tp->htcp.snd_minRTT)
+			tp->htcp.snd_maxRTT = tp->htcp.snd_minRTT;
+		if (tp->srtt>>3 > tp->htcp.snd_maxRTT && tp->srtt>>3 <= tp->htcp.snd_maxRTT+HZ/50)
+			tp->htcp.snd_maxRTT = tp->srtt>>3;
+	}
+}
+
+static inline void measure_achieved_throughput(struct tcp_sock *tp)
+{
+	__u32 now = tcp_time_stamp;
+
+	/* achieved throughput calculations */
+	if (tp->ca_state != TCP_CA_Open && tp->ca_state != TCP_CA_Disorder) {
+		tp->htcp.snd_packetcount = 0;
+		tp->htcp.snd_lasttime = now;
+		return;
+	}
+
+	if (tp->htcp.snd_packetcount >= tp->snd_cwnd-tp->htcp.snd_alpha
+			&& now - tp->htcp.snd_lasttime >= tp->htcp.snd_minRTT
+			&& tp->htcp.snd_minRTT>0) {
+		__u32 cur_Bi = tp->htcp.snd_packetcount*HZ/(now - tp->htcp.snd_lasttime);
+		if (tp->htcp.snd_ccount <=3) {
+			// just after backoff
+			tp->htcp.snd_minB = tp->htcp.snd_maxB = tp->htcp.snd_Bi = cur_Bi;
+		} else {
+			tp->htcp.snd_Bi = (3*tp->htcp.snd_Bi + cur_Bi)/4;
+			if (tp->htcp.snd_Bi > tp->htcp.snd_maxB)
+				tp->htcp.snd_maxB = tp->htcp.snd_Bi;
+			if (tp->htcp.snd_minB > tp->htcp.snd_maxB)
+				tp->htcp.snd_minB = tp->htcp.snd_maxB; //sanity check
+		}
+		tp->htcp.snd_packetcount = 0;
+		tp->htcp.snd_lasttime = now;
+	}
+}
+
 
 /* From syncookies.c */
 extern struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb, 
@@ -1102,14 +1226,6 @@ static __inline__ u32 tcp_receive_window
  */
 extern u32	__tcp_select_window(struct sock *sk);
 
-/* TCP timestamps are only 32-bits, this causes a slight
- * complication on 64-bit systems since we store a snapshot
- * of jiffies in the buffer control blocks below.  We decidely
- * only use of the low 32-bits of jiffies and hide the ugly
- * casts with the following macro.
- */
-#define tcp_time_stamp		((__u32)(jiffies))
-
 /* This is what the send packet queueing engine uses to pass
  * TCP per-packet control information to the transmission
  * code.  We also store the host-order sequence numbers in
@@ -1222,13 +1338,6 @@ static __inline__ unsigned int tcp_packe
 	return (tp->packets_out - tp->left_out + tp->retrans_out);
 }
 
-/*
- * Which congestion algorithim is in use on the connection.
- */
-#define tcp_is_vegas(__tp)	((__tp)->adv_cong == TCP_VEGAS)
-#define tcp_is_westwood(__tp)	((__tp)->adv_cong == TCP_WESTWOOD)
-#define tcp_is_bic(__tp)	((__tp)->adv_cong == TCP_BIC)
-
 /* Recalculate snd_ssthresh, we want to set it to:
  *
  * Reno:
@@ -1238,9 +1347,15 @@ static __inline__ unsigned int tcp_packe
  * BIC:
  *	behave like Reno until low_window is reached,
  *	then increase congestion window slowly
+ *
+ * HTCP:
+ * 	work as tcp but use a variable alpha.
  */
 static inline __u32 tcp_recalc_ssthresh(struct tcp_sock *tp)
 {
+	if (tcp_is_htcp(tp) && sysctl_tcp_htcp_modeswitch)
+		return max((tp->snd_cwnd*tp->htcp.snd_beta)>>7, 2U);
+
 	if (tcp_is_bic(tp)) {
 		if (sysctl_tcp_bic_fast_convergence &&
 		    tp->snd_cwnd < tp->bictcp.last_max_cwnd)
@@ -1354,11 +1469,14 @@ static inline void tcp_cwnd_validate(str
 /* Set slow start threshould and cwnd not falling to slow start */
 static inline void __tcp_enter_cwr(struct tcp_sock *tp)
 {
+	htcp_beta_update(tp);
+
 	tp->undo_marker = 0;
 	tp->snd_ssthresh = tcp_recalc_ssthresh(tp);
 	tp->snd_cwnd = min(tp->snd_cwnd,
 			   tcp_packets_in_flight(tp) + 1U);
 	tp->snd_cwnd_cnt = 0;
+	htcp_reset(tp);
 	tp->high_seq = tp->snd_nxt;
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 	TCP_ECN_queue_cwr(tp);
Index: 2.6.12-rc/net/ipv4/sysctl_net_ipv4.c
===================================================================
--- 2.6.12-rc.orig/net/ipv4/sysctl_net_ipv4.c
+++ 2.6.12-rc/net/ipv4/sysctl_net_ipv4.c
@@ -690,6 +690,22 @@ ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
+	{
+		.ctl_name	= NET_TCP_HTCP,
+		.procname	= "tcp_htcp",
+		.data		= &sysctl_tcp_htcp,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+	{
+		.ctl_name	= NET_TCP_HTCP_MODESWITCH,
+		.procname	= "tcp_htcp_modeswitch",
+		.data		= &sysctl_tcp_htcp_modeswitch,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 	{ .ctl_name = 0 }
 };
 
Index: 2.6.12-rc/net/ipv4/tcp_input.c
===================================================================
--- 2.6.12-rc.orig/net/ipv4/tcp_input.c
+++ 2.6.12-rc/net/ipv4/tcp_input.c
@@ -103,6 +103,8 @@ int sysctl_tcp_bic = 1;
 int sysctl_tcp_bic_fast_convergence = 1;
 int sysctl_tcp_bic_low_window = 14;
 int sysctl_tcp_bic_beta = 819;		/* = 819/1024 (BICTCP_BETA_SCALE) */
+int sysctl_tcp_htcp = 1;
+int sysctl_tcp_htcp_modeswitch = 1;
 
 #define FLAG_DATA		0x01 /* Incoming frame contained data.		*/
 #define FLAG_WIN_UPDATE		0x02 /* Incoming ACK was a window update.	*/
@@ -570,7 +572,9 @@ void tcp_ca_init(struct tcp_sock *tp)
 		tp->adv_cong = TCP_VEGAS;
 		tp->vegas.baseRTT = 0x7fffffff;
 		tcp_vegas_enable(tp);
-	} 
+	} else if (sysctl_tcp_htcp) {
+		tp->adv_cong = TCP_HTCP;
+	}
 }
 
 /* Do RTT sampling needed for Vegas.
@@ -1241,7 +1245,8 @@ static void tcp_enter_frto_loss(struct s
 	tcp_sync_left_out(tp);
 
 	tp->snd_cwnd = tp->frto_counter + tcp_packets_in_flight(tp)+1;
-	tp->snd_cwnd_cnt = 0;
+	tp->snd_cwnd_cnt = 0; // BEVEN major change above (used to be: tp->snd_cwnd=1)
+	htcp_reset(tp);
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 	tp->undo_marker = 0;
 	tp->frto_counter = 0;
@@ -1286,6 +1291,7 @@ void tcp_enter_loss(struct sock *sk, int
 	}
 	tp->snd_cwnd	   = 1;
 	tp->snd_cwnd_cnt   = 0;
+	htcp_reset(tp);
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 
 	tcp_clear_retrans(tp);
@@ -1653,7 +1659,11 @@ static void DBGUNDO(struct sock *sk, str
 static void tcp_undo_cwr(struct tcp_sock *tp, int undo)
 {
 	if (tp->prior_ssthresh) {
-		tp->snd_cwnd = max(tp->snd_cwnd, tp->snd_ssthresh<<1);
+		if (tcp_is_htcp(tp)) {
+			tp->snd_cwnd = max(tp->snd_cwnd, (tp->snd_ssthresh<<7)/tp->htcp.snd_beta);
+			undo_htcp_reset(tp);
+		} else
+			tp->snd_cwnd = max(tp->snd_cwnd, tp->snd_ssthresh<<1);
 
 		if (undo && tp->prior_ssthresh > tp->snd_ssthresh) {
 			tp->snd_ssthresh = tp->prior_ssthresh;
@@ -1939,6 +1949,8 @@ tcp_fastretrans_alert(struct sock *sk, u
 		tp->undo_marker = tp->snd_una;
 		tp->undo_retrans = tp->retrans_out;
 
+		htcp_beta_update(tp);
+
 		if (tp->ca_state < TCP_CA_CWR) {
 			if (!(flag&FLAG_ECE))
 				tp->prior_ssthresh = tcp_current_ssthresh(tp);
@@ -1946,6 +1958,10 @@ tcp_fastretrans_alert(struct sock *sk, u
 			TCP_ECN_queue_cwr(tp);
 		}
 
+		htcp_reset(tp);
+		if (tp->snd_cwnd > tp->htcp.snd_alpha+2) /* account for expected packet loss up front */
+			tp->snd_cwnd = tp->snd_cwnd - tp->htcp.snd_alpha;
+
 		tp->snd_cwnd_cnt = 0;
 		tcp_set_ca_state(tp, TCP_CA_Recovery);
 	}
@@ -2087,18 +2103,43 @@ static inline void reno_cong_avoid(struc
                 /* In "safe" area, increase. */
 		if (tp->snd_cwnd < tp->snd_cwnd_clamp)
 			tp->snd_cwnd++;
+		htcp_beta_check(tp);
 	} else {
-                /* In dangerous area, increase slowly.
-		 * In theory this is tp->snd_cwnd += 1 / tp->snd_cwnd
-		 */
-		if (tp->snd_cwnd_cnt >= bictcp_cwnd(tp)) {
-			if (tp->snd_cwnd < tp->snd_cwnd_clamp)
-				tp->snd_cwnd++;
-			tp->snd_cwnd_cnt=0;
-		} else
+		/* In dangerous area, increase slowly. */
+
+		if (tcp_is_htcp(tp)) {
+			__u32 alpha = 1;
+
+			/* keep track of number of round-trip times since last backoff event */
+			if (tp->htcp.snd_cwnd_cnt2 > tp->snd_cwnd) {
+				tp->htcp.snd_ccount++;
+				tp->htcp.snd_cwnd_cnt2 = 0;
+			} else
+				tp->htcp.snd_cwnd_cnt2++;
+
+			measure_minRTT(tp);
+
+			/* calculate increase rate - alpha is number of packets added to cwnd per RTT */
+			tp->htcp.snd_alpha = alpha;
+
 			tp->snd_cwnd_cnt++;
-        }
-	tp->snd_cwnd_stamp = tcp_time_stamp;
+			if ((tp->snd_cwnd_cnt*alpha)>>7 > tp->snd_cwnd) {
+				tp->snd_cwnd++;
+				tp->snd_cwnd_cnt = 0;
+			}
+		} else {
+			tp->htcp.snd_alpha = 1;
+
+			/* In theory this is tp->snd_cwnd += 1 / tp->snd_cwnd */
+			if (tp->snd_cwnd_cnt >= bictcp_cwnd(tp)) {
+				if (tp->snd_cwnd < tp->snd_cwnd_clamp)
+					tp->snd_cwnd++;
+				tp->snd_cwnd_cnt = 0;
+			} else
+				tp->snd_cwnd_cnt++;
+		}
+		tp->snd_cwnd_stamp = tcp_time_stamp;
+	}
 }
 
 /* This is based on the congestion detection/avoidance scheme described in
@@ -2444,6 +2485,7 @@ static int tcp_clean_rtx_queue(struct so
 		 */
 		if (!(scb->flags & TCPCB_FLAG_SYN)) {
 			acked |= FLAG_DATA_ACKED;
+			tp->htcp.snd_packetcount++;
 		} else {
 			acked |= FLAG_SYN_ACKED;
 			tp->retrans_stamp = 0;
@@ -2479,6 +2521,8 @@ static int tcp_clean_rtx_queue(struct so
 		tcp_ack_packets_out(sk, tp);
 	}
 
+	measure_achieved_throughput(tp);
+
 #if FASTRETRANS_DEBUG > 0
 	BUG_TRAP((int)tp->sacked_out >= 0);
 	BUG_TRAP((int)tp->lost_out >= 0);
@@ -2620,6 +2664,13 @@ static void tcp_process_frto(struct sock
 	tp->frto_counter = (tp->frto_counter + 1) % 3;
 }
 
+static void init_htcp(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	tp->htcp.snd_beta = HTCP_BETA_MIN;
+}
+
 /*
  * TCP Westwood+
  */
@@ -4714,6 +4765,7 @@ int tcp_rcv_state_process(struct sock *s
 				return 1;
 
 			init_westwood(sk);
+			init_htcp(sk);
 			init_bictcp(tp);
 
 			/* Now we have several options: In theory there is 
@@ -4738,6 +4790,7 @@ int tcp_rcv_state_process(struct sock *s
 
 	case TCP_SYN_SENT:
 		init_westwood(sk);
+		init_htcp(sk);
 		init_bictcp(tp);
 
 		queued = tcp_rcv_synsent_state_process(sk, skb, th, len);
