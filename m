From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 2/2] virtio_net: remove send completion interrupts and
 avoid TX queue overrun through packet drop
Date: Thu, 24 Mar 2011 16:28:22 +0200
Message-ID: <20110324142822.GD12958@redhat.com>
References: <20110318133311.GA20623@gondor.apana.org.au>
 <1300498915.3441.21.camel@localhost.localdomain>
 <1300730587.3441.24.camel@localhost.localdomain>
 <20110322113649.GA17071@redhat.com>
 <1300847204.3441.26.camel@localhost.localdomain>
 <87r59xbbr6.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shirley Ma <mashirle@us.ibm.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>, davem@davemloft.net,
	kvm@vger.kernel.org, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10623 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932683Ab1CXO2r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Mar 2011 10:28:47 -0400
Content-Disposition: inline
In-Reply-To: <87r59xbbr6.fsf@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 24, 2011 at 11:00:53AM +1030, Rusty Russell wrote:
> > With simply removing the notify here, it does help the case when TX
> > overrun hits too often, for example for 1K message size, the single
> > TCP_STREAM performance improved from 2.xGb/s to 4.xGb/s.
> 
> OK, we'll be getting rid of the "kick on full", so please delete that on
> all benchmarks.
> 
> Now, does the capacity check before add_buf() still win anything?  I
> can't see how unless we have some weird bug.
> 
> Once we've sorted that out, we should look at the more radical change
> of publishing last_used and using that to intuit whether interrupts
> should be sent.  If we're not careful with ordering and barriers that
> could introduce more bugs.

Right. I am working on this, and trying to be careful.
One thing I'm in doubt about: sometimes we just want to
disable interrupts. Should still use flags in that case?
I thought that if we make the published index 0 to vq->num - 1,
then a special value in the index field could disable
interrupts completely. We could even reuse the space
for the flags field to stick the index in. Too complex?

> Anything else on the optimization agenda I've missed?
> 
> Thanks,
> Rusty.

Several other things I am looking at, wellcome cooperation:
1. It's probably a good idea to update avail index
   immediately instead of upon kick: for RX
   this might help parallelism with the host.

2. Adding an API to add a single buffer instead of s/g,
   seems to help a bit.

3. For TX sometimes we free a single buffer, sometimes
   a ton of them, which might make the transmit latency
   vary. It's probably a good idea to limit this,
   maybe free the minimal number possible to keep the device
   going without stops, maybe free up to MAX_SKB_FRAGS.

4. If the ring is full, we now notify right after
   the first entry is consumed. For TX this is suboptimal,
   we should try delaying the interrupt on host.

More ideas, would be nice if someone can try them out:
1. We are allocating/freeing buffers for indirect descriptors.
   Use some kind of pool instead?
   And we could preformat part of the descriptor.

2. I didn't have time to work on virtio2 ideas presented
   at the kvm forum yet, any takers?

-- 
MST
