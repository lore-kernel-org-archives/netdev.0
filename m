From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 05/15] tcp: Namespace-ify sysctl_tcp_retrans_collapse
Date: Thu, 26 Oct 2017 21:55:00 -0700
Message-ID: <20171027045510.5827-6-edumazet@google.com>
References: <20171027045510.5827-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:56411 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751908AbdJ0Ez0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 00:55:26 -0400
Received: by mail-io0-f194.google.com with SMTP id m81so10103956ioi.13
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 21:55:26 -0700 (PDT)
In-Reply-To: <20171027045510.5827-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  1 -
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp_ipv4.c        |  2 +-
 net/ipv4/tcp_output.c      |  5 +----
 5 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 8662692686b3af98a94a176230b9ed147881d87a..b28c172b10e497f235b51aae0fc2d3bbf7cc51f3 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -132,6 +132,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_recovery;
 	int sysctl_tcp_thin_linear_timeouts;
 	int sysctl_tcp_slow_start_after_idle;
+	int sysctl_tcp_retrans_collapse;
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
 	int sysctl_tcp_fastopen;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index cc2ab522eb5cf7cb08b6918cdfd5c5500cfbf057..33cc86355b8ff9b506d21ad46cfc01b3916f5b61 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -243,7 +243,6 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 
 
 /* sysctl variables for tcp */
-extern int sysctl_tcp_retrans_collapse;
 extern int sysctl_tcp_stdurg;
 extern int sysctl_tcp_rfc1337;
 extern int sysctl_tcp_abort_on_overflow;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 40d69af8b363bc236e23879973872d8f9346d85e..533b92ad39dd0cada542028fe2f276d9eebcd2c8 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -386,13 +386,6 @@ static int proc_tcp_available_ulp(struct ctl_table *ctl,
 }
 
 static struct ctl_table ipv4_table[] = {
-	{
-		.procname	= "tcp_retrans_collapse",
-		.data		= &sysctl_tcp_retrans_collapse,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
 	{
 		.procname	= "tcp_max_orphans",
 		.data		= &sysctl_tcp_max_orphans,
@@ -1145,6 +1138,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "tcp_retrans_collapse",
+		.data		= &init_net.ipv4.sysctl_tcp_retrans_collapse,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index cea63a4b59655823def7a423d27191003c7f084c..2bc6ba2059d32aa848dbc415b4b0e194b61b0268 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2487,7 +2487,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_early_retrans = 3;
 	net->ipv4.sysctl_tcp_recovery = TCP_RACK_LOSS_DETECTION;
 	net->ipv4.sysctl_tcp_slow_start_after_idle = 1; /* By default, RFC2861 behavior.  */
-
+	net->ipv4.sysctl_tcp_retrans_collapse = 1;
 	net->ipv4.sysctl_tcp_fastopen = TFO_CLIENT_ENABLE;
 	spin_lock_init(&net->ipv4.tcp_fastopen_ctx_lock);
 	net->ipv4.sysctl_tcp_fastopen_blackhole_timeout = 60 * 60;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index bdc288a06f941add38a5cde434081c63ee94ed42..55a0aa4b96dfc7cd8f703ad42b932bae23ea5660 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -45,9 +45,6 @@
 
 #include <trace/events/tcp.h>
 
-/* People can turn this off for buggy TCP's found in printers etc. */
-int sysctl_tcp_retrans_collapse __read_mostly = 1;
-
 /* People can turn this on to work with those rare, broken TCPs that
  * interpret the window field as a signed quantity.
  */
@@ -2804,7 +2801,7 @@ static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *to,
 	struct sk_buff *skb = to, *tmp;
 	bool first = true;
 
-	if (!sysctl_tcp_retrans_collapse)
+	if (!sock_net(sk)->ipv4.sysctl_tcp_retrans_collapse)
 		return;
 	if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_SYN)
 		return;
-- 
2.15.0.rc2.357.g7e34df9404-goog
