From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-2.6] bonding: fix a race in  IGMP handling
Date: Thu, 18 Nov 2010 11:26:18 +0100
Message-ID: <1290075978.2781.36.camel@edumazet-laptop>
References: <20101118091846.26534.38865.sendpatchset@localhost.localdomain>
	 <1290072794.2781.10.camel@edumazet-laptop>
	 <1290073388.2781.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-s390@vger.kernel.org, linux-next@vger.kernel.org,
	ursula.braun@de.ibm.com, Jay Vosburgh <fubar@us.ibm.com>
To: Sachin Sant <sachinp@in.ibm.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:55119 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753790Ab0KRK0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 05:26:23 -0500
In-Reply-To: <1290073388.2781.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 18 novembre 2010 =C3=A0 10:43 +0100, Eric Dumazet a =C3=A9crit=
 :
> Le jeudi 18 novembre 2010 =C3=A0 10:33 +0100, Eric Dumazet a =C3=A9cr=
it :
> >=20
> >=20
> >=20
> > Hmm, sorry but this wont work.
> >=20
> > > diff -Narup linux-2.6-next/drivers/s390/net/lcs.c linux-2.6-next-=
new/drivers/s390/net/lcs.c
> > > --- linux-2.6-next/drivers/s390/net/lcs.c	2010-11-17 11:38:25.000=
000000 +0530
> > > +++ linux-2.6-next-new/drivers/s390/net/lcs.c	2010-11-18 11:59:46=
=2E000000000 +0530
> > > @@ -1269,10 +1269,10 @@ lcs_register_mc_addresses(void *data)
> > >  	in4_dev =3D in_dev_get(card->dev);
> > >  	if (in4_dev =3D=3D NULL)
> > >  		goto out;
> > > -	read_lock(&in4_dev->mc_list_lock);
> > > +	rcu_read_lock();
> >=20
> > If you use rcu_read_lock(), then you also need to=20
> > use the rcu list iterators in lcs_remove_mc_addresses() and
> > lcs_set_mc_addresses()
> >=20
> > Then, its strange this driver is not protected by RTNL at this stag=
e.
> >=20
> > Ah yes, it uses a kthread from its ndo_set_multicast_list() handler=
=2E
> >=20
> > This seems not safe at all.

Actually this raises an interesting case for bonding as well.

Before my RCU conversion __bond_resend_igmp_join_requests() was unsafe.

=46or net-next-2.6, it is now safe (RCU is held), but needs a cleanup
patch to avoid sparse errors.

Thanks

[PATCH net-2.6] bonding: fix a race in IGMP handling

RCU conversion in IGMP code done in net-next-2.6 raised a race in
__bond_resend_igmp_join_requests().

It iterates in_dev->mc_list without appropriate protection (RTNL, or
read_lock on in_dev->mc_list_lock).

Another cpu might delete an entry while we use it and trigger a fault.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index bdb68a6..71a1697 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -878,8 +878,10 @@ static void __bond_resend_igmp_join_requests(struc=
t net_device *dev)
 	rcu_read_lock();
 	in_dev =3D __in_dev_get_rcu(dev);
 	if (in_dev) {
+		read_lock(&in_dev->mc_list_lock);
 		for (im =3D in_dev->mc_list; im; im =3D im->next)
 			ip_mc_rejoin_group(im);
+		read_unlock(&in_dev->mc_list_lock);
 	}
=20
 	rcu_read_unlock();


