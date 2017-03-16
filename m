From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 4/6] bpf: add helper inlining infra and optimize map_array lookup
Date: Wed, 15 Mar 2017 18:26:42 -0700
Message-ID: <1489627604-2288703-5-git-send-email-ast@fb.com>
References: <1489627604-2288703-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Fengguang Wu <fengguang.wu@intel.com>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:58405 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750865AbdCPB0r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 21:26:47 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.20/8.16.0.20) with SMTP id v2G1HKLh025665
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:26:46 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 2974e7cbu6-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:26:45 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 9dbf3a2a09e711e780d70002c9dfb610-bb9fa9a0 for <netdev@vger.kernel.org>;        Wed,
 15 Mar 2017 18:26:44 -0700
In-Reply-To: <1489627604-2288703-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Optimize bpf_call -> bpf_map_lookup_elem() -> array_map_lookup_elem()
into a sequence of bpf instructions.
When JIT is on the sequence of bpf instructions is the sequence
of native cpu instructions with significantly faster performance
than indirect call and two function's prologue/epilogue.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/bpf.h          |  1 +
 include/linux/bpf_verifier.h |  5 ++++-
 include/linux/filter.h       | 10 ++++++++++
 kernel/bpf/arraymap.c        | 29 +++++++++++++++++++++++++++++
 kernel/bpf/verifier.c        | 36 +++++++++++++++++++++++++++++++++---
 5 files changed, 77 insertions(+), 4 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 909fc033173a..da8c64ca8dc9 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -35,6 +35,7 @@ struct bpf_map_ops {
 	void *(*map_fd_get_ptr)(struct bpf_map *map, struct file *map_file,
 				int fd);
 	void (*map_fd_put_ptr)(void *ptr);
+	u32 (*map_gen_lookup)(struct bpf_map *map, struct bpf_insn *insn_buf);
 };
 
 struct bpf_map {
diff --git a/include/linux/bpf_verifier.h b/include/linux/bpf_verifier.h
index a13b031dc6b8..5efb4db44e1e 100644
--- a/include/linux/bpf_verifier.h
+++ b/include/linux/bpf_verifier.h
@@ -66,7 +66,10 @@ struct bpf_verifier_state_list {
 };
 
 struct bpf_insn_aux_data {
-	enum bpf_reg_type ptr_type;	/* pointer type for load/store insns */
+	union {
+		enum bpf_reg_type ptr_type;	/* pointer type for load/store insns */
+		struct bpf_map *map_ptr;	/* pointer for call insn into lookup_elem */
+	};
 };
 
 #define MAX_USED_MAPS 64 /* max number of maps accessed by one eBPF program */
diff --git a/include/linux/filter.h b/include/linux/filter.h
index fbf7b39e8103..dffa072b7b79 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -693,6 +693,11 @@ static inline bool bpf_jit_is_ebpf(void)
 # endif
 }
 
+static inline bool ebpf_jit_enabled(void)
+{
+	return bpf_jit_enable && bpf_jit_is_ebpf();
+}
+
 static inline bool bpf_prog_ebpf_jited(const struct bpf_prog *fp)
 {
 	return fp->jited && bpf_jit_is_ebpf();
@@ -753,6 +758,11 @@ void bpf_prog_kallsyms_del(struct bpf_prog *fp);
 
 #else /* CONFIG_BPF_JIT */
 
+static inline bool ebpf_jit_enabled(void)
+{
+	return false;
+}
+
 static inline bool bpf_prog_ebpf_jited(const struct bpf_prog *fp)
 {
 	return false;
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 6b6f41f0b211..bcf9955fac95 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -1,4 +1,5 @@
 /* Copyright (c) 2011-2014 PLUMgrid, http://plumgrid.com
+ * Copyright (c) 2016,2017 Facebook
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
@@ -113,6 +114,33 @@ static void *array_map_lookup_elem(struct bpf_map *map, void *key)
 	return array->value + array->elem_size * index;
 }
 
+/* emit BPF instructions equivalent to C code of array_map_lookup_elem() */
+static u32 array_map_gen_lookup(struct bpf_map *map, struct bpf_insn *insn_buf)
+{
+	struct bpf_array *array = container_of(map, struct bpf_array, map);
+	struct bpf_insn *insn = insn_buf;
+	u32 elem_size = array->elem_size;
+	const int ret = BPF_REG_0;
+	const int map_ptr = BPF_REG_1;
+	const int index = BPF_REG_2;
+
+	*insn++ = BPF_ALU64_IMM(BPF_ADD, map_ptr, offsetof(struct bpf_array, value));
+	*insn++ = BPF_LDX_MEM(BPF_W, ret, index, 0);
+	*insn++ = BPF_JMP_IMM(BPF_JGE, ret, array->map.max_entries,
+			      elem_size == 1 ? 2 : 3);
+	if (elem_size == 1) {
+		/* nop */
+	} else if (is_power_of_2(elem_size)) {
+		*insn++ = BPF_ALU64_IMM(BPF_LSH, ret, ilog2(elem_size));
+	} else {
+		*insn++ = BPF_ALU64_IMM(BPF_MUL, ret, elem_size);
+	}
+	*insn++ = BPF_ALU64_REG(BPF_ADD, ret, map_ptr);
+	*insn++ = BPF_JMP_IMM(BPF_JA, 0, 0, 1);
+	*insn++ = BPF_MOV64_IMM(ret, 0);
+	return insn - insn_buf;
+}
+
 /* Called from eBPF program */
 static void *percpu_array_map_lookup_elem(struct bpf_map *map, void *key)
 {
@@ -267,6 +295,7 @@ static const struct bpf_map_ops array_ops = {
 	.map_lookup_elem = array_map_lookup_elem,
 	.map_update_elem = array_map_update_elem,
 	.map_delete_elem = array_map_delete_elem,
+	.map_gen_lookup = array_map_gen_lookup,
 };
 
 static struct bpf_map_type_list array_type __ro_after_init = {
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 2990fda1c6a5..90bf46787603 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1273,7 +1273,7 @@ static void clear_all_pkt_pointers(struct bpf_verifier_env *env)
 	}
 }
 
-static int check_call(struct bpf_verifier_env *env, int func_id)
+static int check_call(struct bpf_verifier_env *env, int func_id, int insn_idx)
 {
 	struct bpf_verifier_state *state = &env->cur_state;
 	const struct bpf_func_proto *fn = NULL;
@@ -1369,6 +1369,7 @@ static int check_call(struct bpf_verifier_env *env, int func_id)
 		}
 		regs[BPF_REG_0].map_ptr = meta.map_ptr;
 		regs[BPF_REG_0].id = ++env->id_gen;
+		env->insn_aux_data[insn_idx].map_ptr = meta.map_ptr;
 	} else {
 		verbose("unknown return type %d of func %s#%d\n",
 			fn->ret_type, func_id_name(func_id), func_id);
@@ -2940,7 +2941,7 @@ static int do_check(struct bpf_verifier_env *env)
 					return -EINVAL;
 				}
 
-				err = check_call(env, insn->imm);
+				err = check_call(env, insn->imm, insn_idx);
 				if (err)
 					return err;
 
@@ -3268,6 +3269,7 @@ static int convert_ctx_accesses(struct bpf_verifier_env *env)
 }
 
 /* fixup insn->imm field of bpf_call instructions
+ * and inline eligible helpers as explicit sequence of BPF instructions
  *
  * this function is called after eBPF program passed verification
  */
@@ -3277,7 +3279,10 @@ static int fixup_bpf_calls(struct bpf_verifier_env *env)
 	struct bpf_insn *insn = prog->insnsi;
 	const struct bpf_func_proto *fn;
 	const int insn_cnt = prog->len;
-	int i;
+	struct bpf_insn insn_buf[16];
+	struct bpf_prog *new_prog;
+	struct bpf_map *map_ptr;
+	int i, cnt, delta = 0;
 
 	for (i = 0; i < insn_cnt; i++, insn++) {
 		if (insn->code != (BPF_JMP | BPF_CALL))
@@ -3300,6 +3305,31 @@ static int fixup_bpf_calls(struct bpf_verifier_env *env)
 			continue;
 		}
 
+		if (ebpf_jit_enabled() && insn->imm == BPF_FUNC_map_lookup_elem) {
+			map_ptr = env->insn_aux_data[i + delta].map_ptr;
+			if (!map_ptr->ops->map_gen_lookup)
+				goto patch_call_imm;
+
+			cnt = map_ptr->ops->map_gen_lookup(map_ptr, insn_buf);
+			if (cnt == 0 || cnt >= ARRAY_SIZE(insn_buf)) {
+				verbose("bpf verifier is misconfigured\n");
+				return -EINVAL;
+			}
+
+			new_prog = bpf_patch_insn_data(env, i + delta, insn_buf,
+						       cnt);
+			if (!new_prog)
+				return -ENOMEM;
+
+			delta += cnt - 1;
+
+			/* keep walking new program and skip insns we just inserted */
+			env->prog = prog = new_prog;
+			insn      = new_prog->insnsi + i + delta;
+			continue;
+		}
+
+patch_call_imm:
 		fn = prog->aux->ops->get_func_proto(insn->imm);
 		/* all functions that have prototype and verifier allowed
 		 * programs to call them, must be real in-kernel functions
-- 
2.8.0
