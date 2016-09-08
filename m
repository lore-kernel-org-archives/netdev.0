From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next v4] gso: Support partial splitting at the
 frag_list pointer
Date: Thu, 8 Sep 2016 08:37:47 -0700
Message-ID: <CAKgT0UdieQO3KM1ZdcyczsO7+uNe-fDg9=jkDg-25nuQyiG56A@mail.gmail.com>
References: <20160908113307.GT31137@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36000 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753261AbcIHPht (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 11:37:49 -0400
Received: by mail-it0-f67.google.com with SMTP id i184so4888174itf.3
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 08:37:48 -0700 (PDT)
In-Reply-To: <20160908113307.GT31137@gauss.secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 8, 2016 at 4:33 AM, Steffen Klassert
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
>  net/core/skbuff.c      | 51 +++++++++++++++++++++++++++++++++++++++-----------
>  net/ipv4/af_inet.c     | 14 ++++++++++----
>  net/ipv4/gre_offload.c |  6 ++++--
>  net/ipv4/tcp_offload.c | 13 +++++++------
>  net/ipv4/udp_offload.c |  6 ++++--
>  net/ipv6/ip6_offload.c |  5 ++++-
>  6 files changed, 69 insertions(+), 26 deletions(-)
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 3864b4b6..996e8a6 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3078,11 +3078,31 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
>         sg = !!(features & NETIF_F_SG);
>         csum = !!can_checksum_protocol(features, proto);
>
> -       /* GSO partial only requires that we trim off any excess that
> -        * doesn't fit into an MSS sized block, so take care of that
> -        * now.
> -        */
> -       if (sg && csum && (features & NETIF_F_GSO_PARTIAL)) {
> +       if (sg && csum && (mss != GSO_BY_FRAGS))  {
> +               if (!(features & NETIF_F_GSO_PARTIAL)) {
> +                       struct sk_buff *iter;
> +
> +                       if (!list_skb ||
> +                           !net_gso_ok(features, skb_shinfo(head_skb)->gso_type))
> +                               goto normal;
> +
> +                       /* Split the buffer at the frag_list pointer.
> +                        * This is based on the assumption that all
> +                        * buffers in the chain excluding the last
> +                        * containing the same amount of data.
> +                        */
> +                       skb_walk_frags(head_skb, iter) {
> +                               if (skb_headlen(iter))
> +                                       goto normal;
> +
> +                               len -= iter->len;
> +                       }
> +               }
> +
> +               /* GSO partial only requires that we trim off any excess that
> +                * doesn't fit into an MSS sized block, so take care of that
> +                * now.
> +                */
>                 partial_segs = len / mss;
>                 if (partial_segs > 1)
>                         mss *= partial_segs;
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
> +                         skb_shinfo(tail)->gso_size = 0;
> +               else
> +                       skb_shinfo(tail)->gso_segs = DIV_ROUND_UP(tail->len, gso_size);

A few minor things.

First you somehow got a couple spaces in the line before gso_size.
That is why the two lines above don't line up.

Second it occurred to me that we could have a situation where tail is
equal to segs in the case of GSO_PARTIAL with an MSS aligned frame.
To avoid doing duplicate division we might want to make the else an
"else if (tail != segs)"

Finally I think the value for the division should be tail->len -
doffset, not tail->len as we shouldn't include the header data in the
size as it might cause us to report more packets then we actually
generate.

I think that should cover all of it.  Sorry for the thrash.

- Alex
