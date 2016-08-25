From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next v1] gso: Support partial splitting at the
 frag_list pointer
Date: Thu, 25 Aug 2016 09:02:33 -0700
Message-ID: <CAKgT0UdoGQf6ZS2Ew4nuZdx5C5w-Z=P0HQZDxejrE67Fwen++w@mail.gmail.com>
References: <20160823052030.GI3735@gauss.secunet.com> <CAKgT0UdATK8LUiTQ3sn0nrJTtk9oo29k7CrNdZavsPie_Pte0w@mail.gmail.com>
 <20160824093226.GN3735@gauss.secunet.com> <CAKgT0Ucp_M-oCDjvi2Aay=aNBTH=-sGEVxUgq0b=5KrX8j3O9Q@mail.gmail.com>
 <20160825110019.GR3735@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:35441 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755944AbcHYQCf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 12:02:35 -0400
Received: by mail-it0-f45.google.com with SMTP id x131so279980288ite.0
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 09:02:34 -0700 (PDT)
In-Reply-To: <20160825110019.GR3735@gauss.secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 25, 2016 at 4:00 AM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> On Wed, Aug 24, 2016 at 09:27:54AM -0700, Alexander Duyck wrote:
>>
>> In you case though we maybe be able to make this easier.  If I am not
>> mistaken I believe we should have the main skb, and any in the chain
>> excluding the last containing the same amount of data.
>
> Yes, it seems to be like that. With this observation we can spmplify
> things.
>
>> That being the
>> case we should be able to determine the size that you would need to
>> segment at by taking skb->len, and removing the length of all the
>> skbuffs hanging off of frag_list.  At that point you just use that as
>> your MSS for segmentation and it should break things up so that you
>> have a series of equal sized segments split as the frag_list buffer
>> boundaries.
>>
>> After that all that is left is to update the gso info for the buffers.
>> For GSO_PARTIAL I was handling that on the first segment only.  For
>> this change you would need to update that code to address the fact
>> that you would have to determine the number of segments on the first
>> frame and the last since the last could be less than the first, but
>> all of the others in-between should have the same number of segments.
>
> I tried to do this and ended up with the patch below.
> Seems to work, but sill needs some tests. So it is
> not an official patch submission.
>
> Subject: [PATCH net-next RFC] gso: Support partial splitting at the frag_list pointer
>
> Since commit 8a29111c7 ("net: gro: allow to build full sized skb")
> gro may build buffers with a frag_list. This can hurt forwarding
> because most NICs can't offload such packets, they need to be
> segmented in software. This patch splits buffers with a frag_list
> at the frag_list pointer into buffers that can be TSO offloaded.
>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  net/core/skbuff.c      | 46 ++++++++++++++++++++++++++++++++++++----------
>  net/ipv4/af_inet.c     |  6 ++++--
>  net/ipv4/gre_offload.c |  4 +++-
>  net/ipv4/tcp_offload.c |  3 +++
>  net/ipv4/udp_offload.c |  6 ++++--
>  net/ipv6/ip6_offload.c |  5 ++++-
>  6 files changed, 54 insertions(+), 16 deletions(-)
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 3864b4b6..cb326e5 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3060,6 +3060,7 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
>         unsigned int offset = doffset;
>         unsigned int tnl_hlen = skb_tnl_header_len(head_skb);
>         unsigned int partial_segs = 0;
> +       unsigned int fraglist_segs = 0;
>         unsigned int headroom;
>         unsigned int len = head_skb->len;
>         __be16 proto;
> @@ -3078,16 +3079,27 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
>         sg = !!(features & NETIF_F_SG);
>         csum = !!can_checksum_protocol(features, proto);
>
> -       /* GSO partial only requires that we trim off any excess that
> -        * doesn't fit into an MSS sized block, so take care of that
> -        * now.
> -        */
> -       if (sg && csum && (features & NETIF_F_GSO_PARTIAL)) {
> -               partial_segs = len / mss;
> -               if (partial_segs > 1)
> -                       mss *= partial_segs;
> -               else
> -                       partial_segs = 0;
> +       if (sg && csum) {
> +               /* GSO partial only requires that we trim off any excess that
> +                * doesn't fit into an MSS sized block, so take care of that
> +                * now.
> +                */
> +               if ((features & NETIF_F_GSO_PARTIAL)) {
> +                       partial_segs = len / mss;
> +                       if (partial_segs > 1)
> +                               mss *= partial_segs;
> +                       else
> +                               partial_segs = 0;
> +               } else if (list_skb && (mss != GSO_BY_FRAGS) &&
> +                          net_gso_ok(features, skb_shinfo(head_skb)->gso_type)) {

It might be worthwhile to declare your own skb pointer in here instead
of reusing segs.  That way you can avoid having it initialized on the
stack and then being overwritten here.

> +
> +                       skb_walk_frags(head_skb, segs) {
> +                               len -= segs->len;
> +                       }

One thought I had is that you may want to add a check here to make
certain that the skb frags have a headlen of 0.  If they don't you
would probably need to bail.

Also a comment on the assumption that no skb will have more page frags
than the first might be useful to explain this for anyone that has to
look into this in the future.

> +                       fraglist_segs = len / mss;
> +                       mss = len;

There are a few things here that need to be verified.  First you
should probably verify that fralist_segs is >= 2.  If not we might as
well just bail since there is no advantage to segmenting frames in
this approach if the segments per resultant frame is just 1.  Also you
may wan to use "mss *= fraglist_segs".  In most cases it should be the
same as len, but in the unlikely event that there is some extra data
that was added to skb->head it should round us down to even MSS sized
chunks.

> +                       segs = NULL;
> +               }
>         }
>
>         headroom = skb_headroom(head_skb);
> @@ -3298,6 +3310,20 @@ perform_csum_check:
>                 SKB_GSO_CB(segs)->data_offset = skb_headroom(segs) + doffset;
>         }
>
> +       if (fraglist_segs) {
> +               struct sk_buff *iter;
> +
> +               for (iter = segs; iter; iter = iter->next) {
> +                       if (iter->next) {
> +                               skb_shinfo(iter)->gso_size = skb_shinfo(head_skb)->gso_size;
> +                               skb_shinfo(iter)->gso_segs = fraglist_segs;
> +                       } else {
> +                               skb_shinfo(iter)->gso_size = skb_shinfo(head_skb)->gso_size;
> +                               skb_shinfo(iter)->gso_segs = iter->len / skb_shinfo(head_skb)->gso_size;
> +                       }
> +               }
> +       }
> +
>         /* Following permits correct backpressure, for protocols
>          * using skb_set_owner_w().
>          * Idea is to tranfert ownership from head_skb to last segment.
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 989a362..ac46233 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1190,7 +1190,7 @@ EXPORT_SYMBOL(inet_sk_rebuild_header);
>  struct sk_buff *inet_gso_segment(struct sk_buff *skb,
>                                  netdev_features_t features)
>  {
> -       bool udpfrag = false, fixedid = false, encap;
> +       bool udpfrag = false, fixedid = false, gso_partial, encap;
>         struct sk_buff *segs = ERR_PTR(-EINVAL);
>         const struct net_offload *ops;
>         unsigned int offset = 0;
> @@ -1243,6 +1243,8 @@ struct sk_buff *inet_gso_segment(struct sk_buff *skb,
>         if (IS_ERR_OR_NULL(segs))
>                 goto out;
>
> +       gso_partial = !!(skb_shinfo(segs)->gso_type & SKB_GSO_PARTIAL);
> +
>         skb = segs;
>         do {
>                 iph = (struct iphdr *)(skb_mac_header(skb) + nhoff);
> @@ -1252,7 +1254,7 @@ struct sk_buff *inet_gso_segment(struct sk_buff *skb,
>                                 iph->frag_off |= htons(IP_MF);
>                         offset += skb->len - nhoff - ihl;
>                         tot_len = skb->len - nhoff;
> -               } else if (skb_is_gso(skb)) {
> +               } else if (skb_is_gso(skb) && gso_partial) {
>                         if (!fixedid) {
>                                 iph->id = htons(id);
>                                 id += skb_shinfo(skb)->gso_segs;
> diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
> index ecd1e09..7c56785 100644
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

Yeah, like Marcelo said this value is unused so you dropped some code somewhere.

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

Maybe we should just merge the code for this with GSO_PARTIAL which
has something similar a few lines up.

What you could do is just update mss like so:
    if (skb_is_gso(segs))
        mss *= skb_shinfo(segs)->gso_segs;

Then we have both the GSO_PARTIAL and your case covered.

> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index 81f253b..0b909f9 100644
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
> +               if (skb_is_gso(skb) && gso_partial) {
>                         uh->len = htons(skb_shinfo(skb)->gso_size +
>                                         SKB_GSO_CB(skb)->data_offset +
>                                         skb->head - (unsigned char *)uh);

It might be worth while to reverse these checks.  You can probably
save a few cycles if you check for gso_partial first and then
skb_is_gso instead of the current ordering.

> diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
> index 22e90e5..73dd0d1 100644
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
> +               if (skb_is_gso(skb) && gso_partial)
>                         payload_len = skb_shinfo(skb)->gso_size +
>                                       SKB_GSO_CB(skb)->data_offset +
>                                       skb->head - (unsigned char *)(ipv6h + 1);
> --
> 1.9.1
>
