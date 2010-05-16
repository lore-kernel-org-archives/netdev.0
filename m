From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bnx2/BCM5709: why 5 interrupts on a 4 core system (2.6.33.3)
Date: Sun, 16 May 2010 22:47:06 +0200
Message-ID: <1274042826.2299.26.camel@edumazet-laptop>
References: <C27F8246C663564A84BB7AB3439772421B7814753A@IRVEXCHCCR01.corp.ad.broadcom.com>
	 <1274040928.2299.17.camel@edumazet-laptop>  <4BF056F0.8010008@ans.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Krzysztof =?UTF-8?Q?Ol=C4=99dzki?= <ole@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33865 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752897Ab0EPUrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 16:47:10 -0400
Received: by wyb39 with SMTP id 39so10434wyb.19
        for <netdev@vger.kernel.org>; Sun, 16 May 2010 13:47:09 -0700 (PDT)
In-Reply-To: <4BF056F0.8010008@ans.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 16 mai 2010 =C3=A0 22:34 +0200, Krzysztof Ol=C4=99dzki a =C3=
=A9crit :
> On 2010-05-16 22:15, Eric Dumazet wrote:

> > All tx packets through bonding will use txqueue 0, since bnx2 doesn=
t
> > provide a ndo_select_queue() function.
>=20
> OK, that explains everything. Thank you Eric. I assume it may take so=
me=20
> time for bonding to become multiqueue aware and/or bnx2x to provide=20
> ndo_select_queue?
>=20

bonding might become multiqueue aware, there are several patches
floating around.

But with your ping tests, it wont change the selected txqueue anyway (i=
t
will be the same for any targets, because skb_tx_hash() wont hash the
destination address, only the skb->protocol.

> BTW: With a normal router workload, should I expect big performance d=
rop=20
> when receiving and forwarding the same packet using different CPUs?=20
> Bonding provides very important functionality, I'm not able to drop i=
t. :(
>=20

Not sure what you mean by forwarding same packet using different CPUs.
You probably meant different queues, because in normal case, only one
cpu is involved (the one receiving the packet is also the one
transmitting it, unless you have congestion or trafic shaping)

If you have 4 cpus, you can use following patch and have a transparent
bonding against multiqueue. Still bonding xmit path hits a global
rwlock, so performance is not what you can get without bonding.

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 5e12462..2c257f7 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -5012,8 +5012,8 @@ int bond_create(struct net *net, const char *name=
)
=20
 	rtnl_lock();
=20
-	bond_dev =3D alloc_netdev(sizeof(struct bonding), name ? name : "",
-				bond_setup);
+	bond_dev =3D alloc_netdev_mq(sizeof(struct bonding), name ? name : ""=
,
+				bond_setup, 4);
 	if (!bond_dev) {
 		pr_err("%s: eek! can't alloc netdev!\n", name);
 		rtnl_unlock();


