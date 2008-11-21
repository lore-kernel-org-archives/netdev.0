From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 03/10] x86: add initialization code for DMA-API
	debugging
Date: Fri, 21 Nov 2008 18:19:52 +0100
Message-ID: <20081121171952.GL733@elte.hu>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com> <1227284770-19215-4-git-send-email-joerg.roedel@amd.com> <20081121165628.GD733@elte.hu> <20081121171004.GE1386@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org
To: Joerg Roedel <joerg.roedel@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:49781 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753858AbYKURUo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 12:20:44 -0500
Content-Disposition: inline
In-Reply-To: <20081121171004.GE1386@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Joerg Roedel <joerg.roedel@amd.com> wrote:

> On Fri, Nov 21, 2008 at 05:56:28PM +0100, Ingo Molnar wrote:
> > > +	return (entry->dev_addr >> HASH_FN_SHIFT) & HASH_FN_MASK;
> > > +}
> > > +
> > > +static struct dma_debug_entry *dma_entry_alloc(void)
> > > +{
> > > +	gfp_t gfp = GFP_KERNEL | __GFP_ZERO;
> > > +
> > > +	if (in_atomic())
> > > +		gfp |= GFP_ATOMIC;
> > > +
> > > +	return kmem_cache_alloc(dma_entry_cache, gfp);
> > 
> > hm. that slab allocation in the middle of DMA mapping ops makes me a 
> > bit nervous. the DMA mapping ops are generally rather atomic.
> > 
> > and in_atomic() check there is a bug on !PREEMPT kernels, so it wont 
> > fly.
> 
> I am not sure I understand this correctly. You say the check for 
> in_atomic() will break on !PREEMPT kernels?

Correct. There is no check to be able to tell whether we can schedule 
or not. I.e. on !PREEMPT your patches will crash and burn.

> > We dont have a gfp flag passed in as all the DMA mapping APIs 
> > really expect all allocations having been done in advance already.
> 
> Hmm, I can change the code to pre-allocate a certain (configurable?) 
> number of these entries and disble the checking if we run out of it.

yeah, that's a good approach too - that's what lockdep does. Perhaps 
make the max entries nr a Kconfig entity - so it can be tuned up/down 
depending on what type of iommu scheme is enabled.

	Ingo
