From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 1/2] bpf: add a bpf_override_function helper
Date: Tue, 31 Oct 2017 11:45:56 -0400
Message-ID: <1509464757-2222-2-git-send-email-josef@toxicpanda.com>
References: <1509464757-2222-1-git-send-email-josef@toxicpanda.com>
Cc: Josef Bacik <jbacik@fb.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ast@kernel.org, kernel-team@fb.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1509464757-2222-1-git-send-email-josef@toxicpanda.com>
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
 include/linux/trace_events.h     |  7 +++++++
 include/uapi/linux/bpf.h         |  7 ++++++-
 kernel/trace/Kconfig             | 11 +++++++++++
 kernel/trace/bpf_trace.c         | 30 ++++++++++++++++++++++++++++
 kernel/trace/trace_kprobe.c      | 42 +++++++++++++++++++++++++++++++++-------
 10 files changed, 116 insertions(+), 8 deletions(-)

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
diff --git a/include/linux/trace_events.h b/include/linux/trace_events.h
index fc6aeca945db..9179f109c49b 100644
--- a/include/linux/trace_events.h
+++ b/include/linux/trace_events.h
@@ -521,7 +521,14 @@ do {									\
 #ifdef CONFIG_PERF_EVENTS
 struct perf_event;
 
+enum {
+	BPF_STATE_NORMAL_KPROBE = 0,
+	BPF_STATE_FTRACE_KPROBE,
+	BPF_STATE_MODIFIED_PC,
+};
+
 DECLARE_PER_CPU(struct pt_regs, perf_trace_regs);
+DECLARE_PER_CPU(int, bpf_kprobe_state);
 
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
index 136aa6bb0422..e9a7ae9c3a78 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -13,6 +13,8 @@
 #include <linux/filter.h>
 #include <linux/uaccess.h>
 #include <linux/ctype.h>
+#include <asm/kprobes.h>
+
 #include "trace.h"
 
 u64 bpf_get_stackid(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
@@ -76,6 +78,32 @@ unsigned int trace_call_bpf(struct trace_event_call *call, void *ctx)
 }
 EXPORT_SYMBOL_GPL(trace_call_bpf);
 
+#ifdef CONFIG_BPF_KPROBE_OVERRIDE
+BPF_CALL_2(bpf_override_return, struct pt_regs *, regs, unsigned long, rc)
+{
+	/* We can only override ftrace kprobes at the moment. */
+	if (__this_cpu_read(bpf_kprobe_state) != BPF_STATE_FTRACE_KPROBE)
+		return -EINVAL;
+	__this_cpu_write(bpf_kprobe_state, BPF_STATE_MODIFIED_PC);
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
@@ -551,6 +579,8 @@ static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func
 		return &bpf_get_stackid_proto;
 	case BPF_FUNC_perf_event_read_value:
 		return &bpf_perf_event_read_value_proto;
+	case BPF_FUNC_override_return:
+		return &bpf_override_return_proto;
 	default:
 		return tracing_func_proto(func_id);
 	}
diff --git a/kernel/trace/trace_kprobe.c b/kernel/trace/trace_kprobe.c
index abf92e478cfb..b7173e44e2e7 100644
--- a/kernel/trace/trace_kprobe.c
+++ b/kernel/trace/trace_kprobe.c
@@ -42,6 +42,7 @@ struct trace_kprobe {
 	(offsetof(struct trace_kprobe, tp.args) +	\
 	(sizeof(struct probe_arg) * (n)))
 
+DEFINE_PER_CPU(int, bpf_kprobe_state);
 
 static nokprobe_inline bool trace_kprobe_is_return(struct trace_kprobe *tk)
 {
@@ -1170,7 +1171,7 @@ static int kretprobe_event_define_fields(struct trace_event_call *event_call)
 #ifdef CONFIG_PERF_EVENTS
 
 /* Kprobe profile handler */
-static void
+static int
 kprobe_perf_func(struct trace_kprobe *tk, struct pt_regs *regs)
 {
 	struct trace_event_call *call = &tk->tp.call;
@@ -1179,12 +1180,37 @@ kprobe_perf_func(struct trace_kprobe *tk, struct pt_regs *regs)
 	int size, __size, dsize;
 	int rctx;
 
-	if (bpf_prog_array_valid(call) && !trace_call_bpf(call, regs))
-		return;
+	if (bpf_prog_array_valid(call)) {
+		int ret, state;
+
+		/*
+		 * If we are an ftrace kprobe then we are allowed to do
+		 * overrides for this kprobe.
+		 */
+		if (unlikely(kprobe_ftrace(&tk->rp.kp)))
+			__this_cpu_write(bpf_kprobe_state,
+					 BPF_STATE_FTRACE_KPROBE);
+		ret = trace_call_bpf(call, regs);
+
+		/*
+		 * We need to check and see if we modified the pc of the
+		 * pt_regs, and if so clear the kprobe and return 1 so that we
+		 * don't do the instruction skipping.  Also reset our state so
+		 * we are clean the next pass through.
+		 */
+		state = __this_cpu_read(bpf_kprobe_state);
+		__this_cpu_write(bpf_kprobe_state, BPF_STATE_NORMAL_KPROBE);
+		if (state == BPF_STATE_MODIFIED_PC) {
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
@@ -1193,13 +1219,14 @@ kprobe_perf_func(struct trace_kprobe *tk, struct pt_regs *regs)
 
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
 
@@ -1275,6 +1302,7 @@ static int kprobe_register(struct trace_event_call *event,
 static int kprobe_dispatcher(struct kprobe *kp, struct pt_regs *regs)
 {
 	struct trace_kprobe *tk = container_of(kp, struct trace_kprobe, rp.kp);
+	int ret = 0;
 
 	raw_cpu_inc(*tk->nhit);
 
@@ -1282,9 +1310,9 @@ static int kprobe_dispatcher(struct kprobe *kp, struct pt_regs *regs)
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
 
-- 
2.7.5
