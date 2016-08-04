From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] [v6] net: emac: emac gigabit ethernet controller driver
Date: Thu, 04 Aug 2016 11:21:43 +0200
Message-ID: <3036653.SbY9jG7XMU@wuerfel>
References: <1466812008-26686-1-git-send-email-timur@codeaurora.org> <79189959.nJygzEHqi7@wuerfel> <57A26106.50206@codeaurora.org>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:60189 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932336AbcHDJaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 05:30:07 -0400
In-Reply-To: <57A26106.50206@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, August 3, 2016 4:24:22 PM CEST Timur Tabi wrote:
> Arnd Bergmann wrote:
> > As I said, this is inherently driver specific. If setting the 64-bit
> > mask fails, the driver itself needs to fall back to the 32-bit mask
> > so it can allocate buffers from ZONE_DMA instead of ZONE_NORMAL.
> 
> I just posted a v7 of my patch, but I forgot to fix the dma_set_mask 
> call.  I'll post a v8 soon, but before I do, what do you think of this:
> 
> /* The EMAC itself is capable of 64-bit DMA, so try that first. */
> ret = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64));
> if (ret) {
>          /* Some platforms may restrict the EMAC's address bus to less
>           * then the size of DDR. In this case, we need to try a
>           * smaller mask.  We could try every possible smaller mask,
>           * but that's overkill.  Instead, just fall to 32-bit, which
>           * should always work.
>           */
>          ret = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32));
>          if (ret) {
>                  dev_err(&pdev->dev, "could not set DMA mask\n");
>                  return ret;
>          }
> }

This is basically ok, but then I think you should pass GFP_DMA
or GFP_DMA32 to all allocations that the driver does after
the 64-bit mask fails, otherwise you get a significant overhead
in the bounce buffers.

For data that comes from the network stack, we have no choice
and always use bounce buffers for data that is beyond the mask.

	Arnd
