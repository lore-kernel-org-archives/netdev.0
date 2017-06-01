From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 net-next 1/3] perf, bpf: Add BPF support to all
 perf_event types
Date: Thu, 1 Jun 2017 15:32:16 +0200
Message-ID: <20170601133216.oxroqy4z5qjwvrdm@hirez.programming.kicks-ass.net>
References: <20170526055549.557818-1-ast@fb.com>
 <20170526055549.557818-2-ast@fb.com>
 <20170529091253.lopsd33qticsbgii@hirez.programming.kicks-ass.net>
 <20170529093918.xmbijgozjrfi22ru@hirez.programming.kicks-ass.net>
 <a6bf362c-9df9-f387-bac3-ab5516e4cb68@fb.com>
 <20170530165102.kvcutyfp6i2in2zx@hirez.programming.kicks-ass.net>
 <132719d0-a18c-d4a0-8e72-56658c0c344f@fb.com>
 <20170530190339.svpp53bggfznc476@hirez.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Teng Qin <qinteng@fb.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170530190339.svpp53bggfznc476@hirez.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 30, 2017 at 09:03:39PM +0200, Peter Zijlstra wrote:
> On Tue, May 30, 2017 at 10:37:46AM -0700, Alexei Starovoitov wrote:
> > On 5/30/17 9:51 AM, Peter Zijlstra wrote:
> 
> > > I'm not entirely sure I see how that is required. Should per task not
> > > already work? The WARN that's there will only trigger if you call them
> > > on the wrong task, which is something you shouldn't do anyway.
> > 
> > The kernel WARN is considered to be a bug of bpf infra. That's the
> > reason we do all these checks at map update time and at run-time.
> > The bpf program authors should be able to do all possible experiments
> > until their scripts work. Dealing with kernel warns and reboots is not
> > something user space folks like to do.
> > Today bpf_perf_event_read() for per-task events isn't really
> > working due to event->oncpu != cpu runtime check in there.
> > If we convert warns to returns the existing scripts will continue
> > to work as-is and per-task will be possible.
> 
> Ah yes.. I always forget that side of things (not ever having seen a
> bpf thing working doesn't help either of course).
> 
> Let me consider that for a bit..

OK, do that. Something like the below should do I suppose.

It will return -EOPNOTSUPP for permanent failure (it cannot ever work)
and -EINVAL for temporary failure (could work if you call it on another
task/cpu).

---
 kernel/events/core.c | 41 +++++++++++++++++++++++++++--------------
 1 file changed, 27 insertions(+), 14 deletions(-)

diff --git a/kernel/events/core.c b/kernel/events/core.c
index 8d6acaeeea17..22b6407da374 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -3637,10 +3637,10 @@ static inline u64 perf_event_count(struct perf_event *event)
  *     will not be local and we cannot read them atomically
  *   - must not have a pmu::count method
  */
-u64 perf_event_read_local(struct perf_event *event)
+int perf_event_read_local(struct perf_event *event, u64 *value)
 {
 	unsigned long flags;
-	u64 val;
+	int ret = 0;
 
 	/*
 	 * Disabling interrupts avoids all counter scheduling (context
@@ -3648,25 +3648,37 @@ u64 perf_event_read_local(struct perf_event *event)
 	 */
 	local_irq_save(flags);
 
-	/* If this is a per-task event, it must be for current */
-	WARN_ON_ONCE((event->attach_state & PERF_ATTACH_TASK) &&
-		     event->hw.target != current);
-
-	/* If this is a per-CPU event, it must be for this CPU */
-	WARN_ON_ONCE(!(event->attach_state & PERF_ATTACH_TASK) &&
-		     event->cpu != smp_processor_id());
-
 	/*
 	 * It must not be an event with inherit set, we cannot read
 	 * all child counters from atomic context.
 	 */
-	WARN_ON_ONCE(event->attr.inherit);
+	if (event->attr.inherit) {
+		ret = -EOPNOTSUPP;
+		goto out;
+	}
 
 	/*
 	 * It must not have a pmu::count method, those are not
 	 * NMI safe.
 	 */
-	WARN_ON_ONCE(event->pmu->count);
+	if (event->pmu->count) {
+		ret = -EOPNOTSUPP;
+		goto out;
+	}
+
+	/* If this is a per-task event, it must be for current */
+	if ((event->attach_state & PERF_ATTACH_TASK) &&
+	    event->hw.target != current) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	/* If this is a per-CPU event, it must be for this CPU */
+	if (!(event->attach_state & PERF_ATTACH_TASK) &&
+	    event->cpu != smp_processor_id()) {
+		ret = -EINVAL;
+		goto out;
+	}
 
 	/*
 	 * If the event is currently on this CPU, its either a per-task event,
@@ -3676,10 +3688,11 @@ u64 perf_event_read_local(struct perf_event *event)
 	if (event->oncpu == smp_processor_id())
 		event->pmu->read(event);
 
-	val = local64_read(&event->count);
+	*value = local64_read(&event->count);
+out:
 	local_irq_restore(flags);
 
-	return val;
+	return ret;
 }
 
 static int perf_event_read(struct perf_event *event, bool group)
