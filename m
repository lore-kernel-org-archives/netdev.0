From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH RFC 2/2] virtio_net: enable probing for NEEDS_RESET support
Date: Tue, 29 Aug 2017 17:02:29 -0400
Message-ID: <CAF=yD-+gPOYSgq8ckJ4wt3TPQYEnnB36g=Q5G4=yfoesGc=4hA@mail.gmail.com>
References: <20170829200759.13975-1-willemdebruijn.kernel@gmail.com>
 <20170829200759.13975-3-willemdebruijn.kernel@gmail.com> <20170829231606-mutt-send-email-mst@kernel.org>
 <CAF=yD-L95x1EPKFeiPiZ2hbTzwYmDaG9O54+0tUW_4opuRKDMw@mail.gmail.com> <20170829233525-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        Jason Wang <jasowang@redhat.com>,
        virtualization@lists.linux-foundation.org,
        Willem de Bruijn <willemb@google.com>,
        virtio-dev@lists.oasis-open.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:34900 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751240AbdH2VDK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 17:03:10 -0400
Received: by mail-oi0-f65.google.com with SMTP id k77so4067840oib.2
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 14:03:10 -0700 (PDT)
In-Reply-To: <20170829233525-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+ virtio-dev

On Tue, Aug 29, 2017 at 4:38 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> On Tue, Aug 29, 2017 at 04:27:41PM -0400, Willem de Bruijn wrote:
>> On Tue, Aug 29, 2017 at 4:16 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
>> > On Tue, Aug 29, 2017 at 04:07:59PM -0400, Willem de Bruijn wrote:
>> >> From: Willem de Bruijn <willemb@google.com>
>> >>
>> >> Implement a mechanism to signal that a virtio device implements the
>> >> VIRTIO_CONFIG_S_NEEDS_RESET command.
>> >>
>> >> Testing for VIRTIO_CONFIG_S_NEEDS_RESET support by issuing the request
>> >> and verifying the reset state would require an expensive state change.
>> >>
>> >> To avoid that, add a status bit to the feature register used during
>> >> feature negotiation between host and guest.
>> >>
>> >> Set the bit for virtio-net, which supports the feature.
>> >>
>> >> Signed-off-by: Willem de Bruijn <willemb@google.com>
>> >
>> > All virtio 1 devices have the reset feature
>>
>> I don't quite follow. No device drivers implement this request currently?
>
> Depends. Spec 1.0 describes the bit and that driver can respond
> by reseting the device. You seem to do something else
> in this patchset, but as designed in 1.0 it does not seem to need
> a feature bit.

I see. So support is designed to be best effort?

The feature bit is only needed if driver support is optional.

The ack response is necessary if the device acts differently
depending on whether the reset happened. The device has
to reset its local state, too, so I think that this is needed.


>> > so maybe guest does
>> > not need this flag. Does device need it? Does device really
>> > care that guest can't recover?
>>
>> If all device drivers support it, then the flag is not needed.
>>
>> But as long as legacy device drivers can exist that do not support
>> this feature, it has to have a way of differentiating between the two.
>
> Why? Device won't set this unless it's in a bad state. In that case,
> setting the bit is harmless even if drivers ignore it.

The goal is for the device to be able to rely on the driver reset to get
to a good state even if it gets it into a bad state.

That allows it to implement optimizations that could get it into that bad
state.

In particular, in the edge case where the device performs backpressure,
takes the descriptor out of the avail ring and does not immediately post
it to the used ring.

A reset will make the guest free all delayed packets and treat any
unsent and unacknowledged as network drops. This allows the
device to indeed drop long delayed packets when they eventually
surface (e.g., leave a qdisc queue). This is of course not safe with
zerocopy packets.
