From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: TCP rx window autotuning harmful at LAN context
Date: Mon, 9 Mar 2009 13:33:24 -0700
Message-ID: <20090309133324.0dd56f82@nehalam>
References: <20090309112521.GB37984@bts.sk>
	<1e41a3230903091101u536a3b3bv7f0dd9da6891781e@mail.gmail.com>
	<20090309195906.M50328@bts.sk>
	<1e41a3230903091323j541d1895j2eb69b9f9c11f2f3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marian =?UTF-8?B?xI51cmtvdmnEjQ==?= <md@bts.sk>,
	netdev@vger.kernel.org
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56576 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751597AbZCIUd1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 16:33:27 -0400
In-Reply-To: <1e41a3230903091323j541d1895j2eb69b9f9c11f2f3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 9 Mar 2009 13:23:15 -0700
John Heffner <johnwheffner@gmail.com> wrote:

> On Mon, Mar 9, 2009 at 1:02 PM, Marian =C4=8Eurkovi=C4=8D <md@bts.sk>=
 wrote:
> > On Mon, 9 Mar 2009 11:01:52 -0700, John Heffner wrote
> >> On Mon, Mar 9, 2009 at 4:25 AM, Marian =C4=8Eurkovi=C4=8D <md@bts.=
sk> wrote:
> >> > =C2=A0 As rx window autotuning is enabled in all recent kernels =
and with 1 GB
> >> > of RAM the maximum tcp_rmem becomes 4 MB, this problem is spread=
ing rapidly
> >> > and we believe it needs urgent attention. As demontrated above, =
such huge
> >> > rx window (which is at least 100*BDP of the example above) does =
not deliver
> >> > any performance gain but instead it seriously harms other hosts =
and/or
> >> > applications. It should also be noted, that host with autotuning=
 enabled
> >> > steals an unfair share of the total available bandwidth, which m=
ight look
> >> > like a "better" performing TCP stack at first sight - however su=
ch behaviour
> >> > is not appropriate (RFC2914, section 3.2).
> >>
> >> It's well known that "standard" TCP fills all available drop-tail
> >> buffers, and that this behavior is not desirable.
> >
> > Well, in practice that was always limited by receive window size, w=
hich
> > was by default 64 kB on most operating systems. So this undesirable=
 behavior
> > was limited to hosts where receive window was manually increased to=
 huge values.
> >
> > Today, the real effect of autotuning is the same as changing the re=
ceive window
> > size to 4 MB on *all* hosts, since there's no mechanism to prevent =
it from
> > growing the window to maximum even for low RTT paths.
> >
> >> The situation you describe is exactly what congestion control (the
> >> topic of RFC2914) should fix. =C2=A0It is not the role of receive =
window
> >> (flow control). =C2=A0It is really the sender's job to detect and =
react to
> >> this, not the receiver's. =C2=A0(We have had this discussion befor=
e on
> >> netdev.)
> >
> > It's not of high importance whose job it is according to pure theor=
y.
> > What matters is, that autotuning introduced serious problem at LAN =
context
> > by disabling any possibility to properly react to increasing RTT. A=
gain,
> > it's not important whether this functionality was there by design o=
r by
> > coincidence, but it was holding the system well-balanced for many y=
ears.
>=20
> This is not a theoretical exercise, but one in good system design.
> This "well-balanced" system was really broken all along, and
> autotuning has exposed this.
>=20
> A drop-tail queue size of 1000 packets on a local interface is
> questionable, and I think this is the real source of your problem.
> This change was introduced a few years ago on most drivers --
> generally used to be 100 by default.  This was partly because TCP
> slow-start has problems when a drop-tail queue is smaller than the
> BDP.  (Limited slow-start is meant to address this problem, but
> requires tuning to the right value.)  Again, using AQM is likely the
> best solution.

By default, sky2 queue is 511 pkts which is 6.2ms on @ 1G.
Probably, should be half that by default. Also there is
software transmit queue as well, which could be 0 unless some
form of AQM is being done.

>=20
> > Now, as autotuning is enabled by default in stock kernel, this prob=
lem is
> > spreading into LANs without users even knowing what's going on. The=
refore
> > I'd like to suggest to look for a decent fix which could be impleme=
nted
> > in relatively short time frame. My proposal is this:
> >
> > - measure RTT during the initial phase of TCP connection (first X s=
egments)
> > - compute maximal receive window size depending on measured RTT usi=
ng
> > =C2=A0configurable constant representing the bandwidth part of BDP
> > - let autotuning do its work upto that limit.
>=20
> Let's take this proposal, and try it instead at the sender side, as
> part of congestion control.  Would this proposal make sense in that
> position?  Would you seriously consider it there?
>=20
> (As a side note, this is in fact what happens if you disable
> timestamps, since TCP cannot get an updated measurement of RTT withou=
t
> timestamps, only a lower bound.  However, I consider this a limitatio=
n
> not a feature.)
>=20
>   -John
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
