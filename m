From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v4 2/3] bpf: Add new cgroup attach type to enable sock modifications
Date: Mon, 28 Nov 2016 20:38:48 -0800
Message-ID: <1480394329-24847-3-git-send-email-dsa@cumulusnetworks.com>
References: <1480394329-24847-1-git-send-email-dsa@cumulusnetworks.com>
Cc: daniel@zonque.org, ast@fb.com, daniel@iogearbox.net,
        maheshb@google.com, tgraf@suug.ch,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33935 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753135AbcK2Ei5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 23:38:57 -0500
Received: by mail-pf0-f169.google.com with SMTP id c4so29269564pfb.1
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 20:38:57 -0800 (PST)
In-Reply-To: <1480394329-24847-1-git-send-email-dsa@cumulusnetworks.com>
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
v4
- dropped tweak to bpf_func signature
- dropped cg_sock_func_proto in favor of sk_filter_func_proto
- new __cgroup_bpf_run_filter_sk versus overloading __cgroup_bpf_run_filter
- reverted BPF_CGROUP_INET_SOCK to BPF_CGROUP_INET_SOCK_CREATE

v3
- reverted to new prog type BPF_PROG_TYPE_CGROUP_SOCK
- dropped the subtype

v2
- dropped the bpf_sock_store_u32 helper
- dropped the new prog type BPF_PROG_TYPE_CGROUP_SOCK
- moved valid access and context conversion to use subtype
- dropped CREATE from BPF_CGROUP_INET_SOCK and related function names
- moved running of filter from sk_alloc to inet{6}_create

 include/linux/bpf-cgroup.h | 14 +++++++++++
 include/uapi/linux/bpf.h   |  6 +++++
 kernel/bpf/cgroup.c        | 33 ++++++++++++++++++++++++++
 kernel/bpf/syscall.c       |  5 +++-
 net/core/filter.c          | 59 ++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/af_inet.c         | 12 +++++++++-
 net/ipv6/af_inet6.c        |  8 +++++++
 7 files changed, 135 insertions(+), 2 deletions(-)

diff --git a/include/linux/bpf-cgroup.h b/include/linux/bpf-cgroup.h
index 7f0fc635b13e..7de376e37c5c 100644
--- a/include/linux/bpf-cgroup.h
+++ b/include/linux/bpf-cgroup.h
@@ -41,6 +41,9 @@ int __cgroup_bpf_run_filter_skb(struct sock *sk,
 				struct sk_buff *skb,
 				enum bpf_attach_type type);
 
+int __cgroup_bpf_run_filter_sk(struct sock *sk,
+			       enum bpf_attach_type type);
+
 /* Wrappers for __cgroup_bpf_run_filter_skb() guarded by cgroup_bpf_enabled. */
 #define BPF_CGROUP_RUN_PROG_INET_INGRESS(sk, skb)			      \
 ({									      \
@@ -64,6 +67,16 @@ int __cgroup_bpf_run_filter_skb(struct sock *sk,
 	__ret;								       \
 })
 
+#define BPF_CGROUP_RUN_PROG_INET_SOCK(sk)				       \
+({									       \
+	int __ret = 0;							       \
+	if (cgroup_bpf_enabled && sk) {					       \
+		__ret = __cgroup_bpf_run_filter_sk(sk,			       \
+						 BPF_CGROUP_INET_SOCK_CREATE); \
+	}								       \
+	__ret;								       \
+})
+
 #else
 
 struct cgroup_bpf {};
@@ -73,6 +86,7 @@ static inline void cgroup_bpf_inherit(struct cgroup *cgrp,
 
 #define BPF_CGROUP_RUN_PROG_INET_INGRESS(sk,skb) ({ 0; })
 #define BPF_CGROUP_RUN_PROG_INET_EGRESS(sk,skb) ({ 0; })
+#define BPF_CGROUP_RUN_PROG_INET_SOCK(sk) ({ 0; })
 
 #endif /* CONFIG_CGROUP_BPF */
 
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 1370a9d1456f..75964e00d947 100644
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
+	BPF_CGROUP_INET_SOCK_CREATE,
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
index 19892973a78a..fe1c9ad03a36 100644
--- a/kernel/bpf/cgroup.c
+++ b/kernel/bpf/cgroup.c
@@ -165,3 +165,36 @@ int __cgroup_bpf_run_filter_skb(struct sock *sk,
 	return ret;
 }
 EXPORT_SYMBOL(__cgroup_bpf_run_filter_skb);
+
+/**
+ * __cgroup_bpf_run_filter_sk() - Run a program on a sock
+ * @sk: sock structure to manipulate
+ * @type: The type of program to be exectuted
+ *
+ * socket is passed is expected to be of type INET or INET6.
+ *
+ * The program type passed in via @type must be suitable for sock
+ * filtering. No further check is performed to assert that.
+ *
+ * This function will return %-EPERM if any if an attached program was found
+ * and if it returned != 1 during execution. In all other cases, 0 is returned.
+ */
+int __cgroup_bpf_run_filter_sk(struct sock *sk,
+			       enum bpf_attach_type type)
+{
+	struct cgroup *cgrp = sock_cgroup_ptr(&sk->sk_cgrp_data);
+	struct bpf_prog *prog;
+	int ret = 0;
+
+
+	rcu_read_lock();
+
+	prog = rcu_dereference(cgrp->bpf.effective[type]);
+	if (prog)
+		ret = BPF_PROG_RUN(prog, sk) == 1 ? 0 : -EPERM;
+
+	rcu_read_unlock();
+
+	return ret;
+}
+EXPORT_SYMBOL(__cgroup_bpf_run_filter_sk);
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 5518a6839ab1..85af86c496cd 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -869,7 +869,9 @@ static int bpf_prog_attach(const union bpf_attr *attr)
 	case BPF_CGROUP_INET_EGRESS:
 		ptype = BPF_PROG_TYPE_CGROUP_SKB;
 		break;
-
+	case BPF_CGROUP_INET_SOCK_CREATE:
+		ptype = BPF_PROG_TYPE_CGROUP_SOCK;
+		break;
 	default:
 		return -EINVAL;
 	}
@@ -905,6 +907,7 @@ static int bpf_prog_detach(const union bpf_attr *attr)
 	switch (attr->attach_type) {
 	case BPF_CGROUP_INET_INGRESS:
 	case BPF_CGROUP_INET_EGRESS:
+	case BPF_CGROUP_INET_SOCK_CREATE:
 		cgrp = cgroup_get_from_fd(attr->target_fd);
 		if (IS_ERR(cgrp))
 			return PTR_ERR(cgrp);
diff --git a/net/core/filter.c b/net/core/filter.c
index 698a262b8ebb..404aaa1bfa1f 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2676,6 +2676,29 @@ static bool sk_filter_is_valid_access(int off, int size,
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
@@ -2934,6 +2957,30 @@ static u32 sk_filter_convert_ctx_access(enum bpf_access_type type, int dst_reg,
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
@@ -3007,6 +3054,12 @@ static const struct bpf_verifier_ops cg_skb_ops = {
 	.convert_ctx_access	= sk_filter_convert_ctx_access,
 };
 
+static const struct bpf_verifier_ops cg_sock_ops = {
+	.get_func_proto		= sk_filter_func_proto,
+	.is_valid_access	= sock_filter_is_valid_access,
+	.convert_ctx_access	= sock_filter_convert_ctx_access,
+};
+
 static struct bpf_prog_type_list sk_filter_type __read_mostly = {
 	.ops	= &sk_filter_ops,
 	.type	= BPF_PROG_TYPE_SOCKET_FILTER,
@@ -3032,6 +3085,11 @@ static struct bpf_prog_type_list cg_skb_type __read_mostly = {
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
@@ -3039,6 +3097,7 @@ static int __init register_sk_filter_ops(void)
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
