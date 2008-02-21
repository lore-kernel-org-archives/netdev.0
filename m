From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH] alloc_percpu() fails to allocate percpu data
Date: Thu, 21 Feb 2008 23:26:05 +0100
Message-ID: <1203632765.6112.20.camel@lappy>
References: <47BDBC23.10605@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Christoph Lameter <clameter@sgi.com>,
	"Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:53305 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752138AbYBUW0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 17:26:19 -0500
In-Reply-To: <47BDBC23.10605@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2008-02-21 at 19:00 +0100, Eric Dumazet wrote:
> Some oprofile results obtained while using tbench on a 2x2 cpu machine 
> were very surprising.
> 
> For example, loopback_xmit() function was using high number of cpu 
> cycles to perform the statistic updates, supposed to be real cheap
> since they use percpu data
> 
>         pcpu_lstats = netdev_priv(dev);
>         lb_stats = per_cpu_ptr(pcpu_lstats, smp_processor_id());
>         lb_stats->packets++;  /* HERE : serious contention */
>         lb_stats->bytes += skb->len;
> 
> 
> struct pcpu_lstats is a small structure containing two longs. It
> appears that on my 32bits platform, alloc_percpu(8) allocates a single
> cache line,  instead of giving to each cpu a separate cache line.
> 
> Using the following patch gave me impressive boost in various
> benchmarks ( 6 % in tbench) (all percpu_counters hit this bug too)
> 
> Long term fix (ie >= 2.6.26) would be to let each CPU allocate their
> own block of memory, so that we dont need to roudup sizes to
> L1_CACHE_BYTES, or merging the SGI stuff of course...
> 
> Note : SLUB vs SLAB is important here to *show* the improvement, since
> they dont have the same minimum allocation sizes (8 bytes vs 32
> bytes). This could very well explain regressions some guys reported
> when they switched to SLUB.

I've complained about this false sharing as well, so until we get the
new and improved percpu allocators,

Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> 
>  mm/allocpercpu.c |   15 ++++++++++++++-
>  1 files changed, 14 insertions(+), 1 deletion(-)
> 
> 
> plain text document attachment (percpu_populate.patch)
> diff --git a/mm/allocpercpu.c b/mm/allocpercpu.c
> index 7e58322..b0012e2 100644
> --- a/mm/allocpercpu.c
> +++ b/mm/allocpercpu.c
> @@ -6,6 +6,10 @@
>  #include <linux/mm.h>
>  #include <linux/module.h>
>  
> +#ifndef cache_line_size
> +#define cache_line_size()	L1_CACHE_BYTES
> +#endif
> +
>  /**
>   * percpu_depopulate - depopulate per-cpu data for given cpu
>   * @__pdata: per-cpu data to depopulate
> @@ -52,6 +56,11 @@ void *percpu_populate(void *__pdata, size_t size, gfp_t gfp, int cpu)
>  	struct percpu_data *pdata = __percpu_disguise(__pdata);
>  	int node = cpu_to_node(cpu);
>  
> +	/*
> +	 * We should make sure each CPU gets private memory.
> +	 */
> +	size = roundup(size, cache_line_size());
> +
>  	BUG_ON(pdata->ptrs[cpu]);
>  	if (node_online(node))
>  		pdata->ptrs[cpu] = kmalloc_node(size, gfp|__GFP_ZERO, node);
> @@ -98,7 +107,11 @@ EXPORT_SYMBOL_GPL(__percpu_populate_mask);
>   */
>  void *__percpu_alloc_mask(size_t size, gfp_t gfp, cpumask_t *mask)
>  {
> -	void *pdata = kzalloc(nr_cpu_ids * sizeof(void *), gfp);
> +	/*
> +	 * We allocate whole cache lines to avoid false sharing
> +	 */
> +	size_t sz = roundup(nr_cpu_ids * sizeof(void *), cache_line_size());
> +	void *pdata = kzalloc(sz, gfp);
>  	void *__pdata = __percpu_disguise(pdata);
>  
>  	if (unlikely(!pdata))

