From: Simon Horman <horms@verge.net.au>
Subject: Re: bonding: flow control regression [was Re: bridging: flow
 control regression]
Date: Tue, 2 Nov 2010 17:46:48 +0900
Message-ID: <20101102084646.GA23774@verge.net.au>
References: <20101101122920.GB10052@verge.net.au>
 <1288616372.2660.101.camel@edumazet-laptop>
 <20101102020625.GA22724@verge.net.au>
 <1288673622.2660.147.camel@edumazet-laptop>
 <20101102070308.GA19924@verge.net.au>
 <1288683057.2660.154.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:58871 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927Ab0KBIrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Nov 2010 04:47:02 -0400
Content-Disposition: inline
In-Reply-To: <1288683057.2660.154.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 02, 2010 at 08:30:57AM +0100, Eric Dumazet wrote:
> Le mardi 02 novembre 2010 =C3=A0 16:03 +0900, Simon Horman a =C3=A9cr=
it :
> > On Tue, Nov 02, 2010 at 05:53:42AM +0100, Eric Dumazet wrote:
> > > Le mardi 02 novembre 2010 =C3=A0 11:06 +0900, Simon Horman a =C3=A9=
crit :
> > >=20
> > > > Thanks for the explanation.
> > > > I'm not entirely sure how much of a problem this is in practice=
=2E
> > >=20
> > > Maybe for virtual devices (tunnels, bonding, ...), it would make =
sense
> > > to delay the orphaning up to the real device.
> >=20
> > That was my initial thought. Could you give me some guidance
> > on how that might be done so I can try and make a patch to test?
> >=20
> > > But if the socket send buffer is very large, it would defeat the =
flow
> > > control any way...
> >=20
> > I'm primarily concerned about a situation where
> > UDP packets are sent as fast as possible, indefinitely.
> > And in that scenario, I think it would need to be a rather large bu=
ffer.
> >=20
>=20
> Please try following patch, thanks.

Thanks Eric, that seems to resolve the problem that I was seeing.

With your patch I see:

No bonding

# netperf -c -4 -t UDP_STREAM -H 172.17.60.216 -l 30 -- -m 1472
UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 1=
72.17.60.216 (172.17.60.216) port 0 AF_INET
Socket  Message  Elapsed      Messages                   CPU      Servi=
ce
Size    Size     Time         Okay Errors   Throughput   Util     Deman=
d
bytes   bytes    secs            #      #   10^6bits/sec % SU     us/KB

116736    1472   30.00     2438413      0      957.2     8.52     1.458=
=20
129024           30.00     2438413             957.2     -1.00    -1.00=
0

With bonding (one slave, the interface used in the test above)

netperf -c -4 -t UDP_STREAM -H 172.17.60.216 -l 30 -- -m 1472
UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 1=
72.17.60.216 (172.17.60.216) port 0 AF_INET
Socket  Message  Elapsed      Messages                   CPU      Servi=
ce
Size    Size     Time         Okay Errors   Throughput   Util     Deman=
d
bytes   bytes    secs            #      #   10^6bits/sec % SU     us/KB

116736    1472   30.00     2438390      0      957.1     8.97     1.535=
=20
129024           30.00     2438390             957.1     -1.00    -1.00=
0

