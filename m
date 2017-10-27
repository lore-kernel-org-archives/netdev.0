From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 02/15] tcp: Namespace-ify sysctl_tcp_recovery
Date: Thu, 26 Oct 2017 21:54:57 -0700
Message-ID: <20171027045510.5827-3-edumazet@google.com>
References: <20171027045510.5827-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:46653 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751588AbdJ0EzU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 00:55:20 -0400
Received: by mail-io0-f195.google.com with SMTP id 101so10131631ioj.3
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 21:55:20 -0700 (PDT)
In-Reply-To: <20171027045510.5827-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  2 +-
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp_input.c       |  2 +-
 net/ipv4/tcp_ipv4.c        |  1 +
 net/ipv4/tcp_recovery.c    |  2 --
 6 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index a7f39e3ea666a835b6042e4008c86ccaadd14b46..d6ed718075d44cfc0e60995c1e938d588ad261a8 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -129,6 +129,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_window_scaling;
 	int sysctl_tcp_timestamps;
 	int sysctl_tcp_early_retrans;
+	int sysctl_tcp_recovery;
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
 	int sysctl_tcp_fastopen;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index a12b71d4118baa6b939bdeba7380cb3830d46ff0..c7f51534fc44c61a95225e0adc0a1200ea5c0c1c 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -265,7 +265,7 @@ extern int sysctl_tcp_workaround_signed_windows;
 extern int sysctl_tcp_slow_start_after_idle;
 extern int sysctl_tcp_thin_linear_timeouts;
 extern int sysctl_tcp_thin_dupack;
-extern int sysctl_tcp_recovery;
+
 #define TCP_RACK_LOSS_DETECTION  0x1 /* Use RACK to detect losses */
 
 extern int sysctl_tcp_limit_output_bytes;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index f0f650f020afd535f41943c6c9fb1483be7cfb8d..78019adcae875a438264ee47723670f6b54cacf9 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -449,13 +449,6 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
-	{
-		.procname	= "tcp_recovery",
-		.data		= &sysctl_tcp_recovery,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
 	{
 		.procname	= "tcp_max_reordering",
 		.data		= &sysctl_tcp_max_reordering,
@@ -1145,6 +1138,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.extra1		= &zero,
 		.extra2		= &four,
 	},
+	{
+		.procname	= "tcp_recovery",
+		.data		= &init_net.ipv4.sysctl_tcp_recovery,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 7656b1e6d5046297b4c5e6cf5591266b9be40095..5b2272dbf6a9a507d62d8ee594fab53284b22a6d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2788,7 +2788,7 @@ static void tcp_rack_identify_loss(struct sock *sk, int *ack_flag)
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	/* Use RACK to detect loss */
-	if (sysctl_tcp_recovery & TCP_RACK_LOSS_DETECTION) {
+	if (sock_net(sk)->ipv4.sysctl_tcp_recovery & TCP_RACK_LOSS_DETECTION) {
 		u32 prior_retrans = tp->retrans_out;
 
 		tcp_rack_mark_lost(sk);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7ab313f6768e234173d78f17cfb1f664b230e958..517ff1948a71287b06ea0859e1f25a15119a3dd9 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2485,6 +2485,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_window_scaling = 1;
 	net->ipv4.sysctl_tcp_timestamps = 1;
 	net->ipv4.sysctl_tcp_early_retrans = 3;
+	net->ipv4.sysctl_tcp_recovery = TCP_RACK_LOSS_DETECTION;
 
 	net->ipv4.sysctl_tcp_fastopen = TFO_CLIENT_ENABLE;
 	spin_lock_init(&net->ipv4.tcp_fastopen_ctx_lock);
diff --git a/net/ipv4/tcp_recovery.c b/net/ipv4/tcp_recovery.c
index cda6074a429a24b7be600065d95600f4f9810ee4..d3603a9e24eae8649edd12d3f0678015b09b2037 100644
--- a/net/ipv4/tcp_recovery.c
+++ b/net/ipv4/tcp_recovery.c
@@ -1,8 +1,6 @@
 #include <linux/tcp.h>
 #include <net/tcp.h>
 
-int sysctl_tcp_recovery __read_mostly = TCP_RACK_LOSS_DETECTION;
-
 static void tcp_rack_mark_skb_lost(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-- 
2.15.0.rc2.357.g7e34df9404-goog
