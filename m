From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 6/7] slub: improve bulk alloc strategy
Date: Tue, 16 Jun 2015 14:53:36 -0700
Message-ID: <20150616145336.1cacbfb88ff55b0e088676c3@linux-foundation.org>
References: <20150615155053.18824.617.stgit@devil>
	<20150615155246.18824.3788.stgit@devil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>,
 netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20150615155246.18824.3788.stgit@devil>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, 15 Jun 2015 17:52:46 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> Call slowpath __slab_alloc() from within the bulk loop, as the
> side-effect of this call likely repopulates c->freelist.
> 
> Choose to reenable local IRQs while calling slowpath.
> 
> Saving some optimizations for later.  E.g. it is possible to
> extract parts of __slab_alloc() and avoid the unnecessary and
> expensive (37 cycles) local_irq_{save,restore}.  For now, be
> happy calling __slab_alloc() this lower icache impact of this
> func and I don't have to worry about correctness.
> 
> ...
>
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2776,8 +2776,23 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
>  	for (i = 0; i < size; i++) {
>  		void *object = c->freelist;
>  
> -		if (!object)
> -			break;
> +		if (unlikely(!object)) {
> +			c->tid = next_tid(c->tid);
> +			local_irq_enable();
> +
> +			/* Invoke slow path one time, then retry fastpath
> +			 * as side-effect have updated c->freelist
> +			 */

That isn't very grammatical.

Block comments are formatted

	/*
	 * like this
	 */

please.


> +			p[i] = __slab_alloc(s, flags, NUMA_NO_NODE,
> +					    _RET_IP_, c);
> +			if (unlikely(!p[i])) {
> +				__kmem_cache_free_bulk(s, i, p);
> +				return false;
> +			}
> +			local_irq_disable();
> +			c = this_cpu_ptr(s->cpu_slab);
> +			continue; /* goto for-loop */
> +		}
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
