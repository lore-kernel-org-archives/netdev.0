From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCHv2 net-next 05/16] net: mvpp2: introduce PPv2.2 HW
 descriptors and adapt accessors
Date: Sat, 4 Feb 2017 14:59:38 +0100
Message-ID: <20170204145938.6e6380d9@free-electrons.com>
References: <1482943592-12556-1-git-send-email-thomas.petazzoni@free-electrons.com>
        <1482943592-12556-6-git-send-email-thomas.petazzoni@free-electrons.com>
        <20170106142901.GC14217@n2100.armlinux.org.uk>
        <113811b6-79a4-9c66-d302-add9fb0c5b1a@arm.com>
        <20170203142446.2ee517a7@free-electrons.com>
        <231514f4-2e35-8bde-4469-aada833635aa@arm.com>
        <20170203155449.GC27312@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Robin Murphy <robin.murphy@arm.com>,
        Mark Rutland <mark.rutland@arm.com>,
        devicetree@vger.kernel.org, Yehuda Yitschak <yehuday@marvell.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Pawel Moll <pawel.moll@arm.com>,
        Ian Campbell <ijc+devicetree@hellion.org.uk>,
        netdev@vger.kernel.org, Hanna Hawa <hannah@marvell.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Rob Herring <robh+dt@kernel.org>, Andrew Lunn <andrew@lunn.ch>,
        Kumar Gala <galak@codeaurora.org>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-arm-kernel@lists.infradead.org,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:47935 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750851AbdBDN7t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 08:59:49 -0500
In-Reply-To: <20170203155449.GC27312@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Fri, 3 Feb 2017 15:54:49 +0000, Russell King - ARM Linux wrote:

> Now for a bit of a whinge.  Reading through this code is rather annoying
> because of what's called a "physical" address which is actually a DMA
> address as far as the kernel is concerned - this makes it much harder
> when thinking about this issue because it causes all sorts of confusion.
> Please can the next revision of the patches start calling things by their
> right name - a dma_addr_t is a DMA address, not a physical address, even
> though _numerically_ it may be the same thing.  From the point of view
> of the kernel, you must not do phys_to_virt() on a dma_addr_t address.
> Thanks.

I do know that phys_addr_t is different from dma_addr_t. The case where
you have an IOMMU makes this very obvious. The fact that the driver
isn't completely correct in that respect indeed needs to be fixed.

> Taking a step backwards...
> 
> How do DMA addresses and this cookie get into the receive ring - from what
> I can see, the driver doesn't write these into the receive ring, it's the
> hardware that writes it, and the only route I can see that they get there
> is via writes performed in mvpp2_bm_pool_put().

Correct. Here is a quick summary of my understand of the HW operation.
The HW has a "buffer manager", i.e it can internally manage a list of
buffers. At initialization time, we provide to the HW a list of buffers
by pushing the DMA address and virtual address of each buffer into a
register. Thanks to that the HW then knows about all the buffers we
have given. Then, upon RX of a packet, the HW picks one of those
buffers, and then fills a RX descriptor with the DMA address of the
packet, and the VA in the "cookie" field. The "cookie" field can I
believe be used for whatever we want, it's just "free" space in the
descriptor.

> Now, from what I can see, the "buf_virt_addr" comes from:
> 
> +static void *mvpp2_frag_alloc(const struct mvpp2_bm_pool *pool)
> +{
> +       if (likely(pool->frag_size <= PAGE_SIZE))
> +               return netdev_alloc_frag(pool->frag_size);
> +       else
> +               return kmalloc(pool->frag_size, GFP_ATOMIC);
> +}
> 
> via mvpp2_buf_alloc().
> 
> Both kmalloc() and netdev_alloc_frag() guarantee that the virtual
> address will be in lowmem.

*That* is the thing I didn't realize until now. If the buffers are
always in lowmem, then it's much easier because we can indeed use
virt_to_phys()/phys_to_virt() on them. But it's indeed obvious they are
in lowmem, since we get a void* pointer for them.

> Given that, I would suggest changing mvpp2_bm_pool_put() as follows -
> and this is where my point above about separating the notion of "dma
> address" and "physical address" becomes very important:
> 
>  static inline void mvpp2_bm_pool_put(struct mvpp2_port *port, int pool,
> -                                    dma_addr_t buf_phys_addr,
> -                                    unsigned long buf_virt_addr)
> +                                    dma_addr_t dma, phys_addr_t phys)
>  {
> 
> and updating it to write "phys" as the existing buf_virt_addr.
> 
> In mvpp2_bm_bufs_add():
> 
>                 buf = mvpp2_buf_alloc(port, bm_pool, &phys_addr, GFP_KERNEL);
>                 if (!buf)
>                         break;
>  
>                 mvpp2_bm_pool_put(port, bm_pool->id, phys_addr,
> -                                 (unsigned long)buf);
> +                                 virt_to_phys(buf));
> 
> which I think means that mvpp2_rxdesc_virt_addr_get() can just become:
> 
>  	phys_addr_t cookie;
>  
>         /* PPv2.1 can only be used on 32 bits architectures, and there
>          * are 32 bits in buf_cookie which are enough to store the
>          * full virtual address, so things are easy.
>          */
>         if (port->priv->hw_version == MVPP21)
>                 cookie = rx_desc->pp21.buf_cookie;
>         else
>  		cookie = rx_desc->pp22.buf_cookie_misc & FORTY_BIT_MASK;
> 
>  	return phys_to_virt(cookie);

This makes complete sense. We use the cookie to store the phys_addr_t
rather than the virtual address. I might be missing something, but it
seems like a very good solution. Thanks for the suggestion, I'll try
this!

> I'd suggest against using DMA_BIT_MASK(40) there - because it's not a
> DMA address, even though it happens to resolve to the same number.

Sure, will update this as well.

> Again, I may have missed how the addresses end up getting into
> buf_cookie_misc, so what I suggest above may not be possible.

No, I think you got it right. At least it matches my own understanding
of the HW.

> I'd also suggest that there is some test in mvpp2_bm_bufs_add() to
> verify that the physical addresses and DMA addresses do fit within
> the available number of bits - if they don't we could end up scribbling
> over memory that we shouldn't be, and it looks like we have a failure
> path there to gracefully handle that situation - gracefully compared
> to a nasty BUG_ON().

For the DMA addresses, I have some additional changes on top of my v2
to use dma_set_mask() to ensure that DMA addresses fit in 40 bits. But
that's only for DMA addresses indeed.

Thanks again for your suggestion!

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
