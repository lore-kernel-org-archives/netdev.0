From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] udp: Optimise multicast reception
Date: Fri, 06 Nov 2009 17:54:15 +0100
Message-ID: <4AF454B7.6050103@gmail.com>
References: <200911052033.21964.lgrijincu@ixiacom.com> <4AF43C5E.4060300@gmail.com> <4AF447F7.6000700@gmail.com> <200911061835.24928.lgrijincu@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	opurdila@ixiacom.com
To: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:41585 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758257AbZKFQyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 11:54:15 -0500
In-Reply-To: <200911061835.24928.lgrijincu@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lucian Adrian Grijincu a =C3=A9crit :
> =C3=8En data de Vin 06 Noi 2009 17:59:51 a=C8=9Bi scris:
>> +static void flush_stack(struct sock **stack, unsigned int count,
>> +                       struct sk_buff *skb, unsigned int final)
>> +{
>> +       unsigned int i;
>> +       struct sk_buff *skb1 =3D NULL;
>> +
>> +       for (i =3D 0; i < count; i++) {
>> +             if (likely(skb1 =3D=3D NULL))
>> +                    skb1 =3D (i =3D=3D final) ? skb : skb_clone(skb=
, GFP_ATOMIC);
>> +
>> +               if (skb1 && udp_queue_rcv_skb(stack[i], skb1) <=3D 0=
)
>> +                       skb1 =3D NULL;
>> +       }
>> +       if (skb1)
>> +               consume_skb(skb1);
>> +}
>=20
> consume_skb() assumes the skb was successfuly transmitted.
>=20
> free_skb() does the same thing, but assumes that the frame is being d=
ropped=20
> after a failure and notes that.
>=20
> In your code, if (count =3D=3D 0) you:
> * fail to remove the original skb (memory leak),=20
> * simply consume the last dropped skb, without noting the droping fai=
lure.
>=20
> I fixed these in the attached (untested) patch.
>=20
> One last issue: you silently ignore dropped failures (skb1 is reused =
in case=20
> of a failure).
>=20
> If this tracing must record all failures, I'd add an
> 	trace_kfree_skb(skb1, __builtin_return_address(0));
> if udp_queue_rcv_skb() fails.
>=20
> Other than this, nicely done!
>=20

Thanks !

Note, free_skb() doesnt exist ;)
And we should not call consume_skb() in this path.

I made the if (count =3D=3D 0) done at the end of __udp4_lib_mcast_deli=
ver()



[PATCH net-next-2.6] udp: Optimise multicast reception

UDP multicast rx path is a bit complex and can hold a spinlock
for a long time.

Using a small (32 or 64 entries) stack of socket pointers can help
to perform expensive operations (skb_clone(), udp_queue_rcv_skb())
outside of the lock, in most cases.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
---
 net/ipv4/udp.c |   76 ++++++++++++++++++++++++++++++-----------------
 1 files changed, 50 insertions(+), 26 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index d5e75e9..45c73b1 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1190,49 +1190,73 @@ drop:
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
 static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *s=
kb,
 				    struct udphdr  *uh,
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
+	}
+	/*
+	 * before releasing chain lock, we must take a reference on sockets
+	 */
+	for (i =3D 0; i < count; i++)
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
+		for (i =3D 0; i < count; i++)
+			sock_put(stack[i]);
+	} else {
+		kfree_skb(skb);
+	}
 	return 0;
 }
=20
