From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] net: ep93xx_eth: drop GFP_DMA from memory allocations
Date: Sun, 29 May 2011 12:27:42 +0100
Message-ID: <20110529112742.GA24876@n2100.arm.linux.org.uk>
References: <1306659837-23553-1-git-send-email-mika.westerberg@iki.fi> <20110529103825.GZ24876@n2100.arm.linux.org.uk> <20110529105946.GA2655@acer>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hsweeten@visionengravers.com,
	ryan@bluewatersys.com, kernel@wantstofly.org,
	linux-arm-kernel@lists.infradead.org
To: Mika Westerberg <mika.westerberg@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:46873 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751818Ab1E2L1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 May 2011 07:27:55 -0400
Content-Disposition: inline
In-Reply-To: <20110529105946.GA2655@acer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 29, 2011 at 01:59:46PM +0300, Mika Westerberg wrote:
> FYI, I just enabled DMA debugging and I've got:
> 
> [    1.980000] WARNING: at lib/dma-debug.c:911 check_sync+0x460/0x510()
> [    1.980000] NULL NULL: DMA-API: device driver tries to sync DMA memory it has not allocated [device address=0x00000000c5a11800] [size=78 bytes]

That's because of the 'allocate one buffer, map it once, then treat it
as two buffers' thing.  DMA API debugging requires that the struct
device, and device address match:

static struct dma_debug_entry *hash_bucket_find(struct hash_bucket *bucket,
                                                struct dma_debug_entry *ref)
{
        struct dma_debug_entry *entry, *ret = NULL;
        int matches = 0, match_lvl, last_lvl = 0;

        list_for_each_entry(entry, &bucket->list, list) {
                if ((entry->dev_addr != ref->dev_addr) ||
                    (entry->dev != ref->dev))
                        continue;

so the practice of using dma_sync_single_for_xxx() with partial buffers
is prohibited by this code (which I've always believed to be the right
answer.)  I've always believed that dma_sync_single_range_for_xxx() is
the correct interface for doing this kind of thing.

Others may have a different view, in which case _something_ needs to get
fixed because their view is inconsistent with the debugging code!
