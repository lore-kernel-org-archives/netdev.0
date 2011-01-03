From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] net_sched: mark packet staying on queue too long
Date: Mon, 03 Jan 2011 15:02:52 +0100
Message-ID: <1294063372.2892.408.camel@edumazet-laptop>
References: <1292855730-19265-1-git-send-email-xiaosuo@gmail.com>
	 <20101220232020.GB2052@del.dom.local>
	 <1292887689.2627.150.camel@edumazet-laptop>
	 <20101220235209.GA1865@del.dom.local> <1292939574.6535.27.camel@mojatatu>
	 <AANLkTikwMQBwNdT1nZ97NNFYGJnwhk39+8afTKONgeF5@mail.gmail.com>
	 <20101221223704.GA1979@del.dom.local> <1293111333.11306.170.camel@mojatatu>
	 <1294003631.2535.253.camel@edumazet-laptop>
	 <1294062755.2472.11.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50906 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754866Ab1ACODI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 09:03:08 -0500
Received: by wwa36 with SMTP id 36so14159815wwa.1
        for <netdev@vger.kernel.org>; Mon, 03 Jan 2011 06:03:06 -0800 (PST)
In-Reply-To: <1294062755.2472.11.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 03 janvier 2011 =C3=A0 08:52 -0500, jamal a =C3=A9crit :
> On Sun, 2011-01-02 at 22:27 +0100, Eric Dumazet wrote:
> > While playing with SFQ and other AQM, I was bothered to see how eas=
y it
> > was for a single tcp flow to 'fill the pipe' and consume lot of mem=
ory
> > buffers in queues. I know Jesper use more than 50.000 SFQ on his
> > routers, and with GRO packets this can consume a lot of memory.
> >=20
> > I played a bit adding ECN in SFQ, first by marking packets for a
> > particular flow if this flow qlen was above a given threshold, and =
later
> > using another trick : ECN mark packet if it stayed longer than a gi=
ven
> > delay in the queue. This of course could be done on other modules, =
what
> > do you think ?
> >=20
>=20
> I think for this to be effective, it would require maintaining some
> history of the effect (some form of moving window average)
> and probably a randomness in marking instead of a deterministic one.
> Something like what Stochastic Fair RED/BLUE Queueing does.
> Otherwise you get a burst of marked packets then silence then a burst
> etc (i.e the classical synchronization effect).
>=20

I got fairly good results here, but admit-idly on a LAN.

Yep, maybe adding RED on each SFQ slot ;) Should be fairly cheap, and
actually needed in case ECN is not possible and we must earlly drop
instead.

I found BLUE very expensive in term of cache line accesses. Especially
with double hashing.

> It would probably be more effective to provide feedback to the local =
tcp
> since we can detect this locally instead of waiting to some round tri=
p
> (or half roundtrip) effect at the receiver with ECN i.e in the same
> spirit as NET_XMIT_CN but for which local TCP does something useful w=
ith
> that info (instead of "retransmit shortly"). But even that would requ=
ire
> maintaining some state on the scheduler per hash in this case....
>=20

local tcp, for a router ? Hmm... But yes I see your point.

Speaking of ECN marking, it seems we (in RED/GRED or tunnels) change sk=
b
data even if it is shared (can happen on ingress path)

Probably harmless, but tcpdump can show ECN bit being marked even on sk=
b
snapshot before ingress (and later, ECN marked) or tunnels, while it
came unset from the wire.

Is it worth fixing this ? maybe using skb_make_writable() [once moved t=
o
core network from netfilter]



