From: Nikolay Borisov <kernel@kyup.com>
Subject: [PATCH 8/9] ipv4: Namespaceify tcp_fin_timeout sysctl knob
Date: Mon, 11 Jan 2016 11:51:54 +0200
Message-ID: <1452505915-19912-9-git-send-email-kernel@kyup.com>
References: <1452505915-19912-1-git-send-email-kernel@kyup.com>
Cc: linux-kernel@vger.kernel.org, edumazet@google.com,
	kuznet@ms2.inr.ac.ru, kaber@trash.net, ebiederm@xmission.com,
	operations@siteground.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:33601 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759009AbcAKJwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 04:52:07 -0500
Received: by mail-wm0-f51.google.com with SMTP id f206so205421611wmf.0
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 01:52:07 -0800 (PST)
In-Reply-To: <1452505915-19912-1-git-send-email-kernel@kyup.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nikolay Borisov <kernel@kyup.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  3 +--
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp.c             |  7 +++----
 net/ipv4/tcp_ipv4.c        |  1 +
 5 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 6903335fbe3a..a1caddadecc2 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -102,6 +102,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_retries1;
 	int sysctl_tcp_retries2;
 	int sysctl_tcp_orphan_retries;
+	int sysctl_tcp_fin_timeout;
 
 	struct ping_group_range ping_group_range;
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 606a0a1a6d15..f8c3f75e6c99 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -239,7 +239,6 @@ extern struct inet_timewait_death_row tcp_death_row;
 extern int sysctl_tcp_timestamps;
 extern int sysctl_tcp_window_scaling;
 extern int sysctl_tcp_sack;
-extern int sysctl_tcp_fin_timeout;
 extern int sysctl_tcp_fastopen;
 extern int sysctl_tcp_retrans_collapse;
 extern int sysctl_tcp_stdurg;
@@ -1245,7 +1244,7 @@ static inline u32 keepalive_time_elapsed(const struct tcp_sock *tp)
 
 static inline int tcp_fin_time(const struct sock *sk)
 {
-	int fin_timeout = tcp_sk(sk)->linger2 ? : sysctl_tcp_fin_timeout;
+	int fin_timeout = tcp_sk(sk)->linger2 ? : sock_net(sk)->ipv4.sysctl_tcp_fin_timeout;
 	const int rto = inet_csk(sk)->icsk_rto;
 
 	if (fin_timeout < (rto << 2) - (rto >> 1))
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index e866e9fe6d84..20e086f88438 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -321,13 +321,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.procname	= "tcp_fin_timeout",
-		.data		= &sysctl_tcp_fin_timeout,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
 		.procname	= "tcp_fastopen",
 		.data		= &sysctl_tcp_fastopen,
 		.maxlen		= sizeof(int),
@@ -950,6 +943,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "tcp_fin_timeout",
+		.data		= &init_net.ipv4.sysctl_tcp_fin_timeout,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index d0547395d81d..ad903790c0a4 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -281,8 +281,6 @@
 #include <asm/ioctls.h>
 #include <net/busy_poll.h>
 
-int sysctl_tcp_fin_timeout __read_mostly = TCP_FIN_TIMEOUT;
-
 int sysctl_tcp_min_tso_segs __read_mostly = 2;
 
 int sysctl_tcp_autocorking __read_mostly = 1;
@@ -2324,6 +2322,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
+	struct net *net = sock_net(sk);
 	int val;
 	int err = 0;
 
@@ -2520,7 +2519,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 	case TCP_LINGER2:
 		if (val < 0)
 			tp->linger2 = -1;
-		else if (val > sysctl_tcp_fin_timeout / HZ)
+		else if (val > net->ipv4.sysctl_tcp_fin_timeout / HZ)
 			tp->linger2 = 0;
 		else
 			tp->linger2 = val * HZ;
@@ -2762,7 +2761,7 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 	case TCP_LINGER2:
 		val = tp->linger2;
 		if (val >= 0)
-			val = (val ? : sysctl_tcp_fin_timeout) / HZ;
+			val = (val ? : net->ipv4.sysctl_tcp_fin_timeout) / HZ;
 		break;
 	case TCP_DEFER_ACCEPT:
 		val = retrans_to_secs(icsk->icsk_accept_queue.rskq_defer_accept,
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index fc4d4ee38012..3c263c00f5ea 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2388,6 +2388,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_retries1 = TCP_RETR1;
 	net->ipv4.sysctl_tcp_retries2 = TCP_RETR2;
 	net->ipv4.sysctl_tcp_orphan_retries = 0;
+	net->ipv4.sysctl_tcp_fin_timeout = TCP_FIN_TIMEOUT;
 
 	return 0;
 fail:
-- 
2.5.0
