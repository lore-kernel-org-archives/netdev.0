From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 01/11] SYSCTL: export root and set handling routines
Date: Sat, 17 Dec 2011 14:25:14 -0800
Message-ID: <m1bor6rg39.fsf@fess.ebiederm.org>
References: <20111214103602.3991.20990.stgit@localhost6.localdomain6>
	<20111214104449.3991.61989.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org,
	bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20111214104449.3991.61989.stgit-bi+AKbBUZKagILUCTcTcHdKyNwTtLsGr@public.gmane.org>
	(Stanislav Kinsbursky's message of "Wed, 14 Dec 2011 14:44:49 +0300")
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> writes:

> These routines are required for making SUNRPC sysctl's per network namespace
> context.

Why does sunrpc require it's own sysctl root?  You should be able to use
the generic per network namespace root and call it good.

What makes register_net_sysctl_table and register_net_sysctl_ro_table
unsuitable for sunrpc.  I skimmed through your patches and I haven't
seen anything obvious.

Eric


> Signed-off-by: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
>
> ---
>  include/linux/sysctl.h |    1 +
>  kernel/sysctl.c        |   11 +++++++++++
>  2 files changed, 12 insertions(+), 0 deletions(-)
>
> diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
> index 703cfa3..be586a9 100644
> --- a/include/linux/sysctl.h
> +++ b/include/linux/sysctl.h
> @@ -1084,6 +1084,7 @@ struct ctl_path {
>  };
>  
>  void register_sysctl_root(struct ctl_table_root *root);
> +void unregister_sysctl_root(struct ctl_table_root *root);
>  struct ctl_table_header *__register_sysctl_paths(
>  	struct ctl_table_root *root, struct nsproxy *namespaces,
>  	const struct ctl_path *path, struct ctl_table *table);
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index ae27196..fb016a9 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -1700,6 +1700,15 @@ void register_sysctl_root(struct ctl_table_root *root)
>  	list_add_tail(&root->root_list, &sysctl_table_root.root_list);
>  	spin_unlock(&sysctl_lock);
>  }
> +EXPORT_SYMBOL_GPL(register_sysctl_root);
> +
> +void unregister_sysctl_root(struct ctl_table_root *root)
> +{
> +	spin_lock(&sysctl_lock);
> +	list_del(&root->root_list);
> +	spin_unlock(&sysctl_lock);
> +}
> +EXPORT_SYMBOL_GPL(unregister_sysctl_root);
>  
>  /*
>   * sysctl_perm does NOT grant the superuser all rights automatically, because
> @@ -1925,6 +1934,7 @@ struct ctl_table_header *__register_sysctl_paths(
>  
>  	return header;
>  }
> +EXPORT_SYMBOL_GPL(__register_sysctl_paths);
>  
>  /**
>   * register_sysctl_table_path - register a sysctl table hierarchy
> @@ -2007,6 +2017,7 @@ void setup_sysctl_set(struct ctl_table_set *p,
>  	p->parent = parent ? parent : &sysctl_table_root.default_set;
>  	p->is_seen = is_seen;
>  }
> +EXPORT_SYMBOL_GPL(setup_sysctl_set);
>  
>  #else /* !CONFIG_SYSCTL */
>  struct ctl_table_header *register_sysctl_table(struct ctl_table * table)
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
