From: Roman Gushchin <guro@fb.com>
Subject: [PATCH net-next 2/4] bpf, cgroup: implement eBPF-based device controller for cgroup v2
Date: Wed, 1 Nov 2017 11:20:35 -0400
Message-ID: <20171101152037.3288-3-guro@fb.com>
References: <20171101152037.3288-1-guro@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tejun Heo <tj@kernel.org>, Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        <linux-kernel@vger.kernel.org>, Roman Gushchin <guro@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:57942 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754714AbdKAPVg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 11:21:36 -0400
In-Reply-To: <20171101152037.3288-1-guro@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cgroup v2 lacks the device controller, provided by cgroup v1.
This patch adds a new eBPF program type, which in combination
of previously added ability to attach multiple eBPF programs
to a cgroup, will provide a similar functionality, but with some
additional flexibility.

This patch introduces a BPF_PROG_TYPE_CGROUP_DEVICE program type.
A program takes major and minor device numbers, device type
(block/character) and access type (mknod/read/write) as parameters
and returns an integer which defines if the operation should be
allowed or terminated with -EPERM.

Signed-off-by: Roman Gushchin <guro@fb.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Tejun Heo <tj@kernel.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/bpf-cgroup.h     | 15 ++++++++++
 include/linux/bpf_types.h      |  3 ++
 include/linux/device_cgroup.h  |  8 ++++-
 include/uapi/linux/bpf.h       | 15 ++++++++++
 kernel/bpf/cgroup.c            | 67 ++++++++++++++++++++++++++++++++++++++++++
 kernel/bpf/syscall.c           |  7 +++++
 kernel/bpf/verifier.c          |  1 +
 tools/include/uapi/linux/bpf.h | 15 ++++++++++
 8 files changed, 130 insertions(+), 1 deletion(-)

diff --git a/include/linux/bpf-cgroup.h b/include/linux/bpf-cgroup.h
index 359b6f5d3d90..d77cefb3fe99 100644
--- a/include/linux/bpf-cgroup.h
+++ b/include/linux/bpf-cgroup.h
@@ -66,6 +66,9 @@ int __cgroup_bpf_run_filter_sock_ops(struct sock *sk,
 				     struct bpf_sock_ops_kern *sock_ops,
 				     enum bpf_attach_type type);
 
+int __cgroup_bpf_check_dev_permission(short dev_type, u32 major, u32 minor,
+				      short access, enum bpf_attach_type type);
+
 /* Wrappers for __cgroup_bpf_run_filter_skb() guarded by cgroup_bpf_enabled. */
 #define BPF_CGROUP_RUN_PROG_INET_INGRESS(sk, skb)			      \
 ({									      \
@@ -111,6 +114,17 @@ int __cgroup_bpf_run_filter_sock_ops(struct sock *sk,
 	}								       \
 	__ret;								       \
 })
+
+#define BPF_CGROUP_RUN_PROG_DEVICE_CGROUP(type, major, minor, access)	      \
+({									      \
+	int __ret = 0;							      \
+	if (cgroup_bpf_enabled)						      \
+		__ret = __cgroup_bpf_check_dev_permission(type, major, minor, \
+							  access,	      \
+							  BPF_CGROUP_DEVICE); \
+									      \
+	__ret;								      \
+})
 #else
 
 struct cgroup_bpf {};
@@ -121,6 +135,7 @@ static inline int cgroup_bpf_inherit(struct cgroup *cgrp) { return 0; }
 #define BPF_CGROUP_RUN_PROG_INET_EGRESS(sk,skb) ({ 0; })
 #define BPF_CGROUP_RUN_PROG_INET_SOCK(sk) ({ 0; })
 #define BPF_CGROUP_RUN_PROG_SOCK_OPS(sock_ops) ({ 0; })
+#define BPF_CGROUP_RUN_PROG_DEVICE_CGROUP(type,major,minor,access) ({ 0; })
 
 #endif /* CONFIG_CGROUP_BPF */
 
diff --git a/include/linux/bpf_types.h b/include/linux/bpf_types.h
index 36418ad43245..963a97ee4b7c 100644
--- a/include/linux/bpf_types.h
+++ b/include/linux/bpf_types.h
@@ -18,6 +18,9 @@ BPF_PROG_TYPE(BPF_PROG_TYPE_KPROBE, kprobe)
 BPF_PROG_TYPE(BPF_PROG_TYPE_TRACEPOINT, tracepoint)
 BPF_PROG_TYPE(BPF_PROG_TYPE_PERF_EVENT, perf_event)
 #endif
+#ifdef CONFIG_CGROUP_BPF
+BPF_PROG_TYPE(BPF_PROG_TYPE_CGROUP_DEVICE, cg_dev)
+#endif
 
 BPF_MAP_TYPE(BPF_MAP_TYPE_ARRAY, array_map_ops)
 BPF_MAP_TYPE(BPF_MAP_TYPE_PERCPU_ARRAY, percpu_array_map_ops)
diff --git a/include/linux/device_cgroup.h b/include/linux/device_cgroup.h
index 25f1dc7673db..9a4f849f73cb 100644
--- a/include/linux/device_cgroup.h
+++ b/include/linux/device_cgroup.h
@@ -1,4 +1,5 @@
 #include <linux/fs.h>
+#include <linux/bpf-cgroup.h>
 
 #define ACC_MKNOD 1
 #define ACC_READ  2
@@ -18,10 +19,15 @@ static inline int __devcgroup_check_permission(short type, u32 major, u32 minor,
 { return 0; }
 #endif
 
-#ifdef CONFIG_CGROUP_DEVICE
+#if defined(CONFIG_CGROUP_DEVICE) || defined(CONFIG_CGROUP_BPF)
 static inline int devcgroup_check_permission(short type, u32 major, u32 minor,
 					     short access)
 {
+	int rc = BPF_CGROUP_RUN_PROG_DEVICE_CGROUP(type, major, minor, access);
+
+	if (rc)
+		return -EPERM;
+
 	return __devcgroup_check_permission(type, major, minor, access);
 }
 
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 0b7b54d898bd..4deb3c9acbb2 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -131,6 +131,7 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_LWT_XMIT,
 	BPF_PROG_TYPE_SOCK_OPS,
 	BPF_PROG_TYPE_SK_SKB,
+	BPF_PROG_TYPE_CGROUP_DEVICE,
 };
 
 enum bpf_attach_type {
@@ -140,6 +141,7 @@ enum bpf_attach_type {
 	BPF_CGROUP_SOCK_OPS,
 	BPF_SK_SKB_STREAM_PARSER,
 	BPF_SK_SKB_STREAM_VERDICT,
+	BPF_CGROUP_DEVICE,
 	__MAX_BPF_ATTACH_TYPE
 };
 
@@ -984,4 +986,17 @@ struct bpf_perf_event_value {
 	__u64 running;
 };
 
+#define DEV_BPF_ACC_MKNOD	(1ULL << 0)
+#define DEV_BPF_ACC_READ	(1ULL << 1)
+#define DEV_BPF_ACC_WRITE	(1ULL << 2)
+
+#define DEV_BPF_DEV_BLOCK	(1ULL << 0)
+#define DEV_BPF_DEV_CHAR	(1ULL << 1)
+
+struct bpf_cgroup_dev_ctx {
+	__u32 access_type; /* (access << 16) | type */
+	__u32 major;
+	__u32 minor;
+};
+
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
index 3db5a17fcfe8..b789ab78d28f 100644
--- a/kernel/bpf/cgroup.c
+++ b/kernel/bpf/cgroup.c
@@ -522,3 +522,70 @@ int __cgroup_bpf_run_filter_sock_ops(struct sock *sk,
 	return ret == 1 ? 0 : -EPERM;
 }
 EXPORT_SYMBOL(__cgroup_bpf_run_filter_sock_ops);
+
+int __cgroup_bpf_check_dev_permission(short dev_type, u32 major, u32 minor,
+				      short access, enum bpf_attach_type type)
+{
+	struct cgroup *cgrp;
+	struct bpf_cgroup_dev_ctx ctx = {
+		.access_type = (access << 16) | dev_type,
+		.major = major,
+		.minor = minor,
+	};
+	int allow = 1;
+
+	rcu_read_lock();
+	cgrp = task_dfl_cgroup(current);
+	allow = BPF_PROG_RUN_ARRAY(cgrp->bpf.effective[type], &ctx,
+				   BPF_PROG_RUN);
+	rcu_read_unlock();
+
+	return !allow;
+}
+EXPORT_SYMBOL(__cgroup_bpf_check_dev_permission);
+
+static const struct bpf_func_proto *
+cgroup_dev_func_proto(enum bpf_func_id func_id)
+{
+	switch (func_id) {
+	case BPF_FUNC_map_lookup_elem:
+		return &bpf_map_lookup_elem_proto;
+	case BPF_FUNC_map_update_elem:
+		return &bpf_map_update_elem_proto;
+	case BPF_FUNC_map_delete_elem:
+		return &bpf_map_delete_elem_proto;
+	case BPF_FUNC_get_current_uid_gid:
+		return &bpf_get_current_uid_gid_proto;
+	case BPF_FUNC_trace_printk:
+		if (capable(CAP_SYS_ADMIN))
+			return bpf_get_trace_printk_proto();
+	default:
+		return NULL;
+	}
+}
+
+static bool cgroup_dev_is_valid_access(int off, int size,
+				       enum bpf_access_type type,
+				       struct bpf_insn_access_aux *info)
+{
+	if (type == BPF_WRITE)
+		return false;
+
+	if (off < 0 || off + size > sizeof(struct bpf_cgroup_dev_ctx))
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
+const struct bpf_prog_ops cg_dev_prog_ops = {
+};
+
+const struct bpf_verifier_ops cg_dev_verifier_ops = {
+	.get_func_proto		= cgroup_dev_func_proto,
+	.is_valid_access	= cgroup_dev_is_valid_access,
+};
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 323be2473c4b..08f7b450828e 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -1291,6 +1291,9 @@ static int bpf_prog_attach(const union bpf_attr *attr)
 	case BPF_CGROUP_SOCK_OPS:
 		ptype = BPF_PROG_TYPE_SOCK_OPS;
 		break;
+	case BPF_CGROUP_DEVICE:
+		ptype = BPF_PROG_TYPE_CGROUP_DEVICE;
+		break;
 	case BPF_SK_SKB_STREAM_PARSER:
 	case BPF_SK_SKB_STREAM_VERDICT:
 		return sockmap_get_from_fd(attr, true);
@@ -1343,6 +1346,9 @@ static int bpf_prog_detach(const union bpf_attr *attr)
 	case BPF_CGROUP_SOCK_OPS:
 		ptype = BPF_PROG_TYPE_SOCK_OPS;
 		break;
+	case BPF_CGROUP_DEVICE:
+		ptype = BPF_PROG_TYPE_CGROUP_DEVICE;
+		break;
 	case BPF_SK_SKB_STREAM_PARSER:
 	case BPF_SK_SKB_STREAM_VERDICT:
 		return sockmap_get_from_fd(attr, false);
@@ -1385,6 +1391,7 @@ static int bpf_prog_query(const union bpf_attr *attr,
 	case BPF_CGROUP_INET_EGRESS:
 	case BPF_CGROUP_INET_SOCK_CREATE:
 	case BPF_CGROUP_SOCK_OPS:
+	case BPF_CGROUP_DEVICE:
 		break;
 	default:
 		return -EINVAL;
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 2bb6d6aa7085..811f0582a1cc 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -3100,6 +3100,7 @@ static int check_return_code(struct bpf_verifier_env *env)
 	case BPF_PROG_TYPE_CGROUP_SKB:
 	case BPF_PROG_TYPE_CGROUP_SOCK:
 	case BPF_PROG_TYPE_SOCK_OPS:
+	case BPF_PROG_TYPE_CGROUP_DEVICE:
 		break;
 	default:
 		return 0;
diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index 4a4b6e78c977..c0306ac49860 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -131,6 +131,7 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_LWT_XMIT,
 	BPF_PROG_TYPE_SOCK_OPS,
 	BPF_PROG_TYPE_SK_SKB,
+	BPF_PROG_TYPE_CGROUP_DEVICE,
 };
 
 enum bpf_attach_type {
@@ -140,6 +141,7 @@ enum bpf_attach_type {
 	BPF_CGROUP_SOCK_OPS,
 	BPF_SK_SKB_STREAM_PARSER,
 	BPF_SK_SKB_STREAM_VERDICT,
+	BPF_CGROUP_DEVICE,
 	__MAX_BPF_ATTACH_TYPE
 };
 
@@ -984,4 +986,17 @@ struct bpf_perf_event_value {
 	__u64 running;
 };
 
+#define DEV_BPF_ACC_MKNOD	(1ULL << 0)
+#define DEV_BPF_ACC_READ	(1ULL << 1)
+#define DEV_BPF_ACC_WRITE	(1ULL << 2)
+
+#define DEV_BPF_DEV_BLOCK	(1ULL << 0)
+#define DEV_BPF_DEV_CHAR	(1ULL << 1)
+
+struct bpf_cgroup_dev_ctx {
+	__u32 access_type; /* (access << 16) | type */
+	__u32 major;
+	__u32 minor;
+};
+
 #endif /* _UAPI__LINUX_BPF_H__ */
-- 
2.13.6
