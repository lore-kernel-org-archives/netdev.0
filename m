From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] virtio-net: invoke zerocopy callback on xmit
 path if no tx napi
Date: Thu, 24 Aug 2017 23:50:53 +0300
Message-ID: <20170824234551-mutt-send-email-mst@kernel.org>
References: <5352c98a-fa48-fcf9-c062-9986a317a1b0@redhat.com>
 <CAF=yD-LZ4=WAYfUtY7xRWi50FRSkrcOa+b7uc46xRnC4sbDCzQ@mail.gmail.com>
 <64d451ae-9944-e978-5a05-54bb1a62aaad@redhat.com>
 <20170822204015-mutt-send-email-mst@kernel.org>
 <1503498504.8694.26.camel@klaipeden.com>
 <CAF=yD-+U_aWxSmPPY8v8t=JO0MRZ+N+DzVJTAMKYQ5F=pE1PfA@mail.gmail.com>
 <20170824014553-mutt-send-email-mst@kernel.org>
 <CAF=yD-KSek+LmZu0X0TXetmFEQ59iF3NpjZ4KugbwLo1BGfhaA@mail.gmail.com>
 <20170824160748-mutt-send-email-mst@kernel.org>
 <CAF=yD-+9Ah8pC9i2w3Ad3WnhQit7Yo479pMrToty7priL6BFLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Koichiro Den <den@klaipeden.com>, Jason Wang <jasowang@redhat.com>,
        virtualization@lists.linux-foundation.org,
        Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47636 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753492AbdHXUu5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Aug 2017 16:50:57 -0400
Content-Disposition: inline
In-Reply-To: <CAF=yD-+9Ah8pC9i2w3Ad3WnhQit7Yo479pMrToty7priL6BFLw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 24, 2017 at 04:20:39PM -0400, Willem de Bruijn wrote:
> >> Traffic shaping can introduce msec timescale latencies.
> >>
> >> The delay may actually be a useful signal. If the guest does not
> >> orphan skbs early, TSQ will throttle the socket causing host
> >> queue build up.
> >>
> >> But, if completions are queued in-order, unrelated flows may be
> >> throttled as well. Allowing out of order completions would resolve
> >> this HoL blocking.
> >
> > We can allow out of order, no guests that follow virtio spec
> > will break. But this won't help in all cases
> > - a single slow flow can occupy the whole ring, you will not
> >   be able to make any new buffers available for the fast flow
> > - what host considers a single flow can be multiple flows for guest
> >
> > There are many other examples.
> 
> These examples are due to exhaustion of the fixed ubuf_info pool,
> right?

No - the ring size itself.

> We could use dynamic allocation or a resizable pool if these
> issues are serious enough.

We need some kind of limit on how many requests a guest can queue in the
host, or it's an obvious DoS attack vector. We used the ring size for
that.

> >> > Neither
> >> > do I see why would using tx interrupts within guest be a work around -
> >> > AFAIK windows driver uses tx interrupts.
> >>
> >> It does not address completion latency itself. What I meant was
> >> that in an interrupt-driver model, additional starvation issues,
> >> such as the potential deadlock raised at the start of this thread,
> >> or the timer delay observed before packets were orphaned in
> >> virtio-net in commit b0c39dbdc204, are mitigated.
> >>
> >> Specifically, it breaks the potential deadlock where sockets are
> >> blocked waiting for completions (to free up budget in sndbuf, tsq, ..),
> >> yet completion handling is blocked waiting for a new packet to
> >> trigger free_old_xmit_skbs from start_xmit.
> >
> > This talk of potential deadlock confuses me - I think you mean we would
> > deadlock if we did not orphan skbs in !use_napi - is that right?  If you
> > mean that you can drop skb orphan and this won't lead to a deadlock if
> > free skbs upon a tx interrupt, I agree, for sure.
> 
> Yes, that is what I meant.
> 
> >> >> That is the only thing keeping us from removing the HoL blocking in vhost-net zerocopy.
> >> >
> >> > We don't enable network watchdog on virtio but we could and maybe
> >> > should.
> >>
> >> Can you elaborate?
> >
> > The issue is that holding onto buffers for very long times makes guests
> > think they are stuck. This is funamentally because from guest point of
> > view this is a NIC, so it is supposed to transmit things out in
> > a timely manner. If host backs the virtual NIC by something that is not
> > a NIC, with traffic shaping etc introducing unbounded latencies,
> > guest will be confused.
> 
> That assumes that guests are fragile in this regard. A linux guest
> does not make such assumptions.

Yes it does. Examples above:
	> > - a single slow flow can occupy the whole ring, you will not
	> >   be able to make any new buffers available for the fast flow
	> > - what host considers a single flow can be multiple flows for guest

it's easier to see if you enable the watchdog timer for virtio. Linux
supports that.

> There are NICs with hardware
> rate limiting, so I'm not sure how much of a leap host os rate
> limiting is.

I don't know what happens if these NICs hold onto packets for seconds.

-- 
MST
