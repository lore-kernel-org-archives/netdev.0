From: Willy Tarreau <w@1wt.eu>
Subject: Re: ARM network performance and dma_mask (was: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s)
Date: Thu, 21 Nov 2013 22:51:26 +0100
Message-ID: <20131121215126.GD18513@1wt.eu>
References: <20131119174323.GH913@1wt.eu> <1384885910.8604.110.camel@edumazet-glaptop2.roam.corp.google.com> <20131119184121.GN913@1wt.eu> <874n780wzc.fsf@natisbad.org> <20131120191145.GP8581@1wt.eu> <87txf692zx.fsf@natisbad.org> <20131120215435.GT8581@1wt.eu> <20131121004430.GX8581@1wt.eu> <20131121183834.GB18513@1wt.eu> <20131121200433.4cb97d9e@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, simon.guinot@sequanux.org,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Arnaud Ebalard <arno@natisbad.org>,
	Rob Herring <rob.herring@calxeda.com>, edumazet@google.com,
	Cong Wang <xiyou.wangcong@gmail.com>,
	linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:51039 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752430Ab3KUVwB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Nov 2013 16:52:01 -0500
Content-Disposition: inline
In-Reply-To: <20131121200433.4cb97d9e@skate>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas,

On Thu, Nov 21, 2013 at 08:04:33PM +0100, Thomas Petazzoni wrote:
> > I'm not at ease with these things so I'd like to ask your opinion here, is
> > this supposed to be an improvement or a fix ? Is this something we should
> > backport into stable versions, or is there something to fix in the armada
> > platform so that it works just as if the patch was applied ?
> 
> I guess the driver should have been setting its dma_mask to 0xffffffff,
> since the platform is capable of doing DMA on the first 32 bits of the
> physical address space, probably something like calling
> pci_set_dma_mask(pdev, DMA_BIT_MASK(32)) or something like that.

Almost, yes. Thanks for the tip! There are so few drivers which do this
that I was convinced something was missing (nobody initializes dma_mask
on this platform), so calls to dma_set_mask() from drivers return -EIO
and are ignored.

I ended up with that in mvneta_init() at the end :

       /* setting DMA mask significantly improves transfer rates */
       pp->dev->dev.parent->coherent_dma_mask = DMA_BIT_MASK(32);
       pp->dev->dev.parent->dma_mask = &pp->dev->dev.parent->coherent_dma_mask;

This method changed in 3.12 with Russell's commit fa6a8d6 (DMA-API: provide
a helper to setup DMA masks) doing it a cleaner and safer way, using
dma_coerce_mask_and_coherent().

Then Rob's commit 0589342 (of: set dma_mask to point to coherent_dma_mask) also
merged in 3.12 pre-initialized the dma_mask to point to &coherent_dma_mask for
all devices by default.

> I know
> Russell has recently added some helpers to prevent stupid people (like
> me) from doing mistakes when setting the DMA masks. Certainly worth
> having a look.

My change now allows me to proxy HTTP traffic at 1 Gbps between the two
ports of the mirabox, while it limits to 650 Mbps without the change. But
it's not needed in mainline anymore. However it might be worth having in
older kernels (I don't know if it's suitable for stable since I don't
know if that's a bug), or at least in your own kernels if you have to
maintain and older branch for some customers.

That said, I tend to believe that applying Rob's patch will be better than
just the change above since it will cover all drivers, not only mvneta.
I'll have to test on the AX3 and the XP-GP to see the performance gain in
SMP and using the PCIe.

Best regards,
Willy
