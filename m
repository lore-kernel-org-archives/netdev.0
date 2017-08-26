From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next 1/8] bpf: Add support for recursively running
 cgroup sock filters
Date: Sat, 26 Aug 2017 04:00:15 +0200
Message-ID: <59A0D62F.3030806@iogearbox.net>
References: <1503687941-626-1-git-send-email-dsahern@gmail.com> <1503687941-626-2-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org,
        ast@kernel.org, tj@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39925 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751407AbdHZCAY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 22:00:24 -0400
In-Reply-To: <1503687941-626-2-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/25/2017 09:05 PM, David Ahern wrote:
> Add support for recursively applying sock filters attached to a cgroup.
> For now, start with the inner cgroup attached to the socket and work back
> to the root or first cgroup without the recursive flag set. Once the
> recursive flag is set for a cgroup all descendant group's must have the
> flag as well.
>
> Signed-off-by: David Ahern <dsahern@gmail.com>
[...]
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index f71f5e07d82d..595e31b30f23 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -151,6 +151,15 @@ enum bpf_attach_type {
>    */
>   #define BPF_F_ALLOW_OVERRIDE	(1U << 0)
>
> +/* If BPF_F_RECURSIVE flag is used in BPF_PROG_ATTACH command
> + * cgroups are walked recursively back to the root cgroup or the
> + * first cgroup without the flag set running any program attached.
> + * Once the flag is set, it MUST be set for all descendant cgroups.
> + */
> +#define BPF_F_RECURSIVE		(1U << 1)
> +
> +#define BPF_F_ALL_ATTACH_FLAGS  (BPF_F_ALLOW_OVERRIDE | BPF_F_RECURSIVE)
> +
>   /* If BPF_F_STRICT_ALIGNMENT is used in BPF_PROG_LOAD command, the
>    * verifier will perform strict alignment checking as if the kernel
>    * has been built with CONFIG_EFFICIENT_UNALIGNED_ACCESS not set,
> diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
> index 546113430049..eb1f436c18fb 100644
> --- a/kernel/bpf/cgroup.c
> +++ b/kernel/bpf/cgroup.c
> @@ -47,10 +47,16 @@ void cgroup_bpf_inherit(struct cgroup *cgrp, struct cgroup *parent)
>   	unsigned int type;
>
>   	for (type = 0; type < ARRAY_SIZE(cgrp->bpf.effective); type++) {
> -		struct bpf_prog *e;
> +		struct bpf_prog *e = NULL;
> +
> +		/* do not need to set effective program if cgroups are
> +		 * walked recursively
> +		 */
> +		cgrp->bpf.is_recursive[type] = parent->bpf.is_recursive[type];
> +		if (!cgrp->bpf.is_recursive[type])
> +			e = rcu_dereference_protected(parent->bpf.effective[type],
> +						      lockdep_is_held(&cgroup_mutex));

[...]

> -		e = rcu_dereference_protected(parent->bpf.effective[type],
> -					      lockdep_is_held(&cgroup_mutex));
>   		rcu_assign_pointer(cgrp->bpf.effective[type], e);
>   		cgrp->bpf.disallow_override[type] = parent->bpf.disallow_override[type];
>   	}
[...]
> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> index d5774a6851f1..a1ab5dbaae89 100644
> --- a/kernel/bpf/syscall.c
> +++ b/kernel/bpf/syscall.c
> @@ -1187,7 +1187,7 @@ static int bpf_prog_attach(const union bpf_attr *attr)
>   	if (CHECK_ATTR(BPF_PROG_ATTACH))
>   		return -EINVAL;
>
> -	if (attr->attach_flags & ~BPF_F_ALLOW_OVERRIDE)
> +	if (attr->attach_flags & ~BPF_F_ALL_ATTACH_FLAGS)
>   		return -EINVAL;
>
>   	switch (attr->attach_type) {
> @@ -1222,7 +1222,7 @@ static int bpf_prog_attach(const union bpf_attr *attr)
>   	}
>
>   	ret = cgroup_bpf_update(cgrp, prog, attr->attach_type,
> -				attr->attach_flags & BPF_F_ALLOW_OVERRIDE);
> +				attr->attach_flags);
>   	if (ret)
>   		bpf_prog_put(prog);
>   	cgroup_put(cgrp);
> @@ -1252,7 +1252,7 @@ static int bpf_prog_detach(const union bpf_attr *attr)
>   		if (IS_ERR(cgrp))
>   			return PTR_ERR(cgrp);
>
> -		ret = cgroup_bpf_update(cgrp, NULL, attr->attach_type, false);
> +		ret = cgroup_bpf_update(cgrp, NULL, attr->attach_type, 0);
>   		cgroup_put(cgrp);
>   		break;

Can you elaborate on the semantical changes for the programs
setting the new flag which are not using below cgroup_bpf_run_filter_sk()
helper to walk back to root?

> diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
> index df2e0f14a95d..27a4f14435a3 100644
> --- a/kernel/cgroup/cgroup.c
> +++ b/kernel/cgroup/cgroup.c
> @@ -5176,14 +5176,35 @@ void cgroup_sk_free(struct sock_cgroup_data *skcd)
>
>   #ifdef CONFIG_CGROUP_BPF
>   int cgroup_bpf_update(struct cgroup *cgrp, struct bpf_prog *prog,
> -		      enum bpf_attach_type type, bool overridable)
> +		      enum bpf_attach_type type, u32 flags)
>   {
>   	struct cgroup *parent = cgroup_parent(cgrp);
>   	int ret;
>
>   	mutex_lock(&cgroup_mutex);
> -	ret = __cgroup_bpf_update(cgrp, parent, prog, type, overridable);
> +	ret = __cgroup_bpf_update(cgrp, parent, prog, type, flags);
>   	mutex_unlock(&cgroup_mutex);
>   	return ret;
>   }
> +
> +int cgroup_bpf_run_filter_sk(struct sock *sk,
> +			     enum bpf_attach_type type)
> +{
> +	struct cgroup *cgrp = sock_cgroup_ptr(&sk->sk_cgrp_data);
> +	int ret = 0;
> +
> +	while (cgrp) {
> +		ret = __cgroup_bpf_run_filter_sk(cgrp, sk, type);
> +		if (ret)
> +			break;
> +
> +		if (!cgrp->bpf.is_recursive[type])
> +			break;
> +
> +		cgrp = cgroup_parent(cgrp);
> +	}
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL(cgroup_bpf_run_filter_sk);
>   #endif /* CONFIG_CGROUP_BPF */
>
