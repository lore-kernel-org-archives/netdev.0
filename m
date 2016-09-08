From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next v3] gso: Support partial splitting at the
 frag_list pointer
Date: Thu, 8 Sep 2016 13:27:09 +0200
Message-ID: <20160908112708.GS31137@gauss.secunet.com>
References: <20160905104738.GD31137@gauss.secunet.com>
 <CAKgT0UftBBfe08rcHr_Z95TtDLkBq4zz_0xchn5GMpkwKs1P=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Netdev <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        "Marcelo Ricardo Leitner" <marcelo.leitner@gmail.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:43383 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759428AbcIHL1N (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 07:27:13 -0400
Content-Disposition: inline
In-Reply-To: <CAKgT0UftBBfe08rcHr_Z95TtDLkBq4zz_0xchn5GMpkwKs1P=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 05, 2016 at 10:30:44AM -0700, Alexander Duyck wrote:
> On Mon, Sep 5, 2016 at 3:47 AM, Steffen Klassert
> <steffen.klassert@secunet.com> wrote:
> > Since commit 8a29111c7 ("net: gro: allow to build full sized skb")
> > gro may build buffers with a frag_list. This can hurt forwarding
> > because most NICs can't offload such packets, they need to be
> > segmented in software. This patch splits buffers with a frag_list
> > at the frag_list pointer into buffers that can be TSO offloaded.
> >
> > Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> > ---
> >
> > Changes since v1:
> >
> > - Use the assumption that all buffers in the chain excluding the last
> >   containing the same amount of data.
> >
> > - Simplify some checks against gso partial.
> >
> > - Fix the generation of IP IDs.
> >
> > Changes since v2:
> >
> > - Merge common code of gso partial and frag_list pointer splitting.
> >
> >  net/core/skbuff.c      | 50 +++++++++++++++++++++++++++++++++++++++-----------
> >  net/ipv4/af_inet.c     | 14 ++++++++++----
> >  net/ipv4/gre_offload.c |  6 ++++--
> >  net/ipv4/tcp_offload.c | 13 +++++++------
> >  net/ipv4/udp_offload.c |  6 ++++--
> >  net/ipv6/ip6_offload.c |  5 ++++-
> >  6 files changed, 68 insertions(+), 26 deletions(-)
> >
> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > index 3864b4b6..f754d47 100644
> > --- a/net/core/skbuff.c
> > +++ b/net/core/skbuff.c
> > @@ -3078,11 +3078,30 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
> >         sg = !!(features & NETIF_F_SG);
> >         csum = !!can_checksum_protocol(features, proto);
> >
> > -       /* GSO partial only requires that we trim off any excess that
> > -        * doesn't fit into an MSS sized block, so take care of that
> > -        * now.
> > -        */
> > -       if (sg && csum && (features & NETIF_F_GSO_PARTIAL)) {
> > +       if (sg && csum && (mss != GSO_BY_FRAGS))  {
> > +               if (!(features & NETIF_F_GSO_PARTIAL)) {
> > +                       if (list_skb &&
> > +                           net_gso_ok(features, skb_shinfo(head_skb)->gso_type)) {
> 
> The testing logic here is a bit off.

Yes, apparently :-/

> 
> You need to prevent us from doing the partial_segs bit below if
> NETIF_F_GSO_PARTIAL is not set and if your list_skb or net_gso_ok
> tests fail.  Since as you pointed out we shouldn't ever be trying to
> perform GSO_PARTIAL on a frame that has a frag_list, what you might do
> is something like:
>     if (!list_skb || !net_gso_ok(...))
>         goto normal;
> 
> That way we don't setup partial_segs unless we are actually using it.

Will do that.

> > +
> > +               if (tail->len < gso_size)
> 
> You might swap this around and just setup gso_segs on > gso_size,
> either that or this needs to be "<=" instead of just "<";

Ok, I'll use "<=".
