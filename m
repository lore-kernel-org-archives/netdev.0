From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 2/5] bpf: allow helpers access to map element values
Date: Mon, 9 Jan 2017 10:19:47 -0800
Message-ID: <1483985990-1532850-3-git-send-email-ast@fb.com>
References: <1483985990-1532850-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Gianluca Borello <g.borello@gmail.com>,
        Josef Bacik <jbacik@fb.com>, <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:39868 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1163293AbdAISTx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 13:19:53 -0500
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v09I9wYh023075
        for <netdev@vger.kernel.org>; Mon, 9 Jan 2017 10:19:52 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 27tw88nye4-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 10:19:52 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.102.107.99) with ESMTP id
 3606c1bed69811e68c310002c99293a0-739f9a50 for <netdev@vger.kernel.org>;        Mon,
 09 Jan 2017 10:19:51 -0800
In-Reply-To: <1483985990-1532850-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gianluca Borello <g.borello@gmail.com>

Enable helpers to directly access a map element value by passing a
register type PTR_TO_MAP_VALUE (or PTR_TO_MAP_VALUE_ADJ) to helper
arguments ARG_PTR_TO_STACK or ARG_PTR_TO_RAW_STACK.

This enables several use cases. For example, a typical tracing program
might want to capture pathnames passed to sys_open() with:

struct trace_data {
	char pathname[PATHLEN];
};

SEC("kprobe/sys_open")
void bpf_sys_open(struct pt_regs *ctx)
{
	struct trace_data data;
	bpf_probe_read(data.pathname, sizeof(data.pathname), ctx->di);

	/* consume data.pathname, for example via
	 * bpf_trace_printk() or bpf_perf_event_output()
	 */
}

Such a program could easily hit the stack limit in case PATHLEN needs to
be large or more local variables need to exist, both of which are quite
common scenarios. Allowing direct helper access to map element values,
one could do:

struct bpf_map_def SEC("maps") scratch_map = {
	.type = BPF_MAP_TYPE_PERCPU_ARRAY,
	.key_size = sizeof(u32),
	.value_size = sizeof(struct trace_data),
	.max_entries = 1,
};

SEC("kprobe/sys_open")
int bpf_sys_open(struct pt_regs *ctx)
{
	int id = 0;
	struct trace_data *p = bpf_map_lookup_elem(&scratch_map, &id);
	if (!p)
		return;
	bpf_probe_read(p->pathname, sizeof(p->pathname), ctx->di);

	/* consume p->pathname, for example via
	 * bpf_trace_printk() or bpf_perf_event_output()
	 */
}

And wouldn't risk exhausting the stack.

Code changes are loosely modeled after commit 6841de8b0d03 ("bpf: allow
helpers access the packet directly"). Unlike with PTR_TO_PACKET, these
changes just work with ARG_PTR_TO_STACK and ARG_PTR_TO_RAW_STACK (not
ARG_PTR_TO_MAP_KEY, ARG_PTR_TO_MAP_VALUE, ...): adding those would be
trivial, but since there is not currently a use case for that, it's
reasonable to limit the set of changes.

Also, add new tests to make sure accesses to map element values from
helpers never go out of boundary, even when adjusted.

Signed-off-by: Gianluca Borello <g.borello@gmail.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/verifier.c                       |   9 +-
 tools/testing/selftests/bpf/test_verifier.c | 491 ++++++++++++++++++++++++++++
 2 files changed, 498 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 8333fbcfbfe7..b7014606745b 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -627,7 +627,7 @@ static int check_map_access(struct bpf_verifier_env *env, u32 regno, int off,
 {
 	struct bpf_map *map = env->cur_state.regs[regno].map_ptr;
 
-	if (off < 0 || off + size > map->value_size) {
+	if (off < 0 || size <= 0 || off + size > map->value_size) {
 		verbose("invalid access to map value, value_size=%d off=%d size=%d\n",
 			map->value_size, off, size);
 		return -EACCES;
@@ -1025,7 +1025,8 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 		 */
 		if (type == CONST_IMM && reg->imm == 0)
 			/* final test in check_stack_boundary() */;
-		else if (type != PTR_TO_PACKET && type != expected_type)
+		else if (type != PTR_TO_PACKET && type != PTR_TO_MAP_VALUE &&
+			 type != PTR_TO_MAP_VALUE_ADJ && type != expected_type)
 			goto err_type;
 		meta->raw_mode = arg_type == ARG_PTR_TO_RAW_STACK;
 	} else {
@@ -1088,6 +1089,10 @@ static int check_func_arg(struct bpf_verifier_env *env, u32 regno,
 		}
 		if (regs[regno - 1].type == PTR_TO_PACKET)
 			err = check_packet_access(env, regno - 1, 0, reg->imm);
+		else if (regs[regno - 1].type == PTR_TO_MAP_VALUE)
+			err = check_map_access(env, regno - 1, 0, reg->imm);
+		else if (regs[regno - 1].type == PTR_TO_MAP_VALUE_ADJ)
+			err = check_map_access_adj(env, regno - 1, 0, reg->imm);
 		else
 			err = check_stack_boundary(env, regno - 1, reg->imm,
 						   zero_size_allowed, meta);
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 853d7e43434a..b7732e557bf9 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -2905,6 +2905,497 @@ static struct bpf_test tests[] = {
 		.result = REJECT,
 		.errstr = "invalid bpf_context access",
 	},
+	{
+		"helper access to map: full range",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 4),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_MOV64_IMM(BPF_REG_2, sizeof(struct test_val)),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to map: partial range",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 4),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_MOV64_IMM(BPF_REG_2, 8),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to map: empty range",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 4),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_MOV64_IMM(BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr = "invalid access to map value, value_size=48 off=0 size=0",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to map: out-of-bound range",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 4),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_MOV64_IMM(BPF_REG_2, sizeof(struct test_val) + 8),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr = "invalid access to map value, value_size=48 off=0 size=56",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to map: negative range",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 4),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_MOV64_IMM(BPF_REG_2, -8),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr = "invalid access to map value, value_size=48 off=0 size=-8",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to adjusted map (via const imm): full range",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 5),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1,
+				offsetof(struct test_val, foo)),
+			BPF_MOV64_IMM(BPF_REG_2,
+				sizeof(struct test_val) -
+				offsetof(struct test_val, foo)),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to adjusted map (via const imm): partial range",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 5),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1,
+				offsetof(struct test_val, foo)),
+			BPF_MOV64_IMM(BPF_REG_2, 8),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to adjusted map (via const imm): empty range",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 5),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1,
+				offsetof(struct test_val, foo)),
+			BPF_MOV64_IMM(BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr = "R1 min value is outside of the array range",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to adjusted map (via const imm): out-of-bound range",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 5),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1,
+				offsetof(struct test_val, foo)),
+			BPF_MOV64_IMM(BPF_REG_2,
+				sizeof(struct test_val) -
+				offsetof(struct test_val, foo) + 8),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr = "invalid access to map value, value_size=48 off=4 size=52",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to adjusted map (via const imm): negative range (> adjustment)",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 5),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1,
+				offsetof(struct test_val, foo)),
+			BPF_MOV64_IMM(BPF_REG_2, -8),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr = "invalid access to map value, value_size=48 off=4 size=-8",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to adjusted map (via const imm): negative range (< adjustment)",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 5),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1,
+				offsetof(struct test_val, foo)),
+			BPF_MOV64_IMM(BPF_REG_2, -1),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr = "R1 min value is outside of the array range",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to adjusted map (via const reg): full range",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 6),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_MOV64_IMM(BPF_REG_3,
+				offsetof(struct test_val, foo)),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_1, BPF_REG_3),
+			BPF_MOV64_IMM(BPF_REG_2,
+				sizeof(struct test_val) -
+				offsetof(struct test_val, foo)),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to adjusted map (via const reg): partial range",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 6),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_MOV64_IMM(BPF_REG_3,
+				offsetof(struct test_val, foo)),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_1, BPF_REG_3),
+			BPF_MOV64_IMM(BPF_REG_2, 8),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to adjusted map (via const reg): empty range",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 6),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_1, BPF_REG_3),
+			BPF_MOV64_IMM(BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr = "R1 min value is outside of the array range",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to adjusted map (via const reg): out-of-bound range",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 6),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_MOV64_IMM(BPF_REG_3,
+				offsetof(struct test_val, foo)),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_1, BPF_REG_3),
+			BPF_MOV64_IMM(BPF_REG_2,
+				sizeof(struct test_val) -
+				offsetof(struct test_val, foo) + 8),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr = "invalid access to map value, value_size=48 off=4 size=52",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to adjusted map (via const reg): negative range (> adjustment)",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 6),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_MOV64_IMM(BPF_REG_3,
+				offsetof(struct test_val, foo)),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_1, BPF_REG_3),
+			BPF_MOV64_IMM(BPF_REG_2, -8),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr = "invalid access to map value, value_size=48 off=4 size=-8",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to adjusted map (via const reg): negative range (< adjustment)",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 6),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_MOV64_IMM(BPF_REG_3,
+				offsetof(struct test_val, foo)),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_1, BPF_REG_3),
+			BPF_MOV64_IMM(BPF_REG_2, -1),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr = "R1 min value is outside of the array range",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to adjusted map (via variable): full range",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 7),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_0, 0),
+			BPF_JMP_IMM(BPF_JGT, BPF_REG_3,
+				offsetof(struct test_val, foo), 4),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_1, BPF_REG_3),
+			BPF_MOV64_IMM(BPF_REG_2,
+				sizeof(struct test_val) -
+				offsetof(struct test_val, foo)),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to adjusted map (via variable): partial range",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 7),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_0, 0),
+			BPF_JMP_IMM(BPF_JGT, BPF_REG_3,
+				offsetof(struct test_val, foo), 4),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_1, BPF_REG_3),
+			BPF_MOV64_IMM(BPF_REG_2, 8),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to adjusted map (via variable): empty range",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 7),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_0, 0),
+			BPF_JMP_IMM(BPF_JGT, BPF_REG_3,
+				offsetof(struct test_val, foo), 4),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_1, BPF_REG_3),
+			BPF_MOV64_IMM(BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr = "R1 min value is outside of the array range",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to adjusted map (via variable): no max check",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 6),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_0, 0),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_1, BPF_REG_3),
+			BPF_MOV64_IMM(BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr = "R1 min value is negative, either use unsigned index or do a if (index >=0) check",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
+	{
+		"helper access to adjusted map (via variable): wrong max check",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, 0, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_EMIT_CALL(BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 7),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_0, 0),
+			BPF_JMP_IMM(BPF_JGT, BPF_REG_3,
+				offsetof(struct test_val, foo), 4),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_1, BPF_REG_3),
+			BPF_MOV64_IMM(BPF_REG_2,
+				sizeof(struct test_val) -
+				offsetof(struct test_val, foo) + 1),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_EMIT_CALL(BPF_FUNC_probe_read),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr = "invalid access to map value, value_size=48 off=4 size=45",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_TRACEPOINT,
+	},
 };
 
 static int probe_filter_length(const struct bpf_insn *fp)
-- 
2.8.0
