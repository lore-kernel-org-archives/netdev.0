From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: hackbench regression due to commit 9dfc6e68bfe6e
Date: Wed, 7 Apr 2010 13:18:00 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1004071316390.16159@router.home>
References: <1269506457.4513.141.camel@alexs-hp.sh.intel.com>  <alpine.DEB.2.00.1003250942080.2670@router.home>  <1269570902.9614.92.camel@alexs-hp.sh.intel.com>  <1270114166.2078.107.camel@ymzhang.sh.intel.com>  <alpine.DEB.2.00.1004011050340.16531@router.home>
  <1270195589.2078.116.camel@ymzhang.sh.intel.com>  <alpine.DEB.2.00.1004050853300.23149@router.home>  <i2z84144f021004051030k7ff5190cyc083aa12c552dfac@mail.gmail.com>  <4BBA8DF9.8010409@kernel.org>  <1270542497.2078.123.camel@ymzhang.sh.intel.com>
 <alpine.DEB.2.00.1004061033330.18750@router.home>  <alpine.DEB.2.00.1004061552500.19151@router.home>  <1270591841.2091.170.camel@edumazet-laptop> <1270607668.2078.259.camel@ymzhang.sh.intel.com> <alpine.DEB.2.00.1004071130260.13261@router.home>
 <4BBCB7B7.4040901@cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>,
	alex.shi@intel.com,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Ma, Ling" <ling.ma@intel.com>,
	"Chen, Tim C" <tim.c.chen@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BBCB7B7.4040901@cs.helsinki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 7 Apr 2010, Pekka Enberg wrote:

> Christoph Lameter wrote:
> > I wonder if this is not related to the kmem_cache_cpu structure straggling
> > cache line boundaries under some conditions. On 2.6.33 the kmem_cache_cpu
> > structure was larger and therefore tight packing resulted in different
> > alignment.
> >
> > Could you see how the following patch affects the results. It attempts to
> > increase the size of kmem_cache_cpu to a power of 2 bytes. There is also
> > the potential that other per cpu fetches to neighboring objects affect the
> > situation. We could cacheline align the whole thing.
> >
> > ---
> >  include/linux/slub_def.h |    5 +++++
> >  1 file changed, 5 insertions(+)
> >
> > Index: linux-2.6/include/linux/slub_def.h
> > ===================================================================
> > --- linux-2.6.orig/include/linux/slub_def.h	2010-04-07 11:33:50.000000000
> > -0500
> > +++ linux-2.6/include/linux/slub_def.h	2010-04-07 11:35:18.000000000
> > -0500
> > @@ -38,6 +38,11 @@ struct kmem_cache_cpu {
> >  	void **freelist;	/* Pointer to first free per cpu object */
> >  	struct page *page;	/* The slab from which we are allocating */
> >  	int node;		/* The node of the page (or -1 for debug) */
> > +#ifndef CONFIG_64BIT
> > +	int dummy1;
> > +#endif
> > +	unsigned long dummy2;
> > +
> >  #ifdef CONFIG_SLUB_STATS
> >  	unsigned stat[NR_SLUB_STAT_ITEMS];
> >  #endif
>
> Would __cacheline_aligned_in_smp do the trick here?

This is allocated via the percpu allocator. We could specify cacheline
alignment there but that would reduce the density. You basically need 4
words for a kmem_cache_cpu structure. A number of those fit into one 64
byte cacheline.
