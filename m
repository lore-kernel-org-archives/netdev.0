From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 1/2] bpf: add a bpf_override_function helper
Date: Wed,  1 Nov 2017 13:00:42 -0400
Message-ID: <1509555643-2899-2-git-send-email-josef@toxicpanda.com>
References: <1509555643-2899-1-git-send-email-josef@toxicpanda.com>
Cc: Josef Bacik <jbacik@fb.com>
To: rostedt@goodmis.org, mingo@redhat.com, davem@davemloft.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        ast@kernel.org, kernel-team@fb.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1509555643-2899-1-git-send-email-josef@toxicpanda.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Josef Bacik <jbacik@fb.com>

Error injection is sloppy and very ad-hoc.  BPF could fill this niche
perfectly with it's kprobe functionality.  We could make sure errors are
only triggered in specific call chains that we care about with very
specific situations.  Accomplish this with the bpf_override_funciton
helper.  This will modify the probe'd callers return value to the
specified value and set the PC to an override function that simply
returns, bypassing the originally probed function.  This gives us a nice
clean way to implement systematic error injection for all of our code
paths.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 arch/Kconfig                     |  3 +++
 arch/x86/Kconfig                 |  1 +
 arch/x86/include/asm/kprobes.h   |  4 ++++
 arch/x86/include/asm/ptrace.h    |  5 +++++
 arch/x86/kernel/kprobes/ftrace.c | 14 ++++++++++++++
 include/linux/filter.h           |  3 ++-
 include/linux/trace_events.h     |  1 +
 include/uapi/linux/bpf.h         |  7 ++++++-
 kernel/bpf/verifier.c            |  2 ++
 kernel/events/core.c             |  7 +++++++
 kernel/trace/Kconfig             | 11 +++++++++++
 kernel/trace/bpf_trace.c         | 33 +++++++++++++++++++++++++++++++++
 kernel/trace/trace_kprobe.c      | 40 +++++++++++++++++++++++++++++++++-------
 kernel/trace/trace_probe.h       |  2 ++
 14 files changed, 124 insertions(+), 9 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index d789a89cb32c..4fb618082259 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -195,6 +195,9 @@ config HAVE_OPTPROBES
 config HAVE_KPROBES_ON_FTRACE
 	bool
 
+config HAVE_KPROBE_OVERRIDE
+	bool
+
 config HAVE_NMI
 	bool
 
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 971feac13506..5126d2750dd0 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -152,6 +152,7 @@ config X86
 	select HAVE_KERNEL_XZ
 	select HAVE_KPROBES
 	select HAVE_KPROBES_ON_FTRACE
+	select HAVE_KPROBE_OVERRIDE
 	select HAVE_KRETPROBES
 	select HAVE_KVM
 	select HAVE_LIVEPATCH			if X86_64
diff --git a/arch/x86/include/asm/kprobes.h b/arch/x86/include/asm/kprobes.h
index 6cf65437b5e5..c6c3b1f4306a 100644
--- a/arch/x86/include/asm/kprobes.h
+++ b/arch/x86/include/asm/kprobes.h
@@ -67,6 +67,10 @@ extern const int kretprobe_blacklist_size;
 void arch_remove_kprobe(struct kprobe *p);
 asmlinkage void kretprobe_trampoline(void);
 
+#ifdef CONFIG_KPROBES_ON_FTRACE
+extern void arch_ftrace_kprobe_override_function(struct pt_regs *regs);
+#endif
+
 /* Architecture specific copy of original instruction*/
 struct arch_specific_insn {
 	/* copy of the original instruction */
diff --git a/arch/x86/include/asm/ptrace.h b/arch/x86/include/asm/ptrace.h
index 91c04c8e67fa..f04e71800c2f 100644
--- a/arch/x86/include/asm/ptrace.h
+++ b/arch/x86/include/asm/ptrace.h
@@ -108,6 +108,11 @@ static inline unsigned long regs_return_value(struct pt_regs *regs)
 	return regs->ax;
 }
 
+static inline void regs_set_return_value(struct pt_regs *regs, unsigned long rc)
+{
+	regs->ax = rc;
+}
+
 /*
  * user_mode(regs) determines whether a register set came from user
  * mode.  On x86_32, this is true if V8086 mode was enabled OR if the
diff --git a/arch/x86/kernel/kprobes/ftrace.c b/arch/x86/kernel/kprobes/ftrace.c
index 041f7b6dfa0f..3c455bf490cb 100644
--- a/arch/x86/kernel/kprobes/ftrace.c
+++ b/arch/x86/kernel/kprobes/ftrace.c
@@ -97,3 +97,17 @@ int arch_prepare_kprobe_ftrace(struct kprobe *p)
 	p->ainsn.boostable = false;
 	return 0;
 }
+
+asmlinkage void override_func(void);
+asm(
+	".type override_func, @function\n"
+	"override_func:\n"
+	"	ret\n"
+	".size override_func, .-override_func\n"
+);
+
+void arch_ftrace_kprobe_override_function(struct pt_regs *regs)
+{
+	regs->ip = (unsigned long)&override_func;
+}
+NOKPROBE_SYMBOL(arch_ftrace_kprobe_override_function);
diff --git a/include/linux/filter.h b/include/linux/filter.h
index cdd78a7beaae..dfa44fd74bae 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -458,7 +458,8 @@ struct bpf_prog {
 				locked:1,	/* Program image locked? */
 				gpl_compatible:1, /* Is filter GPL compatible? */
 				cb_access:1,	/* Is control block accessed? */
-				dst_needed:1;	/* Do we need dst entry? */
+				dst_needed:1,	/* Do we need dst entry? */
+				kprobe_override:1; /* Do we override a kprobe? */
 	kmemcheck_bitfield_end(meta);
 	enum bpf_prog_type	type;		/* Type of BPF program */
 	u32			len;		/* Number of filter blocks */
diff --git a/include/linux/trace_events.h b/include/linux/trace_events.h
index fc6aeca945db..be8bd5a8efaa 100644
--- a/include/linux/trace_events.h
+++ b/include/linux/trace_events.h
@@ -522,6 +522,7 @@ do {									\
 struct perf_event;
 
 DECLARE_PER_CPU(struct pt_regs, perf_trace_regs);
+DECLARE_PER_CPU(int, bpf_kprobe_override);
 
 extern int  perf_trace_init(struct perf_event *event);
 extern void perf_trace_destroy(struct perf_event *event);
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 0b7b54d898bd..1ad5b87a42f6 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -673,6 +673,10 @@ union bpf_attr {
  *     @buf: buf to fill
  *     @buf_size: size of the buf
  *     Return : 0 on success or negative error code
+ *
+ * int bpf_override_return(pt_regs, rc)
+ *	@pt_regs: pointer to struct pt_regs
+ *	@rc: the return value to set
  */
 #define __BPF_FUNC_MAPPER(FN)		\
 	FN(unspec),			\
@@ -732,7 +736,8 @@ union bpf_attr {
 	FN(xdp_adjust_meta),		\
 	FN(perf_event_read_value),	\
 	FN(perf_prog_read_value),	\
-	FN(getsockopt),
+	FN(getsockopt),			\
+	FN(override_return),
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index d906775e12c1..f8f7927a9152 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -4189,6 +4189,8 @@ static int fixup_bpf_calls(struct bpf_verifier_env *env)
 			prog->dst_needed = 1;
 		if (insn->imm == BPF_FUNC_get_prandom_u32)
 			bpf_user_rnd_init_once();
+		if (insn->imm == BPF_FUNC_override_return)
+			prog->kprobe_override = 1;
 		if (insn->imm == BPF_FUNC_tail_call) {
 			/* If we tail call into other programs, we
 			 * cannot make any assumptions since they can
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 9660ee65fbef..0d7fce52391d 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -8169,6 +8169,13 @@ static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd)
 		return -EINVAL;
 	}
 
+	/* Kprobe override only works for kprobes, not uprobes. */
+	if (prog->kprobe_override &&
+	    !(event->tp_event->flags & TRACE_EVENT_FL_KPROBE)) {
+		bpf_prog_put(prog);
+		return -EINVAL;
+	}
+
 	if (is_tracepoint || is_syscall_tp) {
 		int off = trace_event_get_offsets(event->tp_event);
 
diff --git a/kernel/trace/Kconfig b/kernel/trace/Kconfig
index 434c840e2d82..9dc0deeaad2b 100644
--- a/kernel/trace/Kconfig
+++ b/kernel/trace/Kconfig
@@ -518,6 +518,17 @@ config FUNCTION_PROFILER
 
 	  If in doubt, say N.
 
+config BPF_KPROBE_OVERRIDE
+	bool "Enable BPF programs to override a kprobed function"
+	depends on BPF_EVENTS
+	depends on KPROBES_ON_FTRACE
+	depends on HAVE_KPROBE_OVERRIDE
+	depends on DYNAMIC_FTRACE_WITH_REGS
+	default n
+	help
+	 Allows BPF to override the execution of a probed function and
+	 set a different return value.  This is used for error injection.
+
 config FTRACE_MCOUNT_RECORD
 	def_bool y
 	depends on DYNAMIC_FTRACE
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 136aa6bb0422..430f864bfe6c 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -13,6 +13,10 @@
 #include <linux/filter.h>
 #include <linux/uaccess.h>
 #include <linux/ctype.h>
+#include <linux/kprobes.h>
+#include <asm/kprobes.h>
+
+#include "trace_probe.h"
 #include "trace.h"
 
 u64 bpf_get_stackid(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
@@ -76,6 +80,29 @@ unsigned int trace_call_bpf(struct trace_event_call *call, void *ctx)
 }
 EXPORT_SYMBOL_GPL(trace_call_bpf);
 
+#ifdef CONFIG_BPF_KPROBE_OVERRIDE
+BPF_CALL_2(bpf_override_return, struct pt_regs *, regs, unsigned long, rc)
+{
+	__this_cpu_write(bpf_kprobe_override, 1);
+	regs_set_return_value(regs, rc);
+	arch_ftrace_kprobe_override_function(regs);
+	return 0;
+}
+#else
+BPF_CALL_2(bpf_override_return, struct pt_regs *, regs, unsigned long, rc)
+{
+	return -EINVAL;
+}
+#endif
+
+static const struct bpf_func_proto bpf_override_return_proto = {
+	.func		= bpf_override_return,
+	.gpl_only	= true,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_ANYTHING,
+};
+
 BPF_CALL_3(bpf_probe_read, void *, dst, u32, size, const void *, unsafe_ptr)
 {
 	int ret;
@@ -551,6 +578,8 @@ static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func
 		return &bpf_get_stackid_proto;
 	case BPF_FUNC_perf_event_read_value:
 		return &bpf_perf_event_read_value_proto;
+	case BPF_FUNC_override_return:
+		return &bpf_override_return_proto;
 	default:
 		return tracing_func_proto(func_id);
 	}
@@ -766,6 +795,10 @@ int perf_event_attach_bpf_prog(struct perf_event *event,
 	struct bpf_prog_array *new_array;
 	int ret = -EEXIST;
 
+	/* Kprobe override only works for ftrace based kprobes. */
+	if (prog->kprobe_override && !trace_kprobe_ftrace(event->tp_event))
+		return -EINVAL;
+
 	mutex_lock(&bpf_event_mutex);
 
 	if (event->prog)
diff --git a/kernel/trace/trace_kprobe.c b/kernel/trace/trace_kprobe.c
index abf92e478cfb..8e3c9ec1faf7 100644
--- a/kernel/trace/trace_kprobe.c
+++ b/kernel/trace/trace_kprobe.c
@@ -42,6 +42,7 @@ struct trace_kprobe {
 	(offsetof(struct trace_kprobe, tp.args) +	\
 	(sizeof(struct probe_arg) * (n)))
 
+DEFINE_PER_CPU(int, bpf_kprobe_override);
 
 static nokprobe_inline bool trace_kprobe_is_return(struct trace_kprobe *tk)
 {
@@ -87,6 +88,12 @@ static nokprobe_inline unsigned long trace_kprobe_nhit(struct trace_kprobe *tk)
 	return nhit;
 }
 
+int trace_kprobe_ftrace(struct trace_event_call *call)
+{
+	struct trace_kprobe *tk = (struct trace_kprobe *)call->data;
+	return kprobe_ftrace(&tk->rp.kp);
+}
+
 static int register_kprobe_event(struct trace_kprobe *tk);
 static int unregister_kprobe_event(struct trace_kprobe *tk);
 
@@ -1170,7 +1177,7 @@ static int kretprobe_event_define_fields(struct trace_event_call *event_call)
 #ifdef CONFIG_PERF_EVENTS
 
 /* Kprobe profile handler */
-static void
+static int
 kprobe_perf_func(struct trace_kprobe *tk, struct pt_regs *regs)
 {
 	struct trace_event_call *call = &tk->tp.call;
@@ -1179,12 +1186,29 @@ kprobe_perf_func(struct trace_kprobe *tk, struct pt_regs *regs)
 	int size, __size, dsize;
 	int rctx;
 
-	if (bpf_prog_array_valid(call) && !trace_call_bpf(call, regs))
-		return;
+	if (bpf_prog_array_valid(call)) {
+		int ret;
+
+		ret = trace_call_bpf(call, regs);
+
+		/*
+		 * We need to check and see if we modified the pc of the
+		 * pt_regs, and if so clear the kprobe and return 1 so that we
+		 * don't do the instruction skipping.  Also reset our state so
+		 * we are clean the next pass through.
+		 */
+		if (__this_cpu_read(bpf_kprobe_override)) {
+			__this_cpu_write(bpf_kprobe_override, 0);
+			reset_current_kprobe();
+			return 1;
+		}
+		if (!ret)
+			return 0;
+	}
 
 	head = this_cpu_ptr(call->perf_events);
 	if (hlist_empty(head))
-		return;
+		return 0;
 
 	dsize = __get_data_size(&tk->tp, regs);
 	__size = sizeof(*entry) + tk->tp.size + dsize;
@@ -1193,13 +1217,14 @@ kprobe_perf_func(struct trace_kprobe *tk, struct pt_regs *regs)
 
 	entry = perf_trace_buf_alloc(size, NULL, &rctx);
 	if (!entry)
-		return;
+		return 0;
 
 	entry->ip = (unsigned long)tk->rp.kp.addr;
 	memset(&entry[1], 0, dsize);
 	store_trace_args(sizeof(*entry), &tk->tp, regs, (u8 *)&entry[1], dsize);
 	perf_trace_buf_submit(entry, size, rctx, call->event.type, 1, regs,
 			      head, NULL, NULL);
+	return 0;
 }
 NOKPROBE_SYMBOL(kprobe_perf_func);
 
@@ -1275,6 +1300,7 @@ static int kprobe_register(struct trace_event_call *event,
 static int kprobe_dispatcher(struct kprobe *kp, struct pt_regs *regs)
 {
 	struct trace_kprobe *tk = container_of(kp, struct trace_kprobe, rp.kp);
+	int ret = 0;
 
 	raw_cpu_inc(*tk->nhit);
 
@@ -1282,9 +1308,9 @@ static int kprobe_dispatcher(struct kprobe *kp, struct pt_regs *regs)
 		kprobe_trace_func(tk, regs);
 #ifdef CONFIG_PERF_EVENTS
 	if (tk->tp.flags & TP_FLAG_PROFILE)
-		kprobe_perf_func(tk, regs);
+		ret = kprobe_perf_func(tk, regs);
 #endif
-	return 0;	/* We don't tweek kernel, so just return 0 */
+	return ret;
 }
 NOKPROBE_SYMBOL(kprobe_dispatcher);
 
diff --git a/kernel/trace/trace_probe.h b/kernel/trace/trace_probe.h
index 903273c93e61..75c58bf059a3 100644
--- a/kernel/trace/trace_probe.h
+++ b/kernel/trace/trace_probe.h
@@ -362,6 +362,8 @@ extern ssize_t traceprobe_probes_write(struct file *file,
 
 extern int traceprobe_command(const char *buf, int (*createfn)(int, char**));
 
+extern int trace_kprobe_ftrace(struct trace_event_call *call);
+
 /* Sum up total data length for dynamic arraies (strings) */
 static nokprobe_inline int
 __get_data_size(struct trace_probe *tp, struct pt_regs *regs)
-- 
2.7.5
