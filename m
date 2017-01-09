From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 4/5] bpf: allow helpers access to variable memory
Date: Mon, 9 Jan 2017 10:19:49 -0800
Message-ID: <1483985990-1532850-5-git-send-email-ast@fb.com>
References: <1483985990-1532850-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Gianluca Borello <g.borello@gmail.com>,
        Josef Bacik <jbacik@fb.com>, <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:45392 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1162254AbdAISTx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 13:19:53 -0500
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v09ICMpk021053
        for <netdev@vger.kernel.org>; Mon, 9 Jan 2017 10:19:52 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 27v85rsdpt-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 10:19:52 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.102.107.97) with ESMTP id
 36264336d69811e688020002c99331b0-d85f1a50 for <netdev@vger.kernel.org>;        Mon,
 09 Jan 2017 10:19:51 -0800
In-Reply-To: <1483985990-1532850-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gianluca Borello <g.borello@gmail.com>

Currently, helpers that read and write from/to the stack can do so using
a pair of arguments of type ARG_PTR_TO_STACK and ARG_CONST_STACK_SIZE.
ARG_CONST_STACK_SIZE accepts a constant register of type CONST_IMM, so
that the verifier can safely check the memory access. However, requiring
the argument to be a constant can be limiting in some circumstances.

Since the current logic keeps track of the minimum and maximum value of
a register throughout the simulated execution, ARG_CONST_STACK_SIZE can
be changed to also accept an UNKNOWN_VALUE register in case its
boundaries have been set and the range doesn't cause invalid memory
accesses.

One common situation when this is useful:

int len;
char buf[BUFSIZE]; /* BUFSIZE is 128 */

if (some_condition)
	len = 42;
else
	len = 84;

some_helper(..., buf, len & (BUFSIZE - 1));

The compiler can often decide to assign the constant values 42 or 48
into a variable on the stack, instead of keeping it in a register. When
the variable is then read back from stack into the register in order to
be passed to the helper, the verifier will not be able to recognize the
register as constant (the verifier is not currently tracking all
constant writes into memory), and the program won't be valid.

However, by allowing the helper to accept an UNKNOWN_VALUE register,
this program will work because the bitwise AND operation will set the
range of possible values for the UNKNOWN_VALUE register to [0, BUFSIZE),
so the verifier can guarantee the helper call will be safe (assuming the
argument is of type ARG_CONST_STACK_SIZE_OR_ZERO, otherwise one more
check against 0 would be needed). Custom ranges can be set not only with
ALU operations, but also by explicitly comparing the UNKNOWN_VALUE
register with constants.

Another very common example happens when intercepting system call
arguments and accessing user-provided data of variable size using
bpf_probe_read(). One can load at runtime the user-provided length in an
UNKNOWN_VALUE register, and then read that exact amount of data up to a
compile-time determined limit in order to fit into the proper local
storage allocated on the stack, without having to guess a suboptimal
access size at compile time.

Also, in case the helpers accepting the UNKNOWN_VALUE register operate
in raw mode, disable the raw mode so that the program is required to
initialize all memory, since there is no guarantee the helper will fill
it completely, leaving possibilities for data leak (just relevant when
the memory used by the helper is the stack, not when using a pointer to
map element value or packet). In other words, ARG_PTR_TO_RAW_STACK will
be treated as ARG_PTR_TO_STACK.

Signed-off-by: Gianluca Borello <g.borello@gmail.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/verifier.c                       |  74 ++++-
 tools/testing/selftests/bpf/test_verifier.c | 410 ++++++++++++++++++++++++++++
 2 files changed, 474 insertions(+), 10 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 59ed07b9b4ea..3d4f7bf32aaf 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -980,6 +980,25 @@ static int check_stack_boundary(struct bpf_verifier_env *env, int regno,
 	return 0;
 }
 
+static int check_helper_mem_access(struct bpf_verifier_env *env, int regno,
+				   int access_size, bool zero_size_allowed,
+				   struct bpf_call_arg_meta *meta)
+{
+	struct bpf_reg_state *regs = env->cur_state.regs;
+
+	switch (regs[regno].type) {
+	case PTR_TO_PACKET:
+		return check_packet_access(env, regno, 0, access_size);
+	case PTR_TO_MAP_VALUE:
+		return check_map_access(env, regno, 0, access_size);
+	case PTR_TO_MAP_VALUE_ADJ:
+		return check_map_access_adj(env, regno, 0, access_size);
+	default: /* const_imm|ptr_to_stack or invalid ptr */
+		return check_stack_boundary(env, regno, access_size,
+					    zero_size_allowed, meta);
+	}
+}
+
 static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 			  enum bpf_arg_type arg_type,
 			  struct bpf_call_arg_meta *meta)
@@ -1018,7 +1037,10 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 	} else if (arg_type == ARG_CONST_STACK_SIZE ||
 		   arg_type == ARG_CONST_STACK_SIZE_OR_ZERO) {
 		expected_type = CONST_IMM;
-		if (type != expected_type)
+		/* One exception. Allow UNKNOWN_VALUE registers when the
+		 * boundaries are known and don't cause unsafe memory accesses
+		 */
+		if (type != UNKNOWN_VALUE && type != expected_type)
 			goto err_type;
 	} else if (arg_type == ARG_CONST_MAP_PTR) {
 		expected_type = CONST_PTR_TO_MAP;
@@ -1099,15 +1121,47 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 			verbose("ARG_CONST_STACK_SIZE cannot be first argument\n");
 			return -EACCES;
 		}
-		if (regs[regno - 1].type == PTR_TO_PACKET)
-			err = check_packet_access(env, regno - 1, 0, reg->imm);
-		else if (regs[regno - 1].type == PTR_TO_MAP_VALUE)
-			err = check_map_access(env, regno - 1, 0, reg->imm);
-		else if (regs[regno - 1].type == PTR_TO_MAP_VALUE_ADJ)
-			err = check_map_access_adj(env, regno - 1, 0, reg->imm);
-		else
-			err = check_stack_boundary(env, regno - 1, reg->imm,
-						   zero_size_allowed, meta);
+
+		/* If the register is UNKNOWN_VALUE, the access check happens
+		 * using its boundaries. Otherwise, just use its imm
+		 */
+		if (type == UNKNOWN_VALUE) {
+			/* For unprivileged variable accesses, disable raw
+			 * mode so that the program is required to
+			 * initialize all the memory that the helper could
+			 * just partially fill up.
+			 */
+			meta = NULL;
+
+			if (reg->min_value < 0) {
+				verbose("R%d min value is negative, either use unsigned or 'var &= const'\n",
+					regno);
+				return -EACCES;
+			}
+
+			if (reg->min_value == 0) {
+				err = check_helper_mem_access(env, regno - 1, 0,
+							      zero_size_allowed,
+							      meta);
+				if (err)
+					return err;
+			}
+
+			if (reg->max_value == BPF_REGISTER_MAX_RANGE) {
+				verbose("R%d unbounded memory access, use 'var &= const' or 'if (var < const)'\n",
+					regno);
+				return -EACCES;
+			}
+			err = check_helper_mem_access(env, regno - 1,
+						      reg->max_value,
+						      zero_size_allowed, meta);
+			if (err)
+				return err;
+		} else {
+			/* register is CONST_IMM */
+			err = check_helper_mem_access(env, regno - 1, reg->imm,
+						      zero_size_allowed, meta);
+		}
 	}
 
 	return err;
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index e7b075819c08..9bb45346dc72 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -3442,6 +3442,416 @@ static struct bpf_test tests[] = {
 		.result = ACCEPT,
 		.result_unpriv = REJECT,
 	},
+	{
+		"helper access to variable memory: stack, bitwise AND + JMP, correct bounds",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -64),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -64),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -56),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -48),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -40),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -32),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -24),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -16),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -8),
+			BPF_MOV64_IMM(BPF_REG_2, 16),
+			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_2, -128),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_1, -128),
+			BPF_ALU64_IMM(BPF_AND, BPF_REG_2, 64),
+			BPF_MOV64_IMM(BPF_REG_4, 0),
+			BPF_JMP_REG(BPF_JGE, BPF_REG_4, BPF_REG_2, 2),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to variable memory: stack, bitwise AND, zero included",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -64),
+			BPF_MOV64_IMM(BPF_REG_2, 16),
+			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_2, -128),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_1, -128),
+			BPF_ALU64_IMM(BPF_AND, BPF_REG_2, 64),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid stack type R1 off=-64 access_size=0",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to variable memory: stack, bitwise AND + JMP, wrong max",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -64),
+			BPF_MOV64_IMM(BPF_REG_2, 16),
+			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_2, -128),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_1, -128),
+			BPF_ALU64_IMM(BPF_AND, BPF_REG_2, 65),
+			BPF_MOV64_IMM(BPF_REG_4, 0),
+			BPF_JMP_REG(BPF_JGE, BPF_REG_4, BPF_REG_2, 2),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid stack type R1 off=-64 access_size=65",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to variable memory: stack, JMP, correct bounds",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -64),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -64),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -56),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -48),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -40),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -32),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -24),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -16),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -8),
+			BPF_MOV64_IMM(BPF_REG_2, 16),
+			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_2, -128),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_1, -128),
+			BPF_JMP_IMM(BPF_JGT, BPF_REG_2, 64, 4),
+			BPF_MOV64_IMM(BPF_REG_4, 0),
+			BPF_JMP_REG(BPF_JGE, BPF_REG_4, BPF_REG_2, 2),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to variable memory: stack, JMP (signed), correct bounds",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -64),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -64),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -56),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -48),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -40),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -32),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -24),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -16),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -8),
+			BPF_MOV64_IMM(BPF_REG_2, 16),
+			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_2, -128),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_1, -128),
+			BPF_JMP_IMM(BPF_JSGT, BPF_REG_2, 64, 4),
+			BPF_MOV64_IMM(BPF_REG_4, 0),
+			BPF_JMP_REG(BPF_JSGE, BPF_REG_4, BPF_REG_2, 2),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to variable memory: stack, JMP, bounds + offset",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -64),
+			BPF_MOV64_IMM(BPF_REG_2, 16),
+			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_2, -128),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_1, -128),
+			BPF_JMP_IMM(BPF_JGT, BPF_REG_2, 64, 5),
+			BPF_MOV64_IMM(BPF_REG_4, 0),
+			BPF_JMP_REG(BPF_JGE, BPF_REG_4, BPF_REG_2, 3),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, 1),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid stack type R1 off=-64 access_size=65",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to variable memory: stack, JMP, wrong max",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -64),
+			BPF_MOV64_IMM(BPF_REG_2, 16),
+			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_2, -128),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_1, -128),
+			BPF_JMP_IMM(BPF_JGT, BPF_REG_2, 65, 4),
+			BPF_MOV64_IMM(BPF_REG_4, 0),
+			BPF_JMP_REG(BPF_JGE, BPF_REG_4, BPF_REG_2, 2),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid stack type R1 off=-64 access_size=65",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to variable memory: stack, JMP, no max check",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -64),
+			BPF_MOV64_IMM(BPF_REG_2, 16),
+			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_2, -128),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_1, -128),
+			BPF_MOV64_IMM(BPF_REG_4, 0),
+			BPF_JMP_REG(BPF_JGE, BPF_REG_4, BPF_REG_2, 2),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R2 unbounded memory access",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to variable memory: stack, JMP, no min check",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -64),
+			BPF_MOV64_IMM(BPF_REG_2, 16),
+			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_2, -128),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_1, -128),
+			BPF_JMP_IMM(BPF_JGT, BPF_REG_2, 64, 3),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid stack type R1 off=-64 access_size=0",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to variable memory: stack, JMP (signed), no min check",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -64),
+			BPF_MOV64_IMM(BPF_REG_2, 16),
+			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_2, -128),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_1, -128),
+			BPF_JMP_IMM(BPF_JSGT, BPF_REG_2, 64, 3),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R2 min value is negative",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to variable memory: map, JMP, correct bounds",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 10),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_MOV64_IMM(BPF_REG_2, sizeof(struct test_val)),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_2, -128),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_10, -128),
+			BPF_JMP_IMM(BPF_JSGT, BPF_REG_2,
+				sizeof(struct test_val), 4),
+			BPF_MOV64_IMM(BPF_REG_4, 0),
+			BPF_JMP_REG(BPF_JGE, BPF_REG_4, BPF_REG_2, 2),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to variable memory: map, JMP, wrong max",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 10),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_MOV64_IMM(BPF_REG_2, sizeof(struct test_val)),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_2, -128),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_10, -128),
+			BPF_JMP_IMM(BPF_JSGT, BPF_REG_2,
+				sizeof(struct test_val) + 1, 4),
+			BPF_MOV64_IMM(BPF_REG_4, 0),
+			BPF_JMP_REG(BPF_JGE, BPF_REG_4, BPF_REG_2, 2),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr = "invalid access to map value, value_size=48 off=0 size=49",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to variable memory: map adjusted, JMP, correct bounds",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 11),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 20),
+			BPF_MOV64_IMM(BPF_REG_2, sizeof(struct test_val)),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_2, -128),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_10, -128),
+			BPF_JMP_IMM(BPF_JSGT, BPF_REG_2,
+				sizeof(struct test_val) - 20, 4),
+			BPF_MOV64_IMM(BPF_REG_4, 0),
+			BPF_JMP_REG(BPF_JGE, BPF_REG_4, BPF_REG_2, 2),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to variable memory: map adjusted, JMP, wrong max",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 11),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 20),
+			BPF_MOV64_IMM(BPF_REG_2, sizeof(struct test_val)),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_2, -128),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_10, -128),
+			BPF_JMP_IMM(BPF_JSGT, BPF_REG_2,
+				sizeof(struct test_val) - 19, 4),
+			BPF_MOV64_IMM(BPF_REG_4, 0),
+			BPF_JMP_REG(BPF_JGE, BPF_REG_4, BPF_REG_2, 2),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr = "R1 min value is outside of the array range",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to variable memory: size > 0 not allowed on NULL",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_1, 0),
+			BPF_MOV64_IMM(BPF_REG_2, 0),
+			BPF_ALU64_IMM(BPF_AND, BPF_REG_2, 64),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_MOV64_IMM(BPF_REG_4, 0),
+			BPF_MOV64_IMM(BPF_REG_5, 0),
+			BPF_EMIT_CALL(BPF_FUNC_csum_diff),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R1 type=imm expected=fp",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"helper access to variable memory: size = 0 not allowed on != NULL",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -8),
+			BPF_MOV64_IMM(BPF_REG_2, 0),
+			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_2, 0),
+			BPF_ALU64_IMM(BPF_AND, BPF_REG_2, 8),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_MOV64_IMM(BPF_REG_4, 0),
+			BPF_MOV64_IMM(BPF_REG_5, 0),
+			BPF_EMIT_CALL(BPF_FUNC_csum_diff),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid stack type R1 off=-8 access_size=0",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"helper access to variable memory: 8 bytes leak",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -64),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -64),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -56),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -48),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -40),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -24),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -16),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -8),
+			BPF_MOV64_IMM(BPF_REG_2, 0),
+			BPF_ALU64_IMM(BPF_AND, BPF_REG_2, 63),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, 1),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_1, BPF_REG_10, -16),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid indirect read from stack off -64+32 size 64",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to variable memory: 8 bytes no leak (init memory)",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -64),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -56),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -48),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -40),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -32),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -24),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -16),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_0, -8),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -64),
+			BPF_MOV64_IMM(BPF_REG_2, 0),
+			BPF_ALU64_IMM(BPF_AND, BPF_REG_2, 32),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, 32),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_1, BPF_REG_10, -16),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
 };
 
 static int probe_filter_length(const struct bpf_insn *fp)
-- 
2.8.0
