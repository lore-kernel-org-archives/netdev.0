From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v0 3/5] cgroup: Protect access to task_cls_classid() when
 built as module
Date: Fri, 17 Aug 2012 15:35:27 +0800
Message-ID: <502DF43F.9010209@huawei.com>
References: <1345126336-20755-1-git-send-email-wagi@monom.org> <1345126336-20755-4-git-send-email-wagi@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1345126336-20755-4-git-send-email-wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> +#if IS_ENABLED(CONFIG_NET_CLS_CGROUP)
> +extern struct static_key cgroup_cls_enabled;
> +#define clscg_enabled static_key_false(&cgroup_cls_enabled)
> +#endif
> +

If it's built-in, clscg_enabled is always true (after we call cgroup_subsys_init at
boot), so we don't need jump label at all.

>  extern void sock_update_classid(struct sock *sk);
>  
>  #if IS_BUILTIN(CONFIG_NET_CLS_CGROUP)
> @@ -52,7 +58,7 @@ static inline u32 task_cls_classid(struct task_struct *p)
>  	int id;
>  	u32 classid = 0;
>  
> -	if (in_interrupt())
> +	if (!clscg_enabled || in_interrupt())
>  		return 0;
>  
>  	rcu_read_lock();
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 8f67ced..8d3a400 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -327,6 +327,11 @@ int __sk_backlog_rcv(struct sock *sk, struct sk_buff *skb)
>  EXPORT_SYMBOL(__sk_backlog_rcv);
>  
>  #if defined(CONFIG_CGROUPS)
> +#if IS_ENABLED(CONFIG_NET_CLS_CGROUP)
> +struct static_key cgroup_cls_enabled = STATIC_KEY_INIT_FALSE;
> +EXPORT_SYMBOL_GPL(cgroup_cls_enabled);
> +#endif
> +
>  #if !defined(CONFIG_NET_CLS_CGROUP)
>  int net_cls_subsys_id = -1;
>  EXPORT_SYMBOL_GPL(net_cls_subsys_id);
> diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
> index 7743ea8..f40086b 100644
> --- a/net/sched/cls_cgroup.c
> +++ b/net/sched/cls_cgroup.c
> @@ -44,12 +44,17 @@ static struct cgroup_subsys_state *cgrp_create(struct cgroup *cgrp)
>  
>  	if (cgrp->parent)
>  		cs->classid = cgrp_cls_state(cgrp->parent)->classid;
> +	else if (!clscg_enabled)
> +                static_key_slow_inc(&cgroup_cls_enabled);

It's not necessary to check if !clsg_enabled.

>  
>  	return &cs->css;
>  }
>  
>  static void cgrp_destroy(struct cgroup *cgrp)
>  {
> +	if (!cgrp->parent && clscg_enabled)
> +                static_key_slow_dec(&cgroup_cls_enabled);
> +

ditto.

>  	kfree(cgrp_cls_state(cgrp));
>  }
>  
> 
