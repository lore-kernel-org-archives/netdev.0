From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [RFC PATCH] net: frag limit checks need to use
 percpu_counter_compare
Date: Thu, 31 Aug 2017 18:23:49 +0200
Message-ID: <20170831162349.k3qnkfgkygdh2zqw@unicorn.suse.cz>
References: <150417481955.28907.15567119824187929000.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: liujian56@huawei.com, netdev@vger.kernel.org,
        Florian Westphal <fw@strlen.de>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:34595 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751752AbdHaQXv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 31 Aug 2017 12:23:51 -0400
Content-Disposition: inline
In-Reply-To: <150417481955.28907.15567119824187929000.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 31, 2017 at 12:20:19PM +0200, Jesper Dangaard Brouer wrote:
> To: Liujian can you please test this patch?
>  I want to understand if using __percpu_counter_compare() solves
>  the problem correctness wise (even-though this will be slower
>  than using a simple atomic_t on your big system).
> 
> Fix bug in fragmentation codes use of the percpu_counter API, that
> cause issues on systems with many CPUs.
> 
> The frag_mem_limit() just reads the global counter (fbc->count),
> without considering other CPUs can have upto batch size (130K) that
> haven't been subtracted yet.  Due to the 3MBytes lower thresh limit,
> this become dangerous at >=24 CPUs (3*1024*1024/130000=24).
> 
> The __percpu_counter_compare() does the right thing, and takes into
> account the number of (online) CPUs and batch size, to account for
> this and call __percpu_counter_sum() when needed.
> 
> On systems with many CPUs this will unfortunately always result in the
> heavier fully locked __percpu_counter_sum() which touch the
> per_cpu_ptr of all (online) CPUs.
> 
> On systems with a smaller number of CPUs this solution is also not
> optimal, because __percpu_counter_compare()/__percpu_counter_sum()
> doesn't help synchronize the global counter.
>  Florian Westphal have an idea of adding some counter sync points,
> which should help address this issue.
> ---
>  include/net/inet_frag.h  |   16 ++++++++++++++--
>  net/ipv4/inet_fragment.c |    6 +++---
>  2 files changed, 17 insertions(+), 5 deletions(-)
> 
> diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
> index 6fdcd2427776..b586e320783d 100644
> --- a/include/net/inet_frag.h
> +++ b/include/net/inet_frag.h
> @@ -147,9 +147,21 @@ static inline bool inet_frag_evicting(struct inet_frag_queue *q)
>   */
>  static unsigned int frag_percpu_counter_batch = 130000;
>  
> -static inline int frag_mem_limit(struct netns_frags *nf)
> +static inline bool frag_mem_over_limit(struct netns_frags *nf, int thresh)
>  {
> -	return percpu_counter_read(&nf->mem);
> +	/* When reading counter here, __percpu_counter_compare() call
> +	 * will invoke __percpu_counter_sum() when needed.  Which
> +	 * depend on num_online_cpus()*batch size, as each CPU can
> +	 * potentential can hold a batch count.
> +	 *
> +	 * With many CPUs this heavier sum operation will
> +	 * unfortunately always occur.
> +	 */
> +	if (__percpu_counter_compare(&nf->mem, thresh,
> +				     frag_percpu_counter_batch) > 0)
> +		return true;
> +	else
> +		return false;
>  }
>  
>  static inline void sub_frag_mem_limit(struct netns_frags *nf, int i)
> diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
> index 96e95e83cc61..ee2cf56900e6 100644
> --- a/net/ipv4/inet_fragment.c
> +++ b/net/ipv4/inet_fragment.c
> @@ -120,7 +120,7 @@ static void inet_frag_secret_rebuild(struct inet_frags *f)
>  static bool inet_fragq_should_evict(const struct inet_frag_queue *q)
>  {
>  	return q->net->low_thresh == 0 ||
> -	       frag_mem_limit(q->net) >= q->net->low_thresh;
> +		frag_mem_over_limit(q->net, q->net->low_thresh);
>  }
>  
>  static unsigned int
> @@ -355,7 +355,7 @@ static struct inet_frag_queue *inet_frag_alloc(struct netns_frags *nf,
>  {
>  	struct inet_frag_queue *q;
>  
> -	if (!nf->high_thresh || frag_mem_limit(nf) > nf->high_thresh) {
> +	if (!nf->high_thresh || frag_mem_over_limit(nf, nf->high_thresh)) {
>  		inet_frag_schedule_worker(f);
>  		return NULL;
>  	}

If we go this way (which would IMHO require some benchmarks to make sure
it doesn't harm performance too much) we can drop the explicit checks
for zero thresholds which were added to work around the unreliability of
fast checks of percpu counters (or at least the second one was by commit
30759219f562 ("net: disable fragment reassembly if high_thresh is zero").
 
Michal Kubecek

> @@ -396,7 +396,7 @@ struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
>  	struct inet_frag_queue *q;
>  	int depth = 0;
>  
> -	if (frag_mem_limit(nf) > nf->low_thresh)
> +	if (frag_mem_over_limit(nf, nf->low_thresh))
>  		inet_frag_schedule_worker(f);
>  
>  	hash &= (INETFRAGS_HASHSZ - 1);
> 
