From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH] ipv4: Namespaceify tcp_fastopen knob
Date: Tue, 12 Sep 2017 18:30:57 +0800
Message-ID: <1505212257-13386-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Different namespace application might require enable TCP Fast Open
feature independently of the host.

Reported-by: Luca BRUNO <lucab@debian.org>
Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 include/net/netns/ipv4.h   |  2 ++
 include/net/tcp.h          |  1 -
 net/ipv4/af_inet.c         |  7 ++++---
 net/ipv4/sysctl_net_ipv4.c | 42 +++++++++++++++++++++---------------------
 net/ipv4/tcp.c             |  4 ++--
 net/ipv4/tcp_fastopen.c    | 13 ++++++-------
 net/ipv4/tcp_ipv4.c        |  2 ++
 samples/bpf/test_ipip.sh   |  2 ++
 8 files changed, 39 insertions(+), 34 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 305e031..ea0953b 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -128,6 +128,8 @@ struct netns_ipv4 {
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
 	int sysctl_tcp_max_orphans;
+	int sysctl_tcp_fastopen;
+	unsigned int sysctl_tcp_fastopen_blackhole_timeout;
 
 #ifdef CONFIG_NET_L3_MASTER_DEV
 	int sysctl_udp_l3mdev_accept;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index ac2d998..e4cc0dd 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -240,7 +240,6 @@
 
 
 /* sysctl variables for tcp */
-extern int sysctl_tcp_fastopen;
 extern int sysctl_tcp_retrans_collapse;
 extern int sysctl_tcp_stdurg;
 extern int sysctl_tcp_rfc1337;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index e31108e..309b849 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -195,7 +195,7 @@ int inet_listen(struct socket *sock, int backlog)
 {
 	struct sock *sk = sock->sk;
 	unsigned char old_state;
-	int err;
+	int err, tcp_fastopen;
 
 	lock_sock(sk);
 
@@ -217,8 +217,9 @@ int inet_listen(struct socket *sock, int backlog)
 		 * because the socket was in TCP_LISTEN state previously but
 		 * was shutdown() rather than close().
 		 */
-		if ((sysctl_tcp_fastopen & TFO_SERVER_WO_SOCKOPT1) &&
-		    (sysctl_tcp_fastopen & TFO_SERVER_ENABLE) &&
+		tcp_fastopen =  sock_net(sk)->ipv4.sysctl_tcp_fastopen;
+		if ((tcp_fastopen & TFO_SERVER_WO_SOCKOPT1) &&
+		    (tcp_fastopen & TFO_SERVER_ENABLE) &&
 		    !inet_csk(sk)->icsk_accept_queue.fastopenq.max_qlen) {
 			fastopen_queue_tune(sk, backlog);
 			tcp_fastopen_init_key_once(true);
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 4f26c8d3..30ebeb9 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -394,27 +394,6 @@ static int proc_tcp_available_ulp(struct ctl_table *ctl,
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.procname	= "tcp_fastopen",
-		.data		= &sysctl_tcp_fastopen,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
-	{
-		.procname	= "tcp_fastopen_key",
-		.mode		= 0600,
-		.maxlen		= ((TCP_FASTOPEN_KEY_LENGTH * 2) + 10),
-		.proc_handler	= proc_tcp_fastopen_key,
-	},
-	{
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
@@ -1085,6 +1064,27 @@ static int proc_tcp_available_ulp(struct ctl_table *ctl,
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "tcp_fastopen",
+		.data		= &init_net.ipv4.sysctl_tcp_fastopen,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "tcp_fastopen_key",
+		.mode		= 0600,
+		.maxlen		= ((TCP_FASTOPEN_KEY_LENGTH * 2) + 10),
+		.proc_handler	= proc_tcp_fastopen_key,
+	},
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
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 39187ac..b3a2ffc 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1126,7 +1126,7 @@ static int tcp_sendmsg_fastopen(struct sock *sk, struct msghdr *msg,
 	struct sockaddr *uaddr = msg->msg_name;
 	int err, flags;
 
-	if (!(sysctl_tcp_fastopen & TFO_CLIENT_ENABLE) ||
+	if (!(sock_net(sk)->ipv4.sysctl_tcp_fastopen & TFO_CLIENT_ENABLE) ||
 	    (uaddr && msg->msg_namelen >= sizeof(uaddr->sa_family) &&
 	     uaddr->sa_family == AF_UNSPEC))
 		return -EOPNOTSUPP;
@@ -2759,7 +2759,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 	case TCP_FASTOPEN_CONNECT:
 		if (val > 1 || val < 0) {
 			err = -EINVAL;
-		} else if (sysctl_tcp_fastopen & TFO_CLIENT_ENABLE) {
+		} else if (net->ipv4.sysctl_tcp_fastopen & TFO_CLIENT_ENABLE) {
 			if (sk->sk_state == TCP_CLOSE)
 				tp->fastopen_connect = val;
 			else
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index e3c3322..1bf57e8 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -9,8 +9,6 @@
 #include <net/inetpeer.h>
 #include <net/tcp.h>
 
-int sysctl_tcp_fastopen __read_mostly = TFO_CLIENT_ENABLE;
-
 struct tcp_fastopen_context __rcu *tcp_fastopen_ctx;
 
 static DEFINE_SPINLOCK(tcp_fastopen_ctx_lock);
@@ -282,18 +280,19 @@ struct sock *tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
 	struct tcp_fastopen_cookie valid_foc = { .len = -1 };
 	bool syn_data = TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq + 1;
 	struct sock *child;
+	int tcp_fastopen = sock_net(sk)->ipv4.sysctl_tcp_fastopen;
 
 	if (foc->len == 0) /* Client requests a cookie */
 		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPFASTOPENCOOKIEREQD);
 
-	if (!((sysctl_tcp_fastopen & TFO_SERVER_ENABLE) &&
+	if (!((tcp_fastopen & TFO_SERVER_ENABLE) &&
 	      (syn_data || foc->len >= 0) &&
 	      tcp_fastopen_queue_check(sk))) {
 		foc->len = -1;
 		return NULL;
 	}
 
-	if (syn_data && (sysctl_tcp_fastopen & TFO_SERVER_COOKIE_NOT_REQD))
+	if (syn_data && (tcp_fastopen & TFO_SERVER_COOKIE_NOT_REQD))
 		goto fastopen;
 
 	if (foc->len >= 0 &&  /* Client presents or requests a cookie */
@@ -347,7 +346,7 @@ bool tcp_fastopen_cookie_check(struct sock *sk, u16 *mss,
 		return false;
 	}
 
-	if (sysctl_tcp_fastopen & TFO_CLIENT_NO_COOKIE) {
+	if (sock_net(sk)->ipv4.sysctl_tcp_fastopen & TFO_CLIENT_NO_COOKIE) {
 		cookie->len = -1;
 		return true;
 	}
@@ -402,7 +401,6 @@ bool tcp_fastopen_defer_connect(struct sock *sk, int *err)
  */
 
 /* Default to 1hr */
-unsigned int sysctl_tcp_fastopen_blackhole_timeout __read_mostly = 60 * 60;
 static atomic_t tfo_active_disable_times __read_mostly = ATOMIC_INIT(0);
 static unsigned long tfo_active_disable_stamp __read_mostly;
 
@@ -431,13 +429,14 @@ bool tcp_fastopen_active_should_disable(struct sock *sk)
 	int tfo_da_times = atomic_read(&tfo_active_disable_times);
 	int multiplier;
 	unsigned long timeout;
+	unsigned int tfo_bh_timeout = sock_net(sk)->ipv4.sysctl_tcp_fastopen_blackhole_timeout;
 
 	if (!tfo_da_times)
 		return false;
 
 	/* Limit timout to max: 2^6 * initial timeout */
 	multiplier = 1 << min(tfo_da_times - 1, 6);
-	timeout = multiplier * sysctl_tcp_fastopen_blackhole_timeout * HZ;
+	timeout = multiplier * tfo_bh_timeout * HZ;
 	if (time_before(jiffies, tfo_active_disable_stamp + timeout))
 		return true;
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 4b17a91..38d30ea 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2473,6 +2473,8 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_window_scaling = 1;
 	net->ipv4.sysctl_tcp_timestamps = 1;
 
+	net->ipv4.sysctl_tcp_fastopen = TFO_CLIENT_ENABLE;
+	net->ipv4.sysctl_tcp_fastopen_blackhole_timeout = 60 * 60;
 	return 0;
 fail:
 	tcp_sk_exit(net);
diff --git a/samples/bpf/test_ipip.sh b/samples/bpf/test_ipip.sh
index 1969254..7bbc521 100755
--- a/samples/bpf/test_ipip.sh
+++ b/samples/bpf/test_ipip.sh
@@ -173,6 +173,8 @@ function cleanup {
 cleanup
 echo "Testing IP tunnels..."
 test_ipip
+sleep 1
 test_ipip6
+sleep 1
 test_ip6ip6
 echo "*** PASS ***"
-- 
1.8.3.1
