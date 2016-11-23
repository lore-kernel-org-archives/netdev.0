From: Daniel Mack <daniel@zonque.org>
Subject: [PATCH v9 6/6] samples: bpf: add userspace example for attaching eBPF programs to cgroups
Date: Wed, 23 Nov 2016 16:52:30 +0100
Message-ID: <1479916350-28462-7-git-send-email-daniel@zonque.org>
References: <1479916350-28462-1-git-send-email-daniel@zonque.org>
Cc: davem@davemloft.net, kafai@fb.com, fw@strlen.de,
        pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org,
        sargun@sargun.me, cgroups@vger.kernel.org,
        Daniel Mack <daniel@zonque.org>
To: htejun@fb.com, daniel@iogearbox.net, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:49664 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935117AbcKWPwn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Nov 2016 10:52:43 -0500
In-Reply-To: <1479916350-28462-1-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a simple userpace program to demonstrate the new API to attach eBPF
programs to cgroups. This is what it does:

 * Create arraymap in kernel with 4 byte keys and 8 byte values

 * Load eBPF program

   The eBPF program accesses the map passed in to store two pieces of
   information. The number of invocations of the program, which maps
   to the number of packets received, is stored to key 0. Key 1 is
   incremented on each iteration by the number of bytes stored in
   the skb.

 * Detach any eBPF program previously attached to the cgroup

 * Attach the new program to the cgroup using BPF_PROG_ATTACH

 * Once a second, read map[0] and map[1] to see how many bytes and
   packets were seen on any socket of tasks in the given cgroup.

The program takes a cgroup path as 1st argument, and either "ingress"
or "egress" as 2nd. Optionally, "drop" can be passed as 3rd argument,
which will make the generated eBPF program return 0 instead of 1, so
the kernel will drop the packet.

libbpf gained two new wrappers for the new syscall commands.

Signed-off-by: Daniel Mack <daniel@zonque.org>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/Makefile            |   2 +
 samples/bpf/libbpf.c            |  21 ++++++
 samples/bpf/libbpf.h            |   3 +
 samples/bpf/test_cgrp2_attach.c | 147 ++++++++++++++++++++++++++++++++++++++++
 4 files changed, 173 insertions(+)
 create mode 100644 samples/bpf/test_cgrp2_attach.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 12b7304..e4cdc74 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -22,6 +22,7 @@ hostprogs-y += spintest
 hostprogs-y += map_perf_test
 hostprogs-y += test_overhead
 hostprogs-y += test_cgrp2_array_pin
+hostprogs-y += test_cgrp2_attach
 hostprogs-y += xdp1
 hostprogs-y += xdp2
 hostprogs-y += test_current_task_under_cgroup
@@ -49,6 +50,7 @@ spintest-objs := bpf_load.o libbpf.o spintest_user.o
 map_perf_test-objs := bpf_load.o libbpf.o map_perf_test_user.o
 test_overhead-objs := bpf_load.o libbpf.o test_overhead_user.o
 test_cgrp2_array_pin-objs := libbpf.o test_cgrp2_array_pin.o
+test_cgrp2_attach-objs := libbpf.o test_cgrp2_attach.o
 xdp1-objs := bpf_load.o libbpf.o xdp1_user.o
 # reuse xdp1 source intentionally
 xdp2-objs := bpf_load.o libbpf.o xdp1_user.o
diff --git a/samples/bpf/libbpf.c b/samples/bpf/libbpf.c
index 9969e35..9ce707b 100644
--- a/samples/bpf/libbpf.c
+++ b/samples/bpf/libbpf.c
@@ -104,6 +104,27 @@ int bpf_prog_load(enum bpf_prog_type prog_type,
 	return syscall(__NR_bpf, BPF_PROG_LOAD, &attr, sizeof(attr));
 }
 
+int bpf_prog_attach(int prog_fd, int target_fd, enum bpf_attach_type type)
+{
+	union bpf_attr attr = {
+		.target_fd = target_fd,
+		.attach_bpf_fd = prog_fd,
+		.attach_type = type,
+	};
+
+	return syscall(__NR_bpf, BPF_PROG_ATTACH, &attr, sizeof(attr));
+}
+
+int bpf_prog_detach(int target_fd, enum bpf_attach_type type)
+{
+	union bpf_attr attr = {
+		.target_fd = target_fd,
+		.attach_type = type,
+	};
+
+	return syscall(__NR_bpf, BPF_PROG_DETACH, &attr, sizeof(attr));
+}
+
 int bpf_obj_pin(int fd, const char *pathname)
 {
 	union bpf_attr attr = {
diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
index ac6edb6..d0a799a 100644
--- a/samples/bpf/libbpf.h
+++ b/samples/bpf/libbpf.h
@@ -15,6 +15,9 @@ int bpf_prog_load(enum bpf_prog_type prog_type,
 		  const struct bpf_insn *insns, int insn_len,
 		  const char *license, int kern_version);
 
+int bpf_prog_attach(int prog_fd, int attachable_fd, enum bpf_attach_type type);
+int bpf_prog_detach(int attachable_fd, enum bpf_attach_type type);
+
 int bpf_obj_pin(int fd, const char *pathname);
 int bpf_obj_get(const char *pathname);
 
diff --git a/samples/bpf/test_cgrp2_attach.c b/samples/bpf/test_cgrp2_attach.c
new file mode 100644
index 0000000..63ef208
--- /dev/null
+++ b/samples/bpf/test_cgrp2_attach.c
@@ -0,0 +1,147 @@
+/* eBPF example program:
+ *
+ * - Creates arraymap in kernel with 4 bytes keys and 8 byte values
+ *
+ * - Loads eBPF program
+ *
+ *   The eBPF program accesses the map passed in to store two pieces of
+ *   information. The number of invocations of the program, which maps
+ *   to the number of packets received, is stored to key 0. Key 1 is
+ *   incremented on each iteration by the number of bytes stored in
+ *   the skb.
+ *
+ * - Detaches any eBPF program previously attached to the cgroup
+ *
+ * - Attaches the new program to a cgroup using BPF_PROG_ATTACH
+ *
+ * - Every second, reads map[0] and map[1] to see how many bytes and
+ *   packets were seen on any socket of tasks in the given cgroup.
+ */
+
+#define _GNU_SOURCE
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <stddef.h>
+#include <string.h>
+#include <unistd.h>
+#include <assert.h>
+#include <errno.h>
+#include <fcntl.h>
+
+#include <linux/bpf.h>
+
+#include "libbpf.h"
+
+enum {
+	MAP_KEY_PACKETS,
+	MAP_KEY_BYTES,
+};
+
+static int prog_load(int map_fd, int verdict)
+{
+	struct bpf_insn prog[] = {
+		BPF_MOV64_REG(BPF_REG_6, BPF_REG_1), /* save r6 so it's not clobbered by BPF_CALL */
+
+		/* Count packets */
+		BPF_MOV64_IMM(BPF_REG_0, MAP_KEY_PACKETS), /* r0 = 0 */
+		BPF_STX_MEM(BPF_W, BPF_REG_10, BPF_REG_0, -4), /* *(u32 *)(fp - 4) = r0 */
+		BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+		BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -4), /* r2 = fp - 4 */
+		BPF_LD_MAP_FD(BPF_REG_1, map_fd), /* load map fd to r1 */
+		BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+		BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 2),
+		BPF_MOV64_IMM(BPF_REG_1, 1), /* r1 = 1 */
+		BPF_RAW_INSN(BPF_STX | BPF_XADD | BPF_DW, BPF_REG_0, BPF_REG_1, 0, 0), /* xadd r0 += r1 */
+
+		/* Count bytes */
+		BPF_MOV64_IMM(BPF_REG_0, MAP_KEY_BYTES), /* r0 = 1 */
+		BPF_STX_MEM(BPF_W, BPF_REG_10, BPF_REG_0, -4), /* *(u32 *)(fp - 4) = r0 */
+		BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+		BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -4), /* r2 = fp - 4 */
+		BPF_LD_MAP_FD(BPF_REG_1, map_fd),
+		BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+		BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 2),
+		BPF_LDX_MEM(BPF_W, BPF_REG_1, BPF_REG_6, offsetof(struct __sk_buff, len)), /* r1 = skb->len */
+		BPF_RAW_INSN(BPF_STX | BPF_XADD | BPF_DW, BPF_REG_0, BPF_REG_1, 0, 0), /* xadd r0 += r1 */
+
+		BPF_MOV64_IMM(BPF_REG_0, verdict), /* r0 = verdict */
+		BPF_EXIT_INSN(),
+	};
+
+	return bpf_prog_load(BPF_PROG_TYPE_CGROUP_SKB,
+			     prog, sizeof(prog), "GPL", 0);
+}
+
+static int usage(const char *argv0)
+{
+	printf("Usage: %s <cg-path> <egress|ingress> [drop]\n", argv0);
+	return EXIT_FAILURE;
+}
+
+int main(int argc, char **argv)
+{
+	int cg_fd, map_fd, prog_fd, key, ret;
+	long long pkt_cnt, byte_cnt;
+	enum bpf_attach_type type;
+	int verdict = 1;
+
+	if (argc < 3)
+		return usage(argv[0]);
+
+	if (strcmp(argv[2], "ingress") == 0)
+		type = BPF_CGROUP_INET_INGRESS;
+	else if (strcmp(argv[2], "egress") == 0)
+		type = BPF_CGROUP_INET_EGRESS;
+	else
+		return usage(argv[0]);
+
+	if (argc > 3 && strcmp(argv[3], "drop") == 0)
+		verdict = 0;
+
+	cg_fd = open(argv[1], O_DIRECTORY | O_RDONLY);
+	if (cg_fd < 0) {
+		printf("Failed to open cgroup path: '%s'\n", strerror(errno));
+		return EXIT_FAILURE;
+	}
+
+	map_fd = bpf_create_map(BPF_MAP_TYPE_ARRAY,
+				sizeof(key), sizeof(byte_cnt),
+				256, 0);
+	if (map_fd < 0) {
+		printf("Failed to create map: '%s'\n", strerror(errno));
+		return EXIT_FAILURE;
+	}
+
+	prog_fd = prog_load(map_fd, verdict);
+	printf("Output from kernel verifier:\n%s\n-------\n", bpf_log_buf);
+
+	if (prog_fd < 0) {
+		printf("Failed to load prog: '%s'\n", strerror(errno));
+		return EXIT_FAILURE;
+	}
+
+	ret = bpf_prog_detach(cg_fd, type);
+	printf("bpf_prog_detach() returned '%s' (%d)\n", strerror(errno), errno);
+
+	ret = bpf_prog_attach(prog_fd, cg_fd, type);
+	if (ret < 0) {
+		printf("Failed to attach prog to cgroup: '%s'\n",
+		       strerror(errno));
+		return EXIT_FAILURE;
+	}
+
+	while (1) {
+		key = MAP_KEY_PACKETS;
+		assert(bpf_lookup_elem(map_fd, &key, &pkt_cnt) == 0);
+
+		key = MAP_KEY_BYTES;
+		assert(bpf_lookup_elem(map_fd, &key, &byte_cnt) == 0);
+
+		printf("cgroup received %lld packets, %lld bytes\n",
+		       pkt_cnt, byte_cnt);
+		sleep(1);
+	}
+
+	return EXIT_SUCCESS;
+}
-- 
2.7.4
