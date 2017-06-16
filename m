From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC PATCH net-next v2 07/15] bpf: Add setsockopt helper function
 to bpf
Date: Fri, 16 Jun 2017 15:27:18 +0200
Message-ID: <5943DCB6.6070205@iogearbox.net>
References: <20170615200844.2752485-1-brakmo@fb.com> <20170615200844.2752485-8-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: Lawrence Brakmo <brakmo@fb.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57003 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752566AbdFPN1W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 09:27:22 -0400
In-Reply-To: <20170615200844.2752485-8-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/15/2017 10:08 PM, Lawrence Brakmo wrote:
> Added support for calling a subset of socket setsockopts from
> BPF_PROG_TYPE_SOCKET_OPS programs. The code was duplicated rather
> than making the changes to call the socket setsockopt function because
> the changes required would have been larger.
>
> The ops supported are:
>    SO_RCVBUF
>    SO_SNDBUF
>    SO_MAX_PACING_RATE
>    SO_PRIORITY
>    SO_RCVLOWAT
>    SO_MARK
>
> Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
> ---
>   include/uapi/linux/bpf.h  | 14 ++++++++-
>   net/core/filter.c         | 77 ++++++++++++++++++++++++++++++++++++++++++++++-
>   samples/bpf/bpf_helpers.h |  3 ++
>   3 files changed, 92 insertions(+), 2 deletions(-)
>
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index d945336..8accb4d 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -520,6 +520,17 @@ union bpf_attr {
>    *     Set full skb->hash.
>    *     @skb: pointer to skb
>    *     @hash: hash to set
> + *
> + * int bpf_setsockopt(bpf_socket, level, optname, optval, optlen)
> + *     Calls setsockopt. Not all opts are available, only those with
> + *     integer optvals plus TCP_CONGESTION.
> + *     Supported levels: SOL_SOCKET and IPROTO_TCP
> + *     @bpf_socket: pointer to bpf_socket
> + *     @level: SOL_SOCKET or IPROTO_TCP
> + *     @optname: option name
> + *     @optval: pointer to option value
> + *     @optlen: length of optval in byes
> + *     Return: 0 or negative error
>    */
>   #define __BPF_FUNC_MAPPER(FN)		\
>   	FN(unspec),			\
> @@ -570,7 +581,8 @@ union bpf_attr {
>   	FN(probe_read_str),		\
>   	FN(get_socket_cookie),		\
>   	FN(get_socket_uid),		\
> -	FN(set_hash),
> +	FN(set_hash),			\
> +	FN(setsockopt),
>
>   /* integer value in 'imm' field of BPF_CALL instruction selects which helper
>    * function eBPF program intends to call
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 7466f55..9ff567c 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -54,6 +54,7 @@
>   #include <net/dst.h>
>   #include <net/sock_reuseport.h>
>   #include <net/busy_poll.h>
> +#include <net/tcp.h>
>
>   /**
>    *	sk_filter_trim_cap - run a packet through a socket filter
> @@ -2671,6 +2672,69 @@ static const struct bpf_func_proto bpf_get_socket_uid_proto = {
>   	.arg1_type      = ARG_PTR_TO_CTX,
>   };
>
> +BPF_CALL_5(bpf_setsockopt, struct bpf_socket_ops_kern *, bpf_socket,
> +	   int, level, int, optname, char *, optval, int, optlen)
> +{
> +	struct sock *sk = bpf_socket->sk;
> +	int ret = 0;
> +	int val;
> +
> +	if (bpf_socket->is_req_sock)
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

Likely all of the above, I think we could make programs even more
flexible if these are members in the context struct itself, so
that socket_ops_convert_ctx_access() would translate them inline
w/o even needing a helper call with the bonus of having read and
write access.

But what about socket lock that we otherwise have in sock_setsockopt()?

Could we add a sock_owned_by_me(sk) to tcp_call_bpf() to really assert
this for all cases, so that lockdep complains should it ever be not
the case?

> +		default:
> +			ret = -EINVAL;
> +		}
> +	} else if (level == SOL_TCP &&
> +		   bpf_socket->sk->sk_prot->setsockopt == tcp_setsockopt) {
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
> +};
> +
>   static const struct bpf_func_proto *
>   bpf_base_func_proto(enum bpf_func_id func_id)
>   {
> @@ -2822,6 +2886,17 @@ lwt_inout_func_proto(enum bpf_func_id func_id)
>   }
>
>   static const struct bpf_func_proto *
> +	socket_ops_func_proto(enum bpf_func_id func_id)
> +{
> +	switch (func_id) {
> +	case BPF_FUNC_setsockopt:
> +		return &bpf_setsockopt_proto;
> +	default:
> +		return bpf_base_func_proto(func_id);
> +	}
> +}
> +
> +static const struct bpf_func_proto *
>   lwt_xmit_func_proto(enum bpf_func_id func_id)
>   {
>   	switch (func_id) {
> @@ -3565,7 +3640,7 @@ const struct bpf_verifier_ops cg_sock_prog_ops = {
>   };
>
>   const struct bpf_verifier_ops socket_ops_prog_ops = {
> -	.get_func_proto		= bpf_base_func_proto,
> +	.get_func_proto		= socket_ops_func_proto,
>   	.is_valid_access	= socket_ops_is_valid_access,
>   	.convert_ctx_access	= socket_ops_convert_ctx_access,
>   };
> diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
> index f4840b8..d50ac34 100644
> --- a/samples/bpf/bpf_helpers.h
> +++ b/samples/bpf/bpf_helpers.h
> @@ -60,6 +60,9 @@ static unsigned long long (*bpf_get_prandom_u32)(void) =
>   	(void *) BPF_FUNC_get_prandom_u32;
>   static int (*bpf_xdp_adjust_head)(void *ctx, int offset) =
>   	(void *) BPF_FUNC_xdp_adjust_head;
> +static int (*bpf_setsockopt)(void *ctx, int level, int optname, void *optval,
> +			     int optlen) =
> +	(void *) BPF_FUNC_setsockopt;
>
>   /* llvm builtin functions that eBPF C program may use to
>    * emit BPF_LD_ABS and BPF_LD_IND instructions
>
