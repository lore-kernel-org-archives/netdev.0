From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC PATCH 4/5] net: filter: run cgroup eBPF programs
Date: Wed, 17 Aug 2016 11:20:29 -0700
Message-ID: <20160817182027.GD98226@ast-mbp.thefacebook.com>
References: <1471442448-1248-1-git-send-email-daniel@zonque.org>
 <1471442448-1248-5-git-send-email-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: htejun@fb.com, daniel@iogearbox.net, ast@fb.com,
	davem@davemloft.net, kafai@fb.com, fw@strlen.de,
	pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:33481 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752807AbcHQSUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 14:20:33 -0400
Received: by mail-pa0-f67.google.com with SMTP id vy10so7733112pac.0
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 11:20:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1471442448-1248-5-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 17, 2016 at 04:00:47PM +0200, Daniel Mack wrote:
> If CONFIG_CGROUP_BPF is enabled, and the cgroup associated with the
> receiving socket has an eBPF programs installed, run them from
> sk_filter_trim_cap().
> 
> eBPF programs used in this context are expected to either return 1 to
> let the packet pass, or != 1 to drop them. The programs have access to
> the full skb, including the MAC headers.
> 
> This patch only implements the call site for ingress packets.
> 
> Signed-off-by: Daniel Mack <daniel@zonque.org>
> ---
>  net/core/filter.c | 44 ++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 44 insertions(+)
> 
> diff --git a/net/core/filter.c b/net/core/filter.c
> index c5d8332..a1dd94b 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -52,6 +52,44 @@
>  #include <net/dst.h>
>  #include <net/sock_reuseport.h>
>  
> +#ifdef CONFIG_CGROUP_BPF
> +static int sk_filter_cgroup_bpf(struct sock *sk, struct sk_buff *skb,
> +				enum bpf_attach_type type)
> +{
> +	struct sock_cgroup_data *skcd = &sk->sk_cgrp_data;
> +	struct cgroup *cgrp = sock_cgroup_ptr(skcd);
> +	struct bpf_prog *prog;
> +	int ret = 0;
> +
> +	rcu_read_lock();
> +
> +	switch (type) {
> +	case BPF_ATTACH_TYPE_CGROUP_EGRESS:
> +		prog = rcu_dereference(cgrp->bpf_egress);
> +		break;
> +	case BPF_ATTACH_TYPE_CGROUP_INGRESS:
> +		prog = rcu_dereference(cgrp->bpf_ingress);
> +		break;
> +	default:
> +		WARN_ON_ONCE(1);
> +		ret = -EINVAL;
> +		break;
> +	}
> +
> +	if (prog) {

I really like how in this version of the patches it became
a single load+cmp of per-packet cost when this feature is off.
Please move
+	struct cgroup *cgrp = sock_cgroup_ptr(skcd);
into if (prog) {..}
to make sure it's actually single load.
The compiler cannot avoid that load when it's placed at the top.

> +		unsigned int offset = skb->data - skb_mac_header(skb);
> +
> +		__skb_push(skb, offset);
> +		ret = bpf_prog_run_clear_cb(prog, skb) > 0 ? 0 : -EPERM;

that doesn't match commit log. The above '> 0' makes sense to me though.
If we want to do it for 1 only we have to define it in uapi/bpf.h
as action code, so we can extend to 2, 3 in the future if necessary.

It also have to be bpf_prog_run_save_cb() (as sk_filter_trim_cap() does)
instead of bpf_prog_run_clear_cb().
See commit ff936a04e5f2 ("bpf: fix cb access in socket filter programs")

> +		__skb_pull(skb, offset);
> +	}
> +
> +	rcu_read_unlock();
> +
> +	return ret;
> +}
> +#endif /* !CONFIG_CGROUP_BPF */
> +
>  /**
>   *	sk_filter_trim_cap - run a packet through a socket filter
>   *	@sk: sock associated with &sk_buff
> @@ -78,6 +116,12 @@ int sk_filter_trim_cap(struct sock *sk, struct sk_buff *skb, unsigned int cap)
>  	if (skb_pfmemalloc(skb) && !sock_flag(sk, SOCK_MEMALLOC))
>  		return -ENOMEM;
>  
> +#ifdef CONFIG_CGROUP_BPF
> +	err = sk_filter_cgroup_bpf(sk, skb, BPF_ATTACH_TYPE_CGROUP_INGRESS);
> +	if (err)
> +		return err;
> +#endif
> +
>  	err = security_sock_rcv_skb(sk, skb);
>  	if (err)
>  		return err;
> -- 
> 2.5.5
> 
