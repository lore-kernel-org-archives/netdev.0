From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v11 net-next 12/12] bpf: mini eBPF library, test stubs and verifier testsuite
Date: Tue,  9 Sep 2014 22:10:08 -0700
Message-ID: <1410325808-3657-13-git-send-email-ast@plumgrid.com>
References: <1410325808-3657-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linuxfoundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410325808-3657-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

1.
the library includes a trivial set of BPF syscall wrappers:
int bpf_create_map(int key_size, int value_size, int max_entries);
int bpf_update_elem(int fd, void *key, void *value);
int bpf_lookup_elem(int fd, void *key, void *value);
int bpf_delete_elem(int fd, void *key);
int bpf_get_next_key(int fd, void *key, void *next_key);
int bpf_prog_load(enum bpf_prog_type prog_type,
		  const struct sock_filter_int *insns, int insn_len,
		  const char *license);
bpf_prog_load() stores verifier log into global bpf_log_buf[] array

2.
test stubs configure eBPF infra with 'unspec' map and program types.
These are fake types used by user space testsuite only.

3.
verifier tests valid and invalid programs and expects predefined
error log messages from kernel.
40 tests so far.

$ sudo ./test_verifier
 #0 add+sub+mul OK
 #1 unreachable OK
 #2 unreachable2 OK
 #3 out of range jump OK
 #4 out of range jump2 OK
 #5 test1 ld_imm64 OK
 ...

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 kernel/bpf/Makefile         |    4 +
 kernel/bpf/test_stub.c      |  109 +++++++++
 lib/Kconfig.debug           |    3 +-
 samples/bpf/Makefile        |   12 +
 samples/bpf/libbpf.c        |   89 +++++++
 samples/bpf/libbpf.h        |   21 ++
 samples/bpf/test_verifier.c |  548 +++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 785 insertions(+), 1 deletion(-)
 create mode 100644 kernel/bpf/test_stub.c
 create mode 100644 samples/bpf/Makefile
 create mode 100644 samples/bpf/libbpf.c
 create mode 100644 samples/bpf/libbpf.h
 create mode 100644 samples/bpf/test_verifier.c

diff --git a/kernel/bpf/Makefile b/kernel/bpf/Makefile
index 3c726b0995b7..45427239f375 100644
--- a/kernel/bpf/Makefile
+++ b/kernel/bpf/Makefile
@@ -1 +1,5 @@
 obj-y := core.o syscall.o verifier.o
+
+ifdef CONFIG_TEST_BPF
+obj-y += test_stub.o
+endif
diff --git a/kernel/bpf/test_stub.c b/kernel/bpf/test_stub.c
new file mode 100644
index 000000000000..d76ed2c2fe4d
--- /dev/null
+++ b/kernel/bpf/test_stub.c
@@ -0,0 +1,109 @@
+/* Copyright (c) 2011-2014 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/bpf.h>
+
+/* test stubs for BPF_MAP_TYPE_UNSPEC and for BPF_PROG_TYPE_UNSPEC
+ * to be used by user space verifier testsuite
+ */
+struct bpf_context {
+	u64 arg1;
+	u64 arg2;
+};
+
+static u64 test_func(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	return 0;
+}
+
+static struct bpf_func_proto test_funcs[] = {
+	[BPF_FUNC_unspec] = {
+		.func = test_func,
+		.gpl_only = true,
+		.ret_type = RET_PTR_TO_MAP_VALUE_OR_NULL,
+		.arg1_type = ARG_CONST_MAP_PTR,
+		.arg2_type = ARG_PTR_TO_MAP_KEY,
+	},
+};
+
+static const struct bpf_func_proto *test_func_proto(enum bpf_func_id func_id)
+{
+	if (func_id < 0 || func_id >= ARRAY_SIZE(test_funcs))
+		return NULL;
+	return &test_funcs[func_id];
+}
+
+static const struct bpf_context_access {
+	int size;
+	enum bpf_access_type type;
+} test_ctx_access[] = {
+	[offsetof(struct bpf_context, arg1)] = {
+		FIELD_SIZEOF(struct bpf_context, arg1),
+		BPF_READ
+	},
+	[offsetof(struct bpf_context, arg2)] = {
+		FIELD_SIZEOF(struct bpf_context, arg2),
+		BPF_READ
+	},
+};
+
+static bool test_is_valid_access(int off, int size, enum bpf_access_type type)
+{
+	const struct bpf_context_access *access;
+
+	if (off < 0 || off >= ARRAY_SIZE(test_ctx_access))
+		return false;
+
+	access = &test_ctx_access[off];
+	if (access->size == size && (access->type & type))
+		return true;
+
+	return false;
+}
+
+static struct bpf_verifier_ops test_ops = {
+	.get_func_proto = test_func_proto,
+	.is_valid_access = test_is_valid_access,
+};
+
+static struct bpf_prog_type_list tl_prog = {
+	.ops = &test_ops,
+	.type = BPF_PROG_TYPE_UNSPEC,
+};
+
+static struct bpf_map *test_map_alloc(union bpf_attr *attr)
+{
+	static struct bpf_map map;
+
+	map.key_size = attr->key_size;
+	map.value_size = attr->value_size;
+	map.max_entries = attr->max_entries;
+	return &map;
+}
+
+static void test_map_free(struct bpf_map *map)
+{
+}
+
+static struct bpf_map_ops test_map_ops = {
+	.map_alloc = test_map_alloc,
+	.map_free = test_map_free,
+};
+
+static struct bpf_map_type_list tl_map = {
+	.ops = &test_map_ops,
+	.type = BPF_MAP_TYPE_UNSPEC,
+};
+
+static int __init register_test_ops(void)
+{
+	bpf_register_map_type(&tl_map);
+	bpf_register_prog_type(&tl_prog);
+	return 0;
+}
+late_initcall(register_test_ops);
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index a28590083622..3ac43f34437b 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1672,7 +1672,8 @@ config TEST_BPF
 	  against the BPF interpreter or BPF JIT compiler depending on the
 	  current setting. This is in particular useful for BPF JIT compiler
 	  development, but also to run regression tests against changes in
-	  the interpreter code.
+	  the interpreter code. It also enables test stubs for eBPF maps and
+	  verifier used by user space verifier testsuite.
 
 	  If unsure, say N.
 
diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
new file mode 100644
index 000000000000..634391797856
--- /dev/null
+++ b/samples/bpf/Makefile
@@ -0,0 +1,12 @@
+# kbuild trick to avoid linker error. Can be omitted if a module is built.
+obj- := dummy.o
+
+# List of programs to build
+hostprogs-y := test_verifier
+
+test_verifier-objs := test_verifier.o libbpf.o
+
+# Tell kbuild to always build the programs
+always := $(hostprogs-y)
+
+HOSTCFLAGS += -I$(objtree)/usr/include
diff --git a/samples/bpf/libbpf.c b/samples/bpf/libbpf.c
new file mode 100644
index 000000000000..cae0c734274c
--- /dev/null
+++ b/samples/bpf/libbpf.c
@@ -0,0 +1,89 @@
+/* eBPF mini library */
+#include <stdlib.h>
+#include <stdio.h>
+#include <linux/unistd.h>
+#include <unistd.h>
+#include <string.h>
+#include <linux/netlink.h>
+#include <linux/bpf.h>
+#include <errno.h>
+#include "libbpf.h"
+
+int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
+		   int max_entries)
+{
+	union bpf_attr attr = {
+		.map_type = map_type,
+		.key_size = key_size,
+		.value_size = value_size,
+		.max_entries = max_entries
+	};
+
+	return syscall(__NR_bpf, BPF_MAP_CREATE, &attr, sizeof(attr));
+}
+
+int bpf_update_elem(int fd, void *key, void *value)
+{
+	union bpf_attr attr = {
+		.map_fd = fd,
+		.key = key,
+		.value = value,
+	};
+
+	return syscall(__NR_bpf, BPF_MAP_UPDATE_ELEM, &attr, sizeof(attr));
+}
+
+int bpf_lookup_elem(int fd, void *key, void *value)
+{
+	union bpf_attr attr = {
+		.map_fd = fd,
+		.key = key,
+		.value = value,
+	};
+
+	return syscall(__NR_bpf, BPF_MAP_LOOKUP_ELEM, &attr, sizeof(attr));
+}
+
+int bpf_delete_elem(int fd, void *key)
+{
+	union bpf_attr attr = {
+		.map_fd = fd,
+		.key = key,
+	};
+
+	return syscall(__NR_bpf, BPF_MAP_DELETE_ELEM, &attr, sizeof(attr));
+}
+
+int bpf_get_next_key(int fd, void *key, void *next_key)
+{
+	union bpf_attr attr = {
+		.map_fd = fd,
+		.key = key,
+		.next_key = next_key,
+	};
+
+	return syscall(__NR_bpf, BPF_MAP_GET_NEXT_KEY, &attr, sizeof(attr));
+}
+
+#define ROUND_UP(x, n) (((x) + (n) - 1u) & ~((n) - 1u))
+
+char bpf_log_buf[LOG_BUF_SIZE];
+
+int bpf_prog_load(enum bpf_prog_type prog_type,
+		  const struct bpf_insn *insns, int prog_len,
+		  const char *license)
+{
+	union bpf_attr attr = {
+		.prog_type = prog_type,
+		.insns = insns,
+		.insn_cnt = prog_len / sizeof(struct bpf_insn),
+		.license = license,
+		.log_buf = bpf_log_buf,
+		.log_size = LOG_BUF_SIZE,
+		.log_level = 1,
+	};
+
+	bpf_log_buf[0] = 0;
+
+	return syscall(__NR_bpf, BPF_PROG_LOAD, &attr, sizeof(attr));
+}
diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
new file mode 100644
index 000000000000..b19e39794291
--- /dev/null
+++ b/samples/bpf/libbpf.h
@@ -0,0 +1,21 @@
+/* eBPF mini library */
+#ifndef __LIBBPF_H
+#define __LIBBPF_H
+
+struct bpf_insn;
+
+int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
+		   int max_entries);
+int bpf_update_elem(int fd, void *key, void *value);
+int bpf_lookup_elem(int fd, void *key, void *value);
+int bpf_delete_elem(int fd, void *key);
+int bpf_get_next_key(int fd, void *key, void *next_key);
+
+int bpf_prog_load(enum bpf_prog_type prog_type,
+		  const struct bpf_insn *insns, int insn_len,
+		  const char *license);
+
+#define LOG_BUF_SIZE 8192
+extern char bpf_log_buf[LOG_BUF_SIZE];
+
+#endif
diff --git a/samples/bpf/test_verifier.c b/samples/bpf/test_verifier.c
new file mode 100644
index 000000000000..d10992e2740e
--- /dev/null
+++ b/samples/bpf/test_verifier.c
@@ -0,0 +1,548 @@
+/*
+ * Testsuite for eBPF verifier
+ *
+ * Copyright (c) 2014 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <stdio.h>
+#include <unistd.h>
+#include <linux/bpf.h>
+#include <errno.h>
+#include <linux/unistd.h>
+#include <string.h>
+#include <linux/filter.h>
+#include "libbpf.h"
+
+#define MAX_INSNS 512
+#define ARRAY_SIZE(x) (sizeof(x) / sizeof(*(x)))
+
+struct bpf_test {
+	const char *descr;
+	struct bpf_insn	insns[MAX_INSNS];
+	int fixup[32];
+	const char *errstr;
+	enum {
+		ACCEPT,
+		REJECT
+	} result;
+};
+
+static struct bpf_test tests[] = {
+	{
+		"add+sub+mul",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_1, 1),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 2),
+			BPF_MOV64_IMM(BPF_REG_2, 3),
+			BPF_ALU64_REG(BPF_SUB, BPF_REG_1, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -1),
+			BPF_ALU64_IMM(BPF_MUL, BPF_REG_1, 3),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_1),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+	},
+	{
+		"unreachable",
+		.insns = {
+			BPF_EXIT_INSN(),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "unreachable",
+		.result = REJECT,
+	},
+	{
+		"unreachable2",
+		.insns = {
+			BPF_JMP_IMM(BPF_JA, 0, 0, 1),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "unreachable",
+		.result = REJECT,
+	},
+	{
+		"out of range jump",
+		.insns = {
+			BPF_JMP_IMM(BPF_JA, 0, 0, 1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "jump out of range",
+		.result = REJECT,
+	},
+	{
+		"out of range jump2",
+		.insns = {
+			BPF_JMP_IMM(BPF_JA, 0, 0, -2),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "jump out of range",
+		.result = REJECT,
+	},
+	{
+		"test1 ld_imm64",
+		.insns = {
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 1),
+			BPF_LD_IMM64(BPF_REG_0, 0),
+			BPF_LD_IMM64(BPF_REG_0, 0),
+			BPF_LD_IMM64(BPF_REG_0, 1),
+			BPF_LD_IMM64(BPF_REG_0, 1),
+			BPF_MOV64_IMM(BPF_REG_0, 2),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid BPF_LD_IMM insn",
+		.result = REJECT,
+	},
+	{
+		"test2 ld_imm64",
+		.insns = {
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 1),
+			BPF_LD_IMM64(BPF_REG_0, 0),
+			BPF_LD_IMM64(BPF_REG_0, 0),
+			BPF_LD_IMM64(BPF_REG_0, 1),
+			BPF_LD_IMM64(BPF_REG_0, 1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid BPF_LD_IMM insn",
+		.result = REJECT,
+	},
+	{
+		"test3 ld_imm64",
+		.insns = {
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 1),
+			BPF_RAW_INSN(BPF_LD | BPF_IMM | BPF_DW, 0, 0, 0, 0),
+			BPF_LD_IMM64(BPF_REG_0, 0),
+			BPF_LD_IMM64(BPF_REG_0, 0),
+			BPF_LD_IMM64(BPF_REG_0, 1),
+			BPF_LD_IMM64(BPF_REG_0, 1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_ld_imm64 insn",
+		.result = REJECT,
+	},
+	{
+		"test4 ld_imm64",
+		.insns = {
+			BPF_RAW_INSN(BPF_LD | BPF_IMM | BPF_DW, 0, 0, 0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_ld_imm64 insn",
+		.result = REJECT,
+	},
+	{
+		"test5 ld_imm64",
+		.insns = {
+			BPF_RAW_INSN(BPF_LD | BPF_IMM | BPF_DW, 0, 0, 0, 0),
+		},
+		.errstr = "invalid bpf_ld_imm64 insn",
+		.result = REJECT,
+	},
+	{
+		"no bpf_exit",
+		.insns = {
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_0, BPF_REG_2),
+		},
+		.errstr = "jump out of range",
+		.result = REJECT,
+	},
+	{
+		"loop (back-edge)",
+		.insns = {
+			BPF_JMP_IMM(BPF_JA, 0, 0, -1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "back-edge",
+		.result = REJECT,
+	},
+	{
+		"loop2 (back-edge)",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_0),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_0),
+			BPF_JMP_IMM(BPF_JA, 0, 0, -4),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "back-edge",
+		.result = REJECT,
+	},
+	{
+		"conditional loop",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_0),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_0),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, -3),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "back-edge",
+		.result = REJECT,
+	},
+	{
+		"read uninitialized register",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R2 !read_ok",
+		.result = REJECT,
+	},
+	{
+		"read invalid register",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_0, -1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R15 is invalid",
+		.result = REJECT,
+	},
+	{
+		"program doesn't init R0 before exit",
+		.insns = {
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_2, BPF_REG_1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R0 !read_ok",
+		.result = REJECT,
+	},
+	{
+		"stack out of bounds",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, 8, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid stack",
+		.result = REJECT,
+	},
+	{
+		"invalid call insn1",
+		.insns = {
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL | BPF_X, 0, 0, 0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "BPF_CALL uses reserved",
+		.result = REJECT,
+	},
+	{
+		"invalid call insn2",
+		.insns = {
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 1, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "BPF_CALL uses reserved",
+		.result = REJECT,
+	},
+	{
+		"invalid function call",
+		.insns = {
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, 1234567),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid func 1234567",
+		.result = REJECT,
+	},
+	{
+		"uninitialized stack1",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_unspec),
+			BPF_EXIT_INSN(),
+		},
+		.fixup = {2},
+		.errstr = "invalid indirect read from stack",
+		.result = REJECT,
+	},
+	{
+		"uninitialized stack2",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_2, -8),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid read from stack",
+		.result = REJECT,
+	},
+	{
+		"check valid spill/fill",
+		.insns = {
+			/* spill R1(ctx) into stack */
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_1, -8),
+
+			/* fill it back into R2 */
+			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_10, -8),
+
+			/* should be able to access R0 = *(R2 + 8) */
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_2, 8),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+	},
+	{
+		"check corrupted spill/fill",
+		.insns = {
+			/* spill R1(ctx) into stack */
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_1, -8),
+
+			/* mess up with R1 pointer on stack */
+			BPF_ST_MEM(BPF_B, BPF_REG_10, -7, 0x23),
+
+			/* fill back into R0 should fail */
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_10, -8),
+
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "corrupted spill",
+		.result = REJECT,
+	},
+	{
+		"invalid src register in STX",
+		.insns = {
+			BPF_STX_MEM(BPF_B, BPF_REG_10, -1, -1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R15 is invalid",
+		.result = REJECT,
+	},
+	{
+		"invalid dst register in STX",
+		.insns = {
+			BPF_STX_MEM(BPF_B, 14, BPF_REG_10, -1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R14 is invalid",
+		.result = REJECT,
+	},
+	{
+		"invalid dst register in ST",
+		.insns = {
+			BPF_ST_MEM(BPF_B, 14, -1, -1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R14 is invalid",
+		.result = REJECT,
+	},
+	{
+		"invalid src register in LDX",
+		.insns = {
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, 12, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R12 is invalid",
+		.result = REJECT,
+	},
+	{
+		"invalid dst register in LDX",
+		.insns = {
+			BPF_LDX_MEM(BPF_B, 11, BPF_REG_1, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R11 is invalid",
+		.result = REJECT,
+	},
+	{
+		"junk insn",
+		.insns = {
+			BPF_RAW_INSN(0, 0, 0, 0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid BPF_LD_IMM",
+		.result = REJECT,
+	},
+	{
+		"junk insn2",
+		.insns = {
+			BPF_RAW_INSN(1, 0, 0, 0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "BPF_LDX uses reserved fields",
+		.result = REJECT,
+	},
+	{
+		"junk insn3",
+		.insns = {
+			BPF_RAW_INSN(-1, 0, 0, 0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid BPF_ALU opcode f0",
+		.result = REJECT,
+	},
+	{
+		"junk insn4",
+		.insns = {
+			BPF_RAW_INSN(-1, -1, -1, -1, -1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid BPF_ALU opcode f0",
+		.result = REJECT,
+	},
+	{
+		"junk insn5",
+		.insns = {
+			BPF_RAW_INSN(0x7f, -1, -1, -1, -1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "BPF_ALU uses reserved fields",
+		.result = REJECT,
+	},
+	{
+		"misaligned read from stack",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_2, -4),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "misaligned access",
+		.result = REJECT,
+	},
+	{
+		"invalid map_fd for function call",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_unspec),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "fd 0 is not pointing to valid bpf_map",
+		.result = REJECT,
+	},
+	{
+		"don't check return value before access",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_unspec),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup = {3},
+		.errstr = "R0 invalid mem access 'map_value_or_null'",
+		.result = REJECT,
+	},
+	{
+		"access memory with incorrect alignment",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_unspec),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 4, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup = {3},
+		.errstr = "misaligned access",
+		.result = REJECT,
+	},
+	{
+		"sometimes access memory with incorrect alignment",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_unspec),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 2),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 0),
+			BPF_EXIT_INSN(),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 1),
+			BPF_EXIT_INSN(),
+		},
+		.fixup = {3},
+		.errstr = "R0 invalid mem access",
+		.result = REJECT,
+	},
+};
+
+static int probe_filter_length(struct bpf_insn *fp)
+{
+	int len = 0;
+
+	for (len = MAX_INSNS - 1; len > 0; --len)
+		if (fp[len].code != 0 || fp[len].imm != 0)
+			break;
+
+	return len + 1;
+}
+
+static int create_map(void)
+{
+	long long key, value = 0;
+	int map_fd;
+
+	map_fd = bpf_create_map(BPF_MAP_TYPE_UNSPEC, sizeof(key), sizeof(value), 1024);
+	if (map_fd < 0) {
+		printf("failed to create map '%s'\n", strerror(errno));
+	}
+
+	return map_fd;
+}
+
+static int test(void)
+{
+	int prog_fd, i;
+
+	for (i = 0; i < ARRAY_SIZE(tests); i++) {
+		struct bpf_insn *prog = tests[i].insns;
+		int prog_len = probe_filter_length(prog);
+		int *fixup = tests[i].fixup;
+		int map_fd = -1;
+
+		if (*fixup) {
+			map_fd = create_map();
+
+			do {
+				prog[*fixup].imm = map_fd;
+				fixup++;
+			} while (*fixup);
+		}
+		printf("#%d %s ", i, tests[i].descr);
+
+		prog_fd = bpf_prog_load(BPF_PROG_TYPE_UNSPEC, prog,
+					prog_len * sizeof(struct bpf_insn),
+					"GPL");
+
+		if (tests[i].result == ACCEPT) {
+			if (prog_fd < 0) {
+				printf("FAIL\nfailed to load prog '%s'\n",
+				       strerror(errno));
+				printf("%s", bpf_log_buf);
+				goto fail;
+			}
+		} else {
+			if (prog_fd >= 0) {
+				printf("FAIL\nunexpected success to load\n");
+				printf("%s", bpf_log_buf);
+				goto fail;
+			}
+			if (strstr(bpf_log_buf, tests[i].errstr) == 0) {
+				printf("FAIL\nunexpected error message: %s",
+				       bpf_log_buf);
+				goto fail;
+			}
+		}
+
+		printf("OK\n");
+fail:
+		if (map_fd >= 0)
+			close(map_fd);
+		close(prog_fd);
+
+	}
+
+	return 0;
+}
+
+int main(void)
+{
+	return test();
+}
-- 
1.7.9.5
