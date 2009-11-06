From: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
Subject: Re: [PATCH net-next-2.6] udp: Optimise multicast reception
Date: Fri, 6 Nov 2009 18:35:24 +0200
Message-ID: <200911061835.24928.lgrijincu@ixiacom.com>
References: <200911052033.21964.lgrijincu@ixiacom.com> <4AF43C5E.4060300@gmail.com> <4AF447F7.6000700@gmail.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_MBF9Kw6xohBpDIL"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	opurdila@ixiacom.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:19827 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758787AbZKFQfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 11:35:21 -0500
In-Reply-To: <4AF447F7.6000700@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_MBF9Kw6xohBpDIL
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

=C3=8En data de Vin 06 Noi 2009 17:59:51 a=C8=9Bi scris:
> +static void flush_stack(struct sock **stack, unsigned int count,
> +                       struct sk_buff *skb, unsigned int final)
> +{
> +       unsigned int i;
> +       struct sk_buff *skb1 =3D NULL;
> +
> +       for (i =3D 0; i < count; i++) {
> +             if (likely(skb1 =3D=3D NULL))
> +                    skb1 =3D (i =3D=3D final) ? skb : skb_clone(skb, GFP=
_ATOMIC);
> +
> +               if (skb1 && udp_queue_rcv_skb(stack[i], skb1) <=3D 0)
> +                       skb1 =3D NULL;
> +       }
> +       if (skb1)
> +               consume_skb(skb1);
> +}

consume_skb() assumes the skb was successfuly transmitted.

free_skb() does the same thing, but assumes that the frame is being dropped=
=20
after a failure and notes that.

In your code, if (count =3D=3D 0) you:
* fail to remove the original skb (memory leak),=20
* simply consume the last dropped skb, without noting the droping failure.

I fixed these in the attached (untested) patch.

One last issue: you silently ignore dropped failures (skb1 is reused in cas=
e=20
of a failure).

If this tracing must record all failures, I'd add an
	trace_kfree_skb(skb1, __builtin_return_address(0));
if udp_queue_rcv_skb() fails.

Other than this, nicely done!
=2D-=20
Lucian

--Boundary-00=_MBF9Kw6xohBpDIL
Content-Type: text/plain;
  charset="iso-8859-1";
  name="udp-optimise-multicast-reception.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="udp-optimise-multicast-reception.patch"

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index d5e75e9..a2c1a27 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1190,6 +1190,29 @@ drop:
 	return -1;
 }
 
+
+static void flush_stack(struct sock **stack, unsigned int count,
+			struct sk_buff *skb, unsigned int final)
+{
+	unsigned int i;
+	struct sk_buff *skb1 = NULL;
+
+	if ((count == 0) && skb) {
+		consume_skb(skb);
+		return;
+	}
+
+	for (i = 0; i < count; i++) {
+		if (likely(skb1 == NULL))
+			skb1 = (i == final) ? skb : skb_clone(skb, GFP_ATOMIC);
+
+		if (skb1 && udp_queue_rcv_skb(stack[i], skb1) <= 0)
+			skb1 = NULL;
+	}
+	if (skb1)
+		free_skb(skb1);
+}
+
 /*
  *	Multicasts and broadcasts go to each listener.
  *
@@ -1201,38 +1224,42 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
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
+
+	}
+	/*
+	 * before releasing the lock, we must take reference on sockets
+	 */
+	for (i = 0; i < count; i++)
+		sock_hold(stack[i]);
+
 	spin_unlock(&hslot->lock);
+
+	/*
+	 * do the slow work with no lock held
+	 */
+	flush_stack(stack, count, skb, count - 1);
+
+	for (i = 0; i < count; i++)
+		sock_put(stack[i]);
 	return 0;
 }
 

--Boundary-00=_MBF9Kw6xohBpDIL--
