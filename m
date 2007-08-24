From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: RFC: issues concerning the next NAPI interface
Date: Fri, 24 Aug 2007 08:52:03 -0700
Message-ID: <20070824085203.42f4305c@freepuppy.rosehill.hemminger.net>
References: <200708241559.17055.ossthema@de.ibm.com>
	<20070824153703.GN5592@sgi.com>
	<200708241747.16592.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akepner@sgi.com, netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60099 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753894AbXHXPws convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2007 11:52:48 -0400
In-Reply-To: <200708241747.16592.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 24 Aug 2007 17:47:15 +0200
Jan-Bernd Themann <ossthema@de.ibm.com> wrote:

> Hi,
>=20
> On Friday 24 August 2007 17:37, akepner@sgi.com wrote:
> > On Fri, Aug 24, 2007 at 03:59:16PM +0200, Jan-Bernd Themann wrote:
> > > .......
> > > 3) On modern systems the incoming packets are processed very fast=
=2E Especially
> > > =C2=A0 =C2=A0on SMP systems when we use multiple queues we proces=
s only a few packets
> > > =C2=A0 =C2=A0per napi poll cycle. So NAPI does not work very well=
 here and the interrupt=20
> > > =C2=A0 =C2=A0rate is still high. What we need would be some sort =
of timer polling mode=20
> > > =C2=A0 =C2=A0which will schedule a device after a certain amount =
of time for high load=20
> > > =C2=A0 =C2=A0situations. With high precision timers this could wo=
rk well. Current
> > > =C2=A0 =C2=A0usual timers are too slow. A finer granularity would=
 be needed to keep the
> > >    latency down (and queue length moderate).
> > >=20
> >=20
> > We found the same on ia64-sn systems with tg3 a couple of years=20
> > ago. Using simple interrupt coalescing ("don't interrupt until=20
> > you've received N packets or M usecs have elapsed") worked=20
> > reasonably well in practice. If your h/w supports that (and I'd=20
> > guess it does, since it's such a simple thing), you might try=20
> > it.
> >=20
>=20
> I don't see how this should work. Our latest machines are fast enough=
 that they
> simply empty the queue during the first poll iteration (in most cases=
).
> Even if you wait until X packets have been received, it does not help=
 for
> the next poll cycle. The average number of packets we process per pol=
l queue
> is low. So a timer would be preferable that periodically polls the=20
> queue, without the need of generating a HW interrupt. This would allo=
w us
> to wait until a reasonable amount of packets have been received in th=
e meantime
> to keep the poll overhead low. This would also be useful in combinati=
on
> with LRO.
>=20

You need hardware support for deferred interrupts. Most devices have it=
 (e1000, sky2, tg3)
and it interacts well with NAPI. It is not a generic thing you want don=
e by the stack,
you want the hardware to hold off interrupts until X packets or Y usecs=
 have expired.

The parameters for controlling it are already in ethtool, the issue is =
finding a good
default set of values for a wide range of applications and architecture=
s. Maybe some
heuristic based on processor speed would be a good starting point. The =
dynamic irq
moderation stuff is not widely used because it is too hard to get right=
=2E

--=20
Stephen Hemminger <shemminger@linux-foundation.org>
