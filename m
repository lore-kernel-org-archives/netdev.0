From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Heads-up: two regressions in v4.11-rc series
Date: Thu, 20 Apr 2017 11:00:42 +0200
Message-ID: <20170420110042.73d01e0f@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, Mel Gorman <mgorman@techsingularity.net>, Tariq
 Toukan <tariqt@mellanox.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm
 <linux-mm@kvack.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 peterz@infradead.org
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton
 <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Hi Linus,

Just wanted to give a heads-up on two regressions in 4.11-rc series.

(1) page allocator optimization revert

Mel Gorman and I have been playing with optimizing the page allocator,
but Tariq spotted that we caused a regression for (NIC) drivers that
refill DMA RX rings in softirq context.

The end result was a revert, and this is waiting in AKPMs quilt queue:
 http://ozlabs.org/~akpm/mmots/broken-out/revert-mm-page_alloc-only-use-per-cpu-allocator-for-irq-safe-requests.patch


(2) Busy softirq can cause userspace not to be scheduled

I bisected the problem to a499a5a14dbd ("sched/cputime: Increment
kcpustat directly on irqtime account"). See email thread with
 Subject: Bisected softirq accounting issue in v4.11-rc1~170^2~28
 http://lkml.kernel.org/r/20170328101403.34a82fbf@redhat.com

I don't know the scheduler code well enough to fix this, and will have
to rely others to figure out this scheduler regression.

To make it clear: I'm only seeing this scheduler regression when a
remote host is sending many many network packets, towards the kernel
which keeps NAPI/softirq busy all the time.  A possible hint: tool
"top" only shows this in "si" column, while on v4.10 "top" also blames
"ksoftirqd/N", plus "ps" reported cputime (0:00) seems wrong for ksoftirqd.


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
