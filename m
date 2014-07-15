From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: [PATCH RFCv3 05/14] arm64: introduce aarch64_insn_gen_load_store_pair()
Date: Mon, 14 Jul 2014 23:25:03 -0700
Message-ID: <1405405512-4423-6-git-send-email-zlim.lnx@gmail.com>
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
Received: from mail-pd0-f181.google.com ([209.85.192.181]:59795 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757820AbaGOGZh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 02:25:37 -0400
In-Reply-To: <1405405512-4423-1-git-send-email-zlim.lnx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce function to generate load/store pair instructions.

Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
---
 arch/arm64/include/asm/insn.h | 16 +++++++++++
 arch/arm64/kernel/insn.c      | 65 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 81 insertions(+)

diff --git a/arch/arm64/include/asm/insn.h b/arch/arm64/include/asm/insn.h
index 5bc1cc3..eef8f1e 100644
--- a/arch/arm64/include/asm/insn.h
+++ b/arch/arm64/include/asm/insn.h
@@ -66,12 +66,14 @@ enum aarch64_insn_imm_type {
 	AARCH64_INSN_IMM_14,
 	AARCH64_INSN_IMM_12,
 	AARCH64_INSN_IMM_9,
+	AARCH64_INSN_IMM_7,
 	AARCH64_INSN_IMM_MAX
 };
 
 enum aarch64_insn_register_type {
 	AARCH64_INSN_REGTYPE_RT,
 	AARCH64_INSN_REGTYPE_RN,
+	AARCH64_INSN_REGTYPE_RT2,
 	AARCH64_INSN_REGTYPE_RM,
 };
 
@@ -154,6 +156,10 @@ enum aarch64_insn_size_type {
 enum aarch64_insn_ldst_type {
 	AARCH64_INSN_LDST_LOAD_REG_OFFSET,
 	AARCH64_INSN_LDST_STORE_REG_OFFSET,
+	AARCH64_INSN_LDST_LOAD_PAIR_PRE_INDEX,
+	AARCH64_INSN_LDST_STORE_PAIR_PRE_INDEX,
+	AARCH64_INSN_LDST_LOAD_PAIR_POST_INDEX,
+	AARCH64_INSN_LDST_STORE_PAIR_POST_INDEX,
 };
 
 #define	__AARCH64_INSN_FUNCS(abbr, mask, val)	\
@@ -164,6 +170,10 @@ static __always_inline u32 aarch64_insn_get_##abbr##_value(void) \
 
 __AARCH64_INSN_FUNCS(str_reg,	0x3FE0EC00, 0x38206800)
 __AARCH64_INSN_FUNCS(ldr_reg,	0x3FE0EC00, 0x38606800)
+__AARCH64_INSN_FUNCS(stp_post,	0x7FC00000, 0x28800000)
+__AARCH64_INSN_FUNCS(ldp_post,	0x7FC00000, 0x28C00000)
+__AARCH64_INSN_FUNCS(stp_pre,	0x7FC00000, 0x29800000)
+__AARCH64_INSN_FUNCS(ldp_pre,	0x7FC00000, 0x29C00000)
 __AARCH64_INSN_FUNCS(b,		0xFC000000, 0x14000000)
 __AARCH64_INSN_FUNCS(bl,	0xFC000000, 0x94000000)
 __AARCH64_INSN_FUNCS(cbz,	0xFE000000, 0x34000000)
@@ -204,6 +214,12 @@ u32 aarch64_insn_gen_load_store_reg(enum aarch64_insn_register reg,
 				    enum aarch64_insn_register offset,
 				    enum aarch64_insn_size_type size,
 				    enum aarch64_insn_ldst_type type);
+u32 aarch64_insn_gen_load_store_pair(enum aarch64_insn_register reg1,
+				     enum aarch64_insn_register reg2,
+				     enum aarch64_insn_register base,
+				     int offset,
+				     enum aarch64_insn_variant variant,
+				     enum aarch64_insn_ldst_type type);
 
 bool aarch64_insn_hotpatch_safe(u32 old_insn, u32 new_insn);
 
diff --git a/arch/arm64/kernel/insn.c b/arch/arm64/kernel/insn.c
index 447ad63..e01e789 100644
--- a/arch/arm64/kernel/insn.c
+++ b/arch/arm64/kernel/insn.c
@@ -253,6 +253,10 @@ u32 __kprobes aarch64_insn_encode_immediate(enum aarch64_insn_imm_type type,
 		mask = BIT(9) - 1;
 		shift = 12;
 		break;
+	case AARCH64_INSN_IMM_7:
+		mask = BIT(7) - 1;
+		shift = 15;
+		break;
 	default:
 		pr_err("aarch64_insn_encode_immediate: unknown immediate encoding %d\n",
 			type);
@@ -284,6 +288,9 @@ static u32 aarch64_insn_encode_register(enum aarch64_insn_register_type type,
 	case AARCH64_INSN_REGTYPE_RN:
 		shift = 5;
 		break;
+	case AARCH64_INSN_REGTYPE_RT2:
+		shift = 10;
+		break;
 	case AARCH64_INSN_REGTYPE_RM:
 		shift = 16;
 		break;
@@ -488,3 +495,61 @@ u32 aarch64_insn_gen_load_store_reg(enum aarch64_insn_register reg,
 	return aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RM, insn,
 					    offset);
 }
+
+u32 aarch64_insn_gen_load_store_pair(enum aarch64_insn_register reg1,
+				     enum aarch64_insn_register reg2,
+				     enum aarch64_insn_register base,
+				     int offset,
+				     enum aarch64_insn_variant variant,
+				     enum aarch64_insn_ldst_type type)
+{
+	u32 insn;
+	int shift;
+
+	switch (type) {
+	case AARCH64_INSN_LDST_LOAD_PAIR_PRE_INDEX:
+		insn = aarch64_insn_get_ldp_pre_value();
+		break;
+	case AARCH64_INSN_LDST_STORE_PAIR_PRE_INDEX:
+		insn = aarch64_insn_get_stp_pre_value();
+		break;
+	case AARCH64_INSN_LDST_LOAD_PAIR_POST_INDEX:
+		insn = aarch64_insn_get_ldp_post_value();
+		break;
+	case AARCH64_INSN_LDST_STORE_PAIR_POST_INDEX:
+		insn = aarch64_insn_get_stp_post_value();
+		break;
+	default:
+		BUG_ON(1);
+	}
+
+	switch (variant) {
+	case AARCH64_INSN_VARIANT_32BIT:
+		/* offset must be multiples of 4 in the range [-256, 252] */
+		BUG_ON(offset & 0x3);
+		BUG_ON(offset < -256 || offset > 252);
+		shift = 2;
+		break;
+	case AARCH64_INSN_VARIANT_64BIT:
+		/* offset must be multiples of 8 in the range [-512, 504] */
+		BUG_ON(offset & 0x7);
+		BUG_ON(offset < -512 || offset > 504);
+		shift = 3;
+		insn |= BIT(31);
+		break;
+	default:
+		BUG_ON(1);
+	}
+
+	insn = aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RT, insn,
+					    reg1);
+
+	insn = aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RT2, insn,
+					    reg2);
+
+	insn = aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RN, insn,
+					    base);
+
+	return aarch64_insn_encode_immediate(AARCH64_INSN_IMM_7, insn,
+					     offset >> shift);
+}
-- 
1.9.1
