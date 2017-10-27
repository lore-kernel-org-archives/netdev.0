From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 12/12] tcp: Namespace-ify sysctl_tcp_pacing_ca_ratio
Date: Fri, 27 Oct 2017 07:47:32 -0700
Message-ID: <20171027144732.23885-13-edumazet@google.com>
References: <20171027144732.23885-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:48404 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751736AbdJ0OsF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 10:48:05 -0400
Received: by mail-io0-f196.google.com with SMTP id j17so13200213iod.5
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 07:48:05 -0700 (PDT)
In-Reply-To: <20171027144732.23885-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  2 --
 net/ipv4/sysctl_net_ipv4.c | 18 +++++++++---------
 net/ipv4/tcp_input.c       |  4 +---
 net/ipv4/tcp_ipv4.c        |  1 +
 5 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index eb2dcf1cbe61bf392e1c186e6fd1a11b82d8bad2..141ba82b5efbda4df09ea022679096f97c36df93 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -153,6 +153,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_autocorking;
 	int sysctl_tcp_invalid_ratelimit;
 	int sysctl_tcp_pacing_ss_ratio;
+	int sysctl_tcp_pacing_ca_ratio;
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
 	int sysctl_tcp_fastopen;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 2a5f8261ca03b76061dfbe85bbcf0fa15e5f8b40..092d606fcc1658d9e0b5dd451022d1b5ad1f20c1 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -250,8 +250,6 @@ extern int sysctl_tcp_rmem[3];
 
 #define TCP_RACK_LOSS_DETECTION  0x1 /* Use RACK to detect losses */
 
-extern int sysctl_tcp_pacing_ca_ratio;
-
 extern atomic_long_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
 extern unsigned long tcp_memory_pressure;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 7f0dba852d471a6e78d508d0b87966e26d4ca621..4602af6d5358d414df68a0e74ad2dae7fed9bfb6 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -492,15 +492,6 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler   = proc_allowed_congestion_control,
 	},
-	{
-		.procname	= "tcp_pacing_ca_ratio",
-		.data		= &sysctl_tcp_pacing_ca_ratio,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &zero,
-		.extra2		= &thousand,
-	},
 	{
 		.procname	= "tcp_available_ulp",
 		.maxlen		= TCP_ULP_BUF_MAX,
@@ -1145,6 +1136,15 @@ static struct ctl_table ipv4_net_table[] = {
 		.extra1		= &zero,
 		.extra2		= &thousand,
 	},
+	{
+		.procname	= "tcp_pacing_ca_ratio",
+		.data		= &init_net.ipv4.sysctl_tcp_pacing_ca_ratio,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &thousand,
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 29539d39e61a0b99267e6c9b8f63b8acf6ae6200..21c358c0cf2ea6c4a7bcf22b0490e043a57dc680 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -767,8 +767,6 @@ static void tcp_rtt_estimator(struct sock *sk, long mrtt_us)
 	tp->srtt_us = max(1U, srtt);
 }
 
-int sysctl_tcp_pacing_ca_ratio __read_mostly = 120;
-
 static void tcp_update_pacing_rate(struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
@@ -788,7 +786,7 @@ static void tcp_update_pacing_rate(struct sock *sk)
 	if (tp->snd_cwnd < tp->snd_ssthresh / 2)
 		rate *= sock_net(sk)->ipv4.sysctl_tcp_pacing_ss_ratio;
 	else
-		rate *= sysctl_tcp_pacing_ca_ratio;
+		rate *= sock_net(sk)->ipv4.sysctl_tcp_pacing_ca_ratio;
 
 	rate *= max(tp->snd_cwnd, tp->packets_out);
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 1d8fc663af51f4d248de73ee30e28db44ffc940a..7c1dae6493c3fa36f34f38b7d5fc070d628ddee9 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2508,6 +2508,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_autocorking = 1;
 	net->ipv4.sysctl_tcp_invalid_ratelimit = HZ/2;
 	net->ipv4.sysctl_tcp_pacing_ss_ratio = 200;
+	net->ipv4.sysctl_tcp_pacing_ca_ratio = 120;
 
 	net->ipv4.sysctl_tcp_fastopen = TFO_CLIENT_ENABLE;
 	spin_lock_init(&net->ipv4.tcp_fastopen_ctx_lock);
-- 
2.15.0.rc2.357.g7e34df9404-goog
