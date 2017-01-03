From: Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [RFC PATCH 2/4] page_pool: basic implementation of page_pool
Date: Tue, 3 Jan 2017 17:07:49 +0100
Message-ID: <52478d40-8c34-4354-c9d8-286020eb26a6@suse.cz>
References: <20161220132444.18788.50875.stgit@firesoul>
 <20161220132817.18788.64726.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: willemdebruijn.kernel@gmail.com, netdev@vger.kernel.org,
 john.fastabend@gmail.com, Saeed Mahameed <saeedm@mellanox.com>,
 bjorn.topel@intel.com, Alexei Starovoitov <alexei.starovoitov@gmail.com>,
 Tariq Toukan <tariqt@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org,
 Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20161220132817.18788.64726.stgit@firesoul>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 12/20/2016 02:28 PM, Jesper Dangaard Brouer wrote:
> The focus in this patch is getting the API around page_pool figured out.
>
> The internal data structures for returning page_pool pages is not optimal.
> This implementation use ptr_ring for recycling, which is known not to scale
> in case of multiple remote CPUs releasing/returning pages.

Just few very quick impressions...

> A bulking interface into the page allocator is also left for later. (This
> requires cooperation will Mel Gorman, who just send me some PoC patches for this).
> ---
>  include/linux/mm.h             |    6 +
>  include/linux/mm_types.h       |   11 +
>  include/linux/page-flags.h     |   13 +
>  include/linux/page_pool.h      |  158 +++++++++++++++
>  include/linux/skbuff.h         |    2
>  include/trace/events/mmflags.h |    3
>  mm/Makefile                    |    3
>  mm/page_alloc.c                |   10 +
>  mm/page_pool.c                 |  423 ++++++++++++++++++++++++++++++++++++++++
>  mm/slub.c                      |    4
>  10 files changed, 627 insertions(+), 6 deletions(-)
>  create mode 100644 include/linux/page_pool.h
>  create mode 100644 mm/page_pool.c
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 4424784ac374..11b4d8fb280b 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -23,6 +23,7 @@
>  #include <linux/page_ext.h>
>  #include <linux/err.h>
>  #include <linux/page_ref.h>
> +#include <linux/page_pool.h>
>
>  struct mempolicy;
>  struct anon_vma;
> @@ -765,6 +766,11 @@ static inline void put_page(struct page *page)
>  {
>  	page = compound_head(page);
>
> +	if (PagePool(page)) {
> +		page_pool_put_page(page);
> +		return;
> +	}

Can't say I'm thrilled about a new page flag and a test in put_page(). I don't 
know the full life cycle here, but isn't it that these pages will be 
specifically allocated and used in page pool aware drivers, so maybe they can be 
also specifically freed there without hooking to the generic page refcount 
mechanism?

> +
>  	if (put_page_testzero(page))
>  		__put_page(page);
>
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 08d947fc4c59..c74dea967f99 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -47,6 +47,12 @@ struct page {
>  	unsigned long flags;		/* Atomic flags, some possibly
>  					 * updated asynchronously */
>  	union {
> +		/* DISCUSS: Considered moving page_pool pointer here,
> +		 * but I'm unsure if 'mapping' is needed for userspace
> +		 * mapping the page, as this is a use-case the
> +		 * page_pool need to support in the future. (Basically
> +		 * mapping a NIC RX ring into userspace).

I think so, but might be wrong here. In any case mapping usually goes with 
index, and you put dma_addr in union with index below...

> +		 */
>  		struct address_space *mapping;	/* If low bit clear, points to
>  						 * inode address_space, or NULL.
>  						 * If page mapped as anonymous
> @@ -63,6 +69,7 @@ struct page {
>  	union {
>  		pgoff_t index;		/* Our offset within mapping. */
>  		void *freelist;		/* sl[aou]b first free object */
> +		dma_addr_t dma_addr;    /* used by page_pool */
>  		/* page_deferred_list().prev	-- second tail page */
>  	};
>
> @@ -117,6 +124,8 @@ struct page {
>  	 * avoid collision and false-positive PageTail().
>  	 */
>  	union {
> +		/* XXX: Idea reuse lru list, in page_pool to align with PCP */
> +
>  		struct list_head lru;	/* Pageout list, eg. active_list
>  					 * protected by zone_lru_lock !
>  					 * Can be used as a generic list
> @@ -189,6 +198,8 @@ struct page {
>  #endif
>  #endif
>  		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
> +		/* XXX: Sure page_pool will have no users of "private"? */
> +		struct page_pool *pool;
>  	};
>
>  #ifdef CONFIG_MEMCG

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
