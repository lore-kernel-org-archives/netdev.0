From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 4/4] dma debug: introduce debug_dma_assert_idle()
Date: Thu, 9 Jan 2014 16:38:20 -0800
Message-ID: <20140109163820.ddbaaab9fdb2222c92ec3d78@linux-foundation.org>
References: <20140109201157.28381.94057.stgit@viggo.jf.intel.com>
	<20140109201657.28381.9305.stgit@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dmaengine@vger.kernel.org, Vinod Koul <vinod.koul@intel.com>,
	netdev@vger.kernel.org, Joerg Roedel <joro@8bytes.org>,
	linux-kernel@vger.kernel.org,
	James Bottomley <JBottomley@Parallels.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>
To: Dan Williams <dan.j.williams@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140109201657.28381.9305.stgit@viggo.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 09 Jan 2014 12:17:26 -0800 Dan Williams <dan.j.williams@intel.com> wrote:

> Record actively mapped pages and provide an api for asserting a given
> page is dma inactive before execution proceeds.  Placing
> debug_dma_assert_idle() in cow_user_page() flagged the violation of the
> dma-api in the NET_DMA implementation (see commit 77873803363c "net_dma:
> mark broken").
> 
> --- a/include/linux/dma-debug.h
> +++ b/include/linux/dma-debug.h
> @@ -185,4 +185,10 @@ static inline void debug_dma_dump_mappings(struct device *dev)
>  
>  #endif /* CONFIG_DMA_API_DEBUG */
>  
> +#ifdef CONFIG_DMA_VS_CPU_DEBUG
> +extern void debug_dma_assert_idle(struct page *page);
> +#else
> +static inline void debug_dma_assert_idle(struct page *page) { }

Surely this breaks the build when CONFIG_DMA_VS_CPU_DEBUG=n? 
lib/dma-debug.c is missing the necessary "#ifdef
CONFIG_DMA_VS_CPU_DEBUG"s.

Do we really need this config setting anyway?  What goes bad if we
permanently enable this subfeature when dma debugging is enabled?

>
> ...
>
> index d87a17a819d0..f67ae111cd2f 100644
> --- a/lib/dma-debug.c
> +++ b/lib/dma-debug.c
> @@ -57,7 +57,8 @@ struct dma_debug_entry {
>  	struct list_head list;
>  	struct device    *dev;
>  	int              type;
> -	phys_addr_t      paddr;
> +	unsigned long	 pfn;
> +	size_t		 offset;

Some documentation for the fields would be nice.  offset of what
relative to what, in what units?

>  	u64              dev_addr;
>  	u64              size;
>  	int              direction;
> @@ -372,6 +373,11 @@ static void hash_bucket_del(struct dma_debug_entry *entry)
>  	list_del(&entry->list);
>  }
>  
>
> ...
>
>  
> +/* memory usage is constrained by the maximum number of available
> + * dma-debug entries
> + */

A brief design overview would be useful.  What goes in tree, how is it
indexed, when and why do we add/remove/test items, etc.

> +static RADIX_TREE(dma_active_pfn, GFP_NOWAIT);
> +static DEFINE_SPINLOCK(radix_lock);
> +
> +static void __active_pfn_inc_overlap(struct dma_debug_entry *entry)
> +{
> +	unsigned long pfn = entry->pfn;
> +	int i;
> +
> +	for (i = 0; i < RADIX_TREE_MAX_TAGS; i++)
> +		if (radix_tree_tag_get(&dma_active_pfn, pfn, i) == 0) {
> +			radix_tree_tag_set(&dma_active_pfn, pfn, i);
> +			return;
> +		}
> +	pr_debug("DMA-API: max overlap count (%d) reached for pfn 0x%lx\n",
> +		 RADIX_TREE_MAX_TAGS, pfn);
> +}
> +
>
> ...
>
> +void debug_dma_assert_idle(struct page *page)
> +{
> +	unsigned long flags;
> +	struct dma_debug_entry *entry;
> +
> +	if (!page)
> +		return;
> +
> +	spin_lock_irqsave(&radix_lock, flags);
> +	entry = radix_tree_lookup(&dma_active_pfn, page_to_pfn(page));
> +	spin_unlock_irqrestore(&radix_lock, flags);
> +
> +	if (!entry)
> +		return;
> +
> +	err_printk(entry->dev, entry,
> +		   "DMA-API: cpu touching an active dma mapped page "
> +		   "[pfn=0x%lx]\n", entry->pfn);
> +}
> +EXPORT_SYMBOL_GPL(debug_dma_assert_idle);

The export isn't needed for mm/memory.c

>
> ...
>
