From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next] ebpf: Allow dereferences of PTR_TO_STACK registers
Date: Thu, 23 Jul 2015 14:24:40 -0700
Message-ID: <1437686680-1157510-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
	<kernel-team@fb.com>, Alex Gartrell <agartrell@fb.com>
To: <davem@davemloft.net>, <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:8227 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754436AbbGWVZX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 17:25:23 -0400
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t6NLPJwa027142
	for <netdev@vger.kernel.org>; Thu, 23 Jul 2015 14:25:22 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1vu7ju8637-4
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 23 Jul 2015 14:25:22 -0700
Received: from facebook.com (2401:db00:20:7017:face:0:13:0)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 3be3ce1e318111e589430002c99293a0-bb3fd2b0 for <netdev@vger.kernel.org>;	Thu,
 23 Jul 2015 14:24:42 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

        mov %rsp, %r1           ; r1 = rsp
        add $-8, %r1            ; r1 = rsp - 8
        store_q $123, -8(%rsp)  ; *(u64*)r1 = 123  <- valid
        store_q $123, (%r1)     ; *(u64*)r1 = 123  <- previously invalid
        mov $0, %r0
        exit                    ; Always need to exit

And we'd get the following error:

	0: (bf) r1 = r10
	1: (07) r1 += -8
	2: (7a) *(u64 *)(r10 -8) = 999
	3: (7a) *(u64 *)(r1 +0) = 999
	R1 invalid mem access 'fp'

	Unable to load program

We already know that a register is a stack address and the appropriate
offset, so we should be able to validate those references as well.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 kernel/bpf/verifier.c       |  6 ++++-
 samples/bpf/test_verifier.c | 59 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 64 insertions(+), 1 deletion(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 039d866..cd307df 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -648,6 +648,9 @@ static int check_mem_access(struct verifier_env *env, u32 regno, int off,
 	struct verifier_state *state = &env->cur_state;
 	int size, err = 0;
 
+	if (state->regs[regno].type == PTR_TO_STACK)
+		off += state->regs[regno].imm;
+
 	size = bpf_size_to_bytes(bpf_size);
 	if (size < 0)
 		return size;
@@ -667,7 +670,8 @@ static int check_mem_access(struct verifier_env *env, u32 regno, int off,
 		if (!err && t == BPF_READ && value_regno >= 0)
 			mark_reg_unknown_value(state->regs, value_regno);
 
-	} else if (state->regs[regno].type == FRAME_PTR) {
+	} else if (state->regs[regno].type == FRAME_PTR ||
+		   state->regs[regno].type == PTR_TO_STACK) {
 		if (off >= 0 || off < -MAX_BPF_STACK) {
 			verbose("invalid stack off=%d size=%d\n", off, size);
 			return -EACCES;
diff --git a/samples/bpf/test_verifier.c b/samples/bpf/test_verifier.c
index 6936059..ee0f110 100644
--- a/samples/bpf/test_verifier.c
+++ b/samples/bpf/test_verifier.c
@@ -822,6 +822,65 @@ static struct bpf_test tests[] = {
 		.result = ACCEPT,
 		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
 	},
+	{
+		"PTR_TO_STACK store/load",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -10),
+			BPF_ST_MEM(BPF_DW, BPF_REG_1, 2, 0xfaceb00c),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1, 2),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+	},
+	{
+		"PTR_TO_STACK store/load - bad alignment on off",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_1, 2, 0xfaceb00c),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1, 2),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "misaligned access off -6 size 8",
+	},
+	{
+		"PTR_TO_STACK store/load - bad alignment on reg",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -10),
+			BPF_ST_MEM(BPF_DW, BPF_REG_1, 8, 0xfaceb00c),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1, 8),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "misaligned access off -2 size 8",
+	},
+	{
+		"PTR_TO_STACK store/load - out of bounds low",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -80000),
+			BPF_ST_MEM(BPF_DW, BPF_REG_1, 8, 0xfaceb00c),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1, 8),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid stack off=-79992 size=8",
+	},
+	{
+		"PTR_TO_STACK store/load - out of bounds high",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_1, 8, 0xfaceb00c),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1, 8),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid stack off=0 size=8",
+	},
 };
 
 static int probe_filter_length(struct bpf_insn *fp)
-- 
Alex Gartrell <agartrell@fb.com>
