From: greearb@candelatech.com
Subject: [RFC] TCP:  Support configurable delayed-ack parameters.
Date: Mon, 18 Jun 2012 17:52:43 -0700
Message-ID: <1340067163-29329-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>,
	Daniel Baluta <dbaluta@ixiacom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34507 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751656Ab2FSAw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 20:52:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

RFC2581 ($4.2) specifies when an ACK should be generated as follows:

" .. an ACK SHOULD be generated for at least every second
  full-sized segment, and MUST be generated within 500 ms
  of the arrival of the first unacknowledged packet.
"

We export the number of segments and the timeout limits
specified above, so that a user can tune them according
to their needs.

Specifically:
	* /proc/sys/net/ipv4/tcp_default_delack_segs, represents
	the threshold for the number of segments.
	* /proc/sys/net/ipv4/tcp_default_delack_min, specifies
	the minimum timeout value
	* /proc/sys/net/ipv4/tcp_default_delack_max, specifies
	the maximum timeout value.

In addition, new TCP socket options are added to allow
per-socket configuration:

TCP_DELACK_SEGS
TCP_DELACK_MIN
TCP_DELACK_MAX

In order to keep a multiply out of the hot path, the segs * mss
computation is recalculated and cached whenever segs or mss changes.

Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>
Signed-off-by: Ben Greear <greearb@candelatech.com>
---

Compile-tested only at this point.


 Documentation/networking/ip-sysctl.txt |   13 +++++++++++++
 include/linux/tcp.h                    |    3 +++
 include/net/inet_connection_sock.h     |   31 ++++++++++++++++++++++++++++---
 include/net/tcp.h                      |   13 ++++++++++---
 net/dccp/output.c                      |    5 +++--
 net/dccp/timer.c                       |    2 +-
 net/ipv4/inet_connection_sock.c        |   13 +++++++++++++
 net/ipv4/sysctl_net_ipv4.c             |   21 +++++++++++++++++++++
 net/ipv4/tcp.c                         |   23 +++++++++++++++++++----
 net/ipv4/tcp_input.c                   |   24 ++++++++++++++----------
 net/ipv4/tcp_output.c                  |   22 +++++++++++++++-------
 net/ipv4/tcp_timer.c                   |    3 ++-
 12 files changed, 142 insertions(+), 31 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 6f896b9..89675d8 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -551,6 +551,19 @@ tcp_thin_dupack - BOOLEAN
 	Documentation/networking/tcp-thin.txt
 	Default: 0
 
+tcp_default_delack_segs: - INTEGER
+	Sets the default minimal number of full-sized TCP segments
+	received after which an ACK should be sent.
+	Default: 1 (as specified in RFC2582, S4.2)
+
+tcp_default_delack_min:	- INTEGER
+	Sets the default minimum time (in miliseconds) to delay before sending an ACK.
+	Default: 40ms
+
+tcp_default_delack_max: - INTEGER
+	Sets the maximum time (in miliseconds) to delay before sending an ACK.
+	Default: 200ms
+
 UDP variables:
 
 udp_mem - vector of 3 INTEGERs: min, pressure, max
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 5f359db..bc73d8c 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -110,6 +110,9 @@ enum {
 #define TCP_REPAIR_QUEUE	20
 #define TCP_QUEUE_SEQ		21
 #define TCP_REPAIR_OPTIONS	22
+#define TCP_DELACK_SEGS         23 /* Number of segments per delayed ack */
+#define TCP_DELACK_MIN          24 /* minimum delayed ack, in miliseconds */
+#define TCP_DELACK_MAX          25 /* maximum delayed ack, in miliseconds */
 
 struct tcp_repair_opt {
 	__u32	opt_code;
diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 7d83f90..2ada03c 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -113,7 +113,12 @@ struct inet_connection_sock {
 		unsigned long	  timeout;	 /* Currently scheduled timeout		   */
 		__u32		  lrcvtime;	 /* timestamp of last received data packet */
 		__u16		  last_seg_size; /* Size of last incoming segment	   */
-		__u16		  rcv_mss;	 /* MSS used for delayed ACK decisions	   */ 
+		__u16		  _rcv_mss;	 /* MSS used for delayed ACK decisions	   */
+		__u32		  calc_thresh;   /* rcv_mss * tcp_delack_segs          */
+		__u16		  tcp_delack_min; /* Minimum ack delay in ms               */
+		__u16		  tcp_delack_max; /* Minimum ack delay in ms               */
+		__u16		  tcp_delack_segs;/* Delay # of segs before sending ack    */
+		__u16		  UNUSED_HOLE;    /* Add new member(s) here                */
 	} icsk_ack;
 	struct {
 		int		  enabled;
@@ -171,11 +176,31 @@ static inline int inet_csk_ack_scheduled(const struct sock *sk)
 	return inet_csk(sk)->icsk_ack.pending & ICSK_ACK_SCHED;
 }
 
-static inline void inet_csk_delack_init(struct sock *sk)
+static inline __u16 inet_csk_get_rcv_mss(const struct sock *sk)
 {
-	memset(&inet_csk(sk)->icsk_ack, 0, sizeof(inet_csk(sk)->icsk_ack));
+	return inet_csk(sk)->icsk_ack._rcv_mss;
 }
 
+static inline void inet_csk_recalc_delack_thresh(struct sock *sk)
+{
+       struct inet_connection_sock *icsk = inet_csk(sk);
+       icsk->icsk_ack.calc_thresh =
+               icsk->icsk_ack._rcv_mss * icsk->icsk_ack.tcp_delack_segs;
+}
+
+static inline void inet_csk_set_rcv_mss(struct sock *sk, __u16 rcv_mss)
+{
+	inet_csk(sk)->icsk_ack._rcv_mss = rcv_mss;
+	inet_csk_recalc_delack_thresh(sk);
+}
+
+static inline u32 inet_csk_delack_thresh(const struct sock *sk)
+{
+       return inet_csk(sk)->icsk_ack.calc_thresh;
+}
+
+extern void inet_csk_delack_init(struct sock *sk);
+
 extern void inet_csk_delete_keepalive_timer(struct sock *sk);
 extern void inet_csk_reset_keepalive_timer(struct sock *sk, unsigned long timeout);
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index e79aa48..d6cb650 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -113,14 +113,18 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 				  * TIME-WAIT timer.
 				  */
 
-#define TCP_DELACK_MAX	((unsigned)(HZ/5))	/* maximal time to delay before sending an ACK */
+/* default maximum time to delay before sending an ACK */
+#define TCP_DELACK_MAX_DEFAULT	((unsigned)(HZ/5))
+
 #if HZ >= 100
-#define TCP_DELACK_MIN	((unsigned)(HZ/25))	/* minimal time to delay before sending an ACK */
+/* default minimum time to delay before sending an ACK */
+#define TCP_DELACK_MIN_DEFAULT	((unsigned)(HZ/25))
 #define TCP_ATO_MIN	((unsigned)(HZ/25))
 #else
-#define TCP_DELACK_MIN	4U
+#define TCP_DELACK_MIN_DEFAULT	4U
 #define TCP_ATO_MIN	4U
 #endif
+
 #define TCP_RTO_MAX	((unsigned)(120*HZ))
 #define TCP_RTO_MIN	((unsigned)(HZ/5))
 #define TCP_TIMEOUT_INIT ((unsigned)(1*HZ))	/* RFC6298 2.1 initial RTO value	*/
@@ -253,6 +257,9 @@ extern int sysctl_tcp_cookie_size;
 extern int sysctl_tcp_thin_linear_timeouts;
 extern int sysctl_tcp_thin_dupack;
 extern int sysctl_tcp_early_retrans;
+extern int sysctl_tcp_default_delack_segs;
+extern int sysctl_tcp_default_delack_min;
+extern int sysctl_tcp_default_delack_max;
 
 extern atomic_long_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 7873673..984a19a 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -574,10 +574,11 @@ void dccp_send_ack(struct sock *sk)
 						GFP_ATOMIC);
 
 		if (skb == NULL) {
+			struct inet_connection_sock *icsk = inet_csk(sk);
 			inet_csk_schedule_ack(sk);
-			inet_csk(sk)->icsk_ack.ato = TCP_ATO_MIN;
+			icsk->icsk_ack.ato = TCP_ATO_MIN;
 			inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
-						  TCP_DELACK_MAX,
+						  icsk->icsk_ack.tcp_delack_max,
 						  DCCP_RTO_MAX);
 			return;
 		}
diff --git a/net/dccp/timer.c b/net/dccp/timer.c
index 16f0b22..2fc883c 100644
--- a/net/dccp/timer.c
+++ b/net/dccp/timer.c
@@ -203,7 +203,7 @@ static void dccp_delack_timer(unsigned long data)
 		icsk->icsk_ack.blocked = 1;
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_DELAYEDACKLOCKED);
 		sk_reset_timer(sk, &icsk->icsk_delack_timer,
-			       jiffies + TCP_DELACK_MIN);
+			       jiffies + icsk->icsk_ack.tcp_delack_min);
 		goto out;
 	}
 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index f9ee741..4206b79 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -366,6 +366,19 @@ void inet_csk_reset_keepalive_timer(struct sock *sk, unsigned long len)
 }
 EXPORT_SYMBOL(inet_csk_reset_keepalive_timer);
 
+extern int sysctl_tcp_default_delack_min;
+extern int sysctl_tcp_default_delack_max;
+extern int sysctl_tcp_default_delack_segs;
+void inet_csk_delack_init(struct sock *sk)
+{
+	struct inet_connection_sock *icsk = inet_csk(sk);
+	memset(&icsk->icsk_ack, 0, sizeof(icsk->icsk_ack));
+	icsk->icsk_ack.tcp_delack_min = sysctl_tcp_default_delack_min;
+	icsk->icsk_ack.tcp_delack_max = sysctl_tcp_default_delack_max;
+	icsk->icsk_ack.tcp_delack_segs = sysctl_tcp_default_delack_segs;
+}
+EXPORT_SYMBOL(inet_csk_delack_init);
+
 struct dst_entry *inet_csk_route_req(struct sock *sk,
 				     struct flowi4 *fl4,
 				     const struct request_sock *req)
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index ef32956..e898a2e 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -687,6 +687,27 @@ static struct ctl_table ipv4_table[] = {
 		.extra2		= &two,
 	},
 	{
+		.procname	= "tcp_default_delack_segs",
+		.data		= &sysctl_tcp_default_delack_segs,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
+		.procname	= "tcp_default_delack_min",
+		.data		= &sysctl_tcp_default_delack_min,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_ms_jiffies
+	},
+	{
+		.procname	= "tcp_default_delack_max",
+		.data		= &sysctl_tcp_default_delack_max,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_ms_jiffies
+	},
+	{
 		.procname	= "udp_mem",
 		.data		= &sysctl_udp_mem,
 		.maxlen		= sizeof(sysctl_udp_mem),
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3ba605f..55a4597 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1305,8 +1305,9 @@ void tcp_cleanup_rbuf(struct sock *sk, int copied)
 		   /* Delayed ACKs frequently hit locked sockets during bulk
 		    * receive. */
 		if (icsk->icsk_ack.blocked ||
-		    /* Once-per-two-segments ACK was not sent by tcp_input.c */
-		    tp->rcv_nxt - tp->rcv_wup > icsk->icsk_ack.rcv_mss ||
+		    /* More than once-per-tcp_delack_segs-segments ACK
+		     * was not sent by tcp_input.c */
+		    tp->rcv_nxt - tp->rcv_wup > inet_csk_delack_thresh(sk) ||
 		    /*
 		     * If this read emptied read buffer, we send ACK, if
 		     * connection is not bidirectional, user drained
@@ -2436,7 +2437,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 	case TCP_NODELAY:
 		if (val) {
 			/* TCP_NODELAY is weaker than TCP_CORK, so that
-			 * this option on corked socket is remembered, but
+			 * thiso ption on corked socket is remembered, but
 			 * it is not activated until cork is cleared.
 			 *
 			 * However, when TCP_NODELAY is set we make
@@ -2627,6 +2628,20 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		 */
 		icsk->icsk_user_timeout = msecs_to_jiffies(val);
 		break;
+
+	case TCP_DELACK_SEGS:
+		icsk->icsk_ack.tcp_delack_segs = val;
+		inet_csk_recalc_delack_thresh(sk);
+		break;
+
+	case TCP_DELACK_MIN:
+		icsk->icsk_ack.tcp_delack_min = val;
+		break;
+
+	case TCP_DELACK_MAX:
+		icsk->icsk_ack.tcp_delack_max = val;
+		break;
+
 	default:
 		err = -ENOPROTOOPT;
 		break;
@@ -2693,7 +2708,7 @@ void tcp_get_info(const struct sock *sk, struct tcp_info *info)
 	info->tcpi_rto = jiffies_to_usecs(icsk->icsk_rto);
 	info->tcpi_ato = jiffies_to_usecs(icsk->icsk_ack.ato);
 	info->tcpi_snd_mss = tp->mss_cache;
-	info->tcpi_rcv_mss = icsk->icsk_ack.rcv_mss;
+	info->tcpi_rcv_mss = inet_csk_get_rcv_mss(sk);
 
 	if (sk->sk_state == TCP_LISTEN) {
 		info->tcpi_unacked = sk->sk_ack_backlog;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index b224eb8..6c0f901 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -101,6 +101,8 @@ int sysctl_tcp_moderate_rcvbuf __read_mostly = 1;
 int sysctl_tcp_abc __read_mostly;
 int sysctl_tcp_early_retrans __read_mostly = 2;
 
+int sysctl_tcp_default_delack_segs __read_mostly = 1;
+
 #define FLAG_DATA		0x01 /* Incoming frame contained data.		*/
 #define FLAG_WIN_UPDATE		0x02 /* Incoming ACK was a window update.	*/
 #define FLAG_DATA_ACKED		0x04 /* This ACK acknowledged new data.		*/
@@ -139,8 +141,8 @@ static void tcp_measure_rcv_mss(struct sock *sk, const struct sk_buff *skb)
 	 * sends good full-sized frames.
 	 */
 	len = skb_shinfo(skb)->gso_size ? : skb->len;
-	if (len >= icsk->icsk_ack.rcv_mss) {
-		icsk->icsk_ack.rcv_mss = len;
+	if (len >= inet_csk_get_rcv_mss(sk)) {
+		inet_csk_set_rcv_mss(sk, len);
 	} else {
 		/* Otherwise, we make more careful check taking into account,
 		 * that SACKs block is variable.
@@ -163,7 +165,7 @@ static void tcp_measure_rcv_mss(struct sock *sk, const struct sk_buff *skb)
 			len -= tcp_sk(sk)->tcp_header_len;
 			icsk->icsk_ack.last_seg_size = len;
 			if (len == lss) {
-				icsk->icsk_ack.rcv_mss = len;
+				inet_csk_set_rcv_mss(sk, len);
 				return;
 			}
 		}
@@ -176,7 +178,8 @@ static void tcp_measure_rcv_mss(struct sock *sk, const struct sk_buff *skb)
 static void tcp_incr_quickack(struct sock *sk)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
-	unsigned int quickacks = tcp_sk(sk)->rcv_wnd / (2 * icsk->icsk_ack.rcv_mss);
+	unsigned int quickacks;
+	quickacks = tcp_sk(sk)->rcv_wnd / (2 * inet_csk_get_rcv_mss(sk));
 
 	if (quickacks == 0)
 		quickacks = 2;
@@ -310,7 +313,7 @@ static int __tcp_grow_window(const struct sock *sk, const struct sk_buff *skb)
 
 	while (tp->rcv_ssthresh <= window) {
 		if (truesize <= skb->len)
-			return 2 * inet_csk(sk)->icsk_ack.rcv_mss;
+			return 2 * inet_csk_get_rcv_mss(sk);
 
 		truesize >>= 1;
 		window >>= 1;
@@ -440,7 +443,7 @@ void tcp_initialize_rcv_mss(struct sock *sk)
 	hint = min(hint, TCP_MSS_DEFAULT);
 	hint = max(hint, TCP_MIN_MSS);
 
-	inet_csk(sk)->icsk_ack.rcv_mss = hint;
+	inet_csk_set_rcv_mss(sk, hint);
 }
 EXPORT_SYMBOL(tcp_initialize_rcv_mss);
 
@@ -510,7 +513,7 @@ static inline void tcp_rcv_rtt_measure_ts(struct sock *sk,
 	struct tcp_sock *tp = tcp_sk(sk);
 	if (tp->rx_opt.rcv_tsecr &&
 	    (TCP_SKB_CB(skb)->end_seq -
-	     TCP_SKB_CB(skb)->seq >= inet_csk(sk)->icsk_ack.rcv_mss))
+	     TCP_SKB_CB(skb)->seq >= inet_csk_get_rcv_mss(sk)))
 		tcp_rcv_rtt_update(tp, tcp_time_stamp - tp->rx_opt.rcv_tsecr, 0);
 }
 
@@ -5206,8 +5209,8 @@ static void __tcp_ack_snd_check(struct sock *sk, int ofo_possible)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	    /* More than one full frame received... */
-	if (((tp->rcv_nxt - tp->rcv_wup) > inet_csk(sk)->icsk_ack.rcv_mss &&
+	/* More than tcp_delack_segs full frame(s) received... */
+	if (((tp->rcv_nxt - tp->rcv_wup) > inet_csk_delack_thresh(sk) &&
 	     /* ... and right edge of window advances far enough.
 	      * (tcp_recvmsg() will send ACK otherwise). Or...
 	      */
@@ -5909,7 +5912,8 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 			icsk->icsk_ack.lrcvtime = tcp_time_stamp;
 			tcp_enter_quickack_mode(sk);
 			inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
-						  TCP_DELACK_MAX, TCP_RTO_MAX);
+						  icsk->icsk_ack.tcp_delack_max,
+						  TCP_RTO_MAX);
 
 discard:
 			__kfree_skb(skb);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 803cbfe..25f4e45 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -65,6 +65,11 @@ int sysctl_tcp_slow_start_after_idle __read_mostly = 1;
 int sysctl_tcp_cookie_size __read_mostly = 0; /* TCP_COOKIE_MAX */
 EXPORT_SYMBOL_GPL(sysctl_tcp_cookie_size);
 
+int sysctl_tcp_default_delack_min __read_mostly = TCP_DELACK_MIN_DEFAULT;
+EXPORT_SYMBOL(sysctl_tcp_default_delack_min);
+
+int sysctl_tcp_default_delack_max __read_mostly = TCP_DELACK_MAX_DEFAULT;
+EXPORT_SYMBOL(sysctl_tcp_default_delack_max);
 
 /* Account for new data that has been sent to the network. */
 static void tcp_event_new_data_sent(struct sock *sk, const struct sk_buff *skb)
@@ -1927,7 +1932,7 @@ u32 __tcp_select_window(struct sock *sk)
 	 * but may be worse for the performance because of rcv_mss
 	 * fluctuations.  --SAW  1998/11/1
 	 */
-	int mss = icsk->icsk_ack.rcv_mss;
+	int mss = inet_csk_get_rcv_mss(sk);
 	int free_space = tcp_space(sk);
 	int full_space = min_t(int, tp->window_clamp, tcp_full_space(sk));
 	int window;
@@ -2699,14 +2704,14 @@ void tcp_send_delayed_ack(struct sock *sk)
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	int ato = icsk->icsk_ack.ato;
 	unsigned long timeout;
+	const struct tcp_sock *tp = tcp_sk(sk);
 
-	if (ato > TCP_DELACK_MIN) {
-		const struct tcp_sock *tp = tcp_sk(sk);
+	if (ato > icsk->icsk_ack.tcp_delack_min) {
 		int max_ato = HZ / 2;
 
 		if (icsk->icsk_ack.pingpong ||
 		    (icsk->icsk_ack.pending & ICSK_ACK_PUSHED))
-			max_ato = TCP_DELACK_MAX;
+			max_ato = icsk->icsk_ack.tcp_delack_max;
 
 		/* Slow path, intersegment interval is "high". */
 
@@ -2715,7 +2720,8 @@ void tcp_send_delayed_ack(struct sock *sk)
 		 * directly.
 		 */
 		if (tp->srtt) {
-			int rtt = max(tp->srtt >> 3, TCP_DELACK_MIN);
+			int rtt = max_t(unsigned, tp->srtt >> 3,
+					icsk->icsk_ack.tcp_delack_min);
 
 			if (rtt < max_ato)
 				max_ato = rtt;
@@ -2750,6 +2756,7 @@ void tcp_send_delayed_ack(struct sock *sk)
 void tcp_send_ack(struct sock *sk)
 {
 	struct sk_buff *buff;
+	struct inet_connection_sock *icsk = inet_csk(sk);
 
 	/* If we have been reset, we may not send again. */
 	if (sk->sk_state == TCP_CLOSE)
@@ -2762,9 +2769,10 @@ void tcp_send_ack(struct sock *sk)
 	buff = alloc_skb(MAX_TCP_HEADER, GFP_ATOMIC);
 	if (buff == NULL) {
 		inet_csk_schedule_ack(sk);
-		inet_csk(sk)->icsk_ack.ato = TCP_ATO_MIN;
+		icsk->icsk_ack.ato = TCP_ATO_MIN;
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
-					  TCP_DELACK_MAX, TCP_RTO_MAX);
+					  icsk->icsk_ack.tcp_delack_max,
+					  TCP_RTO_MAX);
 		return;
 	}
 
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index e911e6c..4bd85fd 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -216,7 +216,8 @@ static void tcp_delack_timer(unsigned long data)
 		/* Try again later. */
 		icsk->icsk_ack.blocked = 1;
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_DELAYEDACKLOCKED);
-		sk_reset_timer(sk, &icsk->icsk_delack_timer, jiffies + TCP_DELACK_MIN);
+		sk_reset_timer(sk, &icsk->icsk_delack_timer,
+			       jiffies + icsk->icsk_ack.tcp_delack_min);
 		goto out_unlock;
 	}
 
-- 
1.7.7.6
