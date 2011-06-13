From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Question about LRO/GRO and TCP acknowledgements
Date: Mon, 13 Jun 2011 10:55:26 -0700
Message-ID: <1307987726.8149.3312.camel@tardy>
References: <20110611215919.5fc29c27@konijn>
	 <1307850224.22348.626.camel@localhost> <20110612095131.6d924082@konijn>
	 <1307869632.2872.106.camel@edumazet-laptop>
	 <20110612113004.79f48f40@konijn>
	 <1307875698.2872.130.camel@edumazet-laptop>
	 <20110612132428.3e1a4593@konijn>
	 <1307890657.2872.158.camel@edumazet-laptop>
Reply-To: rick.jones2@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joris van Rantwijk <joris@jorisvr.nl>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:28474 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753492Ab1FMRz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2011 13:55:28 -0400
In-Reply-To: <1307890657.2872.158.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-06-12 at 16:57 +0200, Eric Dumazet wrote:
> Le dimanche 12 juin 2011 =C3=A0 13:24 +0200, Joris van Rantwijk a =C3=
=A9crit :
> > On 2011-06-12, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > So your concern is more a Sender side implementation missing this
> > > recommendation, not GRO per se...
> >=20
> > Not really. The same RFC says:
> >   Specifically, an ACK SHOULD be generated for at least every
> >   second full-sized segment, ...
> >=20
>=20
> Well, SHOULD is not MUST.
>=20
>=20
> > I can see how the world may have been a better place if every sende=
r
> > implemented Appropriate Byte Counting and TCP receivers were allowe=
d to
> > send fewer ACKs. However, current reality is that ABC is optional,
> > disabled by default in Linux, and receivers are recommended to send=
 one
> > ACK per two segments.
> >=20
>=20
> ABC might be nice for stacks that use byte counters for cwnd. We use
> segments.
>=20
> > I suspect that GRO currently hurts throughput of isolated TCP
> > connections. This is based on a purely theoretic argument. I may be
> > wrong and I have absolutely no data to confirm my suspicion.
> >=20
> > If you can point out the flaw in my reasoning, I would be greatly
> > relieved. Until then, I remain concerned that there may be somethin=
g
> > wrong with GRO and TCP ACKs.
>=20
> Think of GRO being a receiver facility against stress/load, typically=
 in
> datacenter.
>=20
> Only when receiver is overloaded, GRO kicks in and can coalesce sever=
al
> frames before being handled in TCP stack in one run.

How is that affected by interrupt coalescing in the NIC and the sending
side doing TSO (and so, ostensibly sending back-to-back frames)?  Are w=
e
assured that a NIC is updating its completion pointer on the rx ring
continuously rather than just before a coalesced interrupt?

Does GRO "never" kick-in over a 1GbE link (making the handwaving
assumption that cores today are >> faster than a 1GbE link on a bulk
transfer).

It was just a quick and dirty test, but it does seem there is a positiv=
e
hit from GRO being enabled on a 1GbE link on a system with "fast
processors"

raj@tardy:~/netperf2_trunk$ sudo ethtool -K eth1 gro off
raj@tardy:~/netperf2_trunk$ src/netperf -t TCP_MAERTS -H 192.168.1.3 -i
10,3 -c -- -k foo
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.1.3 (192.168.1.3) port 0 AF_INET : +/-2.500% @ 99% conf.  :
histogram : demo
THROUGHPUT=3D935.07
LOCAL_INTERFACE_NAME=3Deth1
LOCAL_CPU_UTIL=3D16.64
LOCAL_SD=3D5.830
raj@tardy:~/netperf2_trunk$ sudo ethtool -K eth1 gro on
raj@tardy:~/netperf2_trunk$ src/netperf -t TCP_MAERTS -H 192.168.1.3 -i
10,3 -c -- -k foo
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
192.168.1.3 (192.168.1.3) port 0 AF_INET : +/-2.500% @ 99% conf.  :
histogram : demo
THROUGHPUT=3D934.81
LOCAL_INTERFACE_NAME=3Deth1
LOCAL_CPU_UTIL=3D16.21
LOCAL_SD=3D5.684
raj@tardy:~/netperf2_trunk$ uname -a
Linux tardy 2.6.35-28-generic #50-Ubuntu SMP Fri Mar 18 18:42:20 UTC
2011 x86_64 GNU/Linux

The receiver system here has a 3.07 GHz W3550 in it and eth1 is a port
on an Intel 82571EB-based four-port card.

raj@tardy:~/netperf2_trunk$ ethtool -i eth1
driver: e1000e
version: 1.0.2-k4
firmware-version: 5.10-2
bus-info: 0000:2a:00.0

> If receiver is so loaded that more than 2 frames are coalesced in a N=
API
> run, it certainly helps to not allow sender to increase its cwnd more
> than one SMSS. We probably are right before packet drops anyway.

If we are indeed statistically certain we are right before packet drops
(or I suppose asserting pause) then shouldn't ECN get set by the GRO
code?

rick

