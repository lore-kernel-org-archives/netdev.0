From: Nikolay Borisov <kernel@kyup.com>
Subject: [PATCH 7/9] ipv4: Namespaceify tcp_orphan_retries sysctl knob
Date: Mon, 11 Jan 2016 11:51:53 +0200
Message-ID: <1452505915-19912-8-git-send-email-kernel@kyup.com>
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
 include/net/tcp.h          |  1 -
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp_ipv4.c        |  1 +
 net/ipv4/tcp_timer.c       |  3 +--
 5 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 3cb2073c55f5..6903335fbe3a 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -101,6 +101,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_reordering;
 	int sysctl_tcp_retries1;
 	int sysctl_tcp_retries2;
+	int sysctl_tcp_orphan_retries;
 
 	struct ping_group_range ping_group_range;
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 9b3aabbac85e..606a0a1a6d15 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -240,7 +240,6 @@ extern int sysctl_tcp_timestamps;
 extern int sysctl_tcp_window_scaling;
 extern int sysctl_tcp_sack;
 extern int sysctl_tcp_fin_timeout;
-extern int sysctl_tcp_orphan_retries;
 extern int sysctl_tcp_fastopen;
 extern int sysctl_tcp_retrans_collapse;
 extern int sysctl_tcp_stdurg;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 39c302fda534..e866e9fe6d84 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -421,13 +421,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
-		.procname	= "tcp_orphan_retries",
-		.data		= &sysctl_tcp_orphan_retries,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
-	{
 		.procname	= "tcp_fack",
 		.data		= &sysctl_tcp_fack,
 		.maxlen		= sizeof(int),
@@ -950,6 +943,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "tcp_orphan_retries",
+		.data		= &init_net.ipv4.sysctl_tcp_orphan_retries,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 3a2db4a7d651..fc4d4ee38012 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2387,6 +2387,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_reordering = TCP_FASTRETRANS_THRESH;
 	net->ipv4.sysctl_tcp_retries1 = TCP_RETR1;
 	net->ipv4.sysctl_tcp_retries2 = TCP_RETR2;
+	net->ipv4.sysctl_tcp_orphan_retries = 0;
 
 	return 0;
 fail:
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 09f4e0297e56..49bc474f8e35 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -22,7 +22,6 @@
 #include <linux/gfp.h>
 #include <net/tcp.h>
 
-int sysctl_tcp_orphan_retries __read_mostly;
 int sysctl_tcp_thin_linear_timeouts __read_mostly;
 
 static void tcp_write_err(struct sock *sk)
@@ -78,7 +77,7 @@ static int tcp_out_of_resources(struct sock *sk, bool do_reset)
 /* Calculate maximal number or retries on an orphaned socket. */
 static int tcp_orphan_retries(struct sock *sk, bool alive)
 {
-	int retries = sysctl_tcp_orphan_retries; /* May be zero. */
+	int retries = sock_net(sk)->ipv4.sysctl_tcp_orphan_retries; /* May be zero. */
 
 	/* We know from an ICMP that something is wrong. */
 	if (sk->sk_err_soft && !alive)
-- 
2.5.0
