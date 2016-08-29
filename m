From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next v1] gso: Support partial splitting at the
 frag_list pointer
Date: Mon, 29 Aug 2016 14:00:34 +0200
Message-ID: <20160829120034.GY3735@gauss.secunet.com>
References: <20160823052030.GI3735@gauss.secunet.com>
 <CAKgT0UdATK8LUiTQ3sn0nrJTtk9oo29k7CrNdZavsPie_Pte0w@mail.gmail.com>
 <20160824093226.GN3735@gauss.secunet.com>
 <CAKgT0Ucp_M-oCDjvi2Aay=aNBTH=-sGEVxUgq0b=5KrX8j3O9Q@mail.gmail.com>
 <20160825110019.GR3735@gauss.secunet.com>
 <CAKgT0UdoGQf6ZS2Ew4nuZdx5C5w-Z=P0HQZDxejrE67Fwen++w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:56256 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932523AbcH2MAj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 Aug 2016 08:00:39 -0400
Content-Disposition: inline
In-Reply-To: <CAKgT0UdoGQf6ZS2Ew4nuZdx5C5w-Z=P0HQZDxejrE67Fwen++w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 25, 2016 at 09:02:33AM -0700, Alexander Duyck wrote:
> On Thu, Aug 25, 2016 at 4:00 AM, Steffen Klassert
> > +
> > +                       skb_walk_frags(head_skb, segs) {
> > +                               len -= segs->len;
> > +                       }
> 
> One thought I had is that you may want to add a check here to make
> certain that the skb frags have a headlen of 0.  If they don't you
> would probably need to bail.

Why do you think we need this check? Is it because the assumption that
all excluding the last skb have the same size might be wrong in this
case?

> >
> > +       gso_partial = !!(skb_shinfo(segs)->gso_type & SKB_GSO_PARTIAL);
> > +
> >         outer_hlen = skb_tnl_header_len(skb);
> >         udp_offset = outer_hlen - tnl_hlen;
> >         skb = segs;
> > @@ -117,7 +119,7 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
> >                  * will be using a length value equal to only one MSS sized
> >                  * segment instead of the entire frame.
> >                  */
> > -               if (skb_is_gso(skb)) {
> > +               if (skb_is_gso(skb) && gso_partial) {
> >                         uh->len = htons(skb_shinfo(skb)->gso_size +
> >                                         SKB_GSO_CB(skb)->data_offset +
> >                                         skb->head - (unsigned char *)uh);
> 
> It might be worth while to reverse these checks.  You can probably
> save a few cycles if you check for gso_partial first and then
> skb_is_gso instead of the current ordering.

Maybe we can even remove the skb_is_gso check, the gso_partial
check should be sufficient.
