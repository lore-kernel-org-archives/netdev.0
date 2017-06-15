From: Edward Cree <ecree@solarflare.com>
Subject: [RFC PATCH v2 net-next 01/10] selftests/bpf: add test for mixed
 signed and unsigned bounds checks
Date: Thu, 15 Jun 2017 15:36:32 +0100
Message-ID: <35287424-c6b9-579d-738f-2ee792fd1019@solarflare.com>
References: <87861693-dbcd-c026-a1b4-8c27c2a90735@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>
To: <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:43847 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752170AbdFOOgn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 10:36:43 -0400
In-Reply-To: <87861693-dbcd-c026-a1b4-8c27c2a90735@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently fails due to bug in verifier bounds handling.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 tools/testing/selftests/bpf/test_verifier.c | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index c0af019..fceed67 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -5279,6 +5279,32 @@ static struct bpf_test tests[] = {
 		.errstr = "invalid bpf_context access",
 		.prog_type = BPF_PROG_TYPE_LWT_IN,
 	},
+	{
+		"bounds checks mixing signed and unsigned",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 7),
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -16, -8),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_1, BPF_REG_10, -16),
+			BPF_MOV64_IMM(BPF_REG_2, -1),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_1, BPF_REG_2, 3),
+			BPF_JMP_IMM(BPF_JSGT, BPF_REG_1, 1, 2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
+			BPF_ST_MEM(BPF_B, BPF_REG_0, 0, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 3 },
+		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
+		.result = REJECT,
+		.result_unpriv = REJECT,
+	},
 };
 
 static int probe_filter_length(const struct bpf_insn *fp)
