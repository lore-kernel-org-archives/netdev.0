From: Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 2/4] mm: introduce memalloc_noreclaim_{save,
	restore}
Date: Wed, 5 Apr 2017 13:28:18 +0200
Message-ID: <20170405112817.GK6035@dhcp22.suse.cz>
References: <20170405074700.29871-1-vbabka@suse.cz>
	<20170405074700.29871-3-vbabka@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nbd-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-block-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org,
	Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	Mel Gorman <mgorman-3eNAlZScCAx27rWaFMvyedHuzzzSOjJt@public.gmane.org>
To: Vlastimil Babka <vbabka-AlSwsSmVLrQ@public.gmane.org>
Return-path: <nbd-general-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170405074700.29871-3-vbabka-AlSwsSmVLrQ@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nbd-general>,
	<mailto:nbd-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nbd-general>
List-Post: <mailto:nbd-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:nbd-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nbd-general>,
	<mailto:nbd-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: nbd-general-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed 05-04-17 09:46:58, Vlastimil Babka wrote:
> The previous patch has shown that simply setting and clearing PF_MEMALLOC in
> current->flags can result in wrongly clearing a pre-existing PF_MEMALLOC flag
> and potentially lead to recursive reclaim. Let's introduce helpers that support
> proper nesting by saving the previous stat of the flag, similar to the existing
> memalloc_noio_* and memalloc_nofs_* helpers. Convert existing setting/clearing
> of PF_MEMALLOC within mm to the new helpers.
> 
> There are no known issues with the converted code, but the change makes it more
> robust.
> 
> Suggested-by: Michal Hocko <mhocko-IBi9RG/b67k@public.gmane.org>
> Signed-off-by: Vlastimil Babka <vbabka-AlSwsSmVLrQ@public.gmane.org>

One could argue that tsk_restore_flags() could be extended to provide
tsk_set_flags() and use it for all allocation related PF flags. I do not
have a strong opinion on that but explicit API sounds a bit better to me
because is easier to follow (at least for me). If others think that
generic API would be better then I won't have any objections. Anyway
this looks good to me.
Acked-by: Michal Hocko <mhocko-IBi9RG/b67k@public.gmane.org>

> ---
>  include/linux/sched/mm.h | 12 ++++++++++++
>  mm/page_alloc.c          | 11 ++++++-----
>  mm/vmscan.c              | 17 +++++++++++------
>  3 files changed, 29 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/sched/mm.h b/include/linux/sched/mm.h
> index 9daabe138c99..2b24a6974847 100644
> --- a/include/linux/sched/mm.h
> +++ b/include/linux/sched/mm.h
> @@ -191,4 +191,16 @@ static inline void memalloc_nofs_restore(unsigned int flags)
>  	current->flags = (current->flags & ~PF_MEMALLOC_NOFS) | flags;
>  }
>  
> +static inline unsigned int memalloc_noreclaim_save(void)
> +{
> +	unsigned int flags = current->flags & PF_MEMALLOC;
> +	current->flags |= PF_MEMALLOC;
> +	return flags;
> +}
> +
> +static inline void memalloc_noreclaim_restore(unsigned int flags)
> +{
> +	current->flags = (current->flags & ~PF_MEMALLOC) | flags;
> +}
> +
>  #endif /* _LINUX_SCHED_MM_H */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index b84e6ffbe756..037e32dccd7a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3288,15 +3288,15 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
>  		enum compact_priority prio, enum compact_result *compact_result)
>  {
>  	struct page *page;
> -	unsigned int noreclaim_flag = current->flags & PF_MEMALLOC;
> +	unsigned int noreclaim_flag;
>  
>  	if (!order)
>  		return NULL;
>  
> -	current->flags |= PF_MEMALLOC;
> +	noreclaim_flag = memalloc_noreclaim_save();
>  	*compact_result = try_to_compact_pages(gfp_mask, order, alloc_flags, ac,
>  									prio);
> -	current->flags = (current->flags & ~PF_MEMALLOC) | noreclaim_flag;
> +	memalloc_noreclaim_restore(noreclaim_flag);
>  
>  	if (*compact_result <= COMPACT_INACTIVE)
>  		return NULL;
> @@ -3443,12 +3443,13 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order,
>  {
>  	struct reclaim_state reclaim_state;
>  	int progress;
> +	unsigned int noreclaim_flag;
>  
>  	cond_resched();
>  
>  	/* We now go into synchronous reclaim */
>  	cpuset_memory_pressure_bump();
> -	current->flags |= PF_MEMALLOC;
> +	noreclaim_flag = memalloc_noreclaim_save();
>  	lockdep_set_current_reclaim_state(gfp_mask);
>  	reclaim_state.reclaimed_slab = 0;
>  	current->reclaim_state = &reclaim_state;
> @@ -3458,7 +3459,7 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order,
>  
>  	current->reclaim_state = NULL;
>  	lockdep_clear_current_reclaim_state();
> -	current->flags &= ~PF_MEMALLOC;
> +	memalloc_noreclaim_restore(noreclaim_flag);
>  
>  	cond_resched();
>  
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 58615bb27f2f..ff63b91a0f48 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2992,6 +2992,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
>  	struct zonelist *zonelist;
>  	unsigned long nr_reclaimed;
>  	int nid;
> +	unsigned int noreclaim_flag;
>  	struct scan_control sc = {
>  		.nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),
>  		.gfp_mask = (current_gfp_context(gfp_mask) & GFP_RECLAIM_MASK) |
> @@ -3018,9 +3019,9 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
>  					    sc.gfp_mask,
>  					    sc.reclaim_idx);
>  
> -	current->flags |= PF_MEMALLOC;
> +	noreclaim_flag = memalloc_noreclaim_save();
>  	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
> -	current->flags &= ~PF_MEMALLOC;
> +	memalloc_noreclaim_restore(noreclaim_flag);
>  
>  	trace_mm_vmscan_memcg_reclaim_end(nr_reclaimed);
>  
> @@ -3544,8 +3545,9 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
>  	struct zonelist *zonelist = node_zonelist(numa_node_id(), sc.gfp_mask);
>  	struct task_struct *p = current;
>  	unsigned long nr_reclaimed;
> +	unsigned int noreclaim_flag;
>  
> -	p->flags |= PF_MEMALLOC;
> +	noreclaim_flag = memalloc_noreclaim_save();
>  	lockdep_set_current_reclaim_state(sc.gfp_mask);
>  	reclaim_state.reclaimed_slab = 0;
>  	p->reclaim_state = &reclaim_state;
> @@ -3554,7 +3556,7 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
>  
>  	p->reclaim_state = NULL;
>  	lockdep_clear_current_reclaim_state();
> -	p->flags &= ~PF_MEMALLOC;
> +	memalloc_noreclaim_restore(noreclaim_flag);
>  
>  	return nr_reclaimed;
>  }
> @@ -3719,6 +3721,7 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
>  	struct task_struct *p = current;
>  	struct reclaim_state reclaim_state;
>  	int classzone_idx = gfp_zone(gfp_mask);
> +	unsigned int noreclaim_flag;
>  	struct scan_control sc = {
>  		.nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),
>  		.gfp_mask = (gfp_mask = current_gfp_context(gfp_mask)),
> @@ -3736,7 +3739,8 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
>  	 * and we also need to be able to write out pages for RECLAIM_WRITE
>  	 * and RECLAIM_UNMAP.
>  	 */
> -	p->flags |= PF_MEMALLOC | PF_SWAPWRITE;
> +	noreclaim_flag = memalloc_noreclaim_save();
> +	p->flags |= PF_SWAPWRITE;
>  	lockdep_set_current_reclaim_state(gfp_mask);
>  	reclaim_state.reclaimed_slab = 0;
>  	p->reclaim_state = &reclaim_state;
> @@ -3752,7 +3756,8 @@ static int __node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned in
>  	}
>  
>  	p->reclaim_state = NULL;
> -	current->flags &= ~(PF_MEMALLOC | PF_SWAPWRITE);
> +	current->flags &= ~PF_SWAPWRITE;
> +	memalloc_noreclaim_restore(noreclaim_flag);
>  	lockdep_clear_current_reclaim_state();
>  	return sc.nr_reclaimed >= nr_pages;
>  }
> -- 
> 2.12.2

-- 
Michal Hocko
SUSE Labs

------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, Slashdot.org! http://sdm.link/slashdot
