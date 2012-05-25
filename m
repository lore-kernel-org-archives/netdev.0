From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Using jiffies for tcp_time_stamp?
Date: Fri, 25 May 2012 18:54:40 +0200
Message-ID: <1337964880.3347.52.camel@edumazet-glaptop>
References: <CAACrLC39Xdm3vTKUsjz43ZPyEq_vHxR-_Uf56SjSm+kUqxOqZg@mail.gmail.com>
	 <CAACrLC2CXU-DNeonWQGJTfX53ssm_asK7WQrFuWRBB77cg-YdA@mail.gmail.com>
	 <4FBFAC30.8050508@genband.com>
	 <CAA93jw7MU8PjFk-UX864STSBp2SjjjivmfpRiPhaQ2kxZLu2sA@mail.gmail.com>
	 <CAACrLC0b5dyjJM=DGf-9nUOwar3O9EVTTR0tvynQj285EDpfwA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Taht <dave.taht@gmail.com>,
	Chris Friesen <chris.friesen@genband.com>,
	netdev@vger.kernel.org
To: =?UTF-8?Q?Sre=C4=87ko_Juri=C4=87-Kavelj?=
	<srecko.juric-kavelj@fer.hr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:37884 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864Ab2EYQyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2012 12:54:43 -0400
Received: by eeit10 with SMTP id t10so303657eei.19
        for <netdev@vger.kernel.org>; Fri, 25 May 2012 09:54:42 -0700 (PDT)
In-Reply-To: <CAACrLC0b5dyjJM=DGf-9nUOwar3O9EVTTR0tvynQj285EDpfwA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-05-25 at 18:23 +0200, Sre=C4=87ko Juri=C4=87-Kavelj wrote:
> On Fri, May 25, 2012 at 6:17 PM, Dave Taht <dave.taht@gmail.com> wrot=
e:
> > On Fri, May 25, 2012 at 4:58 PM, Chris Friesen
> > <chris.friesen@genband.com> wrote:
> >> I don't know if it would make any difference to the tcp algorithms=
, but
> >> certainly on some architectures you can get a fast and accurate ha=
rdware
> >> timestamp.
> >
> > I would be interested in someone doing that experiment in light of =
the
> > codel work.
>=20
> I've looked this up in other implementations, e.g. FreeBSD uses 1ms
> granularity no matter what HZ says, NetBSD has 500ms ticks, ...
>=20
> I guess that granularity also depends on the retransmit timers used. =
I
> didn't make out what's the precision of the timers that Linux uses in
> TCP, but I guess it uses high resolution timers? At least on x86?
>=20
> I've done a simple experiment by repeatedly calling clock_gettime
> (from userspace, but I guess it ends up as a vsyscall). I get >17
> million calls per second on a Q6600.

linux TCP uses high precision timestamps (ktime_get_real()) where
needed.

# find net|xargs grep -n TCP_CONG_RTT_STAMP
net/ipv4/tcp_veno.c:205:	.flags		=3D TCP_CONG_RTT_STAMP,
net/ipv4/tcp_vegas.c:308:	.flags		=3D TCP_CONG_RTT_STAMP,
net/ipv4/tcp_cubic.c:478:		cubictcp.flags |=3D TCP_CONG_RTT_STAMP;
net/ipv4/tcp_output.c:815:	if (icsk->icsk_ca_ops->flags & TCP_CONG_RTT_=
STAMP)
net/ipv4/tcp_lp.c:317:	.flags =3D TCP_CONG_RTT_STAMP,
net/ipv4/tcp_yeah.c:229:	.flags		=3D TCP_CONG_RTT_STAMP,
net/ipv4/tcp_illinois.c:326:	.flags		=3D TCP_CONG_RTT_STAMP,
net/ipv4/tcp_input.c:3496:				if (ca_ops->flags & TCP_CONG_RTT_STAMP &&

Other than that HZ=3D1000 seems fine.

HZ=3D100 seems a poor choice, we have NO_HZ since a long time.
