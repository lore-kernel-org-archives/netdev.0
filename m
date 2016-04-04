From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC PATCH 1/5] bpf: add PHYS_DEV prog type for early driver
 filter
Date: Mon, 04 Apr 2016 10:49:09 +0200
Message-ID: <57022A85.6040002@iogearbox.net>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com> <1459560118-5582-2-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com,
	alexei.starovoitov@gmail.com, gerlitz@mellanox.com,
	john.fastabend@gmail.com, brouer@redhat.com
To: Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48065 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310AbcDDItP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 04:49:15 -0400
In-Reply-To: <1459560118-5582-2-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/02/2016 03:21 AM, Brenden Blanco wrote:
> Add a new bpf prog type that is intended to run in early stages of the
> packet rx path. Only minimal packet metadata will be available, hence a new
> context type, struct xdp_metadata, is exposed to userspace. So far only
> expose the readable packet length, and only in read mode.
>
> The PHYS_DEV name is chosen to represent that the program is meant only
> for physical adapters, rather than all netdevs.
>
> While the user visible struct is new, the underlying context must be
> implemented as a minimal skb in order for the packet load_* instructions
> to work. The skb filled in by the driver must have skb->len, skb->head,
> and skb->data set, and skb->data_len == 0.
>
> Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
> ---
>   include/uapi/linux/bpf.h |  5 ++++
>   kernel/bpf/verifier.c    |  1 +
>   net/core/filter.c        | 68 ++++++++++++++++++++++++++++++++++++++++++++++++
>   3 files changed, 74 insertions(+)
>
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 924f537..b8a4ef2 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -92,6 +92,7 @@ enum bpf_prog_type {
>   	BPF_PROG_TYPE_KPROBE,
>   	BPF_PROG_TYPE_SCHED_CLS,
>   	BPF_PROG_TYPE_SCHED_ACT,
> +	BPF_PROG_TYPE_PHYS_DEV,
>   };
>
>   #define BPF_PSEUDO_MAP_FD	1
> @@ -367,6 +368,10 @@ struct __sk_buff {
>   	__u32 tc_classid;
>   };
>
> +struct xdp_metadata {
> +	__u32 len;
> +};

Should this consistently be called 'xdp' or rather 'phys dev',
because currently it's a mixture of both everywhere?

>   struct bpf_tunnel_key {
>   	__u32 tunnel_id;
>   	union {
> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> index 2e08f8e..804ca70 100644
> --- a/kernel/bpf/verifier.c
> +++ b/kernel/bpf/verifier.c
> @@ -1340,6 +1340,7 @@ static bool may_access_skb(enum bpf_prog_type type)
>   	case BPF_PROG_TYPE_SOCKET_FILTER:
>   	case BPF_PROG_TYPE_SCHED_CLS:
>   	case BPF_PROG_TYPE_SCHED_ACT:
> +	case BPF_PROG_TYPE_PHYS_DEV:
>   		return true;
>   	default:
>   		return false;
> diff --git a/net/core/filter.c b/net/core/filter.c
> index b7177d0..c417db6 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -2018,6 +2018,12 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
>   	}
>   }
>
> +static const struct bpf_func_proto *
> +phys_dev_func_proto(enum bpf_func_id func_id)
> +{
> +	return sk_filter_func_proto(func_id);

Do you plan to support bpf_skb_load_bytes() as well? I like using
this API especially when dealing with larger chunks (>4 bytes) to
load into stack memory, plus content is kept in network byte order.

What about other helpers such as bpf_skb_store_bytes() et al that
work on skbs. Do you intent to reuse them as is and thus populate
the per cpu skb with needed fields (faking linear data), or do you
see larger obstacles that prevent for this?

Thanks,
Daniel
