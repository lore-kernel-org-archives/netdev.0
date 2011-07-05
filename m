From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison
 overwritten
Date: Tue, 05 Jul 2011 20:32:55 +0200
Message-ID: <1309890775.2545.17.camel@edumazet-laptop>
References: <1309840708.2720.31.camel@edumazet-laptop>
	 <CAB9v_DFM8PcujUB-YzcK49DS7T6Bz2FLDtkVdEYt8an1oPYVFw@mail.gmail.com>
	 <1309842642.2720.36.camel@edumazet-laptop>
	 <CAB9v_DEiPFzQt-TgeVC3r3Y7YFwApLK_NHkDahFOKpibtABrZg@mail.gmail.com>
	 <1309844009.2720.39.camel@edumazet-laptop>
	 <1309845573.2720.41.camel@edumazet-laptop>
	 <20110705160531.GC2959@hmsreliant.think-freely.org>
	 <1309882352.2271.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110705164202.GD2959@hmsreliant.think-freely.org>
	 <1309884441.2271.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110705180650.GF2959@hmsreliant.think-freely.org>
	 <1309889634.2545.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Zaytsev <alexey.zaytsev@gmail.com>,
	Michael =?ISO-8859-1?Q?B=FCsch?= <m@bues.ch>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Pekka Pietikainen <pp@ee.oulu.fi>,
	Florian Schirmer <jolt@tuxbox.org>,
	Felix Fietkau <nbd@openwrt.org>, Michael Buesch <mb@bu3sch.de>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36561 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752239Ab1GESdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 14:33:01 -0400
Received: by wwe5 with SMTP id 5so6210585wwe.1
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 11:32:59 -0700 (PDT)
In-Reply-To: <1309889634.2545.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 05 juillet 2011 =C3=A0 20:13 +0200, Eric Dumazet a =C3=A9crit =
:
> Le mardi 05 juillet 2011 =C3=A0 14:06 -0400, Neil Horman a =C3=A9crit=
 :
> > On Tue, Jul 05, 2011 at 06:47:21PM +0200, Eric Dumazet wrote:
> > > Le mardi 05 juillet 2011 =C3=A0 12:42 -0400, Neil Horman a =C3=A9=
crit :
> > > > On Tue, Jul 05, 2011 at 06:12:32PM +0200, Eric Dumazet wrote:
> > >=20
> > > > > So all descriptors before prod are guaranteed to be ready for=
 host
> > > > > consume... Fact that a dma access is running on 'next descrip=
tor' should
> > > > > be irrelevant.
> > > > >=20
> > > > But we handle more than one descriptor per b44_rx call - theres=
 a while loop in
> > > > there where we do advance to the next descriptor.
> > >=20
> > > Yes, but we advance up to 'prod', which is the very last safe
> > > descriptor.
> > >=20
> > > If hardware advertises descriptor X being ready to be handled by =
host,
> > > while DMA on this X descriptor is not yet finished, this would be=
 a
> > > really useless hardware ;)
> > >=20
> > >=20
> > >=20
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe netdev"=
 in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.htm=
l
> > >=20
> >=20
> >=20
> > Something else just jumped out at me.  During b44_open, we call b44=
_init_rings.
> > This function allocates bp->rx_pending skb's and iteratively puts t=
hem in the rx
> > dma ring. bp->rx_pending is initalized to B44_DEF_RX_RING_PENDING, =
which is
> > defined as 200 (just about half of the 512 entries that the dma rin=
g actually
> > supports in the hardware.  This is normally ok, as subsequent calls=
 to
> > b44_alloc_rx_skb will fill in entries in the ring as those skbs are=
 consumed.
> > The problem with this however is that b44_alloc_rx_skb only sets th=
e
> > DESC_CTRL_EOT bit in the descriptor of the 512th entry, indicating =
that the
> > hardware should wrap around and reset the index counter.  If a larg=
e volume of
> > traffic is pushed through the adapter early on after initalization,=
 or if the
> > cpu is busy during init, it would be possible that the ring buffer =
would fill up
> > prior to having additional entries added to the ring, the result be=
ing that the
> > dma engine would reach the end of the allocated descriptors, not se=
e an EOT bit
> > set, and continue on using unallocated descriptors.
> >=20
> > Just a theory, but it would be interesting to see if the problem su=
bsided if you
> > ensured that you allocated  a full descriptor ring on b44_open
> > Neil
> > =20
> > diff --git a/drivers/net/b44.c b/drivers/net/b44.c
> > index 3d247f3..1b58a7c 100644
> > --- a/drivers/net/b44.c
> > +++ b/drivers/net/b44.c
> > @@ -57,7 +57,7 @@
> >  #define B44_MAX_MTU			1500
> > =20
> >  #define B44_RX_RING_SIZE		512
> > -#define B44_DEF_RX_RING_PENDING		200
> > +#define B44_DEF_RX_RING_PENDING		512
> >  #define B44_RX_RING_BYTES	(sizeof(struct dma_desc) * \
> >  				 B44_RX_RING_SIZE)
> >  #define B44_TX_RING_SIZE		512
>=20
> No
>=20
> Please take time to read the driver again.
>=20
> 200 desc are setup, and NIC is not allowed to use more than 200 descs=
=2E
>=20
> ( B44_DMARX_PTR )
>=20
> We carefuly advance this pointer after a new desc(s) is(are) setup
>=20
>=20

Then, maybe the driver model is completely wrong, and should really
setup 512 buffers, or use less descs but set EOT on last one.

Currently it uses a 200 sliding window out of the 512 descs.



