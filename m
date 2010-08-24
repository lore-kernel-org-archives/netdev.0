From: "H.K. Jerry Chu" <hkchu@google.com>
Subject: [PATCH] TCP_FAILFAST: a new socket option to timeout/abort a connection quicker
Date: Mon, 23 Aug 2010 23:20:19 -0700
Message-ID: <1282630819-23104-1-git-send-email-hkchu@google.com>
Cc: netdev@vger.kernel.org, Jerry Chu <hkchu@google.com>
To: ilpo.jarvinen@helsinki.fi, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:48501 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752871Ab0HXGVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 02:21:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jerry Chu <hkchu@google.com>

This is a TCP level socket option that takes an unsigned int to specify
how long in ms TCP should resend a lost data packet before giving up
and returning ETIMEDOUT. The normal TCP retry/abort timeout limit still
applies. In other words this option is only meant for those applications
that need to "fail faster" than the default TCP timeout. The latter
may take upto 20 minutes in a normal WAN environment.

The option is disabled (by default) when set to 0. Also it does not
apply during the connection establishment phase.

Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
---
 include/linux/tcp.h                |    1 +
 include/net/inet_connection_sock.h |    1 +
 net/ipv4/tcp.c                     |   11 ++++++++-
 net/ipv4/tcp_timer.c               |   42 +++++++++++++++++++++++++++++++----
 4 files changed, 49 insertions(+), 6 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index a778ee0..60b7244 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -105,6 +105,7 @@ enum {
 #define TCP_COOKIE_TRANSACTIONS	15	/* TCP Cookie Transactions */
 #define TCP_THIN_LINEAR_TIMEOUTS 16      /* Use linear timeouts for thin streams*/
 #define TCP_THIN_DUPACK         17      /* Fast retrans. after 1 dupack */
+#define TCP_FAILFAST		18	/* Abort connection in loss retry sooner*/
 
 /* for TCP_INFO socket option */
 #define TCPI_OPT_TIMESTAMPS	1
diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index b6d3b55..6553921 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -125,6 +125,7 @@ struct inet_connection_sock {
 		int		  probe_size;
 	} icsk_mtup;
 	u32			  icsk_ca_priv[16];
+	u32			  icsk_max_timeout;
 #define ICSK_CA_PRIV_SIZE	(16 * sizeof(u32))
 };
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 176e11a..ddb548a 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2391,7 +2391,12 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		err = tp->af_specific->md5_parse(sk, optval, optlen);
 		break;
 #endif
-
+	case TCP_FAILFAST:
+		/* Cap the max timeout in ms TCP will retry/retrans
+		 * before giving up and aborting (ETIMEDOUT) a connection.
+		 */
+		icsk->icsk_max_timeout = msecs_to_jiffies(val);
+		break;
 	default:
 		err = -ENOPROTOOPT;
 		break;
@@ -2610,6 +2615,10 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 	case TCP_THIN_DUPACK:
 		val = tp->thin_dupack;
 		break;
+
+	case TCP_FAILFAST:
+		val = jiffies_to_msecs(icsk->icsk_max_timeout);
+		break;
 	default:
 		return -ENOPROTOOPT;
 	}
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 808bb92..95c2548 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -138,7 +138,8 @@ static void tcp_mtu_probing(struct inet_connection_sock *icsk, struct sock *sk)
  * retransmissions with an initial RTO of TCP_RTO_MIN.
  */
 static bool retransmits_timed_out(struct sock *sk,
-				  unsigned int boundary)
+				  unsigned int boundary,
+				  unsigned int max_timeout)
 {
 	unsigned int timeout, linear_backoff_thresh;
 	unsigned int start_ts;
@@ -159,6 +160,9 @@ static bool retransmits_timed_out(struct sock *sk,
 		timeout = ((2 << linear_backoff_thresh) - 1) * TCP_RTO_MIN +
 			  (boundary - linear_backoff_thresh) * TCP_RTO_MAX;
 
+	if (max_timeout != 0 && timeout > max_timeout)
+		timeout = max_timeout;
+
 	return (tcp_time_stamp - start_ts) >= timeout;
 }
 
@@ -174,7 +178,7 @@ static int tcp_write_timeout(struct sock *sk)
 			dst_negative_advice(sk);
 		retry_until = icsk->icsk_syn_retries ? : sysctl_tcp_syn_retries;
 	} else {
-		if (retransmits_timed_out(sk, sysctl_tcp_retries1)) {
+		if (retransmits_timed_out(sk, sysctl_tcp_retries1, 0)) {
 			/* Black hole detection */
 			tcp_mtu_probing(icsk, sk);
 
@@ -187,14 +191,16 @@ static int tcp_write_timeout(struct sock *sk)
 
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
+	    icsk->icsk_max_timeout)) {
 		/* Has it gone just too far? */
 		tcp_write_err(sk);
 		return 1;
@@ -434,9 +440,35 @@ out_reset_timer:
 	} else {
 		/* Use normal (exponential) backoff */
 		icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
+		if (icsk->icsk_max_timeout &&
+		    ((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV)) == 0) {
+			int ts;
+			unsigned int base_rto =
+			    min(__tcp_set_rto(tp), TCP_RTO_MAX);
+
+			if (unlikely(!tp->retrans_stamp))
+				ts = (int)TCP_SKB_CB(tcp_write_queue_head(sk))->when;
+			else
+				ts = (int)tp->retrans_stamp;
+			ts = icsk->icsk_max_timeout - (tcp_time_stamp - ts) -
+				base_rto-1;
+			/*
+			 * Adjust rto so that the total timeout is not far off
+			 * the max_timeout range. Also if the total # of
+			 * retries would be less than 6, allow one more shot.
+			 */
+			if (icsk->icsk_rto > ts && icsk->icsk_retransmits < 6)
+				icsk->icsk_rto >>= 1;
+			if ((int)(icsk->icsk_rto) > ts) {
+				if (ts < (int)base_rto)
+					icsk->icsk_rto = base_rto;
+				else
+					icsk->icsk_rto = ts;
+			}
+		}
 	}
 	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto, TCP_RTO_MAX);
-	if (retransmits_timed_out(sk, sysctl_tcp_retries1 + 1))
+	if (retransmits_timed_out(sk, sysctl_tcp_retries1 + 1, 0))
 		__sk_dst_reset(sk);
 
 out:;
-- 
1.7.1

