From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NULL pointer dereference panic in stable (2.6.33.2), amd64
Date: Mon, 12 Apr 2010 09:18:17 +0200
Message-ID: <1271056697.16881.7.camel@edumazet-laptop>
References: <201004112338.47019.nuclearcat@nuclearcat.com>
	 <1271025353.2078.155.camel@edumazet-laptop>
	 <OF19A2A36F.5B268C61-ON65257703.0012EB6A-65257703.0013F81C@in.ibm.com>
	 <1271052111.2078.168.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Denys Fedorysychenko <nuclearcat@nuclearcat.com>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:39023 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009Ab0DLHSW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 03:18:22 -0400
Received: by bwz19 with SMTP id 19so204186bwz.21
        for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 00:18:20 -0700 (PDT)
In-Reply-To: <1271052111.2078.168.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 12 avril 2010 =C3=A0 08:01 +0200, Eric Dumazet a =C3=A9crit :

> Problem is when you reset sk->sk_tx_queue_mapping at the very moment
> route (or destination) changes, we might have old packets queued in t=
x
> queues, of the old ethernet device (eth0 : multi queue compatable)
>=20
> 2) Application does a sendmsg() or connect() call and sk->sk_dst_cach=
e
> is rebuild, it points to a dst_entry referring a new device (eth1 : n=
on
> multiqueue)
>=20
> 3) When one old packet finally is transmitted, we do :
>=20
> 	queue_index =3D 1; // any value > 0
>=20
> 	if (sk && sk->sk_dst_cache)
> 		sk_tx_queue_set(sk, queue_index); // remember a >0 value
>=20
> 4) application does a sendmsg(), enqueues a new skb on eth1
>=20
> 5) We re-enter dev_pick_tx(), and consider cached value in 3) is vali=
d.
>    we pick a non existent txq for eth1 device.
>=20
> 6) We crash.
>=20
>=20
> > The following might be better to prove the panic is due to this, si=
nce
> > your suggestion will hide a panic that happens somewhat rare (accor=
ding
> > to Denys):
> >=20
> >       if (sk_tx_queue_recorded(sk)) {
> >             queue_index =3D sk_tx_queue_get(sk);
> > +           queue_index =3D dev_cap_txqueue(dev, queue_index);
> >       } else {
> >=20
>=20
> Sure, but I thought I was clear enough to prove this commit was wrong=
,
> and we have to find a fix.

Here the patch I cooked, this is a stable candidate, once tested and
acknowledged.

[PATCH] net: dev_pick_tx() fix

When dev_pick_tx() caches tx queue_index on a socket, we must check
socket dst_entry matches skb one, or risk a crash later, as reported by
Denys Fedorysychenko, if old packets are in flight during a route
change, involving devices with different number of queues.

Bug introduced by commit a4ee3ce3
(net: Use sk_tx_queue_mapping for connected sockets)

Reported-by: Denys Fedorysychenko <nuclearcat@nuclearcat.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/core/dev.c b/net/core/dev.c
index 1c8a0ce..92584bf 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1989,8 +1989,12 @@ static struct netdev_queue *dev_pick_tx(struct n=
et_device *dev,
 			if (dev->real_num_tx_queues > 1)
 				queue_index =3D skb_tx_hash(dev, skb);
=20
-			if (sk && sk->sk_dst_cache)
-				sk_tx_queue_set(sk, queue_index);
+			if (sk) {
+				struct dst_entry *dst =3D rcu_dereference(sk->sk_dst_cache);
+
+				if (dst && skb_dst(skb) =3D=3D dst)
+					sk_tx_queue_set(sk, queue_index);
+			}
 		}
 	}
=20


