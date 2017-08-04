From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v2 net-next 3/7] net: ipv4: add second dif to raw socket lookups
Date: Fri,  4 Aug 2017 13:16:59 -0700
Message-ID: <1501877823-31365-4-git-send-email-dsahern@gmail.com>
References: <1501877823-31365-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36418 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751870AbdHDURN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 16:17:13 -0400
Received: by mail-pf0-f193.google.com with SMTP id t83so2758884pfj.3
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 13:17:13 -0700 (PDT)
In-Reply-To: <1501877823-31365-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a second device index, sdif, to raw socket lookups. sdif is the
index for ingress devices enslaved to an l3mdev. It allows the lookups
to consider the enslaved device as well as the L3 domain when searching
for a socket.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/raw.h   |  2 +-
 net/ipv4/raw.c      | 16 +++++++++++-----
 net/ipv4/raw_diag.c |  2 +-
 3 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/include/net/raw.h b/include/net/raw.h
index 57c33dd22ec4..99d26d0c4a19 100644
--- a/include/net/raw.h
+++ b/include/net/raw.h
@@ -26,7 +26,7 @@ extern struct proto raw_prot;
 extern struct raw_hashinfo raw_v4_hashinfo;
 struct sock *__raw_v4_lookup(struct net *net, struct sock *sk,
 			     unsigned short num, __be32 raddr,
-			     __be32 laddr, int dif);
+			     __be32 laddr, int dif, int sdif);
 
 int raw_abort(struct sock *sk, int err);
 void raw_icmp_error(struct sk_buff *, int, u32);
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index b0bb5d0a30bd..2726aecf224b 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -122,7 +122,8 @@ void raw_unhash_sk(struct sock *sk)
 EXPORT_SYMBOL_GPL(raw_unhash_sk);
 
 struct sock *__raw_v4_lookup(struct net *net, struct sock *sk,
-		unsigned short num, __be32 raddr, __be32 laddr, int dif)
+			     unsigned short num, __be32 raddr, __be32 laddr,
+			     int dif, int sdif)
 {
 	sk_for_each_from(sk) {
 		struct inet_sock *inet = inet_sk(sk);
@@ -130,7 +131,8 @@ struct sock *__raw_v4_lookup(struct net *net, struct sock *sk,
 		if (net_eq(sock_net(sk), net) && inet->inet_num == num	&&
 		    !(inet->inet_daddr && inet->inet_daddr != raddr) 	&&
 		    !(inet->inet_rcv_saddr && inet->inet_rcv_saddr != laddr) &&
-		    !(sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif))
+		    !(sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif &&
+		      sk->sk_bound_dev_if != sdif))
 			goto found; /* gotcha */
 	}
 	sk = NULL;
@@ -171,6 +173,7 @@ static int icmp_filter(const struct sock *sk, const struct sk_buff *skb)
  */
 static int raw_v4_input(struct sk_buff *skb, const struct iphdr *iph, int hash)
 {
+	int sdif = inet_sdif(skb);
 	struct sock *sk;
 	struct hlist_head *head;
 	int delivered = 0;
@@ -184,7 +187,7 @@ static int raw_v4_input(struct sk_buff *skb, const struct iphdr *iph, int hash)
 	net = dev_net(skb->dev);
 	sk = __raw_v4_lookup(net, __sk_head(head), iph->protocol,
 			     iph->saddr, iph->daddr,
-			     skb->dev->ifindex);
+			     skb->dev->ifindex, sdif);
 
 	while (sk) {
 		delivered = 1;
@@ -199,7 +202,7 @@ static int raw_v4_input(struct sk_buff *skb, const struct iphdr *iph, int hash)
 		}
 		sk = __raw_v4_lookup(net, sk_next(sk), iph->protocol,
 				     iph->saddr, iph->daddr,
-				     skb->dev->ifindex);
+				     skb->dev->ifindex, sdif);
 	}
 out:
 	read_unlock(&raw_v4_hashinfo.lock);
@@ -297,12 +300,15 @@ void raw_icmp_error(struct sk_buff *skb, int protocol, u32 info)
 	read_lock(&raw_v4_hashinfo.lock);
 	raw_sk = sk_head(&raw_v4_hashinfo.ht[hash]);
 	if (raw_sk) {
+		int dif = skb->dev->ifindex;
+		int sdif = inet_sdif(skb);
+
 		iph = (const struct iphdr *)skb->data;
 		net = dev_net(skb->dev);
 
 		while ((raw_sk = __raw_v4_lookup(net, raw_sk, protocol,
 						iph->daddr, iph->saddr,
-						skb->dev->ifindex)) != NULL) {
+						dif, sdif)) != NULL) {
 			raw_err(raw_sk, skb, info);
 			raw_sk = sk_next(raw_sk);
 			iph = (const struct iphdr *)skb->data;
diff --git a/net/ipv4/raw_diag.c b/net/ipv4/raw_diag.c
index e1a51ca68d23..c600d3c71d4d 100644
--- a/net/ipv4/raw_diag.c
+++ b/net/ipv4/raw_diag.c
@@ -46,7 +46,7 @@ static struct sock *raw_lookup(struct net *net, struct sock *from,
 		sk = __raw_v4_lookup(net, from, r->sdiag_raw_protocol,
 				     r->id.idiag_dst[0],
 				     r->id.idiag_src[0],
-				     r->id.idiag_if);
+				     r->id.idiag_if, 0);
 #if IS_ENABLED(CONFIG_IPV6)
 	else
 		sk = __raw_v6_lookup(net, from, r->sdiag_raw_protocol,
-- 
2.1.4
