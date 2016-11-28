From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v3 2/3] bpf: Add new cgroup attach type to
 enable sock modifications
Date: Mon, 28 Nov 2016 12:32:53 -0800
Message-ID: <20161128203252.GB7634@ast-mbp.thefacebook.com>
References: <1480348130-31354-1-git-send-email-dsa@cumulusnetworks.com>
 <1480348130-31354-3-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@zonque.org, ast@fb.com,
        daniel@iogearbox.net, maheshb@google.com, tgraf@suug.ch
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35339 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755033AbcK1Uc6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 15:32:58 -0500
Received: by mail-pf0-f195.google.com with SMTP id i88so6934482pfk.2
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 12:32:58 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1480348130-31354-3-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 07:48:49AM -0800, David Ahern wrote:
> Add new cgroup based program type, BPF_PROG_TYPE_CGROUP_SOCK. Similar to
> BPF_PROG_TYPE_CGROUP_SKB programs can be attached to a cgroup and run
> any time a process in the cgroup opens an AF_INET or AF_INET6 socket.
> Currently only sk_bound_dev_if is exported to userspace for modification
> by a bpf program.
> 
> This allows a cgroup to be configured such that AF_INET{6} sockets opened
> by processes are automatically bound to a specific device. In turn, this
> enables the running of programs that do not support SO_BINDTODEVICE in a
> specific VRF context / L3 domain.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
...
> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index 1f09c521adfe..808e158742a2 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -408,7 +408,7 @@ struct bpf_prog {
>  	enum bpf_prog_type	type;		/* Type of BPF program */
>  	struct bpf_prog_aux	*aux;		/* Auxiliary fields */
>  	struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
> -	unsigned int		(*bpf_func)(const struct sk_buff *skb,
> +	unsigned int		(*bpf_func)(const void *ctx,
>  					    const struct bpf_insn *filter);

Daniel already tweaked it. pls rebase.

> +static const struct bpf_func_proto *
> +cg_sock_func_proto(enum bpf_func_id func_id)
> +{
> +	return NULL;
> +}

if you don't want any helpers, just don't set .get_func_proto.
See check_call() in verifier.
Though why not allow socket filter like helpers that
sk_filter_func_proto() provides?
tail call, bpf_trace_printk, maps are useful things that you get for free.
Developing programs without bpf_trace_printk is pretty hard.

> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 5ddf5cda07f4..24d2550492ee 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -374,8 +374,18 @@ static int inet_create(struct net *net, struct socket *sock, int protocol,
>  
>  	if (sk->sk_prot->init) {
>  		err = sk->sk_prot->init(sk);
> -		if (err)
> +		if (err) {
> +			sk_common_release(sk);
> +			goto out;
> +		}
> +	}
> +
> +	if (!kern) {
> +		err = BPF_CGROUP_RUN_PROG_INET_SOCK(sk);

i guess from vrf use case point of view this is the best place,
since so_bindtodevice can still override it,
but thinking little bit into other use case like port binding
restrictions and port rewrites can we move it into inet_bind ?
My understanding nothing will be using bound_dev_if until that
time, so we can set it there?
And at that point we can extend 'struct bpf_sock' with other
fields like port and sockaddr...
and single BPF_PROG_TYPE_CGROUP_SOCK type will be used for
vrf and port binding use cases...
More users, more testing of that code path...
