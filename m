From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 7/7] slub: initial bulk free implementation
Date: Tue, 16 Jun 2015 16:23:28 +0900
Message-ID: <20150616072328.GB13125@js1304-P5Q-DELUXE>
References: <20150615155053.18824.617.stgit@devil>
 <20150615155256.18824.42651.stgit@devil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lgeamrelo01.lge.com ([156.147.1.125]:41068 "EHLO
	lgeamrelo01.lge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419AbbFPHVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 03:21:20 -0400
Content-Disposition: inline
In-Reply-To: <20150615155256.18824.42651.stgit@devil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 15, 2015 at 05:52:56PM +0200, Jesper Dangaard Brouer wrote:
> This implements SLUB specific kmem_cache_free_bulk().  SLUB allocator
> now both have bulk alloc and free implemented.
> 
> Play nice and reenable local IRQs while calling slowpath.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
>  mm/slub.c |   32 +++++++++++++++++++++++++++++++-
>  1 file changed, 31 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 98d0e6f73ec1..cc4f870677bb 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2752,7 +2752,37 @@ EXPORT_SYMBOL(kmem_cache_free);
>  
>  void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
>  {
> -	__kmem_cache_free_bulk(s, size, p);
> +	struct kmem_cache_cpu *c;
> +	struct page *page;
> +	int i;
> +
> +	local_irq_disable();
> +	c = this_cpu_ptr(s->cpu_slab);
> +
> +	for (i = 0; i < size; i++) {
> +		void *object = p[i];
> +
> +		if (unlikely(!object))
> +			continue; // HOW ABOUT BUG_ON()???
> +
> +		page = virt_to_head_page(object);
> +		BUG_ON(s != page->slab_cache); /* Check if valid slab page */

You need to use cache_from_objt() to support kmemcg accounting.
And, slab_free_hook() should be called before free.

Thanks.
