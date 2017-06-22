From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v3 01/15] bpf: BPF support for sock_ops
Date: Fri, 23 Jun 2017 00:41:37 +0200
Message-ID: <594C47A1.1080102@iogearbox.net>
References: <20170620030048.3275347-1-brakmo@fb.com> <20170620030048.3275347-2-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: Lawrence Brakmo <brakmo@fb.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44849 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753611AbdFVWll (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 18:41:41 -0400
In-Reply-To: <20170620030048.3275347-2-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/20/2017 05:00 AM, Lawrence Brakmo wrote:
[...]
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index f94b48b..861dbe9 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -120,12 +120,14 @@ enum bpf_prog_type {
>   	BPF_PROG_TYPE_LWT_IN,
>   	BPF_PROG_TYPE_LWT_OUT,
>   	BPF_PROG_TYPE_LWT_XMIT,
> +	BPF_PROG_TYPE_SOCK_OPS,
>   };
>
>   enum bpf_attach_type {
>   	BPF_CGROUP_INET_INGRESS,
>   	BPF_CGROUP_INET_EGRESS,
>   	BPF_CGROUP_INET_SOCK_CREATE,
> +	BPF_GLOBAL_SOCK_OPS,
>   	__MAX_BPF_ATTACH_TYPE
>   };
[...]
>   #endif /* _UAPI__LINUX_BPF_H__ */
> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> index 8942c82..e02831f 100644
> --- a/kernel/bpf/syscall.c
> +++ b/kernel/bpf/syscall.c
[...]
> +static int bpf_prog_attach(const union bpf_attr *attr)
> +{
> +	if (!capable(CAP_NET_ADMIN))
> +		return -EPERM;
> +
> +	if (CHECK_ATTR(BPF_PROG_ATTACH))
> +		return -EINVAL;
> +
> +	if (attr->attach_type == BPF_GLOBAL_SOCK_OPS)
> +		return bpf_sock_ops_attach_global_prog(attr->attach_bpf_fd);
> +	else
> +		return bpf_prog_attach_cgroup(attr);
> +}
> +
[...]
> +static int bpf_prog_detach(const union bpf_attr *attr)
> +{
> +	if (!capable(CAP_NET_ADMIN))
> +		return -EPERM;
> +
> +	if (CHECK_ATTR(BPF_PROG_DETACH))
> +		return -EINVAL;
> +
> +	if (attr->attach_type == BPF_GLOBAL_SOCK_OPS)
> +		return bpf_sock_ops_detach_global_prog();
> +	else
> +		return bpf_prog_detach_cgroup(attr);
> +}
>
>   #define BPF_PROG_TEST_RUN_LAST_FIELD test.duration
>
> @@ -1431,14 +1467,12 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
>   	case BPF_OBJ_GET:
>   		err = bpf_obj_get(&attr);
>   		break;
> -#ifdef CONFIG_CGROUP_BPF
>   	case BPF_PROG_ATTACH:
>   		err = bpf_prog_attach(&attr);
>   		break;
>   	case BPF_PROG_DETACH:
>   		err = bpf_prog_detach(&attr);
>   		break;
> -#endif
>   	case BPF_PROG_TEST_RUN:
>   		err = bpf_prog_test_run(&attr, uattr);
>   		break;
[...]
> diff --git a/net/core/sock_bpfops.c b/net/core/sock_bpfops.c
> new file mode 100644
> index 0000000..06f4a64
> --- /dev/null
> +++ b/net/core/sock_bpfops.c
> @@ -0,0 +1,65 @@
> +/*
> + * BPF support for sockets
> + *
> + * Copyright (c) 2016 Lawrence Brakmo <brakmo@fb.com>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2
> + * as published by the Free Software Foundation.
> + */
> +
> +#include <net/sock.h>
> +#include <linux/skbuff.h>
> +#include <linux/bpf.h>
> +#include <linux/filter.h>
> +#include <linux/errno.h>
> +#ifdef CONFIG_NET_NS
> +#include <net/net_namespace.h>
> +#include <linux/proc_ns.h>
> +#endif
> +
> +/* Global BPF program for sockets */
> +static struct bpf_prog *bpf_global_sock_ops_prog;
> +
> +int bpf_sock_ops_detach_global_prog(void)
> +{
> +	struct bpf_prog *old_prog;
> +
> +	old_prog = xchg(&bpf_global_sock_ops_prog, NULL);
> +
> +	if (old_prog)
> +		bpf_prog_put(old_prog);
> +
> +	return 0;
> +}
> +
> +int bpf_sock_ops_attach_global_prog(int fd)
> +{
> +	struct bpf_prog *prog, *old_prog;
> +	int err = 0;
> +
> +	prog = bpf_prog_get_type(fd, BPF_PROG_TYPE_SOCK_OPS);
> +	if (IS_ERR(prog))
> +		return PTR_ERR(prog);
> +
> +	old_prog = xchg(&bpf_global_sock_ops_prog, prog);
> +	if (old_prog)
> +		bpf_prog_put(old_prog);
> +	return err;
> +}
> +
> +int bpf_sock_ops_call(struct bpf_sock_ops_kern *bpf_sock)
> +{
> +	struct bpf_prog *prog;
> +	int ret;
> +
> +	rcu_read_lock();
> +	prog =  READ_ONCE(bpf_global_sock_ops_prog);
> +	if (prog)
> +		ret = BPF_PROG_RUN(prog, bpf_sock);
> +	else
> +		ret = -1;
> +	rcu_read_unlock();
> +
> +	return ret;
> +}

Now that we integrate with BPF_PROG_ATTACH/DETACH, can you make all
the above also per cgroup as we have with all other BPF_CGROUP_INET_*
progs? It seems kind of weird that we have one single global program
doing the enforcement of TCP and congctl options. Something on a more
fine-grained level like cgroups would be more suited wrt containers,
etc. Right now there's no notion of global program of such kind.

Thanks,
Daniel
