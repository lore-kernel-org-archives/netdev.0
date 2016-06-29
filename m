From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v6] net: emac: emac gigabit ethernet controller driver
Date: Wed, 29 Jun 2016 07:17:29 -0500
Message-ID: <5773BC59.5010404@codeaurora.org>
References: <1466812008-26686-1-git-send-email-timur@codeaurora.org>
 <5301045.3F9gkJcz60@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	shankerd@codeaurora.org, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org, robh+dt@kernel.org,
	andrew@lunn.ch, bjorn.andersson@linaro.org, mlangsdo@redhat.com,
	jcm@redhat.com, agross@codeaurora.org, davem@davemloft.net,
	f.fainelli@gmail.com
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:43651 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752073AbcF2MRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 08:17:33 -0400
In-Reply-To: <5301045.3F9gkJcz60@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann wrote:
> On Friday, June 24, 2016 6:46:48 PM CEST Timur Tabi wrote:
>> >+       /* The EMAC itself is capable of 64-bit DMA. If the SOC limits that
>> >+        * range, then we expect platform code to adjust the mask accordingly.
>> >+        */
>> >+       ret = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64));
>> >+       if (ret) {
>> >+               dev_err(&pdev->dev, "could not set DMA mask\n");
>> >+               return ret;
>> >+       }
>> >
> The comment does not match the code: if the platform has no IOMMU
> and the bus limit is smaller than the memory, dma_set_mask_and_coherent()
> will fail, and the driver should instead ensure that the buffers are
> allocated from the 32-bit area.
>
> Alternatively, adjust the comment to explain that this is a limitation
> in the driver that can be lifted if necessary.

I'm not sure I understand.  The EMAC hardware is capable of 64-bit DMA. 
  This is true on every platform -- the hardware registers that take bus 
addresses are 64-bit.  The driver itself has no limitations.

And that's what the dma_set_mask_and_coherent() does.  It tells the 
kernel what the device is capable of.

However, on some SOCs, only a subset of those address lines are 
connected to the memory bus.  So for instance, some platforms only have 
32 bits connected.

There's no way for the EMAC driver to know this, so it expects other 
code in the kernel to adjust.  I'm not exactly sure what this code is 
supposed to be, because I get conflicting information.  At one point, I 
thought that the dma-ranges property would handle that.  The kernel 
would parse that property, see that the DMA range is limited to 32 bits, 
and adjust the DMA mask accordingly.  However, with dma-ranges in the 
parent node, I don't see how that can work.

So my question is, how do I handle the situation where a subset of the 
DMA address lines are masked off by the SOC?  I've seen code like this:

ret = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64));
if (ret)
	ret = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32));

But this has never made any sense to me.  If DMA_BIT_MASK(64) fails, 
then how can DMA_BIT_MASK(32) succeed?
	
-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
