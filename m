From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison
 overwritten
Date: Tue, 05 Jul 2011 18:12:32 +0200
Message-ID: <1309882352.2271.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1309839258.2720.17.camel@edumazet-laptop>
	 <CAB9v_DGSFAG9V0jqem+tDP3G-N8v6Z+_6oKdPwL-ZwhfhCOZnw@mail.gmail.com>
	 <1309839928.2720.23.camel@edumazet-laptop>
	 <CAB9v_DEOhZh37aqx1qrLnrz5+tqjcjgBx-DP6M_0NkygZ1LjcQ@mail.gmail.com>
	 <1309840708.2720.31.camel@edumazet-laptop>
	 <CAB9v_DFM8PcujUB-YzcK49DS7T6Bz2FLDtkVdEYt8an1oPYVFw@mail.gmail.com>
	 <1309842642.2720.36.camel@edumazet-laptop>
	 <CAB9v_DEiPFzQt-TgeVC3r3Y7YFwApLK_NHkDahFOKpibtABrZg@mail.gmail.com>
	 <1309844009.2720.39.camel@edumazet-laptop>
	 <1309845573.2720.41.camel@edumazet-laptop>
	 <20110705160531.GC2959@hmsreliant.think-freely.org>
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
Received: from mail-ww0-f42.google.com ([74.125.82.42]:42630 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754803Ab1GEQMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 12:12:46 -0400
Received: by wwg11 with SMTP id 11so2416694wwg.1
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 09:12:45 -0700 (PDT)
In-Reply-To: <20110705160531.GC2959@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 05 juillet 2011 =C3=A0 12:05 -0400, Neil Horman a =C3=A9crit :
> On Tue, Jul 05, 2011 at 07:59:33AM +0200, Eric Dumazet wrote:
> > Le mardi 05 juillet 2011 =C3=A0 07:33 +0200, Eric Dumazet a =C3=A9c=
rit :
> > > Le mardi 05 juillet 2011 =C3=A0 09:18 +0400, Alexey Zaytsev a =C3=
=A9crit :
> > >=20
> > > > Actually, I've added a trace to show b44_init_rings and b44_fre=
e_rings
> > > > calls, and they are only called once, right after the driver is
> > > > loaded. So it can't be related to START_RFO. Will attach the di=
ff and
> > > > dmesg.
> > >=20
> > > Thanks
> > >=20
> > > I was wondering if DMA could be faster if providing word aligned
> > > addresses, could you try :
> > >=20
> > > -#define RX_PKT_OFFSET          (RX_HEADER_LEN + 2)
> > > +#define RX_PKT_OFFSET          (RX_HEADER_LEN + NET_IP_ALIGN)
> > >=20
> > > (On x86, we now have NET_IP_ALIGN =3D 0 since commit ea812ca1)
> > >=20
> >=20
> > I suspect a hardware bug.
> >=20
> I'm not sure if this helps, but I've been reading over this bug, and =
it seems
> that the rx path never checks the status of a buffers rx header prior=
 to
> unmapping it or otherwise modifying it in hardware.  If we were to st=
art munging
> pointers in the rx channel while a dma was active in it still, it sem=
s like the
> observed corruption might be the result.  The docs aren't super clear=
 on this,
> but I think a descriptor needs to be in the idle wait or stopped stat=
e prior to
> being acessed.  This patch might help out there (although I don't hav=
e hardware
> to test)
> Neil
>=20
> diff --git a/drivers/net/b44.c b/drivers/net/b44.c
> index 3d247f3..48540ad 100644
> --- a/drivers/net/b44.c
> +++ b/drivers/net/b44.c
> @@ -769,7 +769,19 @@ static int b44_rx(struct b44 *bp, int budget)
>  		dma_addr_t map =3D rp->mapping;
>  		struct rx_header *rh;
>  		u16 len;
> -
> +		u32 state =3D br32(bp, B44_DMARX_STAT) & DMARX_STAT_SMASK;
> +		state >>=3D 12;
> +
> +		/*
> + 		 * I _think_ descriptors need to be in the idle or stopped state
> + 		 * before its safe to access them.  If the current buffer
> + 		 * pointed to by the dma channel is in state 1 or lower (active
> + 		 * or disabled), then we should just stop receving until the
> + 		 * next interrupt kicks us again (I think)
> + 		 */
> +		if (state < 2)
> +			return;
> +=20
>  		dma_sync_single_for_cpu(bp->sdev->dev, map,
>  					    RX_PKT_BUF_SZ,
>  					    DMA_FROM_DEVICE);

Hmm... We are in a NAPI handler... There wont be a new interrupt.

Plus, we do at start of b44_rx() :

prod  =3D br32(bp, B44_DMARX_STAT) & DMARX_STAT_CDMASK;

So all descriptors before prod are guaranteed to be ready for host
consume... Fact that a dma access is running on 'next descriptor' shoul=
d
be irrelevant.

IMHO Peeking B44_DMARX_STAT for each packet would be a waste of time.



