From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, page_alloc: re-enable softirq use of per-cpu page
 allocator
Date: Mon, 10 Apr 2017 14:26:16 -0700
Message-ID: <20170410142616.6d37a11904dd153298cf7f3b@linux-foundation.org>
References: <20170410150821.vcjlz7ntabtfsumm@techsingularity.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, willy@infradead.org, peterz@infradead.org,
 pagupta@redhat.com, ttoukan.linux@gmail.com, tariqt@mellanox.com,
 netdev@vger.kernel.org, saeedm@mellanox.com, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
To: Mel Gorman <mgorman@techsingularity.net>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20170410150821.vcjlz7ntabtfsumm@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, 10 Apr 2017 16:08:21 +0100 Mel Gorman <mgorman@techsingularity.net> wrote:

> IRQ context were excluded from using the Per-Cpu-Pages (PCP) lists caching
> of order-0 pages in commit 374ad05ab64d ("mm, page_alloc: only use per-cpu
> allocator for irq-safe requests").
> 
> This unfortunately also included excluded SoftIRQ.  This hurt the performance
> for the use-case of refilling DMA RX rings in softirq context.

Out of curiosity: by how much did it "hurt"?

<ruffles through the archives>

Tariq found:

: I disabled the page-cache (recycle) mechanism to stress the page
: allocator, and see a drastic degradation in BW, from 47.5 G in v4.10 to
: 31.4 G in v4.11-rc1 (34% drop).

then with this patch he found

: It looks very good!  I get line-rate (94Gbits/sec) with 8 streams, in
: comparison to less than 55Gbits/sec before.

Can I take this to mean that the page allocator's per-cpu-pages feature
ended up doubling the performance of this driver?  Better than the
driver's private page recycling?  I'd like to believe that, but am
having trouble doing so ;)

> This patch re-allow softirq context, which should be safe by disabling
> BH/softirq, while accessing the list.  PCP-lists access from both hard-IRQ
> and NMI context must not be allowed.  Peter Zijlstra says in_nmi() code
> never access the page allocator, thus it should be sufficient to only test
> for !in_irq().
> 
> One concern with this change is adding a BH (enable) scheduling point at
> both PCP alloc and free. If further concerns are highlighted by this patch,
> the result wiill be to revert 374ad05ab64d and try again at a later date
> to offset the irq enable/disable overhead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
