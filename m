From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH v2 net-next 1/2] bpf/verifier: improve disassembly of BPF_END
 instructions
Date: Tue, 26 Sep 2017 16:35:13 +0100
Message-ID: <b0a84ccf-8842-876c-ec82-b4b1da3d6efa@solarflare.com>
References: <52270348-67f1-4e7a-cd2f-9d611ae94064@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <daniel@iogearbox.net>,
        <alexei.starovoitov@gmail.com>, <ys114321@gmail.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:33410 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1031415AbdIZPf0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 11:35:26 -0400
In-Reply-To: <52270348-67f1-4e7a-cd2f-9d611ae94064@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

print_bpf_insn() was treating all BPF_ALU[64] the same, but BPF_END has a
 different structure: it has a size in insn->imm (even if it's BPF_X) and
 uses the BPF_SRC (X or K) to indicate which endianness to use.  So it
 needs different code to print it.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 kernel/bpf/verifier.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 799b245..3aaa3262 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -325,26 +325,40 @@ static const char *const bpf_jmp_string[16] = {
 	[BPF_EXIT >> 4] = "exit",
 };
 
+static void print_bpf_end_insn(const struct bpf_verifier_env *env,
+			       const struct bpf_insn *insn)
+{
+	verbose("(%02x) r%d = %s%d r%d\n", insn->code, insn->dst_reg,
+		BPF_SRC(insn->code) == BPF_TO_BE ? "be" : "le",
+		insn->imm, insn->dst_reg);
+}
+
 static void print_bpf_insn(const struct bpf_verifier_env *env,
 			   const struct bpf_insn *insn)
 {
 	u8 class = BPF_CLASS(insn->code);
 
 	if (class == BPF_ALU || class == BPF_ALU64) {
-		if (BPF_SRC(insn->code) == BPF_X)
+		if (BPF_OP(insn->code) == BPF_END) {
+			if (class == BPF_ALU64)
+				verbose("BUG_alu64_%02x\n", insn->code);
+			else
+				print_bpf_end_insn(env, insn);
+		} else if (BPF_SRC(insn->code) == BPF_X) {
 			verbose("(%02x) %sr%d %s %sr%d\n",
 				insn->code, class == BPF_ALU ? "(u32) " : "",
 				insn->dst_reg,
 				bpf_alu_string[BPF_OP(insn->code) >> 4],
 				class == BPF_ALU ? "(u32) " : "",
 				insn->src_reg);
-		else
+		} else {
 			verbose("(%02x) %sr%d %s %s%d\n",
 				insn->code, class == BPF_ALU ? "(u32) " : "",
 				insn->dst_reg,
 				bpf_alu_string[BPF_OP(insn->code) >> 4],
 				class == BPF_ALU ? "(u32) " : "",
 				insn->imm);
+		}
 	} else if (class == BPF_STX) {
 		if (BPF_MODE(insn->code) == BPF_MEM)
 			verbose("(%02x) *(%s *)(r%d %+d) = r%d\n",
