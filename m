From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [RFC PATCH 1/2] af_packet: direct dma for packet ineterface
Date: Mon, 30 Jan 2017 20:31:57 -0500
Message-ID: <CAF=yD-J_2Y4eX_iG40rKm3tgs_xr2dr-Rw=JL_OsV0TnfOKhhQ@mail.gmail.com>
References: <20170127213132.14162.82951.stgit@john-Precision-Tower-5810>
 <20170127213344.14162.59976.stgit@john-Precision-Tower-5810>
 <20170130191607.14d964e4@redhat.com> <588FB57B.1060507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, bjorn.topel@gmail.com,
        jasowang@redhat.com, ast@fb.com, alexander.duyck@gmail.com,
        john.r.fastabend@intel.com,
        Network Development <netdev@vger.kernel.org>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f196.google.com ([209.85.210.196]:36708 "EHLO
        mail-wj0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751752AbdAaBiu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 20:38:50 -0500
Received: by mail-wj0-f196.google.com with SMTP id kq3so9524413wjc.3
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 17:38:49 -0800 (PST)
In-Reply-To: <588FB57B.1060507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> V3 header formats added bulk polling via socket calls and timers
>>> used in the polling interface to return every n milliseconds. Currently,
>>> I don't see any way to support this in hardware because we can't
>>> know if the hardware is in the middle of a DMA operation or not
>>> on a slot. So when a timer fires I don't know how to advance the
>>> descriptor ring leaving empty descriptors similar to how the software
>>> ring works. The easiest (best?) route is to simply not support this.
>>
>> From a performance pov bulking is essential. Systems like netmap that
>> also depend on transferring control between kernel and userspace,
>> report[1] that they need at least bulking size 8, to amortize the overhead.

To introduce interrupt moderation, ixgbe_do_ddma only has to elide the
sk_data_ready, and schedule an hrtimer if one is not scheduled yet.

If I understand correctly, the difficulty lies in v3 requiring that the
timer "close" the block when the timer expires. That may not be worth
implementing, indeed.

Hardware interrupt moderation and napi may already give some
moderation, even with a sock_def_readable call for each packet. If
considering a v4 format, I'll again suggest virtio virtqueues. Those
have interrupt suppression built in with EVENT_IDX.

>> Likely, but I would like that we do a measurement based approach.  Lets
>> benchmark with this V2 header format, and see how far we are from
>> target, and see what lights-up in perf report and if it is something we
>> can address.
>
> Yep I'm hoping to get to this sometime this week.

Perhaps also without filling in the optional metadata data fields
in tpacket and sockaddr_ll.

>> E.g. how will you support XDP_TX?  AFAIK you cannot remove/detach a
>> packet with this solution (and place it on a TX queue and wait for DMA
>> TX completion).
>>
>
> This is something worth exploring. tpacket_v2 uses a fixed ring with
> slots so all the pages are allocated and assigned to the ring at init
> time. To xmit a packet in this case the user space application would
> be required to leave the packet descriptor on the rx side pinned
> until the tx side DMA has completed. Then it can unpin the rx side
> and return it to the driver. This works if the TX/RX processing is
> fast enough to keep up. For many things this is good enough.
>
> For some work loads though this may not be sufficient. In which
> case a tpacket_v4 would be useful that can push down a new set
> of "slots" every n packets. Where n is sufficiently large to keep
> the workload running.

Here, too, virtio rings may help.

The extra level of indirection allows out of order completions,
reducing the chance of running out of rx descriptors when redirecting
a subset of packets to a tx ring, as that does not block the entire ring.

And passing explicit descriptors from userspace enables pointing to
new memory regions. On the flipside, they now have to be checked for
safety against region bounds.

> This is similar in many ways to virtio/vhost interaction.

Ah, I only saw this after writing the above :)
