From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 15/15] tcp: Namespace-ify sysctl_tcp_frto
Date: Thu, 26 Oct 2017 16:35:26 -0700
Message-ID: <20171026233526.6155-16-edumazet@google.com>
References: <20171026233526.6155-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:45654 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932442AbdJZXgI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 19:36:08 -0400
Received: by mail-pg0-f67.google.com with SMTP id b192so3900739pga.2
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 16:36:08 -0700 (PDT)
In-Reply-To: <20171026233526.6155-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  1 -
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp_input.c       |  3 +--
 net/ipv4/tcp_ipv4.c        |  1 +
 5 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 9dbb07d4eff465428817831e55c6a4922b7208fb..f4622e28db3a1484553f51709b144ee769766a28 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -141,6 +141,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_dsack;
 	int sysctl_tcp_app_win;
 	int sysctl_tcp_adv_win_scale;
+	int sysctl_tcp_frto;
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
 	int sysctl_tcp_fastopen;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 2572b57682987dd5f3700ed47d63e7238946b9a8..19006a5d073c202995ba63199ab8cde814d6d869 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -244,7 +244,6 @@ extern int sysctl_tcp_max_orphans;
 extern long sysctl_tcp_mem[3];
 extern int sysctl_tcp_wmem[3];
 extern int sysctl_tcp_rmem[3];
-extern int sysctl_tcp_frto;
 extern int sysctl_tcp_nometrics_save;
 extern int sysctl_tcp_moderate_rcvbuf;
 extern int sysctl_tcp_tso_win_divisor;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index a95123e1e7da706c88bf5553b7d8ef6c2653ab50..f1bcb9b7e082c6688fad12e15be9b872ebed8151 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -437,13 +437,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &one,
 	},
-	{
-		.procname	= "tcp_frto",
-		.data		= &sysctl_tcp_frto,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
 	{
 		.procname	= "tcp_min_rtt_wlen",
 		.data		= &sysctl_tcp_min_rtt_wlen,
@@ -1145,6 +1138,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.extra1		= &tcp_adv_win_scale_min,
 		.extra2		= &tcp_adv_win_scale_max,
 	},
+	{
+		.procname	= "tcp_frto",
+		.data		= &init_net.ipv4.sysctl_tcp_frto,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d01f390da23dcd4100271b150bd8bc143f7328cf..24950ea3094288cad8d9cd9eb0e0698d6f50e989 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -81,7 +81,6 @@
 int sysctl_tcp_challenge_ack_limit = 1000;
 
 int sysctl_tcp_max_orphans __read_mostly = NR_FILE;
-int sysctl_tcp_frto __read_mostly = 2;
 int sysctl_tcp_min_rtt_wlen __read_mostly = 300;
 int sysctl_tcp_moderate_rcvbuf __read_mostly = 1;
 int sysctl_tcp_invalid_ratelimit __read_mostly = HZ/2;
@@ -2024,7 +2023,7 @@ void tcp_enter_loss(struct sock *sk)
 	 * falsely raise the receive window, which results in repeated
 	 * timeouts and stop-and-go behavior.
 	 */
-	tp->frto = sysctl_tcp_frto &&
+	tp->frto = net->ipv4.sysctl_tcp_frto &&
 		   (new_recovery || icsk->icsk_retransmits) &&
 		   !inet_csk(sk)->icsk_mtup.probe_size;
 }
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 1fe30fb99308b3e3fd07509b509b0e3727cc5d44..49757c75821111c6d2cf413415be2c1b58482659 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2492,6 +2492,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_dsack = 1;
 	net->ipv4.sysctl_tcp_app_win = 31;
 	net->ipv4.sysctl_tcp_adv_win_scale = 1;
+	net->ipv4.sysctl_tcp_frto = 2;
 
 	net->ipv4.sysctl_tcp_fastopen = TFO_CLIENT_ENABLE;
 	spin_lock_init(&net->ipv4.tcp_fastopen_ctx_lock);
-- 
2.15.0.rc2.357.g7e34df9404-goog
