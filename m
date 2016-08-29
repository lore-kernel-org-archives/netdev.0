From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v3 1/6] bpf: add new prog type for cgroup socket filtering
Date: Tue, 30 Aug 2016 00:14:46 +0200
Message-ID: <57C4B3D6.9090000@iogearbox.net>
References: <1472241532-11682-1-git-send-email-daniel@zonque.org> <1472241532-11682-2-git-send-email-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kafai@fb.com, fw@strlen.de,
        pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org,
        sargun@sargun.me
To: Daniel Mack <daniel@zonque.org>, htejun@fb.com, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55391 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753932AbcH2WPR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 18:15:17 -0400
In-Reply-To: <1472241532-11682-2-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2016 09:58 PM, Daniel Mack wrote:
> For now, this program type is equivalent to BPF_PROG_TYPE_SOCKET_FILTER in
> terms of checks during the verification process. It may access the skb as
> well.
>
> Programs of this type will be attached to cgroups for network filtering
> and accounting.
>
> Signed-off-by: Daniel Mack <daniel@zonque.org>
> ---
>   include/uapi/linux/bpf.h | 7 +++++++
>   kernel/bpf/verifier.c    | 1 +
>   net/core/filter.c        | 6 ++++++
>   3 files changed, 14 insertions(+)
>
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index e4c5a1b..1d5db42 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -95,6 +95,13 @@ enum bpf_prog_type {
>   	BPF_PROG_TYPE_SCHED_ACT,
>   	BPF_PROG_TYPE_TRACEPOINT,
>   	BPF_PROG_TYPE_XDP,
> +	BPF_PROG_TYPE_CGROUP_SOCKET_FILTER,
> +};

Nit: can we drop the _FILTER suffix? So just leaving it
at BPF_PROG_TYPE_CGROUP_SOCKET. Some of these use cases
might not always strictly be related to filtering, so
seems cleaner to just leave it out everywhere.

> +
> +enum bpf_attach_type {
> +	BPF_ATTACH_TYPE_CGROUP_INET_INGRESS,
> +	BPF_ATTACH_TYPE_CGROUP_INET_EGRESS,
> +	__MAX_BPF_ATTACH_TYPE
>   };

#define BPF_MAX_ATTACH_TYPE	__BPF_MAX_ATTACH_TYPE

And then use that in your follow-up patches for declaring
arrays, etc?

>
>   #define BPF_PSEUDO_MAP_FD	1
> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> index abb61f3..12ca880 100644
> --- a/kernel/bpf/verifier.c
> +++ b/kernel/bpf/verifier.c
> @@ -1805,6 +1805,7 @@ static bool may_access_skb(enum bpf_prog_type type)
>   	case BPF_PROG_TYPE_SOCKET_FILTER:
>   	case BPF_PROG_TYPE_SCHED_CLS:
>   	case BPF_PROG_TYPE_SCHED_ACT:
> +	case BPF_PROG_TYPE_CGROUP_SOCKET_FILTER:
>   		return true;
>   	default:
>   		return false;
> diff --git a/net/core/filter.c b/net/core/filter.c
> index a83766b..bc04e5c 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -2848,12 +2848,18 @@ static struct bpf_prog_type_list xdp_type __read_mostly = {
>   	.type	= BPF_PROG_TYPE_XDP,
>   };
>
> +static struct bpf_prog_type_list cg_sk_filter_type __read_mostly = {
> +	.ops	= &sk_filter_ops,
> +	.type	= BPF_PROG_TYPE_CGROUP_SOCKET_FILTER,
> +};
> +
>   static int __init register_sk_filter_ops(void)
>   {
>   	bpf_register_prog_type(&sk_filter_type);
>   	bpf_register_prog_type(&sched_cls_type);
>   	bpf_register_prog_type(&sched_act_type);
>   	bpf_register_prog_type(&xdp_type);
> +	bpf_register_prog_type(&cg_sk_filter_type);
>
>   	return 0;
>   }
>
