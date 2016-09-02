From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next v2] gso: Support partial splitting at the
 frag_list pointer
Date: Fri, 2 Sep 2016 06:57:22 -0700
Message-ID: <CAKgT0UersGR-01odVJPFv+E150mYh5oyB7FN8nJunsUtAm3rhQ@mail.gmail.com>
References: <20160831104128.GE3735@gauss.secunet.com> <CAKgT0UcnkRdjo2oeL_G_JAWk9RpFEhpqG-oYZG7Z70Yb_KwbfQ@mail.gmail.com>
 <20160902072533.GG3735@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:35096 "EHLO
        mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752328AbcIBN5Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 09:57:24 -0400
Received: by mail-it0-f51.google.com with SMTP id e124so37824658ith.0
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 06:57:24 -0700 (PDT)
In-Reply-To: <20160902072533.GG3735@gauss.secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 2, 2016 at 12:25 AM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> On Wed, Aug 31, 2016 at 10:25:59AM -0700, Alexander Duyck wrote:
>> On Wed, Aug 31, 2016 at 3:41 AM, Steffen Klassert
>> <steffen.klassert@secunet.com> wrote:
>> >
>> > -       /* GSO partial only requires that we trim off any excess that
>> > -        * doesn't fit into an MSS sized block, so take care of that
>> > -        * now.
>> > -        */
>> > -       if (sg && csum && (features & NETIF_F_GSO_PARTIAL)) {
>> > -               partial_segs = len / mss;
>> > -               if (partial_segs > 1)
>> > -                       mss *= partial_segs;
>> > -               else
>> > -                       partial_segs = 0;
>> > +       if (sg && csum) {
>>
>> Actually you could also put the && (mss != GSO_BY_FRAGS) test up here
>> as well.  The GSO_PARTIAL code doesn't make any sense if we are
>> segmenting by frags.
>>
>
> Ok, we can do that.
>
>> > +               /* GSO partial only requires that we trim off any excess that
>> > +                * doesn't fit into an MSS sized block, so take care of that
>> > +                * now.
>> > +                */
>> > +               if ((features & NETIF_F_GSO_PARTIAL)) {
>> > +                       partial_segs = len / mss;
>> > +                       if (partial_segs > 1)
>> > +                               mss *= partial_segs;
>> > +                       else
>> > +                               partial_segs = 0;
>> > +               } else if (list_skb && (mss != GSO_BY_FRAGS) &&
>> > +                          net_gso_ok(features, skb_shinfo(head_skb)->gso_type)) {
>> > +                       struct sk_buff *iter;
>>
>> Actually I think we have the ordering backwards here by a little bit.
>> What we should probably be doing is your test for list_skb and such
>> first and then checking for GSO_PARTIAL.  If I am not mistaken we
>> could end up with a situation where we have buffers with a frag_list
>> that need to be partially segmented.
>
> Hm, when I look at __skb_gso_segment(), you remove NETIF_F_GSO_PARTIAL
> from features if skb_gso_ok() returns false. So you do GSO partial only
> if this buffer has no fraglist or if NETIF_F_FRAGLIST is set. This
> means that we either don't need or don't want to do the fraglist
> splitting in the GSO partial case.

Well I think all it would take to allow it though would be to replace
skb_gso_ok with net_gso_ok, but now that I am aware that we are taking
steps to prevent both firing a the same time we can hold off on that
for now.

>> Also I think we can merge
>> partial_segs and fraglist_segs into one thing.
>
> Given that my assumption above is true, we could check
> !(features & NETIF_F_GSO_PARTIAL). Then I do my stuff
> if needed and then we do what's needed in both cases.

Right.  That is kind of what I was thinking.  I think I call out
something like that in some example code below.

>>
>> > +
>> > +                       /* Split the buffer at the frag_list pointer. This is
>> > +                        * based on the assumption that all buffers in the chain
>> > +                        * excluding the last containing the same amount of data.
>> > +                        */
>> > +                       skb_walk_frags(head_skb, iter) {
>> > +                               if (skb_headlen(iter))
>> > +                                       goto normal;
>> > +
>> > +                               len -= iter->len;
>> > +                       }
>>
>> What you could probably do here is actually have a goto that jumps
>> into the code for NETIF_F_GSO_PARTIAL.  If we do that then these two
>> paths are mostly merged.
>>
>> > +                       fraglist_segs = len / mss;
>> > +                       if (fraglist_segs > 1)
>> > +                               mss *= fraglist_segs;
>> > +                       else
>> > +                               fraglist_segs = 0;
>> > +               }
>> >         }
>> >
>> > +normal:
>> >         headroom = skb_headroom(head_skb);
>> >         pos = skb_headlen(head_skb);
>> >
>>
>> So one bit I can think of that might be an issue if we have to do both
>> this and GSO_PARTIAL is that we might end up with a last chunk that
>> has to be segmented twice, once to get rid of frag_list and again to
>> trim the end piece off so that we are are evenly MSS aligned.
>
> As said above, I currently don't think that this can happen.

You are correct.  I didn't realize I was using skb_gso_ok instead of
net_gso_ok.  So we can fork some of this off into a separate patch for
later.  I can probably look into it when I have time.

>>
>> > @@ -3298,6 +3321,19 @@ perform_csum_check:
>> >                 SKB_GSO_CB(segs)->data_offset = skb_headroom(segs) + doffset;
>> >         }
>> >
>> > +       if (fraglist_segs) {
>> > +               struct sk_buff *iter;
>> > +
>> > +               for (iter = segs; iter; iter = iter->next) {
>> > +                       skb_shinfo(iter)->gso_size = skb_shinfo(head_skb)->gso_size;
>> > +
>> > +                       if (iter->next)
>> > +                               skb_shinfo(iter)->gso_segs = fraglist_segs;
>> > +                       else
>> > +                               skb_shinfo(iter)->gso_segs = iter->len / skb_shinfo(head_skb)->gso_size;
>>
>> It might be faster to just set gso_segs to fraglist_segs in every
>> iteration of the loop, and then outside of the loop you could update
>> the tail skb.  It will save the effort of a test and jump which should
>> be a few cycles per iteration.  Also you will probably need to fixup
>> gso_size for the tail segment.  If the length less than or equal to
>> gso_size then you need to drop gso_size to 0, otherwise you update
>> gso_segs.  Also I am pretty sure you will want to use a DIV_ROUND_UP
>> logic for the segments since you want to reflect the actual packet
>> count.
>>
>> Also this is still doing the same thing as I do at the end of the loop
>> in the conditional section for partial segs.  What we may want to do
>> is just tweak the bits I have in that block with a check that is
>> something along the lines of:
>>                 /* Update type to add partial and then remove dodgy if set */
>>                 type |= (features & NETIF_F_GSO_PARTIAL) /
>> NETIF_F_GSO_PARTIAL * SKB_GSO_PARTIAL;
>>                 type &= ~SKB_GSO_DODGY;
>>
>> That bit of code is just a fancy way of setting the SKB_GSO_PARTIAL
>> bit only if the NETIF_F_GSO_PARTIAL feature bit is set.  Since we can
>> avoid conditional jumps that way it usually runs faster since it is
>> just an AND, SHIFT, and OR and I don't have any CPU flags to worry
>> about.  Once you have type recorded you could just set the 4 values I
>> do in your loop and then fixup the last one.
>
> OK, sounds reasonable.
>
