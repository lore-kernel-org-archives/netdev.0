From: Mel Gorman <mgorman@suse.de>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle facility?
Date: Mon, 11 Apr 2016 09:58:19 +0100
Message-ID: <20160411085819.GE21128@suse.de>
References: <1460034425.20949.7.camel@HansenPartnership.com>
 <20160407161715.52635cac@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Brenden Blanco <bblanco@plumgrid.com>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	Tom Herbert <tom@herbertland.com>,
	lsf-pc@lists.linux-foundation.org,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20160407161715.52635cac@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 07, 2016 at 04:17:15PM +0200, Jesper Dangaard Brouer wrote:
> (Topic proposal for MM-summit)
> 
> Network Interface Cards (NIC) drivers, and increasing speeds stress
> the page-allocator (and DMA APIs).  A number of driver specific
> open-coded approaches exists that work-around these bottlenecks in the
> page allocator and DMA APIs. E.g. open-coded recycle mechanisms, and
> allocating larger pages and handing-out page "fragments".
> 
> I'm proposing a generic page-pool recycle facility, that can cover the
> driver use-cases, increase performance and open up for zero-copy RX.
> 

Which bottleneck dominates -- the page allocator or the DMA API when
setting up coherent pages?

I'm wary of another page allocator API being introduced if it's for
performance reasons. In response to this thread, I spent two days on
a series that boosts performance of the allocator in the fast paths by
11-18% to illustrate that there was low-hanging fruit for optimising. If
the one-LRU-per-node series was applied on top, there would be a further
boost to performance on the allocation side. It could be further boosted
if debugging checks and statistic updates were conditionally disabled by
the caller.

The main reason another allocator concerns me is that those pages
are effectively pinned and cannot be reclaimed by the VM in low memory
situations. It ends up needing its own API for tuning the size and hoping
all the drivers get it right without causing OOM situations. It becomes
a slippery slope of introducing shrinkers, locking and complexity. Then
callers start getting concerned about NUMA locality and having to deal
with multiple lists to maintain performance. Ultimately, it ends up being
as slow as the page allocator and back to square 1 except now with more code.

If it's the DMA API that dominates then something may be required but it
should rely on the existing page allocator to alloc/free from. It would
also need something like drain_all_pages to force free everything in there
in low memory situations. Remember that multiple instances private to
drivers or tasks will require shrinker implementations and the complexity
may get unwieldly.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
