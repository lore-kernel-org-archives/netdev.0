From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 1/6] bpf: introduce BPF_PROG_TEST_RUN command
Date: Thu, 30 Mar 2017 18:31:52 -0700
Message-ID: <20170331013157.3298003-2-ast@fb.com>
References: <20170331013157.3298003-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Wang Nan <wangnan0@huawei.com>,
        Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:52910 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S934836AbdCaBcD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 21:32:03 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.20/8.16.0.20) with SMTP id v2V1VrdE013743
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 18:32:02 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 29hcyw82gf-4
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 18:32:02 -0700
Received: from facebook.com (2401:db00:11:d082:face:0:5:0)      by
 mx-out.facebook.com (10.222.219.45) with ESMTP id
 d4d24e1e15b111e7bc5a24be05904660-eb7fb9a0 for <netdev@vger.kernel.org>;        Thu,
 30 Mar 2017 18:31:58 -0700
In-Reply-To: <20170331013157.3298003-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

development and testing of networking bpf programs is quite cumbersome.
Despite availability of user space bpf interpreters the kernel is
the ultimate authority and execution environment.
Current test frameworks for TC include creation of netns, veth,
qdiscs and use of various packet generators just to test functionality
of a bpf program. XDP testing is even more complicated, since
qemu needs to be started with gro/gso disabled and precise queue
configuration, transferring of xdp program from host into guest,
attaching to virtio/eth0 and generating traffic from the host
while capturing the results from the guest.

Moreover analyzing performance bottlenecks in XDP program is
impossible in virtio environment, since cost of running the program
is tiny comparing to the overhead of virtio packet processing,
so performance testing can only be done on physical nic
with another server generating traffic.

Furthermore ongoing changes to user space control plane of production
applications cannot be run on the test servers leaving bpf programs
stubbed out for testing.

Last but not least, the upstream llvm changes are validated by the bpf
backend testsuite which has no ability to test the code generated.

To improve this situation introduce BPF_PROG_TEST_RUN command
to test and performance benchmark bpf programs.

Joint work with Daniel Borkmann.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 include/linux/bpf.h      |   7 ++
 include/uapi/linux/bpf.h |  12 ++++
 kernel/bpf/syscall.c     |  27 +++++++-
 net/Makefile             |   2 +-
 net/bpf/Makefile         |   1 +
 net/bpf/test_run.c       | 172 +++++++++++++++++++++++++++++++++++++++++++++++
 net/core/filter.c        |   5 ++
 7 files changed, 223 insertions(+), 3 deletions(-)
 create mode 100644 net/bpf/Makefile
 create mode 100644 net/bpf/test_run.c

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 2ae39a3e9ead..bbb513da5075 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -169,6 +169,8 @@ struct bpf_verifier_ops {
 				  const struct bpf_insn *src,
 				  struct bpf_insn *dst,
 				  struct bpf_prog *prog);
+	int (*test_run)(struct bpf_prog *prog, const union bpf_attr *kattr,
+			union bpf_attr __user *uattr);
 };
 
 struct bpf_prog_type_list {
@@ -233,6 +235,11 @@ typedef unsigned long (*bpf_ctx_copy_t)(void *dst, const void *src,
 u64 bpf_event_output(struct bpf_map *map, u64 flags, void *meta, u64 meta_size,
 		     void *ctx, u64 ctx_size, bpf_ctx_copy_t ctx_copy);
 
+int bpf_prog_test_run_xdp(struct bpf_prog *prog, const union bpf_attr *kattr,
+			  union bpf_attr __user *uattr);
+int bpf_prog_test_run_skb(struct bpf_prog *prog, const union bpf_attr *kattr,
+			  union bpf_attr __user *uattr);
+
 #ifdef CONFIG_BPF_SYSCALL
 DECLARE_PER_CPU(int, bpf_prog_active);
 
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 28317a04c34d..a1d95386f562 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -81,6 +81,7 @@ enum bpf_cmd {
 	BPF_OBJ_GET,
 	BPF_PROG_ATTACH,
 	BPF_PROG_DETACH,
+	BPF_PROG_TEST_RUN,
 };
 
 enum bpf_map_type {
@@ -189,6 +190,17 @@ union bpf_attr {
 		__u32		attach_type;
 		__u32		attach_flags;
 	};
+
+	struct { /* anonymous struct used by BPF_PROG_TEST_RUN command */
+		__u32		prog_fd;
+		__u32		retval;
+		__u32		data_size_in;
+		__u32		data_size_out;
+		__aligned_u64	data_in;
+		__aligned_u64	data_out;
+		__u32		repeat;
+		__u32		duration;
+	} test;
 } __attribute__((aligned(8)));
 
 /* BPF helper function descriptions:
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index c35ebfe6d84d..ab0cf4c43690 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -973,6 +973,28 @@ static int bpf_prog_detach(const union bpf_attr *attr)
 }
 #endif /* CONFIG_CGROUP_BPF */
 
+#define BPF_PROG_TEST_RUN_LAST_FIELD test.duration
+
+static int bpf_prog_test_run(const union bpf_attr *attr,
+			     union bpf_attr __user *uattr)
+{
+	struct bpf_prog *prog;
+	int ret = -ENOTSUPP;
+
+	if (CHECK_ATTR(BPF_PROG_TEST_RUN))
+		return -EINVAL;
+
+	prog = bpf_prog_get(attr->test.prog_fd);
+	if (IS_ERR(prog))
+		return PTR_ERR(prog);
+
+	if (prog->aux->ops->test_run)
+		ret = prog->aux->ops->test_run(prog, attr, uattr);
+
+	bpf_prog_put(prog);
+	return ret;
+}
+
 SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, size)
 {
 	union bpf_attr attr = {};
@@ -1039,7 +1061,6 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
 	case BPF_OBJ_GET:
 		err = bpf_obj_get(&attr);
 		break;
-
 #ifdef CONFIG_CGROUP_BPF
 	case BPF_PROG_ATTACH:
 		err = bpf_prog_attach(&attr);
@@ -1048,7 +1069,9 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
 		err = bpf_prog_detach(&attr);
 		break;
 #endif
-
+	case BPF_PROG_TEST_RUN:
+		err = bpf_prog_test_run(&attr, uattr);
+		break;
 	default:
 		err = -EINVAL;
 		break;
diff --git a/net/Makefile b/net/Makefile
index 9b681550e3a3..9086ffbb5085 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -12,7 +12,7 @@ obj-$(CONFIG_NET)		+= $(tmp-y)
 
 # LLC has to be linked before the files in net/802/
 obj-$(CONFIG_LLC)		+= llc/
-obj-$(CONFIG_NET)		+= ethernet/ 802/ sched/ netlink/
+obj-$(CONFIG_NET)		+= ethernet/ 802/ sched/ netlink/ bpf/
 obj-$(CONFIG_NETFILTER)		+= netfilter/
 obj-$(CONFIG_INET)		+= ipv4/
 obj-$(CONFIG_XFRM)		+= xfrm/
diff --git a/net/bpf/Makefile b/net/bpf/Makefile
new file mode 100644
index 000000000000..27b2992a0692
--- /dev/null
+++ b/net/bpf/Makefile
@@ -0,0 +1 @@
+obj-y	:= test_run.o
diff --git a/net/bpf/test_run.c b/net/bpf/test_run.c
new file mode 100644
index 000000000000..8a6d0a37c30c
--- /dev/null
+++ b/net/bpf/test_run.c
@@ -0,0 +1,172 @@
+/* Copyright (c) 2017 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <linux/bpf.h>
+#include <linux/slab.h>
+#include <linux/vmalloc.h>
+#include <linux/etherdevice.h>
+#include <linux/filter.h>
+#include <linux/sched/signal.h>
+
+static __always_inline u32 bpf_test_run_one(struct bpf_prog *prog, void *ctx)
+{
+	u32 ret;
+
+	preempt_disable();
+	rcu_read_lock();
+	ret = BPF_PROG_RUN(prog, ctx);
+	rcu_read_unlock();
+	preempt_enable();
+
+	return ret;
+}
+
+static u32 bpf_test_run(struct bpf_prog *prog, void *ctx, u32 repeat, u32 *time)
+{
+	u64 time_start, time_spent = 0;
+	u32 ret = 0, i;
+
+	if (!repeat)
+		repeat = 1;
+	time_start = ktime_get_ns();
+	for (i = 0; i < repeat; i++) {
+		ret = bpf_test_run_one(prog, ctx);
+		if (need_resched()) {
+			if (signal_pending(current))
+				break;
+			time_spent += ktime_get_ns() - time_start;
+			cond_resched();
+			time_start = ktime_get_ns();
+		}
+	}
+	time_spent += ktime_get_ns() - time_start;
+	do_div(time_spent, repeat);
+	*time = time_spent > U32_MAX ? U32_MAX : (u32)time_spent;
+
+	return ret;
+}
+
+static int bpf_test_finish(union bpf_attr __user *uattr, const void *data,
+			   u32 size, u32 retval, u32 duration)
+{
+	void __user *data_out = u64_to_user_ptr(uattr->test.data_out);
+	int err = -EFAULT;
+
+	if (data_out && copy_to_user(data_out, data, size))
+		goto out;
+	if (copy_to_user(&uattr->test.data_size_out, &size, sizeof(size)))
+		goto out;
+	if (copy_to_user(&uattr->test.retval, &retval, sizeof(retval)))
+		goto out;
+	if (copy_to_user(&uattr->test.duration, &duration, sizeof(duration)))
+		goto out;
+	err = 0;
+out:
+	return err;
+}
+
+static void *bpf_test_init(const union bpf_attr *kattr, u32 size,
+			   u32 headroom, u32 tailroom)
+{
+	void __user *data_in = u64_to_user_ptr(kattr->test.data_in);
+	void *data;
+
+	if (size < ETH_HLEN || size > PAGE_SIZE - headroom - tailroom)
+		return ERR_PTR(-EINVAL);
+
+	data = kzalloc(size + headroom + tailroom, GFP_USER);
+	if (!data)
+		return ERR_PTR(-ENOMEM);
+
+	if (copy_from_user(data + headroom, data_in, size)) {
+		kfree(data);
+		return ERR_PTR(-EFAULT);
+	}
+	return data;
+}
+
+int bpf_prog_test_run_skb(struct bpf_prog *prog, const union bpf_attr *kattr,
+			  union bpf_attr __user *uattr)
+{
+	bool is_l2 = false, is_direct_pkt_access = false;
+	u32 size = kattr->test.data_size_in;
+	u32 repeat = kattr->test.repeat;
+	u32 retval, duration;
+	struct sk_buff *skb;
+	void *data;
+	int ret;
+
+	data = bpf_test_init(kattr, size, NET_SKB_PAD,
+			     SKB_DATA_ALIGN(sizeof(struct skb_shared_info)));
+	if (IS_ERR(data))
+		return PTR_ERR(data);
+
+	switch (prog->type) {
+	case BPF_PROG_TYPE_SCHED_CLS:
+	case BPF_PROG_TYPE_SCHED_ACT:
+		is_l2 = true;
+		/* fall through */
+	case BPF_PROG_TYPE_LWT_IN:
+	case BPF_PROG_TYPE_LWT_OUT:
+	case BPF_PROG_TYPE_LWT_XMIT:
+		is_direct_pkt_access = true;
+		break;
+	default:
+		break;
+	}
+
+	skb = build_skb(data, 0);
+	if (!skb) {
+		kfree(data);
+		return -ENOMEM;
+	}
+
+	skb_reserve(skb, NET_SKB_PAD);
+	__skb_put(skb, size);
+	skb->protocol = eth_type_trans(skb, current->nsproxy->net_ns->loopback_dev);
+	skb_reset_network_header(skb);
+
+	if (is_l2)
+		__skb_push(skb, ETH_HLEN);
+	if (is_direct_pkt_access)
+		bpf_compute_data_end(skb);
+	retval = bpf_test_run(prog, skb, repeat, &duration);
+	if (!is_l2)
+		__skb_push(skb, ETH_HLEN);
+	size = skb->len;
+	/* bpf program can never convert linear skb to non-linear */
+	if (WARN_ON_ONCE(skb_is_nonlinear(skb)))
+		size = skb_headlen(skb);
+	ret = bpf_test_finish(uattr, skb->data, size, retval, duration);
+	kfree_skb(skb);
+	return ret;
+}
+
+int bpf_prog_test_run_xdp(struct bpf_prog *prog, const union bpf_attr *kattr,
+			  union bpf_attr __user *uattr)
+{
+	u32 size = kattr->test.data_size_in;
+	u32 repeat = kattr->test.repeat;
+	struct xdp_buff xdp = {};
+	u32 retval, duration;
+	void *data;
+	int ret;
+
+	data = bpf_test_init(kattr, size, XDP_PACKET_HEADROOM, 0);
+	if (IS_ERR(data))
+		return PTR_ERR(data);
+
+	xdp.data_hard_start = data;
+	xdp.data = data + XDP_PACKET_HEADROOM;
+	xdp.data_end = xdp.data + size;
+
+	retval = bpf_test_run(prog, &xdp, repeat, &duration);
+	if (xdp.data != data + XDP_PACKET_HEADROOM)
+		size = xdp.data_end - xdp.data;
+	ret = bpf_test_finish(uattr, xdp.data, size, retval, duration);
+	kfree(data);
+	return ret;
+}
diff --git a/net/core/filter.c b/net/core/filter.c
index dfb9f61a2fd5..15e9a81ffebe 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -3309,24 +3309,28 @@ static const struct bpf_verifier_ops tc_cls_act_ops = {
 	.is_valid_access	= tc_cls_act_is_valid_access,
 	.convert_ctx_access	= tc_cls_act_convert_ctx_access,
 	.gen_prologue		= tc_cls_act_prologue,
+	.test_run		= bpf_prog_test_run_skb,
 };
 
 static const struct bpf_verifier_ops xdp_ops = {
 	.get_func_proto		= xdp_func_proto,
 	.is_valid_access	= xdp_is_valid_access,
 	.convert_ctx_access	= xdp_convert_ctx_access,
+	.test_run		= bpf_prog_test_run_xdp,
 };
 
 static const struct bpf_verifier_ops cg_skb_ops = {
 	.get_func_proto		= cg_skb_func_proto,
 	.is_valid_access	= sk_filter_is_valid_access,
 	.convert_ctx_access	= bpf_convert_ctx_access,
+	.test_run		= bpf_prog_test_run_skb,
 };
 
 static const struct bpf_verifier_ops lwt_inout_ops = {
 	.get_func_proto		= lwt_inout_func_proto,
 	.is_valid_access	= lwt_is_valid_access,
 	.convert_ctx_access	= bpf_convert_ctx_access,
+	.test_run		= bpf_prog_test_run_skb,
 };
 
 static const struct bpf_verifier_ops lwt_xmit_ops = {
@@ -3334,6 +3338,7 @@ static const struct bpf_verifier_ops lwt_xmit_ops = {
 	.is_valid_access	= lwt_is_valid_access,
 	.convert_ctx_access	= bpf_convert_ctx_access,
 	.gen_prologue		= tc_cls_act_prologue,
+	.test_run		= bpf_prog_test_run_skb,
 };
 
 static const struct bpf_verifier_ops cg_sock_ops = {
-- 
2.9.3
