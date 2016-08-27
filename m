From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v3 2/6] cgroup: add support for eBPF programs
Date: Fri, 26 Aug 2016 17:03:27 -0700
Message-ID: <20160827000325.GA29480@ast-mbp.thefacebook.com>
References: <1472241532-11682-1-git-send-email-daniel@zonque.org>
 <1472241532-11682-3-git-send-email-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: htejun@fb.com, daniel@iogearbox.net, ast@fb.com,
        davem@davemloft.net, kafai@fb.com, fw@strlen.de,
        pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org,
        sargun@sargun.me
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:36720 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752060AbcH0ADc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 20:03:32 -0400
Received: by mail-pa0-f67.google.com with SMTP id ez1so5399110pab.3
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 17:03:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1472241532-11682-3-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 26, 2016 at 09:58:48PM +0200, Daniel Mack wrote:
> This patch adds two sets of eBPF program pointers to struct cgroup.
> One for such that are directly pinned to a cgroup, and one for such
> that are effective for it.
> 
> To illustrate the logic behind that, assume the following example
> cgroup hierarchy.
> 
>   A - B - C
>         \ D - E
> 
> If only B has a program attached, it will be effective for B, C, D
> and E. If D then attaches a program itself, that will be effective for
> both D and E, and the program in B will only affect B and C. Only one
> program of a given type is effective for a cgroup.
> 
> Attaching and detaching programs will be done through the bpf(2)
> syscall. For now, ingress and egress inet socket filtering are the
> only supported use-cases.
> 
> Signed-off-by: Daniel Mack <daniel@zonque.org>
...
> +	css_for_each_descendant_pre(pos, &cgrp->self) {
> +		struct cgroup *desc = container_of(pos, struct cgroup, self);
> +
> +		/* skip the subtree if the descendant has its own program */
> +		if (desc->bpf.prog[type] && desc != cgrp)

is desc != cgrp really needed?
I thought css_for_each_descendant_pre() shouldn't walk itself
or I'm missing how it works.

> +			pos = css_rightmost_descendant(pos);
> +		else
> +			rcu_assign_pointer(desc->bpf.effective[type],
> +					   effective);
> +	}
> +}
> +
