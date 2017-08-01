From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 04/10] net: ipv4: Convert raw sockets to sk_lookup
Date: Mon, 31 Jul 2017 20:13:20 -0700
Message-ID: <1501557206-27503-5-git-send-email-dsahern@gmail.com>
References: <1501557206-27503-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35067 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751808AbdHADNm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 23:13:42 -0400
Received: by mail-pf0-f194.google.com with SMTP id q85so514640pfq.2
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 20:13:42 -0700 (PDT)
In-Reply-To: <1501557206-27503-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert __raw_v4_lookup to use the new sk_lookup struct

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/raw.h   |  3 +--
 net/ipv4/raw.c      | 72 ++++++++++++++++++++++++++++++++++-------------------
 net/ipv4/raw_diag.c | 15 +++++++----
 3 files changed, 58 insertions(+), 32 deletions(-)

diff --git a/include/net/raw.h b/include/net/raw.h
index 57c33dd22ec4..8d0f0e5d013b 100644
--- a/include/net/raw.h
+++ b/include/net/raw.h
@@ -25,8 +25,7 @@ extern struct proto raw_prot;
 
 extern struct raw_hashinfo raw_v4_hashinfo;
 struct sock *__raw_v4_lookup(struct net *net, struct sock *sk,
-			     unsigned short num, __be32 raddr,
-			     __be32 laddr, int dif);
+			     const struct sk_lookup *params);
 
 int raw_abort(struct sock *sk, int err);
 void raw_icmp_error(struct sk_buff *, int, u32);
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index b0bb5d0a30bd..4da5d87a61a5 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -122,15 +122,23 @@ void raw_unhash_sk(struct sock *sk)
 EXPORT_SYMBOL_GPL(raw_unhash_sk);
 
 struct sock *__raw_v4_lookup(struct net *net, struct sock *sk,
-		unsigned short num, __be32 raddr, __be32 laddr, int dif)
+			     const struct sk_lookup *params)
 {
+	__be32 raddr = params->saddr.ipv4;
+	__be32 laddr = params->daddr.ipv4;
+
 	sk_for_each_from(sk) {
 		struct inet_sock *inet = inet_sk(sk);
+		bool dev_match;
+
+		dev_match = (!sk->sk_bound_dev_if ||
+				sk->sk_bound_dev_if == params->dif);
 
-		if (net_eq(sock_net(sk), net) && inet->inet_num == num	&&
-		    !(inet->inet_daddr && inet->inet_daddr != raddr) 	&&
+		if (net_eq(sock_net(sk), net) &&
+		    inet->inet_num == params->hnum &&
+		    !(inet->inet_daddr && inet->inet_daddr != raddr) &&
 		    !(inet->inet_rcv_saddr && inet->inet_rcv_saddr != laddr) &&
-		    !(sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif))
+			dev_match)
 			goto found; /* gotcha */
 	}
 	sk = NULL;
@@ -169,23 +177,20 @@ static int icmp_filter(const struct sock *sk, const struct sk_buff *skb)
  * RFC 1122: SHOULD pass TOS value up to the transport layer.
  * -> It does. And not only TOS, but all IP header.
  */
-static int raw_v4_input(struct sk_buff *skb, const struct iphdr *iph, int hash)
+static int __raw_v4_input(struct sk_buff *skb, const struct iphdr *iph,
+			  struct hlist_head *head)
 {
-	struct sock *sk;
-	struct hlist_head *head;
+	struct net *net = dev_net(skb->dev);
+	const struct sk_lookup params = {
+		.saddr.ipv4 = iph->saddr,
+		.daddr.ipv4 = iph->daddr,
+		.hnum = iph->protocol,
+		.dif  = skb->dev->ifindex,
+	};
 	int delivered = 0;
-	struct net *net;
-
-	read_lock(&raw_v4_hashinfo.lock);
-	head = &raw_v4_hashinfo.ht[hash];
-	if (hlist_empty(head))
-		goto out;
-
-	net = dev_net(skb->dev);
-	sk = __raw_v4_lookup(net, __sk_head(head), iph->protocol,
-			     iph->saddr, iph->daddr,
-			     skb->dev->ifindex);
+	struct sock *sk;
 
+	sk = __raw_v4_lookup(net, __sk_head(head), &params);
 	while (sk) {
 		delivered = 1;
 		if ((iph->protocol != IPPROTO_ICMP || !icmp_filter(sk, skb)) &&
@@ -197,11 +202,22 @@ static int raw_v4_input(struct sk_buff *skb, const struct iphdr *iph, int hash)
 			if (clone)
 				raw_rcv(sk, clone);
 		}
-		sk = __raw_v4_lookup(net, sk_next(sk), iph->protocol,
-				     iph->saddr, iph->daddr,
-				     skb->dev->ifindex);
+		sk = __raw_v4_lookup(net, sk_next(sk), &params);
 	}
-out:
+
+	return delivered;
+}
+
+static int raw_v4_input(struct sk_buff *skb, const struct iphdr *iph, int hash)
+{
+	struct hlist_head *head;
+	int delivered = 0;
+
+	read_lock(&raw_v4_hashinfo.lock);
+	head = &raw_v4_hashinfo.ht[hash];
+	if (!hlist_empty(head))
+		delivered = __raw_v4_input(skb, iph, head);
+
 	read_unlock(&raw_v4_hashinfo.lock);
 	return delivered;
 }
@@ -297,12 +313,18 @@ void raw_icmp_error(struct sk_buff *skb, int protocol, u32 info)
 	read_lock(&raw_v4_hashinfo.lock);
 	raw_sk = sk_head(&raw_v4_hashinfo.ht[hash]);
 	if (raw_sk) {
+		struct sk_lookup params = {
+			.hnum = protocol,
+			.dif = skb->dev->ifindex,
+		};
+
 		iph = (const struct iphdr *)skb->data;
 		net = dev_net(skb->dev);
 
-		while ((raw_sk = __raw_v4_lookup(net, raw_sk, protocol,
-						iph->daddr, iph->saddr,
-						skb->dev->ifindex)) != NULL) {
+		params.saddr.ipv4 = iph->daddr;
+		params.daddr.ipv4 = iph->saddr;
+		while ((raw_sk = __raw_v4_lookup(net, raw_sk,
+						 &params)) != NULL) {
 			raw_err(raw_sk, skb, info);
 			raw_sk = sk_next(raw_sk);
 			iph = (const struct iphdr *)skb->data;
diff --git a/net/ipv4/raw_diag.c b/net/ipv4/raw_diag.c
index e1a51ca68d23..a708de070cc6 100644
--- a/net/ipv4/raw_diag.c
+++ b/net/ipv4/raw_diag.c
@@ -42,11 +42,16 @@ static struct sock *raw_lookup(struct net *net, struct sock *from,
 	struct inet_diag_req_raw *r = (void *)req;
 	struct sock *sk = NULL;
 
-	if (r->sdiag_family == AF_INET)
-		sk = __raw_v4_lookup(net, from, r->sdiag_raw_protocol,
-				     r->id.idiag_dst[0],
-				     r->id.idiag_src[0],
-				     r->id.idiag_if);
+	if (r->sdiag_family == AF_INET) {
+		const struct sk_lookup params = {
+			.saddr.ipv4 = r->id.idiag_dst[0],
+			.daddr.ipv4 = r->id.idiag_src[0],
+			.hnum = r->sdiag_raw_protocol,
+			.dif = r->id.idiag_if,
+		};
+
+		sk = __raw_v4_lookup(net, from, &params);
+	}
 #if IS_ENABLED(CONFIG_IPV6)
 	else
 		sk = __raw_v6_lookup(net, from, r->sdiag_raw_protocol,
-- 
2.1.4
