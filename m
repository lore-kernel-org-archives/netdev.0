From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH v6 06/10] tcp buffer limitation: per-cgroup limit
Date: Mon, 28 Nov 2011 12:24:52 +0900
Message-ID: <20111128122452.734d93c0.kamezawa.hiroyu@jp.fujitsu.com>
References: <1322242696-27682-1-git-send-email-glommer@parallels.com>
	<1322242696-27682-7-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org,
	gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org,
	kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org, avagin-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1322242696-27682-7-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


some comments.

On Fri, 25 Nov 2011 15:38:12 -0200
Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> wrote:

> This patch uses the "tcp.limit_in_bytes" field of the kmem_cgroup to
> effectively control the amount of kernel memory pinned by a cgroup.
> 
> This value is ignored in the root cgroup, and in all others,
> caps the value specified by the admin in the net namespaces'
> view of tcp_sysctl_mem.
> 
> If namespaces are being used, the admin is allowed to set a
> value bigger than cgroup's maximum, the same way it is allowed
> to set pretty much unlimited values in a real box.
> 
> Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> CC: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> CC: Hiroyouki Kamezawa <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> CC: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

<snip>

>  EXPORT_SYMBOL(tcp_destroy_cgroup);
> +
> +int tcp_update_limit(struct mem_cgroup *memcg, u64 val)
> +{
> +	struct net *net = current->nsproxy->net_ns;
> +	struct tcp_memcontrol *tcp;
> +	struct cg_proto *cg_proto;
> +	int i;
> +	int ret;
> +
> +	cg_proto = tcp_prot.proto_cgroup(memcg);
> +	if (!cg_proto)
> +		return -EINVAL;
> +
> +	tcp = tcp_from_cgproto(cg_proto);
> +
> +	ret = res_counter_set_limit(&tcp->tcp_memory_allocated, val);

Here, you changed the limit.

> +	if (ret)
> +		return ret;
> +
> +	val >>= PAGE_SHIFT;

Here, you modifies 'val'

> +
> +	for (i = 0; i < 3; i++)
> +		tcp->tcp_prot_mem[i] = min_t(long, val,
> +					     net->ipv4.sysctl_tcp_mem[i]);
> +
> +	if (val == RESOURCE_MAX)
> +		jump_label_dec(&memcg_socket_limit_enabled);

the 'val' never be RESOUECE_MAX.


> +	else {
> +		u64 old_lim;
> +		old_lim = res_counter_read_u64(&tcp->tcp_memory_allocated,
> +					       RES_LIMIT);

old_lim is not already overwritten ?

> +		if (old_lim == RESOURCE_MAX)
> +			jump_label_inc(&memcg_socket_limit_enabled);
> +	}
> +	return 0;
> +}
> +

Thanks,
-Kame

--
To unsubscribe from this list: send the line "unsubscribe cgroups" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
