From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: [PATCH RFCv3 02/14] arm64: introduce aarch64_insn_gen_branch_reg()
Date: Mon, 14 Jul 2014 23:25:00 -0700
Message-ID: <1405405512-4423-3-git-send-email-zlim.lnx@gmail.com>
References: <1405405512-4423-1-git-send-email-zlim.lnx@gmail.com>
Cc: Zi Shen Lim <zlim.lnx@gmail.com>, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Jiang Liu <liuj97@gmail.com>,
	AKASHI Takahiro <takahiro.akashi@linaro.org>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:64910 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757765AbaGOGZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 02:25:33 -0400
In-Reply-To: <1405405512-4423-1-git-send-email-zlim.lnx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce function to generate unconditional branch (register)
instructions.

Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
---
 arch/arm64/include/asm/insn.h |  7 +++++++
 arch/arm64/kernel/insn.c      | 35 +++++++++++++++++++++++++++++++++--
 2 files changed, 40 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/include/asm/insn.h b/arch/arm64/include/asm/insn.h
index a98c495..5080962 100644
--- a/arch/arm64/include/asm/insn.h
+++ b/arch/arm64/include/asm/insn.h
@@ -71,6 +71,7 @@ enum aarch64_insn_imm_type {
 
 enum aarch64_insn_register_type {
 	AARCH64_INSN_REGTYPE_RT,
+	AARCH64_INSN_REGTYPE_RN,
 };
 
 enum aarch64_insn_register {
@@ -119,6 +120,7 @@ enum aarch64_insn_variant {
 enum aarch64_insn_branch_type {
 	AARCH64_INSN_BRANCH_NOLINK,
 	AARCH64_INSN_BRANCH_LINK,
+	AARCH64_INSN_BRANCH_RETURN,
 	AARCH64_INSN_BRANCH_COMP_ZERO,
 	AARCH64_INSN_BRANCH_COMP_NONZERO,
 };
@@ -138,6 +140,9 @@ __AARCH64_INSN_FUNCS(hvc,	0xFFE0001F, 0xD4000002)
 __AARCH64_INSN_FUNCS(smc,	0xFFE0001F, 0xD4000003)
 __AARCH64_INSN_FUNCS(brk,	0xFFE0001F, 0xD4200000)
 __AARCH64_INSN_FUNCS(hint,	0xFFFFF01F, 0xD503201F)
+__AARCH64_INSN_FUNCS(br,	0xFFFFFC1F, 0xD61F0000)
+__AARCH64_INSN_FUNCS(blr,	0xFFFFFC1F, 0xD63F0000)
+__AARCH64_INSN_FUNCS(ret,	0xFFFFFC1F, 0xD65F0000)
 
 #undef	__AARCH64_INSN_FUNCS
 
@@ -156,6 +161,8 @@ u32 aarch64_insn_gen_comp_branch_imm(unsigned long pc, unsigned long addr,
 				     enum aarch64_insn_branch_type type);
 u32 aarch64_insn_gen_hint(enum aarch64_insn_hint_op op);
 u32 aarch64_insn_gen_nop(void);
+u32 aarch64_insn_gen_branch_reg(enum aarch64_insn_register reg,
+				enum aarch64_insn_branch_type type);
 
 bool aarch64_insn_hotpatch_safe(u32 old_insn, u32 new_insn);
 
diff --git a/arch/arm64/kernel/insn.c b/arch/arm64/kernel/insn.c
index d01bb4e..50193d5 100644
--- a/arch/arm64/kernel/insn.c
+++ b/arch/arm64/kernel/insn.c
@@ -281,6 +281,9 @@ static u32 aarch64_insn_encode_register(enum aarch64_insn_register_type type,
 	case AARCH64_INSN_REGTYPE_RT:
 		shift = 0;
 		break;
+	case AARCH64_INSN_REGTYPE_RN:
+		shift = 5;
+		break;
 	default:
 		pr_err("%s: unknown register type encoding %d\n", __func__,
 		       type);
@@ -323,10 +326,16 @@ u32 __kprobes aarch64_insn_gen_branch_imm(unsigned long pc, unsigned long addr,
 	 */
 	offset = branch_imm_common(pc, addr, SZ_128M);
 
-	if (type == AARCH64_INSN_BRANCH_LINK)
+	switch (type) {
+	case AARCH64_INSN_BRANCH_LINK:
 		insn = aarch64_insn_get_bl_value();
-	else
+		break;
+	case AARCH64_INSN_BRANCH_NOLINK:
 		insn = aarch64_insn_get_b_value();
+		break;
+	default:
+		BUG_ON(1);
+	}
 
 	return aarch64_insn_encode_immediate(AARCH64_INSN_IMM_26, insn,
 					     offset >> 2);
@@ -378,3 +387,25 @@ u32 __kprobes aarch64_insn_gen_nop(void)
 {
 	return aarch64_insn_gen_hint(AARCH64_INSN_HINT_NOP);
 }
+
+u32 aarch64_insn_gen_branch_reg(enum aarch64_insn_register reg,
+				enum aarch64_insn_branch_type type)
+{
+	u32 insn;
+
+	switch (type) {
+	case AARCH64_INSN_BRANCH_NOLINK:
+		insn = aarch64_insn_get_br_value();
+		break;
+	case AARCH64_INSN_BRANCH_LINK:
+		insn = aarch64_insn_get_blr_value();
+		break;
+	case AARCH64_INSN_BRANCH_RETURN:
+		insn = aarch64_insn_get_ret_value();
+		break;
+	default:
+		BUG_ON(1);
+	}
+
+	return aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RN, insn, reg);
+}
-- 
1.9.1
