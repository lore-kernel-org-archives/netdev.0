From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH] ipv4: Namespaceify tcp_tw_reuse knob
Date: Sat, 24 Dec 2016 20:43:07 +0800
Message-ID: <1482583387-79777-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>,
        lexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  1 -
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp_ipv4.c        |  4 ++--
 4 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index f0cf5a1..0378e88 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -110,6 +110,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_orphan_retries;
 	int sysctl_tcp_fin_timeout;
 	unsigned int sysctl_tcp_notsent_lowat;
+	int sysctl_tcp_tw_reuse;
 
 	int sysctl_igmp_max_memberships;
 	int sysctl_igmp_max_msf;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 207147b..6061963 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -252,7 +252,6 @@
 extern int sysctl_tcp_rmem[3];
 extern int sysctl_tcp_app_win;
 extern int sysctl_tcp_adv_win_scale;
-extern int sysctl_tcp_tw_reuse;
 extern int sysctl_tcp_frto;
 extern int sysctl_tcp_low_latency;
 extern int sysctl_tcp_nometrics_save;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 80bc36b..22cbd61 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -433,13 +433,6 @@ static int proc_tcp_fastopen_key(struct ctl_table *ctl, int write,
 		.extra2		= &tcp_adv_win_scale_max,
 	},
 	{
-		.procname	= "tcp_tw_reuse",
-		.data		= &sysctl_tcp_tw_reuse,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
-	{
 		.procname	= "tcp_frto",
 		.data		= &sysctl_tcp_frto,
 		.maxlen		= sizeof(int),
@@ -960,6 +953,13 @@ static int proc_tcp_fastopen_key(struct ctl_table *ctl, int write,
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname	= "tcp_tw_reuse",
+		.data		= &init_net.ipv4.sysctl_tcp_tw_reuse,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	{
 		.procname	= "fib_multipath_use_neigh",
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 30d81f5..fe9da4f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -84,7 +84,6 @@
 #include <crypto/hash.h>
 #include <linux/scatterlist.h>
 
-int sysctl_tcp_tw_reuse __read_mostly;
 int sysctl_tcp_low_latency __read_mostly;
 
 #ifdef CONFIG_TCP_MD5SIG
@@ -120,7 +119,7 @@ int tcp_twsk_unique(struct sock *sk, struct sock *sktw, void *twp)
 	   and use initial timestamp retrieved from peer table.
 	 */
 	if (tcptw->tw_ts_recent_stamp &&
-	    (!twp || (sysctl_tcp_tw_reuse &&
+	    (!twp || (sock_net(sk)->ipv4.sysctl_tcp_tw_reuse &&
 			     get_seconds() - tcptw->tw_ts_recent_stamp > 1))) {
 		tp->write_seq = tcptw->tw_snd_nxt + 65535 + 2;
 		if (tp->write_seq == 0)
@@ -2456,6 +2455,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_orphan_retries = 0;
 	net->ipv4.sysctl_tcp_fin_timeout = TCP_FIN_TIMEOUT;
 	net->ipv4.sysctl_tcp_notsent_lowat = UINT_MAX;
+	net->ipv4.sysctl_tcp_tw_reuse = 0;
 
 	return 0;
 fail:
-- 
1.8.3.1
