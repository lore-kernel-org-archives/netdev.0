From: Lawrence Brakmo <brakmo@fb.com>
Subject: [RFC PATCH net-next 01/15] net: BPF support for socket ops
Date: Tue, 13 Jun 2017 10:59:50 -0700
Message-ID: <20170613180004.3008403-2-brakmo@fb.com>
References: <20170613180004.3008403-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>, Blake Matheny <bmatheny@fb.com>,
        "Alexei Starovoitov" <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:44258 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753573AbdFMSAK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 14:00:10 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5DHvBH4000951
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 11:00:10 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 2b29g4bt3a-5
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 11:00:10 -0700
Received: from facebook.com (2401:db00:11:d025:face:0:13:0)     by
 mx-out.facebook.com (10.103.99.97) with ESMTP  id
 22f48ae0506211e7b19b0002c9931860-29b3e8f0 for <netdev@vger.kernel.org>;        Tue,
 13 Jun 2017 11:00:08 -0700
In-Reply-To: <20170613180004.3008403-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Created a new BPF program type, BPF_PROG_TYPE_SOCKET_OPS, and a corresponding
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

I plan to add support for loading per cgroup socket ops BPF programs in
the near future. One question is whether I should add this functionality
into David Ahern's BPF_PROG_TYPE_CGROUP_SOCK or create a new cgroup bpf
type. Whereas the current cgroup_sock type expects to be called only once
during a connection's lifetime, the new socket_ops type could be called
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
struct bpf_socket_ops_kern {
        struct sock *sk;
	__u32  is_req_sock:1;
        __u32  op;
        union {
                __u32 reply;
                __u32 replylong[4];
        };
};

/* user version */
struct bpf_socket_ops {
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
 include/net/tcp.h         |  27 ++++++++
 include/uapi/linux/bpf.h  |  28 +++++++++
 kernel/bpf/syscall.c      |   3 +
 net/core/Makefile         |   3 +-
 net/core/filter.c         | 157 ++++++++++++++++++++++++++++++++++++++++++++++
 net/core/sock_bpfops.c    |  67 ++++++++++++++++++++
 samples/bpf/bpf_load.c    |  13 +++-
 10 files changed, 311 insertions(+), 4 deletions(-)
 create mode 100644 net/core/sock_bpfops.c

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index fcc80ca..b5058e4 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -360,4 +360,10 @@ extern const struct bpf_func_proto bpf_get_stackid_proto;
 void bpf_user_rnd_init_once(void);
 u64 bpf_user_rnd_u32(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
 
+/* socket_ops related */
+struct sock;
+struct bpf_socket_ops_kern;
+
+int bpf_socket_ops_set_prog(int fd);
+int bpf_socket_ops_call(struct bpf_socket_ops_kern *bpf_socket);
 #endif /* _LINUX_BPF_H */
diff --git a/include/linux/bpf_types.h b/include/linux/bpf_types.h
index 03bf223..ca69d10 100644
--- a/include/linux/bpf_types.h
+++ b/include/linux/bpf_types.h
@@ -10,6 +10,7 @@ BPF_PROG_TYPE(BPF_PROG_TYPE_CGROUP_SOCK, cg_sock_prog_ops)
 BPF_PROG_TYPE(BPF_PROG_TYPE_LWT_IN, lwt_inout_prog_ops)
 BPF_PROG_TYPE(BPF_PROG_TYPE_LWT_OUT, lwt_inout_prog_ops)
 BPF_PROG_TYPE(BPF_PROG_TYPE_LWT_XMIT, lwt_xmit_prog_ops)
+BPF_PROG_TYPE(BPF_PROG_TYPE_SOCKET_OPS, socket_ops_prog_ops)
 #endif
 #ifdef CONFIG_BPF_EVENTS
 BPF_PROG_TYPE(BPF_PROG_TYPE_KPROBE, kprobe_prog_ops)
diff --git a/include/linux/filter.h b/include/linux/filter.h
index a20ba40..8f69b8b 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -899,4 +899,14 @@ static inline int bpf_tell_extensions(void)
 	return SKF_AD_MAX;
 }
 
+struct bpf_socket_ops_kern {
+	struct	sock *sk;
+	__u32	is_req_sock:1;
+	__u32	op;
+	union {
+		__u32 reply;
+		__u32 replylong[4];
+	};
+};
+
 #endif /* __LINUX_FILTER_H__ */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 82462db..bc1c92c 100644
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
@@ -1992,4 +1995,28 @@ static inline void tcp_listendrop(const struct sock *sk)
 
 enum hrtimer_restart tcp_pace_kick(struct hrtimer *timer);
 
+/* Call BPF_SOCKET_OPS program that returns an int. If the return value
+ * is < 0, then the BPF op failed (for example if the loaded BPF
+ * program does not support the chosen operation or there is no BPF
+ * program loaded).
+ */
+#ifdef CONFIG_BPF
+static inline int tcp_call_bpf(struct sock *sk, bool is_req_sock, int op)
+{
+	struct bpf_socket_ops_kern socket_ops;
+
+	memset(&socket_ops, 0, sizeof(socket_ops));
+	socket_ops.sk = sk;
+	socket_ops.is_req_sock = is_req_sock ? 1 : 0;
+	socket_ops.op = op;
+
+	return bpf_socket_ops_call(&socket_ops);
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
index e78aece..06e7ee1 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -82,6 +82,7 @@ enum bpf_cmd {
 	BPF_PROG_ATTACH,
 	BPF_PROG_DETACH,
 	BPF_PROG_TEST_RUN,
+	BPF_PROG_LOAD_SOCKET_OPS,
 };
 
 enum bpf_map_type {
@@ -115,6 +116,7 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_LWT_IN,
 	BPF_PROG_TYPE_LWT_OUT,
 	BPF_PROG_TYPE_LWT_XMIT,
+	BPF_PROG_TYPE_SOCKET_OPS,
 };
 
 enum bpf_attach_type {
@@ -673,4 +675,30 @@ struct xdp_md {
 	__u32 data_end;
 };
 
+/* User bpf_socket_ops struct to access socket values and specify request ops
+ * and their replies.
+ * New fields can only be added at the end of this structure
+ */
+struct bpf_socket_ops {
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
+/* List of known BPF socket_ops operators.
+ * New entries can only be added at the end
+ */
+enum {
+	BPF_SOCKET_OPS_VOID,
+};
+
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 59da103..5ef8c01 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -1076,6 +1076,9 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
 	case BPF_PROG_TEST_RUN:
 		err = bpf_prog_test_run(&attr, uattr);
 		break;
+	case BPF_PROG_LOAD_SOCKET_OPS:
+		err = bpf_socket_ops_set_prog(attr.bpf_fd);
+		break;
 	default:
 		err = -EINVAL;
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
index 946f758..7b61690 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -3053,6 +3053,37 @@ void bpf_warn_invalid_xdp_action(u32 act)
 }
 EXPORT_SYMBOL_GPL(bpf_warn_invalid_xdp_action);
 
+static bool __is_valid_socket_ops_access(int off, int size,
+					 enum bpf_access_type type)
+{
+	if (off < 0 || off >= sizeof(struct bpf_socket_ops))
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
+static bool socket_ops_is_valid_access(int off, int size,
+				       enum bpf_access_type type,
+				       enum bpf_reg_type *reg_type)
+{
+	if (type == BPF_WRITE) {
+		switch (off) {
+		case offsetof(struct bpf_socket_ops, op) ...
+		     offsetof(struct bpf_socket_ops, replylong[3]):
+			break;
+		default:
+			return false;
+		}
+	}
+
+	return __is_valid_socket_ops_access(off, size, type);
+}
+
 static u32 bpf_convert_ctx_access(enum bpf_access_type type,
 				  const struct bpf_insn *si,
 				  struct bpf_insn *insn_buf,
@@ -3322,6 +3353,126 @@ static u32 xdp_convert_ctx_access(enum bpf_access_type type,
 	return insn - insn_buf;
 }
 
+static u32 socket_ops_convert_ctx_access(enum bpf_access_type type,
+					 const struct bpf_insn *si,
+					 struct bpf_insn *insn_buf,
+					 struct bpf_prog *prog)
+{
+	struct bpf_insn *insn = insn_buf;
+	int off;
+
+	switch (si->off) {
+	case offsetof(struct bpf_socket_ops, op) ...
+	     offsetof(struct bpf_socket_ops, replylong[3]):
+		off = si->off;
+		off -= offsetof(struct bpf_socket_ops, op);
+		off += offsetof(struct bpf_socket_ops_kern, op);
+		if (type == BPF_WRITE)
+			*insn++ = BPF_STX_MEM(BPF_W, si->dst_reg, si->src_reg,
+					      off);
+		else
+			*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->src_reg,
+					      off);
+		break;
+
+	case offsetof(struct bpf_socket_ops, family):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common, skc_family) != 2);
+
+		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(
+					      struct bpf_socket_ops_kern, sk),
+				      si->dst_reg, si->src_reg,
+				      offsetof(struct bpf_socket_ops_kern, sk));
+		*insn++ = BPF_LDX_MEM(BPF_H, si->dst_reg, si->dst_reg,
+				      offsetof(struct sock_common, skc_family));
+		break;
+
+	case offsetof(struct bpf_socket_ops, remote_ip4):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common, skc_daddr) != 4);
+
+		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(
+						struct bpf_socket_ops_kern, sk),
+				      si->dst_reg, si->src_reg,
+				      offsetof(struct bpf_socket_ops_kern, sk));
+		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->dst_reg,
+				      offsetof(struct sock_common, skc_daddr));
+		*insn++ = BPF_ENDIAN(BPF_FROM_BE, si->dst_reg, 32);
+		break;
+
+	case offsetof(struct bpf_socket_ops, local_ip4):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common, skc_rcv_saddr) != 4);
+
+		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(
+					      struct bpf_socket_ops_kern, sk),
+				      si->dst_reg, si->src_reg,
+				      offsetof(struct bpf_socket_ops_kern, sk));
+		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->dst_reg,
+				      offsetof(struct sock_common,
+					       skc_rcv_saddr));
+		*insn++ = BPF_ENDIAN(BPF_FROM_BE, si->dst_reg, 32);
+		break;
+
+	case offsetof(struct bpf_socket_ops, remote_ip6[0]) ...
+		offsetof(struct bpf_socket_ops, remote_ip6[3]):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common,
+					  skc_v6_daddr.s6_addr32[0]) != 4);
+
+		off = si->off;
+		off -= offsetof(struct bpf_socket_ops, remote_ip6[0]);
+		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(
+						struct bpf_socket_ops_kern, sk),
+				      si->dst_reg, si->src_reg,
+				      offsetof(struct bpf_socket_ops_kern, sk));
+		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->dst_reg,
+				      offsetof(struct sock_common,
+					       skc_v6_daddr.s6_addr32[0]) +
+				      off);
+		*insn++ = BPF_ENDIAN(BPF_FROM_BE, si->dst_reg, 32);
+		break;
+
+	case offsetof(struct bpf_socket_ops, local_ip6[0]) ...
+		offsetof(struct bpf_socket_ops, local_ip6[3]):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common,
+					  skc_v6_rcv_saddr.s6_addr32[0]) != 4);
+
+		off = si->off;
+		off -= offsetof(struct bpf_socket_ops, local_ip6[0]);
+		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(
+						struct bpf_socket_ops_kern, sk),
+				      si->dst_reg, si->src_reg,
+				      offsetof(struct bpf_socket_ops_kern, sk));
+		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->dst_reg,
+				      offsetof(struct sock_common,
+					       skc_v6_rcv_saddr.s6_addr32[0]) +
+				      off);
+		*insn++ = BPF_ENDIAN(BPF_FROM_BE, si->dst_reg, 32);
+		break;
+
+	case offsetof(struct bpf_socket_ops, remote_port):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common, skc_dport) != 2);
+
+		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(
+						struct bpf_socket_ops_kern, sk),
+				      si->dst_reg, si->src_reg,
+				      offsetof(struct bpf_socket_ops_kern, sk));
+		*insn++ = BPF_LDX_MEM(BPF_H, si->dst_reg, si->dst_reg,
+				      offsetof(struct sock_common, skc_dport));
+		*insn++ = BPF_ENDIAN(BPF_FROM_BE, si->dst_reg, 16);
+		break;
+
+	case offsetof(struct bpf_socket_ops, local_port):
+		BUILD_BUG_ON(FIELD_SIZEOF(struct sock_common, skc_num) != 2);
+
+		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(
+						struct bpf_socket_ops_kern, sk),
+				      si->dst_reg, si->src_reg,
+				      offsetof(struct bpf_socket_ops_kern, sk));
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
@@ -3371,6 +3522,12 @@ const struct bpf_verifier_ops cg_sock_prog_ops = {
 	.convert_ctx_access	= sock_filter_convert_ctx_access,
 };
 
+const struct bpf_verifier_ops socket_ops_prog_ops = {
+	.get_func_proto		= bpf_base_func_proto,
+	.is_valid_access	= socket_ops_is_valid_access,
+	.convert_ctx_access	= socket_ops_convert_ctx_access,
+};
+
 int sk_detach_filter(struct sock *sk)
 {
 	int ret = -ENOENT;
diff --git a/net/core/sock_bpfops.c b/net/core/sock_bpfops.c
new file mode 100644
index 0000000..8f8daa5
--- /dev/null
+++ b/net/core/sock_bpfops.c
@@ -0,0 +1,67 @@
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
+static struct bpf_prog *bpf_socket_ops_prog;
+static DEFINE_RWLOCK(bpf_socket_ops_lock);
+
+int bpf_socket_ops_set_prog(int fd)
+{
+	int err = 0;
+
+	write_lock(&bpf_socket_ops_lock);
+	if (bpf_socket_ops_prog) {
+		bpf_prog_put(bpf_socket_ops_prog);
+		bpf_socket_ops_prog = NULL;
+	}
+
+	/* fd of zero is used as a signal to remove the current
+	 * bpf_socket_ops_prog.
+	 */
+	if (fd == 0) {
+		write_unlock(&bpf_socket_ops_lock);
+		return 1;
+	}
+
+	bpf_socket_ops_prog = bpf_prog_get_type(fd, BPF_PROG_TYPE_SOCKET_OPS);
+	if (IS_ERR(bpf_socket_ops_prog)) {
+		bpf_prog_put(bpf_socket_ops_prog);
+		bpf_socket_ops_prog = NULL;
+		err = 1;
+	}
+	write_unlock(&bpf_socket_ops_lock);
+	return err;
+}
+
+int bpf_socket_ops_call(struct bpf_socket_ops_kern *bpf_socket)
+{
+	int ret;
+
+	read_lock(&bpf_socket_ops_lock);
+	if (bpf_socket_ops_prog) {
+		rcu_read_lock();
+		ret = (int)BPF_PROG_RUN(bpf_socket_ops_prog, bpf_socket);
+		rcu_read_unlock();
+	} else {
+		ret = -1;
+	}
+	read_unlock(&bpf_socket_ops_lock);
+	return ret;
+}
diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index a91c57d..c18d713 100644
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
+		prog_type = BPF_PROG_TYPE_SOCKET_OPS;
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
