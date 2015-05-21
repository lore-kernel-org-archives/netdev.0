From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ingress policying for realtime protocol
Date: Thu, 21 May 2015 07:04:05 -0700
Message-ID: <1432217045.4060.91.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150519211145.GA23134@pengutronix.de>
	 <CAHA+R7N8wFKPzOR0EshWzcaTUd+ChMW0zb0=1go4oV_gxoAyiA@mail.gmail.com>
	 <1432168240.4060.63.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150521070712.GY24769@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <cwang@twopensource.com>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:36323 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755329AbbEUOEI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 10:04:08 -0400
Received: by igbpi8 with SMTP id pi8so10493486igb.1
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 07:04:08 -0700 (PDT)
In-Reply-To: <20150521070712.GY24769@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-21 at 09:07 +0200, Uwe Kleine-K=C3=B6nig wrote:
> On Wed, May 20, 2015 at 05:30:40PM -0700, Eric Dumazet wrote:
> > On Wed, 2015-05-20 at 16:46 -0700, Cong Wang wrote:
> >=20
> > > There is very little to do on ingress side since there is no queu=
e at all,
> > > not to mention priority, you could try ifb to see if it fits your=
 need.
> >=20
> > Note that if the need is to police traffic, ifb is not really neede=
d :
> >=20
> > TC=3D"tc"
> > DEV=3D"dev eth0"
> > IP=3D10.246.11.51/32
> > $TC qdisc del $DEV ingress 2>/dev/null
> > $TC qdisc add $DEV ingress
> > $TC filter add $DEV parent ffff: protocol ip u32 match ip src $IP \
> > 	police rate 1Mbit burst 10Mbit mtu 66000 action drop/continue
> >=20
> > $TC -s filter ls $DEV parent ffff: protocol ip
> I have something like that (matching on dst mac addresses instead of =
src ip):
>=20
> 	tc qdisc add dev eth0 handle ffff: ingress
> 	tc filter add dev eth0 parent ffff: protocol all prio 10 u32 match e=
ther dst 01:15:4E:00:00:01 police pass
> 	tc filter add dev eth0 parent ffff: protocol all prio 50 u32 match u=
32 0 0 at 0 police rate 100kbit burst 10k drop

Thats a very aggressive policer.

You cannot really prevent 'other traffic' from consuming wire time.
Dropping them at receiver might be too late, as they had already blocke=
d
your realtime traffic.

>=20
> . So Cong interpreted my question right and probably I just used the
> wrong keywords to make you understand the same. I try again to put my
> idea in words to make it explicit:
>=20
> I imagine that it could help in my case if I could assert that MRP
> packets are handled priorized over other traffic without throwing awa=
y
> so many unrelated packets. For egress that works by e.g. using a prio
> qdisc. For ingress however only shaping is available.

Your script actually implements policing.

If you want shaping, then you need to add IFB to get queues and
scheduling of these queues.

>=20
> So the question essentially is: Why doesn't this work for ingress? Co=
ng
> wrote "there is no queue at all [for ingress]". Is this by design? Or=
 is
> it just not implemented because noone spend the effort to work on tha=
t?
> Do you think it would help me?

Use IFB, and install TBF on top of it.

(But bypass it for your realtime packets)

Adapt following script for example.

ETH=3Deth0
IFB=3Difb0

modprobe ifb
ip link set dev $IFB up

tc qdisc del dev $ETH ingress 2>/dev/null
tc qdisc add dev $ETH ingress 2>/dev/null

tc filter add dev $ETH parent ffff: \
   protocol all prio 10 u32 match ether dst 01:15:4E:00:00:01 police pa=
ss

tc filter add dev $ETH parent ffff: \
   protocol ip u32 match u32 0 0 action mirred egress \
   redirect dev $IFB

ethtool -K $ETH gro off lro off 2>/dev/null

ifconfig $IFB txqueuelen 1000

tc qdisc del dev $IFB root 2>/dev/null
tc qdisc add dev $IFB root \
    tbf limit 1000 burst 64000 rate 100kbit
