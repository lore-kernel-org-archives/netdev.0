From: Gianluca Borello <g.borello@gmail.com>
Subject: [PATCH net-next] bpf: add bpf_probe_read_str helper
Date: Wed, 18 Jan 2017 17:55:49 +0000
Message-ID: <20170118175549.15819-1-g.borello@gmail.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org,
        Gianluca Borello <g.borello@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34039 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751413AbdARSCM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 13:02:12 -0500
Received: by mail-pg0-f66.google.com with SMTP id t6so1930581pgt.1
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 10:02:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Provide a simple helper with the same semantics of strncpy_from_unsafe():

int bpf_probe_read_str(void *dst, int size, const void *unsafe_addr)

This gives more flexibility to a bpf program. A typical use case is
intercepting a file name during sys_open(). The current approach is:

SEC("kprobe/sys_open")
void bpf_sys_open(struct pt_regs *ctx)
{
	char buf[PATHLEN]; // PATHLEN is defined to 256
	bpf_probe_read(buf, sizeof(buf), ctx->di);

	/* consume buf */
}

This is suboptimal because the size of the string needs to be estimated
at compile time, causing more memory to be copied than often necessary,
and can become more problematic if further processing on buf is done,
for example by pushing it to userspace via bpf_perf_event_output(),
since the real length of the string is unknown and the entire buffer
must be copied (and defining an unrolled strnlen() inside the bpf
program is a very inefficient and unfeasible approach).

With the new helper, the code can easily operate on the actual string
length rather than the buffer size:

SEC("kprobe/sys_open")
void bpf_sys_open(struct pt_regs *ctx)
{
	char buf[PATHLEN]; // PATHLEN is defined to 256
	int res = bpf_probe_read_str(buf, sizeof(buf), ctx->di);

	/* consume buf, for example push it to userspace via
	 * bpf_perf_event_output(), but this time we can use
	 * res (the string length) as event size, after checking
	 * its boundaries.
	 */
}

Another useful use case is when parsing individual process arguments or
individual environment variables navigating current->mm->arg_start and
current->mm->env_start: using this helper and the return value, one can
quickly iterate at the right offset of the memory area.

The code changes simply leverage the already existent
strncpy_from_unsafe() kernel function, which is safe to be called from a
bpf program as it is used in bpf_trace_printk().

Signed-off-by: Gianluca Borello <g.borello@gmail.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/uapi/linux/bpf.h | 15 ++++++++++++++-
 kernel/trace/bpf_trace.c | 32 ++++++++++++++++++++++++++++++++
 2 files changed, 46 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 0eb0e87dbe9f..54a5894bb4ea 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -430,6 +430,18 @@ union bpf_attr {
  *     @xdp_md: pointer to xdp_md
  *     @delta: An positive/negative integer to be added to xdp_md.data
  *     Return: 0 on success or negative on error
+ *
+ * int bpf_probe_read_str(void *dst, int size, const void *unsafe_ptr)
+ *     Copy a NUL terminated string from unsafe address. In case the string
+ *     length is smaller than size, the target is not padded with further NUL
+ *     bytes. In case the string length is larger than size, just count-1
+ *     bytes are copied and the last byte is set to NUL.
+ *     @dst: destination address
+ *     @size: maximum number of bytes to copy, including the trailing NUL
+ *     @unsafe_ptr: unsafe address
+ *     Return:
+ *       > 0 length of the string including the trailing NUL on success
+ *       < 0 error
  */
 #define __BPF_FUNC_MAPPER(FN)		\
 	FN(unspec),			\
@@ -476,7 +488,8 @@ union bpf_attr {
 	FN(set_hash_invalid),		\
 	FN(get_numa_node_id),		\
 	FN(skb_change_head),		\
-	FN(xdp_adjust_head),
+	FN(xdp_adjust_head),		\
+	FN(probe_read_str),
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index c22a961d1a42..424daa4586d1 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -395,6 +395,36 @@ static const struct bpf_func_proto bpf_current_task_under_cgroup_proto = {
 	.arg2_type      = ARG_ANYTHING,
 };
 
+BPF_CALL_3(bpf_probe_read_str, void *, dst, u32, size,
+	   const void *, unsafe_ptr)
+{
+	int ret;
+
+	/*
+	 * The strncpy_from_unsafe() call will likely not fill the entire
+	 * buffer, but that's okay in this circumstance as we're probing
+	 * arbitrary memory anyway similar to bpf_probe_read() and might
+	 * as well probe the stack. Thus, memory is explicitly cleared
+	 * only in error case, so that improper users ignoring return
+	 * code altogether don't copy garbage; otherwise length of string
+	 * is returned that can be used for bpf_perf_event_output() et al.
+	 */
+	ret = strncpy_from_unsafe(dst, unsafe_ptr, size);
+	if (unlikely(ret < 0))
+		memset(dst, 0, size);
+
+	return ret;
+}
+
+static const struct bpf_func_proto bpf_probe_read_str_proto = {
+	.func		= bpf_probe_read_str,
+	.gpl_only	= true,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_UNINIT_MEM,
+	.arg2_type	= ARG_CONST_SIZE,
+	.arg3_type	= ARG_ANYTHING,
+};
+
 static const struct bpf_func_proto *tracing_func_proto(enum bpf_func_id func_id)
 {
 	switch (func_id) {
@@ -432,6 +462,8 @@ static const struct bpf_func_proto *tracing_func_proto(enum bpf_func_id func_id)
 		return &bpf_current_task_under_cgroup_proto;
 	case BPF_FUNC_get_prandom_u32:
 		return &bpf_get_prandom_u32_proto;
+	case BPF_FUNC_probe_read_str:
+		return &bpf_probe_read_str_proto;
 	default:
 		return NULL;
 	}
-- 
2.11.0
