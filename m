From: Nikolay Borisov <kernel@kyup.com>
Subject: [PATCH 1/3] ipv4: Namespaceify tcp_keepalive_time sysctl knob
Date: Thu,  7 Jan 2016 16:38:43 +0200
Message-ID: <1452177525-13244-2-git-send-email-kernel@kyup.com>
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

Different net namespaces might have different requirements as to
the keepalive time of tcp sockets. This might be required in cases
where different firewall rules are in place which require tcp
timeout sockets to be increased/decreased independently of the host.

Signed-off-by: Nikolay Borisov <kernel@kyup.com>
---
 include/net/netns/ipv4.h   |  2 ++
 include/net/tcp.h          |  5 +++--
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp_ipv4.c        |  2 ++
 net/ipv4/tcp_timer.c       |  1 -
 5 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index c68926b4899c..d7ee5120e3ec 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -91,6 +91,8 @@ struct netns_ipv4 {
 	int sysctl_tcp_probe_threshold;
 	u32 sysctl_tcp_probe_interval;
 
+	int sysctl_tcp_keepalive_time;
+
 	struct ping_group_range ping_group_range;
 
 	atomic_t dev_addr_genid;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index f80e74c5ad18..1145f890f55c 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -240,7 +240,6 @@ extern int sysctl_tcp_timestamps;
 extern int sysctl_tcp_window_scaling;
 extern int sysctl_tcp_sack;
 extern int sysctl_tcp_fin_timeout;
-extern int sysctl_tcp_keepalive_time;
 extern int sysctl_tcp_keepalive_probes;
 extern int sysctl_tcp_keepalive_intvl;
 extern int sysctl_tcp_syn_retries;
@@ -1228,7 +1227,9 @@ static inline int keepalive_intvl_when(const struct tcp_sock *tp)
 
 static inline int keepalive_time_when(const struct tcp_sock *tp)
 {
-	return tp->keepalive_time ? : sysctl_tcp_keepalive_time;
+	struct net *net = sock_net((struct sock *)tp);
+
+	return tp->keepalive_time ? : net->ipv4.sysctl_tcp_keepalive_time;
 }
 
 static inline int keepalive_probes(const struct tcp_sock *tp)
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index a0bd7a55193e..8755825b92a5 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -337,13 +337,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.procname	= "tcp_keepalive_time",
-		.data		= &sysctl_tcp_keepalive_time,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
 		.procname	= "tcp_keepalive_probes",
 		.data		= &sysctl_tcp_keepalive_probes,
 		.maxlen		= sizeof(int),
@@ -950,6 +943,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "tcp_keepalive_time",
+		.data		= &init_net.ipv4.sysctl_tcp_keepalive_time,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_jiffies,
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index d8841a2f1569..ca8d98de7846 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2378,6 +2378,8 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_probe_threshold = TCP_PROBE_THRESHOLD;
 	net->ipv4.sysctl_tcp_probe_interval = TCP_PROBE_INTERVAL;
 
+	net->ipv4.sysctl_tcp_keepalive_time = TCP_KEEPALIVE_TIME;
+
 	return 0;
 fail:
 	tcp_sk_exit(net);
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 193ba1fa8a9a..166f27b43cc0 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -24,7 +24,6 @@
 
 int sysctl_tcp_syn_retries __read_mostly = TCP_SYN_RETRIES;
 int sysctl_tcp_synack_retries __read_mostly = TCP_SYNACK_RETRIES;
-int sysctl_tcp_keepalive_time __read_mostly = TCP_KEEPALIVE_TIME;
 int sysctl_tcp_keepalive_probes __read_mostly = TCP_KEEPALIVE_PROBES;
 int sysctl_tcp_keepalive_intvl __read_mostly = TCP_KEEPALIVE_INTVL;
 int sysctl_tcp_retries1 __read_mostly = TCP_RETR1;
-- 
2.5.0
