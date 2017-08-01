From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 07/10] net: ipv6: Convert raw sockets to sk_lookup
Date: Mon, 31 Jul 2017 20:13:23 -0700
Message-ID: <1501557206-27503-8-git-send-email-dsahern@gmail.com>
References: <1501557206-27503-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36035 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751877AbdHADNr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 23:13:47 -0400
Received: by mail-pf0-f195.google.com with SMTP id t83so514867pfj.3
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 20:13:46 -0700 (PDT)
In-Reply-To: <1501557206-27503-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert __raw_v6_lookup to use the new sk_lookup struct

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/rawv6.h |  3 +--
 net/ipv4/raw_diag.c | 15 ++++++++++-----
 net/ipv6/raw.c      | 41 +++++++++++++++++++++++------------------
 3 files changed, 34 insertions(+), 25 deletions(-)

diff --git a/include/net/rawv6.h b/include/net/rawv6.h
index cbe4e9de1894..406268324d26 100644
--- a/include/net/rawv6.h
+++ b/include/net/rawv6.h
@@ -5,8 +5,7 @@
 
 extern struct raw_hashinfo raw_v6_hashinfo;
 struct sock *__raw_v6_lookup(struct net *net, struct sock *sk,
-			     unsigned short num, const struct in6_addr *loc_addr,
-			     const struct in6_addr *rmt_addr, int dif);
+			     const struct sk_lookup *params);
 
 int raw_abort(struct sock *sk, int err);
 
diff --git a/net/ipv4/raw_diag.c b/net/ipv4/raw_diag.c
index a708de070cc6..e081c03fd408 100644
--- a/net/ipv4/raw_diag.c
+++ b/net/ipv4/raw_diag.c
@@ -53,11 +53,16 @@ static struct sock *raw_lookup(struct net *net, struct sock *from,
 		sk = __raw_v4_lookup(net, from, &params);
 	}
 #if IS_ENABLED(CONFIG_IPV6)
-	else
-		sk = __raw_v6_lookup(net, from, r->sdiag_raw_protocol,
-				     (const struct in6_addr *)r->id.idiag_src,
-				     (const struct in6_addr *)r->id.idiag_dst,
-				     r->id.idiag_if);
+	else {
+		struct sk_lookup params = {
+			.saddr.ipv6 = (const struct in6_addr *)r->id.idiag_dst,
+			.daddr.ipv6 = (const struct in6_addr *)r->id.idiag_src,
+			.hnum = r->sdiag_raw_protocol,
+			.dif  = r->id.idiag_if,
+		};
+
+		sk = __raw_v6_lookup(net, from, &params);
+	}
 #endif
 	return sk;
 }
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 60be012fe708..51e651f18ffb 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -71,14 +71,14 @@ struct raw_hashinfo raw_v6_hashinfo = {
 EXPORT_SYMBOL_GPL(raw_v6_hashinfo);
 
 struct sock *__raw_v6_lookup(struct net *net, struct sock *sk,
-		unsigned short num, const struct in6_addr *loc_addr,
-		const struct in6_addr *rmt_addr, int dif)
+			     const struct sk_lookup *params)
 {
+	const struct in6_addr *loc_addr = params->daddr.ipv6;
+	const struct in6_addr *rmt_addr = params->saddr.ipv6;
 	bool is_multicast = ipv6_addr_is_multicast(loc_addr);
 
 	sk_for_each_from(sk)
-		if (inet_sk(sk)->inet_num == num) {
-
+		if (inet_sk(sk)->inet_num == params->hnum) {
 			if (!net_eq(sock_net(sk), net))
 				continue;
 
@@ -86,7 +86,8 @@ struct sock *__raw_v6_lookup(struct net *net, struct sock *sk,
 			    !ipv6_addr_equal(&sk->sk_v6_daddr, rmt_addr))
 				continue;
 
-			if (sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif)
+			if (sk->sk_bound_dev_if &&
+			    sk->sk_bound_dev_if != params->dif)
 				continue;
 
 			if (!ipv6_addr_any(&sk->sk_v6_rcv_saddr)) {
@@ -159,15 +160,17 @@ EXPORT_SYMBOL(rawv6_mh_filter_unregister);
  */
 static bool ipv6_raw_deliver(struct sk_buff *skb, int nexthdr)
 {
-	const struct in6_addr *saddr;
-	const struct in6_addr *daddr;
+	struct sk_lookup params = {
+		.saddr.ipv6 = &ipv6_hdr(skb)->saddr,
+		.daddr.ipv6 = &ipv6_hdr(skb)->daddr,
+		.hnum = nexthdr,
+		.dif  = inet6_iif(skb),
+	};
 	struct sock *sk;
 	bool delivered = false;
 	__u8 hash;
 	struct net *net;
 
-	saddr = &ipv6_hdr(skb)->saddr;
-	daddr = saddr + 1;
 
 	hash = nexthdr & (RAW_HTABLE_SIZE - 1);
 
@@ -178,7 +181,7 @@ static bool ipv6_raw_deliver(struct sk_buff *skb, int nexthdr)
 		goto out;
 
 	net = dev_net(skb->dev);
-	sk = __raw_v6_lookup(net, sk, nexthdr, daddr, saddr, inet6_iif(skb));
+	sk = __raw_v6_lookup(net, sk, &params);
 
 	while (sk) {
 		int filtered;
@@ -221,8 +224,7 @@ static bool ipv6_raw_deliver(struct sk_buff *skb, int nexthdr)
 				rawv6_rcv(sk, clone);
 			}
 		}
-		sk = __raw_v6_lookup(net, sk_next(sk), nexthdr, daddr, saddr,
-				     inet6_iif(skb));
+		sk = __raw_v6_lookup(net, sk_next(sk), &params);
 	}
 out:
 	read_unlock(&raw_v6_hashinfo.lock);
@@ -362,23 +364,26 @@ void raw6_icmp_error(struct sk_buff *skb, int nexthdr,
 		u8 type, u8 code, int inner_offset, __be32 info)
 {
 	struct sock *sk;
-	int hash;
-	const struct in6_addr *saddr, *daddr;
 	struct net *net;
+	int hash;
 
 	hash = nexthdr & (RAW_HTABLE_SIZE - 1);
 
 	read_lock(&raw_v6_hashinfo.lock);
 	sk = sk_head(&raw_v6_hashinfo.ht[hash]);
 	if (sk) {
+		struct sk_lookup params = {
+			.hnum = nexthdr,
+			.dif  = inet6_iif(skb),
+		};
 		/* Note: ipv6_hdr(skb) != skb->data */
 		const struct ipv6hdr *ip6h = (const struct ipv6hdr *)skb->data;
-		saddr = &ip6h->saddr;
-		daddr = &ip6h->daddr;
+
+		params.daddr.ipv6 = &ip6h->saddr;
+		params.saddr.ipv6 = &ip6h->daddr;
 		net = dev_net(skb->dev);
 
-		while ((sk = __raw_v6_lookup(net, sk, nexthdr, saddr, daddr,
-						inet6_iif(skb)))) {
+		while ((sk = __raw_v6_lookup(net, sk, &params))) {
 			rawv6_err(sk, skb, NULL, type, code,
 					inner_offset, info);
 			sk = sk_next(sk);
-- 
2.1.4
