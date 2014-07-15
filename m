From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: [PATCH RFCv3 09/14] arm64: introduce aarch64_insn_gen_add_sub_shifted_reg()
Date: Mon, 14 Jul 2014 23:25:07 -0700
Message-ID: <1405405512-4423-10-git-send-email-zlim.lnx@gmail.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405405512-4423-1-git-send-email-zlim.lnx@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduce function to generate add/subtract (shifted register)
instructions.

Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
---
 arch/arm64/include/asm/insn.h | 11 ++++++++++
 arch/arm64/kernel/insn.c      | 49 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 60 insertions(+)

diff --git a/arch/arm64/include/asm/insn.h b/arch/arm64/include/asm/insn.h
index 49dec28..c0a765d 100644
--- a/arch/arm64/include/asm/insn.h
+++ b/arch/arm64/include/asm/insn.h
@@ -67,6 +67,7 @@ enum aarch64_insn_imm_type {
 	AARCH64_INSN_IMM_12,
 	AARCH64_INSN_IMM_9,
 	AARCH64_INSN_IMM_7,
+	AARCH64_INSN_IMM_6,
 	AARCH64_INSN_IMM_S,
 	AARCH64_INSN_IMM_R,
 	AARCH64_INSN_IMM_MAX
@@ -206,6 +207,10 @@ __AARCH64_INSN_FUNCS(bfm,	0x7F800000, 0x33000000)
 __AARCH64_INSN_FUNCS(movz,	0x7F800000, 0x52800000)
 __AARCH64_INSN_FUNCS(ubfm,	0x7F800000, 0x53000000)
 __AARCH64_INSN_FUNCS(movk,	0x7F800000, 0x72800000)
+__AARCH64_INSN_FUNCS(add,	0x7F200000, 0x0B000000)
+__AARCH64_INSN_FUNCS(adds,	0x7F200000, 0x2B000000)
+__AARCH64_INSN_FUNCS(sub,	0x7F200000, 0x4B000000)
+__AARCH64_INSN_FUNCS(subs,	0x7F200000, 0x6B000000)
 __AARCH64_INSN_FUNCS(b,		0xFC000000, 0x14000000)
 __AARCH64_INSN_FUNCS(bl,	0xFC000000, 0x94000000)
 __AARCH64_INSN_FUNCS(cbz,	0xFE000000, 0x34000000)
@@ -265,6 +270,12 @@ u32 aarch64_insn_gen_movewide(enum aarch64_insn_register dst,
 			      int imm, int shift,
 			      enum aarch64_insn_variant variant,
 			      enum aarch64_insn_movewide_type type);
+u32 aarch64_insn_gen_add_sub_shifted_reg(enum aarch64_insn_register dst,
+					 enum aarch64_insn_register src,
+					 enum aarch64_insn_register reg,
+					 int shift,
+					 enum aarch64_insn_variant variant,
+					 enum aarch64_insn_adsb_type type);
 
 bool aarch64_insn_hotpatch_safe(u32 old_insn, u32 new_insn);
 
diff --git a/arch/arm64/kernel/insn.c b/arch/arm64/kernel/insn.c
index 1cb94b4..e24cb13 100644
--- a/arch/arm64/kernel/insn.c
+++ b/arch/arm64/kernel/insn.c
@@ -257,6 +257,7 @@ u32 __kprobes aarch64_insn_encode_immediate(enum aarch64_insn_imm_type type,
 		mask = BIT(7) - 1;
 		shift = 15;
 		break;
+	case AARCH64_INSN_IMM_6:
 	case AARCH64_INSN_IMM_S:
 		mask = BIT(6) - 1;
 		shift = 10;
@@ -696,3 +697,51 @@ u32 aarch64_insn_gen_movewide(enum aarch64_insn_register dst,
 
 	return aarch64_insn_encode_immediate(AARCH64_INSN_IMM_16, insn, imm);
 }
+
+u32 aarch64_insn_gen_add_sub_shifted_reg(enum aarch64_insn_register dst,
+					 enum aarch64_insn_register src,
+					 enum aarch64_insn_register reg,
+					 int shift,
+					 enum aarch64_insn_variant variant,
+					 enum aarch64_insn_adsb_type type)
+{
+	u32 insn;
+
+	switch (type) {
+	case AARCH64_INSN_ADSB_ADD:
+		insn = aarch64_insn_get_add_value();
+		break;
+	case AARCH64_INSN_ADSB_SUB:
+		insn = aarch64_insn_get_sub_value();
+		break;
+	case AARCH64_INSN_ADSB_ADD_SETFLAGS:
+		insn = aarch64_insn_get_adds_value();
+		break;
+	case AARCH64_INSN_ADSB_SUB_SETFLAGS:
+		insn = aarch64_insn_get_subs_value();
+		break;
+	default:
+		BUG_ON(1);
+	}
+
+	switch (variant) {
+	case AARCH64_INSN_VARIANT_32BIT:
+		BUG_ON(shift < 0 || shift > 31);
+		break;
+	case AARCH64_INSN_VARIANT_64BIT:
+		insn |= BIT(31);
+		BUG_ON(shift < 0 || shift > 63);
+		break;
+	default:
+		BUG_ON(1);
+	}
+
+
+	insn = aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RD, insn, dst);
+
+	insn = aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RN, insn, src);
+
+	insn = aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RM, insn, reg);
+
+	return aarch64_insn_encode_immediate(AARCH64_INSN_IMM_6, insn, shift);
+}
-- 
1.9.1
