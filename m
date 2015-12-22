From: "Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/8] cgroup: implement cgroup_get_from_path() and expose
 cgroup_put()
Date: Mon, 21 Dec 2015 18:22:41 -0600
Message-ID: <20151222002240.GA6682@mail.hallyn.com>
References: <1449527935-27056-1-git-send-email-tj@kernel.org>
 <1449527935-27056-4-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org,
	daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-team-b10kYP2dOMg@public.gmane.org, ninasc-b10kYP2dOMg@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1449527935-27056-4-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 07, 2015 at 05:38:50PM -0500, Tejun Heo wrote:
> Implement cgroup_get_from_path() using kernfs_walk_and_get() which
> obtains a default hierarchy cgroup from its path.  This will be used
> to allow cgroup path based matching from outside cgroup proper -
> e.g. networking and perf.

Hi Tejun,

I'm trying to figure out how to handle this in the cgroup ns patchset.
Is this going to be purely used internally?  From the user i see in
this patchset it looks like I should leave it be (and have @path always
be absolute)  Is that right?

thanks,
-serge

> v2: Add EXPORT_SYMBOL_GPL(cgroup_get_from_path).
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> ---
>  include/linux/cgroup.h |  7 +++++++
>  kernel/cgroup.c        | 39 ++++++++++++++++++++++++++++++++++-----
>  2 files changed, 41 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index b5ee2c4..4c3ffab 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -81,6 +81,8 @@ struct cgroup_subsys_state *cgroup_get_e_css(struct cgroup *cgroup,
>  struct cgroup_subsys_state *css_tryget_online_from_dir(struct dentry *dentry,
>  						       struct cgroup_subsys *ss);
>  
> +struct cgroup *cgroup_get_from_path(const char *path);
> +
>  int cgroup_attach_task_all(struct task_struct *from, struct task_struct *);
>  int cgroup_transfer_tasks(struct cgroup *to, struct cgroup *from);
>  
> @@ -351,6 +353,11 @@ static inline void css_put_many(struct cgroup_subsys_state *css, unsigned int n)
>  		percpu_ref_put_many(&css->refcnt, n);
>  }
>  
> +static inline void cgroup_put(struct cgroup *cgrp)
> +{
> +	css_put(&cgrp->self);
> +}
> +
>  /**
>   * task_css_set_check - obtain a task's css_set with extra access conditions
>   * @task: the task to obtain css_set for
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 3190040..3db5e8f 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -434,11 +434,6 @@ static bool cgroup_tryget(struct cgroup *cgrp)
>  	return css_tryget(&cgrp->self);
>  }
>  
> -static void cgroup_put(struct cgroup *cgrp)
> -{
> -	css_put(&cgrp->self);
> -}
> -
>  struct cgroup_subsys_state *of_css(struct kernfs_open_file *of)
>  {
>  	struct cgroup *cgrp = of->kn->parent->priv;
> @@ -5753,6 +5748,40 @@ struct cgroup_subsys_state *css_from_id(int id, struct cgroup_subsys *ss)
>  	return id > 0 ? idr_find(&ss->css_idr, id) : NULL;
>  }
>  
> +/**
> + * cgroup_get_from_path - lookup and get a cgroup from its default hierarchy path
> + * @path: path on the default hierarchy
> + *
> + * Find the cgroup at @path on the default hierarchy, increment its
> + * reference count and return it.  Returns pointer to the found cgroup on
> + * success, ERR_PTR(-ENOENT) if @path doens't exist and ERR_PTR(-ENOTDIR)
> + * if @path points to a non-directory.
> + */
> +struct cgroup *cgroup_get_from_path(const char *path)
> +{
> +	struct kernfs_node *kn;
> +	struct cgroup *cgrp;
> +
> +	mutex_lock(&cgroup_mutex);
> +
> +	kn = kernfs_walk_and_get(cgrp_dfl_root.cgrp.kn, path);
> +	if (kn) {
> +		if (kernfs_type(kn) == KERNFS_DIR) {
> +			cgrp = kn->priv;
> +			cgroup_get(cgrp);
> +		} else {
> +			cgrp = ERR_PTR(-ENOTDIR);
> +		}
> +		kernfs_put(kn);
> +	} else {
> +		cgrp = ERR_PTR(-ENOENT);
> +	}
> +
> +	mutex_unlock(&cgroup_mutex);
> +	return cgrp;
> +}
> +EXPORT_SYMBOL_GPL(cgroup_get_from_path);
> +
>  #ifdef CONFIG_CGROUP_DEBUG
>  static struct cgroup_subsys_state *
>  debug_css_alloc(struct cgroup_subsys_state *parent_css)
> -- 
> 2.5.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
