From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v6] net: emac: emac gigabit ethernet controller driver
Date: Wed, 29 Jun 2016 15:16:04 -0500
Message-ID: <57742C84.6000903@codeaurora.org>
References: <1466812008-26686-1-git-send-email-timur@codeaurora.org>
 <3914163.aNiIdzedWT@wuerfel> <5773ED4F.4050401@codeaurora.org>
 <11472258.9SNjZdPb6l@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	shankerd@codeaurora.org, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org, robh+dt@kernel.org,
	andrew@lunn.ch, bjorn.andersson@linaro.org, mlangsdo@redhat.com,
	jcm@redhat.com, agross@codeaurora.org, davem@davemloft.net,
	f.fainelli@gmail.com, catalin.marinas@arm.com
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:42099 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480AbcF2URh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 16:17:37 -0400
In-Reply-To: <11472258.9SNjZdPb6l@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann wrote:

>> Sure, but in theory, my for-loop is correct, right?  Wouldn't there be
>> some value in setting a 36-bit or 40-bit DMA mask if it works?  We have
>> a platform where memory starts at a 40-bit address, so some devices have
>> a 44-bit address bus.  If a 64-bit mask doesn't work, then a 32-bit mask
>> certainly wont.
>
> The question is whether it makes any difference to the driver: what decision
> does the driver make differently if it has set a 44-bit mask?

> We don't have ZONE_DMA44 (and it's very unlikely that we will introduce
> it), so neither the driver nor the network stack can actually act on the
> fact that a 64-bit mask failed but a 44-bit mask succeeded.

A 44-bit mask would have access to much larger regions of memory than a 
32-bit mask.  Maybe one day we will have a version of dma_alloc_coherent 
that uses the DMA mask to specify an actual range of physical addresses 
to allocate from.  In this situation, a mask of 44 would be much better 
than a mask of 32.

It just seems wrong for driver to hard-code 64-bit and 32-bit masks and 
pretend like those are the only two sizes.  Very few 64-bit SOCs have a 
full 64-bit address bus.  Most have actually around 36-48 bits.  If 
dma_set_mask(64) fails on these systems, then every driver will fall 
back to 32 bits, even though they can technically access all of DDR.

Maybe we need a function like this:

int dma_find_best_mask(struct device *dev, unsigned int max)
{
	struct dma_map_ops *ops = get_dma_ops(dev);
	unsigned int mask;
	int ret;

	if (!ops || !ops->dma_supported)
		return max;

	for (mask = max; mask >= 32; mask--) {
		ret = ops->dma_supported(dev, mask);
		if (ret < 0)
			return ret;

		if (ret > 0)
			return mask;
	}

	return -ENOMEM;
}

You pass a mask size that you know is the maximum that the device could 
support (in my case, 64).  It then returns a number that should be 
passed to dma_set_mask().

>>> Platforms will also allow allow the driver to set a mask that
>>> is larger than what the bus supports, as long as all RAM is
>>> reachable by the bus.
>>
>> And that check (like all others) is made in the dma_set_mask call?
>
> Yes. Regarding the system you mentioned: I understand that it has
> no memory in ZONE_DMA32 and no IOMMU (btw, that also means 32-bit
> PCI devices are fundamentally broken), and the bus can only address
> the lower 44 bit of address space.

Actually, we have an IOMMU, and the size of the address space depends on 
the SOC.  Some SOCs have 32 bits, some have over 40.  The EMAC is the 
same on all of these SOCs.

> Does this system support more than 15TB of RAM? If not, then there
> is no problem, and if it  does, I think your best way out is not
> to disable SWIOTLB. That will be a slower compared to a system
> with an IOMMU or the fictional ZONE_DMA44, but it should work
> correctly. In either case (less than 15TB without swiotlb, or
> more than 15TB with swiotlb), the driver should just ask for
> a 64-bit mask and that will succeed.

Some SOCs can support over 15TB.  They all have IOMMUs.

Apparently, dma_set_mask(64) won't always succeed.  If the SOC has fewer 
DMA address lines than total memory, then a mask of 64 will fail.

I don't want to implement a solution that just happens to work on the 
EMAC.  I'm trying to come up with a generic solution that can work in 
any driver on any SOC, whether you use device tree or ACPI.

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora
Forum, a Linux Foundation collaborative project.
