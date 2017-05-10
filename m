From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 1/3] ptr_ring: batch ring zeroing
Date: Wed, 10 May 2017 11:18:13 +0200
Message-ID: <20170510111813.35f21ab0@redhat.com>
References: <1491544049-19108-1-git-send-email-mst@redhat.com>
        <20170408141408.2101017e@redhat.com>
        <20170509163238-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Jason Wang <jasowang@redhat.com>,
        brouer@redhat.com,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        John Fastabend <john.fastabend@gmail.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170509163238-mutt-send-email-mst@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 9 May 2017 16:33:14 +0300
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> On Sat, Apr 08, 2017 at 02:14:08PM +0200, Jesper Dangaard Brouer wrote:
> > On Fri, 7 Apr 2017 08:49:57 +0300
> > "Michael S. Tsirkin" <mst@redhat.com> wrote:
> >   
> > > A known weakness in ptr_ring design is that it does not handle well the
> > > situation when ring is almost full: as entries are consumed they are
> > > immediately used again by the producer, so consumer and producer are
> > > writing to a shared cache line.
> > > 
> > > To fix this, add batching to consume calls: as entries are
> > > consumed do not write NULL into the ring until we get
> > > a multiple (in current implementation 2x) of cache lines
> > > away from the producer. At that point, write them all out.
> > > 
> > > We do the write out in the reverse order to keep
> > > producer from sharing cache with consumer for as long
> > > as possible.
> > > 
> > > Writeout also triggers when ring wraps around - there's
> > > no special reason to do this but it helps keep the code
> > > a bit simpler.
> > > 
> > > What should we do if getting away from producer by 2 cache lines
> > > would mean we are keeping the ring moe than half empty?
> > > Maybe we should reduce the batching in this case,
> > > current patch simply reduces the batching.
> > > 
> > > Notes:
> > > - it is no longer true that a call to consume guarantees
> > >   that the following call to produce will succeed.
> > >   No users seem to assume that.
> > > - batching can also in theory reduce the signalling rate:
> > >   users that would previously send interrups to the producer
> > >   to wake it up after consuming each entry would now only
> > >   need to do this once in a batch.
> > >   Doing this would be easy by returning a flag to the caller.
> > >   No users seem to do signalling on consume yet so this was not
> > >   implemented yet.
> > > 
> > > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > > ---
> > > 
> > > Jason, I am curious whether the following gives you some of
> > > the performance boost that you see with vhost batching
> > > patches. Is vhost batching on top still helpful?
> > > 
> > >  include/linux/ptr_ring.h | 63 +++++++++++++++++++++++++++++++++++++++++-------
> > >  1 file changed, 54 insertions(+), 9 deletions(-)
> > > 
> > > diff --git a/include/linux/ptr_ring.h b/include/linux/ptr_ring.h
> > > index 6c70444..6b2e0dd 100644
> > > --- a/include/linux/ptr_ring.h
> > > +++ b/include/linux/ptr_ring.h
> > > @@ -34,11 +34,13 @@
> > >  struct ptr_ring {
> > >  	int producer ____cacheline_aligned_in_smp;
> > >  	spinlock_t producer_lock;
> > > -	int consumer ____cacheline_aligned_in_smp;
> > > +	int consumer_head ____cacheline_aligned_in_smp; /* next valid entry */
> > > +	int consumer_tail; /* next entry to invalidate */
> > >  	spinlock_t consumer_lock;
> > >  	/* Shared consumer/producer data */
> > >  	/* Read-only by both the producer and the consumer */
> > >  	int size ____cacheline_aligned_in_smp; /* max entries in queue */
> > > +	int batch; /* number of entries to consume in a batch */
> > >  	void **queue;
> > >  };
> > >  
> > > @@ -170,7 +172,7 @@ static inline int ptr_ring_produce_bh(struct ptr_ring *r, void *ptr)
> > >  static inline void *__ptr_ring_peek(struct ptr_ring *r)
> > >  {
> > >  	if (likely(r->size))
> > > -		return r->queue[r->consumer];
> > > +		return r->queue[r->consumer_head];
> > >  	return NULL;
> > >  }
> > >  
> > > @@ -231,9 +233,38 @@ static inline bool ptr_ring_empty_bh(struct ptr_ring *r)
> > >  /* Must only be called after __ptr_ring_peek returned !NULL */
> > >  static inline void __ptr_ring_discard_one(struct ptr_ring *r)
> > >  {
> > > -	r->queue[r->consumer++] = NULL;
> > > -	if (unlikely(r->consumer >= r->size))
> > > -		r->consumer = 0;
> > > +	/* Fundamentally, what we want to do is update consumer
> > > +	 * index and zero out the entry so producer can reuse it.
> > > +	 * Doing it naively at each consume would be as simple as:
> > > +	 *       r->queue[r->consumer++] = NULL;
> > > +	 *       if (unlikely(r->consumer >= r->size))
> > > +	 *               r->consumer = 0;
> > > +	 * but that is suboptimal when the ring is full as producer is writing
> > > +	 * out new entries in the same cache line.  Defer these updates until a
> > > +	 * batch of entries has been consumed.
> > > +	 */
> > > +	int head = r->consumer_head++;
> > > +
> > > +	/* Once we have processed enough entries invalidate them in
> > > +	 * the ring all at once so producer can reuse their space in the ring.
> > > +	 * We also do this when we reach end of the ring - not mandatory
> > > +	 * but helps keep the implementation simple.
> > > +	 */
> > > +	if (unlikely(r->consumer_head - r->consumer_tail >= r->batch ||
> > > +		     r->consumer_head >= r->size)) {
> > > +		/* Zero out entries in the reverse order: this way we touch the
> > > +		 * cache line that producer might currently be reading the last;
> > > +		 * producer won't make progress and touch other cache lines
> > > +		 * besides the first one until we write out all entries.
> > > +		 */
> > > +		while (likely(head >= r->consumer_tail))
> > > +			r->queue[head--] = NULL;
> > > +		r->consumer_tail = r->consumer_head;
> > > +	}
> > > +	if (unlikely(r->consumer_head >= r->size)) {
> > > +		r->consumer_head = 0;
> > > +		r->consumer_tail = 0;
> > > +	}
> > >  }  
> > 
> > I love this idea.  Reviewed and discussed the idea in-person with MST
> > during netdevconf[1] at this laptop.  I promised I will also run it
> > through my micro-benchmarking[2] once I return home (hint ptr_ring gets
> > used in network stack as skb_array).  
> 
> I'm merging this through my tree. Any objections?

I just did the micro-benchmark evaluation I promised and everything
looks good, so no objections from me.

John Fastabend recently posted a RFC patchset for removing the qdisc
lock.  The main purpose is to separate enqueue'ers and dequeue'ers from
serializing on the same lock.  But we need a new queue implementation
that avoids the false-sharing between enq+deq.

This is why John choose to use ptr_ring, changed (pfifo_fast) qdisc to
use this ptr_ring.  I think this patch might help his overload testing,
as my theory is that he is hitting false-sharing on the queue, due to
the queue always being full.


> > Reviewed-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > 
> > [1] http://netdevconf.org/2.1/
> > [2] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/lib/skb_array_bench01.c

If you like can also add my:

Tested-by: Jesper Dangaard Brouer <brouer@redhat.com>

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

$ modprobe skb_array_test01 
$ dmesg 
[73228.381497] skb_array_test01: Loaded
[73228.381498] skb_array_test01: PASSED - basic_init_and_cleanup()
[73228.381498] skb_array_test01: PASSED - basic_add_and_remove_object()
[73228.381505] skb_array_test01: PASSED - test_queue_full_condition()
[73228.381505] skb_array_test01: PASSED - test_queue_empty_condition()
[73228.381510] skb_array_test01: PASSED - test_queue_resize()
