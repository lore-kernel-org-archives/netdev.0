From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCHv2 net-next 05/16] net: mvpp2: introduce PPv2.2 HW
 descriptors and adapt accessors
Date: Fri, 3 Feb 2017 15:54:49 +0000
Message-ID: <20170203155449.GC27312@n2100.armlinux.org.uk>
References: <1482943592-12556-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1482943592-12556-6-git-send-email-thomas.petazzoni@free-electrons.com>
 <20170106142901.GC14217@n2100.armlinux.org.uk>
 <113811b6-79a4-9c66-d302-add9fb0c5b1a@arm.com>
 <20170203142446.2ee517a7@free-electrons.com>
 <231514f4-2e35-8bde-4469-aada833635aa@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
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
To: Robin Murphy <robin.murphy@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:54668 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751441AbdBCPzI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 10:55:08 -0500
Content-Disposition: inline
In-Reply-To: <231514f4-2e35-8bde-4469-aada833635aa@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 03, 2017 at 02:05:13PM +0000, Robin Murphy wrote:
> AFAICS, even that shouldn't really be necessary - for all VA/PA
> combinations of 32/32, 32/40 and 64/40, storing virt_to_phys() of the
> SKB VA won't overflow 40 bits, so a corresponding phys_to_virt() at the
> other end can't go wrong either.

Except for the detail that virt_to_phys()/phys_to_virt() is only defined
for the direct-mapped memory, not for highmem.  That matters a lot for
32-bit platforms.

Now for a bit of a whinge.  Reading through this code is rather annoying
because of what's called a "physical" address which is actually a DMA
address as far as the kernel is concerned - this makes it much harder
when thinking about this issue because it causes all sorts of confusion.
Please can the next revision of the patches start calling things by their
right name - a dma_addr_t is a DMA address, not a physical address, even
though _numerically_ it may be the same thing.  From the point of view
of the kernel, you must not do phys_to_virt() on a dma_addr_t address.
Thanks.

If we're going to start dealing with _real_ physical addresses, then
this is even more important to separate the concept of what's a physical
address and what's a DMA address in this driver.

Taking a step backwards...

How do DMA addresses and this cookie get into the receive ring - from what
I can see, the driver doesn't write these into the receive ring, it's the
hardware that writes it, and the only route I can see that they get there
is via writes performed in mvpp2_bm_pool_put().

Now, from what I can see, the "buf_virt_addr" comes from:

+static void *mvpp2_frag_alloc(const struct mvpp2_bm_pool *pool)
+{
+       if (likely(pool->frag_size <= PAGE_SIZE))
+               return netdev_alloc_frag(pool->frag_size);
+       else
+               return kmalloc(pool->frag_size, GFP_ATOMIC);
+}

via mvpp2_buf_alloc().

Both kmalloc() and netdev_alloc_frag() guarantee that the virtual
address will be in lowmem.

Given that, I would suggest changing mvpp2_bm_pool_put() as follows -
and this is where my point above about separating the notion of "dma
address" and "physical address" becomes very important:

 static inline void mvpp2_bm_pool_put(struct mvpp2_port *port, int pool,
-                                    dma_addr_t buf_phys_addr,
-                                    unsigned long buf_virt_addr)
+                                    dma_addr_t dma, phys_addr_t phys)
 {

and updating it to write "phys" as the existing buf_virt_addr.

In mvpp2_bm_bufs_add():

                buf = mvpp2_buf_alloc(port, bm_pool, &phys_addr, GFP_KERNEL);
                if (!buf)
                        break;
 
                mvpp2_bm_pool_put(port, bm_pool->id, phys_addr,
-                                 (unsigned long)buf);
+                                 virt_to_phys(buf));

which I think means that mvpp2_rxdesc_virt_addr_get() can just become:

 	phys_addr_t cookie;
 
        /* PPv2.1 can only be used on 32 bits architectures, and there
         * are 32 bits in buf_cookie which are enough to store the
         * full virtual address, so things are easy.
         */
        if (port->priv->hw_version == MVPP21)
                cookie = rx_desc->pp21.buf_cookie;
        else
 		cookie = rx_desc->pp22.buf_cookie_misc & FORTY_BIT_MASK;

 	return phys_to_virt(cookie);

I'd suggest against using DMA_BIT_MASK(40) there - because it's not a
DMA address, even though it happens to resolve to the same number.

Again, I may have missed how the addresses end up getting into
buf_cookie_misc, so what I suggest above may not be possible.

I'd also suggest that there is some test in mvpp2_bm_bufs_add() to
verify that the physical addresses and DMA addresses do fit within
the available number of bits - if they don't we could end up scribbling
over memory that we shouldn't be, and it looks like we have a failure
path there to gracefully handle that situation - gracefully compared
to a nasty BUG_ON().

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
