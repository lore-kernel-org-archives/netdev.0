From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v5] net: emac: emac gigabit ethernet controller driver
Date: Mon, 20 Jun 2016 13:15:27 -0500
Message-ID: <576832BF.7080805@codeaurora.org>
References: <1465942955-22988-1-git-send-email-timur@codeaurora.org>
 <20160619141757.GA4249@rob-hp-laptop> <57682AC3.4040003@codeaurora.org>
 <57683029.1090601@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	vikrams@codeaurora.org, cov@codeaurora.org, gavidov@codeaurora.org,
	andrew@lunn.ch, bjorn.andersson@linaro.org, mlangsdo@redhat.com,
	jcm@redhat.com, agross@codeaurora.org, davem@davemloft.net,
	f.fainelli@gmail.com
To: shankerd@codeaurora.org, Rob Herring <robh@kernel.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <57683029.1090601@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Shanker Donthineni wrote:
>          /* Set dma_mask and coherent_dma_mask to 64-bits,
>           * if xHC supports 64-bit addressing */
>          if (HCC_64BIT_ADDR(xhci->hcc_params) &&
>                          !dma_set_mask(dev, DMA_BIT_MASK(64))) {
>                  xhci_dbg(xhci, "Enabling 64-bit DMA addresses.\n");
>                  dma_set_coherent_mask(dev, DMA_BIT_MASK(64));
>          } else {
>                  /*
>                   * This is to avoid error in cases where a 32-bit USB
>                   * controller is used on a 64-bit capable system.
>                   */
>                  retval = dma_set_mask(dev, DMA_BIT_MASK(32));

I'm not sure this example is valid because HCC_64BIT_ADDR is part of the 
XCHI specification, so there's an architected way determine whether the 
platform is 64-bit capable or not.  The EMAC has nothing like that.

I can do this:

	ret = dma_coerce_mask_and_coherent(dev, DMA_BIT_MASK(64));
	if (ret)
		dma_coerce_mask_and_coherent(dev, DMA_BIT_MASK(32))

but this has always seemed wrong to me, because it doesn't make sense to 
me that DMA_BIT_MASK(64) could ever fail.  DMA_BIT_MASK(64) says that 
the device can handle any physical address, so the device does not 
impose any limitations.  How could that fail?  I have has this question 
multiple times, and I have never gotten a satisfactory answer.

Also, I don't know if I should be using dma_set_mask_and_coherent or 
dma_coerce_mask_and_coherent.  The comment for 
dma_coerce_mask_and_coherent says this:

/*
  * Similar to the above, except it deals with the case where the device
  * does not have dev->dma_mask appropriately setup.
  */

How can I know if the device has dev->dma_mask "appropriately setup"?

Remember, I need a solution that works for DT and ACPI.

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora
Forum, a Linux Foundation collaborative project.
