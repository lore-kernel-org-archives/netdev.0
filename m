From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net] bpf: improve verifier packet range checks
Date: Fri, 24 Mar 2017 15:57:33 -0700
Message-ID: <20170324225733.2776121-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:34187 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753411AbdCXW5g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 18:57:36 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.20/8.16.0.20) with SMTP id v2OMvYg3017996
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 15:57:34 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 29cqswmvfe-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 15:57:34 -0700
Received: from facebook.com (2401:db00:11:d082:face:0:5:0)      by
 mx-out.facebook.com (10.103.99.97) with ESMTP  id
 444d33ca10e511e7b8ea0002c9931860-91bfa9a0 for <netdev@vger.kernel.org>;        Fri,
 24 Mar 2017 15:57:33 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

llvm can optimize the 'if (ptr > data_end)' checks to be in the order
slightly different than the original C code which will confuse verifier.
Like:
if (ptr + 16 > data_end)
  return TC_ACT_SHOT;
// may be followed by
if (ptr + 14 > data_end)
  return TC_ACT_SHOT;
while llvm can see that 'ptr' is valid for all 16 bytes,
the verifier could not.
Fix verifier logic to account for such case and add a test.

Reported-by: Huapeng Zhou <hzhou@fb.com>
Fixes: 969bf05eb3ce ("bpf: direct packet access")
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
new verifier test is added in the middle of older tests to
avoid conflicts with new tests in net-next.

 kernel/bpf/verifier.c                       |  5 +++--
 tools/testing/selftests/bpf/test_verifier.c | 20 ++++++++++++++++++++
 2 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 796b68d00119..5e6202e62265 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1973,14 +1973,15 @@ static void find_good_pkt_pointers(struct bpf_verifier_state *state,
 
 	for (i = 0; i < MAX_BPF_REG; i++)
 		if (regs[i].type == PTR_TO_PACKET && regs[i].id == dst_reg->id)
-			regs[i].range = dst_reg->off;
+			/* keep the maximum range already checked */
+			regs[i].range = max(regs[i].range, dst_reg->off);
 
 	for (i = 0; i < MAX_BPF_STACK; i += BPF_REG_SIZE) {
 		if (state->stack_slot_type[i] != STACK_SPILL)
 			continue;
 		reg = &state->spilled_regs[i / BPF_REG_SIZE];
 		if (reg->type == PTR_TO_PACKET && reg->id == dst_reg->id)
-			reg->range = dst_reg->off;
+			reg->range = max(reg->range, dst_reg->off);
 	}
 }
 
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index d1555e4240c0..7d761d4cc759 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -3418,6 +3418,26 @@ static struct bpf_test tests[] = {
 		.prog_type = BPF_PROG_TYPE_LWT_XMIT,
 	},
 	{
+		"overlapping checks for direct packet access",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 4),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 6),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_1, BPF_REG_3, 1),
+			BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_2, 6),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_LWT_XMIT,
+	},
+	{
 		"invalid access of tc_classid for LWT_IN",
 		.insns = {
 			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
-- 
2.9.3
