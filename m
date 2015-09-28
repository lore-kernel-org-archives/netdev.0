From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 4/7] slab: implement bulking for SLAB allocator
Date: Mon, 28 Sep 2015 10:11:09 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1509281008480.30332@east.gentwo.org>
References: <20150928122444.15409.10498.stgit@canyon> <20150928122624.15409.23038.stgit@canyon>
Content-Type: text/plain; charset=US-ASCII
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
    netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>,
    Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
    Joonsoo Kim <iamjoonsoo.kim@lge.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20150928122624.15409.23038.stgit@canyon>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, 28 Sep 2015, Jesper Dangaard Brouer wrote:

> +/* Note that interrupts must be enabled when calling this function. */
>  bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
> -								void **p)
> +			   void **p)
>  {
> -	return __kmem_cache_alloc_bulk(s, flags, size, p);
> +	size_t i;
> +
> +	local_irq_disable();
> +	for (i = 0; i < size; i++) {
> +		void *x = p[i] = slab_alloc(s, flags, _RET_IP_, false);
> +
> +		if (!x) {
> +			__kmem_cache_free_bulk(s, i, p);
> +			return false;
> +		}
> +	}
> +	local_irq_enable();
> +	return true;
>  }
>  EXPORT_SYMBOL(kmem_cache_alloc_bulk);
>

Ok the above could result in excessive times when the interrupts are
kept off.  Lets say someone is freeing 1000 objects?

> +/* Note that interrupts must be enabled when calling this function. */
> +void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
> +{
> +	size_t i;
> +
> +	local_irq_disable();
> +	for (i = 0; i < size; i++)
> +		__kmem_cache_free(s, p[i], false);
> +	local_irq_enable();
> +}
> +EXPORT_SYMBOL(kmem_cache_free_bulk);

Same concern here. We may just have to accept this for now.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
