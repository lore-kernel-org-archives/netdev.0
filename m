From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCHv3 net-next 05/15] bpf: enable non-core use of the verfier
Date: Wed, 14 Sep 2016 20:00:13 +0100
Message-ID: <1473879623-15382-6-git-send-email-jakub.kicinski@netronome.com>
References: <1473879623-15382-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net, jiri@resnulli.us,
        john.fastabend@gmail.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:38654 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761983AbcINTAr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 15:00:47 -0400
Received: by mail-wm0-f49.google.com with SMTP id 1so49347112wmz.1
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2016 12:00:46 -0700 (PDT)
In-Reply-To: <1473879623-15382-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Advanced JIT compilers and translators may want to use
eBPF verifier as a base for parsers or to perform custom
checks and validations.

Add ability for external users to invoke the verifier
and provide callbacks to be invoked for every intruction
checked.  For now only add most basic callback for
per-instruction pre-interpretation checks is added.  More
advanced users may also like to have per-instruction post
callback and state comparison callback.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 include/linux/bpf_parser.h |  89 ++++++++++++++++++++++++++++++
 kernel/bpf/verifier.c      | 134 +++++++++++++++++++++++----------------------
 2 files changed, 158 insertions(+), 65 deletions(-)
 create mode 100644 include/linux/bpf_parser.h

diff --git a/include/linux/bpf_parser.h b/include/linux/bpf_parser.h
new file mode 100644
index 000000000000..daa53b204f4d
--- /dev/null
+++ b/include/linux/bpf_parser.h
@@ -0,0 +1,89 @@
+/* Copyright (c) 2011-2014 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#ifndef _LINUX_BPF_PARSER_H
+#define _LINUX_BPF_PARSER_H 1
+
+#include <linux/bpf.h> /* for enum bpf_reg_type */
+#include <linux/filter.h> /* for MAX_BPF_STACK */
+
+struct reg_state {
+	enum bpf_reg_type type;
+	union {
+		/* valid when type == CONST_IMM | PTR_TO_STACK | UNKNOWN_VALUE */
+		s64 imm;
+
+		/* valid when type == PTR_TO_PACKET* */
+		struct {
+			u32 id;
+			u16 off;
+			u16 range;
+		};
+
+		/* valid when type == CONST_PTR_TO_MAP | PTR_TO_MAP_VALUE |
+		 *   PTR_TO_MAP_VALUE_OR_NULL
+		 */
+		struct bpf_map *map_ptr;
+	};
+};
+
+enum bpf_stack_slot_type {
+	STACK_INVALID,    /* nothing was stored in this stack slot */
+	STACK_SPILL,      /* register spilled into stack */
+	STACK_MISC	  /* BPF program wrote some data into this slot */
+};
+
+#define BPF_REG_SIZE 8	/* size of eBPF register in bytes */
+
+/* state of the program:
+ * type of all registers and stack info
+ */
+struct verifier_state {
+	struct reg_state regs[MAX_BPF_REG];
+	u8 stack_slot_type[MAX_BPF_STACK];
+	struct reg_state spilled_regs[MAX_BPF_STACK / BPF_REG_SIZE];
+};
+
+/* linked list of verifier states used to prune search */
+struct verifier_state_list {
+	struct verifier_state state;
+	struct verifier_state_list *next;
+};
+
+struct bpf_insn_aux_data {
+	enum bpf_reg_type ptr_type;	/* pointer type for load/store insns */
+};
+
+#define MAX_USED_MAPS 64 /* max number of maps accessed by one eBPF program */
+
+struct verifier_env;
+struct bpf_ext_parser_ops {
+	int (*insn_hook)(struct verifier_env *env,
+			 int insn_idx, int prev_insn_idx);
+};
+
+/* single container for all structs
+ * one verifier_env per bpf_check() call
+ */
+struct verifier_env {
+	struct bpf_prog *prog;		/* eBPF program being verified */
+	struct verifier_stack_elem *head; /* stack of verifier states to be processed */
+	int stack_size;			/* number of states to be processed */
+	struct verifier_state cur_state; /* current verifier state */
+	struct verifier_state_list **explored_states; /* search pruning optimization */
+	const struct bpf_ext_parser_ops *pops; /* external parser ops */
+	void *ppriv; /* pointer to external parser's private data */
+	struct bpf_map *used_maps[MAX_USED_MAPS]; /* array of map's used by eBPF program */
+	u32 used_map_cnt;		/* number of used maps */
+	u32 id_gen;			/* used to generate unique reg IDs */
+	bool allow_ptr_leaks;
+	struct bpf_insn_aux_data *insn_aux_data; /* array of per-insn state */
+};
+
+int bpf_parse(struct bpf_prog *prog, const struct bpf_ext_parser_ops *pops,
+	      void *ppriv);
+
+#endif /* _LINUX_BPF_PARSER_H */
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index ce9c0d1721c6..06067db3ebe3 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -14,6 +14,7 @@
 #include <linux/types.h>
 #include <linux/slab.h>
 #include <linux/bpf.h>
+#include <linux/bpf_parser.h>
 #include <linux/filter.h>
 #include <net/netlink.h>
 #include <linux/file.h>
@@ -126,49 +127,6 @@
  * are set to NOT_INIT to indicate that they are no longer readable.
  */
 
-struct reg_state {
-	enum bpf_reg_type type;
-	union {
-		/* valid when type == CONST_IMM | PTR_TO_STACK | UNKNOWN_VALUE */
-		s64 imm;
-
-		/* valid when type == PTR_TO_PACKET* */
-		struct {
-			u32 id;
-			u16 off;
-			u16 range;
-		};
-
-		/* valid when type == CONST_PTR_TO_MAP | PTR_TO_MAP_VALUE |
-		 *   PTR_TO_MAP_VALUE_OR_NULL
-		 */
-		struct bpf_map *map_ptr;
-	};
-};
-
-enum bpf_stack_slot_type {
-	STACK_INVALID,    /* nothing was stored in this stack slot */
-	STACK_SPILL,      /* register spilled into stack */
-	STACK_MISC	  /* BPF program wrote some data into this slot */
-};
-
-#define BPF_REG_SIZE 8	/* size of eBPF register in bytes */
-
-/* state of the program:
- * type of all registers and stack info
- */
-struct verifier_state {
-	struct reg_state regs[MAX_BPF_REG];
-	u8 stack_slot_type[MAX_BPF_STACK];
-	struct reg_state spilled_regs[MAX_BPF_STACK / BPF_REG_SIZE];
-};
-
-/* linked list of verifier states used to prune search */
-struct verifier_state_list {
-	struct verifier_state state;
-	struct verifier_state_list *next;
-};
-
 /* verifier_state + insn_idx are pushed to stack when branch is encountered */
 struct verifier_stack_elem {
 	/* verifer state is 'st'
@@ -181,28 +139,6 @@ struct verifier_stack_elem {
 	struct verifier_stack_elem *next;
 };
 
-struct bpf_insn_aux_data {
-	enum bpf_reg_type ptr_type;	/* pointer type for load/store insns */
-};
-
-#define MAX_USED_MAPS 64 /* max number of maps accessed by one eBPF program */
-
-/* single container for all structs
- * one verifier_env per bpf_check() call
- */
-struct verifier_env {
-	struct bpf_prog *prog;		/* eBPF program being verified */
-	struct verifier_stack_elem *head; /* stack of verifier states to be processed */
-	int stack_size;			/* number of states to be processed */
-	struct verifier_state cur_state; /* current verifier state */
-	struct verifier_state_list **explored_states; /* search pruning optimization */
-	struct bpf_map *used_maps[MAX_USED_MAPS]; /* array of map's used by eBPF program */
-	u32 used_map_cnt;		/* number of used maps */
-	u32 id_gen;			/* used to generate unique reg IDs */
-	bool allow_ptr_leaks;
-	struct bpf_insn_aux_data *insn_aux_data; /* array of per-insn state */
-};
-
 #define BPF_COMPLEXITY_LIMIT_INSNS	65536
 #define BPF_COMPLEXITY_LIMIT_STACK	1024
 
@@ -688,6 +624,10 @@ static int check_packet_access(struct verifier_env *env, u32 regno, int off,
 static int check_ctx_access(struct verifier_env *env, int off, int size,
 			    enum bpf_access_type t, enum bpf_reg_type *reg_type)
 {
+	/* for parser ctx accesses are already validated and converted */
+	if (env->pops)
+		return 0;
+
 	if (env->prog->aux->ops->is_valid_access &&
 	    env->prog->aux->ops->is_valid_access(off, size, t, reg_type)) {
 		/* remember the offset of last byte accessed in ctx */
@@ -2281,6 +2221,15 @@ static int is_state_visited(struct verifier_env *env, int insn_idx)
 	return 0;
 }
 
+static int ext_parser_hook(struct verifier_env *env,
+			   int insn_idx, int prev_insn_idx)
+{
+	if (!env->pops || !env->pops->insn_hook)
+		return 0;
+
+	return env->pops->insn_hook(env, insn_idx, prev_insn_idx);
+}
+
 static int do_check(struct verifier_env *env)
 {
 	struct verifier_state *state = &env->cur_state;
@@ -2339,6 +2288,10 @@ static int do_check(struct verifier_env *env)
 			print_bpf_insn(insn);
 		}
 
+		err = ext_parser_hook(env, insn_idx, prev_insn_idx);
+		if (err)
+			return err;
+
 		if (class == BPF_ALU || class == BPF_ALU64) {
 			err = check_alu_op(env, insn);
 			if (err)
@@ -2888,3 +2841,54 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 	kfree(env);
 	return ret;
 }
+
+int bpf_parse(struct bpf_prog *prog, const struct bpf_ext_parser_ops *pops,
+	      void *ppriv)
+{
+	struct verifier_env *env;
+	int ret;
+
+	env = kzalloc(sizeof(struct verifier_env), GFP_KERNEL);
+	if (!env)
+		return -ENOMEM;
+
+	env->insn_aux_data = vzalloc(sizeof(struct bpf_insn_aux_data) *
+				     prog->len);
+	ret = -ENOMEM;
+	if (!env->insn_aux_data)
+		goto err_free_env;
+	env->prog = prog;
+	env->pops = pops;
+	env->ppriv = ppriv;
+
+	/* grab the mutex to protect few globals used by verifier */
+	mutex_lock(&bpf_verifier_lock);
+
+	log_level = 0;
+
+	env->explored_states = kcalloc(env->prog->len,
+				       sizeof(struct verifier_state_list *),
+				       GFP_KERNEL);
+	ret = -ENOMEM;
+	if (!env->explored_states)
+		goto skip_full_check;
+
+	ret = check_cfg(env);
+	if (ret < 0)
+		goto skip_full_check;
+
+	env->allow_ptr_leaks = capable(CAP_SYS_ADMIN);
+
+	ret = do_check(env);
+
+skip_full_check:
+	while (pop_stack(env, NULL) >= 0);
+	free_states(env);
+
+	mutex_unlock(&bpf_verifier_lock);
+	vfree(env->insn_aux_data);
+err_free_env:
+	kfree(env);
+	return ret;
+}
+EXPORT_SYMBOL_GPL(bpf_parse);
-- 
1.9.1
