From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v5 2/3] Add a eBPF helper function to retrieve
 socket uid
Date: Tue, 21 Mar 2017 00:11:48 +0100
Message-ID: <58D061B4.7000603@iogearbox.net>
References: <1490035266-9861-1-git-send-email-chenbofeng.kernel@gmail.com> <1490035266-9861-3-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lorenzo Colitti <lorenzo@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>, netdev@vger.kernel.org,
        Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36536 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753136AbdCTXLu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 19:11:50 -0400
In-Reply-To: <1490035266-9861-3-git-send-email-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/20/2017 07:41 PM, Chenbo Feng wrote:
> From: Chenbo Feng <fengc@google.com>
>
> Returns the owner uid of the socket inside a sk_buff. This is useful to
> perform per-UID accounting of network traffic or per-UID packet
> filtering. The socket need to be a fullsock otherwise overflowuid is
> returned.
>
> Signed-off-by: Chenbo Feng <fengc@google.com>
> ---
>   include/uapi/linux/bpf.h       |  9 ++++++++-
>   net/core/filter.c              | 22 ++++++++++++++++++++++
>   tools/include/uapi/linux/bpf.h |  3 ++-
>   3 files changed, 32 insertions(+), 2 deletions(-)
>
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index dc81a9f..ff42111 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -462,6 +462,12 @@ union bpf_attr {
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
> @@ -510,7 +516,8 @@ union bpf_attr {
>   	FN(skb_change_head),		\
>   	FN(xdp_adjust_head),		\
>   	FN(probe_read_str),		\
> -	FN(get_socket_cookie),
> +	FN(get_socket_cookie),		\
> +	FN(get_socket_uid),
>
>   /* integer value in 'imm' field of BPF_CALL instruction selects which helper
>    * function eBPF program intends to call
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 5b65ae3..a7c25c1 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -2612,6 +2612,24 @@ static const struct bpf_func_proto bpf_get_socket_cookie_proto = {
>   	.arg1_type      = ARG_PTR_TO_CTX,
>   };
>
> +BPF_CALL_1(bpf_get_socket_uid, struct sk_buff *, skb)
> +{
> +	kuid_t kuid;
> +	struct sock *sk = sk_to_full_sk(skb->sk);

Minor nit, please change the order into:

	struct sock *sk = sk_to_full_sk(skb->sk);
	kuid_t kuid;

> +	if (!sk || !sk_fullsock(sk))
> +		return overflowuid;
> +	kuid = sock_net_uid(sock_net(sk), sk);
> +	return from_kuid_munged(current_user_ns(), kuid);
> +}
> +
> +static const struct bpf_func_proto bpf_get_socket_uid_proto = {
> +	.func           = bpf_get_socket_uid,
> +	.gpl_only       = false,
> +	.ret_type       = RET_INTEGER,
> +	.arg1_type      = ARG_PTR_TO_CTX,
> +};
> +

Rest looks good, thanks.

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
