From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 3/5] bpf: Add strict alignment flag for BPF_PROG_LOAD.
Date: Thu, 11 May 2017 14:53:58 +0200
Message-ID: <59145EE6.3030409@iogearbox.net>
References: <20170510.150951.1359250469075249855.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47280 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932708AbdEKMyD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 08:54:03 -0400
In-Reply-To: <20170510.150951.1359250469075249855.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/10/2017 09:09 PM, David Miller wrote:
>
> Add a new field, "prog_flags", and an initial flag value
> BPF_F_STRCIT_ALIGNMENT.
>
> When set, the verifier will enforce strict pointer alignment
> regardless of the setting of CONFIG_EFFICIENT_UNALIGNED_ACCESS.
>
> The verifier, in this mode, will also use a fixed value of "2" in
> place of NET_IP_ALIGN.
>
> This facilitates test cases that will exercise and validate this part
> of the verifier even when run on architectures where alignment doesn't
> matter.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>

[...]
> @@ -833,10 +838,12 @@ static int check_val_ptr_alignment(const struct bpf_reg_state *reg,
>   	return 0;
>   }
>
> +static bool strict_alignment;
> +
>   static int check_ptr_alignment(const struct bpf_reg_state *reg,
>   			       int off, int size)
>   {
> -	bool strict = false;
> +	bool strict = strict_alignment;
>
>   	if (!IS_ENABLED(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS))
>   		strict = true;
> @@ -3574,6 +3581,10 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
>   	} else {
>   		log_level = 0;
>   	}
> +	if (attr->prog_flags & BPF_F_STRICT_ALIGNMENT)
> +		strict_alignment = true;
> +	else
> +		strict_alignment = false;

Just minor nit: Can we move this into struct bpf_verifier_env
here instead of global var? The only change it would need is
in check_ptr_alignment() to pass the env from check_mem_access().
check_ptr_alignment() can then infer this from env.

>   	ret = replace_map_fd_with_map_ptr(env);
>   	if (ret < 0)
> @@ -3679,6 +3690,7 @@ int bpf_analyzer(struct bpf_prog *prog, const struct bpf_ext_analyzer_ops *ops,
>   	mutex_lock(&bpf_verifier_lock);
>
>   	log_level = 0;
> +	strict_alignment = false;
>
>   	env->explored_states = kcalloc(env->prog->len,
>   				       sizeof(struct bpf_verifier_state_list *),

Rest looks good:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
