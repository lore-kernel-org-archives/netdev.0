From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] [v6] net: emac: emac gigabit ethernet controller driver
Date: Fri, 01 Jul 2016 15:54:15 +0200
Message-ID: <79189959.nJygzEHqi7@wuerfel>
References: <1466812008-26686-1-git-send-email-timur@codeaurora.org> <11472258.9SNjZdPb6l@wuerfel> <57742C84.6000903@codeaurora.org>
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
In-Reply-To: <57742C84.6000903@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, June 29, 2016 3:16:04 PM CEST Timur Tabi wrote:
> Arnd Bergmann wrote:
> 
> >> Sure, but in theory, my for-loop is correct, right?  Wouldn't there be
> >> some value in setting a 36-bit or 40-bit DMA mask if it works?  We have
> >> a platform where memory starts at a 40-bit address, so some devices have
> >> a 44-bit address bus.  If a 64-bit mask doesn't work, then a 32-bit mask
> >> certainly wont.
> >
> > The question is whether it makes any difference to the driver: what decision
> > does the driver make differently if it has set a 44-bit mask?
> 
> > We don't have ZONE_DMA44 (and it's very unlikely that we will introduce
> > it), so neither the driver nor the network stack can actually act on the
> > fact that a 64-bit mask failed but a 44-bit mask succeeded.
> 
> A 44-bit mask would have access to much larger regions of memory than a 
> 32-bit mask.  Maybe one day we will have a version of dma_alloc_coherent 
> that uses the DMA mask to specify an actual range of physical addresses 
> to allocate from.  In this situation, a mask of 44 would be much better 
> than a mask of 32.
> 
> It just seems wrong for driver to hard-code 64-bit and 32-bit masks and 
> pretend like those are the only two sizes.  Very few 64-bit SOCs have a 
> full 64-bit address bus.  Most have actually around 36-48 bits.  If 
> dma_set_mask(64) fails on these systems, then every driver will fall 
> back to 32 bits, even though they can technically access all of DDR.

To repeat myself: if you have swiotlb enabled, or you have an iommu
or all of your RAM is reachable by the DMA master, then dma_set_mask()
should succeed and do the right thing with setting the correct mask
even if that is different from the one that the driver asked for.

The only case in which it fails is when the device is essentially
unusable and needs to fall back to allocating from ZONE_DMA32
(in case of a mask larger than 32) or cannot allocate from
any zone (in case of mask smaller or equal to 32).

> Maybe we need a function like this:
> 
> int dma_find_best_mask(struct device *dev, unsigned int max)
> {
> 	struct dma_map_ops *ops = get_dma_ops(dev);
> 	unsigned int mask;
> 	int ret;
> 
> 	if (!ops || !ops->dma_supported)
> 		return max;
> 
> 	for (mask = max; mask >= 32; mask--) {
> 		ret = ops->dma_supported(dev, mask);
> 		if (ret < 0)
> 			return ret;
> 
> 		if (ret > 0)
> 			return mask;
> 	}
> 
> 	return -ENOMEM;
> }
> 
> You pass a mask size that you know is the maximum that the device could 
> support (in my case, 64).  It then returns a number that should be 
> passed to dma_set_mask().

You still haven't been able to explain what the driver would do
with that number other than to pass it into dma_set_mask().

> >>> Platforms will also allow allow the driver to set a mask that
> >>> is larger than what the bus supports, as long as all RAM is
> >>> reachable by the bus.
> >>
> >> And that check (like all others) is made in the dma_set_mask call?
> >
> > Yes. Regarding the system you mentioned: I understand that it has
> > no memory in ZONE_DMA32 and no IOMMU (btw, that also means 32-bit
> > PCI devices are fundamentally broken), and the bus can only address
> > the lower 44 bit of address space.
> 
> Actually, we have an IOMMU, and the size of the address space depends on 
> the SOC.  Some SOCs have 32 bits, some have over 40.  The EMAC is the 
> same on all of these SOCs.

If there is an IOMMU, just use it.

> > Does this system support more than 15TB of RAM? If not, then there
> > is no problem, and if it  does, I think your best way out is not
> > to disable SWIOTLB. That will be a slower compared to a system
> > with an IOMMU or the fictional ZONE_DMA44, but it should work
> > correctly. In either case (less than 15TB without swiotlb, or
> > more than 15TB with swiotlb), the driver should just ask for
> > a 64-bit mask and that will succeed.
> 
> Some SOCs can support over 15TB.  They all have IOMMUs.
> 
> Apparently, dma_set_mask(64) won't always succeed.  If the SOC has fewer 
> DMA address lines than total memory, then a mask of 64 will fail.

Correct, unless you have SWIOTLB or IOMMU enabled.

> I don't want to implement a solution that just happens to work on the 
> EMAC.  I'm trying to come up with a generic solution that can work in 
> any driver on any SOC, whether you use device tree or ACPI.

As I said, this is inherently driver specific. If setting the 64-bit
mask fails, the driver itself needs to fall back to the 32-bit mask
so it can allocate buffers from ZONE_DMA instead of ZONE_NORMAL.

I have not been able to find out how network drivers normally
handle this on 64-bit architectures. On 32-bit architectures,
this is handled by calling __skb_linearize on TX SKB with
high data, which will move the data into lowmem when the mask
doesn't match and on the receive path the drivers just don't
pass GFP_HIGHMEM.

My interpretation is that on 64-bit architectures, the network
code simply assumes that either an SWIOTLB or IOMMU is always
there, and lets that handle the copying instead of copying
data to lowmem itself.

	Arnd
