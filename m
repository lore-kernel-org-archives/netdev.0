From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH V5 1/1] bpf: control events stored in PERF_EVENT_ARRAY
 maps trace data output when perf sampling
Date: Fri, 23 Oct 2015 17:12:05 +0200
Message-ID: <20151023151205.GW11639@twins.programming.kicks-ass.net>
References: <56279634.5000606@huawei.com>
 <20151021134951.GH3604@twins.programming.kicks-ass.net>
 <1D2C9396-01CB-4981-B493-EA311F0457E7@163.com>
 <20151021140921.GI3604@twins.programming.kicks-ass.net>
 <586A5B33-C9C9-433D-B6E9-019264BF7DDB@163.com>
 <20151021165758.GK3604@twins.programming.kicks-ass.net>
 <56280175.8060404@plumgrid.com>
 <20151022090632.GK2508@worktop.programming.kicks-ass.net>
 <5628BA46.8060307@huawei.com>
 <20151023125211.GB17308@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@plumgrid.com>, pi3orama <pi3orama@163.com>,
	xiakaixu <xiakaixu@huawei.com>, davem@davemloft.net,
	acme@kernel.org, mingo@redhat.com, masami.hiramatsu.pt@hitachi.com,
	jolsa@kernel.org, daniel@iogearbox.net,
	linux-kernel@vger.kernel.org, hekuang@huawei.com,
	netdev@vger.kernel.org
To: "Wangnan (F)" <wangnan0@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151023125211.GB17308@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 23, 2015 at 02:52:11PM +0200, Peter Zijlstra wrote:
> On Thu, Oct 22, 2015 at 06:28:22PM +0800, Wangnan (F) wrote:
> > information to analysis when glitch happen. Another way we are trying to
> > implement
> > now is to dynamically turn events on and off, or at least enable/disable
> > sampling dynamically because the overhead of copying those samples
> > is a big part of perf's total overhead. After that we can trace as many
> > event as possible, but only fetch data from them when we detect a glitch.
> 
> So why don't you 'fix' the flight recorder mode and just leave the data
> in memory and not bother copying it out until a glitch happens?
> 
> Something like this:
> 
> lkml.kernel.org/r/20130708121557.GA17211@twins.programming.kicks-ass.net
> 
> it appears we never quite finished that.

Updated to current sources, compile tested only.

It obviously needs testing and performance numbers..  and some
userspace.

---
Subject: perf: Update event buffer tail when overwriting old events
From: Peter Zijlstra <peterz@infradead.org>

> From: "Yan, Zheng" <zheng.z.yan@intel.com>
>
> If perf event buffer is in overwrite mode, the kernel only updates
> the data head when it overwrites old samples. The program that owns
> the buffer need periodically check the buffer and update a variable
> that tracks the date tail. If the program fails to do this in time,
> the data tail can be overwritted by new samples. The program has to
> rewind the buffer because it does not know where is the first vaild
> sample.
>
> This patch makes the kernel update the date tail when it overwrites
> old events. So the program that owns the event buffer can always
> read the latest samples. This is convenient for programs that use
> perf to do branch tracing. One use case is GDB branch tracing:
> (http://sourceware.org/ml/gdb-patches/2012-06/msg00172.html)
> It uses perf interface to read BTS, but only cares the branches
> before the ptrace event.

Original-patch-by: "Yan, Zheng" <zheng.z.yan@intel.com>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/x86/kernel/cpu/perf_event_intel_ds.c |    2 
 include/linux/perf_event.h                |    6 --
 kernel/events/core.c                      |   56 +++++++++++++++++----
 kernel/events/internal.h                  |    2 
 kernel/events/ring_buffer.c               |   77 +++++++++++++++++++++---------
 5 files changed, 107 insertions(+), 36 deletions(-)

--- a/arch/x86/kernel/cpu/perf_event_intel_ds.c
+++ b/arch/x86/kernel/cpu/perf_event_intel_ds.c
@@ -1140,7 +1140,7 @@ static void __intel_pmu_pebs_event(struc
 
 	while (count > 1) {
 		setup_pebs_sample_data(event, iregs, at, &data, &regs);
-		perf_event_output(event, &data, &regs);
+		event->overflow_handler(event, &data, &regs);
 		at += x86_pmu.pebs_record_size;
 		at = get_next_pebs_record_by_bit(at, top, bit);
 		count--;
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -828,10 +828,6 @@ extern int perf_event_overflow(struct pe
 				 struct perf_sample_data *data,
 				 struct pt_regs *regs);
 
-extern void perf_event_output(struct perf_event *event,
-				struct perf_sample_data *data,
-				struct pt_regs *regs);
-
 extern void
 perf_event_header__init_id(struct perf_event_header *header,
 			   struct perf_sample_data *data,
@@ -1032,6 +1028,8 @@ static inline bool has_aux(struct perf_e
 
 extern int perf_output_begin(struct perf_output_handle *handle,
 			     struct perf_event *event, unsigned int size);
+extern int perf_output_begin_overwrite(struct perf_output_handle *handle,
+			     struct perf_event *event, unsigned int size);
 extern void perf_output_end(struct perf_output_handle *handle);
 extern unsigned int perf_output_copy(struct perf_output_handle *handle,
 			     const void *buf, unsigned int len);
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -4515,6 +4515,8 @@ static int perf_mmap_fault(struct vm_are
 	return ret;
 }
 
+static void perf_event_set_overflow(struct perf_event *event, struct ring_buffer *rb);
+
 static void ring_buffer_attach(struct perf_event *event,
 			       struct ring_buffer *rb)
 {
@@ -4546,6 +4548,8 @@ static void ring_buffer_attach(struct pe
 		spin_lock_irqsave(&rb->event_lock, flags);
 		list_add_rcu(&event->rb_entry, &rb->event_list);
 		spin_unlock_irqrestore(&rb->event_lock, flags);
+
+		perf_event_set_overflow(event, rb);
 	}
 
 	rcu_assign_pointer(event->rb, rb);
@@ -5579,9 +5583,12 @@ void perf_prepare_sample(struct perf_eve
 	}
 }
 
-void perf_event_output(struct perf_event *event,
-			struct perf_sample_data *data,
-			struct pt_regs *regs)
+static __always_inline void
+__perf_event_output(struct perf_event *event,
+		    struct perf_sample_data *data,
+		    struct pt_regs *regs,
+		    int (*output_begin)(struct perf_output_handle *,
+			                struct perf_event *, unsigned int))
 {
 	struct perf_output_handle handle;
 	struct perf_event_header header;
@@ -5591,7 +5598,7 @@ void perf_event_output(struct perf_event
 
 	perf_prepare_sample(&header, data, event, regs);
 
-	if (perf_output_begin(&handle, event, header.size))
+	if (output_begin(&handle, event, header.size))
 		goto exit;
 
 	perf_output_sample(&handle, &header, data, event);
@@ -5602,6 +5609,33 @@ void perf_event_output(struct perf_event
 	rcu_read_unlock();
 }
 
+static void perf_event_output(struct perf_event *event,
+				struct perf_sample_data *data,
+				struct pt_regs *regs)
+{
+	__perf_event_output(event, data, regs, perf_output_begin);
+}
+
+static void perf_event_output_overwrite(struct perf_event *event,
+				struct perf_sample_data *data,
+				struct pt_regs *regs)
+{
+	__perf_event_output(event, data, regs, perf_output_begin_overwrite);
+}
+
+static void
+perf_event_set_overflow(struct perf_event *event, struct ring_buffer *rb)
+{
+	if (event->overflow_handler != perf_event_output &&
+	    event->overflow_handler != perf_event_output_overwrite)
+		return;
+
+	if (rb->overwrite)
+		event->overflow_handler = perf_event_output_overwrite;
+	else
+		event->overflow_handler = perf_event_output;
+}
+
 /*
  * read event_id
  */
@@ -6426,10 +6460,7 @@ static int __perf_event_overflow(struct
 		irq_work_queue(&event->pending);
 	}
 
-	if (event->overflow_handler)
-		event->overflow_handler(event, data, regs);
-	else
-		perf_event_output(event, data, regs);
+	event->overflow_handler(event, data, regs);
 
 	if (*perf_event_fasync(event) && event->pending_kill) {
 		event->pending_wakeup = 1;
@@ -7904,8 +7935,13 @@ perf_event_alloc(struct perf_event_attr
 		context = parent_event->overflow_handler_context;
 	}
 
-	event->overflow_handler	= overflow_handler;
-	event->overflow_handler_context = context;
+	if (overflow_handler) {
+		event->overflow_handler	= overflow_handler;
+		event->overflow_handler_context = context;
+	} else {
+		event->overflow_handler = perf_event_output;
+		event->overflow_handler_context = NULL;
+	}
 
 	perf_event__state_init(event);
 
--- a/kernel/events/internal.h
+++ b/kernel/events/internal.h
@@ -21,6 +21,8 @@ struct ring_buffer {
 
 	atomic_t			poll;		/* POLL_ for wakeups */
 
+	local_t				tail;		/* read position     */
+	local_t				next_tail;	/* next read position */
 	local_t				head;		/* write position    */
 	local_t				nest;		/* nested writers    */
 	local_t				events;		/* event limit       */
--- a/kernel/events/ring_buffer.c
+++ b/kernel/events/ring_buffer.c
@@ -102,11 +102,11 @@ static void perf_output_put_handle(struc
 	preempt_enable();
 }
 
-int perf_output_begin(struct perf_output_handle *handle,
-		      struct perf_event *event, unsigned int size)
+static __always_inline int __perf_output_begin(struct perf_output_handle *handle,
+		      struct perf_event *event, unsigned int size, bool overwrite)
 {
 	struct ring_buffer *rb;
-	unsigned long tail, offset, head;
+	unsigned long tail, offset, head, max_size;
 	int have_lost, page_shift;
 	struct {
 		struct perf_event_header header;
@@ -125,7 +125,8 @@ int perf_output_begin(struct perf_output
 	if (unlikely(!rb))
 		goto out;
 
-	if (unlikely(!rb->nr_pages))
+	max_size = perf_data_size(rb);
+	if (unlikely(size > max_size))
 		goto out;
 
 	handle->rb    = rb;
@@ -140,27 +141,49 @@ int perf_output_begin(struct perf_output
 
 	perf_output_get_handle(handle);
 
-	do {
-		tail = READ_ONCE_CTRL(rb->user_page->data_tail);
-		offset = head = local_read(&rb->head);
-		if (!rb->overwrite &&
-		    unlikely(CIRC_SPACE(head, tail, perf_data_size(rb)) < size))
-			goto fail;
+	if (overwrite) {
+		do {
+			tail = local_read(&rb->tail);
+			offset = local_read(&rb->head);
+			head = offset + size;
+			if (unlikely(CIRC_SPACE(head, tail, max_size) < size)) {
+				tail = local_read(&rb->next_tail);
+				local_set(&rb->tail, tail);
+				rb->user_page->data_tail = tail;
+			}
+		} while (local_cmpxchg(&rb->head, offset, head) != offset);
 
 		/*
-		 * The above forms a control dependency barrier separating the
-		 * @tail load above from the data stores below. Since the @tail
-		 * load is required to compute the branch to fail below.
-		 *
-		 * A, matches D; the full memory barrier userspace SHOULD issue
-		 * after reading the data and before storing the new tail
-		 * position.
-		 *
-		 * See perf_output_put_handle().
+		 * Save the start of next event when half of the buffer
+		 * has been filled. Later when the event buffer overflows,
+		 * update the tail pointer to point to it.
 		 */
+		if (tail == local_read(&rb->next_tail) &&
+		    CIRC_CNT(head, tail, max_size) >= (max_size / 2))
+			local_cmpxchg(&rb->next_tail, tail, head);
+	} else {
+		do {
+			tail = READ_ONCE_CTRL(rb->user_page->data_tail);
+			offset = head = local_read(&rb->head);
+			if (!rb->overwrite &&
+			    unlikely(CIRC_SPACE(head, tail, perf_data_size(rb)) < size))
+				goto fail;
+
+			/*
+			 * The above forms a control dependency barrier separating the
+			 * @tail load above from the data stores below. Since the @tail
+			 * load is required to compute the branch to fail below.
+			 *
+			 * A, matches D; the full memory barrier userspace SHOULD issue
+			 * after reading the data and before storing the new tail
+			 * position.
+			 *
+			 * See perf_output_put_handle().
+			 */
 
-		head += size;
-	} while (local_cmpxchg(&rb->head, offset, head) != offset);
+			head += size;
+		} while (local_cmpxchg(&rb->head, offset, head) != offset);
+	}
 
 	/*
 	 * We rely on the implied barrier() by local_cmpxchg() to ensure
@@ -203,6 +226,18 @@ int perf_output_begin(struct perf_output
 	return -ENOSPC;
 }
 
+int perf_output_begin(struct perf_output_handle *handle,
+		      struct perf_event *event, unsigned int size)
+{
+	return __perf_output_begin(handle, event, size, false);
+}
+
+int perf_output_begin_overwrite(struct perf_output_handle *handle,
+		      struct perf_event *event, unsigned int size)
+{
+	return __perf_output_begin(handle, event, size, true);
+}
+
 unsigned int perf_output_copy(struct perf_output_handle *handle,
 		      const void *buf, unsigned int len)
 {
