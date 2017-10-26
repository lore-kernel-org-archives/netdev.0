From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 04/15] tcp: Namespace-ify sysctl_tcp_slow_start_after_idle
Date: Thu, 26 Oct 2017 16:35:15 -0700
Message-ID: <20171026233526.6155-5-edumazet@google.com>
References: <20171026233526.6155-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:43859 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932396AbdJZXfm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 19:35:42 -0400
Received: by mail-pg0-f65.google.com with SMTP id s75so3903424pgs.0
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 16:35:42 -0700 (PDT)
In-Reply-To: <20171026233526.6155-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  3 +--
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp_ipv4.c        |  1 +
 net/ipv4/tcp_output.c      |  5 +----
 5 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 2a9f37b39c45fe451e45025790a4e5c45ece5cbc..8662692686b3af98a94a176230b9ed147881d87a 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -131,6 +131,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_early_retrans;
 	int sysctl_tcp_recovery;
 	int sysctl_tcp_thin_linear_timeouts;
+	int sysctl_tcp_slow_start_after_idle;
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
 	int sysctl_tcp_fastopen;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 8ef12bfe1a3a7083f1bbc924bc43a022a4057768..09c79705a0742aa8c22b3b7795d01b6c685d32e2 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -259,7 +259,6 @@ extern int sysctl_tcp_nometrics_save;
 extern int sysctl_tcp_moderate_rcvbuf;
 extern int sysctl_tcp_tso_win_divisor;
 extern int sysctl_tcp_workaround_signed_windows;
-extern int sysctl_tcp_slow_start_after_idle;
 
 #define TCP_RACK_LOSS_DETECTION  0x1 /* Use RACK to detect losses */
 
@@ -1305,7 +1304,7 @@ static inline void tcp_slow_start_after_idle_check(struct sock *sk)
 	struct tcp_sock *tp = tcp_sk(sk);
 	s32 delta;
 
-	if (!sysctl_tcp_slow_start_after_idle || tp->packets_out ||
+	if (!sock_net(sk)->ipv4.sysctl_tcp_slow_start_after_idle || tp->packets_out ||
 	    ca_ops->cong_control)
 		return;
 	delta = tcp_jiffies32 - tp->lsndtime;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 12003214f4d80b38d5f754ddd91be8a990168ade..40d69af8b363bc236e23879973872d8f9346d85e 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -571,13 +571,6 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
-	{
-		.procname	= "tcp_slow_start_after_idle",
-		.data		= &sysctl_tcp_slow_start_after_idle,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
 #ifdef CONFIG_NETLABEL
 	{
 		.procname	= "cipso_cache_enable",
@@ -1145,6 +1138,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode           = 0644,
 		.proc_handler   = proc_dointvec
 	},
+	{
+		.procname	= "tcp_slow_start_after_idle",
+		.data		= &init_net.ipv4.sysctl_tcp_slow_start_after_idle,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 517ff1948a71287b06ea0859e1f25a15119a3dd9..cea63a4b59655823def7a423d27191003c7f084c 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2486,6 +2486,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_timestamps = 1;
 	net->ipv4.sysctl_tcp_early_retrans = 3;
 	net->ipv4.sysctl_tcp_recovery = TCP_RACK_LOSS_DETECTION;
+	net->ipv4.sysctl_tcp_slow_start_after_idle = 1; /* By default, RFC2861 behavior.  */
 
 	net->ipv4.sysctl_tcp_fastopen = TFO_CLIENT_ENABLE;
 	spin_lock_init(&net->ipv4.tcp_fastopen_ctx_lock);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index dd7c22b7d23b016b1da83138d6e8047abdef97e6..bc93a346e6e91289c2aeb2f2d2522b809da12dd6 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -61,9 +61,6 @@ int sysctl_tcp_limit_output_bytes __read_mostly = 262144;
  */
 int sysctl_tcp_tso_win_divisor __read_mostly = 3;
 
-/* By default, RFC2861 behavior.  */
-int sysctl_tcp_slow_start_after_idle __read_mostly = 1;
-
 static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 			   int push_one, gfp_t gfp);
 
@@ -1633,7 +1630,7 @@ static void tcp_cwnd_validate(struct sock *sk, bool is_cwnd_limited)
 		if (tp->packets_out > tp->snd_cwnd_used)
 			tp->snd_cwnd_used = tp->packets_out;
 
-		if (sysctl_tcp_slow_start_after_idle &&
+		if (sock_net(sk)->ipv4.sysctl_tcp_slow_start_after_idle &&
 		    (s32)(tcp_jiffies32 - tp->snd_cwnd_stamp) >= inet_csk(sk)->icsk_rto &&
 		    !ca_ops->cong_control)
 			tcp_cwnd_application_limited(sk);
-- 
2.15.0.rc2.357.g7e34df9404-goog
