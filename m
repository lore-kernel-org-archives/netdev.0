From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 05/15] tcp: Namespace-ify sysctl_tcp_retrans_collapse
Date: Thu, 26 Oct 2017 16:35:16 -0700
Message-ID: <20171026233526.6155-6-edumazet@google.com>
References: <20171026233526.6155-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:44811 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932417AbdJZXfo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 19:35:44 -0400
Received: by mail-pf0-f193.google.com with SMTP id x7so3619326pfa.1
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 16:35:44 -0700 (PDT)
In-Reply-To: <20171026233526.6155-1-edumazet@google.com>
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
index 09c79705a0742aa8c22b3b7795d01b6c685d32e2..085848e4de38058bb09f025387c713ade32b263e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -240,7 +240,6 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 
 
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
index bc93a346e6e91289c2aeb2f2d2522b809da12dd6..735fff44aaca3d5afbb0ac55ebdb9898b6c44ae6 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -44,9 +44,6 @@
 
 #include <trace/events/tcp.h>
 
-/* People can turn this off for buggy TCP's found in printers etc. */
-int sysctl_tcp_retrans_collapse __read_mostly = 1;
-
 /* People can turn this on to work with those rare, broken TCPs that
  * interpret the window field as a signed quantity.
  */
@@ -2747,7 +2744,7 @@ static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *to,
 	struct sk_buff *skb = to, *tmp;
 	bool first = true;
 
-	if (!sysctl_tcp_retrans_collapse)
+	if (!sock_net(sk)->ipv4.sysctl_tcp_retrans_collapse)
 		return;
 	if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_SYN)
 		return;
-- 
2.15.0.rc2.357.g7e34df9404-goog
