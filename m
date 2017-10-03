From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/8] bpf: multi program support for cgroup+bpf
Date: Mon, 2 Oct 2017 20:54:57 -0700
Message-ID: <71bda584-d828-7472-7655-85a454dbe297@cumulusnetworks.com>
References: <20171002234857.3707580-1-ast@fb.com>
 <20171002234857.3707580-2-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, Tejun Heo <tj@kernel.org>,
        netdev@vger.kernel.org, kernel-team@fb.com
To: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:51935 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751784AbdJCDzI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 23:55:08 -0400
Received: by mail-pg0-f42.google.com with SMTP id u144so1374414pgb.8
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 20:55:07 -0700 (PDT)
In-Reply-To: <20171002234857.3707580-2-ast@fb.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/2/17 4:48 PM, Alexei Starovoitov wrote:
> diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
> index 546113430049..70f679a94804 100644
> --- a/kernel/bpf/cgroup.c
> +++ b/kernel/bpf/cgroup.c
> @@ -27,129 +27,361 @@ void cgroup_bpf_put(struct cgroup *cgrp)
>  {
>  	unsigned int type;
>  
> -	for (type = 0; type < ARRAY_SIZE(cgrp->bpf.prog); type++) {
> -		struct bpf_prog *prog = cgrp->bpf.prog[type];
> -
> -		if (prog) {
> -			bpf_prog_put(prog);
> +	for (type = 0; type < ARRAY_SIZE(cgrp->bpf.progs); type++) {
> +		struct list_head *progs = &cgrp->bpf.progs[type];
> +		struct bpf_prog_list *pl, *tmp;
> +
> +		list_for_each_entry_safe(pl, tmp, progs, node) {
> +			list_del(&pl->node);
> +			bpf_prog_put(pl->prog);
> +			kfree(pl);
>  			static_branch_dec(&cgroup_bpf_enabled_key);
>  		}
> +		bpf_prog_array_free(cgrp->bpf.effective[type]);
> +	}
> +}
> +

...

>  
> -	if (prog)
> -		static_branch_inc(&cgroup_bpf_enabled_key);
> +	/* all allocations were successful. Activate all prog arrays */
> +	css_for_each_descendant_pre(css, &cgrp->self) {
> +		struct cgroup *desc = container_of(css, struct cgroup, self);
>  
> +		activate_effective_progs(desc, type, desc->bpf.inactive);
> +		desc->bpf.inactive = NULL;
> +	}
> +
> +	static_branch_inc(&cgroup_bpf_enabled_key);
>  	if (old_prog) {
>  		bpf_prog_put(old_prog);
>  		static_branch_dec(&cgroup_bpf_enabled_key);
>  	}
>  	return 0;

It's not clear to me that the static_branch_inc and static_branch_dec's
are equal since the dec is in the loop over each program in the list,
but the inc is not in a loop.
