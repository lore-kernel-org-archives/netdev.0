From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 2/2] bpf: teach verifier to recognize imm += ptr pattern
Date: Thu, 19 May 2016 18:17:14 -0700
Message-ID: <1463707034-2372430-3-git-send-email-ast@fb.com>
References: <1463707034-2372430-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
	<kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:1567 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754679AbcETBRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 21:17:20 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u4K1DYVh005818
	for <netdev@vger.kernel.org>; Thu, 19 May 2016 18:17:18 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 231qsrr8kq-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 19 May 2016 18:17:18 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 96a72e921e2811e69c1b24be05956610-dd3f6c50 for <netdev@vger.kernel.org>;	Thu,
 19 May 2016 18:17:15 -0700
In-Reply-To: <1463707034-2372430-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Humans don't write C code like:
  u8 *ptr = skb->data;
  int imm = 4;
  imm += ptr;
but from llvm backend point of view 'imm' and 'ptr' are registers and
imm += ptr may be preferred vs ptr += imm depending which register value
will be used further in the code, while verifier can only recognize ptr += imm.
That caused small unrelated changes in the C code of the bpf program to
trigger rejection by the verifier. Therefore teach the verifier to recognize
both ptr += imm and imm += ptr.
For example:
when R6=pkt(id=0,off=0,r=62) R7=imm22
after r7 += r6 instruction
will be R6=pkt(id=0,off=0,r=62) R7=pkt(id=0,off=22,r=62)

Fixes: 969bf05eb3ce ("bpf: direct packet access")
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/verifier.c | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index d54e34874579..668e07903c8f 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1245,6 +1245,7 @@ static int check_packet_ptr_add(struct verifier_env *env, struct bpf_insn *insn)
 	struct reg_state *regs = env->cur_state.regs;
 	struct reg_state *dst_reg = &regs[insn->dst_reg];
 	struct reg_state *src_reg = &regs[insn->src_reg];
+	struct reg_state tmp_reg;
 	s32 imm;
 
 	if (BPF_SRC(insn->code) == BPF_K) {
@@ -1267,6 +1268,19 @@ add_imm:
 		 */
 		dst_reg->off += imm;
 	} else {
+		if (src_reg->type == PTR_TO_PACKET) {
+			/* R6=pkt(id=0,off=0,r=62) R7=imm22; r7 += r6 */
+			tmp_reg = *dst_reg;  /* save r7 state */
+			*dst_reg = *src_reg; /* copy pkt_ptr state r6 into r7 */
+			src_reg = &tmp_reg;  /* pretend it's src_reg state */
+			/* if the checks below reject it, the copy won't matter,
+			 * since we're rejecting the whole program. If all ok,
+			 * then imm22 state will be added to r7
+			 * and r7 will be pkt(id=0,off=22,r=62) while
+			 * r6 will stay as pkt(id=0,off=0,r=62)
+			 */
+		}
+
 		if (src_reg->type == CONST_IMM) {
 			/* pkt_ptr += reg where reg is known constant */
 			imm = src_reg->imm;
@@ -1565,7 +1579,9 @@ static int check_alu_op(struct verifier_env *env, struct bpf_insn *insn)
 			return 0;
 		} else if (opcode == BPF_ADD &&
 			   BPF_CLASS(insn->code) == BPF_ALU64 &&
-			   dst_reg->type == PTR_TO_PACKET) {
+			   (dst_reg->type == PTR_TO_PACKET ||
+			    (BPF_SRC(insn->code) == BPF_X &&
+			     regs[insn->src_reg].type == PTR_TO_PACKET))) {
 			/* ptr_to_packet += K|X */
 			return check_packet_ptr_add(env, insn);
 		} else if (BPF_CLASS(insn->code) == BPF_ALU64 &&
-- 
2.8.0
