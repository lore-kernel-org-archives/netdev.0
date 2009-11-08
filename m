From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 6/8] ipv4: udp: Optimise multicast reception
Date: Sun, 08 Nov 2009 21:18:44 +0100
Message-ID: <4AF727A4.9000704@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	Octavian Purdila <opurdila@ixiacom.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:46203 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755193AbZKHUSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2009 15:18:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

UDP multicast rx path is a bit complex and can hold a spinlock
for a long time.

Using a small (32 or 64 entries) stack of socket pointers can help
to perform expensive operations (skb_clone(), udp_queue_rcv_skb())
outside of the lock, in most cases.

It's also a base for a future RCU conversion of multicast recption.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
---
 net/ipv4/udp.c |   76 ++++++++++++++++++++++++++++++-----------------
 1 files changed, 50 insertions(+), 26 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index dd7f3d2..9d9072c 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1329,49 +1329,73 @@ drop:
 	return -1;
 }
 
+
+static void flush_stack(struct sock **stack, unsigned int count,
+			struct sk_buff *skb, unsigned int final)
+{
+	unsigned int i;
+	struct sk_buff *skb1 = NULL;
+
+	for (i = 0; i < count; i++) {
+		if (likely(skb1 == NULL))
+			skb1 = (i == final) ? skb : skb_clone(skb, GFP_ATOMIC);
+
+		if (skb1 && udp_queue_rcv_skb(stack[i], skb1) <= 0)
+			skb1 = NULL;
+	}
+	if (unlikely(skb1))
+		kfree_skb(skb1);
+}
+
 /*
  *	Multicasts and broadcasts go to each listener.
  *
- *	Note: called only from the BH handler context,
- *	so we don't need to lock the hashes.
+ *	Note: called only from the BH handler context.
  */
 static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 				    struct udphdr  *uh,
 				    __be32 saddr, __be32 daddr,
 				    struct udp_table *udptable)
 {
-	struct sock *sk;
+	struct sock *sk, *stack[256 / sizeof(struct sock *)];
 	struct udp_hslot *hslot = udp_hashslot(udptable, net, ntohs(uh->dest));
 	int dif;
+	unsigned int i, count = 0;
 
 	spin_lock(&hslot->lock);
 	sk = sk_nulls_head(&hslot->head);
 	dif = skb->dev->ifindex;
 	sk = udp_v4_mcast_next(net, sk, uh->dest, daddr, uh->source, saddr, dif);
-	if (sk) {
-		struct sock *sknext = NULL;
-
-		do {
-			struct sk_buff *skb1 = skb;
-
-			sknext = udp_v4_mcast_next(net, sk_nulls_next(sk), uh->dest,
-						   daddr, uh->source, saddr,
-						   dif);
-			if (sknext)
-				skb1 = skb_clone(skb, GFP_ATOMIC);
-
-			if (skb1) {
-				int ret = udp_queue_rcv_skb(sk, skb1);
-				if (ret > 0)
-					/* we should probably re-process instead
-					 * of dropping packets here. */
-					kfree_skb(skb1);
-			}
-			sk = sknext;
-		} while (sknext);
-	} else
-		consume_skb(skb);
+	while (sk) {
+		stack[count++] = sk;
+		sk = udp_v4_mcast_next(net, sk_nulls_next(sk), uh->dest,
+				       daddr, uh->source, saddr, dif);
+		if (unlikely(count == ARRAY_SIZE(stack))) {
+			if (!sk)
+				break;
+			flush_stack(stack, count, skb, ~0);
+			count = 0;
+		}
+	}
+	/*
+	 * before releasing chain lock, we must take a reference on sockets
+	 */
+	for (i = 0; i < count; i++)
+		sock_hold(stack[i]);
+
 	spin_unlock(&hslot->lock);
+
+	/*
+	 * do the slow work with no lock held
+	 */
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
 
