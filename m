From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 7/7] slub: initial bulk free implementation
Date: Mon, 15 Jun 2015 11:34:44 -0500 (CDT)
Message-ID: <alpine.DEB.2.11.1506151133150.20358@east.gentwo.org>
References: <20150615155053.18824.617.stgit@devil> <20150615155256.18824.42651.stgit@devil>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
    netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20150615155256.18824.42651.stgit@devil>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, 15 Jun 2015, Jesper Dangaard Brouer wrote:

> +	for (i = 0; i < size; i++) {
> +		void *object = p[i];
> +
> +		if (unlikely(!object))
> +			continue; // HOW ABOUT BUG_ON()???

Sure BUG_ON would be fitting here.

> +
> +		page = virt_to_head_page(object);
> +		BUG_ON(s != page->slab_cache); /* Check if valid slab page */

This is the check if the slab page belongs to the slab cache we are
interested in.

> +
> +		if (c->page == page) {
> +			/* Fastpath: local CPU free */
> +			set_freepointer(s, object, c->freelist);
> +			c->freelist = object;
> +		} else {
> +			c->tid = next_tid(c->tid);

tids are only useful for the fastpath. No need to fiddle around with them
for the slowpath.

> +			local_irq_enable();
> +			/* Slowpath: overhead locked cmpxchg_double_slab */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
