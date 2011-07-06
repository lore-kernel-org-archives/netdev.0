From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison
 overwritten
Date: Wed, 6 Jul 2011 17:32:43 +0200
Message-ID: <20110706173243.404d8599@maggie>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexey Zaytsev <alexey.zaytsev@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Pekka Pietikainen <pp@ee.oulu.fi>,
	Florian Schirmer <jolt@tuxbox.org>,
	Felix Fietkau <nbd@openwrt.org>, Michael Buesch <mb@bu3sch.de>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bues.ch ([80.190.117.144]:41472 "EHLO bues.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753910Ab1GFPc7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 11:32:59 -0400
In-Reply-To: <20110705220644.GB12118@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 5 Jul 2011 18:06:44 -0400
Neil Horman <nhorman@tuxdriver.com> wrote:

> On Tue, Jul 05, 2011 at 10:15:40PM +0200, Eric Dumazet wrote:
> > Le mardi 05 juillet 2011 =C3=A0 22:02 +0200, Eric Dumazet a =C3=A9c=
rit :
> > > Le mardi 05 juillet 2011 =C3=A0 15:53 -0400, Neil Horman a =C3=A9=
crit :
> > > > I think this is a goo idea, at least for testing.  It seems odd=
 to me that we
> > > > have the B44_DMARX_PTR value which indicates (ostensibly) the p=
ointer to the
> > > > descriptor to be processed next (the documentation isnt' very v=
erbose on the
> > > > subject), along with the EOT bit on a descriptor.  It seems lik=
e both the
> > > > register and the bit are capable of conveying the same (or at l=
east overlapping)
> > > > information.
> > > >=20
> > > > I think what I'm having the most trouble with is understanding =
when the hw looks
> > > > at the EOT bit in the descriptor.  If it completes a DMA and se=
es the EOT bit
> > > > set, does the next DMA occur to the descriptor pointed to by th=
e DMARX_ADDR
> > > > register?  Of does it stall until such time as the DMARX_PTR re=
gister is rotated
> > > > around?  What if it doesn't see the EOT bit set?  Does it just =
keep going with
> > > > the next descriptor? =20
> >=20
> > Since there is no OWN bit (at least not on the online doc I got : i=
t
> > says the rx_ring is read only by the NIC), I would say we really ne=
ed to
> > advance DMARX_PTR to signal NIC a new entry is available for follow=
ing
> > incoming frames.
> >=20
> > This is the reason rx_pending max value is B44_RX_RING_SIZE - 1, or=
 else
> > chip could loop on a circular rx_ring.
> >=20
> Agree, although that still leaves open the question of what exactly s=
hould get
> written into the DMARX_PTR.  Is it an index of the descriptor number,=
 or a byte
> offset.
>=20
> Regardless, I think we ned to fix up the looping so as to prevent an =
EOT reset
> jumping outside of our valid ring window.  Alexey, theres better ways=
 to do
> this, but if in the interim, you could please try this patch, it make=
s the valid
> receive window for b44 cover the entire ring, so as to avoid this pro=
blem.  It
> will at least help support or refute this theory.  Note its not exact=
ly the same
> as my previous patch.  If you set the default ring pending to 512, th=
e math in
> the b44_alloc_rx_skb path is wrong, we skip the EOT bit as well as th=
e first
> entry in the ring.  At 511 it should work out properly.
>=20
> Thanks
> Neil
>=20
>=20
> diff --git a/drivers/net/b44.c b/drivers/net/b44.c
> index 3d247f3..b7f5ed1 100644
> --- a/drivers/net/b44.c
> +++ b/drivers/net/b44.c
> @@ -57,7 +57,7 @@
>  #define B44_MAX_MTU			1500
> =20
>  #define B44_RX_RING_SIZE		512
> -#define B44_DEF_RX_RING_PENDING		200
> +#define B44_DEF_RX_RING_PENDING		511
>  #define B44_RX_RING_BYTES	(sizeof(struct dma_desc) * \
>  				 B44_RX_RING_SIZE)
>  #define B44_TX_RING_SIZE		512

You guys are mixing up quite a bit of stuff here...

The EOT bit has _nothing_ to do with the descriptor pointers.
It simply marks the last descriptor in the (linear) descriptor
page, so that it becomes an actual ring:

   DDDDDDDDDDDDDDDDDDDDDDDDDDDE
   |                          O
   |                          T
   ^--------------------------|

It doesn't say anything about the read and write pointers
to the ring.

The B44_DMARX_PTR is the write-end pointer. It points one entry
beyond the end of the write area. Then there's the software pointer
where we keep track of the read position.

   -rx_cons     DMARX_PTR-
   v                     v
   DDDDDDDDDDDDDDDDDDDDDDDDDDE
   ^                    ^    O
   |                    |    T
   Device might write from
   here to here.

On an RX interrupt (or poll), we read the _actual_ device write
pointer. (B44_DMARX_STAT & DMARX_STAT_CDMASK). If that is equal
to our stored rx_cons, the device didn't write anything.
So we read buffers until we hit the _actual_ device write pointer.
So rx_cons is equal to (B44_DMARX_STAT & DMARX_STAT_CDMASK), except
that it lags behind by one IRQ/poll.
If we read are done, we set the DMARX_PTR write pointer to one desc
beyond the buffer that we just ate. So the device is free to continue
writing the ring _up to_ the position we left.

I don't know why b44 sets the DMARX_PTR to 200 initially (which is 40
descriptors, as this is a byte pointer). This seems kind of arbitrary.
In b43 we set it to (NR_OF_DESCRIPTORS - 1) * sizeof(descriptor).
But I don't think it really matters. It only limits the usable DMA
area before the first interrupt (or poll) occurs. After the final
B44_DMARX_PTR write in b44_rx(), the full descriptor range (well, minus=
 one)
will be usable.

Summary: I don't see where the DMA engine code is broken (except for
the minor missing wmb(), which doesn't trigger this memory corruption, =
though)

I hope that helps to clear up stuff...
