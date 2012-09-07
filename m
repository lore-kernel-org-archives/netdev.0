From: JoonSoo Kim <js1304@gmail.com>
Subject: Re: [PATCH 1/4] slab: do ClearSlabPfmemalloc() for all pages of slab
Date: Sat, 8 Sep 2012 06:10:06 +0900
Message-ID: <CAAmzW4O2xF4Oo6VhnFHHBufg35xJ2Ko3c2KD5DUGgJ1VrL8jJw@mail.gmail.com>
References: <1346779479-1097-1-git-send-email-mgorman@suse.de>
	<1346779479-1097-2-git-send-email-mgorman@suse.de>
	<CAAmzW4M_3hVBfjqFLG=7iydkXeQPdCXRbRmkqUJD4vwo0eWVWQ@mail.gmail.com>
	<CAAmzW4MfFUH1Mi447sQvPNeae_BShEmbECUaK9eoX-8ughEdJw@mail.gmail.com>
	<20120907125519.GB11266@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>,
	Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Chuck Lever <chuck.lever@oracle.com>,
	Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
	Christoph Lameter <cl@linux.com>
To: Mel Gorman <mgorman@suse.de>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20120907125519.GB11266@suse.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

2012/9/7 Mel Gorman <mgorman@suse.de>:
> This churns code a lot more than is necessary. How about this as a
> replacement patch?
>
> ---8<---
> From: Joonsoo Kim <js1304@gmail.com>
> Subject: [PATCH] slab: do ClearSlabPfmemalloc() for all pages of slab
>
> Right now, we call ClearSlabPfmemalloc() for first page of slab when we
> clear SlabPfmemalloc flag. This is fine for most swap-over-network use
> cases as it is expected that order-0 pages are in use. Unfortunately it
> is possible that that __ac_put_obj() checks SlabPfmemalloc on a tail page
> and while this is harmless, it is sloppy. This patch ensures that the head
> page is always used.
>
> [mgorman@suse.de: Easier implementation, changelog cleanup]
> Signed-off-by: Joonsoo Kim <js1304@gmail.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  mm/slab.c |   12 +++++-------
>  1 file changed, 5 insertions(+), 7 deletions(-)
>
> diff --git a/mm/slab.c b/mm/slab.c
> index 811af03..590d52a 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1032,7 +1032,7 @@ static void *__ac_put_obj(struct kmem_cache *cachep, struct array_cache *ac,
>  {
>         if (unlikely(pfmemalloc_active)) {
>                 /* Some pfmemalloc slabs exist, check if this is one */
> -               struct page *page = virt_to_page(objp);
> +               struct page *page = virt_to_head_page(objp);
>                 if (PageSlabPfmemalloc(page))
>                         set_obj_pfmemalloc(&objp);
>         }
> @@ -1919,12 +1919,10 @@ static void *kmem_getpages(struct kmem_cache *cachep, gfp_t flags, int nodeid)
>         else
>                 add_zone_page_state(page_zone(page),
>                         NR_SLAB_UNRECLAIMABLE, nr_pages);
> -       for (i = 0; i < nr_pages; i++) {
> +       for (i = 0; i < nr_pages; i++)
>                 __SetPageSlab(page + i);
> -
> -               if (page->pfmemalloc)
> -                       SetPageSlabPfmemalloc(page + i);
> -       }
> +       if (page->pfmemalloc)
> +               SetPageSlabPfmemalloc(page);
>
>         if (kmemcheck_enabled && !(cachep->flags & SLAB_NOTRACK)) {
>                 kmemcheck_alloc_shadow(page, cachep->gfporder, flags, nodeid);
> @@ -1955,9 +1953,9 @@ static void kmem_freepages(struct kmem_cache *cachep, void *addr)
>         else
>                 sub_zone_page_state(page_zone(page),
>                                 NR_SLAB_UNRECLAIMABLE, nr_freed);
> +       __ClearPageSlabPfmemalloc(page);
>         while (i--) {
>                 BUG_ON(!PageSlab(page));
> -               __ClearPageSlabPfmemalloc(page);
>                 __ClearPageSlab(page);
>                 page++;
>         }

Okay.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
