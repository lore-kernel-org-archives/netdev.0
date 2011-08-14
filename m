From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sch_generic: warning: the comparison will always evaluate as
 =?UTF-8?Q?=E2=80=98true=E2=80=99?= for the address of
 =?UTF-8?Q?=E2=80=98noop=5Fqdisc=E2=80=99?= will never be NULL
Date: Sun, 14 Aug 2011 19:39:58 +0200
Message-ID: <1313343598.2798.12.camel@edumazet-laptop>
References: <CAELBVzA-ArFvp9MRp5ZvgsEpi4ikt9Nq=zHsNSLAOiD=TqZC=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, davem@davemloft.net, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Kevin Winchester <kjwinchester@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55150 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753537Ab1HNRkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2011 13:40:14 -0400
In-Reply-To: <CAELBVzA-ArFvp9MRp5ZvgsEpi4ikt9Nq=zHsNSLAOiD=TqZC=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 14 ao=C3=BBt 2011 =C3=A0 10:44 -0300, Kevin Winchester a =C3=
=A9crit :
> With:
>=20
> gcc (GCC) 4.6.1
>=20
> I noticed the following warning appearing in my build:
>=20
> net/sched/sch_generic.c: In function =E2=80=98dev_graft_qdisc=E2=80=99=
:
> net/sched/sch_generic.c:678:2: warning: the comparison will always
> evaluate as =E2=80=98true=E2=80=99 for the address of =E2=80=98noop_q=
disc=E2=80=99 will never be NULL
> [-Waddress]
>=20
> The code in question runs:
>=20
>=20
>         /* ... and graft new one */
>         if (qdisc =3D=3D NULL)
>                 qdisc =3D &noop_qdisc;
>         dev_queue->qdisc_sleeping =3D qdisc;
>         rcu_assign_pointer(dev_queue->qdisc, &noop_qdisc);
>=20
> where rcu_assign_pointer has a null check that does not apply to
> noop_qdisc, which will never be null.
>=20

gcc is a bit stupid here. Of course we know &noop_qdisc cannot be NULL.

> My question is, should that really be assigning &noop_qdisc in there?
> It seems odd to assign &noop_qdisc to qdisc only if qdisc is null, an=
d
> then unconditionally assign &noop_qdisc into dev_queue->qdisc.
>=20
> Should the line be:
>=20
>         rcu_assign_pointer(dev_queue->qdisc, qdisc);
>=20
> instead?
>=20
> Just curious,
>=20

This was already taken into account, the trick is to make rcu_assign()
not trying to be smart, and use RCU_INIT_POINTER() in places we want to
assign NULL pointers.

So one patch is carried by Paul McKenney (RCU maintainer) for next
kernel, and other one in net-next :

http://git2.kernel.org/?p=3Dlinux/kernel/git/paulmck/linux-2.6-rcu.git;=
a=3Dcommitdiff;h=3Da7590ddfc2c855e75111ef18147a86578fe136e4

http://git2.kernel.org/?p=3Dlinux/kernel/git/davem/net-next-2.6.git;a=3D=
commitdiff;h=3Da9b3cd7f323b2e57593e7215362a7b02fc933e3a



