From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 01/15] tcp: Namespace-ify sysctl_tcp_early_retrans
Date: Thu, 26 Oct 2017 21:54:56 -0700
Message-ID: <20171027045510.5827-2-edumazet@google.com>
References: <20171027045510.5827-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:50682 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751283AbdJ0EzS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 00:55:18 -0400
Received: by mail-io0-f193.google.com with SMTP id 97so10123290iok.7
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 21:55:18 -0700 (PDT)
In-Reply-To: <20171027045510.5827-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  1 -
 net/ipv4/sysctl_net_ipv4.c | 18 +++++++++---------
 net/ipv4/tcp_input.c       |  1 -
 net/ipv4/tcp_ipv4.c        |  1 +
 net/ipv4/tcp_output.c      |  4 +++-
 6 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 2c4222a5d1025f5928665e10edb70fad65352dba..a7f39e3ea666a835b6042e4008c86ccaadd14b46 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -128,6 +128,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_sack;
 	int sysctl_tcp_window_scaling;
 	int sysctl_tcp_timestamps;
+	int sysctl_tcp_early_retrans;
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
 	int sysctl_tcp_fastopen;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 285bc82dea410b22ac585ee65daff5cbac7c3fc7..a12b71d4118baa6b939bdeba7380cb3830d46ff0 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -265,7 +265,6 @@ extern int sysctl_tcp_workaround_signed_windows;
 extern int sysctl_tcp_slow_start_after_idle;
 extern int sysctl_tcp_thin_linear_timeouts;
 extern int sysctl_tcp_thin_dupack;
-extern int sysctl_tcp_early_retrans;
 extern int sysctl_tcp_recovery;
 #define TCP_RACK_LOSS_DETECTION  0x1 /* Use RACK to detect losses */
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 81d218346cf7a0f340f964c434a21cace5c41fa0..f0f650f020afd535f41943c6c9fb1483be7cfb8d 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -634,15 +634,6 @@ static struct ctl_table ipv4_table[] = {
 		.mode           = 0644,
 		.proc_handler   = proc_dointvec
 	},
-	{
-		.procname	= "tcp_early_retrans",
-		.data		= &sysctl_tcp_early_retrans,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &zero,
-		.extra2		= &four,
-	},
 	{
 		.procname	= "tcp_min_tso_segs",
 		.data		= &sysctl_tcp_min_tso_segs,
@@ -1145,6 +1136,15 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "tcp_early_retrans",
+		.data		= &init_net.ipv4.sysctl_tcp_early_retrans,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &four,
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 337f6011528a7d4c3ab7fdcc0623496cfefafc71..7656b1e6d5046297b4c5e6cf5591266b9be40095 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -95,7 +95,6 @@ int sysctl_tcp_max_orphans __read_mostly = NR_FILE;
 int sysctl_tcp_frto __read_mostly = 2;
 int sysctl_tcp_min_rtt_wlen __read_mostly = 300;
 int sysctl_tcp_moderate_rcvbuf __read_mostly = 1;
-int sysctl_tcp_early_retrans __read_mostly = 3;
 int sysctl_tcp_invalid_ratelimit __read_mostly = HZ/2;
 
 #define FLAG_DATA		0x01 /* Incoming frame contained data.		*/
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 23a8100af5ad399d4fa2568f4cac19192a008055..7ab313f6768e234173d78f17cfb1f664b230e958 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2484,6 +2484,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_sack = 1;
 	net->ipv4.sysctl_tcp_window_scaling = 1;
 	net->ipv4.sysctl_tcp_timestamps = 1;
+	net->ipv4.sysctl_tcp_early_retrans = 3;
 
 	net->ipv4.sysctl_tcp_fastopen = TFO_CLIENT_ENABLE;
 	spin_lock_init(&net->ipv4.tcp_fastopen_ctx_lock);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index c8fc512e0bbb48f7d36e159e8aae56ec70a24498..21713836d46af9d48de10e8ec0e7410572ed7eeb 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2435,6 +2435,7 @@ bool tcp_schedule_loss_probe(struct sock *sk)
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	u32 timeout, rto_delta_us;
+	int early_retrans;
 
 	/* Don't do any loss probe on a Fast Open connection before 3WHS
 	 * finishes.
@@ -2442,10 +2443,11 @@ bool tcp_schedule_loss_probe(struct sock *sk)
 	if (tp->fastopen_rsk)
 		return false;
 
+	early_retrans = sock_net(sk)->ipv4.sysctl_tcp_early_retrans;
 	/* Schedule a loss probe in 2*RTT for SACK capable connections
 	 * in Open state, that are either limited by cwnd or application.
 	 */
-	if ((sysctl_tcp_early_retrans != 3 && sysctl_tcp_early_retrans != 4) ||
+	if ((early_retrans != 3 && early_retrans != 4) ||
 	    !tp->packets_out || !tcp_is_sack(tp) ||
 	    icsk->icsk_ca_state != TCP_CA_Open)
 		return false;
-- 
2.15.0.rc2.357.g7e34df9404-goog
