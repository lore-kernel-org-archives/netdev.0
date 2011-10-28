From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: [RFC v2] tcp: Export TCP Delayed ACK parameters to user
Date: Sat, 29 Oct 2011 00:14:03 +0300
Message-ID: <1319836443-4419-1-git-send-email-dbaluta@ixiacom.com>
References: <1319756841-2051-1-git-send-email-dbaluta@ixiacom.com>
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org, luto@amacapital.net,
	rick.jones2@hp.com, Daniel Baluta <dbaluta@ixiacom.com>
To: davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:37537 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752635Ab1J1VO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2011 17:14:27 -0400
Received: by bkbzt4 with SMTP id zt4so790951bkb.19
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2011 14:14:25 -0700 (PDT)
In-Reply-To: <1319756841-2051-1-git-send-email-dbaluta@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC2581 ($4.2) specifies when an ACK should be generated as follows:

" .. an ACK SHOULD be generated for at least every second
  full-sized segment, and MUST be generated within 500 ms
  of the arrival of the first unacknowledged packet.
"

We export the number of segments and the timeout limits
specified above, so that a user can tune them according
to its needs.

Specifically:
	* /proc/sys/net/ipv4/tcp_delack_segs, represents
	the threshold for the number of segments.
	* /proc/sys/net/ipv4/tcp_delack_min, specifies
	the minimum timeout value
	* /proc/sys/net/ipv4/tcp_delack_max, specifies
	the maximum timeout value.

Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>
---
Changes since v1:
	* added documentation for newly introduced /proc entries.
	* exported symbols sysctl_tcp_delack_{min|max}.
	* removed TCP_DELACK_{MIN|MAX} and used directly 
	sysctl_tcp_delack{min|max}.
	* renamed tcp_snd_thresh to tcp_delack_thresh.
	* added const qualifier to struct sock *sk.
---
 Documentation/networking/ip-sysctl.txt |   13 +++++++++++++
 include/net/tcp.h                      |   18 +++++++++++++++---
 net/dccp/output.c                      |    2 +-
 net/dccp/timer.c                       |    2 +-
 net/ipv4/sysctl_net_ipv4.c             |   21 +++++++++++++++++++++
 net/ipv4/tcp.c                         |    5 +++--
 net/ipv4/tcp_input.c                   |    8 +++++---
 net/ipv4/tcp_output.c                  |   13 +++++++++----
 net/ipv4/tcp_timer.c                   |    3 ++-
 9 files changed, 70 insertions(+), 15 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index cb7f314..efbd1b4 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -524,6 +524,19 @@ tcp_thin_dupack - BOOLEAN
 	Documentation/networking/tcp-thin.txt
 	Default: 0
 
+tcp_delack_segs: - INTEGER
+	Sets the strict minimal number of full-sized TCP segments
+	received after which an ACK should be sent.
+	Default: 1 (as specified in RFC2582, S4.2)
+
+tcp_delack_min:	- INTEGER
+	Sets the minimum time (in miliseconds) to delay before sending an ACK.
+	Default: 40ms
+
+tcp_delack_max: - INTEGER
+	Sets the maximum time (in miliseconds) to delay before sending an ACK.
+	Default: 200ms
+
 UDP variables:
 
 udp_mem - vector of 3 INTEGERs: min, pressure, max
diff --git a/include/net/tcp.h b/include/net/tcp.h
index e147f42..9e29a9d 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -111,14 +111,18 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
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
 #define TCP_TIMEOUT_INIT ((unsigned)(1*HZ))	/* RFC2988bis initial RTO value	*/
@@ -251,6 +255,9 @@ extern int sysctl_tcp_max_ssthresh;
 extern int sysctl_tcp_cookie_size;
 extern int sysctl_tcp_thin_linear_timeouts;
 extern int sysctl_tcp_thin_dupack;
+extern int sysctl_tcp_delack_segs;
+extern int sysctl_tcp_delack_min;
+extern int sysctl_tcp_delack_max;
 
 extern atomic_long_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
@@ -1558,6 +1565,11 @@ static inline struct tcp_extend_values *tcp_xv(struct request_values *rvp)
 	return (struct tcp_extend_values *)rvp;
 }
 
+static inline int tcp_delack_thresh(const struct sock *sk)
+{
+	return inet_csk(sk)->icsk_ack.rcv_mss * sysctl_tcp_delack_segs;
+}
+
 extern void tcp_v4_init(void);
 extern void tcp_init(void);
 
diff --git a/net/dccp/output.c b/net/dccp/output.c
index dede3ed..9b5b0c4 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -577,7 +577,7 @@ void dccp_send_ack(struct sock *sk)
 			inet_csk_schedule_ack(sk);
 			inet_csk(sk)->icsk_ack.ato = TCP_ATO_MIN;
 			inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
-						  TCP_DELACK_MAX,
+						  sysctl_tcp_delack_max,
 						  DCCP_RTO_MAX);
 			return;
 		}
diff --git a/net/dccp/timer.c b/net/dccp/timer.c
index 7587870..7bae11e 100644
--- a/net/dccp/timer.c
+++ b/net/dccp/timer.c
@@ -202,7 +202,7 @@ static void dccp_delack_timer(unsigned long data)
 		icsk->icsk_ack.blocked = 1;
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_DELAYEDACKLOCKED);
 		sk_reset_timer(sk, &icsk->icsk_delack_timer,
-			       jiffies + TCP_DELACK_MIN);
+			       jiffies + sysctl_tcp_delack_min);
 		goto out;
 	}
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 69fd720..c22c4c5 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -639,6 +639,27 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler   = proc_dointvec
 	},
 	{
+		.procname	= "tcp_delack_segs",
+		.data		= &sysctl_tcp_delack_segs,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
+		.procname	= "tcp_delack_min",
+		.data		= &sysctl_tcp_delack_min,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_ms_jiffies
+	},
+	{
+		.procname	= "tcp_delack_max",
+		.data		= &sysctl_tcp_delack_max,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_ms_jiffies
+	},
+	{
 		.procname	= "udp_mem",
 		.data		= &sysctl_udp_mem,
 		.maxlen		= sizeof(sysctl_udp_mem),
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 34f5db1..731e284 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1204,8 +1204,9 @@ void tcp_cleanup_rbuf(struct sock *sk, int copied)
 		   /* Delayed ACKs frequently hit locked sockets during bulk
 		    * receive. */
 		if (icsk->icsk_ack.blocked ||
-		    /* Once-per-two-segments ACK was not sent by tcp_input.c */
-		    tp->rcv_nxt - tp->rcv_wup > icsk->icsk_ack.rcv_mss ||
+		    /* More than once-per-tcp_delack_segs-segments ACK
+		     * was not sent by tcp_input.c */
+		    tp->rcv_nxt - tp->rcv_wup > tcp_delack_thresh(sk) ||
 		    /*
 		     * If this read emptied read buffer, we send ACK, if
 		     * connection is not bidirectional, user drained
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 52b5c2d..f2893a9 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -98,6 +98,8 @@ int sysctl_tcp_thin_dupack __read_mostly;
 int sysctl_tcp_moderate_rcvbuf __read_mostly = 1;
 int sysctl_tcp_abc __read_mostly;
 
+int sysctl_tcp_delack_segs __read_mostly = 1;
+
 #define FLAG_DATA		0x01 /* Incoming frame contained data.		*/
 #define FLAG_WIN_UPDATE		0x02 /* Incoming ACK was a window update.	*/
 #define FLAG_DATA_ACKED		0x04 /* This ACK acknowledged new data.		*/
@@ -4993,8 +4995,8 @@ static void __tcp_ack_snd_check(struct sock *sk, int ofo_possible)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	    /* More than one full frame received... */
-	if (((tp->rcv_nxt - tp->rcv_wup) > inet_csk(sk)->icsk_ack.rcv_mss &&
+	    /* More than tcp_delack_segs full frame(s) received... */
+	if (((tp->rcv_nxt - tp->rcv_wup) > tcp_delack_thresh(sk) &&
 	     /* ... and right edge of window advances far enough.
 	      * (tcp_recvmsg() will send ACK otherwise). Or...
 	      */
@@ -5689,7 +5691,7 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 			tcp_incr_quickack(sk);
 			tcp_enter_quickack_mode(sk);
 			inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
-						  TCP_DELACK_MAX, TCP_RTO_MAX);
+						  sysctl_tcp_delack_max, TCP_RTO_MAX);
 
 discard:
 			__kfree_skb(skb);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 980b98f..f4e7614 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -63,6 +63,11 @@ int sysctl_tcp_slow_start_after_idle __read_mostly = 1;
 int sysctl_tcp_cookie_size __read_mostly = 0; /* TCP_COOKIE_MAX */
 EXPORT_SYMBOL_GPL(sysctl_tcp_cookie_size);
 
+int sysctl_tcp_delack_min __read_mostly = TCP_DELACK_MIN_DEFAULT;
+EXPORT_SYMBOL(sysctl_tcp_delack_min);
+
+int sysctl_tcp_delack_max __read_mostly = TCP_DELACK_MAX_DEFAULT;
+EXPORT_SYMBOL(sysctl_tcp_delack_max);
 
 /* Account for new data that has been sent to the network. */
 static void tcp_event_new_data_sent(struct sock *sk, const struct sk_buff *skb)
@@ -2670,13 +2675,13 @@ void tcp_send_delayed_ack(struct sock *sk)
 	int ato = icsk->icsk_ack.ato;
 	unsigned long timeout;
 
-	if (ato > TCP_DELACK_MIN) {
+	if (ato > sysctl_tcp_delack_min) {
 		const struct tcp_sock *tp = tcp_sk(sk);
 		int max_ato = HZ / 2;
 
 		if (icsk->icsk_ack.pingpong ||
 		    (icsk->icsk_ack.pending & ICSK_ACK_PUSHED))
-			max_ato = TCP_DELACK_MAX;
+			max_ato = sysctl_tcp_delack_max;
 
 		/* Slow path, intersegment interval is "high". */
 
@@ -2685,7 +2690,7 @@ void tcp_send_delayed_ack(struct sock *sk)
 		 * directly.
 		 */
 		if (tp->srtt) {
-			int rtt = max(tp->srtt >> 3, TCP_DELACK_MIN);
+			int rtt = max_t(unsigned, tp->srtt >> 3, sysctl_tcp_delack_min);
 
 			if (rtt < max_ato)
 				max_ato = rtt;
@@ -2734,7 +2739,7 @@ void tcp_send_ack(struct sock *sk)
 		inet_csk_schedule_ack(sk);
 		inet_csk(sk)->icsk_ack.ato = TCP_ATO_MIN;
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
-					  TCP_DELACK_MAX, TCP_RTO_MAX);
+					  sysctl_tcp_delack_max, TCP_RTO_MAX);
 		return;
 	}
 
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 2e0f0af..1bdc1c4 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -219,7 +219,8 @@ static void tcp_delack_timer(unsigned long data)
 		/* Try again later. */
 		icsk->icsk_ack.blocked = 1;
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_DELAYEDACKLOCKED);
-		sk_reset_timer(sk, &icsk->icsk_delack_timer, jiffies + TCP_DELACK_MIN);
+		sk_reset_timer(sk, &icsk->icsk_delack_timer,
+			       jiffies + sysctl_tcp_delack_min);
 		goto out_unlock;
 	}
 
-- 
1.7.2.5
