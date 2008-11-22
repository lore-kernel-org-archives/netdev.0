From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: [PATCH 07/10] x86: add checks for alloc/free_coherent code
Date: Sat, 22 Nov 2008 12:27:42 +0900
Message-ID: <20081122120902Y.fujita.tomonori@lab.ntt.co.jp>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com>
	<1227284770-19215-8-git-send-email-joerg.roedel@amd.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@redhat.com, tglx@linutronix.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, iommu@lists.linux-foundation.org
To: joerg.roedel@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:38469 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753934AbYKVD3u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 22:29:50 -0500
In-Reply-To: <1227284770-19215-8-git-send-email-joerg.roedel@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Nov 2008 17:26:07 +0100
Joerg Roedel <joerg.roedel@amd.com> wrote:

> Impact: detect bugs in alloc/free_coherent usage
> 
> Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>
> ---
>  arch/x86/include/asm/dma-mapping.h |   10 +++++-
>  arch/x86/include/asm/dma_debug.h   |   20 +++++++++++++
>  arch/x86/kernel/pci-dma-debug.c    |   56 ++++++++++++++++++++++++++++++++++++
>  3 files changed, 84 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
> index c7bdb75..2893adb 100644
> --- a/arch/x86/include/asm/dma-mapping.h
> +++ b/arch/x86/include/asm/dma-mapping.h
> @@ -304,8 +304,12 @@ dma_alloc_coherent(struct device *dev, size_t size, dma_addr_t *dma_handle,
>  	if (!ops->alloc_coherent)
>  		return NULL;
>  
> -	return ops->alloc_coherent(dev, size, dma_handle,
> -				   dma_alloc_coherent_gfp_flags(dev, gfp));
> +	memory = ops->alloc_coherent(dev, size, dma_handle,
> +				     dma_alloc_coherent_gfp_flags(dev, gfp));
> +
> +	debug_alloc_coherent(dev, size, *dma_handle, memory);
> +
> +	return memory;
>  }
>  
>  static inline void dma_free_coherent(struct device *dev, size_t size,
> @@ -320,6 +324,8 @@ static inline void dma_free_coherent(struct device *dev, size_t size,
>  
>  	if (ops->free_coherent)
>  		ops->free_coherent(dev, size, vaddr, bus);
> +
> +	debug_free_coherent(dev, size, vaddr, bus);
>  }
>  
>  #endif
> diff --git a/arch/x86/include/asm/dma_debug.h b/arch/x86/include/asm/dma_debug.h
> index ff06d1c..7245e27 100644
> --- a/arch/x86/include/asm/dma_debug.h
> +++ b/arch/x86/include/asm/dma_debug.h
> @@ -59,6 +59,14 @@ extern
>  void debug_unmap_sg(struct device *dev, struct scatterlist *sglist,
>  		    int nelems, int dir);
>  
> +extern
> +void debug_alloc_coherent(struct device *dev, size_t size,
> +			  dma_addr_t dma_addr, void *virt);
> +
> +extern
> +void debug_free_coherent(struct device *dev, size_t size,
> +			 void *virt, dma_addr_t addr);
> +
>  #else /* CONFIG_DMA_API_DEBUG */
>  
>  static inline
> @@ -90,6 +98,18 @@ void debug_unmap_sg(struct device *dev, struct scatterlist *sglist,
>  {
>  }
>  
> +static inline
> +void debug_alloc_coherent(struct device *dev, size_t size,
> +			  dma_addr_t dma_addr, void *virt)
> +{
> +}
> +
> +static inline
> +void debug_free_coherent(struct device *dev, size_t size,
> +			 void *virt, dma_addr_t addr)
> +{
> +}
> +
>  #endif /* CONFIG_DMA_API_DEBUG */
>  
>  #endif /* __ASM_X86_DMA_DEBUG */
> diff --git a/arch/x86/kernel/pci-dma-debug.c b/arch/x86/kernel/pci-dma-debug.c
> index 55ef69a..db5ef9a 100644
> --- a/arch/x86/kernel/pci-dma-debug.c
> +++ b/arch/x86/kernel/pci-dma-debug.c
> @@ -352,3 +352,59 @@ void debug_unmap_sg(struct device *dev, struct scatterlist *sglist,
>  }
>  EXPORT_SYMBOL(debug_unmap_sg);
>  
> +void debug_alloc_coherent(struct device *dev, size_t size,
> +			  dma_addr_t dma_addr, void *virt)
> +{
> +	unsigned long flags;
> +	struct dma_debug_entry *entry;
> +
> +	if (dma_addr == bad_dma_address)
> +		return;
> +
> +	entry = dma_entry_alloc();
> +	if (!entry)
> +		return;
> +
> +	entry->type      = DMA_DEBUG_COHERENT;
> +	entry->dev       = dev;
> +	entry->cpu_addr  = virt;
> +	entry->size      = size;
> +	entry->dev_addr  = dma_addr;
> +	entry->direction = DMA_BIDIRECTIONAL;
> +
> +	spin_lock_irqsave(&dma_lock, flags);
> +	add_dma_entry(entry);
> +	spin_unlock_irqrestore(&dma_lock, flags);
> +}
> +EXPORT_SYMBOL(debug_alloc_coherent);

Can you clean up the duplication in debug_map_single, debug_map_sg,
and debug_alloc_coherent? The higher-level helper functions might
help.


> +void debug_free_coherent(struct device *dev, size_t size,
> +			 void *virt, dma_addr_t addr)
> +{
> +	unsigned long flags;
> +	struct dma_debug_entry ref = {
> +		.type = DMA_DEBUG_COHERENT,
> +		.dev = dev,
> +		.cpu_addr = virt,
> +		.dev_addr = addr,
> +		.size = size,
> +		.direction = DMA_BIDIRECTIONAL,
> +	};
> +	struct dma_debug_entry *entry;
> +
> +	if (addr == bad_dma_address)
> +		return;
> +
> +	spin_lock_irqsave(&dma_lock, flags);
> +
> +	entry = find_dma_entry(&ref);
> +
> +	if (check_unmap(&ref, entry)) {
> +		remove_dma_entry(entry);
> +		dma_entry_free(entry);
> +	}
> +
> +	spin_unlock_irqrestore(&dma_lock, flags);
> +}
> +EXPORT_SYMBOL(debug_free_coherent);

Ditto.
