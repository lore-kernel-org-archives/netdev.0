From: Joe Stringer <joe@ovn.org>
Subject: [PATCHv5 perf/core 2/5] samples/bpf: Switch over to libbpf
Date: Fri, 16 Dec 2016 10:32:56 -0800
Message-ID: <20161216183259.14840-3-joe@ovn.org>
References: <20161216183259.14840-1-joe@ovn.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        wangnan0@huawei.com, ast@fb.com, daniel@iogearbox.net
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:43234 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758496AbcLPSdP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 13:33:15 -0500
In-Reply-To: <20161216183259.14840-1-joe@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that libbpf under tools/lib/bpf/* is synced with the version from
samples/bpf, we can get rid most of the libbpf library here.

Committer notes:

Tested it the same way as the previous patch in this series.

Signed-off-by: Joe Stringer <joe@ovn.org>
Tested-by: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Wang Nan <wangnan0@huawei.com>
Cc: netdev@vger.kernel.org
Link: http://lkml.kernel.org/r/20161214224342.12858-3-joe@ovn.org
[ Use -I$(srctree)/tools/lib/ to support out of source code tree builds, as noticed by Wang Nan ]
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
v5: Joe - I took acme's version from his branch tmp.perf/samples-libbpf and
    applied an incremental fix for the discrepancy between the
    bpf_load_program() API - samples/ was using program size while libbpf uses
    instruction count.
---
 samples/bpf/Makefile             |  68 +++++++++++++-----------
 samples/bpf/README.rst           |   4 +-
 samples/bpf/bpf_load.c           |   3 +-
 samples/bpf/fds_example.c        |   3 +-
 samples/bpf/libbpf.c             | 111 ---------------------------------------
 samples/bpf/libbpf.h             |  19 +------
 samples/bpf/sock_example.c       |   3 +-
 samples/bpf/test_cgrp2_attach.c  |   3 +-
 samples/bpf/test_cgrp2_attach2.c |   3 +-
 samples/bpf/test_cgrp2_sock.c    |   3 +-
 10 files changed, 52 insertions(+), 168 deletions(-)

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index f2219c1489e5..81b0ef2f7994 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -35,40 +35,43 @@ hostprogs-y += tc_l2_redirect
 hostprogs-y += lwt_len_hist
 hostprogs-y += xdp_tx_iptunnel
 
-test_lru_dist-objs := test_lru_dist.o libbpf.o
-sock_example-objs := sock_example.o libbpf.o
-fds_example-objs := bpf_load.o libbpf.o fds_example.o
-sockex1-objs := bpf_load.o libbpf.o sockex1_user.o
-sockex2-objs := bpf_load.o libbpf.o sockex2_user.o
-sockex3-objs := bpf_load.o libbpf.o sockex3_user.o
-tracex1-objs := bpf_load.o libbpf.o tracex1_user.o
-tracex2-objs := bpf_load.o libbpf.o tracex2_user.o
-tracex3-objs := bpf_load.o libbpf.o tracex3_user.o
-tracex4-objs := bpf_load.o libbpf.o tracex4_user.o
-tracex5-objs := bpf_load.o libbpf.o tracex5_user.o
-tracex6-objs := bpf_load.o libbpf.o tracex6_user.o
-test_probe_write_user-objs := bpf_load.o libbpf.o test_probe_write_user_user.o
-trace_output-objs := bpf_load.o libbpf.o trace_output_user.o
-lathist-objs := bpf_load.o libbpf.o lathist_user.o
-offwaketime-objs := bpf_load.o libbpf.o offwaketime_user.o
-spintest-objs := bpf_load.o libbpf.o spintest_user.o
-map_perf_test-objs := bpf_load.o libbpf.o map_perf_test_user.o
-test_overhead-objs := bpf_load.o libbpf.o test_overhead_user.o
-test_cgrp2_array_pin-objs := libbpf.o test_cgrp2_array_pin.o
-test_cgrp2_attach-objs := libbpf.o test_cgrp2_attach.o
-test_cgrp2_attach2-objs := libbpf.o test_cgrp2_attach2.o cgroup_helpers.o
-test_cgrp2_sock-objs := libbpf.o test_cgrp2_sock.o
-test_cgrp2_sock2-objs := bpf_load.o libbpf.o test_cgrp2_sock2.o
-xdp1-objs := bpf_load.o libbpf.o xdp1_user.o
+# Libbpf dependencies
+LIBBPF := libbpf.o ../../tools/lib/bpf/bpf.o
+
+test_lru_dist-objs := test_lru_dist.o $(LIBBPF)
+sock_example-objs := sock_example.o $(LIBBPF)
+fds_example-objs := bpf_load.o $(LIBBPF) fds_example.o
+sockex1-objs := bpf_load.o $(LIBBPF) sockex1_user.o
+sockex2-objs := bpf_load.o $(LIBBPF) sockex2_user.o
+sockex3-objs := bpf_load.o $(LIBBPF) sockex3_user.o
+tracex1-objs := bpf_load.o $(LIBBPF) tracex1_user.o
+tracex2-objs := bpf_load.o $(LIBBPF) tracex2_user.o
+tracex3-objs := bpf_load.o $(LIBBPF) tracex3_user.o
+tracex4-objs := bpf_load.o $(LIBBPF) tracex4_user.o
+tracex5-objs := bpf_load.o $(LIBBPF) tracex5_user.o
+tracex6-objs := bpf_load.o $(LIBBPF) tracex6_user.o
+test_probe_write_user-objs := bpf_load.o $(LIBBPF) test_probe_write_user_user.o
+trace_output-objs := bpf_load.o $(LIBBPF) trace_output_user.o
+lathist-objs := bpf_load.o $(LIBBPF) lathist_user.o
+offwaketime-objs := bpf_load.o $(LIBBPF) offwaketime_user.o
+spintest-objs := bpf_load.o $(LIBBPF) spintest_user.o
+map_perf_test-objs := bpf_load.o $(LIBBPF) map_perf_test_user.o
+test_overhead-objs := bpf_load.o $(LIBBPF) test_overhead_user.o
+test_cgrp2_array_pin-objs := $(LIBBPF) test_cgrp2_array_pin.o
+test_cgrp2_attach-objs := $(LIBBPF) test_cgrp2_attach.o
+test_cgrp2_attach2-objs := $(LIBBPF) test_cgrp2_attach2.o cgroup_helpers.o
+test_cgrp2_sock-objs := $(LIBBPF) test_cgrp2_sock.o
+test_cgrp2_sock2-objs := bpf_load.o $(LIBBPF) test_cgrp2_sock2.o
+xdp1-objs := bpf_load.o $(LIBBPF) xdp1_user.o
 # reuse xdp1 source intentionally
-xdp2-objs := bpf_load.o libbpf.o xdp1_user.o
-test_current_task_under_cgroup-objs := bpf_load.o libbpf.o cgroup_helpers.o \
+xdp2-objs := bpf_load.o $(LIBBPF) xdp1_user.o
+test_current_task_under_cgroup-objs := bpf_load.o $(LIBBPF) cgroup_helpers.o \
 				       test_current_task_under_cgroup_user.o
-trace_event-objs := bpf_load.o libbpf.o trace_event_user.o
-sampleip-objs := bpf_load.o libbpf.o sampleip_user.o
-tc_l2_redirect-objs := bpf_load.o libbpf.o tc_l2_redirect_user.o
-lwt_len_hist-objs := bpf_load.o libbpf.o lwt_len_hist_user.o
-xdp_tx_iptunnel-objs := bpf_load.o libbpf.o xdp_tx_iptunnel_user.o
+trace_event-objs := bpf_load.o $(LIBBPF) trace_event_user.o
+sampleip-objs := bpf_load.o $(LIBBPF) sampleip_user.o
+tc_l2_redirect-objs := bpf_load.o $(LIBBPF) tc_l2_redirect_user.o
+lwt_len_hist-objs := bpf_load.o $(LIBBPF) lwt_len_hist_user.o
+xdp_tx_iptunnel-objs := bpf_load.o $(LIBBPF) xdp_tx_iptunnel_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -104,6 +107,7 @@ always += lwt_len_hist_kern.o
 always += xdp_tx_iptunnel_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
+HOSTCFLAGS += -I$(srctree)/tools/lib/
 HOSTCFLAGS += -I$(srctree)/tools/testing/selftests/bpf/
 
 HOSTCFLAGS_bpf_load.o += -I$(objtree)/usr/include -Wno-unused-variable
diff --git a/samples/bpf/README.rst b/samples/bpf/README.rst
index a43eae3f0551..79f9a58f1872 100644
--- a/samples/bpf/README.rst
+++ b/samples/bpf/README.rst
@@ -1,8 +1,8 @@
 eBPF sample programs
 ====================
 
-This directory contains a mini eBPF library, test stubs, verifier
-test-suite and examples for using eBPF.
+This directory contains a test stubs, verifier test-suite and examples
+for using eBPF. The examples use libbpf from tools/lib/bpf.
 
 Build dependencies
 ==================
diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index f5b186c46b7c..1bfb43394013 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -66,6 +66,7 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 	bool is_perf_event = strncmp(event, "perf_event", 10) == 0;
 	bool is_cgroup_skb = strncmp(event, "cgroup/skb", 10) == 0;
 	bool is_cgroup_sk = strncmp(event, "cgroup/sock", 11) == 0;
+	size_t insns_cnt = size / sizeof(struct bpf_insn);
 	enum bpf_prog_type prog_type;
 	char buf[256];
 	int fd, efd, err, id;
@@ -95,7 +96,7 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 		return -1;
 	}
 
-	fd = bpf_load_program(prog_type, prog, size, license, kern_version,
+	fd = bpf_load_program(prog_type, prog, insns_cnt, license, kern_version,
 			      bpf_log_buf, BPF_LOG_BUF_SIZE);
 	if (fd < 0) {
 		printf("bpf_load_program() err=%d\n%s", errno, bpf_log_buf);
diff --git a/samples/bpf/fds_example.c b/samples/bpf/fds_example.c
index 8a4fc4ef3993..6245062844d1 100644
--- a/samples/bpf/fds_example.c
+++ b/samples/bpf/fds_example.c
@@ -53,13 +53,14 @@ static int bpf_prog_create(const char *object)
 		BPF_MOV64_IMM(BPF_REG_0, 1),
 		BPF_EXIT_INSN(),
 	};
+	size_t insns_cnt = sizeof(insns) / sizeof(struct bpf_insn);
 
 	if (object) {
 		assert(!load_bpf_file((char *)object));
 		return prog_fd[0];
 	} else {
 		return bpf_load_program(BPF_PROG_TYPE_SOCKET_FILTER,
-					insns, sizeof(insns), "GPL", 0,
+					insns, insns_cnt, "GPL", 0,
 					bpf_log_buf, BPF_LOG_BUF_SIZE);
 	}
 }
diff --git a/samples/bpf/libbpf.c b/samples/bpf/libbpf.c
index 6f076abdca35..3391225ad7e9 100644
--- a/samples/bpf/libbpf.c
+++ b/samples/bpf/libbpf.c
@@ -4,8 +4,6 @@
 #include <linux/unistd.h>
 #include <unistd.h>
 #include <string.h>
-#include <linux/netlink.h>
-#include <linux/bpf.h>
 #include <errno.h>
 #include <net/ethernet.h>
 #include <net/if.h>
@@ -13,96 +11,6 @@
 #include <arpa/inet.h>
 #include "libbpf.h"
 
-static __u64 ptr_to_u64(void *ptr)
-{
-	return (__u64) (unsigned long) ptr;
-}
-
-int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
-		   int max_entries, int map_flags)
-{
-	union bpf_attr attr = {
-		.map_type = map_type,
-		.key_size = key_size,
-		.value_size = value_size,
-		.max_entries = max_entries,
-		.map_flags = map_flags,
-	};
-
-	return syscall(__NR_bpf, BPF_MAP_CREATE, &attr, sizeof(attr));
-}
-
-int bpf_map_update_elem(int fd, void *key, void *value, unsigned long long flags)
-{
-	union bpf_attr attr = {
-		.map_fd = fd,
-		.key = ptr_to_u64(key),
-		.value = ptr_to_u64(value),
-		.flags = flags,
-	};
-
-	return syscall(__NR_bpf, BPF_MAP_UPDATE_ELEM, &attr, sizeof(attr));
-}
-
-int bpf_map_lookup_elem(int fd, void *key, void *value)
-{
-	union bpf_attr attr = {
-		.map_fd = fd,
-		.key = ptr_to_u64(key),
-		.value = ptr_to_u64(value),
-	};
-
-	return syscall(__NR_bpf, BPF_MAP_LOOKUP_ELEM, &attr, sizeof(attr));
-}
-
-int bpf_map_delete_elem(int fd, void *key)
-{
-	union bpf_attr attr = {
-		.map_fd = fd,
-		.key = ptr_to_u64(key),
-	};
-
-	return syscall(__NR_bpf, BPF_MAP_DELETE_ELEM, &attr, sizeof(attr));
-}
-
-int bpf_map_get_next_key(int fd, void *key, void *next_key)
-{
-	union bpf_attr attr = {
-		.map_fd = fd,
-		.key = ptr_to_u64(key),
-		.next_key = ptr_to_u64(next_key),
-	};
-
-	return syscall(__NR_bpf, BPF_MAP_GET_NEXT_KEY, &attr, sizeof(attr));
-}
-
-#define ROUND_UP(x, n) (((x) + (n) - 1u) & ~((n) - 1u))
-
-int bpf_load_program(enum bpf_prog_type prog_type,
-		     const struct bpf_insn *insns, int prog_len,
-		     const char *license, int kern_version,
-		     char *log_buf, size_t log_buf_sz)
-{
-	union bpf_attr attr = {
-		.prog_type = prog_type,
-		.insns = ptr_to_u64((void *) insns),
-		.insn_cnt = prog_len / sizeof(struct bpf_insn),
-		.license = ptr_to_u64((void *) license),
-		.log_buf = ptr_to_u64(log_buf),
-		.log_size = log_buf_sz,
-		.log_level = 1,
-	};
-
-	/* assign one field outside of struct init to make sure any
-	 * padding is zero initialized
-	 */
-	attr.kern_version = kern_version;
-
-	log_buf[0] = 0;
-
-	return syscall(__NR_bpf, BPF_PROG_LOAD, &attr, sizeof(attr));
-}
-
 int bpf_prog_attach(int prog_fd, int target_fd, enum bpf_attach_type type)
 {
 	union bpf_attr attr = {
@@ -124,25 +32,6 @@ int bpf_prog_detach(int target_fd, enum bpf_attach_type type)
 	return syscall(__NR_bpf, BPF_PROG_DETACH, &attr, sizeof(attr));
 }
 
-int bpf_obj_pin(int fd, const char *pathname)
-{
-	union bpf_attr attr = {
-		.pathname	= ptr_to_u64((void *)pathname),
-		.bpf_fd		= fd,
-	};
-
-	return syscall(__NR_bpf, BPF_OBJ_PIN, &attr, sizeof(attr));
-}
-
-int bpf_obj_get(const char *pathname)
-{
-	union bpf_attr attr = {
-		.pathname	= ptr_to_u64((void *)pathname),
-	};
-
-	return syscall(__NR_bpf, BPF_OBJ_GET, &attr, sizeof(attr));
-}
-
 int open_raw_sock(const char *name)
 {
 	struct sockaddr_ll sll;
diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
index 20e3457857ca..cf7d2386d1f9 100644
--- a/samples/bpf/libbpf.h
+++ b/samples/bpf/libbpf.h
@@ -2,28 +2,13 @@
 #ifndef __LIBBPF_H
 #define __LIBBPF_H
 
-struct bpf_insn;
-
-int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
-		   int max_entries, int map_flags);
-int bpf_map_update_elem(int fd, void *key, void *value, unsigned long long flags);
-int bpf_map_lookup_elem(int fd, void *key, void *value);
-int bpf_map_delete_elem(int fd, void *key);
-int bpf_map_get_next_key(int fd, void *key, void *next_key);
+#include <bpf/bpf.h>
 
-int bpf_load_program(enum bpf_prog_type prog_type,
-		     const struct bpf_insn *insns, int insn_len,
-		     const char *license, int kern_version,
-		     char *log_buf, size_t log_buf_sz);
+struct bpf_insn;
 
 int bpf_prog_attach(int prog_fd, int attachable_fd, enum bpf_attach_type type);
 int bpf_prog_detach(int attachable_fd, enum bpf_attach_type type);
 
-int bpf_obj_pin(int fd, const char *pathname);
-int bpf_obj_get(const char *pathname);
-
-#define BPF_LOG_BUF_SIZE (256 * 1024)
-
 /* ALU ops on registers, bpf_add|sub|...: dst_reg += src_reg */
 
 #define BPF_ALU64_REG(OP, DST, SRC)				\
diff --git a/samples/bpf/sock_example.c b/samples/bpf/sock_example.c
index d6b91e9a38ad..5546f8aac37e 100644
--- a/samples/bpf/sock_example.c
+++ b/samples/bpf/sock_example.c
@@ -56,8 +56,9 @@ static int test_sock(void)
 		BPF_MOV64_IMM(BPF_REG_0, 0), /* r0 = 0 */
 		BPF_EXIT_INSN(),
 	};
+	size_t insns_cnt = sizeof(prog) / sizeof(struct bpf_insn);
 
-	prog_fd = bpf_load_program(BPF_PROG_TYPE_SOCKET_FILTER, prog, sizeof(prog),
+	prog_fd = bpf_load_program(BPF_PROG_TYPE_SOCKET_FILTER, prog, insns_cnt,
 				   "GPL", 0, bpf_log_buf, BPF_LOG_BUF_SIZE);
 	if (prog_fd < 0) {
 		printf("failed to load prog '%s'\n", strerror(errno));
diff --git a/samples/bpf/test_cgrp2_attach.c b/samples/bpf/test_cgrp2_attach.c
index 8283ef86d392..504058631ffc 100644
--- a/samples/bpf/test_cgrp2_attach.c
+++ b/samples/bpf/test_cgrp2_attach.c
@@ -68,9 +68,10 @@ static int prog_load(int map_fd, int verdict)
 		BPF_MOV64_IMM(BPF_REG_0, verdict), /* r0 = verdict */
 		BPF_EXIT_INSN(),
 	};
+	size_t insns_cnt = sizeof(prog) / sizeof(struct bpf_insn);
 
 	return bpf_load_program(BPF_PROG_TYPE_CGROUP_SKB,
-				prog, sizeof(prog), "GPL", 0,
+				prog, insns_cnt, "GPL", 0,
 				bpf_log_buf, BPF_LOG_BUF_SIZE);
 }
 
diff --git a/samples/bpf/test_cgrp2_attach2.c b/samples/bpf/test_cgrp2_attach2.c
index fc6092fdc3b0..6e69be37f87f 100644
--- a/samples/bpf/test_cgrp2_attach2.c
+++ b/samples/bpf/test_cgrp2_attach2.c
@@ -41,9 +41,10 @@ static int prog_load(int verdict)
 		BPF_MOV64_IMM(BPF_REG_0, verdict), /* r0 = verdict */
 		BPF_EXIT_INSN(),
 	};
+	size_t insns_cnt = sizeof(prog) / sizeof(struct bpf_insn);
 
 	ret = bpf_load_program(BPF_PROG_TYPE_CGROUP_SKB,
-			       prog, sizeof(prog), "GPL", 0,
+			       prog, insns_cnt, "GPL", 0,
 			       bpf_log_buf, BPF_LOG_BUF_SIZE);
 
 	if (ret < 0) {
diff --git a/samples/bpf/test_cgrp2_sock.c b/samples/bpf/test_cgrp2_sock.c
index 43b4bde5d05c..0791b949cbe4 100644
--- a/samples/bpf/test_cgrp2_sock.c
+++ b/samples/bpf/test_cgrp2_sock.c
@@ -35,8 +35,9 @@ static int prog_load(int idx)
 		BPF_MOV64_IMM(BPF_REG_0, 1), /* r0 = verdict */
 		BPF_EXIT_INSN(),
 	};
+	size_t insns_cnt = sizeof(prog) / sizeof(struct bpf_insn);
 
-	return bpf_load_program(BPF_PROG_TYPE_CGROUP_SOCK, prog, sizeof(prog),
+	return bpf_load_program(BPF_PROG_TYPE_CGROUP_SOCK, prog, insns_cnt,
 				"GPL", 0, bpf_log_buf, BPF_LOG_BUF_SIZE);
 }
 
-- 
2.10.2
