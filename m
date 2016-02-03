From: Nikolay Borisov <kernel@kyup.com>
Subject: [RESEND PATCH 1/9] ipv4: Namespaceify tcp syn retries sysctl knob
Date: Wed,  3 Feb 2016 09:46:49 +0200
Message-ID: <1454485617-16541-2-git-send-email-kernel@kyup.com>
References: <1454485617-16541-1-git-send-email-kernel@kyup.com>
Cc: edumazet@google.com, ebiederm@xmission.com, fan.du@intel.com,
	kaber@trash.net, jmorris@namei.org, alexander.h.duyck@redhat.com,
	kuznet@ms2.inr.ac.ru
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:36109 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933414AbcBCHrE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 02:47:04 -0500
Received: by mail-wm0-f48.google.com with SMTP id p63so151842396wmp.1
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 23:47:03 -0800 (PST)
In-Reply-To: <1454485617-16541-1-git-send-email-kernel@kyup.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nikolay Borisov <kernel@kyup.com>
---
 include/net/netns/ipv4.h   |  2 ++
 include/net/tcp.h          |  1 -
 net/ipv4/sysctl_net_ipv4.c | 18 +++++++++---------
 net/ipv4/tcp.c             |  3 ++-
 net/ipv4/tcp_ipv4.c        |  2 ++
 net/ipv4/tcp_timer.c       |  4 ++--
 6 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index ffa2777b6475..59c6155e4896 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -95,6 +95,8 @@ struct netns_ipv4 {
 	int sysctl_tcp_keepalive_probes;
 	int sysctl_tcp_keepalive_intvl;
 
+	int sysctl_tcp_syn_retries;
+
 	struct ping_group_range ping_group_range;
 
 	atomic_t dev_addr_genid;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 3ed10fc89c7d..a7f6f25297d7 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -240,7 +240,6 @@ extern int sysctl_tcp_timestamps;
 extern int sysctl_tcp_window_scaling;
 extern int sysctl_tcp_sack;
 extern int sysctl_tcp_fin_timeout;
-extern int sysctl_tcp_syn_retries;
 extern int sysctl_tcp_synack_retries;
 extern int sysctl_tcp_retries1;
 extern int sysctl_tcp_retries2;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index fccf8e92bf81..db95287d2b94 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -293,15 +293,6 @@ static struct ctl_table ipv4_table[] = {
 		.extra2		= &ip_ttl_max,
 	},
 	{
-		.procname	= "tcp_syn_retries",
-		.data		= &sysctl_tcp_syn_retries,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &tcp_syn_retries_min,
-		.extra2		= &tcp_syn_retries_max
-	},
-	{
 		.procname	= "tcp_synack_retries",
 		.data		= &sysctl_tcp_synack_retries,
 		.maxlen		= sizeof(int),
@@ -950,6 +941,15 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
+	{
+		.procname	= "tcp_syn_retries",
+		.data		= &init_net.ipv4.sysctl_tcp_syn_retries,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &tcp_syn_retries_min,
+		.extra2		= &tcp_syn_retries_max
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index c82cca18c90f..bb36a39b5685 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2722,6 +2722,7 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct net *net = sock_net(sk);
 	int val, len;
 
 	if (get_user(len, optlen))
@@ -2756,7 +2757,7 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
 		val = keepalive_probes(tp);
 		break;
 	case TCP_SYNCNT:
-		val = icsk->icsk_syn_retries ? : sysctl_tcp_syn_retries;
+		val = icsk->icsk_syn_retries ? : net->ipv4.sysctl_tcp_syn_retries;
 		break;
 	case TCP_LINGER2:
 		val = tp->linger2;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 9db9bdb14449..c9944e0c48d3 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2382,6 +2382,8 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_keepalive_probes = TCP_KEEPALIVE_PROBES;
 	net->ipv4.sysctl_tcp_keepalive_intvl = TCP_KEEPALIVE_INTVL;
 
+	net->ipv4.sysctl_tcp_syn_retries = TCP_SYN_RETRIES;
+
 	return 0;
 fail:
 	tcp_sk_exit(net);
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index a4730a28b220..c5d51f530c65 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -22,7 +22,6 @@
 #include <linux/gfp.h>
 #include <net/tcp.h>
 
-int sysctl_tcp_syn_retries __read_mostly = TCP_SYN_RETRIES;
 int sysctl_tcp_synack_retries __read_mostly = TCP_SYNACK_RETRIES;
 int sysctl_tcp_retries1 __read_mostly = TCP_RETR1;
 int sysctl_tcp_retries2 __read_mostly = TCP_RETR2;
@@ -157,6 +156,7 @@ static int tcp_write_timeout(struct sock *sk)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct net *net = sock_net(sk);
 	int retry_until;
 	bool do_reset, syn_set = false;
 
@@ -169,7 +169,7 @@ static int tcp_write_timeout(struct sock *sk)
 				NET_INC_STATS_BH(sock_net(sk),
 						 LINUX_MIB_TCPFASTOPENACTIVEFAIL);
 		}
-		retry_until = icsk->icsk_syn_retries ? : sysctl_tcp_syn_retries;
+		retry_until = icsk->icsk_syn_retries ? : net->ipv4.sysctl_tcp_syn_retries;
 		syn_set = true;
 	} else {
 		if (retransmits_timed_out(sk, sysctl_tcp_retries1, 0, 0)) {
-- 
2.5.0
