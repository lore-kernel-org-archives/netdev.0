From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net v5] bpf: add helper to compare network namespaces
Date: Wed, 15 Feb 2017 17:29:24 -0800
Message-ID: <1487208564-4666-1-git-send-email-dsa@cumulusnetworks.com>
Cc: ast@kernel.org, daniel@iogearbox.net, tj@kernel.org,
        luto@amacapital.net, ebiederm@xmission.com,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:34062 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751371AbdBPB3c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 20:29:32 -0500
Received: by mail-pg0-f50.google.com with SMTP id z67so1251043pgb.1
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 17:29:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In cases where bpf programs are looking at sockets and packets
that belong to different netns, it could be useful to compare the
network namespace of the socket or packet

Introduce bpf_sk_netns_cmp and bpf_skb_netns_cmp helpers to compare
network namespace of the socket or skb to the namespace parameters
in a prorgam.

For example to disallow raw sockets in all non-init netns
the bpf_type_cgroup_sock program can do:
if (sk->type == SOCK_RAW && !bpf_sk_netns_cmp(sk, 0x3, 0xf0000075))
  return 0;

where 0x3 and 0xf0000075 are the st_dev and st_ino of /proc/pid/ns/net.

Note that all bpf programs types are global. The same socket filter
program can be attached to sockets in different netns,
just like cls_bpf can see ingress/egress packets of multiple
net_devices in different netns. The cgroup_bpf programs are
the most exposed to sockets and devices across netns,
but the need to identify netns applies to all.
For example, if bpf_type_cgroup_skb didn't exist the system wide
monitoring daemon could have used ld_preload mechanism and
attached the same program to see traffic from applications
across netns. Therefore make bpf_sk_netns_cmp() helper available
to all network related bpf program types.

For socket, cls_bpf and cgroup_skb programs this helper
can be considered a new feature, whereas for cgroup_sock
programs that modify sk->bound_dev_if (like 'ip vrf' does)
it's a bug fix, since 'ip vrf' needs to be netns aware.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v2->v3: build bot complained. s/static/static inline/. no other changes.
v3->v4: fixed fallthrough case. Thanks Daniel.
v4->v5: dsa converted netns_id as a u64 to netns_cmp with individual dev
        and inode number. Updated samples test for sock bind.

 fs/nsfs.c                      |   7 ++
 include/linux/proc_ns.h        |   2 +
 include/net/net_namespace.h    |  11 +++
 include/uapi/linux/bpf.h       |  11 ++-
 net/core/filter.c              |  50 ++++++++++++-
 samples/bpf/bpf_helpers.h      |   2 +
 samples/bpf/test_cgrp2_sock.c  | 156 +++++++++++++++++++++++++++++++++++++----
 samples/bpf/test_cgrp2_sock.sh |  18 ++---
 8 files changed, 233 insertions(+), 24 deletions(-)

diff --git a/fs/nsfs.c b/fs/nsfs.c
index 8c9fb29c6673..c335f513d467 100644
--- a/fs/nsfs.c
+++ b/fs/nsfs.c
@@ -49,6 +49,13 @@ static void nsfs_evict(struct inode *inode)
 	ns->ops->put(ns);
 }
 
+int ns_cmp(struct ns_common *ns, u64 dev, u64 ino)
+{
+	u64 ns_dev = new_encode_dev(nsfs_mnt->mnt_sb->s_dev);
+
+	return dev == ns_dev && ino == ns->inum;
+}
+
 static void *__ns_get_path(struct path *path, struct ns_common *ns)
 {
 	struct vfsmount *mnt = nsfs_mnt;
diff --git a/include/linux/proc_ns.h b/include/linux/proc_ns.h
index 12cb8bd81d2d..5d962eda8686 100644
--- a/include/linux/proc_ns.h
+++ b/include/linux/proc_ns.h
@@ -76,6 +76,8 @@ extern struct file *proc_ns_fget(int fd);
 extern void *ns_get_path(struct path *path, struct task_struct *task,
 			const struct proc_ns_operations *ns_ops);
 
+extern int ns_cmp(struct ns_common *ns, u64 dev, u64 ino);
+
 extern int ns_get_name(char *buf, size_t size, struct task_struct *task,
 			const struct proc_ns_operations *ns_ops);
 extern void nsfs_init(void);
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index af8fe8a909dc..70d1d6d473ae 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -28,6 +28,7 @@
 #include <net/netns/xfrm.h>
 #include <net/netns/mpls.h>
 #include <linux/ns_common.h>
+#include <linux/proc_ns.h>
 #include <linux/idr.h>
 #include <linux/skbuff.h>
 
@@ -215,6 +216,11 @@ int net_eq(const struct net *net1, const struct net *net2)
 
 void net_drop_ns(void *);
 
+static inline int netns_cmp(struct net *net, u64 dev, u64 ino)
+{
+	return ns_cmp(&net->ns, dev, ino);
+}
+
 #else
 
 static inline struct net *get_net(struct net *net)
@@ -237,6 +243,11 @@ int net_eq(const struct net *net1, const struct net *net2)
 	return 1;
 }
 
+static inline int netns_cmp(struct net *net, u64 dev, u64 ino)
+{
+	return 1;
+}
+
 #define net_drop_ns NULL
 #endif
 
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index d2b0ac799d03..0a59dd182916 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -437,6 +437,14 @@ union bpf_attr {
  *     @xdp_md: pointer to xdp_md
  *     @delta: An positive/negative integer to be added to xdp_md.data
  *     Return: 0 on success or negative on error
+ *
+ * int bpf_sk_netns_cmp(ctx, dev, ino)
+ *     Compare the network namespace for sk or skb against the given
+ *     device and inode number.
+ *     @ctx: pointer to struct sock or struct __sk_buff
+ *     @dev: unsigned long device id for namespace
+ *     @ino: unsigned long inode for namespace
+ *     Return: 1 on match, 0 if no match and -1 on error
  */
 #define __BPF_FUNC_MAPPER(FN)		\
 	FN(unspec),			\
@@ -483,7 +491,8 @@ union bpf_attr {
 	FN(set_hash_invalid),		\
 	FN(get_numa_node_id),		\
 	FN(skb_change_head),		\
-	FN(xdp_adjust_head),
+	FN(xdp_adjust_head),		\
+	FN(sk_netns_cmp),
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
diff --git a/net/core/filter.c b/net/core/filter.c
index 1969b3f118c1..69918f8c79ee 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -52,6 +52,7 @@
 #include <net/dst_metadata.h>
 #include <net/dst.h>
 #include <net/sock_reuseport.h>
+#include <linux/proc_ns.h>
 
 /**
  *	sk_filter_trim_cap - run a packet through a socket filter
@@ -2597,6 +2598,39 @@ static const struct bpf_func_proto bpf_xdp_event_output_proto = {
 	.arg5_type	= ARG_CONST_STACK_SIZE,
 };
 
+BPF_CALL_3(bpf_sk_netns_cmp, struct sock *, sk,  u64, ns_dev, u64, ns_ino)
+{
+	return netns_cmp(sock_net(sk), ns_dev, ns_ino);
+}
+
+static const struct bpf_func_proto bpf_sk_netns_cmp_proto = {
+	.func		= bpf_sk_netns_cmp,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_ANYTHING,
+	.arg3_type	= ARG_ANYTHING,
+};
+
+BPF_CALL_3(bpf_skb_netns_cmp, struct sk_buff *, skb,  u64, ns_dev, u64, ns_ino)
+{
+	struct net_device *dev = skb->dev;
+
+	if (!dev)
+		return -EINVAL;
+
+	return netns_cmp(dev_net(dev), ns_dev, ns_ino);
+}
+
+static const struct bpf_func_proto bpf_skb_netns_cmp_proto = {
+	.func		= bpf_skb_netns_cmp,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_ANYTHING,
+	.arg3_type	= ARG_ANYTHING,
+};
+
 static const struct bpf_func_proto *
 sk_filter_func_proto(enum bpf_func_id func_id)
 {
@@ -2617,9 +2651,12 @@ sk_filter_func_proto(enum bpf_func_id func_id)
 		return &bpf_tail_call_proto;
 	case BPF_FUNC_ktime_get_ns:
 		return &bpf_ktime_get_ns_proto;
+	case BPF_FUNC_sk_netns_cmp:
+		return &bpf_skb_netns_cmp_proto;
 	case BPF_FUNC_trace_printk:
 		if (capable(CAP_SYS_ADMIN))
 			return bpf_get_trace_printk_proto();
+		/* fallthrough */
 	default:
 		return NULL;
 	}
@@ -2700,6 +2737,17 @@ xdp_func_proto(enum bpf_func_id func_id)
 }
 
 static const struct bpf_func_proto *
+cg_sock_func_proto(enum bpf_func_id func_id)
+{
+	switch (func_id) {
+	case BPF_FUNC_sk_netns_cmp:
+		return &bpf_sk_netns_cmp_proto;
+	default:
+		return sk_filter_func_proto(func_id);
+	}
+}
+
+static const struct bpf_func_proto *
 cg_skb_func_proto(enum bpf_func_id func_id)
 {
 	switch (func_id) {
@@ -3255,7 +3303,7 @@ static const struct bpf_verifier_ops lwt_xmit_ops = {
 };
 
 static const struct bpf_verifier_ops cg_sock_ops = {
-	.get_func_proto		= sk_filter_func_proto,
+	.get_func_proto		= cg_sock_func_proto,
 	.is_valid_access	= sock_filter_is_valid_access,
 	.convert_ctx_access	= sock_filter_convert_ctx_access,
 };
diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index faaffe2e139a..679cf1496c37 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -94,6 +94,8 @@ static int (*bpf_skb_under_cgroup)(void *ctx, void *map, int index) =
 	(void *) BPF_FUNC_skb_under_cgroup;
 static int (*bpf_skb_change_head)(void *, int len, int flags) =
 	(void *) BPF_FUNC_skb_change_head;
+static unsigned long long (*bpf_sk_netns_cmp)(void *) =
+	(void *) BPF_FUNC_sk_netns_cmp;
 
 #if defined(__x86_64__)
 
diff --git a/samples/bpf/test_cgrp2_sock.c b/samples/bpf/test_cgrp2_sock.c
index c3cfb23e23b5..c29514101a46 100644
--- a/samples/bpf/test_cgrp2_sock.c
+++ b/samples/bpf/test_cgrp2_sock.c
@@ -10,6 +10,7 @@
 
 #define _GNU_SOURCE
 
+#include <sys/stat.h>
 #include <stdio.h>
 #include <stdlib.h>
 #include <stddef.h>
@@ -25,13 +26,24 @@
 
 char bpf_log_buf[BPF_LOG_BUF_SIZE];
 
-static int prog_load(int idx)
+static int prog_load(int idx, __u64 dev, __u64 ino)
 {
 	struct bpf_insn prog[] = {
-		BPF_MOV64_REG(BPF_REG_6, BPF_REG_1),
-		BPF_MOV64_IMM(BPF_REG_3, idx),
-		BPF_MOV64_IMM(BPF_REG_2, offsetof(struct bpf_sock, bound_dev_if)),
-		BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_3, offsetof(struct bpf_sock, bound_dev_if)),
+		BPF_MOV64_REG(BPF_REG_6, BPF_REG_1), /* save sk ctx to r6 */
+
+		/* compare network namespace context for socket; r1 = ctx */
+		BPF_LD_IMM64(BPF_REG_2, dev),
+		BPF_LD_IMM64(BPF_REG_3, ino),
+		BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_sk_netns_cmp),
+		/* if no match skip setting sk_bound_dev_if */
+		BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 3),
+
+		/* set sk_bound_dev_if for socket */
+		BPF_MOV64_IMM(BPF_REG_2, idx),
+		BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
+		BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_2,
+			    offsetof(struct bpf_sock, bound_dev_if)),
+
 		BPF_MOV64_IMM(BPF_REG_0, 1), /* r0 = verdict */
 		BPF_EXIT_INSN(),
 	};
@@ -41,33 +53,51 @@ static int prog_load(int idx)
 				"GPL", 0, bpf_log_buf, BPF_LOG_BUF_SIZE);
 }
 
-static int usage(const char *argv0)
+/* return namespace dev and inode */
+static int get_netns(pid_t pid, __u64 *ns_dev, __u64 *ns_ino)
 {
-	printf("Usage: %s cg-path device-index\n", argv0);
-	return EXIT_FAILURE;
+	char path[64];
+	struct stat st;
+
+	snprintf(path, sizeof(path), "/proc/%d/ns/net", pid);
+
+	if (stat(path, &st) != 0)
+		return -1;
+
+	*ns_dev = st.st_dev;
+	*ns_ino = st.st_ino;
+
+	return 0;
 }
 
-int main(int argc, char **argv)
+static int bind_prog(const char *cpath, const char *dev)
 {
 	int cg_fd, prog_fd, ret;
 	unsigned int idx;
+	__u64 ns_dev, ns_ino;
 
-	if (argc < 2)
-		return usage(argv[0]);
+	if (!dev)
+		return 1;
 
-	idx = if_nametoindex(argv[2]);
+	idx = if_nametoindex(dev);
 	if (!idx) {
 		printf("Invalid device name\n");
 		return EXIT_FAILURE;
 	}
 
-	cg_fd = open(argv[1], O_DIRECTORY | O_RDONLY);
+	if (get_netns(getpid(), &ns_dev, &ns_ino)) {
+		fprintf(stderr,
+			"Failed to read network namespace data\n");
+		return EXIT_FAILURE;
+	}
+
+	cg_fd = open(cpath, O_DIRECTORY | O_RDONLY);
 	if (cg_fd < 0) {
 		printf("Failed to open cgroup path: '%s'\n", strerror(errno));
 		return EXIT_FAILURE;
 	}
 
-	prog_fd = prog_load(idx);
+	prog_fd = prog_load(idx, ns_dev, ns_ino);
 	printf("Output from kernel verifier:\n%s\n-------\n", bpf_log_buf);
 
 	if (prog_fd < 0) {
@@ -84,3 +114,101 @@ int main(int argc, char **argv)
 
 	return EXIT_SUCCESS;
 }
+
+static int socket_test(int family, const char *dev, int is_negative)
+{
+	unsigned int idx;
+	socklen_t optlen;
+	char name[16];
+	int sd, rc;
+
+	if (!dev)
+		return 1;
+
+	if (!is_negative) {
+		idx = if_nametoindex(dev);
+		if (!idx) {
+			printf("Invalid device name\n");
+			return EXIT_FAILURE;
+		}
+	}
+
+	sd = socket(family, SOCK_DGRAM, 0);
+	if (sd < 0)
+		return 1;
+
+	name[0] = '\0';
+	optlen = sizeof(name);
+	rc = getsockopt(sd, SOL_SOCKET, SO_BINDTODEVICE, name, &optlen);
+
+	close(sd);
+	if (rc) {
+		printf("getsockopt(SO_BINDTODEVICE) failed\n");
+		return 1;
+	}
+
+	printf("%s socket bound to \"%s\", checking against \"%s\", neg test %d\n",
+		family == PF_INET ? "ipv4" : "ipv6",
+		name, dev, is_negative);
+
+	if (strcmp(name, dev) && !is_negative) {
+		printf("socket not bound to device as expected\n");
+		return 1;
+	}
+
+	if (!strcmp(name, dev) && is_negative) {
+		printf("socket is bound to device when not expected\n");
+		return 1;
+	}
+
+	return 0;
+}
+
+static int usage(const char *argv0)
+{
+	printf("Usage: %s -c cg-path -d device-index -4 -6 -n\n", argv0);
+	return EXIT_FAILURE;
+}
+
+int main(int argc, char **argv)
+{
+	const char *dev = NULL, *cpath = NULL;
+	int do_ipv4 = 0, do_ipv6 = 0, is_negative = 0;
+	int rc;
+
+	extern char *optarg;
+
+	while ((rc = getopt(argc, argv, "d:c:46in")) > 0) {
+		switch (rc) {
+		case 'd':
+			dev = optarg;
+			break;
+		case 'c':
+			cpath = optarg;
+			break;
+		case '4':
+			do_ipv4 = 1;
+			break;
+		case '6':
+			do_ipv6 = 1;
+			break;
+		case 'n':
+			is_negative = 1;
+			break;
+		default:
+			usage(argv[0]);
+			return 1;
+		}
+	}
+
+	if (cpath && bind_prog(cpath, dev))
+		return 1;
+
+	if (do_ipv4 && socket_test(PF_INET, dev, is_negative))
+		return 1;
+
+	if (do_ipv6 && socket_test(PF_INET6, dev, is_negative))
+		return 1;
+
+	return EXIT_SUCCESS;
+}
diff --git a/samples/bpf/test_cgrp2_sock.sh b/samples/bpf/test_cgrp2_sock.sh
index 925fd467c7cc..bab5185e46f8 100755
--- a/samples/bpf/test_cgrp2_sock.sh
+++ b/samples/bpf/test_cgrp2_sock.sh
@@ -8,11 +8,8 @@ function config_device {
 	ip netns exec at_ns0 ip addr add 172.16.1.100/24 dev veth0
 	ip netns exec at_ns0 ip addr add 2401:db00::1/64 dev veth0 nodad
 	ip netns exec at_ns0 ip link set dev veth0 up
-	ip link add foo type vrf table 1234
-	ip link set foo up
 	ip addr add 172.16.1.101/24 dev veth0b
 	ip addr add 2401:db00::2/64 dev veth0b nodad
-	ip link set veth0b master foo
 }
 
 function attach_bpf {
@@ -20,28 +17,33 @@ function attach_bpf {
 	mkdir -p /tmp/cgroupv2
 	mount -t cgroup2 none /tmp/cgroupv2
 	mkdir -p /tmp/cgroupv2/foo
-	test_cgrp2_sock /tmp/cgroupv2/foo foo
+	test_cgrp2_sock -c /tmp/cgroupv2/foo -d veth0b
 	echo $$ >> /tmp/cgroupv2/foo/cgroup.procs
 }
 
 function cleanup {
 	set +ex
+	ip link del veth0b
 	ip netns delete at_ns0
-	ip link del veth0
-	ip link del foo
 	umount /tmp/cgroupv2
 	rm -rf /tmp/cgroupv2
 	set -ex
 }
 
 function do_test {
-	ping -c1 -w1 172.16.1.100
-	ping6 -c1 -w1 2401:db00::1
+	test_cgrp2_sock -4 -d veth0b
+	test_cgrp2_sock -6 -d veth0b
+}
+
+function do_neg_test {
+	ip netns exec at_ns0 test_cgrp2_sock -4 -n -d veth0b
+	ip netns exec at_ns0 test_cgrp2_sock -6 -n -d veth0b
 }
 
 cleanup 2>/dev/null
 config_device
 attach_bpf
 do_test
+do_neg_test
 cleanup
 echo "*** PASS ***"
-- 
2.1.4
