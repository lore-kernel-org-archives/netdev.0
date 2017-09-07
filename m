From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH] ipv4: Namespaceify tcp_max_orphans knob
Date: Thu,  7 Sep 2017 11:10:08 +0800
Message-ID: <1504753808-13266-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Different namespace application might require different maximal number
of TCP sockets independently of the host.

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  5 +++--
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp.c             |  3 ---
 net/ipv4/tcp_input.c       |  1 -
 net/ipv4/tcp_ipv4.c        |  1 +
 6 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 20d061c..305e031 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -127,6 +127,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_timestamps;
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
+	int sysctl_tcp_max_orphans;
 
 #ifdef CONFIG_NET_L3_MASTER_DEV
 	int sysctl_udp_l3mdev_accept;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index b510f28..ac2d998 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -320,10 +320,11 @@ static inline bool tcp_too_many_orphans(struct sock *sk, int shift)
 {
 	struct percpu_counter *ocp = sk->sk_prot->orphan_count;
 	int orphans = percpu_counter_read_positive(ocp);
+	int tcp_max_orphans = sock_net(sk)->ipv4.sysctl_tcp_max_orphans;
 
-	if (orphans << shift > sysctl_tcp_max_orphans) {
+	if (orphans << shift > tcp_max_orphans) {
 		orphans = percpu_counter_sum_positive(ocp);
-		if (orphans << shift > sysctl_tcp_max_orphans)
+		if (orphans << shift > tcp_max_orphans)
 			return true;
 	}
 	return false;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 0d3c038..4f26c8d3 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -394,13 +394,6 @@ static int proc_tcp_available_ulp(struct ctl_table *ctl,
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.procname	= "tcp_max_orphans",
-		.data		= &sysctl_tcp_max_orphans,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
-	{
 		.procname	= "tcp_fastopen",
 		.data		= &sysctl_tcp_fastopen,
 		.maxlen		= sizeof(int),
@@ -1085,6 +1078,13 @@ static int proc_tcp_available_ulp(struct ctl_table *ctl,
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "tcp_max_orphans",
+		.data		= &init_net.ipv4.sysctl_tcp_max_orphans,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	{
 		.procname	= "fib_multipath_use_neigh",
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 5091402..39187ac 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3522,9 +3522,6 @@ void __init tcp_init(void)
 	}
 
 
-	cnt = tcp_hashinfo.ehash_mask + 1;
-	sysctl_tcp_max_orphans = cnt / 2;
-
 	tcp_init_mem();
 	/* Set per-socket limits to no more than 1/128 the pressure threshold */
 	limit = nr_free_buffer_pages() << (PAGE_SHIFT - 7);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c5d7656..0230509 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -88,7 +88,6 @@
 
 int sysctl_tcp_stdurg __read_mostly;
 int sysctl_tcp_rfc1337 __read_mostly;
-int sysctl_tcp_max_orphans __read_mostly = NR_FILE;
 int sysctl_tcp_frto __read_mostly = 2;
 int sysctl_tcp_min_rtt_wlen __read_mostly = 300;
 int sysctl_tcp_moderate_rcvbuf __read_mostly = 1;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a63486a..4b17a91 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2468,6 +2468,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.tcp_death_row.hashinfo = &tcp_hashinfo;
 
 	net->ipv4.sysctl_max_syn_backlog = max(128, cnt / 256);
+	net->ipv4.sysctl_tcp_max_orphans = cnt / 2;
 	net->ipv4.sysctl_tcp_sack = 1;
 	net->ipv4.sysctl_tcp_window_scaling = 1;
 	net->ipv4.sysctl_tcp_timestamps = 1;
-- 
1.8.3.1
