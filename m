From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] ebpf: add skb->hash to offset map for usage in
 {cls,act}_bpf or filters
Date: Sun, 2 Aug 2015 18:09:43 -0700
Message-ID: <CALx6S35Xw-14Z8=w2cg7dFFzfkEmkjuqU=37uG3Tb-OoW2JEoA@mail.gmail.com>
References: <4b25d0b28e9c366a8a307d855d1690038956e6bd.1438382433.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:34281 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957AbbHCBJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2015 21:09:44 -0400
Received: by igk11 with SMTP id 11so62646886igk.1
        for <netdev@vger.kernel.org>; Sun, 02 Aug 2015 18:09:43 -0700 (PDT)
In-Reply-To: <4b25d0b28e9c366a8a307d855d1690038956e6bd.1438382433.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 31, 2015 at 3:46 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> Add skb->hash to the __sk_buff offset map, so it can be accessed from
> an eBPF program. We currently already do this for classic BPF filters,
> but not yet on eBPF, it might be useful as a demuxer in combination with
> helpers like bpf_clone_redirect(), toy example:
>
>   __section("cls-lb") int ingress_main(struct __sk_buff *skb)
>   {
>     unsigned int which = 3 + (skb->hash & 7);
>     /* bpf_skb_store_bytes(skb, ...); */
>     /* bpf_l{3,4}_csum_replace(skb, ...); */
>     bpf_clone_redirect(skb, which, 0);
>     return -1;
>   }
>
> I was thinking whether to add skb_get_hash(), but then concluded the
> raw skb->hash seems fine in this case: we can directly access the hash
> w/o extra eBPF helper function call, it's filled out by many NICs on
> ingress, and in case the entropy level would not be sufficient, people
> can still implement their own specific sw fallback hash mix anyway.
>
Maybe we should add the skb_get_hash also? It doesn't as useful if
some scenarios we get a valid hash and in others not.

Tom

> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
>  include/uapi/linux/bpf.h | 1 +
>  net/core/filter.c        | 7 +++++++
>  2 files changed, 8 insertions(+)
>
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index bc0d27d..2ce13c1 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -290,6 +290,7 @@ struct __sk_buff {
>         __u32 ifindex;
>         __u32 tc_index;
>         __u32 cb[5];
> +       __u32 hash;
>  };
>
>  struct bpf_tunnel_key {
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 1b72264..a50dbfa 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -1711,6 +1711,13 @@ static u32 bpf_net_convert_ctx_access(enum bpf_access_type type, int dst_reg,
>                                       offsetof(struct net_device, ifindex));
>                 break;
>
> +       case offsetof(struct __sk_buff, hash):
> +               BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, hash) != 4);
> +
> +               *insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
> +                                     offsetof(struct sk_buff, hash));
> +               break;
> +
>         case offsetof(struct __sk_buff, mark):
>                 BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, mark) != 4);
>
> --
> 1.9.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
