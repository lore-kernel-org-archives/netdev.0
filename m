From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v4 net] bpf: add bpf_sk_netns_id() helper
Date: Mon, 6 Feb 2017 18:02:48 -0800
Message-ID: <1486432968-3255218-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Tejun Heo <tj@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:41027 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751164AbdBGCCv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 21:02:51 -0500
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
        by m0089730.ppops.net (8.16.0.20/8.16.0.20) with SMTP id v171wlr6011682
        for <netdev@vger.kernel.org>; Mon, 6 Feb 2017 18:02:50 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0089730.ppops.net with ESMTP id 28f20k8f0v-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 18:02:50 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.102.107.97) with ESMTP id
 866ee166ecd911e68b690002c99331b0-d8df2a50 for <netdev@vger.kernel.org>;        Mon,
 06 Feb 2017 18:02:48 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in cases where bpf programs are looking at sockets and packets
that belong to different netns, it could be useful to get an id
that uniquely identify a netns within the whole system.

Therefore introduce 'u64 bpf_sk_netns_id(sk);' helper. It returns
unique value that identifies netns of given socket or dev_net(skb->dev)
The upper 32-bits of the return value contain device id where namespace
filesystem resides and lower 32-bits contain inode number within that filesystem.
It's the same as
 struct stat st;
 stat("/proc/pid/ns/net", &st);
 return (st->st_dev << 32)  | st->st_ino;

For example to disallow raw sockets in all non-init netns
the bpf_type_cgroup_sock program can do:
if (sk->type == SOCK_RAW && bpf_sk_netns_id(sk) != 0x3f0000075)
  return 0;
where 0x3f0000075 comes from combination of st_dev and st_ino
of /proc/pid/ns/net

Note that all bpf programs types are global. The same socket filter
program can be attached to sockets in different netns,
just like cls_bpf can see ingress/egress packets of multiple
net_devices in different netns. The cgroup_bpf programs are
the most exposed to sockets and devices across netns,
but the need to identify netns applies to all.
For example, if bpf_type_cgroup_skb didn't exist the system wide
monitoring daemon could have used ld_preload mechanism and
attached the same program to see traffic from applications
across netns. Therefore make bpf_sk_netns_id() helper available
to all network related bpf program types.
For socket, cls_bpf and cgroup_skb programs this helper
can be considered a new feature, whereas for cgroup_sock
programs that modify sk->bound_dev_if (like 'ip vrf' does)
it's a bug fix, since 'ip vrf' needs to be netns aware.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Reviewed-by: David Ahern <dsa@cumulusnetworks.com>
Tested-by: David Ahern <dsa@cumulusnetworks.com>
---
Eric, I'v added proc_get_ns_devid_inum() to nsfs.c
right next to __ns_get_path(), so when it is time in the future
to make nsfs more namespace aware, it will be easy to adjust
both new_inode_pseudo(mnt->mnt_sb) line and proc_get_ns_devid_inum()
I thought about using ns->stashed, but it's obviously transient
inode and not usable. If later we decide to store dev_t into ns_common
it will be fine as well. We'll just change proc_get_ns_devid_inum()
without affecting user space.

Note that eBPF is 64-bit and sizeof(long)==8 in bpf program,
so no need to mess with old_encode_dev and old_valid_dev checks.
new_encode_dev() is enough.

v2->v3: build bot complained. s/static/static inline/. no other changes.
v3->v4: fixed fallthrough case. Thanks Daniel.
---
 fs/nsfs.c                     |  7 +++++++
 include/linux/proc_ns.h       |  3 ++-
 include/uapi/linux/bpf.h      | 14 +++++++++++++-
 net/core/filter.c             | 45 ++++++++++++++++++++++++++++++++++++++++++-
 samples/bpf/bpf_helpers.h     |  2 ++
 samples/bpf/sock_flags_kern.c |  2 ++
 samples/bpf/sockex1_kern.c    |  2 ++
 7 files changed, 72 insertions(+), 3 deletions(-)

diff --git a/fs/nsfs.c b/fs/nsfs.c
index 8c9fb29c6673..1a604bccef86 100644
--- a/fs/nsfs.c
+++ b/fs/nsfs.c
@@ -49,6 +49,13 @@ static void nsfs_evict(struct inode *inode)
 	ns->ops->put(ns);
 }
 
+u64 proc_get_ns_devid_inum(struct ns_common *ns)
+{
+	u64 dev = new_encode_dev(nsfs_mnt->mnt_sb->s_dev);
+
+	return (dev << 32) | ns->inum;
+}
+
 static void *__ns_get_path(struct path *path, struct ns_common *ns)
 {
 	struct vfsmount *mnt = nsfs_mnt;
diff --git a/include/linux/proc_ns.h b/include/linux/proc_ns.h
index 12cb8bd81d2d..531c16105198 100644
--- a/include/linux/proc_ns.h
+++ b/include/linux/proc_ns.h
@@ -48,7 +48,7 @@ extern int pid_ns_prepare_proc(struct pid_namespace *ns);
 extern void pid_ns_release_proc(struct pid_namespace *ns);
 extern int proc_alloc_inum(unsigned int *pino);
 extern void proc_free_inum(unsigned int inum);
-
+extern u64 proc_get_ns_devid_inum(struct ns_common *ns);
 #else /* CONFIG_PROC_FS */
 
 static inline int pid_ns_prepare_proc(struct pid_namespace *ns) { return 0; }
@@ -61,6 +61,7 @@ static inline int proc_alloc_inum(unsigned int *inum)
 }
 static inline void proc_free_inum(unsigned int inum) {}
 
+static inline u64 proc_get_ns_devid_inum(struct ns_common *ns) { return 0; }
 #endif /* CONFIG_PROC_FS */
 
 static inline int ns_alloc_inum(struct ns_common *ns)
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 0eb0e87dbe9f..e5b8cf16cbaf 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -430,6 +430,17 @@ union bpf_attr {
  *     @xdp_md: pointer to xdp_md
  *     @delta: An positive/negative integer to be added to xdp_md.data
  *     Return: 0 on success or negative on error
+ *
+ * u64 bpf_sk_netns_id(sk)
+ *     Returns unique value that identifies netns of given socket or skb.
+ *     The upper 32-bits of the return value contain device id where namespace
+ *     filesystem resides and lower 32-bits contain inode number within
+ *     that filesystem. It's the same value as:
+ *      struct stat st;
+ *      stat("/proc/pid/ns/net", &st);
+ *      return (st->st_dev << 32)  | st->st_ino;
+ *     @sk: pointer to struct sock or struct __sk_buff
+ *     Return: filesystem's device id | netns inode
  */
 #define __BPF_FUNC_MAPPER(FN)		\
 	FN(unspec),			\
@@ -476,7 +487,8 @@ union bpf_attr {
 	FN(set_hash_invalid),		\
 	FN(get_numa_node_id),		\
 	FN(skb_change_head),		\
-	FN(xdp_adjust_head),
+	FN(xdp_adjust_head),		\
+	FN(sk_netns_id),
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
diff --git a/net/core/filter.c b/net/core/filter.c
index 1969b3f118c1..be434c8aaf18 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -52,6 +52,7 @@
 #include <net/dst_metadata.h>
 #include <net/dst.h>
 #include <net/sock_reuseport.h>
+#include <linux/proc_ns.h>
 
 /**
  *	sk_filter_trim_cap - run a packet through a socket filter
@@ -2597,6 +2598,34 @@ static const struct bpf_func_proto bpf_xdp_event_output_proto = {
 	.arg5_type	= ARG_CONST_STACK_SIZE,
 };
 
+BPF_CALL_1(bpf_sk_netns_id, struct sock *, sk)
+{
+	return proc_get_ns_devid_inum(&sock_net(sk)->ns);
+}
+
+static const struct bpf_func_proto bpf_sk_netns_id_proto = {
+	.func		= bpf_sk_netns_id,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+};
+
+BPF_CALL_1(bpf_skb_netns_id, struct sk_buff *, skb)
+{
+	struct net_device *dev = skb->dev;
+
+	if (!dev)
+		return 0;
+	return proc_get_ns_devid_inum(&dev_net(dev)->ns);
+}
+
+static const struct bpf_func_proto bpf_skb_netns_id_proto = {
+	.func		= bpf_skb_netns_id,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+};
+
 static const struct bpf_func_proto *
 sk_filter_func_proto(enum bpf_func_id func_id)
 {
@@ -2617,9 +2646,12 @@ sk_filter_func_proto(enum bpf_func_id func_id)
 		return &bpf_tail_call_proto;
 	case BPF_FUNC_ktime_get_ns:
 		return &bpf_ktime_get_ns_proto;
+	case BPF_FUNC_sk_netns_id:
+		return &bpf_skb_netns_id_proto;
 	case BPF_FUNC_trace_printk:
 		if (capable(CAP_SYS_ADMIN))
 			return bpf_get_trace_printk_proto();
+		/* fallthrough */
 	default:
 		return NULL;
 	}
@@ -2700,6 +2732,17 @@ xdp_func_proto(enum bpf_func_id func_id)
 }
 
 static const struct bpf_func_proto *
+cg_sock_func_proto(enum bpf_func_id func_id)
+{
+	switch (func_id) {
+	case BPF_FUNC_sk_netns_id:
+		return &bpf_sk_netns_id_proto;
+	default:
+		return sk_filter_func_proto(func_id);
+	}
+}
+
+static const struct bpf_func_proto *
 cg_skb_func_proto(enum bpf_func_id func_id)
 {
 	switch (func_id) {
@@ -3255,7 +3298,7 @@ static const struct bpf_verifier_ops lwt_xmit_ops = {
 };
 
 static const struct bpf_verifier_ops cg_sock_ops = {
-	.get_func_proto		= sk_filter_func_proto,
+	.get_func_proto		= cg_sock_func_proto,
 	.is_valid_access	= sock_filter_is_valid_access,
 	.convert_ctx_access	= sock_filter_convert_ctx_access,
 };
diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index faaffe2e139a..971649483d62 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -94,6 +94,8 @@ static int (*bpf_skb_under_cgroup)(void *ctx, void *map, int index) =
 	(void *) BPF_FUNC_skb_under_cgroup;
 static int (*bpf_skb_change_head)(void *, int len, int flags) =
 	(void *) BPF_FUNC_skb_change_head;
+static unsigned long long (*bpf_sk_netns_id)(void *) =
+	(void *) BPF_FUNC_sk_netns_id;
 
 #if defined(__x86_64__)
 
diff --git a/samples/bpf/sock_flags_kern.c b/samples/bpf/sock_flags_kern.c
index 533dd11a6baa..f2507d7d847b 100644
--- a/samples/bpf/sock_flags_kern.c
+++ b/samples/bpf/sock_flags_kern.c
@@ -9,8 +9,10 @@ SEC("cgroup/sock1")
 int bpf_prog1(struct bpf_sock *sk)
 {
 	char fmt[] = "socket: family %d type %d protocol %d\n";
+	char fmt2[] = "socket: netns dev+inode %llx\n";
 
 	bpf_trace_printk(fmt, sizeof(fmt), sk->family, sk->type, sk->protocol);
+	bpf_trace_printk(fmt2, sizeof(fmt2), bpf_sk_netns_id(sk));
 
 	/* block PF_INET6, SOCK_RAW, IPPROTO_ICMPV6 sockets
 	 * ie., make ping6 fail
diff --git a/samples/bpf/sockex1_kern.c b/samples/bpf/sockex1_kern.c
index ed18e9a4909c..73b62cc0d617 100644
--- a/samples/bpf/sockex1_kern.c
+++ b/samples/bpf/sockex1_kern.c
@@ -16,6 +16,7 @@ int bpf_prog1(struct __sk_buff *skb)
 {
 	int index = load_byte(skb, ETH_HLEN + offsetof(struct iphdr, protocol));
 	long *value;
+	char fmt[] = "netns dev+inode %llx\n";
 
 	if (skb->pkt_type != PACKET_OUTGOING)
 		return 0;
@@ -24,6 +25,7 @@ int bpf_prog1(struct __sk_buff *skb)
 	if (value)
 		__sync_fetch_and_add(value, skb->len);
 
+	bpf_trace_printk(fmt, sizeof(fmt), bpf_sk_netns_id(skb));
 	return 0;
 }
 char _license[] SEC("license") = "GPL";
-- 
2.8.0
