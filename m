From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 3/3] ipv4: clean up cookie_v4_check()
Date: Wed, 15 Oct 2014 14:33:22 -0700
Message-ID: <1413408802-21052-3-git-send-email-xiyou.wangcong@gmail.com>
References: <1413408802-21052-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: davem@davemloft.net, Cong Wang <xiyou.wangcong@gmail.com>,
	Krzysztof Kolasa <kkolasa@winsoft.pl>,
	Eric Dumazet <edumazet@google.com>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:35698 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbaJOVdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 17:33:36 -0400
Received: by mail-pd0-f177.google.com with SMTP id v10so1921616pde.8
        for <netdev@vger.kernel.org>; Wed, 15 Oct 2014 14:33:35 -0700 (PDT)
In-Reply-To: <1413408802-21052-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>

We can retrieve opt from skb, no need to pass it as a parameter.
And opt should always be non-NULL, no need to check.

Cc: Krzysztof Kolasa <kkolasa@winsoft.pl>
Cc: Eric Dumazet <edumazet@google.com>
Tested-by: Krzysztof Kolasa <kkolasa@winsoft.pl>
Signed-off-by: Cong Wang <cwang@twopensource.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/tcp.h     | 5 ++---
 net/ipv4/syncookies.c | 6 +++---
 net/ipv4/tcp_ipv4.c   | 2 +-
 3 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 869637a..3a4bbbf 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -468,8 +468,7 @@ void inet_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb);
 /* From syncookies.c */
 int __cookie_v4_check(const struct iphdr *iph, const struct tcphdr *th,
 		      u32 cookie);
-struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
-			     struct ip_options *opt);
+struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb);
 #ifdef CONFIG_SYN_COOKIES
 
 /* Syncookies use a monotonic timer which increments every 60 seconds.
@@ -1674,7 +1673,7 @@ static inline struct ip_options_rcu *tcp_v4_save_options(struct sk_buff *skb)
 	const struct ip_options *opt = &TCP_SKB_CB(skb)->header.h4.opt;
 	struct ip_options_rcu *dopt = NULL;
 
-	if (opt && opt->optlen) {
+	if (opt->optlen) {
 		int opt_size = sizeof(*dopt) + opt->optlen;
 
 		dopt = kmalloc(opt_size, GFP_ATOMIC);
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index c68d0a1..d346303 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -255,9 +255,9 @@ bool cookie_check_timestamp(struct tcp_options_received *tcp_opt,
 }
 EXPORT_SYMBOL(cookie_check_timestamp);
 
-struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
-			     struct ip_options *opt)
+struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 {
+	struct ip_options *opt = &TCP_SKB_CB(skb)->header.h4.opt;
 	struct tcp_options_received tcp_opt;
 	struct inet_request_sock *ireq;
 	struct tcp_request_sock *treq;
@@ -336,7 +336,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	flowi4_init_output(&fl4, sk->sk_bound_dev_if, ireq->ir_mark,
 			   RT_CONN_FLAGS(sk), RT_SCOPE_UNIVERSE, IPPROTO_TCP,
 			   inet_sk_flowi_flags(sk),
-			   (opt && opt->srr) ? opt->faddr : ireq->ir_rmt_addr,
+			   opt->srr ? opt->faddr : ireq->ir_rmt_addr,
 			   ireq->ir_loc_addr, th->source, th->dest);
 	security_req_classify_flow(req, flowi4_to_flowi(&fl4));
 	rt = ip_route_output_key(sock_net(sk), &fl4);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 6a2a7d6..94d1a77 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1408,7 +1408,7 @@ static struct sock *tcp_v4_hnd_req(struct sock *sk, struct sk_buff *skb)
 
 #ifdef CONFIG_SYN_COOKIES
 	if (!th->syn)
-		sk = cookie_v4_check(sk, skb, &TCP_SKB_CB(skb)->header.h4.opt);
+		sk = cookie_v4_check(sk, skb);
 #endif
 	return sk;
 }
-- 
1.8.3.1
