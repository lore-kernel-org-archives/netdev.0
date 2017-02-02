From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 2/2] Add a eBPF helper function to retrieve socket
 uid
Date: Thu, 02 Feb 2017 22:32:55 +0100
Message-ID: <5893A587.6090000@iogearbox.net>
References: <20170202205950.100334-1-chenbofeng.kernel@gmail.com> <20170202205950.100334-3-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>,
        Lorenzo Colitti <lorenzo@google.com>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@fb.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48625 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751298AbdBBVdO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 16:33:14 -0500
In-Reply-To: <20170202205950.100334-3-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/02/2017 09:59 PM, Chenbo Feng wrote:
> From: Chenbo Feng <fengc@google.com>
>
> Returns the owner uid of the socket inside a sk_buff. This is useful to
> perform per-UID accounting of network traffic or per-UID packet
> filtering.
>
> Signed-off-by: Chenbo Feng <chenbofeng.kernel@gmail.com>
> ---
>   include/linux/bpf.h      |  1 +
>   include/uapi/linux/bpf.h |  9 ++++++++-
>   net/core/filter.c        | 19 +++++++++++++++++++
>   3 files changed, 28 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/bpf.h b/include/linux/bpf.h
> index 3f2e0af28c6e..c775ca4678b7 100644
> --- a/include/linux/bpf.h
> +++ b/include/linux/bpf.h
> @@ -350,6 +350,7 @@ extern const struct bpf_func_proto bpf_skb_vlan_push_proto;
>   extern const struct bpf_func_proto bpf_skb_vlan_pop_proto;
>   extern const struct bpf_func_proto bpf_get_stackid_proto;
>   extern const struct bpf_func_proto bpf_get_socket_cookie_proto;
> +extern const struct bpf_func_proto bpf_get_socket_uid_proto;

Likewise, no need to add it here.

>   /* Shared helpers among cBPF and eBPF. */
>   void bpf_user_rnd_init_once(void);
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 62ee5fab08e5..dad4dc7aca49 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -436,6 +436,12 @@ union bpf_attr {
>    *     @skb: pointer to skb
>    *     Return: 8 Bytes non-decreasing number on success or 0 if the socket
>    *     field is missing inside sk_buff
> + *
> + * u32 bpf_get_socket_uid(skb)
> + *     Get the owner uid of the socket stored inside sk_buff.
> + *     @skb: pointer to skb
> + *     Return: uid of the socket owner on success or 0 if the socket pointer
> + *     inside sk_buff is NULL
>    */
>   #define __BPF_FUNC_MAPPER(FN)		\
>   	FN(unspec),			\
> @@ -483,7 +489,8 @@ union bpf_attr {
>   	FN(get_numa_node_id),		\
>   	FN(skb_change_head),		\
>   	FN(xdp_adjust_head),		\
> -	FN(get_socket_cookie),
> +	FN(get_socket_cookie),	\
> +	FN(get_socket_uid),
>
>   /* integer value in 'imm' field of BPF_CALL instruction selects which helper
>    * function eBPF program intends to call
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 913b14d3b484..bc36ed72551f 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -2610,6 +2610,23 @@ const struct bpf_func_proto bpf_get_socket_cookie_proto = {
>   	.arg1_type      = ARG_PTR_TO_CTX,
>   };
>
> +BPF_CALL_1(bpf_get_socket_uid, struct sk_buff *, skb)
> +{
> +	struct sock *sk;
> +	kuid_t kuid;

Nit: already init them above.

> +	sk = skb->sk;
> +	kuid = sock_net_uid(dev_net(skb->dev), sk);

Don't you need to test for fullsock? Do you mean something like below?

struct sock *sk = skb->sk;
kuid_t kuid = sock_net_uid(net, sk && sk_fullsock(sk) ?
			   sk : NULL);

> +	return (u32)kuid.val;
> +}
> +
> +const struct bpf_func_proto bpf_get_socket_uid_proto = {

static ...

> +	.func           = bpf_get_socket_uid,
> +	.gpl_only       = false,
> +	.ret_type       = RET_INTEGER,
> +	.arg1_type      = ARG_PTR_TO_CTX,
> +};
> +
>   static const struct bpf_func_proto *
>   sk_filter_func_proto(enum bpf_func_id func_id)
>   {
> @@ -2635,6 +2652,8 @@ sk_filter_func_proto(enum bpf_func_id func_id)
>   			return bpf_get_trace_printk_proto();
>   	case BPF_FUNC_get_socket_cookie:
>   		return &bpf_get_socket_cookie_proto;
> +	case BPF_FUNC_get_socket_uid:
> +		return &bpf_get_socket_uid_proto;
>   	default:
>   		return NULL;
>   	}
>
