From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 08/10] cgroupns: Add a limit on the number of cgroup
 namespaces
Date: Mon, 25 Jul 2016 18:12:05 -0500
Message-ID: <20160725231205.GF26841@mail.hallyn.com>
References: <87d1m754jc.fsf@x220.int.ebiederm.org>
 <20160721164014.17534-1-ebiederm@xmission.com>
 <20160721164014.17534-8-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>,
	"Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>,
	Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160721164014.17534-8-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Acked-by: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>

> ---
>  include/linux/user_namespace.h |  1 +
>  kernel/cgroup.c                | 15 +++++++++++++++
>  kernel/user_namespace.c        |  1 +
>  3 files changed, 17 insertions(+)
> 
> diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
> index 367cf08ff63d..1a3a9cb93277 100644
> --- a/include/linux/user_namespace.h
> +++ b/include/linux/user_namespace.h
> @@ -27,6 +27,7 @@ enum ucounts {
>  	UCOUNT_PID_NAMESPACES,
>  	UCOUNT_UTS_NAMESPACES,
>  	UCOUNT_IPC_NAMESPACES,
> +	UCOUNT_CGROUP_NAMESPACES,
>  	UCOUNT_COUNTS,
>  };
>  
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 86cb5c6e8932..240eec43390b 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -6260,6 +6260,16 @@ void cgroup_sk_free(struct sock_cgroup_data *skcd)
>  
>  /* cgroup namespaces */
>  
> +static bool inc_cgroup_namespaces(struct user_namespace *ns)
> +{
> +	return inc_ucount(ns, UCOUNT_CGROUP_NAMESPACES);
> +}
> +
> +static void dec_cgroup_namespaces(struct user_namespace *ns)
> +{
> +	dec_ucount(ns, UCOUNT_CGROUP_NAMESPACES);
> +}
> +
>  static struct cgroup_namespace *alloc_cgroup_ns(void)
>  {
>  	struct cgroup_namespace *new_ns;
> @@ -6281,6 +6291,7 @@ static struct cgroup_namespace *alloc_cgroup_ns(void)
>  void free_cgroup_ns(struct cgroup_namespace *ns)
>  {
>  	put_css_set(ns->root_cset);
> +	dec_cgroup_namespaces(ns->user_ns);
>  	put_user_ns(ns->user_ns);
>  	ns_free_inum(&ns->ns);
>  	kfree(ns);
> @@ -6305,6 +6316,9 @@ struct cgroup_namespace *copy_cgroup_ns(unsigned long flags,
>  	if (!ns_capable(user_ns, CAP_SYS_ADMIN))
>  		return ERR_PTR(-EPERM);
>  
> +	if (!inc_cgroup_namespaces(user_ns))
> +		return ERR_PTR(-ENFILE);
> +
>  	mutex_lock(&cgroup_mutex);
>  	spin_lock_bh(&css_set_lock);
>  
> @@ -6317,6 +6331,7 @@ struct cgroup_namespace *copy_cgroup_ns(unsigned long flags,
>  	new_ns = alloc_cgroup_ns();
>  	if (IS_ERR(new_ns)) {
>  		put_css_set(cset);
> +		dec_cgroup_namespaces(user_ns);
>  		return new_ns;
>  	}
>  
> diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
> index 060d3e099f87..1cf074cb47e2 100644
> --- a/kernel/user_namespace.c
> +++ b/kernel/user_namespace.c
> @@ -80,6 +80,7 @@ static struct ctl_table userns_table[] = {
>  	UCOUNT_ENTRY("max_pid_namespaces"),
>  	UCOUNT_ENTRY("max_uts_namespaces"),
>  	UCOUNT_ENTRY("max_ipc_namespaces"),
> +	UCOUNT_ENTRY("max_cgroup_namespaces"),
>  	{ }
>  };
>  #endif /* CONFIG_SYSCTL */
> -- 
> 2.8.3
