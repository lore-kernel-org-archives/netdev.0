From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 1/4] bpf: Fix and simplifications on inline map lookup
Date: Wed, 22 Mar 2017 10:00:32 -0700
Message-ID: <20170322170035.923581-2-kafai@fb.com>
References: <20170322170035.923581-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        FB Kernel Team <Kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:34802 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1760939AbdCVRAh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 13:00:37 -0400
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2MGwGgP016107
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 10:00:36 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 29bnvgtkha-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 10:00:36 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.102.107.99) with ESMTP id
 111ad0f40f2111e7815d0002c99293a0-bc1fc9a0 for <netdev@vger.kernel.org>;        Wed,
 22 Mar 2017 10:00:35 -0700
In-Reply-To: <20170322170035.923581-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix in verifier:
For the same bpf_map_lookup_elem() instruction (i.e. "call 1"),
a broken case is "a different type of map could be used for the
same lookup instruction". For example, an array in one case and a
hashmap in another.  We have to resort to the old dynamic call behavior
in this case.  The fix is to check for collision on insn_aux->map_ptr.
If there is collision, don't inline the map lookup.

Please see the "do_reg_lookup()" in test_map_in_map_kern.c in the later
patch for how-to trigger the above case.

Simplifications on array_map_gen_lookup():
1. Calculate elem_size from map->value_size.  It removes the
   need for 'struct bpf_array' which makes the later map-in-map
   implementation easier.
2. Remove the 'elem_size == 1' test

Fixes: 81ed18ab3098 ("bpf: add helper inlining infra and optimize map_array lookup")
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/arraymap.c | 11 ++++-------
 kernel/bpf/verifier.c | 13 +++++++++++--
 2 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index bcf9955fac95..4d7d5d0ed76a 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -117,20 +117,17 @@ static void *array_map_lookup_elem(struct bpf_map *map, void *key)
 /* emit BPF instructions equivalent to C code of array_map_lookup_elem() */
 static u32 array_map_gen_lookup(struct bpf_map *map, struct bpf_insn *insn_buf)
 {
-	struct bpf_array *array = container_of(map, struct bpf_array, map);
 	struct bpf_insn *insn = insn_buf;
-	u32 elem_size = array->elem_size;
+	u32 elem_size = round_up(map->value_size, 8);
 	const int ret = BPF_REG_0;
 	const int map_ptr = BPF_REG_1;
 	const int index = BPF_REG_2;
 
 	*insn++ = BPF_ALU64_IMM(BPF_ADD, map_ptr, offsetof(struct bpf_array, value));
 	*insn++ = BPF_LDX_MEM(BPF_W, ret, index, 0);
-	*insn++ = BPF_JMP_IMM(BPF_JGE, ret, array->map.max_entries,
-			      elem_size == 1 ? 2 : 3);
-	if (elem_size == 1) {
-		/* nop */
-	} else if (is_power_of_2(elem_size)) {
+	*insn++ = BPF_JMP_IMM(BPF_JGE, ret, map->max_entries, 3);
+
+	if (is_power_of_2(elem_size)) {
 		*insn++ = BPF_ALU64_IMM(BPF_LSH, ret, ilog2(elem_size));
 	} else {
 		*insn++ = BPF_ALU64_IMM(BPF_MUL, ret, elem_size);
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 90bf46787603..9bf82267f2f9 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -143,6 +143,8 @@ struct bpf_verifier_stack_elem {
 #define BPF_COMPLEXITY_LIMIT_INSNS	65536
 #define BPF_COMPLEXITY_LIMIT_STACK	1024
 
+#define BPF_MAP_PTR_POISON ((void *)0xeB9F + POISON_POINTER_DELTA)
+
 struct bpf_call_arg_meta {
 	struct bpf_map *map_ptr;
 	bool raw_mode;
@@ -1357,6 +1359,8 @@ static int check_call(struct bpf_verifier_env *env, int func_id, int insn_idx)
 	} else if (fn->ret_type == RET_VOID) {
 		regs[BPF_REG_0].type = NOT_INIT;
 	} else if (fn->ret_type == RET_PTR_TO_MAP_VALUE_OR_NULL) {
+		struct bpf_insn_aux_data *insn_aux;
+
 		regs[BPF_REG_0].type = PTR_TO_MAP_VALUE_OR_NULL;
 		regs[BPF_REG_0].max_value = regs[BPF_REG_0].min_value = 0;
 		/* remember map_ptr, so that check_map_access()
@@ -1369,7 +1373,11 @@ static int check_call(struct bpf_verifier_env *env, int func_id, int insn_idx)
 		}
 		regs[BPF_REG_0].map_ptr = meta.map_ptr;
 		regs[BPF_REG_0].id = ++env->id_gen;
-		env->insn_aux_data[insn_idx].map_ptr = meta.map_ptr;
+		insn_aux = &env->insn_aux_data[insn_idx];
+		if (!insn_aux->map_ptr)
+			insn_aux->map_ptr = meta.map_ptr;
+		else if (insn_aux->map_ptr != meta.map_ptr)
+			insn_aux->map_ptr = BPF_MAP_PTR_POISON;
 	} else {
 		verbose("unknown return type %d of func %s#%d\n",
 			fn->ret_type, func_id_name(func_id), func_id);
@@ -3307,7 +3315,8 @@ static int fixup_bpf_calls(struct bpf_verifier_env *env)
 
 		if (ebpf_jit_enabled() && insn->imm == BPF_FUNC_map_lookup_elem) {
 			map_ptr = env->insn_aux_data[i + delta].map_ptr;
-			if (!map_ptr->ops->map_gen_lookup)
+			if (map_ptr == BPF_MAP_PTR_POISON ||
+			    !map_ptr->ops->map_gen_lookup)
 				goto patch_call_imm;
 
 			cnt = map_ptr->ops->map_gen_lookup(map_ptr, insn_buf);
-- 
2.9.3
