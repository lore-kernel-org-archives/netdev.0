From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 3/4] tcp: Namespaceify sysctl_tcp_window_scaling
Date: Wed,  7 Jun 2017 10:34:38 -0700
Message-ID: <20170607173439.17092-4-edumazet@google.com>
References: <20170607173439.17092-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:34036 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751622AbdFGRev (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 13:34:51 -0400
Received: by mail-pg0-f46.google.com with SMTP id v18so7544466pgb.1
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 10:34:51 -0700 (PDT)
In-Reply-To: <20170607173439.17092-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  1 -
 net/ipv4/syncookies.c      |  2 +-
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp_input.c       |  3 +--
 net/ipv4/tcp_ipv4.c        |  1 +
 net/ipv4/tcp_output.c      |  4 ++--
 7 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index bb02482ec8215d59943a708fce0f720e0a71aa8f..1a2ae74a108510a49466a08fd2c2d84c3940a3a9 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -123,6 +123,7 @@ struct netns_ipv4 {
 	unsigned int sysctl_tcp_notsent_lowat;
 	int sysctl_tcp_tw_reuse;
 	int sysctl_tcp_sack;
+	int sysctl_tcp_window_scaling;
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index f9d2ce0ba6769d3b95da8846344c0ba1811a55a8..f41ed5bac49312e2bd9b7bfd54b59a95d9888ec9 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -238,7 +238,6 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 
 /* sysctl variables for tcp */
 extern int sysctl_tcp_timestamps;
-extern int sysctl_tcp_window_scaling;
 extern int sysctl_tcp_fastopen;
 extern int sysctl_tcp_retrans_collapse;
 extern int sysctl_tcp_stdurg;
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index b386e8592ffddf2c3565486b6897cb9a4dc2dcb1..3d74a45773f1f7adf430885fe46096a498b4e489 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -257,7 +257,7 @@ bool cookie_timestamp_decode(const struct net *net,
 	tcp_opt->wscale_ok = 1;
 	tcp_opt->snd_wscale = options & TS_OPT_WSCALE_MASK;
 
-	return sysctl_tcp_window_scaling != 0;
+	return net->ipv4.sysctl_tcp_window_scaling != 0;
 }
 EXPORT_SYMBOL(cookie_timestamp_decode);
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 74718f8a0aa8fd8ff52cb50112bb0f5101125b6a..c30ac2ba0e140698d310b4d84e1bbd8f37e650a5 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -371,13 +371,6 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
-	{
-		.procname	= "tcp_window_scaling",
-		.data		= &sysctl_tcp_window_scaling,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
 	{
 		.procname	= "tcp_retrans_collapse",
 		.data		= &sysctl_tcp_retrans_collapse,
@@ -1116,6 +1109,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "tcp_window_scaling",
+		.data		= &init_net.ipv4.sysctl_tcp_window_scaling,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2eacfcaf1257b9f474ae5af8169eec4b4d30f3f3..675ee903370ffd983109a2651235d627cad6eaa5 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -77,7 +77,6 @@
 #include <linux/errqueue.h>
 
 int sysctl_tcp_timestamps __read_mostly = 1;
-int sysctl_tcp_window_scaling __read_mostly = 1;
 int sysctl_tcp_fack __read_mostly;
 int sysctl_tcp_max_reordering __read_mostly = 300;
 int sysctl_tcp_dsack __read_mostly = 1;
@@ -3765,7 +3764,7 @@ void tcp_parse_options(const struct net *net,
 				break;
 			case TCPOPT_WINDOW:
 				if (opsize == TCPOLEN_WINDOW && th->syn &&
-				    !estab && sysctl_tcp_window_scaling) {
+				    !estab && net->ipv4.sysctl_tcp_window_scaling) {
 					__u8 snd_wscale = *(__u8 *)ptr;
 					opt_rx->wscale_ok = 1;
 					if (snd_wscale > TCP_MAX_WSCALE) {
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 3c475a2a84323c8064d271b7dc2d0e1d68dd7e2e..e07ef5b14aaf4bd46253775b649cd77b58af5a2f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2466,6 +2466,7 @@ static int __net_init tcp_sk_init(struct net *net)
 
 	net->ipv4.sysctl_max_syn_backlog = max(128, cnt / 256);
 	net->ipv4.sysctl_tcp_sack = 1;
+	net->ipv4.sysctl_tcp_window_scaling = 1;
 
 	return 0;
 fail:
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 45c8e459db49bcbf3ca17b5f048cee82c3273ef7..3f40950107857b2984e858bf6d9e48e6f87a3259 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -575,7 +575,7 @@ static unsigned int tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 		opts->tsecr = tp->rx_opt.ts_recent;
 		remaining -= TCPOLEN_TSTAMP_ALIGNED;
 	}
-	if (likely(sysctl_tcp_window_scaling)) {
+	if (likely(sock_net(sk)->ipv4.sysctl_tcp_window_scaling)) {
 		opts->ws = tp->rx_opt.rcv_wscale;
 		opts->options |= OPTION_WSCALE;
 		remaining -= TCPOLEN_WSCALE_ALIGNED;
@@ -3303,7 +3303,7 @@ static void tcp_connect_init(struct sock *sk)
 				  tp->advmss - (tp->rx_opt.ts_recent_stamp ? tp->tcp_header_len - sizeof(struct tcphdr) : 0),
 				  &tp->rcv_wnd,
 				  &tp->window_clamp,
-				  sysctl_tcp_window_scaling,
+				  sock_net(sk)->ipv4.sysctl_tcp_window_scaling,
 				  &rcv_wscale,
 				  dst_metric(dst, RTAX_INITRWND));
 
-- 
2.13.0.506.g27d5fe0cd-goog
