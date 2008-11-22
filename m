From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: [PATCH 03/10] x86: add initialization code for DMA-API
 debugging
Date: Sat, 22 Nov 2008 12:27:41 +0900
Message-ID: <20081122120058I.fujita.tomonori@lab.ntt.co.jp>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com>
	<1227284770-19215-4-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@redhat.com, tglx@linutronix.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, iommu@lists.linux-foundation.org
To: joerg.roedel@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:38480 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754081AbYKVDaQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 22:30:16 -0500
In-Reply-To: <1227284770-19215-4-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Nov 2008 17:26:03 +0100
Joerg Roedel <joerg.roedel@amd.com> wrote:

> Impact: creates necessary data structures for DMA-API debugging
> 
> Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>
> ---
>  arch/x86/include/asm/dma-mapping.h |    1 +
>  arch/x86/include/asm/dma_debug.h   |   14 +++++
>  arch/x86/kernel/Makefile           |    2 +
>  arch/x86/kernel/pci-dma-debug.c    |  111 ++++++++++++++++++++++++++++++++++++
>  arch/x86/kernel/pci-dma.c          |    2 +
>  5 files changed, 130 insertions(+), 0 deletions(-)
>  create mode 100644 arch/x86/kernel/pci-dma-debug.c
> 
> diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
> index 7f225a4..83d7b7d 100644
> --- a/arch/x86/include/asm/dma-mapping.h
> +++ b/arch/x86/include/asm/dma-mapping.h
> @@ -9,6 +9,7 @@
>  #include <linux/scatterlist.h>
>  #include <asm/io.h>
>  #include <asm/swiotlb.h>
> +#include <asm/dma_debug.h>
>  #include <asm-generic/dma-coherent.h>
>  
>  extern dma_addr_t bad_dma_address;
> diff --git a/arch/x86/include/asm/dma_debug.h b/arch/x86/include/asm/dma_debug.h
> index d79f024..f2c3d53 100644
> --- a/arch/x86/include/asm/dma_debug.h
> +++ b/arch/x86/include/asm/dma_debug.h
> @@ -38,4 +38,18 @@ struct dma_debug_entry {
>  	int direction;
>  };
>  
> +#ifdef CONFIG_DMA_API_DEBUG
> +
> +extern
> +void dma_debug_init(void);
> +
> +#else /* CONFIG_DMA_API_DEBUG */
> +
> +static inline
> +void dma_debug_init(void)
> +{
> +}
> +
> +#endif /* CONFIG_DMA_API_DEBUG */
> +
>  #endif /* __ASM_X86_DMA_DEBUG */
> diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
> index e489ff9..6271cd2 100644
> --- a/arch/x86/kernel/Makefile
> +++ b/arch/x86/kernel/Makefile
> @@ -105,6 +105,8 @@ microcode-$(CONFIG_MICROCODE_INTEL)	+= microcode_intel.o
>  microcode-$(CONFIG_MICROCODE_AMD)	+= microcode_amd.o
>  obj-$(CONFIG_MICROCODE)			+= microcode.o
>  
> +obj-$(CONFIG_DMA_API_DEBUG)             += pci-dma-debug.o
> +
>  ###
>  # 64 bit specific files
>  ifeq ($(CONFIG_X86_64),y)
> diff --git a/arch/x86/kernel/pci-dma-debug.c b/arch/x86/kernel/pci-dma-debug.c
> new file mode 100644
> index 0000000..c2d3408
> --- /dev/null
> +++ b/arch/x86/kernel/pci-dma-debug.c
> @@ -0,0 +1,111 @@
> +/*
> + * Copyright (C) 2008 Advanced Micro Devices, Inc.
> + *
> + * Author: Joerg Roedel <joerg.roedel@amd.com>
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of the GNU General Public License version 2 as published
> + * by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
> + */
> +
> +#include <linux/types.h>
> +#include <linux/scatterlist.h>
> +#include <linux/list.h>
> +#include <linux/slab.h>
> +#include <linux/spinlock.h>
> +#include <linux/module.h>
> +#include <linux/hardirq.h>
> +#include <linux/dma-mapping.h>
> +#include <asm/bug.h>
> +#include <asm/dma-mapping.h>
> +#include <asm/dma_debug.h>
> +
> +#define HASH_SIZE 256
> +#define HASH_FN_SHIFT 20
> +#define HASH_FN_MASK 0xffULL
> +
> +/* Hash list to save the allocated dma addresses */
> +static struct list_head dma_entry_hash[HASH_SIZE];
> +
> +/* A slab cache to allocate dma_map_entries fast */
> +static struct kmem_cache *dma_entry_cache;
> +
> +/* lock to protect the data structures */
> +static DEFINE_SPINLOCK(dma_lock);
> +
> +static int hash_fn(struct dma_debug_entry *entry)
> +{
> +	/*
> +	 * Hash function is based on the dma address.
> +	 * We use bits 20-27 here as the index into the hash
> +	 */
> +	BUG_ON(entry->dev_addr == bad_dma_address);

'bad_dma_address' is x86 specific. You already found it though.
