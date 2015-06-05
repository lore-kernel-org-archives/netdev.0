From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: get_cookie_sock() consolidation
Date: Thu, 04 Jun 2015 18:30:43 -0700
Message-ID: <1433467843.1895.47.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:34848 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752374AbbFEBap (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 21:30:45 -0400
Received: by igbzc4 with SMTP id zc4so4738797igb.0
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 18:30:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

IPv4 and IPv6 share same implementation of get_cookie_sock(),
and there is no point inlining it.

We add tcp_ prefix to the common helper name and export it.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h     |    3 +++
 net/ipv4/syncookies.c |   10 +++++-----
 net/ipv6/syncookies.c |   19 +------------------
 3 files changed, 9 insertions(+), 23 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 2bb2bad21d5c2e0d1b079e7bcf19e192bc126637..978cebedd3fc5c5e12bcfe46e4835c480e53a1be 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -469,6 +469,9 @@ int tcp_send_rcvq(struct sock *sk, struct msghdr *msg, size_t size);
 void inet_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb);
 
 /* From syncookies.c */
+struct sock *tcp_get_cookie_sock(struct sock *sk, struct sk_buff *skb,
+				 struct request_sock *req,
+				 struct dst_entry *dst);
 int __cookie_v4_check(const struct iphdr *iph, const struct tcphdr *th,
 		      u32 cookie);
 struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb);
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index df849e5a10f1d7f41fb3353a26356ede81f56f72..d70b1f603692554664c478ebb597ba73958ebd9a 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -219,9 +219,9 @@ int __cookie_v4_check(const struct iphdr *iph, const struct tcphdr *th,
 }
 EXPORT_SYMBOL_GPL(__cookie_v4_check);
 
-static struct sock *get_cookie_sock(struct sock *sk, struct sk_buff *skb,
-				    struct request_sock *req,
-				    struct dst_entry *dst)
+struct sock *tcp_get_cookie_sock(struct sock *sk, struct sk_buff *skb,
+				 struct request_sock *req,
+				 struct dst_entry *dst)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct sock *child;
@@ -235,7 +235,7 @@ static struct sock *get_cookie_sock(struct sock *sk, struct sk_buff *skb,
 	}
 	return child;
 }
-
+EXPORT_SYMBOL(tcp_get_cookie_sock);
 
 /*
  * when syncookies are in effect and tcp timestamps are enabled we stored
@@ -391,7 +391,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	ireq->rcv_wscale  = rcv_wscale;
 	ireq->ecn_ok = cookie_ecn_ok(&tcp_opt, sock_net(sk), &rt->dst);
 
-	ret = get_cookie_sock(sk, skb, req, &rt->dst);
+	ret = tcp_get_cookie_sock(sk, skb, req, &rt->dst);
 	/* ip_queue_xmit() depends on our flow being setup
 	 * Normal sockets get it right from inet_csk_route_child_sock()
 	 */
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 21bc2eb53c57bce6dd0a1073bc77766eabf9ac5f..0909f4e0d53c200f6643883df29682bca8e86fbb 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -41,23 +41,6 @@ static __u16 const msstab[] = {
 	9000 - 60,
 };
 
-static inline struct sock *get_cookie_sock(struct sock *sk, struct sk_buff *skb,
-					   struct request_sock *req,
-					   struct dst_entry *dst)
-{
-	struct inet_connection_sock *icsk = inet_csk(sk);
-	struct sock *child;
-
-	child = icsk->icsk_af_ops->syn_recv_sock(sk, skb, req, dst);
-	if (child) {
-		atomic_set(&req->rsk_refcnt, 1);
-		inet_csk_reqsk_queue_add(sk, req, child);
-	} else {
-		reqsk_free(req);
-	}
-	return child;
-}
-
 static DEFINE_PER_CPU(__u32 [16 + 5 + SHA_WORKSPACE_WORDS],
 		      ipv6_cookie_scratch);
 
@@ -264,7 +247,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	ireq->rcv_wscale = rcv_wscale;
 	ireq->ecn_ok = cookie_ecn_ok(&tcp_opt, sock_net(sk), dst);
 
-	ret = get_cookie_sock(sk, skb, req, dst);
+	ret = tcp_get_cookie_sock(sk, skb, req, dst);
 out:
 	return ret;
 out_free:
