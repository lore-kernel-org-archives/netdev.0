From: Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
Subject: [net-next RFC v2 5/9] bpf: Add bpf_probe_write_checmate helper
Date: Mon, 29 Aug 2016 04:46:41 -0700
Message-ID: <20160829114639.GA20871@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds bpf_probe_write_checmate. This is a specific type of
helper for the Checmate subsystem. It allows safe writes to kernel
memory based on inspection of the Checmate ctx.

In this patch, it only allows writes during the socket_bind, and
socket_connect hooks to sockaddr. It can used to implement behaviour
that's common in containerzation platforms that either perform
DNAT/SNAT, or proxying to veil the true location of address to
service mapping.

Since this occurs only once, as opposed to per packet, it allows
for much higher performance. Not only this, but the standard BSD
API for introspecting sockets (getpeername) still works.

Signed-off-by: Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>
---
 include/uapi/linux/bpf.h         | 11 ++++++++
 security/checmate/checmate_bpf.c | 55 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 66 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 91bc92f..3971456 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -398,6 +398,17 @@ enum bpf_func_id {
 	 */
 	BPF_FUNC_skb_change_tail,
 
+	/**
+	 * bpf_probe_write_checmate(ctx, void *dst, void *src, int len)
+	 * safely attempt to write to memory pointed to by a Checmate context
+	 * @ctx: struct checmate_ctx*
+	 * @dst: destination address in userspace
+	 * @src: source address on stack
+	 * @len: number of bytes to copy
+	 * Return: 0 on success or negative error
+	 */
+	BPF_FUNC_probe_write_checmate,
+
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/security/checmate/checmate_bpf.c b/security/checmate/checmate_bpf.c
index 001225c..24d6935 100644
--- a/security/checmate/checmate_bpf.c
+++ b/security/checmate/checmate_bpf.c
@@ -12,6 +12,59 @@
 #include <linux/bpf.h>
 #include <linux/checmate.h>
 
+static int probe_write_socket_bind(struct checmate_socket_bind_ctx *ctx,
+				   void *unsafe_ptr, void *src, int size)
+{
+	if (unsafe_ptr < (void *)ctx->address ||
+	    (unsafe_ptr + size) > ((void *)ctx->address + ctx->addrlen))
+		return -EPERM;
+
+	memcpy(unsafe_ptr, src, size);
+
+	return 0;
+}
+
+static int probe_write_socket_connect(struct checmate_socket_connect_ctx *ctx,
+				      void *unsafe_ptr, void *src, int size)
+{
+	if (unsafe_ptr < (void *)ctx->address ||
+	    (unsafe_ptr + size) > ((void *)ctx->address + ctx->addrlen))
+		return -EPERM;
+
+	memcpy(unsafe_ptr, src, size);
+
+	return 0;
+}
+
+static u64 bpf_probe_write_checmate(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	struct checmate_ctx *ctx = (struct checmate_ctx *) (long) (r1);
+	void *unsafe_ptr = (void *) (long) r2;
+	void *src = (void *) (long) r3;
+	int size = (int) r4;
+
+	switch (ctx->hook) {
+	case CHECMATE_HOOK_SOCKET_BIND:
+		return probe_write_socket_bind(&ctx->socket_bind, unsafe_ptr,
+					       src, size);
+	case CHECMATE_HOOK_SOCKET_CONNECT:
+		return probe_write_socket_connect(&ctx->socket_connect,
+						  unsafe_ptr, src, size);
+	}
+
+	return -EPERM;
+}
+
+static const struct bpf_func_proto bpf_probe_write_user_proto = {
+	.func		= bpf_probe_write_checmate,
+	.gpl_only	= true,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_ANYTHING,
+	.arg3_type	= ARG_PTR_TO_STACK,
+	.arg4_type	= ARG_CONST_STACK_SIZE,
+};
+
 static const struct bpf_func_proto *
 checmate_prog_func_proto(enum bpf_func_id func_id)
 {
@@ -34,6 +87,8 @@ checmate_prog_func_proto(enum bpf_func_id func_id)
 		return &bpf_get_current_uid_gid_proto;
 	case BPF_FUNC_get_current_comm:
 		return &bpf_get_current_comm_proto;
+	case BPF_FUNC_probe_write_checmate:
+		return &bpf_probe_write_user_proto;
 	case BPF_FUNC_trace_printk:
 		return bpf_get_trace_printk_proto();
 	default:
-- 
2.7.4
