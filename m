From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next] virtio-net: invoke zerocopy callback on xmit
 path if no tx napi
Date: Fri, 25 Aug 2017 21:03:29 -0400
Message-ID: <CAF=yD-Lre0NATUVH8p0zS=G5CiY=WfKSefLmOZw940jZFgECgQ@mail.gmail.com>
References: <64d451ae-9944-e978-5a05-54bb1a62aaad@redhat.com>
 <20170822204015-mutt-send-email-mst@kernel.org> <1503498504.8694.26.camel@klaipeden.com>
 <CAF=yD-+U_aWxSmPPY8v8t=JO0MRZ+N+DzVJTAMKYQ5F=pE1PfA@mail.gmail.com>
 <20170824014553-mutt-send-email-mst@kernel.org> <CAF=yD-KSek+LmZu0X0TXetmFEQ59iF3NpjZ4KugbwLo1BGfhaA@mail.gmail.com>
 <20170824160748-mutt-send-email-mst@kernel.org> <CAF=yD-+9Ah8pC9i2w3Ad3WnhQit7Yo479pMrToty7priL6BFLw@mail.gmail.com>
 <20170824234551-mutt-send-email-mst@kernel.org> <CAF=yD-+1wheMmC+HFKe_B_ULO0Mmh6HMSEbYY5D-HgqxVJee6A@mail.gmail.com>
 <20170826022744-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Koichiro Den <den@klaipeden.com>, Jason Wang <jasowang@redhat.com>,
        virtualization@lists.linux-foundation.org,
        Network Development <netdev@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:36289 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754700AbdHZBEL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 21:04:11 -0400
Received: by mail-oi0-f66.google.com with SMTP id d66so875334oib.3
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 18:04:11 -0700 (PDT)
In-Reply-To: <20170826022744-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 25, 2017 at 7:32 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> On Fri, Aug 25, 2017 at 06:44:36PM -0400, Willem de Bruijn wrote:
>> >> >> > We don't enable network watchdog on virtio but we could and maybe
>> >> >> > should.
>> >> >>
>> >> >> Can you elaborate?
>> >> >
>> >> > The issue is that holding onto buffers for very long times makes guests
>> >> > think they are stuck. This is funamentally because from guest point of
>> >> > view this is a NIC, so it is supposed to transmit things out in
>> >> > a timely manner. If host backs the virtual NIC by something that is not
>> >> > a NIC, with traffic shaping etc introducing unbounded latencies,
>> >> > guest will be confused.
>> >>
>> >> That assumes that guests are fragile in this regard. A linux guest
>> >> does not make such assumptions.
>> >
>> > Yes it does. Examples above:
>> >         > > - a single slow flow can occupy the whole ring, you will not
>> >         > >   be able to make any new buffers available for the fast flow
>>
>> Oh, right. Though those are due to vring_desc pool exhaustion
>> rather than an upper bound on latency of any single packet.
>>
>> Limiting the number of zerocopy packets in flight to some fraction
>> of the ring ensures that fast flows can always grab a slot.
>> Running
>> out of ubuf_info slots reverts to copy, so indirectly does this. But
>> I read it correclty the zerocopy pool may be equal to or larger than
>> the descriptor pool. Should we refine the zcopy_used test
>>
>>     (nvq->upend_idx + 1) % UIO_MAXIOV != nvq->done_idx
>>
>> to also return false if the number of outstanding ubuf_info is greater
>> than, say, vq->num >> 1?
>
>
> We'll need to think about where to put the threshold, but I think it's
> a good idea.
>
> Maybe even a fixed number, e.g. max(vq->num >> 1, X) to limit host
> resources.
>
> In a sense it still means once you run out of slots zcopt gets disabled possibly permanently.
>
> Need to experiment with some numbers.

I can take a stab with two flows, one delayed in a deep host qdisc
queue. See how this change affects the other flow and also how
sensitive that is to the chosen threshold value.
