From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 08/12] tcp: Namespace-ify sysctl_tcp_min_rtt_wlen
Date: Fri, 27 Oct 2017 07:47:28 -0700
Message-ID: <20171027144732.23885-9-edumazet@google.com>
References: <20171027144732.23885-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:57236 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751755AbdJ0Or4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 10:47:56 -0400
Received: by mail-io0-f196.google.com with SMTP id m81so13197801ioi.13
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 07:47:55 -0700 (PDT)
In-Reply-To: <20171027144732.23885-1-edumazet@google.com>
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
index a2da3e19a977bdf4447339e6b71937eaf7e24c08..1a66af8a0d32424cc80213001f131230d117b61d 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -149,6 +149,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_limit_output_bytes;
 	int sysctl_tcp_challenge_ack_limit;
 	int sysctl_tcp_min_tso_segs;
+	int sysctl_tcp_min_rtt_wlen;
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
 	int sysctl_tcp_fastopen;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 0735303a6575670babef06b23964ab9572aa2a07..56f50c9a3e6a8dd54d44d48bde678a144b10abbf 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -250,7 +250,6 @@ extern int sysctl_tcp_rmem[3];
 
 #define TCP_RACK_LOSS_DETECTION  0x1 /* Use RACK to detect losses */
 
-extern int sysctl_tcp_min_rtt_wlen;
 extern int sysctl_tcp_autocorking;
 extern int sysctl_tcp_invalid_ratelimit;
 extern int sysctl_tcp_pacing_ss_ratio;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 00b4aea3705b21e552ca482eb816ac7023c13565..029692d2e4ae3a4dbf039ac6e5cb916383a833be 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -437,13 +437,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &one,
 	},
-	{
-		.procname	= "tcp_min_rtt_wlen",
-		.data		= &sysctl_tcp_min_rtt_wlen,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
 	{
 		.procname	= "tcp_low_latency",
 		.data		= &sysctl_tcp_low_latency,
@@ -1145,6 +1138,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.extra1		= &one,
 		.extra2		= &gso_max_segs,
 	},
+	{
+		.procname	= "tcp_min_rtt_wlen",
+		.data		= &init_net.ipv4.sysctl_tcp_min_rtt_wlen,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 928048a4e2c5bf5f7875adfe019af88af8244533..da1ef666d1f9bb008fec3fe49852ba273802bd1a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -80,7 +80,6 @@
 #include <linux/static_key.h>
 
 int sysctl_tcp_max_orphans __read_mostly = NR_FILE;
-int sysctl_tcp_min_rtt_wlen __read_mostly = 300;
 int sysctl_tcp_invalid_ratelimit __read_mostly = HZ/2;
 
 #define FLAG_DATA		0x01 /* Incoming frame contained data.		*/
@@ -2915,8 +2914,8 @@ static void tcp_fastretrans_alert(struct sock *sk, const int acked,
 
 static void tcp_update_rtt_min(struct sock *sk, u32 rtt_us)
 {
+	u32 wlen = sock_net(sk)->ipv4.sysctl_tcp_min_rtt_wlen * HZ;
 	struct tcp_sock *tp = tcp_sk(sk);
-	u32 wlen = sysctl_tcp_min_rtt_wlen * HZ;
 
 	minmax_running_min(&tp->rtt_min, wlen, tcp_jiffies32,
 			   rtt_us ? : jiffies_to_usecs(1));
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 6192f26145d36d478ee5115a241c19c3a36a7642..ced35af5737a041aa7aa19336056863da84f989e 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2504,6 +2504,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	/* rfc5961 challenge ack rate limiting */
 	net->ipv4.sysctl_tcp_challenge_ack_limit = 1000;
 	net->ipv4.sysctl_tcp_min_tso_segs = 2;
+	net->ipv4.sysctl_tcp_min_rtt_wlen = 300;
 
 	net->ipv4.sysctl_tcp_fastopen = TFO_CLIENT_ENABLE;
 	spin_lock_init(&net->ipv4.tcp_fastopen_ctx_lock);
-- 
2.15.0.rc2.357.g7e34df9404-goog
