From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next] bpf/verifier: improve disassembly of BPF_END
 instructions
Date: Thu, 21 Sep 2017 16:09:34 +0100
Message-ID: <7013ee9d-a8e6-13fd-cc5f-86cf3d8bf4e0@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([148.163.129.52]:55220 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751387AbdIUPJk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 11:09:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

print_bpf_insn() was treating all BPF_ALU[64] the same, but BPF_END has a
 different structure: it has a size in insn->imm (even if it's BPF_X) and
 uses the BPF_SRC (X or K) to indicate which endianness to use.  So it
 needs different code to print it.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
It's not the same format as the new LLVM asm uses, does that matter?
AFAIK the LLVM format doesn't comprehend BPF_TO_LE, just assumes that all
 endian ops are necessarily swaps (rather than sometimes nops).

 kernel/bpf/verifier.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 799b245..e7657a4 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -331,20 +331,29 @@ static void print_bpf_insn(const struct bpf_verifier_env *env,
 	u8 class = BPF_CLASS(insn->code);
 
 	if (class == BPF_ALU || class == BPF_ALU64) {
-		if (BPF_SRC(insn->code) == BPF_X)
+		if (BPF_OP(insn->code) == BPF_END) {
+			if (class == BPF_ALU64)
+				verbose("BUG_alu64_%02x\n", insn->code);
+			else
+				verbose("(%02x) (u%d) r%d %s %s\n",
+					insn->code, insn->imm, insn->dst_reg,
+					bpf_alu_string[BPF_END >> 4],
+					BPF_SRC(insn->code) == BPF_X ? "be" : "le");
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
