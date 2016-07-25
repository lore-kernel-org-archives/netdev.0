From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 10/10] mntns: Add a limit on the number of mount
	namespaces.
Date: Mon, 25 Jul 2016 18:15:22 -0500
Message-ID: <20160725231522.GH26841@mail.hallyn.com>
References: <87d1m754jc.fsf@x220.int.ebiederm.org>
	<20160721164014.17534-1-ebiederm@xmission.com>
	<20160721164014.17534-10-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160721164014.17534-10-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Acked-by: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>

Thanks, Eric.

> ---
>  fs/namespace.c                 | 19 ++++++++++++++++++-
>  include/linux/user_namespace.h |  1 +
>  kernel/user_namespace.c        |  1 +
>  3 files changed, 20 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/namespace.c b/fs/namespace.c
> index aabe8e397fc3..3942ae6c34f5 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -2718,9 +2718,20 @@ dput_out:
>  	return retval;
>  }
>  
> +static bool inc_mnt_namespaces(struct user_namespace *ns)
> +{
> +	return inc_ucount(ns, UCOUNT_MNT_NAMESPACES);
> +}
> +
> +static void dec_mnt_namespaces(struct user_namespace *ns)
> +{
> +	dec_ucount(ns, UCOUNT_MNT_NAMESPACES);
> +}
> +
>  static void free_mnt_ns(struct mnt_namespace *ns)
>  {
>  	ns_free_inum(&ns->ns);
> +	dec_mnt_namespaces(ns->user_ns);
>  	put_user_ns(ns->user_ns);
>  	kfree(ns);
>  }
> @@ -2739,12 +2750,18 @@ static struct mnt_namespace *alloc_mnt_ns(struct user_namespace *user_ns)
>  	struct mnt_namespace *new_ns;
>  	int ret;
>  
> +	if (!inc_mnt_namespaces(user_ns))
> +		return ERR_PTR(-ENFILE);
> +
>  	new_ns = kmalloc(sizeof(struct mnt_namespace), GFP_KERNEL);
> -	if (!new_ns)
> +	if (!new_ns) {
> +		dec_mnt_namespaces(user_ns);
>  		return ERR_PTR(-ENOMEM);
> +	}
>  	ret = ns_alloc_inum(&new_ns->ns);
>  	if (ret) {
>  		kfree(new_ns);
> +		dec_mnt_namespaces(user_ns);
>  		return ERR_PTR(ret);
>  	}
>  	new_ns->ns.ops = &mntns_operations;
> diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
> index f86afa536baf..ee0e9d7b2e67 100644
> --- a/include/linux/user_namespace.h
> +++ b/include/linux/user_namespace.h
> @@ -28,6 +28,7 @@ enum ucounts {
>  	UCOUNT_UTS_NAMESPACES,
>  	UCOUNT_IPC_NAMESPACES,
>  	UCOUNT_NET_NAMESPACES,
> +	UCOUNT_MNT_NAMESPACES,
>  	UCOUNT_CGROUP_NAMESPACES,
>  	UCOUNT_COUNTS,
>  };
> diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
> index e326ca722ae0..f6702d84afab 100644
> --- a/kernel/user_namespace.c
> +++ b/kernel/user_namespace.c
> @@ -81,6 +81,7 @@ static struct ctl_table userns_table[] = {
>  	UCOUNT_ENTRY("max_uts_namespaces"),
>  	UCOUNT_ENTRY("max_ipc_namespaces"),
>  	UCOUNT_ENTRY("max_net_namespaces"),
> +	UCOUNT_ENTRY("max_mnt_namespaces"),
>  	UCOUNT_ENTRY("max_cgroup_namespaces"),
>  	{ }
>  };
> -- 
> 2.8.3
