From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Date: Thu, 22 Oct 2015 21:47:57 +0300
Message-ID: <20151022184757.GO18351@esperanza>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <1445487696-21545-6-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>,
	<netdev@vger.kernel.org>, <linux-mm@kvack.org>,
	<cgroups@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1445487696-21545-6-git-send-email-hannes@cmpxchg.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 22, 2015 at 12:21:33AM -0400, Johannes Weiner wrote:
...
> @@ -5500,13 +5524,38 @@ void sock_release_memcg(struct sock *sk)
>   */
>  bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
>  {
> +	unsigned int batch = max(CHARGE_BATCH, nr_pages);
>  	struct page_counter *counter;
> +	bool force = false;
>  
> -	if (page_counter_try_charge(&memcg->skmem, nr_pages, &counter))
> +	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys)) {
> +		if (page_counter_try_charge(&memcg->skmem, nr_pages, &counter))
> +			return true;
> +		page_counter_charge(&memcg->skmem, nr_pages);
> +		return false;
> +	}
> +
> +	if (consume_stock(memcg, nr_pages))
>  		return true;
> +retry:
> +	if (page_counter_try_charge(&memcg->memory, batch, &counter))
> +		goto done;

Currently, we use memcg->memory only for charging memory pages. Besides,
every page charged to this counter (including kmem) has ->mem_cgroup
field set appropriately. This looks consistent and nice. As an extra
benefit, we can track all pages charged to a memory cgroup via
/proc/kapgecgroup.

Now, you charge "window size" to it, which AFAIU isn't necessarily equal
to the amount of memory actually consumed by the cgroup for socket
buffers. I think this looks ugly and inconsistent with the existing
behavior. I agree that we need to charge socker buffers to ->memory, but
IMO we should do that per each skb page, using memcg_kmem_charge_kmem
somewhere in alloc_skb_with_frags invoking the reclaimer just as we do
for kmalloc, while tcp window size control should stay aside.

Thanks,
Vladimir
