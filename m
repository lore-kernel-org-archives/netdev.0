From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 01/10] ebpf: remove kernel test stubs
Date: Fri, 27 Feb 2015 15:55:33 +0100
Message-ID: <ec69789523a8a25f092b4b9c9c35f261494afe5c.1425040939.git.daniel@iogearbox.net>
References: <cover.1425040939.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47825 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751693AbbB0Ozs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 09:55:48 -0500
In-Reply-To: <cover.1425040939.git.daniel@iogearbox.net>
In-Reply-To: <cover.1425040939.git.daniel@iogearbox.net>
References: <cover.1425040939.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we have BPF_PROG_TYPE_SOCKET_FILTER up and running, we can
remove the test stubs which were added to get the verifier suite up.

We can just let the test cases probe under socket filter type instead.
In the fill/spill test case, we cannot (yet) access fields from the
context (skb), but we may adapt that test case in future.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
---
 kernel/bpf/Makefile         |  3 --
 kernel/bpf/test_stub.c      | 78 ---------------------------------------------
 samples/bpf/test_verifier.c |  5 +--
 3 files changed, 3 insertions(+), 83 deletions(-)
 delete mode 100644 kernel/bpf/test_stub.c

diff --git a/kernel/bpf/Makefile b/kernel/bpf/Makefile
index a5ae60f..e6983be 100644
--- a/kernel/bpf/Makefile
+++ b/kernel/bpf/Makefile
@@ -1,5 +1,2 @@
 obj-y := core.o
 obj-$(CONFIG_BPF_SYSCALL) += syscall.o verifier.o hashtab.o arraymap.o helpers.o
-ifdef CONFIG_TEST_BPF
-obj-$(CONFIG_BPF_SYSCALL) += test_stub.o
-endif
diff --git a/kernel/bpf/test_stub.c b/kernel/bpf/test_stub.c
deleted file mode 100644
index 0ceae1e..0000000
--- a/kernel/bpf/test_stub.c
+++ /dev/null
@@ -1,78 +0,0 @@
-/* Copyright (c) 2011-2014 PLUMgrid, http://plumgrid.com
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of version 2 of the GNU General Public
- * License as published by the Free Software Foundation.
- */
-#include <linux/kernel.h>
-#include <linux/types.h>
-#include <linux/slab.h>
-#include <linux/err.h>
-#include <linux/bpf.h>
-
-/* test stubs for BPF_MAP_TYPE_UNSPEC and for BPF_PROG_TYPE_UNSPEC
- * to be used by user space verifier testsuite
- */
-struct bpf_context {
-	u64 arg1;
-	u64 arg2;
-};
-
-static const struct bpf_func_proto *test_func_proto(enum bpf_func_id func_id)
-{
-	switch (func_id) {
-	case BPF_FUNC_map_lookup_elem:
-		return &bpf_map_lookup_elem_proto;
-	case BPF_FUNC_map_update_elem:
-		return &bpf_map_update_elem_proto;
-	case BPF_FUNC_map_delete_elem:
-		return &bpf_map_delete_elem_proto;
-	default:
-		return NULL;
-	}
-}
-
-static const struct bpf_context_access {
-	int size;
-	enum bpf_access_type type;
-} test_ctx_access[] = {
-	[offsetof(struct bpf_context, arg1)] = {
-		FIELD_SIZEOF(struct bpf_context, arg1),
-		BPF_READ
-	},
-	[offsetof(struct bpf_context, arg2)] = {
-		FIELD_SIZEOF(struct bpf_context, arg2),
-		BPF_READ
-	},
-};
-
-static bool test_is_valid_access(int off, int size, enum bpf_access_type type)
-{
-	const struct bpf_context_access *access;
-
-	if (off < 0 || off >= ARRAY_SIZE(test_ctx_access))
-		return false;
-
-	access = &test_ctx_access[off];
-	if (access->size == size && (access->type & type))
-		return true;
-
-	return false;
-}
-
-static struct bpf_verifier_ops test_ops = {
-	.get_func_proto = test_func_proto,
-	.is_valid_access = test_is_valid_access,
-};
-
-static struct bpf_prog_type_list tl_prog = {
-	.ops = &test_ops,
-	.type = BPF_PROG_TYPE_UNSPEC,
-};
-
-static int __init register_test_ops(void)
-{
-	bpf_register_prog_type(&tl_prog);
-	return 0;
-}
-late_initcall(register_test_ops);
diff --git a/samples/bpf/test_verifier.c b/samples/bpf/test_verifier.c
index b96175e..7b56b59 100644
--- a/samples/bpf/test_verifier.c
+++ b/samples/bpf/test_verifier.c
@@ -288,7 +288,8 @@ static struct bpf_test tests[] = {
 			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_10, -8),
 
 			/* should be able to access R0 = *(R2 + 8) */
-			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_2, 8),
+			/* BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_2, 8), */
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
 			BPF_EXIT_INSN(),
 		},
 		.result = ACCEPT,
@@ -687,7 +688,7 @@ static int test(void)
 		}
 		printf("#%d %s ", i, tests[i].descr);
 
-		prog_fd = bpf_prog_load(BPF_PROG_TYPE_UNSPEC, prog,
+		prog_fd = bpf_prog_load(BPF_PROG_TYPE_SOCKET_FILTER, prog,
 					prog_len * sizeof(struct bpf_insn),
 					"GPL");
 
-- 
1.9.3
