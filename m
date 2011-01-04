From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] net_sched: mark packet staying on queue too long
Date: Tue, 04 Jan 2011 16:02:09 +0100
Message-ID: <1294153329.3579.99.camel@edumazet-laptop>
References: <1292855730-19265-1-git-send-email-xiaosuo@gmail.com>
	 <20101220232020.GB2052@del.dom.local>
	 <1292887689.2627.150.camel@edumazet-laptop>
	 <20101220235209.GA1865@del.dom.local> <1292939574.6535.27.camel@mojatatu>
	 <AANLkTikwMQBwNdT1nZ97NNFYGJnwhk39+8afTKONgeF5@mail.gmail.com>
	 <20101221223704.GA1979@del.dom.local> <1293111333.11306.170.camel@mojatatu>
	 <1294003631.2535.253.camel@edumazet-laptop>
	 <20110103095842.7677130d@nehalam>
	 <Pine.LNX.4.64.1101041506300.2576@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, hadi@cyberus.ca,
	Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45106 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139Ab1ADPCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 10:02:14 -0500
Received: by wyb28 with SMTP id 28so14381865wyb.19
        for <netdev@vger.kernel.org>; Tue, 04 Jan 2011 07:02:12 -0800 (PST)
In-Reply-To: <Pine.LNX.4.64.1101041506300.2576@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 04 janvier 2011 =C3=A0 15:19 +0100, Jesper Dangaard Brouer a =C3=
=A9crit :
> On Mon, 3 Jan 2011, Stephen Hemminger wrote:
>=20
> > On Sun, 02 Jan 2011 22:27:11 +0100
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> >> While playing with SFQ and other AQM, I was bothered to see how ea=
sy it
> >> was for a single tcp flow to 'fill the pipe' and consume lot of me=
mory
> >> buffers in queues. I know Jesper use more than 50.000 SFQ on his
> >> routers, and with GRO packets this can consume a lot of memory.
>=20
> That is true, operations department went kind of crazy when they star=
ted=20
> to add/move customers to our new Nehalem Xeon 5550 systems.  I have=20
> stopped them now ;-)
>=20
> The use of an SFQ per customer, actually also solves the buffer bloat=
=20
> issue for our customers...
>=20
>=20
> >> I played a bit adding ECN in SFQ, first by marking packets for a
> >> particular flow if this flow qlen was above a given threshold, and=
 later
> >> using another trick : ECN mark packet if it stayed longer than a g=
iven
> >> delay in the queue. This of course could be done on other modules,=
 what
> >> do you think ?
>=20
> This is very interesting stuff! :-)
>=20
> Are you inspired by Jim Gettys buffer bloat discussions?
>=20

Not at all, I had to install an AQM here at work, I chose SFQ because
the machines only handle tcp flows (and limited number of flows)

> > ...
> > You might want to look into CHOKe and ECSFQ which are other AQM mod=
els
> > that have shown up in research.
>=20
> Have you looked at the SFB (Stochastic Fair Blue) implementation by=20
> Juliusz Chroboczek?
>=20
> http://www.pps.jussieu.fr/~jch/software/sfb/

Yes I did, but after some reading, I think there is an issue with BLUE,
regarding number of cache misses and complexity because of Bloom filter
(and double hashing)
=46or workloads with many flows, all bits are marked very fast.

I'd like to try kind of a SFQRED implementation, ie :

classify flows, then instead of using plain pfifo queues (currently don=
e
in SFQ), use N pseudo RED queues.

RED is a bit complex because it tries to make the probability estimatio=
n
given queue backlog average. It has to use expensive time services (on
some machines at least, if TSC not available)

My idea was to take into account the delay packets stay in its queue, s=
o
that no extra state is needed : Only take a timestamp when packet is
enqueued, compute delta when dequeued, get=20

Px =3D delta * Prob_per_time_unit;
and drop/mark packet with Px probability.

Ram usage of SFQRED would be the same than SFQ, and cost roughly the
same (because we could use jiffies based time sampling, (and HZ=3D1000 =
for
a ms unit)).



