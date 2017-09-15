From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net] bpf/verifier: reject BPF_ALU64|BPF_END
Date: Fri, 15 Sep 2017 14:37:38 +0100
Message-ID: <8c3d5513-6171-3e68-56df-1efd0e87f071@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([148.163.129.52]:59386 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751561AbdIONn1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 09:43:27 -0400
Received: from dispatch1-us1.ppe-hosted.com (localhost.localdomain [127.0.0.1])
        by dispatch1-us1.ppe-hosted.com (Proofpoint Essentials ESMTP Server) with ESMTP id D82ACC10CE
        for <netdev@vger.kernel.org>; Fri, 15 Sep 2017 13:37:45 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neither ___bpf_prog_run nor the JITs accept it.
Also adds a new test case.

Fixes: 17a5267067f3 ("bpf: verifier (add verifier core)")
Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 kernel/bpf/verifier.c                       |  3 ++-
 tools/testing/selftests/bpf/test_verifier.c | 16 ++++++++++++++++
 2 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 477b693..799b245 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -2292,7 +2292,8 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 			}
 		} else {
 			if (insn->src_reg != BPF_REG_0 || insn->off != 0 ||
-			    (insn->imm != 16 && insn->imm != 32 && insn->imm != 64)) {
+			    (insn->imm != 16 && insn->imm != 32 && insn->imm != 64) ||
+			    BPF_CLASS(insn->code) == BPF_ALU64) {
 				verbose("BPF_END uses reserved fields\n");
 				return -EINVAL;
 			}
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 8eb0995..26f3250 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -6629,6 +6629,22 @@ static struct bpf_test tests[] = {
 		.result = REJECT,
 		.flags = F_NEEDS_EFFICIENT_UNALIGNED_ACCESS,
 	},
+	{
+		"invalid 64-bit BPF_END",
+		.insns = {
+			BPF_MOV32_IMM(BPF_REG_0, 0),
+			{
+				.code  = BPF_ALU64 | BPF_END | BPF_TO_LE,
+				.dst_reg = BPF_REG_0,
+				.src_reg = 0,
+				.off   = 0,
+				.imm   = 32,
+			},
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "BPF_END uses reserved fields",
+		.result = REJECT,
+	},
 };
 
 static int probe_filter_length(const struct bpf_insn *fp)
