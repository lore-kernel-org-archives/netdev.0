From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 4/6] perf, bpf: add perf events core support for BPF_PROG_TYPE_PERF_EVENT programs
Date: Fri, 26 Aug 2016 19:31:22 -0700
Message-ID: <1472265084-1767670-5-git-send-email-ast@fb.com>
References: <1472265084-1767670-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <peterz@infradead.org>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Arnaldo Carvalho de Melo <acme@infradead.org>,
        Wang Nan <wangnan0@huawei.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472265084-1767670-1-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow attaching BPF_PROG_TYPE_PERF_EVENT programs to sw and hw perf events
via overflow_handler mechanism.
When program is attached the overflow_handlers become stacked.
The program acts as a filter.
Returning zero from the program means that the normal perf_event_output handler
will not be called and sampling event won't be stored in the ring buffer.

The overflow_handler_context==NULL is an additional safety check
to make sure programs are not attached to hw breakpoints and watchdog
in case other checks (that prevent that now anyway) get accidentally
relaxed in the future.

The program refcnt is incremented in case perf_events are inhereted
when target task is forked.
Similar to kprobe and tracepoint programs there is no ioctl to
detach the program or swap already attached program. The user space
expected to close(perf_event_fd) like it does right now for kprobe+bpf.
That restriction simplifies the code quite a bit.

The invocation of overflow_handler in __perf_event_overflow() is now
done via READ_ONCE, since that pointer can be replaced when the program
is attached while perf_event itself could have been active already.
There is no need to do similar treatment for event->prog, since it's
assigned only once before it's accessed.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/bpf.h        |  4 +++
 include/linux/perf_event.h |  2 ++
 kernel/events/core.c       | 82 +++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 87 insertions(+), 1 deletion(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 11134238417d..9a904f63f8c1 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -297,6 +297,10 @@ static inline struct bpf_prog *bpf_prog_add(struct bpf_prog *prog, int i)
 static inline void bpf_prog_put(struct bpf_prog *prog)
 {
 }
+static inline struct bpf_prog *bpf_prog_inc(struct bpf_prog *prog)
+{
+	return ERR_PTR(-EOPNOTSUPP);
+}
 #endif /* CONFIG_BPF_SYSCALL */
 
 /* verifier prototypes for helper functions called from eBPF programs */
diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
index 97bfe62f30d7..dcaaaf3ec8e6 100644
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -679,6 +679,8 @@ struct perf_event {
 	u64				(*clock)(void);
 	perf_overflow_handler_t		overflow_handler;
 	void				*overflow_handler_context;
+	perf_overflow_handler_t		orig_overflow_handler;
+	struct bpf_prog			*prog;
 
 #ifdef CONFIG_EVENT_TRACING
 	struct trace_event_call		*tp_event;
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 1903b8f3a705..282920cd8f5f 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -6987,7 +6987,7 @@ static int __perf_event_overflow(struct perf_event *event,
 		irq_work_queue(&event->pending);
 	}
 
-	event->overflow_handler(event, data, regs);
+	READ_ONCE(event->overflow_handler)(event, data, regs);
 
 	if (*perf_event_fasync(event) && event->pending_kill) {
 		event->pending_wakeup = 1;
@@ -7602,11 +7602,75 @@ static void perf_event_free_filter(struct perf_event *event)
 	ftrace_profile_free_filter(event);
 }
 
+static void bpf_overflow_handler(struct perf_event *event,
+				 struct perf_sample_data *data,
+				 struct pt_regs *regs)
+{
+	struct bpf_perf_event_data_kern ctx = {
+		.data = data,
+		.regs = regs,
+	};
+	int ret = 0;
+
+#ifdef CONFIG_BPF_SYSCALL
+	preempt_disable();
+	if (unlikely(__this_cpu_inc_return(bpf_prog_active) != 1))
+		goto out;
+	rcu_read_lock();
+	ret = BPF_PROG_RUN(event->prog, (void *)&ctx);
+	rcu_read_unlock();
+ out:
+	__this_cpu_dec(bpf_prog_active);
+	preempt_enable();
+#endif
+	if (!ret)
+		return;
+
+	event->orig_overflow_handler(event, data, regs);
+}
+
+static int perf_event_set_bpf_handler(struct perf_event *event, u32 prog_fd)
+{
+	struct bpf_prog *prog;
+
+	if (event->overflow_handler_context)
+		/* hw breakpoint or kernel counter */
+		return -EINVAL;
+
+	if (event->prog)
+		return -EEXIST;
+
+	prog = bpf_prog_get_type(prog_fd, BPF_PROG_TYPE_PERF_EVENT);
+	if (IS_ERR(prog))
+		return PTR_ERR(prog);
+
+	event->prog = prog;
+	event->orig_overflow_handler = READ_ONCE(event->overflow_handler);
+	WRITE_ONCE(event->overflow_handler, bpf_overflow_handler);
+	return 0;
+}
+
+static void perf_event_free_bpf_handler(struct perf_event *event)
+{
+	struct bpf_prog *prog = event->prog;
+
+	if (!prog)
+		return;
+
+	WRITE_ONCE(event->overflow_handler, event->orig_overflow_handler);
+	event->prog = NULL;
+	bpf_prog_put(prog);
+}
+
 static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd)
 {
 	bool is_kprobe, is_tracepoint;
 	struct bpf_prog *prog;
 
+	if (event->attr.type == PERF_TYPE_HARDWARE ||
+	    event->attr.type == PERF_TYPE_SOFTWARE)
+		return perf_event_set_bpf_handler(event, prog_fd);
+
 	if (event->attr.type != PERF_TYPE_TRACEPOINT)
 		return -EINVAL;
 
@@ -7647,6 +7711,8 @@ static void perf_event_free_bpf_prog(struct perf_event *event)
 {
 	struct bpf_prog *prog;
 
+	perf_event_free_bpf_handler(event);
+
 	if (!event->tp_event)
 		return;
 
@@ -7675,6 +7741,12 @@ static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd)
 static void perf_event_free_bpf_prog(struct perf_event *event)
 {
 }
+
+static void bpf_overflow_handler(struct perf_event *event,
+				 struct perf_sample_data *data,
+				 struct pt_regs *regs)
+{
+}
 #endif /* CONFIG_EVENT_TRACING */
 
 #ifdef CONFIG_HAVE_HW_BREAKPOINT
@@ -8957,6 +9029,14 @@ perf_event_alloc(struct perf_event_attr *attr, int cpu,
 	if (!overflow_handler && parent_event) {
 		overflow_handler = parent_event->overflow_handler;
 		context = parent_event->overflow_handler_context;
+		if (overflow_handler == bpf_overflow_handler) {
+			event->prog = bpf_prog_inc(parent_event->prog);
+			event->orig_overflow_handler = parent_event->orig_overflow_handler;
+			if (IS_ERR(event->prog)) {
+				event->prog = NULL;
+				overflow_handler = NULL;
+			}
+		}
 	}
 
 	if (overflow_handler) {
-- 
2.8.0
