From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison overwritten
Date: Tue, 5 Jul 2011 12:42:02 -0400
Message-ID: <20110705164202.GD2959@hmsreliant.think-freely.org>
References: <1309839928.2720.23.camel@edumazet-laptop>
 <CAB9v_DEOhZh37aqx1qrLnrz5+tqjcjgBx-DP6M_0NkygZ1LjcQ@mail.gmail.com>
 <1309840708.2720.31.camel@edumazet-laptop>
 <CAB9v_DFM8PcujUB-YzcK49DS7T6Bz2FLDtkVdEYt8an1oPYVFw@mail.gmail.com>
 <1309842642.2720.36.camel@edumazet-laptop>
 <CAB9v_DEiPFzQt-TgeVC3r3Y7YFwApLK_NHkDahFOKpibtABrZg@mail.gmail.com>
 <1309844009.2720.39.camel@edumazet-laptop>
 <1309845573.2720.41.camel@edumazet-laptop>
 <20110705160531.GC2959@hmsreliant.think-freely.org>
 <1309882352.2271.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
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
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44052 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753909Ab1GEQmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 12:42:14 -0400
Content-Disposition: inline
In-Reply-To: <1309882352.2271.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 05, 2011 at 06:12:32PM +0200, Eric Dumazet wrote:
> Le mardi 05 juillet 2011 =E0 12:05 -0400, Neil Horman a =E9crit :
> > On Tue, Jul 05, 2011 at 07:59:33AM +0200, Eric Dumazet wrote:
> > > Le mardi 05 juillet 2011 =E0 07:33 +0200, Eric Dumazet a =E9crit =
:
> > > > Le mardi 05 juillet 2011 =E0 09:18 +0400, Alexey Zaytsev a =E9c=
rit :
> > > >=20
> > > > > Actually, I've added a trace to show b44_init_rings and b44_f=
ree_rings
> > > > > calls, and they are only called once, right after the driver =
is
> > > > > loaded. So it can't be related to START_RFO. Will attach the =
diff and
> > > > > dmesg.
> > > >=20
> > > > Thanks
> > > >=20
> > > > I was wondering if DMA could be faster if providing word aligne=
d
> > > > addresses, could you try :
> > > >=20
> > > > -#define RX_PKT_OFFSET          (RX_HEADER_LEN + 2)
> > > > +#define RX_PKT_OFFSET          (RX_HEADER_LEN + NET_IP_ALIGN)
> > > >=20
> > > > (On x86, we now have NET_IP_ALIGN =3D 0 since commit ea812ca1)
> > > >=20
> > >=20
> > > I suspect a hardware bug.
> > >=20
> > I'm not sure if this helps, but I've been reading over this bug, an=
d it seems
> > that the rx path never checks the status of a buffers rx header pri=
or to
> > unmapping it or otherwise modifying it in hardware.  If we were to =
start munging
> > pointers in the rx channel while a dma was active in it still, it s=
ems like the
> > observed corruption might be the result.  The docs aren't super cle=
ar on this,
> > but I think a descriptor needs to be in the idle wait or stopped st=
ate prior to
> > being acessed.  This patch might help out there (although I don't h=
ave hardware
> > to test)
> > Neil
> >=20
> > diff --git a/drivers/net/b44.c b/drivers/net/b44.c
> > index 3d247f3..48540ad 100644
> > --- a/drivers/net/b44.c
> > +++ b/drivers/net/b44.c
> > @@ -769,7 +769,19 @@ static int b44_rx(struct b44 *bp, int budget)
> >  		dma_addr_t map =3D rp->mapping;
> >  		struct rx_header *rh;
> >  		u16 len;
> > -
> > +		u32 state =3D br32(bp, B44_DMARX_STAT) & DMARX_STAT_SMASK;
> > +		state >>=3D 12;
> > +
> > +		/*
> > + 		 * I _think_ descriptors need to be in the idle or stopped stat=
e
> > + 		 * before its safe to access them.  If the current buffer
> > + 		 * pointed to by the dma channel is in state 1 or lower (active
> > + 		 * or disabled), then we should just stop receving until the
> > + 		 * next interrupt kicks us again (I think)
> > + 		 */
> > +		if (state < 2)
> > +			return;
> > +=20
> >  		dma_sync_single_for_cpu(bp->sdev->dev, map,
> >  					    RX_PKT_BUF_SZ,
> >  					    DMA_FROM_DEVICE);
>=20
> Hmm... We are in a NAPI handler... There wont be a new interrupt.
>=20
Not until we're done with the napi handler, no.  But if we encounter a =
dma
descriptor that isn't idle, then we know that either we're clearing out=
 the ring
(ie. for a shutdown), or we'll get another interrupt when the descripto=
r we
failed on completes.

> Plus, we do at start of b44_rx() :
>=20
> prod  =3D br32(bp, B44_DMARX_STAT) & DMARX_STAT_CDMASK;
>=20
Yes, that just tells us which is the current dma index.  After that we =
loop
through subsequent dma descriptor incrementing the index each time.

> So all descriptors before prod are guaranteed to be ready for host
> consume... Fact that a dma access is running on 'next descriptor' sho=
uld
> be irrelevant.
>=20
But we handle more than one descriptor per b44_rx call - theres a while=
 loop in
there where we do advance to the next descriptor.

> IMHO Peeking B44_DMARX_STAT for each packet would be a waste of time.
>=20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
