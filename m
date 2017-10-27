From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 10/12] tcp: Namespace-ify sysctl_tcp_invalid_ratelimit
Date: Fri, 27 Oct 2017 07:47:30 -0700
Message-ID: <20171027144732.23885-11-edumazet@google.com>
References: <20171027144732.23885-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:44524 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751785AbdJ0OsA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 10:48:00 -0400
Received: by mail-io0-f193.google.com with SMTP id m16so13221597iod.1
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 07:48:00 -0700 (PDT)
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
index 537830882149c3c18c8c0b5b50b8ecded46fad09..e52c2124b32e799f32943621cc0cc55dc7d8413d 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -151,6 +151,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_min_tso_segs;
 	int sysctl_tcp_min_rtt_wlen;
 	int sysctl_tcp_autocorking;
+	int sysctl_tcp_invalid_ratelimit;
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
 	int sysctl_tcp_fastopen;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 0268f1025d9d5fa24046b383f4fde5fb660712fd..5869a822ecb1b8f350cb393b4b43343ccf206eb5 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -250,7 +250,6 @@ extern int sysctl_tcp_rmem[3];
 
 #define TCP_RACK_LOSS_DETECTION  0x1 /* Use RACK to detect losses */
 
-extern int sysctl_tcp_invalid_ratelimit;
 extern int sysctl_tcp_pacing_ss_ratio;
 extern int sysctl_tcp_pacing_ca_ratio;
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 43a18a3170531ca9ea490fc5bb251cb9c9b8b889..6a9349c27f00b1a665b969fe0291d195ec473e3e 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -510,13 +510,6 @@ static struct ctl_table ipv4_table[] = {
 		.extra1		= &zero,
 		.extra2		= &thousand,
 	},
-	{
-		.procname	= "tcp_invalid_ratelimit",
-		.data		= &sysctl_tcp_invalid_ratelimit,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_ms_jiffies,
-	},
 	{
 		.procname	= "tcp_available_ulp",
 		.maxlen		= TCP_ULP_BUF_MAX,
@@ -1145,6 +1138,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.extra1		= &zero,
 		.extra2		= &one,
 	},
+	{
+		.procname	= "tcp_invalid_ratelimit",
+		.data		= &init_net.ipv4.sysctl_tcp_invalid_ratelimit,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_ms_jiffies,
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index da1ef666d1f9bb008fec3fe49852ba273802bd1a..db4d458d0205027681f96498019a5fd0bb0303b8 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -80,7 +80,6 @@
 #include <linux/static_key.h>
 
 int sysctl_tcp_max_orphans __read_mostly = NR_FILE;
-int sysctl_tcp_invalid_ratelimit __read_mostly = HZ/2;
 
 #define FLAG_DATA		0x01 /* Incoming frame contained data.		*/
 #define FLAG_WIN_UPDATE		0x02 /* Incoming ACK was a window update.	*/
@@ -3403,7 +3402,7 @@ static bool __tcp_oow_rate_limited(struct net *net, int mib_idx,
 	if (*last_oow_ack_time) {
 		s32 elapsed = (s32)(tcp_jiffies32 - *last_oow_ack_time);
 
-		if (0 <= elapsed && elapsed < sysctl_tcp_invalid_ratelimit) {
+		if (0 <= elapsed && elapsed < net->ipv4.sysctl_tcp_invalid_ratelimit) {
 			NET_INC_STATS(net, mib_idx);
 			return true;	/* rate-limited: don't send yet! */
 		}
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 351e3497c8f3ae565114c80465f149c7341b8272..6617aae18ba2e2ad23663708a39311b0e987522d 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2506,6 +2506,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_min_tso_segs = 2;
 	net->ipv4.sysctl_tcp_min_rtt_wlen = 300;
 	net->ipv4.sysctl_tcp_autocorking = 1;
+	net->ipv4.sysctl_tcp_invalid_ratelimit = HZ/2;
 
 	net->ipv4.sysctl_tcp_fastopen = TFO_CLIENT_ENABLE;
 	spin_lock_init(&net->ipv4.tcp_fastopen_ctx_lock);
-- 
2.15.0.rc2.357.g7e34df9404-goog
