From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next v3] gso: Support partial splitting at the
 frag_list pointer
Date: Mon, 5 Sep 2016 10:30:44 -0700
Message-ID: <CAKgT0UftBBfe08rcHr_Z95TtDLkBq4zz_0xchn5GMpkwKs1P=Q@mail.gmail.com>
References: <20160905104738.GD31137@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33453 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934995AbcIERaq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2016 13:30:46 -0400
Received: by mail-it0-f68.google.com with SMTP id g185so9520061ith.0
        for <netdev@vger.kernel.org>; Mon, 05 Sep 2016 10:30:45 -0700 (PDT)
In-Reply-To: <20160905104738.GD31137@gauss.secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 5, 2016 at 3:47 AM, Steffen Klassert
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
>  net/core/skbuff.c      | 50 +++++++++++++++++++++++++++++++++++++++-----------
>  net/ipv4/af_inet.c     | 14 ++++++++++----
>  net/ipv4/gre_offload.c |  6 ++++--
>  net/ipv4/tcp_offload.c | 13 +++++++------
>  net/ipv4/udp_offload.c |  6 ++++--
>  net/ipv6/ip6_offload.c |  5 ++++-
>  6 files changed, 68 insertions(+), 26 deletions(-)
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 3864b4b6..f754d47 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3078,11 +3078,30 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
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
> +                       if (list_skb &&
> +                           net_gso_ok(features, skb_shinfo(head_skb)->gso_type)) {

The testing logic here is a bit off.

You need to prevent us from doing the partial_segs bit below if
NETIF_F_GSO_PARTIAL is not set and if your list_skb or net_gso_ok
tests fail.  Since as you pointed out we shouldn't ever be trying to
perform GSO_PARTIAL on a frame that has a frag_list, what you might do
is something like:
    if (!list_skb || !net_gso_ok(...))
        goto normal;

That way we don't setup partial_segs unless we are actually using it.

> +                               struct sk_buff *iter;
> +
> +                               /* Split the buffer at the frag_list pointer.
> +                                * This is based on the assumption that all
> +                                * buffers in the chain excluding the last
> +                                * containing the same amount of data.
> +                                */
> +                               skb_walk_frags(head_skb, iter) {
> +                                       if (skb_headlen(iter))
> +                                               goto normal;
> +
> +                                       len -= iter->len;
> +                               }
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
> @@ -3090,6 +3109,7 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
>                         partial_segs = 0;
>         }
>
> +normal:
>         headroom = skb_headroom(head_skb);
>         pos = skb_headlen(head_skb);
>
> @@ -3281,21 +3301,29 @@ perform_csum_check:
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
> +               if (tail->len < gso_size)

You might swap this around and just setup gso_segs on > gso_size,
either that or this needs to be "<=" instead of just "<";

> +                         skb_shinfo(tail)->gso_size = 0;
> +               else
> +                       skb_shinfo(tail)->gso_segs = DIV_ROUND_UP(tail->len, gso_size);
>         }
>
>         /* Following permits correct backpressure, for protocols
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index e94b47b..1effc98 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1192,7 +1192,7 @@ EXPORT_SYMBOL(inet_sk_rebuild_header);
>  struct sk_buff *inet_gso_segment(struct sk_buff *skb,
>                                  netdev_features_t features)
>  {
> -       bool udpfrag = false, fixedid = false, encap;
> +       bool udpfrag = false, fixedid = false, gso_partial, encap;
>         struct sk_buff *segs = ERR_PTR(-EINVAL);
>         const struct net_offload *ops;
>         unsigned int offset = 0;
> @@ -1245,6 +1245,8 @@ struct sk_buff *inet_gso_segment(struct sk_buff *skb,
>         if (IS_ERR_OR_NULL(segs))
>                 goto out;
>
> +       gso_partial = !!(skb_shinfo(segs)->gso_type & SKB_GSO_PARTIAL);
> +
>         skb = segs;
>         do {
>                 iph = (struct iphdr *)(skb_mac_header(skb) + nhoff);
> @@ -1259,9 +1261,13 @@ struct sk_buff *inet_gso_segment(struct sk_buff *skb,
>                                 iph->id = htons(id);
>                                 id += skb_shinfo(skb)->gso_segs;
>                         }
> -                       tot_len = skb_shinfo(skb)->gso_size +
> -                                 SKB_GSO_CB(skb)->data_offset +
> -                                 skb->head - (unsigned char *)iph;
> +
> +                       if (gso_partial)
> +                               tot_len = skb_shinfo(skb)->gso_size +
> +                                         SKB_GSO_CB(skb)->data_offset +
> +                                         skb->head - (unsigned char *)iph;
> +                       else
> +                               tot_len = skb->len - nhoff;
>                 } else {
>                         if (!fixedid)
>                                 iph->id = htons(id++);
> diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
> index ecd1e09..96e0efe 100644
> --- a/net/ipv4/gre_offload.c
> +++ b/net/ipv4/gre_offload.c
> @@ -24,7 +24,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
>         __be16 protocol = skb->protocol;
>         u16 mac_len = skb->mac_len;
>         int gre_offset, outer_hlen;
> -       bool need_csum, ufo;
> +       bool need_csum, ufo, gso_partial;
>
>         if (!skb->encapsulation)
>                 goto out;
> @@ -69,6 +69,8 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
>                 goto out;
>         }
>
> +       gso_partial = !!(skb_shinfo(segs)->gso_type & SKB_GSO_PARTIAL);
> +
>         outer_hlen = skb_tnl_header_len(skb);
>         gre_offset = outer_hlen - tnl_hlen;
>         skb = segs;
> @@ -96,7 +98,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
>                 greh = (struct gre_base_hdr *)skb_transport_header(skb);
>                 pcsum = (__sum16 *)(greh + 1);
>
> -               if (skb_is_gso(skb)) {
> +               if (gso_partial) {
>                         unsigned int partial_adj;
>
>                         /* Adjust checksum to account for the fact that
> diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
> index 5c59649..bc68da3 100644
> --- a/net/ipv4/tcp_offload.c
> +++ b/net/ipv4/tcp_offload.c
> @@ -90,12 +90,6 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
>                 goto out;
>         }
>
> -       /* GSO partial only requires splitting the frame into an MSS
> -        * multiple and possibly a remainder.  So update the mss now.
> -        */
> -       if (features & NETIF_F_GSO_PARTIAL)
> -               mss = skb->len - (skb->len % mss);
> -
>         copy_destructor = gso_skb->destructor == tcp_wfree;
>         ooo_okay = gso_skb->ooo_okay;
>         /* All segments but the first should have ooo_okay cleared */
> @@ -108,6 +102,13 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
>         /* Only first segment might have ooo_okay set */
>         segs->ooo_okay = ooo_okay;
>
> +       /* GSO partial and frag_list segmentation only requires splitting
> +        * the frame into an MSS multiple and possibly a remainder, both
> +        * cases return a GSO skb. So update the mss now.
> +        */
> +       if (skb_is_gso(segs))
> +               mss *= skb_shinfo(segs)->gso_segs;
> +
>         delta = htonl(oldlen + (thlen + mss));
>
>         skb = segs;
> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index 81f253b..f9333c9 100644
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -21,7 +21,7 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
>         __be16 new_protocol, bool is_ipv6)
>  {
>         int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
> -       bool remcsum, need_csum, offload_csum, ufo;
> +       bool remcsum, need_csum, offload_csum, ufo, gso_partial;
>         struct sk_buff *segs = ERR_PTR(-EINVAL);
>         struct udphdr *uh = udp_hdr(skb);
>         u16 mac_offset = skb->mac_header;
> @@ -88,6 +88,8 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
>                 goto out;
>         }
>
> +       gso_partial = !!(skb_shinfo(segs)->gso_type & SKB_GSO_PARTIAL);
> +
>         outer_hlen = skb_tnl_header_len(skb);
>         udp_offset = outer_hlen - tnl_hlen;
>         skb = segs;
> @@ -117,7 +119,7 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
>                  * will be using a length value equal to only one MSS sized
>                  * segment instead of the entire frame.
>                  */
> -               if (skb_is_gso(skb)) {
> +               if (gso_partial) {
>                         uh->len = htons(skb_shinfo(skb)->gso_size +
>                                         SKB_GSO_CB(skb)->data_offset +
>                                         skb->head - (unsigned char *)uh);
> diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
> index 22e90e5..e7bfd55 100644
> --- a/net/ipv6/ip6_offload.c
> +++ b/net/ipv6/ip6_offload.c
> @@ -69,6 +69,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
>         int offset = 0;
>         bool encap, udpfrag;
>         int nhoff;
> +       bool gso_partial;
>
>         skb_reset_network_header(skb);
>         nhoff = skb_network_header(skb) - skb_mac_header(skb);
> @@ -101,9 +102,11 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
>         if (IS_ERR(segs))
>                 goto out;
>
> +       gso_partial = !!(skb_shinfo(segs)->gso_type & SKB_GSO_PARTIAL);
> +
>         for (skb = segs; skb; skb = skb->next) {
>                 ipv6h = (struct ipv6hdr *)(skb_mac_header(skb) + nhoff);
> -               if (skb_is_gso(skb))
> +               if (gso_partial)
>                         payload_len = skb_shinfo(skb)->gso_size +
>                                       SKB_GSO_CB(skb)->data_offset +
>                                       skb->head - (unsigned char *)(ipv6h + 1);
> --
> 1.9.1
>
