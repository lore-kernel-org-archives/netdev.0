From: "H.K. Jerry Chu" <hkchu@google.com>
Subject: [PATCH] TCP_USER_TIMEOUT: a new socket option to specify max timeout before a TCP connection is aborted
Date: Fri, 27 Aug 2010 22:13:28 -0700
Message-ID: <1282972408-19164-1-git-send-email-hkchu@google.com>
Cc: netdev@vger.kernel.org, Jerry Chu <hkchu@google.com>
To: eric.dumazet@gmail.com, hannemann@nets.rwth-aachen.de,
	hagen@jauu.net, lars.eggert@nokia.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:61925 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733Ab0H1FOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Aug 2010 01:14:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jerry Chu <hkchu@google.com>

This patch provides a "user timeout" support as described in RFC793. The
socket option is also needed for the the local half of RFC5482 "TCP User
Timeout Option".

TCP_USER_TIMEOUT is a TCP level socket option that takes an unsigned int,
when > 0, to specify the maximum amount of time in ms that transmitted
data may remain unacknowledged before TCP will forcefully close the
corresponding connection and return ETIMEDOUT to the application. If
0 is given, TCP will continue to use the system default.

Increasing the user timeouts allows a TCP connection to survive extended
periods without end-to-end connectivity. Decreasing the user timeouts
allows applications to "fail fast" if so desired. Otherwise it may take
upto 20 minutes with the current system defaults in a normal WAN
environment.

The socket option can be made during any state of a TCP connection, but
is only effective during the synchronized states of a connection
(ESTABLISHED, FIN-WAIT-1, FIN-WAIT-2, CLOSE-WAIT, CLOSING, or LAST-ACK).
Moreover, when used with the TCP keepalive (SO_KEEPALIVE) option,
TCP_USER_TIMEOUT will overtake keepalive to determine when to close a
connection due to keepalive failure.

The option does not change in anyway when TCP retransmits a packet, nor
when a keepalive probe will be sent.

This option, like many others, will be inherited by an acceptor from its
listener.

Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
---
 include/linux/tcp.h                |    1 +
 include/net/inet_connection_sock.h |    1 +
 net/ipv4/tcp.c                     |   11 +++++++++-
 net/ipv4/tcp_timer.c               |   40 ++++++++++++++++++++++-------------
 4 files changed, 37 insertions(+), 16 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index a778ee0..e64f4c6 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -105,6 +105,7 @@ enum {
 #define TCP_COOKIE_TRANSACTIONS	15	/* TCP Cookie Transactions */
 #define TCP_THIN_LINEAR_TIMEOUTS 16      /* Use linear timeouts for thin streams*/
 #define TCP_THIN_DUPACK         17      /* Fast retrans. after 1 dupack */
+#define TCP_USER_TIMEOUT	18	/* How long for loss retry before timeout */
 
 /* for TCP_INFO socket option */
 #define TCPI_OPT_TIMESTAMPS	1
diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index b6d3b55..e4f494b 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -125,6 +125,7 @@ struct inet_connection_sock {
 		int		  probe_size;
 	} icsk_mtup;
 	u32			  icsk_ca_priv[16];
+	u32			  icsk_user_timeout;
 #define ICSK_CA_PRIV_SIZE	(16 * sizeof(u32))
 };
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 176e11a..cf32545 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2391,7 +2391,12 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		err = tp->af_specific->md5_parse(sk, optval, optlen);
 		break;
 #endif
-
+	case TCP_USER_TIMEOUT:
+		/* Cap the max timeout in ms TCP will retry/retrans
+		 * before giving up and aborting (ETIMEDOUT) a connection.
+		 */
+		icsk->icsk_user_timeout = msecs_to_jiffies(val);
+		break;
 	default:
 		err = -ENOPROTOOPT;
 		break;
@@ -2610,6 +2615,10 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 	case TCP_THIN_DUPACK:
 		val = tp->thin_dupack;
 		break;
+
+	case TCP_USER_TIMEOUT:
+		val = jiffies_to_msecs(icsk->icsk_user_timeout);
+		break;
 	default:
 		return -ENOPROTOOPT;
 	}
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 808bb92..11569de 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -138,10 +138,10 @@ static void tcp_mtu_probing(struct inet_connection_sock *icsk, struct sock *sk)
  * retransmissions with an initial RTO of TCP_RTO_MIN.
  */
 static bool retransmits_timed_out(struct sock *sk,
-				  unsigned int boundary)
+				  unsigned int boundary,
+				  unsigned int timeout)
 {
-	unsigned int timeout, linear_backoff_thresh;
-	unsigned int start_ts;
+	unsigned int linear_backoff_thresh, start_ts;
 
 	if (!inet_csk(sk)->icsk_retransmits)
 		return false;
@@ -151,14 +151,15 @@ static bool retransmits_timed_out(struct sock *sk,
 	else
 		start_ts = tcp_sk(sk)->retrans_stamp;
 
-	linear_backoff_thresh = ilog2(TCP_RTO_MAX/TCP_RTO_MIN);
-
-	if (boundary <= linear_backoff_thresh)
-		timeout = ((2 << boundary) - 1) * TCP_RTO_MIN;
-	else
-		timeout = ((2 << linear_backoff_thresh) - 1) * TCP_RTO_MIN +
-			  (boundary - linear_backoff_thresh) * TCP_RTO_MAX;
+	if (likely(timeout == 0)) {
+		linear_backoff_thresh = ilog2(TCP_RTO_MAX/TCP_RTO_MIN);
 
+		if (boundary <= linear_backoff_thresh)
+			timeout = ((2 << boundary) - 1) * TCP_RTO_MIN;
+		else
+			timeout = ((2 << linear_backoff_thresh) - 1) * TCP_RTO_MIN +
+				(boundary - linear_backoff_thresh) * TCP_RTO_MAX;
+	}
 	return (tcp_time_stamp - start_ts) >= timeout;
 }
 
@@ -174,7 +175,7 @@ static int tcp_write_timeout(struct sock *sk)
 			dst_negative_advice(sk);
 		retry_until = icsk->icsk_syn_retries ? : sysctl_tcp_syn_retries;
 	} else {
-		if (retransmits_timed_out(sk, sysctl_tcp_retries1)) {
+		if (retransmits_timed_out(sk, sysctl_tcp_retries1, 0)) {
 			/* Black hole detection */
 			tcp_mtu_probing(icsk, sk);
 
@@ -187,14 +188,16 @@ static int tcp_write_timeout(struct sock *sk)
 
 			retry_until = tcp_orphan_retries(sk, alive);
 			do_reset = alive ||
-				   !retransmits_timed_out(sk, retry_until);
+				   !retransmits_timed_out(sk, retry_until, 0);
 
 			if (tcp_out_of_resources(sk, do_reset))
 				return 1;
 		}
 	}
 
-	if (retransmits_timed_out(sk, retry_until)) {
+	if (retransmits_timed_out(sk, retry_until,
+	    (1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV) ? 0 :
+	    icsk->icsk_user_timeout)) {
 		/* Has it gone just too far? */
 		tcp_write_err(sk);
 		return 1;
@@ -436,7 +439,7 @@ out_reset_timer:
 		icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
 	}
 	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto, TCP_RTO_MAX);
-	if (retransmits_timed_out(sk, sysctl_tcp_retries1 + 1))
+	if (retransmits_timed_out(sk, sysctl_tcp_retries1 + 1, 0))
 		__sk_dst_reset(sk);
 
 out:;
@@ -556,7 +559,14 @@ static void tcp_keepalive_timer (unsigned long data)
 	elapsed = keepalive_time_elapsed(tp);
 
 	if (elapsed >= keepalive_time_when(tp)) {
-		if (icsk->icsk_probes_out >= keepalive_probes(tp)) {
+		/* If the TCP_USER_TIMEOUT option is enabled, use that
+		 * to determine when to timeout instead.
+		 */
+		if ((icsk->icsk_user_timeout != 0 &&
+		    elapsed >= icsk->icsk_user_timeout &&
+		    icsk->icsk_probes_out > 0) ||
+		    (icsk->icsk_user_timeout == 0 &&
+		    icsk->icsk_probes_out >= keepalive_probes(tp))) {
 			tcp_send_active_reset(sk, GFP_ATOMIC);
 			tcp_write_err(sk);
 			goto out;
-- 
1.7.1

