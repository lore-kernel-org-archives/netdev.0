From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/1] net: Add Aeroflex Gaisler GRETH 10/100/1G Ethernet
	MAC driver
Date: Mon, 11 Jan 2010 17:34:30 +0000
Message-ID: <1263231270.2781.22.camel@achroite.uk.solarflarecom.com>
References: <1262965531-4800-1-git-send-email-kristoffer@gaisler.com>
	 <1262965531-4800-2-git-send-email-kristoffer@gaisler.com>
	 <1262991459.17358.63.camel@achroite.uk.solarflarecom.com>
	 <4B4B4FFA.8070805@gaisler.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kristoffer Glembo <kristoffer@gaisler.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:46043 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751545Ab0AKRed (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 12:34:33 -0500
In-Reply-To: <4B4B4FFA.8070805@gaisler.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-01-11 at 17:21 +0100, Kristoffer Glembo wrote:
[...]
> > [...] 
> >> diff --git a/drivers/net/greth.c b/drivers/net/greth.c
> 
> >> +#define GRETH_REGLOAD(a)	    (__raw_readl(&(a)))
> >> +#define GRETH_REGSAVE(a, v)         (__raw_writel(v, &(a)))
> >> +#define GRETH_REGORIN(a, v)         (GRETH_REGSAVE(a, (GRETH_REGLOAD(a) | (v))))
> >> +#define GRETH_REGANDIN(a, v)        (GRETH_REGSAVE(a, (GRETH_REGLOAD(a) & (v))))
> > 
> > I think you need an mmiowb() after the __raw_writel().
> > Also, are you sure the registers are going to match host byte order?
> 
> 
> I'm working on a CPU with strong ordering so I'm not so confident in these matters,
> but as I understand it I should in that case not put mmiowb() after each __raw_writel()
> but only before unlocks where mmio has been done in the critical section.
> 
> I have not put a single explicit memory barrier in the code, I was under the 
> impression that each architecture that needs it has it in the __raw_writel. 

No, the __raw functions are about as raw as you can get without
resorting to architecture-specific operations.

> I only used the __raw versions since I wanted native byte ordering. I should add
> cpu_to_be32 and be32_to_cpu however as you point out.

That depends on how this device is likely to be attached to the bus.

> Questions is do I need to add wmb/mb when I use __raw as well?
[...]

If you need to write multiple registers in a specific sequence, you will
use a spinlock or mutex to serialise this with register writes from
other contexts.  But in general you also need to call mmiowb() before
dropping the lock, to serialise these at the bus level.

You may need to use the stronger memory barriers (wmb(), rmb() or mb()
as appropriate) between access to registers and access to associated DMA
buffers.  For example, there should be a wmb() between writing DMA
descriptors and writing the pointer register that triggers the
controller to start reading those descriptors.

Documentation/memory-barriers.txt has general information on this.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

