From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next v1] gso: Support partial splitting at the
 frag_list pointer
Date: Wed, 24 Aug 2016 09:27:54 -0700
Message-ID: <CAKgT0Ucp_M-oCDjvi2Aay=aNBTH=-sGEVxUgq0b=5KrX8j3O9Q@mail.gmail.com>
References: <20160823052030.GI3735@gauss.secunet.com> <CAKgT0UdATK8LUiTQ3sn0nrJTtk9oo29k7CrNdZavsPie_Pte0w@mail.gmail.com>
 <20160824093226.GN3735@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:32868 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756259AbcHXQ14 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 12:27:56 -0400
Received: by mail-it0-f65.google.com with SMTP id d65so2749920ith.0
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 09:27:55 -0700 (PDT)
In-Reply-To: <20160824093226.GN3735@gauss.secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 24, 2016 at 2:32 AM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> On Tue, Aug 23, 2016 at 07:47:32AM -0700, Alexander Duyck wrote:
>> On Mon, Aug 22, 2016 at 10:20 PM, Steffen Klassert
>> <steffen.klassert@secunet.com> wrote:
>> > Since commit 8a29111c7 ("net: gro: allow to build full sized skb")
>> > gro may build buffers with a frag_list. This can hurt forwarding
>> > because most NICs can't offload such packets, they need to be
>> > segmented in software. This patch splits buffers with a frag_list
>> > at the frag_list pointer into buffers that can be TSO offloaded.
>> >
>> > Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
>> > ---
>> >  net/core/skbuff.c      | 89 +++++++++++++++++++++++++++++++++++++++++++++++++-
>> >  net/ipv4/af_inet.c     |  7 ++--
>> >  net/ipv4/gre_offload.c |  7 +++-
>> >  net/ipv4/tcp_offload.c |  3 ++
>> >  net/ipv4/udp_offload.c |  9 +++--
>> >  net/ipv6/ip6_offload.c |  6 +++-
>> >  6 files changed, 114 insertions(+), 7 deletions(-)
>> >
>> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>> > index 3864b4b6..a614e9d 100644
>> > --- a/net/core/skbuff.c
>> > +++ b/net/core/skbuff.c
>> > @@ -3078,6 +3078,92 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
>> >         sg = !!(features & NETIF_F_SG);
>> >         csum = !!can_checksum_protocol(features, proto);
>> >
>> > +       headroom = skb_headroom(head_skb);
>> > +
>> > +       if (list_skb && net_gso_ok(features, skb_shinfo(head_skb)->gso_type) &&
>> > +           csum && sg && (mss != GSO_BY_FRAGS) &&
>> > +           !(features & NETIF_F_GSO_PARTIAL)) {
>>
>> Does this really need to be mutually exclusive with
>> NETIF_F_GSO_PARTIAL and GSO_BY_FRAGS?
>
> It should be possible to extend this to NETIF_F_GSO_PARTIAL but
> I have no test for this. Regarding GSO_BY_FRAGS, this is rather
> new and just used for sctp. I don't know what sctp does with
> GSO_BY_FRAGS.

I'm adding Marcelo as he could probably explain the GSO_BY_FRAGS
functionality better than I could since he is the original author.

If I recall GSO_BY_FRAGS does something similar to what you are doing,
although I believe it doesn't carry any data in the first buffer other
than just a header.  I believe the idea behind GSO_BY_FRAGS was to
allow for segmenting a frame at the frag_list level instead of having
it done just based on MSS.  That was the only reason why I brought it
up.

In you case though we maybe be able to make this easier.  If I am not
mistaken I believe we should have the main skb, and any in the chain
excluding the last containing the same amount of data.  That being the
case we should be able to determine the size that you would need to
segment at by taking skb->len, and removing the length of all the
skbuffs hanging off of frag_list.  At that point you just use that as
your MSS for segmentation and it should break things up so that you
have a series of equal sized segments split as the frag_list buffer
boundaries.

After that all that is left is to update the gso info for the buffers.
For GSO_PARTIAL I was handling that on the first segment only.  For
this change you would need to update that code to address the fact
that you would have to determine the number of segments on the first
frame and the last since the last could be less than the first, but
all of the others in-between should have the same number of segments.

- Alex
