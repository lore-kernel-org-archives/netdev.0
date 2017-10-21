From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 2/3] bpf: fix pattern matches for direct packet access
Date: Sat, 21 Oct 2017 02:34:22 +0200
Message-ID: <40e994d92bf40661a94e52de299d12fe5538f9c7.1508545543.git.daniel@iogearbox.net>
References: <cover.1508545543.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, john.r.fastabend@gmail.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47362 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752891AbdJUAex (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 20:34:53 -0400
In-Reply-To: <cover.1508545543.git.daniel@iogearbox.net>
In-Reply-To: <cover.1508545543.git.daniel@iogearbox.net>
References: <cover.1508545543.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexander had a test program with direct packet access, where
the access test was in the form of data + X > data_end. In an
unrelated change to the program LLVM decided to swap the branches
and emitted code for the test in form of data + X <= data_end.
We hadn't seen these being generated previously, thus verifier
would reject the program. Therefore, fix up the verifier to
detect all test cases, so we don't run into such issues in the
future.

Fixes: b4e432f1000a ("bpf: enable BPF_J{LT, LE, SLT, SLE} opcodes in verifier")
Reported-by: Alexander Alemayhu <alexander@alemayhu.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/verifier.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 49cb5ad..c48ca2a 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -2874,18 +2874,42 @@ static int check_cond_jmp_op(struct bpf_verifier_env *env,
 	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JGT &&
 		   dst_reg->type == PTR_TO_PACKET &&
 		   regs[insn->src_reg].type == PTR_TO_PACKET_END) {
+		/* pkt_data' > pkt_end */
 		find_good_pkt_pointers(this_branch, dst_reg, false);
+	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JGT &&
+		   dst_reg->type == PTR_TO_PACKET_END &&
+		   regs[insn->src_reg].type == PTR_TO_PACKET) {
+		/* pkt_end > pkt_data' */
+		find_good_pkt_pointers(other_branch, &regs[insn->src_reg], true);
 	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JLT &&
 		   dst_reg->type == PTR_TO_PACKET &&
 		   regs[insn->src_reg].type == PTR_TO_PACKET_END) {
+		/* pkt_data' < pkt_end */
 		find_good_pkt_pointers(other_branch, dst_reg, true);
+	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JLT &&
+		   dst_reg->type == PTR_TO_PACKET_END &&
+		   regs[insn->src_reg].type == PTR_TO_PACKET) {
+		/* pkt_end < pkt_data' */
+		find_good_pkt_pointers(this_branch, &regs[insn->src_reg], false);
+	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JGE &&
+		   dst_reg->type == PTR_TO_PACKET &&
+		   regs[insn->src_reg].type == PTR_TO_PACKET_END) {
+		/* pkt_data' >= pkt_end */
+		find_good_pkt_pointers(this_branch, dst_reg, true);
 	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JGE &&
 		   dst_reg->type == PTR_TO_PACKET_END &&
 		   regs[insn->src_reg].type == PTR_TO_PACKET) {
+		/* pkt_end >= pkt_data' */
 		find_good_pkt_pointers(other_branch, &regs[insn->src_reg], false);
 	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JLE &&
+		   dst_reg->type == PTR_TO_PACKET &&
+		   regs[insn->src_reg].type == PTR_TO_PACKET_END) {
+		/* pkt_data' <= pkt_end */
+		find_good_pkt_pointers(other_branch, dst_reg, false);
+	} else if (BPF_SRC(insn->code) == BPF_X && opcode == BPF_JLE &&
 		   dst_reg->type == PTR_TO_PACKET_END &&
 		   regs[insn->src_reg].type == PTR_TO_PACKET) {
+		/* pkt_end <= pkt_data' */
 		find_good_pkt_pointers(this_branch, &regs[insn->src_reg], true);
 	} else if (is_pointer_value(env, insn->dst_reg)) {
 		verbose("R%d pointer comparison prohibited\n", insn->dst_reg);
-- 
1.9.3
