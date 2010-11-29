From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: inet_hash_connect: source port allocation
Date: Mon, 29 Nov 2010 20:07:35 +0100
Message-ID: <1291057655.3435.1363.camel@edumazet-laptop>
References: <4CF3DD02.90906@oracle.com>
	 <1291051560.3435.1198.camel@edumazet-laptop>  <4CF3F114.2070108@oracle.com>
	 <1291056363.3435.1338.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: John Haxby <john.haxby@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:33272 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742Ab0K2THk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 14:07:40 -0500
Received: by ewy5 with SMTP id 5so2209266ewy.19
        for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 11:07:39 -0800 (PST)
In-Reply-To: <1291056363.3435.1338.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 29 novembre 2010 =C3=A0 19:46 +0100, Eric Dumazet a =C3=A9crit=
 :
> Le lundi 29 novembre 2010 =C3=A0 18:29 +0000, John Haxby a =C3=A9crit=
 :
>=20
> > Sorry,  I think I phrased my question badly.
> >=20
> > inet_csk_get_port() starts its search for a free port with
> >=20
> >      smallest_rover =3D rover =3D net_random() % remaining + low;
> >=20
> > whereas __inet_hash_connect() basically misses out that call to=20
> > net_random() so you get a predictable port number.
> >=20
> > Is there any good reason why that is the case?
> >=20
>=20
> It seems random select was done at bind() time only in commit
> 6df716340da3a6f ([TCP/DCCP]: Randomize port selection)
>=20
> It probably should be done in autobind too.
>=20
>=20

I'll test following patch :

diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 1b344f3..65c3702 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -466,20 +466,18 @@ int __inet_hash_connect(struct inet_timewait_deat=
h_row *death_row,
 	int twrefcnt =3D 1;
=20
 	if (!snum) {
-		int i, remaining, low, high, port;
-		static u32 hint;
-		u32 offset =3D hint + port_offset;
+		int remaining, low, high, port;
 		struct hlist_node *node;
 		struct inet_timewait_sock *tw =3D NULL;
=20
 		inet_get_local_port_range(&low, &high);
 		remaining =3D (high - low) + 1;
+		port =3D net_random() % remaining + low;
=20
 		local_bh_disable();
-		for (i =3D 1; i <=3D remaining; i++) {
-			port =3D low + (i + offset) % remaining;
+		do {
 			if (inet_is_reserved_local_port(port))
-				continue;
+				goto next_nolock;
 			head =3D &hinfo->bhash[inet_bhashfn(net, port,
 					hinfo->bhash_size)];
 			spin_lock(&head->lock);
@@ -510,16 +508,17 @@ int __inet_hash_connect(struct inet_timewait_deat=
h_row *death_row,
 			tb->fastreuse =3D -1;
 			goto ok;
=20
-		next_port:
+next_port:
 			spin_unlock(&head->lock);
-		}
+next_nolock:
+			if (++port > high)
+				port =3D low;
+		} while (--remaining > 0);
 		local_bh_enable();
=20
 		return -EADDRNOTAVAIL;
=20
 ok:
-		hint +=3D i;
-
 		/* Head lock still held and bh's disabled */
 		inet_bind_hash(sk, tb, port);
 		if (sk_unhashed(sk)) {


