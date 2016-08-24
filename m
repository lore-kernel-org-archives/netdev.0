From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next v1] gso: Support partial splitting at the
 frag_list pointer
Date: Wed, 24 Aug 2016 11:32:27 +0200
Message-ID: <20160824093226.GN3735@gauss.secunet.com>
References: <20160823052030.GI3735@gauss.secunet.com>
 <CAKgT0UdATK8LUiTQ3sn0nrJTtk9oo29k7CrNdZavsPie_Pte0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:53545 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754337AbcHXJcc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 Aug 2016 05:32:32 -0400
Content-Disposition: inline
In-Reply-To: <CAKgT0UdATK8LUiTQ3sn0nrJTtk9oo29k7CrNdZavsPie_Pte0w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 23, 2016 at 07:47:32AM -0700, Alexander Duyck wrote:
> On Mon, Aug 22, 2016 at 10:20 PM, Steffen Klassert
> <steffen.klassert@secunet.com> wrote:
> > Since commit 8a29111c7 ("net: gro: allow to build full sized skb")
> > gro may build buffers with a frag_list. This can hurt forwarding
> > because most NICs can't offload such packets, they need to be
> > segmented in software. This patch splits buffers with a frag_list
> > at the frag_list pointer into buffers that can be TSO offloaded.
> >
> > Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> > ---
> >  net/core/skbuff.c      | 89 +++++++++++++++++++++++++++++++++++++++++++++++++-
> >  net/ipv4/af_inet.c     |  7 ++--
> >  net/ipv4/gre_offload.c |  7 +++-
> >  net/ipv4/tcp_offload.c |  3 ++
> >  net/ipv4/udp_offload.c |  9 +++--
> >  net/ipv6/ip6_offload.c |  6 +++-
> >  6 files changed, 114 insertions(+), 7 deletions(-)
> >
> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > index 3864b4b6..a614e9d 100644
> > --- a/net/core/skbuff.c
> > +++ b/net/core/skbuff.c
> > @@ -3078,6 +3078,92 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
> >         sg = !!(features & NETIF_F_SG);
> >         csum = !!can_checksum_protocol(features, proto);
> >
> > +       headroom = skb_headroom(head_skb);
> > +
> > +       if (list_skb && net_gso_ok(features, skb_shinfo(head_skb)->gso_type) &&
> > +           csum && sg && (mss != GSO_BY_FRAGS) &&
> > +           !(features & NETIF_F_GSO_PARTIAL)) {
> 
> Does this really need to be mutually exclusive with
> NETIF_F_GSO_PARTIAL and GSO_BY_FRAGS? 

It should be possible to extend this to NETIF_F_GSO_PARTIAL but
I have no test for this. Regarding GSO_BY_FRAGS, this is rather
new and just used for sctp. I don't know what sctp does with
GSO_BY_FRAGS.

> This is occurring early enough
> that maybe instead of doubling the size of skb_segment you should look
> at instead adding a new static function that could handle splitting
> the frag_list and just call that instead of adding this massive amount
> of code.

Ok, will do that.

> 
> Some of these checks are more expensive than others.  I would
> recommend doing the sg && csum && !(features & NETIF_F_GSO_PARTIAL)
> checks first.  If possible you could even combine some of the checks
> since they are also in the block that sets up partial_segs.  That way
> we can cut down on the total number of conditional branches needed.

We can combine the sg && csum check in the block that sets up partial_segs.
In case this is not NETIF_F_GSO_PARTIAL, I'll do the list_skb and
net_gso_ok() check and call the new static function then.

> >
> > +       if (skb_shinfo(segs)->gso_type & SKB_GSO_PARTIAL)
> > +               gso_partial = true;
> > +
> 
> For these kind of blocks it is usually best to just do:
>     gso_partial = !!(skb_shinfo(segs)->gso_type & SKB_GSO_PARTIAL);
> 
> The compiler usually does a better job of just doing a bit of
> arithmetic instead of generating a set of test/jump type instructions
> and generally that runs faster since there is less branching.  The
> same applies to all the other cases where you setup gso_partial this
> way.

Good point, I'll change this.

Thanks for the review!
