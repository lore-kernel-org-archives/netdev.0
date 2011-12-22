From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] Partial revert "Basic kernel memory functionality for
 the Memory Controller"
Date: Thu, 22 Dec 2011 11:43:39 +0100
Message-ID: <20111222104339.GA8833@tiehlicka.suse.cz>
References: <1324543990-27784-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	kamezawa.hiroyu@jp.fujitsu.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, cgroups@vger.kernel.org,
	"Kirill A. Shutemov" <kirill@shutemov.name>,
	Paul Menage <paul@paulmenage.org>,
	Greg Thelen <gthelen@google.com>,
	Johannes Weiner <jweiner@redhat.com>
To: Glauber Costa <glommer@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1324543990-27784-1-git-send-email-glommer@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu 22-12-11 12:53:10, Glauber Costa wrote:
> This reverts commit e5671dfae59b165e2adfd4dfbdeab11ac8db5bda.
> 
> After a follow up discussion with Michal, it was agreed it would
> be better to leave the kmem controller with just the tcp files,
> deferring the behavior of the other general memory.kmem.* files
> for a later time, when more caches are controlled.

"Because generic kmem files are not used by tcp accounting and it is
not clear how other slab caches would fit into the scheme."

> 
> We are reverting the original commit so we can track the reference.
> Part of the patch is kept, because it was used by the later tcp
> code. Conflicts are shown in the bottom. init/Kconfig is removed from
> the revert entirely.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Kirill A. Shutemov <kirill@shutemov.name>
> CC: Paul Menage <paul@paulmenage.org>
> CC: Greg Thelen <gthelen@google.com>
> CC: Johannes Weiner <jweiner@redhat.com>
> CC: Michal Hocko <mhocko@suse.cz>
> CC: David S. Miller <davem@davemloft.net>

Acked-by: Michal Hocko <mhocko@suse.cz>

> 
> 
> Conflicts:
> 
> 	Documentation/cgroups/memory.txt
> 	mm/memcontrol.c
> ---
>  Documentation/cgroups/memory.txt |   22 +--------
>  mm/memcontrol.c                  |   93 +++-----------------------------------
>  2 files changed, 8 insertions(+), 107 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index 6922b6c..4d8774f 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -44,9 +44,8 @@ Features:
>   - oom-killer disable knob and oom-notifier
>   - Root cgroup has no limit controls.
>  
> - Hugepages is not under control yet. We just manage pages on LRU. To add more
> - controls, we have to take care of performance. Kernel memory support is work
> - in progress, and the current version provides basically functionality.
> + Kernel memory support is work in progress, and the current version provides
> + basically functionality. (See Section 2.7)
>  
>  Brief summary of control files.
>  
> @@ -57,11 +56,8 @@ Brief summary of control files.
>  				 (See 5.5 for details)
>   memory.memsw.usage_in_bytes	 # show current res_counter usage for memory+Swap
>  				 (See 5.5 for details)
> - memory.kmem.usage_in_bytes	 # show current res_counter usage for kmem only.
> -				 (See 2.7 for details)
>   memory.limit_in_bytes		 # set/show limit of memory usage
>   memory.memsw.limit_in_bytes	 # set/show limit of memory+Swap usage
> - memory.kmem.limit_in_bytes	 # if allowed, set/show limit of kernel memory
>   memory.failcnt			 # show the number of memory usage hits limits
>   memory.memsw.failcnt		 # show the number of memory+Swap hits limits
>   memory.max_usage_in_bytes	 # show max memory usage recorded
> @@ -76,8 +72,6 @@ Brief summary of control files.
>   memory.oom_control		 # set/show oom controls.
>   memory.numa_stat		 # show the number of memory usage per numa node
>  
> - memory.independent_kmem_limit	 # select whether or not kernel memory limits are
> -				   independent of user limits
>   memory.kmem.tcp.limit_in_bytes  # set/show hard limit for tcp buf memory
>   memory.kmem.tcp.usage_in_bytes  # show current tcp buf memory allocation
>  
> @@ -271,21 +265,9 @@ the amount of kernel memory used by the system. Kernel memory is fundamentally
>  different than user memory, since it can't be swapped out, which makes it
>  possible to DoS the system by consuming too much of this precious resource.
>  
> -Some kernel memory resources may be accounted and limited separately from the
> -main "kmem" resource. For instance, a slab cache that is considered important
> -enough to be limited separately may have its own knobs.
> -
>  Kernel memory limits are not imposed for the root cgroup. Usage for the root
>  cgroup may or may not be accounted.
>  
> -Memory limits as specified by the standard Memory Controller may or may not
> -take kernel memory into consideration. This is achieved through the file
> -memory.independent_kmem_limit. A Value different than 0 will allow for kernel
> -memory to be controlled separately.
> -
> -When kernel memory limits are not independent, the limit values set in
> -memory.kmem files are ignored.
> -
>  Currently no soft limit is implemented for kernel memory. It is future work
>  to trigger slab reclaim when those limits are reached.
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 7266202..8cdc915 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -229,10 +229,6 @@ struct mem_cgroup {
>  	 */
>  	struct res_counter memsw;
>  	/*
> -	 * the counter to account for kmem usage.
> -	 */
> -	struct res_counter kmem;
> -	/*
>  	 * Per cgroup active and inactive list, similar to the
>  	 * per zone LRU lists.
>  	 */
> @@ -283,11 +279,6 @@ struct mem_cgroup {
>  	 */
>  	unsigned long 	move_charge_at_immigrate;
>  	/*
> -	 * Should kernel memory limits be stabilished independently
> -	 * from user memory ?
> -	 */
> -	int		kmem_independent_accounting;
> -	/*
>  	 * percpu counter.
>  	 */
>  	struct mem_cgroup_stat_cpu *stat;
> @@ -359,14 +350,9 @@ enum charge_type {
>  };
>  
>  /* for encoding cft->private value on file */
> -
> -enum mem_type {
> -	_MEM = 0,
> -	_MEMSWAP,
> -	_OOM_TYPE,
> -	_KMEM,
> -};
> -
> +#define _MEM			(0)
> +#define _MEMSWAP		(1)
> +#define _OOM_TYPE		(2)
>  #define MEMFILE_PRIVATE(x, val)	(((x) << 16) | (val))
>  #define MEMFILE_TYPE(val)	(((val) >> 16) & 0xffff)
>  #define MEMFILE_ATTR(val)	((val) & 0xffff)
> @@ -3919,17 +3905,10 @@ static inline u64 mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
>  	u64 val;
>  
>  	if (!mem_cgroup_is_root(memcg)) {
> -		val = 0;
> -#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> -		if (!memcg->kmem_independent_accounting)
> -			val = res_counter_read_u64(&memcg->kmem, RES_USAGE);
> -#endif
>  		if (!swap)
> -			val += res_counter_read_u64(&memcg->res, RES_USAGE);
> +			return res_counter_read_u64(&memcg->res, RES_USAGE);
>  		else
> -			val += res_counter_read_u64(&memcg->memsw, RES_USAGE);
> -
> -		return val;
> +			return res_counter_read_u64(&memcg->memsw, RES_USAGE);
>  	}
>  
>  	val = mem_cgroup_recursive_stat(memcg, MEM_CGROUP_STAT_CACHE);
> @@ -3962,11 +3941,6 @@ static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
>  		else
>  			val = res_counter_read_u64(&memcg->memsw, name);
>  		break;
> -#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> -	case _KMEM:
> -		val = res_counter_read_u64(&memcg->kmem, name);
> -		break;
> -#endif
>  	default:
>  		BUG();
>  		break;
> @@ -4696,59 +4670,8 @@ static int mem_control_numa_stat_open(struct inode *unused, struct file *file)
>  #endif /* CONFIG_NUMA */
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> -static u64 kmem_limit_independent_read(struct cgroup *cgroup, struct cftype *cft)
> -{
> -	return mem_cgroup_from_cont(cgroup)->kmem_independent_accounting;
> -}
> -
> -static int kmem_limit_independent_write(struct cgroup *cgroup, struct cftype *cft,
> -					u64 val)
> -{
> -	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgroup);
> -	struct mem_cgroup *parent = parent_mem_cgroup(memcg);
> -
> -	val = !!val;
> -
> -	/*
> -	 * This follows the same hierarchy restrictions than
> -	 * mem_cgroup_hierarchy_write()
> -	 */
> -	if (!parent || !parent->use_hierarchy) {
> -		if (list_empty(&cgroup->children))
> -			memcg->kmem_independent_accounting = val;
> -		else
> -			return -EBUSY;
> -	}
> -	else
> -		return -EINVAL;
> -
> -	return 0;
> -}
> -static struct cftype kmem_cgroup_files[] = {
> -	{
> -		.name = "independent_kmem_limit",
> -		.read_u64 = kmem_limit_independent_read,
> -		.write_u64 = kmem_limit_independent_write,
> -	},
> -	{
> -		.name = "kmem.usage_in_bytes",
> -		.private = MEMFILE_PRIVATE(_KMEM, RES_USAGE),
> -		.read_u64 = mem_cgroup_read,
> -	},
> -	{
> -		.name = "kmem.limit_in_bytes",
> -		.private = MEMFILE_PRIVATE(_KMEM, RES_LIMIT),
> -		.read_u64 = mem_cgroup_read,
> -	},
> -};
> -
>  static int register_kmem_files(struct cgroup *cont, struct cgroup_subsys *ss)
>  {
> -	int ret = 0;
> -
> -	ret = cgroup_add_files(cont, ss, kmem_cgroup_files,
> -			       ARRAY_SIZE(kmem_cgroup_files));
> -
>  	/*
>  	 * Part of this would be better living in a separate allocation
>  	 * function, leaving us with just the cgroup tree population work.
> @@ -4756,9 +4679,7 @@ static int register_kmem_files(struct cgroup *cont, struct cgroup_subsys *ss)
>  	 * is only initialized after cgroup creation. I found the less
>  	 * cumbersome way to deal with it to defer it all to populate time
>  	 */
> -	if (!ret)
> -		ret = mem_cgroup_sockets_init(cont, ss);
> -	return ret;
> +	return mem_cgroup_sockets_init(cont, ss);
>  };
>  
>  static void kmem_cgroup_destroy(struct cgroup_subsys *ss,
> @@ -5092,7 +5013,6 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  	if (parent && parent->use_hierarchy) {
>  		res_counter_init(&memcg->res, &parent->res);
>  		res_counter_init(&memcg->memsw, &parent->memsw);
> -		res_counter_init(&memcg->kmem, &parent->kmem);
>  		/*
>  		 * We increment refcnt of the parent to ensure that we can
>  		 * safely access it on res_counter_charge/uncharge.
> @@ -5103,7 +5023,6 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  	} else {
>  		res_counter_init(&memcg->res, NULL);
>  		res_counter_init(&memcg->memsw, NULL);
> -		res_counter_init(&memcg->kmem, NULL);
>  	}
>  	memcg->last_scanned_child = 0;
>  	memcg->last_scanned_node = MAX_NUMNODES;
> -- 
> 1.7.6.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic
