From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next] virtio-net: invoke zerocopy callback on xmit
 path if no tx napi
Date: Tue, 22 Aug 2017 13:19:36 -0400
Message-ID: <CAF=yD-JyLEUgUgeH5TjRUj2wz9CjRkAx1HUyXRxCDyT5iHx-sg@mail.gmail.com>
References: <20170819063854.27010-1-den@klaipeden.com> <CAF=yD-LYLsQNt_5yYZ+PUwv04ZwaJUXn-YakH=tuh0TV+BG7iA@mail.gmail.com>
 <CAF=yD-LO0rP1A_hrxqx_1HYEv6qyk=Sc=D7iH7cPh2YXDm=cYQ@mail.gmail.com> <1503410668.8694.14.camel@klaipeden.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
        virtualization@lists.linux-foundation.org,
        Network Development <netdev@vger.kernel.org>
To: Koichiro Den <den@klaipeden.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:32806 "EHLO
        mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751061AbdHVRUR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 13:20:17 -0400
Received: by mail-oi0-f49.google.com with SMTP id f11so192398011oic.0
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 10:20:17 -0700 (PDT)
In-Reply-To: <1503410668.8694.14.camel@klaipeden.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> > >         /* Don't wait up for transmitted skbs to be freed. */
>> > >         if (!use_napi) {
>> > > +               if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
>> > > +                       struct ubuf_info *uarg;
>> > > +                       uarg = skb_shinfo(skb)->destructor_arg;
>> > > +                       if (uarg->callback)
>> > > +                           uarg->callback(uarg, true);
>> > > +                       skb_shinfo(skb)->destructor_arg = NULL;
>> > > +                       skb_shinfo(skb)->tx_flags &= ~SKBTX_DEV_ZEROCOPY;
>> > > +               }
>> >
>> > Instead of open coding, this can use skb_zcopy_clear.
>>
>> It is not correct to only send the zerocopy completion here, as
>> the skb will still be shared with the nic. The only safe approach
>> to notifying early is to create a copy with skb_orphan_frags_rx.
>> That will call skb_zcopy_clear(skb, false) internally. But the
>> copy will be very expensive.
> I noticed this email after my last post. I cannot not imagine how it could be
> unsafe in virtio case. Sorry could you explain a bit more?

A guest process sends a packet with MSG_ZEROCOPY to the
virtio-net device. As soon as the process receives the completion
notification, it is allowed to reuse the memory backing the packet.

A call to skb_zcopy_clear in virtio-net start_xmit will notify the
process that it is allowed to reuse the memory. But the user pages
are still linked into the skb frags and are about to be shared with
the host os.

>> Is the deadlock you refer to the case where tx interrupts are
>> disabled, so transmit completions are only handled in start_xmit
>> and somehow the socket(s) are unable to send new data? The
>> question is what is blocking them. If it is zerocopy, it may be a
>> too low optmem_max or hitting the per-user locked pages limit.
>> We may have to keep interrupts enabled when zerocopy skbs
>> are in flight.
> Even if we keep interrupts enabled, We miss the completion without start_xmit.
> And it's also likely that the next start_xmit depends on the completion itself
> as I described in my last post.
>
