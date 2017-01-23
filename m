From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC PATCH net-next 2/5] net: split skb_checksum_help
Date: Mon, 23 Jan 2017 12:59:48 -0800
Message-ID: <CALx6S37E=OEkRego_u=oDuUgQUn9-NZLpupvbN_dge1rqF92CQ@mail.gmail.com>
References: <cover.1485177252.git.dcaratti@redhat.com> <532e1db70b6c40f1b1e5c60b5b51be9f3437a30b.1485177252.git.dcaratti@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        linux-sctp@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Davide Caratti <dcaratti@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:33272 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750714AbdAWU7u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 15:59:50 -0500
Received: by mail-qt0-f193.google.com with SMTP id n13so20107960qtc.0
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 12:59:49 -0800 (PST)
In-Reply-To: <532e1db70b6c40f1b1e5c60b5b51be9f3437a30b.1485177252.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 8:52 AM, Davide Caratti <dcaratti@redhat.com> wrote:
> skb_checksum_help is designed to compute the Internet Checksum only. To
> avoid duplicating code when other checksumming algorithms (e.g. crc32c)
> are used, separate common part from RFC1624-specific part.
>
> Reviewed-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Signed-off-by: Davide Caratti <dcaratti@redhat.com>
> ---
>  net/core/dev.c | 51 +++++++++++++++++++++++++++++++++++----------------
>  1 file changed, 35 insertions(+), 16 deletions(-)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index ad5959e..6742160 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2532,13 +2532,36 @@ static void skb_warn_bad_offload(const struct sk_buff *skb)
>              skb_shinfo(skb)->gso_type, skb->ip_summed);
>  }
>
> -/*
> - * Invalidate hardware checksum when packet is to be mangled, and
> +/* compute 16-bit RFC1624 checksum and store it at skb->data + offset */
> +static int skb_rfc1624_csum(struct sk_buff *skb, int offset)
> +{
> +       __wsum csum;
> +       int ret = 0;
> +
> +       csum = skb_checksum(skb, offset, skb->len - offset, 0);
> +
> +       offset += skb->csum_offset;
> +       BUG_ON(offset + sizeof(__sum16) > skb_headlen(skb));
> +
> +       if (skb_cloned(skb) &&
> +           !skb_clone_writable(skb, offset + sizeof(__sum16))) {
> +               ret = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
> +               if (ret)
> +                       goto out;
> +       }
> +       *(__sum16 *)(skb->data + offset) = csum_fold(csum) ?: CSUM_MANGLED_0;
> +out:
> +       return ret;
> +}
> +
> +/* Invalidate hardware checksum when packet is to be mangled, and
>   * complete checksum manually on outgoing path.
> + *    @skb - buffer that needs checksum
> + *    @csum_algo(skb, offset) - function used to compute the checksum
>   */
> -int skb_checksum_help(struct sk_buff *skb)
> +static int __skb_checksum_help(struct sk_buff *skb,
> +                              int (*csum_algo)(struct sk_buff *, int))
>  {
> -       __wsum csum;
>         int ret = 0, offset;
>
>         if (skb->ip_summed == CHECKSUM_COMPLETE)

skb_checksum_help is specific to the Internet checksum. For instance,
CHECKSUM_COMPLETE can _only_ refer to Internet checksum calculation
nothing else will work. Checksums and CRCs are very different things
with very different processing. They are not interchangeable, have
very different properties, and hence it is a mistake to try to shoe
horn things so that they use a common infrastructure.

It might make sense to create some CRC helper functions, but last time
I checked there are so few users of CRC in skbufs I'm not even sure
that would make sense.

Tom

> @@ -2560,24 +2583,20 @@ int skb_checksum_help(struct sk_buff *skb)
>
>         offset = skb_checksum_start_offset(skb);
>         BUG_ON(offset >= skb_headlen(skb));
> -       csum = skb_checksum(skb, offset, skb->len - offset, 0);
> -
> -       offset += skb->csum_offset;
> -       BUG_ON(offset + sizeof(__sum16) > skb_headlen(skb));
> -
> -       if (skb_cloned(skb) &&
> -           !skb_clone_writable(skb, offset + sizeof(__sum16))) {
> -               ret = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
> -               if (ret)
> -                       goto out;
> -       }
>
> -       *(__sum16 *)(skb->data + offset) = csum_fold(csum) ?: CSUM_MANGLED_0;
> +       ret = csum_algo(skb, offset);
> +       if (ret)
> +               goto out;
>  out_set_summed:
>         skb->ip_summed = CHECKSUM_NONE;
>  out:
>         return ret;
>  }
> +
> +int skb_checksum_help(struct sk_buff *skb)
> +{
> +       return __skb_checksum_help(skb, skb_rfc1624_csum);
> +}
>  EXPORT_SYMBOL(skb_checksum_help);
>
>  __be16 skb_network_protocol(struct sk_buff *skb, int *depth)
> --
> 2.7.4
>
