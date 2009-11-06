From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipv6: udp: Optimise multicast reception
Date: Fri, 06 Nov 2009 17:35:55 +0100
Message-ID: <4AF4506B.3080905@gmail.com>
References: <200911052033.21964.lgrijincu@ixiacom.com> <20091106.004215.114490979.davem@davemloft.net> <200911061604.21465.lgrijincu@ixiacom.com> <4AF43C5E.4060300@gmail.com> <4AF447F7.6000700@gmail.com> <4AF44F3D.3050407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	netdev@vger.kernel.org, opurdila@ixiacom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:56964 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757641AbZKFQfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 11:35:55 -0500
In-Reply-To: <4AF44F3D.3050407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for previous empty mail :(

[PATCH net-next-2.6] ipv6: udp: Optimise multicast reception

IPV6 UDP multicast rx path is a bit complex and can hold a spinlock
for a long time.

Using a small (32 or 64 entries) stack of socket pointers can help
to perform expensive operations (skb_clone(), udp_queue_rcv_skb())
outside of the lock, in most cases.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/udp.c |   67 ++++++++++++++++++++++++++++++-----------------
 1 files changed, 43 insertions(+), 24 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 5bc7cdb..670662a 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -440,6 +440,27 @@ static struct sock *udp_v6_mcast_next(struct net *net, struct sock *sk,
 	return NULL;
 }
 
+static void flush_stack(struct sock **stack, unsigned int count,
+			struct sk_buff *skb, unsigned int final)
+{
+	unsigned int i;
+	struct sock *sk;
+	struct sk_buff *skb1;
+
+	for (i = 0; i < count; i++) {
+		skb1 = (i == final) ? skb : skb_clone(skb, GFP_ATOMIC);
+
+		if (skb1) {
+			sk = stack[i];
+			bh_lock_sock(sk);
+			if (!sock_owned_by_user(sk))
+				udpv6_queue_rcv_skb(sk, skb1);
+			else
+				sk_add_backlog(sk, skb1);
+			bh_unlock_sock(sk);
+		}
+	}
+}
 /*
  * Note: called only from the BH handler context,
  * so we don't need to lock the hashes.
@@ -448,41 +469,39 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 		struct in6_addr *saddr, struct in6_addr *daddr,
 		struct udp_table *udptable)
 {
-	struct sock *sk, *sk2;
+	struct sock *sk, *stack[256 / sizeof(struct sock *)];
 	const struct udphdr *uh = udp_hdr(skb);
 	struct udp_hslot *hslot = udp_hashslot(udptable, net, ntohs(uh->dest));
 	int dif;
+	unsigned int i, count = 0;
 
 	spin_lock(&hslot->lock);
 	sk = sk_nulls_head(&hslot->head);
 	dif = inet6_iif(skb);
 	sk = udp_v6_mcast_next(net, sk, uh->dest, daddr, uh->source, saddr, dif);
-	if (!sk) {
-		kfree_skb(skb);
-		goto out;
-	}
-
-	sk2 = sk;
-	while ((sk2 = udp_v6_mcast_next(net, sk_nulls_next(sk2), uh->dest, daddr,
-					uh->source, saddr, dif))) {
-		struct sk_buff *buff = skb_clone(skb, GFP_ATOMIC);
-		if (buff) {
-			bh_lock_sock(sk2);
-			if (!sock_owned_by_user(sk2))
-				udpv6_queue_rcv_skb(sk2, buff);
-			else
-				sk_add_backlog(sk2, buff);
-			bh_unlock_sock(sk2);
+	while (sk) {
+		stack[count++] = sk;
+		sk = udp_v6_mcast_next(net, sk_nulls_next(sk), uh->dest, daddr,
+				       uh->source, saddr, dif);
+		if (unlikely(count == ARRAY_SIZE(stack))) {
+			if (!sk)
+				break;
+			flush_stack(stack, count, skb, ~0);
+			count = 0;
 		}
 	}
-	bh_lock_sock(sk);
-	if (!sock_owned_by_user(sk))
-		udpv6_queue_rcv_skb(sk, skb);
-	else
-		sk_add_backlog(sk, skb);
-	bh_unlock_sock(sk);
-out:
+	/*
+	 * before releasing the lock, we must take reference on sockets
+	 */
+	for (i = 0; i < count; i++)
+		sock_hold(stack[i]);
+
 	spin_unlock(&hslot->lock);
+
+	flush_stack(stack, count, skb, count - 1);
+
+	for (i = 0; i < count; i++)
+		sock_put(stack[i]);
 	return 0;
 }
 
