From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6 1/2] net: add IFLA_NUM_TXQ attribute
Date: Sat, 18 Sep 2010 07:33:03 +0200
Message-ID: <1284787983.4373.560.camel@edumazet-laptop>
References: <1284712288.3391.36.camel@edumazet-laptop>
	 <20100917.162958.221590019.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64498 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751986Ab0IRFdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Sep 2010 01:33:10 -0400
Received: by wwb39 with SMTP id 39so1670770wwb.1
        for <netdev@vger.kernel.org>; Fri, 17 Sep 2010 22:33:08 -0700 (PDT)
In-Reply-To: <20100917.162958.221590019.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 17 septembre 2010 =C3=A0 16:29 -0700, David Miller a =C3=A9=
crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 17 Sep 2010 10:31:28 +0200
>=20
> > In order to enable multiqueue support on some devices,
> > add IFLA_NUM_TXQ attribute, number of transmit queues, that "ip lin=
k"
> > can use, at creation and show time :
> >=20
> > # ip link add gre34 txqueues 8 type gre remote 192.168.20.80
> >=20
> > # ip link sho dev gre34
> > 8: gre34: <POINTOPOINT,NOARP> mtu 1476 qdisc noop state DOWN txqueu=
es 8=20
> >     link/gre 0.0.0.0 peer 192.168.20.80
> >=20
> > Drivers not yet multiqueue aware are supported, because core networ=
k
> > temporary sets real_num_tx_queues to one.
> >=20
> > Multiqueue enabled drivers must then sets real_num_tx_queues to
> > num_tx_queues in their newlink() method.
> >=20
> > Limits number of queues to 256 for the moment.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> This is one way to solve the problem, but I think we can do a lot
> better.
>=20
> What is the true barrier for full parallel processing over GRE tunnel=
s
> at the moment?
>=20
> It seems to me that the only issue that exists is the TXQ->lock done
> by dev_queue_xmit() for the GRE tunnel xmit.
>=20
> This is something we should have fixed ages ago, and we tried with th=
e
> ugly LLTX thing.  In my opinion all paths leading to a non-queueing
> device should not take the TX lock, because by definition there is no
> queueing state or synchronization to be cognizant of.
>=20
> Actually, statistics can matter but we already have to address that
> problem seperately for the sake of 64-bit stats on 32-bit machines.
>=20

Agreed, and even before 64bit stats, we did percpu stats on
loopback/bridge...

> Alexey even open condones this in the huge comment that sits in
> the "!q->enqueue" path of dev_queue_xmit().
>=20
> If we take care of this, then TX multi-queue works transparently for
> all software devices layered on top of suitably capable hardware,
> without us having to make any explicit multi-queue changes to the
> software device code.
>=20
> Eric, if you can demonstrate a real need for this once we solve the
> fundamental issue, as I have outlined above, I am happy to add this
> netlink attribute and tunable.  But for now I'm deferring these
> two patches.
>=20
> Thanks!

Hmm, in my case, I was interested in RX processing and RPS.
(Asymetric routing)

The only way to have more than one rx queue today is to have more than
one tx queue.

But this probably can be addressed separately.

Thanks !


