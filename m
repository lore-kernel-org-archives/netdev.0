From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 3/5] bpf: convert relevant helper args to ARG_PTR_TO_RAW_STACK
Date: Wed, 13 Apr 2016 00:10:52 +0200
Message-ID: <88d32c57dcaac4f2b313c4cd32f51b5f570f3349.1460497071.git.daniel@iogearbox.net>
References: <cover.1460497071.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch, bblanco@plumgrid.com,
	brendan.d.gregg@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34347 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966156AbcDLWLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 18:11:13 -0400
In-Reply-To: <cover.1460497071.git.daniel@iogearbox.net>
In-Reply-To: <cover.1460497071.git.daniel@iogearbox.net>
References: <cover.1460497071.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts all helpers that can use ARG_PTR_TO_RAW_STACK as argument
type. For tc programs this is bpf_skb_load_bytes(), bpf_skb_get_tunnel_key(),
bpf_skb_get_tunnel_opt(). For tracing, this optimizes bpf_get_current_comm()
and bpf_probe_read(). The check in bpf_skb_load_bytes() for MAX_BPF_STACK can
also be removed since the verifier already makes sure we stay within bounds
on stack buffers.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/helpers.c     | 17 +++++++++++----
 kernel/trace/bpf_trace.c | 10 ++++++---
 net/core/filter.c        | 57 +++++++++++++++++++++++++++++++++---------------
 3 files changed, 60 insertions(+), 24 deletions(-)

diff --git a/kernel/bpf/helpers.c b/kernel/bpf/helpers.c
index 50da680..ad7a057 100644
--- a/kernel/bpf/helpers.c
+++ b/kernel/bpf/helpers.c
@@ -163,17 +163,26 @@ static u64 bpf_get_current_comm(u64 r1, u64 size, u64 r3, u64 r4, u64 r5)
 	struct task_struct *task = current;
 	char *buf = (char *) (long) r1;
 
-	if (!task)
-		return -EINVAL;
+	if (unlikely(!task))
+		goto err_clear;
 
-	strlcpy(buf, task->comm, min_t(size_t, size, sizeof(task->comm)));
+	strncpy(buf, task->comm, size);
+
+	/* Verifier guarantees that size > 0. For task->comm exceeding
+	 * size, guarantee that buf is %NUL-terminated. Unconditionally
+	 * done here to save the size test.
+	 */
+	buf[size - 1] = 0;
 	return 0;
+err_clear:
+	memset(buf, 0, size);
+	return -EINVAL;
 }
 
 const struct bpf_func_proto bpf_get_current_comm_proto = {
 	.func		= bpf_get_current_comm,
 	.gpl_only	= false,
 	.ret_type	= RET_INTEGER,
-	.arg1_type	= ARG_PTR_TO_STACK,
+	.arg1_type	= ARG_PTR_TO_RAW_STACK,
 	.arg2_type	= ARG_CONST_STACK_SIZE,
 };
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 413ec56..6855878 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -62,17 +62,21 @@ EXPORT_SYMBOL_GPL(trace_call_bpf);
 static u64 bpf_probe_read(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 {
 	void *dst = (void *) (long) r1;
-	int size = (int) r2;
+	int ret, size = (int) r2;
 	void *unsafe_ptr = (void *) (long) r3;
 
-	return probe_kernel_read(dst, unsafe_ptr, size);
+	ret = probe_kernel_read(dst, unsafe_ptr, size);
+	if (unlikely(ret < 0))
+		memset(dst, 0, size);
+
+	return ret;
 }
 
 static const struct bpf_func_proto bpf_probe_read_proto = {
 	.func		= bpf_probe_read,
 	.gpl_only	= true,
 	.ret_type	= RET_INTEGER,
-	.arg1_type	= ARG_PTR_TO_STACK,
+	.arg1_type	= ARG_PTR_TO_RAW_STACK,
 	.arg2_type	= ARG_CONST_STACK_SIZE,
 	.arg3_type	= ARG_ANYTHING,
 };
diff --git a/net/core/filter.c b/net/core/filter.c
index e8486ba..5d2ac2b 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1409,16 +1409,19 @@ static u64 bpf_skb_load_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 	unsigned int len = (unsigned int) r4;
 	void *ptr;
 
-	if (unlikely((u32) offset > 0xffff || len > MAX_BPF_STACK))
-		return -EFAULT;
+	if (unlikely((u32) offset > 0xffff))
+		goto err_clear;
 
 	ptr = skb_header_pointer(skb, offset, len, to);
 	if (unlikely(!ptr))
-		return -EFAULT;
+		goto err_clear;
 	if (ptr != to)
 		memcpy(to, ptr, len);
 
 	return 0;
+err_clear:
+	memset(to, 0, len);
+	return -EFAULT;
 }
 
 static const struct bpf_func_proto bpf_skb_load_bytes_proto = {
@@ -1427,7 +1430,7 @@ static const struct bpf_func_proto bpf_skb_load_bytes_proto = {
 	.ret_type	= RET_INTEGER,
 	.arg1_type	= ARG_PTR_TO_CTX,
 	.arg2_type	= ARG_ANYTHING,
-	.arg3_type	= ARG_PTR_TO_STACK,
+	.arg3_type	= ARG_PTR_TO_RAW_STACK,
 	.arg4_type	= ARG_CONST_STACK_SIZE,
 };
 
@@ -1756,12 +1759,19 @@ static u64 bpf_skb_get_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
 	struct bpf_tunnel_key *to = (struct bpf_tunnel_key *) (long) r2;
 	const struct ip_tunnel_info *info = skb_tunnel_info(skb);
 	u8 compat[sizeof(struct bpf_tunnel_key)];
+	void *to_orig = to;
+	int err;
 
-	if (unlikely(!info || (flags & ~(BPF_F_TUNINFO_IPV6))))
-		return -EINVAL;
-	if (ip_tunnel_info_af(info) != bpf_tunnel_key_af(flags))
-		return -EPROTO;
+	if (unlikely(!info || (flags & ~(BPF_F_TUNINFO_IPV6)))) {
+		err = -EINVAL;
+		goto err_clear;
+	}
+	if (ip_tunnel_info_af(info) != bpf_tunnel_key_af(flags)) {
+		err = -EPROTO;
+		goto err_clear;
+	}
 	if (unlikely(size != sizeof(struct bpf_tunnel_key))) {
+		err = -EINVAL;
 		switch (size) {
 		case offsetof(struct bpf_tunnel_key, tunnel_label):
 		case offsetof(struct bpf_tunnel_key, tunnel_ext):
@@ -1771,12 +1781,12 @@ static u64 bpf_skb_get_tunnel_key(u64 r1, u64 r2, u64 size, u64 flags, u64 r5)
 			 * a common path later on.
 			 */
 			if (ip_tunnel_info_af(info) != AF_INET)
-				return -EINVAL;
+				goto err_clear;
 set_compat:
 			to = (struct bpf_tunnel_key *)compat;
 			break;
 		default:
-			return -EINVAL;
+			goto err_clear;
 		}
 	}
 
@@ -1793,9 +1803,12 @@ set_compat:
 	}
 
 	if (unlikely(size != sizeof(struct bpf_tunnel_key)))
-		memcpy((void *)(long) r2, to, size);
+		memcpy(to_orig, to, size);
 
 	return 0;
+err_clear:
+	memset(to_orig, 0, size);
+	return err;
 }
 
 static const struct bpf_func_proto bpf_skb_get_tunnel_key_proto = {
@@ -1803,7 +1816,7 @@ static const struct bpf_func_proto bpf_skb_get_tunnel_key_proto = {
 	.gpl_only	= false,
 	.ret_type	= RET_INTEGER,
 	.arg1_type	= ARG_PTR_TO_CTX,
-	.arg2_type	= ARG_PTR_TO_STACK,
+	.arg2_type	= ARG_PTR_TO_RAW_STACK,
 	.arg3_type	= ARG_CONST_STACK_SIZE,
 	.arg4_type	= ARG_ANYTHING,
 };
@@ -1813,16 +1826,26 @@ static u64 bpf_skb_get_tunnel_opt(u64 r1, u64 r2, u64 size, u64 r4, u64 r5)
 	struct sk_buff *skb = (struct sk_buff *) (long) r1;
 	u8 *to = (u8 *) (long) r2;
 	const struct ip_tunnel_info *info = skb_tunnel_info(skb);
+	int err;
 
 	if (unlikely(!info ||
-		     !(info->key.tun_flags & TUNNEL_OPTIONS_PRESENT)))
-		return -ENOENT;
-	if (unlikely(size < info->options_len))
-		return -ENOMEM;
+		     !(info->key.tun_flags & TUNNEL_OPTIONS_PRESENT))) {
+		err = -ENOENT;
+		goto err_clear;
+	}
+	if (unlikely(size < info->options_len)) {
+		err = -ENOMEM;
+		goto err_clear;
+	}
 
 	ip_tunnel_info_opts_get(to, info);
+	if (size > info->options_len)
+		memset(to + info->options_len, 0, size - info->options_len);
 
 	return info->options_len;
+err_clear:
+	memset(to, 0, size);
+	return err;
 }
 
 static const struct bpf_func_proto bpf_skb_get_tunnel_opt_proto = {
@@ -1830,7 +1853,7 @@ static const struct bpf_func_proto bpf_skb_get_tunnel_opt_proto = {
 	.gpl_only	= false,
 	.ret_type	= RET_INTEGER,
 	.arg1_type	= ARG_PTR_TO_CTX,
-	.arg2_type	= ARG_PTR_TO_STACK,
+	.arg2_type	= ARG_PTR_TO_RAW_STACK,
 	.arg3_type	= ARG_CONST_STACK_SIZE,
 };
 
-- 
1.9.3
