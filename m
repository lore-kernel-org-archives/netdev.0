From: Nikolay Borisov <kernel@kyup.com>
Subject: [PATCH 2/3] ipv4: Namespecify tcp_keepalive_probes sysctl knob
Date: Thu,  7 Jan 2016 16:38:44 +0200
Message-ID: <1452177525-13244-3-git-send-email-kernel@kyup.com>
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

This is required to have full tcp keepalive mechanism namespace
support.

Signed-off-by: Nikolay Borisov <kernel@kyup.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  5 +++--
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp_ipv4.c        |  1 +
 net/ipv4/tcp_timer.c       |  1 -
 5 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index d7ee5120e3ec..4955c160be59 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -92,6 +92,7 @@ struct netns_ipv4 {
 	u32 sysctl_tcp_probe_interval;
 
 	int sysctl_tcp_keepalive_time;
+	int sysctl_tcp_keepalive_probes;
 
 	struct ping_group_range ping_group_range;
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 1145f890f55c..5cf1cfde7fda 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -240,7 +240,6 @@ extern int sysctl_tcp_timestamps;
 extern int sysctl_tcp_window_scaling;
 extern int sysctl_tcp_sack;
 extern int sysctl_tcp_fin_timeout;
-extern int sysctl_tcp_keepalive_probes;
 extern int sysctl_tcp_keepalive_intvl;
 extern int sysctl_tcp_syn_retries;
 extern int sysctl_tcp_synack_retries;
@@ -1234,7 +1233,9 @@ static inline int keepalive_time_when(const struct tcp_sock *tp)
 
 static inline int keepalive_probes(const struct tcp_sock *tp)
 {
-	return tp->keepalive_probes ? : sysctl_tcp_keepalive_probes;
+	struct net *net = sock_net((struct sock *)tp);
+
+	return tp->keepalive_probes ? : net->ipv4.sysctl_tcp_keepalive_probes;
 }
 
 static inline u32 keepalive_time_elapsed(const struct tcp_sock *tp)
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 8755825b92a5..d9e17bbf08cf 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -337,13 +337,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.procname	= "tcp_keepalive_probes",
-		.data		= &sysctl_tcp_keepalive_probes,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
-	{
 		.procname	= "tcp_keepalive_intvl",
 		.data		= &sysctl_tcp_keepalive_intvl,
 		.maxlen		= sizeof(int),
@@ -950,6 +943,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
+	{
+		.procname	= "tcp_keepalive_probes",
+		.data		= &init_net.ipv4.sysctl_tcp_keepalive_probes,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index ca8d98de7846..9e9187c3b45a 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2379,6 +2379,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_probe_interval = TCP_PROBE_INTERVAL;
 
 	net->ipv4.sysctl_tcp_keepalive_time = TCP_KEEPALIVE_TIME;
+	net->ipv4.sysctl_tcp_keepalive_probes = TCP_KEEPALIVE_PROBES;
 
 	return 0;
 fail:
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 166f27b43cc0..0ccb120d591a 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -24,7 +24,6 @@
 
 int sysctl_tcp_syn_retries __read_mostly = TCP_SYN_RETRIES;
 int sysctl_tcp_synack_retries __read_mostly = TCP_SYNACK_RETRIES;
-int sysctl_tcp_keepalive_probes __read_mostly = TCP_KEEPALIVE_PROBES;
 int sysctl_tcp_keepalive_intvl __read_mostly = TCP_KEEPALIVE_INTVL;
 int sysctl_tcp_retries1 __read_mostly = TCP_RETR1;
 int sysctl_tcp_retries2 __read_mostly = TCP_RETR2;
-- 
2.5.0
