From: Sargun Dhillon <sargun@sargun.me>
Subject: [PATCH v4 1/2] bpf: Add bpf_probe_write BPF helper to be called in
 tracers (kprobes)
Date: Thu, 21 Jul 2016 18:09:17 -0700
Message-ID: <20160722010915.GA22992@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This allows user memory to be written to during the course of a kprobe.
It shouldn't be used to implement any kind of security mechanism
because of TOC-TOU attacks, but rather to debug, divert, and
manipulate execution of semi-cooperative processes.

Although it uses probe_kernel_write, we limit the address space
the probe can write into by checking the space with access_ok.
This is so the call doesn't sleep.

Given this feature is experimental, and has the risk of crashing
the system, we print a warning on invocation.

It was tested with the tracex7 program on x86-64.

Signed-off-by: Sargun Dhillon <sargun@sargun.me>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
---
 include/uapi/linux/bpf.h  | 12 ++++++++++++
 kernel/bpf/verifier.c     |  9 +++++++++
 kernel/trace/bpf_trace.c  | 37 +++++++++++++++++++++++++++++++++++++
 samples/bpf/bpf_helpers.h |  2 ++
 4 files changed, 60 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 2b7076f..4536282 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -365,6 +365,18 @@ enum bpf_func_id {
 	 */
 	BPF_FUNC_get_current_task,
 
+	/**
+	 * bpf_probe_write(void *dst, void *src, int len)
+	 * safely attempt to write to a location
+	 * @dst: destination address in userspace
+	 * @src: source address on stack
+	 * @len: number of bytes to copy
+	 * Return:
+	 *   Returns number of bytes that could not be copied.
+	 *   On success, this will be zero
+	 */
+	BPF_FUNC_probe_write,
+
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index f72f23b..6785008 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1154,6 +1154,15 @@ static int check_call(struct verifier_env *env, int func_id)
 		return -EINVAL;
 	}
 
+	if (func_id == BPF_FUNC_probe_write) {
+		pr_warn_once("************************************************\n");
+		pr_warn_once("* bpf_probe_write: Experimental Feature in use *\n");
+		pr_warn_once("* bpf_probe_write: Feature may corrupt memory  *\n");
+		pr_warn_once("************************************************\n");
+		pr_notice_ratelimited("bpf_probe_write in use by: %.16s-%d",
+				      current->comm, task_pid_nr(current));
+	}
+
 	/* eBPF programs must be GPL compatible to use GPL-ed functions */
 	if (!env->prog->gpl_compatible && fn->gpl_only) {
 		verbose("cannot call GPL only function from proprietary program\n");
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index a12bbd3..440487c 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -81,6 +81,41 @@ static const struct bpf_func_proto bpf_probe_read_proto = {
 	.arg3_type	= ARG_ANYTHING,
 };
 
+static u64 bpf_probe_write(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	void *unsafe_ptr = (void *) (long) r1;
+	void *src = (void *) (long) r2;
+	int size = (int) r3;
+	struct task_struct *task = current;
+
+	/*
+	 * Ensure we're in a user context which it is safe for the helper
+	 * to run. This helper has no business in a kthread
+	 *
+	 * access_ok should prevent writing to non-user memory, but on
+	 * some architectures (nommu, etc...) access_ok isn't enough
+	 * So we check the current segment
+	 */
+
+	if (unlikely(in_interrupt() || (task->flags & PF_KTHREAD)))
+		return -EPERM;
+	if (unlikely(segment_eq(get_fs(), KERNEL_DS)))
+		return -EPERM;
+	if (!access_ok(VERIFY_WRITE, unsafe_ptr, size))
+		return -EPERM;
+
+	return probe_kernel_write(unsafe_ptr, src, size);
+}
+
+static const struct bpf_func_proto bpf_probe_write_proto = {
+	.func		= bpf_probe_write,
+	.gpl_only	= true,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_ANYTHING,
+	.arg2_type	= ARG_PTR_TO_STACK,
+	.arg3_type	= ARG_CONST_STACK_SIZE,
+};
+
 /*
  * limited trace_printk()
  * only %d %u %x %ld %lu %lx %lld %llu %llx %p %s conversion specifiers allowed
@@ -362,6 +397,8 @@ static const struct bpf_func_proto *tracing_func_proto(enum bpf_func_id func_id)
 		return &bpf_get_smp_processor_id_proto;
 	case BPF_FUNC_perf_event_read:
 		return &bpf_perf_event_read_proto;
+	case BPF_FUNC_probe_write:
+		return &bpf_probe_write_proto;
 	default:
 		return NULL;
 	}
diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index 84e3fd9..94fd2b1 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -41,6 +41,8 @@ static int (*bpf_perf_event_output)(void *ctx, void *map, int index, void *data,
 	(void *) BPF_FUNC_perf_event_output;
 static int (*bpf_get_stackid)(void *ctx, void *map, int flags) =
 	(void *) BPF_FUNC_get_stackid;
+static int (*bpf_probe_write)(void *dst, void *src, int size) =
+	(void *) BPF_FUNC_probe_write;
 
 /* llvm builtin functions that eBPF C program may use to
  * emit BPF_LD_ABS and BPF_LD_IND instructions
-- 
2.7.4
