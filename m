From: Mika Westerberg <mika.westerberg@iki.fi>
Subject: Re: [PATCH] net: ep93xx_eth: drop GFP_DMA from memory allocations
Date: Sun, 29 May 2011 13:59:46 +0300
Message-ID: <20110529105946.GA2655@acer>
References: <1306659837-23553-1-git-send-email-mika.westerberg@iki.fi>
 <20110529103825.GZ24876@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hsweeten@visionengravers.com,
	ryan@bluewatersys.com, kernel@wantstofly.org,
	linux-arm-kernel@lists.infradead.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:57063 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433Ab1E2LBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 May 2011 07:01:51 -0400
Received: by eyx24 with SMTP id 24so1095691eyx.19
        for <netdev@vger.kernel.org>; Sun, 29 May 2011 04:01:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20110529103825.GZ24876@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 29, 2011 at 11:38:25AM +0100, Russell King - ARM Linux wrote:
> On Sun, May 29, 2011 at 12:03:57PM +0300, Mika Westerberg wrote:
> > diff --git a/drivers/net/arm/ep93xx_eth.c b/drivers/net/arm/ep93xx_eth.c
> > index 5a77001..e495f76 100644
> > --- a/drivers/net/arm/ep93xx_eth.c
> > +++ b/drivers/net/arm/ep93xx_eth.c
> > @@ -494,7 +494,7 @@ static int ep93xx_alloc_buffers(struct ep93xx_priv *ep)
> >  	int i;
> >  
> >  	ep->descs = dma_alloc_coherent(NULL, sizeof(struct ep93xx_descs),
> > -				&ep->descs_dma_addr, GFP_KERNEL | GFP_DMA);
> > +				&ep->descs_dma_addr, GFP_KERNEL);
> 
> This one is correct anyway - whether the allocation comes from the DMA
> zone or not is something which should be controlled by the DMA mask and
> not the driver passing random GFP flags to dma_alloc_coherent.
> 
> However, because it is passing a NULL device to dma_alloc_coherent(), it
> assumes that it is for an old ISA device, and so will continue to perform
> a GFP_DMA allocation.  The solution - pass a struct device and set the
> DMA masks correctly.

Ok, thanks. I'll send updated patch soon.

> > @@ -525,7 +525,7 @@ static int ep93xx_alloc_buffers(struct ep93xx_priv *ep)
> >  		void *page;
> >  		dma_addr_t d;
> >  
> > -		page = (void *)__get_free_page(GFP_KERNEL | GFP_DMA);
> > +		page = (void *)__get_free_page(GFP_KERNEL);
> >  		if (page == NULL)
> >  			goto err;
> >  
> 
> Wow, just looked at what this driver is doing with the DMA buffer handling,
> and I'm wondering how come its soo broken.
> 
[...]
> 
> While it may work on ep93xx, it's not respecting the DMA API rules,
> and with DMA debugging enabled it will probably encounter quite a few
> warnings.

FYI, I just enabled DMA debugging and I've got:

[    1.980000] WARNING: at lib/dma-debug.c:911 check_sync+0x460/0x510()
[    1.980000] NULL NULL: DMA-API: device driver tries to sync DMA memory it has not allocated [device address=0x00000000c5a11800] [size=78 b
ytes]
[    1.980000] Modules linked in:
[    1.980000] [<c0035498>] (unwind_backtrace+0x0/0xf4) from [<c0043ea4>] (warn_slowpath_common+0x48/0x60)
[    1.980000] [<c0043ea4>] (warn_slowpath_common+0x48/0x60) from [<c0043f50>] (warn_slowpath_fmt+0x30/0x40)
[    1.980000] [<c0043f50>] (warn_slowpath_fmt+0x30/0x40) from [<c01e2a00>] (check_sync+0x460/0x510)
[    1.980000] [<c01e2a00>] (check_sync+0x460/0x510) from [<c01e2ea4>] (debug_dma_sync_single_for_cpu+0x50/0x5c)
[    1.980000] [<c01e2ea4>] (debug_dma_sync_single_for_cpu+0x50/0x5c) from [<c0229a40>] (ep93xx_xmit+0x80/0x144)
[    1.980000] [<c0229a40>] (ep93xx_xmit+0x80/0x144) from [<c0284558>] (dev_hard_start_xmit+0x33c/0x5e8)
[    1.980000] [<c0284558>] (dev_hard_start_xmit+0x33c/0x5e8) from [<c02992d8>] (sch_direct_xmit+0xa8/0x1c0)
[    1.980000] [<c02992d8>] (sch_direct_xmit+0xa8/0x1c0) from [<c028494c>] (dev_queue_xmit+0x148/0x46c)
[    1.980000] [<c028494c>] (dev_queue_xmit+0x148/0x46c) from [<c028ed24>] (neigh_resolve_output+0x110/0x3bc)
[    1.980000] [<c028ed24>] (neigh_resolve_output+0x110/0x3bc) from [<c02f7898>] (ip6_finish_output2+0x388/0x458)
[    1.980000] [<c02f7898>] (ip6_finish_output2+0x388/0x458) from [<c03071a4>] (ndisc_send_skb+0x1dc/0x330)
[    1.980000] [<c03071a4>] (ndisc_send_skb+0x1dc/0x330) from [<c0308be4>] (ndisc_send_ns+0x7c/0xac)
[    1.980000] [<c0308be4>] (ndisc_send_ns+0x7c/0xac) from [<c02fb7e0>] (addrconf_dad_timer+0x144/0x15c)
[    1.980000] [<c02fb7e0>] (addrconf_dad_timer+0x144/0x15c) from [<c0050760>] (run_timer_softirq+0x110/0x23c)
[    1.980000] [<c0050760>] (run_timer_softirq+0x110/0x23c) from [<c0049ec0>] (__do_softirq+0xa4/0x168)
[    1.980000] [<c0049ec0>] (__do_softirq+0xa4/0x168) from [<c004a148>] (irq_exit+0x54/0x60)
[    1.980000] [<c004a148>] (irq_exit+0x54/0x60) from [<c0023034>] (asm_do_IRQ+0x34/0x84)
[    1.980000] [<c0023034>] (asm_do_IRQ+0x34/0x84) from [<c002f4f8>] (__irq_svc+0x38/0xd4)
...

I'll prepare a separate patch where these are fixed.
