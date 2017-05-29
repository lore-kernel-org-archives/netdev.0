From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 net-next 1/3] perf, bpf: Add BPF support to all
 perf_event types
Date: Mon, 29 May 2017 11:39:18 +0200
Message-ID: <20170529093918.xmbijgozjrfi22ru@hirez.programming.kicks-ass.net>
References: <20170526055549.557818-1-ast@fb.com>
 <20170526055549.557818-2-ast@fb.com>
 <20170529091253.lopsd33qticsbgii@hirez.programming.kicks-ass.net>
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
In-Reply-To: <20170529091253.lopsd33qticsbgii@hirez.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 29, 2017 at 11:12:53AM +0200, Peter Zijlstra wrote:
> On Thu, May 25, 2017 at 10:55:47PM -0700, Alexei Starovoitov wrote:
> 
> > +++ b/kernel/bpf/arraymap.c
> > @@ -462,26 +462,22 @@ static void *perf_event_fd_array_get_ptr(struct bpf_map *map,
> >  
> >  	event = perf_file->private_data;
> >  	ee = ERR_PTR(-EINVAL);
> > +	/* Per-task events are not supported */
> > +	if (event->attach_state & PERF_ATTACH_TASK)
> > +		goto err_out;
> >  
> >  	attr = perf_event_attrs(event);
> >  	if (IS_ERR(attr) || attr->inherit)
> >  		goto err_out;
> 
> > +	/* TRACEPOINT and BREAKPOINT not supported in perf_event_read_local */
> 
> I cannot find reason for this comment. That is, why would
> perf_event_read_local() not support those two types?
> 
> > +	if (attr->type == PERF_TYPE_TRACEPOINT ||
> > +	    attr->type == PERF_TYPE_BREAKPOINT)
> > +		goto err_out;
> >  
> > +	ee = bpf_event_entry_gen(perf_file, map_file);
> > +	if (ee)
> > +		return ee;
> > +	ee = ERR_PTR(-ENOMEM);
> >  
> >  err_out:
> >  	fput(perf_file);


Do we want something like the below to replace much of the above?

	if (!perf_event_valid_local(event, NULL, cpu))
		goto err_out;

Seems to be roughly what you're after, although I suppose @cpu might be
hard to determine a priory, so maybe we should allow a magic value to
short-circuit that test.

---
 kernel/events/core.c | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/kernel/events/core.c b/kernel/events/core.c
index 8d6acaeeea17..a7dc34f19568 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -3630,6 +3630,36 @@ static inline u64 perf_event_count(struct perf_event *event)
 }
 
 /*
+ * perf_event_valid_local() - validates if the event is usable by perf_event_read_local()
+ * event: the event to validate
+ * task:  the task the @event will be used in
+ * cpu:   the cpu the @event will be used on
+ *
+ * In case one wants to disallow all per-task events, use @task = NULL.
+ * In case one wants to disallow all per-cpu events, use @cpu = -1.
+ */
+bool perf_event_valid_local(struct perf_event *event, struct task_struct *task, int cpu)
+{
+	/* See perf_event_read_local() for the reasons for these tests */
+
+	if ((event->attach_state & PERF_ATTACH_TASK) &&
+	    event->hw.target != task)
+		return false;
+
+	if (!(event->attach_state & PERF_ATTACH_TASK) &&
+	    event->cpu != cpu)
+		return false;
+
+	if (event->attr.inherit)
+		return false;
+
+	if (event->pmu->count)
+		return false;
+
+	return true;
+}
+
+/*
  * NMI-safe method to read a local event, that is an event that
  * is:
  *   - either for the current task, or for this CPU
