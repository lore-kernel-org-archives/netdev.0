From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 07/12] tcp: Namespace-ify sysctl_tcp_min_tso_segs
Date: Fri, 27 Oct 2017 07:47:27 -0700
Message-ID: <20171027144732.23885-8-edumazet@google.com>
References: <20171027144732.23885-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:45768 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751816AbdJ0Orx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 10:47:53 -0400
Received: by mail-io0-f195.google.com with SMTP id i38so13213370iod.2
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 07:47:53 -0700 (PDT)
In-Reply-To: <20171027144732.23885-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  1 -
 net/ipv4/sysctl_net_ipv4.c | 18 +++++++++---------
 net/ipv4/tcp.c             |  2 --
 net/ipv4/tcp_ipv4.c        |  1 +
 net/ipv4/tcp_output.c      |  3 ++-
 6 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index e9895d40868e609dc460755b13a85cdcc82c053e..a2da3e19a977bdf4447339e6b71937eaf7e24c08 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -148,6 +148,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_workaround_signed_windows;
 	int sysctl_tcp_limit_output_bytes;
 	int sysctl_tcp_challenge_ack_limit;
+	int sysctl_tcp_min_tso_segs;
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
 	int sysctl_tcp_fastopen;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index afc23596e9aa30fe6b4ed64049b3f55b6760be2b..0735303a6575670babef06b23964ab9572aa2a07 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -250,7 +250,6 @@ extern int sysctl_tcp_rmem[3];
 
 #define TCP_RACK_LOSS_DETECTION  0x1 /* Use RACK to detect losses */
 
-extern int sysctl_tcp_min_tso_segs;
 extern int sysctl_tcp_min_rtt_wlen;
 extern int sysctl_tcp_autocorking;
 extern int sysctl_tcp_invalid_ratelimit;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index e28b3b7a7bbc75d3eb20718caef18d03bea79f95..00b4aea3705b21e552ca482eb816ac7023c13565 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -499,15 +499,6 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler   = proc_allowed_congestion_control,
 	},
-	{
-		.procname	= "tcp_min_tso_segs",
-		.data		= &sysctl_tcp_min_tso_segs,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &one,
-		.extra2		= &gso_max_segs,
-	},
 	{
 		.procname	= "tcp_pacing_ss_ratio",
 		.data		= &sysctl_tcp_pacing_ss_ratio,
@@ -1145,6 +1136,15 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "tcp_min_tso_segs",
+		.data		= &init_net.ipv4.sysctl_tcp_min_tso_segs,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &one,
+		.extra2		= &gso_max_segs,
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index c7c983f0f817c639e68f6fb1a70916cb604de90b..a01c97708d8388cdb44577597f76837b35ea7047 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -285,8 +285,6 @@
 
 #include <trace/events/tcp.h>
 
-int sysctl_tcp_min_tso_segs __read_mostly = 2;
-
 int sysctl_tcp_autocorking __read_mostly = 1;
 
 struct percpu_counter tcp_orphan_count;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 50ab3a3eced342846f57a93f0ec8c7d5ae0d7e32..6192f26145d36d478ee5115a241c19c3a36a7642 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2503,6 +2503,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_limit_output_bytes = 262144;
 	/* rfc5961 challenge ack rate limiting */
 	net->ipv4.sysctl_tcp_challenge_ack_limit = 1000;
+	net->ipv4.sysctl_tcp_min_tso_segs = 2;
 
 	net->ipv4.sysctl_tcp_fastopen = TFO_CLIENT_ENABLE;
 	spin_lock_init(&net->ipv4.tcp_fastopen_ctx_lock);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index f018892c6a98ca7b806570995474bd394d9ab427..aab6e7145013e5a77fa989c66e8b5f6937158bbf 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1758,7 +1758,8 @@ static u32 tcp_tso_segs(struct sock *sk, unsigned int mss_now)
 	u32 tso_segs = ca_ops->tso_segs_goal ? ca_ops->tso_segs_goal(sk) : 0;
 
 	return tso_segs ? :
-		tcp_tso_autosize(sk, mss_now, sysctl_tcp_min_tso_segs);
+		tcp_tso_autosize(sk, mss_now,
+				 sock_net(sk)->ipv4.sysctl_tcp_min_tso_segs);
 }
 
 /* Returns the portion of skb which can be sent right away */
-- 
2.15.0.rc2.357.g7e34df9404-goog
