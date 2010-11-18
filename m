From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch -next] Adapt s390 qeth & lcs driver code to use RCU
Date: Thu, 18 Nov 2010 10:43:08 +0100
Message-ID: <1290073388.2781.12.camel@edumazet-laptop>
References: <20101118091846.26534.38865.sendpatchset@localhost.localdomain>
	 <1290072794.2781.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-s390@vger.kernel.org, linux-next@vger.kernel.org,
	ursula.braun@de.ibm.com
To: Sachin Sant <sachinp@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:50301 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756126Ab0KRJnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 04:43:13 -0500
In-Reply-To: <1290072794.2781.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 18 novembre 2010 =C3=A0 10:33 +0100, Eric Dumazet a =C3=A9crit=
 :
> Le jeudi 18 novembre 2010 =C3=A0 14:48 +0530, Sachin Sant a =C3=A9cri=
t :
> > Commit 1d7138de878d1d4210727c1200193e69596f93b3
> > igmp: RCU conversion of in_dev->mc_list
> >=20
> > converted rwlock to RCU.
> >=20
> > Update the s390 network drivers(qeth & lcs) code to adapt to this c=
hange.
> >=20
> > Signed-off-by : Sachin Sant <sachinp@in.ibm.com>
> > ---
> >=20
> > Only compile tested.
> >=20
>=20
> Hmm, sorry but this wont work.
>=20
> > diff -Narup linux-2.6-next/drivers/s390/net/lcs.c linux-2.6-next-ne=
w/drivers/s390/net/lcs.c
> > --- linux-2.6-next/drivers/s390/net/lcs.c	2010-11-17 11:38:25.00000=
0000 +0530
> > +++ linux-2.6-next-new/drivers/s390/net/lcs.c	2010-11-18 11:59:46.0=
00000000 +0530
> > @@ -1269,10 +1269,10 @@ lcs_register_mc_addresses(void *data)
> >  	in4_dev =3D in_dev_get(card->dev);
> >  	if (in4_dev =3D=3D NULL)
> >  		goto out;
> > -	read_lock(&in4_dev->mc_list_lock);
> > +	rcu_read_lock();
>=20
> If you use rcu_read_lock(), then you also need to=20
> use the rcu list iterators in lcs_remove_mc_addresses() and
> lcs_set_mc_addresses()
>=20
> Then, its strange this driver is not protected by RTNL at this stage.
>=20
> Ah yes, it uses a kthread from its ndo_set_multicast_list() handler.
>=20
> This seems not safe at all.

Please check following patch to give you the idea of what is needed :


diff --git a/drivers/s390/net/lcs.c b/drivers/s390/net/lcs.c
index 0f19d54..05755b7 100644
--- a/drivers/s390/net/lcs.c
+++ b/drivers/s390/net/lcs.c
@@ -1188,7 +1188,9 @@ lcs_remove_mc_addresses(struct lcs_card *card, st=
ruct in_device *in4_dev)
 	spin_lock_irqsave(&card->ipm_lock, flags);
 	list_for_each(l, &card->ipm_list) {
 		ipm =3D list_entry(l, struct lcs_ipm_list, list);
-		for (im4 =3D in4_dev->mc_list; im4 !=3D NULL; im4 =3D im4->next) {
+		for (im4 =3D rcu_dereference(in4_dev->mc_list);
+		     im4 !=3D NULL;
+		     im4 =3D rcu_dereference(im4->next_rcu)) {
 			lcs_get_mac_for_ipm(im4->multiaddr, buf, card->dev);
 			if ( (ipm->ipm.ip_addr =3D=3D im4->multiaddr) &&
 			     (memcmp(buf, &ipm->ipm.mac_addr,
@@ -1233,7 +1235,9 @@ lcs_set_mc_addresses(struct lcs_card *card, struc=
t in_device *in4_dev)
 	unsigned long flags;
=20
 	LCS_DBF_TEXT(4, trace, "setmclst");
-	for (im4 =3D in4_dev->mc_list; im4; im4 =3D im4->next) {
+	for (im4 =3D rcu_dereference(in4_dev->mc_list);
+	     im4 !=3D NULL;
+	     im4 =3D rcu_dereference(im4->next_rcu)) {
 		lcs_get_mac_for_ipm(im4->multiaddr, buf, card->dev);
 		ipm =3D lcs_check_addr_entry(card, im4, buf);
 		if (ipm !=3D NULL)
@@ -1269,10 +1273,10 @@ lcs_register_mc_addresses(void *data)
 	in4_dev =3D in_dev_get(card->dev);
 	if (in4_dev =3D=3D NULL)
 		goto out;
-	read_lock(&in4_dev->mc_list_lock);
+	rcu_read_lock();
 	lcs_remove_mc_addresses(card,in4_dev);
 	lcs_set_mc_addresses(card, in4_dev);
-	read_unlock(&in4_dev->mc_list_lock);
+	rcu_read_unlock();
 	in_dev_put(in4_dev);
=20
 	netif_carrier_off(card->dev);


