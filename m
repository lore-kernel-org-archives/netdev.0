From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 03/10] x86: add initialization code for DMA-API debugging
Date: Sat, 22 Nov 2008 10:40:32 +0100
Message-ID: <20081122094032.GJ29705@8bytes.org>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com> <1227284770-19215-4-git-send-email-joerg.roedel@amd.com> <20081122120058I.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: joerg.roedel@amd.com, netdev@vger.kernel.org, tglx@linutronix.de,
	mingo@redhat.com, linux-kernel@vger.kernel.org,
	iommu@lists.linux-foundation.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 8bytes.org ([88.198.83.132]:42421 "EHLO 8bytes.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751072AbYKVJke (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Nov 2008 04:40:34 -0500
Content-Disposition: inline
In-Reply-To: <20081122120058I.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 22, 2008 at 12:27:41PM +0900, FUJITA Tomonori wrote:
> On Fri, 21 Nov 2008 17:26:03 +0100
> Joerg Roedel <joerg.roedel@amd.com> wrote:
> 
> > Impact: creates necessary data structures for DMA-API debugging
> > 
> > Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>
> > ---
> >  arch/x86/include/asm/dma-mapping.h |    1 +
> >  arch/x86/include/asm/dma_debug.h   |   14 +++++
> >  arch/x86/kernel/Makefile           |    2 +
> >  arch/x86/kernel/pci-dma-debug.c    |  111 ++++++++++++++++++++++++++++++++++++
> >  arch/x86/kernel/pci-dma.c          |    2 +
> >  5 files changed, 130 insertions(+), 0 deletions(-)
> >  create mode 100644 arch/x86/kernel/pci-dma-debug.c
> > 
> > diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
> > index 7f225a4..83d7b7d 100644
> > --- a/arch/x86/include/asm/dma-mapping.h
> > +++ b/arch/x86/include/asm/dma-mapping.h
> > @@ -9,6 +9,7 @@
> >  #include <linux/scatterlist.h>
> >  #include <asm/io.h>
> >  #include <asm/swiotlb.h>
> > +#include <asm/dma_debug.h>
> >  #include <asm-generic/dma-coherent.h>
> >  
> >  extern dma_addr_t bad_dma_address;
> > diff --git a/arch/x86/include/asm/dma_debug.h b/arch/x86/include/asm/dma_debug.h
> > index d79f024..f2c3d53 100644
> > --- a/arch/x86/include/asm/dma_debug.h
> > +++ b/arch/x86/include/asm/dma_debug.h
> > @@ -38,4 +38,18 @@ struct dma_debug_entry {
> >  	int direction;
> >  };
> >  
> > +#ifdef CONFIG_DMA_API_DEBUG
> > +
> > +extern
> > +void dma_debug_init(void);
> > +
> > +#else /* CONFIG_DMA_API_DEBUG */
> > +
> > +static inline
> > +void dma_debug_init(void)
> > +{
> > +}
> > +
> > +#endif /* CONFIG_DMA_API_DEBUG */
> > +
> >  #endif /* __ASM_X86_DMA_DEBUG */
> > diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
> > index e489ff9..6271cd2 100644
> > --- a/arch/x86/kernel/Makefile
> > +++ b/arch/x86/kernel/Makefile
> > @@ -105,6 +105,8 @@ microcode-$(CONFIG_MICROCODE_INTEL)	+= microcode_intel.o
> >  microcode-$(CONFIG_MICROCODE_AMD)	+= microcode_amd.o
> >  obj-$(CONFIG_MICROCODE)			+= microcode.o
> >  
> > +obj-$(CONFIG_DMA_API_DEBUG)             += pci-dma-debug.o
> > +
> >  ###
> >  # 64 bit specific files
> >  ifeq ($(CONFIG_X86_64),y)
> > diff --git a/arch/x86/kernel/pci-dma-debug.c b/arch/x86/kernel/pci-dma-debug.c
> > new file mode 100644
> > index 0000000..c2d3408
> > --- /dev/null
> > +++ b/arch/x86/kernel/pci-dma-debug.c
> > @@ -0,0 +1,111 @@
> > +/*
> > + * Copyright (C) 2008 Advanced Micro Devices, Inc.
> > + *
> > + * Author: Joerg Roedel <joerg.roedel@amd.com>
> > + *
> > + * This program is free software; you can redistribute it and/or modify it
> > + * under the terms of the GNU General Public License version 2 as published
> > + * by the Free Software Foundation.
> > + *
> > + * This program is distributed in the hope that it will be useful,
> > + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> > + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> > + * GNU General Public License for more details.
> > + *
> > + * You should have received a copy of the GNU General Public License
> > + * along with this program; if not, write to the Free Software
> > + * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
> > + */
> > +
> > +#include <linux/types.h>
> > +#include <linux/scatterlist.h>
> > +#include <linux/list.h>
> > +#include <linux/slab.h>
> > +#include <linux/spinlock.h>
> > +#include <linux/module.h>
> > +#include <linux/hardirq.h>
> > +#include <linux/dma-mapping.h>
> > +#include <asm/bug.h>
> > +#include <asm/dma-mapping.h>
> > +#include <asm/dma_debug.h>
> > +
> > +#define HASH_SIZE 256
> > +#define HASH_FN_SHIFT 20
> > +#define HASH_FN_MASK 0xffULL
> > +
> > +/* Hash list to save the allocated dma addresses */
> > +static struct list_head dma_entry_hash[HASH_SIZE];
> > +
> > +/* A slab cache to allocate dma_map_entries fast */
> > +static struct kmem_cache *dma_entry_cache;
> > +
> > +/* lock to protect the data structures */
> > +static DEFINE_SPINLOCK(dma_lock);
> > +
> > +static int hash_fn(struct dma_debug_entry *entry)
> > +{
> > +	/*
> > +	 * Hash function is based on the dma address.
> > +	 * We use bits 20-27 here as the index into the hash
> > +	 */
> > +	BUG_ON(entry->dev_addr == bad_dma_address);
> 
> 'bad_dma_address' is x86 specific. You already found it though.

Interesting. Is there another value for dma_addr_t which drivers can
check for to find out if a dma-api operation failed?

Joerg
