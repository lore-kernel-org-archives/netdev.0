From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 04/12] tcp: Namespace-ify sysctl_tcp_workaround_signed_windows
Date: Fri, 27 Oct 2017 07:47:24 -0700
Message-ID: <20171027144732.23885-5-edumazet@google.com>
References: <20171027144732.23885-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:43586 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751785AbdJ0Orr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 10:47:47 -0400
Received: by mail-io0-f195.google.com with SMTP id 134so13211697ioo.0
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 07:47:47 -0700 (PDT)
In-Reply-To: <20171027144732.23885-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  4 ++--
 net/ipv4/syncookies.c      |  2 +-
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp_minisocks.c   |  2 +-
 net/ipv4/tcp_output.c      | 14 +++++---------
 net/ipv6/syncookies.c      |  2 +-
 7 files changed, 18 insertions(+), 21 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 60bccda046dba6c20bcc8bee097525e9455846b2..e74c7c1b0d18e68a4b6caeeb65f6ec09148a6549 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -145,6 +145,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_nometrics_save;
 	int sysctl_tcp_moderate_rcvbuf;
 	int sysctl_tcp_tso_win_divisor;
+	int sysctl_tcp_workaround_signed_windows;
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
 	int sysctl_tcp_fastopen;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index ed0828dc82f1b8fd686cd68404e2abe31c6c357d..e338e16178dd8c46a96e81ff4d4aa1ccaaf9c937 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -247,7 +247,6 @@ extern int sysctl_tcp_max_orphans;
 extern long sysctl_tcp_mem[3];
 extern int sysctl_tcp_wmem[3];
 extern int sysctl_tcp_rmem[3];
-extern int sysctl_tcp_workaround_signed_windows;
 
 #define TCP_RACK_LOSS_DETECTION  0x1 /* Use RACK to detect losses */
 
@@ -1302,7 +1301,8 @@ static inline void tcp_slow_start_after_idle_check(struct sock *sk)
 }
 
 /* Determine a window scaling and initial window to offer. */
-void tcp_select_initial_window(int __space, __u32 mss, __u32 *rcv_wnd,
+void tcp_select_initial_window(const struct sock *sk, int __space,
+			       __u32 mss, __u32 *rcv_wnd,
 			       __u32 *window_clamp, int wscale_ok,
 			       __u8 *rcv_wscale, __u32 init_rcv_wnd);
 
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 77cf32a80952fcf3ceff4ada946cc2d0df2411d9..fda37f2862c923eb8b6d0b49d9442950fc6a7446 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -385,7 +385,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	/* Try to redo what tcp_v4_send_synack did. */
 	req->rsk_window_clamp = tp->window_clamp ? :dst_metric(&rt->dst, RTAX_WINDOW);
 
-	tcp_select_initial_window(tcp_full_space(sk), req->mss,
+	tcp_select_initial_window(sk, tcp_full_space(sk), req->mss,
 				  &req->rsk_rcv_wnd, &req->rsk_window_clamp,
 				  ireq->wscale_ok, &rcv_wscale,
 				  dst_metric(&rt->dst, RTAX_INITRWND));
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index a053cacb82905bb12da60f8555a135ea11f23d28..3ae9012a497997f542fa1d743ba78a6c61beaf95 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -457,13 +457,6 @@ static struct ctl_table ipv4_table[] = {
 		.maxlen		= TCP_CA_NAME_MAX,
 		.proc_handler	= proc_tcp_congestion_control,
 	},
-	{
-		.procname	= "tcp_workaround_signed_windows",
-		.data		= &sysctl_tcp_workaround_signed_windows,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
 	{
 		.procname	= "tcp_limit_output_bytes",
 		.data		= &sysctl_tcp_limit_output_bytes,
@@ -1145,6 +1138,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname	= "tcp_workaround_signed_windows",
+		.data		= &init_net.ipv4.sysctl_tcp_workaround_signed_windows,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 3270ab8416ce8691cbb1c3a25533142fe1029bed..3c65c1a3f94485e4099989273d7211e37243494e 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -369,7 +369,7 @@ void tcp_openreq_init_rwin(struct request_sock *req,
 		full_space = rcv_wnd * mss;
 
 	/* tcp_full_space because it is guaranteed to be the first packet */
-	tcp_select_initial_window(full_space,
+	tcp_select_initial_window(sk_listener, full_space,
 		mss - (ireq->tstamp_ok ? TCPOLEN_TSTAMP_ALIGNED : 0),
 		&req->rsk_rcv_wnd,
 		&req->rsk_window_clamp,
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 60df3ab52166ac20941d540ad075d60ab3426d25..5bbed67c27e9c163ede3065e57ceb0d04a4925d2 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -45,11 +45,6 @@
 
 #include <trace/events/tcp.h>
 
-/* People can turn this on to work with those rare, broken TCPs that
- * interpret the window field as a signed quantity.
- */
-int sysctl_tcp_workaround_signed_windows __read_mostly = 0;
-
 /* Default TSQ limit of four TSO segments */
 int sysctl_tcp_limit_output_bytes __read_mostly = 262144;
 
@@ -196,7 +191,7 @@ u32 tcp_default_init_rwnd(u32 mss)
  * be a multiple of mss if possible. We assume here that mss >= 1.
  * This MUST be enforced by all callers.
  */
-void tcp_select_initial_window(int __space, __u32 mss,
+void tcp_select_initial_window(const struct sock *sk, int __space, __u32 mss,
 			       __u32 *rcv_wnd, __u32 *window_clamp,
 			       int wscale_ok, __u8 *rcv_wscale,
 			       __u32 init_rcv_wnd)
@@ -220,7 +215,7 @@ void tcp_select_initial_window(int __space, __u32 mss,
 	 * which we interpret as a sign the remote TCP is not
 	 * misinterpreting the window field as a signed quantity.
 	 */
-	if (sysctl_tcp_workaround_signed_windows)
+	if (sock_net(sk)->ipv4.sysctl_tcp_workaround_signed_windows)
 		(*rcv_wnd) = min(space, MAX_TCP_WINDOW);
 	else
 		(*rcv_wnd) = space;
@@ -280,7 +275,8 @@ static u16 tcp_select_window(struct sock *sk)
 	/* Make sure we do not exceed the maximum possible
 	 * scaled window.
 	 */
-	if (!tp->rx_opt.rcv_wscale && sysctl_tcp_workaround_signed_windows)
+	if (!tp->rx_opt.rcv_wscale &&
+	    sock_net(sk)->ipv4.sysctl_tcp_workaround_signed_windows)
 		new_win = min(new_win, MAX_TCP_WINDOW);
 	else
 		new_win = min(new_win, (65535U << tp->rx_opt.rcv_wscale));
@@ -3349,7 +3345,7 @@ static void tcp_connect_init(struct sock *sk)
 	if (rcv_wnd == 0)
 		rcv_wnd = dst_metric(dst, RTAX_INITRWND);
 
-	tcp_select_initial_window(tcp_full_space(sk),
+	tcp_select_initial_window(sk, tcp_full_space(sk),
 				  tp->advmss - (tp->rx_opt.ts_recent_stamp ? tp->tcp_header_len - sizeof(struct tcphdr) : 0),
 				  &tp->rcv_wnd,
 				  &tp->window_clamp,
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 4e7817abc0b934fbff21ba481c3f6773475c7a63..e7a3a6b6cf5650f1036b875688b48f3ee2f9c967 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -244,7 +244,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	}
 
 	req->rsk_window_clamp = tp->window_clamp ? :dst_metric(dst, RTAX_WINDOW);
-	tcp_select_initial_window(tcp_full_space(sk), req->mss,
+	tcp_select_initial_window(sk, tcp_full_space(sk), req->mss,
 				  &req->rsk_rcv_wnd, &req->rsk_window_clamp,
 				  ireq->wscale_ok, &rcv_wscale,
 				  dst_metric(dst, RTAX_INITRWND));
-- 
2.15.0.rc2.357.g7e34df9404-goog
