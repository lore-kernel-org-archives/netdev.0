From: Lawrence Brakmo <brakmo@fb.com>
Subject: [PATCH net-next v3 01/15] bpf: BPF support for sock_ops
Date: Mon, 19 Jun 2017 20:00:34 -0700
Message-ID: <20170620030048.3275347-2-brakmo@fb.com>
References: <20170620030048.3275347-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:57436 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750916AbdFTDAx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 23:00:53 -0400
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5K2xsaK021845
        for <netdev@vger.kernel.org>; Mon, 19 Jun 2017 20:00:52 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2b6m6ahabk-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 19 Jun 2017 20:00:52 -0700
Received: from facebook.com (2401:db00:11:d025:face:0:13:0)     by
 mx-out.facebook.com (2401:db00:2050:5102:face:0000:003b:0000) with ESMTP       id
 aada2792556411e7815d31330017d677-db6446b0 for <netdev@vger.kernel.org>;        Mon,
 19 Jun 2017 20:00:51 -0700
In-Reply-To: <20170620030048.3275347-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Created a new BPF program type, BPF_PROG_TYPE_SOCK_OPS, and a corresponding
struct that allows BPF programs of this type to access some of the
socket's fields (such as IP addresses, ports, etc.). Currently there is
functionality to load one global BPF program of this type which can be
called at appropriate times to set relevant connection parameters such
as buffer sizes, SYN and SYN-ACK RTOs, etc., based on connection
information such as IP addresses, port numbers, etc.

Alghough there are already 3 mechanisms to set parameters (sysctls,
route metrics and setsockopts), this new mechanism provides some
disticnt advantages. Unlike sysctls, it can set parameters per
connection. In contrast to route metrics, it can also use port numbers
and information provided by a user level program. In addition, it could
set parameters probabilistically for evaluation purposes (i.e. do
something different on 10% of the flows and compare results with the
other 90% of the flows). Also, in cases where IPv6 addresses contain
geographic information, the rules to make changes based on the distance
(or RTT) between the hosts are much easier than route metric rules and
can be global. Finally, unlike setsockopt, it oes not require
application changes and it can be updated easily at any time.

I plan to add support for loading per cgroup sock_ops BPF programs in
the near future. One question is whether I should add this functionality
into David Ahern's BPF_PROG_TYPE_CGROUP_SOCK or create a new cgroup bpf
type. Whereas the current cgroup_sock type expects to be called only once
during a connection's lifetime, the new sock_ops type could be called
multipe times. For example, before sending SYN and SYN-ACKs to set an
appropriate timeout, when the connection is established to set
congestion control, etc. As a result it has "op" field to specify the
type of operation requested.

The purpose of this new program type is to simplify setting connection
parameters, such as buffer sizes, TCP's SYN RTO, etc. For example, it is
easy to use facebook's internal IPv6 addresses to determine if both hosts
of a connection are in the same datacenter. Therefore, it is easy to
write a BPF program to choose a small SYN RTO value when both hosts are
in the same datacenter.

This patch only contains the framework to support the new BPF program
type, following patches add the functionality to set various connection
parameters.

This patch defines a new BPF program type: BPF_PROG_TYPE_SOCKET_OPS
and a new bpf syscall command to load a new program of this type:
BPF_PROG_LOAD_SOCKET_OPS.

Two new corresponding structs (one for the kernel one for the user/BPF
program):

/* kernel version */
struct bpf_sock_ops_kern {
        struct sock *sk;
	bool   is_req_sock:1;
        __u32  op;
        union {
                __u32 reply;
                __u32 replylong[4];
        };
};

/* user version */
struct bpf_sock_ops {
        __u32 op;
        union {
                __u32 reply;
                __u32 replylong[4];
        };
        __u32 family;
        __u32 remote_ip4;
        __u32 local_ip4;
        __u32 remote_ip6[4];
        __u32 local_ip6[4];
        __u32 remote_port;
        __u32 local_port;
};

Currently there are two types of ops. The first type expects the BPF
program to return a value which is then used by the caller (or a
negative value to indicate the operation is not supported). The second
type expects state changes to be done by the BPF program, for example
through a setsockopt BPF helper function, and they ignore the return
value.

The reply fields of the bpf_sockt_ops struct are there in case a bpf
program needs to return a value larger than an integer.

Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
---
 include/linux/bpf.h       |   6 ++
 include/linux/bpf_types.h |   1 +
 include/linux/filter.h    |  10 +++
 include/net/tcp.h         |  30 ++++++++
 include/uapi/linux/bpf.h  |  28 ++++++++
 kernel/bpf/syscall.c      |  62 +++++++++++++----
 net/core/Makefile         |   3 +-
 net/core/filter.c         | 170 ++++++++++++++++++++++++++++++++++++++++++++++
 net/core/sock_bpfops.c    |  65 ++++++++++++++++++
 samples/bpf/bpf_load.c    |  13 +++-
 10 files changed, 370 insertions(+), 18 deletions(-)
 create mode 100644 net/core/sock_bpfops.c

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 1bcbf0a..a1a1f2f 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -362,4 +362,10 @@ extern const struct bpf_func_proto bpf_get_stackid_proto;
 void bpf_user_rnd_init_once(void);
 u64 bpf_user_rnd_u32(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
 
+/* sock_ops related */
+struct bpf_sock_ops_kern;
+
+int bpf_sock_ops_attach_global_prog(int fd);
+int bpf_sock_ops_detach_global_prog(void);
+int bpf_sock_ops_call(struct bpf_sock_ops_kern *bpf_sock);
 #endif /* _LINUX_BPF_H */
diff --git a/include/linux/bpf_types.h b/include/linux/bpf_types.h
index 03bf223..3d137c3 100644
--- a/include/linux/bpf_types.h
+++ b/include/linux/bpf_types.h
@@ -10,6 +10,7 @@ BPF_PROG_TYPE(BPF_PROG_TYPE_CGROUP_SOCK, cg_sock_prog_ops)
 BPF_PROG_TYPE(BPF_PROG_TYPE_LWT_IN, lwt_inout_prog_ops)
 BPF_PROG_TYPE(BPF_PROG_TYPE_LWT_OUT, lwt_inout_prog_ops)
 BPF_PROG_TYPE(BPF_PROG_TYPE_LWT_XMIT, lwt_xmit_prog_ops)
+BPF_PROG_TYPE(BPF_PROG_TYPE_SOCK_OPS, sock_ops_prog_ops)
 #endif
 #ifdef CONFIG_BPF_EVENTS
 BPF_PROG_TYPE(BPF_PROG_TYPE_KPROBE, kprobe_prog_ops)
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 1fa26dc..bbd6429 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -898,4 +898,14 @@ static inline int bpf_tell_extensions(void)
 	return SKF_AD_MAX;
 }
 
+struct bpf_sock_ops_kern {
+	struct	sock *sk;
+	bool	is_req_sock:1;
+	u32	op;
+	union {
+		u32 reply;
+		u32 replylong[4];
+	};
+};
+
 #endif /* __LINUX_FILTER_H__ */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index d0751b7..f6f415c 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -46,6 +46,9 @@
 #include <linux/seq_file.h>
 #include <linux/memcontrol.h>
 
+#include <linux/bpf.h>
+#include <linux/filter.h>
+
 extern struct inet_hashinfo tcp_hashinfo;
 
 extern struct percpu_counter tcp_orphan_count;
@@ -2021,4 +2024,31 @@ int tcp_set_ulp(struct sock *sk, const char *name);
 void tcp_get_available_ulp(char *buf, size_t len);
 void tcp_cleanup_ulp(struct sock *sk);
 
+/* Call BPF_SOCK_OPS program that returns an int. If the return value
+ * is < 0, then the BPF op failed (for example if the loaded BPF
+ * program does not support the chosen operation or there is no BPF
+ * program loaded).
+ */
+#ifdef CONFIG_BPF
+static inline int tcp_call_bpf(struct sock *sk, bool is_req_sock, int op)
+{
+	struct bpf_sock_ops_kern sock_ops;
+
+	if (!is_req_sock)
+		sock_owned_by_me(sk);
+
+	memset(&sock_ops, 0, sizeof(sock_ops));
+	sock_ops.sk = sk;
+	sock_ops.is_req_sock = is_req_sock;
+	sock_ops.op = op;
+
+	return bpf_sock_ops_call(&sock_ops);
+}
+#else
+static inline int tcp_call_bpf(struct sock *sk, bool is_req_sock, int op)
+{
+	return -1;
+}
+#endif
+
 #endif	/* _TCP_H */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index f94b48b..861dbe9 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -120,12 +120,14 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_LWT_IN,
 	BPF_PROG_TYPE_LWT_OUT,
 	BPF_PROG_TYPE_LWT_XMIT,
+	BPF_PROG_TYPE_SOCK_OPS,
 };
 
 enum bpf_attach_type {
 	BPF_CGROUP_INET_INGRESS,
 	BPF_CGROUP_INET_EGRESS,
 	BPF_CGROUP_INET_SOCK_CREATE,
+	BPF_GLOBAL_SOCK_OPS,
 	__MAX_BPF_ATTACH_TYPE
 };
 
@@ -720,4 +722,30 @@ struct bpf_map_info {
 	__u32 map_flags;
 } __attribute__((aligned(8)));
 
+/* User bpf_sock_ops struct to access socket values and specify request ops
+ * and their replies.
+ * New fields can only be added at the end of this structure
+ */
+struct bpf_sock_ops {
+	__u32 op;
+	union {
+		__u32 reply;
+		__u32 replylong[4];
+	};
+	__u32 family;
+	__u32 remote_ip4;
+	__u32 local_ip4;
+	__u32 remote_ip6[4];
+	__u32 local_ip6[4];
+	__u32 remote_port;
+	__u32 local_port;
+};
+
+/* List of known BPF sock_ops operators.
+ * New entries can only be added at the end
+ */
+enum {
+	BPF_SOCK_OPS_VOID,
+};
+
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 8942c82..e02831f 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -1041,23 +1041,17 @@ static int bpf_obj_get(const union bpf_attr *attr)
 	return bpf_obj_get_user(u64_to_user_ptr(attr->pathname));
 }
 
-#ifdef CONFIG_CGROUP_BPF
-
 #define BPF_PROG_ATTACH_LAST_FIELD attach_flags
 
-static int bpf_prog_attach(const union bpf_attr *attr)
+#ifdef CONFIG_CGROUP_BPF
+
+static int bpf_prog_attach_cgroup(const union bpf_attr *attr)
 {
 	enum bpf_prog_type ptype;
 	struct bpf_prog *prog;
 	struct cgroup *cgrp;
 	int ret;
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
-	if (CHECK_ATTR(BPF_PROG_ATTACH))
-		return -EINVAL;
-
 	if (attr->attach_flags & ~BPF_F_ALLOW_OVERRIDE)
 		return -EINVAL;
 
@@ -1092,9 +1086,32 @@ static int bpf_prog_attach(const union bpf_attr *attr)
 	return ret;
 }
 
+#else
+static int bpf_prog_attach_cgroup(const union bpf_attr *attr)
+{
+	return -EINVAL;
+}
+#endif
+
+static int bpf_prog_attach(const union bpf_attr *attr)
+{
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (CHECK_ATTR(BPF_PROG_ATTACH))
+		return -EINVAL;
+
+	if (attr->attach_type == BPF_GLOBAL_SOCK_OPS)
+		return bpf_sock_ops_attach_global_prog(attr->attach_bpf_fd);
+	else
+		return bpf_prog_attach_cgroup(attr);
+}
+
 #define BPF_PROG_DETACH_LAST_FIELD attach_type
 
-static int bpf_prog_detach(const union bpf_attr *attr)
+#ifdef CONFIG_CGROUP_BPF
+
+static int bpf_prog_detach_cgroup(const union bpf_attr *attr)
 {
 	struct cgroup *cgrp;
 	int ret;
@@ -1116,14 +1133,33 @@ static int bpf_prog_detach(const union bpf_attr *attr)
 		ret = cgroup_bpf_update(cgrp, NULL, attr->attach_type, false);
 		cgroup_put(cgrp);
 		break;
-
 	default:
 		return -EINVAL;
 	}
 
 	return ret;
 }
-#endif /* CONFIG_CGROUP_BPF */
+
+#else
+static int bpf_prog_detach_cgroup(const union bpf_attr *attr)
+{
+	return -EINVAL;
+}
+#endif
+
+static int bpf_prog_detach(const union bpf_attr *attr)
+{
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (CHECK_ATTR(BPF_PROG_DETACH))
+		return -EINVAL;
+
+	if (attr->attach_type == BPF_GLOBAL_SOCK_OPS)
+		return bpf_sock_ops_detach_global_prog();
+	else
+		return bpf_prog_detach_cgroup(attr);
+}
 
 #define BPF_PROG_TEST_RUN_LAST_FIELD test.duration
 
@@ -1431,14 +1467,12 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
 	case BPF_OBJ_GET:
 		err = bpf_obj_get(&attr);
 		break;
-#ifdef CONFIG_CGROUP_BPF
 	case BPF_PROG_ATTACH:
 		err = bpf_prog_attach(&attr);
 		break;
 	case BPF_PROG_DETACH:
 		err = bpf_prog_detach(&attr);
 		break;
-#endif
 	case BPF_PROG_TEST_RUN:
 		err = bpf_prog_test_run(&attr, uattr);
 		break;
diff --git a/net/core/Makefile b/net/core/Makefile
index 79f9479..5d711c2 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -9,7 +9,8 @@ obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
 
 obj-y		     += dev.o ethtool.o dev_addr_lists.o dst.o netevent.o \
 			neighbour.o rtnetlink.o utils.o link_watch.o filter.o \
-			sock_diag.o dev_ioctl.o tso.o sock_reuseport.o
+			sock_diag.o dev_ioctl.o tso.o sock_reuseport.o \
+			sock_bpfops.o
 
 obj-$(CONFIG_XFRM) += flow.o
 obj-y += net-sysfs.o
diff --git a/net/core/filter.c b/net/core/filter.c
index 60ed6f3..7d69d16 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -3095,6 +3095,36 @@ void bpf_warn_invalid_xdp_action(u32 act)
 }
 EXPORT_SYMBOL_GPL(bpf_warn_invalid_xdp_action);
 
+static bool __is_valid_sock_ops_access(int off, int size)
+{
+	if (off < 0 || off >= sizeof(struct bpf_sock_ops))
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
+static bool sock_ops_is_valid_access(int off, int size,
+				     enum bpf_access_type type,
+				     enum bpf_reg_type *reg_type)
+{
+	if (type == BPF_WRITE) {
+		switch (off) {
+		case offsetof(struct bpf_sock_ops, op) ...
+		     offsetof(struct bpf_sock_ops, replylong[3]):
+			break;
+		default:
+			return false;
+		}
+	}
+
+	return __is_valid_sock_ops_access(off, size);
+}
+
 static u32 bpf_convert_ctx_access(enum bpf_access_type type,
 				  const struct bpf_insn *si,
 				  struct bpf_insn *insn_buf,
@@ -3364,6 +3394,140 @@ static u32 xdp_convert_ctx_access(enum bpf_access_type type,
 	return insn - insn_buf;
 }
 
+static u32 sock_ops_convert_ctx_access(enum bpf_access_type type,
+				       const struct bpf_insn *si,
+				       struct bpf_insn *insn_buf,
+				       struct bpf_prog *prog)
+{
+	struct bpf_insn *insn = insn_buf;
+	int off;
+
+	switch (si->off) {
+	case offsetof(struct bpf_sock_ops, op) ...
+	     offsetof(struct bpf_sock_ops, replylong[3]):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct bpf_sock_ops, op) !=
+			     FIELD_SIZEOF(struct bpf_sock_ops_kern, op));
+		BUILD_BUG_ON(FIELD_SIZEOF(struct bpf_sock_ops, reply) !=
+			     FIELD_SIZEOF(struct bpf_sock_ops_kern, reply));
+		BUILD_BUG_ON(FIELD_SIZEOF(struct bpf_sock_ops, replylong) !=
+			     FIELD_SIZEOF(struct bpf_sock_ops_kern, replylong));
+		off = si->off;
+		off -= offsetof(struct bpf_sock_ops, op);
+		off += offsetof(struct bpf_sock_ops_kern, op);
+		if (type == BPF_WRITE)
+			*insn++ = BPF_STX_MEM(BPF_W, si->dst_reg, si->src_reg,
+					      off);
+		else
+			*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->src_reg,
+					      off);
+		break;
+
+	case offsetof(struct bpf_sock_ops, family):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common, skc_family) != 2);
+
+		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(
+					      struct bpf_sock_ops_kern, sk),
+				      si->dst_reg, si->src_reg,
+				      offsetof(struct bpf_sock_ops_kern, sk));
+		*insn++ = BPF_LDX_MEM(BPF_H, si->dst_reg, si->dst_reg,
+				      offsetof(struct sock_common, skc_family));
+		break;
+
+	case offsetof(struct bpf_sock_ops, remote_ip4):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common, skc_daddr) != 4);
+
+		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(
+						struct bpf_sock_ops_kern, sk),
+				      si->dst_reg, si->src_reg,
+				      offsetof(struct bpf_sock_ops_kern, sk));
+		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->dst_reg,
+				      offsetof(struct sock_common, skc_daddr));
+		*insn++ = BPF_ENDIAN(BPF_FROM_BE, si->dst_reg, 32);
+		break;
+
+	case offsetof(struct bpf_sock_ops, local_ip4):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common, skc_rcv_saddr) != 4);
+
+		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(
+					      struct bpf_sock_ops_kern, sk),
+				      si->dst_reg, si->src_reg,
+				      offsetof(struct bpf_sock_ops_kern, sk));
+		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->dst_reg,
+				      offsetof(struct sock_common,
+					       skc_rcv_saddr));
+		*insn++ = BPF_ENDIAN(BPF_FROM_BE, si->dst_reg, 32);
+		break;
+
+	case offsetof(struct bpf_sock_ops, remote_ip6[0]) ...
+	     offsetof(struct bpf_sock_ops, remote_ip6[3]):
+#if IS_ENABLED(CONFIG_IPV6)
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common,
+					  skc_v6_daddr.s6_addr32[0]) != 4);
+
+		off = si->off;
+		off -= offsetof(struct bpf_sock_ops, remote_ip6[0]);
+		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(
+						struct bpf_sock_ops_kern, sk),
+				      si->dst_reg, si->src_reg,
+				      offsetof(struct bpf_sock_ops_kern, sk));
+		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->dst_reg,
+				      offsetof(struct sock_common,
+					       skc_v6_daddr.s6_addr32[0]) +
+				      off);
+		*insn++ = BPF_ENDIAN(BPF_FROM_BE, si->dst_reg, 32);
+#else
+		*insn++ = BPF_MOV32_IMM(si->dst_reg, 0);
+#endif
+		break;
+
+	case offsetof(struct bpf_sock_ops, local_ip6[0]) ...
+	     offsetof(struct bpf_sock_ops, local_ip6[3]):
+#if IS_ENABLED(CONFIG_IPV6)
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common,
+					  skc_v6_rcv_saddr.s6_addr32[0]) != 4);
+
+		off = si->off;
+		off -= offsetof(struct bpf_sock_ops, local_ip6[0]);
+		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(
+						struct bpf_sock_ops_kern, sk),
+				      si->dst_reg, si->src_reg,
+				      offsetof(struct bpf_sock_ops_kern, sk));
+		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->dst_reg,
+				      offsetof(struct sock_common,
+					       skc_v6_rcv_saddr.s6_addr32[0]) +
+				      off);
+		*insn++ = BPF_ENDIAN(BPF_FROM_BE, si->dst_reg, 32);
+#else
+		*insn++ = BPF_MOV32_IMM(si->dst_reg, 0);
+#endif
+		break;
+
+	case offsetof(struct bpf_sock_ops, remote_port):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common, skc_dport) != 2);
+
+		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(
+						struct bpf_sock_ops_kern, sk),
+				      si->dst_reg, si->src_reg,
+				      offsetof(struct bpf_sock_ops_kern, sk));
+		*insn++ = BPF_LDX_MEM(BPF_H, si->dst_reg, si->dst_reg,
+				      offsetof(struct sock_common, skc_dport));
+		*insn++ = BPF_ENDIAN(BPF_FROM_BE, si->dst_reg, 16);
+		break;
+
+	case offsetof(struct bpf_sock_ops, local_port):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common, skc_num) != 2);
+
+		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(
+						struct bpf_sock_ops_kern, sk),
+				      si->dst_reg, si->src_reg,
+				      offsetof(struct bpf_sock_ops_kern, sk));
+		*insn++ = BPF_LDX_MEM(BPF_H, si->dst_reg, si->dst_reg,
+				      offsetof(struct sock_common, skc_num));
+		break;
+	}
+	return insn - insn_buf;
+}
+
 const struct bpf_verifier_ops sk_filter_prog_ops = {
 	.get_func_proto		= sk_filter_func_proto,
 	.is_valid_access	= sk_filter_is_valid_access,
@@ -3413,6 +3577,12 @@ const struct bpf_verifier_ops cg_sock_prog_ops = {
 	.convert_ctx_access	= sock_filter_convert_ctx_access,
 };
 
+const struct bpf_verifier_ops sock_ops_prog_ops = {
+	.get_func_proto		= bpf_base_func_proto,
+	.is_valid_access	= sock_ops_is_valid_access,
+	.convert_ctx_access	= sock_ops_convert_ctx_access,
+};
+
 int sk_detach_filter(struct sock *sk)
 {
 	int ret = -ENOENT;
diff --git a/net/core/sock_bpfops.c b/net/core/sock_bpfops.c
new file mode 100644
index 0000000..06f4a64
--- /dev/null
+++ b/net/core/sock_bpfops.c
@@ -0,0 +1,65 @@
+/*
+ * BPF support for sockets
+ *
+ * Copyright (c) 2016 Lawrence Brakmo <brakmo@fb.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ */
+
+#include <net/sock.h>
+#include <linux/skbuff.h>
+#include <linux/bpf.h>
+#include <linux/filter.h>
+#include <linux/errno.h>
+#ifdef CONFIG_NET_NS
+#include <net/net_namespace.h>
+#include <linux/proc_ns.h>
+#endif
+
+/* Global BPF program for sockets */
+static struct bpf_prog *bpf_global_sock_ops_prog;
+
+int bpf_sock_ops_detach_global_prog(void)
+{
+	struct bpf_prog *old_prog;
+
+	old_prog = xchg(&bpf_global_sock_ops_prog, NULL);
+
+	if (old_prog)
+		bpf_prog_put(old_prog);
+
+	return 0;
+}
+
+int bpf_sock_ops_attach_global_prog(int fd)
+{
+	struct bpf_prog *prog, *old_prog;
+	int err = 0;
+
+	prog = bpf_prog_get_type(fd, BPF_PROG_TYPE_SOCK_OPS);
+	if (IS_ERR(prog))
+		return PTR_ERR(prog);
+
+	old_prog = xchg(&bpf_global_sock_ops_prog, prog);
+	if (old_prog)
+		bpf_prog_put(old_prog);
+	return err;
+}
+
+int bpf_sock_ops_call(struct bpf_sock_ops_kern *bpf_sock)
+{
+	struct bpf_prog *prog;
+	int ret;
+
+	rcu_read_lock();
+	prog =  READ_ONCE(bpf_global_sock_ops_prog);
+	if (prog)
+		ret = BPF_PROG_RUN(prog, bpf_sock);
+	else
+		ret = -1;
+	rcu_read_unlock();
+
+	return ret;
+}
diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index a91c57d..a4be7cf 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -64,6 +64,7 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 	bool is_perf_event = strncmp(event, "perf_event", 10) == 0;
 	bool is_cgroup_skb = strncmp(event, "cgroup/skb", 10) == 0;
 	bool is_cgroup_sk = strncmp(event, "cgroup/sock", 11) == 0;
+	bool is_sockops = strncmp(event, "sockops", 7) == 0;
 	size_t insns_cnt = size / sizeof(struct bpf_insn);
 	enum bpf_prog_type prog_type;
 	char buf[256];
@@ -89,6 +90,8 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 		prog_type = BPF_PROG_TYPE_CGROUP_SKB;
 	} else if (is_cgroup_sk) {
 		prog_type = BPF_PROG_TYPE_CGROUP_SOCK;
+	} else if (is_sockops) {
+		prog_type = BPF_PROG_TYPE_SOCK_OPS;
 	} else {
 		printf("Unknown event '%s'\n", event);
 		return -1;
@@ -106,8 +109,11 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 	if (is_xdp || is_perf_event || is_cgroup_skb || is_cgroup_sk)
 		return 0;
 
-	if (is_socket) {
-		event += 6;
+	if (is_socket || is_sockops) {
+		if (is_socket)
+			event += 6;
+		else
+			event += 7;
 		if (*event != '/')
 			return 0;
 		event++;
@@ -560,7 +566,8 @@ static int do_load_bpf_file(const char *path, fixup_map_cb fixup_map)
 		    memcmp(shname, "xdp", 3) == 0 ||
 		    memcmp(shname, "perf_event", 10) == 0 ||
 		    memcmp(shname, "socket", 6) == 0 ||
-		    memcmp(shname, "cgroup/", 7) == 0)
+		    memcmp(shname, "cgroup/", 7) == 0 ||
+		    memcmp(shname, "sockops", 7) == 0)
 			load_and_attach(shname, data->d_buf, data->d_size);
 	}
 
-- 
2.9.3
