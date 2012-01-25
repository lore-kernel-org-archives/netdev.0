From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BISECTED] Linux 3.2: Networking out of LAN does not work
Date: Wed, 25 Jan 2012 12:05:31 +0100
Message-ID: <1327489531.2425.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <OF0BD4E9BA.3C3D7E41-ONC1257990.0034993D-C1257990.0034B2CE@bdpnet.dk>
	 <1327484459.2425.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Mihai Maruseac <mihai.maruseac@gmail.com>
To: Rune Magnussen <rum@bankdata.dk>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:43258 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752261Ab2AYLFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2012 06:05:37 -0500
Received: by bkas6 with SMTP id s6so4269138bka.19
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2012 03:05:35 -0800 (PST)
In-Reply-To: <1327484459.2425.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 25 janvier 2012 =C3=A0 10:40 +0100, Eric Dumazet a =C3=A9cr=
it :
> Le mercredi 25 janvier 2012 =C3=A0 10:35 +0100, Rune Magnussen a =C3=A9=
crit :
> > Hi
> >=20
> > Networking to and from the outside of my LAN does not work with Lin=
ux=20
> > 3.2.x.
> > Linux 3.1.x works. Using ssh from a PC on the LAN also works.
> > The machine has a VIA C7 CPU and the NIC uses the 8139too-driver.
> >=20
> > Another machine with a r8169-NIC and an Atom-CPU (32bit) did not=20
> > show any problems.
> > It was used very ligtly though.
> >=20
> > Bisection led to this:
> > ---
> > f04565ddf52e401880f8ba51de0dff8ba51c99fd is the first bad commit
> > commit f04565ddf52e401880f8ba51de0dff8ba51c99fd
> > Author: Mihai Maruseac <mihai.maruseac@gmail.com>
> > Date:   Thu Oct 20 20:45:10 2011 +0000
> >=20
> >     dev: use name hash for dev_seq_ops
> > =20
> >     Instead of using the dev->next chain and trying to resync at ea=
ch call=20
> > to
> >     dev_seq_start, use the name hash, keeping the bucket and the of=
fset in
> >     seq->private field.
> > =20
> >     Tests revealed the following results for ifconfig > /dev/null
> >        * 1000 interfaces:
> >           * 0.114s without patch
> >           * 0.089s with patch
> >        * 3000 interfaces:
> >           * 0.489s without patch
> >           * 0.110s with patch
> >        * 5000 interfaces:
> >           * 1.363s without patch
> >           * 0.250s with patch
> >        * 128000 interfaces (other setup):
> >           * ~100s without patch
> >           * ~30s with patch
> > =20
> >     Signed-off-by: Mihai Maruseac <mmaruseac@ixiacom.com>
> >     Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> >     Signed-off-by: David S. Miller <davem@davemloft.net>
> >=20
> > :040000 040000 2e86e1c9ecaf719d312a8b5863ec9e89d92bc4b3=20
> > 8b0d09ca105502dd5389bb6281ef059c8bb38667 M   net
> > ---
> >=20
> > Simply reverting the commit on top of Linux 3.2.1 resultet in a bui=
ld=20
> > error.
> >=20
> > Used kernel configuration: http://knus.info/kernel/config-3.1.txt
> >=20
> > Greetings Rune

OK please test the following patch.

[PATCH] net: use index hash for /proc/net/dev

Commit f04565ddf52e (dev: use name hash for dev_seq_ops) added a
regression for legacy apps expecting to find devices in a particular
order.

Instead of using name hash, we can use dev_index_head hash, based on
device index, to not change device ordering.

Name hash order is not particularly useful, while index ordering is
meaningful on machines where no more than 256 devices are ever created.

"cat /proc/net/dev" and "ip link" will output devices in same order.

Reported-by: Rune Magnussen <rum@bankdata.dk>
Bisected-by: Rune Magnussen <rum@bankdata.dk>
Cc: Mihai Maruseac <mihai.maruseac@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/dev.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 115dee1..c58dba3 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4052,9 +4052,9 @@ static inline struct net_device *dev_from_same_bu=
cket(struct seq_file *seq)
=20
 	bucket =3D get_bucket(state->pos);
 	offset =3D get_offset(state->pos);
-	h =3D &net->dev_name_head[bucket];
+	h =3D dev_index_hash(net, bucket);
 	count =3D 0;
-	hlist_for_each_entry_rcu(dev, p, h, name_hlist) {
+	hlist_for_each_entry_rcu(dev, p, h, index_hlist) {
 		if (count++ =3D=3D offset) {
 			state->pos =3D set_bucket_offset(bucket, count);
 			return dev;
