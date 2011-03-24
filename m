From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 2/2] virtio_net: remove send completion interrupts and
 avoid TX queue overrun through packet drop
Date: Thu, 24 Mar 2011 20:10:39 +0200
Message-ID: <20110324181039.GA16168@redhat.com>
References: <20110318133311.GA20623@gondor.apana.org.au>
 <1300498915.3441.21.camel@localhost.localdomain>
 <1300730587.3441.24.camel@localhost.localdomain>
 <20110322113649.GA17071@redhat.com>
 <1300847204.3441.26.camel@localhost.localdomain>
 <87r59xbbr6.fsf@rustcorp.com.au>
 <20110324142822.GD12958@redhat.com>
 <1300988809.3441.48.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Herbert Xu <herbert@gondor.hengli.com.au>, davem@davemloft.net,
	kvm@vger.kernel.org, netdev@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1300988809.3441.48.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 24, 2011 at 10:46:49AM -0700, Shirley Ma wrote:
> On Thu, 2011-03-24 at 16:28 +0200, Michael S. Tsirkin wrote:
> > On Thu, Mar 24, 2011 at 11:00:53AM +1030, Rusty Russell wrote:
> > > > With simply removing the notify here, it does help the case when TX
> > > > overrun hits too often, for example for 1K message size, the single
> > > > TCP_STREAM performance improved from 2.xGb/s to 4.xGb/s.
> > > 
> > > OK, we'll be getting rid of the "kick on full", so please delete that on
> > > all benchmarks.
> > > 
> > > Now, does the capacity check before add_buf() still win anything?  I
> > > can't see how unless we have some weird bug.
> > > 
> > > Once we've sorted that out, we should look at the more radical change
> > > of publishing last_used and using that to intuit whether interrupts
> > > should be sent.  If we're not careful with ordering and barriers that
> > > could introduce more bugs.
> > 
> > Right. I am working on this, and trying to be careful.
> > One thing I'm in doubt about: sometimes we just want to
> > disable interrupts. Should still use flags in that case?
> > I thought that if we make the published index 0 to vq->num - 1,
> > then a special value in the index field could disable
> > interrupts completely. We could even reuse the space
> > for the flags field to stick the index in. Too complex?
> > > Anything else on the optimization agenda I've missed?
> > > 
> > > Thanks,
> > > Rusty.
> > 
> > Several other things I am looking at, wellcome cooperation:
> > 1. It's probably a good idea to update avail index
> >    immediately instead of upon kick: for RX
> >    this might help parallelism with the host.
> Is that possible to use the same idea for publishing last used idx to
> publish avail idx? Then we can save guest iowrite/exits.

Yes, but unrelated to 1 above :)

> > 2. Adding an API to add a single buffer instead of s/g,
> >    seems to help a bit.
> > 
> > 3. For TX sometimes we free a single buffer, sometimes
> >    a ton of them, which might make the transmit latency
> >    vary. It's probably a good idea to limit this,
> >    maybe free the minimal number possible to keep the device
> >    going without stops, maybe free up to MAX_SKB_FRAGS.
> 
> I am playing with it now, to collect more perf data to see what's the
> best value to free number of used buffers.

The best IMO is to keep the number of freed buffers constant
so that we have more or less identical overhead for each packet.

> > 4. If the ring is full, we now notify right after
> >    the first entry is consumed. For TX this is suboptimal,
> >    we should try delaying the interrupt on host.
> 
> > More ideas, would be nice if someone can try them out:
> > 1. We are allocating/freeing buffers for indirect descriptors.
> >    Use some kind of pool instead?
> >    And we could preformat part of the descriptor.
> > 2. I didn't have time to work on virtio2 ideas presented
> >    at the kvm forum yet, any takers?
> If I have time, I will look at this.
> 
> Thanks
> Shirley
> 
