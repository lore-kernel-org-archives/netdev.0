From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: pppol2tp over pppoe NULL pointer dereference
Date: Sat, 05 Nov 2011 08:40:29 +0100
Message-ID: <1320478829.16609.15.camel@edumazet-laptop>
References: <CAKpUy7Z5KOfHbKfBp-qg+77cED=OxUAkm2P4pQacHaHKmKBQpw@mail.gmail.com>
	 <1320191893.4728.13.camel@edumazet-laptop>
	 <20111104.222851.1376278499619626232.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: spiked.yar@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34766 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810Ab1KEHkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Nov 2011 03:40:39 -0400
Received: by wyh15 with SMTP id 15so2980551wyh.19
        for <netdev@vger.kernel.org>; Sat, 05 Nov 2011 00:40:38 -0700 (PDT)
In-Reply-To: <20111104.222851.1376278499619626232.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 04 novembre 2011 =C3=A0 22:28 -0400, David Miller a =C3=A9c=
rit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 02 Nov 2011 00:58:13 +0100
>=20
> > Please try following patch, thanks !
> >=20
> > [PATCH] l2tp: handle fragmented skbs in receive path
> >=20
> > Modern drivers provide skb with fragments, and L2TP doesnt properly
> > handles them.
> >=20
> > Some bad frames can also trigger panics because of insufficent chec=
ks.
> >=20
> > Reported-by: Misha Labjuk <spiked.yar@gmail.com>
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> I'm still waiting for testing results of this patch.

Of course.

If you prefer, I can submit a smaller patch for the obvious bug first,
and I can respin the thing when net-next reopens.

[PATCH] l2tp: fix l2tp_udp_recv_core()

pskb_may_pull() can change skb->data, so we have to load ptr/optr at th=
e
right place.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/l2tp/l2tp_core.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index bf8d50c..cf0f308 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -756,9 +756,6 @@ static int l2tp_udp_recv_core(struct l2tp_tunnel *t=
unnel, struct sk_buff *skb,
 		goto error;
 	}
=20
-	/* Point to L2TP header */
-	optr =3D ptr =3D skb->data;
-
 	/* Trace packet contents, if enabled */
 	if (tunnel->debug & L2TP_MSG_DATA) {
 		length =3D min(32u, skb->len);
@@ -769,12 +766,15 @@ static int l2tp_udp_recv_core(struct l2tp_tunnel =
*tunnel, struct sk_buff *skb,
=20
 		offset =3D 0;
 		do {
-			printk(" %02X", ptr[offset]);
+			printk(" %02X", skb->data[offset]);
 		} while (++offset < length);
=20
 		printk("\n");
 	}
=20
+	/* Point to L2TP header */
+	optr =3D ptr =3D skb->data;
+
 	/* Get L2TP header flags */
 	hdrflags =3D ntohs(*(__be16 *) ptr);
=20
