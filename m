From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 02/12] tcp: Namespace-ify sysctl_tcp_moderate_rcvbuf
Date: Fri, 27 Oct 2017 07:47:22 -0700
Message-ID: <20171027144732.23885-3-edumazet@google.com>
References: <20171027144732.23885-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:47760 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751712AbdJ0Orm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 10:47:42 -0400
Received: by mail-io0-f195.google.com with SMTP id h70so13221935ioi.4
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 07:47:42 -0700 (PDT)
In-Reply-To: <20171027144732.23885-1-edumazet@google.com>
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
index 9606e2ea1f1428744c7a734bf6cc58944889a8dd..4458a54fe3f4e9dc79561039dba0f4d19ee8271e 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -143,6 +143,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_adv_win_scale;
 	int sysctl_tcp_frto;
 	int sysctl_tcp_nometrics_save;
+	int sysctl_tcp_moderate_rcvbuf;
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
 	int sysctl_tcp_fastopen;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 6ab7fa4154b27aad8d70d02f48d1c0aa9302839a..f954e74578fff2e52cf89521132c72fe5a047d13 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -247,7 +247,6 @@ extern int sysctl_tcp_max_orphans;
 extern long sysctl_tcp_mem[3];
 extern int sysctl_tcp_wmem[3];
 extern int sysctl_tcp_rmem[3];
-extern int sysctl_tcp_moderate_rcvbuf;
 extern int sysctl_tcp_tso_win_divisor;
 extern int sysctl_tcp_workaround_signed_windows;
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index b742a5e26a9d9c5a2ad730fda649bdd152b23988..2ebe87fd11696948ab87349ba233a16eccb98b44 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -451,13 +451,6 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
-	{
-		.procname	= "tcp_moderate_rcvbuf",
-		.data		= &sysctl_tcp_moderate_rcvbuf,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
 	{
 		.procname	= "tcp_tso_win_divisor",
 		.data		= &sysctl_tcp_tso_win_divisor,
@@ -1145,6 +1138,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname	= "tcp_moderate_rcvbuf",
+		.data		= &init_net.ipv4.sysctl_tcp_moderate_rcvbuf,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 90d76f1c8f96bc89618ddc59ae237a34cd25db7c..ce481325115fe7cb8a3b007276f2ce2a519a7383 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -84,7 +84,6 @@ int sysctl_tcp_challenge_ack_limit = 1000;
 
 int sysctl_tcp_max_orphans __read_mostly = NR_FILE;
 int sysctl_tcp_min_rtt_wlen __read_mostly = 300;
-int sysctl_tcp_moderate_rcvbuf __read_mostly = 1;
 int sysctl_tcp_invalid_ratelimit __read_mostly = HZ/2;
 
 #define FLAG_DATA		0x01 /* Incoming frame contained data.		*/
@@ -411,7 +410,7 @@ static void tcp_fixup_rcvbuf(struct sock *sk)
 	/* Dynamic Right Sizing (DRS) has 2 to 3 RTT latency
 	 * Allow enough cushion so that sender is not limited by our window
 	 */
-	if (sysctl_tcp_moderate_rcvbuf)
+	if (sock_net(sk)->ipv4.sysctl_tcp_moderate_rcvbuf)
 		rcvmem <<= 2;
 
 	if (sk->sk_rcvbuf < rcvmem)
@@ -602,7 +601,7 @@ void tcp_rcv_space_adjust(struct sock *sk)
 	 * <prev RTT . ><current RTT .. ><next RTT .... >
 	 */
 
-	if (sysctl_tcp_moderate_rcvbuf &&
+	if (sock_net(sk)->ipv4.sysctl_tcp_moderate_rcvbuf &&
 	    !(sk->sk_userlocks & SOCK_RCVBUF_LOCK)) {
 		int rcvwin, rcvmem, rcvbuf;
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 49757c75821111c6d2cf413415be2c1b58482659..27f376b90913519493e78e1f3a198a3a840892f1 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2493,6 +2493,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_app_win = 31;
 	net->ipv4.sysctl_tcp_adv_win_scale = 1;
 	net->ipv4.sysctl_tcp_frto = 2;
+	net->ipv4.sysctl_tcp_moderate_rcvbuf = 1;
 
 	net->ipv4.sysctl_tcp_fastopen = TFO_CLIENT_ENABLE;
 	spin_lock_init(&net->ipv4.tcp_fastopen_ctx_lock);
-- 
2.15.0.rc2.357.g7e34df9404-goog
