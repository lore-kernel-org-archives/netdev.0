From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm, page_alloc: re-enable softirq use of per-cpu page
 allocator
Date: Tue, 11 Apr 2017 09:23:35 +0100
Message-ID: <20170411082335.i3t4fysi2rw5iydd@techsingularity.net>
References: <20170410150821.vcjlz7ntabtfsumm@techsingularity.net>
 <20170410225302.2ec8cf56@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: akpm@linux-foundation.org, willy@infradead.org, peterz@infradead.org,
	pagupta@redhat.com, ttoukan.linux@gmail.com, tariqt@mellanox.com,
	netdev@vger.kernel.org, saeedm@mellanox.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20170410225302.2ec8cf56@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 10, 2017 at 10:53:02PM +0200, Jesper Dangaard Brouer wrote:
> 
> I will appreciate review of this patch.

I had reviewed it but didn't have much to say other than the in_interrupt()
is inconvenient rather than wrong.

> My micro-benchmarking show we
> basically return to same page alloc+free cost as before 374ad05ab64d
> ("mm, page_alloc: only use per-cpu allocator for irq-safe requests").
> Which sort of invalidates this attempt of optimizing the page allocator.
> But Mel's micro-benchmarks still show an improvement.
> 

Which could be down to differences in CPUs.

> Notice the slowdown comes from me checking irqs_disabled() ... if
> someone can spot a way to get rid of that this, then this patch will be
> a win.
> 

I didn't spot an easy way of doing it. One approach which would be lighter,
if somewhat surprising, is to put a lock into the per-cpu structures that
is *not* IRQ-safe and trylock it for the per-cpu allocator. If it's !irq
allocation, it'll be uncontended. If it's an irq-allocation and contended,
it means that CPU has re-entered the allocator and must use the irq-safe
buddy lists. That would mean that for the uncontended case, both irq-safe
and irq-unsafe allocations could use the list and in the contended case, irq
allocations will still succeed. However, it would need careful development,
testing and review and not appropriate to wedge in as a fix late in the
rc cycle.

> I'm traveling out of Montreal today, and will rerun my benchmarks when
> I get home.  Tariq will also do some more testing with 100G NIC (he
> also participated in the Montreal conf, so he is likely in transit too).
> 

Rerun them please. If there is a problem or any doubt then I'll post the
revert and try this again outside of an rc cycle. That would be preferable
to releasing 4.11 with a known regression.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
