From: Joe Stringer <joe@ovn.org>
Subject: [PATCHv2 perf/core 2/2] tools lib bpf: Sync with samples/bpf/libbpf
Date: Wed, 16 Nov 2016 09:43:24 -0800
Message-ID: <20161116174324.29675-3-joe@ovn.org>
References: <20161116174324.29675-1-joe@ovn.org>
Cc: netdev@vger.kernel.org, wangnan0@huawei.com, ast@fb.com,
        daniel@iogearbox.net, acme@kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:56852 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933386AbcKPRno (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 12:43:44 -0500
In-Reply-To: <20161116174324.29675-1-joe@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend the tools/ version of libbpf to include all of the functionality
provided in the samples/bpf version.

Signed-off-by: Joe Stringer <joe@ovn.org>
---
v2: Don't shift non-bpf changes across.
    Various type cleanups, removal of extraneous declarations
---
 tools/lib/bpf/bpf.c    | 107 ++++++++++++++++++++------
 tools/lib/bpf/bpf.h    | 202 +++++++++++++++++++++++++++++++++++++++++++++++--
 tools/lib/bpf/libbpf.c |   3 +-
 3 files changed, 279 insertions(+), 33 deletions(-)

diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
index 4212ed62235b..5e061851ac00 100644
--- a/tools/lib/bpf/bpf.c
+++ b/tools/lib/bpf/bpf.c
@@ -20,10 +20,17 @@
  */
 
 #include <stdlib.h>
-#include <memory.h>
+#include <stdio.h>
 #include <unistd.h>
 #include <asm/unistd.h>
+#include <string.h>
+#include <linux/netlink.h>
 #include <linux/bpf.h>
+#include <errno.h>
+#include <net/ethernet.h>
+#include <net/if.h>
+#include <linux/if_packet.h>
+#include <arpa/inet.h>
 #include "bpf.h"
 
 /*
@@ -53,24 +60,71 @@ static int sys_bpf(enum bpf_cmd cmd, union bpf_attr *attr,
 	return syscall(__NR_bpf, cmd, attr, size);
 }
 
-int bpf_create_map(enum bpf_map_type map_type, int key_size,
-		   int value_size, int max_entries)
+int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
+		   int max_entries, int map_flags)
 {
-	union bpf_attr attr;
+	union bpf_attr attr = {
+		.map_type = map_type,
+		.key_size = key_size,
+		.value_size = value_size,
+		.max_entries = max_entries,
+		.map_flags = map_flags,
+	};
 
-	memset(&attr, '\0', sizeof(attr));
+	return sys_bpf(BPF_MAP_CREATE, &attr, sizeof(attr));
+}
 
-	attr.map_type = map_type;
-	attr.key_size = key_size;
-	attr.value_size = value_size;
-	attr.max_entries = max_entries;
+int bpf_update_elem(int fd, void *key, void *value, unsigned long long flags)
+{
+	union bpf_attr attr = {
+		.map_fd = fd,
+		.key = ptr_to_u64(key),
+		.value = ptr_to_u64(value),
+		.flags = flags,
+	};
 
-	return sys_bpf(BPF_MAP_CREATE, &attr, sizeof(attr));
+	return sys_bpf(BPF_MAP_UPDATE_ELEM, &attr, sizeof(attr));
+}
+
+int bpf_lookup_elem(int fd, void *key, void *value)
+{
+	union bpf_attr attr = {
+		.map_fd = fd,
+		.key = ptr_to_u64(key),
+		.value = ptr_to_u64(value),
+	};
+
+	return sys_bpf(BPF_MAP_LOOKUP_ELEM, &attr, sizeof(attr));
+}
+
+int bpf_delete_elem(int fd, void *key)
+{
+	union bpf_attr attr = {
+		.map_fd = fd,
+		.key = ptr_to_u64(key),
+	};
+
+	return sys_bpf(BPF_MAP_DELETE_ELEM, &attr, sizeof(attr));
 }
 
-int bpf_load_program(enum bpf_prog_type type, struct bpf_insn *insns,
-		     size_t insns_cnt, char *license,
-		     u32 kern_version, char *log_buf, size_t log_buf_sz)
+int bpf_get_next_key(int fd, void *key, void *next_key)
+{
+	union bpf_attr attr = {
+		.map_fd = fd,
+		.key = ptr_to_u64(key),
+		.next_key = ptr_to_u64(next_key),
+	};
+
+	return sys_bpf(BPF_MAP_GET_NEXT_KEY, &attr, sizeof(attr));
+}
+
+#define ROUND_UP(x, n) (((x) + (n) - 1u) & ~((n) - 1u))
+
+
+int bpf_load_program(enum bpf_prog_type type,
+		     const struct bpf_insn *insns, int insns_cnt,
+		     const char *license, int kern_version,
+		     char *log_buf, size_t log_buf_sz)
 {
 	int fd;
 	union bpf_attr attr;
@@ -78,8 +132,8 @@ int bpf_load_program(enum bpf_prog_type type, struct bpf_insn *insns,
 	bzero(&attr, sizeof(attr));
 	attr.prog_type = type;
 	attr.insn_cnt = (__u32)insns_cnt;
-	attr.insns = ptr_to_u64(insns);
-	attr.license = ptr_to_u64(license);
+	attr.insns = ptr_to_u64((void *)insns);
+	attr.license = ptr_to_u64((void *)license);
 	attr.log_buf = ptr_to_u64(NULL);
 	attr.log_size = 0;
 	attr.log_level = 0;
@@ -97,16 +151,21 @@ int bpf_load_program(enum bpf_prog_type type, struct bpf_insn *insns,
 	return sys_bpf(BPF_PROG_LOAD, &attr, sizeof(attr));
 }
 
-int bpf_map_update_elem(int fd, void *key, void *value,
-			u64 flags)
+int bpf_obj_pin(int fd, const char *pathname)
 {
-	union bpf_attr attr;
+	union bpf_attr attr = {
+		.pathname	= ptr_to_u64((void *)pathname),
+		.bpf_fd		= fd,
+	};
 
-	bzero(&attr, sizeof(attr));
-	attr.map_fd = fd;
-	attr.key = ptr_to_u64(key);
-	attr.value = ptr_to_u64(value);
-	attr.flags = flags;
+	return sys_bpf(BPF_OBJ_PIN, &attr, sizeof(attr));
+}
 
-	return sys_bpf(BPF_MAP_UPDATE_ELEM, &attr, sizeof(attr));
+int bpf_obj_get(const char *pathname)
+{
+	union bpf_attr attr = {
+		.pathname	= ptr_to_u64((void *)pathname),
+	};
+
+	return sys_bpf(BPF_OBJ_GET, &attr, sizeof(attr));
 }
diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
index e8ba54087497..4dba36995771 100644
--- a/tools/lib/bpf/bpf.h
+++ b/tools/lib/bpf/bpf.h
@@ -23,16 +23,202 @@
 
 #include <linux/bpf.h>
 
+struct bpf_insn;
+
 int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
-		   int max_entries);
+		   int max_entries, int map_flags);
+int bpf_update_elem(int fd, void *key, void *value, unsigned long long flags);
+int bpf_lookup_elem(int fd, void *key, void *value);
+int bpf_delete_elem(int fd, void *key);
+int bpf_get_next_key(int fd, void *key, void *next_key);
+
+int bpf_load_program(enum bpf_prog_type prog_type,
+		     const struct bpf_insn *insns, int insn_len,
+		     const char *license, int kern_version,
+		     char *log_buf, size_t log_buf_sz);
+
+int bpf_obj_pin(int fd, const char *pathname);
+int bpf_obj_get(const char *pathname);
 
-/* Recommend log buffer size */
 #define BPF_LOG_BUF_SIZE 65536
-int bpf_load_program(enum bpf_prog_type type, struct bpf_insn *insns,
-		     size_t insns_cnt, char *license,
-		     u32 kern_version, char *log_buf,
-		     size_t log_buf_sz);
 
-int bpf_map_update_elem(int fd, void *key, void *value,
-			u64 flags);
+/* ALU ops on registers, bpf_add|sub|...: dst_reg += src_reg */
+
+#define BPF_ALU64_REG(OP, DST, SRC)				\
+	((struct bpf_insn) {					\
+		.code  = BPF_ALU64 | BPF_OP(OP) | BPF_X,	\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = 0,					\
+		.imm   = 0 })
+
+#define BPF_ALU32_REG(OP, DST, SRC)				\
+	((struct bpf_insn) {					\
+		.code  = BPF_ALU | BPF_OP(OP) | BPF_X,		\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = 0,					\
+		.imm   = 0 })
+
+/* ALU ops on immediates, bpf_add|sub|...: dst_reg += imm32 */
+
+#define BPF_ALU64_IMM(OP, DST, IMM)				\
+	((struct bpf_insn) {					\
+		.code  = BPF_ALU64 | BPF_OP(OP) | BPF_K,	\
+		.dst_reg = DST,					\
+		.src_reg = 0,					\
+		.off   = 0,					\
+		.imm   = IMM })
+
+#define BPF_ALU32_IMM(OP, DST, IMM)				\
+	((struct bpf_insn) {					\
+		.code  = BPF_ALU | BPF_OP(OP) | BPF_K,		\
+		.dst_reg = DST,					\
+		.src_reg = 0,					\
+		.off   = 0,					\
+		.imm   = IMM })
+
+/* Short form of mov, dst_reg = src_reg */
+
+#define BPF_MOV64_REG(DST, SRC)					\
+	((struct bpf_insn) {					\
+		.code  = BPF_ALU64 | BPF_MOV | BPF_X,		\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = 0,					\
+		.imm   = 0 })
+
+#define BPF_MOV32_REG(DST, SRC)					\
+	((struct bpf_insn) {					\
+		.code  = BPF_ALU | BPF_MOV | BPF_X,		\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = 0,					\
+		.imm   = 0 })
+
+/* Short form of mov, dst_reg = imm32 */
+
+#define BPF_MOV64_IMM(DST, IMM)					\
+	((struct bpf_insn) {					\
+		.code  = BPF_ALU64 | BPF_MOV | BPF_K,		\
+		.dst_reg = DST,					\
+		.src_reg = 0,					\
+		.off   = 0,					\
+		.imm   = IMM })
+
+#define BPF_MOV32_IMM(DST, IMM)					\
+	((struct bpf_insn) {					\
+		.code  = BPF_ALU | BPF_MOV | BPF_K,		\
+		.dst_reg = DST,					\
+		.src_reg = 0,					\
+		.off   = 0,					\
+		.imm   = IMM })
+
+/* BPF_LD_IMM64 macro encodes single 'load 64-bit immediate' insn */
+#define BPF_LD_IMM64(DST, IMM)					\
+	BPF_LD_IMM64_RAW(DST, 0, IMM)
+
+#define BPF_LD_IMM64_RAW(DST, SRC, IMM)				\
+	((struct bpf_insn) {					\
+		.code  = BPF_LD | BPF_DW | BPF_IMM,		\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = 0,					\
+		.imm   = (__u32) (IMM) }),			\
+	((struct bpf_insn) {					\
+		.code  = 0, /* zero is reserved opcode */	\
+		.dst_reg = 0,					\
+		.src_reg = 0,					\
+		.off   = 0,					\
+		.imm   = ((__u64) (IMM)) >> 32 })
+
+#ifndef BPF_PSEUDO_MAP_FD
+# define BPF_PSEUDO_MAP_FD	1
+#endif
+
+/* pseudo BPF_LD_IMM64 insn used to refer to process-local map_fd */
+#define BPF_LD_MAP_FD(DST, MAP_FD)				\
+	BPF_LD_IMM64_RAW(DST, BPF_PSEUDO_MAP_FD, MAP_FD)
+
+
+/* Direct packet access, R0 = *(uint *) (skb->data + imm32) */
+
+#define BPF_LD_ABS(SIZE, IMM)					\
+	((struct bpf_insn) {					\
+		.code  = BPF_LD | BPF_SIZE(SIZE) | BPF_ABS,	\
+		.dst_reg = 0,					\
+		.src_reg = 0,					\
+		.off   = 0,					\
+		.imm   = IMM })
+
+/* Memory load, dst_reg = *(uint *) (src_reg + off16) */
+
+#define BPF_LDX_MEM(SIZE, DST, SRC, OFF)			\
+	((struct bpf_insn) {					\
+		.code  = BPF_LDX | BPF_SIZE(SIZE) | BPF_MEM,	\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = OFF,					\
+		.imm   = 0 })
+
+/* Memory store, *(uint *) (dst_reg + off16) = src_reg */
+
+#define BPF_STX_MEM(SIZE, DST, SRC, OFF)			\
+	((struct bpf_insn) {					\
+		.code  = BPF_STX | BPF_SIZE(SIZE) | BPF_MEM,	\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = OFF,					\
+		.imm   = 0 })
+
+/* Memory store, *(uint *) (dst_reg + off16) = imm32 */
+
+#define BPF_ST_MEM(SIZE, DST, OFF, IMM)				\
+	((struct bpf_insn) {					\
+		.code  = BPF_ST | BPF_SIZE(SIZE) | BPF_MEM,	\
+		.dst_reg = DST,					\
+		.src_reg = 0,					\
+		.off   = OFF,					\
+		.imm   = IMM })
+
+/* Conditional jumps against registers, if (dst_reg 'op' src_reg) goto pc + off16 */
+
+#define BPF_JMP_REG(OP, DST, SRC, OFF)				\
+	((struct bpf_insn) {					\
+		.code  = BPF_JMP | BPF_OP(OP) | BPF_X,		\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = OFF,					\
+		.imm   = 0 })
+
+/* Conditional jumps against immediates, if (dst_reg 'op' imm32) goto pc + off16 */
+
+#define BPF_JMP_IMM(OP, DST, IMM, OFF)				\
+	((struct bpf_insn) {					\
+		.code  = BPF_JMP | BPF_OP(OP) | BPF_K,		\
+		.dst_reg = DST,					\
+		.src_reg = 0,					\
+		.off   = OFF,					\
+		.imm   = IMM })
+
+/* Raw code statement block */
+
+#define BPF_RAW_INSN(CODE, DST, SRC, OFF, IMM)			\
+	((struct bpf_insn) {					\
+		.code  = CODE,					\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = OFF,					\
+		.imm   = IMM })
+
+/* Program exit */
+
+#define BPF_EXIT_INSN()						\
+	((struct bpf_insn) {					\
+		.code  = BPF_JMP | BPF_EXIT,			\
+		.dst_reg = 0,					\
+		.src_reg = 0,					\
+		.off   = 0,					\
+		.imm   = 0 })
+
 #endif
diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
index b699aea9a025..951e11023554 100644
--- a/tools/lib/bpf/libbpf.c
+++ b/tools/lib/bpf/libbpf.c
@@ -796,7 +796,8 @@ bpf_object__create_maps(struct bpf_object *obj)
 		*pfd = bpf_create_map(def->type,
 				      def->key_size,
 				      def->value_size,
-				      def->max_entries);
+				      def->max_entries,
+				      0);
 		if (*pfd < 0) {
 			size_t j;
 			int err = *pfd;
-- 
2.9.3
