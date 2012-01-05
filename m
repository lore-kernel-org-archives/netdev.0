From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net_sched: red: split red_parms into parms and
 vars
Date: Thu, 05 Jan 2012 14:39:37 +0100
Message-ID: <1325770777.2415.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1325766316.2415.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAA93jw4ndMg-4BnhmspxgcXYdozu5+YX9VJgtHJ3N5HVX1b4yg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:40595 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756270Ab2AENjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 08:39:41 -0500
Received: by werm1 with SMTP id m1so363574wer.19
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2012 05:39:40 -0800 (PST)
In-Reply-To: <CAA93jw4ndMg-4BnhmspxgcXYdozu5+YX9VJgtHJ3N5HVX1b4yg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 05 janvier 2012 =C3=A0 14:03 +0100, Dave Taht a =C3=A9crit :
> On Thu, Jan 5, 2012 at 1:25 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> > This patch splits the red_parms structure into two components.
> >
> > One holding the RED 'constant' parameters, and one containing the
> > variables.
> >
> > This permits a size reduction of GRED qdisc, and is a preliminary s=
tep
> > to add an optional RED unit to SFQ.
>=20
> ah. I see where you are going with this. You are trying also to get y=
our
> 'time in red' adaptation idea done, aren't you, or at least lay the g=
roundwork
> for that?
>=20

RED algo is agnostic : The quantity you want to average can be :

1) queue length in bytes
2) queue length in packets
3) time of residence in queue
=2E..

Adding 3) is very easy.

> Are you trying to make the 3.3 merge window for all this?
>=20

Its up to David ;)

> I don't want to discourage you in any way, but byte oriented RED
> with or without TSO doesn't work in your typical asymmetric
> environment. If you set an appropriate byte limit for
> stuff going one way, you end up with acks going out of
> control - and vice versa.

TSO has little impact if you use "average queue length in bytes"

My main concern about adding RED is to be able to perform ecn marking
instead of mere packet drops.

In the case of your router, TSO is a non issue, since a router should
handle MTU sized skbs. (disable GRO at ingress side)

>=20
> and/or packet oriented RED has some hope, but in either
> case you have to do something intelligent with a giant TSO
> stream if you are going to use it on a server or host.
>=20

Again, a flow is a flow, and TSO is just a big packet.

Once you separate flows (using SFQ or QFQ), adding a RED unit permits
early drops only on flows that want to be unfair.

> And the basic red still has two flaws that may or may
> not go away with your adaptation, or combination with
> SFQ - (I do retain hope, though)

I only want to 'activate' red on selected backlogged flows.

tc qdisc add dev eth0 root sfq[red] \
	limit 3000 headdrop flows 512 divisor 16384 \
	redflowlimit 200000b ecn

Problems of RED are :

1) the 'average' on highly variable trafic : It means nothing
interesting at all.

2) the idle time management requires to specify the link bandwidth, as =
a
fixed value. This is a problem.

In case of SFQRED, flow bandwidth is unknown, or very dynamic.

This is why I plan to reset qavg to 0 each time a flow becomes 'active'=
,
and not care of idle time at all.
