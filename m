From: Matteo Croce <mcroce@redhat.com>
Subject: [RFC] net: make net.core.{r,w}mem_{default,max} namespaced
Date: Wed, 26 Jul 2017 19:03:33 +0200
Message-ID: <20170726170333.24580-1-mcroce@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33594 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750921AbdGZRDg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 13:03:36 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 4E937883DF
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 17:03:36 +0000 (UTC)
Received: from dhcp-176-85.mxp.redhat.com (dhcp-176-85.mxp.redhat.com [10.32.176.85])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 9482B6973B
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 17:03:35 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following sysctl are global and can't be read or set from a netns:

net.core.rmem_default
net.core.rmem_max
net.core.wmem_default
net.core.wmem_max

Make the following sysctl parameters available from within a network
namespace, allowing to set unique values per network namespace.

My concern is about the initial value of this sysctl in the newly
creates netns: I'm not sure if is better to copy them from the init
namespace or set them to the default values.

Setting them to the default value has the advantage that a new namespace
behaves like a freshly booted system, while copying them from the init
netns has the advantage of keeping the current behaviour as the values
from the init netns are used.

Signed-off-by: Matteo Croce <mcroce@redhat.com>
---
 include/net/netns/core.h        |  5 +++
 include/net/sock.h              |  6 ----
 include/net/tcp.h               |  3 +-
 net/core/net_namespace.c        | 22 +++++++++++++
 net/core/sock.c                 | 31 +++++-------------
 net/core/sysctl_net_core.c      | 70 ++++++++++++++++++++++-------------------
 net/ipv4/ip_output.c            |  2 +-
 net/ipv4/syncookies.c           |  3 +-
 net/ipv4/tcp_minisocks.c        |  3 +-
 net/ipv4/tcp_output.c           | 12 ++++---
 net/ipv6/syncookies.c           |  3 +-
 net/netfilter/ipvs/ip_vs_sync.c |  4 +--
 12 files changed, 89 insertions(+), 75 deletions(-)

diff --git a/include/net/netns/core.h b/include/net/netns/core.h
index 78eb1ff75475..9b613162467d 100644
--- a/include/net/netns/core.h
+++ b/include/net/netns/core.h
@@ -9,6 +9,11 @@ struct netns_core {
 	struct ctl_table_header	*sysctl_hdr;
 
 	int	sysctl_somaxconn;
+	u32	sysctl_wmem_max;
+	u32	sysctl_rmem_max;
+
+	u32	sysctl_wmem_default;
+	u32	sysctl_rmem_default;
 
 	struct prot_inuse __percpu *inuse;
 };
diff --git a/include/net/sock.h b/include/net/sock.h
index 7c0632c7e870..e62a279e420f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2363,13 +2363,7 @@ bool sk_net_capable(const struct sock *sk, int cap);
 
 void sk_get_meminfo(const struct sock *sk, u32 *meminfo);
 
-extern __u32 sysctl_wmem_max;
-extern __u32 sysctl_rmem_max;
-
 extern int sysctl_tstamp_allow_data;
 extern int sysctl_optmem_max;
 
-extern __u32 sysctl_wmem_default;
-extern __u32 sysctl_rmem_default;
-
 #endif	/* _SOCK_H */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 70483296157f..460f4373d42a 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1300,7 +1300,8 @@ static inline void tcp_slow_start_after_idle_check(struct sock *sk)
 /* Determine a window scaling and initial window to offer. */
 void tcp_select_initial_window(int __space, __u32 mss, __u32 *rcv_wnd,
 			       __u32 *window_clamp, int wscale_ok,
-			       __u8 *rcv_wscale, __u32 init_rcv_wnd);
+			       __u8 *rcv_wscale, __u32 init_rcv_wnd,
+			       __u32 rmem_max);
 
 static inline int tcp_win_from_space(int space)
 {
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 8726d051f31d..2d72b2bd6eab 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -23,6 +23,16 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
+/* Take into consideration the size of the struct sk_buff overhead in the
+ * determination of these values, since that is non-constant across
+ * platforms.  This makes socket queueing behavior and performance
+ * not depend upon such differences.
+ */
+#define _SK_MEM_PACKETS		256
+#define _SK_MEM_OVERHEAD	SKB_TRUESIZE(256)
+#define SK_WMEM_MAX		(_SK_MEM_OVERHEAD * _SK_MEM_PACKETS)
+#define SK_RMEM_MAX		(_SK_MEM_OVERHEAD * _SK_MEM_PACKETS)
+
 /*
  *	Our network namespace constructor/destructor lists
  */
@@ -318,6 +328,18 @@ static __net_init int setup_net(struct net *net, struct user_namespace *user_ns)
 static int __net_init net_defaults_init_net(struct net *net)
 {
 	net->core.sysctl_somaxconn = SOMAXCONN;
+	if (net_eq(net, &init_net)) {
+		init_net.core.sysctl_wmem_max = SK_WMEM_MAX;
+		init_net.core.sysctl_rmem_max = SK_RMEM_MAX;
+		init_net.core.sysctl_wmem_default = SK_WMEM_MAX;
+		init_net.core.sysctl_rmem_default = SK_RMEM_MAX;
+	} else {
+		net->core.sysctl_wmem_max = init_net.core.sysctl_wmem_max;
+		net->core.sysctl_rmem_max = init_net.core.sysctl_rmem_max;
+		net->core.sysctl_wmem_default = init_net.core.sysctl_wmem_default;
+		net->core.sysctl_rmem_default = init_net.core.sysctl_rmem_default;
+	}
+
 	return 0;
 }
 
diff --git a/net/core/sock.c b/net/core/sock.c
index ac2a404c73eb..8086a660d75f 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -307,24 +307,6 @@ static struct lock_class_key af_wlock_keys[AF_MAX];
 static struct lock_class_key af_elock_keys[AF_MAX];
 static struct lock_class_key af_kern_callback_keys[AF_MAX];
 
-/* Take into consideration the size of the struct sk_buff overhead in the
- * determination of these values, since that is non-constant across
- * platforms.  This makes socket queueing behavior and performance
- * not depend upon such differences.
- */
-#define _SK_MEM_PACKETS		256
-#define _SK_MEM_OVERHEAD	SKB_TRUESIZE(256)
-#define SK_WMEM_MAX		(_SK_MEM_OVERHEAD * _SK_MEM_PACKETS)
-#define SK_RMEM_MAX		(_SK_MEM_OVERHEAD * _SK_MEM_PACKETS)
-
-/* Run time adjustable parameters. */
-__u32 sysctl_wmem_max __read_mostly = SK_WMEM_MAX;
-EXPORT_SYMBOL(sysctl_wmem_max);
-__u32 sysctl_rmem_max __read_mostly = SK_RMEM_MAX;
-EXPORT_SYMBOL(sysctl_rmem_max);
-__u32 sysctl_wmem_default __read_mostly = SK_WMEM_MAX;
-__u32 sysctl_rmem_default __read_mostly = SK_RMEM_MAX;
-
 /* Maximal space eaten by iovec or ancillary data plus some space */
 int sysctl_optmem_max __read_mostly = sizeof(unsigned long)*(2*UIO_MAXIOV+512);
 EXPORT_SYMBOL(sysctl_optmem_max);
@@ -702,6 +684,7 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 		    char __user *optval, unsigned int optlen)
 {
 	struct sock *sk = sock->sk;
+	struct net *net = sock_net(sk);
 	int val;
 	int valbool;
 	struct linger ling;
@@ -755,7 +738,7 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 		 * play 'guess the biggest size' games. RCVBUF/SNDBUF
 		 * are treated in BSD as hints
 		 */
-		val = min_t(u32, val, sysctl_wmem_max);
+		val = min_t(u32, val, net->core.sysctl_wmem_max);
 set_sndbuf:
 		sk->sk_userlocks |= SOCK_SNDBUF_LOCK;
 		sk->sk_sndbuf = max_t(int, val * 2, SOCK_MIN_SNDBUF);
@@ -776,7 +759,7 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 		 * play 'guess the biggest size' games. RCVBUF/SNDBUF
 		 * are treated in BSD as hints
 		 */
-		val = min_t(u32, val, sysctl_rmem_max);
+		val = min_t(u32, val, net->core.sysctl_rmem_max);
 set_rcvbuf:
 		sk->sk_userlocks |= SOCK_RCVBUF_LOCK;
 		/*
@@ -820,7 +803,7 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 
 	case SO_PRIORITY:
 		if ((val >= 0 && val <= 6) ||
-		    ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
+		    ns_capable(net->user_ns, CAP_NET_ADMIN))
 			sk->sk_priority = val;
 		else
 			ret = -EPERM;
@@ -994,7 +977,7 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 			clear_bit(SOCK_PASSSEC, &sock->flags);
 		break;
 	case SO_MARK:
-		if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			ret = -EPERM;
 		else
 			sk->sk_mark = val;
@@ -2626,8 +2609,8 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 	init_timer(&sk->sk_timer);
 
 	sk->sk_allocation	=	GFP_KERNEL;
-	sk->sk_rcvbuf		=	sysctl_rmem_default;
-	sk->sk_sndbuf		=	sysctl_wmem_default;
+	sk->sk_rcvbuf		=	sock_net(sk)->core.sysctl_rmem_default;
+	sk->sk_sndbuf		=	sock_net(sk)->core.sysctl_wmem_default;
 	sk->sk_state		=	TCP_CLOSE;
 	sk_set_socket(sk, sock);
 
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index b7cd9aafe99e..01bb23ba4c86 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -252,38 +252,6 @@ static int proc_do_rss_key(struct ctl_table *table, int write,
 static struct ctl_table net_core_table[] = {
 #ifdef CONFIG_NET
 	{
-		.procname	= "wmem_max",
-		.data		= &sysctl_wmem_max,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &min_sndbuf,
-	},
-	{
-		.procname	= "rmem_max",
-		.data		= &sysctl_rmem_max,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &min_rcvbuf,
-	},
-	{
-		.procname	= "wmem_default",
-		.data		= &sysctl_wmem_default,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &min_sndbuf,
-	},
-	{
-		.procname	= "rmem_default",
-		.data		= &sysctl_rmem_default,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &min_rcvbuf,
-	},
-	{
 		.procname	= "dev_weight",
 		.data		= &weight_p,
 		.maxlen		= sizeof(int),
@@ -472,6 +440,38 @@ static struct ctl_table netns_core_table[] = {
 		.extra1		= &zero,
 		.proc_handler	= proc_dointvec_minmax
 	},
+	{
+		.procname	= "wmem_max",
+		.data		= &init_net.core.sysctl_wmem_max,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &min_sndbuf,
+	},
+	{
+		.procname	= "rmem_max",
+		.data		= &init_net.core.sysctl_rmem_max,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &min_rcvbuf,
+	},
+	{
+		.procname	= "wmem_default",
+		.data		= &init_net.core.sysctl_wmem_default,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &min_sndbuf,
+	},
+	{
+		.procname	= "rmem_default",
+		.data		= &init_net.core.sysctl_rmem_default,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &min_rcvbuf,
+	},
 	{ }
 };
 
@@ -481,11 +481,15 @@ static __net_init int sysctl_core_net_init(struct net *net)
 
 	tbl = netns_core_table;
 	if (!net_eq(net, &init_net)) {
+		int i;
+
 		tbl = kmemdup(tbl, sizeof(netns_core_table), GFP_KERNEL);
 		if (tbl == NULL)
 			goto err_dup;
 
-		tbl[0].data = &net->core.sysctl_somaxconn;
+		/* Update the variables to point into the current struct net */
+		for (i = 0; i < ARRAY_SIZE(netns_core_table) - 1; i++)
+			tbl[i].data += (void *)net - (void *)&init_net;
 
 		/* Don't export any sysctls to unprivileged users */
 		if (net->user_ns != &init_user_ns) {
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 50c74cd890bc..658927c673ee 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1639,7 +1639,7 @@ void ip_send_unicast_reply(struct sock *sk, struct sk_buff *skb,
 	sk->sk_priority = skb->priority;
 	sk->sk_protocol = ip_hdr(skb)->protocol;
 	sk->sk_bound_dev_if = arg->bound_dev_if;
-	sk->sk_sndbuf = sysctl_wmem_default;
+	sk->sk_sndbuf = net->core.sysctl_wmem_default;
 	sk->sk_mark = fl4.flowi4_mark;
 	err = ip_append_data(sk, &fl4, ip_reply_glue_bits, arg->iov->iov_base,
 			     len, 0, &ipc, &rt, MSG_DONTWAIT);
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 03ad8778c395..ee364e5976a4 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -388,7 +388,8 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	tcp_select_initial_window(tcp_full_space(sk), req->mss,
 				  &req->rsk_rcv_wnd, &req->rsk_window_clamp,
 				  ireq->wscale_ok, &rcv_wscale,
-				  dst_metric(&rt->dst, RTAX_INITRWND));
+				  dst_metric(&rt->dst, RTAX_INITRWND),
+				  sock_net(sk)->core.sysctl_rmem_max);
 
 	ireq->rcv_wscale  = rcv_wscale;
 	ireq->ecn_ok = cookie_ecn_ok(&tcp_opt, sock_net(sk), &rt->dst);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 0ff83c1637d8..e5243ac2edd3 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -377,7 +377,8 @@ void tcp_openreq_init_rwin(struct request_sock *req,
 		&req->rsk_window_clamp,
 		ireq->wscale_ok,
 		&rcv_wscale,
-		rcv_wnd);
+		rcv_wnd,
+		sock_net(sk_listener)->core.sysctl_rmem_max);
 	ireq->rcv_wscale = rcv_wscale;
 }
 EXPORT_SYMBOL(tcp_openreq_init_rwin);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 4e985dea1dd2..9173d01e7d21 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -206,7 +206,7 @@ u32 tcp_default_init_rwnd(u32 mss)
 void tcp_select_initial_window(int __space, __u32 mss,
 			       __u32 *rcv_wnd, __u32 *window_clamp,
 			       int wscale_ok, __u8 *rcv_wscale,
-			       __u32 init_rcv_wnd)
+			       __u32 init_rcv_wnd, __u32 rmem_max)
 {
 	unsigned int space = (__space < 0 ? 0 : __space);
 
@@ -236,7 +236,7 @@ void tcp_select_initial_window(int __space, __u32 mss,
 	if (wscale_ok) {
 		/* Set window scaling on max possible window */
 		space = max_t(u32, space, sysctl_tcp_rmem[2]);
-		space = max_t(u32, space, sysctl_rmem_max);
+		space = max_t(u32, space, rmem_max);
 		space = min_t(u32, space, *window_clamp);
 		while (space > U16_MAX && (*rcv_wscale) < TCP_MAX_WSCALE) {
 			space >>= 1;
@@ -3268,6 +3268,7 @@ static void tcp_connect_init(struct sock *sk)
 {
 	const struct dst_entry *dst = __sk_dst_get(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
+	struct net *net = sock_net(sk);
 	__u8 rcv_wscale;
 	u32 rcv_wnd;
 
@@ -3275,7 +3276,7 @@ static void tcp_connect_init(struct sock *sk)
 	 * See tcp_input.c:tcp_rcv_state_process case TCP_SYN_SENT.
 	 */
 	tp->tcp_header_len = sizeof(struct tcphdr);
-	if (sock_net(sk)->ipv4.sysctl_tcp_timestamps)
+	if (net->ipv4.sysctl_tcp_timestamps)
 		tp->tcp_header_len += TCPOLEN_TSTAMP_ALIGNED;
 
 #ifdef CONFIG_TCP_MD5SIG
@@ -3311,9 +3312,10 @@ static void tcp_connect_init(struct sock *sk)
 				  tp->advmss - (tp->rx_opt.ts_recent_stamp ? tp->tcp_header_len - sizeof(struct tcphdr) : 0),
 				  &tp->rcv_wnd,
 				  &tp->window_clamp,
-				  sock_net(sk)->ipv4.sysctl_tcp_window_scaling,
+				  net->ipv4.sysctl_tcp_window_scaling,
 				  &rcv_wscale,
-				  rcv_wnd);
+				  rcv_wnd,
+				  net->core.sysctl_rmem_max);
 
 	tp->rx_opt.rcv_wscale = rcv_wscale;
 	tp->rcv_ssthresh = tp->rcv_wnd;
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 4e7817abc0b9..bf38ee15766c 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -247,7 +247,8 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	tcp_select_initial_window(tcp_full_space(sk), req->mss,
 				  &req->rsk_rcv_wnd, &req->rsk_window_clamp,
 				  ireq->wscale_ok, &rcv_wscale,
-				  dst_metric(dst, RTAX_INITRWND));
+				  dst_metric(dst, RTAX_INITRWND),
+				  sock_net(sk)->core.sysctl_rmem_max);
 
 	ireq->rcv_wscale = rcv_wscale;
 	ireq->ecn_ok = cookie_ecn_ok(&tcp_opt, sock_net(sk), dst);
diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
index 0e5b64a75da0..4ad447333379 100644
--- a/net/netfilter/ipvs/ip_vs_sync.c
+++ b/net/netfilter/ipvs/ip_vs_sync.c
@@ -1283,12 +1283,12 @@ static void set_sock_size(struct sock *sk, int mode, int val)
 	lock_sock(sk);
 	if (mode) {
 		val = clamp_t(int, val, (SOCK_MIN_SNDBUF + 1) / 2,
-			      sysctl_wmem_max);
+			      sock_net(sk)->core.sysctl_wmem_max);
 		sk->sk_sndbuf = val * 2;
 		sk->sk_userlocks |= SOCK_SNDBUF_LOCK;
 	} else {
 		val = clamp_t(int, val, (SOCK_MIN_RCVBUF + 1) / 2,
-			      sysctl_rmem_max);
+			      sock_net(sk)->core.sysctl_rmem_max);
 		sk->sk_rcvbuf = val * 2;
 		sk->sk_userlocks |= SOCK_RCVBUF_LOCK;
 	}
-- 
2.13.3
