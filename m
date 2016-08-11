From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH net-next v3 1/2] bpf: Add bpf_current_task_in_cgroup
 helper
Date: Thu, 11 Aug 2016 17:47:38 -0400
Message-ID: <20160811214738.GH2695@mtj.duckdns.org>
References: <20160811185140.GA28294@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	daniel@iogearbox.net
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f193.google.com ([209.85.213.193]:34923 "EHLO
	mail-yb0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932286AbcHKV67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 17:58:59 -0400
Received: by mail-yb0-f193.google.com with SMTP id m12so130834ybm.2
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 14:58:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160811185140.GA28294@ircssh.c.rugged-nimbus-611.internal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Sargun.

On Thu, Aug 11, 2016 at 11:51:42AM -0700, Sargun Dhillon wrote:
> This adds a bpf helper that's similar to the skb_in_cgroup helper to check
> whether the probe is currently executing in the context of a specific
> subset of the cgroupsv2 hierarchy. It does this based on membership test
> for a cgroup arraymap. It is invalid to call this in an interrupt, and
> it'll return an error. The helper is primarily to be used in debugging
> activities for containers, where you may have multiple programs running in
> a given top-level "container".
> 
> This patch also genericizes some of the arraymap fetching logic between the
> skb_in_cgroup helper and this new helper.

I think it'd be better to put the changes into separate patches.

> @@ -319,4 +319,26 @@ extern const struct bpf_func_proto bpf_get_stackid_proto;
>  void bpf_user_rnd_init_once(void);
>  u64 bpf_user_rnd_u32(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
>  
> +/* Helper to fetch a cgroup pointer based on index.

/**
 *

> + * @map: a cgroup arraymap
> + * @idx: index of the item you want to fetch
> + *
> + * Returns pointer on success,
> + * Error code if item not found, or out-of-bounds access
> + */
> +static inline struct cgroup *fetch_arraymap_ptr(struct bpf_map *map, int idx)
...
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 984f73b..d4e173d 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -497,6 +497,23 @@ static inline bool cgroup_is_descendant(struct cgroup *cgrp,
>  	return cgrp->ancestor_ids[ancestor->level] == ancestor->id;
>  }
>  
> +/**
> + * task_in_cgroup_hierarchy - test task's membership of cgroup ancestry
> + * @task: the task to be tested
> + * @ancestor: possible ancestor of @task's cgroup
> + *
> + * Tests whether @task's default cgroup hierarchy is a descendant of @ancestor.
> + * It follows all the same rules as cgroup_is_descendant, and only applies
> + * to the default hierarchy.
> + */
> +static inline bool task_in_cgroup_hierarchy(struct task_struct *task,
> +					    struct cgroup *ancestor)

Maybe task_is_under_cgroup() is a better name?

> @@ -574,6 +592,11 @@ static inline void cgroup_free(struct task_struct *p) {}
>  static inline int cgroup_init_early(void) { return 0; }
>  static inline int cgroup_init(void) { return 0; }
>  
> +static inline bool task_in_cgroup_hierarchy(struct task_struct *task,
> +					    struct cgroup *ancestor)
> +{
> +	return false;
> +}

If cgroup is not enabled, all tasks are in the root cgroup, so the
test should always return true.

> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -375,6 +375,17 @@ enum bpf_func_id {
>  	 */
>  	BPF_FUNC_probe_write_user,
>  
> +	/**
> +	 * bpf_current_task_in_cgroup(map, index) - Check cgroup2 membership of current task
> +	 * @map: pointer to bpf_map in BPF_MAP_TYPE_CGROUP_ARRAY type
> +	 * @index: index of the cgroup in the bpf_map
> +	 * Return:
> +	 *   == 0 current failed the cgroup2 descendant test
> +	 *   == 1 current succeeded the cgroup2 descendant test
> +	 *    < 0 error
> +	 */
> +	BPF_FUNC_current_task_in_cgroup,

I think "under" would be better than "in" here.

Thanks.

-- 
tejun
