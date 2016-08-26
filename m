From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next v1] gso: Support partial splitting at the
 frag_list pointer
Date: Fri, 26 Aug 2016 13:45:56 -0700
Message-ID: <CAKgT0UcYLrx1PzKo6Lw-rHGOj-1wMO2dP-93Brs7EGY-OFR4Gw@mail.gmail.com>
References: <20160823052030.GI3735@gauss.secunet.com> <CAKgT0UdATK8LUiTQ3sn0nrJTtk9oo29k7CrNdZavsPie_Pte0w@mail.gmail.com>
 <20160824093226.GN3735@gauss.secunet.com> <CAKgT0Ucp_M-oCDjvi2Aay=aNBTH=-sGEVxUgq0b=5KrX8j3O9Q@mail.gmail.com>
 <20160825110019.GR3735@gauss.secunet.com> <20160826233621.0230ee44@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
        Netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:38167 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751554AbcHZUp5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 16:45:57 -0400
Received: by mail-it0-f52.google.com with SMTP id g62so11403193ith.1
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 13:45:57 -0700 (PDT)
In-Reply-To: <20160826233621.0230ee44@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 26, 2016 at 1:36 PM, Shmulik Ladkani
<shmulik.ladkani@gmail.com> wrote:
> Hi,
>
> On Thu, 25 Aug 2016 13:00:19 +0200 Steffen Klassert <steffen.klassert@secunet.com> wrote:
>> On Wed, Aug 24, 2016 at 09:27:54AM -0700, Alexander Duyck wrote:
>> > That being the
>> > case we should be able to determine the size that you would need to
>> > segment at by taking skb->len, and removing the length of all the
>> > skbuffs hanging off of frag_list.  At that point you just use that as
>> > your MSS for segmentation and it should break things up so that you
>> > have a series of equal sized segments split as the frag_list buffer
>> > boundaries.
>> >
>> > After that all that is left is to update the gso info for the buffers.
>> > For GSO_PARTIAL I was handling that on the first segment only.  For
>> > this change you would need to update that code to address the fact
>> > that you would have to determine the number of segments on the first
>> > frame and the last since the last could be less than the first, but
>> > all of the others in-between should have the same number of segments.
>>
>> I tried to do this and ended up with the patch below.
>
> Nice idea.
>
> Still I'm missing something here, appreciate if you can explain.
>
> We initially split the original head_skb to "big" skbs per the frag_list
> boundaries (in a way similar to the SKB_GSO_PARTIAL trick).
>
> Then we reassign gso_size (and gso_segs) for each seg skb, to be the
> original gso_size specified in the head_skb.
>
> So if they go for TSO (for devices doing NETIF_F_SG), each skb will be
> split to mss segments by the device.
>
> However, if TSO is off, but GSO is on, who takes care of further
> splitting these skbs according to their gso_size?

I believe the patch resolves it via the net_gso_ok check.  This is
used to verify if the lower device could segment it if we split out
the buffers from skb->frag_list.

> And another question:
> Can this be utilized in any way to solve the problem described in [1] ?
>
> Thanks
> Shmulik
>
> [1] https://patchwork.ozlabs.org/patch/661419/

I don't think so.  This solution is to only do part of the software
offload and still make use of an existing hardware offload.

The problem in item 1 is that you are wanting to fragment a frame that
has to also be segmented.  Really in order to make something like that
work you would have to do two passes.  One for the segmentation and
another for the fragmentation.  The fact that GSO is already used to
handle UDP fragmentation offload makes this a bit trickier since it
means you would have to pass the frame through the same software
offload stack twice.

- Alex
