From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v2 net-next 7/7] net: ipv6: add second dif to raw socket lookups
Date: Fri,  4 Aug 2017 13:17:03 -0700
Message-ID: <1501877823-31365-8-git-send-email-dsahern@gmail.com>
References: <1501877823-31365-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:32869 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752006AbdHDURQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 16:17:16 -0400
Received: by mail-pg0-f66.google.com with SMTP id u185so2710546pgb.0
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 13:17:16 -0700 (PDT)
In-Reply-To: <1501877823-31365-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a second device index, sdif, to raw socket lookups. sdif is the
index for ingress devices enslaved to an l3mdev. It allows the lookups
to consider the enslaved device as well as the L3 domain when searching
for a socket.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/rawv6.h |  2 +-
 net/ipv4/raw_diag.c |  2 +-
 net/ipv6/raw.c      | 13 ++++++++-----
 3 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/include/net/rawv6.h b/include/net/rawv6.h
index cbe4e9de1894..4addc5c988e0 100644
--- a/include/net/rawv6.h
+++ b/include/net/rawv6.h
@@ -6,7 +6,7 @@
 extern struct raw_hashinfo raw_v6_hashinfo;
 struct sock *__raw_v6_lookup(struct net *net, struct sock *sk,
 			     unsigned short num, const struct in6_addr *loc_addr,
-			     const struct in6_addr *rmt_addr, int dif);
+			     const struct in6_addr *rmt_addr, int dif, int sdif);
 
 int raw_abort(struct sock *sk, int err);
 
diff --git a/net/ipv4/raw_diag.c b/net/ipv4/raw_diag.c
index c600d3c71d4d..c200065ef9a5 100644
--- a/net/ipv4/raw_diag.c
+++ b/net/ipv4/raw_diag.c
@@ -52,7 +52,7 @@ static struct sock *raw_lookup(struct net *net, struct sock *from,
 		sk = __raw_v6_lookup(net, from, r->sdiag_raw_protocol,
 				     (const struct in6_addr *)r->id.idiag_src,
 				     (const struct in6_addr *)r->id.idiag_dst,
-				     r->id.idiag_if);
+				     r->id.idiag_if, 0);
 #endif
 	return sk;
 }
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 60be012fe708..e4462b0ff801 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -72,7 +72,7 @@ EXPORT_SYMBOL_GPL(raw_v6_hashinfo);
 
 struct sock *__raw_v6_lookup(struct net *net, struct sock *sk,
 		unsigned short num, const struct in6_addr *loc_addr,
-		const struct in6_addr *rmt_addr, int dif)
+		const struct in6_addr *rmt_addr, int dif, int sdif)
 {
 	bool is_multicast = ipv6_addr_is_multicast(loc_addr);
 
@@ -86,7 +86,9 @@ struct sock *__raw_v6_lookup(struct net *net, struct sock *sk,
 			    !ipv6_addr_equal(&sk->sk_v6_daddr, rmt_addr))
 				continue;
 
-			if (sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif)
+			if (sk->sk_bound_dev_if &&
+			    sk->sk_bound_dev_if != dif &&
+			    sk->sk_bound_dev_if != sdif)
 				continue;
 
 			if (!ipv6_addr_any(&sk->sk_v6_rcv_saddr)) {
@@ -178,7 +180,8 @@ static bool ipv6_raw_deliver(struct sk_buff *skb, int nexthdr)
 		goto out;
 
 	net = dev_net(skb->dev);
-	sk = __raw_v6_lookup(net, sk, nexthdr, daddr, saddr, inet6_iif(skb));
+	sk = __raw_v6_lookup(net, sk, nexthdr, daddr, saddr,
+			     inet6_iif(skb), inet6_sdif(skb));
 
 	while (sk) {
 		int filtered;
@@ -222,7 +225,7 @@ static bool ipv6_raw_deliver(struct sk_buff *skb, int nexthdr)
 			}
 		}
 		sk = __raw_v6_lookup(net, sk_next(sk), nexthdr, daddr, saddr,
-				     inet6_iif(skb));
+				     inet6_iif(skb), inet6_sdif(skb));
 	}
 out:
 	read_unlock(&raw_v6_hashinfo.lock);
@@ -378,7 +381,7 @@ void raw6_icmp_error(struct sk_buff *skb, int nexthdr,
 		net = dev_net(skb->dev);
 
 		while ((sk = __raw_v6_lookup(net, sk, nexthdr, saddr, daddr,
-						inet6_iif(skb)))) {
+					     inet6_iif(skb), inet6_iif(skb)))) {
 			rawv6_err(sk, skb, NULL, type, code,
 					inner_offset, info);
 			sk = sk_next(sk);
-- 
2.1.4
