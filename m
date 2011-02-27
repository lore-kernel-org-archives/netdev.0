From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: txqueuelen has wrong units; should be time
Date: Sun, 27 Feb 2011 21:07:53 +0100
Message-ID: <1298837273.8726.128.camel@edumazet-laptop>
References: <AANLkTimd5GQwtUFP2fD_An=M8ajBD8DJpzxQJezv8fB8@mail.gmail.com>
	 <alpine.DEB.1.10.1102270758580.11974@uplift.swm.pp.se>
	 <1298793252.8726.45.camel@edumazet-laptop>
	 <AANLkTinyE10wtM_xJsufT_3s3hvti7CN+9nyqScWa6SA@mail.gmail.com>
	 <20110227125540.40754c5y78j9u2m8@hayate.sektori.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Albert Cahalan <acahalan@gmail.com>,
	Mikael Abrahamsson <swmike@swm.pp.se>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110227125540.40754c5y78j9u2m8@hayate.sektori.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 27 f=C3=A9vrier 2011 =C3=A0 12:55 +0200, Jussi Kivilinna a =
=C3=A9crit :
> Quoting Albert Cahalan <acahalan@gmail.com>:
>=20
> > On Sun, Feb 27, 2011 at 2:54 AM, Eric Dumazet <eric.dumazet@gmail.c=
om> wrote:
> >> Le dimanche 27 f=C3=A9vrier 2011 =C3=A0 08:02 +0100, Mikael Abraha=
msson a =C3=A9crit :
> >>> On Sun, 27 Feb 2011, Albert Cahalan wrote:
> >>>
> >>> > Nanoseconds seems fine; it's unlikely you'd ever want
> >>> > more than 4.2 seconds (32-bit unsigned) of queue.
> > ...
> >> Problem is some machines have slow High Resolution timing services=
=2E
> >>
> >> _If_ we have a time limit, it will probably use the low resolution=
 (aka
> >> jiffies), unless high resolution services are cheap.
> >
> > As long as that is totally internal to the kernel and never
> > getting exposed by some API for setting the amount, sure.
> >
> >> I was thinking not having an absolute hard limit, but an EWMA base=
d one.
> >
> > The whole point is to prevent stale packets, especially to prevent
> > them from messing with TCP, so I really don't think so. I suppose
> > you do get this to some extent via early drop.
>=20
> I made simple hack on sch_fifo with per packet time limits =20
> (attachment) this weekend and have been doing limited testing on =20
> wireless link. I think hardlimit is fine, it's simple and does =20
> somewhat same as what packet(-hard)limited buffer does, drops packets=
 =20
> when buffer is 'full'. My hack checks for timed out packets on =20
> enqueue, might be wrong approach (on other hand might allow some more=
 =20
> burstiness).
>=20


Qdisc should return to caller a good indication packet is queued or
dropped at enqueue() time... not later (aka : never)

Accepting a packet at t0, and dropping it later at t0+limit without
giving any indication to caller is a problem.

This is why I suggested using an EWMA plus a probabilist drop or
congestion indication (NET_XMIT_CN) to caller at enqueue() time.

The absolute time limit you are trying to implement should be checked a=
t
dequeue time, to cope with enqueue bursts or pauses on wire.
