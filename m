From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next v1] gso: Support partial splitting at the
 frag_list pointer
Date: Tue, 23 Aug 2016 07:47:32 -0700
Message-ID: <CAKgT0UdATK8LUiTQ3sn0nrJTtk9oo29k7CrNdZavsPie_Pte0w@mail.gmail.com>
References: <20160823052030.GI3735@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33746 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754667AbcHWOre (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 10:47:34 -0400
Received: by mail-it0-f68.google.com with SMTP id d65so8269195ith.0
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 07:47:34 -0700 (PDT)
In-Reply-To: <20160823052030.GI3735@gauss.secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 22, 2016 at 10:20 PM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> Since commit 8a29111c7 ("net: gro: allow to build full sized skb")
> gro may build buffers with a frag_list. This can hurt forwarding
> because most NICs can't offload such packets, they need to be
> segmented in software. This patch splits buffers with a frag_list
> at the frag_list pointer into buffers that can be TSO offloaded.
>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  net/core/skbuff.c      | 89 +++++++++++++++++++++++++++++++++++++++++++++++++-
>  net/ipv4/af_inet.c     |  7 ++--
>  net/ipv4/gre_offload.c |  7 +++-
>  net/ipv4/tcp_offload.c |  3 ++
>  net/ipv4/udp_offload.c |  9 +++--
>  net/ipv6/ip6_offload.c |  6 +++-
>  6 files changed, 114 insertions(+), 7 deletions(-)
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 3864b4b6..a614e9d 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3078,6 +3078,92 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
>         sg = !!(features & NETIF_F_SG);
>         csum = !!can_checksum_protocol(features, proto);
>
> +       headroom = skb_headroom(head_skb);
> +
> +       if (list_skb && net_gso_ok(features, skb_shinfo(head_skb)->gso_type) &&
> +           csum && sg && (mss != GSO_BY_FRAGS) &&
> +           !(features & NETIF_F_GSO_PARTIAL)) {

Does this really need to be mutually exclusive with
NETIF_F_GSO_PARTIAL and GSO_BY_FRAGS?  This is occurring early enough
that maybe instead of doubling the size of skb_segment you should look
at instead adding a new static function that could handle splitting
the frag_list and just call that instead of adding this massive amount
of code.

Some of these checks are more expensive than others.  I would
recommend doing the sg && csum && !(features & NETIF_F_GSO_PARTIAL)
checks first.  If possible you could even combine some of the checks
since they are also in the block that sets up partial_segs.  That way
we can cut down on the total number of conditional branches needed.

> +               unsigned int lskb_segs;
> +               unsigned int delta_segs, delta_len, delta_truesize;
> +               struct sk_buff *nskb;
> +               delta_segs = delta_len = delta_truesize = 0;
> +
> +               segs = __alloc_skb(skb_headlen(head_skb) + headroom,
> +                                  GFP_ATOMIC, skb_alloc_rx_flag(head_skb),
> +                                  NUMA_NO_NODE);
> +               if (unlikely(!segs))
> +                       return ERR_PTR(-ENOMEM);
> +
> +               skb_reserve(segs, headroom);
> +               skb_put(segs, skb_headlen(head_skb));
> +               skb_copy_from_linear_data(head_skb, segs->data, segs->len);
> +               copy_skb_header(segs, head_skb);
> +
> +               if (skb_shinfo(head_skb)->nr_frags) {
> +                       int i;
> +
> +                       if (skb_orphan_frags(head_skb, GFP_ATOMIC))
> +                               goto err;
> +
> +                       for (i = 0; i < skb_shinfo(head_skb)->nr_frags; i++) {
> +                               skb_shinfo(segs)->frags[i] = skb_shinfo(head_skb)->frags[i];
> +                               skb_frag_ref(head_skb, i);
> +                       }
> +                       skb_shinfo(segs)->nr_frags = i;
> +               }
> +
> +               do {
> +                       nskb = skb_clone(list_skb, GFP_ATOMIC);
> +                       if (unlikely(!nskb))
> +                               goto err;
> +
> +                       list_skb = list_skb->next;
> +
> +                       if (!tail)
> +                               segs->next = nskb;
> +                       else
> +                               tail->next = nskb;
> +
> +                       tail = nskb;
> +
> +                       if (skb_cow_head(nskb, doffset + headroom))
> +                               goto err;
> +
> +                       lskb_segs = nskb->len / mss;
> +
> +                       skb_shinfo(nskb)->gso_size = mss;
> +                       skb_shinfo(nskb)->gso_type = skb_shinfo(head_skb)->gso_type;
> +                       skb_shinfo(nskb)->gso_segs = lskb_segs;
> +
> +
> +                       delta_segs += lskb_segs;
> +                       delta_len += nskb->len;
> +                       delta_truesize += nskb->truesize;
> +
> +                       __skb_push(nskb, doffset);
> +
> +                       skb_release_head_state(nskb);
> +                       __copy_skb_header(nskb, head_skb);
> +
> +                       skb_headers_offset_update(nskb, skb_headroom(nskb) - headroom);
> +                       skb_reset_mac_len(nskb);
> +
> +                       skb_copy_from_linear_data_offset(head_skb, -tnl_hlen,
> +                                                        nskb->data - tnl_hlen,
> +                                                        doffset + tnl_hlen);
> +
> +               } while (list_skb);
> +
> +               skb_shinfo(segs)->gso_segs -= delta_segs;
> +               segs->len = head_skb->len - delta_len;
> +               segs->data_len = head_skb->data_len - delta_len;
> +               segs->truesize += head_skb->data_len - delta_truesize;
> +
> +               segs->prev = tail;
> +
> +               goto out;
> +       }
> +
>         /* GSO partial only requires that we trim off any excess that
>          * doesn't fit into an MSS sized block, so take care of that
>          * now.
> @@ -3090,7 +3176,6 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
>                         partial_segs = 0;
>         }
>
> -       headroom = skb_headroom(head_skb);
>         pos = skb_headlen(head_skb);
>
>         do {
> @@ -3307,6 +3392,8 @@ perform_csum_check:
>                 swap(tail->destructor, head_skb->destructor);
>                 swap(tail->sk, head_skb->sk);
>         }
> +
> +out:
>         return segs;
>
>  err:
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 55513e6..c814afa 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1195,7 +1195,7 @@ EXPORT_SYMBOL(inet_sk_rebuild_header);
>  struct sk_buff *inet_gso_segment(struct sk_buff *skb,
>                                  netdev_features_t features)
>  {
> -       bool udpfrag = false, fixedid = false, encap;
> +       bool udpfrag = false, fixedid = false, gso_partial = false, encap;
>         struct sk_buff *segs = ERR_PTR(-EINVAL);
>         const struct net_offload *ops;
>         unsigned int offset = 0;
> @@ -1248,6 +1248,9 @@ struct sk_buff *inet_gso_segment(struct sk_buff *skb,
>         if (IS_ERR_OR_NULL(segs))
>                 goto out;
>
> +       if (skb_shinfo(segs)->gso_type & SKB_GSO_PARTIAL)
> +               gso_partial = true;
> +

For these kind of blocks it is usually best to just do:
    gso_partial = !!(skb_shinfo(segs)->gso_type & SKB_GSO_PARTIAL);

The compiler usually does a better job of just doing a bit of
arithmetic instead of generating a set of test/jump type instructions
and generally that runs faster since there is less branching.  The
same applies to all the other cases where you setup gso_partial this
way.

>         skb = segs;
>         do {
>                 iph = (struct iphdr *)(skb_mac_header(skb) + nhoff);
> @@ -1257,7 +1260,7 @@ struct sk_buff *inet_gso_segment(struct sk_buff *skb,
>                                 iph->frag_off |= htons(IP_MF);
>                         offset += skb->len - nhoff - ihl;
>                         tot_len = skb->len - nhoff;
> -               } else if (skb_is_gso(skb)) {
> +               } else if (skb_is_gso(skb) && gso_partial) {
>                         if (!fixedid) {
>                                 iph->id = htons(id);
>                                 id += skb_shinfo(skb)->gso_segs;
> diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
> index ecd1e09..cf82e28 100644
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
> @@ -69,6 +69,11 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
>                 goto out;
>         }
>
> +       if (skb_shinfo(segs)->gso_type & SKB_GSO_PARTIAL)
> +               gso_partial = true;
> +       else
> +               gso_partial = false;
> +
>         outer_hlen = skb_tnl_header_len(skb);
>         gre_offset = outer_hlen - tnl_hlen;
>         skb = segs;
> diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
> index 5c59649..dddd227 100644
> --- a/net/ipv4/tcp_offload.c
> +++ b/net/ipv4/tcp_offload.c
> @@ -107,6 +107,9 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
>
>         /* Only first segment might have ooo_okay set */
>         segs->ooo_okay = ooo_okay;
> +       if (skb_is_gso(segs) && !(skb_shinfo(segs)->gso_type & SKB_GSO_PARTIAL))
> +               mss = (skb_tail_pointer(segs) - skb_transport_header(segs)) +
> +                      segs->data_len - thlen;
>
>         delta = htonl(oldlen + (thlen + mss));
>
> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index 81f253b..dfb6a2c 100644
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
> @@ -88,6 +88,11 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
>                 goto out;
>         }
>
> +       if (skb_shinfo(segs)->gso_type & SKB_GSO_PARTIAL)
> +               gso_partial = true;
> +       else
> +               gso_partial = false;
> +
>         outer_hlen = skb_tnl_header_len(skb);
>         udp_offset = outer_hlen - tnl_hlen;
>         skb = segs;
> @@ -117,7 +122,7 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
>                  * will be using a length value equal to only one MSS sized
>                  * segment instead of the entire frame.
>                  */
> -               if (skb_is_gso(skb)) {
> +               if (skb_is_gso(skb) && gso_partial) {
>                         uh->len = htons(skb_shinfo(skb)->gso_size +
>                                         SKB_GSO_CB(skb)->data_offset +
>                                         skb->head - (unsigned char *)uh);
> diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
> index 22e90e5..0ec16ba 100644
> --- a/net/ipv6/ip6_offload.c
> +++ b/net/ipv6/ip6_offload.c
> @@ -69,6 +69,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
>         int offset = 0;
>         bool encap, udpfrag;
>         int nhoff;
> +       bool gso_partial = false;
>
>         skb_reset_network_header(skb);
>         nhoff = skb_network_header(skb) - skb_mac_header(skb);
> @@ -101,9 +102,12 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
>         if (IS_ERR(segs))
>                 goto out;
>
> +       if (skb_shinfo(segs)->gso_type & SKB_GSO_PARTIAL)
> +               gso_partial = true;
> +
>         for (skb = segs; skb; skb = skb->next) {
>                 ipv6h = (struct ipv6hdr *)(skb_mac_header(skb) + nhoff);
> -               if (skb_is_gso(skb))
> +               if (skb_is_gso(skb) && gso_partial)
>                         payload_len = skb_shinfo(skb)->gso_size +
>                                       SKB_GSO_CB(skb)->data_offset +
>                                       skb->head - (unsigned char *)(ipv6h + 1);
> --
> 1.9.1
>
