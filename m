From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6 v3] net_sched: SFB flow scheduler
Date: Wed, 23 Feb 2011 18:16:08 +0100
Message-ID: <1298481368.3301.390.camel@edumazet-laptop>
References: <20110221160306.GA9650@tuxdriver.com>
	 <1298308283.2849.5.camel@edumazet-laptop>
	 <1298390536.2861.9.camel@edumazet-laptop>
	 <1298474091.3301.364.camel@edumazet-laptop>  <4D6534C3.1080305@trash.net>
	 <1298479711.3301.373.camel@edumazet-laptop>  <4D653C9C.8010205@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>,
	"John W. Linville" <linville@tuxdriver.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f51.google.com ([209.85.214.51]:42216 "EHLO
	mail-bw0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932381Ab1BWRQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 12:16:13 -0500
Received: by bwz10 with SMTP id 10so344839bwz.10
        for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 09:16:11 -0800 (PST)
In-Reply-To: <4D653C9C.8010205@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 23 f=C3=A9vrier 2011 =C3=A0 17:58 +0100, Patrick McHardy a =
=C3=A9crit :
> Am 23.02.2011 17:48, schrieb Eric Dumazet:
> > Le mercredi 23 f=C3=A9vrier 2011 =C3=A0 17:24 +0100, Patrick McHard=
y a =C3=A9crit :
> >=20
> >> This needs to be a per-skb property, otherwise you could have the
> >> situation:
> >>
> >> - enqueue skb, double_buffering=3D0, increment buffer 0
> >> - enable double buffering
> >> - swap buffers
> >> - dequeue same skb, decrement buffer 1
> >>
> >> after which the qlen values of buffer 1 will be incorrect.
> >>
> >=20
> > Normally its OK, because we bzero() the zone, and the "decrement" i=
s
> > 0-bounded.
>=20
> Yeah, but we might decrement buckets of different flows which
> are non-zero. Probably not too bad, but still not correct.
>=20
> > I had this idea (of storing two bits per skb), but :
> >=20
> > - It means that swap_buffer() should not touch (bzero) the 'old' bi=
ns
>=20
> Yes, it means we have to properly decrement the old buffer
> until all bins reached zero.
>=20
> > - Since hash perturbator is changed, we have to store the two hash
> > values per skb (instead of one u32 / classid).
>=20
> Indeed.

BTQ, I had this idea of storing the double_buffer per skb reading SFB
paper, because paper says the double buffering is really needed only fo=
r
unelastic flows, not for all packets.

paper quote :

As one set of bins is being used
for queue management, a second set of bins using the next set of hash
functions can be warmed up. In this
case, any time a flow is classified as non-responsive, it is hashed
using the second set of hash functions and
the marking probabilities of the corresponding bins in the warmup set
are updated.

So using two 'hash' values per skb is the way to go, with special 0
value meanings : skb was not 'inserted' into virtual queues.



