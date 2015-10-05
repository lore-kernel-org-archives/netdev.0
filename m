From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next 1/2] bpf: enable non-root eBPF programs
Date: Mon,  5 Oct 2015 13:48:20 -0700
Message-ID: <1444078101-29060-2-git-send-email-ast@plumgrid.com>
References: <1444078101-29060-1-git-send-email-ast@plumgrid.com>
Cc: Andy Lutomirski <luto@amacapital.net>,
	Ingo Molnar <mingo@kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34049 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751612AbbJEUsh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 16:48:37 -0400
Received: by padhy16 with SMTP id hy16so46567679pad.1
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 13:48:36 -0700 (PDT)
In-Reply-To: <1444078101-29060-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to let unprivileged users load and execute eBPF programs
teach verifier to prevent pointer leaks.
Verifier will prevent
- any arithmetic on pointers
  (except R10+Imm which is used to compute stack addresses)
- comparison of pointers
- passing pointers to helper functions
- indirectly passing pointers in stack to helper functions
- returning pointer from bpf program
- storing pointers into ctx or maps

Spill/fill of pointers into stack is allowed, but mangling
of pointers stored in the stack or reading them byte by byte is not.

Within bpf programs the pointers do exist, since programs need to
be able to access maps, pass skb pointer to LD_ABS insns, etc
but programs cannot pass such pointer values to the outside
or obfuscate them.

Only allow BPF_PROG_TYPE_SOCKET_FILTER unprivileged programs,
so that socket filters (tcpdump), af_packet (quic acceleration)
and future kcm can use it.
tracing and tc cls/act program types still require root permissions,
since tracing actually needs to be able to see all kernel pointers
and tc is for root only.

For example, the following unprivileged socket filter program is allowed:
int foo(struct __sk_buff *skb)
{
  char fmt[] = "hello %d\n";
  bpf_trace_printk(fmt, sizeof(fmt), skb->len);
  return 0;
}

but the following program is not:
int foo(struct __sk_buff *skb)
{
  char fmt[] = "hello %p\n";
  bpf_trace_printk(fmt, sizeof(fmt), fmt);
  return 0;
}
since it would leak the kernel stack address via bpf_trace_printk().

Unprivileged socket filter bpf programs have access to the
following helper functions:
- map lookup/update/delete (but they cannot store kernel pointers into them)
- get_random (it's already exposed to unprivileged user space)
- get_smp_processor_id
- tail_call into another socket filter program
- ktime_get_ns
- bpf_trace_printk (for debugging)

The feature is controlled by sysctl kernel.bpf_enable_unprivileged
which is off by default.

New tests were added to test_verifier:
 unpriv: return pointer OK
 unpriv: add const to pointer OK
 unpriv: add pointer to pointer OK
 unpriv: neg pointer OK
 unpriv: cmp pointer with const OK
 unpriv: cmp pointer with pointer OK
 unpriv: pass pointer to printk OK
 unpriv: pass pointer to helper function OK
 unpriv: indirectly pass pointer on stack to helper function OK
 unpriv: mangle pointer on stack 1 OK
 unpriv: mangle pointer on stack 2 OK
 unpriv: read pointer from stack in small chunks OK
 unpriv: write pointer into ctx OK
 unpriv: write pointer into map elem value OK
 unpriv: partial copy of pointer OK

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/bpf.h         |    3 +
 kernel/bpf/syscall.c        |   11 +-
 kernel/bpf/verifier.c       |  114 +++++++++++++++++++--
 kernel/sysctl.c             |   10 ++
 kernel/trace/bpf_trace.c    |    3 +
 samples/bpf/libbpf.h        |    8 ++
 samples/bpf/test_verifier.c |  239 ++++++++++++++++++++++++++++++++++++++++++-
 7 files changed, 371 insertions(+), 17 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index f57d7fed9ec3..acf97d66b681 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -66,6 +66,7 @@ enum bpf_arg_type {
 
 	ARG_PTR_TO_CTX,		/* pointer to context */
 	ARG_ANYTHING,		/* any (initialized) argument is ok */
+	ARG_VARARG,		/* optional argument */
 };
 
 /* type of values returned from helper functions */
@@ -168,6 +169,8 @@ void bpf_prog_put_rcu(struct bpf_prog *prog);
 struct bpf_map *bpf_map_get(struct fd f);
 void bpf_map_put(struct bpf_map *map);
 
+extern int sysctl_bpf_enable_unprivileged;
+
 /* verify correctness of eBPF program */
 int bpf_check(struct bpf_prog **fp, union bpf_attr *attr);
 #else
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 5f35f420c12f..9a2098da2da9 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -18,6 +18,8 @@
 #include <linux/filter.h>
 #include <linux/version.h>
 
+int sysctl_bpf_enable_unprivileged __read_mostly;
+
 static LIST_HEAD(bpf_map_types);
 
 static struct bpf_map *find_and_alloc_map(union bpf_attr *attr)
@@ -542,6 +544,9 @@ static int bpf_prog_load(union bpf_attr *attr)
 	    attr->kern_version != LINUX_VERSION_CODE)
 		return -EINVAL;
 
+	if (type != BPF_PROG_TYPE_SOCKET_FILTER && !capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
 	/* plain bpf_prog allocation */
 	prog = bpf_prog_alloc(bpf_prog_size(attr->insn_cnt), GFP_USER);
 	if (!prog)
@@ -597,11 +602,7 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
 	union bpf_attr attr = {};
 	int err;
 
-	/* the syscall is limited to root temporarily. This restriction will be
-	 * lifted when security audit is clean. Note that eBPF+tracing must have
-	 * this restriction, since it may pass kernel data to user space
-	 */
-	if (!capable(CAP_SYS_ADMIN))
+	if (!capable(CAP_SYS_ADMIN) && !sysctl_bpf_enable_unprivileged)
 		return -EPERM;
 
 	if (!access_ok(VERIFY_READ, uattr, 1))
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index b074b23000d6..dccaeeeb1128 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -199,6 +199,7 @@ struct verifier_env {
 	struct verifier_state_list **explored_states; /* search pruning optimization */
 	struct bpf_map *used_maps[MAX_USED_MAPS]; /* array of map's used by eBPF program */
 	u32 used_map_cnt;		/* number of used maps */
+	bool allow_ptr_leaks;
 };
 
 /* verbose verifier prints what it's seeing
@@ -538,6 +539,21 @@ static int bpf_size_to_bytes(int bpf_size)
 		return -EINVAL;
 }
 
+static bool is_spillable_regtype(enum bpf_reg_type type)
+{
+	switch (type) {
+	case PTR_TO_MAP_VALUE:
+	case PTR_TO_MAP_VALUE_OR_NULL:
+	case PTR_TO_STACK:
+	case PTR_TO_CTX:
+	case FRAME_PTR:
+	case CONST_PTR_TO_MAP:
+		return true;
+	default:
+		return false;
+	}
+}
+
 /* check_stack_read/write functions track spill/fill of registers,
  * stack boundary and alignment are checked in check_mem_access()
  */
@@ -550,9 +566,7 @@ static int check_stack_write(struct verifier_state *state, int off, int size,
 	 */
 
 	if (value_regno >= 0 &&
-	    (state->regs[value_regno].type == PTR_TO_MAP_VALUE ||
-	     state->regs[value_regno].type == PTR_TO_STACK ||
-	     state->regs[value_regno].type == PTR_TO_CTX)) {
+	    is_spillable_regtype(state->regs[value_regno].type)) {
 
 		/* register containing pointer is being spilled into stack */
 		if (size != BPF_REG_SIZE) {
@@ -643,6 +657,20 @@ static int check_ctx_access(struct verifier_env *env, int off, int size,
 	return -EACCES;
 }
 
+static bool is_pointer_value(struct verifier_env *env, int regno)
+{
+	if (env->allow_ptr_leaks)
+		return false;
+
+	switch (env->cur_state.regs[regno].type) {
+	case UNKNOWN_VALUE:
+	case CONST_IMM:
+		return false;
+	default:
+		return true;
+	}
+}
+
 /* check whether memory at (regno + off) is accessible for t = (read | write)
  * if t==write, value_regno is a register which value is stored into memory
  * if t==read, value_regno is a register which will receive the value from memory
@@ -669,11 +697,21 @@ static int check_mem_access(struct verifier_env *env, u32 regno, int off,
 	}
 
 	if (state->regs[regno].type == PTR_TO_MAP_VALUE) {
+		if (t == BPF_WRITE && value_regno >= 0 &&
+		    is_pointer_value(env, value_regno)) {
+			verbose("R%d leaks addr into map\n", value_regno);
+			return -EACCES;
+		}
 		err = check_map_access(env, regno, off, size);
 		if (!err && t == BPF_READ && value_regno >= 0)
 			mark_reg_unknown_value(state->regs, value_regno);
 
 	} else if (state->regs[regno].type == PTR_TO_CTX) {
+		if (t == BPF_WRITE && value_regno >= 0 &&
+		    is_pointer_value(env, value_regno)) {
+			verbose("R%d leaks addr into ctx\n", value_regno);
+			return -EACCES;
+		}
 		err = check_ctx_access(env, off, size, t);
 		if (!err && t == BPF_READ && value_regno >= 0)
 			mark_reg_unknown_value(state->regs, value_regno);
@@ -684,10 +722,17 @@ static int check_mem_access(struct verifier_env *env, u32 regno, int off,
 			verbose("invalid stack off=%d size=%d\n", off, size);
 			return -EACCES;
 		}
-		if (t == BPF_WRITE)
+		if (t == BPF_WRITE) {
+			if (!env->allow_ptr_leaks &&
+			    state->stack_slot_type[MAX_BPF_STACK + off] == STACK_SPILL &&
+			    size != BPF_REG_SIZE) {
+				verbose("attempt to corrupt spilled pointer on stack\n");
+				return -EACCES;
+			}
 			err = check_stack_write(state, off, size, value_regno);
-		else
+		} else {
 			err = check_stack_read(state, off, size, value_regno);
+		}
 	} else {
 		verbose("R%d invalid mem access '%s'\n",
 			regno, reg_type_str[state->regs[regno].type]);
@@ -770,13 +815,26 @@ static int check_func_arg(struct verifier_env *env, u32 regno,
 	if (arg_type == ARG_DONTCARE)
 		return 0;
 
+	if (arg_type == ARG_VARARG) {
+		if (is_pointer_value(env, regno)) {
+			verbose("R%d leaks addr into printk\n", regno);
+			return -EACCES;
+		}
+		return 0;
+	}
+
 	if (reg->type == NOT_INIT) {
 		verbose("R%d !read_ok\n", regno);
 		return -EACCES;
 	}
 
-	if (arg_type == ARG_ANYTHING)
+	if (arg_type == ARG_ANYTHING) {
+		if (is_pointer_value(env, regno)) {
+			verbose("R%d leaks addr into helper function\n", regno);
+			return -EACCES;
+		}
 		return 0;
+	}
 
 	if (arg_type == ARG_PTR_TO_STACK || arg_type == ARG_PTR_TO_MAP_KEY ||
 	    arg_type == ARG_PTR_TO_MAP_VALUE) {
@@ -950,8 +1008,9 @@ static int check_call(struct verifier_env *env, int func_id)
 }
 
 /* check validity of 32-bit and 64-bit arithmetic operations */
-static int check_alu_op(struct reg_state *regs, struct bpf_insn *insn)
+static int check_alu_op(struct verifier_env *env, struct bpf_insn *insn)
 {
+	struct reg_state *regs = env->cur_state.regs;
 	u8 opcode = BPF_OP(insn->code);
 	int err;
 
@@ -976,6 +1035,12 @@ static int check_alu_op(struct reg_state *regs, struct bpf_insn *insn)
 		if (err)
 			return err;
 
+		if (is_pointer_value(env, insn->dst_reg)) {
+			verbose("R%d pointer arithmetic prohibited\n",
+				insn->dst_reg);
+			return -EACCES;
+		}
+
 		/* check dest operand */
 		err = check_reg_arg(regs, insn->dst_reg, DST_OP);
 		if (err)
@@ -1012,6 +1077,11 @@ static int check_alu_op(struct reg_state *regs, struct bpf_insn *insn)
 				 */
 				regs[insn->dst_reg] = regs[insn->src_reg];
 			} else {
+				if (is_pointer_value(env, insn->src_reg)) {
+					verbose("R%d partial copy of pointer\n",
+						insn->src_reg);
+					return -EACCES;
+				}
 				regs[insn->dst_reg].type = UNKNOWN_VALUE;
 				regs[insn->dst_reg].map_ptr = NULL;
 			}
@@ -1061,8 +1131,18 @@ static int check_alu_op(struct reg_state *regs, struct bpf_insn *insn)
 		/* pattern match 'bpf_add Rx, imm' instruction */
 		if (opcode == BPF_ADD && BPF_CLASS(insn->code) == BPF_ALU64 &&
 		    regs[insn->dst_reg].type == FRAME_PTR &&
-		    BPF_SRC(insn->code) == BPF_K)
+		    BPF_SRC(insn->code) == BPF_K) {
 			stack_relative = true;
+		} else if (is_pointer_value(env, insn->dst_reg)) {
+			verbose("R%d pointer arithmetic prohibited\n",
+				insn->dst_reg);
+			return -EACCES;
+		} else if (BPF_SRC(insn->code) == BPF_X &&
+			   is_pointer_value(env, insn->src_reg)) {
+			verbose("R%d pointer arithmetic prohibited\n",
+				insn->src_reg);
+			return -EACCES;
+		}
 
 		/* check dest operand */
 		err = check_reg_arg(regs, insn->dst_reg, DST_OP);
@@ -1101,6 +1181,12 @@ static int check_cond_jmp_op(struct verifier_env *env,
 		err = check_reg_arg(regs, insn->src_reg, SRC_OP);
 		if (err)
 			return err;
+
+		if (is_pointer_value(env, insn->src_reg)) {
+			verbose("R%d pointer comparison prohibited\n",
+				insn->src_reg);
+			return -EACCES;
+		}
 	} else {
 		if (insn->src_reg != BPF_REG_0) {
 			verbose("BPF_JMP uses reserved fields\n");
@@ -1155,6 +1241,9 @@ static int check_cond_jmp_op(struct verifier_env *env,
 			regs[insn->dst_reg].type = CONST_IMM;
 			regs[insn->dst_reg].imm = 0;
 		}
+	} else if (is_pointer_value(env, insn->dst_reg)) {
+		verbose("R%d pointer comparison prohibited\n", insn->dst_reg);
+		return -EACCES;
 	} else if (BPF_SRC(insn->code) == BPF_K &&
 		   (opcode == BPF_JEQ || opcode == BPF_JNE)) {
 
@@ -1658,7 +1747,7 @@ static int do_check(struct verifier_env *env)
 		}
 
 		if (class == BPF_ALU || class == BPF_ALU64) {
-			err = check_alu_op(regs, insn);
+			err = check_alu_op(env, insn);
 			if (err)
 				return err;
 
@@ -1816,6 +1905,11 @@ static int do_check(struct verifier_env *env)
 				if (err)
 					return err;
 
+				if (is_pointer_value(env, BPF_REG_0)) {
+					verbose("R0 leaks addr as return value\n");
+					return -EACCES;
+				}
+
 process_bpf_exit:
 				insn_idx = pop_stack(env, &prev_insn_idx);
 				if (insn_idx < 0) {
@@ -2144,6 +2238,8 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 	if (ret < 0)
 		goto skip_full_check;
 
+	env->allow_ptr_leaks = capable(CAP_SYS_ADMIN);
+
 	ret = do_check(env);
 
 skip_full_check:
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index e69201d8094e..a281849278d9 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -64,6 +64,7 @@
 #include <linux/binfmts.h>
 #include <linux/sched/sysctl.h>
 #include <linux/kexec.h>
+#include <linux/bpf.h>
 
 #include <asm/uaccess.h>
 #include <asm/processor.h>
@@ -1139,6 +1140,15 @@ static struct ctl_table kern_table[] = {
 		.proc_handler	= timer_migration_handler,
 	},
 #endif
+#ifdef CONFIG_BPF_SYSCALL
+	{
+		.procname	= "bpf_enable_unprivileged",
+		.data		= &sysctl_bpf_enable_unprivileged,
+		.maxlen		= sizeof(sysctl_bpf_enable_unprivileged),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+#endif
 	{ }
 };
 
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 0fe96c7c8803..46bbed24d1f5 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -173,6 +173,9 @@ static const struct bpf_func_proto bpf_trace_printk_proto = {
 	.ret_type	= RET_INTEGER,
 	.arg1_type	= ARG_PTR_TO_STACK,
 	.arg2_type	= ARG_CONST_STACK_SIZE,
+	.arg3_type	= ARG_VARARG,
+	.arg4_type	= ARG_VARARG,
+	.arg5_type	= ARG_VARARG,
 };
 
 const struct bpf_func_proto *bpf_get_trace_printk_proto(void)
diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
index 7235e292a03b..b7f63c70b4a2 100644
--- a/samples/bpf/libbpf.h
+++ b/samples/bpf/libbpf.h
@@ -64,6 +64,14 @@ extern char bpf_log_buf[LOG_BUF_SIZE];
 		.off   = 0,					\
 		.imm   = 0 })
 
+#define BPF_MOV32_REG(DST, SRC)					\
+	((struct bpf_insn) {					\
+		.code  = BPF_ALU | BPF_MOV | BPF_X,		\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = 0,					\
+		.imm   = 0 })
+
 /* Short form of mov, dst_reg = imm32 */
 
 #define BPF_MOV64_IMM(DST, IMM)					\
diff --git a/samples/bpf/test_verifier.c b/samples/bpf/test_verifier.c
index ee0f110c9c54..266d014a885e 100644
--- a/samples/bpf/test_verifier.c
+++ b/samples/bpf/test_verifier.c
@@ -15,6 +15,7 @@
 #include <string.h>
 #include <linux/filter.h>
 #include <stddef.h>
+#include <stdbool.h>
 #include "libbpf.h"
 
 #define MAX_INSNS 512
@@ -25,10 +26,12 @@ struct bpf_test {
 	struct bpf_insn	insns[MAX_INSNS];
 	int fixup[32];
 	const char *errstr;
+	const char *errstr_unpriv;
 	enum {
+		UNDEF,
 		ACCEPT,
 		REJECT
-	} result;
+	} result, result_unpriv;
 	enum bpf_prog_type prog_type;
 };
 
@@ -96,6 +99,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.errstr = "invalid BPF_LD_IMM insn",
+		.errstr_unpriv = "R1 pointer comparison",
 		.result = REJECT,
 	},
 	{
@@ -109,6 +113,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.errstr = "invalid BPF_LD_IMM insn",
+		.errstr_unpriv = "R1 pointer comparison",
 		.result = REJECT,
 	},
 	{
@@ -219,6 +224,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.errstr = "R0 !read_ok",
+		.errstr_unpriv = "R1 pointer comparison",
 		.result = REJECT,
 	},
 	{
@@ -294,7 +300,9 @@ static struct bpf_test tests[] = {
 			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
 			BPF_EXIT_INSN(),
 		},
+		.errstr_unpriv = "R0 leaks addr",
 		.result = ACCEPT,
+		.result_unpriv = REJECT,
 	},
 	{
 		"check corrupted spill/fill",
@@ -310,6 +318,7 @@ static struct bpf_test tests[] = {
 
 			BPF_EXIT_INSN(),
 		},
+		.errstr_unpriv = "attempt to corrupt spilled",
 		.errstr = "corrupted spill",
 		.result = REJECT,
 	},
@@ -473,6 +482,7 @@ static struct bpf_test tests[] = {
 		},
 		.fixup = {3},
 		.errstr = "R0 invalid mem access",
+		.errstr_unpriv = "R0 leaks addr",
 		.result = REJECT,
 	},
 	{
@@ -495,6 +505,8 @@ static struct bpf_test tests[] = {
 			BPF_MOV64_IMM(BPF_REG_0, 0),
 			BPF_EXIT_INSN(),
 		},
+		.errstr_unpriv = "R1 pointer comparison",
+		.result_unpriv = REJECT,
 		.result = ACCEPT,
 	},
 	{
@@ -521,6 +533,8 @@ static struct bpf_test tests[] = {
 			BPF_MOV64_IMM(BPF_REG_0, 0),
 			BPF_EXIT_INSN(),
 		},
+		.errstr_unpriv = "R1 pointer comparison",
+		.result_unpriv = REJECT,
 		.result = ACCEPT,
 	},
 	{
@@ -555,6 +569,8 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.fixup = {24},
+		.errstr_unpriv = "R1 pointer comparison",
+		.result_unpriv = REJECT,
 		.result = ACCEPT,
 	},
 	{
@@ -603,6 +619,8 @@ static struct bpf_test tests[] = {
 			BPF_MOV64_IMM(BPF_REG_0, 0),
 			BPF_EXIT_INSN(),
 		},
+		.errstr_unpriv = "R1 pointer comparison",
+		.result_unpriv = REJECT,
 		.result = ACCEPT,
 	},
 	{
@@ -642,6 +660,8 @@ static struct bpf_test tests[] = {
 			BPF_MOV64_IMM(BPF_REG_0, 0),
 			BPF_EXIT_INSN(),
 		},
+		.errstr_unpriv = "R1 pointer comparison",
+		.result_unpriv = REJECT,
 		.result = ACCEPT,
 	},
 	{
@@ -699,6 +719,7 @@ static struct bpf_test tests[] = {
 		},
 		.fixup = {4},
 		.errstr = "different pointers",
+		.errstr_unpriv = "R1 pointer comparison",
 		.result = REJECT,
 	},
 	{
@@ -720,6 +741,7 @@ static struct bpf_test tests[] = {
 		},
 		.fixup = {6},
 		.errstr = "different pointers",
+		.errstr_unpriv = "R1 pointer comparison",
 		.result = REJECT,
 	},
 	{
@@ -742,6 +764,7 @@ static struct bpf_test tests[] = {
 		},
 		.fixup = {7},
 		.errstr = "different pointers",
+		.errstr_unpriv = "R1 pointer comparison",
 		.result = REJECT,
 	},
 	{
@@ -752,6 +775,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.errstr = "invalid bpf_context access",
+		.errstr_unpriv = "R1 leaks addr",
 		.result = REJECT,
 	},
 	{
@@ -762,6 +786,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.errstr = "invalid bpf_context access",
+		.errstr_unpriv = "R1 leaks addr",
 		.result = REJECT,
 	},
 	{
@@ -772,6 +797,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.errstr = "invalid bpf_context access",
+		.errstr_unpriv = "R1 leaks addr",
 		.result = REJECT,
 	},
 	{
@@ -782,6 +808,7 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.errstr = "invalid bpf_context access",
+		.errstr_unpriv = "",
 		.result = REJECT,
 		.prog_type = BPF_PROG_TYPE_SCHED_ACT,
 	},
@@ -803,6 +830,8 @@ static struct bpf_test tests[] = {
 			BPF_EXIT_INSN(),
 		},
 		.result = ACCEPT,
+		.errstr_unpriv = "R1 leaks addr",
+		.result_unpriv = REJECT,
 	},
 	{
 		"write skb fields from tc_cls_act prog",
@@ -819,6 +848,8 @@ static struct bpf_test tests[] = {
 				    offsetof(struct __sk_buff, cb[3])),
 			BPF_EXIT_INSN(),
 		},
+		.errstr_unpriv = "",
+		.result_unpriv = REJECT,
 		.result = ACCEPT,
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
@@ -881,6 +912,195 @@ static struct bpf_test tests[] = {
 		.result = REJECT,
 		.errstr = "invalid stack off=0 size=8",
 	},
+	{
+		"unpriv: return pointer",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_10),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.result_unpriv = REJECT,
+		.errstr_unpriv = "R0 leaks addr",
+	},
+	{
+		"unpriv: add const to pointer",
+		.insns = {
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 8),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.result_unpriv = REJECT,
+		.errstr_unpriv = "R1 pointer arithmetic",
+	},
+	{
+		"unpriv: add pointer to pointer",
+		.insns = {
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_1, BPF_REG_10),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.result_unpriv = REJECT,
+		.errstr_unpriv = "R1 pointer arithmetic",
+	},
+	{
+		"unpriv: neg pointer",
+		.insns = {
+			BPF_ALU64_IMM(BPF_NEG, BPF_REG_1, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.result_unpriv = REJECT,
+		.errstr_unpriv = "R1 pointer arithmetic",
+	},
+	{
+		"unpriv: cmp pointer with const",
+		.insns = {
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.result_unpriv = REJECT,
+		.errstr_unpriv = "R1 pointer comparison",
+	},
+	{
+		"unpriv: cmp pointer with pointer",
+		.insns = {
+			BPF_JMP_REG(BPF_JEQ, BPF_REG_1, BPF_REG_10, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.result_unpriv = REJECT,
+		.errstr_unpriv = "R10 pointer comparison",
+	},
+	{
+		"unpriv: pass pointer to printk",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -8),
+			BPF_MOV64_IMM(BPF_REG_2, 8),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_1),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_trace_printk),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr_unpriv = "R3 leaks addr",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"unpriv: pass pointer to helper function",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_2),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_update_elem),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup = {3},
+		.errstr_unpriv = "R4 leaks addr",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"unpriv: indirectly pass pointer on stack to helper function",
+		.insns = {
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_10, -8),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup = {3},
+		.errstr = "invalid indirect read from stack off -8+0 size 8",
+		.result = REJECT,
+	},
+	{
+		"unpriv: mangle pointer on stack 1",
+		.insns = {
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_10, -8),
+			BPF_ST_MEM(BPF_W, BPF_REG_10, -8, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr_unpriv = "attempt to corrupt spilled",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"unpriv: mangle pointer on stack 2",
+		.insns = {
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_10, -8),
+			BPF_ST_MEM(BPF_B, BPF_REG_10, -1, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr_unpriv = "attempt to corrupt spilled",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"unpriv: read pointer from stack in small chunks",
+		.insns = {
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_10, -8),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_10, -8),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid size",
+		.result = REJECT,
+	},
+	{
+		"unpriv: write pointer into ctx",
+		.insns = {
+			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_1, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr_unpriv = "R1 leaks addr",
+		.result_unpriv = REJECT,
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+	},
+	{
+		"unpriv: write pointer into map elem value",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
+			BPF_STX_MEM(BPF_DW, BPF_REG_0, BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup = {3},
+		.errstr_unpriv = "R0 leaks addr",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"unpriv: partial copy of pointer",
+		.insns = {
+			BPF_MOV32_REG(BPF_REG_1, BPF_REG_10),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr_unpriv = "R10 partial copy",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
 };
 
 static int probe_filter_length(struct bpf_insn *fp)
@@ -910,12 +1130,15 @@ static int create_map(void)
 static int test(void)
 {
 	int prog_fd, i, pass_cnt = 0, err_cnt = 0;
+	bool unpriv = geteuid() != 0;
 
 	for (i = 0; i < ARRAY_SIZE(tests); i++) {
 		struct bpf_insn *prog = tests[i].insns;
 		int prog_type = tests[i].prog_type;
 		int prog_len = probe_filter_length(prog);
 		int *fixup = tests[i].fixup;
+		int expected_result;
+		const char *expected_errstr;
 		int map_fd = -1;
 
 		if (*fixup) {
@@ -932,7 +1155,17 @@ static int test(void)
 					prog, prog_len * sizeof(struct bpf_insn),
 					"GPL", 0);
 
-		if (tests[i].result == ACCEPT) {
+		if (unpriv && tests[i].result_unpriv != UNDEF)
+			expected_result = tests[i].result_unpriv;
+		else
+			expected_result = tests[i].result;
+
+		if (unpriv && tests[i].errstr_unpriv)
+			expected_errstr = tests[i].errstr_unpriv;
+		else
+			expected_errstr = tests[i].errstr;
+
+		if (expected_result == ACCEPT) {
 			if (prog_fd < 0) {
 				printf("FAIL\nfailed to load prog '%s'\n",
 				       strerror(errno));
@@ -947,7 +1180,7 @@ static int test(void)
 				err_cnt++;
 				goto fail;
 			}
-			if (strstr(bpf_log_buf, tests[i].errstr) == 0) {
+			if (strstr(bpf_log_buf, expected_errstr) == 0) {
 				printf("FAIL\nunexpected error message: %s",
 				       bpf_log_buf);
 				err_cnt++;
-- 
1.7.9.5
