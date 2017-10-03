From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net-next 3/8] bpf: enforce return code for cgroup-bpf programs
Date: Mon, 2 Oct 2017 22:50:23 -0700
Message-ID: <20171003055028.1294791-4-ast@fb.com>
References: <20171003055028.1294791-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, Tejun Heo <tj@kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:41135 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750787AbdJCFub (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 01:50:31 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v935nT4A008513
        for <netdev@vger.kernel.org>; Mon, 2 Oct 2017 22:50:31 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2dbwmpabw4-5
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 22:50:31 -0700
In-Reply-To: <20171003055028.1294791-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

with addition of tnum logic the verifier got smart enough and
we can enforce return codes at program load time.
For now do so for cgroup-bpf program types.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/verifier.c                       | 40 ++++++++++++++++
 tools/testing/selftests/bpf/test_verifier.c | 72 +++++++++++++++++++++++++++++
 2 files changed, 112 insertions(+)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 4cf9b72c59a0..52b022310f6a 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -3073,6 +3073,43 @@ static int check_ld_abs(struct bpf_verifier_env *env, struct bpf_insn *insn)
 	return 0;
 }
 
+static int check_return_code(struct bpf_verifier_env *env)
+{
+	struct bpf_reg_state *reg;
+	struct tnum range = tnum_range(0, 1);
+
+	switch (env->prog->type) {
+	case BPF_PROG_TYPE_CGROUP_SKB:
+	case BPF_PROG_TYPE_CGROUP_SOCK:
+	case BPF_PROG_TYPE_SOCK_OPS:
+		break;
+	default:
+		return 0;
+	}
+
+	reg = &env->cur_state.regs[BPF_REG_0];
+	if (reg->type != SCALAR_VALUE) {
+		verbose("At program exit the register R0 is not a known value (%s)\n",
+			reg_type_str[reg->type]);
+		return -EINVAL;
+	}
+
+	if (!tnum_in(range, reg->var_off)) {
+		verbose("At program exit the register R0 ");
+		if (!tnum_is_unknown(reg->var_off)) {
+			char tn_buf[48];
+
+			tnum_strn(tn_buf, sizeof(tn_buf), reg->var_off);
+			verbose("has value %s", tn_buf);
+		} else {
+			verbose("has unknown scalar value");
+		}
+		verbose(" should have been 0 or 1\n");
+		return -EINVAL;
+	}
+	return 0;
+}
+
 /* non-recursive DFS pseudo code
  * 1  procedure DFS-iterative(G,v):
  * 2      label v as discovered
@@ -3863,6 +3900,9 @@ static int do_check(struct bpf_verifier_env *env)
 					return -EACCES;
 				}
 
+				err = check_return_code(env);
+				if (err)
+					return err;
 process_bpf_exit:
 				insn_idx = pop_stack(env, &prev_insn_idx);
 				if (insn_idx < 0) {
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 290d5056c165..cc91d0159f43 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -6892,6 +6892,78 @@ static struct bpf_test tests[] = {
 		.result = ACCEPT,
 		.prog_type = BPF_PROG_TYPE_XDP,
 	},
+	{
+		"bpf_exit with invalid return code. test1",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R0 has value (0x0; 0xffffffff)",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_CGROUP_SOCK,
+	},
+	{
+		"bpf_exit with invalid return code. test2",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1, 0),
+			BPF_ALU64_IMM(BPF_AND, BPF_REG_0, 1),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_CGROUP_SOCK,
+	},
+	{
+		"bpf_exit with invalid return code. test3",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1, 0),
+			BPF_ALU64_IMM(BPF_AND, BPF_REG_0, 3),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R0 has value (0x0; 0x3)",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_CGROUP_SOCK,
+	},
+	{
+		"bpf_exit with invalid return code. test4",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 1),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_CGROUP_SOCK,
+	},
+	{
+		"bpf_exit with invalid return code. test5",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 2),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R0 has value (0x2; 0x0)",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_CGROUP_SOCK,
+	},
+	{
+		"bpf_exit with invalid return code. test6",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R0 is not a known value (ctx)",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_CGROUP_SOCK,
+	},
+	{
+		"bpf_exit with invalid return code. test7",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1, 0),
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1, 4),
+			BPF_ALU64_REG(BPF_MUL, BPF_REG_0, BPF_REG_2),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R0 has unknown scalar value",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_CGROUP_SOCK,
+	},
 };
 
 static int probe_filter_length(const struct bpf_insn *fp)
-- 
2.9.5
