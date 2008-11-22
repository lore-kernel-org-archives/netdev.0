From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 03/10] x86: add initialization code for DMA-API debugging
Date: Sat, 22 Nov 2008 10:48:07 +0100
Message-ID: <20081122094807.GK29705@8bytes.org>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com> <1227284770-19215-4-git-send-email-joerg.roedel@amd.com> <20081121174348.GB4336@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joerg Roedel <joerg.roedel@amd.com>, netdev@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	iommu@lists.linux-foundation.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 8bytes.org ([88.198.83.132]:54071 "EHLO 8bytes.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751072AbYKVJsI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Nov 2008 04:48:08 -0500
Content-Disposition: inline
In-Reply-To: <20081121174348.GB4336@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 21, 2008 at 06:43:48PM +0100, Ingo Molnar wrote:
> 
> * Joerg Roedel <joerg.roedel@amd.com> wrote:
> 
> > +static struct list_head dma_entry_hash[HASH_SIZE];
> > +
> > +/* A slab cache to allocate dma_map_entries fast */
> > +static struct kmem_cache *dma_entry_cache;
> > +
> > +/* lock to protect the data structures */
> > +static DEFINE_SPINLOCK(dma_lock);
> 
> some more generic comments about the data structure: it's main purpose 
> is to provide a mapping based on (dev,addr). There's little if any 
> cross-entry interaction - same-address+same-dev DMA is checked.
> 
> 1)
> 
> the hash:
> 
> + 	return (entry->dev_addr >> HASH_FN_SHIFT) & HASH_FN_MASK;
> 
> should mix in entry->dev as well - that way we get not just per 
> address but per device hash space separation as well.
> 
> 2)
> 
> HASH_FN_SHIFT is 1MB chunks right now - that's probably fine in 
> practice albeit perhaps a bit too small. There's seldom any coherency 
> between the physical addresses of DMA - we rarely have any real 
> (performance-relevant) physical co-location of DMA addresses beyond 4K 
> granularity. So using 1MB chunking here will discard a good deal of 
> random low bits we should be hashing on.
> 
> 3)
> 
> And the most scalable locking would be per hash bucket locking - no 
> global lock is needed. The bucket hash heads should probably be 
> cacheline sized - so we'd get one lock per bucket.

Hmm, I just had the idea of saving this data in struct device. How about
that? The locking should scale too and we can extend it easier. For
example it simplifys a per-device disable function for the checking. Or
another future feature might be leak tracing.

> This way if there's irq+DMA traffic on one CPU from one device into 
> one range of memory, and irq+DMA traffic on another CPU to another 
> device, they will map to two different hash buckets.
> 
> 4)
> 
> Plus it might be an option to make hash lookup lockless as well: 
> depending on the DMA flux we can get a lot of lookups, and taking the 
> bucket lock can be avoided, if you use RCU-safe list ops and drive the 
> refilling of the free entries pool from RCU.

Joerg
