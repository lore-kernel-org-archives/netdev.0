From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next v5] gso: Support partial splitting at the
 frag_list pointer
Date: Fri, 9 Sep 2016 08:20:55 -0700
Message-ID: <CAKgT0UdMoMUgpt2dbSc0CEX8RkCZT4d9YAqcJSGvNeL0gvLS6g@mail.gmail.com>
References: <20160909072554.GX31137@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:34359 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752933AbcIIPU5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 11:20:57 -0400
Received: by mail-oi0-f66.google.com with SMTP id a144so2534390oii.1
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 08:20:56 -0700 (PDT)
In-Reply-To: <20160909072554.GX31137@gauss.secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 9, 2016 at 12:25 AM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> Since commit 8a29111c7 ("net: gro: allow to build full sized skb")
> gro may build buffers with a frag_list. This can hurt forwarding
> because most NICs can't offload such packets, they need to be
> segmented in software. This patch splits buffers with a frag_list
> at the frag_list pointer into buffers that can be TSO offloaded.
>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>
> Changes since v1:
>
> - Use the assumption that all buffers in the chain excluding the last
>   containing the same amount of data.
>
> - Simplify some checks against gso partial.
>
> - Fix the generation of IP IDs.
>
> Changes since v2:
>
> - Merge common code of gso partial and frag_list pointer splitting.
>
> Changes since v3:
>
> - Fix the checks for doing frag_list pointer splitting.
>
> Changes since v4:
>
> - Whitespace fix.
> - Fix size calculations of the tail packet.
>
>  net/core/skbuff.c      | 51 +++++++++++++++++++++++++++++++++++++++-----------
>  net/ipv4/af_inet.c     | 14 ++++++++++----
>  net/ipv4/gre_offload.c |  6 ++++--
>  net/ipv4/tcp_offload.c | 13 +++++++------
>  net/ipv4/udp_offload.c |  6 ++++--
>  net/ipv6/ip6_offload.c |  5 ++++-
>  6 files changed, 69 insertions(+), 26 deletions(-)
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 3864b4b6..51e761a 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3078,11 +3078,31 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,

<...>

> @@ -3090,6 +3110,7 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
>                         partial_segs = 0;
>         }
>
> +normal:
>         headroom = skb_headroom(head_skb);
>         pos = skb_headlen(head_skb);
>
> @@ -3281,21 +3302,29 @@ perform_csum_check:
>          */
>         segs->prev = tail;
>
> -       /* Update GSO info on first skb in partial sequence. */
>         if (partial_segs) {
> +               struct sk_buff *iter;
>                 int type = skb_shinfo(head_skb)->gso_type;
> +               unsigned short gso_size = skb_shinfo(head_skb)->gso_size;
>
>                 /* Update type to add partial and then remove dodgy if set */
> -               type |= SKB_GSO_PARTIAL;
> +               type |= (features & NETIF_F_GSO_PARTIAL) / NETIF_F_GSO_PARTIAL * SKB_GSO_PARTIAL;
>                 type &= ~SKB_GSO_DODGY;
>
>                 /* Update GSO info and prepare to start updating headers on
>                  * our way back down the stack of protocols.
>                  */
> -               skb_shinfo(segs)->gso_size = skb_shinfo(head_skb)->gso_size;
> -               skb_shinfo(segs)->gso_segs = partial_segs;
> -               skb_shinfo(segs)->gso_type = type;
> -               SKB_GSO_CB(segs)->data_offset = skb_headroom(segs) + doffset;
> +               for (iter = segs; iter; iter = iter->next) {
> +                       skb_shinfo(iter)->gso_size = gso_size;
> +                       skb_shinfo(iter)->gso_segs = partial_segs;
> +                       skb_shinfo(iter)->gso_type = type;
> +                       SKB_GSO_CB(iter)->data_offset = skb_headroom(iter) + doffset;
> +               }
> +
> +               if (tail->len <= gso_size)
> +                       skb_shinfo(tail)->gso_size = 0;

Actually we need to do tail->len - doffset up here as well.  The
gso_size value reflects the size of the data segment, and tail->len is
the size of the entire frame so we have to remove the size of the
headers to make the comparison accurate.

> +               else if (tail != segs)
> +                       skb_shinfo(tail)->gso_segs = DIV_ROUND_UP(tail->len - doffset, gso_size);
>         }
>
>         /* Following permits correct backpressure, for protocols
