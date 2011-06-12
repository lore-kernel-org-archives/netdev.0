From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Question about LRO/GRO and TCP acknowledgements
Date: Sun, 12 Jun 2011 12:48:18 +0200
Message-ID: <1307875698.2872.130.camel@edumazet-laptop>
References: <20110611215919.5fc29c27@konijn>
	 <1307850224.22348.626.camel@localhost> <20110612095131.6d924082@konijn>
	 <1307869632.2872.106.camel@edumazet-laptop>
	 <20110612113004.79f48f40@konijn>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Joris van Rantwijk <joris@jorisvr.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35134 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753004Ab1FLKs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2011 06:48:26 -0400
Received: by wya21 with SMTP id 21so2657501wya.19
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2011 03:48:25 -0700 (PDT)
In-Reply-To: <20110612113004.79f48f40@konijn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 12 juin 2011 =C3=A0 11:30 +0200, Joris van Rantwijk a =C3=A9=
crit :
> On 2011-06-12, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > As far as I can see, current code will send just one ACK per
> > > coalesced GRO bundle, while the sender expects one ACK per two
> > > segments.
>=20
> > One ACK carries an implicit ack for _all_ previous segments. If sen=
der
> > only 'counts' ACKs, it is a bit dumb...
>=20
> It may be dumb, but it's what the RFCs recommend and it's what Linux
> implements.
>=20
> RFC 5681:
>   "During slow start, a TCP increments cwnd by at most SMSS bytes for
>    each ACK received that cumulatively acknowledges new data."
>=20

Note also RFC says:

The RECOMMENDED way to increase cwnd during congestion avoidance is
   to count the number of bytes that have been acknowledged by ACKs for
   new data.=20

So your concern is more a Sender side implementation missing this
recommendation, not GRO per se...

GRO kicks when receiver receives a train of consecutive frames in his
NAPI run. In order to really reduce number of ACKS, you need to receive
3 frames in a very short time.

This leads to the RTT rule : "Note that during congestion avoidance,
cwnd MUST NOT be increased by more than SMSS bytes per RTT"

So GRO, lowering number of ACKS, can help sender to not waste its time
on extra ACKS.


