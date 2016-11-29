From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH net-next] bpf: add test for the verifier equal logic bug
Date: Tue, 29 Nov 2016 12:35:19 -0500
Message-ID: <1480440919-3252-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>, <ast@kernel.org>,
        <jannh@google.com>, <daniel@iogearbox.net>, <kernel-team@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:60743 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753048AbcK2Rfo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 12:35:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a test to verify that

bpf: fix states equal logic for varlen access

actually fixed the problem.  The problem was if the register we added to our map
register was UNKNOWN in both the false and true branches and the only thing that
changed was the range then we'd incorrectly assume that the true branch was
valid, which it really wasnt.  This tests this case and properly fails without
my fix in place and passes with it in place.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 tools/testing/selftests/bpf/test_verifier.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 3c4a1fb..5da2e9d 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -2660,6 +2660,29 @@ static struct bpf_test tests[] = {
 		.result = ACCEPT,
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS
 	},
+	{
+		"invalid map access from else condition",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 6),
+			BPF_LDX_MEM(BPF_W, BPF_REG_1, BPF_REG_0, 0),
+			BPF_JMP_IMM(BPF_JGE, BPF_REG_1, MAX_ENTRIES-1, 1),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 1),
+			BPF_ALU64_IMM(BPF_LSH, BPF_REG_1, 2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, offsetof(struct test_val, foo)),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr = "R0 unbounded memory access, make sure to bounds check any array access into a map",
+		.result = REJECT,
+		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.result_unpriv = REJECT,
+	},
 };
 
 static int probe_filter_length(const struct bpf_insn *fp)
-- 
2.7.4
