From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 11/12] tcp: Namespace-ify sysctl_tcp_pacing_ss_ratio
Date: Fri, 27 Oct 2017 07:47:31 -0700
Message-ID: <20171027144732.23885-12-edumazet@google.com>
References: <20171027144732.23885-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:53440 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751975AbdJ0OsC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 10:48:02 -0400
Received: by mail-io0-f194.google.com with SMTP id 189so13208460iow.10
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 07:48:02 -0700 (PDT)
In-Reply-To: <20171027144732.23885-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also remove an obsolete comment about TCP pacing.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  1 -
 net/ipv4/sysctl_net_ipv4.c | 18 +++++++++---------
 net/ipv4/tcp_input.c       |  9 +--------
 net/ipv4/tcp_ipv4.c        |  1 +
 5 files changed, 12 insertions(+), 18 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index e52c2124b32e799f32943621cc0cc55dc7d8413d..eb2dcf1cbe61bf392e1c186e6fd1a11b82d8bad2 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -152,6 +152,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_min_rtt_wlen;
 	int sysctl_tcp_autocorking;
 	int sysctl_tcp_invalid_ratelimit;
+	int sysctl_tcp_pacing_ss_ratio;
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
 	int sysctl_tcp_fastopen;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 5869a822ecb1b8f350cb393b4b43343ccf206eb5..2a5f8261ca03b76061dfbe85bbcf0fa15e5f8b40 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -250,7 +250,6 @@ extern int sysctl_tcp_rmem[3];
 
 #define TCP_RACK_LOSS_DETECTION  0x1 /* Use RACK to detect losses */
 
-extern int sysctl_tcp_pacing_ss_ratio;
 extern int sysctl_tcp_pacing_ca_ratio;
 
 extern atomic_long_t tcp_memory_allocated;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 6a9349c27f00b1a665b969fe0291d195ec473e3e..7f0dba852d471a6e78d508d0b87966e26d4ca621 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -492,15 +492,6 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler   = proc_allowed_congestion_control,
 	},
-	{
-		.procname	= "tcp_pacing_ss_ratio",
-		.data		= &sysctl_tcp_pacing_ss_ratio,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &zero,
-		.extra2		= &thousand,
-	},
 	{
 		.procname	= "tcp_pacing_ca_ratio",
 		.data		= &sysctl_tcp_pacing_ca_ratio,
@@ -1145,6 +1136,15 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_ms_jiffies,
 	},
+	{
+		.procname	= "tcp_pacing_ss_ratio",
+		.data		= &init_net.ipv4.sysctl_tcp_pacing_ss_ratio,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &thousand,
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index db4d458d0205027681f96498019a5fd0bb0303b8..29539d39e61a0b99267e6c9b8f63b8acf6ae6200 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -767,13 +767,6 @@ static void tcp_rtt_estimator(struct sock *sk, long mrtt_us)
 	tp->srtt_us = max(1U, srtt);
 }
 
-/* Set the sk_pacing_rate to allow proper sizing of TSO packets.
- * Note: TCP stack does not yet implement pacing.
- * FQ packet scheduler can be used to implement cheap but effective
- * TCP pacing, to smooth the burst on large writes when packets
- * in flight is significantly lower than cwnd (or rwin)
- */
-int sysctl_tcp_pacing_ss_ratio __read_mostly = 200;
 int sysctl_tcp_pacing_ca_ratio __read_mostly = 120;
 
 static void tcp_update_pacing_rate(struct sock *sk)
@@ -793,7 +786,7 @@ static void tcp_update_pacing_rate(struct sock *sk)
 	 *	 end of slow start and should slow down.
 	 */
 	if (tp->snd_cwnd < tp->snd_ssthresh / 2)
-		rate *= sysctl_tcp_pacing_ss_ratio;
+		rate *= sock_net(sk)->ipv4.sysctl_tcp_pacing_ss_ratio;
 	else
 		rate *= sysctl_tcp_pacing_ca_ratio;
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 6617aae18ba2e2ad23663708a39311b0e987522d..1d8fc663af51f4d248de73ee30e28db44ffc940a 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2507,6 +2507,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_min_rtt_wlen = 300;
 	net->ipv4.sysctl_tcp_autocorking = 1;
 	net->ipv4.sysctl_tcp_invalid_ratelimit = HZ/2;
+	net->ipv4.sysctl_tcp_pacing_ss_ratio = 200;
 
 	net->ipv4.sysctl_tcp_fastopen = TFO_CLIENT_ENABLE;
 	spin_lock_init(&net->ipv4.tcp_fastopen_ctx_lock);
-- 
2.15.0.rc2.357.g7e34df9404-goog
