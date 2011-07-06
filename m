From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison
 overwritten
Date: Wed, 06 Jul 2011 18:00:19 +0200
Message-ID: <1309968019.2292.44.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1309882352.2271.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110705164202.GD2959@hmsreliant.think-freely.org>
	 <1309884441.2271.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110705180650.GF2959@hmsreliant.think-freely.org>
	 <1309889634.2545.2.camel@edumazet-laptop>
	 <1309890775.2545.17.camel@edumazet-laptop>
	 <1309891516.2545.23.camel@edumazet-laptop>
	 <20110705195353.GG2959@hmsreliant.think-freely.org>
	 <1309896147.2545.28.camel@edumazet-laptop>
	 <1309896940.2545.34.camel@edumazet-laptop>
	 <20110705220644.GB12118@hmsreliant.think-freely.org>
	 <20110706173243.404d8599@maggie>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Alexey Zaytsev <alexey.zaytsev@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Pekka Pietikainen <pp@ee.oulu.fi>,
	Florian Schirmer <jolt@tuxbox.org>,
	Felix Fietkau <nbd@openwrt.org>, Michael Buesch <mb@bu3sch.de>
To: Michael =?ISO-8859-1?Q?B=FCsch?= <m@bues.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63356 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754536Ab1GFQAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 12:00:33 -0400
Received: by wyg8 with SMTP id 8so52347wyg.19
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2011 09:00:32 -0700 (PDT)
In-Reply-To: <20110706173243.404d8599@maggie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 06 juillet 2011 =C3=A0 17:32 +0200, Michael B=C3=BCsch a =C3=
=A9crit :

> You guys are mixing up quite a bit of stuff here...
>=20
> The EOT bit has _nothing_ to do with the descriptor pointers.
> It simply marks the last descriptor in the (linear) descriptor
> page, so that it becomes an actual ring:
>=20
>    DDDDDDDDDDDDDDDDDDDDDDDDDDDE
>    |                          O
>    |                          T
>    ^--------------------------|
>=20
> It doesn't say anything about the read and write pointers
> to the ring.
>=20
> The B44_DMARX_PTR is the write-end pointer. It points one entry
> beyond the end of the write area. Then there's the software pointer
> where we keep track of the read position.
>=20
>    -rx_cons     DMARX_PTR-
>    v                     v
>    DDDDDDDDDDDDDDDDDDDDDDDDDDE
>    ^                    ^    O
>    |                    |    T
>    Device might write from
>    here to here.
>=20
> On an RX interrupt (or poll), we read the _actual_ device write
> pointer. (B44_DMARX_STAT & DMARX_STAT_CDMASK). If that is equal
> to our stored rx_cons, the device didn't write anything.
> So we read buffers until we hit the _actual_ device write pointer.
> So rx_cons is equal to (B44_DMARX_STAT & DMARX_STAT_CDMASK), except
> that it lags behind by one IRQ/poll.
> If we read are done, we set the DMARX_PTR write pointer to one desc
> beyond the buffer that we just ate. So the device is free to continue
> writing the ring _up to_ the position we left.

Not exactly :

If we read one skb at descriptor 0, we prepare a new buffer on slot 200=
,
and advance DMARX_PTR to 201*sizeof(descriptor).

>=20
> I don't know why b44 sets the DMARX_PTR to 200 initially (which is 40
> descriptors, as this is a byte pointer). This seems kind of arbitrary=
=2E
> In b43 we set it to (NR_OF_DESCRIPTORS - 1) * sizeof(descriptor).
> But I don't think it really matters. It only limits the usable DMA
> area before the first interrupt (or poll) occurs. After the final
> B44_DMARX_PTR write in b44_rx(), the full descriptor range (well, min=
us one)
> will be usable.

Yes, this is probably a small bug, we should fix it for correctness.

>=20
> Summary: I don't see where the DMA engine code is broken (except for
> the minor missing wmb(), which doesn't trigger this memory corruption=
, though)
>=20
> I hope that helps to clear up stuff...

Well, you describe (nicely, thanks !) your understanding of how work th=
e
driver and chip.

Problem is we suspect a wrong statement or wrong hardware ;)

Another problem is Alexey doesnt answer anymore, and I dont have this
(old) hardware...

Other point : Do you know why b44_get_ringparam() doesnt  set
ering->tx_max_pending and ering->tx_pending

The comment seems wrong :
/* XXX ethtool lacks a tx_max_pending, oops... */



