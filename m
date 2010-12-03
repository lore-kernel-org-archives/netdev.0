From: Simon Horman <horms@verge.net.au>
Subject: Re: Bonding, GRO and tcp_reordering
Date: Fri, 3 Dec 2010 22:38:00 +0900
Message-ID: <20101203133800.GA26038@verge.net.au>
References: <20101130135549.GA22688@verge.net.au>
 <1291131776.21077.27.camel@bwh-desktop>
 <1291133073.2904.128.camel@edumazet-laptop>
 <20101201043445.GC3485@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:51687 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754898Ab0LCNiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 08:38:05 -0500
Content-Disposition: inline
In-Reply-To: <20101201043445.GC3485@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 01, 2010 at 01:34:45PM +0900, Simon Horman wrote:
> On Tue, Nov 30, 2010 at 05:04:33PM +0100, Eric Dumazet wrote:
> > Le mardi 30 novembre 2010 =C3=A0 15:42 +0000, Ben Hutchings a =C3=A9=
crit :
> > > On Tue, 2010-11-30 at 22:55 +0900, Simon Horman wrote:

To clarify my statement in a previous email that GSO had no effect: I
re-ran the tests and I still haven't observed any affect of GSO on my
results. However, I did notice that in order for GRO on the server to h=
ave
effect I also need TSO enabled on the client.  I thought that I had
previously checked that but I was mistaken.

Enabling TSO on the client while leaving GSO disabled on the server
resulted in increased CPU utilisation on the client, from ~15% to ~20%.

> > > > The only other parameter that seemed to have significant effect=
 was to
> > > > increase the mtu.  In the case of MTU=3D9000, GRO seemed to hav=
e a negative
> > > > impact on throughput, though a significant positive effect on C=
PU
> > > > utilisation.
> > > [...]
> > >=20
> > > Increasing MTU also increases the interval between packets on a T=
CP flow
> > > using maximum segment size so that it is more likely to exceed th=
e
> > > difference in delay.
> > >=20
> >=20
> > GRO really is operational _if_ we receive in same NAPI run several
> > packets for the same flow.
> >=20
> > As soon as we exit NAPI mode, GRO packets are flushed.
> >=20
> > Big MTU --> bigger delays between packets, so big chance that GRO c=
annot
> > trigger at all, since NAPI runs for one packet only.
> >=20
> > One possibility with big MTU is to tweak "ethtool -c eth0" params
> > rx-usecs: 20
> > rx-frames: 5
> > rx-usecs-irq: 0
> > rx-frames-irq: 5
> > so that "rx-usecs" is bigger than the delay between two MTU full si=
zed
> > packets.
> >=20
> > Gigabit speed means 1 nano second per bit, and MTU=3D9000 means 72 =
us
> > delay between packets.
> >=20
> > So try :
> >=20
> > ethtool -C eth0 rx-usecs 100
> >=20
> > to get chance that several packets are delivered at once by NIC.
> >=20
> > Unfortunately, this also add some latency, so it helps bulk transfe=
rts,
> > and slowdown interactive traffic=20
>=20
> Thanks Eric,
>=20
> I was tweaking those values recently for some latency tuning
> but I didn't think of them in relation to last night's tests.
>=20
> In terms of my measurements, its just benchmarking at this stage.
> So a trade-off between throughput and latency is acceptable, so long
> as I remember to measure what it is.

Thanks, rx-usecs was set to 3 and changing it to 15 on the server
did seem increase throughput with 1500 byte packets. Although
CPU utilisation increased too, disproportionally so on the client.

MTU=3D1500, client,server:tcp_reordering=3D3, client:GSO=3Doff,
	client:TSO=3Don, server:GRO=3Doff, server:rx-usecs=3D3(default)
# netperf -c -4 -t TCP_STREAM -H 172.17.60.216
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.17.60.216 =
(172.17.60.216) port 0 AF_INET
Recv   Send    Send                          Utilization       Service =
Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    =
Recv
Size   Size    Size     Time     Throughput  local    remote   local   =
remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   =
us/KB

 87380  16384  16384    10.00      1591.34   16.35    5.80     1.683   =
2.390

MTU=3D1500, client,server:tcp_reordering=3D3(default), client:GSO=3Doff=
,
	client:TSO=3Don, server:GRO=3Doff server:rx-usecs=3D15
# netperf -c -4 -t TCP_STREAM -H 172.17.60.216
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.17.60.216 =
(172.17.60.216) port 0 AF_INET
Recv   Send    Send                          Utilization       Service =
Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    =
Recv
Size   Size    Size     Time     Throughput  local    remote   local   =
remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   =
us/KB

 87380  16384  16384    10.00      1774.38   23.75    7.58     2.193   =
2.801

I also saw an improvement with GRO enabled on the server and TSO enable=
d on
the client.  Although in this case I found rx-usecs=3D45 to be the best
value.

MTU=3D1500, client,server:tcp_reordering=3D3(default), client:GSO=3Doff=
,
	client:TSO=3Don, server:GRO=3Don server:rx-usecs=3D3(default)
# netperf -c -4 -t TCP_STREAM -H 172.17.60.216
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.17.60.216 =
(172.17.60.216) port 0 AF_INET
Recv   Send    Send                          Utilization       Service =
Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    =
Recv
Size   Size    Size     Time     Throughput  local    remote   local   =
remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   =
us/KB

 87380  16384  16384    10.00      2553.27   13.31    3.35     0.854   =
0.860

MTU=3D1500, client,server:tcp_reordering=3D3(default), client:GSO=3Doff=
,
	client:TSO=3Don, server:GRO=3Don server:rx-usecs=3D45
# netperf -c -4 -t TCP_STREAM -H 172.17.60.216
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 172.17.60.216 =
(172.17.60.216) port 0 AF_INET
Recv   Send    Send                          Utilization       Service =
Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    =
Recv
Size   Size    Size     Time     Throughput  local    remote   local   =
remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   =
us/KB

 87380  16384  16384    10.00      2727.53   29.45    9.48     1.769   =
2.278

I did not observe any improvement in throughput when increasing rx-usec=
s
from 3 when using mtu=3D9000 although there was a slight increase in CP=
U
utilisation (maybe, there is quite a lot of noise in the results).

