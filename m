From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net-next 1/8] bpf: Add support for recursively running
 cgroup sock filters
Date: Fri, 25 Aug 2017 19:49:58 -0700
Message-ID: <20170826024957.m5ita6usxihywmdd@ast-mbp>
References: <1503687941-626-1-git-send-email-dsahern@gmail.com>
 <1503687941-626-2-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
        tj@kernel.org, davem@davemloft.net
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35860 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751508AbdHZCuC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 22:50:02 -0400
Received: by mail-pf0-f195.google.com with SMTP id a2so174838pfj.3
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 19:50:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1503687941-626-2-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 25, 2017 at 12:05:34PM -0700, David Ahern wrote:
> Add support for recursively applying sock filters attached to a cgroup.
> For now, start with the inner cgroup attached to the socket and work back
> to the root or first cgroup without the recursive flag set. Once the
> recursive flag is set for a cgroup all descendant group's must have the
> flag as well.
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>
> ---
>  include/linux/bpf-cgroup.h | 10 ++++++----
>  include/uapi/linux/bpf.h   |  9 +++++++++
>  kernel/bpf/cgroup.c        | 29 ++++++++++++++++++++++-------
>  kernel/bpf/syscall.c       |  6 +++---
>  kernel/cgroup/cgroup.c     | 25 +++++++++++++++++++++++--
>  5 files changed, 63 insertions(+), 16 deletions(-)
> 
> diff --git a/include/linux/bpf-cgroup.h b/include/linux/bpf-cgroup.h
> index d41d40ac3efd..2d02187f242f 100644
> --- a/include/linux/bpf-cgroup.h
> +++ b/include/linux/bpf-cgroup.h
> @@ -23,6 +23,7 @@ struct cgroup_bpf {
>  	struct bpf_prog *prog[MAX_BPF_ATTACH_TYPE];
>  	struct bpf_prog __rcu *effective[MAX_BPF_ATTACH_TYPE];
>  	bool disallow_override[MAX_BPF_ATTACH_TYPE];
> +	bool is_recursive[MAX_BPF_ATTACH_TYPE];
>  };
>  
>  void cgroup_bpf_put(struct cgroup *cgrp);
> @@ -30,18 +31,19 @@ void cgroup_bpf_inherit(struct cgroup *cgrp, struct cgroup *parent);
>  
>  int __cgroup_bpf_update(struct cgroup *cgrp, struct cgroup *parent,
>  			struct bpf_prog *prog, enum bpf_attach_type type,
> -			bool overridable);
> +			u32 flags);
>  
>  /* Wrapper for __cgroup_bpf_update() protected by cgroup_mutex */
>  int cgroup_bpf_update(struct cgroup *cgrp, struct bpf_prog *prog,
> -		      enum bpf_attach_type type, bool overridable);
> +		      enum bpf_attach_type type, u32 flags);
>  
>  int __cgroup_bpf_run_filter_skb(struct sock *sk,
>  				struct sk_buff *skb,
>  				enum bpf_attach_type type);
>  
> -int __cgroup_bpf_run_filter_sk(struct sock *sk,
> +int __cgroup_bpf_run_filter_sk(struct cgroup *cgrp, struct sock *sk,
>  			       enum bpf_attach_type type);
> +int cgroup_bpf_run_filter_sk(struct sock *sk, enum bpf_attach_type type);
>  
>  int __cgroup_bpf_run_filter_sock_ops(struct sock *sk,
>  				     struct bpf_sock_ops_kern *sock_ops,
> @@ -74,7 +76,7 @@ int __cgroup_bpf_run_filter_sock_ops(struct sock *sk,
>  ({									       \
>  	int __ret = 0;							       \
>  	if (cgroup_bpf_enabled && sk) {					       \
> -		__ret = __cgroup_bpf_run_filter_sk(sk,			       \
> +		__ret = cgroup_bpf_run_filter_sk(sk,			       \
>  						 BPF_CGROUP_INET_SOCK_CREATE); \
>  	}								       \
>  	__ret;								       \
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index f71f5e07d82d..595e31b30f23 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -151,6 +151,15 @@ enum bpf_attach_type {
>   */
>  #define BPF_F_ALLOW_OVERRIDE	(1U << 0)
>  
> +/* If BPF_F_RECURSIVE flag is used in BPF_PROG_ATTACH command
> + * cgroups are walked recursively back to the root cgroup or the
> + * first cgroup without the flag set running any program attached.
> + * Once the flag is set, it MUST be set for all descendant cgroups.
> + */
> +#define BPF_F_RECURSIVE		(1U << 1)

above logic makes sense, but ...

> +	if (prog && curr_recursive && !new_recursive)
> +		/* if a parent has recursive prog attached, only
> +		 * allow recursive programs in descendent cgroup
> +		 */
> +		return -EINVAL;
> +
>  	old_prog = cgrp->bpf.prog[type];

... I'm struggling to completely understand how it interacts
with BPF_F_ALLOW_OVERRIDE.
By default we shouldn't allow overriding, so if default prog attached
to a root, what happens if we try to attach F_RECURSIVE to a descendent?
If I'm reading the code correctly it will not succeed, which is good.
Could you add such scenario as test to test_cgrp2_attach2.c ?

Now say we attach overridable and !recursive to a root, another
recursive prog will not be attached to a descedent, which is correct.

But if we attach !overridable + recursive to a root we cannot attach
anything to a descendent right? Then why allow such combination at all?
So only overridable + recursive combination makes sense, right?

I think all these combinations must be documented and tests must be
added. Sooner or later people will build security sensitive environment
with it and we have to meticulous now.

Do you think it would make sense to split this patch out and
push patches 2 and 3 with few tests in parallel, while we're review
this change?

Tejun needs to take a deep look into this patch as well.
