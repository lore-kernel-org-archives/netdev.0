From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH v8 3/9] socket: initial cgroup code.
Date: Fri, 9 Dec 2011 11:05:50 +0900
Message-ID: <20111209110550.fc740b81.kamezawa.hiroyu@jp.fujitsu.com>
References: <1323120903-2831-1-git-send-email-glommer@parallels.com>
	<1323120903-2831-4-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org,
	avagin-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org,
	KAMEZAWA Hiroyuki <kamezawa.hiroyu-ZTyZJ+IMMTwvtab9mdV7tw@public.gmane.org>
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1323120903-2831-4-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon,  5 Dec 2011 19:34:57 -0200
Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> wrote:

> The goal of this work is to move the memory pressure tcp
> controls to a cgroup, instead of just relying on global
> conditions.
> 
> To avoid excessive overhead in the network fast paths,
> the code that accounts allocated memory to a cgroup is
> hidden inside a static_branch(). This branch is patched out
> until the first non-root cgroup is created. So when nobody
> is using cgroups, even if it is mounted, no significant performance
> penalty should be seen.
> 
> This patch handles the generic part of the code, and has nothing
> tcp-specific.
> 
> Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> CC: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
> CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu-ZTyZJ+IMMTwvtab9mdV7tw@public.gmane.org>
> CC: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> CC: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> CC: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

I already replied Reviewed-by: but...


> +/* Writing them here to avoid exposing memcg's inner layout */
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> +#ifdef CONFIG_INET
> +#include <net/sock.h>
> +
> +static bool mem_cgroup_is_root(struct mem_cgroup *memcg);
> +void sock_update_memcg(struct sock *sk)
> +{
> +	/* A socket spends its whole life in the same cgroup */
> +	if (sk->sk_cgrp) {
> +		WARN_ON(1);
> +		return;
> +	}
> +	if (static_branch(&memcg_socket_limit_enabled)) {
> +		struct mem_cgroup *memcg;
> +
> +		BUG_ON(!sk->sk_prot->proto_cgroup);
> +
> +		rcu_read_lock();
> +		memcg = mem_cgroup_from_task(current);
> +		if (!mem_cgroup_is_root(memcg)) {
> +			mem_cgroup_get(memcg);
> +			sk->sk_cgrp = sk->sk_prot->proto_cgroup(memcg);
> +		}
> +		rcu_read_unlock();
> +	}
> +}

Here, you do mem_cgroup_get() if !mem_cgroup_is_root().


> +EXPORT_SYMBOL(sock_update_memcg);
> +
> +void sock_release_memcg(struct sock *sk)
> +{
> +	if (static_branch(&memcg_socket_limit_enabled) && sk->sk_cgrp) {
> +		struct mem_cgroup *memcg;
> +		WARN_ON(!sk->sk_cgrp->memcg);
> +		memcg = sk->sk_cgrp->memcg;
> +		mem_cgroup_put(memcg);
> +	}
> +}
>

You don't check !mem_cgroup_is_root(). Hm, root memcg will not be freed
by this ?

Thanks,
-Kame


--
To unsubscribe from this list: send the line "unsubscribe cgroups" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
