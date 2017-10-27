From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 09/12] tcp: Namespace-ify sysctl_tcp_autocorking
Date: Fri, 27 Oct 2017 07:47:29 -0700
Message-ID: <20171027144732.23885-10-edumazet@google.com>
References: <20171027144732.23885-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:46320 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751907AbdJ0Or6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 10:47:58 -0400
Received: by mail-io0-f195.google.com with SMTP id 101so13221809ioj.3
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 07:47:58 -0700 (PDT)
In-Reply-To: <20171027144732.23885-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  1 -
 net/ipv4/sysctl_net_ipv4.c | 18 +++++++++---------
 net/ipv4/tcp.c             |  4 +---
 net/ipv4/tcp_ipv4.c        |  1 +
 5 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 1a66af8a0d32424cc80213001f131230d117b61d..537830882149c3c18c8c0b5b50b8ecded46fad09 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -150,6 +150,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_challenge_ack_limit;
 	int sysctl_tcp_min_tso_segs;
 	int sysctl_tcp_min_rtt_wlen;
+	int sysctl_tcp_autocorking;
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
 	int sysctl_tcp_fastopen;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 56f50c9a3e6a8dd54d44d48bde678a144b10abbf..0268f1025d9d5fa24046b383f4fde5fb660712fd 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -250,7 +250,6 @@ extern int sysctl_tcp_rmem[3];
 
 #define TCP_RACK_LOSS_DETECTION  0x1 /* Use RACK to detect losses */
 
-extern int sysctl_tcp_autocorking;
 extern int sysctl_tcp_invalid_ratelimit;
 extern int sysctl_tcp_pacing_ss_ratio;
 extern int sysctl_tcp_pacing_ca_ratio;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 029692d2e4ae3a4dbf039ac6e5cb916383a833be..43a18a3170531ca9ea490fc5bb251cb9c9b8b889 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -510,15 +510,6 @@ static struct ctl_table ipv4_table[] = {
 		.extra1		= &zero,
 		.extra2		= &thousand,
 	},
-	{
-		.procname	= "tcp_autocorking",
-		.data		= &sysctl_tcp_autocorking,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &zero,
-		.extra2		= &one,
-	},
 	{
 		.procname	= "tcp_invalid_ratelimit",
 		.data		= &sysctl_tcp_invalid_ratelimit,
@@ -1145,6 +1136,15 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "tcp_autocorking",
+		.data		= &init_net.ipv4.sysctl_tcp_autocorking,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &one,
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index a01c97708d8388cdb44577597f76837b35ea7047..a7a0f316eb86f491f648187c051ea0fe7875c207 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -285,8 +285,6 @@
 
 #include <trace/events/tcp.h>
 
-int sysctl_tcp_autocorking __read_mostly = 1;
-
 struct percpu_counter tcp_orphan_count;
 EXPORT_SYMBOL_GPL(tcp_orphan_count);
 
@@ -697,7 +695,7 @@ static bool tcp_should_autocork(struct sock *sk, struct sk_buff *skb,
 				int size_goal)
 {
 	return skb->len < size_goal &&
-	       sysctl_tcp_autocorking &&
+	       sock_net(sk)->ipv4.sysctl_tcp_autocorking &&
 	       skb != tcp_write_queue_head(sk) &&
 	       refcount_read(&sk->sk_wmem_alloc) > skb->truesize;
 }
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ced35af5737a041aa7aa19336056863da84f989e..351e3497c8f3ae565114c80465f149c7341b8272 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2505,6 +2505,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_challenge_ack_limit = 1000;
 	net->ipv4.sysctl_tcp_min_tso_segs = 2;
 	net->ipv4.sysctl_tcp_min_rtt_wlen = 300;
+	net->ipv4.sysctl_tcp_autocorking = 1;
 
 	net->ipv4.sysctl_tcp_fastopen = TFO_CLIENT_ENABLE;
 	spin_lock_init(&net->ipv4.tcp_fastopen_ctx_lock);
-- 
2.15.0.rc2.357.g7e34df9404-goog
