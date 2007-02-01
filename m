From: olof@lixom.net (Olof Johansson)
Subject: Re: [PATCH] [v3] PA Semi PWRficient Ethernet driver
Date: Wed, 31 Jan 2007 21:40:49 -0600
Message-ID: <20070201034049.GB11564@lixom.net>
References: <20070129060852.GA7814@lixom.net> <20070130014434.GC18935@lixom.net> <20070131054457.GA32043@lixom.net> <45C0709E.9090103@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Christoph Hellwig <hch@infradead.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:41194 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161298AbXBADd5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 22:33:57 -0500
Content-Disposition: inline
In-Reply-To: <45C0709E.9090103@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 31, 2007 at 05:34:06AM -0500, Jeff Garzik wrote:
> Olof Johansson wrote:
> >Driver for the PA Semi PWRficient on-chip Ethernet (1/10G)
> >
> >Basic enablement, will be complemented with performance enhancements
> >over time. PHY support will be added as well.
> >
> >Signed-off-by: Olof Johansson <olof@lixom.net>
> 
> Looks generally pretty clean, well done.

Getting better,  I really should have found alot of this on my own. Thanks
to everyone for their patience.

I added a TODO list in the driver for the things that I'll add
incrementally over time.

(I also took out some unused definitions while I was at it)

> Comments included inline...

Replies where approprate, taking out most of the code. New patch posted
separately.

> consider enums rather than #define's for constants.  they generate 
> symbols at the C level rather than cpp level, making the code more 
> readable, providing more type information to the C compiler, and making 
> symbols visible at the debugger level.
> 
> example:
> 
> enum {
> 	PAS_DMA_MAX_IF		= 40,
> 	PAS_DMA_MAX_RXCH	= 8,
> 	PAS_DMA_MAX_TXCH	= 8,
> };

That works quite OK for things like register numbers. For bitfields
I'm not so sure the compiler/debugger will have much benefit from it
though, right? It's also nice to keep the mask/shift and macro together.

I've broken out the simpler register numbers into enums. If you feel
really strongly that I should have the rest the same way I'll give it
a shot.

Also, enums are ints, right? The 64-bit fields will be hard to describe
that way.

> 
> >+static int pasemi_set_mac_addr(struct pasemi_mac *mac)
> 
> poor name.  from the context of the code reader and driver, this should 
> be "pasemi_GET_mac_addr", rather than ...set...

Set it in the structure, get it from the hardware. Yes, I was thinking
of it the other way around there.  Fixed.

> "0" is not the same as "NULL".  Use NULL where appropriate.
> 
> Then make sure your driver passes sparse checks (read 
> Documentation/sparse.txt)

Fixed, and other places where sparse complained (0x...ull on large
constants).

Only exception is the ioremap, see below.

> if feasible, logical operations are often more optimal than '%'
> 
> maybe you need something like tg3.c's NEXT_TX() ?

Nice. Yes, much better. Only drawback is that the ring size will be
compile-time (not that I have the ethtool hookups to set it now anyway).

> >+	if (unlikely(mac->rx->next_to_clean == 0 && mac->rx->next_to_fill == 
> >0))
> >+		count = mac->rx->count - 8;
> 
> why this is needed?

Added a comment before the statment why the check is needed -- both
will be 0 on the very first fill. The -8 can come out now, old workaround
that's no longer needed.

> >+		dma = pci_map_single(mac->dma_pdev, skb->data, skb->len,
> >+				     PCI_DMA_FROMDEVICE);
> 
> check for DMA mapping error

Done. However, I noticed that lots of other network drivers don't do
it. :-)

> >+	if (!spin_trylock_irqsave(&mac->tx->lock, flags))
> >+		return 0;
> 
> what prevents starvation?

Uhm, nothing. Thanks.

> >+	pci_write_config_dword(mac->iob_pdev,
> >+			       PAS_IOB_DMA_RXCH_RESET(mac->dma_rxch), reg);
> 
> is there any faster method of register reading/writing than through PCI 
> config registers?
> 
> pci_{read,write}_config_foo acquires and releases a spinlock for each 
> operation, making it rather expensive in fast path code

Yeah, I noticed lately that while it fits nice with our register structure,
it's really heavy on overhead.

It's at the top of my list for what to work on next; If it's OK with
you I'd prefer to do it incrementally after merge though.

> >+static int pasemi_mac_start_tx(struct sk_buff *skb, struct net_device
> >*dev)
> >+{
> >+	struct pasemi_mac *mac = netdev_priv(dev);
> >+	struct pasemi_mac_txring *txring;
> >+	struct pasemi_mac_buffer *info;
> >+	struct pas_dma_xct_descr *dp;
> >+	u64 flags;
> >+	dma_addr_t map;
> 
> needs locking, as mentioned elsewhere

Doh, need to protect the whole ring not just in clean. Added.

> >+	/* XXXOJN Deal with fragmented packets when larger MTU is supported 
> >*/
> 
> does this comment imply that larger MTUs make the driver go splat, or 
> does driver code elsewhere prevent the user from using an invalid MTU?

Larger MTU support is just not wired up yet (no change_mtu function). It's
on the list.

> >+	pci_write_config_dword(mac->pdev, PAS_MAC_CFG_PCFG, flags);
> 
> you have no multicast capability?

The device has it, just not hooked up in the driver. On the list.

> >+	/* The dma status structure is located in the I/O bridge, and
> >+	 * is cache coherent.
> >+	 */
> >+	if (!dma_status)
> >+		/* XXXOJN This should come from the device tree */
> >+		dma_status = __ioremap(0xfd800000, 0x1000, 0);
> 
> why __ioremap ?

As the comment says, the registers live in the I/O bridge, and they
are cache coherent. So to map them in, I use the version that (on
powerpc at least) you can specify the flags -- and I'm not specifying
_PAGE_NO_CACHE|_PAGE_GUARDED that the standard ioremap does.

Still, this makes sparse unhappy since it's still flagged as another
address space. I'm open for better ideas.


-Olof
