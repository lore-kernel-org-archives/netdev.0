From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 01/12] tcp: Namespace-ify sysctl_tcp_nometrics_save
Date: Fri, 27 Oct 2017 07:47:21 -0700
Message-ID: <20171027144732.23885-2-edumazet@google.com>
References: <20171027144732.23885-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:44464 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751673AbdJ0Ork (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 10:47:40 -0400
Received: by mail-io0-f193.google.com with SMTP id m16so13219375iod.1
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 07:47:40 -0700 (PDT)
In-Reply-To: <20171027144732.23885-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  1 -
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp_metrics.c     |  4 +---
 4 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index f4622e28db3a1484553f51709b144ee769766a28..9606e2ea1f1428744c7a734bf6cc58944889a8dd 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -142,6 +142,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_app_win;
 	int sysctl_tcp_adv_win_scale;
 	int sysctl_tcp_frto;
+	int sysctl_tcp_nometrics_save;
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
 	int sysctl_tcp_fastopen;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 18f047501f53be3780bd41a5c8234adf9683cebf..6ab7fa4154b27aad8d70d02f48d1c0aa9302839a 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -247,7 +247,6 @@ extern int sysctl_tcp_max_orphans;
 extern long sysctl_tcp_mem[3];
 extern int sysctl_tcp_wmem[3];
 extern int sysctl_tcp_rmem[3];
-extern int sysctl_tcp_nometrics_save;
 extern int sysctl_tcp_moderate_rcvbuf;
 extern int sysctl_tcp_tso_win_divisor;
 extern int sysctl_tcp_workaround_signed_windows;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index f1bcb9b7e082c6688fad12e15be9b872ebed8151..b742a5e26a9d9c5a2ad730fda649bdd152b23988 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -451,13 +451,6 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
-	{
-		.procname	= "tcp_no_metrics_save",
-		.data		= &sysctl_tcp_nometrics_save,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
 	{
 		.procname	= "tcp_moderate_rcvbuf",
 		.data		= &sysctl_tcp_moderate_rcvbuf,
@@ -1145,6 +1138,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "tcp_no_metrics_save",
+		.data		= &init_net.ipv4.sysctl_tcp_nometrics_save,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 0ab78abc811bef0388089befed672e3d4ee9d881..0507b56b6d4b2721ebce42d2a89a6638350c3b74 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -20,8 +20,6 @@
 #include <net/tcp.h>
 #include <net/genetlink.h>
 
-int sysctl_tcp_nometrics_save __read_mostly;
-
 static struct tcp_metrics_block *__tcp_get_metrics(const struct inetpeer_addr *saddr,
 						   const struct inetpeer_addr *daddr,
 						   struct net *net, unsigned int hash);
@@ -330,7 +328,7 @@ void tcp_update_metrics(struct sock *sk)
 	int m;
 
 	sk_dst_confirm(sk);
-	if (sysctl_tcp_nometrics_save || !dst)
+	if (net->ipv4.sysctl_tcp_nometrics_save || !dst)
 		return;
 
 	rcu_read_lock();
-- 
2.15.0.rc2.357.g7e34df9404-goog
