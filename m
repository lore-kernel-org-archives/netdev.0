From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] udp: Optimise multicast reception
Date: Fri, 06 Nov 2009 16:59:51 +0100
Message-ID: <4AF447F7.6000700@gmail.com>
References: <200911052033.21964.lgrijincu@ixiacom.com> <20091106.004215.114490979.davem@davemloft.net> <200911061604.21465.lgrijincu@ixiacom.com> <4AF43C5E.4060300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, opurdila@ixiacom.com
To: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:51753 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759364AbZKFP7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 10:59:51 -0500
In-Reply-To: <4AF43C5E.4060300@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :

> Yes, but this single skb freeing is in multicast very slow path
> (it happens if we receive a multicast packet with no listener, which =
should
>  not happen with multicast aware network...)
>=20
>=20
> If you really want to optimize this part, we could use an array of
> 32 (or 64) socket pointers, to be able to perform the really expensiv=
e
> work (skb_clone(), udp_queue_rcv_skb()) outside of the lock.
>=20
> Something like this untested patch :

I did some tests and made one fix.

With this kind of stacking, we eventually could try a rcu lookup as wel=
l.



[PATCH net-next-2.6] udp: Optimise multicast reception

UDP multicast rx path is a bit complex and can hold a spinlock
for a long time.

Using a small (32 or 64 entries) stack of socket pointers can help
to perform expensive operations (skb_clone(), udp_queue_rcv_skb())
outside of the lock, in most cases.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/udp.c |   70 ++++++++++++++++++++++++++++++-----------------
 1 files changed, 46 insertions(+), 24 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index d5e75e9..89637d0 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1190,6 +1190,24 @@ drop:
 	return -1;
 }
=20
+
+static void flush_stack(struct sock **stack, unsigned int count,
+			struct sk_buff *skb, unsigned int final)
+{
+	unsigned int i;
+	struct sk_buff *skb1 =3D NULL;
+
+	for (i =3D 0; i < count; i++) {
+		if (likely(skb1 =3D=3D NULL))
+			skb1 =3D (i =3D=3D final) ? skb : skb_clone(skb, GFP_ATOMIC);
+
+		if (skb1 && udp_queue_rcv_skb(stack[i], skb1) <=3D 0)
+			skb1 =3D NULL;
+	}
+	if (skb1)
+		consume_skb(skb1);
+}
+
 /*
  *	Multicasts and broadcasts go to each listener.
  *
@@ -1201,38 +1219,42 @@ static int __udp4_lib_mcast_deliver(struct net =
*net, struct sk_buff *skb,
 				    __be32 saddr, __be32 daddr,
 				    struct udp_table *udptable)
 {
-	struct sock *sk;
+	struct sock *sk, *stack[256 / sizeof(struct sock *)];
 	struct udp_hslot *hslot =3D udp_hashslot(udptable, net, ntohs(uh->des=
t));
 	int dif;
+	unsigned int i, count =3D 0;
=20
 	spin_lock(&hslot->lock);
 	sk =3D sk_nulls_head(&hslot->head);
 	dif =3D skb->dev->ifindex;
 	sk =3D udp_v4_mcast_next(net, sk, uh->dest, daddr, uh->source, saddr,=
 dif);
-	if (sk) {
-		struct sock *sknext =3D NULL;
-
-		do {
-			struct sk_buff *skb1 =3D skb;
-
-			sknext =3D udp_v4_mcast_next(net, sk_nulls_next(sk), uh->dest,
-						   daddr, uh->source, saddr,
-						   dif);
-			if (sknext)
-				skb1 =3D skb_clone(skb, GFP_ATOMIC);
-
-			if (skb1) {
-				int ret =3D udp_queue_rcv_skb(sk, skb1);
-				if (ret > 0)
-					/* we should probably re-process instead
-					 * of dropping packets here. */
-					kfree_skb(skb1);
-			}
-			sk =3D sknext;
-		} while (sknext);
-	} else
-		consume_skb(skb);
+	while (sk) {
+		stack[count++] =3D sk;
+		sk =3D udp_v4_mcast_next(net, sk_nulls_next(sk), uh->dest,
+				       daddr, uh->source, saddr, dif);
+		if (unlikely(count =3D=3D ARRAY_SIZE(stack))) {
+			if (!sk)
+				break;
+			flush_stack(stack, count, skb, ~0);
+			count =3D 0;
+		}
+
+	}
+	/*
+	 * before releasing the lock, we must take reference on sockets
+	 */
+	for (i =3D 0; i < count; i++)
+		sock_hold(stack[i]);
+
 	spin_unlock(&hslot->lock);
+
+	/*
+	 * do the slow work with no lock held
+	 */
+	flush_stack(stack, count, skb, count - 1);
+
+	for (i =3D 0; i < count; i++)
+		sock_put(stack[i]);
 	return 0;
 }
=20
