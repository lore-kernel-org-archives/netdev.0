From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [Lsf] [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle
 facility?
Date: Mon, 11 Apr 2016 18:19:07 +0200
Message-ID: <20160411181907.15fdb8b9@redhat.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
	<20160407161715.52635cac@redhat.com>
	<20160411085819.GE21128@suse.de>
	<20160411142639.1c5e520b@redhat.com>
	<20160411130826.GB32073@techsingularity.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Brenden Blanco <bblanco@plumgrid.com>,
	lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>,
	Mel Gorman <mgorman@suse.de>,
	Tom Herbert <tom@herbertland.com>,
	lsf-pc@lists.linux-foundation.org,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	brouer@redhat.com
To: Mel Gorman <mgorman@techsingularity.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44086 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750953AbcDKQTP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2016 12:19:15 -0400
In-Reply-To: <20160411130826.GB32073@techsingularity.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 11 Apr 2016 14:08:27 +0100 Mel Gorman <mgorman@techsingularity.net> wrote:
> On Mon, Apr 11, 2016 at 02:26:39PM +0200, Jesper Dangaard Brouer wrote:
[...]
> > 
> > It is always great if you can optimized the page allocator.  IMHO the
> > page allocator is too slow.  
> 
> It's why I spent some time on it as any improvement in the allocator is
> an unconditional win without requiring driver modifications.
> 
> > At least for my performance needs (67ns
> > per packet, approx 201 cycles at 3GHz).  I've measured[1]
> > alloc_pages(order=0) + __free_pages() to cost 277 cycles(tsc).
> >   
> 
> It'd be worth retrying this with the branch
> 
> http://git.kernel.org/cgit/linux/kernel/git/mel/linux.git/log/?h=mm-vmscan-node-lru-v4r5
> 

The cost decreased to: 228 cycles(tsc), but there are some variations,
sometimes it increase to 238 cycles(tsc).

Nice, but there is still a looong way to my performance target, where I
can spend 201 cycles for the entire forwarding path....


> This is an unreleased series that contains both the page allocator
> optimisations and the one-LRU-per-node series which in combination remove a
> lot of code from the page allocator fast paths. I have no data on how the
> combined series behaves but each series individually is known to improve
> page allocator performance.
>
> Once you have that, do a hackjob to remove the debugging checks from both the
> alloc and free path and see what that leaves. They could be bypassed properly
> with a __GFP_NOACCT flag used only by drivers that absolutely require pages
> as quickly as possible and willing to be less safe to get that performance.

I would be interested in testing/benchmarking a patch where you remove
the debugging checks...

You are also welcome to try out my benchmarking modules yourself:
 https://github.com/netoptimizer/prototype-kernel/blob/master/getting_started.rst

This is really simple stuff (for rapid prototyping) I'm just doing:
 modprobe page_bench01; rmmod page_bench01 ; dmesg | tail -n40

[...]
> 
> Be aware that compound order allocs like this are a double edged sword as
> it'll be fast sometimes and other times require reclaim/compaction which
> can stall for prolonged periods of time.

Yes, I've notice that there can be a fairly high variation, when doing
compound order allocs, which is not so nice!  I really don't like these
variations....

Drivers also do tricks where they fallback to smaller order pages. E.g.
lookup function mlx4_alloc_pages().  I've tried to simulate that
function here:
https://github.com/netoptimizer/prototype-kernel/blob/91d323fc53/kernel/mm/bench/page_bench01.c#L69

It does not seem very optimal. I tried to mem pressure the system a bit
to cause the alloc_pages() to fail, and then the result were very bad,
something like 2500 cycles, and it usually got the next order pages.


> > I've measured order 3 (32KB) alloc_pages(order=3) + __free_pages() to
> > cost approx 500 cycles(tsc).  That was more expensive, BUT an order=3
> > page 32Kb correspond to 8 pages (32768/4096), thus 500/8 = 62.5
> > cycles.  Usually a network RX-frame only need to be 2048 bytes, thus
> > the "bulk" effect speed up is x16 (32768/2048), thus 31.25 cycles.

The order=3 cost were reduced to: 417 cycles(tsc), nice!  But I've also
seen it jump to 611 cycles.


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
