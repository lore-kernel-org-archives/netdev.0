From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 7/8] ipv6: udp: Optimise multicast reception
Date: Sun, 08 Nov 2009 21:18:52 +0100
Message-ID: <4AF727AC.4010904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	Octavian Purdila <opurdila@ixiacom.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:46207 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755210AbZKHUSz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2009 15:18:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


IPV6 UDP multicast rx path is a bit complex and can hold a spinlock
for a long time.

Using a small (32 or 64 entries) stack of socket pointers can help
to perform expensive operations (skb_clone(), udp_queue_rcv_skb())
outside of the lock, in most cases.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/udp.c |   71 +++++++++++++++++++++++++++++++----------------
 1 files changed, 47 insertions(+), 24 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index c5b0451..173e531 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -569,6 +569,27 @@ static struct sock *udp_v6_mcast_next(struct net *net, struct sock *sk,
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
@@ -577,41 +598,43 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
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
+	if (count) {
+		flush_stack(stack, count, skb, count - 1);
+
+		for (i = 0; i < count; i++)
+			sock_put(stack[i]);
+	} else {
+		kfree_skb(skb);
+	}
 	return 0;
 }
 
