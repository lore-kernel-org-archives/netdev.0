From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v5 07/16] bpf: Add setsockopt helper function
 to bpf
Date: Sat, 01 Jul 2017 02:01:25 +0200
Message-ID: <5956E655.20105@iogearbox.net>
References: <20170630200706.4183158-1-brakmo@fb.com> <20170630200706.4183158-8-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: Lawrence Brakmo <brakmo@fb.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60758 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751581AbdGAAB1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 20:01:27 -0400
In-Reply-To: <20170630200706.4183158-8-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/30/2017 10:06 PM, Lawrence Brakmo wrote:
[...]
> @@ -2672,6 +2673,69 @@ static const struct bpf_func_proto bpf_get_socket_uid_proto = {
>   	.arg1_type      = ARG_PTR_TO_CTX,
>   };
>
> +BPF_CALL_5(bpf_setsockopt, struct bpf_sock_ops_kern *, bpf_sock,
> +	   int, level, int, optname, char *, optval, int, optlen)
> +{
> +	struct sock *sk = bpf_sock->sk;
> +	int ret = 0;
> +	int val;
> +
> +	if (!sk_fullsock(sk))
> +		return -EINVAL;
> +
> +	if (level == SOL_SOCKET) {
> +		/* Only some socketops are supported */
> +		val = *((int *)optval);
> +
> +		switch (optname) {
> +		case SO_RCVBUF:
> +			sk->sk_userlocks |= SOCK_RCVBUF_LOCK;
> +			sk->sk_rcvbuf = max_t(int, val * 2, SOCK_MIN_RCVBUF);
> +			break;
> +		case SO_SNDBUF:
> +			sk->sk_userlocks |= SOCK_SNDBUF_LOCK;
> +			sk->sk_sndbuf = max_t(int, val * 2, SOCK_MIN_SNDBUF);
> +			break;
> +		case SO_MAX_PACING_RATE:
> +			sk->sk_max_pacing_rate = val;
> +			sk->sk_pacing_rate = min(sk->sk_pacing_rate,
> +						 sk->sk_max_pacing_rate);
> +			break;
> +		case SO_PRIORITY:
> +			sk->sk_priority = val;
> +			break;
> +		case SO_RCVLOWAT:
> +			if (val < 0)
> +				val = INT_MAX;
> +			sk->sk_rcvlowat = val ? : 1;
> +			break;
> +		case SO_MARK:
> +			sk->sk_mark = val;
> +			break;
> +		default:
> +			ret = -EINVAL;
> +		}
> +	} else if (level == SOL_TCP &&
> +		   sk->sk_prot->setsockopt == tcp_setsockopt) {
> +		/* Place holder */
> +		ret = -EINVAL;
> +	} else {
> +		ret = -EINVAL;
> +	}
> +	return ret;
> +}
> +
> +static const struct bpf_func_proto bpf_setsockopt_proto = {
> +	.func		= bpf_setsockopt,
> +	.gpl_only	= true,
> +	.ret_type	= RET_INTEGER,
> +	.arg1_type	= ARG_PTR_TO_CTX,
> +	.arg2_type	= ARG_ANYTHING,
> +	.arg3_type	= ARG_ANYTHING,
> +	.arg4_type	= ARG_PTR_TO_MEM,
> +	.arg5_type	= ARG_CONST_SIZE_OR_ZERO,

Hm, I had some feedback on this in your last revision of the patch
set [1] that a NULL pointer dereference can be triggered here. Probably
oversaw it; I mentioned wrt the above:

   Any reason you went with the ARG_CONST_SIZE_OR_ZERO type? Semantics
   of this are that allowed [arg4, arg5] pair can be i) [NULL, 0] or
   ii) [non-NULL, non-zero], where in case ii) verifier checks that the
   area is initialized when coming from BPF stack.

   So above 'val = *((int *)optval);' would give a NULL pointer deref
   with NULL passed as arg or in case optlen was < sizeof(int) we access
   stack out of bounds potentially. If the [NULL, 0] pair is not required,
   I would just make that a ARG_CONST_SIZE and then check for size before
   accessing optval.

Would be good if you could still address it in a most likely final respin.

Thanks,
Daniel

   [1] http://patchwork.ozlabs.org/patch/781800/
