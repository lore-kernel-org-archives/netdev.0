From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] Revert "mm, page_alloc: only use per-cpu allocator for
 irq-safe requests"
Date: Sat, 15 Apr 2017 20:57:35 +0100
Message-ID: <20170415195734.avk2zk237a2oe5cd@techsingularity.net>
References: <20170415145350.ixy7vtrzdzve57mh@techsingularity.net>
 <20170415212833.30ed3f2b@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Andrew Morton <akpm@linux-foundation.org>, willy@infradead.org,
	peterz@infradead.org, pagupta@redhat.com, ttoukan.linux@gmail.com,
	tariqt@mellanox.com, netdev@vger.kernel.org, saeedm@mellanox.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20170415212833.30ed3f2b@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 15, 2017 at 09:28:33PM +0200, Jesper Dangaard Brouer wrote:
> On Sat, 15 Apr 2017 15:53:50 +0100
> Mel Gorman <mgorman@techsingularity.net> wrote:
> 
> > This reverts commit 374ad05ab64d696303cec5cc8ec3a65d457b7b1c. While the
> > patch worked great for userspace allocations, the fact that softirq loses
> > the per-cpu allocator caused problems. It needs to be redone taking into
> > account that a separate list is needed for hard/soft IRQs or alternatively
> > find a cheap way of detecting reentry due to an interrupt. Both are possible
> > but sufficiently tricky that it shouldn't be rushed. Jesper had one method
> > for allowing softirqs but reported that the cost was high enough that it
> > performed similarly to a plain revert. His figures for netperf TCP_STREAM
> > were as follows
> > 
> > Baseline v4.10.0  : 60316 Mbit/s
> > Current 4.11.0-rc6: 47491 Mbit/s
> > This patch        : 60662 Mbit/s
> (should instead state "Jesper's patch" or "His patch")
> 

Yes, you are correct of course.

> Ran same test (8 parallel netperf TCP_STREAMs) with this patch applied:
> 
>  This patch 60106 Mbit/s (average of 7 iteration 60 sec runs)
> 
> With these speeds I'm starting to hit the memory bandwidth of my machines.
> Thus, the 60 GBit/s measurement cannot be used to validate the
> performance impact of reverting this compared to my softirq patch, it
> only shows we fixed the regression.  (I'm suspicious as I see a higher
> contention on the page allocator lock (4% vs 1.3%) with this patch and
> still same performance... but lets worry about that outside the rc-series).
> 

Well, in itself that limitation highlights that evaluating this is
challenging and needs careful treatment. Otherwise two different
approaches can seem equivalent only because a hardware-related
bottleneck was at play.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
