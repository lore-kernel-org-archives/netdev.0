From: Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v2 4/4] dma debug: introduce debug_dma_assert_idle()
Date: Fri, 10 Jan 2014 18:35:13 -0800
Message-ID: <CAPcyv4h8nsa9OW1bEokmShf_5CnA+0seeCtOTg_jYuBER28MgQ@mail.gmail.com>
References: <20140109201157.28381.94057.stgit@viggo.jf.intel.com>
	<20140109201657.28381.9305.stgit@viggo.jf.intel.com>
	<20140109163820.ddbaaab9fdb2222c92ec3d78@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "dmaengine@vger.kernel.org" <dmaengine@vger.kernel.org>,
	Vinod Koul <vinod.koul@intel.com>,
	Netdev <netdev@vger.kernel.org>, Joerg Roedel <joro@8bytes.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	James Bottomley <JBottomley@parallels.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140109163820.ddbaaab9fdb2222c92ec3d78@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 9, 2014 at 4:38 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Thu, 09 Jan 2014 12:17:26 -0800 Dan Williams <dan.j.williams@intel.com> wrote:
>
>> Record actively mapped pages and provide an api for asserting a given
>> page is dma inactive before execution proceeds.  Placing
>> debug_dma_assert_idle() in cow_user_page() flagged the violation of the
>> dma-api in the NET_DMA implementation (see commit 77873803363c "net_dma:
>> mark broken").
>>
>> --- a/include/linux/dma-debug.h
>> +++ b/include/linux/dma-debug.h
>> @@ -185,4 +185,10 @@ static inline void debug_dma_dump_mappings(struct device *dev)
>>
>>  #endif /* CONFIG_DMA_API_DEBUG */
>>
>> +#ifdef CONFIG_DMA_VS_CPU_DEBUG
>> +extern void debug_dma_assert_idle(struct page *page);
>> +#else
>> +static inline void debug_dma_assert_idle(struct page *page) { }
>
> Surely this breaks the build when CONFIG_DMA_VS_CPU_DEBUG=n?
> lib/dma-debug.c is missing the necessary "#ifdef
> CONFIG_DMA_VS_CPU_DEBUG"s.

facepalm

> Do we really need this config setting anyway?  What goes bad if we
> permanently enable this subfeature when dma debugging is enabled?

I did want to provide notification/description of this extra check,
but I'll go ahead and fold it into the DMA_API_DEBUG description.

The only thing that potentially goes bad is no longer having hard
expectation of memory consumption.  Before the patch it's a simple
sizeof(struct dma_debug_entry) * PREALLOC_DMA_DEBUG_ENTRIES, after the
patch it's variable size of the radix tree based on sparseness and
variable based on the number of pages included in each dma_map_sg
call.  The testing with NET_DMA did not involve dma_map_sg calls

>> ...
>>
>> index d87a17a819d0..f67ae111cd2f 100644
>> --- a/lib/dma-debug.c
>> +++ b/lib/dma-debug.c
>> @@ -57,7 +57,8 @@ struct dma_debug_entry {
>>       struct list_head list;
>>       struct device    *dev;
>>       int              type;
>> -     phys_addr_t      paddr;
>> +     unsigned long    pfn;
>> +     size_t           offset;
>
> Some documentation for the fields would be nice.  offset of what
> relative to what, in what units?

This is the same 'offset' passed to dma_map_page(), will document.

>
>>       u64              dev_addr;
>>       u64              size;
>>       int              direction;
>> @@ -372,6 +373,11 @@ static void hash_bucket_del(struct dma_debug_entry *entry)
>>       list_del(&entry->list);
>>  }
>>
>>
>> ...
>>
>>
>> +/* memory usage is constrained by the maximum number of available
>> + * dma-debug entries
>> + */
>
> A brief design overview would be useful.  What goes in tree, how is it
> indexed, when and why do we add/remove/test items, etc.
>

...added this documentation to dma_active_pfn for the next revision.

/*
 * For each page mapped (initial page in the case of
 * dma_alloc_coherent/dma_map_{single|page}, or each page in a
 * scatterlist) insert into this tree using the pfn as the key. At
 * dma_unmap_{single|sg|page} or dma_free_coherent delete the entry.  If
 * the pfn already exists at insertion time add a tag as a reference
 * count for the overlapping mappings.  For now the overlap tracking
 * just ensures that 'unmaps' balance 'maps' before marking the pfn
 * idle, but we should also be flagging overlaps as an API violation.
 *
 * Memory usage is mostly constrained by the maximum number of available
 * dma-debug entries.  In the case of dma_map_{single|page} and
 * dma_alloc_coherent there is only one dma_debug_entry and one pfn to
 * track per each of these calls.  dma_map_sg(), on the other hand,
 * consumes a single dma_debug_entry, but inserts 'nents' entries into
 * the tree.
 *
 * At any time debug_dma_assert_idle() can be called to trigger a
 * warning if the given page is in the active set.
 */


>> +static RADIX_TREE(dma_active_pfn, GFP_NOWAIT);
>> +static DEFINE_SPINLOCK(radix_lock);
>> +
>> +static void __active_pfn_inc_overlap(struct dma_debug_entry *entry)
>> +{
>> +     unsigned long pfn = entry->pfn;
>> +     int i;
>> +
>> +     for (i = 0; i < RADIX_TREE_MAX_TAGS; i++)
>> +             if (radix_tree_tag_get(&dma_active_pfn, pfn, i) == 0) {
>> +                     radix_tree_tag_set(&dma_active_pfn, pfn, i);
>> +                     return;
>> +             }
>> +     pr_debug("DMA-API: max overlap count (%d) reached for pfn 0x%lx\n",
>> +              RADIX_TREE_MAX_TAGS, pfn);
>> +}
>> +
>>
>> ...
>>
>> +void debug_dma_assert_idle(struct page *page)
>> +{
>> +     unsigned long flags;
>> +     struct dma_debug_entry *entry;
>> +
>> +     if (!page)
>> +             return;
>> +
>> +     spin_lock_irqsave(&radix_lock, flags);
>> +     entry = radix_tree_lookup(&dma_active_pfn, page_to_pfn(page));
>> +     spin_unlock_irqrestore(&radix_lock, flags);
>> +
>> +     if (!entry)
>> +             return;
>> +
>> +     err_printk(entry->dev, entry,
>> +                "DMA-API: cpu touching an active dma mapped page "
>> +                "[pfn=0x%lx]\n", entry->pfn);
>> +}
>> +EXPORT_SYMBOL_GPL(debug_dma_assert_idle);
>
> The export isn't needed for mm/memory.c

True, it can wait until other call sites arise.

Thanks Andrew.
