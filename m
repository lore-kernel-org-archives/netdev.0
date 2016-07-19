From: Sargun Dhillon <sargun@sargun.me>
Subject: [PATCH net-next v2 1/2] Add bpf_copy_to_user BPF helper to be called
 in tracers (kprobes)
Date: Tue, 19 Jul 2016 00:58:56 -0700
Message-ID: <20160719075854.GA22353@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:34021 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752487AbcGSH67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 03:58:59 -0400
Received: by mail-io0-f179.google.com with SMTP id q83so12276524iod.1
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 00:58:58 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows user memory to be written to during the course of a kprobe.
It shouldn't be used to implement any kind of security mechanism
because of TOC-TOU attacks, but rather to debug, divert, and
manipulate execution of semi-cooperative processes.

Although it uses probe_kernel_write, we limit the address space
the probe can write into by checking the space with access_ok.
This call shouldn't sleep on any architectures based on review.

It was tested with the tracex7 program on x86-64.

Signed-off-by: Sargun Dhillon <sargun@sargun.me>
Cc: Alexei Starovoitov <ast@kernel.org>
---
 include/uapi/linux/bpf.h  | 11 +++++++++++
 kernel/trace/bpf_trace.c  | 31 +++++++++++++++++++++++++++++++
 samples/bpf/bpf_helpers.h |  2 ++
 3 files changed, 44 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index c4d9224..d435f7c 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -364,6 +364,17 @@ enum bpf_func_id {
 	 */
 	BPF_FUNC_get_current_task,
 
+	/**
+	 * copy_to_user(to, from, len) - Copy a block of data into user space.
+	 * @to: destination address in userspace
+	 * @from: source address on stack
+	 * @len: number of bytes to copy
+	 * Return:
+	 *   Returns number of bytes that could not be copied.
+	 *   On success, this will be zero
+	 */
+	BPF_FUNC_copy_to_user,
+
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index ebfbb7d..45878f3 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -81,6 +81,35 @@ static const struct bpf_func_proto bpf_probe_read_proto = {
 	.arg3_type	= ARG_ANYTHING,
 };
 
+static u64 bpf_copy_to_user(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	void *to = (void *) (long) r1;
+	void *from = (void *) (long) r2;
+	int  size = (int) r3;
+	struct task_struct *task = current;
+
+	/* check if we're in a user context */
+	if (unlikely(in_interrupt()))
+		return -EINVAL;
+	if (unlikely(!task || !task->pid))
+		return -EINVAL;
+
+	/* Is this a user address, or a kernel address? */
+	if (!access_ok(VERIFY_WRITE, to, size))
+		return -EINVAL;
+
+	return probe_kernel_write(to, from, size);
+}
+
+static const struct bpf_func_proto bpf_copy_to_user_proto = {
+	.func = bpf_copy_to_user,
+	.gpl_only = false,
+	.ret_type = RET_INTEGER,
+	.arg1_type = ARG_ANYTHING,
+	.arg2_type = ARG_PTR_TO_RAW_STACK,
+	.arg3_type = ARG_CONST_STACK_SIZE,
+};
+
 /*
  * limited trace_printk()
  * only %d %u %x %ld %lu %lx %lld %llu %llx %p %s conversion specifiers allowed
@@ -360,6 +389,8 @@ static const struct bpf_func_proto *tracing_func_proto(enum bpf_func_id func_id)
 		return &bpf_get_smp_processor_id_proto;
 	case BPF_FUNC_perf_event_read:
 		return &bpf_perf_event_read_proto;
+	case BPF_FUNC_copy_to_user:
+		return &bpf_copy_to_user_proto;
 	default:
 		return NULL;
 	}
diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index 84e3fd9..a54a26c 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -41,6 +41,8 @@ static int (*bpf_perf_event_output)(void *ctx, void *map, int index, void *data,
 	(void *) BPF_FUNC_perf_event_output;
 static int (*bpf_get_stackid)(void *ctx, void *map, int flags) =
 	(void *) BPF_FUNC_get_stackid;
+static int (*bpf_copy_to_user)(void *to, void *from, int size) =
+	(void *) BPF_FUNC_copy_to_user;
 
 /* llvm builtin functions that eBPF C program may use to
  * emit BPF_LD_ABS and BPF_LD_IND instructions
-- 
2.7.4
