From: Nikolay Borisov <kernel@kyup.com>
Subject: [PATCH 2/9] ipv4: Namespaceify tcp synack retries sysctl knob
Date: Mon, 11 Jan 2016 11:51:48 +0200
Message-ID: <1452505915-19912-3-git-send-email-kernel@kyup.com>
References: <1452505915-19912-1-git-send-email-kernel@kyup.com>
Cc: linux-kernel@vger.kernel.org, edumazet@google.com,
	kuznet@ms2.inr.ac.ru, kaber@trash.net, ebiederm@xmission.com,
	operations@siteground.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:38801 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758918AbcAKJwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 04:52:01 -0500
Received: by mail-wm0-f46.google.com with SMTP id b14so258927448wmb.1
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 01:52:00 -0800 (PST)
In-Reply-To: <1452505915-19912-1-git-send-email-kernel@kyup.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nikolay Borisov <kernel@kyup.com>
---
 include/net/netns/ipv4.h        |  1 +
 include/net/tcp.h               |  1 -
 net/ipv4/inet_connection_sock.c |  7 ++-----
 net/ipv4/sysctl_net_ipv4.c      | 14 +++++++-------
 net/ipv4/tcp_ipv4.c             |  1 +
 net/ipv4/tcp_timer.c            |  3 +--
 6 files changed, 12 insertions(+), 15 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 59c6155e4896..bca049102441 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -96,6 +96,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_keepalive_intvl;
 
 	int sysctl_tcp_syn_retries;
+	int sysctl_tcp_synack_retries;
 
 	struct ping_group_range ping_group_range;
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index a7f6f25297d7..5a162875e80c 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -240,7 +240,6 @@ extern int sysctl_tcp_timestamps;
 extern int sysctl_tcp_window_scaling;
 extern int sysctl_tcp_sack;
 extern int sysctl_tcp_fin_timeout;
-extern int sysctl_tcp_synack_retries;
 extern int sysctl_tcp_retries1;
 extern int sysctl_tcp_retries2;
 extern int sysctl_tcp_orphan_retries;
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 46b9c887bede..9b17c1792dce 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -482,10 +482,6 @@ EXPORT_SYMBOL_GPL(inet_csk_route_child_sock);
 #define AF_INET_FAMILY(fam) true
 #endif
 
-/* Only thing we need from tcp.h */
-extern int sysctl_tcp_synack_retries;
-
-
 /* Decide when to expire the request and when to resend SYN-ACK */
 static inline void syn_ack_recalc(struct request_sock *req, const int thresh,
 				  const int max_retries,
@@ -557,6 +553,7 @@ static void reqsk_timer_handler(unsigned long data)
 {
 	struct request_sock *req = (struct request_sock *)data;
 	struct sock *sk_listener = req->rsk_listener;
+	struct net *net = sock_net(sk_listener);
 	struct inet_connection_sock *icsk = inet_csk(sk_listener);
 	struct request_sock_queue *queue = &icsk->icsk_accept_queue;
 	int qlen, expire = 0, resend = 0;
@@ -566,7 +563,7 @@ static void reqsk_timer_handler(unsigned long data)
 	if (sk_state_load(sk_listener) != TCP_LISTEN)
 		goto drop;
 
-	max_retries = icsk->icsk_syn_retries ? : sysctl_tcp_synack_retries;
+	max_retries = icsk->icsk_syn_retries ? : net->ipv4.sysctl_tcp_synack_retries;
 	thresh = max_retries;
 	/* Normally all the openreqs are young and become mature
 	 * (i.e. converted to established socket) for first timeout.
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index db95287d2b94..5dd89de5bf8d 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -293,13 +293,6 @@ static struct ctl_table ipv4_table[] = {
 		.extra2		= &ip_ttl_max,
 	},
 	{
-		.procname	= "tcp_synack_retries",
-		.data		= &sysctl_tcp_synack_retries,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
-	{
 		.procname	= "tcp_max_orphans",
 		.data		= &sysctl_tcp_max_orphans,
 		.maxlen		= sizeof(int),
@@ -950,6 +943,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.extra1		= &tcp_syn_retries_min,
 		.extra2		= &tcp_syn_retries_max
 	},
+	{
+		.procname	= "tcp_synack_retries",
+		.data		= &init_net.ipv4.sysctl_tcp_synack_retries,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index c9944e0c48d3..a5268576021c 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2383,6 +2383,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_keepalive_intvl = TCP_KEEPALIVE_INTVL;
 
 	net->ipv4.sysctl_tcp_syn_retries = TCP_SYN_RETRIES;
+	net->ipv4.sysctl_tcp_synack_retries = TCP_SYNACK_RETRIES;
 
 	return 0;
 fail:
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index c5d51f530c65..ca25fdf0c525 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -22,7 +22,6 @@
 #include <linux/gfp.h>
 #include <net/tcp.h>
 
-int sysctl_tcp_synack_retries __read_mostly = TCP_SYNACK_RETRIES;
 int sysctl_tcp_retries1 __read_mostly = TCP_RETR1;
 int sysctl_tcp_retries2 __read_mostly = TCP_RETR2;
 int sysctl_tcp_orphan_retries __read_mostly;
@@ -332,7 +331,7 @@ static void tcp_fastopen_synack_timer(struct sock *sk)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	int max_retries = icsk->icsk_syn_retries ? :
-	    sysctl_tcp_synack_retries + 1; /* add one more retry for fastopen */
+	    sock_net(sk)->ipv4.sysctl_tcp_synack_retries + 1; /* add one more retry for fastopen */
 	struct request_sock *req;
 
 	req = tcp_sk(sk)->fastopen_rsk;
-- 
2.5.0
