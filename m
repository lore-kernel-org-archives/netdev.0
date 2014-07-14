From: David Held <drheld@google.com>
Subject: [PATCH net-next 1/2] udp: Simplify __udp*_lib_mcast_deliver.
Date: Mon, 14 Jul 2014 18:30:38 -0400
Message-ID: <1405377039-10082-1-git-send-email-drheld@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, willemb@google.com,
	David Held <drheld@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f74.google.com ([209.85.220.74]:59418 "EHLO
	mail-pa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757078AbaGNWbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 18:31:01 -0400
Received: by mail-pa0-f74.google.com with SMTP id rd3so405958pab.1
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2014 15:31:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch to using sk_nulls_for_each which shortens the code and makes it
easier to update.

Signed-off-by: David Held <drheld@google.com>
---
 net/ipv4/udp.c | 48 ++++++++++----------------------
 net/ipv6/udp.c | 88 +++++++++++++++++++++++-----------------------------------
 2 files changed, 49 insertions(+), 87 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index ac30e10..8089ba2 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -594,26 +594,6 @@ static inline bool __udp_is_mcast_sock(struct net *net, struct sock *sk,
 	return true;
 }
 
-static inline struct sock *udp_v4_mcast_next(struct net *net, struct sock *sk,
-					     __be16 loc_port, __be32 loc_addr,
-					     __be16 rmt_port, __be32 rmt_addr,
-					     int dif)
-{
-	struct hlist_nulls_node *node;
-	unsigned short hnum = ntohs(loc_port);
-
-	sk_nulls_for_each_from(sk, node) {
-		if (__udp_is_mcast_sock(net, sk,
-					loc_port, loc_addr,
-					rmt_port, rmt_addr,
-					dif, hnum))
-			goto found;
-	}
-	sk = NULL;
-found:
-	return sk;
-}
-
 /*
  * This routine is called by the ICMP module when it gets some
  * sort of error condition.  If err < 0 then the socket should
@@ -1664,23 +1644,23 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 				    struct udp_table *udptable)
 {
 	struct sock *sk, *stack[256 / sizeof(struct sock *)];
-	struct udp_hslot *hslot = udp_hashslot(udptable, net, ntohs(uh->dest));
-	int dif;
+	struct hlist_nulls_node *node;
+	unsigned short hnum = ntohs(uh->dest);
+	struct udp_hslot *hslot = udp_hashslot(udptable, net, hnum);
+	int dif = skb->dev->ifindex;
 	unsigned int i, count = 0;
 
 	spin_lock(&hslot->lock);
-	sk = sk_nulls_head(&hslot->head);
-	dif = skb->dev->ifindex;
-	sk = udp_v4_mcast_next(net, sk, uh->dest, daddr, uh->source, saddr, dif);
-	while (sk) {
-		stack[count++] = sk;
-		sk = udp_v4_mcast_next(net, sk_nulls_next(sk), uh->dest,
-				       daddr, uh->source, saddr, dif);
-		if (unlikely(count == ARRAY_SIZE(stack))) {
-			if (!sk)
-				break;
-			flush_stack(stack, count, skb, ~0);
-			count = 0;
+	sk_nulls_for_each(sk, node, &hslot->head) {
+		if (__udp_is_mcast_sock(net, sk,
+					uh->dest, daddr,
+					uh->source, saddr,
+					dif, hnum)) {
+			stack[count++] = sk;
+			if (unlikely(count == ARRAY_SIZE(stack))) {
+				flush_stack(stack, count, skb, ~0);
+				count = 0;
+			}
 		}
 	}
 	/*
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index c2bd28f..cade19b 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -698,43 +698,26 @@ drop:
 	return -1;
 }
 
-static struct sock *udp_v6_mcast_next(struct net *net, struct sock *sk,
-				      __be16 loc_port, const struct in6_addr *loc_addr,
-				      __be16 rmt_port, const struct in6_addr *rmt_addr,
-				      int dif)
+static bool __udp_v6_is_mcast_sock(struct net *net, struct sock *sk,
+				   __be16 loc_port, const struct in6_addr *loc_addr,
+				   __be16 rmt_port, const struct in6_addr *rmt_addr,
+				   int dif, unsigned short hnum)
 {
-	struct hlist_nulls_node *node;
-	unsigned short num = ntohs(loc_port);
-
-	sk_nulls_for_each_from(sk, node) {
-		struct inet_sock *inet = inet_sk(sk);
-
-		if (!net_eq(sock_net(sk), net))
-			continue;
-
-		if (udp_sk(sk)->udp_port_hash == num &&
-		    sk->sk_family == PF_INET6) {
-			if (inet->inet_dport) {
-				if (inet->inet_dport != rmt_port)
-					continue;
-			}
-			if (!ipv6_addr_any(&sk->sk_v6_daddr) &&
-			    !ipv6_addr_equal(&sk->sk_v6_daddr, rmt_addr))
-				continue;
-
-			if (sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif)
-				continue;
+	struct inet_sock *inet = inet_sk(sk);
 
-			if (!ipv6_addr_any(&sk->sk_v6_rcv_saddr)) {
-				if (!ipv6_addr_equal(&sk->sk_v6_rcv_saddr, loc_addr))
-					continue;
-			}
-			if (!inet6_mc_check(sk, loc_addr, rmt_addr))
-				continue;
-			return sk;
-		}
-	}
-	return NULL;
+	if (!net_eq(sock_net(sk), net))
+		return false;
+
+	if (udp_sk(sk)->udp_port_hash != hnum ||
+	    sk->sk_family != PF_INET6 ||
+	    (inet->inet_dport && inet->inet_dport != rmt_port) ||
+	    (!ipv6_addr_any(&sk->sk_v6_daddr) &&
+		    !ipv6_addr_equal(&sk->sk_v6_daddr, rmt_addr)) ||
+	    (sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif))
+		return false;
+	if (!inet6_mc_check(sk, loc_addr, rmt_addr))
+		return false;
+	return true;
 }
 
 static void flush_stack(struct sock **stack, unsigned int count,
@@ -783,28 +766,27 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 {
 	struct sock *sk, *stack[256 / sizeof(struct sock *)];
 	const struct udphdr *uh = udp_hdr(skb);
-	struct udp_hslot *hslot = udp_hashslot(udptable, net, ntohs(uh->dest));
-	int dif;
+	struct hlist_nulls_node *node;
+	unsigned short hnum = ntohs(uh->dest);
+	struct udp_hslot *hslot = udp_hashslot(udptable, net, hnum);
+	int dif = inet6_iif(skb);
 	unsigned int i, count = 0;
 
 	spin_lock(&hslot->lock);
-	sk = sk_nulls_head(&hslot->head);
-	dif = inet6_iif(skb);
-	sk = udp_v6_mcast_next(net, sk, uh->dest, daddr, uh->source, saddr, dif);
-	while (sk) {
-		/* If zero checksum and no_check is not on for
-		 * the socket then skip it.
-		 */
-		if (uh->check || udp_sk(sk)->no_check6_rx)
+	sk_nulls_for_each(sk, node, &hslot->head) {
+		if (__udp_v6_is_mcast_sock(net, sk,
+					   uh->dest, daddr,
+					   uh->source, saddr,
+					   dif, hnum) &&
+		    /* If zero checksum and no_check is not on for
+		     * the socket then skip it.
+		     */
+		    (uh->check || udp_sk(sk)->no_check6_rx)) {
 			stack[count++] = sk;
-
-		sk = udp_v6_mcast_next(net, sk_nulls_next(sk), uh->dest, daddr,
-				       uh->source, saddr, dif);
-		if (unlikely(count == ARRAY_SIZE(stack))) {
-			if (!sk)
-				break;
-			flush_stack(stack, count, skb, ~0);
-			count = 0;
+			if (unlikely(count == ARRAY_SIZE(stack))) {
+				flush_stack(stack, count, skb, ~0);
+				count = 0;
+			}
 		}
 	}
 	/*
-- 
2.0.0.526.g5318336
