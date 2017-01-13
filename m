From: Yuchung Cheng <ycheng@google.com>
Subject: [net-next 12/13] tcp: remove thin_dupack feature
Date: Thu, 12 Jan 2017 22:03:53 -0800
Message-ID: <20170113060354.85234-13-ycheng@google.com>
References: <20170113060354.85234-1-ycheng@google.com>
Cc: netdev@vger.kernel.org, edumazet@google.com, ncardwell@google.com,
        nanditad@google.com, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35455 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751146AbdAMGEm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 01:04:42 -0500
Received: by mail-pf0-f171.google.com with SMTP id f144so25782462pfa.2
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 22:04:42 -0800 (PST)
In-Reply-To: <20170113060354.85234-1-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thin stream DUPACK is to start fast recovery on only one DUPACK
provided the connection is a thin stream (i.e., low inflight).  But
this older feature is now subsumed with RACK. If a connection
receives only a single DUPACK, RACK would arm a reordering timer
and soon starts fast recovery instead of timeout if no further
ACKs are received.

The socket option (THIN_DUPACK) is kept as a nop for compatibility.
Note that this patch does not change another thin-stream feature
which enables linear RTO. Although it might be good to generalize
that in the future (i.e., linear RTO for the first say 3 retries).

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 Documentation/networking/ip-sysctl.txt | 12 ------------
 include/linux/tcp.h                    |  2 +-
 net/ipv4/sysctl_net_ipv4.c             |  7 -------
 net/ipv4/tcp.c                         |  6 ++----
 net/ipv4/tcp_input.c                   | 13 -------------
 5 files changed, 3 insertions(+), 37 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 7de2cf79e16f..aa1bb49f1dc6 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -703,18 +703,6 @@ tcp_thin_linear_timeouts - BOOLEAN
 	Documentation/networking/tcp-thin.txt
 	Default: 0
 
-tcp_thin_dupack - BOOLEAN
-	Enable dynamic triggering of retransmissions after one dupACK
-	for thin streams. If set, a check is performed upon reception
-	of a dupACK to determine if the stream is thin (less than 4
-	packets in flight). As long as the stream is found to be thin,
-	data is retransmitted on the first received dupACK. This
-	improves retransmission latency for non-aggressive thin
-	streams, often found to be time-dependent.
-	For more information on thin streams, see
-	Documentation/networking/tcp-thin.txt
-	Default: 0
-
 tcp_limit_output_bytes - INTEGER
 	Controls TCP Small Queue limit per tcp socket.
 	TCP bulk sender tends to increase packets in flight until it
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 4733368f953a..6c22332afb75 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -220,7 +220,7 @@ struct tcp_sock {
 		unused:5;
 	u8	nonagle     : 4,/* Disable Nagle algorithm?             */
 		thin_lto    : 1,/* Use linear timeouts for thin streams */
-		thin_dupack : 1,/* Fast retransmit on first dupack      */
+		unused1	    : 1,
 		repair      : 1,
 		frto        : 1;/* F-RTO (RFC5682) activated in CA_Loss */
 	u8	repair_queue;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 0f2d37e8e983..c8d283615c6f 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -537,13 +537,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler   = proc_dointvec
 	},
 	{
-		.procname       = "tcp_thin_dupack",
-		.data           = &sysctl_tcp_thin_dupack,
-		.maxlen         = sizeof(int),
-		.mode           = 0644,
-		.proc_handler   = proc_dointvec
-	},
-	{
 		.procname	= "tcp_early_retrans",
 		.data		= &sysctl_tcp_early_retrans,
 		.maxlen		= sizeof(int),
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index d9023e8ed53e..aba6ea76338e 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2474,9 +2474,6 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 	case TCP_THIN_DUPACK:
 		if (val < 0 || val > 1)
 			err = -EINVAL;
-		else {
-			tp->thin_dupack = val;
-		}
 		break;
 
 	case TCP_REPAIR:
@@ -2966,8 +2963,9 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 	case TCP_THIN_LINEAR_TIMEOUTS:
 		val = tp->thin_lto;
 		break;
+
 	case TCP_THIN_DUPACK:
-		val = tp->thin_dupack;
+		val = 0;
 		break;
 
 	case TCP_REPAIR:
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 87315ab1ab1a..39ebc20ca1b2 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -95,9 +95,6 @@ int sysctl_tcp_rfc1337 __read_mostly;
 int sysctl_tcp_max_orphans __read_mostly = NR_FILE;
 int sysctl_tcp_frto __read_mostly = 2;
 int sysctl_tcp_min_rtt_wlen __read_mostly = 300;
-
-int sysctl_tcp_thin_dupack __read_mostly;
-
 int sysctl_tcp_moderate_rcvbuf __read_mostly = 1;
 int sysctl_tcp_early_retrans __read_mostly = 3;
 int sysctl_tcp_invalid_ratelimit __read_mostly = HZ/2;
@@ -2170,16 +2167,6 @@ static bool tcp_time_to_recover(struct sock *sk, int flag)
 	if (tcp_dupack_heuristics(tp) > tp->reordering)
 		return true;
 
-	/* If a thin stream is detected, retransmit after first
-	 * received dupack. Employ only if SACK is supported in order
-	 * to avoid possible corner-case series of spurious retransmissions
-	 * Use only if there are no unsent data.
-	 */
-	if ((tp->thin_dupack || sysctl_tcp_thin_dupack) &&
-	    tcp_stream_is_thin(tp) && tcp_dupack_heuristics(tp) > 1 &&
-	    tcp_is_sack(tp) && !tcp_send_head(sk))
-		return true;
-
 	return false;
 }
 
-- 
2.11.0.483.g087da7b7c-goog
