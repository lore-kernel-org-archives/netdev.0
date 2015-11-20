From: Vladimir Davydov <vdavydov-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
Subject: Re: [PATCH 13/14] mm: memcontrol: account socket memory in unified
 hierarchy memory controller
Date: Fri, 20 Nov 2015 16:10:33 +0300
Message-ID: <20151120131033.GF31308@esperanza>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-14-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>,
	<cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<kernel-team-b10kYP2dOMg@public.gmane.org>
To: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1447371693-25143-14-git-send-email-hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 12, 2015 at 06:41:32PM -0500, Johannes Weiner wrote:
...
> @@ -5514,16 +5550,43 @@ void sock_release_memcg(struct sock *sk)
>   */
>  bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
>  {
> +	unsigned int batch = max(CHARGE_BATCH, nr_pages);
>  	struct page_counter *counter;
> +	bool force = false;
>  
> -	if (page_counter_try_charge(&memcg->tcp_mem.memory_allocated,
> -				    nr_pages, &counter)) {
> -		memcg->tcp_mem.memory_pressure = 0;
> +#ifdef CONFIG_MEMCG_KMEM
> +	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys)) {
> +		if (page_counter_try_charge(&memcg->tcp_mem.memory_allocated,
> +					    nr_pages, &counter)) {
> +			memcg->tcp_mem.memory_pressure = 0;
> +			return true;
> +		}
> +		page_counter_charge(&memcg->tcp_mem.memory_allocated, nr_pages);
> +		memcg->tcp_mem.memory_pressure = 1;
> +		return false;
> +	}
> +#endif
> +	if (consume_stock(memcg, nr_pages))
>  		return true;
> +retry:
> +	if (page_counter_try_charge(&memcg->memory, batch, &counter))
> +		goto done;
> +
> +	if (batch > nr_pages) {
> +		batch = nr_pages;
> +		goto retry;
>  	}
> -	page_counter_charge(&memcg->tcp_mem.memory_allocated, nr_pages);
> -	memcg->tcp_mem.memory_pressure = 1;
> -	return false;
> +
> +	page_counter_charge(&memcg->memory, batch);
> +	force = true;
> +done:

> +	css_get_many(&memcg->css, batch);

Is there any point to get css reference per each charged page? For kmem
it is absolutely necessary, because dangling slabs must block
destruction of memcg's kmem caches, which are destroyed on css_free. But
for sockets there's no such problem: memcg will be destroyed only after
all sockets are destroyed and therefore uncharged (since
sock_update_memcg pins css).

> +	if (batch > nr_pages)
> +		refill_stock(memcg, batch - nr_pages);
> +
> +	schedule_work(&memcg->socket_work);

I think it's suboptimal to schedule the work even if we are below the
high threshold.

BTW why do we need this work at all? Why is reclaim_high called from
task_work not enough?

Thanks,
Vladimir

> +
> +	return !force;
>  }
>  
>  /**
