From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: [PATCH RFCv3 03/14] arm64: introduce aarch64_insn_gen_cond_branch_imm()
Date: Mon, 14 Jul 2014 23:25:01 -0700
Message-ID: <1405405512-4423-4-git-send-email-zlim.lnx@gmail.com>
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
Received: from mail-pd0-f182.google.com ([209.85.192.182]:60471 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757770AbaGOGZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 02:25:35 -0400
In-Reply-To: <1405405512-4423-1-git-send-email-zlim.lnx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce function to generate conditional branch (immediate)
instructions.

Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
---
 arch/arm64/include/asm/insn.h | 21 +++++++++++++++++++++
 arch/arm64/kernel/insn.c      | 17 +++++++++++++++++
 2 files changed, 38 insertions(+)

diff --git a/arch/arm64/include/asm/insn.h b/arch/arm64/include/asm/insn.h
index 5080962..86a8a9c 100644
--- a/arch/arm64/include/asm/insn.h
+++ b/arch/arm64/include/asm/insn.h
@@ -117,6 +117,24 @@ enum aarch64_insn_variant {
 	AARCH64_INSN_VARIANT_64BIT
 };
 
+enum aarch64_insn_condition {
+	AARCH64_INSN_COND_EQ = 0x0, /* == */
+	AARCH64_INSN_COND_NE = 0x1, /* != */
+	AARCH64_INSN_COND_CS = 0x2, /* unsigned >= */
+	AARCH64_INSN_COND_CC = 0x3, /* unsigned < */
+	AARCH64_INSN_COND_MI = 0x4, /* < 0 */
+	AARCH64_INSN_COND_PL = 0x5, /* >= 0 */
+	AARCH64_INSN_COND_VS = 0x6, /* overflow */
+	AARCH64_INSN_COND_VC = 0x7, /* no overflow */
+	AARCH64_INSN_COND_HI = 0x8, /* unsigned > */
+	AARCH64_INSN_COND_LS = 0x9, /* unsigned <= */
+	AARCH64_INSN_COND_GE = 0xa, /* signed >= */
+	AARCH64_INSN_COND_LT = 0xb, /* signed < */
+	AARCH64_INSN_COND_GT = 0xc, /* signed > */
+	AARCH64_INSN_COND_LE = 0xd, /* signed <= */
+	AARCH64_INSN_COND_AL = 0xe, /* always */
+};
+
 enum aarch64_insn_branch_type {
 	AARCH64_INSN_BRANCH_NOLINK,
 	AARCH64_INSN_BRANCH_LINK,
@@ -135,6 +153,7 @@ __AARCH64_INSN_FUNCS(b,		0xFC000000, 0x14000000)
 __AARCH64_INSN_FUNCS(bl,	0xFC000000, 0x94000000)
 __AARCH64_INSN_FUNCS(cbz,	0xFE000000, 0x34000000)
 __AARCH64_INSN_FUNCS(cbnz,	0xFE000000, 0x35000000)
+__AARCH64_INSN_FUNCS(bcond,	0xFF000010, 0x54000000)
 __AARCH64_INSN_FUNCS(svc,	0xFFE0001F, 0xD4000001)
 __AARCH64_INSN_FUNCS(hvc,	0xFFE0001F, 0xD4000002)
 __AARCH64_INSN_FUNCS(smc,	0xFFE0001F, 0xD4000003)
@@ -159,6 +178,8 @@ u32 aarch64_insn_gen_comp_branch_imm(unsigned long pc, unsigned long addr,
 				     enum aarch64_insn_register reg,
 				     enum aarch64_insn_variant variant,
 				     enum aarch64_insn_branch_type type);
+u32 aarch64_insn_gen_cond_branch_imm(unsigned long pc, unsigned long addr,
+				     enum aarch64_insn_condition cond);
 u32 aarch64_insn_gen_hint(enum aarch64_insn_hint_op op);
 u32 aarch64_insn_gen_nop(void);
 u32 aarch64_insn_gen_branch_reg(enum aarch64_insn_register reg,
diff --git a/arch/arm64/kernel/insn.c b/arch/arm64/kernel/insn.c
index 50193d5..f2cf8ab 100644
--- a/arch/arm64/kernel/insn.c
+++ b/arch/arm64/kernel/insn.c
@@ -378,6 +378,23 @@ u32 aarch64_insn_gen_comp_branch_imm(unsigned long pc, unsigned long addr,
 					     offset >> 2);
 }
 
+u32 aarch64_insn_gen_cond_branch_imm(unsigned long pc, unsigned long addr,
+				     enum aarch64_insn_condition cond)
+{
+	u32 insn;
+	long offset;
+
+	offset = branch_imm_common(pc, addr, SZ_1M);
+
+	insn = aarch64_insn_get_bcond_value();
+
+	BUG_ON(cond < AARCH64_INSN_COND_EQ || cond > AARCH64_INSN_COND_AL);
+	insn |= cond;
+
+	return aarch64_insn_encode_immediate(AARCH64_INSN_IMM_19, insn,
+					     offset >> 2);
+}
+
 u32 __kprobes aarch64_insn_gen_hint(enum aarch64_insn_hint_op op)
 {
 	return aarch64_insn_get_hint_value() | op;
-- 
1.9.1
