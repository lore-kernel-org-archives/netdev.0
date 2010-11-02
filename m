From: Simon Horman <horms@verge.net.au>
Subject: Re: bonding: flow control regression [was Re: bridging: flow
 control regression]
Date: Tue, 2 Nov 2010 11:06:28 +0900
Message-ID: <20101102020625.GA22724@verge.net.au>
References: <20101101122920.GB10052@verge.net.au>
 <1288616372.2660.101.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:47016 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753018Ab0KBCFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 22:05:51 -0400
Content-Disposition: inline
In-Reply-To: <1288616372.2660.101.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 01, 2010 at 01:59:32PM +0100, Eric Dumazet wrote:
> Le lundi 01 novembre 2010 =C3=A0 21:29 +0900, Simon Horman a =C3=A9cr=
it :
> > Hi,
> >=20
> > I have observed what appears to be a regression between 2.6.34 and
> > 2.6.35-rc1. The behaviour described below is still present in Linus=
's
> > current tree (2.6.36+).
> >=20
> > On 2.6.34 and earlier when sending a UDP stream to a bonded interfa=
ce
> > the throughput is approximately equal to the available physical ban=
dwidth.
> >=20
> > # netperf -c -4 -t UDP_STREAM -H 172.17.50.253 -l 30 -- -m 1472
> > UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET =
to
> > 172.17.50.253 (172.17.50.253) port 0 AF_INET
> > Socket  Message  Elapsed      Messages                   CPU      S=
ervice
> > Size    Size     Time         Okay Errors   Throughput   Util     D=
emand
> > bytes   bytes    secs            #      #   10^6bits/sec % SU     u=
s/KB
> >=20
> > 114688    1472   30.00     2438265      0      957.1     18.09    3=
=2E159=20
> > 109568           30.00     2389980             938.1     -1.00    -=
1.000
> >=20
> > On 2.6.35-rc1 netpref sends~7Gbits/s.
> > Curiously it only consumes 50% CPU, I would expect this to be CPU b=
ound.
> >=20
> > # netperf -c -4 -t UDP_STREAM -H 172.17.50.253 -l 30 -- -m 1472
> > UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET =
to
> > 172.17.50.253 (172.17.50.253) port 0 AF_INET
> > Socket  Message  Elapsed      Messages                   CPU      S=
ervice
> > Size    Size     Time         Okay Errors   Throughput   Util     D=
emand
> > bytes   bytes    secs            #      #   10^6bits/sec % SU     u=
s/KB
> >=20
> > 116736    1472   30.00     18064360      0     7090.8     50.62    =
8.665=20
> > 109568           30.00     2438090             957.0     -1.00    -=
1.000
> >=20
> > In this case the bonding device has a single gitabit slave device
> > and is running in balance-rr mode. I have observed similar results
> > with two and three slave devices.
> >=20
> > I have bisected the problem and the offending commit appears to be
> > "net: Introduce skb_orphan_try()". My tired eyes tell me that chang=
e
> > frees skb's earlier than they otherwise would be unless tx timestam=
ping
> > is in effect. That does seem to make sense in relation to this prob=
lem,
> > though I am yet to dig into specifically why bonding is adversely a=
ffected.
> >=20
>=20
> I assume you meant "bonding: flow control regression", ie this is not
> related to bridging ?

Yes, sorry about that. I meant bonding not bridging.

> One problem on bonding is that the xmit() method always returns
> NETDEV_TX_OK.
>=20
> So a flooder cannot know some of its frames were lost.
>=20
> So yes, the patch you mention has the effect of allowing UDP to flood
> bonding device, since we orphan skb before giving it to device (bond =
or
> ethX)
>=20
> With a normal device (with a qdisc), we queue skb, and orphan it only
> when leaving queue. With a not too big socket send buffer, it slows d=
own
> the sender enough to "send UDP frames at line rate only"

Thanks for the explanation.
I'm not entirely sure how much of a problem this is in practice.
