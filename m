From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2 06/10] cgroup: Assign subsystem IDs during compile
 time
Date: Fri, 24 Aug 2012 16:38:10 -0700
Message-ID: <20120824233810.GT21325@google.com>
References: <1345816904-21745-1-git-send-email-wagi@monom.org>
 <1345816904-21745-7-git-send-email-wagi@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1345816904-21745-7-git-send-email-wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

On Fri, Aug 24, 2012 at 04:01:40PM +0200, Daniel Wagner wrote:
> We are able to safe some space when we assign the subsystem
                 ^               ^
		 save    if we assign both builtin and
		         module susbsystem IDs at compile time?

> IDs at compile time. Instead of allocating per cgroup
> cgroup->subsys[CGROUP_SUBSYS_COUNT] where CGROUP_SUBSYS_COUNT is
> always 64, we allocate at max 12 (at this point there are 12
> subsystem).

Please note (in big fat ugly way) that this disallows support for
modular controller which isn't known at kernel compile time.

> task_cls_classid() and task_netprioidx() (when built as
> module) are protected by a jump label and therefore we can
> simply replace the subsystem index lookup with the enum.

Can we put these in a separate patch?  ie. The first patch makes all
subsys IDs constant and then patches to simplify users.

> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 3787872..ada517f 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -43,18 +43,27 @@ extern void cgroup_unload_subsys(struct cgroup_subsys *ss);
>  
>  extern const struct file_operations proc_cgroup_operations;
>  
> -/* Define the enumeration of all builtin cgroup subsystems */
> -#define SUBSYS(_x) _x ## _subsys_id,
> +/*
> + * Define the enumeration of all builtin cgroup subsystems.
> + * For the builtin subsystems the subsys_id needs to be indentical
> + * with the index in css->subsys. Therefore, all the builtin
> + * subsys are listed first and then the modules ids.
> + */
>  enum cgroup_subsys_id {
> +#define SUBSYS(_x) _x ## _subsys_id,
> +
> +#define IS_SUBSYS_ENABLED(option) IS_BUILTIN(option)
>  #include <linux/cgroup_subsys.h>
> -};
> +#undef IS_SUBSYS_ENABLED
> +
> +#define IS_SUBSYS_ENABLED(option) IS_MODULE(option)
> +#include <linux/cgroup_subsys.h>
> +#undef IS_SUBSYS_ENABLED
> +

Why do we need to segregate in-kernel and modular ones at all?  What's
wrong with just defining them in one go?

> diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
> index 24443d2..43fae13 100644
> --- a/include/net/cls_cgroup.h
> +++ b/include/net/cls_cgroup.h
> @@ -49,22 +49,16 @@ static inline u32 task_cls_classid(struct task_struct *p)
>  extern struct static_key cgroup_cls_enabled;
>  #define clscg_enabled static_key_false(&cgroup_cls_enabled)
>  
> -extern int net_cls_subsys_id;
> -
>  static inline u32 task_cls_classid(struct task_struct *p)
>  {
> -	int id;
> -	u32 classid = 0;
> +	u32 classid;
>  
>  	if (!clscg_enabled || in_interrupt())
>  		return 0;
>  
>  	rcu_read_lock();
> -	id = rcu_dereference_index_check(net_cls_subsys_id,
> -					 rcu_read_lock_held());
> -	if (id >= 0)
> -		classid = container_of(task_subsys_state(p, id),
> -				       struct cgroup_cls_state, css)->classid;
> +	classid = container_of(task_subsys_state(p, net_cls_subsys_id),
> +			       struct cgroup_cls_state, css)->classid;
>  	rcu_read_unlock();
>  
>  	return classid;

Hmm... patch sequence looks odd to me.  If you first make all IDs
constant, you can first remove module specific ones and then later add
jump labels as separate patches.  Wouldn't that be simpler?

Thanks.

-- 
tejun
