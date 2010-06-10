From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: unable to handle kernel paging request at 000041ed00000001
Date: Thu, 10 Jun 2010 18:00:09 +0200
Message-ID: <1276185609.2448.12.camel@edumazet-laptop>
References: <9D7251E7-0EFD-4645-BC30-A96191D1046E@res.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Arturas <arturasl@res.lt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f223.google.com ([209.85.219.223]:57382 "EHLO
	mail-ew0-f223.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750989Ab0FJQAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jun 2010 12:00:14 -0400
Received: by ewy23 with SMTP id 23so51177ewy.1
        for <netdev@vger.kernel.org>; Thu, 10 Jun 2010 09:00:12 -0700 (PDT)
In-Reply-To: <9D7251E7-0EFD-4645-BC30-A96191D1046E@res.lt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 10 juin 2010 =C3=A0 16:45 +0300, Arturas a =C3=A9crit :
> Hello,
>=20
> I'm not sure if i'm writing to right mailling list, but i hope I am. =
I'm doing

>  bonding, bridging and traffic shaping on linux. With such setup i ha=
ve no

>  panics for a few days. But when I add ip address on br0, assign brid=
ge=20

> interface and ip address to different routing table and using iptable=
s n

> at REDIRECT I'm getting an oops (see attachment). An oops triggers on=
ly

>  after some traffic. Dmesg and .config also attached. I don't know is=
 it=20

> enough information for you, but if not, just say what I should do to =
get

>  more information and i'll try.  Older kernels have deadlocks for suc=
h setup=20

> except bridge routing, so I can't try older kernels (>=3D2.6.32). If =
someone is interested i can write call traces.
>=20
> Bonding is not multiqueue aware right now and someone promised to mak=
e it mq aware

>  (not just patch bonding with netdev_alloc_mq). Maybe someone knows w=
hat is a status? I can test patches.
>=20
> Performance tips for .config are very welcome.
>=20
> --
> Arturas
>=20
>=20
> =20

This is right mailing list :)

I would try following patch for 2.6.34,
not blindly trusting sk_tx_queue_get(sk)

--- net/core/dev.c.orig	2010-06-10 17:52:17.000000000 +0200
+++ net/core/dev.c	2010-06-10 17:54:56.000000000 +0200
@@ -1958,12 +1958,10 @@
 static inline u16 dev_cap_txqueue(struct net_device *dev, u16 queue_in=
dex)
 {
 	if (unlikely(queue_index >=3D dev->real_num_tx_queues)) {
-		if (net_ratelimit()) {
-			WARN(1, "%s selects TX queue %d, but "
-			     "real number of TX queues is %d\n",
-			     dev->name, queue_index,
-			     dev->real_num_tx_queues);
-		}
+		WARN_ONCE("%s selects TX queue %d, but "
+			  "real number of TX queues is %d\n",
+			  dev->name, queue_index,
+			  dev->real_num_tx_queues);
 		return 0;
 	}
 	return queue_index;
@@ -1977,6 +1975,7 @@
=20
 	if (sk_tx_queue_recorded(sk)) {
 		queue_index =3D sk_tx_queue_get(sk);
+		queue_index =3D dev_cap_txqueue(dev, queue_index);
 	} else {
 		const struct net_device_ops *ops =3D dev->netdev_ops;
=20


