From: Sargun Dhillon <sargun@sargun.me>
Subject: Re: [net-next v2 v2 1/2] bpf: Add bpf_current_task_in_cgroup helper
Date: Tue, 9 Aug 2016 20:40:05 -0700
Message-ID: <20160810034004.GA31242@ircssh.c.rugged-nimbus-611.internal>
References: <20160810000010.GA28455@ircssh.c.rugged-nimbus-611.internal>
 <20160810002349.GA19751@ast-mbp.thefacebook.com>
 <20160810005525.GA28930@ircssh.c.rugged-nimbus-611.internal>
 <20160810010232.GA21141@ast-mbp.thefacebook.com>
 <20160810012636.GB28930@ircssh.c.rugged-nimbus-611.internal>
 <20160810032730.GA22945@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:33169 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932584AbcHJDkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 23:40:33 -0400
Received: by mail-io0-f172.google.com with SMTP id 38so30444930iol.0
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2016 20:40:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160810032730.GA22945@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 09, 2016 at 08:27:32PM -0700, Alexei Starovoitov wrote:
> On Tue, Aug 09, 2016 at 06:26:37PM -0700, Sargun Dhillon wrote:
> > On Tue, Aug 09, 2016 at 06:02:34PM -0700, Alexei Starovoitov wrote:
> > > On Tue, Aug 09, 2016 at 05:55:26PM -0700, Sargun Dhillon wrote:
> > > > On Tue, Aug 09, 2016 at 05:23:50PM -0700, Alexei Starovoitov wrote:
> > > > > On Tue, Aug 09, 2016 at 05:00:12PM -0700, Sargun Dhillon wrote:
> > > > > > This adds a bpf helper that's similar to the skb_in_cgroup helper to check
> > > > > > whether the probe is currently executing in the context of a specific
> > > > > > subset of the cgroupsv2 hierarchy. It does this based on membership test
> > > > > > for a cgroup arraymap. It is invalid to call this in an interrupt, and
> > > > > > it'll return an error. The helper is primarily to be used in debugging
> > > > > > activities for containers, where you may have multiple programs running in
> > > > > > a given top-level "container".
> > > > > > 
> > > > > > This patch also genericizes some of the arraymap fetching logic between the
> > > > > > skb_in_cgroup helper and this new helper.
> > > > > > 
> > > > > > Signed-off-by: Sargun Dhillon <sargun@sargun.me>
> > > > > > Cc: Alexei Starovoitov <ast@kernel.org>
> > > > > > Cc: Daniel Borkmann <daniel@iogearbox.net>
> > > > > > ---
> > > > > >  include/linux/bpf.h      | 24 ++++++++++++++++++++++++
> > > > > >  include/uapi/linux/bpf.h | 11 +++++++++++
> > > > > >  kernel/bpf/arraymap.c    |  2 +-
> > > > > >  kernel/bpf/verifier.c    |  4 +++-
> > > > > >  kernel/trace/bpf_trace.c | 34 ++++++++++++++++++++++++++++++++++
> > > > > >  net/core/filter.c        | 11 ++++-------
> > > > > >  6 files changed, 77 insertions(+), 9 deletions(-)
> > > > > > 
> > > > > > diff --git a/include/linux/bpf.h b/include/linux/bpf.h
> > > > > > index 1113423..9adf712 100644
> > > > > > --- a/include/linux/bpf.h
> > > > > > +++ b/include/linux/bpf.h
> > > > > > @@ -319,4 +319,28 @@ extern const struct bpf_func_proto bpf_get_stackid_proto;
> > > > > >  void bpf_user_rnd_init_once(void);
> > > > > >  u64 bpf_user_rnd_u32(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
> > > > > >  
> > > > > > +#ifdef CONFIG_CGROUPS
> > > > > > +/* Helper to fetch a cgroup pointer based on index.
> > > > > > + * @map: a cgroup arraymap
> > > > > > + * @idx: index of the item you want to fetch
> > > > > > + *
> > > > > > + * Returns pointer on success,
> > > > > > + * Error code if item not found, or out-of-bounds access
> > > > > > + */
> > > > > > +static inline struct cgroup *fetch_arraymap_ptr(struct bpf_map *map, int idx)
> > > > > > +{
> > > > > > +	struct cgroup *cgrp;
> > > > > > +	struct bpf_array *array = container_of(map, struct bpf_array, map);
> > > > > > +
> > > > > > +	if (unlikely(idx >= array->map.max_entries))
> > > > > > +		return ERR_PTR(-E2BIG);
> > > > > > +
> > > > > > +	cgrp = READ_ONCE(array->ptrs[idx]);
> > > > > > +	if (unlikely(!cgrp))
> > > > > > +		return ERR_PTR(-EAGAIN);
> > > > > > +
> > > > > > +	return cgrp;
> > > > > > +}
> > > > > > +#endif /* CONFIG_CGROUPS */
> > > > > > +
> > > > > >  #endif /* _LINUX_BPF_H */
> > > > > > diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> > > > > > index da218fe..64b1a07 100644
> > > > > > --- a/include/uapi/linux/bpf.h
> > > > > > +++ b/include/uapi/linux/bpf.h
> > > > > > @@ -375,6 +375,17 @@ enum bpf_func_id {
> > > > > >  	 */
> > > > > >  	BPF_FUNC_probe_write_user,
> > > > > >  
> > > > > > +	/**
> > > > > > +	 * bpf_current_task_in_cgroup(map, index) - Check cgroup2 membership of current task
> > > > > > +	 * @map: pointer to bpf_map in BPF_MAP_TYPE_CGROUP_ARRAY type
> > > > > > +	 * @index: index of the cgroup in the bpf_map
> > > > > > +	 * Return:
> > > > > > +	 *   == 0 current failed the cgroup2 descendant test
> > > > > > +	 *   == 1 current succeeded the cgroup2 descendant test
> > > > > > +	 *    < 0 error
> > > > > > +	 */
> > > > > > +	BPF_FUNC_current_task_in_cgroup,
> > > > > > +
> > > > > >  	__BPF_FUNC_MAX_ID,
> > > > > >  };
> > > > > >  
> > > > > > diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
> > > > > > index 633a650..a2ac051 100644
> > > > > > --- a/kernel/bpf/arraymap.c
> > > > > > +++ b/kernel/bpf/arraymap.c
> > > > > > @@ -538,7 +538,7 @@ static int __init register_perf_event_array_map(void)
> > > > > >  }
> > > > > >  late_initcall(register_perf_event_array_map);
> > > > > >  
> > > > > > -#ifdef CONFIG_SOCK_CGROUP_DATA
> > > > > > +#ifdef CONFIG_CGROUPS
> > > > > >  static void *cgroup_fd_array_get_ptr(struct bpf_map *map,
> > > > > >  				     struct file *map_file /* not used */,
> > > > > >  				     int fd)
> > > > > > diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> > > > > > index 7094c69..80efab8 100644
> > > > > > --- a/kernel/bpf/verifier.c
> > > > > > +++ b/kernel/bpf/verifier.c
> > > > > > @@ -1053,7 +1053,8 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
> > > > > >  			goto error;
> > > > > >  		break;
> > > > > >  	case BPF_MAP_TYPE_CGROUP_ARRAY:
> > > > > > -		if (func_id != BPF_FUNC_skb_in_cgroup)
> > > > > > +		if (func_id != BPF_FUNC_skb_in_cgroup &&
> > > > > > +		    func_id != BPF_FUNC_current_task_in_cgroup)
> > > > > >  			goto error;
> > > > > >  		break;
> > > > > >  	default:
> > > > > > @@ -1075,6 +1076,7 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
> > > > > >  		if (map->map_type != BPF_MAP_TYPE_STACK_TRACE)
> > > > > >  			goto error;
> > > > > >  		break;
> > > > > > +	case BPF_FUNC_current_task_in_cgroup:
> > > > > >  	case BPF_FUNC_skb_in_cgroup:
> > > > > >  		if (map->map_type != BPF_MAP_TYPE_CGROUP_ARRAY)
> > > > > >  			goto error;
> > > > > > diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
> > > > > > index b20438f..39f0290 100644
> > > > > > --- a/kernel/trace/bpf_trace.c
> > > > > > +++ b/kernel/trace/bpf_trace.c
> > > > > > @@ -376,6 +376,36 @@ static const struct bpf_func_proto bpf_get_current_task_proto = {
> > > > > >  	.ret_type	= RET_INTEGER,
> > > > > >  };
> > > > > >  
> > > > > > +#ifdef CONFIG_CGROUPS
> > > > > > +static u64 bpf_current_task_in_cgroup(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
> > > > > 
> > > > > please don't introduce #ifdef into .c code.
> > > > > In this case add #else in .h to fetch_arraymap_ptr() that returns -EOPNOTSUPP.
> > > > > Also why guard it with CONFIG_CGROUPS in .h at all?
> > > > > I think it should compile fine even when cgroups are not defined.
> > > > > The helper won't be functional anyway, since no cgroup_fd can be added
> > > > > to cgroup map.
> > > > > 
> > > > Pardon my ignorance, but if I don't have an ifdef wont I be referencing a bunch 
> > > > of non-existent code (like cgroup_is_descendant)? Unless your suggestion is to 
> > > > move this to the .h file as well.
> > > 
> > > I see. If cgroup_is_descendant is the only function we use, how about
> > > adding it as 'return false' in #else part of linux/cgroup.h ?
> > > There are a bunch of them there like cgroup_exit/cgroup_free/...
> > > 
> > It appears messier than that:
> > kernel/trace/bpf_trace.c: In function ‘bpf_current_task_in_cgroup’:
> > kernel/trace/bpf_trace.c:394:9: error: implicit declaration of function ‘task_css_set’ [-Werror=implicit-function-declaration]
> >   cset = task_css_set(current);
> >          ^
> > kernel/trace/bpf_trace.c:394:7: warning: assignment makes pointer from integer without a cast [-Wint-conversion]
> >   cset = task_css_set(current);
> >        ^
> > kernel/trace/bpf_trace.c:396:9: error: implicit declaration of function ‘cgroup_is_descendant’ [-Werror=implicit-function-declaration]
> >   return cgroup_is_descendant(cset->dfl_cgrp, cgrp);
> >          ^
> > kernel/trace/bpf_trace.c:396:34: error: dereferencing pointer to incomplete type ‘struct css_set’
> >   return cgroup_is_descendant(cset->dfl_cgrp, cgrp);
> 
> yeah. exporting struct css_set is too much. 
> No other ideas how to reduce so many #ifdef CONFIG_CGROUPS.
> At least the one in .h can be dropped, right?
> Please cc Tejun in the next spin.
> 
The path I'm going down is to add this helper to cgroup.h:

#ifdef CONFIG_CGROUPS
/**
 * task_in_cgroup_hierarchy - test task's membership of cgroup ancestry
 * @task: the task to be tested
 * @ancestor: possible ancestor of @task's cgroup
 *
 * Tests whether @task's default cgroup hierarchy is a descendant of @ancestor.
 * It follows all the same rules as cgroup_is_descendant, and only applies
 * to the default hierarchy.
 */
static inline bool task_in_cgroup_hierarchy(struct task_struct *task,
					    struct cgroup *ancestor)
{
	struct css_set *cset = task_css_set(task);
	return cgroup_is_descendant(cset->dfl_cgrp, ancestor);
}

#else

struct cgroup;
static inline bool task_in_cgroup_hierarchy(struct task_struct *task,
				  struct cgroup *ancestor) { return false; }
#endif


It gets rid of all of the CONFIG_CGROUPS, and I think it's a useful helper for 
others. I can't be the only one, esp. as we move towards cgroupv2 more that
depends on default cgroups hierarchy checks.
