From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison overwritten
Date: Tue, 5 Jul 2011 18:06:44 -0400
Message-ID: <20110705220644.GB12118@hmsreliant.think-freely.org>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Zaytsev <alexey.zaytsev@gmail.com>,
	Michael =?iso-8859-1?Q?B=FCsch?= <m@bues.ch>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Pekka Pietikainen <pp@ee.oulu.fi>,
	Florian Schirmer <jolt@tuxbox.org>,
	Felix Fietkau <nbd@openwrt.org>, Michael Buesch <mb@bu3sch.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34073 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751608Ab1GEWHB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 18:07:01 -0400
Content-Disposition: inline
In-Reply-To: <1309896940.2545.34.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 05, 2011 at 10:15:40PM +0200, Eric Dumazet wrote:
> Le mardi 05 juillet 2011 =E0 22:02 +0200, Eric Dumazet a =E9crit :
> > Le mardi 05 juillet 2011 =E0 15:53 -0400, Neil Horman a =E9crit :
> > > I think this is a goo idea, at least for testing.  It seems odd t=
o me that we
> > > have the B44_DMARX_PTR value which indicates (ostensibly) the poi=
nter to the
> > > descriptor to be processed next (the documentation isnt' very ver=
bose on the
> > > subject), along with the EOT bit on a descriptor.  It seems like =
both the
> > > register and the bit are capable of conveying the same (or at lea=
st overlapping)
> > > information.
> > >=20
> > > I think what I'm having the most trouble with is understanding wh=
en the hw looks
> > > at the EOT bit in the descriptor.  If it completes a DMA and sees=
 the EOT bit
> > > set, does the next DMA occur to the descriptor pointed to by the =
DMARX_ADDR
> > > register?  Of does it stall until such time as the DMARX_PTR regi=
ster is rotated
> > > around?  What if it doesn't see the EOT bit set?  Does it just ke=
ep going with
> > > the next descriptor? =20
>=20
> Since there is no OWN bit (at least not on the online doc I got : it
> says the rx_ring is read only by the NIC), I would say we really need=
 to
> advance DMARX_PTR to signal NIC a new entry is available for followin=
g
> incoming frames.
>=20
> This is the reason rx_pending max value is B44_RX_RING_SIZE - 1, or e=
lse
> chip could loop on a circular rx_ring.
>=20
Agree, although that still leaves open the question of what exactly sho=
uld get
written into the DMARX_PTR.  Is it an index of the descriptor number, o=
r a byte
offset.

Regardless, I think we ned to fix up the looping so as to prevent an EO=
T reset
jumping outside of our valid ring window.  Alexey, theres better ways t=
o do
this, but if in the interim, you could please try this patch, it makes =
the valid
receive window for b44 cover the entire ring, so as to avoid this probl=
em.  It
will at least help support or refute this theory.  Note its not exactly=
 the same
as my previous patch.  If you set the default ring pending to 512, the =
math in
the b44_alloc_rx_skb path is wrong, we skip the EOT bit as well as the =
first
entry in the ring.  At 511 it should work out properly.

Thanks
Neil


diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 3d247f3..b7f5ed1 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -57,7 +57,7 @@
 #define B44_MAX_MTU			1500
=20
 #define B44_RX_RING_SIZE		512
-#define B44_DEF_RX_RING_PENDING		200
+#define B44_DEF_RX_RING_PENDING		511
 #define B44_RX_RING_BYTES	(sizeof(struct dma_desc) * \
 				 B44_RX_RING_SIZE)
 #define B44_TX_RING_SIZE		512
>=20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
