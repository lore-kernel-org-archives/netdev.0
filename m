From: Joris van Rantwijk <joris@jorisvr.nl>
Subject: Re: Question about LRO/GRO and TCP acknowledgements
Date: Sun, 12 Jun 2011 13:24:28 +0200
Message-ID: <20110612132428.3e1a4593@konijn>
References: <20110611215919.5fc29c27@konijn>
	<1307850224.22348.626.camel@localhost>
	<20110612095131.6d924082@konijn>
	<1307869632.2872.106.camel@edumazet-laptop>
	<20110612113004.79f48f40@konijn>
	<1307875698.2872.130.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-vbr1.xs4all.nl ([194.109.24.21]:1274 "EHLO
	smtp-vbr1.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751692Ab1FLLYe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2011 07:24:34 -0400
In-Reply-To: <1307875698.2872.130.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2011-06-12, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Le dimanche 12 juin 2011 =C3=A0 11:30 +0200, Joris van Rantwijk a =C3=
=A9crit :
> > > > As far as I can see, current code will send just one ACK per
> > > > coalesced GRO bundle, while the sender expects one ACK per two
> > > > segments.

> Note also RFC says:
> The RECOMMENDED way to increase cwnd during congestion avoidance is
>    to count the number of bytes that have been acknowledged by ACKs
> for new data.=20

This is during the congestion avoidance phase. I'm actually more
concerned about the slow start phase, but congestion avoidance may also
be an issue.

By the way, Linux does not implement the recommended (byte-counting)
method by default. It can be enabled through sysctl tcp_abc, which is
off by default.

Also:
  Byte counting during congestion avoidance is also recommended,
  while the method from [RFC2581] and other safe methods are still
  allowed.

> So your concern is more a Sender side implementation missing this
> recommendation, not GRO per se...

Not really. The same RFC says:
  Specifically, an ACK SHOULD be generated for at least every
  second full-sized segment, ...

Sender side behaviour is just my argument for the practical importance
of this issue. But sender side arguments are not an excuse for the
receiver to deviate from its own recommended behaviour.

> GRO kicks when receiver receives a train of consecutive frames in his
> NAPI run. In order to really reduce number of ACKS, you need to
> receive 3 frames in a very short time.
>=20
> This leads to the RTT rule : "Note that during congestion avoidance,
> cwnd MUST NOT be increased by more than SMSS bytes per RTT"

But this RTT rule is already taken into account in the code which
increases cwnd during congestion avoidance. This code _assumes_ that
the receiver sends one ACK per two segments. If the receiver sends
fewer ACKs, the congestion window will grow too slowly.

> So GRO, lowering number of ACKS, can help sender to not waste its tim=
e
> on extra ACKS.

I can see how the world may have been a better place if every sender
implemented Appropriate Byte Counting and TCP receivers were allowed to
send fewer ACKs. However, current reality is that ABC is optional,
disabled by default in Linux, and receivers are recommended to send one
ACK per two segments.

I suspect that GRO currently hurts throughput of isolated TCP
connections. This is based on a purely theoretic argument. I may be
wrong and I have absolutely no data to confirm my suspicion.

If you can point out the flaw in my reasoning, I would be greatly
relieved. Until then, I remain concerned that there may be something
wrong with GRO and TCP ACKs.

Joris.
