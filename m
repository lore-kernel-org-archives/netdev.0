From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: [RFC] tcp: Export TCP Delayed ACK parameters to user
Date: Fri, 28 Oct 2011 02:07:21 +0300
Message-ID: <1319756841-2051-1-git-send-email-dbaluta@ixiacom.com>
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org, eric.dumazet@gmail.com,
	Daniel Baluta <dbaluta@ixiacom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:49425 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751459Ab1J0XIB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 19:08:01 -0400
Received: by faan17 with SMTP id n17so3140292faa.19
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2011 16:08:00 -0700 (PDT)
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
 include/net/tcp.h          |   20 +++++++++++++++++---
 net/ipv4/sysctl_net_ipv4.c |   21 +++++++++++++++++++++
 net/ipv4/tcp.c             |    5 +++--
 net/ipv4/tcp_input.c       |    7 +++++--
 net/ipv4/tcp_output.c      |    4 +++-
 5 files changed, 49 insertions(+), 8 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index e147f42..f3b0c17 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -111,14 +111,21 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
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
+#define TCP_DELACK_MIN sysctl_tcp_delack_min
+#define TCP_DELACK_MAX sysctl_tcp_delack_max
+
 #define TCP_RTO_MAX	((unsigned)(120*HZ))
 #define TCP_RTO_MIN	((unsigned)(HZ/5))
 #define TCP_TIMEOUT_INIT ((unsigned)(1*HZ))	/* RFC2988bis initial RTO value	*/
@@ -251,6 +258,9 @@ extern int sysctl_tcp_max_ssthresh;
 extern int sysctl_tcp_cookie_size;
 extern int sysctl_tcp_thin_linear_timeouts;
 extern int sysctl_tcp_thin_dupack;
+extern int sysctl_tcp_delack_segs;
+extern int sysctl_tcp_delack_min;
+extern int sysctl_tcp_delack_max;
 
 extern atomic_long_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
@@ -1557,6 +1567,10 @@ static inline struct tcp_extend_values *tcp_xv(struct request_values *rvp)
 {
 	return (struct tcp_extend_values *)rvp;
 }
+static inline int tcp_snd_thresh(struct sock *sk)
+{
+	return inet_csk(sk)->icsk_ack.rcv_mss * sysctl_tcp_delack_segs;
+}
 
 extern void tcp_v4_init(void);
 extern void tcp_init(void);
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
index 34f5db1..0aad29b 100644
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
+		    tp->rcv_nxt - tp->rcv_wup > tcp_snd_thresh(sk) ||
 		    /*
 		     * If this read emptied read buffer, we send ACK, if
 		     * connection is not bidirectional, user drained
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 52b5c2d..1e02a80 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -98,6 +98,9 @@ int sysctl_tcp_thin_dupack __read_mostly;
 int sysctl_tcp_moderate_rcvbuf __read_mostly = 1;
 int sysctl_tcp_abc __read_mostly;
 
+int sysctl_tcp_delack_segs __read_mostly = 1;
+
+
 #define FLAG_DATA		0x01 /* Incoming frame contained data.		*/
 #define FLAG_WIN_UPDATE		0x02 /* Incoming ACK was a window update.	*/
 #define FLAG_DATA_ACKED		0x04 /* This ACK acknowledged new data.		*/
@@ -4993,8 +4996,8 @@ static void __tcp_ack_snd_check(struct sock *sk, int ofo_possible)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	    /* More than one full frame received... */
-	if (((tp->rcv_nxt - tp->rcv_wup) > inet_csk(sk)->icsk_ack.rcv_mss &&
+	    /* More than tcp_delack_segs full frame(s) received... */
+	if (((tp->rcv_nxt - tp->rcv_wup) > tcp_snd_thresh(sk) &&
 	     /* ... and right edge of window advances far enough.
 	      * (tcp_recvmsg() will send ACK otherwise). Or...
 	      */
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 980b98f..0ec31af 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -63,6 +63,8 @@ int sysctl_tcp_slow_start_after_idle __read_mostly = 1;
 int sysctl_tcp_cookie_size __read_mostly = 0; /* TCP_COOKIE_MAX */
 EXPORT_SYMBOL_GPL(sysctl_tcp_cookie_size);
 
+int sysctl_tcp_delack_min __read_mostly = TCP_DELACK_MIN_DEFAULT;
+int sysctl_tcp_delack_max __read_mostly = TCP_DELACK_MAX_DEFAULT;
 
 /* Account for new data that has been sent to the network. */
 static void tcp_event_new_data_sent(struct sock *sk, const struct sk_buff *skb)
@@ -2685,7 +2687,7 @@ void tcp_send_delayed_ack(struct sock *sk)
 		 * directly.
 		 */
 		if (tp->srtt) {
-			int rtt = max(tp->srtt >> 3, TCP_DELACK_MIN);
+			int rtt = max_t(unsigned, tp->srtt >> 3, TCP_DELACK_MIN);
 
 			if (rtt < max_ato)
 				max_ato = rtt;
-- 
1.7.2.5
