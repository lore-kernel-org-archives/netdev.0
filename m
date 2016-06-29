From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v6] net: emac: emac gigabit ethernet controller driver
Date: Wed, 29 Jun 2016 09:33:54 -0500
Message-ID: <5773DC52.4010703@codeaurora.org>
References: <1466812008-26686-1-git-send-email-timur@codeaurora.org>
 <5301045.3F9gkJcz60@wuerfel> <5773BC59.5010404@codeaurora.org>
 <4312386.60Y44nCzSI@wuerfel>
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
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <4312386.60Y44nCzSI@wuerfel>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann wrote:
> If the ranges property lists the bus as dma capable for only the
> lower 32 bits, then dma_set_mask_and_coherent(dev, DMA_BIT_MASK(64));
> should fail, otherwise dma_alloc_coherent() will return an invalid
> memory area.

That seems wrong.  dma_alloc_coherent() should be smart enough to 
restrict itself to the the dma-ranges property.  Isn't that why the 
property exists?  When dma_alloc_coherent() looks for memory, it should 
knows it has to create a 32-bit address.  That's why we have ZONE_DMA.

> Another twist is how arm64 currently uses SWIOTLB unconditionally:
> As long as SWIOTLB (or iommu) is enabled, dma_set_mask_and_coherent()
> should succeed for any mask(), but not actually update the mask of the
> device to more than the bus can handle.

That just seems like a bug in ARM64 SWIOTLB.  SWIOTLB should inject 
itself when the driver tries to map memory outside of its DMA range.

In this case, SWIOTLB/IOMMU is handling the translation from low memory 
to high memory, eliminating the need to restrict memory access to a 
specific physical range.

Without SWIOTLB/IOMMU, dma_alloc_coherent() should be aware of the 
platform-specific limitations of each device and ensure that it only 
allocates memory that conforms *all* limitations.  For example, if the 
platform is capable of 64-bit DMA, but a legacy device can only handle 
32-bit bus addresses, then the driver should do this:

	dma_set_mask_and_coherent(dev, DMA_BIT_MASK(32))

If there's no SWIOTLB or IOMMU, then dma_alloc_coherent() should 
allocate only 32-bit addresses.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
