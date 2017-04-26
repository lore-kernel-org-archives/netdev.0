From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 4/6] bpf: track if the bpf program was loaded
 with SYS_ADMIN capabilities
Date: Wed, 26 Apr 2017 23:04:26 +0200
Message-ID: <59010B5A.6060509@iogearbox.net>
References: <20170426182419.14574-1-hannes@stressinduktion.org> <20170426182419.14574-5-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@iogearbox.com, jbenc@redhat.com,
        aconole@bytheb.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41378 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967611AbdDZVE2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 17:04:28 -0400
In-Reply-To: <20170426182419.14574-5-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/26/2017 08:24 PM, Hannes Frederic Sowa wrote:
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Ahh, looks this got swapped with 3/6.

> ---
>   include/linux/filter.h | 6 ++++--
>   kernel/bpf/core.c      | 4 +++-
>   kernel/bpf/syscall.c   | 7 ++++---
>   kernel/bpf/verifier.c  | 4 ++--
>   net/core/filter.c      | 6 +++---
>   5 files changed, 16 insertions(+), 11 deletions(-)
>
> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index 63624c619e371b..635311f57bf24f 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -413,7 +413,8 @@ struct bpf_prog {
>   				locked:1,	/* Program image locked? */
>   				gpl_compatible:1, /* Is filter GPL compatible? */
>   				cb_access:1,	/* Is control block accessed? */
> -				dst_needed:1;	/* Do we need dst entry? */
> +				dst_needed:1,	/* Do we need dst entry? */
> +				priv_cap_sys_admin:1; /* Where we loaded as sys_admin? */
>   	kmemcheck_bitfield_end(meta);
>   	enum bpf_prog_type	type;		/* Type of BPF program */
[...]
> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> index 6f8b6ed690be93..24c9dac374770f 100644
> --- a/kernel/bpf/verifier.c
> +++ b/kernel/bpf/verifier.c
> @@ -3488,7 +3488,7 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
>   	if (ret < 0)
>   		goto skip_full_check;
>
> -	env->allow_ptr_leaks = capable(CAP_SYS_ADMIN);
> +	env->allow_ptr_leaks = env->prog->priv_cap_sys_admin;
>
>   	ret = do_check(env);
>
> @@ -3589,7 +3589,7 @@ int bpf_analyzer(struct bpf_prog *prog, const struct bpf_ext_analyzer_ops *ops,
>   	if (ret < 0)
>   		goto skip_full_check;
>
> -	env->allow_ptr_leaks = capable(CAP_SYS_ADMIN);
> +	env->allow_ptr_leaks = prog->priv_cap_sys_admin;
>
>   	ret = do_check(env);
>
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 9a37860a80fc78..dc020d40bb770a 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -1100,7 +1100,7 @@ int bpf_prog_create(struct bpf_prog **pfp, struct sock_fprog_kern *fprog)
>   	if (!bpf_check_basics_ok(fprog->filter, fprog->len))
>   		return -EINVAL;
>
> -	fp = bpf_prog_alloc(bpf_prog_size(fprog->len), 0);
> +	fp = bpf_prog_alloc(bpf_prog_size(fprog->len), 0, false);
>   	if (!fp)
>   		return -ENOMEM;
>

Did you check that transferring allow_ptr_leaks doesn't have a side
effect on the nfp JIT? I believe it can also do cbpf migrations to
a certain extend.
