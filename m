From: Sargun Dhillon <sargun@sargun.me>
Subject: [PATCH net-next v6 1/2] bpf: Add bpf_probe_write_user BPF helper to
 be called in tracers
Date: Sat, 23 Jul 2016 20:22:37 -0700
Message-ID: <20160724032235.GA1647@ircssh.c.rugged-nimbus-611.internal>
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
We do this as opposed to calling copy_to_user directly, in order
to avoid sleeping. In addition we ensure the threads's current fs
/ segment is USER_DS and the thread isn't exiting nor a kernel thread.

Given this feature is experimental, and has the risk of crashing the
system, we print a warning on installing a proglet that could invoke
this helper, along with the process name.

Signed-off-by: Sargun Dhillon <sargun@sargun.me>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/uapi/linux/bpf.h  | 10 ++++++++++
 kernel/trace/bpf_trace.c  | 48 +++++++++++++++++++++++++++++++++++++++++++++++
 samples/bpf/bpf_helpers.h |  2 ++
 3 files changed, 60 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 2b7076f..da218fe 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -365,6 +365,16 @@ enum bpf_func_id {
 	 */
 	BPF_FUNC_get_current_task,
 
+	/**
+	 * bpf_probe_write_user(void *dst, void *src, int len)
+	 * safely attempt to write to a location
+	 * @dst: destination address in userspace
+	 * @src: source address on stack
+	 * @len: number of bytes to copy
+	 * Return: 0 on success or negative error
+	 */
+	BPF_FUNC_probe_write_user,
+
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index a12bbd3..aa16a17 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -81,6 +81,52 @@ static const struct bpf_func_proto bpf_probe_read_proto = {
 	.arg3_type	= ARG_ANYTHING,
 };
 
+static u64 bpf_probe_write_user(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	void *unsafe_ptr = (void *) (long) r1;
+	void *src = (void *) (long) r2;
+	int size = (int) r3;
+
+	/*
+	 * Ensure we're in a user context which it is safe for the helper
+	 * to run. This helper has no business in a kthread.
+	 *
+	 * access_ok should prevent writing to non-user memory, but in some
+	 * situations (nommu, temporary switch, etc...) access_ok does not
+	 * provide enough validation.
+	 *
+	 * In order to avoid this we check the current segment to verify that
+	 * it is USER_DS. This avoid odd architectures and user threads that
+	 * temporarily switch to KERNEL_DS.
+	 */
+
+	if (unlikely(in_interrupt() ||
+		     current->flags & (PF_KTHREAD | PF_EXITING)))
+		return -EPERM;
+	if (unlikely(segment_eq(get_fs(), KERNEL_DS)))
+		return -EPERM;
+	if (!access_ok(VERIFY_WRITE, unsafe_ptr, size))
+		return -EPERM;
+
+	return probe_kernel_write(unsafe_ptr, src, size);
+}
+
+static const struct bpf_func_proto bpf_probe_write_user_proto = {
+	.func		= bpf_probe_write_user,
+	.gpl_only	= true,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_ANYTHING,
+	.arg2_type	= ARG_PTR_TO_STACK,
+	.arg3_type	= ARG_CONST_STACK_SIZE,
+};
+
+static const struct bpf_func_proto *bpf_get_probe_write_proto(void) {
+	pr_warn_ratelimited("bpf_probe_write_user: %s[%d] installing program with helper: it may corrupt user memory!",
+			    current->comm, task_pid_nr(current));
+
+	return &bpf_probe_write_user_proto;
+}
+
 /*
  * limited trace_printk()
  * only %d %u %x %ld %lu %lx %lld %llu %llx %p %s conversion specifiers allowed
@@ -362,6 +408,8 @@ static const struct bpf_func_proto *tracing_func_proto(enum bpf_func_id func_id)
 		return &bpf_get_smp_processor_id_proto;
 	case BPF_FUNC_perf_event_read:
 		return &bpf_perf_event_read_proto;
+	case BPF_FUNC_probe_write_user:
+		return bpf_get_probe_write_proto();
 	default:
 		return NULL;
 	}
diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index 84e3fd9..217c8d5 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -41,6 +41,8 @@ static int (*bpf_perf_event_output)(void *ctx, void *map, int index, void *data,
 	(void *) BPF_FUNC_perf_event_output;
 static int (*bpf_get_stackid)(void *ctx, void *map, int flags) =
 	(void *) BPF_FUNC_get_stackid;
+static int (*bpf_probe_write_user)(void *dst, void *src, int size) =
+	(void *) BPF_FUNC_probe_write_user;
 
 /* llvm builtin functions that eBPF C program may use to
  * emit BPF_LD_ABS and BPF_LD_IND instructions
-- 
2.7.4
