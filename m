From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH v5 1/4] ipv4: Namespaceify tcp_fastopen knob
Date: Wed, 27 Sep 2017 11:35:40 +0800
Message-ID: <1506483343-11544-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Eric Dumazet <edumazet@google.com>,
        Wei Wang <weiwan@google.com>, Luca BRUNO <lucab@debian.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Different namespace application might require enable TCP Fast Open
feature independently of the host.

This patch series continues making more of the TCP Fast Open related
sysctl knobs be per net-namespace.

Reported-by: Luca BRUNO <lucab@debian.org>
Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

---
Changes since v5:
  * Splite patch #2 into two changes
  * Fix potential leak issue
  * Fix typo error
  * Split the patches to be per-sysctl
  * Remove unrelated change by mistake
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  1 -
 net/ipv4/af_inet.c         |  7 ++++---
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp.c             |  4 ++--
 net/ipv4/tcp_fastopen.c    | 11 +++++------
 net/ipv4/tcp_ipv4.c        |  2 ++
 7 files changed, 21 insertions(+), 19 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 20d061c..ce6dde0 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -127,6 +127,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_timestamps;
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
+	int sysctl_tcp_fastopen;
 
 #ifdef CONFIG_NET_L3_MASTER_DEV
 	int sysctl_udp_l3mdev_accept;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index b510f28..f628967 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -240,7 +240,6 @@
 
 
 /* sysctl variables for tcp */
-extern int sysctl_tcp_fastopen;
 extern int sysctl_tcp_retrans_collapse;
 extern int sysctl_tcp_stdurg;
 extern int sysctl_tcp_rfc1337;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index e31108e..ddd126d 100644
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
+		tcp_fastopen = sock_net(sk)->ipv4.sysctl_tcp_fastopen;
+		if ((tcp_fastopen & TFO_SERVER_WO_SOCKOPT1) &&
+		    (tcp_fastopen & TFO_SERVER_ENABLE) &&
 		    !inet_csk(sk)->icsk_accept_queue.fastopenq.max_qlen) {
 			fastopen_queue_tune(sk, backlog);
 			tcp_fastopen_init_key_once(true);
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 0d3c038..e31e853c 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -401,13 +401,6 @@ static int proc_tcp_available_ulp(struct ctl_table *ctl,
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
 		.procname	= "tcp_fastopen_key",
 		.mode		= 0600,
 		.maxlen		= ((TCP_FASTOPEN_KEY_LENGTH * 2) + 10),
@@ -1085,6 +1078,13 @@ static int proc_tcp_available_ulp(struct ctl_table *ctl,
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
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	{
 		.procname	= "fib_multipath_use_neigh",
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 5091402..dac56c4 100644
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
index e3c3322..31b08ec 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -9,8 +9,6 @@
 #include <net/inetpeer.h>
 #include <net/tcp.h>
 
-int sysctl_tcp_fastopen __read_mostly = TFO_CLIENT_ENABLE;
-
 struct tcp_fastopen_context __rcu *tcp_fastopen_ctx;
 
 static DEFINE_SPINLOCK(tcp_fastopen_ctx_lock);
@@ -279,21 +277,22 @@ struct sock *tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
 			      struct request_sock *req,
 			      struct tcp_fastopen_cookie *foc)
 {
-	struct tcp_fastopen_cookie valid_foc = { .len = -1 };
 	bool syn_data = TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq + 1;
+	int tcp_fastopen = sock_net(sk)->ipv4.sysctl_tcp_fastopen;
+	struct tcp_fastopen_cookie valid_foc = { .len = -1 };
 	struct sock *child;
 
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
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index d9416b5..88409b1 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2472,6 +2472,8 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_window_scaling = 1;
 	net->ipv4.sysctl_tcp_timestamps = 1;
 
+	net->ipv4.sysctl_tcp_fastopen = TFO_CLIENT_ENABLE;
+
 	return 0;
 fail:
 	tcp_sk_exit(net);
-- 
1.8.3.1
