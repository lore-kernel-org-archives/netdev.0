From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2/2] Rename nsproxy.pid_ns to nsproxy.pid_ns_for_children
Date: Mon, 26 Aug 2013 18:02:42 -0700
Message-ID: <87y57olzd9.fsf@xmission.com>
References: <cover.1377196394.git.luto@amacapital.net>
	<cover.1377196394.git.luto@amacapital.net>
	<a5db0606160dbd1412828be0d91a4a115a84abf6.1377196394.git.luto@amacapital.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: security@kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a5db0606160dbd1412828be0d91a4a115a84abf6.1377196394.git.luto@amacapital.net>
	(Andy Lutomirski's message of "Thu, 22 Aug 2013 11:39:16 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Lutomirski <luto@amacapital.net> writes:

> nsproxy.pid_ns is *not* the task's pid namespace.  The name should clarify
> that.
>
> This makes it more obvious that setns on a pid namespace is weird --
> it won't change the pid namespace shown in procfs.

Reviewed-by: "Eric W. Biederman" <ebiederm@xmission.com>

> Signed-off-by: Andy Lutomirski <luto@amacapital.net>
> ---
>  include/linux/nsproxy.h |  6 +++++-
>  kernel/fork.c           |  5 +++--
>  kernel/nsproxy.c        | 27 ++++++++++++++-------------
>  kernel/pid_namespace.c  |  4 ++--
>  4 files changed, 24 insertions(+), 18 deletions(-)
>
> diff --git a/include/linux/nsproxy.h b/include/linux/nsproxy.h
> index 10e5947..b4ec59d 100644
> --- a/include/linux/nsproxy.h
> +++ b/include/linux/nsproxy.h
> @@ -14,6 +14,10 @@ struct fs_struct;
>   * A structure to contain pointers to all per-process
>   * namespaces - fs (mount), uts, network, sysvipc, etc.
>   *
> + * The pid namespace is an exception -- it's accessed using
> + * task_active_pid_ns.  The pid namespace here is the
> + * namespace that children will use.
> + *
>   * 'count' is the number of tasks holding a reference.
>   * The count for each namespace, then, will be the number
>   * of nsproxies pointing to it, not the number of tasks.
> @@ -27,7 +31,7 @@ struct nsproxy {
>  	struct uts_namespace *uts_ns;
>  	struct ipc_namespace *ipc_ns;
>  	struct mnt_namespace *mnt_ns;
> -	struct pid_namespace *pid_ns;
> +	struct pid_namespace *pid_ns_for_children;
>  	struct net 	     *net_ns;
>  };
>  extern struct nsproxy init_nsproxy;
> diff --git a/kernel/fork.c b/kernel/fork.c
> index e23bb19..bf46287 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -1177,7 +1177,8 @@ static struct task_struct *copy_process(unsigned long clone_flags,
>  	 * don't allow the creation of threads.
>  	 */
>  	if ((clone_flags & (CLONE_VM|CLONE_NEWPID)) &&
> -	    (task_active_pid_ns(current) != current->nsproxy->pid_ns))
> +	    (task_active_pid_ns(current) !=
> +	     current->nsproxy->pid_ns_for_children))
>  		return ERR_PTR(-EINVAL);
>  
>  	retval = security_task_create(clone_flags);
> @@ -1351,7 +1352,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
>  
>  	if (pid != &init_struct_pid) {
>  		retval = -ENOMEM;
> -		pid = alloc_pid(p->nsproxy->pid_ns);
> +		pid = alloc_pid(p->nsproxy->pid_ns_for_children);
>  		if (!pid)
>  			goto bad_fork_cleanup_io;
>  	}
> diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
> index 364ceab..997cbb9 100644
> --- a/kernel/nsproxy.c
> +++ b/kernel/nsproxy.c
> @@ -29,15 +29,15 @@
>  static struct kmem_cache *nsproxy_cachep;
>  
>  struct nsproxy init_nsproxy = {
> -	.count	= ATOMIC_INIT(1),
> -	.uts_ns	= &init_uts_ns,
> +	.count			= ATOMIC_INIT(1),
> +	.uts_ns			= &init_uts_ns,
>  #if defined(CONFIG_POSIX_MQUEUE) || defined(CONFIG_SYSVIPC)
> -	.ipc_ns	= &init_ipc_ns,
> +	.ipc_ns			= &init_ipc_ns,
>  #endif
> -	.mnt_ns	= NULL,
> -	.pid_ns	= &init_pid_ns,
> +	.mnt_ns			= NULL,
> +	.pid_ns_for_children	= &init_pid_ns,
>  #ifdef CONFIG_NET
> -	.net_ns	= &init_net,
> +	.net_ns			= &init_net,
>  #endif
>  };
>  
> @@ -85,9 +85,10 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
>  		goto out_ipc;
>  	}
>  
> -	new_nsp->pid_ns = copy_pid_ns(flags, user_ns, tsk->nsproxy->pid_ns);
> -	if (IS_ERR(new_nsp->pid_ns)) {
> -		err = PTR_ERR(new_nsp->pid_ns);
> +	new_nsp->pid_ns_for_children =
> +		copy_pid_ns(flags, user_ns, tsk->nsproxy->pid_ns_for_children);
> +	if (IS_ERR(new_nsp->pid_ns_for_children)) {
> +		err = PTR_ERR(new_nsp->pid_ns_for_children);
>  		goto out_pid;
>  	}
>  
> @@ -100,8 +101,8 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
>  	return new_nsp;
>  
>  out_net:
> -	if (new_nsp->pid_ns)
> -		put_pid_ns(new_nsp->pid_ns);
> +	if (new_nsp->pid_ns_for_children)
> +		put_pid_ns(new_nsp->pid_ns_for_children);
>  out_pid:
>  	if (new_nsp->ipc_ns)
>  		put_ipc_ns(new_nsp->ipc_ns);
> @@ -174,8 +175,8 @@ void free_nsproxy(struct nsproxy *ns)
>  		put_uts_ns(ns->uts_ns);
>  	if (ns->ipc_ns)
>  		put_ipc_ns(ns->ipc_ns);
> -	if (ns->pid_ns)
> -		put_pid_ns(ns->pid_ns);
> +	if (ns->pid_ns_for_children)
> +		put_pid_ns(ns->pid_ns_for_children);
>  	put_net(ns->net_ns);
>  	kmem_cache_free(nsproxy_cachep, ns);
>  }
> diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
> index 6917e8e..601bb36 100644
> --- a/kernel/pid_namespace.c
> +++ b/kernel/pid_namespace.c
> @@ -349,8 +349,8 @@ static int pidns_install(struct nsproxy *nsproxy, void *ns)
>  	if (ancestor != active)
>  		return -EINVAL;
>  
> -	put_pid_ns(nsproxy->pid_ns);
> -	nsproxy->pid_ns = get_pid_ns(new);
> +	put_pid_ns(nsproxy->pid_ns_for_children);
> +	nsproxy->pid_ns_for_children = get_pid_ns(new);
>  	return 0;
>  }
