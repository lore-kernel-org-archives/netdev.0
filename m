From: Salvador Fandino <salvador@qindel.com>
Subject: [PATCH] allow to configure tcp_retries1 and tcp_retries2 per TCP
 socket
Date: Thu, 10 Jun 2010 18:09:21 +0200
Message-ID: <1276186161.2419.10.camel@topo>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"; linux-kernel"@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.qindel.com ([62.97.67.18]:42180 "EHLO thor.int.qindel.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750989Ab0FJQSP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jun 2010 12:18:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The included patch adds support for setting the tcp_retries1 and
tcp_retries2 options in a per socket fashion as it is done for the
keepalive options TCP_KEEPIDLE, TCP_KEEPCNT and TCP_KEEPINTVL.

The issue I am trying to solve is that when a socket has data queued for
delivering, the keepalive logic is not triggered. Instead, the
tcp_retries1/2 parameters are used to determine how many delivering
attempts should be performed before giving up.

The patch is very straight forward and just replicates similar
functionality. There is one thing I am not completely sure and is if the
new per-socket fields should go into inet_connection_sock instead of
into tcp_sock.

Regards

Signed-off-by: Salvador Fandino <salvador@qindel.com>



diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index a778ee0..15ca599 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -105,6 +105,8 @@ enum {
 #define TCP_COOKIE_TRANSACTIONS	15	/* TCP Cookie Transactions */
 #define TCP_THIN_LINEAR_TIMEOUTS 16      /* Use linear timeouts for thin streams*/
 #define TCP_THIN_DUPACK         17      /* Fast retrans. after 1 dupack */
+#define TCP_RETRIES1		18	/* Number of attempts to retransmit packet normally */
+#define TCP_RETRIES2		19	/* Number of attempts to retransmit packet */
 
 /* for TCP_INFO socket option */
 #define TCPI_OPT_TIMESTAMPS	1
@@ -424,6 +426,9 @@ struct tcp_sock {
 	unsigned int		keepalive_time;	  /* time before keep alive takes place */
 	unsigned int		keepalive_intvl;  /* time interval between keep alive probes */
 
+        int    	retries1;  	/* number of attempts to retransmit packed normally */
+        int    	retries2;  	/* number of attempts to retransmit packed */
+
 	int			linger2;
 
 /* Receiver side RTT estimation */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index a144914..6d13c97 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -138,6 +138,8 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define MAX_TCP_KEEPIDLE	32767
 #define MAX_TCP_KEEPINTVL	32767
 #define MAX_TCP_KEEPCNT		127
+#define MAX_TCP_RETRIES1	255
+#define MAX_TCP_RETRIES2	32767
 #define MAX_TCP_SYNCNT		127
 
 #define TCP_SYNQ_INTERVAL	(HZ/5)	/* Period of SYNACK timer */
@@ -1041,6 +1043,16 @@ static inline u32 keepalive_time_elapsed(const struct tcp_sock *tp)
 			  tcp_time_stamp - tp->rcv_tstamp);
 }
 
+static inline int tcp_retries1_when(const struct tcp_sock *tp)
+{
+        return tp->retries1 ? : sysctl_tcp_retries1;
+}
+
+static inline int tcp_retries2_when(const struct tcp_sock *tp)
+{
+        return tp->retries2 ? : sysctl_tcp_retries2;
+}
+
 static inline int tcp_fin_time(const struct sock *sk)
 {
 	int fin_timeout = tcp_sk(sk)->linger2 ? : sysctl_tcp_fin_timeout;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index d96c1da..d4f6c4a 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -23,7 +23,7 @@
 #include <net/inet_frag.h>
 
 static int zero;
-static int tcp_retr1_max = 255;
+static int tcp_retr1_max = MAX_TCP_RETRIES1;
 static int ip_local_port_range_min[] = { 1, 1 };
 static int ip_local_port_range_max[] = { 65535, 65535 };
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 6596b4f..1fb25d5 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2319,6 +2319,18 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		else
 			tp->keepalive_probes = val;
 		break;
+        case TCP_RETRIES1:
+                if (val < 1 || val > MAX_TCP_RETRIES1)
+                        err = -EINVAL;
+                else
+                        tp->retries1 = val;
+                break;
+        case TCP_RETRIES2:
+                if (val < 1 || val > MAX_TCP_RETRIES2)
+                        err = -EINVAL;
+                else
+                        tp->retries2 = val;
+                break;
 	case TCP_SYNCNT:
 		if (val < 1 || val > MAX_TCP_SYNCNT)
 			err = -EINVAL;
@@ -2511,6 +2523,12 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 	case TCP_KEEPCNT:
 		val = keepalive_probes(tp);
 		break;
+        case TCP_RETRIES1:
+                val = tcp_retries1_when(tp);
+                break;
+        case TCP_RETRIES2:
+                val = tcp_retries2_when(tp);
+                break;
 	case TCP_SYNCNT:
 		val = icsk->icsk_syn_retries ? : sysctl_tcp_syn_retries;
 		break;
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 440a5c6..26db67b 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -167,6 +167,7 @@ static bool retransmits_timed_out(struct sock *sk,
 static int tcp_write_timeout(struct sock *sk)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	int retry_until;
 	bool do_reset;
 
@@ -175,14 +176,14 @@ static int tcp_write_timeout(struct sock *sk)
 			dst_negative_advice(sk);
 		retry_until = icsk->icsk_syn_retries ? : sysctl_tcp_syn_retries;
 	} else {
-		if (retransmits_timed_out(sk, sysctl_tcp_retries1)) {
+		if (retransmits_timed_out(sk, tcp_retries1_when(tp))) {
 			/* Black hole detection */
 			tcp_mtu_probing(icsk, sk);
 
 			dst_negative_advice(sk);
 		}
 
-		retry_until = sysctl_tcp_retries2;
+		retry_until = tcp_retries2_when(tp);
 		if (sock_flag(sk, SOCK_DEAD)) {
 			const int alive = (icsk->icsk_rto < TCP_RTO_MAX);
 
@@ -290,7 +291,7 @@ static void tcp_probe_timer(struct sock *sk)
 	 * with RFCs, only probe timer combines both retransmission timeout
 	 * and probe timeout in one bottle.				--ANK
 	 */
-	max_probes = sysctl_tcp_retries2;
+	max_probes = tcp_retries2_when(tp);
 
 	if (sock_flag(sk, SOCK_DEAD)) {
 		const int alive = ((icsk->icsk_rto << icsk->icsk_backoff) < TCP_RTO_MAX);
@@ -437,7 +438,7 @@ out_reset_timer:
 		icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
 	}
 	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto, TCP_RTO_MAX);
-	if (retransmits_timed_out(sk, sysctl_tcp_retries1 + 1))
+	if (retransmits_timed_out(sk, tcp_retries1_when(tp) + 1))
 		__sk_dst_reset(sk);
 
 out:;


