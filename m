From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/2] ebpf: misc core cleanup
Date: Fri, 29 May 2015 23:23:07 +0200
Message-ID: <331333f9ad9f3317ebf128ee90eb32e64404029e.1432912637.git.daniel@iogearbox.net>
References: <cover.1432912637.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39920 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030234AbbE2VXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 17:23:11 -0400
In-Reply-To: <cover.1432912637.git.daniel@iogearbox.net>
In-Reply-To: <cover.1432912637.git.daniel@iogearbox.net>
References: <cover.1432912637.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Besides others, move bpf_tail_call_proto to the remaining definitions
of other protos, improve comments a bit (i.e. remove some obvious ones,
where the code is already self-documenting, add objectives for others),
simplify bpf_prog_array_compatible() a bit.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/core.c    | 72 ++++++++++++++++++++++++++++++----------------------
 kernel/bpf/helpers.c | 34 ++++++++++++-------------
 2 files changed, 58 insertions(+), 48 deletions(-)

diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 4548422..1e00aa3 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -26,9 +26,10 @@
 #include <linux/vmalloc.h>
 #include <linux/random.h>
 #include <linux/moduleloader.h>
-#include <asm/unaligned.h>
 #include <linux/bpf.h>
 
+#include <asm/unaligned.h>
+
 /* Registers */
 #define BPF_R0	regs[BPF_REG_0]
 #define BPF_R1	regs[BPF_REG_1]
@@ -62,6 +63,7 @@ void *bpf_internal_load_pointer_neg_helper(const struct sk_buff *skb, int k, uns
 		ptr = skb_network_header(skb) + k - SKF_NET_OFF;
 	else if (k >= SKF_LL_OFF)
 		ptr = skb_mac_header(skb) + k - SKF_LL_OFF;
+
 	if (ptr >= skb->head && ptr + size <= skb_tail_pointer(skb))
 		return ptr;
 
@@ -176,15 +178,6 @@ noinline u64 __bpf_call_base(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 	return 0;
 }
 
-const struct bpf_func_proto bpf_tail_call_proto = {
-	.func = NULL,
-	.gpl_only = false,
-	.ret_type = RET_VOID,
-	.arg1_type = ARG_PTR_TO_CTX,
-	.arg2_type = ARG_CONST_MAP_PTR,
-	.arg3_type = ARG_ANYTHING,
-};
-
 /**
  *	__bpf_prog_run - run eBPF program on a given context
  *	@ctx: is the data we are operating on
@@ -650,36 +643,35 @@ load_byte:
 		return 0;
 }
 
-void __weak bpf_int_jit_compile(struct bpf_prog *prog)
-{
-}
-
-bool bpf_prog_array_compatible(struct bpf_array *array, const struct bpf_prog *fp)
+bool bpf_prog_array_compatible(struct bpf_array *array,
+			       const struct bpf_prog *fp)
 {
-	if (array->owner_prog_type) {
-		if (array->owner_prog_type != fp->type)
-			return false;
-		if (array->owner_jited != fp->jited)
-			return false;
-	} else {
+	if (!array->owner_prog_type) {
+		/* There's no owner yet where we could check for
+		 * compatibility.
+		 */
 		array->owner_prog_type = fp->type;
 		array->owner_jited = fp->jited;
+
+		return true;
 	}
-	return true;
+
+	return array->owner_prog_type == fp->type &&
+	       array->owner_jited == fp->jited;
 }
 
-static int check_tail_call(const struct bpf_prog *fp)
+static int bpf_check_tail_call(const struct bpf_prog *fp)
 {
 	struct bpf_prog_aux *aux = fp->aux;
 	int i;
 
 	for (i = 0; i < aux->used_map_cnt; i++) {
+		struct bpf_map *map = aux->used_maps[i];
 		struct bpf_array *array;
-		struct bpf_map *map;
 
-		map = aux->used_maps[i];
 		if (map->map_type != BPF_MAP_TYPE_PROG_ARRAY)
 			continue;
+
 		array = container_of(map, struct bpf_array, map);
 		if (!bpf_prog_array_compatible(array, fp))
 			return -EINVAL;
@@ -689,22 +681,25 @@ static int check_tail_call(const struct bpf_prog *fp)
 }
 
 /**
- *	bpf_prog_select_runtime - select execution runtime for BPF program
+ *	bpf_prog_select_runtime - select exec runtime for BPF program
  *	@fp: bpf_prog populated with internal BPF program
  *
- * try to JIT internal BPF program, if JIT is not available select interpreter
- * BPF program will be executed via BPF_PROG_RUN() macro
+ * Try to JIT eBPF program, if JIT is not available, use interpreter.
+ * The BPF program will be executed via BPF_PROG_RUN() macro.
  */
 int bpf_prog_select_runtime(struct bpf_prog *fp)
 {
 	fp->bpf_func = (void *) __bpf_prog_run;
 
-	/* Probe if internal BPF can be JITed */
 	bpf_int_jit_compile(fp);
-	/* Lock whole bpf_prog as read-only */
 	bpf_prog_lock_ro(fp);
 
-	return check_tail_call(fp);
+	/* The tail call compatibility check can only be done at
+	 * this late stage as we need to determine, if we deal
+	 * with JITed or non JITed program concatenations and not
+	 * all eBPF JITs might immediately support all features.
+	 */
+	return bpf_check_tail_call(fp);
 }
 EXPORT_SYMBOL_GPL(bpf_prog_select_runtime);
 
@@ -736,6 +731,21 @@ const struct bpf_func_proto bpf_get_prandom_u32_proto __weak;
 const struct bpf_func_proto bpf_get_smp_processor_id_proto __weak;
 const struct bpf_func_proto bpf_ktime_get_ns_proto __weak;
 
+/* Always built-in helper functions. */
+const struct bpf_func_proto bpf_tail_call_proto = {
+	.func		= NULL,
+	.gpl_only	= false,
+	.ret_type	= RET_VOID,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_CONST_MAP_PTR,
+	.arg3_type	= ARG_ANYTHING,
+};
+
+/* For classic BPF JITs that don't implement bpf_int_jit_compile(). */
+void __weak bpf_int_jit_compile(struct bpf_prog *prog)
+{
+}
+
 /* To execute LD_ABS/LD_IND instructions __bpf_prog_run() may call
  * skb_copy_bits(), so provide a weak definition of it for NET-less config.
  */
diff --git a/kernel/bpf/helpers.c b/kernel/bpf/helpers.c
index b3aaabd..7ad5d88 100644
--- a/kernel/bpf/helpers.c
+++ b/kernel/bpf/helpers.c
@@ -45,11 +45,11 @@ static u64 bpf_map_lookup_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 }
 
 const struct bpf_func_proto bpf_map_lookup_elem_proto = {
-	.func = bpf_map_lookup_elem,
-	.gpl_only = false,
-	.ret_type = RET_PTR_TO_MAP_VALUE_OR_NULL,
-	.arg1_type = ARG_CONST_MAP_PTR,
-	.arg2_type = ARG_PTR_TO_MAP_KEY,
+	.func		= bpf_map_lookup_elem,
+	.gpl_only	= false,
+	.ret_type	= RET_PTR_TO_MAP_VALUE_OR_NULL,
+	.arg1_type	= ARG_CONST_MAP_PTR,
+	.arg2_type	= ARG_PTR_TO_MAP_KEY,
 };
 
 static u64 bpf_map_update_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
@@ -64,13 +64,13 @@ static u64 bpf_map_update_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 }
 
 const struct bpf_func_proto bpf_map_update_elem_proto = {
-	.func = bpf_map_update_elem,
-	.gpl_only = false,
-	.ret_type = RET_INTEGER,
-	.arg1_type = ARG_CONST_MAP_PTR,
-	.arg2_type = ARG_PTR_TO_MAP_KEY,
-	.arg3_type = ARG_PTR_TO_MAP_VALUE,
-	.arg4_type = ARG_ANYTHING,
+	.func		= bpf_map_update_elem,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_CONST_MAP_PTR,
+	.arg2_type	= ARG_PTR_TO_MAP_KEY,
+	.arg3_type	= ARG_PTR_TO_MAP_VALUE,
+	.arg4_type	= ARG_ANYTHING,
 };
 
 static u64 bpf_map_delete_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
@@ -84,11 +84,11 @@ static u64 bpf_map_delete_elem(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 }
 
 const struct bpf_func_proto bpf_map_delete_elem_proto = {
-	.func = bpf_map_delete_elem,
-	.gpl_only = false,
-	.ret_type = RET_INTEGER,
-	.arg1_type = ARG_CONST_MAP_PTR,
-	.arg2_type = ARG_PTR_TO_MAP_KEY,
+	.func		= bpf_map_delete_elem,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_CONST_MAP_PTR,
+	.arg2_type	= ARG_PTR_TO_MAP_KEY,
 };
 
 static u64 bpf_get_prandom_u32(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
-- 
1.9.3
