From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: 8139cp: set ring address before enabling receiver
Date: Wed, 21 Nov 2012 21:10:38 +0000
Message-ID: <1353532238.2619.46.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120602235020.2C0A57C006C@ra.kernel.org>
	 <1353517042.26346.130.camel@shinybook.infradead.org>
	 <50AD1972.5080403@pobox.com>
	 <1353527481.26346.150.camel@shinybook.infradead.org>
	 <1353529135.2619.36.camel@bwh-desktop.uk.solarflarecom.com>
	 <50AD3C51.9070105@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Woodhouse <dwmw2@infradead.org>,
	Jason Wang <jasowang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [12.187.104.25] ([12.187.104.25]:22171 "EHLO
	webmail.solarflare.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S964850Ab2KUVLC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 16:11:02 -0500
In-Reply-To: <50AD3C51.9070105@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-11-21 at 15:40 -0500, Jeff Garzik wrote:
> On 11/21/2012 03:18 PM, Ben Hutchings wrote:
> > On Wed, 2012-11-21 at 19:51 +0000, David Woodhouse wrote:
> >> On Wed, 2012-11-21 at 13:12 -0500, Jeff Garzik wrote:
> >>>
> >>> What sticks out at me from the commit message?
> >>>
> >>> It was not tested on the famously quirky 8139 hardware at all.
> >>>
> >>> While I have not looked at the 8139C+ data sheet in a while, some=
times
> >>> the hardware _did_ have a strange init order.
> >>>
> >>> As this works in a simulator but fails on real hardware, it seems=
 like
> >>> an obvious regression caused by an untested [on read hardware] pa=
tch.
> >>
> >> The data sheet (v1.6, from http://realtek.info/pdf/rtl8139cp.pdf )=
 says
> >> in =C2=A76.33 (C+ Command Register):
> >>   "Enable C+ mode functions in C+CR register first,
> >>   =3D> Enable transmit/receive in Command register (offset 37h),
> >>   =3D> Configure other related registers (ex. Descriptor start add=
ress,
> >>      TCR, RCR, ...)."
> >>
> >> I understand the concern expressed in the offending commit message=
 about
> >> DMA happening to invalid addresses, and I'll look at the data shee=
t
> >> harder to see when the DMA actually starts happening. But it defin=
itely
> >> seems that our current code isn't doing what the data sheet says.
> >>
> >> I wonder if I can find one of these lying around and stick it in a
> >> machine with an IOMMU...
> >
> > You might be able to avoid disaster by doing:
> >
> > 1. Set MAC filter to drop everything
> > 2. Enable RX DMA
> > 3. Set RX DMA ring address
> > 4. Set MAC filter according to current flags & multicast list
> >
> > I'm assuming, knowing nothing about this particular hardware, that =
the
> > MAC filter register(s) will accept writes before RX DMA is enabled.
>=20
> A larger point is that the commit was created to avoid imagined disas=
ter=20
> on simulated hardware...
>
>   ...and wound up creating behavior that is (a) contra to the data sh=
eet=20
> and (b) breaks real hardware.

I wasn't suggesting anyone should change this again without testing on
real hardware.  But the 'imagined disaster' seems to be an obvious and
real race condition, which the driver is just more likely to win when
racing real hardware than when racing virtual hardware.

(It could be that the hardware pre-fetches DMA descriptors, in which
case this is a 'how did that ever work?' bug.  Alternately, there could
be a hidden enable bit that doesn't get set until the RX DMA ring
address is written, in which case the driver may need a quirk for
emulations that lack that.  An IOMMU should be able to answer these
questions.)

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
