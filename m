From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net PATCH] atl1c: Fix misuse of netdev_alloc_skb in refilling
 rx ring
Date: Mon, 29 Jul 2013 01:07:18 +0100
Message-ID: <1375056438.2546.55.camel@deadeye.wl.decadent.org.uk>
References: <87k3kbdcmy.fsf@canonical.com>
	 <1374960610.3607.13.camel@deadeye.wl.decadent.org.uk>
	 <1374969583.3669.23.camel@edumazet-glaptop>
	 <20130727.200205.67471633133830510.davem@davemloft.net>
	 <20130728104446.GB9876@neilslaptop.think-freely.org>
	 <1375028154.3669.30.camel@edumazet-glaptop>
	 <20130728185318.GA10795@neilslaptop.think-freely.org>
	 <1375042972.2546.17.camel@deadeye.wl.decadent.org.uk>
	 <1375052482.3669.54.camel@edumazet-glaptop>
	 <1375053654.3669.58.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>,
	<luis.henriques@canonical.com>, <netdev@vger.kernel.org>,
	<jcliburn@gmail.com>, <stable@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1375053654.3669.58.camel@edumazet-glaptop>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2013-07-28 at 16:20 -0700, Eric Dumazet wrote:
> On Sun, 2013-07-28 at 16:01 -0700, Eric Dumazet wrote:
> > On Sun, 2013-07-28 at 21:22 +0100, Ben Hutchings wrote:
> > 
> > > 
> > > Since we know lengths > 4K work, perhaps it would be worth testing with
> > > the fragment cache size reduced to 16K?  The driver would never
> > > previously have used RX buffers crossing 16K boundaries, except if SLOB
> > > was used (and that's an unlikely combination).
> > 
> > Sure, please note the following maths :
> > 
> > NET_SKB_PAD + 1536 + sizeof(struct skb_shared_info) = 1920
> > 
> > 16384/1920 = 8
> > 
> > 32768/1920 = 17
> > 
> > I don't think atl1c is used in any critical host (given it doesn't even
> > provide RX checksums and GRO ...), so I will provide a patch doing mere
> > page allocations.
> > 
> 
> Oh well, look at code around line 2530
> 
>         * The atl1c chip can DMA to 64-bit addresses, but it uses a single
>          * shared register for the high 32 bits, so only a single, aligned,
>          * 4 GB physical address range can be used at a time.
>          *
>          * Supporting 64-bit DMA on this hardware is more trouble than it's
>          * worth.  It is far easier to limit to 32-bit DMA than update
>          * various kernel subsystems to support the mechanics required by a
>          * fixed-high-32-bit system.
>          */
>         if ((pci_set_dma_mask(pdev, DMA_BIT_MASK(32)) != 0) ||
>             (pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32)) != 0)) {
>                 dev_err(&pdev->dev, "No usable DMA configuration,aborting\n");
>                 goto err_dma;
>         }
> 
> It looks like we have a winner !
> 
> This $@!? really needs DMA32 allocations.
[...]

Just like many older PCI/PCIe devices.  So what?  pci_map_single() takes
care of that, just so long as the driver sets the DMA mask correctly.
In fact, PCI devices have a 32-bit DMA mask by default.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
