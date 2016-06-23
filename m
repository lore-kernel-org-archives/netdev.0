From: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Subject: Re: [PATCH net-next v2 3/4] cgroup: bpf: Add bpf_skb_in_cgroup_proto
Date: Thu, 23 Jun 2016 11:53:50 +0200
Message-ID: <576BB1AE.5080605@iogearbox.net>
References: <1466630252-3822277-1-git-send-email-kafai@fb.com> <1466630252-3822277-4-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	kernel-team-b10kYP2dOMg@public.gmane.org
To: Martin KaFai Lau <kafai-b10kYP2dOMg@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1466630252-3822277-4-git-send-email-kafai-b10kYP2dOMg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 06/22/2016 11:17 PM, Martin KaFai Lau wrote:
> Adds a bpf helper, bpf_skb_in_cgroup, to decide if a skb->sk
> belongs to a descendant of a cgroup2.  It is similar to the
> feature added in netfilter:
> commit c38c4597e4bf ("netfilter: implement xt_cgroup cgroup2 path match")
>
> The user is expected to populate a BPF_MAP_TYPE_CGROUP_ARRAY
> which will be used by the bpf_skb_in_cgroup.
>
> Modifications to the bpf verifier is to ensure BPF_MAP_TYPE_CGROUP_ARRAY
> and bpf_skb_in_cgroup() are always used together.
>
> Signed-off-by: Martin KaFai Lau <kafai-b10kYP2dOMg@public.gmane.org>
> Cc: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>
> Cc: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
> Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Acked-by: Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> ---
>   include/uapi/linux/bpf.h | 12 ++++++++++++
>   kernel/bpf/verifier.c    |  8 ++++++++
>   net/core/filter.c        | 40 ++++++++++++++++++++++++++++++++++++++++
>   3 files changed, 60 insertions(+)
>
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index ef4e386..bad309f 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -314,6 +314,18 @@ enum bpf_func_id {
>   	 */
>   	BPF_FUNC_skb_get_tunnel_opt,
>   	BPF_FUNC_skb_set_tunnel_opt,
> +
> +	/**
> +	 * bpf_skb_in_cgroup(skb, map, index) - Check cgroup2 membership of skb
> +	 * @skb: pointer to skb
> +	 * @map: pointer to bpf_map in BPF_MAP_TYPE_CGROUP_ARRAY type
> +	 * @index: index of the cgroup in the bpf_map
> +	 * Return:
> +	 *   == 0 skb failed the cgroup2 descendant test
> +	 *   == 1 skb succeeded the cgroup2 descendant test
> +	 *    < 0 error
> +	 */
> +	BPF_FUNC_skb_in_cgroup,
>   	__BPF_FUNC_MAX_ID,
>   };
>
> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> index 668e079..68753e0 100644
> --- a/kernel/bpf/verifier.c
> +++ b/kernel/bpf/verifier.c
> @@ -1062,6 +1062,10 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
>   		if (func_id != BPF_FUNC_get_stackid)
>   			goto error;
>   		break;
> +	case BPF_MAP_TYPE_CGROUP_ARRAY:
> +		if (func_id != BPF_FUNC_skb_in_cgroup)
> +			goto error;
> +		break;

I think the BPF_MAP_TYPE_CGROUP_ARRAY case should have been fist here in
patch 2/4, but with unconditional goto error. And this one only adds the
'func_id != BPF_FUNC_skb_in_cgroup' test.

>   	default:
>   		break;
>   	}
> @@ -1081,6 +1085,10 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
>   		if (map->map_type != BPF_MAP_TYPE_STACK_TRACE)
>   			goto error;
>   		break;
> +	case BPF_FUNC_skb_in_cgroup:
> +		if (map->map_type != BPF_MAP_TYPE_CGROUP_ARRAY)
> +			goto error;
> +		break;
>   	default:
>   		break;
>   	}
> diff --git a/net/core/filter.c b/net/core/filter.c
> index df6860c..a16f7d2 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -2024,6 +2024,42 @@ bpf_get_skb_set_tunnel_proto(enum bpf_func_id which)
>   	}
>   }
>
> +#ifdef CONFIG_CGROUPS
> +static u64 bpf_skb_in_cgroup(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
> +{
> +	struct sk_buff *skb = (struct sk_buff *)(long)r1;
> +	struct bpf_map *map = (struct bpf_map *)(long)r2;
> +	struct bpf_array *array = container_of(map, struct bpf_array, map);
> +	struct cgroup *cgrp;
> +	struct sock *sk;
> +	u32 i = (u32)r3;
> +
> +	WARN_ON_ONCE(!rcu_read_lock_held());

I think the WARN_ON_ONCE() test can be removed all-together. There are many
other functions without it. We really rely on RCU read-lock being held for
BPF programs (otherwise it would be horribly broken). F.e. it's kinda silly
that for some map update/lookups we even have this WARN_ON_ONCE() test twice
we go through in the fast-path (once from the generic eBPF helper function
and then once again from the actual implementation since it could also be
called from syscall). The actual invocation points are not that many and we
can make sure that related call sites hold RCU read lock.

Rest looks good to me, thanks.

> +	sk = skb->sk;
> +	if (!sk || !sk_fullsock(sk))
> +		return -ENOENT;
> +
> +	if (unlikely(i >= array->map.max_entries))
> +		return -E2BIG;
> +
> +	cgrp = READ_ONCE(array->ptrs[i]);
> +	if (unlikely(!cgrp))
> +		return -ENOENT;
> +
> +	return cgroup_is_descendant(sock_cgroup_ptr(&sk->sk_cgrp_data), cgrp);
> +}
> +
> +static const struct bpf_func_proto bpf_skb_in_cgroup_proto = {
> +	.func		= bpf_skb_in_cgroup,
> +	.gpl_only	= false,
> +	.ret_type	= RET_INTEGER,
> +	.arg1_type	= ARG_PTR_TO_CTX,
> +	.arg2_type	= ARG_CONST_MAP_PTR,
> +	.arg3_type	= ARG_ANYTHING,
> +};
> +#endif
> +
>   static const struct bpf_func_proto *
>   sk_filter_func_proto(enum bpf_func_id func_id)
>   {
> @@ -2086,6 +2122,10 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
>   		return &bpf_get_route_realm_proto;
>   	case BPF_FUNC_perf_event_output:
>   		return bpf_get_event_output_proto();
> +#ifdef CONFIG_CGROUPS
> +	case BPF_FUNC_skb_in_cgroup:
> +		return &bpf_skb_in_cgroup_proto;
> +#endif
>   	default:
>   		return sk_filter_func_proto(func_id);
>   	}
>
