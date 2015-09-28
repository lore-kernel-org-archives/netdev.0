From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 5/7] slub: support for bulk free with SLUB freelists
Date: Mon, 28 Sep 2015 10:16:49 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1509281011250.30332@east.gentwo.org>
References: <20150928122444.15409.10498.stgit@canyon> <20150928122629.15409.69466.stgit@canyon>
Content-Type: text/plain; charset=US-ASCII
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
    netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>,
    Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
    Joonsoo Kim <iamjoonsoo.kim@lge.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20150928122629.15409.69466.stgit@canyon>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, 28 Sep 2015, Jesper Dangaard Brouer wrote:

> diff --git a/mm/slub.c b/mm/slub.c
> index 1cf98d89546d..13b5f53e4840 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -675,11 +675,18 @@ static void init_object(struct kmem_cache *s, void *object, u8 val)
>  {
>  	u8 *p = object;
>
> +	/* Freepointer not overwritten as SLAB_POISON moved it after object */
>  	if (s->flags & __OBJECT_POISON) {
>  		memset(p, POISON_FREE, s->object_size - 1);
>  		p[s->object_size - 1] = POISON_END;
>  	}
>
> +	/*
> +	 * If both SLAB_RED_ZONE and SLAB_POISON are enabled, then
> +	 * freepointer is still safe, as then s->offset equals
> +	 * s->inuse and below redzone is after s->object_size and only
> +	 * area between s->object_size and s->inuse.
> +	 */
>  	if (s->flags & SLAB_RED_ZONE)
>  		memset(p + s->object_size, val, s->inuse - s->object_size);
>  }

Are these comments really adding something? This is basic metadata
handling for SLUB that is commented on elsehwere.

> @@ -2584,9 +2646,14 @@ EXPORT_SYMBOL(kmem_cache_alloc_node_trace);
>   * So we still attempt to reduce cache line usage. Just take the slab
>   * lock and free the item. If there is no additional partial page
>   * handling required then we can return immediately.
> + *
> + * Bulk free of a freelist with several objects (all pointing to the
> + * same page) possible by specifying freelist_head ptr and object as
> + * tail ptr, plus objects count (cnt).
>   */
>  static void __slab_free(struct kmem_cache *s, struct page *page,
> -			void *x, unsigned long addr)
> +			void *x, unsigned long addr,
> +			void *freelist_head, int cnt)

Do you really need separate parameters for freelist_head? If you just want
to deal with one object pass it as freelist_head and set cnt = 1?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
