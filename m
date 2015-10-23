From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/8] mm: memcontrol: prepare for unified hierarchy socket
 accounting
Date: Fri, 23 Oct 2015 14:39:30 +0200
Message-ID: <20151023123930.GM2410@dhcp22.suse.cz>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <1445487696-21545-5-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vladimir Davydov <vdavydov@virtuozzo.com>,
	Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org,
	linux-mm@kvack.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Weiner <hannes@cmpxchg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:35225 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751800AbbJWMjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 08:39:33 -0400
Content-Disposition: inline
In-Reply-To: <1445487696-21545-5-git-send-email-hannes@cmpxchg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu 22-10-15 00:21:32, Johannes Weiner wrote:
> The unified hierarchy memory controller will account socket
> memory. Move the infrastructure functions accordingly.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 136 ++++++++++++++++++++++++++++----------------------------
>  1 file changed, 68 insertions(+), 68 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index c41e6d7..3789050 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -287,74 +287,6 @@ static inline struct mem_cgroup *mem_cgroup_from_id(unsigned short id)
>  	return mem_cgroup_from_css(css);
>  }
>  
> -/* Writing them here to avoid exposing memcg's inner layout */
> -#if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
> -
> -DEFINE_STATIC_KEY_FALSE(mem_cgroup_sockets);
> -
> -void sock_update_memcg(struct sock *sk)
> -{
> -	struct mem_cgroup *memcg;
> -	/*
> -	 * Socket cloning can throw us here with sk_cgrp already
> -	 * filled. It won't however, necessarily happen from
> -	 * process context. So the test for root memcg given
> -	 * the current task's memcg won't help us in this case.
> -	 *
> -	 * Respecting the original socket's memcg is a better
> -	 * decision in this case.
> -	 */
> -	if (sk->sk_memcg) {
> -		BUG_ON(mem_cgroup_is_root(sk->sk_memcg));
> -		css_get(&sk->sk_memcg->css);
> -		return;
> -	}
> -
> -	rcu_read_lock();
> -	memcg = mem_cgroup_from_task(current);
> -	if (css_tryget_online(&memcg->css))
> -		sk->sk_memcg = memcg;
> -	rcu_read_unlock();
> -}
> -EXPORT_SYMBOL(sock_update_memcg);
> -
> -void sock_release_memcg(struct sock *sk)
> -{
> -	if (sk->sk_memcg)
> -		css_put(&sk->sk_memcg->css);
> -}
> -
> -/**
> - * mem_cgroup_charge_skmem - charge socket memory
> - * @memcg: memcg to charge
> - * @nr_pages: number of pages to charge
> - *
> - * Charges @nr_pages to @memcg. Returns %true if the charge fit within
> - * the memcg's configured limit, %false if the charge had to be forced.
> - */
> -bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
> -{
> -	struct page_counter *counter;
> -
> -	if (page_counter_try_charge(&memcg->skmem, nr_pages, &counter))
> -		return true;
> -
> -	page_counter_charge(&memcg->skmem, nr_pages);
> -	return false;
> -}
> -
> -/**
> - * mem_cgroup_uncharge_skmem - uncharge socket memory
> - * @memcg: memcg to uncharge
> - * @nr_pages: number of pages to uncharge
> - */
> -void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
> -{
> -	page_counter_uncharge(&memcg->skmem, nr_pages);
> -}
> -
> -#endif
> -
>  #ifdef CONFIG_MEMCG_KMEM
>  /*
>   * This will be the memcg's index in each cache's ->memcg_params.memcg_caches.
> @@ -5521,6 +5453,74 @@ void mem_cgroup_replace_page(struct page *oldpage, struct page *newpage)
>  	commit_charge(newpage, memcg, true);
>  }
>  
> +/* Writing them here to avoid exposing memcg's inner layout */
> +#if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
> +
> +DEFINE_STATIC_KEY_FALSE(mem_cgroup_sockets);
> +
> +void sock_update_memcg(struct sock *sk)
> +{
> +	struct mem_cgroup *memcg;
> +	/*
> +	 * Socket cloning can throw us here with sk_cgrp already
> +	 * filled. It won't however, necessarily happen from
> +	 * process context. So the test for root memcg given
> +	 * the current task's memcg won't help us in this case.
> +	 *
> +	 * Respecting the original socket's memcg is a better
> +	 * decision in this case.
> +	 */
> +	if (sk->sk_memcg) {
> +		BUG_ON(mem_cgroup_is_root(sk->sk_memcg));
> +		css_get(&sk->sk_memcg->css);
> +		return;
> +	}
> +
> +	rcu_read_lock();
> +	memcg = mem_cgroup_from_task(current);
> +	if (css_tryget_online(&memcg->css))
> +		sk->sk_memcg = memcg;
> +	rcu_read_unlock();
> +}
> +EXPORT_SYMBOL(sock_update_memcg);
> +
> +void sock_release_memcg(struct sock *sk)
> +{
> +	if (sk->sk_memcg)
> +		css_put(&sk->sk_memcg->css);
> +}
> +
> +/**
> + * mem_cgroup_charge_skmem - charge socket memory
> + * @memcg: memcg to charge
> + * @nr_pages: number of pages to charge
> + *
> + * Charges @nr_pages to @memcg. Returns %true if the charge fit within
> + * the memcg's configured limit, %false if the charge had to be forced.
> + */
> +bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
> +{
> +	struct page_counter *counter;
> +
> +	if (page_counter_try_charge(&memcg->skmem, nr_pages, &counter))
> +		return true;
> +
> +	page_counter_charge(&memcg->skmem, nr_pages);
> +	return false;
> +}
> +
> +/**
> + * mem_cgroup_uncharge_skmem - uncharge socket memory
> + * @memcg: memcg to uncharge
> + * @nr_pages: number of pages to uncharge
> + */
> +void mem_cgroup_uncharge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
> +{
> +	page_counter_uncharge(&memcg->skmem, nr_pages);
> +}
> +
> +#endif
> +
>  /*
>   * subsys_initcall() for memory controller.
>   *
> -- 
> 2.6.1

-- 
Michal Hocko
SUSE Labs
