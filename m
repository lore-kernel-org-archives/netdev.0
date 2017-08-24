From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next] virtio-net: invoke zerocopy callback on xmit
 path if no tx napi
Date: Wed, 23 Aug 2017 23:28:24 -0400
Message-ID: <CAF=yD-KSek+LmZu0X0TXetmFEQ59iF3NpjZ4KugbwLo1BGfhaA@mail.gmail.com>
References: <20170819063854.27010-1-den@klaipeden.com> <5352c98a-fa48-fcf9-c062-9986a317a1b0@redhat.com>
 <CAF=yD-LZ4=WAYfUtY7xRWi50FRSkrcOa+b7uc46xRnC4sbDCzQ@mail.gmail.com>
 <64d451ae-9944-e978-5a05-54bb1a62aaad@redhat.com> <20170822204015-mutt-send-email-mst@kernel.org>
 <1503498504.8694.26.camel@klaipeden.com> <CAF=yD-+U_aWxSmPPY8v8t=JO0MRZ+N+DzVJTAMKYQ5F=pE1PfA@mail.gmail.com>
 <20170824014553-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Koichiro Den <den@klaipeden.com>, Jason Wang <jasowang@redhat.com>,
        virtualization@lists.linux-foundation.org,
        Network Development <netdev@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:34765 "EHLO
        mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750962AbdHXD3G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 23:29:06 -0400
Received: by mail-oi0-f53.google.com with SMTP id j144so19234296oib.1
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 20:29:06 -0700 (PDT)
In-Reply-To: <20170824014553-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> > * as a generic solution, if we were to somehow overcome the safety issue, track
>> > the delay and do copy if some threshold is reached could be an answer, but it's
>> > hard for now.> * so things like the current vhost-net implementation of deciding whether or not
>> > to do zerocopy beforehand referring the zerocopy tx error ratio is a point of
>> > practical compromise.
>>
>> The fragility of this mechanism is another argument for switching to tx napi
>> as default.
>>
>> Is there any more data about the windows guest issues when completions
>> are not queued within a reasonable timeframe? What is this timescale and
>> do we really need to work around this.
>
> I think it's pretty large, many milliseconds.
>
> But I wonder what do you mean by "work around". Using buffers within
> limited time frame sounds like a reasonable requirement to me.

Vhost-net zerocopy delays completions until the skb is really
sent. Traffic shaping can introduce msec timescale latencies.

The delay may actually be a useful signal. If the guest does not
orphan skbs early, TSQ will throttle the socket causing host
queue build up.

But, if completions are queued in-order, unrelated flows may be
throttled as well. Allowing out of order completions would resolve
this HoL blocking.

> Neither
> do I see why would using tx interrupts within guest be a work around -
> AFAIK windows driver uses tx interrupts.

It does not address completion latency itself. What I meant was
that in an interrupt-driver model, additional starvation issues,
such as the potential deadlock raised at the start of this thread,
or the timer delay observed before packets were orphaned in
virtio-net in commit b0c39dbdc204, are mitigated.

Specifically, it breaks the potential deadlock where sockets are
blocked waiting for completions (to free up budget in sndbuf, tsq, ..),
yet completion handling is blocked waiting for a new packet to
trigger free_old_xmit_skbs from start_xmit.

>> That is the only thing keeping us from removing the HoL blocking in vhost-net zerocopy.
>
> We don't enable network watchdog on virtio but we could and maybe
> should.

Can you elaborate?
