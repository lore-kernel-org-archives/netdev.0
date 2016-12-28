From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH 2/2] ipv4: Namespaceify tcp_max_syn_backlog knob
Date: Wed, 28 Dec 2016 17:52:33 +0800
Message-ID: <1482918753-1235-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
References: <1482918753-1235-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Nikolay Borisov <kernel@kyup.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482918753-1235-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Different namespace application might require different maximal
number of remembered connection requests.

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/request_sock.h |  4 +---
 net/core/request_sock.c    |  2 --
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp.c             |  2 --
 net/ipv4/tcp_input.c       |  4 ++--
 net/ipv4/tcp_ipv4.c        |  7 +++++--
 7 files changed, 16 insertions(+), 18 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 99becaf..96b15a2 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -122,6 +122,7 @@ struct netns_ipv4 {
 	unsigned int sysctl_tcp_notsent_lowat;
 	int sysctl_tcp_tw_reuse;
 	struct inet_timewait_death_row tcp_death_row; 
+	int sysctl_max_syn_backlog;
 
 	int sysctl_igmp_max_memberships;
 	int sysctl_igmp_max_msf;
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 6ebe13e..a12a5d2 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -1,7 +1,7 @@
 /*
  * NET		Generic infrastructure for Network protocols.
  *
- *		Definitions for request_sock 
+ *		Definitions for request_sock
  *
  * Authors:	Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  *
@@ -123,8 +123,6 @@ static inline void reqsk_put(struct request_sock *req)
 		reqsk_free(req);
 }
 
-extern int sysctl_max_syn_backlog;
-
 /*
  * For a TCP Fast Open listener -
  *	lock - protects the access to all the reqsk, which is co-owned by
diff --git a/net/core/request_sock.c b/net/core/request_sock.c
index 5d26056..9b8727c 100644
--- a/net/core/request_sock.c
+++ b/net/core/request_sock.c
@@ -34,8 +34,6 @@
  * and it will increase in proportion to the memory of machine.
  * Note : Dont forget somaxconn that may limit backlog too.
  */
-int sysctl_max_syn_backlog = 256;
-EXPORT_SYMBOL(sysctl_max_syn_backlog);
 
 void reqsk_queue_alloc(struct request_sock_queue *queue)
 {
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 66f8f1b..134d8e1 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -324,13 +324,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.procname	= "tcp_max_syn_backlog",
-		.data		= &sysctl_max_syn_backlog,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
-	{
 		.procname	= "inet_peer_threshold",
 		.data		= &inet_peer_threshold,
 		.maxlen		= sizeof(int),
@@ -960,6 +953,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "tcp_max_syn_backlog",
+		.data		= &init_net.ipv4.sysctl_max_syn_backlog,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	{
 		.procname	= "fib_multipath_use_neigh",
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 91938c9..f0637a9 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3378,9 +3378,7 @@ void __init tcp_init(void)
 
 
 	cnt = tcp_hashinfo.ehash_mask + 1;
-
 	sysctl_tcp_max_orphans = cnt / 2;
-	sysctl_max_syn_backlog = max(128, cnt / 256);
 
 	tcp_init_mem();
 	/* Set per-socket limits to no more than 1/128 the pressure threshold */
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c614802..ec6d843 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -6377,8 +6377,8 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
 		}
 		/* Kill the following clause, if you dislike this way. */
 		else if (!net->ipv4.sysctl_tcp_syncookies &&
-			 (sysctl_max_syn_backlog - inet_csk_reqsk_queue_len(sk) <
-			  (sysctl_max_syn_backlog >> 2)) &&
+			 (net->ipv4.sysctl_max_syn_backlog - inet_csk_reqsk_queue_len(sk) <
+			  (net->ipv4.sysctl_max_syn_backlog >> 2)) &&
 			 !tcp_peer_is_proven(req, dst, false,
 					     tmp_opt.saw_tstamp)) {
 			/* Without syncookies last quarter of
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 56b5f49..7e4be4f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2419,7 +2419,7 @@ static void __net_exit tcp_sk_exit(struct net *net)
 
 static int __net_init tcp_sk_init(struct net *net)
 {
-	int res, cpu;
+	int res, cpu, cnt;
 
 	net->ipv4.tcp_sk = alloc_percpu(struct sock *);
 	if (!net->ipv4.tcp_sk)
@@ -2458,10 +2458,13 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_notsent_lowat = UINT_MAX;
 	net->ipv4.sysctl_tcp_tw_reuse = 0;
 
+	cnt = tcp_hashinfo.ehash_mask + 1;
 	net->ipv4.tcp_death_row.sysctl_tw_recycle = 0;
-	net->ipv4.tcp_death_row.sysctl_max_tw_buckets = (tcp_hashinfo.ehash_mask + 1) / 2;
+	net->ipv4.tcp_death_row.sysctl_max_tw_buckets = (cnt + 1) / 2;
 	net->ipv4.tcp_death_row.hashinfo = &tcp_hashinfo;
 
+	net->ipv4.sysctl_max_syn_backlog = max(128, cnt / 256);
+
 	return 0;
 fail:
 	tcp_sk_exit(net);
-- 
2.5.0
