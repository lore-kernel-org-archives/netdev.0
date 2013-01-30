From: Mikael Pettersson <mikpe@it.uu.se>
Subject: Re: ixp4xx eth broken in 3.7.0/3.8-rc5?
Date: Wed, 30 Jan 2013 21:50:13 +0100
Message-ID: <20745.34693.504730.621596@pilspetsen.it.uu.se>
References: <20744.9777.937924.822371@pilspetsen.it.uu.se>
	<20744.25884.660535.514911@pilspetsen.it.uu.se>
	<51086A17.1090707@gmail.com>
	<1359509647.4144.36.camel@bwh-desktop.uk.solarflarecom.com>
	<20744.61933.566806.942439@pilspetsen.it.uu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Xi Wang <xi.wang@gmail.com>,
	<linux-arm-kernel@lists.infradead.org>,
	Imre Kaloz <kaloz@openwrt.org>,
	Krzysztof Halasa <khc@pm.waw.pl>, <netdev@vger.kernel.org>
To: Mikael Pettersson <mikpe@it.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.uu.se ([130.238.7.54]:44111 "EHLO smtp1.uu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756889Ab3A3UvT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2013 15:51:19 -0500
In-Reply-To: <20744.61933.566806.942439@pilspetsen.it.uu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mikael Pettersson writes:
 > Ben Hutchings writes:
 >  > On Tue, 2013-01-29 at 19:32 -0500, Xi Wang wrote:
 >  > > On 1/29/13 7:11 PM, Mikael Pettersson wrote:
 >  > > > A git bisect identified the following as the culprit:
 >  > > > 
 >  > > >   > From 1a4901177574083c35fafc24c4d151c2a7c7647c Mon Sep 17 00:00:00 2001
 >  > > >   > From: Xi Wang <xi.wang@gmail.com>
 >  > > >   > Date: Sat, 17 Nov 2012 20:25:09 +0000
 >  > > >   > Subject: [PATCH] ixp4xx_eth: avoid calling dma_pool_create() with NULL dev
 >  > > >   >
 >  > > >   > Use &port->netdev->dev instead of NULL since dma_pool_create() doesn't
 >  > > >   > allow NULL dev.
 >  > > >   >
 >  > > >   > Signed-off-by: Xi Wang <xi.wang@gmail.com>
 >  > > >   > Cc: Andrew Morton <akpm@linux-foundation.org>
 >  > > >   > Signed-off-by: David S. Miller <davem@davemloft.net>
 >  > > >   > ---
 >  > > >   >  drivers/net/ethernet/xscale/ixp4xx_eth.c |    8 +++++---
 >  > > >   >  1 files changed, 5 insertions(+), 3 deletions(-)
 >  > > > 
 >  > > > Reverting this unbreaks ixp4xx_eth on my ixp4xx machine with kernels
 >  > > > 3.7.0 and 3.8-rc5.
 >  > > 
 >  > > Thanks.  The problem was that in init_queues(), the dma_pool_create()
 >  > > call requires a non-null dev.
 >  > > 
 >  > >   dma_pool = dma_pool_create(DRV_NAME, ??, ...);
 > 
 > I had a look around in the 3.8-rc5 kernel source.
 > 
 > mm/dmapool.c:dma_pool_create() needs a non-NULL dev in the CONFIG_NUMA case,
 > because it calls dev_to_node(dev) which dereferences dev if CONFIG_NUMA.
 > But in the non-CONFIG_NUMA case there is no dereference of dev, and in fact
 > there is an explicit check for dev being NULL or not towards the end of
 > dma_pool_create().  So that explains why ixp4xx works without the change:
 > it's not NUMA.
 > 
 > A quick grep found three calls to dma_pool_create() with a NULL dev parameter,
 > two in drivers/usb/gadget/amd5536udc.c and one in arch/arm/mach-s3c64xx/dma.c.
 > These would all be broken with CONFIG_NUMA but Ok otherwise.
 > 
 >  > > 
 >  > > What do you think would work here?
 >  > 
 >  > For DMA purposes I would expect the right device to be the parent bus
 >  > device, i.e. port->netdev->dev.parent.  The driver might also need to
 >  > set its DMA masks.
 > 
 > At least on ixp4xx the DMA masks are normally set by the platform PCI init
 > code (it has a 64MB PCI DMA window limitation).
 > 
 > I can give the port->netdev->dev.parent variant a try later this evening.

No joy, s/&port->netdev->dev/port->netdev->dev.parent/ in init_queues' call
to dma_pool_create made no difference, it still fails.

/Mikael
