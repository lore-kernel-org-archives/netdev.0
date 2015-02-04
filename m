From: Andy Zhou <azhou@nicira.com>
Subject: [RFC: add openvswitch actions using BPF 6/9] lib: import into libbpf to ovs/lib
Date: Wed,  4 Feb 2015 14:49:20 -0800
Message-ID: <1423090163-19902-7-git-send-email-azhou@nicira.com>
References: <1423090163-19902-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: dev@openvswitch.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog106.obsmtp.com ([74.125.149.77]:50725 "HELO
	na3sys009aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1161227AbbBDXSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 18:18:52 -0500
Received: by mail-pa0-f49.google.com with SMTP id fa1so5753370pad.8
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 15:18:51 -0800 (PST)
In-Reply-To: <1423090163-19902-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Those files are basically imported from 'net-next: sample/bpf'
directory.  This is a stop gap measure unil libbpf is upstreamed.

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 lib/automake.mk |  22 +++++++
 lib/libbpf.c    | 100 ++++++++++++++++++++++++++++++
 lib/libbpf.h    | 185 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 307 insertions(+)
 create mode 100644 lib/libbpf.c
 create mode 100644 lib/libbpf.h

diff --git a/lib/automake.mk b/lib/automake.mk
index 2a5844b..d9488c0 100644
--- a/lib/automake.mk
+++ b/lib/automake.mk
@@ -317,6 +317,28 @@ lib_libsflow_la_CFLAGS += -Wno-unused-parameter
 endif
 
 if LINUX
+lib_LTLIBRARIES += lib/libbpf.la
+lib_libbpf_la_LDFLAGS = \
+        -version-info $(LT_CURRENT):$(LT_REVISION):$(LT_AGE) \
+	-Wl,--version-script=$(top_builddir)/lib/libbpf.sym \
+        $(AM_LDFLAGS)
+lib_libbpf_la_SOURCES = \
+	lib/libbpf.h \
+	lib/libbpf.c
+lib_libbpf_la_CPPFLAGS = $(AM_CPPFLAGS)
+# GCC Bug 60784 affects both GCC 4.8 and GCC 4.9. -Wmissing-field-initializers will
+# give spurious warning when compiling libbpf. Turn it off for now.
+lib_libbpf_la_CFLAGS = $(filter-out -Wmissing-field-initializers, $(AM_CFLAGS))
+lib_libbpf_la_CFLAGS += -Wno-missing-field-initializers
+if HAVE_WNO_UNUSED
+lib_libbpf_la_CFLAGS += -Wno-unused
+endif
+if HAVE_WNO_UNUSED_PARAMETER
+lib_libbpf_la_CFLAGS += -Wno-unused-parameter
+endif
+endif
+
+if LINUX
 lib_libopenvswitch_la_SOURCES += \
 	lib/dpif-netlink.c \
 	lib/dpif-netlink.h \
diff --git a/lib/libbpf.c b/lib/libbpf.c
new file mode 100644
index 0000000..045bdba
--- /dev/null
+++ b/lib/libbpf.c
@@ -0,0 +1,100 @@
+/* eBPF mini library */
+#include <stdlib.h>
+#include <stdio.h>
+#include <linux/unistd.h>
+#include <unistd.h>
+#include <string.h>
+#include <linux/bpf.h>
+#include <errno.h>
+#include <net/ethernet.h>
+#include <net/if.h>
+#include <linux/if_packet.h>
+#include <arpa/inet.h>
+#include "libbpf.h"
+
+#include <config.h>
+
+static __u64 ptr_to_u64(void *ptr)
+{
+    return (__u64) (unsigned long) ptr;
+}
+
+int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
+                   int max_entries)
+{
+    union bpf_attr attr = {
+        .map_type = map_type,
+        .key_size = key_size,
+        .value_size = value_size,
+        .max_entries = max_entries,
+    };
+
+    return syscall(__NR_bpf, BPF_MAP_CREATE, &attr, sizeof(attr));
+}
+
+int bpf_update_elem(int fd, void *key, void *value, unsigned long long flags)
+{
+    union bpf_attr attr = {
+        .map_fd = fd,
+        .key = ptr_to_u64(key),
+        .value = ptr_to_u64(value),
+        .flags = flags,
+    };
+
+    return syscall(__NR_bpf, BPF_MAP_UPDATE_ELEM, &attr, sizeof(attr));
+}
+
+int bpf_lookup_elem(int fd, void *key, void *value)
+{
+    union bpf_attr attr = {
+        .map_fd = fd,
+        .key = ptr_to_u64(key),
+        .value = ptr_to_u64(value),
+    };
+
+    return syscall(__NR_bpf, BPF_MAP_LOOKUP_ELEM, &attr, sizeof(attr));
+}
+
+int bpf_delete_elem(int fd, void *key)
+{
+    union bpf_attr attr = {
+        .map_fd = fd,
+        .key = ptr_to_u64(key),
+    };
+
+    return syscall(__NR_bpf, BPF_MAP_DELETE_ELEM, &attr, sizeof(attr));
+}
+
+int bpf_get_next_key(int fd, void *key, void *next_key)
+{
+    union bpf_attr attr = {
+        .map_fd = fd,
+        .key = ptr_to_u64(key),
+        .next_key = ptr_to_u64(next_key),
+    };
+
+    return syscall(__NR_bpf, BPF_MAP_GET_NEXT_KEY, &attr, sizeof(attr));
+}
+
+#define ROUND_UP(x, n) (((x) + (n) - 1u) & ~((n) - 1u))
+
+char bpf_log_buf[LOG_BUF_SIZE];
+
+int bpf_prog_load(enum bpf_prog_type prog_type,
+          const struct bpf_insn *insns, int prog_len,
+          const char *license)
+{
+    union bpf_attr attr = {
+        .prog_type = prog_type,
+        .insns = ptr_to_u64((void *) insns),
+        .insn_cnt = prog_len / sizeof(struct bpf_insn),
+        .license = ptr_to_u64((void *) license),
+        .log_buf = ptr_to_u64(bpf_log_buf),
+        .log_size = LOG_BUF_SIZE,
+        .log_level = 1,
+    };
+
+    bpf_log_buf[0] = 0;
+
+    return syscall(__NR_bpf, BPF_PROG_LOAD, &attr, sizeof(attr));
+}
diff --git a/lib/libbpf.h b/lib/libbpf.h
new file mode 100644
index 0000000..fe6f31e
--- /dev/null
+++ b/lib/libbpf.h
@@ -0,0 +1,185 @@
+/* eBPF mini library */
+#ifndef __LIBBPF_H
+#define __LIBBPF_H
+
+struct bpf_insn;
+
+int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
+           int max_entries);
+int bpf_update_elem(int fd, void *key, void *value, unsigned long long flags);
+int bpf_lookup_elem(int fd, void *key, void *value);
+int bpf_delete_elem(int fd, void *key);
+int bpf_get_next_key(int fd, void *key, void *next_key);
+
+int bpf_prog_load(enum bpf_prog_type prog_type,
+          const struct bpf_insn *insns, int insn_len,
+          const char *license);
+
+#define LOG_BUF_SIZE 65536
+extern char bpf_log_buf[LOG_BUF_SIZE];
+
+/* ALU ops on registers, bpf_add|sub|...: dst_reg += src_reg */
+
+#define BPF_ALU64_REG(OP, DST, SRC)             \
+    ((struct bpf_insn) {                    \
+        .code  = BPF_ALU64 | BPF_OP(OP) | BPF_X,    \
+        .dst_reg = DST,                 \
+        .src_reg = SRC,                 \
+        .off   = 0,                 \
+        .imm   = 0 })
+
+#define BPF_ALU32_REG(OP, DST, SRC)             \
+    ((struct bpf_insn) {                    \
+        .code  = BPF_ALU | BPF_OP(OP) | BPF_X,      \
+        .dst_reg = DST,                 \
+        .src_reg = SRC,                 \
+        .off   = 0,                 \
+        .imm   = 0 })
+
+/* ALU ops on immediates, bpf_add|sub|...: dst_reg += imm32 */
+
+#define BPF_ALU64_IMM(OP, DST, IMM)             \
+    ((struct bpf_insn) {                    \
+        .code  = BPF_ALU64 | BPF_OP(OP) | BPF_K,    \
+        .dst_reg = DST,                 \
+        .src_reg = 0,                   \
+        .off   = 0,                 \
+        .imm   = IMM })
+
+#define BPF_ALU32_IMM(OP, DST, IMM)             \
+    ((struct bpf_insn) {                    \
+        .code  = BPF_ALU | BPF_OP(OP) | BPF_K,      \
+        .dst_reg = DST,                 \
+        .src_reg = 0,                   \
+        .off   = 0,                 \
+        .imm   = IMM })
+
+/* Short form of mov, dst_reg = src_reg */
+
+#define BPF_MOV64_REG(DST, SRC)                 \
+    ((struct bpf_insn) {                    \
+        .code  = BPF_ALU64 | BPF_MOV | BPF_X,       \
+        .dst_reg = DST,                 \
+        .src_reg = SRC,                 \
+        .off   = 0,                 \
+        .imm   = 0 })
+
+/* Short form of mov, dst_reg = imm32 */
+
+#define BPF_MOV64_IMM(DST, IMM)                 \
+    ((struct bpf_insn) {                    \
+        .code  = BPF_ALU64 | BPF_MOV | BPF_K,       \
+        .dst_reg = DST,                 \
+        .src_reg = 0,                   \
+        .off   = 0,                 \
+        .imm   = IMM })
+
+/* BPF_LD_IMM64 macro encodes single 'load 64-bit immediate' insn */
+#define BPF_LD_IMM64(DST, IMM)                  \
+    BPF_LD_IMM64_RAW(DST, 0, IMM)
+
+#define BPF_LD_IMM64_RAW(DST, SRC, IMM)             \
+    ((struct bpf_insn) {                    \
+        .code  = BPF_LD | BPF_DW | BPF_IMM,     \
+        .dst_reg = DST,                 \
+        .src_reg = SRC,                 \
+        .off   = 0,                 \
+        .imm   = (__u32) (IMM) }),          \
+    ((struct bpf_insn) {                    \
+        .code  = 0, /* zero is reserved opcode */   \
+        .dst_reg = 0,                   \
+        .src_reg = 0,                   \
+        .off   = 0,                 \
+        .imm   = ((__u64) (IMM)) >> 32 })
+
+#define BPF_PSEUDO_MAP_FD   1
+
+/* pseudo BPF_LD_IMM64 insn used to refer to process-local map_fd */
+#define BPF_LD_MAP_FD(DST, MAP_FD)              \
+    BPF_LD_IMM64_RAW(DST, BPF_PSEUDO_MAP_FD, MAP_FD)
+
+
+/* Direct packet access, R0 = *(uint *) (skb->data + imm32) */
+
+#define BPF_LD_ABS(SIZE, IMM)                   \
+    ((struct bpf_insn) {                    \
+        .code  = BPF_LD | BPF_SIZE(SIZE) | BPF_ABS, \
+        .dst_reg = 0,                   \
+        .src_reg = 0,                   \
+        .off   = 0,                 \
+        .imm   = IMM })
+
+/* Memory load, dst_reg = *(uint *) (src_reg + off16) */
+
+#define BPF_LDX_MEM(SIZE, DST, SRC, OFF)            \
+    ((struct bpf_insn) {                    \
+        .code  = BPF_LDX | BPF_SIZE(SIZE) | BPF_MEM,    \
+        .dst_reg = DST,                 \
+        .src_reg = SRC,                 \
+        .off   = OFF,                   \
+        .imm   = 0 })
+
+/* Memory store, *(uint *) (dst_reg + off16) = src_reg */
+
+#define BPF_STX_MEM(SIZE, DST, SRC, OFF)            \
+    ((struct bpf_insn) {                    \
+        .code  = BPF_STX | BPF_SIZE(SIZE) | BPF_MEM,    \
+        .dst_reg = DST,                 \
+        .src_reg = SRC,                 \
+        .off   = OFF,                   \
+        .imm   = 0 })
+
+/* Memory store, *(uint *) (dst_reg + off16) = imm32 */
+
+#define BPF_ST_MEM(SIZE, DST, OFF, IMM)             \
+    ((struct bpf_insn) {                    \
+        .code  = BPF_ST | BPF_SIZE(SIZE) | BPF_MEM, \
+        .dst_reg = DST,                 \
+        .src_reg = 0,                   \
+        .off   = OFF,                   \
+        .imm   = IMM })
+
+/* Conditional jumps against registers, if (dst_reg 'op' src_reg) goto pc + off16 */
+
+#define BPF_JMP_REG(OP, DST, SRC, OFF)              \
+    ((struct bpf_insn) {                    \
+        .code  = BPF_JMP | BPF_OP(OP) | BPF_X,      \
+        .dst_reg = DST,                 \
+        .src_reg = SRC,                 \
+        .off   = OFF,                   \
+        .imm   = 0 })
+
+/* Conditional jumps against immediates, if (dst_reg 'op' imm32) goto pc + off16 */
+
+#define BPF_JMP_IMM(OP, DST, IMM, OFF)              \
+    ((struct bpf_insn) {                    \
+        .code  = BPF_JMP | BPF_OP(OP) | BPF_K,      \
+        .dst_reg = DST,                 \
+        .src_reg = 0,                   \
+        .off   = OFF,                   \
+        .imm   = IMM })
+
+/* Raw code statement block */
+
+#define BPF_RAW_INSN(CODE, DST, SRC, OFF, IMM)          \
+    ((struct bpf_insn) {                    \
+        .code  = CODE,                  \
+        .dst_reg = DST,                 \
+        .src_reg = SRC,                 \
+        .off   = OFF,                   \
+        .imm   = IMM })
+
+/* Program exit */
+
+#define BPF_EXIT_INSN()                     \
+    ((struct bpf_insn) {                    \
+        .code  = BPF_JMP | BPF_EXIT,            \
+        .dst_reg = 0,                   \
+        .src_reg = 0,                   \
+        .off   = 0,                 \
+        .imm   = 0 })
+
+/* create RAW socket and bind to interface 'name' */
+int open_raw_sock(const char *name);
+
+#endif
-- 
1.9.1
