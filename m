From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next] virtio-net: invoke zerocopy callback on xmit
 path if no tx napi
Date: Mon, 21 Aug 2017 23:10:04 -0400
Message-ID: <CAF=yD-L-9QnxV2kM_j2BxVk=h7i3wvMZxG-3_=0Q=jDPgeT=VQ@mail.gmail.com>
References: <20170819063854.27010-1-den@klaipeden.com> <5352c98a-fa48-fcf9-c062-9986a317a1b0@redhat.com>
 <CAF=yD-LZ4=WAYfUtY7xRWi50FRSkrcOa+b7uc46xRnC4sbDCzQ@mail.gmail.com> <64d451ae-9944-e978-5a05-54bb1a62aaad@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Koichiro Den <den@klaipeden.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        virtualization@lists.linux-foundation.org,
        Network Development <netdev@vger.kernel.org>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:37107 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754381AbdHVDKq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 23:10:46 -0400
Received: by mail-oi0-f67.google.com with SMTP id k77so3753338oib.4
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 20:10:46 -0700 (PDT)
In-Reply-To: <64d451ae-9944-e978-5a05-54bb1a62aaad@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> Interesting, deadlock could be treated as a a radical case of the
>>> discussion
>>> here https://patchwork.kernel.org/patch/3787671/.
>>>
>>> git grep tells more similar skb_orphan() cases. Do we need to change them
>>> all (or part)?
>>
>> Most skb_orphan calls are not relevant to the issue of transmit delay.
>
>
> Yes, but at least we should audit the ones in drivers/net.

Do you mean other virtual device driver transmit paths, like xen,
specifically?

>>> Actually, we may meet similar issues at many other places (e.g netem).
>>
>> Netem is an interesting case. Because it is intended to mimic network
>> delay, at least in the case where it calls skb_orphan, it may make
>> sense to release all references, including calling skb_zcopy_clear.
>>
>> In general, zerocopy reverts to copy on all paths that may cause
>> unbounded delay due to another process. Guarding against delay
>> induced by the administrator is infeasible. It is always possible to
>> just pause the nic. Netem is one instance of that, and not unbounded.
>
>
> The problem is, admin may only delay the traffic in e.g one interface, but
> it actually delay or stall all traffic inside a VM.

Understood. Ideally we can remove the HoL blocking cause of this,
itself.

>>> Need
>>> to consider a complete solution for this. Figuring out all places that
>>> could
>>> delay a packet is a method.
>>
>> The issue described in the referenced patch seems like head of line
>> blocking between two flows. If one flow delays zerocopy descriptor
>> release from the vhost-net pool, it blocks all subsequent descriptors
>> in that pool from being released, also delaying other flows that use
>> the same descriptor pool. If the pool is empty, all transmission stopped.
>>
>> Reverting to copy tx when the pool reaches a low watermark, as the
>> patch does, fixes this.
>
>
> An issue of the referenced patch is that sndbuf could be smaller than low
> watermark.
>
>> Perhaps the descriptor pool should also be
>> revised to allow out of order completions. Then there is no need to
>> copy zerocopy packets whenever they may experience delay.
>
>
> Yes, but as replied in the referenced thread, windows driver may treat out
> of order completion as a bug.

Interesting. I missed that. Perhaps the zerocopy optimization
could be gated on guest support for out of order completions.

>> On the point of counting copy vs zerocopy: the new msg_zerocopy
>> variant of ubuf_info has a field to record whether a deep copy was
>> made. This can be used with vhost-net zerocopy, too.
>
>
> Just to make sure I understand. It's still not clear to me how to reuse this
> for vhost-net, e.g zerocopy flag is in a union which is not used by
> vhost_net.

True, but that is not set in stone. I went back and forth on that when
preparing fix 0a4a060bb204 ("sock: fix zerocopy_success regression
with msg_zerocopy"). The field can be moved outside the union and
initialized in the other zerocopy paths.
