From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/4] tcp: Namespaceify sysctl_tcp_sack
Date: Wed,  7 Jun 2017 10:34:37 -0700
Message-ID: <20170607173439.17092-3-edumazet@google.com>
References: <20170607173439.17092-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:36192 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751522AbdFGRet (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 13:34:49 -0400
Received: by mail-pg0-f43.google.com with SMTP id a70so7525521pge.3
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 10:34:49 -0700 (PDT)
In-Reply-To: <20170607173439.17092-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  4 ++--
 net/ipv4/syncookies.c      |  7 ++++---
 net/ipv4/sysctl_net_ipv4.c | 14 +++++++-------
 net/ipv4/tcp_input.c       |  3 +--
 net/ipv4/tcp_ipv4.c        |  1 +
 net/ipv4/tcp_output.c      |  2 +-
 net/ipv6/syncookies.c      |  2 +-
 8 files changed, 18 insertions(+), 16 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index cd686c4fb32dc5409a08f818d48228bffa6f6778..bb02482ec8215d59943a708fce0f720e0a71aa8f 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -122,6 +122,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_fin_timeout;
 	unsigned int sysctl_tcp_notsent_lowat;
 	int sysctl_tcp_tw_reuse;
+	int sysctl_tcp_sack;
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 0b0cfeefa05b86473bbef091f54dc976334e9372..f9d2ce0ba6769d3b95da8846344c0ba1811a55a8 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -239,7 +239,6 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 /* sysctl variables for tcp */
 extern int sysctl_tcp_timestamps;
 extern int sysctl_tcp_window_scaling;
-extern int sysctl_tcp_sack;
 extern int sysctl_tcp_fastopen;
 extern int sysctl_tcp_retrans_collapse;
 extern int sysctl_tcp_stdurg;
@@ -520,7 +519,8 @@ u32 __cookie_v4_init_sequence(const struct iphdr *iph, const struct tcphdr *th,
 			      u16 *mssp);
 __u32 cookie_v4_init_sequence(const struct sk_buff *skb, __u16 *mss);
 u64 cookie_init_timestamp(struct request_sock *req);
-bool cookie_timestamp_decode(struct tcp_options_received *opt);
+bool cookie_timestamp_decode(const struct net *net,
+			     struct tcp_options_received *opt);
 bool cookie_ecn_ok(const struct tcp_options_received *opt,
 		   const struct net *net, const struct dst_entry *dst);
 
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 6a32cb3818771d3109a013521bda9c0e6cdab74b..b386e8592ffddf2c3565486b6897cb9a4dc2dcb1 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -232,7 +232,8 @@ EXPORT_SYMBOL(tcp_get_cookie_sock);
  * return false if we decode a tcp option that is disabled
  * on the host.
  */
-bool cookie_timestamp_decode(struct tcp_options_received *tcp_opt)
+bool cookie_timestamp_decode(const struct net *net,
+			     struct tcp_options_received *tcp_opt)
 {
 	/* echoed timestamp, lowest bits contain options */
 	u32 options = tcp_opt->rcv_tsecr;
@@ -247,7 +248,7 @@ bool cookie_timestamp_decode(struct tcp_options_received *tcp_opt)
 
 	tcp_opt->sack_ok = (options & TS_OPT_SACK) ? TCP_SACK_SEEN : 0;
 
-	if (tcp_opt->sack_ok && !sysctl_tcp_sack)
+	if (tcp_opt->sack_ok && !net->ipv4.sysctl_tcp_sack)
 		return false;
 
 	if ((options & TS_OPT_WSCALE_MASK) == TS_OPT_WSCALE_MASK)
@@ -319,7 +320,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 		tcp_opt.rcv_tsecr -= tsoff;
 	}
 
-	if (!cookie_timestamp_decode(&tcp_opt))
+	if (!cookie_timestamp_decode(sock_net(sk), &tcp_opt))
 		goto out;
 
 	ret = NULL;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 86957e9cd6c6748ac00aa0307154bb131c43f1da..74718f8a0aa8fd8ff52cb50112bb0f5101125b6a 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -378,13 +378,6 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
-	{
-		.procname	= "tcp_sack",
-		.data		= &sysctl_tcp_sack,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
 	{
 		.procname	= "tcp_retrans_collapse",
 		.data		= &sysctl_tcp_retrans_collapse,
@@ -1116,6 +1109,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.extra2		= &one,
 	},
 #endif
+	{
+		.procname	= "tcp_sack",
+		.data		= &init_net.ipv4.sysctl_tcp_sack,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 99ee707f0ef496998b11b5367ade1a0412b50bef..2eacfcaf1257b9f474ae5af8169eec4b4d30f3f3 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -78,7 +78,6 @@
 
 int sysctl_tcp_timestamps __read_mostly = 1;
 int sysctl_tcp_window_scaling __read_mostly = 1;
-int sysctl_tcp_sack __read_mostly = 1;
 int sysctl_tcp_fack __read_mostly;
 int sysctl_tcp_max_reordering __read_mostly = 300;
 int sysctl_tcp_dsack __read_mostly = 1;
@@ -3790,7 +3789,7 @@ void tcp_parse_options(const struct net *net,
 				break;
 			case TCPOPT_SACK_PERM:
 				if (opsize == TCPOLEN_SACK_PERM && th->syn &&
-				    !estab && sysctl_tcp_sack) {
+				    !estab && net->ipv4.sysctl_tcp_sack) {
 					opt_rx->sack_ok = TCP_SACK_SEEN;
 					tcp_sack_reset(opt_rx);
 				}
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 191b2f78b19d2c8d62c59cc046bd608687679619..3c475a2a84323c8064d271b7dc2d0e1d68dd7e2e 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2465,6 +2465,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.tcp_death_row.hashinfo = &tcp_hashinfo;
 
 	net->ipv4.sysctl_max_syn_backlog = max(128, cnt / 256);
+	net->ipv4.sysctl_tcp_sack = 1;
 
 	return 0;
 fail:
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index e3aab1c1cf78d7b5696fc1438fe54f8ce448c09e..45c8e459db49bcbf3ca17b5f048cee82c3273ef7 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -580,7 +580,7 @@ static unsigned int tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 		opts->options |= OPTION_WSCALE;
 		remaining -= TCPOLEN_WSCALE_ALIGNED;
 	}
-	if (likely(sysctl_tcp_sack)) {
+	if (likely(sock_net(sk)->ipv4.sysctl_tcp_sack)) {
 		opts->options |= OPTION_SACK_ADVERTISE;
 		if (unlikely(!(OPTION_TS & opts->options)))
 			remaining -= TCPOLEN_SACKPERM_ALIGNED;
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 4c0a047ec230ade24ac6bfa39d72b3b2da9b7e5f..aa6443c6da19055ced1094d2afc7c114028acc35 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -170,7 +170,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 		tcp_opt.rcv_tsecr -= tsoff;
 	}
 
-	if (!cookie_timestamp_decode(&tcp_opt))
+	if (!cookie_timestamp_decode(sock_net(sk), &tcp_opt))
 		goto out;
 
 	ret = NULL;
-- 
2.13.0.506.g27d5fe0cd-goog
