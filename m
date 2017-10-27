From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 11/15] tcp: Namespace-ify sysctl_tcp_max_reordering
Date: Thu, 26 Oct 2017 21:55:06 -0700
Message-ID: <20171027045510.5827-12-edumazet@google.com>
References: <20171027045510.5827-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:55920 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751947AbdJ0Ezj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 00:55:39 -0400
Received: by mail-io0-f193.google.com with SMTP id p186so10094016ioe.12
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 21:55:39 -0700 (PDT)
In-Reply-To: <20171027045510.5827-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  1 -
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp_input.c       |  3 +--
 net/ipv4/tcp_ipv4.c        |  2 ++
 5 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index f0e792beeea974b0850090d7624a3d7490124067..3f6844665a2fbe66fc0c91bd13e057ac2e03007a 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -137,6 +137,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_rfc1337;
 	int sysctl_tcp_abort_on_overflow;
 	int sysctl_tcp_fack;
+	int sysctl_tcp_max_reordering;
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
 	int sysctl_tcp_fastopen;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index fc134ba74c7d38d08304b5be36506946784538f2..8cd286226a1eca27d97b9f182d1a951b072e4575 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -244,7 +244,6 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 
 /* sysctl variables for tcp */
 extern int sysctl_tcp_max_orphans;
-extern int sysctl_tcp_max_reordering;
 extern int sysctl_tcp_dsack;
 extern long sysctl_tcp_mem[3];
 extern int sysctl_tcp_wmem[3];
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 1f23be13ce7be8b2a12b82aada36c6351fdfb70a..18cd228a20690541936dd6b3d9bb02cb283a9740 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -414,13 +414,6 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
-	{
-		.procname	= "tcp_max_reordering",
-		.data		= &sysctl_tcp_max_reordering,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
 	{
 		.procname	= "tcp_dsack",
 		.data		= &sysctl_tcp_dsack,
@@ -1145,6 +1138,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "tcp_max_reordering",
+		.data		= &init_net.ipv4.sysctl_tcp_max_reordering,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c5b94460793f9693719b38978c123209e2b6ec0f..c118657f06ee390053e38c35f03bea5b82845513 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -79,7 +79,6 @@
 #include <linux/unaligned/access_ok.h>
 #include <linux/static_key.h>
 
-int sysctl_tcp_max_reordering __read_mostly = 300;
 int sysctl_tcp_dsack __read_mostly = 1;
 int sysctl_tcp_app_win __read_mostly = 31;
 int sysctl_tcp_adv_win_scale __read_mostly = 1;
@@ -889,7 +888,7 @@ static void tcp_update_reordering(struct sock *sk, const int metric,
 		return;
 
 	if (metric > tp->reordering) {
-		tp->reordering = min(sysctl_tcp_max_reordering, metric);
+		tp->reordering = min(sock_net(sk)->ipv4.sysctl_tcp_max_reordering, metric);
 
 #if FASTRETRANS_DEBUG > 1
 		pr_debug("Disorder%d %d %u f%u s%u rr%d\n",
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 2bc6ba2059d32aa848dbc415b4b0e194b61b0268..c379a242abb3546044da9a3ef032f6f68acafe88 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2488,6 +2488,8 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_recovery = TCP_RACK_LOSS_DETECTION;
 	net->ipv4.sysctl_tcp_slow_start_after_idle = 1; /* By default, RFC2861 behavior.  */
 	net->ipv4.sysctl_tcp_retrans_collapse = 1;
+	net->ipv4.sysctl_tcp_max_reordering = 300;
+
 	net->ipv4.sysctl_tcp_fastopen = TFO_CLIENT_ENABLE;
 	spin_lock_init(&net->ipv4.tcp_fastopen_ctx_lock);
 	net->ipv4.sysctl_tcp_fastopen_blackhole_timeout = 60 * 60;
-- 
2.15.0.rc2.357.g7e34df9404-goog
