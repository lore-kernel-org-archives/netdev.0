From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC net-next-2.6] net: speedup sk_wake_async()
Date: Wed, 07 Oct 2009 08:53:37 -0700
Message-ID: <4ACCB981.9030002@hp.com>
References: <4ACBCDD8.5000306@gmail.com> <4ACBE3E7.60404@hp.com> <4ACC0CDE.1020907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:11328 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752841AbZJGPyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 11:54:15 -0400
In-Reply-To: <4ACC0CDE.1020907@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Rick Jones a =E9crit :
>=20
>>How about 64-bit?
>=20
>=20
> No data yet, but larger footprint unfortunatly :-(

True - nothing comes for free.  I'm not "in touch" with the embedded si=
de, where=20
I presume 32 bit will be if not already is now the primary bitness, but=
 over in=20
the server side of the world, at least the part I see, 64 bit is de rig=
eur,=20
hence my curiousity.

>>Got any netperf service demand changes?
>=20
>=20
> I was going to setup a bench lab, with a typical RTP mediaserver, wit=
h say
> 4000 UDP sockets, 2000 sockets exchanging 50 G.711 Alaw/ulaw
> messages per second tx and rx. (Total : 100.000 packets per second ea=
ch way)
>=20
> Is netperf able to simulate this workload ?

Touche :)

It would be, well, cumbersome with netperf2, but possible.  One would=20
=2E/configure --enable-intervals and then run some variation of:

netperf -t UDP_STREAM -l <time> -H <remote> -b <burst size> -w <burst i=
nterval>=20
-- -m <message size>

a large number of times.  Given the lack of test synchronization in net=
perf2 I=20
probably would not try to aggregate the results of N thousand simultane=
ous=20
netperf2 instances and would rely instead on external (relative to netp=
erf)=20
packet rate reports.

Still, if the cache miss removed is a non-trivial fraction of the overh=
ead I=20
would think that something like:

netperf -t UDP_RR -l <time> -I 99,0.5 -i 30,3 -c -C -H remote -- -r 4

run with and without the change would show a difference in the service =
demand,=20
and if you hit the confidence intervals you would be able, per the abov=
e be=20
confident in the "reality" of a CPU utilization difference of +/- 0.25%=
 .=20
Getting that test to that level of confidence probably means pinning th=
e NIC=20
interrupts to a specific CPU and then binding netperf/netserver on eith=
er side=20
using the global -T option.

Barring getting sutiable confidence intervals, somewhere in the middle =
of all=20
that would be ./configure --enable-burst and then, still with pinning a=
nd=20
binding for "stability" something like:

netperf -t UDP_RR -l <time> -I 99,0.5 -i 30,3 -H <remote> -- -r 4 -b <b=
urst>

to put multiple transactions in flight across that flow - choosing <bur=
st> to=20
take the CPU on which either netperf, netserver, or the interrupts are =
running=20
to 100% saturation.  Here I left-off the CPU utilization since that is =
often the=20
thing that cannot hit the confidence intervals, and leave the aggregate=
=20
throughput as the proxy for efficiency change - which is why <burst> ne=
eds to=20
take something to saturation in each case.

happy benchmarking,

rick jones
