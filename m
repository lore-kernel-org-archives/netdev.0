From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Ipv6: Delete rcu_read_lock
Date: Thu, 29 Sep 2011 10:44:19 +0200
Message-ID: <1317285859.2855.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1317282414-13368-1-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: rongqing.li@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:65287 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754872Ab1I2IoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2011 04:44:08 -0400
Received: by bkbzt4 with SMTP id zt4so396814bkb.19
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2011 01:44:07 -0700 (PDT)
In-Reply-To: <1317282414-13368-1-git-send-email-rongqing.li@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 29 septembre 2011 =C3=A0 15:46 +0800, rongqing.li@windriver.co=
m a
=C3=A9crit :
> From: Roy.Li <rongqing.li@windriver.com>
>=20
> Delete rcu_read_lock, it is redundant.
>=20

A good changelog and patch title are required.

Something like :

[PATCH net-next] ipv6: remove a rcu_read_lock in ndisc_constructor

in6_dev_get(dev) takes a reference on struct inet6_dev, we dont need rc=
u
locking in ndisc_constructor()



-----

Or, you could try to really use RCU and not take a reference (ie, use=20
__in6_dev_get() instead of in6_dev_get(dev).


Untested patch :

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 9da6e02..a4f4472 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -371,7 +371,7 @@ static int ndisc_constructor(struct neighbour *neig=
h)
 	int is_multicast =3D ipv6_addr_is_multicast(addr);
=20
 	rcu_read_lock();
-	in6_dev =3D in6_dev_get(dev);
+	in6_dev =3D __in6_dev_get(dev);
 	if (in6_dev =3D=3D NULL) {
 		rcu_read_unlock();
 		return -EINVAL;
@@ -380,7 +380,6 @@ static int ndisc_constructor(struct neighbour *neig=
h)
 	parms =3D in6_dev->nd_parms;
 	__neigh_parms_put(neigh->parms);
 	neigh->parms =3D neigh_parms_clone(parms);
-	rcu_read_unlock();
=20
 	neigh->type =3D is_multicast ? RTN_MULTICAST : RTN_UNICAST;
 	if (!dev->header_ops) {
@@ -409,7 +408,7 @@ static int ndisc_constructor(struct neighbour *neig=
h)
 		else
 			neigh->output =3D neigh->ops->output;
 	}
-	in6_dev_put(in6_dev);
+	rcu_read_unlock();
 	return 0;
 }
=20
