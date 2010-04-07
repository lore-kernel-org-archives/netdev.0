From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: hackbench regression due to commit 9dfc6e68bfe6e
Date: Wed, 7 Apr 2010 11:43:21 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1004071130260.13261@router.home>
References: <1269506457.4513.141.camel@alexs-hp.sh.intel.com>  <alpine.DEB.2.00.1003250942080.2670@router.home>  <1269570902.9614.92.camel@alexs-hp.sh.intel.com>  <1270114166.2078.107.camel@ymzhang.sh.intel.com>  <alpine.DEB.2.00.1004011050340.16531@router.home>
  <1270195589.2078.116.camel@ymzhang.sh.intel.com>  <alpine.DEB.2.00.1004050853300.23149@router.home>  <i2z84144f021004051030k7ff5190cyc083aa12c552dfac@mail.gmail.com>  <4BBA8DF9.8010409@kernel.org>  <1270542497.2078.123.camel@ymzhang.sh.intel.com>
 <alpine.DEB.2.00.1004061033330.18750@router.home>  <alpine.DEB.2.00.1004061552500.19151@router.home>  <1270591841.2091.170.camel@edumazet-laptop> <1270607668.2078.259.camel@ymzhang.sh.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>, alex.shi@intel.com,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Ma, Ling" <ling.ma@intel.com>,
	"Chen, Tim C" <tim.c.chen@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nlpi129.sbcis.sbc.com ([207.115.36.143]:42733 "EHLO
	nlpi129.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932754Ab0DGQnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 12:43:37 -0400
In-Reply-To: <1270607668.2078.259.camel@ymzhang.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 7 Apr 2010, Zhang, Yanmin wrote:

> I collected retired instruction, dtlb miss and LLC miss.
> Below is data of LLC miss.
>
> Kernel 2.6.33:
>     20.94%        hackbench  [kernel.kallsyms]                                       [k] copy_user_generic_string
>     14.56%        hackbench  [kernel.kallsyms]                                       [k] unix_stream_recvmsg
>     12.88%        hackbench  [kernel.kallsyms]                                       [k] kfree
>      7.37%        hackbench  [kernel.kallsyms]                                       [k] kmem_cache_free
>      7.18%        hackbench  [kernel.kallsyms]                                       [k] kmem_cache_alloc_node
>      6.78%        hackbench  [kernel.kallsyms]                                       [k] kfree_skb
>      6.27%        hackbench  [kernel.kallsyms]                                       [k] __kmalloc_node_track_caller
>      2.73%        hackbench  [kernel.kallsyms]                                       [k] __slab_free
>      2.21%        hackbench  [kernel.kallsyms]                                       [k] get_partial_node
>      2.01%        hackbench  [kernel.kallsyms]                                       [k] _raw_spin_lock
>      1.59%        hackbench  [kernel.kallsyms]                                       [k] schedule
>      1.27%        hackbench  hackbench                                               [.] receiver
>      0.99%        hackbench  libpthread-2.9.so                                       [.] __read
>      0.87%        hackbench  [kernel.kallsyms]                                       [k] unix_stream_sendmsg
>
> Kernel 2.6.34-rc3:
>     18.55%        hackbench  [kernel.kallsyms]                                                     [k] copy_user_generic_str
> ing
>     13.19%        hackbench  [kernel.kallsyms]                                                     [k] unix_stream_recvmsg
>     11.62%        hackbench  [kernel.kallsyms]                                                     [k] kfree
>      8.54%        hackbench  [kernel.kallsyms]                                                     [k] kmem_cache_free
>      7.88%        hackbench  [kernel.kallsyms]                                                     [k] __kmalloc_node_track_
> caller

Seems that the overhead of __kmalloc_node_track_caller was increased. The
function inlines slab_alloc().

>      6.54%        hackbench  [kernel.kallsyms]                                                     [k] kmem_cache_alloc_node
>      5.94%        hackbench  [kernel.kallsyms]                                                     [k] kfree_skb
>      3.48%        hackbench  [kernel.kallsyms]                                                     [k] __slab_free
>      2.15%        hackbench  [kernel.kallsyms]                                                     [k] _raw_spin_lock
>      1.83%        hackbench  [kernel.kallsyms]                                                     [k] schedule
>      1.82%        hackbench  [kernel.kallsyms]                                                     [k] get_partial_node
>      1.59%        hackbench  hackbench                                                             [.] receiver
>      1.37%        hackbench  libpthread-2.9.so                                                     [.] __read

I wonder if this is not related to the kmem_cache_cpu structure straggling
cache line boundaries under some conditions. On 2.6.33 the kmem_cache_cpu
structure was larger and therefore tight packing resulted in different
alignment.

Could you see how the following patch affects the results. It attempts to
increase the size of kmem_cache_cpu to a power of 2 bytes. There is also
the potential that other per cpu fetches to neighboring objects affect the
situation. We could cacheline align the whole thing.

---
 include/linux/slub_def.h |    5 +++++
 1 file changed, 5 insertions(+)

Index: linux-2.6/include/linux/slub_def.h
===================================================================
--- linux-2.6.orig/include/linux/slub_def.h	2010-04-07 11:33:50.000000000 -0500
+++ linux-2.6/include/linux/slub_def.h	2010-04-07 11:35:18.000000000 -0500
@@ -38,6 +38,11 @@ struct kmem_cache_cpu {
 	void **freelist;	/* Pointer to first free per cpu object */
 	struct page *page;	/* The slab from which we are allocating */
 	int node;		/* The node of the page (or -1 for debug) */
+#ifndef CONFIG_64BIT
+	int dummy1;
+#endif
+	unsigned long dummy2;
+
 #ifdef CONFIG_SLUB_STATS
 	unsigned stat[NR_SLUB_STAT_ITEMS];
 #endif
