From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] [v6] net: emac: emac gigabit ethernet controller driver
Date: Wed, 29 Jun 2016 17:04:45 +0200
Message-ID: <5679359.84lXZytcOR@wuerfel>
References: <1466812008-26686-1-git-send-email-timur@codeaurora.org> <4312386.60Y44nCzSI@wuerfel> <5773DC52.4010703@codeaurora.org>
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
In-Reply-To: <5773DC52.4010703@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, June 29, 2016 9:33:54 AM CEST Timur Tabi wrote:
> Arnd Bergmann wrote:
> > If the ranges property lists the bus as dma capable for only the
> > lower 32 bits, then dma_set_mask_and_coherent(dev, DMA_BIT_MASK(64));
> > should fail, otherwise dma_alloc_coherent() will return an invalid
> > memory area.
> 
> That seems wrong.  dma_alloc_coherent() should be smart enough to 
> restrict itself to the the dma-ranges property.  Isn't that why the 
> property exists?  When dma_alloc_coherent() looks for memory, it should 
> knows it has to create a 32-bit address.  That's why we have ZONE_DMA.

No, dma_alloc_coherent() is documented to use the dma_mask as
its reference, it's supposed to be independent of the underlying
bus.

dma-ranges is just how we communicate the limitation of the
bus to the kernel, but relying on dma-ranges itself would fail
to consider drivers that impose additional limitations, i.e.
when a device needs a smaller mask and calls 'dma_set_mask(dev,
DMA_BIT_MASK(24))' or something like that.

> > Another twist is how arm64 currently uses SWIOTLB unconditionally:
> > As long as SWIOTLB (or iommu) is enabled, dma_set_mask_and_coherent()
> > should succeed for any mask(), but not actually update the mask of the
> > device to more than the bus can handle.
> 
> That just seems like a bug in ARM64 SWIOTLB.  SWIOTLB should inject 
> itself when the driver tries to map memory outside of its DMA range.

Again, the dma mask is how swiotlb_map_*() finds whether a page
needs a bounce buffer or not, so it has to be set to whatever
the device can address.

> Without SWIOTLB/IOMMU, dma_alloc_coherent() should be aware of the 
> platform-specific limitations of each device and ensure that it only 
> allocates memory that conforms *all* limitations.  For example, if the 
> platform is capable of 64-bit DMA, but a legacy device can only handle 
> 32-bit bus addresses, then the driver should do this:
> 
> 	dma_set_mask_and_coherent(dev, DMA_BIT_MASK(32))

That's also not how it works: each device starts out with a 32-bit mask,
because that's what historically all PCI devices can do. If a device
is 64-bit DMA capable, it can extend the mask by passing DMA_BIT_MASK(64)
(or whatever it can support), and the platform code checks if that's
possible.


	Arnd
