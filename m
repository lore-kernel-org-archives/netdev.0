From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: [PATCH v2 07/10] ipcns: Add a  limit on the number of ipc
 namespaces
Date: Mon, 25 Jul 2016 18:10:29 -0500
Message-ID: <20160725231029.GE26841@mail.hallyn.com>
References: <87d1m754jc.fsf@x220.int.ebiederm.org>
 <20160721164014.17534-1-ebiederm@xmission.com>
 <20160721164014.17534-7-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Containers <containers@lists.linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Jann Horn <jann@thejh.net>, Kees Cook <keescook@chromium.org>,
	Nikolay Borisov <kernel@kyup.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Seth Forshee <seth.forshee@canonical.com>,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160721164014.17534-7-ebiederm@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Eric W. Biederman (ebiederm@xmission.com):
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Acked-by: Serge Hallyn <serge@hallyn.com>

> ---
>  include/linux/user_namespace.h |  1 +
>  ipc/namespace.c                | 42 +++++++++++++++++++++++++++++++-----------
>  kernel/user_namespace.c        |  1 +
>  3 files changed, 33 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
> index bed2506081fe..367cf08ff63d 100644
> --- a/include/linux/user_namespace.h
> +++ b/include/linux/user_namespace.h
> @@ -26,6 +26,7 @@ enum ucounts {
>  	UCOUNT_USER_NAMESPACES,
>  	UCOUNT_PID_NAMESPACES,
>  	UCOUNT_UTS_NAMESPACES,
> +	UCOUNT_IPC_NAMESPACES,
>  	UCOUNT_COUNTS,
>  };
>  
> diff --git a/ipc/namespace.c b/ipc/namespace.c
> index 04cb07eb81f1..3996a1e41a1d 100644
> --- a/ipc/namespace.c
> +++ b/ipc/namespace.c
> @@ -16,33 +16,42 @@
>  
>  #include "util.h"
>  
> +static bool inc_ipc_namespaces(struct user_namespace *ns)
> +{
> +	return inc_ucount(ns, UCOUNT_IPC_NAMESPACES);
> +}
> +
> +static void dec_ipc_namespaces(struct user_namespace *ns)
> +{
> +	dec_ucount(ns, UCOUNT_IPC_NAMESPACES);
> +}
> +
>  static struct ipc_namespace *create_ipc_ns(struct user_namespace *user_ns,
>  					   struct ipc_namespace *old_ns)
>  {
>  	struct ipc_namespace *ns;
>  	int err;
>  
> +	err = -ENFILE;
> +	if (!inc_ipc_namespaces(user_ns))
> +		goto fail;
> +
> +	err = -ENOMEM;
>  	ns = kmalloc(sizeof(struct ipc_namespace), GFP_KERNEL);
>  	if (ns == NULL)
> -		return ERR_PTR(-ENOMEM);
> +		goto fail_dec;
>  
>  	err = ns_alloc_inum(&ns->ns);
> -	if (err) {
> -		kfree(ns);
> -		return ERR_PTR(err);
> -	}
> +	if (err)
> +		goto fail_free;
>  	ns->ns.ops = &ipcns_operations;
>  
>  	atomic_set(&ns->count, 1);
>  	ns->user_ns = get_user_ns(user_ns);
>  
>  	err = mq_init_ns(ns);
> -	if (err) {
> -		put_user_ns(ns->user_ns);
> -		ns_free_inum(&ns->ns);
> -		kfree(ns);
> -		return ERR_PTR(err);
> -	}
> +	if (err)
> +		goto fail_put;
>  	atomic_inc(&nr_ipc_ns);
>  
>  	sem_init_ns(ns);
> @@ -50,6 +59,16 @@ static struct ipc_namespace *create_ipc_ns(struct user_namespace *user_ns,
>  	shm_init_ns(ns);
>  
>  	return ns;
> +
> +fail_put:
> +	put_user_ns(ns->user_ns);
> +	ns_free_inum(&ns->ns);
> +fail_free:
> +	kfree(ns);
> +fail_dec:
> +	dec_ipc_namespaces(user_ns);
> +fail:
> +	return ERR_PTR(err);
>  }
>  
>  struct ipc_namespace *copy_ipcs(unsigned long flags,
> @@ -98,6 +117,7 @@ static void free_ipc_ns(struct ipc_namespace *ns)
>  	shm_exit_ns(ns);
>  	atomic_dec(&nr_ipc_ns);
>  
> +	dec_ipc_namespaces(ns->user_ns);
>  	put_user_ns(ns->user_ns);
>  	ns_free_inum(&ns->ns);
>  	kfree(ns);
> diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
> index 6b205c24e888..060d3e099f87 100644
> --- a/kernel/user_namespace.c
> +++ b/kernel/user_namespace.c
> @@ -79,6 +79,7 @@ static struct ctl_table userns_table[] = {
>  	UCOUNT_ENTRY("max_user_namespaces"),
>  	UCOUNT_ENTRY("max_pid_namespaces"),
>  	UCOUNT_ENTRY("max_uts_namespaces"),
> +	UCOUNT_ENTRY("max_ipc_namespaces"),
>  	{ }
>  };
>  #endif /* CONFIG_SYSCTL */
> -- 
> 2.8.3
