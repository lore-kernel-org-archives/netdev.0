From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH V1 1/3] net: bulk alloc and reuse of SKBs in NAPI context
Date: Mon, 9 May 2016 13:46:32 -0700
Message-ID: <CAKgT0UfKzKWnNzGpB-915by2M1nzDAdNz-hDwwcwGoowmZefrg@mail.gmail.com>
References: <20160509134352.3573.37044.stgit@firesoul>
	<20160509134429.3573.4048.stgit@firesoul>
	<CAKgT0Uftr643AR9n2=_aQmaGJO3eEyKTuaCfXwEKbYj1rVruRw@mail.gmail.com>
	<20160509215956.19ec1c10@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:32826 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537AbcEIUqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 16:46:33 -0400
Received: by mail-io0-f175.google.com with SMTP id f89so184605925ioi.0
        for <netdev@vger.kernel.org>; Mon, 09 May 2016 13:46:33 -0700 (PDT)
In-Reply-To: <20160509215956.19ec1c10@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 9, 2016 at 12:59 PM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> On Mon, 9 May 2016 09:20:41 -0700
> Alexander Duyck <alexander.duyck@gmail.com> wrote:
>
>> On Mon, May 9, 2016 at 6:44 AM, Jesper Dangaard Brouer
>> <brouer@redhat.com> wrote:
>> > This patch introduce bulk alloc of SKBs and allow reuse of SKBs
>> > free'ed in same softirq cycle.  SKBs are normally free'ed during TX
>> > completion, but most high speed drivers also cleanup TX ring during
>> > NAPI RX poll cycle.  Thus, if using napi_consume_skb/__kfree_skb_defer,
>> > SKBs will be avail in the napi_alloc_cache->skb_cache.
>> >
>> > If no SKBs are avail for reuse, then only bulk alloc 8 SKBs, to limit
>> > the potential overshooting unused SKBs needed to free'ed when NAPI
>> > cycle ends (flushed in net_rx_action via __kfree_skb_flush()).
>> >
>> > Generalize ___build_skb() to allow passing it a preallocated SKB.
>> >
>> > I've previously demonstrated a 1% speedup for IPv4 forwarding, when
>> > used on the ixgbe driver.  If SKB alloc and free happens on different
>> > CPUs (like in RPS use-case) the performance benefit is expected to
>> > increase.
>>
>> Really I am not sure this patch series is worth the effort.  For
>> freeing buffers in Tx it was an obvious win.  But adding all this
>> complexity for a 1% gain just doesn't seen worth the effort.
>
> I still think it is worth it, because: 1) it enables recycling, which
> is more likely for real-life traffic (e.g. some TCP ACKs gets TX DMA
> completion cleanup, and RX can re-use these), and 2) because bulk alloc
> and bulk free gets "coupled" (mostly relevant when doing cross CPU).

I disagree.  While there will be some ACKs it will likely be
significantly less then the number of packets received, especially
when you take GRO into account.

>
>> > All drivers using the napi_alloc_skb() call will benefit from
>> > this change automatically.
>>
>> Yes, but a 1% improvement is essentially just noise.  I'd say we need
>> to show a better gain or be able to more precisely show that this is a
>> definite gain and not just a test fluctuation resulting in the
>> improvement.  For all I know all of the gain could be due to a
>> function shifting around so that some loop is now 16 byte aligned.
>>
>> > Joint work with Alexander Duyck.
>> >
>> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
>> > Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
>>
>> The fact that this is still using my redhat.com address says volumes.
>> If I recall I think we were working on this code around 9 months ago
>> and had similar issues with it showing either negative performance or
>> no gain.  My advice then was to push the bulk free code and try to
>> find a way to fix the bulk allocation.  If we are still at this state
>> for bulk allocation then maybe we need to drop the bulk allocation and
>> start looking at other avenues to pursue.
>
> I'm sure there is a gain here. Sure I can spend 2-3 weeks coming up
> with a benchmark that show a bigger gain, but is it time well spend?
>
> My quick benchmarking with mlx4 actually showed 2.7% improvement, for
> local UDP socket delivery. And only 0.6% on IP-forwarding.  If I find
> some bidirectional traffic then the benefit should be higher due to
> recycling kicking in.

Is that with or without patch 2 being a part of the set?  This patch
should be able to prove itself as a stand-alone patch.  I'd say go
ahead and submit patch 2 as a standalone and then we can start working
on collecting numbers on the mlx4.  Also are you running your test
with GRO disabled?  If so you might try enabling it on the mlx4
because that changes the skbuff allocation which would impact the
behavior for the device.

Try testing with TCP_RR instead and watch the CPU utilization.  I'm
suspecting allocating 8 and freeing 7 buffers for every 1 buffer
received will blow any gains right out of the water.  Also try it with
a mix of traffic.  So have one NIC doing TCP_RR while another is doing
a stream test.  You are stuffing 7 buffers onto a queue that were were
using to perform bulk freeing.  How much of a penalty do you take if
you are now limited on how many you can bulk free because somebody
left a stray 7 packets sitting on the queue?

Also please stop focusing on IP-forwarding.  There are some use cases
for it out there, but the vast majority of people don't care that much
about it.  It is just one data point out of many.  Try running a few
TCP based applications and see if you can notice any difference.  It
is okay to focus on routing numbers when you are doing work that will
only impact routing or has next to no likelihood of introducing a
regression, but the fact is the bulk alloc has a strong likelihood of
having effects on other parts of the network stack since you are
pulling in more buffers then you actually need.

> We did do as you recommended, and the bulk free code first. I'm
> just getting the last pieces pushed.  I didn't see any negative
> performance in my testing.

Not seeing any negative performance is not the same as seeing gains.
You are introducing complexity, there needs to be something to show
for it.  Otherwise you are just making the code harder to maintain for
no good reason.

> As you also know, tuning the SLUB system will give higher performance,
> easily.  In the future, I'm planning to get some auto-tuning into the
> SLUB allocator.  I've already discussed this with Christiph Lameter, at
> MM-summit, see presentation[1] slides 4 and 5.

We aren't discussing tuning parameters.  We are discussing this patch.
If you want to argue that with certain tuning parameters this shows
more performance then bring the numbers, but don't try to bias things.
If you have to tune the system in some way that nobody will there is
probably no point in submitting the patch because nobody will use it
that way.

You also didn't test for low latency.  As I said this is coming at a
high expense to other use cases, but your use case only shows a 1%
improvement.  In my opinion it is not worth adding the complexity if
we cannot show much of a gain.  If you want to win me over we need to
be able to justify the complexity.  Right now I am not seeing it.  In
addition patch 3 illustrates the added complexity you are bringing to
all this because you are having to add limitations to napi_alloc_skb
because you are trying to make it work with recycling which
historically has never been a win because there are too many traffic
patterns where recycling cannot occur.

> [1] http://people.netfilter.org/hawk/presentations/MM-summit2016/slab_mm_summit2016.odp
>
>> > ---
>> >  net/core/skbuff.c |   71
>> > ++++++++++++++++++++++++++++++++++------------------- 1 file
>> > changed, 45 insertions(+), 26 deletions(-)
>> >
>> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>> > index 5586be93632f..e85f1065b263 100644
>> > --- a/net/core/skbuff.c
>> > +++ b/net/core/skbuff.c
>> > @@ -281,32 +281,14 @@ nodata:
>> >  }
>> >  EXPORT_SYMBOL(__alloc_skb);
>> >
>> > -/**
>> > - * __build_skb - build a network buffer
>> > - * @data: data buffer provided by caller
>> > - * @frag_size: size of data, or 0 if head was kmalloced
>> > - *
>> > - * Allocate a new &sk_buff. Caller provides space holding head and
>> > - * skb_shared_info. @data must have been allocated by kmalloc()
>> > only if
>> > - * @frag_size is 0, otherwise data should come from the page
>> > allocator
>> > - *  or vmalloc()
>> > - * The return is the new skb buffer.
>> > - * On a failure the return is %NULL, and @data is not freed.
>> > - * Notes :
>> > - *  Before IO, driver allocates only data buffer where NIC put
>> > incoming frame
>> > - *  Driver should add room at head (NET_SKB_PAD) and
>> > - *  MUST add room at tail (SKB_DATA_ALIGN(skb_shared_info))
>> > - *  After IO, driver calls build_skb(), to allocate sk_buff and
>> > populate it
>> > - *  before giving packet to stack.
>> > - *  RX rings only contains data buffers, not full skbs.
>> > - */
>> > -struct sk_buff *__build_skb(void *data, unsigned int frag_size)
>> > +/* Allows skb being (pre)allocated by caller */
>> > +static inline
>> > +struct sk_buff *___build_skb(void *data, unsigned int frag_size,
>> > +                            struct sk_buff *skb)
>> >  {
>> >         struct skb_shared_info *shinfo;
>> > -       struct sk_buff *skb;
>> >         unsigned int size = frag_size ? : ksize(data);
>> >
>> > -       skb = kmem_cache_alloc(skbuff_head_cache, GFP_ATOMIC);
>> >         if (!skb)
>> >                 return NULL;
>> >
>> > @@ -331,6 +313,34 @@ struct sk_buff *__build_skb(void *data,
>> > unsigned int frag_size) return skb;
>> >  }
>> >
>> > +/**
>> > + * __build_skb - build a network buffer
>> > + * @data: data buffer provided by caller
>> > + * @frag_size: size of data, or 0 if head was kmalloced
>> > + *
>> > + * Allocate a new &sk_buff. Caller provides space holding head and
>> > + * skb_shared_info. @data must have been allocated by kmalloc()
>> > only if
>> > + * @frag_size is 0, otherwise data should come from the page
>> > allocator
>> > + *  or vmalloc()
>> > + * The return is the new skb buffer.
>> > + * On a failure the return is %NULL, and @data is not freed.
>> > + * Notes :
>> > + *  Before IO, driver allocates only data buffer where NIC put
>> > incoming frame
>> > + *  Driver should add room at head (NET_SKB_PAD) and
>> > + *  MUST add room at tail (SKB_DATA_ALIGN(skb_shared_info))
>> > + *  After IO, driver calls build_skb(), to allocate sk_buff and
>> > populate it
>> > + *  before giving packet to stack.
>> > + *  RX rings only contains data buffers, not full skbs.
>> > + */
>> > +struct sk_buff *__build_skb(void *data, unsigned int frag_size)
>> > +{
>> > +       struct sk_buff *skb;
>> > +       unsigned int size = frag_size ? : ksize(data);
>> > +
>> > +       skb = kmem_cache_alloc(skbuff_head_cache, GFP_ATOMIC);
>> > +       return ___build_skb(data, size, skb);
>> > +}
>> > +
>> >  /* build_skb() is wrapper over __build_skb(), that specifically
>> >   * takes care of skb->head and skb->pfmemalloc
>> >   * This means that if @frag_size is not zero, then @data must be
>> > backed
>>
>> If we can avoid having to break up build_skb into more functions that
>> would be preferred.  I realize I probably wrote this code in order to
>> enable the bulk allocation approach, but really I don't want to add
>> more complexity unless we can show a strong gain which we haven't been
>> able to demonstrate.
>
> You do notice that ___build_skb gets inlined, thus there is not
> performance loss.  And this change was explicitly requested last time
> this patch was reviewed.  And I think this variant is much less
> intrusive.

I didn't notice the inline, so it means we are bloating the code a bit
instead of adding more function calls.  I guess that is a better trade
off, but still not the most desirable thing to do.

>
>> > @@ -490,8 +500,8 @@ struct sk_buff *__napi_alloc_skb(struct
>> > napi_struct *napi, unsigned int len,
>> >
>> >         len += NET_SKB_PAD + NET_IP_ALIGN;
>> >
>> > -       if ((len > SKB_WITH_OVERHEAD(PAGE_SIZE)) ||
>> > -           (gfp_mask & (__GFP_DIRECT_RECLAIM | GFP_DMA))) {
>> > +       if (unlikely((len > SKB_WITH_OVERHEAD(PAGE_SIZE)) ||
>> > +                    (gfp_mask & (__GFP_DIRECT_RECLAIM |
>> > GFP_DMA)))) { skb = __alloc_skb(len, gfp_mask, SKB_ALLOC_RX,
>> > NUMA_NO_NODE); if (!skb)
>> >                         goto skb_fail;
>>
>> Does this unlikely really make a difference?  If so you might want to
>> move it into a patch all on its own.
>
> I can place it in a patch of it's own.  I just noticed the compiler
> layed out the code wrongly compared to the normal use-case.

What version of gcc are you seeing this with?  From what I can tell on
the 4.8.5 version that came with my RHEL 7.2 build I am seeing the
proper setup with 2 compares and 2 jumps to the remote code.

>> > @@ -508,11 +518,20 @@ struct sk_buff *__napi_alloc_skb(struct
>> > napi_struct *napi, unsigned int len, if (unlikely(!data))
>> >                 return NULL;
>> >
>> > -       skb = __build_skb(data, len);
>> > -       if (unlikely(!skb)) {
>> > +#define BULK_ALLOC_SIZE 8
>> > +       if (!nc->skb_count) {
>> > +               nc->skb_count =
>> > kmem_cache_alloc_bulk(skbuff_head_cache,
>> > +                                                     gfp_mask,
>> > BULK_ALLOC_SIZE,
>> > +
>> > nc->skb_cache);
>> > +       }
>> > +       if (likely(nc->skb_count)) {
>> > +               skb = (struct sk_buff
>> > *)nc->skb_cache[--nc->skb_count];
>> > +       } else {
>> > +               /* alloc bulk failed */
>>
>> So did you try doing a low latency socket test with this patch?  I'm
>> guessing not as I am certain there is a negative impact from having to
>> allocate 8 buffers, and then free back 7 every time you call the NAPI
>> polling routine with just one buffer in the ring.
>
> There is a very high probability that pulling out 8 objects, and
> returning 7 object, will have the same cost of alloc and free of a
> single object.  This is due to how the SLUB allocator's per CPU
> allocator works.

I very much doubt that.  You are still having to move around many more
objects then you really should be and dragging in 8 cache lines as you
have to walk the percpu freelist to pull the entries and then push
them back in.

> Notice I said "high probability".  I have adjusted the slab bulk APIs,
> such that we can extend them to bulk return "upto" a given number of
> objects.  Then the SLUB allocator can remove the "high probability"
> part, and make sure only to return object on the per CPU slab-page,
> thus guaranteeing no cmpxchg_double calls, and only
> local_irq_disable/enable cycles, which is actually faster than the
> normal fastpath local cmpxchg_double (non-atomic variant).

On your system.  There is no guarantee that is the case across all
CPUs supported by the x86 architecture.

Also I can think of scenarios where your code would become very
expensive.  The fact is you are pushing an additional 7 objects into
the L1 cache each time you do one of these bulk allocations.  The
question you have to ask yourself is what is it you are evicting when
you do it.  There are scenerios where you could be evicting critical
data back out to L2 which will negatively impact your performance.  A
1% gain 99% of the time is kind of useless when there is a risk of a
significant performance hit for that remaining 1% of cases.
