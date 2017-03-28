From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: Bisected softirq accounting issue in v4.11-rc1~170^2~28
Date: Tue, 28 Mar 2017 16:34:36 +0200
Message-ID: <20170328143431.GB4216@lerouge>
References: <20170328101403.34a82fbf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	Tariq Toukan <tariqt@mellanox.com>,
	Tariq Toukan <ttoukan.linux@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Rik van Riel <riel@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@kernel.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20170328101403.34a82fbf@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 28, 2017 at 10:14:03AM +0200, Jesper Dangaard Brouer wrote:
> 
> (While evaluating some changes to the page allocator) I ran into an
> issue with ksoftirqd getting too much CPU sched time.
> 
> I bisected the problem to
>  a499a5a14dbd ("sched/cputime: Increment kcpustat directly on irqtime account")
> 
>  a499a5a14dbd1d0315a96fc62a8798059325e9e6 is the first bad commit
>  commit a499a5a14dbd1d0315a96fc62a8798059325e9e6
>  Author: Frederic Weisbecker <fweisbec@gmail.com>
>  Date:   Tue Jan 31 04:09:32 2017 +0100
> 
>     sched/cputime: Increment kcpustat directly on irqtime account
>     
>     The irqtime is accounted is nsecs and stored in
>     cpu_irq_time.hardirq_time and cpu_irq_time.softirq_time. Once the
>     accumulated amount reaches a new jiffy, this one gets accounted to the
>     kcpustat.
>     
>     This was necessary when kcpustat was stored in cputime_t, which could at
>     worst have jiffies granularity. But now kcpustat is stored in nsecs
>     so this whole discretization game with temporary irqtime storage has
>     become unnecessary.
>     
>     We can now directly account the irqtime to the kcpustat.
>     
>     Signed-off-by: Frederic Weisbecker <fweisbec@gmail.com>
>     Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>     Cc: Fenghua Yu <fenghua.yu@intel.com>
>     Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
>     Cc: Linus Torvalds <torvalds@linux-foundation.org>
>     Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
>     Cc: Michael Ellerman <mpe@ellerman.id.au>
>     Cc: Paul Mackerras <paulus@samba.org>
>     Cc: Peter Zijlstra <peterz@infradead.org>
>     Cc: Rik van Riel <riel@redhat.com>
>     Cc: Stanislaw Gruszka <sgruszka@redhat.com>
>     Cc: Thomas Gleixner <tglx@linutronix.de>
>     Cc: Tony Luck <tony.luck@intel.com>
>     Cc: Wanpeng Li <wanpeng.li@hotmail.com>
>     Link: http://lkml.kernel.org/r/1485832191-26889-17-git-send-email-fweisbec@gmail.com
>     Signed-off-by: Ingo Molnar <mingo@kernel.org>
> 
> The reproducer is running a userspace udp_sink[1] program, and taskset
> pinning the process to the same CPU as softirq RX is running on, and
> starting a UDP flood with pktgen (tool part of kernel tree:
> samples/pktgen/pktgen_sample03_burst_single_flow.sh).

So that means I need to run udp_sink on the same CPU than pktgen?

> 
> [1] udp_sink
>  https://github.com/netoptimizer/network-testing/blob/master/src/udp_sink.c
> 
> The expected results (after commit 4cd13c21b207 ("softirq: Let
> ksoftirqd do its job")) is that the scheduler split the CPU time 50/50
> between udp_sink and ksoftirqd.

I guess you mean that this is what happened before this commit?

> 
> After this commit, the udp_sink program does not get any sched CPU
> time, and no packets are delivered to userspace.  (All packets are
> dropped by softirq due to a full socket queue, nstat UdpRcvbufErrors).
> 
> A related symptom is that ksoftirqd no longer get accounted in top.

That's indeed what I observe. udp_sink has almost no CPU time, neither has
ksoftirqd but kpktgend_0 has everything.

Finally a bug I can reproduce!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
