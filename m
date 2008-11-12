From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] ssb: Fix DMA-API compilation for non-PCI systems
Date: Tue, 11 Nov 2008 16:26:35 -0800
Message-ID: <20081111162635.0c62033d.akpm@linux-foundation.org>
References: <200811062149.21841.mb@bu3sch.de>
	<8bd0f97a0811061316u6b9a330dy279cb7dca679ab73@mail.gmail.com>
	<200811062223.09400.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: vapier.adi@gmail.com, linville@tuxdriver.com, vapier@gentoo.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51050 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754715AbYKLAfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2008 19:35:39 -0500
In-Reply-To: <200811062223.09400.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 6 Nov 2008 22:23:09 +0100
Michael Buesch <mb@bu3sch.de> wrote:

> On Thursday 06 November 2008 22:16:00 Mike Frysinger wrote:
> > On Thu, Nov 6, 2008 at 15:49, Michael Buesch wrote:
> > > --- wireless-testing.orig/include/linux/ssb/ssb.h       2008-08-01 17:26:05.000000000 +0200
> > > +++ wireless-testing/include/linux/ssb/ssb.h    2008-11-06 21:45:37.000000000 +0100
> > > @@ -427,12 +427,16 @@ static inline int ssb_dma_mapping_error(
> > >  {
> > >        switch (dev->bus->bustype) {
> > >        case SSB_BUSTYPE_PCI:
> > > +#ifdef CONFIG_SSB_PCIHOST
> > >                return pci_dma_mapping_error(dev->bus->host_pci, addr);
> > > +#endif
> > > +               break;
> > >        case SSB_BUSTYPE_SSB:
> > >                return dma_mapping_error(dev->dev, addr);
> > >        default:
> > > -               __ssb_dma_not_implemented(dev);
> > > +               break;
> > >        }
> > 
> > all these functions now read:
> > default: break;
> > seems kind of pointless ... why not just drop that case completely
> 
> Because the compiler complains "not handled all cases...".
> And yes, we do want to trigger __ssb_dma_not_implemented() for
> these cases.

Please always quote the compiler error messages when fixing build
errors.  It is unobvious what the problems are here.  I could struggle
away and create a CONFIG_PCI=n build, but what .c file do I need to
compile?  Dunno.


All those ifdefs are nasty.  Couldn't we do something like:

#ifdef CONFIG_SSB_PCIHOST
static inline int
ssb_pci_dma_mapping_error(structy pci_dev *host_pci, dma_addr_t addr)
{
	return pci_dma_mapping_error(host_pci, addr);
}

#else

static inline int
ssb_pci_dma_mapping_error(structy pci_dev *host_pci, dma_addr_t addr)
{
	return -ENOSYS;
}

#endif

(etc)

and then leave the __ssb_dma_not_implemented() calls under the default:
case in the switch statements?

