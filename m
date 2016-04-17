From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: FlameGraph of mlx4 early drop with order-0 pages
Date: Sun, 17 Apr 2016 14:23:57 +0100
Message-ID: <20160417132357.GB11792@techsingularity.net>
References: <20160415214034.6ffae9ee@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: linux-mm <linux-mm@kvack.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Brenden Blanco <bblanco@plumgrid.com>, tom@herbertland.com,
	alexei.starovoitov@gmail.com, ogerlitz@mellanox.com,
	daniel@iogearbox.net, eric.dumazet@gmail.com, ecree@solarflare.com,
	john.fastabend@gmail.com, tgraf@suug.ch, johannes@sipsolutions.net,
	eranlinuxmellanox@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20160415214034.6ffae9ee@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 15, 2016 at 09:40:34PM +0200, Jesper Dangaard Brouer wrote:
> Hi Mel,
> 
> I did an experiment that you might find interesting.  Using Brenden's
> early drop with eBPF in the mxl4 driver.  I changed the mlx4 driver to
> use order-0 pages.  It usually use order-3 pages to amortize the cost
> of calling the page allocator (which is problematic for other reasons,
> like memory pin-down, latency spikes and multi CPU scalability)
> 
> With this change I could do around 12Mpps (Mill packet per sec) drops,
> usually does 14.5Mpps (limited due to a HW setup/limit, with idle cycles). 
> 
> Looking at the perf report as a FlameGraph, the page allocator clearly
> show up as the bottleneck: 
> 

Yeah, it's very obvious there. You didn't say if this had the optimisations
included or not but it doesn't really matter. Even halving the cost would
still be a lot.

FWIW, the latest series included an optimisation around the debugging
check. I also have an extreme patch that creates a special fast path for
order-0 pages only when there is plenty of free memory. It halved the
cost of the allocation side even on top of the current optimisations. I'm
not super-happy with it though as it duplicates some code and it requires
node-lru to be merged. Right now, node-lru is colliding very badly with
what's in mmotm so there is legwork required.

I also prototyped something that caches high-order pages on the per-cpu
lists on the flight over. It is at the "it builds so it must be ok"
stage. It's at the horrible hack and the accounting is quesionable but
something like it may be justified for SLUB even if network drivers move
away from high-order pages.

> Signing off, heading for the plane soon... see you at MM-summit!

Indeed and we'll slap some sort of plan together. If there is a slot free,
we might spend 15-30 minutes on it. Failing that, we'll grab a table
somewhere. We'll see how far we can get before considering a page-recycle
layer that preserves cache coherent state.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
