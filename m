From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next 3/4] soreuseport: setsockopt SO_ATTACH_REUSEPORT_[CE]BPF
Date: Sat, 02 Jan 2016 22:28:30 +0100
Message-ID: <568840FE.6000001@iogearbox.net>
References: <1451410150-15466-1-git-send-email-kraigatgoog@gmail.com> <1451410150-15466-4-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41600 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385AbcABV2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jan 2016 16:28:33 -0500
In-Reply-To: <1451410150-15466-4-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/29/2015 06:29 PM, Craig Gallek wrote:
> From: Craig Gallek <kraig@google.com>
>
> Expose socket options for setting a classic or extended BPF program
> for use when selecting sockets in an SO_REUSEPORT group.  These options
> can be used on the first socket to belong to a group before bind or
> on any socket in the group after bind.
>
> This change includes refactoring of the existing sk_filter code to
> allow reuse of the existing BPF filter validation checks.
>
> Signed-off-by: Craig Gallek <kraig@google.com>
[...]
> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index 4165e9a..3561d3a 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -447,6 +447,8 @@ void bpf_prog_destroy(struct bpf_prog *fp);
>
>   int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk);
>   int sk_attach_bpf(u32 ufd, struct sock *sk);
> +int reuseport_attach_filter(struct sock_fprog *fprog, struct sock *sk);
> +int reuseport_attach_bpf(u32 ufd, struct sock *sk);

Maybe for consistency this should be sk_* prefixed as well due to its
relation to sockets?

>   int sk_detach_filter(struct sock *sk);
>   int sk_get_filter(struct sock *sk, struct sock_filter __user *filter,
>   		  unsigned int len);
[...]
> diff --git a/net/core/filter.c b/net/core/filter.c
> index c770196..81eeeae 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -50,6 +50,7 @@
>   #include <net/cls_cgroup.h>
>   #include <net/dst_metadata.h>
>   #include <net/dst.h>
> +#include <net/sock_reuseport.h>
>
>   /**
>    *	sk_filter - run a packet through a socket filter
> @@ -1167,17 +1168,32 @@ static int __sk_attach_prog(struct bpf_prog *prog, struct sock *sk)
>   	return 0;
>   }
>
> -/**
> - *	sk_attach_filter - attach a socket filter
> - *	@fprog: the filter program
> - *	@sk: the socket to use
> - *
> - * Attach the user's filter code. We first run some sanity checks on
> - * it to make sure it does not explode on us later. If an error
> - * occurs or there is insufficient memory for the filter a negative
> - * errno code is returned. On success the return is zero.
> - */
> -int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
> +static int __reuseport_attach_prog(struct bpf_prog *prog, struct sock *sk)
> +{
> +	struct bpf_prog *old_prog;
> +	int err;
> +
> +	if (bpf_prog_size(prog->len) > sysctl_optmem_max)
> +		return -ENOMEM;

You currently don't charge the BPF program against the optmem limits, but just
test if the size of a given program would surpass the current sysctl_optmem_max.
Ok, after all, this would block anything beyond 2560 insns by default. Is there
a reason it's not charged for real? Due to the sysctl_optmem_max default being
too small?

Btw, in case of an eBPF fd, we already charged it to the user's RLIMIT_MEMLOCK,
not sure if blocking it here after program already got an fd makes much sense.
I'm fine if you want to leave it for now and refine this later, though.

> +	if (sk_unhashed(sk)) {
> +		err = reuseport_alloc(sk);
> +		if (err)
> +			return err;
> +	} else if (!rcu_access_pointer(sk->sk_reuseport_cb)) {
> +		/* The socket wasn't bound with SO_REUSEPORT */
> +		return -EINVAL;
> +	}
> +
> +	old_prog = reuseport_attach_prog(sk, prog);
> +	if (old_prog)
> +		bpf_prog_destroy(old_prog);
> +
> +	return 0;
> +}
> +
> +static
> +struct bpf_prog *__get_filter(struct sock_fprog *fprog, struct sock *sk)
>   {
>   	unsigned int fsize = bpf_classic_proglen(fprog);
>   	unsigned int bpf_fsize = bpf_prog_size(fprog->len);
> @@ -1185,19 +1201,19 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
>   	int err;
>
>   	if (sock_flag(sk, SOCK_FILTER_LOCKED))
> -		return -EPERM;
> +		return ERR_PTR(-EPERM);
>
>   	/* Make sure new filter is there and in the right amounts. */
>   	if (fprog->filter == NULL)
> -		return -EINVAL;
> +		return ERR_PTR(-EINVAL);
>
>   	prog = bpf_prog_alloc(bpf_fsize, 0);
>   	if (!prog)
> -		return -ENOMEM;
> +		return ERR_PTR(-ENOMEM);
>
>   	if (copy_from_user(prog->insns, fprog->filter, fsize)) {
>   		__bpf_prog_free(prog);
> -		return -EFAULT;
> +		return ERR_PTR(-EFAULT);
>   	}
>
>   	prog->len = fprog->len;
> @@ -1205,13 +1221,31 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
>   	err = bpf_prog_store_orig_filter(prog, fprog);
>   	if (err) {
>   		__bpf_prog_free(prog);
> -		return -ENOMEM;
> +		return ERR_PTR(-ENOMEM);
>   	}
>
>   	/* bpf_prepare_filter() already takes care of freeing
>   	 * memory in case something goes wrong.
>   	 */
>   	prog = bpf_prepare_filter(prog, NULL);
> +	return prog;
> +}

Nit: return bpf_prepare_filter(prog, NULL);

Rest of BPF bits look good to me.

Thanks,
Daniel
