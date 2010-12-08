From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bonding: flow control regression [was Re: bridging: flow
 control regression]
Date: Wed, 08 Dec 2010 14:50:58 +0100
Message-ID: <1291816258.2883.46.camel@edumazet-laptop>
References: <20101101122920.GB10052@verge.net.au>
	 <1288616372.2660.101.camel@edumazet-laptop>
	 <20101102020625.GA22724@verge.net.au>
	 <1288673622.2660.147.camel@edumazet-laptop>
	 <20101102070308.GA19924@verge.net.au>
	 <1288683057.2660.154.camel@edumazet-laptop>
	 <20101102084646.GA23774@verge.net.au>
	 <1288690185.2832.8.camel@edumazet-laptop>
	 <20101106092535.GD5128@verge.net.au>  <20101208132217.GA28040@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48672 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755035Ab0LHNvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 08:51:03 -0500
Received: by wyb28 with SMTP id 28so1106319wyb.19
        for <netdev@vger.kernel.org>; Wed, 08 Dec 2010 05:51:02 -0800 (PST)
In-Reply-To: <20101208132217.GA28040@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 08 d=C3=A9cembre 2010 =C3=A0 22:22 +0900, Simon Horman a =C3=
=A9crit :

> Hi Eric,
>=20
> do you have any thoughts on this?
>=20
> I measured the performance impact of your patch on 2.6.37-rc1
> and I can see why early orphaning is a win.
>=20
> The tests are run over a bond with 3 slaves.
> The bond is in rr-balance mode. Other parameters of interest are:
> 	MTU=3D1500
> 	client,server:tcp_reordering=3D3(default)
> 	client:GSO=3Doff,
> 	client:TSO=3Doff
> 	server:GRO=3Doff
> 	server:rx-usecs=3D3(default)
>=20
> Without your no early-orphan patch
> TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
> 	172.17.60.216 (172.17.60.216) port 0 AF_INET
> Recv   Send    Send                          Utilization       Servic=
e Demand
> Socket Socket  Message  Elapsed              Send     Recv     Send  =
  Recv
> Size   Size    Size     Time     Throughput  local    remote   local =
  remote
> bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB =
  us/KB
>=20
>  87380  16384  16384    10.00      1621.03   16.31    6.48     1.648 =
  2.621
>=20
> With your no early-orphan patch
> # netperf -C -c -4 -t TCP_STREAM -H 172.17.60.216
> TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
> 	172.17.60.216 (172.17.60.216) port 0 AF_INET
> Recv   Send    Send                          Utilization       Servic=
e Demand
> Socket Socket  Message  Elapsed              Send     Recv     Send  =
  Recv
> Size   Size    Size     Time     Throughput  local    remote   local =
  remote
> bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB =
  us/KB
>=20
>  87380  16384  16384    10.00      1433.48   9.60     5.45     1.098 =
  2.490
>=20

It seems strange this makes such big difference with one flow


>=20
> However in the case of virtualisation I think it is a win to be able =
to do
> flow control on UDP traffic from guests (using vitio). Am I missing
> something and flow control can be bypassed anyway? If not perhaps mak=
ing
> the change that your patch makes configurable through proc or ethtool=
 is an
> option?
>=20

virtio_net start_xmit() does one skb_orphan() anyway, so not doing it
some nano seconds before wont change anything.

Real perf problem is when skb are queued (for example on eth driver TX
ring or qdisc queue), then freed some micro (or milli) seconds later.

Maybe your ethtool suggestion is the way to go, so that we can remove
special "skb_orphans()" that can be done in some drivers : Let core
network stack decide to skb_orphan() itself, not the driver.



