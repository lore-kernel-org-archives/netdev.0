From: Nikolay Borisov <kernel@kyup.com>
Subject: [PATCH 9/9] ipv4: Namespaceify tcp_notsent_lowat sysctl knob
Date: Mon, 11 Jan 2016 11:51:55 +0200
Message-ID: <1452505915-19912-10-git-send-email-kernel@kyup.com>
References: <1452505915-19912-1-git-send-email-kernel@kyup.com>
Cc: linux-kernel@vger.kernel.org, edumazet@google.com,
	kuznet@ms2.inr.ac.ru, kaber@trash.net, ebiederm@xmission.com,
	operations@siteground.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452505915-19912-1-git-send-email-kernel@kyup.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Nikolay Borisov <kernel@kyup.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  4 ++--
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp_ipv4.c        |  1 +
 net/ipv4/tcp_output.c      |  3 ---
 5 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index a1caddadecc2..df265ea5bc72 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -103,6 +103,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_retries2;
 	int sysctl_tcp_orphan_retries;
 	int sysctl_tcp_fin_timeout;
+	unsigned int sysctl_tcp_notsent_lowat;
 
 	struct ping_group_range ping_group_range;
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index f8c3f75e6c99..83de2b9f970e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -267,7 +267,6 @@ extern int sysctl_tcp_thin_dupack;
 extern int sysctl_tcp_early_retrans;
 extern int sysctl_tcp_limit_output_bytes;
 extern int sysctl_tcp_challenge_ack_limit;
-extern unsigned int sysctl_tcp_notsent_lowat;
 extern int sysctl_tcp_min_tso_segs;
 extern int sysctl_tcp_min_rtt_wlen;
 extern int sysctl_tcp_autocorking;
@@ -1665,7 +1664,8 @@ void __tcp_v4_send_check(struct sk_buff *skb, __be32 saddr, __be32 daddr);
 
 static inline u32 tcp_notsent_lowat(const struct tcp_sock *tp)
 {
-	return tp->notsent_lowat ?: sysctl_tcp_notsent_lowat;
+	struct net *net = sock_net((struct sock *)tp);
+	return tp->notsent_lowat ?: net->ipv4.sysctl_tcp_notsent_lowat;
 }
 
 static inline bool tcp_stream_memory_free(const struct sock *sk)
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 20e086f88438..23afa08641c2 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -457,13 +457,6 @@ static struct ctl_table ipv4_table[] = {
 		.extra1		= &one,
 	},
 	{
-		.procname	= "tcp_notsent_lowat",
-		.data		= &sysctl_tcp_notsent_lowat,
-		.maxlen		= sizeof(sysctl_tcp_notsent_lowat),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
-	{
 		.procname	= "tcp_rmem",
 		.data		= &sysctl_tcp_rmem,
 		.maxlen		= sizeof(sysctl_tcp_rmem),
@@ -950,6 +943,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
+	{
+		.procname	= "tcp_notsent_lowat",
+		.data		= &init_net.ipv4.sysctl_tcp_notsent_lowat,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 3c263c00f5ea..2871acf8f4b9 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2389,6 +2389,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_retries2 = TCP_RETR2;
 	net->ipv4.sysctl_tcp_orphan_retries = 0;
 	net->ipv4.sysctl_tcp_fin_timeout = TCP_FIN_TIMEOUT;
+	net->ipv4.sysctl_tcp_notsent_lowat = UINT_MAX;
 
 	return 0;
 fail:
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index e997488b2f8f..54455739e851 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -62,9 +62,6 @@ int sysctl_tcp_tso_win_divisor __read_mostly = 3;
 /* By default, RFC2861 behavior.  */
 int sysctl_tcp_slow_start_after_idle __read_mostly = 1;
 
-unsigned int sysctl_tcp_notsent_lowat __read_mostly = UINT_MAX;
-EXPORT_SYMBOL(sysctl_tcp_notsent_lowat);
-
 static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 			   int push_one, gfp_t gfp);
 
-- 
2.5.0
