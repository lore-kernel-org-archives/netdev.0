From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 1/5] bpf: remove global verifier log
Date: Thu,  5 Oct 2017 08:34:18 -0700
Message-ID: <20171005153422.8947-2-jakub.kicinski@netronome.com>
References: <20171005153422.8947-1-jakub.kicinski@netronome.com>
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:54384 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751330AbdJEPeg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 11:34:36 -0400
Received: by mail-pf0-f172.google.com with SMTP id m28so3165582pfi.11
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 08:34:36 -0700 (PDT)
In-Reply-To: <20171005153422.8947-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The biggest piece of global state protected by the verifier lock
is the verifier log.  Move that log to struct bpf_verifier_env.
struct bpf_verifier_env has to be passed now to all invocations
of verbose().

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 include/linux/bpf_verifier.h |   5 +
 kernel/bpf/verifier.c        | 514 +++++++++++++++++++++++--------------------
 2 files changed, 276 insertions(+), 243 deletions(-)

diff --git a/include/linux/bpf_verifier.h b/include/linux/bpf_verifier.h
index b8d200f60a40..598802dd1897 100644
--- a/include/linux/bpf_verifier.h
+++ b/include/linux/bpf_verifier.h
@@ -139,6 +139,11 @@ struct bpf_verifier_env {
 	bool allow_ptr_leaks;
 	bool seen_direct_write;
 	struct bpf_insn_aux_data *insn_aux_data; /* array of per-insn state */
+
+	u32 log_level;
+	u32 log_size;
+	u32 log_len;
+	char *log_buf;
 };
 
 int bpf_analyzer(struct bpf_prog *prog, const struct bpf_ext_analyzer_ops *ops,
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 52b022310f6a..cb97dfde65fc 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -153,27 +153,23 @@ struct bpf_call_arg_meta {
 	int access_size;
 };
 
-/* verbose verifier prints what it's seeing
- * bpf_check() is called under lock, so no race to access these global vars
- */
-static u32 log_level, log_size, log_len;
-static char *log_buf;
-
 static DEFINE_MUTEX(bpf_verifier_lock);
 
 /* log_level controls verbosity level of eBPF verifier.
  * verbose() is used to dump the verification trace to the log, so the user
  * can figure out what's wrong with the program
  */
-static __printf(1, 2) void verbose(const char *fmt, ...)
+static __printf(2, 3) void verbose(struct bpf_verifier_env *env,
+				   const char *fmt, ...)
 {
 	va_list args;
 
-	if (log_level == 0 || log_len >= log_size - 1)
+	if (env->log_level == 0 || env->log_len >= env->log_size - 1)
 		return;
 
 	va_start(args, fmt);
-	log_len += vscnprintf(log_buf + log_len, log_size - log_len, fmt, args);
+	env->log_len += vscnprintf(env->log_buf + env->log_len,
+				   env->log_size - env->log_len, fmt, args);
 	va_end(args);
 }
 
@@ -213,7 +209,8 @@ static const char *func_id_name(int id)
 		return "unknown";
 }
 
-static void print_verifier_state(struct bpf_verifier_state *state)
+static void print_verifier_state(struct bpf_verifier_env *env,
+				 struct bpf_verifier_state *state)
 {
 	struct bpf_reg_state *reg;
 	enum bpf_reg_type t;
@@ -224,21 +221,21 @@ static void print_verifier_state(struct bpf_verifier_state *state)
 		t = reg->type;
 		if (t == NOT_INIT)
 			continue;
-		verbose(" R%d=%s", i, reg_type_str[t]);
+		verbose(env, " R%d=%s", i, reg_type_str[t]);
 		if ((t == SCALAR_VALUE || t == PTR_TO_STACK) &&
 		    tnum_is_const(reg->var_off)) {
 			/* reg->off should be 0 for SCALAR_VALUE */
-			verbose("%lld", reg->var_off.value + reg->off);
+			verbose(env, "%lld", reg->var_off.value + reg->off);
 		} else {
-			verbose("(id=%d", reg->id);
+			verbose(env, "(id=%d", reg->id);
 			if (t != SCALAR_VALUE)
-				verbose(",off=%d", reg->off);
+				verbose(env, ",off=%d", reg->off);
 			if (type_is_pkt_pointer(t))
-				verbose(",r=%d", reg->range);
+				verbose(env, ",r=%d", reg->range);
 			else if (t == CONST_PTR_TO_MAP ||
 				 t == PTR_TO_MAP_VALUE ||
 				 t == PTR_TO_MAP_VALUE_OR_NULL)
-				verbose(",ks=%d,vs=%d",
+				verbose(env, ",ks=%d,vs=%d",
 					reg->map_ptr->key_size,
 					reg->map_ptr->value_size);
 			if (tnum_is_const(reg->var_off)) {
@@ -246,38 +243,38 @@ static void print_verifier_state(struct bpf_verifier_state *state)
 				 * could be a pointer whose offset is too big
 				 * for reg->off
 				 */
-				verbose(",imm=%llx", reg->var_off.value);
+				verbose(env, ",imm=%llx", reg->var_off.value);
 			} else {
 				if (reg->smin_value != reg->umin_value &&
 				    reg->smin_value != S64_MIN)
-					verbose(",smin_value=%lld",
+					verbose(env, ",smin_value=%lld",
 						(long long)reg->smin_value);
 				if (reg->smax_value != reg->umax_value &&
 				    reg->smax_value != S64_MAX)
-					verbose(",smax_value=%lld",
+					verbose(env, ",smax_value=%lld",
 						(long long)reg->smax_value);
 				if (reg->umin_value != 0)
-					verbose(",umin_value=%llu",
+					verbose(env, ",umin_value=%llu",
 						(unsigned long long)reg->umin_value);
 				if (reg->umax_value != U64_MAX)
-					verbose(",umax_value=%llu",
+					verbose(env, ",umax_value=%llu",
 						(unsigned long long)reg->umax_value);
 				if (!tnum_is_unknown(reg->var_off)) {
 					char tn_buf[48];
 
 					tnum_strn(tn_buf, sizeof(tn_buf), reg->var_off);
-					verbose(",var_off=%s", tn_buf);
+					verbose(env, ",var_off=%s", tn_buf);
 				}
 			}
-			verbose(")");
+			verbose(env, ")");
 		}
 	}
 	for (i = 0; i < MAX_BPF_STACK; i += BPF_REG_SIZE) {
 		if (state->stack_slot_type[i] == STACK_SPILL)
-			verbose(" fp%d=%s", -MAX_BPF_STACK + i,
+			verbose(env, " fp%d=%s", -MAX_BPF_STACK + i,
 				reg_type_str[state->spilled_regs[i / BPF_REG_SIZE].type]);
 	}
-	verbose("\n");
+	verbose(env, "\n");
 }
 
 static const char *const bpf_class_string[] = {
@@ -332,15 +329,15 @@ static const char *const bpf_jmp_string[16] = {
 	[BPF_EXIT >> 4] = "exit",
 };
 
-static void print_bpf_end_insn(const struct bpf_verifier_env *env,
+static void print_bpf_end_insn(struct bpf_verifier_env *env,
 			       const struct bpf_insn *insn)
 {
-	verbose("(%02x) r%d = %s%d r%d\n", insn->code, insn->dst_reg,
+	verbose(env, "(%02x) r%d = %s%d r%d\n", insn->code, insn->dst_reg,
 		BPF_SRC(insn->code) == BPF_TO_BE ? "be" : "le",
 		insn->imm, insn->dst_reg);
 }
 
-static void print_bpf_insn(const struct bpf_verifier_env *env,
+static void print_bpf_insn(struct bpf_verifier_env *env,
 			   const struct bpf_insn *insn)
 {
 	u8 class = BPF_CLASS(insn->code);
@@ -348,23 +345,23 @@ static void print_bpf_insn(const struct bpf_verifier_env *env,
 	if (class == BPF_ALU || class == BPF_ALU64) {
 		if (BPF_OP(insn->code) == BPF_END) {
 			if (class == BPF_ALU64)
-				verbose("BUG_alu64_%02x\n", insn->code);
+				verbose(env, "BUG_alu64_%02x\n", insn->code);
 			else
 				print_bpf_end_insn(env, insn);
 		} else if (BPF_OP(insn->code) == BPF_NEG) {
-			verbose("(%02x) r%d = %s-r%d\n",
+			verbose(env, "(%02x) r%d = %s-r%d\n",
 				insn->code, insn->dst_reg,
 				class == BPF_ALU ? "(u32) " : "",
 				insn->dst_reg);
 		} else if (BPF_SRC(insn->code) == BPF_X) {
-			verbose("(%02x) %sr%d %s %sr%d\n",
+			verbose(env, "(%02x) %sr%d %s %sr%d\n",
 				insn->code, class == BPF_ALU ? "(u32) " : "",
 				insn->dst_reg,
 				bpf_alu_string[BPF_OP(insn->code) >> 4],
 				class == BPF_ALU ? "(u32) " : "",
 				insn->src_reg);
 		} else {
-			verbose("(%02x) %sr%d %s %s%d\n",
+			verbose(env, "(%02x) %sr%d %s %s%d\n",
 				insn->code, class == BPF_ALU ? "(u32) " : "",
 				insn->dst_reg,
 				bpf_alu_string[BPF_OP(insn->code) >> 4],
@@ -373,46 +370,46 @@ static void print_bpf_insn(const struct bpf_verifier_env *env,
 		}
 	} else if (class == BPF_STX) {
 		if (BPF_MODE(insn->code) == BPF_MEM)
-			verbose("(%02x) *(%s *)(r%d %+d) = r%d\n",
+			verbose(env, "(%02x) *(%s *)(r%d %+d) = r%d\n",
 				insn->code,
 				bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
 				insn->dst_reg,
 				insn->off, insn->src_reg);
 		else if (BPF_MODE(insn->code) == BPF_XADD)
-			verbose("(%02x) lock *(%s *)(r%d %+d) += r%d\n",
+			verbose(env, "(%02x) lock *(%s *)(r%d %+d) += r%d\n",
 				insn->code,
 				bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
 				insn->dst_reg, insn->off,
 				insn->src_reg);
 		else
-			verbose("BUG_%02x\n", insn->code);
+			verbose(env, "BUG_%02x\n", insn->code);
 	} else if (class == BPF_ST) {
 		if (BPF_MODE(insn->code) != BPF_MEM) {
-			verbose("BUG_st_%02x\n", insn->code);
+			verbose(env, "BUG_st_%02x\n", insn->code);
 			return;
 		}
-		verbose("(%02x) *(%s *)(r%d %+d) = %d\n",
+		verbose(env, "(%02x) *(%s *)(r%d %+d) = %d\n",
 			insn->code,
 			bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
 			insn->dst_reg,
 			insn->off, insn->imm);
 	} else if (class == BPF_LDX) {
 		if (BPF_MODE(insn->code) != BPF_MEM) {
-			verbose("BUG_ldx_%02x\n", insn->code);
+			verbose(env, "BUG_ldx_%02x\n", insn->code);
 			return;
 		}
-		verbose("(%02x) r%d = *(%s *)(r%d %+d)\n",
+		verbose(env, "(%02x) r%d = *(%s *)(r%d %+d)\n",
 			insn->code, insn->dst_reg,
 			bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
 			insn->src_reg, insn->off);
 	} else if (class == BPF_LD) {
 		if (BPF_MODE(insn->code) == BPF_ABS) {
-			verbose("(%02x) r0 = *(%s *)skb[%d]\n",
+			verbose(env, "(%02x) r0 = *(%s *)skb[%d]\n",
 				insn->code,
 				bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
 				insn->imm);
 		} else if (BPF_MODE(insn->code) == BPF_IND) {
-			verbose("(%02x) r0 = *(%s *)skb[r%d + %d]\n",
+			verbose(env, "(%02x) r0 = *(%s *)skb[r%d + %d]\n",
 				insn->code,
 				bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
 				insn->src_reg, insn->imm);
@@ -427,36 +424,37 @@ static void print_bpf_insn(const struct bpf_verifier_env *env,
 			if (map_ptr && !env->allow_ptr_leaks)
 				imm = 0;
 
-			verbose("(%02x) r%d = 0x%llx\n", insn->code,
+			verbose(env, "(%02x) r%d = 0x%llx\n", insn->code,
 				insn->dst_reg, (unsigned long long)imm);
 		} else {
-			verbose("BUG_ld_%02x\n", insn->code);
+			verbose(env, "BUG_ld_%02x\n", insn->code);
 			return;
 		}
 	} else if (class == BPF_JMP) {
 		u8 opcode = BPF_OP(insn->code);
 
 		if (opcode == BPF_CALL) {
-			verbose("(%02x) call %s#%d\n", insn->code,
+			verbose(env, "(%02x) call %s#%d\n", insn->code,
 				func_id_name(insn->imm), insn->imm);
 		} else if (insn->code == (BPF_JMP | BPF_JA)) {
-			verbose("(%02x) goto pc%+d\n",
+			verbose(env, "(%02x) goto pc%+d\n",
 				insn->code, insn->off);
 		} else if (insn->code == (BPF_JMP | BPF_EXIT)) {
-			verbose("(%02x) exit\n", insn->code);
+			verbose(env, "(%02x) exit\n", insn->code);
 		} else if (BPF_SRC(insn->code) == BPF_X) {
-			verbose("(%02x) if r%d %s r%d goto pc%+d\n",
+			verbose(env, "(%02x) if r%d %s r%d goto pc%+d\n",
 				insn->code, insn->dst_reg,
 				bpf_jmp_string[BPF_OP(insn->code) >> 4],
 				insn->src_reg, insn->off);
 		} else {
-			verbose("(%02x) if r%d %s 0x%x goto pc%+d\n",
+			verbose(env, "(%02x) if r%d %s 0x%x goto pc%+d\n",
 				insn->code, insn->dst_reg,
 				bpf_jmp_string[BPF_OP(insn->code) >> 4],
 				insn->imm, insn->off);
 		}
 	} else {
-		verbose("(%02x) %s\n", insn->code, bpf_class_string[class]);
+		verbose(env, "(%02x) %s\n",
+			insn->code, bpf_class_string[class]);
 	}
 }
 
@@ -495,7 +493,7 @@ static struct bpf_verifier_state *push_stack(struct bpf_verifier_env *env,
 	env->head = elem;
 	env->stack_size++;
 	if (env->stack_size > BPF_COMPLEXITY_LIMIT_STACK) {
-		verbose("BPF program is too complex\n");
+		verbose(env, "BPF program is too complex\n");
 		goto err;
 	}
 	return &elem->st;
@@ -533,10 +531,11 @@ static void __mark_reg_known_zero(struct bpf_reg_state *reg)
 	__mark_reg_known(reg, 0);
 }
 
-static void mark_reg_known_zero(struct bpf_reg_state *regs, u32 regno)
+static void mark_reg_known_zero(struct bpf_verifier_env *env,
+				struct bpf_reg_state *regs, u32 regno)
 {
 	if (WARN_ON(regno >= MAX_BPF_REG)) {
-		verbose("mark_reg_known_zero(regs, %u)\n", regno);
+		verbose(env, "mark_reg_known_zero(regs, %u)\n", regno);
 		/* Something bad happened, let's kill all regs */
 		for (regno = 0; regno < MAX_BPF_REG; regno++)
 			__mark_reg_not_init(regs + regno);
@@ -646,10 +645,11 @@ static void __mark_reg_unknown(struct bpf_reg_state *reg)
 	__mark_reg_unbounded(reg);
 }
 
-static void mark_reg_unknown(struct bpf_reg_state *regs, u32 regno)
+static void mark_reg_unknown(struct bpf_verifier_env *env,
+			     struct bpf_reg_state *regs, u32 regno)
 {
 	if (WARN_ON(regno >= MAX_BPF_REG)) {
-		verbose("mark_reg_unknown(regs, %u)\n", regno);
+		verbose(env, "mark_reg_unknown(regs, %u)\n", regno);
 		/* Something bad happened, let's kill all regs */
 		for (regno = 0; regno < MAX_BPF_REG; regno++)
 			__mark_reg_not_init(regs + regno);
@@ -664,10 +664,11 @@ static void __mark_reg_not_init(struct bpf_reg_state *reg)
 	reg->type = NOT_INIT;
 }
 
-static void mark_reg_not_init(struct bpf_reg_state *regs, u32 regno)
+static void mark_reg_not_init(struct bpf_verifier_env *env,
+			      struct bpf_reg_state *regs, u32 regno)
 {
 	if (WARN_ON(regno >= MAX_BPF_REG)) {
-		verbose("mark_reg_not_init(regs, %u)\n", regno);
+		verbose(env, "mark_reg_not_init(regs, %u)\n", regno);
 		/* Something bad happened, let's kill all regs */
 		for (regno = 0; regno < MAX_BPF_REG; regno++)
 			__mark_reg_not_init(regs + regno);
@@ -676,22 +677,23 @@ static void mark_reg_not_init(struct bpf_reg_state *regs, u32 regno)
 	__mark_reg_not_init(regs + regno);
 }
 
-static void init_reg_state(struct bpf_reg_state *regs)
+static void init_reg_state(struct bpf_verifier_env *env,
+			   struct bpf_reg_state *regs)
 {
 	int i;
 
 	for (i = 0; i < MAX_BPF_REG; i++) {
-		mark_reg_not_init(regs, i);
+		mark_reg_not_init(env, regs, i);
 		regs[i].live = REG_LIVE_NONE;
 	}
 
 	/* frame pointer */
 	regs[BPF_REG_FP].type = PTR_TO_STACK;
-	mark_reg_known_zero(regs, BPF_REG_FP);
+	mark_reg_known_zero(env, regs, BPF_REG_FP);
 
 	/* 1st arg to a function */
 	regs[BPF_REG_1].type = PTR_TO_CTX;
-	mark_reg_known_zero(regs, BPF_REG_1);
+	mark_reg_known_zero(env, regs, BPF_REG_1);
 }
 
 enum reg_arg_type {
@@ -721,26 +723,26 @@ static int check_reg_arg(struct bpf_verifier_env *env, u32 regno,
 	struct bpf_reg_state *regs = env->cur_state.regs;
 
 	if (regno >= MAX_BPF_REG) {
-		verbose("R%d is invalid\n", regno);
+		verbose(env, "R%d is invalid\n", regno);
 		return -EINVAL;
 	}
 
 	if (t == SRC_OP) {
 		/* check whether register used as source operand can be read */
 		if (regs[regno].type == NOT_INIT) {
-			verbose("R%d !read_ok\n", regno);
+			verbose(env, "R%d !read_ok\n", regno);
 			return -EACCES;
 		}
 		mark_reg_read(&env->cur_state, regno);
 	} else {
 		/* check whether register used as dest operand can be written to */
 		if (regno == BPF_REG_FP) {
-			verbose("frame pointer is read only\n");
+			verbose(env, "frame pointer is read only\n");
 			return -EACCES;
 		}
 		regs[regno].live |= REG_LIVE_WRITTEN;
 		if (t == DST_OP)
-			mark_reg_unknown(regs, regno);
+			mark_reg_unknown(env, regs, regno);
 	}
 	return 0;
 }
@@ -765,7 +767,8 @@ static bool is_spillable_regtype(enum bpf_reg_type type)
 /* check_stack_read/write functions track spill/fill of registers,
  * stack boundary and alignment are checked in check_mem_access()
  */
-static int check_stack_write(struct bpf_verifier_state *state, int off,
+static int check_stack_write(struct bpf_verifier_env *env,
+			     struct bpf_verifier_state *state, int off,
 			     int size, int value_regno)
 {
 	int i, spi = (MAX_BPF_STACK + off) / BPF_REG_SIZE;
@@ -778,7 +781,7 @@ static int check_stack_write(struct bpf_verifier_state *state, int off,
 
 		/* register containing pointer is being spilled into stack */
 		if (size != BPF_REG_SIZE) {
-			verbose("invalid size of register spill\n");
+			verbose(env, "invalid size of register spill\n");
 			return -EACCES;
 		}
 
@@ -813,7 +816,8 @@ static void mark_stack_slot_read(const struct bpf_verifier_state *state, int slo
 	}
 }
 
-static int check_stack_read(struct bpf_verifier_state *state, int off, int size,
+static int check_stack_read(struct bpf_verifier_env *env,
+			    struct bpf_verifier_state *state, int off, int size,
 			    int value_regno)
 {
 	u8 *slot_type;
@@ -823,12 +827,12 @@ static int check_stack_read(struct bpf_verifier_state *state, int off, int size,
 
 	if (slot_type[0] == STACK_SPILL) {
 		if (size != BPF_REG_SIZE) {
-			verbose("invalid size of register spill\n");
+			verbose(env, "invalid size of register spill\n");
 			return -EACCES;
 		}
 		for (i = 1; i < BPF_REG_SIZE; i++) {
 			if (slot_type[i] != STACK_SPILL) {
-				verbose("corrupted spill memory\n");
+				verbose(env, "corrupted spill memory\n");
 				return -EACCES;
 			}
 		}
@@ -844,14 +848,14 @@ static int check_stack_read(struct bpf_verifier_state *state, int off, int size,
 	} else {
 		for (i = 0; i < size; i++) {
 			if (slot_type[i] != STACK_MISC) {
-				verbose("invalid read from stack off %d+%d size %d\n",
+				verbose(env, "invalid read from stack off %d+%d size %d\n",
 					off, i, size);
 				return -EACCES;
 			}
 		}
 		if (value_regno >= 0)
 			/* have read misc data from the stack */
-			mark_reg_unknown(state->regs, value_regno);
+			mark_reg_unknown(env, state->regs, value_regno);
 		return 0;
 	}
 }
@@ -863,7 +867,7 @@ static int __check_map_access(struct bpf_verifier_env *env, u32 regno, int off,
 	struct bpf_map *map = env->cur_state.regs[regno].map_ptr;
 
 	if (off < 0 || size <= 0 || off + size > map->value_size) {
-		verbose("invalid access to map value, value_size=%d off=%d size=%d\n",
+		verbose(env, "invalid access to map value, value_size=%d off=%d size=%d\n",
 			map->value_size, off, size);
 		return -EACCES;
 	}
@@ -882,8 +886,8 @@ static int check_map_access(struct bpf_verifier_env *env, u32 regno,
 	 * need to try adding each of min_value and max_value to off
 	 * to make sure our theoretical access will be safe.
 	 */
-	if (log_level)
-		print_verifier_state(state);
+	if (env->log_level)
+		print_verifier_state(env, state);
 	/* The minimum value is only important with signed
 	 * comparisons where we can't assume the floor of a
 	 * value is 0.  If we are using signed variables for our
@@ -891,13 +895,14 @@ static int check_map_access(struct bpf_verifier_env *env, u32 regno,
 	 * will have a set floor within our range.
 	 */
 	if (reg->smin_value < 0) {
-		verbose("R%d min value is negative, either use unsigned index or do a if (index >=0) check.\n",
+		verbose(env, "R%d min value is negative, either use unsigned index or do a if (index >=0) check.\n",
 			regno);
 		return -EACCES;
 	}
 	err = __check_map_access(env, regno, reg->smin_value + off, size);
 	if (err) {
-		verbose("R%d min value is outside of the array range\n", regno);
+		verbose(env, "R%d min value is outside of the array range\n",
+			regno);
 		return err;
 	}
 
@@ -906,13 +911,14 @@ static int check_map_access(struct bpf_verifier_env *env, u32 regno,
 	 * If reg->umax_value + off could overflow, treat that as unbounded too.
 	 */
 	if (reg->umax_value >= BPF_MAX_VAR_OFF) {
-		verbose("R%d unbounded memory access, make sure to bounds check any array access into a map\n",
+		verbose(env, "R%d unbounded memory access, make sure to bounds check any array access into a map\n",
 			regno);
 		return -EACCES;
 	}
 	err = __check_map_access(env, regno, reg->umax_value + off, size);
 	if (err)
-		verbose("R%d max value is outside of the array range\n", regno);
+		verbose(env, "R%d max value is outside of the array range\n",
+			regno);
 	return err;
 }
 
@@ -951,7 +957,7 @@ static int __check_packet_access(struct bpf_verifier_env *env, u32 regno,
 	struct bpf_reg_state *reg = &regs[regno];
 
 	if (off < 0 || size <= 0 || (u64)off + size > reg->range) {
-		verbose("invalid access to packet, off=%d size=%d, R%d(id=%d,off=%d,r=%d)\n",
+		verbose(env, "invalid access to packet, off=%d size=%d, R%d(id=%d,off=%d,r=%d)\n",
 			off, size, regno, reg->id, reg->off, reg->range);
 		return -EACCES;
 	}
@@ -974,13 +980,13 @@ static int check_packet_access(struct bpf_verifier_env *env, u32 regno, int off,
 	 * detail to prove they're safe.
 	 */
 	if (reg->smin_value < 0) {
-		verbose("R%d min value is negative, either use unsigned index or do a if (index >=0) check.\n",
+		verbose(env, "R%d min value is negative, either use unsigned index or do a if (index >=0) check.\n",
 			regno);
 		return -EACCES;
 	}
 	err = __check_packet_access(env, regno, off, size);
 	if (err) {
-		verbose("R%d offset is outside of the packet\n", regno);
+		verbose(env, "R%d offset is outside of the packet\n", regno);
 		return err;
 	}
 	return err;
@@ -1016,7 +1022,7 @@ static int check_ctx_access(struct bpf_verifier_env *env, int insn_idx, int off,
 		return 0;
 	}
 
-	verbose("invalid bpf_context access off=%d size=%d\n", off, size);
+	verbose(env, "invalid bpf_context access off=%d size=%d\n", off, size);
 	return -EACCES;
 }
 
@@ -1034,7 +1040,8 @@ static bool is_pointer_value(struct bpf_verifier_env *env, int regno)
 	return __is_pointer_value(env->allow_ptr_leaks, &env->cur_state.regs[regno]);
 }
 
-static int check_pkt_ptr_alignment(const struct bpf_reg_state *reg,
+static int check_pkt_ptr_alignment(struct bpf_verifier_env *env,
+				   const struct bpf_reg_state *reg,
 				   int off, int size, bool strict)
 {
 	struct tnum reg_off;
@@ -1059,7 +1066,8 @@ static int check_pkt_ptr_alignment(const struct bpf_reg_state *reg,
 		char tn_buf[48];
 
 		tnum_strn(tn_buf, sizeof(tn_buf), reg->var_off);
-		verbose("misaligned packet access off %d+%s+%d+%d size %d\n",
+		verbose(env,
+			"misaligned packet access off %d+%s+%d+%d size %d\n",
 			ip_align, tn_buf, reg->off, off, size);
 		return -EACCES;
 	}
@@ -1067,7 +1075,8 @@ static int check_pkt_ptr_alignment(const struct bpf_reg_state *reg,
 	return 0;
 }
 
-static int check_generic_ptr_alignment(const struct bpf_reg_state *reg,
+static int check_generic_ptr_alignment(struct bpf_verifier_env *env,
+				       const struct bpf_reg_state *reg,
 				       const char *pointer_desc,
 				       int off, int size, bool strict)
 {
@@ -1082,7 +1091,7 @@ static int check_generic_ptr_alignment(const struct bpf_reg_state *reg,
 		char tn_buf[48];
 
 		tnum_strn(tn_buf, sizeof(tn_buf), reg->var_off);
-		verbose("misaligned %saccess off %s+%d+%d size %d\n",
+		verbose(env, "misaligned %saccess off %s+%d+%d size %d\n",
 			pointer_desc, tn_buf, reg->off, off, size);
 		return -EACCES;
 	}
@@ -1103,7 +1112,7 @@ static int check_ptr_alignment(struct bpf_verifier_env *env,
 		/* Special case, because of NET_IP_ALIGN. Given metadata sits
 		 * right in front, treat it the very same way.
 		 */
-		return check_pkt_ptr_alignment(reg, off, size, strict);
+		return check_pkt_ptr_alignment(env, reg, off, size, strict);
 	case PTR_TO_MAP_VALUE:
 		pointer_desc = "value ";
 		break;
@@ -1116,7 +1125,8 @@ static int check_ptr_alignment(struct bpf_verifier_env *env,
 	default:
 		break;
 	}
-	return check_generic_ptr_alignment(reg, pointer_desc, off, size, strict);
+	return check_generic_ptr_alignment(env, reg, pointer_desc, off, size,
+					   strict);
 }
 
 /* check whether memory at (regno + off) is accessible for t = (read | write)
@@ -1148,20 +1158,20 @@ static int check_mem_access(struct bpf_verifier_env *env, int insn_idx, u32 regn
 	if (reg->type == PTR_TO_MAP_VALUE) {
 		if (t == BPF_WRITE && value_regno >= 0 &&
 		    is_pointer_value(env, value_regno)) {
-			verbose("R%d leaks addr into map\n", value_regno);
+			verbose(env, "R%d leaks addr into map\n", value_regno);
 			return -EACCES;
 		}
 
 		err = check_map_access(env, regno, off, size);
 		if (!err && t == BPF_READ && value_regno >= 0)
-			mark_reg_unknown(state->regs, value_regno);
+			mark_reg_unknown(env, state->regs, value_regno);
 
 	} else if (reg->type == PTR_TO_CTX) {
 		enum bpf_reg_type reg_type = SCALAR_VALUE;
 
 		if (t == BPF_WRITE && value_regno >= 0 &&
 		    is_pointer_value(env, value_regno)) {
-			verbose("R%d leaks addr into ctx\n", value_regno);
+			verbose(env, "R%d leaks addr into ctx\n", value_regno);
 			return -EACCES;
 		}
 		/* ctx accesses must be at a fixed offset, so that we can
@@ -1171,7 +1181,8 @@ static int check_mem_access(struct bpf_verifier_env *env, int insn_idx, u32 regn
 			char tn_buf[48];
 
 			tnum_strn(tn_buf, sizeof(tn_buf), reg->var_off);
-			verbose("variable ctx access var_off=%s off=%d size=%d",
+			verbose(env,
+				"variable ctx access var_off=%s off=%d size=%d",
 				tn_buf, off, size);
 			return -EACCES;
 		}
@@ -1183,9 +1194,10 @@ static int check_mem_access(struct bpf_verifier_env *env, int insn_idx, u32 regn
 			 * case, we know the offset is zero.
 			 */
 			if (reg_type == SCALAR_VALUE)
-				mark_reg_unknown(state->regs, value_regno);
+				mark_reg_unknown(env, state->regs, value_regno);
 			else
-				mark_reg_known_zero(state->regs, value_regno);
+				mark_reg_known_zero(env, state->regs,
+						    value_regno);
 			state->regs[value_regno].id = 0;
 			state->regs[value_regno].off = 0;
 			state->regs[value_regno].range = 0;
@@ -1201,13 +1213,14 @@ static int check_mem_access(struct bpf_verifier_env *env, int insn_idx, u32 regn
 			char tn_buf[48];
 
 			tnum_strn(tn_buf, sizeof(tn_buf), reg->var_off);
-			verbose("variable stack access var_off=%s off=%d size=%d",
+			verbose(env, "variable stack access var_off=%s off=%d size=%d",
 				tn_buf, off, size);
 			return -EACCES;
 		}
 		off += reg->var_off.value;
 		if (off >= 0 || off < -MAX_BPF_STACK) {
-			verbose("invalid stack off=%d size=%d\n", off, size);
+			verbose(env, "invalid stack off=%d size=%d\n", off,
+				size);
 			return -EACCES;
 		}
 
@@ -1218,29 +1231,32 @@ static int check_mem_access(struct bpf_verifier_env *env, int insn_idx, u32 regn
 			if (!env->allow_ptr_leaks &&
 			    state->stack_slot_type[MAX_BPF_STACK + off] == STACK_SPILL &&
 			    size != BPF_REG_SIZE) {
-				verbose("attempt to corrupt spilled pointer on stack\n");
+				verbose(env, "attempt to corrupt spilled pointer on stack\n");
 				return -EACCES;
 			}
-			err = check_stack_write(state, off, size, value_regno);
+			err = check_stack_write(env, state, off, size,
+						value_regno);
 		} else {
-			err = check_stack_read(state, off, size, value_regno);
+			err = check_stack_read(env, state, off, size,
+					       value_regno);
 		}
 	} else if (reg_is_pkt_pointer(reg)) {
 		if (t == BPF_WRITE && !may_access_direct_pkt_data(env, NULL, t)) {
-			verbose("cannot write into packet\n");
+			verbose(env, "cannot write into packet\n");
 			return -EACCES;
 		}
 		if (t == BPF_WRITE && value_regno >= 0 &&
 		    is_pointer_value(env, value_regno)) {
-			verbose("R%d leaks addr into packet\n", value_regno);
+			verbose(env, "R%d leaks addr into packet\n",
+				value_regno);
 			return -EACCES;
 		}
 		err = check_packet_access(env, regno, off, size);
 		if (!err && t == BPF_READ && value_regno >= 0)
-			mark_reg_unknown(state->regs, value_regno);
+			mark_reg_unknown(env, state->regs, value_regno);
 	} else {
-		verbose("R%d invalid mem access '%s'\n",
-			regno, reg_type_str[reg->type]);
+		verbose(env, "R%d invalid mem access '%s'\n", regno,
+			reg_type_str[reg->type]);
 		return -EACCES;
 	}
 
@@ -1260,7 +1276,7 @@ static int check_xadd(struct bpf_verifier_env *env, int insn_idx, struct bpf_ins
 
 	if ((BPF_SIZE(insn->code) != BPF_W && BPF_SIZE(insn->code) != BPF_DW) ||
 	    insn->imm != 0) {
-		verbose("BPF_XADD uses reserved fields\n");
+		verbose(env, "BPF_XADD uses reserved fields\n");
 		return -EINVAL;
 	}
 
@@ -1275,7 +1291,7 @@ static int check_xadd(struct bpf_verifier_env *env, int insn_idx, struct bpf_ins
 		return err;
 
 	if (is_pointer_value(env, insn->src_reg)) {
-		verbose("R%d leaks addr into mem\n", insn->src_reg);
+		verbose(env, "R%d leaks addr into mem\n", insn->src_reg);
 		return -EACCES;
 	}
 
@@ -1316,7 +1332,7 @@ static int check_stack_boundary(struct bpf_verifier_env *env, int regno,
 		    register_is_null(regs[regno]))
 			return 0;
 
-		verbose("R%d type=%s expected=%s\n", regno,
+		verbose(env, "R%d type=%s expected=%s\n", regno,
 			reg_type_str[regs[regno].type],
 			reg_type_str[PTR_TO_STACK]);
 		return -EACCES;
@@ -1327,13 +1343,13 @@ static int check_stack_boundary(struct bpf_verifier_env *env, int regno,
 		char tn_buf[48];
 
 		tnum_strn(tn_buf, sizeof(tn_buf), regs[regno].var_off);
-		verbose("invalid variable stack read R%d var_off=%s\n",
+		verbose(env, "invalid variable stack read R%d var_off=%s\n",
 			regno, tn_buf);
 	}
 	off = regs[regno].off + regs[regno].var_off.value;
 	if (off >= 0 || off < -MAX_BPF_STACK || off + access_size > 0 ||
 	    access_size <= 0) {
-		verbose("invalid stack type R%d off=%d access_size=%d\n",
+		verbose(env, "invalid stack type R%d off=%d access_size=%d\n",
 			regno, off, access_size);
 		return -EACCES;
 	}
@@ -1349,7 +1365,7 @@ static int check_stack_boundary(struct bpf_verifier_env *env, int regno,
 
 	for (i = 0; i < access_size; i++) {
 		if (state->stack_slot_type[MAX_BPF_STACK + off + i] != STACK_MISC) {
-			verbose("invalid indirect read from stack off %d+%d size %d\n",
+			verbose(env, "invalid indirect read from stack off %d+%d size %d\n",
 				off, i, access_size);
 			return -EACCES;
 		}
@@ -1392,7 +1408,8 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 
 	if (arg_type == ARG_ANYTHING) {
 		if (is_pointer_value(env, regno)) {
-			verbose("R%d leaks addr into helper function\n", regno);
+			verbose(env, "R%d leaks addr into helper function\n",
+				regno);
 			return -EACCES;
 		}
 		return 0;
@@ -1400,7 +1417,7 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 
 	if (type_is_pkt_pointer(type) &&
 	    !may_access_direct_pkt_data(env, meta, BPF_READ)) {
-		verbose("helper access to the packet is not allowed\n");
+		verbose(env, "helper access to the packet is not allowed\n");
 		return -EACCES;
 	}
 
@@ -1438,7 +1455,7 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 			goto err_type;
 		meta->raw_mode = arg_type == ARG_PTR_TO_UNINIT_MEM;
 	} else {
-		verbose("unsupported arg_type %d\n", arg_type);
+		verbose(env, "unsupported arg_type %d\n", arg_type);
 		return -EFAULT;
 	}
 
@@ -1456,7 +1473,7 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 			 * we have to check map_key here. Otherwise it means
 			 * that kernel subsystem misconfigured verifier
 			 */
-			verbose("invalid map_ptr to access map->key\n");
+			verbose(env, "invalid map_ptr to access map->key\n");
 			return -EACCES;
 		}
 		if (type_is_pkt_pointer(type))
@@ -1472,7 +1489,7 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 		 */
 		if (!meta->map_ptr) {
 			/* kernel subsystem misconfigured verifier */
-			verbose("invalid map_ptr to access map->value\n");
+			verbose(env, "invalid map_ptr to access map->value\n");
 			return -EACCES;
 		}
 		if (type_is_pkt_pointer(type))
@@ -1492,7 +1509,8 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 		 */
 		if (regno == 0) {
 			/* kernel subsystem misconfigured verifier */
-			verbose("ARG_CONST_SIZE cannot be first argument\n");
+			verbose(env,
+				"ARG_CONST_SIZE cannot be first argument\n");
 			return -EACCES;
 		}
 
@@ -1509,7 +1527,7 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 			meta = NULL;
 
 		if (reg->smin_value < 0) {
-			verbose("R%d min value is negative, either use unsigned or 'var &= const'\n",
+			verbose(env, "R%d min value is negative, either use unsigned or 'var &= const'\n",
 				regno);
 			return -EACCES;
 		}
@@ -1523,7 +1541,7 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 		}
 
 		if (reg->umax_value >= BPF_MAX_VAR_SIZ) {
-			verbose("R%d unbounded memory access, use 'var &= const' or 'if (var < const)'\n",
+			verbose(env, "R%d unbounded memory access, use 'var &= const' or 'if (var < const)'\n",
 				regno);
 			return -EACCES;
 		}
@@ -1534,12 +1552,13 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 
 	return err;
 err_type:
-	verbose("R%d type=%s expected=%s\n", regno,
+	verbose(env, "R%d type=%s expected=%s\n", regno,
 		reg_type_str[type], reg_type_str[expected_type]);
 	return -EACCES;
 }
 
-static int check_map_func_compatibility(struct bpf_map *map, int func_id)
+static int check_map_func_compatibility(struct bpf_verifier_env *env,
+					struct bpf_map *map, int func_id)
 {
 	if (!map)
 		return 0;
@@ -1625,7 +1644,7 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
 
 	return 0;
 error:
-	verbose("cannot pass map_type %d into func %s#%d\n",
+	verbose(env, "cannot pass map_type %d into func %s#%d\n",
 		map->map_type, func_id_name(func_id), func_id);
 	return -EINVAL;
 }
@@ -1659,7 +1678,7 @@ static void clear_all_pkt_pointers(struct bpf_verifier_env *env)
 
 	for (i = 0; i < MAX_BPF_REG; i++)
 		if (reg_is_pkt_pointer_any(&regs[i]))
-			mark_reg_unknown(regs, i);
+			mark_reg_unknown(env, regs, i);
 
 	for (i = 0; i < MAX_BPF_STACK; i += BPF_REG_SIZE) {
 		if (state->stack_slot_type[i] != STACK_SPILL)
@@ -1681,7 +1700,8 @@ static int check_call(struct bpf_verifier_env *env, int func_id, int insn_idx)
 
 	/* find function prototype */
 	if (func_id < 0 || func_id >= __BPF_FUNC_MAX_ID) {
-		verbose("invalid func %s#%d\n", func_id_name(func_id), func_id);
+		verbose(env, "invalid func %s#%d\n", func_id_name(func_id),
+			func_id);
 		return -EINVAL;
 	}
 
@@ -1689,13 +1709,14 @@ static int check_call(struct bpf_verifier_env *env, int func_id, int insn_idx)
 		fn = env->prog->aux->ops->get_func_proto(func_id);
 
 	if (!fn) {
-		verbose("unknown func %s#%d\n", func_id_name(func_id), func_id);
+		verbose(env, "unknown func %s#%d\n", func_id_name(func_id),
+			func_id);
 		return -EINVAL;
 	}
 
 	/* eBPF programs must be GPL compatible to use GPL-ed functions */
 	if (!env->prog->gpl_compatible && fn->gpl_only) {
-		verbose("cannot call GPL only function from proprietary program\n");
+		verbose(env, "cannot call GPL only function from proprietary program\n");
 		return -EINVAL;
 	}
 
@@ -1709,7 +1730,7 @@ static int check_call(struct bpf_verifier_env *env, int func_id, int insn_idx)
 	 */
 	err = check_raw_mode(fn);
 	if (err) {
-		verbose("kernel subsystem misconfigured func %s#%d\n",
+		verbose(env, "kernel subsystem misconfigured func %s#%d\n",
 			func_id_name(func_id), func_id);
 		return err;
 	}
@@ -1742,14 +1763,14 @@ static int check_call(struct bpf_verifier_env *env, int func_id, int insn_idx)
 
 	/* reset caller saved regs */
 	for (i = 0; i < CALLER_SAVED_REGS; i++) {
-		mark_reg_not_init(regs, caller_saved[i]);
+		mark_reg_not_init(env, regs, caller_saved[i]);
 		check_reg_arg(env, caller_saved[i], DST_OP_NO_MARK);
 	}
 
 	/* update return register (already marked as written above) */
 	if (fn->ret_type == RET_INTEGER) {
 		/* sets type to SCALAR_VALUE */
-		mark_reg_unknown(regs, BPF_REG_0);
+		mark_reg_unknown(env, regs, BPF_REG_0);
 	} else if (fn->ret_type == RET_VOID) {
 		regs[BPF_REG_0].type = NOT_INIT;
 	} else if (fn->ret_type == RET_PTR_TO_MAP_VALUE_OR_NULL) {
@@ -1757,14 +1778,15 @@ static int check_call(struct bpf_verifier_env *env, int func_id, int insn_idx)
 
 		regs[BPF_REG_0].type = PTR_TO_MAP_VALUE_OR_NULL;
 		/* There is no offset yet applied, variable or fixed */
-		mark_reg_known_zero(regs, BPF_REG_0);
+		mark_reg_known_zero(env, regs, BPF_REG_0);
 		regs[BPF_REG_0].off = 0;
 		/* remember map_ptr, so that check_map_access()
 		 * can check 'value_size' boundary of memory access
 		 * to map element returned from bpf_map_lookup_elem()
 		 */
 		if (meta.map_ptr == NULL) {
-			verbose("kernel subsystem misconfigured verifier\n");
+			verbose(env,
+				"kernel subsystem misconfigured verifier\n");
 			return -EINVAL;
 		}
 		regs[BPF_REG_0].map_ptr = meta.map_ptr;
@@ -1775,12 +1797,12 @@ static int check_call(struct bpf_verifier_env *env, int func_id, int insn_idx)
 		else if (insn_aux->map_ptr != meta.map_ptr)
 			insn_aux->map_ptr = BPF_MAP_PTR_POISON;
 	} else {
-		verbose("unknown return type %d of func %s#%d\n",
+		verbose(env, "unknown return type %d of func %s#%d\n",
 			fn->ret_type, func_id_name(func_id), func_id);
 		return -EINVAL;
 	}
 
-	err = check_map_func_compatibility(meta.map_ptr, func_id);
+	err = check_map_func_compatibility(env, meta.map_ptr, func_id);
 	if (err)
 		return err;
 
@@ -1839,39 +1861,42 @@ static int adjust_ptr_min_max_vals(struct bpf_verifier_env *env,
 	dst_reg = &regs[dst];
 
 	if (WARN_ON_ONCE(known && (smin_val != smax_val))) {
-		print_verifier_state(&env->cur_state);
-		verbose("verifier internal error: known but bad sbounds\n");
+		print_verifier_state(env, &env->cur_state);
+		verbose(env,
+			"verifier internal error: known but bad sbounds\n");
 		return -EINVAL;
 	}
 	if (WARN_ON_ONCE(known && (umin_val != umax_val))) {
-		print_verifier_state(&env->cur_state);
-		verbose("verifier internal error: known but bad ubounds\n");
+		print_verifier_state(env, &env->cur_state);
+		verbose(env,
+			"verifier internal error: known but bad ubounds\n");
 		return -EINVAL;
 	}
 
 	if (BPF_CLASS(insn->code) != BPF_ALU64) {
 		/* 32-bit ALU ops on pointers produce (meaningless) scalars */
 		if (!env->allow_ptr_leaks)
-			verbose("R%d 32-bit pointer arithmetic prohibited\n",
+			verbose(env,
+				"R%d 32-bit pointer arithmetic prohibited\n",
 				dst);
 		return -EACCES;
 	}
 
 	if (ptr_reg->type == PTR_TO_MAP_VALUE_OR_NULL) {
 		if (!env->allow_ptr_leaks)
-			verbose("R%d pointer arithmetic on PTR_TO_MAP_VALUE_OR_NULL prohibited, null-check it first\n",
+			verbose(env, "R%d pointer arithmetic on PTR_TO_MAP_VALUE_OR_NULL prohibited, null-check it first\n",
 				dst);
 		return -EACCES;
 	}
 	if (ptr_reg->type == CONST_PTR_TO_MAP) {
 		if (!env->allow_ptr_leaks)
-			verbose("R%d pointer arithmetic on CONST_PTR_TO_MAP prohibited\n",
+			verbose(env, "R%d pointer arithmetic on CONST_PTR_TO_MAP prohibited\n",
 				dst);
 		return -EACCES;
 	}
 	if (ptr_reg->type == PTR_TO_PACKET_END) {
 		if (!env->allow_ptr_leaks)
-			verbose("R%d pointer arithmetic on PTR_TO_PACKET_END prohibited\n",
+			verbose(env, "R%d pointer arithmetic on PTR_TO_PACKET_END prohibited\n",
 				dst);
 		return -EACCES;
 	}
@@ -1936,7 +1961,7 @@ static int adjust_ptr_min_max_vals(struct bpf_verifier_env *env,
 		if (dst_reg == off_reg) {
 			/* scalar -= pointer.  Creates an unknown scalar */
 			if (!env->allow_ptr_leaks)
-				verbose("R%d tried to subtract pointer from scalar\n",
+				verbose(env, "R%d tried to subtract pointer from scalar\n",
 					dst);
 			return -EACCES;
 		}
@@ -1946,7 +1971,7 @@ static int adjust_ptr_min_max_vals(struct bpf_verifier_env *env,
 		 */
 		if (ptr_reg->type == PTR_TO_STACK) {
 			if (!env->allow_ptr_leaks)
-				verbose("R%d subtraction from stack pointer prohibited\n",
+				verbose(env, "R%d subtraction from stack pointer prohibited\n",
 					dst);
 			return -EACCES;
 		}
@@ -2001,13 +2026,13 @@ static int adjust_ptr_min_max_vals(struct bpf_verifier_env *env,
 		 * ptr &= ~3 which would reduce min_value by 3.)
 		 */
 		if (!env->allow_ptr_leaks)
-			verbose("R%d bitwise operator %s on pointer prohibited\n",
+			verbose(env, "R%d bitwise operator %s on pointer prohibited\n",
 				dst, bpf_alu_string[opcode >> 4]);
 		return -EACCES;
 	default:
 		/* other operators (e.g. MUL,LSH) produce non-pointer results */
 		if (!env->allow_ptr_leaks)
-			verbose("R%d pointer arithmetic with %s operator prohibited\n",
+			verbose(env, "R%d pointer arithmetic with %s operator prohibited\n",
 				dst, bpf_alu_string[opcode >> 4]);
 		return -EACCES;
 	}
@@ -2173,7 +2198,7 @@ static int adjust_scalar_min_max_vals(struct bpf_verifier_env *env,
 			/* Shifts greater than 63 are undefined.  This includes
 			 * shifts by a negative number.
 			 */
-			mark_reg_unknown(regs, insn->dst_reg);
+			mark_reg_unknown(env, regs, insn->dst_reg);
 			break;
 		}
 		/* We lose all sign bit information (except what we can pick
@@ -2201,7 +2226,7 @@ static int adjust_scalar_min_max_vals(struct bpf_verifier_env *env,
 			/* Shifts greater than 63 are undefined.  This includes
 			 * shifts by a negative number.
 			 */
-			mark_reg_unknown(regs, insn->dst_reg);
+			mark_reg_unknown(env, regs, insn->dst_reg);
 			break;
 		}
 		/* BPF_RSH is an unsigned shift, so make the appropriate casts */
@@ -2229,7 +2254,7 @@ static int adjust_scalar_min_max_vals(struct bpf_verifier_env *env,
 		__update_reg_bounds(dst_reg);
 		break;
 	default:
-		mark_reg_unknown(regs, insn->dst_reg);
+		mark_reg_unknown(env, regs, insn->dst_reg);
 		break;
 	}
 
@@ -2261,12 +2286,12 @@ static int adjust_reg_min_max_vals(struct bpf_verifier_env *env,
 				 * an arbitrary scalar.
 				 */
 				if (!env->allow_ptr_leaks) {
-					verbose("R%d pointer %s pointer prohibited\n",
+					verbose(env, "R%d pointer %s pointer prohibited\n",
 						insn->dst_reg,
 						bpf_alu_string[opcode >> 4]);
 					return -EACCES;
 				}
-				mark_reg_unknown(regs, insn->dst_reg);
+				mark_reg_unknown(env, regs, insn->dst_reg);
 				return 0;
 			} else {
 				/* scalar += pointer
@@ -2318,13 +2343,13 @@ static int adjust_reg_min_max_vals(struct bpf_verifier_env *env,
 
 	/* Got here implies adding two SCALAR_VALUEs */
 	if (WARN_ON_ONCE(ptr_reg)) {
-		print_verifier_state(&env->cur_state);
-		verbose("verifier internal error: unexpected ptr_reg\n");
+		print_verifier_state(env, &env->cur_state);
+		verbose(env, "verifier internal error: unexpected ptr_reg\n");
 		return -EINVAL;
 	}
 	if (WARN_ON(!src_reg)) {
-		print_verifier_state(&env->cur_state);
-		verbose("verifier internal error: no src_reg\n");
+		print_verifier_state(env, &env->cur_state);
+		verbose(env, "verifier internal error: no src_reg\n");
 		return -EINVAL;
 	}
 	return adjust_scalar_min_max_vals(env, insn, dst_reg, *src_reg);
@@ -2342,14 +2367,14 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 			if (BPF_SRC(insn->code) != 0 ||
 			    insn->src_reg != BPF_REG_0 ||
 			    insn->off != 0 || insn->imm != 0) {
-				verbose("BPF_NEG uses reserved fields\n");
+				verbose(env, "BPF_NEG uses reserved fields\n");
 				return -EINVAL;
 			}
 		} else {
 			if (insn->src_reg != BPF_REG_0 || insn->off != 0 ||
 			    (insn->imm != 16 && insn->imm != 32 && insn->imm != 64) ||
 			    BPF_CLASS(insn->code) == BPF_ALU64) {
-				verbose("BPF_END uses reserved fields\n");
+				verbose(env, "BPF_END uses reserved fields\n");
 				return -EINVAL;
 			}
 		}
@@ -2360,7 +2385,7 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 			return err;
 
 		if (is_pointer_value(env, insn->dst_reg)) {
-			verbose("R%d pointer arithmetic prohibited\n",
+			verbose(env, "R%d pointer arithmetic prohibited\n",
 				insn->dst_reg);
 			return -EACCES;
 		}
@@ -2374,7 +2399,7 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 
 		if (BPF_SRC(insn->code) == BPF_X) {
 			if (insn->imm != 0 || insn->off != 0) {
-				verbose("BPF_MOV uses reserved fields\n");
+				verbose(env, "BPF_MOV uses reserved fields\n");
 				return -EINVAL;
 			}
 
@@ -2384,7 +2409,7 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 				return err;
 		} else {
 			if (insn->src_reg != BPF_REG_0 || insn->off != 0) {
-				verbose("BPF_MOV uses reserved fields\n");
+				verbose(env, "BPF_MOV uses reserved fields\n");
 				return -EINVAL;
 			}
 		}
@@ -2403,11 +2428,12 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 			} else {
 				/* R1 = (u32) R2 */
 				if (is_pointer_value(env, insn->src_reg)) {
-					verbose("R%d partial copy of pointer\n",
+					verbose(env,
+						"R%d partial copy of pointer\n",
 						insn->src_reg);
 					return -EACCES;
 				}
-				mark_reg_unknown(regs, insn->dst_reg);
+				mark_reg_unknown(env, regs, insn->dst_reg);
 				/* high 32 bits are known zero. */
 				regs[insn->dst_reg].var_off = tnum_cast(
 						regs[insn->dst_reg].var_off, 4);
@@ -2422,14 +2448,14 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 		}
 
 	} else if (opcode > BPF_END) {
-		verbose("invalid BPF_ALU opcode %x\n", opcode);
+		verbose(env, "invalid BPF_ALU opcode %x\n", opcode);
 		return -EINVAL;
 
 	} else {	/* all other ALU ops: and, sub, xor, add, ... */
 
 		if (BPF_SRC(insn->code) == BPF_X) {
 			if (insn->imm != 0 || insn->off != 0) {
-				verbose("BPF_ALU uses reserved fields\n");
+				verbose(env, "BPF_ALU uses reserved fields\n");
 				return -EINVAL;
 			}
 			/* check src1 operand */
@@ -2438,7 +2464,7 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 				return err;
 		} else {
 			if (insn->src_reg != BPF_REG_0 || insn->off != 0) {
-				verbose("BPF_ALU uses reserved fields\n");
+				verbose(env, "BPF_ALU uses reserved fields\n");
 				return -EINVAL;
 			}
 		}
@@ -2450,7 +2476,7 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 
 		if ((opcode == BPF_MOD || opcode == BPF_DIV) &&
 		    BPF_SRC(insn->code) == BPF_K && insn->imm == 0) {
-			verbose("div by zero\n");
+			verbose(env, "div by zero\n");
 			return -EINVAL;
 		}
 
@@ -2459,7 +2485,7 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 			int size = BPF_CLASS(insn->code) == BPF_ALU64 ? 64 : 32;
 
 			if (insn->imm < 0 || insn->imm >= size) {
-				verbose("invalid shift %d\n", insn->imm);
+				verbose(env, "invalid shift %d\n", insn->imm);
 				return -EINVAL;
 			}
 		}
@@ -2812,13 +2838,13 @@ static int check_cond_jmp_op(struct bpf_verifier_env *env,
 	int err;
 
 	if (opcode > BPF_JSLE) {
-		verbose("invalid BPF_JMP opcode %x\n", opcode);
+		verbose(env, "invalid BPF_JMP opcode %x\n", opcode);
 		return -EINVAL;
 	}
 
 	if (BPF_SRC(insn->code) == BPF_X) {
 		if (insn->imm != 0) {
-			verbose("BPF_JMP uses reserved fields\n");
+			verbose(env, "BPF_JMP uses reserved fields\n");
 			return -EINVAL;
 		}
 
@@ -2828,13 +2854,13 @@ static int check_cond_jmp_op(struct bpf_verifier_env *env,
 			return err;
 
 		if (is_pointer_value(env, insn->src_reg)) {
-			verbose("R%d pointer comparison prohibited\n",
+			verbose(env, "R%d pointer comparison prohibited\n",
 				insn->src_reg);
 			return -EACCES;
 		}
 	} else {
 		if (insn->src_reg != BPF_REG_0) {
-			verbose("BPF_JMP uses reserved fields\n");
+			verbose(env, "BPF_JMP uses reserved fields\n");
 			return -EINVAL;
 		}
 	}
@@ -2946,11 +2972,12 @@ static int check_cond_jmp_op(struct bpf_verifier_env *env,
 		find_good_pkt_pointers(this_branch, &regs[insn->src_reg],
 				       PTR_TO_PACKET_META);
 	} else if (is_pointer_value(env, insn->dst_reg)) {
-		verbose("R%d pointer comparison prohibited\n", insn->dst_reg);
+		verbose(env, "R%d pointer comparison prohibited\n",
+			insn->dst_reg);
 		return -EACCES;
 	}
-	if (log_level)
-		print_verifier_state(this_branch);
+	if (env->log_level)
+		print_verifier_state(env, this_branch);
 	return 0;
 }
 
@@ -2969,11 +2996,11 @@ static int check_ld_imm(struct bpf_verifier_env *env, struct bpf_insn *insn)
 	int err;
 
 	if (BPF_SIZE(insn->code) != BPF_DW) {
-		verbose("invalid BPF_LD_IMM insn\n");
+		verbose(env, "invalid BPF_LD_IMM insn\n");
 		return -EINVAL;
 	}
 	if (insn->off != 0) {
-		verbose("BPF_LD_IMM64 uses reserved fields\n");
+		verbose(env, "BPF_LD_IMM64 uses reserved fields\n");
 		return -EINVAL;
 	}
 
@@ -3031,14 +3058,14 @@ static int check_ld_abs(struct bpf_verifier_env *env, struct bpf_insn *insn)
 	int i, err;
 
 	if (!may_access_skb(env->prog->type)) {
-		verbose("BPF_LD_[ABS|IND] instructions not allowed for this program type\n");
+		verbose(env, "BPF_LD_[ABS|IND] instructions not allowed for this program type\n");
 		return -EINVAL;
 	}
 
 	if (insn->dst_reg != BPF_REG_0 || insn->off != 0 ||
 	    BPF_SIZE(insn->code) == BPF_DW ||
 	    (mode == BPF_ABS && insn->src_reg != BPF_REG_0)) {
-		verbose("BPF_LD_[ABS|IND] uses reserved fields\n");
+		verbose(env, "BPF_LD_[ABS|IND] uses reserved fields\n");
 		return -EINVAL;
 	}
 
@@ -3048,7 +3075,8 @@ static int check_ld_abs(struct bpf_verifier_env *env, struct bpf_insn *insn)
 		return err;
 
 	if (regs[BPF_REG_6].type != PTR_TO_CTX) {
-		verbose("at the time of BPF_LD_ABS|IND R6 != pointer to skb\n");
+		verbose(env,
+			"at the time of BPF_LD_ABS|IND R6 != pointer to skb\n");
 		return -EINVAL;
 	}
 
@@ -3061,7 +3089,7 @@ static int check_ld_abs(struct bpf_verifier_env *env, struct bpf_insn *insn)
 
 	/* reset caller saved regs to unreadable */
 	for (i = 0; i < CALLER_SAVED_REGS; i++) {
-		mark_reg_not_init(regs, caller_saved[i]);
+		mark_reg_not_init(env, regs, caller_saved[i]);
 		check_reg_arg(env, caller_saved[i], DST_OP_NO_MARK);
 	}
 
@@ -3069,7 +3097,7 @@ static int check_ld_abs(struct bpf_verifier_env *env, struct bpf_insn *insn)
 	 * the value fetched from the packet.
 	 * Already marked as written above.
 	 */
-	mark_reg_unknown(regs, BPF_REG_0);
+	mark_reg_unknown(env, regs, BPF_REG_0);
 	return 0;
 }
 
@@ -3089,22 +3117,22 @@ static int check_return_code(struct bpf_verifier_env *env)
 
 	reg = &env->cur_state.regs[BPF_REG_0];
 	if (reg->type != SCALAR_VALUE) {
-		verbose("At program exit the register R0 is not a known value (%s)\n",
+		verbose(env, "At program exit the register R0 is not a known value (%s)\n",
 			reg_type_str[reg->type]);
 		return -EINVAL;
 	}
 
 	if (!tnum_in(range, reg->var_off)) {
-		verbose("At program exit the register R0 ");
+		verbose(env, "At program exit the register R0 ");
 		if (!tnum_is_unknown(reg->var_off)) {
 			char tn_buf[48];
 
 			tnum_strn(tn_buf, sizeof(tn_buf), reg->var_off);
-			verbose("has value %s", tn_buf);
+			verbose(env, "has value %s", tn_buf);
 		} else {
-			verbose("has unknown scalar value");
+			verbose(env, "has unknown scalar value");
 		}
-		verbose(" should have been 0 or 1\n");
+		verbose(env, " should have been 0 or 1\n");
 		return -EINVAL;
 	}
 	return 0;
@@ -3170,7 +3198,7 @@ static int push_insn(int t, int w, int e, struct bpf_verifier_env *env)
 		return 0;
 
 	if (w < 0 || w >= env->prog->len) {
-		verbose("jump out of range from insn %d to %d\n", t, w);
+		verbose(env, "jump out of range from insn %d to %d\n", t, w);
 		return -EINVAL;
 	}
 
@@ -3187,13 +3215,13 @@ static int push_insn(int t, int w, int e, struct bpf_verifier_env *env)
 		insn_stack[cur_stack++] = w;
 		return 1;
 	} else if ((insn_state[w] & 0xF0) == DISCOVERED) {
-		verbose("back-edge from insn %d to %d\n", t, w);
+		verbose(env, "back-edge from insn %d to %d\n", t, w);
 		return -EINVAL;
 	} else if (insn_state[w] == EXPLORED) {
 		/* forward- or cross-edge */
 		insn_state[t] = DISCOVERED | e;
 	} else {
-		verbose("insn state internal bug\n");
+		verbose(env, "insn state internal bug\n");
 		return -EFAULT;
 	}
 	return 0;
@@ -3287,7 +3315,7 @@ static int check_cfg(struct bpf_verifier_env *env)
 mark_explored:
 	insn_state[t] = EXPLORED;
 	if (cur_stack-- <= 0) {
-		verbose("pop stack internal bug\n");
+		verbose(env, "pop stack internal bug\n");
 		ret = -EFAULT;
 		goto err_free;
 	}
@@ -3296,7 +3324,7 @@ static int check_cfg(struct bpf_verifier_env *env)
 check_state:
 	for (i = 0; i < insn_cnt; i++) {
 		if (insn_state[i] != EXPLORED) {
-			verbose("unreachable insn %d\n", i);
+			verbose(env, "unreachable insn %d\n", i);
 			ret = -EINVAL;
 			goto err_free;
 		}
@@ -3677,7 +3705,7 @@ static int do_check(struct bpf_verifier_env *env)
 	int insn_processed = 0;
 	bool do_print_state = false;
 
-	init_reg_state(regs);
+	init_reg_state(env, regs);
 	state->parent = NULL;
 	insn_idx = 0;
 	for (;;) {
@@ -3686,7 +3714,7 @@ static int do_check(struct bpf_verifier_env *env)
 		int err;
 
 		if (insn_idx >= insn_cnt) {
-			verbose("invalid insn idx %d insn_cnt %d\n",
+			verbose(env, "invalid insn idx %d insn_cnt %d\n",
 				insn_idx, insn_cnt);
 			return -EFAULT;
 		}
@@ -3695,7 +3723,8 @@ static int do_check(struct bpf_verifier_env *env)
 		class = BPF_CLASS(insn->code);
 
 		if (++insn_processed > BPF_COMPLEXITY_LIMIT_INSNS) {
-			verbose("BPF program is too large. Processed %d insn\n",
+			verbose(env,
+				"BPF program is too large. Processed %d insn\n",
 				insn_processed);
 			return -E2BIG;
 		}
@@ -3705,12 +3734,12 @@ static int do_check(struct bpf_verifier_env *env)
 			return err;
 		if (err == 1) {
 			/* found equivalent state, can prune the search */
-			if (log_level) {
+			if (env->log_level) {
 				if (do_print_state)
-					verbose("\nfrom %d to %d: safe\n",
+					verbose(env, "\nfrom %d to %d: safe\n",
 						prev_insn_idx, insn_idx);
 				else
-					verbose("%d: safe\n", insn_idx);
+					verbose(env, "%d: safe\n", insn_idx);
 			}
 			goto process_bpf_exit;
 		}
@@ -3718,18 +3747,18 @@ static int do_check(struct bpf_verifier_env *env)
 		if (need_resched())
 			cond_resched();
 
-		if (log_level > 1 || (log_level && do_print_state)) {
-			if (log_level > 1)
-				verbose("%d:", insn_idx);
+		if (env->log_level > 1 || (env->log_level && do_print_state)) {
+			if (env->log_level > 1)
+				verbose(env, "%d:", insn_idx);
 			else
-				verbose("\nfrom %d to %d:",
+				verbose(env, "\nfrom %d to %d:",
 					prev_insn_idx, insn_idx);
-			print_verifier_state(&env->cur_state);
+			print_verifier_state(env, &env->cur_state);
 			do_print_state = false;
 		}
 
-		if (log_level) {
-			verbose("%d: ", insn_idx);
+		if (env->log_level) {
+			verbose(env, "%d: ", insn_idx);
 			print_bpf_insn(env, insn);
 		}
 
@@ -3786,7 +3815,7 @@ static int do_check(struct bpf_verifier_env *env)
 				 * src_reg == stack|map in some other branch.
 				 * Reject it.
 				 */
-				verbose("same insn cannot be used with different pointers\n");
+				verbose(env, "same insn cannot be used with different pointers\n");
 				return -EINVAL;
 			}
 
@@ -3826,14 +3855,14 @@ static int do_check(struct bpf_verifier_env *env)
 			} else if (dst_reg_type != *prev_dst_type &&
 				   (dst_reg_type == PTR_TO_CTX ||
 				    *prev_dst_type == PTR_TO_CTX)) {
-				verbose("same insn cannot be used with different pointers\n");
+				verbose(env, "same insn cannot be used with different pointers\n");
 				return -EINVAL;
 			}
 
 		} else if (class == BPF_ST) {
 			if (BPF_MODE(insn->code) != BPF_MEM ||
 			    insn->src_reg != BPF_REG_0) {
-				verbose("BPF_ST uses reserved fields\n");
+				verbose(env, "BPF_ST uses reserved fields\n");
 				return -EINVAL;
 			}
 			/* check src operand */
@@ -3856,7 +3885,7 @@ static int do_check(struct bpf_verifier_env *env)
 				    insn->off != 0 ||
 				    insn->src_reg != BPF_REG_0 ||
 				    insn->dst_reg != BPF_REG_0) {
-					verbose("BPF_CALL uses reserved fields\n");
+					verbose(env, "BPF_CALL uses reserved fields\n");
 					return -EINVAL;
 				}
 
@@ -3869,7 +3898,7 @@ static int do_check(struct bpf_verifier_env *env)
 				    insn->imm != 0 ||
 				    insn->src_reg != BPF_REG_0 ||
 				    insn->dst_reg != BPF_REG_0) {
-					verbose("BPF_JA uses reserved fields\n");
+					verbose(env, "BPF_JA uses reserved fields\n");
 					return -EINVAL;
 				}
 
@@ -3881,7 +3910,7 @@ static int do_check(struct bpf_verifier_env *env)
 				    insn->imm != 0 ||
 				    insn->src_reg != BPF_REG_0 ||
 				    insn->dst_reg != BPF_REG_0) {
-					verbose("BPF_EXIT uses reserved fields\n");
+					verbose(env, "BPF_EXIT uses reserved fields\n");
 					return -EINVAL;
 				}
 
@@ -3896,7 +3925,7 @@ static int do_check(struct bpf_verifier_env *env)
 					return err;
 
 				if (is_pointer_value(env, BPF_REG_0)) {
-					verbose("R0 leaks addr as return value\n");
+					verbose(env, "R0 leaks addr as return value\n");
 					return -EACCES;
 				}
 
@@ -3931,19 +3960,19 @@ static int do_check(struct bpf_verifier_env *env)
 
 				insn_idx++;
 			} else {
-				verbose("invalid BPF_LD mode\n");
+				verbose(env, "invalid BPF_LD mode\n");
 				return -EINVAL;
 			}
 		} else {
-			verbose("unknown insn class %d\n", class);
+			verbose(env, "unknown insn class %d\n", class);
 			return -EINVAL;
 		}
 
 		insn_idx++;
 	}
 
-	verbose("processed %d insns, stack depth %d\n",
-		insn_processed, env->prog->aux->stack_depth);
+	verbose(env, "processed %d insns, stack depth %d\n", insn_processed,
+		env->prog->aux->stack_depth);
 	return 0;
 }
 
@@ -3955,7 +3984,8 @@ static int check_map_prealloc(struct bpf_map *map)
 		!(map->map_flags & BPF_F_NO_PREALLOC);
 }
 
-static int check_map_prog_compatibility(struct bpf_map *map,
+static int check_map_prog_compatibility(struct bpf_verifier_env *env,
+					struct bpf_map *map,
 					struct bpf_prog *prog)
 
 {
@@ -3966,12 +3996,12 @@ static int check_map_prog_compatibility(struct bpf_map *map,
 	 */
 	if (prog->type == BPF_PROG_TYPE_PERF_EVENT) {
 		if (!check_map_prealloc(map)) {
-			verbose("perf_event programs can only use preallocated hash map\n");
+			verbose(env, "perf_event programs can only use preallocated hash map\n");
 			return -EINVAL;
 		}
 		if (map->inner_map_meta &&
 		    !check_map_prealloc(map->inner_map_meta)) {
-			verbose("perf_event programs can only use preallocated inner hash map\n");
+			verbose(env, "perf_event programs can only use preallocated inner hash map\n");
 			return -EINVAL;
 		}
 	}
@@ -3994,14 +4024,14 @@ static int replace_map_fd_with_map_ptr(struct bpf_verifier_env *env)
 	for (i = 0; i < insn_cnt; i++, insn++) {
 		if (BPF_CLASS(insn->code) == BPF_LDX &&
 		    (BPF_MODE(insn->code) != BPF_MEM || insn->imm != 0)) {
-			verbose("BPF_LDX uses reserved fields\n");
+			verbose(env, "BPF_LDX uses reserved fields\n");
 			return -EINVAL;
 		}
 
 		if (BPF_CLASS(insn->code) == BPF_STX &&
 		    ((BPF_MODE(insn->code) != BPF_MEM &&
 		      BPF_MODE(insn->code) != BPF_XADD) || insn->imm != 0)) {
-			verbose("BPF_STX uses reserved fields\n");
+			verbose(env, "BPF_STX uses reserved fields\n");
 			return -EINVAL;
 		}
 
@@ -4012,7 +4042,7 @@ static int replace_map_fd_with_map_ptr(struct bpf_verifier_env *env)
 			if (i == insn_cnt - 1 || insn[1].code != 0 ||
 			    insn[1].dst_reg != 0 || insn[1].src_reg != 0 ||
 			    insn[1].off != 0) {
-				verbose("invalid bpf_ld_imm64 insn\n");
+				verbose(env, "invalid bpf_ld_imm64 insn\n");
 				return -EINVAL;
 			}
 
@@ -4021,19 +4051,20 @@ static int replace_map_fd_with_map_ptr(struct bpf_verifier_env *env)
 				goto next_insn;
 
 			if (insn->src_reg != BPF_PSEUDO_MAP_FD) {
-				verbose("unrecognized bpf_ld_imm64 insn\n");
+				verbose(env,
+					"unrecognized bpf_ld_imm64 insn\n");
 				return -EINVAL;
 			}
 
 			f = fdget(insn->imm);
 			map = __bpf_map_get(f);
 			if (IS_ERR(map)) {
-				verbose("fd %d is not pointing to valid bpf_map\n",
+				verbose(env, "fd %d is not pointing to valid bpf_map\n",
 					insn->imm);
 				return PTR_ERR(map);
 			}
 
-			err = check_map_prog_compatibility(map, env->prog);
+			err = check_map_prog_compatibility(env, map, env->prog);
 			if (err) {
 				fdput(f);
 				return err;
@@ -4155,7 +4186,7 @@ static int convert_ctx_accesses(struct bpf_verifier_env *env)
 		cnt = ops->gen_prologue(insn_buf, env->seen_direct_write,
 					env->prog);
 		if (cnt >= ARRAY_SIZE(insn_buf)) {
-			verbose("bpf verifier is misconfigured\n");
+			verbose(env, "bpf verifier is misconfigured\n");
 			return -EINVAL;
 		} else if (cnt) {
 			new_prog = bpf_patch_insn_data(env, 0, insn_buf, cnt);
@@ -4203,7 +4234,7 @@ static int convert_ctx_accesses(struct bpf_verifier_env *env)
 			u8 size_code;
 
 			if (type == BPF_WRITE) {
-				verbose("bpf verifier narrow ctx access misconfigured\n");
+				verbose(env, "bpf verifier narrow ctx access misconfigured\n");
 				return -EINVAL;
 			}
 
@@ -4222,7 +4253,7 @@ static int convert_ctx_accesses(struct bpf_verifier_env *env)
 					      &target_size);
 		if (cnt == 0 || cnt >= ARRAY_SIZE(insn_buf) ||
 		    (ctx_field_size && !target_size)) {
-			verbose("bpf verifier is misconfigured\n");
+			verbose(env, "bpf verifier is misconfigured\n");
 			return -EINVAL;
 		}
 
@@ -4304,7 +4335,7 @@ static int fixup_bpf_calls(struct bpf_verifier_env *env)
 
 			cnt = map_ptr->ops->map_gen_lookup(map_ptr, insn_buf);
 			if (cnt == 0 || cnt >= ARRAY_SIZE(insn_buf)) {
-				verbose("bpf verifier is misconfigured\n");
+				verbose(env, "bpf verifier is misconfigured\n");
 				return -EINVAL;
 			}
 
@@ -4348,7 +4379,8 @@ static int fixup_bpf_calls(struct bpf_verifier_env *env)
 		 * programs to call them, must be real in-kernel functions
 		 */
 		if (!fn->func) {
-			verbose("kernel subsystem misconfigured func %s#%d\n",
+			verbose(env,
+				"kernel subsystem misconfigured func %s#%d\n",
 				func_id_name(insn->imm), insn->imm);
 			return -EFAULT;
 		}
@@ -4407,23 +4439,20 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 		/* user requested verbose verifier output
 		 * and supplied buffer to store the verification trace
 		 */
-		log_level = attr->log_level;
+		env->log_level = attr->log_level;
 		log_ubuf = (char __user *) (unsigned long) attr->log_buf;
-		log_size = attr->log_size;
-		log_len = 0;
+		env->log_size = attr->log_size;
 
 		ret = -EINVAL;
 		/* log_* values have to be sane */
-		if (log_size < 128 || log_size > UINT_MAX >> 8 ||
-		    log_level == 0 || log_ubuf == NULL)
+		if (env->log_size < 128 || env->log_size > UINT_MAX >> 8 ||
+		    env->log_level == 0 || log_ubuf == NULL)
 			goto err_unlock;
 
 		ret = -ENOMEM;
-		log_buf = vmalloc(log_size);
-		if (!log_buf)
+		env->log_buf = vmalloc(env->log_size);
+		if (!env->log_buf)
 			goto err_unlock;
-	} else {
-		log_level = 0;
 	}
 
 	env->strict_alignment = !!(attr->prog_flags & BPF_F_STRICT_ALIGNMENT);
@@ -4460,15 +4489,16 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 	if (ret == 0)
 		ret = fixup_bpf_calls(env);
 
-	if (log_level && log_len >= log_size - 1) {
-		BUG_ON(log_len >= log_size);
+	if (env->log_level && env->log_len >= env->log_size - 1) {
+		BUG_ON(env->log_len >= env->log_size);
 		/* verifier log exceeded user supplied buffer */
 		ret = -ENOSPC;
 		/* fall through to return what was recorded */
 	}
 
 	/* copy verifier log back to user space including trailing zero */
-	if (log_level && copy_to_user(log_ubuf, log_buf, log_len + 1) != 0) {
+	if (env->log_level &&
+	    copy_to_user(log_ubuf, env->log_buf, env->log_len + 1) != 0) {
 		ret = -EFAULT;
 		goto free_log_buf;
 	}
@@ -4495,8 +4525,8 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 	}
 
 free_log_buf:
-	if (log_level)
-		vfree(log_buf);
+	if (env->log_level)
+		vfree(env->log_buf);
 	if (!env->prog->aux->used_maps)
 		/* if we didn't copy map pointers into bpf_prog_info, release
 		 * them now. Otherwise free_bpf_prog_info() will release them.
@@ -4533,8 +4563,6 @@ int bpf_analyzer(struct bpf_prog *prog, const struct bpf_ext_analyzer_ops *ops,
 	/* grab the mutex to protect few globals used by verifier */
 	mutex_lock(&bpf_verifier_lock);
 
-	log_level = 0;
-
 	env->strict_alignment = false;
 	if (!IS_ENABLED(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS))
 		env->strict_alignment = true;
-- 
2.14.1
