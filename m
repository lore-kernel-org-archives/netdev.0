From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v3 3/6] bpf: add BPF_PROG_ATTACH and BPF_PROG_DETACH
 commands
Date: Fri, 26 Aug 2016 17:08:21 -0700
Message-ID: <20160827000819.GB29480@ast-mbp.thefacebook.com>
References: <1472241532-11682-1-git-send-email-daniel@zonque.org>
 <1472241532-11682-4-git-send-email-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: htejun@fb.com, daniel@iogearbox.net, ast@fb.com,
        davem@davemloft.net, kafai@fb.com, fw@strlen.de,
        pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org,
        sargun@sargun.me
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33704 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752161AbcH0AI1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 20:08:27 -0400
Received: by mail-pa0-f68.google.com with SMTP id vy10so5395681pac.0
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 17:08:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1472241532-11682-4-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 26, 2016 at 09:58:49PM +0200, Daniel Mack wrote:
> Extend the bpf(2) syscall by two new commands, BPF_PROG_ATTACH and
> BPF_PROG_DETACH which allow attaching and detaching eBPF programs
> to a target.
> 
> On the API level, the target could be anything that has an fd in
> userspace, hence the name of the field in union bpf_attr is called
> 'target_fd'.
> 
> When called with BPF_ATTACH_TYPE_CGROUP_INET_{E,IN}GRESS, the target is
> expected to be a valid file descriptor of a cgroup v2 directory which
> has the bpf controller enabled. These are the only use-cases
> implemented by this patch at this point, but more can be added.
> 
> If a program of the given type already exists in the given cgroup,
> the program is swapped automically, so userspace does not have to drop
> an existing program first before installing a new one, which would
> otherwise leave a gap in which no program is attached.
> 
> For more information on the propagation logic to subcgroups, please
> refer to the bpf cgroup controller implementation.
> 
> The API is guarded by CAP_NET_ADMIN.
> 
> Signed-off-by: Daniel Mack <daniel@zonque.org>
> syscall
> ---
>  include/uapi/linux/bpf.h |  9 ++++++
>  kernel/bpf/syscall.c     | 83 ++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 92 insertions(+)
> 
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 1d5db42..4cc2dcf 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -73,6 +73,8 @@ enum bpf_cmd {
>  	BPF_PROG_LOAD,
>  	BPF_OBJ_PIN,
>  	BPF_OBJ_GET,
> +	BPF_PROG_ATTACH,
> +	BPF_PROG_DETACH,
>  };
>  
>  enum bpf_map_type {
> @@ -147,6 +149,13 @@ union bpf_attr {
>  		__aligned_u64	pathname;
>  		__u32		bpf_fd;
>  	};
> +
> +	struct { /* anonymous struct used by BPF_PROG_ATTACH/DETACH commands */
> +		__u32		target_fd;	/* container object to attach to */
> +		__u32		attach_bpf_fd;	/* eBPF program to attach */
> +		__u32		attach_type;	/* BPF_ATTACH_TYPE_* */
> +		__u64		attach_flags;
> +	};

there is a 4 byte hole in this struct. Can we pack it differently?

>  } __attribute__((aligned(8)));
>  
>  /* integer value in 'imm' field of BPF_CALL instruction selects which helper
> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> index 228f962..cc4d603 100644
> --- a/kernel/bpf/syscall.c
> +++ b/kernel/bpf/syscall.c
> @@ -822,6 +822,79 @@ static int bpf_obj_get(const union bpf_attr *attr)
>  	return bpf_obj_get_user(u64_to_ptr(attr->pathname));
>  }
>  
> +#ifdef CONFIG_CGROUP_BPF
> +static int bpf_prog_attach(const union bpf_attr *attr)
> +{
> +	struct bpf_prog *prog;
> +
> +	if (!capable(CAP_NET_ADMIN))
> +		return -EPERM;
> +
> +	/* Flags are unused for now */
> +	if (attr->attach_flags != 0)
> +		return -EINVAL;
> +
> +	switch (attr->attach_type) {
> +	case BPF_ATTACH_TYPE_CGROUP_INET_INGRESS:
> +	case BPF_ATTACH_TYPE_CGROUP_INET_EGRESS: {
> +		struct cgroup *cgrp;
> +
> +		prog = bpf_prog_get_type(attr->attach_bpf_fd,
> +					 BPF_PROG_TYPE_CGROUP_SOCKET_FILTER);
> +		if (IS_ERR(prog))
> +			return PTR_ERR(prog);
> +
> +		cgrp = cgroup_get_from_fd(attr->target_fd);
> +		if (IS_ERR(cgrp)) {
> +			bpf_prog_put(prog);
> +			return PTR_ERR(cgrp);
> +		}
> +
> +		cgroup_bpf_update(cgrp, prog, attr->attach_type);
> +		cgroup_put(cgrp);
> +
> +		break;
> +	}

this } formatting style is confusing. The above } looks
like it matches 'switch () {'.
May be move 'struct cgroup *cgrp' to the top to avoid that?
