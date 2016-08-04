From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v6] net: emac: emac gigabit ethernet controller driver
Date: Thu, 4 Aug 2016 09:24:54 -0500
Message-ID: <57A35036.2030604@codeaurora.org>
References: <1466812008-26686-1-git-send-email-timur@codeaurora.org>
 <79189959.nJygzEHqi7@wuerfel> <57A26106.50206@codeaurora.org>
 <3036653.SbY9jG7XMU@wuerfel>
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
In-Reply-To: <3036653.SbY9jG7XMU@wuerfel>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann wrote:
> This is basically ok, but then I think you should pass GFP_DMA
> or GFP_DMA32 to all allocations that the driver does after
> the 64-bit mask fails, otherwise you get a significant overhead
> in the bounce buffers.

Well, for starters, ZONE_DMA32 is the same as ZONE_NORMAL on ARM, 
because CONFIG_ZONE_DMA32 is not defined.

#ifdef CONFIG_ZONE_DMA32
#define OPT_ZONE_DMA32 ZONE_DMA32
#else
#define OPT_ZONE_DMA32 ZONE_NORMAL
#endif

(I wonder if this should say instead:

#ifdef CONFIG_ZONE_DMA32
#define OPT_ZONE_DMA32 ZONE_DMA32
#else
#define OPT_ZONE_DMA32 ZONE_DMA  <----
#endif
)

However, I'm not sure where I should be using GFP_DMA anyway.  Whenever 
the driver allocates memory for DMA, it uses dma_zalloc_coherent():

ring_header->v_addr = dma_zalloc_coherent(dev, ring_header->size,
					 &ring_header->dma_addr,
					 GFP_KERNEL);

and I don't think I need to pass GFP_DMA to dma_zalloc_coherent.  Every 
other memory allocation is a kmalloc variant, but that's never for DMA, 
so that memory can be anywhere.

I found about 70 drivers that fall-back to 32-bit DMA if 64-bit fails. 
None of them do as you suggest.  They all just set the mask to 64 or 32 
and that's it.

Some drivers set NETIF_F_HIGHDMA if 64-bit DMA is enabled:

	if (pci_using_dac)
		netdev->features |= NETIF_F_HIGHDMA;

I could do this, but I think it has no meaning on ARM64 because it 
depends on CONFIG_HIGHMEM.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
