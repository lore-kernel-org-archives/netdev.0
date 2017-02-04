From: William Tu <u9012063@gmail.com>
Subject: [PATHv3 net-next] bpf: enable verifier to add 0 to packet ptr
Date: Sat,  4 Feb 2017 08:37:29 -0800
Message-ID: <1486226249-1851-1-git-send-email-u9012063@gmail.com>
Cc: Mihai Budiu <mbudiu@vmware.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34281 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750851AbdBDQht (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 11:37:49 -0500
Received: by mail-pf0-f195.google.com with SMTP id y143so3756018pfb.1
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 08:37:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch fixes the case when adding a zero value to the packet
pointer.  The zero value could come from src_reg equals type
BPF_K or CONST_IMM.  The patch fixes both, otherwise the verifer
reports the following error:
  [...]
    R0=imm0,min_value=0,max_value=0
    R1=pkt(id=0,off=0,r=4)
    R2=pkt_end R3=fp-12
    R4=imm4,min_value=4,max_value=4
    R5=pkt(id=0,off=4,r=4)
  269: (bf) r2 = r0     // r2 becomes imm0
  270: (77) r2 >>= 3
  271: (bf) r4 = r1     // r4 becomes pkt ptr
  272: (0f) r4 += r2    // r4 += 0
  addition of negative constant to packet pointer is not allowed

Signed-off-by: William Tu <u9012063@gmail.com>
Signed-off-by: Mihai Budiu <mbudiu@vmware.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/verifier.c                       |  2 +-
 tools/testing/selftests/bpf/test_verifier.c | 23 +++++++++++++++++++++++
 2 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index fb3513b..1a754e5 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1397,7 +1397,7 @@ static int check_packet_ptr_add(struct bpf_verifier_env *env,
 		imm = insn->imm;
 
 add_imm:
-		if (imm <= 0) {
+		if (imm < 0) {
 			verbose("addition of negative constant to packet pointer is not allowed\n");
 			return -EACCES;
 		}
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 0d0912c..c841e5f 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -2404,6 +2404,29 @@ static struct bpf_test tests[] = {
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
 	{
+		"direct packet access: test14 (pkt_ptr += 0, CONST_IMM, good access)",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 22),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 7),
+			BPF_MOV64_IMM(BPF_REG_5, 12),
+			BPF_ALU64_IMM(BPF_RSH, BPF_REG_5, 4),
+			BPF_MOV64_REG(BPF_REG_6, BPF_REG_2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_6, BPF_REG_5),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_6, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 1),
+			BPF_EXIT_INSN(),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
 		"helper access to packet: test1, valid packet_ptr range",
 		.insns = {
 			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
-- 
2.7.4
