From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 14/15] tcp: Namespace-ify sysctl_tcp_adv_win_scale
Date: Thu, 26 Oct 2017 16:35:25 -0700
Message-ID: <20171026233526.6155-15-edumazet@google.com>
References: <20171026233526.6155-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:47979 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932470AbdJZXgF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 19:36:05 -0400
Received: by mail-pf0-f195.google.com with SMTP id z11so3614568pfk.4
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 16:36:05 -0700 (PDT)
In-Reply-To: <20171026233526.6155-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/netns/ipv4.h   |  1 +
 include/net/tcp.h          |  9 ++++-----
 net/ipv4/sysctl_net_ipv4.c | 18 +++++++++---------
 net/ipv4/tcp_input.c       | 13 +++++--------
 net/ipv4/tcp_ipv4.c        |  1 +
 5 files changed, 20 insertions(+), 22 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 63f91d52cbc0ad35d8e04a8da0d9f57aa960bcb0..9dbb07d4eff465428817831e55c6a4922b7208fb 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -140,6 +140,7 @@ struct netns_ipv4 {
 	int sysctl_tcp_max_reordering;
 	int sysctl_tcp_dsack;
 	int sysctl_tcp_app_win;
+	int sysctl_tcp_adv_win_scale;
 	struct inet_timewait_death_row tcp_death_row;
 	int sysctl_max_syn_backlog;
 	int sysctl_tcp_fastopen;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index c6bee85a3dec0dea6d4402d89184ade02a637a2e..2572b57682987dd5f3700ed47d63e7238946b9a8 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -244,7 +244,6 @@ extern int sysctl_tcp_max_orphans;
 extern long sysctl_tcp_mem[3];
 extern int sysctl_tcp_wmem[3];
 extern int sysctl_tcp_rmem[3];
-extern int sysctl_tcp_adv_win_scale;
 extern int sysctl_tcp_frto;
 extern int sysctl_tcp_nometrics_save;
 extern int sysctl_tcp_moderate_rcvbuf;
@@ -1308,9 +1307,9 @@ void tcp_select_initial_window(int __space, __u32 mss, __u32 *rcv_wnd,
 			       __u32 *window_clamp, int wscale_ok,
 			       __u8 *rcv_wscale, __u32 init_rcv_wnd);
 
-static inline int tcp_win_from_space(int space)
+static inline int tcp_win_from_space(const struct sock *sk, int space)
 {
-	int tcp_adv_win_scale = sysctl_tcp_adv_win_scale;
+	int tcp_adv_win_scale = sock_net(sk)->ipv4.sysctl_tcp_adv_win_scale;
 
 	return tcp_adv_win_scale <= 0 ?
 		(space>>(-tcp_adv_win_scale)) :
@@ -1320,13 +1319,13 @@ static inline int tcp_win_from_space(int space)
 /* Note: caller must be prepared to deal with negative returns */
 static inline int tcp_space(const struct sock *sk)
 {
-	return tcp_win_from_space(sk->sk_rcvbuf -
+	return tcp_win_from_space(sk, sk->sk_rcvbuf -
 				  atomic_read(&sk->sk_rmem_alloc));
 }
 
 static inline int tcp_full_space(const struct sock *sk)
 {
-	return tcp_win_from_space(sk->sk_rcvbuf);
+	return tcp_win_from_space(sk, sk->sk_rcvbuf);
 }
 
 extern void tcp_openreq_init_rwin(struct request_sock *req,
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index e057788834a99cf99e141a602ddbe19b8e6fce3c..a95123e1e7da706c88bf5553b7d8ef6c2653ab50 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -437,15 +437,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &one,
 	},
-	{
-		.procname	= "tcp_adv_win_scale",
-		.data		= &sysctl_tcp_adv_win_scale,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &tcp_adv_win_scale_min,
-		.extra2		= &tcp_adv_win_scale_max,
-	},
 	{
 		.procname	= "tcp_frto",
 		.data		= &sysctl_tcp_frto,
@@ -1145,6 +1136,15 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "tcp_adv_win_scale",
+		.data		= &init_net.ipv4.sysctl_tcp_adv_win_scale,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &tcp_adv_win_scale_min,
+		.extra2		= &tcp_adv_win_scale_max,
+	},
 	{ }
 };
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 06a8c27e1a690e3b26cb6773320bafa31b06d3b3..d01f390da23dcd4100271b150bd8bc143f7328cf 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -77,9 +77,6 @@
 #include <linux/errqueue.h>
 #include <trace/events/tcp.h>
 
-int sysctl_tcp_adv_win_scale __read_mostly = 1;
-EXPORT_SYMBOL(sysctl_tcp_adv_win_scale);
-
 /* rfc5961 challenge ack rate limiting */
 int sysctl_tcp_challenge_ack_limit = 1000;
 
@@ -361,8 +358,8 @@ static int __tcp_grow_window(const struct sock *sk, const struct sk_buff *skb)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	/* Optimize this! */
-	int truesize = tcp_win_from_space(skb->truesize) >> 1;
-	int window = tcp_win_from_space(sysctl_tcp_rmem[2]) >> 1;
+	int truesize = tcp_win_from_space(sk, skb->truesize) >> 1;
+	int window = tcp_win_from_space(sk, sysctl_tcp_rmem[2]) >> 1;
 
 	while (tp->rcv_ssthresh <= window) {
 		if (truesize <= skb->len)
@@ -387,7 +384,7 @@ static void tcp_grow_window(struct sock *sk, const struct sk_buff *skb)
 		/* Check #2. Increase window, if skb with such overhead
 		 * will fit to rcvbuf in future.
 		 */
-		if (tcp_win_from_space(skb->truesize) <= skb->len)
+		if (tcp_win_from_space(sk, skb->truesize) <= skb->len)
 			incr = 2 * tp->advmss;
 		else
 			incr = __tcp_grow_window(sk, skb);
@@ -628,7 +625,7 @@ void tcp_rcv_space_adjust(struct sock *sk)
 		}
 
 		rcvmem = SKB_TRUESIZE(tp->advmss + MAX_TCP_HEADER);
-		while (tcp_win_from_space(rcvmem) < tp->advmss)
+		while (tcp_win_from_space(sk, rcvmem) < tp->advmss)
 			rcvmem += 128;
 
 		rcvbuf = min(rcvwin / tp->advmss * rcvmem, sysctl_tcp_rmem[2]);
@@ -4789,7 +4786,7 @@ tcp_collapse(struct sock *sk, struct sk_buff_head *list, struct rb_root *root,
 		 *   overlaps to the next one.
 		 */
 		if (!(TCP_SKB_CB(skb)->tcp_flags & (TCPHDR_SYN | TCPHDR_FIN)) &&
-		    (tcp_win_from_space(skb->truesize) > skb->len ||
+		    (tcp_win_from_space(sk, skb->truesize) > skb->len ||
 		     before(TCP_SKB_CB(skb)->seq, start))) {
 			end_of_skbs = false;
 			break;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 189664ebd28e4cda7ef40a47591c3bd8cac3574b..1fe30fb99308b3e3fd07509b509b0e3727cc5d44 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2491,6 +2491,7 @@ static int __net_init tcp_sk_init(struct net *net)
 	net->ipv4.sysctl_tcp_max_reordering = 300;
 	net->ipv4.sysctl_tcp_dsack = 1;
 	net->ipv4.sysctl_tcp_app_win = 31;
+	net->ipv4.sysctl_tcp_adv_win_scale = 1;
 
 	net->ipv4.sysctl_tcp_fastopen = TFO_CLIENT_ENABLE;
 	spin_lock_init(&net->ipv4.tcp_fastopen_ctx_lock);
-- 
2.15.0.rc2.357.g7e34df9404-goog
