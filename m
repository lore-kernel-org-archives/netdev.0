From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH 0/10] DMA-API debugging facility
Date: Wed, 25 Feb 2009 17:11:02 +0900
Message-ID: <1235549462.519.38.camel@macbook.infradead.org>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com>
	 <1227286492.4901.208.camel@macbook.infradead.org>
	 <20081121165722.GD1386@amd.com>
	 <1227287215.4901.213.camel@macbook.infradead.org>
	 <20081121171802.GK733@elte.hu> <20081121172046.GF1386@amd.com>
	 <1227288269.4901.222.camel@macbook.infradead.org>
	 <20081121172722.GG1386@amd.com>
	 <1233873842.8135.6.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Ingo Molnar <mingo@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org
To: Joerg Roedel <joerg.roedel@amd.com>, linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:53955 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752752AbZBYIL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 03:11:29 -0500
In-Reply-To: <1233873842.8135.6.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-02-05 at 22:44 +0000, David Woodhouse wrote:
> On Fri, 2008-11-21 at 18:27 +0100, Joerg Roedel wrote:
> > On Fri, Nov 21, 2008 at 05:24:29PM +0000, David Woodhouse wrote:
> > > On Fri, 2008-11-21 at 18:20 +0100, Joerg Roedel wrote:
> > > > Ok, I will move the generic bits to lib/ and include/linux and let
> > > > architectures decide if they want to use it.
> > > 
> > > Once you've done that, I'll try to hook it up on PowerPC to make sure it
> > > works there.
> > 
> > Ok, cool. Thanks
> 
> This builds; I haven't actually tried booting it yet. Will do that in
> the morning.

So I lied about that. Did anyone else manage...?

(Applies on top of the dma-api/debug branch of
git://git.kernel.org/pub/scm/linux/kernel/git/joro/linux-2.6-iommu)

> I'm not so fond of the way each architecture gets to define
> PREALLOC_DMA_DEBUG_ENTRIES for itself... and also call dma_debug_init(),
> for that matter. Couldn't we do that in lib/dma-debug.c directly?
> 
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
> 
> diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
> index 74cc312..11db356 100644
> --- a/arch/powerpc/Kconfig
> +++ b/arch/powerpc/Kconfig
> @@ -124,6 +124,7 @@ config PPC
>  	select USE_GENERIC_SMP_HELPERS if SMP
>  	select HAVE_OPROFILE
>  	select HAVE_SYSCALL_WRAPPERS if PPC64
> +	select HAVE_DMA_API_DEBUG
>  
>  config EARLY_PRINTK
>  	bool
> diff --git a/arch/powerpc/include/asm/dma-mapping.h b/arch/powerpc/include/asm/dma-mapping.h
> index 86cef7d..b49107a 100644
> --- a/arch/powerpc/include/asm/dma-mapping.h
> +++ b/arch/powerpc/include/asm/dma-mapping.h
> @@ -13,6 +13,7 @@
>  /* need struct page definitions */
>  #include <linux/mm.h>
>  #include <linux/scatterlist.h>
> +#include <linux/dma-debug.h>
>  #include <linux/dma-attrs.h>
>  #include <asm/io.h>
>  
> @@ -170,12 +171,17 @@ static inline dma_addr_t dma_map_single_attrs(struct device *dev,
>  					      struct dma_attrs *attrs)
>  {
>  	struct dma_mapping_ops *dma_ops = get_dma_ops(dev);
> +	dma_addr_t addr;
>  
>  	BUG_ON(!dma_ops);
>  
> -	return dma_ops->map_page(dev, virt_to_page(cpu_addr),
> +	addr = dma_ops->map_page(dev, virt_to_page(cpu_addr),
>  				 (unsigned long)cpu_addr % PAGE_SIZE, size,
>  				 direction, attrs);
> +	debug_dma_map_page(dev, virt_to_page(cpu_addr),
> +			   (unsigned long)cpu_addr & PAGE_SIZE, size,
> +			   direction, addr, true);
> +	return addr;
>  }
>  
>  static inline void dma_unmap_single_attrs(struct device *dev,
> @@ -189,6 +195,7 @@ static inline void dma_unmap_single_attrs(struct device *dev,
>  	BUG_ON(!dma_ops);
>  
>  	dma_ops->unmap_page(dev, dma_addr, size, direction, attrs);
> +	debug_dma_unmap_page(dev, dma_addr, size, direction, true);
>  }
>  
>  static inline dma_addr_t dma_map_page_attrs(struct device *dev,
> @@ -198,10 +205,13 @@ static inline dma_addr_t dma_map_page_attrs(struct device *dev,
>  					    struct dma_attrs *attrs)
>  {
>  	struct dma_mapping_ops *dma_ops = get_dma_ops(dev);
> +	dma_addr_t addr;
>  
>  	BUG_ON(!dma_ops);
>  
> -	return dma_ops->map_page(dev, page, offset, size, direction, attrs);
> +	addr = dma_ops->map_page(dev, page, offset, size, direction, attrs);
> +	debug_dma_map_page(dev, page, offset, size, direction, addr, false);
> +	return addr;
>  }
>  
>  static inline void dma_unmap_page_attrs(struct device *dev,
> @@ -215,6 +225,7 @@ static inline void dma_unmap_page_attrs(struct device *dev,
>  	BUG_ON(!dma_ops);
>  
>  	dma_ops->unmap_page(dev, dma_address, size, direction, attrs);
> +	debug_dma_unmap_page(dev, dma_address, size, direction, false);
>  }
>  
>  static inline int dma_map_sg_attrs(struct device *dev, struct scatterlist *sg,
> @@ -222,9 +233,12 @@ static inline int dma_map_sg_attrs(struct device *dev, struct scatterlist *sg,
>  				   struct dma_attrs *attrs)
>  {
>  	struct dma_mapping_ops *dma_ops = get_dma_ops(dev);
> +	int ents;
>  
>  	BUG_ON(!dma_ops);
> -	return dma_ops->map_sg(dev, sg, nents, direction, attrs);
> +	ents = dma_ops->map_sg(dev, sg, nents, direction, attrs);
> +	debug_dma_map_sg(dev, sg, ents, direction);
> +	return ents;
>  }
>  
>  static inline void dma_unmap_sg_attrs(struct device *dev,
> @@ -237,15 +251,19 @@ static inline void dma_unmap_sg_attrs(struct device *dev,
>  
>  	BUG_ON(!dma_ops);
>  	dma_ops->unmap_sg(dev, sg, nhwentries, direction, attrs);
> +	debug_dma_unmap_sg(dev, sg, nhwentries, direction);
>  }
>  
>  static inline void *dma_alloc_coherent(struct device *dev, size_t size,
>  				       dma_addr_t *dma_handle, gfp_t flag)
>  {
>  	struct dma_mapping_ops *dma_ops = get_dma_ops(dev);
> +	void *mem;
>  
>  	BUG_ON(!dma_ops);
> -	return dma_ops->alloc_coherent(dev, size, dma_handle, flag);
> +	mem = dma_ops->alloc_coherent(dev, size, dma_handle, flag);
> +	debug_dma_alloc_coherent(dev, size, *dma_handle, mem);
> +	return mem;
>  }
>  
>  static inline void dma_free_coherent(struct device *dev, size_t size,
> @@ -254,6 +272,7 @@ static inline void dma_free_coherent(struct device *dev, size_t size,
>  	struct dma_mapping_ops *dma_ops = get_dma_ops(dev);
>  
>  	BUG_ON(!dma_ops);
> +	debug_dma_free_coherent(dev, size, cpu_addr, dma_handle);
>  	dma_ops->free_coherent(dev, size, cpu_addr, dma_handle);
>  }
>  
> @@ -306,6 +325,8 @@ static inline void dma_sync_single_for_cpu(struct device *dev,
>  	struct dma_mapping_ops *dma_ops = get_dma_ops(dev);
>  
>  	BUG_ON(!dma_ops);
> +	debug_dma_sync_single_range_for_cpu(dev, dma_handle, 0,
> +					    size, direction);
>  	dma_ops->sync_single_range_for_cpu(dev, dma_handle, 0,
>  					   size, direction);
>  }
> @@ -317,6 +338,8 @@ static inline void dma_sync_single_for_device(struct device *dev,
>  	struct dma_mapping_ops *dma_ops = get_dma_ops(dev);
>  
>  	BUG_ON(!dma_ops);
> +	debug_dma_sync_single_range_for_device(dev, dma_handle,
> +					       0, size, direction);
>  	dma_ops->sync_single_range_for_device(dev, dma_handle,
>  					      0, size, direction);
>  }
> @@ -328,6 +351,7 @@ static inline void dma_sync_sg_for_cpu(struct device *dev,
>  	struct dma_mapping_ops *dma_ops = get_dma_ops(dev);
>  
>  	BUG_ON(!dma_ops);
> +	debug_dma_sync_sg_for_cpu(dev, sgl, nents, direction);
>  	dma_ops->sync_sg_for_cpu(dev, sgl, nents, direction);
>  }
>  
> @@ -338,6 +362,7 @@ static inline void dma_sync_sg_for_device(struct device *dev,
>  	struct dma_mapping_ops *dma_ops = get_dma_ops(dev);
>  
>  	BUG_ON(!dma_ops);
> +	debug_dma_sync_sg_for_device(dev, sgl, nents, direction);
>  	dma_ops->sync_sg_for_device(dev, sgl, nents, direction);
>  }
>  
> @@ -348,6 +373,8 @@ static inline void dma_sync_single_range_for_cpu(struct device *dev,
>  	struct dma_mapping_ops *dma_ops = get_dma_ops(dev);
>  
>  	BUG_ON(!dma_ops);
> +	debug_dma_sync_single_range_for_cpu(dev, dma_handle,
> +					    offset, size, direction);
>  	dma_ops->sync_single_range_for_cpu(dev, dma_handle,
>  					   offset, size, direction);
>  }
> @@ -359,6 +386,8 @@ static inline void dma_sync_single_range_for_device(struct device *dev,
>  	struct dma_mapping_ops *dma_ops = get_dma_ops(dev);
>  
>  	BUG_ON(!dma_ops);
> +	debug_dma_sync_single_range_for_device(dev, dma_handle, offset,
> +					       size, direction);
>  	dma_ops->sync_single_range_for_device(dev, dma_handle, offset,
>  					      size, direction);
>  }
> @@ -367,36 +396,46 @@ static inline void dma_sync_single_for_cpu(struct device *dev,
>  		dma_addr_t dma_handle, size_t size,
>  		enum dma_data_direction direction)
>  {
> +	debug_dma_sync_single_range_for_cpu(dev, dma_handle, 0,
> +					    size, direction);
>  }
>  
>  static inline void dma_sync_single_for_device(struct device *dev,
>  		dma_addr_t dma_handle, size_t size,
>  		enum dma_data_direction direction)
>  {
> +	debug_dma_sync_single_range_for_device(dev, dma_handle,
> +					       0, size, direction);
>  }
>  
>  static inline void dma_sync_sg_for_cpu(struct device *dev,
>  		struct scatterlist *sgl, int nents,
>  		enum dma_data_direction direction)
>  {
> +	debug_dma_sync_sg_for_cpu(dev, sgl, nents, direction);
>  }
>  
>  static inline void dma_sync_sg_for_device(struct device *dev,
>  		struct scatterlist *sgl, int nents,
>  		enum dma_data_direction direction)
>  {
> +	debug_dma_sync_sg_for_device(dev, sgl, nents, direction);
>  }
>  
>  static inline void dma_sync_single_range_for_cpu(struct device *dev,
>  		dma_addr_t dma_handle, unsigned long offset, size_t size,
>  		enum dma_data_direction direction)
>  {
> +	debug_dma_sync_single_range_for_cpu(dev, dma_handle,
> +					    offset, size, direction);
>  }
>  
>  static inline void dma_sync_single_range_for_device(struct device *dev,
>  		dma_addr_t dma_handle, unsigned long offset, size_t size,
>  		enum dma_data_direction direction)
>  {
> +	debug_dma_sync_single_range_for_device(dev, dma_handle, offset,
> +					       size, direction);
>  }
>  #endif
>  
> diff --git a/arch/powerpc/kernel/dma.c b/arch/powerpc/kernel/dma.c
> index 1c5c8a6..90bb016 100644
> --- a/arch/powerpc/kernel/dma.c
> +++ b/arch/powerpc/kernel/dma.c
> @@ -6,7 +6,9 @@
>   */
>  
>  #include <linux/device.h>
> +#include <linux/dma-debug.h>
>  #include <linux/dma-mapping.h>
> +#include <linux/init.h>
>  #include <asm/bug.h>
>  #include <asm/abs_addr.h>
>  
> @@ -156,3 +158,12 @@ struct dma_mapping_ops dma_direct_ops = {
>  #endif
>  };
>  EXPORT_SYMBOL(dma_direct_ops);
> +
> +#define PREALLOC_DMA_DEBUG_ENTRIES		8192
> +
> +static int __init dma_debug_init_ppc(void)
> +{
> +	dma_debug_init(PREALLOC_DMA_DEBUG_ENTRIES);
> +	return 0;
> +}
> +fs_initcall(dma_debug_init_ppc);
> 

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

