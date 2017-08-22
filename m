From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next] virtio-net: invoke zerocopy callback on xmit
 path if no tx napi
Date: Tue, 22 Aug 2017 13:16:26 -0400
Message-ID: <CAF=yD-+AOnYafiwAf+v+fhyg_0fi-6LdQSnPYcoAcngJqYs9dg@mail.gmail.com>
References: <20170819063854.27010-1-den@klaipeden.com> <5352c98a-fa48-fcf9-c062-9986a317a1b0@redhat.com>
 <CAF=yD-LZ4=WAYfUtY7xRWi50FRSkrcOa+b7uc46xRnC4sbDCzQ@mail.gmail.com>
 <64d451ae-9944-e978-5a05-54bb1a62aaad@redhat.com> <CAF=yD-L-9QnxV2kM_j2BxVk=h7i3wvMZxG-3_=0Q=jDPgeT=VQ@mail.gmail.com>
 <1503409339.8694.12.camel@klaipeden.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jason Wang <jasowang@redhat.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        virtualization@lists.linux-foundation.org,
        Network Development <netdev@vger.kernel.org>
To: Koichiro Den <den@klaipeden.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:33592 "EHLO
        mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751289AbdHVRRI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 13:17:08 -0400
Received: by mail-oi0-f43.google.com with SMTP id f11so192311043oic.0
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 10:17:07 -0700 (PDT)
In-Reply-To: <1503409339.8694.12.camel@klaipeden.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> > An issue of the referenced patch is that sndbuf could be smaller than low
>> > watermark.
> We cannot determine the low watermark properly because of not only sndbuf size
> issue but also the fact that the upper vhost-net cannot directly see how much
> descriptor is currently available at the virtio-net tx queue. It depends on
> multiqueue settings or other senders which are also using the same tx queue.
> Note that in the latter case if they constantly transmitting, the deadlock could
> not occur(*), however if it has just temporarily fulfill some portion of the
> pool in the mean time, then the low watermark cannot be helpful.
> (*: That is because it's reliable enough in the sense I mention below.)
>
> Keep in this in mind, let me briefly describe the possible deadlock I mentioned:
> (1). vhost-net on L1 guest has nothing to do sendmsg until the upper layer sets
> new descriptors, which depends only on the vhost-net zcopy callback and adding
> newly used descriptors.
> (2). vhost-net callback depends on the skb freeing on the xmit path only.
> (3). the xmit path depends (possibly only) on the vhost-net sendmsg.
> As you see, it's enough to bring about the situation above that L1 virtio-net
> reaches its limit earlier than the L0 host processing. The vhost-net pool could
> be almost full or empty, whatever.

Thanks for the context. This issue is very similar to the one that used to
exist when running out of transmit descriptors, before the removal of
the timer and introduction of skb_orphan in start_xmit.

To make sure that I understand correctly, let me paraphrase:

A. guest socket cannot send because it exhausted its sk budget (sndbuf, tsq, ..)

B. budget is not freed up until guest receives tx completion for this flow

C. tx completion is held back on the host side in vhost_zerocopy_signal_used
   behind the completion for an unrelated skb

D. unrelated packet is delayed somewhere in the host stackf zerocopy
completions.
   e.g., netem

The issue that is specific to vhost-net zerocopy is that (C) enforces strict
ordering of transmit completions causing head of line blocking behind
vhost-net zerocopy callbacks.

This is a different problem from

C1. tx completion is delayed until guest sends another packet and
       triggers free_old_xmit_skb

Both in host and guest, zerocopy packets should never be able to loop
to a receive path where they can cause unbounded delay.

The obvious cases of latency are queueing, like netem. That leads
to poor performance for unrelated flows, but I don't see how this
could cause deadlock.
