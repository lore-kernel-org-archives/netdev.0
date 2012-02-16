From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: limited network bandwidth with 3.2.x kernels
Date: Thu, 16 Feb 2012 13:51:05 +0000
Message-ID: <1329400265.3048.178.camel@deadeye>
References: <8633039.fHPLx6GNq3@localhost.localdomain>
	 <4249109.nLB9JCi9YF@localhost.localdomain>
	 <1329313785.2437.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <2687521.3ztN17SHUf@localhost.localdomain>
	 <1329318481.2437.57.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CADVnQy=UOvC06TBOE7d7WvuKm1Tdkzu7M4dfvm6VRcRJaDMyLw@mail.gmail.com>
	 <1329377352.5646.32.camel@edumazet-laptop>
	 <1329399616.9395.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neal Cardwell <ncardwell@google.com>,
	Netdev <netdev@vger.kernel.org>, <alekcejk@googlemail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:19440 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751220Ab2BPNvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 08:51:04 -0500
In-Reply-To: <1329399616.9395.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-02-16 at 14:40 +0100, Eric Dumazet wrote:
> Le jeudi 16 f=C3=A9vrier 2012 =C3=A0 08:29 +0100, Eric Dumazet a =C3=A9=
crit :
> > So I took the time to setup a netem in my lab (and had to fix netem=
 by
> > the way). Gigabit link.
> >=20
> > On sender :
> > tc qdisc add dev vlan.103 root netem delay 50ms
> >=20
> > And netperf session is a bit strange, since receiver window is abou=
t
> > 1Mbytes (17097*64) but sender never uses half of it.
> >=20
> > cwnd is ~408
> >=20
> > $ ss -emoi  dst 192.168.20.108
> > State      Recv-Q Send-Q                                 Local
> > Address:Port                                     Peer Address:Port =
 =20
> > ESTAB      0      450976
> > 192.168.20.110:52017
> > 192.168.20.108:44169    timer:(on,235ms,0) ino:21711 sk:f24d2d00
> > 	 mem:(r0,w698880,f206336,t0) ts sack ecn bic wscale:6,8 rto:252
> > rtt:52/0.75 cwnd:408 send 90.9Mbps rcv_space:14600
> >=20
> > $ tc -s -d qdisc show dev vlan.103
> > qdisc netem 8009: root refcnt 2 limit 1000 delay 50.0ms
> >  Sent 15149167430 bytes 10017438 pkt (dropped 0, overlimits 0 reque=
ues
> > 0)=20
> >  rate 74878Kbit 6193pps backlog 476760b 316p requeues 0=20
>=20
> Its seems a problem with GRO.
>=20
> Receiver opens its window each time it sends an ACK, without taking c=
are
> how many segments were ACKed.
>=20
> In these traces, I give the ACKS sent by receiver, first trace GRO on=
,
> second with GRO off
>=20
> We can see that with GRO off, receiver opens its window way faster
> (against number of received bytes)
>=20
> (REC & SENDER are both 3.0 kernels, so problem is quite old)
[...]

I'm aware of this problem and I believe it exists with most
implementations of LRO.

The out-of-tree version of the sfc driver has its own soft-LRO
implementation (SSR) which does some limited connection tracking to
detect slow start and disable aggregation temporarily.  I've been
meaning to look into enhancing GRO to match SSR, but haven't got round
to it yet.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
