From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 4/4] bpf: Add tests for map-in-map
Date: Wed, 22 Mar 2017 10:00:35 -0700
Message-ID: <20170322170035.923581-5-kafai@fb.com>
References: <20170322170035.923581-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        FB Kernel Team <Kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:45052 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1760942AbdCVRAn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 13:00:43 -0400
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2MGwj8R009081
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 10:00:37 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 29bnywt6bg-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 10:00:37 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.102.107.99) with ESMTP id
 1131eeba0f2111e796020002c99293a0-bedf39a0 for <netdev@vger.kernel.org>;        Wed,
 22 Mar 2017 10:00:35 -0700
In-Reply-To: <20170322170035.923581-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Test cases for array of maps and hash of maps.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/Makefile                        |   4 +
 samples/bpf/bpf_helpers.h                   |   1 +
 samples/bpf/bpf_load.c                      |  22 +++-
 samples/bpf/test_map_in_map_kern.c          | 173 ++++++++++++++++++++++++++++
 samples/bpf/test_map_in_map_user.c          | 116 +++++++++++++++++++
 tools/include/uapi/linux/bpf.h              |   3 +
 tools/lib/bpf/bpf.c                         |  17 +++
 tools/lib/bpf/bpf.h                         |   2 +
 tools/testing/selftests/bpf/test_verifier.c | 131 ++++++++++++++++++---
 9 files changed, 451 insertions(+), 18 deletions(-)
 create mode 100644 samples/bpf/test_map_in_map_kern.c
 create mode 100644 samples/bpf/test_map_in_map_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 09e9d535bd74..91c1d616d975 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -34,6 +34,7 @@ hostprogs-y += sampleip
 hostprogs-y += tc_l2_redirect
 hostprogs-y += lwt_len_hist
 hostprogs-y += xdp_tx_iptunnel
+hostprogs-y += test_map_in_map
 
 # Libbpf dependencies
 LIBBPF := ../../tools/lib/bpf/bpf.o
@@ -72,6 +73,7 @@ sampleip-objs := bpf_load.o $(LIBBPF) sampleip_user.o
 tc_l2_redirect-objs := bpf_load.o $(LIBBPF) tc_l2_redirect_user.o
 lwt_len_hist-objs := bpf_load.o $(LIBBPF) lwt_len_hist_user.o
 xdp_tx_iptunnel-objs := bpf_load.o $(LIBBPF) xdp_tx_iptunnel_user.o
+test_map_in_map-objs := bpf_load.o $(LIBBPF) test_map_in_map_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -105,6 +107,7 @@ always += trace_event_kern.o
 always += sampleip_kern.o
 always += lwt_len_hist_kern.o
 always += xdp_tx_iptunnel_kern.o
+always += test_map_in_map_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 HOSTCFLAGS += -I$(srctree)/tools/lib/
@@ -139,6 +142,7 @@ HOSTLOADLIBES_sampleip += -lelf
 HOSTLOADLIBES_tc_l2_redirect += -l elf
 HOSTLOADLIBES_lwt_len_hist += -l elf
 HOSTLOADLIBES_xdp_tx_iptunnel += -lelf
+HOSTLOADLIBES_test_map_in_map += -lelf
 
 # Allows pointing LLC/CLANG to a LLVM backend with bpf support, redefine on cmdline:
 #  make samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index faaffe2e139a..52de9d88c021 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -80,6 +80,7 @@ struct bpf_map_def {
 	unsigned int value_size;
 	unsigned int max_entries;
 	unsigned int map_flags;
+	unsigned int inner_map_idx;
 };
 
 static int (*bpf_skb_load_bytes)(void *ctx, int off, void *to, int len) =
diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index b86ee54da2d1..dcdce1270d38 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -43,6 +43,7 @@ struct bpf_map_def {
 	unsigned int value_size;
 	unsigned int max_entries;
 	unsigned int map_flags;
+	unsigned int inner_map_idx;
 };
 
 static int populate_prog_array(const char *event, int prog_fd)
@@ -198,11 +199,22 @@ static int load_maps(struct bpf_map_def *maps, int len)
 
 	for (i = 0; i < len / sizeof(struct bpf_map_def); i++) {
 
-		map_fd[i] = bpf_create_map(maps[i].type,
-					   maps[i].key_size,
-					   maps[i].value_size,
-					   maps[i].max_entries,
-					   maps[i].map_flags);
+		if (maps[i].type == BPF_MAP_TYPE_ARRAY_OF_MAPS ||
+		    maps[i].type == BPF_MAP_TYPE_HASH_OF_MAPS) {
+			int inner_map_fd = map_fd[maps[i].inner_map_idx];
+
+			map_fd[i] = bpf_create_map_in_map(maps[i].type,
+							  maps[i].key_size,
+							  inner_map_fd,
+							  maps[i].max_entries,
+							  maps[i].map_flags);
+		} else {
+			map_fd[i] = bpf_create_map(maps[i].type,
+						   maps[i].key_size,
+						   maps[i].value_size,
+						   maps[i].max_entries,
+						   maps[i].map_flags);
+		}
 		if (map_fd[i] < 0) {
 			printf("failed to create a map: %d %s\n",
 			       errno, strerror(errno));
diff --git a/samples/bpf/test_map_in_map_kern.c b/samples/bpf/test_map_in_map_kern.c
new file mode 100644
index 000000000000..42c44d091dd1
--- /dev/null
+++ b/samples/bpf/test_map_in_map_kern.c
@@ -0,0 +1,173 @@
+/*
+ * Copyright (c) 2017 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#define KBUILD_MODNAME "foo"
+#include <linux/ptrace.h>
+#include <linux/version.h>
+#include <uapi/linux/bpf.h>
+#include <uapi/linux/in6.h>
+#include "bpf_helpers.h"
+
+#define MAX_NR_PORTS 65536
+
+/* map #0 */
+struct bpf_map_def SEC("maps") port_a = {
+	.type = BPF_MAP_TYPE_ARRAY,
+	.key_size = sizeof(u32),
+	.value_size = sizeof(int),
+	.max_entries = MAX_NR_PORTS,
+};
+
+/* map #1 */
+struct bpf_map_def SEC("maps") port_h = {
+	.type = BPF_MAP_TYPE_HASH,
+	.key_size = sizeof(u32),
+	.value_size = sizeof(int),
+	.max_entries = 1,
+};
+
+/* map #2 */
+struct bpf_map_def SEC("maps") reg_result_h = {
+	.type = BPF_MAP_TYPE_HASH,
+	.key_size = sizeof(u32),
+	.value_size = sizeof(int),
+	.max_entries = 1,
+};
+
+/* map #3 */
+struct bpf_map_def SEC("maps") inline_result_h = {
+	.type = BPF_MAP_TYPE_HASH,
+	.key_size = sizeof(u32),
+	.value_size = sizeof(int),
+	.max_entries = 1,
+};
+
+/* map #4 */ /* Test case #0 */
+struct bpf_map_def SEC("maps") a_of_port_a = {
+	.type = BPF_MAP_TYPE_ARRAY_OF_MAPS,
+	.key_size = sizeof(u32),
+	.inner_map_idx = 0, /* map_fd[0] is port_a */
+	.max_entries = MAX_NR_PORTS,
+};
+
+/* map #5 */ /* Test case #1 */
+struct bpf_map_def SEC("maps") h_of_port_a = {
+	.type = BPF_MAP_TYPE_HASH_OF_MAPS,
+	.key_size = sizeof(u32),
+	.inner_map_idx = 0, /* map_fd[0] is port_a */
+	.max_entries = 1,
+};
+
+/* map #6 */ /* Test case #2 */
+struct bpf_map_def SEC("maps") h_of_port_h = {
+	.type = BPF_MAP_TYPE_HASH_OF_MAPS,
+	.key_size = sizeof(u32),
+	.inner_map_idx = 1, /* map_fd[1] is port_h */
+	.max_entries = 1,
+};
+
+static __always_inline int do_reg_lookup(void *inner_map, u32 port)
+{
+	int *result;
+
+	result = bpf_map_lookup_elem(inner_map, &port);
+	return result ? *result : -ENOENT;
+}
+
+static __always_inline int do_inline_array_lookup(void *inner_map, u32 port)
+{
+	int *result;
+
+	if (inner_map != &port_a)
+		return -EINVAL;
+
+	result = bpf_map_lookup_elem(&port_a, &port);
+	return result ? *result : -ENOENT;
+}
+
+static __always_inline int do_inline_hash_lookup(void *inner_map, u32 port)
+{
+	int *result;
+
+	if (inner_map != &port_h)
+		return -EINVAL;
+
+	result = bpf_map_lookup_elem(&port_h, &port);
+	return result ? *result : -ENOENT;
+}
+
+SEC("kprobe/sys_connect")
+int trace_sys_connect(struct pt_regs *ctx)
+{
+	struct sockaddr_in6 *in6;
+	u16 test_case, port, dst6[8];
+	int addrlen, ret, inline_ret, ret_key = 0;
+	u32 port_key;
+	void *outer_map, *inner_map;
+	bool inline_hash = false;
+
+	in6 = (struct sockaddr_in6 *)PT_REGS_PARM2(ctx);
+	addrlen = (int)PT_REGS_PARM3(ctx);
+
+	if (addrlen != sizeof(*in6))
+		return 0;
+
+	ret = bpf_probe_read(dst6, sizeof(dst6), &in6->sin6_addr);
+	if (ret) {
+		inline_ret = ret;
+		goto done;
+	}
+
+	if (dst6[0] != 0xdead || dst6[1] != 0xbeef)
+		return 0;
+
+	test_case = dst6[7];
+
+	ret = bpf_probe_read(&port, sizeof(port), &in6->sin6_port);
+	if (ret) {
+		inline_ret = ret;
+		goto done;
+	}
+
+	port_key = port;
+
+	ret = -ENOENT;
+	if (test_case == 0) {
+		outer_map = &a_of_port_a;
+	} else if (test_case == 1) {
+		outer_map = &h_of_port_a;
+	} else if (test_case == 2) {
+		outer_map = &h_of_port_h;
+	} else {
+		ret = __LINE__;
+		inline_ret = ret;
+		goto done;
+	}
+
+	inner_map = bpf_map_lookup_elem(outer_map, &port_key);
+	if (!inner_map) {
+		ret = __LINE__;
+		inline_ret = ret;
+		goto done;
+	}
+
+	ret = do_reg_lookup(inner_map, port_key);
+
+	if (test_case == 0 || test_case == 1)
+		inline_ret = do_inline_array_lookup(inner_map, port_key);
+	else
+		inline_ret = do_inline_hash_lookup(inner_map, port_key);
+
+done:
+	bpf_map_update_elem(&reg_result_h, &ret_key, &ret, BPF_ANY);
+	bpf_map_update_elem(&inline_result_h, &ret_key, &inline_ret, BPF_ANY);
+
+	return 0;
+}
+
+char _license[] SEC("license") = "GPL";
+u32 _version SEC("version") = LINUX_VERSION_CODE;
diff --git a/samples/bpf/test_map_in_map_user.c b/samples/bpf/test_map_in_map_user.c
new file mode 100644
index 000000000000..f62fdc2bd428
--- /dev/null
+++ b/samples/bpf/test_map_in_map_user.c
@@ -0,0 +1,116 @@
+/*
+ * Copyright (c) 2017 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <sys/resource.h>
+#include <sys/socket.h>
+#include <arpa/inet.h>
+#include <stdint.h>
+#include <assert.h>
+#include <errno.h>
+#include <stdlib.h>
+#include <stdio.h>
+#include "libbpf.h"
+#include "bpf_load.h"
+
+#define PORT_A		(map_fd[0])
+#define PORT_H		(map_fd[1])
+#define REG_RESULT_H	(map_fd[2])
+#define INLINE_RESULT_H	(map_fd[3])
+#define A_OF_PORT_A	(map_fd[4]) /* Test case #0 */
+#define H_OF_PORT_A	(map_fd[5]) /* Test case #1 */
+#define H_OF_PORT_H	(map_fd[6]) /* Test case #2 */
+
+static const char * const test_names[] = {
+	"Array of Array",
+	"Hash of Array",
+	"Hash of Hash",
+};
+
+#define NR_TESTS (sizeof(test_names) / sizeof(*test_names))
+
+static void populate_map(uint32_t port_key, int magic_result)
+{
+	int ret;
+
+	ret = bpf_map_update_elem(PORT_A, &port_key, &magic_result, BPF_ANY);
+	assert(!ret);
+
+	ret = bpf_map_update_elem(PORT_H, &port_key, &magic_result,
+				  BPF_NOEXIST);
+	assert(!ret);
+
+	ret = bpf_map_update_elem(A_OF_PORT_A, &port_key, &PORT_A, BPF_ANY);
+	assert(!ret);
+
+	ret = bpf_map_update_elem(H_OF_PORT_A, &port_key, &PORT_A, BPF_NOEXIST);
+	assert(!ret);
+
+	ret = bpf_map_update_elem(H_OF_PORT_H, &port_key, &PORT_H, BPF_NOEXIST);
+	assert(!ret);
+}
+
+static void test_map_in_map(void)
+{
+	struct sockaddr_in6 in6 = { .sin6_family = AF_INET6 };
+	uint32_t result_key = 0, port_key;
+	int result, inline_result;
+	int magic_result = 0xfaceb00c;
+	int ret;
+	int i;
+
+	port_key = rand() & 0x00FF;
+	populate_map(port_key, magic_result);
+
+	in6.sin6_addr.s6_addr16[0] = 0xdead;
+	in6.sin6_addr.s6_addr16[1] = 0xbeef;
+	in6.sin6_port = port_key;
+
+	for (i = 0; i < NR_TESTS; i++) {
+		printf("%s: ", test_names[i]);
+
+		in6.sin6_addr.s6_addr16[7] = i;
+		ret = connect(-1, (struct sockaddr *)&in6, sizeof(in6));
+		assert(ret == -1 && errno == EBADF);
+
+		ret = bpf_map_lookup_elem(REG_RESULT_H, &result_key, &result);
+		assert(!ret);
+
+		ret = bpf_map_lookup_elem(INLINE_RESULT_H, &result_key,
+					  &inline_result);
+		assert(!ret);
+
+		if (result != magic_result || inline_result != magic_result) {
+			printf("Error. result:%d inline_result:%d\n",
+			       result, inline_result);
+			exit(1);
+		}
+
+		bpf_map_delete_elem(REG_RESULT_H, &result_key);
+		bpf_map_delete_elem(INLINE_RESULT_H, &result_key);
+
+		printf("Pass\n");
+	}
+}
+
+int main(int argc, char **argv)
+{
+	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
+	char filename[256];
+
+	assert(!setrlimit(RLIMIT_MEMLOCK, &r));
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+
+	if (load_bpf_file(filename)) {
+		printf("%s", bpf_log_buf);
+		return 1;
+	}
+
+	test_map_in_map();
+
+	return 0;
+}
diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index 0539a0ceef38..ce6f029ac368 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -96,6 +96,8 @@ enum bpf_map_type {
 	BPF_MAP_TYPE_LRU_HASH,
 	BPF_MAP_TYPE_LRU_PERCPU_HASH,
 	BPF_MAP_TYPE_LPM_TRIE,
+	BPF_MAP_TYPE_ARRAY_OF_MAPS,
+	BPF_MAP_TYPE_HASH_OF_MAPS,
 };
 
 enum bpf_prog_type {
@@ -152,6 +154,7 @@ union bpf_attr {
 		__u32	value_size;	/* size of value in bytes */
 		__u32	max_entries;	/* max number of entries in a map */
 		__u32	map_flags;	/* prealloc or not */
+		__u32	inner_map_fd;	/* fd pointing to the inner map */
 	};
 
 	struct { /* anonymous struct used by BPF_MAP_*_ELEM commands */
diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
index 207c2eeddab0..9b58d20e8c93 100644
--- a/tools/lib/bpf/bpf.c
+++ b/tools/lib/bpf/bpf.c
@@ -69,6 +69,23 @@ int bpf_create_map(enum bpf_map_type map_type, int key_size,
 	return sys_bpf(BPF_MAP_CREATE, &attr, sizeof(attr));
 }
 
+int bpf_create_map_in_map(enum bpf_map_type map_type, int key_size,
+			  int inner_map_fd, int max_entries, __u32 map_flags)
+{
+	union bpf_attr attr;
+
+	memset(&attr, '\0', sizeof(attr));
+
+	attr.map_type = map_type;
+	attr.key_size = key_size;
+	attr.value_size = 4;
+	attr.inner_map_fd = inner_map_fd;
+	attr.max_entries = max_entries;
+	attr.map_flags = map_flags;
+
+	return sys_bpf(BPF_MAP_CREATE, &attr, sizeof(attr));
+}
+
 int bpf_load_program(enum bpf_prog_type type, const struct bpf_insn *insns,
 		     size_t insns_cnt, const char *license,
 		     __u32 kern_version, char *log_buf, size_t log_buf_sz)
diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
index 09c3dcac0496..93f021932623 100644
--- a/tools/lib/bpf/bpf.h
+++ b/tools/lib/bpf/bpf.h
@@ -26,6 +26,8 @@
 
 int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
 		   int max_entries, __u32 map_flags);
+int bpf_create_map_in_map(enum bpf_map_type map_type, int key_size,
+			  int inner_map_fd, int max_entries, __u32 map_flags);
 
 /* Recommend log buffer size */
 #define BPF_LOG_BUF_SIZE 65536
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index d1555e4240c0..f4f43c98cf7f 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -38,6 +38,7 @@
 
 #define MAX_INSNS	512
 #define MAX_FIXUPS	8
+#define MAX_NR_MAPS	4
 
 struct bpf_test {
 	const char *descr;
@@ -45,6 +46,7 @@ struct bpf_test {
 	int fixup_map1[MAX_FIXUPS];
 	int fixup_map2[MAX_FIXUPS];
 	int fixup_prog[MAX_FIXUPS];
+	int fixup_map_in_map[MAX_FIXUPS];
 	const char *errstr;
 	const char *errstr_unpriv;
 	enum {
@@ -4452,7 +4454,76 @@ static struct bpf_test tests[] = {
 		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
 		.result = REJECT,
 		.result_unpriv = REJECT,
-	}
+	},
+	{
+		"map in map access",
+		.insns = {
+			BPF_ST_MEM(0, BPF_REG_10, -4, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -4),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 5),
+			BPF_ST_MEM(0, BPF_REG_10, -4, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -4),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_MOV64_REG(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map_in_map = { 3 },
+		.result = ACCEPT,
+	},
+	{
+		"invalid inner map pointer",
+		.insns = {
+			BPF_ST_MEM(0, BPF_REG_10, -4, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -4),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 6),
+			BPF_ST_MEM(0, BPF_REG_10, -4, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -4),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 8),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_MOV64_REG(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map_in_map = { 3 },
+		.errstr = "R1 type=inv expected=map_ptr",
+		.errstr_unpriv = "R1 pointer arithmetic prohibited",
+		.result = REJECT,
+	},
+	{
+		"forgot null checking on the inner map pointer",
+		.insns = {
+			BPF_ST_MEM(0, BPF_REG_10, -4, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -4),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_ST_MEM(0, BPF_REG_10, -4, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -4),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_MOV64_REG(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map_in_map = { 3 },
+		.errstr = "R1 type=map_value_or_null expected=map_ptr",
+		.result = REJECT,
+	},
 };
 
 static int probe_filter_length(const struct bpf_insn *fp)
@@ -4489,42 +4560,73 @@ static int create_prog_array(void)
 	return fd;
 }
 
+static int create_map_in_map(void)
+{
+	int inner_map_fd, outer_map_fd;
+
+	inner_map_fd = bpf_create_map(BPF_MAP_TYPE_ARRAY, sizeof(int),
+				      sizeof(int), 1, 0);
+	if (inner_map_fd < 0) {
+		printf("Failed to create array '%s'!\n", strerror(errno));
+		return inner_map_fd;
+	}
+
+	outer_map_fd = bpf_create_map_in_map(BPF_MAP_TYPE_ARRAY_OF_MAPS,
+					     sizeof(int), inner_map_fd, 1, 0);
+	if (outer_map_fd < 0)
+		printf("Failed to create array of maps '%s'!\n",
+		       strerror(errno));
+
+	close(inner_map_fd);
+
+	return outer_map_fd;
+}
+
 static char bpf_vlog[32768];
 
 static void do_test_fixup(struct bpf_test *test, struct bpf_insn *prog,
-			  int *fd_f1, int *fd_f2, int *fd_f3)
+			  int *map_fds)
 {
 	int *fixup_map1 = test->fixup_map1;
 	int *fixup_map2 = test->fixup_map2;
 	int *fixup_prog = test->fixup_prog;
+	int *fixup_map_in_map = test->fixup_map_in_map;
 
 	/* Allocating HTs with 1 elem is fine here, since we only test
 	 * for verifier and not do a runtime lookup, so the only thing
 	 * that really matters is value size in this case.
 	 */
 	if (*fixup_map1) {
-		*fd_f1 = create_map(sizeof(long long), 1);
+		map_fds[0] = create_map(sizeof(long long), 1);
 		do {
-			prog[*fixup_map1].imm = *fd_f1;
+			prog[*fixup_map1].imm = map_fds[0];
 			fixup_map1++;
 		} while (*fixup_map1);
 	}
 
 	if (*fixup_map2) {
-		*fd_f2 = create_map(sizeof(struct test_val), 1);
+		map_fds[1] = create_map(sizeof(struct test_val), 1);
 		do {
-			prog[*fixup_map2].imm = *fd_f2;
+			prog[*fixup_map2].imm = map_fds[1];
 			fixup_map2++;
 		} while (*fixup_map2);
 	}
 
 	if (*fixup_prog) {
-		*fd_f3 = create_prog_array();
+		map_fds[2] = create_prog_array();
 		do {
-			prog[*fixup_prog].imm = *fd_f3;
+			prog[*fixup_prog].imm = map_fds[2];
 			fixup_prog++;
 		} while (*fixup_prog);
 	}
+
+	if (*fixup_map_in_map) {
+		map_fds[3] = create_map_in_map();
+		do {
+			prog[*fixup_map_in_map].imm = map_fds[3];
+			fixup_map_in_map++;
+		} while (*fixup_map_in_map);
+	}
 }
 
 static void do_test_single(struct bpf_test *test, bool unpriv,
@@ -4533,11 +4635,15 @@ static void do_test_single(struct bpf_test *test, bool unpriv,
 	struct bpf_insn *prog = test->insns;
 	int prog_len = probe_filter_length(prog);
 	int prog_type = test->prog_type;
-	int fd_f1 = -1, fd_f2 = -1, fd_f3 = -1;
+	int map_fds[MAX_NR_MAPS];
 	int fd_prog, expected_ret;
 	const char *expected_err;
+	int i;
+
+	for (i = 0; i < MAX_NR_MAPS; i++)
+		map_fds[i] = -1;
 
-	do_test_fixup(test, prog, &fd_f1, &fd_f2, &fd_f3);
+	do_test_fixup(test, prog, map_fds);
 
 	fd_prog = bpf_load_program(prog_type ? : BPF_PROG_TYPE_SOCKET_FILTER,
 				   prog, prog_len, "GPL", 0, bpf_vlog,
@@ -4568,9 +4674,8 @@ static void do_test_single(struct bpf_test *test, bool unpriv,
 	printf("OK\n");
 close_fds:
 	close(fd_prog);
-	close(fd_f1);
-	close(fd_f2);
-	close(fd_f3);
+	for (i = 0; i < MAX_NR_MAPS; i++)
+		close(map_fds[i]);
 	sched_yield();
 	return;
 fail_log:
-- 
2.9.3
