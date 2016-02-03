From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 04/11] net: bulk alloc and reuse of SKBs in
 NAPI context
Date: Wed, 3 Feb 2016 11:38:40 +0100
Message-ID: <20160203113840.215521ed@redhat.com>
References: <20160202211051.16315.51808.stgit@firesoul>
	<20160202211159.16315.58487.stgit@firesoul>
	<20160203005249.GA3103@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Christoph Lameter <cl@linux.com>,
	tom@herbertland.com, Alexander Duyck <alexander.duyck@gmail.com>,
	ogerlitz@mellanox.com, gerlitz.or@gmail.com, brouer@redhat.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43225 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751090AbcBCKit (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Feb 2016 05:38:49 -0500
In-Reply-To: <20160203005249.GA3103@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2 Feb 2016 16:52:50 -0800
Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:

> On Tue, Feb 02, 2016 at 10:12:01PM +0100, Jesper Dangaard Brouer wrote:
> > Think twice before applying
> >  - This patch can potentially introduce added latency in some workloads
> > 
> > This patch introduce bulk alloc of SKBs and allow reuse of SKBs
> > free'ed in same softirq cycle.  SKBs are normally free'ed during TX
> > completion, but most high speed drivers also cleanup TX ring during
> > NAPI RX poll cycle.  Thus, if using napi_consume_skb/__kfree_skb_defer,
> > SKBs will be avail in the napi_alloc_cache->skb_cache.
> > 
> > If no SKBs are avail for reuse, then only bulk alloc 8 SKBs, to limit
> > the potential overshooting unused SKBs needed to free'ed when NAPI
> > cycle ends (flushed in net_rx_action via __kfree_skb_flush()).
> > 
> > Benchmarking IPv4-forwarding, on CPU i7-4790K @4.2GHz (no turbo boost)
> > (GCC version 5.1.1 20150618 (Red Hat 5.1.1-4))
> >  Allocator SLUB:
> >   Single CPU/flow numbers: before: 2064446 pps -> after: 2083031 pps
> >   Improvement: +18585 pps, -4.3 nanosec, +0.9%
> >  Allocator SLAB:
> >   Single CPU/flow numbers: before: 2035949 pps -> after: 2033567 pps
> >   Regression: -2382 pps, +0.57 nanosec, -0.1 %
> > 
> > Even-though benchmarking does show an improvement for SLUB(+0.9%), I'm
> > not convinced bulk alloc will be a win in all situations:
> >  * I see stalls on walking the SLUB freelist (normal hidden by prefetch)
> >  * In case RX queue is not full, alloc and free more SKBs than needed
> > 
> > More testing is needed with more real life benchmarks.
> > 
> > Joint work with Alexander Duyck.
> > 
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>  
> ...
> > -	skb = __build_skb(data, len);
> > -	if (unlikely(!skb)) {
> > +#define BULK_ALLOC_SIZE 8
> > +	if (!nc->skb_count) {
> > +		nc->skb_count = kmem_cache_alloc_bulk(skbuff_head_cache,
> > +						      gfp_mask, BULK_ALLOC_SIZE,
> > +						      nc->skb_cache);
> > +	}
> > +	if (likely(nc->skb_count)) {
> > +		skb = (struct sk_buff *)nc->skb_cache[--nc->skb_count];
> > +	} else {
> > +		/* alloc bulk failed */
> >  		skb_free_frag(data);
> >  		return NULL;
> >  	}
> >  
> > +	len -= SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
> > +
> > +	memset(skb, 0, offsetof(struct sk_buff, tail));
> > +	skb->truesize = SKB_TRUESIZE(len);
> > +	atomic_set(&skb->users, 1);
> > +	skb->head = data;
> > +	skb->data = data;
> > +	skb_reset_tail_pointer(skb);
> > +	skb->end = skb->tail + len;
> > +	skb->mac_header = (typeof(skb->mac_header))~0U;
> > +	skb->transport_header = (typeof(skb->transport_header))~0U;
> > +
> > +	/* make sure we initialize shinfo sequentially */
> > +	shinfo = skb_shinfo(skb);
> > +	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
> > +	atomic_set(&shinfo->dataref, 1);
> > +	kmemcheck_annotate_variable(shinfo->destructor_arg);  
> 
> copy-pasting from __build_skb()...
> Either new helper is needed or extend __build_skb() to take
> pre-allocated 'raw_skb' pointer.

Guess should have create a helper for the basic skb setup.  I just kept
it here, as I was planning to do trick like removing the memset, as
discussed below.

> Overall I like the first 3 patches. I think they're useful
> on their won.

Great, hope they can go into net-next soon.

> As far as bulk alloc... have you considered splitting
> bulk alloc of skb and init of skb?

I have many consideration on the SKB memset, as it shows up quite high
in profiles, how we can either 1) avoid clearing this much, or 2) speed
up clearing by clearing more (full pages in allocator).

My idea (2) is about clearing larger memory chunks, as the
memset/rep-stos operation have a fixed startup cost.  But do it inside
the slab allocator's bulk alloc call.  During bulk alloc we can
identify objects that are "next-to-each-other" and exec one rep-stos
operation.  My measurements show we need 3x 256-byte object's cleared
together before it is a win.

*BUT* I actually like your idea better, below, of delaying the init
... more comments below.

> Like in the above
> +	skb = (struct sk_buff *)nc->skb_cache[--nc->skb_count];
> will give cold pointer and first memset() will be missing cache.
> Either prefetch is needed the way slab_alloc_node() is doing
> in the line prefetch_freepointer(s, next_object);

I could prefetch the next elem in skb_cache[]. I have been playing with
that.  It didn't have much effect, as the bulk alloc (at least for
SLUB) have already walked the memory.  It helped a little to prefetch
the 3rd cache-line, on the memset speed... (but so small that is was
difficult to measure with enough confidence).

> or buld_alloc_skb and bulk_init_skb need to be two loops
> driven by drivers.
> Another idea is we can move skb_init all the way up till
> eth_type_trans() and the driver should prefetch both
> skb->data and skb pointers. Then eth_type_trans_and_skb_init()
> helper will read from cache and store into cache.
>
> Rephrasing the idea:
> when the drivers do napi_alloc_skb() they don't really
> need initialized 'struct sk_buff'. They either need skb->data
> to copy headers into or shinfo->frags to add a page to,
> the full init can wait till eth_type_trans_and_init()
> right before napi_gro_receive().
> Thoughts?

I actually like this idea better than my own.  Of delaying memset init
of the SKB. (I didn't understood it, until after you rephrased it ;-))

The drivers also need some extra fields, like hash and some flags.  But
we could easily organize sk_buff, to account for this.

I also like it because, delaying it until napi_gro_receive, we might
have a chance to avoid the clearing, e.g. if GRO can merge it, or for
other fastpath forwarding, we have not invented yet.  (Thinking out
loud, maybe even RPS could delay the memset, until it reach the remote
CPU, saving may cache-line transfers between the CPUs).

I think I like yours delayed memset idea the best.  Lets see if others
shoot it down? ;-)
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
