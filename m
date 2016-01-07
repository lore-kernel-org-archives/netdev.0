From: Nikolay Borisov <kernel@kyup.com>
Subject: [PATCH 3/3] ipv4: Namespecify the tcp_keepalive_intvl sysctl knob
Date: Thu,  7 Jan 2016 16:38:45 +0200
Message-ID: <1452177525-13244-4-git-send-email-kernel@kyup.com>
References: <1452177525-13244-1-git-send-email-kernel@kyup.com>
Cc: edumazet@google.com, ebiederm@xmission.com, fan.du@intel.com,
	kaber@trash.net, jmorris@namei.org, alexander.h.duyck@redhat.com,
	kuznet@ms2.inr.ac.ru, operations@siteground.com
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452177525-13244-1-git-send-email-kernel@kyup.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the final part required to namespaceify the tcp
keep alive mechanism.

Signed-off-by: Nikolay Borisov <kernel@kyup.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  5 +++--
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp_ipv4.c        |  1 +
 net/ipv4/tcp_timer.c       |  1 -
 5 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 4955c160be59..ffa2777b6475 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -93,6 +93,7 @@ struct netns_ipv4 {
 
 	int sysctl_tcp_keepalive_time;
 	int sysctl_tcp_keepalive_probes;
+	int sysctl_tcp_keepalive_intvl;
 
 	struct ping_group_range ping_group_range;
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 5cf1cfde7fda..3ed10fc89c7d 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -240,7 +240,6 @@ extern int sysctl_tcp_timestamps;
 extern int sysctl_tcp_window_scaling;
 extern int sysctl_tcp_sack;
 extern int sysctl_tcp_fin_timeout;
-extern int sysctl_tcp_keepalive_intvl;
 extern int sysctl_tcp_syn_retries;
 extern int sysctl_tcp_synack_retries;
 extern int sysctl_tcp_retries1;
@@ -1221,7 +1220,9 @@ void tcp_enter_memory_pressure(struct sock *sk);
 
 static inline int keepalive_intvl_when(const struct tcp_sock *tp)
 {
-	return tp->keepalive_intvl ? : sysctl_tcp_keepalive_intvl;
+	struct net *net = sock_net((struct sock *)tp);
+
+	return tp->keepalive_intvl ? : net->ipv4.sysctl_tcp_keepalive_intvl;
 }
 
 static inline int keepalive_time_when(const struct tcp_sock *tp)
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index d9e17bbf08cf..fccf8e92bf81 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -337,13 +337,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.procname	= "tcp_keepalive_intvl",
-		.data		= &sysctl_tcp_keepalive_intvl,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
 		.procname	= "tcp_retries1",
 		.data		= &sysctl_tcp_retries1,
 		.maxlen		= sizeof(int),
@@ -950,6 +943,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "tcp_keepalive_intvl",
+		.data		= &init_net.ipv4.sysctl_tcp_keepalive_intvl,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 9e9187c3b45a..9db9bdb14449 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2380,6 +2380,7 @@ static int __net_init tcp_sk_init(struct net *net)
 
 	net->ipv4.sysctl_tcp_keepalive_time = TCP_KEEPALIVE_TIME;
 	net->ipv4.sysctl_tcp_keepalive_probes = TCP_KEEPALIVE_PROBES;
+	net->ipv4.sysctl_tcp_keepalive_intvl = TCP_KEEPALIVE_INTVL;
 
 	return 0;
 fail:
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 0ccb120d591a..a4730a28b220 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -24,7 +24,6 @@
 
 int sysctl_tcp_syn_retries __read_mostly = TCP_SYN_RETRIES;
 int sysctl_tcp_synack_retries __read_mostly = TCP_SYNACK_RETRIES;
-int sysctl_tcp_keepalive_intvl __read_mostly = TCP_KEEPALIVE_INTVL;
 int sysctl_tcp_retries1 __read_mostly = TCP_RETR1;
 int sysctl_tcp_retries2 __read_mostly = TCP_RETR2;
 int sysctl_tcp_orphan_retries __read_mostly;
-- 
2.5.0
