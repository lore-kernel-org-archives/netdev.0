From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 05/12] tcp: Namespace-ify sysctl_tcp_limit_output_bytes
Date: Fri, 27 Oct 2017 07:47:25 -0700
Message-ID: <20171027144732.23885-6-edumazet@google.com>
References: <20171027144732.23885-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:45757 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751786AbdJ0Ort (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 10:47:49 -0400
Received: by mail-io0-f194.google.com with SMTP id i38so13212908iod.2
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 07:47:49 -0700 (PDT)
In-Reply-To: <20171027144732.23885-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  1 -
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp_ipv4.c        |  2 ++
 net/ipv4/tcp_output.c      |  6 ++----
 5 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index e74c7c1b0d18e68a4b6caeeb65f6ec09148a6549..e98f473bab13cd9b8ff5cc3a62a75134dd84371a 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -146,6 +146,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_moderate_rcvbuf;
 	int sysctl_tcp_tso_win_divisor;
 	int sysctl_tcp_workaround_signed_windows;
+	int sysctl_tcp_limit_output_bytes;
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
 	int sysctl_tcp_fastopen;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index e338e16178dd8c46a96e81ff4d4aa1ccaaf9c937..33f9d30a69050e4d3eaf4e1f4869d148442902fc 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -250,7 +250,6 @@ extern int sysctl_tcp_rmem[3];
 
 #define TCP_RACK_LOSS_DETECTION  0x1 /* Use RACK to detect losses */
 
-extern int sysctl_tcp_limit_output_bytes;
 extern int sysctl_tcp_challenge_ack_limit;
 extern int sysctl_tcp_min_tso_segs;
 extern int sysctl_tcp_min_rtt_wlen;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 3ae9012a497997f542fa1d743ba78a6c61beaf95..6caf5c40730fa10f14a35e1f3219a69f5365a2ce 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -457,13 +457,6 @@ static struct ctl_table ipv4_table[] = {
 		.maxlen		= TCP_CA_NAME_MAX,
 		.proc_handler	= proc_tcp_congestion_control,
 	},
-	{
-		.procname	= "tcp_limit_output_bytes",
-		.data		= &sysctl_tcp_limit_output_bytes,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
 	{
 		.procname	= "tcp_challenge_ack_limit",
 		.data		= &sysctl_tcp_challenge_ack_limit,
@@ -1145,6 +1138,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "tcp_limit_output_bytes",
+		.data		= &init_net.ipv4.sysctl_tcp_limit_output_bytes,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 284ff16148df908b8fdb0a0ec70e6c18513d35fc..713b80261e4fdbafa9031a7e3bfc06f0700c2279 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2499,6 +2499,8 @@ static int __net_init tcp_sk_init(struct net *net)
 	 * which are too large can cause TCP streams to be bursty.
 	 */
 	net->ipv4.sysctl_tcp_tso_win_divisor = 3;
+	/* Default TSQ limit of four TSO segments */
+	net->ipv4.sysctl_tcp_limit_output_bytes = 262144;
 
 	net->ipv4.sysctl_tcp_fastopen = TFO_CLIENT_ENABLE;
 	spin_lock_init(&net->ipv4.tcp_fastopen_ctx_lock);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 5bbed67c27e9c163ede3065e57ceb0d04a4925d2..f018892c6a98ca7b806570995474bd394d9ab427 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -45,9 +45,6 @@
 
 #include <trace/events/tcp.h>
 
-/* Default TSQ limit of four TSO segments */
-int sysctl_tcp_limit_output_bytes __read_mostly = 262144;
-
 static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 			   int push_one, gfp_t gfp);
 
@@ -2215,7 +2212,8 @@ static bool tcp_small_queue_check(struct sock *sk, const struct sk_buff *skb,
 	unsigned int limit;
 
 	limit = max(2 * skb->truesize, sk->sk_pacing_rate >> 10);
-	limit = min_t(u32, limit, sysctl_tcp_limit_output_bytes);
+	limit = min_t(u32, limit,
+		      sock_net(sk)->ipv4.sysctl_tcp_limit_output_bytes);
 	limit <<= factor;
 
 	if (refcount_read(&sk->sk_wmem_alloc) > limit) {
-- 
2.15.0.rc2.357.g7e34df9404-goog
