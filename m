From: Rob Herring <robherring2@gmail.com>
Subject: Re: ARM network performance and dma_mask
Date: Thu, 21 Nov 2013 16:01:42 -0600
Message-ID: <528E82C6.2010106@gmail.com>
References: <87li0kkhzx.fsf@natisbad.org> <1384869194.8604.92.camel@edumazet-glaptop2.roam.corp.google.com> <20131119174323.GH913@1wt.eu> <1384885910.8604.110.camel@edumazet-glaptop2.roam.corp.google.com> <20131119184121.GN913@1wt.eu> <874n780wzc.fsf@natisbad.org> <20131120191145.GP8581@1wt.eu> <87txf692zx.fsf@natisbad.org> <20131120215435.GT8581@1wt.eu> <20131121004430.GX8581@1wt.eu> <20131121183834.GB18513@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Arnaud Ebalard <arno@natisbad.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	simon.guinot@sequanux.org, Eric Dumazet <eric.dumazet@gmail.com>,
	netdev@vger.kernel.org, edumazet@google.com,
	Cong Wang <xiyou.wangcong@gmail.com>,
	linux-arm-kernel@lists.infradead.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:38050 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752537Ab3KUWBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 17:01:46 -0500
Received: by mail-ob0-f178.google.com with SMTP id uz6so423322obc.37
        for <netdev@vger.kernel.org>; Thu, 21 Nov 2013 14:01:45 -0800 (PST)
In-Reply-To: <20131121183834.GB18513@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/21/2013 12:38 PM, Willy Tarreau wrote:
> Hi Rob,
> 
> While we were diagnosing a network performance regression that we finally
> found and fixed, it appeared during a test that Linus' tree shows a much
> higher performance on Armada 370 (armv7) than its predecessors. I can
> saturate the two Gig links of my Mirabox each with a single TCP flow and
> keep up to 25% of idle CPU in the optimal case. In 3.12.1 or 3.10.20, I
> can achieve around 1.3 Gbps when the two ports are used in parallel.
> 
> Today I bisected these kernels to find what was causing this difference.
> I found it was your patch below which I can copy entirely here :
> 
>   commit 0589342c27944e50ebd7a54f5215002b6598b748
>   Author: Rob Herring <rob.herring@calxeda.com>
>   Date:   Tue Oct 29 23:36:46 2013 -0500
> 
>       of: set dma_mask to point to coherent_dma_mask
>     
>       Platform devices created by DT code don't initialize dma_mask pointer to
>       anything. Set it to coherent_dma_mask by default if the architecture
>       code has not set it.
>     
>       Signed-off-by: Rob Herring <rob.herring@calxeda.com>
> 
>   diff --git a/drivers/of/platform.c b/drivers/of/platform.c
>   index 9b439ac..c005495 100644
>   --- a/drivers/of/platform.c
>   +++ b/drivers/of/platform.c
>   @@ -216,6 +216,8 @@ static struct platform_device *of_platform_device_create_pdata(
>           dev->archdata.dma_mask = 0xffffffffUL;
>    #endif
>           dev->dev.coherent_dma_mask = DMA_BIT_MASK(32);
>   +       if (!dev->dev.dma_mask)
>   +               dev->dev.dma_mask = &dev->dev.coherent_dma_mask;
>           dev->dev.bus = &platform_bus_type;
>           dev->dev.platform_data = platform_data;
> 
> And I can confirm that applying this patch on 3.10.20 + the fixes we found
> yesterday substantially boosted my network performance (and reduced the CPU
> usage when running on a single link).
> 
> I'm not at ease with these things so I'd like to ask your opinion here, is
> this supposed to be an improvement or a fix ? Is this something we should
> backport into stable versions, or is there something to fix in the armada
> platform so that it works just as if the patch was applied ?
> 

The patch was to fix this issue[1]. It is fixed in the core code because
dma_mask not being set has been a known issue with DT probing for some
time. Since most drivers don't seem to care, we've gotten away with it.
I thought the normal failure mode was drivers failing to probe.

As to why it helps performance, I'm not really sure. Perhaps it is
causing some bounce buffers to be used.

Rob

[1] http://lists.xen.org/archives/html/xen-devel/2013-10/msg00092.html
