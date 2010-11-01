From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bridging: flow control regression
Date: Mon, 01 Nov 2010 13:59:32 +0100
Message-ID: <1288616372.2660.101.camel@edumazet-laptop>
References: <20101101122920.GB10052@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46484 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757557Ab0KAM7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 08:59:40 -0400
Received: by wyf28 with SMTP id 28so5463261wyf.19
        for <netdev@vger.kernel.org>; Mon, 01 Nov 2010 05:59:39 -0700 (PDT)
In-Reply-To: <20101101122920.GB10052@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 01 novembre 2010 =C3=A0 21:29 +0900, Simon Horman a =C3=A9crit=
 :
> Hi,
>=20
> I have observed what appears to be a regression between 2.6.34 and
> 2.6.35-rc1. The behaviour described below is still present in Linus's
> current tree (2.6.36+).
>=20
> On 2.6.34 and earlier when sending a UDP stream to a bonded interface
> the throughput is approximately equal to the available physical bandw=
idth.
>=20
> # netperf -c -4 -t UDP_STREAM -H 172.17.50.253 -l 30 -- -m 1472
> UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
> 172.17.50.253 (172.17.50.253) port 0 AF_INET
> Socket  Message  Elapsed      Messages                   CPU      Ser=
vice
> Size    Size     Time         Okay Errors   Throughput   Util     Dem=
and
> bytes   bytes    secs            #      #   10^6bits/sec % SU     us/=
KB
>=20
> 114688    1472   30.00     2438265      0      957.1     18.09    3.1=
59=20
> 109568           30.00     2389980             938.1     -1.00    -1.=
000
>=20
> On 2.6.35-rc1 netpref sends~7Gbits/s.
> Curiously it only consumes 50% CPU, I would expect this to be CPU bou=
nd.
>=20
> # netperf -c -4 -t UDP_STREAM -H 172.17.50.253 -l 30 -- -m 1472
> UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
> 172.17.50.253 (172.17.50.253) port 0 AF_INET
> Socket  Message  Elapsed      Messages                   CPU      Ser=
vice
> Size    Size     Time         Okay Errors   Throughput   Util     Dem=
and
> bytes   bytes    secs            #      #   10^6bits/sec % SU     us/=
KB
>=20
> 116736    1472   30.00     18064360      0     7090.8     50.62    8.=
665=20
> 109568           30.00     2438090             957.0     -1.00    -1.=
000
>=20
> In this case the bonding device has a single gitabit slave device
> and is running in balance-rr mode. I have observed similar results
> with two and three slave devices.
>=20
> I have bisected the problem and the offending commit appears to be
> "net: Introduce skb_orphan_try()". My tired eyes tell me that change
> frees skb's earlier than they otherwise would be unless tx timestampi=
ng
> is in effect. That does seem to make sense in relation to this proble=
m,
> though I am yet to dig into specifically why bonding is adversely aff=
ected.
>=20

I assume you meant "bonding: flow control regression", ie this is not
related to bridging ?

One problem on bonding is that the xmit() method always returns
NETDEV_TX_OK.

So a flooder cannot know some of its frames were lost.

So yes, the patch you mention has the effect of allowing UDP to flood
bonding device, since we orphan skb before giving it to device (bond or
ethX)

With a normal device (with a qdisc), we queue skb, and orphan it only
when leaving queue. With a not too big socket send buffer, it slows dow=
n
the sender enough to "send UDP frames at line rate only"



