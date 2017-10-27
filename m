From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 12/15] tcp: Namespace-ify sysctl_tcp_dsack
Date: Thu, 26 Oct 2017 21:55:07 -0700
Message-ID: <20171027045510.5827-13-edumazet@google.com>
References: <20171027045510.5827-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:53475 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751997AbdJ0Ezk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 00:55:40 -0400
Received: by mail-io0-f193.google.com with SMTP id 189so10116363iow.10
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 21:55:40 -0700 (PDT)
In-Reply-To: <20171027045510.5827-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  1 -
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp_input.c       |  5 ++---
 net/ipv4/tcp_ipv4.c        |  1 +
 5 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 3f6844665a2fbe66fc0c91bd13e057ac2e03007a..956957a77db96ad3d231cc018c13503d615d8d2e 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -138,6 +138,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_abort_on_overflow;
 	int sysctl_tcp_fack;
 	int sysctl_tcp_max_reordering;
+	int sysctl_tcp_dsack;
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
 	int sysctl_tcp_fastopen;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 8cd286226a1eca27d97b9f182d1a951b072e4575..8b2ae3e8d79f223d4637226fc7278fe751d0b5d7 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -244,7 +244,6 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 
 /* sysctl variables for tcp */
 extern int sysctl_tcp_max_orphans;
-extern int sysctl_tcp_dsack;
 extern long sysctl_tcp_mem[3];
 extern int sysctl_tcp_wmem[3];
 extern int sysctl_tcp_rmem[3];
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 18cd228a20690541936dd6b3d9bb02cb283a9740..7652a9c2a65d3f1cfa0a75d1198e1d9d56761c35 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -414,13 +414,6 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
-	{
-		.procname	= "tcp_dsack",
-		.data		= &sysctl_tcp_dsack,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
 	{
 		.procname	= "tcp_mem",
 		.maxlen		= sizeof(sysctl_tcp_mem),
@@ -1145,6 +1138,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "tcp_dsack",
+		.data		= &init_net.ipv4.sysctl_tcp_dsack,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c118657f06ee390053e38c35f03bea5b82845513..fd77037ac800a1153ec0ef904fcf00b93c061fa1 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -79,7 +79,6 @@
 #include <linux/unaligned/access_ok.h>
 #include <linux/static_key.h>
 
-int sysctl_tcp_dsack __read_mostly = 1;
 int sysctl_tcp_app_win __read_mostly = 31;
 int sysctl_tcp_adv_win_scale __read_mostly = 1;
 EXPORT_SYMBOL(sysctl_tcp_adv_win_scale);
@@ -4150,7 +4149,7 @@ static void tcp_dsack_set(struct sock *sk, u32 seq, u32 end_seq)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	if (tcp_is_sack(tp) && sysctl_tcp_dsack) {
+	if (tcp_is_sack(tp) && sock_net(sk)->ipv4.sysctl_tcp_dsack) {
 		int mib_idx;
 
 		if (before(seq, tp->rcv_nxt))
@@ -4185,7 +4184,7 @@ static void tcp_send_dupack(struct sock *sk, const struct sk_buff *skb)
 		NET_INC_STATS(sock_net(sk), LINUX_MIB_DELAYEDACKLOST);
 		tcp_enter_quickack_mode(sk);
 
-		if (tcp_is_sack(tp) && sysctl_tcp_dsack) {
+		if (tcp_is_sack(tp) && sock_net(sk)->ipv4.sysctl_tcp_dsack) {
 			u32 end_seq = TCP_SKB_CB(skb)->end_seq;
 
 			if (after(TCP_SKB_CB(skb)->end_seq, tp->rcv_nxt))
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index c379a242abb3546044da9a3ef032f6f68acafe88..d9d4d191e8f3c962a6ee68015ffe5a6e7fb8e9c1 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2489,6 +2489,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_slow_start_after_idle = 1; /* By default, RFC2861 behavior.  */
 	net->ipv4.sysctl_tcp_retrans_collapse = 1;
 	net->ipv4.sysctl_tcp_max_reordering = 300;
+	net->ipv4.sysctl_tcp_dsack = 1;
 
 	net->ipv4.sysctl_tcp_fastopen = TFO_CLIENT_ENABLE;
 	spin_lock_init(&net->ipv4.tcp_fastopen_ctx_lock);
-- 
2.15.0.rc2.357.g7e34df9404-goog
