From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 2/2] virtio_net: remove send completion interrupts and
 avoid TX queue overrun through packet drop
Date: Sun, 27 Mar 2011 09:52:54 +0200
Message-ID: <20110327075254.GA3776@redhat.com>
References: <20110318133311.GA20623@gondor.apana.org.au>
 <1300498915.3441.21.camel@localhost.localdomain>
 <1300730587.3441.24.camel@localhost.localdomain>
 <20110322113649.GA17071@redhat.com>
 <1300847204.3441.26.camel@localhost.localdomain>
 <87r59xbbr6.fsf@rustcorp.com.au>
 <20110324142822.GD12958@redhat.com>
 <87mxkjls61.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shirley Ma <mashirle@us.ibm.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>, davem@davemloft.net,
	kvm@vger.kernel.org, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87mxkjls61.fsf@rustcorp.com.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 25, 2011 at 03:20:46PM +1030, Rusty Russell wrote:
> > 3. For TX sometimes we free a single buffer, sometimes
> >    a ton of them, which might make the transmit latency
> >    vary. It's probably a good idea to limit this,
> >    maybe free the minimal number possible to keep the device
> >    going without stops, maybe free up to MAX_SKB_FRAGS.
> 
> This kind of heuristic is going to be quite variable depending on
> circumstance, I think, so it's a lot of work to make sure we get it
> right.

Hmm, trying to keep the amount of work per descriptor
constant seems to make sense though, no?
Latency variations are not good for either RT uses or
protocols such as TCP.

> > 4. If the ring is full, we now notify right after
> >    the first entry is consumed. For TX this is suboptimal,
> >    we should try delaying the interrupt on host.
> 
> Lguest already does that: only sends an interrupt when it's run out of
> things to do.  It does update the used ring, however, as it processes
> them.

There are many approaches here I suspect something like
interrupt after half work is done might be better for
parallelism.

> 
> This seems sensible to me, but needs to be measured separately as well.

Agree.

> > More ideas, would be nice if someone can try them out:
> > 1. We are allocating/freeing buffers for indirect descriptors.
> >    Use some kind of pool instead?
> >    And we could preformat part of the descriptor.
> 
> We need some poolish mechanism for virtio_blk too; perhaps an allocation
> callback which both can use (virtio_blk to alloc from a pool, virtio_net
> to recycle?).

BTW for recycling, need to be careful about numa effects:
probably store cpu id and reallocate if we switch cpus ...
(or noma nodes - unfortunately not always described correctly).

> Along similar lines to preformatting, we could actually try to prepend
> the skb_vnet_hdr to the vnet data, and use a single descriptor for the
> hdr and the first part of the packet.
> 
> Though IIRC, qemu's virtio barfs if the first descriptor isn't just the
> hdr (barf...).

Maybe we can try fixing this before adding more flags,
then e.g. publish used flag can be resued to also
tell us layout is flexible. Or just add a feature flag for that.

> > 2. I didn't have time to work on virtio2 ideas presented
> >    at the kvm forum yet, any takers?
> 
> I didn't even attend.

Hmm, right. But what was presented there was discussed on list as well:
a single R/W descriptor ring with valid bit instead of 2 rings
+ a descriptor array.

>  But I think that virtio is moribund for the
> moment; there wasn't enough demand and it's clear that there are
> optimization unexplored in virtio1.

I agree absolutely that not all lessons has been learned,
playing with different ring layouts would make at least
an interesting paper IMO.

-- 
MST
