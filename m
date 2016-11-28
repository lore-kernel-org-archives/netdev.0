From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v3 2/3] bpf: Add new cgroup attach type to enable sock modifications
Date: Mon, 28 Nov 2016 07:48:49 -0800
Message-ID: <1480348130-31354-3-git-send-email-dsa@cumulusnetworks.com>
References: <1480348130-31354-1-git-send-email-dsa@cumulusnetworks.com>
Cc: daniel@zonque.org, ast@fb.com, daniel@iogearbox.net,
        maheshb@google.com, tgraf@suug.ch,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:32943 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754740AbcK1Ps7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 10:48:59 -0500
Received: by mail-pg0-f53.google.com with SMTP id 3so58317777pgd.0
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 07:48:58 -0800 (PST)
In-Reply-To: <1480348130-31354-1-git-send-email-dsa@cumulusnetworks.com>
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
v3
- reverted to new prog type BPF_PROG_TYPE_CGROUP_SOCK
- dropped the subtype

v2
- dropped the bpf_sock_store_u32 helper
- dropped the new prog type BPF_PROG_TYPE_CGROUP_SOCK
- moved valid access and context conversion to use subtype
- dropped CREATE from BPF_CGROUP_INET_SOCK and related function names
- moved running of filter from sk_alloc to inet{6}_create

 include/linux/bpf-cgroup.h | 11 ++++++++
 include/linux/filter.h     |  2 +-
 include/uapi/linux/bpf.h   |  6 +++++
 kernel/bpf/cgroup.c        |  9 +++++++
 kernel/bpf/syscall.c       |  5 +++-
 net/core/filter.c          | 65 ++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/af_inet.c         | 12 ++++++++-
 net/ipv6/af_inet6.c        |  8 ++++++
 8 files changed, 115 insertions(+), 3 deletions(-)

diff --git a/include/linux/bpf-cgroup.h b/include/linux/bpf-cgroup.h
index ec80d0c0953e..2ca529664c8b 100644
--- a/include/linux/bpf-cgroup.h
+++ b/include/linux/bpf-cgroup.h
@@ -64,6 +64,16 @@ int __cgroup_bpf_run_filter(struct sock *sk,
 	__ret;								\
 })
 
+#define BPF_CGROUP_RUN_PROG_INET_SOCK(sk)				\
+({									\
+	int __ret = 0;							\
+	if (cgroup_bpf_enabled && sk) {					\
+		__ret = __cgroup_bpf_run_filter(sk, NULL,		\
+						BPF_CGROUP_INET_SOCK);	\
+	}								\
+	__ret;								\
+})
+
 #else
 
 struct cgroup_bpf {};
@@ -73,6 +83,7 @@ static inline void cgroup_bpf_inherit(struct cgroup *cgrp,
 
 #define BPF_CGROUP_RUN_PROG_INET_INGRESS(sk,skb) ({ 0; })
 #define BPF_CGROUP_RUN_PROG_INET_EGRESS(sk,skb) ({ 0; })
+#define BPF_CGROUP_RUN_PROG_INET_SOCK(sk) ({ 0; })
 
 #endif /* CONFIG_CGROUP_BPF */
 
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
index 1370a9d1456f..8f410ecdaac4 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -101,11 +101,13 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_XDP,
 	BPF_PROG_TYPE_PERF_EVENT,
 	BPF_PROG_TYPE_CGROUP_SKB,
+	BPF_PROG_TYPE_CGROUP_SOCK,
 };
 
 enum bpf_attach_type {
 	BPF_CGROUP_INET_INGRESS,
 	BPF_CGROUP_INET_EGRESS,
+	BPF_CGROUP_INET_SOCK,
 	__MAX_BPF_ATTACH_TYPE
 };
 
@@ -537,6 +539,10 @@ struct bpf_tunnel_key {
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
index d5746aec8f34..796e39aa28f5 100644
--- a/kernel/bpf/cgroup.c
+++ b/kernel/bpf/cgroup.c
@@ -117,6 +117,12 @@ void __cgroup_bpf_update(struct cgroup *cgrp,
 	}
 }
 
+static int __cgroup_bpf_run_filter_sock(struct sock *sk,
+					struct bpf_prog *prog)
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
+		case BPF_CGROUP_INET_SOCK:
+			ret = __cgroup_bpf_run_filter_sock(sk, prog);
+			break;
 		/* make gcc happy else complains about missing enum value */
 		default:
 			return 0;
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index c2bce596e842..f5247901a4cc 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -856,7 +856,9 @@ static int bpf_prog_attach(const union bpf_attr *attr)
 	case BPF_CGROUP_INET_EGRESS:
 		ptype = BPF_PROG_TYPE_CGROUP_SKB;
 		break;
-
+	case BPF_CGROUP_INET_SOCK:
+		ptype = BPF_PROG_TYPE_CGROUP_SOCK;
+		break;
 	default:
 		return -EINVAL;
 	}
@@ -892,6 +894,7 @@ static int bpf_prog_detach(const union bpf_attr *attr)
 	switch (attr->attach_type) {
 	case BPF_CGROUP_INET_INGRESS:
 	case BPF_CGROUP_INET_EGRESS:
+	case BPF_CGROUP_INET_SOCK:
 		cgrp = cgroup_get_from_fd(attr->target_fd);
 		if (IS_ERR(cgrp))
 			return PTR_ERR(cgrp);
diff --git a/net/core/filter.c b/net/core/filter.c
index ea315af56511..593b6b664c0c 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2645,6 +2645,12 @@ cg_skb_func_proto(enum bpf_func_id func_id)
 	}
 }
 
+static const struct bpf_func_proto *
+cg_sock_func_proto(enum bpf_func_id func_id)
+{
+	return NULL;
+}
+
 static bool __is_valid_access(int off, int size, enum bpf_access_type type)
 {
 	if (off < 0 || off >= sizeof(struct __sk_buff))
@@ -2682,6 +2688,29 @@ static bool sk_filter_is_valid_access(int off, int size,
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
+	if (off < 0 || off + size > sizeof(struct bpf_sock))
+		return false;
+
+	/* The verifier guarantees that size > 0. */
+	if (off % size != 0)
+		return false;
+
+	return true;
+}
+
 static int tc_cls_act_prologue(struct bpf_insn *insn_buf, bool direct_write,
 			       const struct bpf_prog *prog)
 {
@@ -2940,6 +2969,30 @@ static u32 sk_filter_convert_ctx_access(enum bpf_access_type type, int dst_reg,
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
@@ -3013,6 +3066,12 @@ static const struct bpf_verifier_ops cg_skb_ops = {
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
@@ -3038,6 +3097,11 @@ static struct bpf_prog_type_list cg_skb_type __read_mostly = {
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
@@ -3045,6 +3109,7 @@ static int __init register_sk_filter_ops(void)
 	bpf_register_prog_type(&sched_act_type);
 	bpf_register_prog_type(&xdp_type);
 	bpf_register_prog_type(&cg_skb_type);
+	bpf_register_prog_type(&cg_sock_type);
 
 	return 0;
 }
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 5ddf5cda07f4..24d2550492ee 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -374,8 +374,18 @@ static int inet_create(struct net *net, struct socket *sock, int protocol,
 
 	if (sk->sk_prot->init) {
 		err = sk->sk_prot->init(sk);
-		if (err)
+		if (err) {
+			sk_common_release(sk);
+			goto out;
+		}
+	}
+
+	if (!kern) {
+		err = BPF_CGROUP_RUN_PROG_INET_SOCK(sk);
+		if (err) {
 			sk_common_release(sk);
+			goto out;
+		}
 	}
 out:
 	return err;
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index d424f3a3737a..237e654ba717 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -258,6 +258,14 @@ static int inet6_create(struct net *net, struct socket *sock, int protocol,
 			goto out;
 		}
 	}
+
+	if (!kern) {
+		err = BPF_CGROUP_RUN_PROG_INET_SOCK(sk);
+		if (err) {
+			sk_common_release(sk);
+			goto out;
+		}
+	}
 out:
 	return err;
 out_rcu_unlock:
-- 
2.1.4
