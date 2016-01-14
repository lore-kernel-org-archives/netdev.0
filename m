From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: [PATCH 1/2] arm64: insn: remove BUG_ON from codegen
Date: Wed, 13 Jan 2016 23:33:21 -0800
Message-ID: <1452756802-16511-1-git-send-email-zlim.lnx@gmail.com>
Cc: Zi Shen Lim <zlim.lnx@gmail.com>, Rabin Vincent <rabin@rab.in>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Will Deacon <will.deacon@arm.com>,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Catalin Marinas <catalin.marinas@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:36341 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808AbcANHdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 02:33:45 -0500
Received: by mail-pa0-f68.google.com with SMTP id a20so22905948pag.3
        for <netdev@vger.kernel.org>; Wed, 13 Jan 2016 23:33:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During code generation, we used to BUG_ON unknown/unsupported encoding
or invalid parameters.

Instead, now we report these as errors and simply return the
instruction AARCH64_BREAK_FAULT. Users of these codegen helpers should
check for and handle this failure condition as appropriate.

Otherwise, unhandled codegen failure will result in trapping at
run-time due to AARCH64_BREAK_FAULT, which is arguably better than a
BUG_ON.

Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
Cc: Will Deacon <will.deacon@arm.com>
---
Per discussion here: http://www.spinics.net/lists/arm-kernel/msg474179.html

 arch/arm64/kernel/insn.c | 165 ++++++++++++++++++++++++++++++++---------------
 1 file changed, 112 insertions(+), 53 deletions(-)

diff --git a/arch/arm64/kernel/insn.c b/arch/arm64/kernel/insn.c
index c08b9ad..7371455 100644
--- a/arch/arm64/kernel/insn.c
+++ b/arch/arm64/kernel/insn.c
@@ -2,7 +2,7 @@
  * Copyright (C) 2013 Huawei Ltd.
  * Author: Jiang Liu <liuj97@gmail.com>
  *
- * Copyright (C) 2014 Zi Shen Lim <zlim.lnx@gmail.com>
+ * Copyright (C) 2014-2016 Zi Shen Lim <zlim.lnx@gmail.com>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -363,6 +363,9 @@ u32 __kprobes aarch64_insn_encode_immediate(enum aarch64_insn_imm_type type,
 	u32 immlo, immhi, mask;
 	int shift;
 
+	if (insn == AARCH64_BREAK_FAULT)
+		return AARCH64_BREAK_FAULT;
+
 	switch (type) {
 	case AARCH64_INSN_IMM_ADR:
 		shift = 0;
@@ -377,7 +380,7 @@ u32 __kprobes aarch64_insn_encode_immediate(enum aarch64_insn_imm_type type,
 		if (aarch64_get_imm_shift_mask(type, &mask, &shift) < 0) {
 			pr_err("aarch64_insn_encode_immediate: unknown immediate encoding %d\n",
 			       type);
-			return 0;
+			return AARCH64_BREAK_FAULT;
 		}
 	}
 
@@ -394,9 +397,12 @@ static u32 aarch64_insn_encode_register(enum aarch64_insn_register_type type,
 {
 	int shift;
 
+	if (insn == AARCH64_BREAK_FAULT)
+		return AARCH64_BREAK_FAULT;
+
 	if (reg < AARCH64_INSN_REG_0 || reg > AARCH64_INSN_REG_SP) {
 		pr_err("%s: unknown register encoding %d\n", __func__, reg);
-		return 0;
+		return AARCH64_BREAK_FAULT;
 	}
 
 	switch (type) {
@@ -417,7 +423,7 @@ static u32 aarch64_insn_encode_register(enum aarch64_insn_register_type type,
 	default:
 		pr_err("%s: unknown register type encoding %d\n", __func__,
 		       type);
-		return 0;
+		return AARCH64_BREAK_FAULT;
 	}
 
 	insn &= ~(GENMASK(4, 0) << shift);
@@ -446,7 +452,7 @@ static u32 aarch64_insn_encode_ldst_size(enum aarch64_insn_size_type type,
 		break;
 	default:
 		pr_err("%s: unknown size encoding %d\n", __func__, type);
-		return 0;
+		return AARCH64_BREAK_FAULT;
 	}
 
 	insn &= ~GENMASK(31, 30);
@@ -460,14 +466,17 @@ static inline long branch_imm_common(unsigned long pc, unsigned long addr,
 {
 	long offset;
 
-	/*
-	 * PC: A 64-bit Program Counter holding the address of the current
-	 * instruction. A64 instructions must be word-aligned.
-	 */
-	BUG_ON((pc & 0x3) || (addr & 0x3));
+	if ((pc & 0x3) || (addr & 0x3)) {
+		pr_err("%s: A64 instructions must be word aligned\n", __func__);
+		return range;
+	}
 
 	offset = ((long)addr - (long)pc);
-	BUG_ON(offset < -range || offset >= range);
+
+	if (offset < -range || offset >= range) {
+		pr_err("%s: offset out of range\n", __func__);
+		return range;
+	}
 
 	return offset;
 }
@@ -484,6 +493,8 @@ u32 __kprobes aarch64_insn_gen_branch_imm(unsigned long pc, unsigned long addr,
 	 * texts are within +/-128M.
 	 */
 	offset = branch_imm_common(pc, addr, SZ_128M);
+	if (offset >= SZ_128M)
+		return AARCH64_BREAK_FAULT;
 
 	switch (type) {
 	case AARCH64_INSN_BRANCH_LINK:
@@ -493,7 +504,7 @@ u32 __kprobes aarch64_insn_gen_branch_imm(unsigned long pc, unsigned long addr,
 		insn = aarch64_insn_get_b_value();
 		break;
 	default:
-		BUG_ON(1);
+		pr_err("%s: unknown branch encoding %d\n", __func__, type);
 		return AARCH64_BREAK_FAULT;
 	}
 
@@ -510,6 +521,8 @@ u32 aarch64_insn_gen_comp_branch_imm(unsigned long pc, unsigned long addr,
 	long offset;
 
 	offset = branch_imm_common(pc, addr, SZ_1M);
+	if (offset >= SZ_1M)
+		return AARCH64_BREAK_FAULT;
 
 	switch (type) {
 	case AARCH64_INSN_BRANCH_COMP_ZERO:
@@ -519,7 +532,7 @@ u32 aarch64_insn_gen_comp_branch_imm(unsigned long pc, unsigned long addr,
 		insn = aarch64_insn_get_cbnz_value();
 		break;
 	default:
-		BUG_ON(1);
+		pr_err("%s: unknown branch encoding %d\n", __func__, type);
 		return AARCH64_BREAK_FAULT;
 	}
 
@@ -530,7 +543,7 @@ u32 aarch64_insn_gen_comp_branch_imm(unsigned long pc, unsigned long addr,
 		insn |= AARCH64_INSN_SF_BIT;
 		break;
 	default:
-		BUG_ON(1);
+		pr_err("%s: unknown variant encoding %d\n", __func__, variant);
 		return AARCH64_BREAK_FAULT;
 	}
 
@@ -550,7 +563,10 @@ u32 aarch64_insn_gen_cond_branch_imm(unsigned long pc, unsigned long addr,
 
 	insn = aarch64_insn_get_bcond_value();
 
-	BUG_ON(cond < AARCH64_INSN_COND_EQ || cond > AARCH64_INSN_COND_AL);
+	if (cond < AARCH64_INSN_COND_EQ || cond > AARCH64_INSN_COND_AL) {
+		pr_err("%s: unknown condition encoding %d\n", __func__, cond);
+		return AARCH64_BREAK_FAULT;
+	}
 	insn |= cond;
 
 	return aarch64_insn_encode_immediate(AARCH64_INSN_IMM_19, insn,
@@ -583,7 +599,7 @@ u32 aarch64_insn_gen_branch_reg(enum aarch64_insn_register reg,
 		insn = aarch64_insn_get_ret_value();
 		break;
 	default:
-		BUG_ON(1);
+		pr_err("%s: unknown branch encoding %d\n", __func__, type);
 		return AARCH64_BREAK_FAULT;
 	}
 
@@ -606,7 +622,7 @@ u32 aarch64_insn_gen_load_store_reg(enum aarch64_insn_register reg,
 		insn = aarch64_insn_get_str_reg_value();
 		break;
 	default:
-		BUG_ON(1);
+		pr_err("%s: unknown load/store encoding %d\n", __func__, type);
 		return AARCH64_BREAK_FAULT;
 	}
 
@@ -645,26 +661,30 @@ u32 aarch64_insn_gen_load_store_pair(enum aarch64_insn_register reg1,
 		insn = aarch64_insn_get_stp_post_value();
 		break;
 	default:
-		BUG_ON(1);
+		pr_err("%s: unknown load/store encoding %d\n", __func__, type);
 		return AARCH64_BREAK_FAULT;
 	}
 
 	switch (variant) {
 	case AARCH64_INSN_VARIANT_32BIT:
-		/* offset must be multiples of 4 in the range [-256, 252] */
-		BUG_ON(offset & 0x3);
-		BUG_ON(offset < -256 || offset > 252);
+		if ((offset & 0x3) || (offset < -256) || (offset > 252)) {
+			pr_err("%s: offset must be multiples of 4 in the range of [-256, 252] %d\n",
+			       __func__, offset);
+			return AARCH64_BREAK_FAULT;
+		}
 		shift = 2;
 		break;
 	case AARCH64_INSN_VARIANT_64BIT:
-		/* offset must be multiples of 8 in the range [-512, 504] */
-		BUG_ON(offset & 0x7);
-		BUG_ON(offset < -512 || offset > 504);
+		if ((offset & 0x7) || (offset < -512) || (offset > 504)) {
+			pr_err("%s: offset must be multiples of 8 in the range of [-512, 504] %d\n",
+			       __func__, offset);
+			return AARCH64_BREAK_FAULT;
+		}
 		shift = 3;
 		insn |= AARCH64_INSN_SF_BIT;
 		break;
 	default:
-		BUG_ON(1);
+		pr_err("%s: unknown variant encoding %d\n", __func__, variant);
 		return AARCH64_BREAK_FAULT;
 	}
 
@@ -702,7 +722,7 @@ u32 aarch64_insn_gen_add_sub_imm(enum aarch64_insn_register dst,
 		insn = aarch64_insn_get_subs_imm_value();
 		break;
 	default:
-		BUG_ON(1);
+		pr_err("%s: unknown add/sub encoding %d\n", __func__, type);
 		return AARCH64_BREAK_FAULT;
 	}
 
@@ -713,11 +733,14 @@ u32 aarch64_insn_gen_add_sub_imm(enum aarch64_insn_register dst,
 		insn |= AARCH64_INSN_SF_BIT;
 		break;
 	default:
-		BUG_ON(1);
+		pr_err("%s: unknown variant encoding %d\n", __func__, variant);
 		return AARCH64_BREAK_FAULT;
 	}
 
-	BUG_ON(imm & ~(SZ_4K - 1));
+	if (imm & ~(SZ_4K - 1)) {
+		pr_err("%s: invalid immediate encoding %d\n", __func__, imm);
+		return AARCH64_BREAK_FAULT;
+	}
 
 	insn = aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RD, insn, dst);
 
@@ -746,7 +769,7 @@ u32 aarch64_insn_gen_bitfield(enum aarch64_insn_register dst,
 		insn = aarch64_insn_get_sbfm_value();
 		break;
 	default:
-		BUG_ON(1);
+		pr_err("%s: unknown bitfield encoding %d\n", __func__, type);
 		return AARCH64_BREAK_FAULT;
 	}
 
@@ -759,12 +782,18 @@ u32 aarch64_insn_gen_bitfield(enum aarch64_insn_register dst,
 		mask = GENMASK(5, 0);
 		break;
 	default:
-		BUG_ON(1);
+		pr_err("%s: unknown variant encoding %d\n", __func__, variant);
 		return AARCH64_BREAK_FAULT;
 	}
 
-	BUG_ON(immr & ~mask);
-	BUG_ON(imms & ~mask);
+	if (immr & ~mask) {
+		pr_err("%s: invalid immr encoding %d\n", __func__, immr);
+		return AARCH64_BREAK_FAULT;
+	}
+	if (imms & ~mask) {
+		pr_err("%s: invalid imms encoding %d\n", __func__, imms);
+		return AARCH64_BREAK_FAULT;
+	}
 
 	insn = aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RD, insn, dst);
 
@@ -793,23 +822,33 @@ u32 aarch64_insn_gen_movewide(enum aarch64_insn_register dst,
 		insn = aarch64_insn_get_movn_value();
 		break;
 	default:
-		BUG_ON(1);
+		pr_err("%s: unknown movewide encoding %d\n", __func__, type);
 		return AARCH64_BREAK_FAULT;
 	}
 
-	BUG_ON(imm & ~(SZ_64K - 1));
+	if (imm & ~(SZ_64K - 1)) {
+		pr_err("%s: invalid immediate encoding %d\n", __func__, imm);
+		return AARCH64_BREAK_FAULT;
+	}
 
 	switch (variant) {
 	case AARCH64_INSN_VARIANT_32BIT:
-		BUG_ON(shift != 0 && shift != 16);
+		if (shift != 0 && shift != 16) {
+			pr_err("%s: invalid shift encoding %d\n", __func__,
+			       shift);
+			return AARCH64_BREAK_FAULT;
+		}
 		break;
 	case AARCH64_INSN_VARIANT_64BIT:
 		insn |= AARCH64_INSN_SF_BIT;
-		BUG_ON(shift != 0 && shift != 16 && shift != 32 &&
-		       shift != 48);
+		if (shift != 0 && shift != 16 && shift != 32 && shift != 48) {
+			pr_err("%s: invalid shift encoding %d\n", __func__,
+			       shift);
+			return AARCH64_BREAK_FAULT;
+		}
 		break;
 	default:
-		BUG_ON(1);
+		pr_err("%s: unknown variant encoding %d\n", __func__, variant);
 		return AARCH64_BREAK_FAULT;
 	}
 
@@ -843,20 +882,28 @@ u32 aarch64_insn_gen_add_sub_shifted_reg(enum aarch64_insn_register dst,
 		insn = aarch64_insn_get_subs_value();
 		break;
 	default:
-		BUG_ON(1);
+		pr_err("%s: unknown add/sub encoding %d\n", __func__, type);
 		return AARCH64_BREAK_FAULT;
 	}
 
 	switch (variant) {
 	case AARCH64_INSN_VARIANT_32BIT:
-		BUG_ON(shift & ~(SZ_32 - 1));
+		if (shift & ~(SZ_32 - 1)) {
+			pr_err("%s: invalid shift encoding %d\n", __func__,
+			       shift);
+			return AARCH64_BREAK_FAULT;
+		}
 		break;
 	case AARCH64_INSN_VARIANT_64BIT:
 		insn |= AARCH64_INSN_SF_BIT;
-		BUG_ON(shift & ~(SZ_64 - 1));
+		if (shift & ~(SZ_64 - 1)) {
+			pr_err("%s: invalid shift encoding %d\n", __func__,
+			       shift);
+			return AARCH64_BREAK_FAULT;
+		}
 		break;
 	default:
-		BUG_ON(1);
+		pr_err("%s: unknown variant encoding %d\n", __func__, variant);
 		return AARCH64_BREAK_FAULT;
 	}
 
@@ -885,11 +932,15 @@ u32 aarch64_insn_gen_data1(enum aarch64_insn_register dst,
 		insn = aarch64_insn_get_rev32_value();
 		break;
 	case AARCH64_INSN_DATA1_REVERSE_64:
-		BUG_ON(variant != AARCH64_INSN_VARIANT_64BIT);
+		if (variant != AARCH64_INSN_VARIANT_64BIT) {
+			pr_err("%s: invalid variant for reverse64 %d\n",
+			       __func__, variant);
+			return AARCH64_BREAK_FAULT;
+		}
 		insn = aarch64_insn_get_rev64_value();
 		break;
 	default:
-		BUG_ON(1);
+		pr_err("%s: unknown data1 encoding %d\n", __func__, type);
 		return AARCH64_BREAK_FAULT;
 	}
 
@@ -900,7 +951,7 @@ u32 aarch64_insn_gen_data1(enum aarch64_insn_register dst,
 		insn |= AARCH64_INSN_SF_BIT;
 		break;
 	default:
-		BUG_ON(1);
+		pr_err("%s: unknown variant encoding %d\n", __func__, variant);
 		return AARCH64_BREAK_FAULT;
 	}
 
@@ -937,7 +988,7 @@ u32 aarch64_insn_gen_data2(enum aarch64_insn_register dst,
 		insn = aarch64_insn_get_rorv_value();
 		break;
 	default:
-		BUG_ON(1);
+		pr_err("%s: unknown data2 encoding %d\n", __func__, type);
 		return AARCH64_BREAK_FAULT;
 	}
 
@@ -948,7 +999,7 @@ u32 aarch64_insn_gen_data2(enum aarch64_insn_register dst,
 		insn |= AARCH64_INSN_SF_BIT;
 		break;
 	default:
-		BUG_ON(1);
+		pr_err("%s: unknown variant encoding %d\n", __func__, variant);
 		return AARCH64_BREAK_FAULT;
 	}
 
@@ -976,7 +1027,7 @@ u32 aarch64_insn_gen_data3(enum aarch64_insn_register dst,
 		insn = aarch64_insn_get_msub_value();
 		break;
 	default:
-		BUG_ON(1);
+		pr_err("%s: unknown data3 encoding %d\n", __func__, type);
 		return AARCH64_BREAK_FAULT;
 	}
 
@@ -987,7 +1038,7 @@ u32 aarch64_insn_gen_data3(enum aarch64_insn_register dst,
 		insn |= AARCH64_INSN_SF_BIT;
 		break;
 	default:
-		BUG_ON(1);
+		pr_err("%s: unknown variant encoding %d\n", __func__, variant);
 		return AARCH64_BREAK_FAULT;
 	}
 
@@ -1037,20 +1088,28 @@ u32 aarch64_insn_gen_logical_shifted_reg(enum aarch64_insn_register dst,
 		insn = aarch64_insn_get_bics_value();
 		break;
 	default:
-		BUG_ON(1);
+		pr_err("%s: unknown logical encoding %d\n", __func__, type);
 		return AARCH64_BREAK_FAULT;
 	}
 
 	switch (variant) {
 	case AARCH64_INSN_VARIANT_32BIT:
-		BUG_ON(shift & ~(SZ_32 - 1));
+		if (shift & ~(SZ_32 - 1)) {
+			pr_err("%s: invalid shift encoding %d\n", __func__,
+			       shift);
+			return AARCH64_BREAK_FAULT;
+		}
 		break;
 	case AARCH64_INSN_VARIANT_64BIT:
 		insn |= AARCH64_INSN_SF_BIT;
-		BUG_ON(shift & ~(SZ_64 - 1));
+		if (shift & ~(SZ_64 - 1)) {
+			pr_err("%s: invalid shift encoding %d\n", __func__,
+			       shift);
+			return AARCH64_BREAK_FAULT;
+		}
 		break;
 	default:
-		BUG_ON(1);
+		pr_err("%s: unknown variant encoding %d\n", __func__, variant);
 		return AARCH64_BREAK_FAULT;
 	}
 
-- 
1.9.1
