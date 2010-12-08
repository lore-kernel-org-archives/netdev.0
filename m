From: Simon Horman <horms@verge.net.au>
Subject: Re: bonding: flow control regression [was Re: bridging: flow
 control regression]
Date: Wed, 8 Dec 2010 22:22:17 +0900
Message-ID: <20101208132217.GA28040@verge.net.au>
References: <20101101122920.GB10052@verge.net.au>
 <1288616372.2660.101.camel@edumazet-laptop>
 <20101102020625.GA22724@verge.net.au>
 <1288673622.2660.147.camel@edumazet-laptop>
 <20101102070308.GA19924@verge.net.au>
 <1288683057.2660.154.camel@edumazet-laptop>
 <20101102084646.GA23774@verge.net.au>
 <1288690185.2832.8.camel@edumazet-laptop>
 <20101106092535.GD5128@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:49467 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754692Ab0LHNWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 08:22:22 -0500
Content-Disposition: inline
In-Reply-To: <20101106092535.GD5128@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 06, 2010 at 06:25:37PM +0900, Simon Horman wrote:
> On Tue, Nov 02, 2010 at 10:29:45AM +0100, Eric Dumazet wrote:
> > Le mardi 02 novembre 2010 =C3=A0 17:46 +0900, Simon Horman a =C3=A9=
crit :
> >=20
> > > Thanks Eric, that seems to resolve the problem that I was seeing.
> > >=20
> > > With your patch I see:
> > >=20
> > > No bonding
> > >=20
> > > # netperf -c -4 -t UDP_STREAM -H 172.17.60.216 -l 30 -- -m 1472
> > > UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INE=
T to 172.17.60.216 (172.17.60.216) port 0 AF_INET
> > > Socket  Message  Elapsed      Messages                   CPU     =
 Service
> > > Size    Size     Time         Okay Errors   Throughput   Util    =
 Demand
> > > bytes   bytes    secs            #      #   10^6bits/sec % SU    =
 us/KB
> > >=20
> > > 116736    1472   30.00     2438413      0      957.2     8.52    =
 1.458=20
> > > 129024           30.00     2438413             957.2     -1.00   =
 -1.000
> > >=20
> > > With bonding (one slave, the interface used in the test above)
> > >=20
> > > netperf -c -4 -t UDP_STREAM -H 172.17.60.216 -l 30 -- -m 1472
> > > UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INE=
T to 172.17.60.216 (172.17.60.216) port 0 AF_INET
> > > Socket  Message  Elapsed      Messages                   CPU     =
 Service
> > > Size    Size     Time         Okay Errors   Throughput   Util    =
 Demand
> > > bytes   bytes    secs            #      #   10^6bits/sec % SU    =
 us/KB
> > >=20
> > > 116736    1472   30.00     2438390      0      957.1     8.97    =
 1.535=20
> > > 129024           30.00     2438390             957.1     -1.00   =
 -1.000
> > >=20
> >=20
> >=20
> > Sure the patch helps when not too many flows are involved, but this=
 is a
> > hack.
> >=20
> > Say the device queue is 1000 packets, and you run a workload with 2=
000
> > sockets, it wont work...
> >=20
> > Or device queue is 1000 packets, one flow, and socket send queue si=
ze
> > allows for more than 1000 packets to be 'in flight' (echo 2000000
> > >/proc/sys/net/core/wmem_default) , it wont work too with bonding, =
only
> > with devices with a qdisc sitting in the first device met after the
> > socket.
>=20
> True, thanks for pointing that out.
>=20
> The scenario that I am actually interested in is virtualisation.
> And I believe that your patch helps the vhostnet case (I don't see
> flow control problems with bonding + virtio without vhostnet). Howeve=
r,
> I am unsure if there are also some easy work-arounds to degrade
> flow control in the vhostnet case too.

Hi Eric,

do you have any thoughts on this?

I measured the performance impact of your patch on 2.6.37-rc1
and I can see why early orphaning is a win.

The tests are run over a bond with 3 slaves.
The bond is in rr-balance mode. Other parameters of interest are:
	MTU=3D1500
	client,server:tcp_reordering=3D3(default)
	client:GSO=3Doff,
	client:TSO=3Doff
	server:GRO=3Doff
	server:rx-usecs=3D3(default)

Without your no early-orphan patch
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
	172.17.60.216 (172.17.60.216) port 0 AF_INET
Recv   Send    Send                          Utilization       Service =
Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    =
Recv
Size   Size    Size     Time     Throughput  local    remote   local   =
remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   =
us/KB

 87380  16384  16384    10.00      1621.03   16.31    6.48     1.648   =
2.621

With your no early-orphan patch
# netperf -C -c -4 -t TCP_STREAM -H 172.17.60.216
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
	172.17.60.216 (172.17.60.216) port 0 AF_INET
Recv   Send    Send                          Utilization       Service =
Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    =
Recv
Size   Size    Size     Time     Throughput  local    remote   local   =
remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   =
us/KB

 87380  16384  16384    10.00      1433.48   9.60     5.45     1.098   =
2.490


However in the case of virtualisation I think it is a win to be able to=
 do
flow control on UDP traffic from guests (using vitio). Am I missing
something and flow control can be bypassed anyway? If not perhaps makin=
g
the change that your patch makes configurable through proc or ethtool i=
s an
option?

