From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 7/7] slub: do prefetching in kmem_cache_alloc_bulk()
Date: Mon, 28 Sep 2015 17:59:01 +0200
Message-ID: <20150928175901.39976cdb@redhat.com>
References: <20150928122444.15409.10498.stgit@canyon>
	<20150928122639.15409.21583.stgit@canyon>
	<5609545C.4010807@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Christoph Lameter <cl@linux.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, brouer@redhat.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51909 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934252AbbI1P7H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Sep 2015 11:59:07 -0400
In-Reply-To: <5609545C.4010807@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 28 Sep 2015 07:53:16 -0700 Alexander Duyck <alexander.duyck@gmail.com> wrote:

> On 09/28/2015 05:26 AM, Jesper Dangaard Brouer wrote:
> > For practical use-cases it is beneficial to prefetch the next freelist
> > object in bulk allocation loop.
> >
> > Micro benchmarking show approx 1 cycle change:
> >
> > bulk -  prev-patch     -  this patch
> >     1 -  49 cycles(tsc) - 49 cycles(tsc) - increase in cycles:0
> >     2 -  30 cycles(tsc) - 31 cycles(tsc) - increase in cycles:1
> >     3 -  23 cycles(tsc) - 25 cycles(tsc) - increase in cycles:2
> >     4 -  20 cycles(tsc) - 22 cycles(tsc) - increase in cycles:2
> >     8 -  18 cycles(tsc) - 19 cycles(tsc) - increase in cycles:1
> >    16 -  17 cycles(tsc) - 18 cycles(tsc) - increase in cycles:1
> >    30 -  18 cycles(tsc) - 17 cycles(tsc) - increase in cycles:-1
> >    32 -  18 cycles(tsc) - 19 cycles(tsc) - increase in cycles:1
> >    34 -  23 cycles(tsc) - 24 cycles(tsc) - increase in cycles:1
> >    48 -  21 cycles(tsc) - 22 cycles(tsc) - increase in cycles:1
> >    64 -  20 cycles(tsc) - 21 cycles(tsc) - increase in cycles:1
> >   128 -  27 cycles(tsc) - 27 cycles(tsc) - increase in cycles:0
> >   158 -  30 cycles(tsc) - 30 cycles(tsc) - increase in cycles:0
> >   250 -  37 cycles(tsc) - 37 cycles(tsc) - increase in cycles:0
> >
> > Note, benchmark done with slab_nomerge to keep it stable enough
> > for accurate comparison.
> >
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > ---
> >   mm/slub.c |    2 ++
> >   1 file changed, 2 insertions(+)
> >
> > diff --git a/mm/slub.c b/mm/slub.c
> > index c25717ab3b5a..5af75a618b91 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -2951,6 +2951,7 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
> >   				goto error;
> >   
> >   			c = this_cpu_ptr(s->cpu_slab);
> > +			prefetch_freepointer(s, c->freelist);
> >   			continue; /* goto for-loop */
> >   		}
> >   
> > @@ -2960,6 +2961,7 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
> >   			goto error;
> >   
> >   		c->freelist = get_freepointer(s, object);
> > +		prefetch_freepointer(s, c->freelist);
> >   		p[i] = object;
> >   
> >   		/* kmem_cache debug support */
> >
> 
> I can see the prefetch in the last item case being possibly useful since 
> you have time between when you call the prefetch and when you are 
> accessing the next object.  However, is there any actual benefit to 
> prefetching inside the loop itself?  Based on your data above it doesn't 
> seem like that is the case since you are now adding one additional cycle 
> to the allocation and I am not seeing any actual gain reported here.

The gain will first show up, when using bulk alloc in real use-cases.

As you know, bulk alloc on RX path don't show any improvement. And I
measured (with perf-mem-record) L1 miss'es here.  I could reduce the L1
misses here by adding prefetch.  But I cannot remember if I measured
any PPS improvement with this.

As you hint, the time I have between my prefetch and use is very small,
thus the question is if this will show any benefit for real use-cases.

We can drop this patch, and then I'll include it in my network
use-case, and measure the effect? (Although I'll likely be wasting my
time, as we should likely redesign the alloc API instead).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
