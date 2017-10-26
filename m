From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 13/15] tcp: Namespace-ify sysctl_tcp_app_win
Date: Thu, 26 Oct 2017 16:35:24 -0700
Message-ID: <20171026233526.6155-14-edumazet@google.com>
References: <20171026233526.6155-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:55112 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932466AbdJZXgD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 19:36:03 -0400
Received: by mail-pg0-f66.google.com with SMTP id l24so3879271pgu.11
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 16:36:03 -0700 (PDT)
In-Reply-To: <20171026233526.6155-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  1 -
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp_input.c       |  8 ++++----
 net/ipv4/tcp_ipv4.c        |  1 +
 5 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 956957a77db96ad3d231cc018c13503d615d8d2e..63f91d52cbc0ad35d8e04a8da0d9f57aa960bcb0 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -139,6 +139,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_fack;
 	int sysctl_tcp_max_reordering;
 	int sysctl_tcp_dsack;
+	int sysctl_tcp_app_win;
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
 	int sysctl_tcp_fastopen;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index aba20c4828ee912d9f0f3ef49f3de5376729c022..c6bee85a3dec0dea6d4402d89184ade02a637a2e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -244,7 +244,6 @@ extern int sysctl_tcp_max_orphans;
 extern long sysctl_tcp_mem[3];
 extern int sysctl_tcp_wmem[3];
 extern int sysctl_tcp_rmem[3];
-extern int sysctl_tcp_app_win;
 extern int sysctl_tcp_adv_win_scale;
 extern int sysctl_tcp_frto;
 extern int sysctl_tcp_nometrics_save;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 7652a9c2a65d3f1cfa0a75d1198e1d9d56761c35..e057788834a99cf99e141a602ddbe19b8e6fce3c 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -437,13 +437,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &one,
 	},
-	{
-		.procname	= "tcp_app_win",
-		.data		= &sysctl_tcp_app_win,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
 	{
 		.procname	= "tcp_adv_win_scale",
 		.data		= &sysctl_tcp_adv_win_scale,
@@ -1145,6 +1138,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "tcp_app_win",
+		.data		= &init_net.ipv4.sysctl_tcp_app_win,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index db4798f99bb093b6d5a3e0fdd76efb83b88da49e..06a8c27e1a690e3b26cb6773320bafa31b06d3b3 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -77,7 +77,6 @@
 #include <linux/errqueue.h>
 #include <trace/events/tcp.h>
 
-int sysctl_tcp_app_win __read_mostly = 31;
 int sysctl_tcp_adv_win_scale __read_mostly = 1;
 EXPORT_SYMBOL(sysctl_tcp_adv_win_scale);
 
@@ -426,6 +425,7 @@ static void tcp_fixup_rcvbuf(struct sock *sk)
  */
 void tcp_init_buffer_space(struct sock *sk)
 {
+	int tcp_app_win = sock_net(sk)->ipv4.sysctl_tcp_app_win;
 	struct tcp_sock *tp = tcp_sk(sk);
 	int maxwin;
 
@@ -444,14 +444,14 @@ void tcp_init_buffer_space(struct sock *sk)
 	if (tp->window_clamp >= maxwin) {
 		tp->window_clamp = maxwin;
 
-		if (sysctl_tcp_app_win && maxwin > 4 * tp->advmss)
+		if (tcp_app_win && maxwin > 4 * tp->advmss)
 			tp->window_clamp = max(maxwin -
-					       (maxwin >> sysctl_tcp_app_win),
+					       (maxwin >> tcp_app_win),
 					       4 * tp->advmss);
 	}
 
 	/* Force reservation of one segment. */
-	if (sysctl_tcp_app_win &&
+	if (tcp_app_win &&
 	    tp->window_clamp > 2 * tp->advmss &&
 	    tp->window_clamp + tp->advmss > maxwin)
 		tp->window_clamp = max(2 * tp->advmss, maxwin - tp->advmss);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index d9d4d191e8f3c962a6ee68015ffe5a6e7fb8e9c1..189664ebd28e4cda7ef40a47591c3bd8cac3574b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2490,6 +2490,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_retrans_collapse = 1;
 	net->ipv4.sysctl_tcp_max_reordering = 300;
 	net->ipv4.sysctl_tcp_dsack = 1;
+	net->ipv4.sysctl_tcp_app_win = 31;
 
 	net->ipv4.sysctl_tcp_fastopen = TFO_CLIENT_ENABLE;
 	spin_lock_init(&net->ipv4.tcp_fastopen_ctx_lock);
-- 
2.15.0.rc2.357.g7e34df9404-goog
