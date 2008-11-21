From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 03/10] x86: add initialization code for DMA-API
	debugging
Date: Fri, 21 Nov 2008 18:43:48 +0100
Message-ID: <20081121174348.GB4336@elte.hu>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com> <1227284770-19215-4-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org
To: Joerg Roedel <joerg.roedel@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:40403 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752887AbYKURoL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 12:44:11 -0500
Content-Disposition: inline
In-Reply-To: <1227284770-19215-4-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Joerg Roedel <joerg.roedel@amd.com> wrote:

> +static struct list_head dma_entry_hash[HASH_SIZE];
> +
> +/* A slab cache to allocate dma_map_entries fast */
> +static struct kmem_cache *dma_entry_cache;
> +
> +/* lock to protect the data structures */
> +static DEFINE_SPINLOCK(dma_lock);

some more generic comments about the data structure: it's main purpose 
is to provide a mapping based on (dev,addr). There's little if any 
cross-entry interaction - same-address+same-dev DMA is checked.

1)

the hash:

+ 	return (entry->dev_addr >> HASH_FN_SHIFT) & HASH_FN_MASK;

should mix in entry->dev as well - that way we get not just per 
address but per device hash space separation as well.

2)

HASH_FN_SHIFT is 1MB chunks right now - that's probably fine in 
practice albeit perhaps a bit too small. There's seldom any coherency 
between the physical addresses of DMA - we rarely have any real 
(performance-relevant) physical co-location of DMA addresses beyond 4K 
granularity. So using 1MB chunking here will discard a good deal of 
random low bits we should be hashing on.

3)

And the most scalable locking would be per hash bucket locking - no 
global lock is needed. The bucket hash heads should probably be 
cacheline sized - so we'd get one lock per bucket.

This way if there's irq+DMA traffic on one CPU from one device into 
one range of memory, and irq+DMA traffic on another CPU to another 
device, they will map to two different hash buckets.

4)

Plus it might be an option to make hash lookup lockless as well: 
depending on the DMA flux we can get a lot of lookups, and taking the 
bucket lock can be avoided, if you use RCU-safe list ops and drive the 
refilling of the free entries pool from RCU.

	Ingo
