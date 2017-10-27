From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 03/12] tcp: Namespace-ify sysctl_tcp_tso_win_divisor
Date: Fri, 27 Oct 2017 07:47:23 -0700
Message-ID: <20171027144732.23885-4-edumazet@google.com>
References: <20171027144732.23885-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:55366 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751736AbdJ0Orp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 10:47:45 -0400
Received: by mail-io0-f195.google.com with SMTP id p186so13179397ioe.12
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 07:47:44 -0700 (PDT)
In-Reply-To: <20171027144732.23885-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  1 -
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp_ipv4.c        |  5 +++++
 net/ipv4/tcp_output.c      |  8 +-------
 5 files changed, 14 insertions(+), 15 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 4458a54fe3f4e9dc79561039dba0f4d19ee8271e..60bccda046dba6c20bcc8bee097525e9455846b2 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -144,6 +144,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_frto;
 	int sysctl_tcp_nometrics_save;
 	int sysctl_tcp_moderate_rcvbuf;
+	int sysctl_tcp_tso_win_divisor;
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
 	int sysctl_tcp_fastopen;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index f954e74578fff2e52cf89521132c72fe5a047d13..ed0828dc82f1b8fd686cd68404e2abe31c6c357d 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -247,7 +247,6 @@ extern int sysctl_tcp_max_orphans;
 extern long sysctl_tcp_mem[3];
 extern int sysctl_tcp_wmem[3];
 extern int sysctl_tcp_rmem[3];
-extern int sysctl_tcp_tso_win_divisor;
 extern int sysctl_tcp_workaround_signed_windows;
 
 #define TCP_RACK_LOSS_DETECTION  0x1 /* Use RACK to detect losses */
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 2ebe87fd11696948ab87349ba233a16eccb98b44..a053cacb82905bb12da60f8555a135ea11f23d28 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -451,13 +451,6 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
-	{
-		.procname	= "tcp_tso_win_divisor",
-		.data		= &sysctl_tcp_tso_win_divisor,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
 	{
 		.procname	= "tcp_congestion_control",
 		.mode		= 0644,
@@ -1145,6 +1138,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname	= "tcp_tso_win_divisor",
+		.data		= &init_net.ipv4.sysctl_tcp_tso_win_divisor,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 27f376b90913519493e78e1f3a198a3a840892f1..284ff16148df908b8fdb0a0ec70e6c18513d35fc 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2494,6 +2494,11 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_adv_win_scale = 1;
 	net->ipv4.sysctl_tcp_frto = 2;
 	net->ipv4.sysctl_tcp_moderate_rcvbuf = 1;
+	/* This limits the percentage of the congestion window which we
+	 * will allow a single TSO frame to consume.  Building TSO frames
+	 * which are too large can cause TCP streams to be bursty.
+	 */
+	net->ipv4.sysctl_tcp_tso_win_divisor = 3;
 
 	net->ipv4.sysctl_tcp_fastopen = TFO_CLIENT_ENABLE;
 	spin_lock_init(&net->ipv4.tcp_fastopen_ctx_lock);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 55a0aa4b96dfc7cd8f703ad42b932bae23ea5660..60df3ab52166ac20941d540ad075d60ab3426d25 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -53,12 +53,6 @@ int sysctl_tcp_workaround_signed_windows __read_mostly = 0;
 /* Default TSQ limit of four TSO segments */
 int sysctl_tcp_limit_output_bytes __read_mostly = 262144;
 
-/* This limits the percentage of the congestion window which we
- * will allow a single TSO frame to consume.  Building TSO frames
- * which are too large can cause TCP streams to be bursty.
- */
-int sysctl_tcp_tso_win_divisor __read_mostly = 3;
-
 static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 			   int push_one, gfp_t gfp);
 
@@ -1988,7 +1982,7 @@ static bool tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb,
 	if ((skb != tcp_write_queue_tail(sk)) && (limit >= skb->len))
 		goto send_now;
 
-	win_divisor = ACCESS_ONCE(sysctl_tcp_tso_win_divisor);
+	win_divisor = ACCESS_ONCE(sock_net(sk)->ipv4.sysctl_tcp_tso_win_divisor);
 	if (win_divisor) {
 		u32 chunk = min(tp->snd_wnd, tp->snd_cwnd * tp->mss_cache);
 
-- 
2.15.0.rc2.357.g7e34df9404-goog
