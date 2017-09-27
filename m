From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH v5 4/4] ipv4: Namespaceify tcp_fastopen_blackhole_timeout knob
Date: Wed, 27 Sep 2017 11:35:43 +0800
Message-ID: <1506483343-11544-4-git-send-email-yanhaishuang@cmss.chinamobile.com>
References: <1506483343-11544-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Eric Dumazet <edumazet@google.com>,
        Wei Wang <weiwan@google.com>, Luca BRUNO <lucab@debian.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506483343-11544-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Different namespace application might require different time period in
second to disable Fastopen on active TCP sockets.

Tested:
Simulate following similar situation that the server's data gets dropped
after 3WHS.
C ---- syn-data ---> S
C <--- syn/ack ----- S
C ---- ack --------> S
S (accept & write)
C?  X <- data ------ S
	[retry and timeout]

And then print netstat of TCPFastOpenBlackhole, the counter increased as
expected when the firewall blackhole issue is detected and active TFO is
disabled.
# cat /proc/net/netstat | awk '{print $91}'
TCPFastOpenBlackhole
1

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 include/net/netns/ipv4.h   |  3 +++
 net/ipv4/sysctl_net_ipv4.c | 20 +++++++++++---------
 net/ipv4/tcp_fastopen.c    | 30 +++++++++++-------------------
 net/ipv4/tcp_ipv4.c        |  2 ++
 4 files changed, 27 insertions(+), 28 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 66b8335..d76edde 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -132,6 +132,9 @@ struct netns_ipv4 {
 	int sysctl_tcp_fastopen;
 	struct tcp_fastopen_context __rcu *tcp_fastopen_ctx;
 	spinlock_t tcp_fastopen_ctx_lock;
+	unsigned int sysctl_tcp_fastopen_blackhole_timeout;
+	atomic_t tfo_active_disable_times;
+	unsigned long tfo_active_disable_stamp;
 
 #ifdef CONFIG_NET_L3_MASTER_DEV
 	int sysctl_udp_l3mdev_accept;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 20e19fe..cac8dd3 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -355,11 +355,13 @@ static int proc_tfo_blackhole_detect_timeout(struct ctl_table *table,
 					     void __user *buffer,
 					     size_t *lenp, loff_t *ppos)
 {
+	struct net *net = container_of(table->data, struct net,
+	    ipv4.sysctl_tcp_fastopen_blackhole_timeout);
 	int ret;
 
 	ret = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
 	if (write && ret == 0)
-		tcp_fastopen_active_timeout_reset();
+		atomic_set(&net->ipv4.tfo_active_disable_times, 0);
 
 	return ret;
 }
@@ -398,14 +400,6 @@ static int proc_tcp_available_ulp(struct ctl_table *ctl,
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.procname	= "tcp_fastopen_blackhole_timeout_sec",
-		.data		= &sysctl_tcp_fastopen_blackhole_timeout,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_tfo_blackhole_detect_timeout,
-		.extra1		= &zero,
-	},
-	{
 		.procname	= "tcp_abort_on_overflow",
 		.data		= &sysctl_tcp_abort_on_overflow,
 		.maxlen		= sizeof(int),
@@ -1083,6 +1077,14 @@ static int proc_tcp_available_ulp(struct ctl_table *ctl,
 		.maxlen		= ((TCP_FASTOPEN_KEY_LENGTH * 2) + 10),
 		.proc_handler	= proc_tcp_fastopen_key,
 	},
+	{
+		.procname	= "tcp_fastopen_blackhole_timeout_sec",
+		.data		= &init_net.ipv4.sysctl_tcp_fastopen_blackhole_timeout,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_tfo_blackhole_detect_timeout,
+		.extra1		= &zero,
+	},
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	{
 		.procname	= "fib_multipath_use_neigh",
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 4eae44a..de470e7 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -422,25 +422,16 @@ bool tcp_fastopen_defer_connect(struct sock *sk, int *err)
  * TFO connection with data exchanges.
  */
 
-/* Default to 1hr */
-unsigned int sysctl_tcp_fastopen_blackhole_timeout __read_mostly = 60 * 60;
-static atomic_t tfo_active_disable_times __read_mostly = ATOMIC_INIT(0);
-static unsigned long tfo_active_disable_stamp __read_mostly;
-
 /* Disable active TFO and record current jiffies and
  * tfo_active_disable_times
  */
 void tcp_fastopen_active_disable(struct sock *sk)
 {
-	atomic_inc(&tfo_active_disable_times);
-	tfo_active_disable_stamp = jiffies;
-	NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPFASTOPENBLACKHOLE);
-}
+	struct net *net = sock_net(sk);
 
-/* Reset tfo_active_disable_times to 0 */
-void tcp_fastopen_active_timeout_reset(void)
-{
-	atomic_set(&tfo_active_disable_times, 0);
+	atomic_inc(&net->ipv4.tfo_active_disable_times);
+	net->ipv4.tfo_active_disable_stamp = jiffies;
+	NET_INC_STATS(net, LINUX_MIB_TCPFASTOPENBLACKHOLE);
 }
 
 /* Calculate timeout for tfo active disable
@@ -449,17 +440,18 @@ void tcp_fastopen_active_timeout_reset(void)
  */
 bool tcp_fastopen_active_should_disable(struct sock *sk)
 {
-	int tfo_da_times = atomic_read(&tfo_active_disable_times);
-	int multiplier;
+	unsigned int tfo_bh_timeout = sock_net(sk)->ipv4.sysctl_tcp_fastopen_blackhole_timeout;
+	int tfo_da_times = atomic_read(&sock_net(sk)->ipv4.tfo_active_disable_times);
 	unsigned long timeout;
+	int multiplier;
 
 	if (!tfo_da_times)
 		return false;
 
 	/* Limit timout to max: 2^6 * initial timeout */
 	multiplier = 1 << min(tfo_da_times - 1, 6);
-	timeout = multiplier * sysctl_tcp_fastopen_blackhole_timeout * HZ;
-	if (time_before(jiffies, tfo_active_disable_stamp + timeout))
+	timeout = multiplier * tfo_bh_timeout * HZ;
+	if (time_before(jiffies, sock_net(sk)->ipv4.tfo_active_disable_stamp + timeout))
 		return true;
 
 	/* Mark check bit so we can check for successful active TFO
@@ -495,10 +487,10 @@ void tcp_fastopen_active_disable_ofo_check(struct sock *sk)
 			}
 		}
 	} else if (tp->syn_fastopen_ch &&
-		   atomic_read(&tfo_active_disable_times)) {
+		   atomic_read(&sock_net(sk)->ipv4.tfo_active_disable_times)) {
 		dst = sk_dst_get(sk);
 		if (!(dst && dst->dev && (dst->dev->flags & IFF_LOOPBACK)))
-			tcp_fastopen_active_timeout_reset();
+			atomic_set(&sock_net(sk)->ipv4.tfo_active_disable_times, 0);
 		dst_release(dst);
 	}
 }
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 49c74c0..ad3b5bb 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2474,6 +2474,8 @@ static int __net_init tcp_sk_init(struct net *net)
 
 	net->ipv4.sysctl_tcp_fastopen = TFO_CLIENT_ENABLE;
 	spin_lock_init(&net->ipv4.tcp_fastopen_ctx_lock);
+	net->ipv4.sysctl_tcp_fastopen_blackhole_timeout = 60 * 60;
+	atomic_set(&net->ipv4.tfo_active_disable_times, 0);
 
 	return 0;
 fail:
-- 
1.8.3.1
