From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 2/3] bpf: Add new cgroups prog type to enable sock modifications
Date: Tue, 25 Oct 2016 15:30:12 -0700
Message-ID: <1477434613-3169-3-git-send-email-dsa@cumulusnetworks.com>
References: <1477434613-3169-1-git-send-email-dsa@cumulusnetworks.com>
Cc: daniel@zonque.org, ast@fb.com, daniel@iogearbox.net,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:33383 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942125AbcJYWb0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 18:31:26 -0400
Received: by mail-pf0-f177.google.com with SMTP id 197so2587982pfu.0
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2016 15:31:26 -0700 (PDT)
In-Reply-To: <1477434613-3169-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add new cgroup based program type, BPF_PROG_TYPE_CGROUP_SOCK. Similar to
BPF_PROG_TYPE_CGROUP_SKB programs can be attached to a cgroup and run
any time a process in the cgroup opens an AF_INET or AF_INET6 socket.
Currently only sk_bound_dev_if is exported to userspace for modification
by a bpf program.

This allows a cgroup to be configured such that AF_INET{6} sockets opened
by processes are automatically bound to a specific device. In turn, this
enables the running of programs that do not support SO_BINDTODEVICE in a
specific VRF context / L3 domain.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/linux/filter.h   |  2 +-
 include/uapi/linux/bpf.h | 15 ++++++++
 kernel/bpf/cgroup.c      |  9 +++++
 kernel/bpf/syscall.c     |  4 +++
 net/core/filter.c        | 92 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/core/sock.c          |  7 ++++
 6 files changed, 128 insertions(+), 1 deletion(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 1f09c521adfe..808e158742a2 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -408,7 +408,7 @@ struct bpf_prog {
 	enum bpf_prog_type	type;		/* Type of BPF program */
 	struct bpf_prog_aux	*aux;		/* Auxiliary fields */
 	struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
-	unsigned int		(*bpf_func)(const struct sk_buff *skb,
+	unsigned int		(*bpf_func)(const void *ctx,
 					    const struct bpf_insn *filter);
 	/* Instructions for interpreter */
 	union {
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 6b62ee9a2f78..ce5283f221e7 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -99,11 +99,13 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_XDP,
 	BPF_PROG_TYPE_PERF_EVENT,
 	BPF_PROG_TYPE_CGROUP_SKB,
+	BPF_PROG_TYPE_CGROUP_SOCK,
 };
 
 enum bpf_attach_type {
 	BPF_CGROUP_INET_INGRESS,
 	BPF_CGROUP_INET_EGRESS,
+	BPF_CGROUP_INET_SOCK_CREATE,
 	__MAX_BPF_ATTACH_TYPE
 };
 
@@ -449,6 +451,15 @@ enum bpf_func_id {
 	 */
 	BPF_FUNC_get_numa_node_id,
 
+	/**
+	 * sock_store_u32(sk, offset, val) - store bytes into sock
+	 * @sk: pointer to sock
+	 * @offset: offset within sock
+	 * @val: value to write
+	 * Return: 0 on success
+	 */
+	BPF_FUNC_sock_store_u32,
+
 	__BPF_FUNC_MAX_ID,
 };
 
@@ -524,6 +535,10 @@ struct bpf_tunnel_key {
 	__u32 tunnel_label;
 };
 
+struct bpf_sock {
+	__u32 bound_dev_if;
+};
+
 /* User return codes for XDP prog type.
  * A valid XDP program must return one of these defined values. All other
  * return codes are reserved for future use. Unknown return codes will result
diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
index 918c01a6f129..4fcb58013a3a 100644
--- a/kernel/bpf/cgroup.c
+++ b/kernel/bpf/cgroup.c
@@ -117,6 +117,12 @@ void __cgroup_bpf_update(struct cgroup *cgrp,
 	}
 }
 
+static int __cgroup_bpf_run_filter_sk_create(struct sock *sk,
+					     struct bpf_prog *prog)
+{
+	return prog->bpf_func(sk, prog->insnsi) == 1 ? 0 : -EPERM;
+}
+
 static int __cgroup_bpf_run_filter_skb(struct sk_buff *skb,
 				       struct bpf_prog *prog)
 {
@@ -171,6 +177,9 @@ int __cgroup_bpf_run_filter(struct sock *sk,
 		case BPF_CGROUP_INET_EGRESS:
 			ret = __cgroup_bpf_run_filter_skb(skb, prog);
 			break;
+		case BPF_CGROUP_INET_SOCK_CREATE:
+			ret = __cgroup_bpf_run_filter_sk_create(sk, prog);
+			break;
 		/* make gcc happy else complains about missing enum value */
 		default:
 			return 0;
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 9abc88deabbc..3b7e30e28cd3 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -844,6 +844,9 @@ static int bpf_prog_attach(const union bpf_attr *attr)
 		ptype = BPF_PROG_TYPE_CGROUP_SKB;
 		break;
 
+	case BPF_CGROUP_INET_SOCK_CREATE:
+		ptype = BPF_PROG_TYPE_CGROUP_SOCK;
+		break;
 	default:
 		return -EINVAL;
 	}
@@ -879,6 +882,7 @@ static int bpf_prog_detach(const union bpf_attr *attr)
 	switch (attr->attach_type) {
 	case BPF_CGROUP_INET_INGRESS:
 	case BPF_CGROUP_INET_EGRESS:
+	case BPF_CGROUP_INET_SOCK_CREATE:
 		cgrp = cgroup_get_from_fd(attr->target_fd);
 		if (IS_ERR(cgrp))
 			return PTR_ERR(cgrp);
diff --git a/net/core/filter.c b/net/core/filter.c
index 4552b8c93b99..775802881b01 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2482,6 +2482,27 @@ static const struct bpf_func_proto bpf_xdp_event_output_proto = {
 	.arg5_type	= ARG_CONST_STACK_SIZE,
 };
 
+BPF_CALL_3(bpf_sock_store_u32, struct sock *, sk, u32, offset, u32, val)
+{
+	u8 *ptr = (u8 *)sk;
+
+	if (unlikely(offset > sizeof(*sk)))
+		return -EFAULT;
+
+	*((u32 *)ptr) = val;
+
+	return 0;
+}
+
+static const struct bpf_func_proto bpf_sock_store_u32_proto = {
+	.func		= bpf_sock_store_u32,
+	.gpl_only	= true,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_ANYTHING,
+	.arg3_type	= ARG_ANYTHING,
+};
+
 static const struct bpf_func_proto *
 sk_filter_func_proto(enum bpf_func_id func_id)
 {
@@ -2593,6 +2614,17 @@ cg_skb_func_proto(enum bpf_func_id func_id)
 	}
 }
 
+static const struct bpf_func_proto *
+cg_sock_func_proto(enum bpf_func_id func_id)
+{
+	switch (func_id) {
+	case BPF_FUNC_sock_store_u32:
+		return &bpf_sock_store_u32_proto;
+	default:
+		return NULL;
+	}
+}
+
 static bool __is_valid_access(int off, int size, enum bpf_access_type type)
 {
 	if (off < 0 || off >= sizeof(struct __sk_buff))
@@ -2630,6 +2662,30 @@ static bool sk_filter_is_valid_access(int off, int size,
 	return __is_valid_access(off, size, type);
 }
 
+static bool sock_filter_is_valid_access(int off, int size,
+					enum bpf_access_type type,
+					enum bpf_reg_type *reg_type)
+{
+	if (type == BPF_WRITE) {
+		switch (off) {
+		case offsetof(struct bpf_sock, bound_dev_if):
+			break;
+		default:
+			return false;
+		}
+	}
+
+	if (off < 0 || off >= sizeof(struct bpf_sock))
+		return false;
+	/* The verifier guarantees that size > 0. */
+	if (off % size != 0)
+		return false;
+	if (size != sizeof(__u32))
+		return false;
+
+	return true;
+}
+
 static int tc_cls_act_prologue(struct bpf_insn *insn_buf, bool direct_write,
 			       const struct bpf_prog *prog)
 {
@@ -2888,6 +2944,30 @@ static u32 sk_filter_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 	return insn - insn_buf;
 }
 
+static u32 sock_filter_convert_ctx_access(enum bpf_access_type type,
+					  int dst_reg, int src_reg,
+					  int ctx_off,
+					  struct bpf_insn *insn_buf,
+					  struct bpf_prog *prog)
+{
+	struct bpf_insn *insn = insn_buf;
+
+	switch (ctx_off) {
+	case offsetof(struct bpf_sock, bound_dev_if):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sock, sk_bound_dev_if) != 4);
+
+		if (type == BPF_WRITE)
+			*insn++ = BPF_STX_MEM(BPF_W, dst_reg, src_reg,
+					offsetof(struct sock, sk_bound_dev_if));
+		else
+			*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
+				      offsetof(struct sock, sk_bound_dev_if));
+		break;
+	}
+
+	return insn - insn_buf;
+}
+
 static u32 tc_cls_act_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 					 int src_reg, int ctx_off,
 					 struct bpf_insn *insn_buf,
@@ -2961,6 +3041,12 @@ static const struct bpf_verifier_ops cg_skb_ops = {
 	.convert_ctx_access	= sk_filter_convert_ctx_access,
 };
 
+static const struct bpf_verifier_ops cg_sock_ops = {
+	.get_func_proto		= cg_sock_func_proto,
+	.is_valid_access	= sock_filter_is_valid_access,
+	.convert_ctx_access	= sock_filter_convert_ctx_access,
+};
+
 static struct bpf_prog_type_list sk_filter_type __read_mostly = {
 	.ops	= &sk_filter_ops,
 	.type	= BPF_PROG_TYPE_SOCKET_FILTER,
@@ -2986,6 +3072,11 @@ static struct bpf_prog_type_list cg_skb_type __read_mostly = {
 	.type	= BPF_PROG_TYPE_CGROUP_SKB,
 };
 
+static struct bpf_prog_type_list cg_sock_type __read_mostly = {
+	.ops	= &cg_sock_ops,
+	.type	= BPF_PROG_TYPE_CGROUP_SOCK
+};
+
 static int __init register_sk_filter_ops(void)
 {
 	bpf_register_prog_type(&sk_filter_type);
@@ -2993,6 +3084,7 @@ static int __init register_sk_filter_ops(void)
 	bpf_register_prog_type(&sched_act_type);
 	bpf_register_prog_type(&xdp_type);
 	bpf_register_prog_type(&cg_skb_type);
+	bpf_register_prog_type(&cg_sock_type);
 
 	return 0;
 }
diff --git a/net/core/sock.c b/net/core/sock.c
index d8e4532e89e7..936f221cc6c6 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1404,6 +1404,13 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 		cgroup_sk_alloc(&sk->sk_cgrp_data);
 		sock_update_classid(&sk->sk_cgrp_data);
 		sock_update_netprioidx(&sk->sk_cgrp_data);
+
+		if (!kern &&
+		    cgroup_bpf_run_filter(sk, NULL,
+					  BPF_CGROUP_INET_SOCK_CREATE)) {
+			sk_free(sk);
+			sk = NULL;
+		}
 	}
 
 	return sk;
-- 
2.1.4
