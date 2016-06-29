From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] [v6] net: emac: emac gigabit ethernet controller driver
Date: Wed, 29 Jun 2016 16:07:58 +0200
Message-ID: <4312386.60Y44nCzSI@wuerfel>
References: <1466812008-26686-1-git-send-email-timur@codeaurora.org> <5301045.3F9gkJcz60@wuerfel> <5773BC59.5010404@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	shankerd@codeaurora.org, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org, robh+dt@kernel.org,
	andrew@lunn.ch, bjorn.andersson@linaro.org, mlangsdo@redhat.com,
	jcm@redhat.com, agross@codeaurora.org, davem@davemloft.net,
	f.fainelli@gmail.com, catalin.marinas@arm.com
To: Timur Tabi <timur@codeaurora.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <5773BC59.5010404@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, June 29, 2016 7:17:29 AM CEST Timur Tabi wrote:
> Arnd Bergmann wrote:
> > On Friday, June 24, 2016 6:46:48 PM CEST Timur Tabi wrote:
> >> >+       /* The EMAC itself is capable of 64-bit DMA. If the SOC limits that
> >> >+        * range, then we expect platform code to adjust the mask accordingly.
> >> >+        */
> >> >+       ret = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64));
> >> >+       if (ret) {
> >> >+               dev_err(&pdev->dev, "could not set DMA mask\n");
> >> >+               return ret;
> >> >+       }
> >> >
> > The comment does not match the code: if the platform has no IOMMU
> > and the bus limit is smaller than the memory, dma_set_mask_and_coherent()
> > will fail, and the driver should instead ensure that the buffers are
> > allocated from the 32-bit area.
> >
> > Alternatively, adjust the comment to explain that this is a limitation
> > in the driver that can be lifted if necessary.
> 
> I'm not sure I understand.  The EMAC hardware is capable of 64-bit DMA. 
>   This is true on every platform -- the hardware registers that take bus 
> addresses are 64-bit.  The driver itself has no limitations.
> 
> And that's what the dma_set_mask_and_coherent() does.  It tells the 
> kernel what the device is capable of.

dma_set_mask_and_coherent() is a two-way interface, the driver says what
it wants to do, and the platform reports on whether that is possible.

> However, on some SOCs, only a subset of those address lines are 
> connected to the memory bus.  So for instance, some platforms only have 
> 32 bits connected.
> 
> There's no way for the EMAC driver to know this, so it expects other 
> code in the kernel to adjust.  I'm not exactly sure what this code is 
> supposed to be, because I get conflicting information.  At one point, I 
> thought that the dma-ranges property would handle that.  The kernel 
> would parse that property, see that the DMA range is limited to 32 bits, 
> and adjust the DMA mask accordingly.  However, with dma-ranges in the 
> parent node, I don't see how that can work.

dma-ranges in fact is what should handle it, but arm64 currently does
not interpret it correctly, and just allows the mask to be set regardless,
which I consider a bug in the architecture specific code.

> So my question is, how do I handle the situation where a subset of the 
> DMA address lines are masked off by the SOC?  I've seen code like this:
> 
> ret = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64));
> if (ret)
> 	ret = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32));
> 
> But this has never made any sense to me.  If DMA_BIT_MASK(64) fails, 
> then how can DMA_BIT_MASK(32) succeed?

If the ranges property lists the bus as dma capable for only the
lower 32 bits, then dma_set_mask_and_coherent(dev, DMA_BIT_MASK(64));
should fail, otherwise dma_alloc_coherent() will return an invalid
memory area.

Another twist is how arm64 currently uses SWIOTLB unconditionally:
As long as SWIOTLB (or iommu) is enabled, dma_set_mask_and_coherent()
should succeed for any mask(), but not actually update the mask of the
device to more than the bus can handle.

	Arnd
