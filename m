From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: [PATCH RFCv3 04/14] arm64: introduce aarch64_insn_gen_load_store_reg()
Date: Mon, 14 Jul 2014 23:25:02 -0700
Message-ID: <1405405512-4423-5-git-send-email-zlim.lnx@gmail.com>
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

Introduce function to generate load/store (register offset)
instructions.

Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
---
 arch/arm64/include/asm/insn.h | 20 ++++++++++++++
 arch/arm64/kernel/insn.c      | 62 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 82 insertions(+)

diff --git a/arch/arm64/include/asm/insn.h b/arch/arm64/include/asm/insn.h
index 86a8a9c..5bc1cc3 100644
--- a/arch/arm64/include/asm/insn.h
+++ b/arch/arm64/include/asm/insn.h
@@ -72,6 +72,7 @@ enum aarch64_insn_imm_type {
 enum aarch64_insn_register_type {
 	AARCH64_INSN_REGTYPE_RT,
 	AARCH64_INSN_REGTYPE_RN,
+	AARCH64_INSN_REGTYPE_RM,
 };
 
 enum aarch64_insn_register {
@@ -143,12 +144,26 @@ enum aarch64_insn_branch_type {
 	AARCH64_INSN_BRANCH_COMP_NONZERO,
 };
 
+enum aarch64_insn_size_type {
+	AARCH64_INSN_SIZE_8,
+	AARCH64_INSN_SIZE_16,
+	AARCH64_INSN_SIZE_32,
+	AARCH64_INSN_SIZE_64,
+};
+
+enum aarch64_insn_ldst_type {
+	AARCH64_INSN_LDST_LOAD_REG_OFFSET,
+	AARCH64_INSN_LDST_STORE_REG_OFFSET,
+};
+
 #define	__AARCH64_INSN_FUNCS(abbr, mask, val)	\
 static __always_inline bool aarch64_insn_is_##abbr(u32 code) \
 { return (code & (mask)) == (val); } \
 static __always_inline u32 aarch64_insn_get_##abbr##_value(void) \
 { return (val); }
 
+__AARCH64_INSN_FUNCS(str_reg,	0x3FE0EC00, 0x38206800)
+__AARCH64_INSN_FUNCS(ldr_reg,	0x3FE0EC00, 0x38606800)
 __AARCH64_INSN_FUNCS(b,		0xFC000000, 0x14000000)
 __AARCH64_INSN_FUNCS(bl,	0xFC000000, 0x94000000)
 __AARCH64_INSN_FUNCS(cbz,	0xFE000000, 0x34000000)
@@ -184,6 +199,11 @@ u32 aarch64_insn_gen_hint(enum aarch64_insn_hint_op op);
 u32 aarch64_insn_gen_nop(void);
 u32 aarch64_insn_gen_branch_reg(enum aarch64_insn_register reg,
 				enum aarch64_insn_branch_type type);
+u32 aarch64_insn_gen_load_store_reg(enum aarch64_insn_register reg,
+				    enum aarch64_insn_register base,
+				    enum aarch64_insn_register offset,
+				    enum aarch64_insn_size_type size,
+				    enum aarch64_insn_ldst_type type);
 
 bool aarch64_insn_hotpatch_safe(u32 old_insn, u32 new_insn);
 
diff --git a/arch/arm64/kernel/insn.c b/arch/arm64/kernel/insn.c
index f2cf8ab..447ad63 100644
--- a/arch/arm64/kernel/insn.c
+++ b/arch/arm64/kernel/insn.c
@@ -284,6 +284,9 @@ static u32 aarch64_insn_encode_register(enum aarch64_insn_register_type type,
 	case AARCH64_INSN_REGTYPE_RN:
 		shift = 5;
 		break;
+	case AARCH64_INSN_REGTYPE_RM:
+		shift = 16;
+		break;
 	default:
 		pr_err("%s: unknown register type encoding %d\n", __func__,
 		       type);
@@ -296,6 +299,35 @@ static u32 aarch64_insn_encode_register(enum aarch64_insn_register_type type,
 	return insn;
 }
 
+static u32 aarch64_insn_encode_ldst_size(enum aarch64_insn_size_type type,
+					 u32 insn)
+{
+	u32 size;
+
+	switch (type) {
+	case AARCH64_INSN_SIZE_8:
+		size = 0;
+		break;
+	case AARCH64_INSN_SIZE_16:
+		size = 1;
+		break;
+	case AARCH64_INSN_SIZE_32:
+		size = 2;
+		break;
+	case AARCH64_INSN_SIZE_64:
+		size = 3;
+		break;
+	default:
+		pr_err("%s: unknown size encoding %d\n", __func__, type);
+		return 0;
+	}
+
+	insn &= ~GENMASK(31, 30);
+	insn |= size << 30;
+
+	return insn;
+}
+
 static inline long branch_imm_common(unsigned long pc, unsigned long addr,
 				     long range)
 {
@@ -426,3 +458,33 @@ u32 aarch64_insn_gen_branch_reg(enum aarch64_insn_register reg,
 
 	return aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RN, insn, reg);
 }
+
+u32 aarch64_insn_gen_load_store_reg(enum aarch64_insn_register reg,
+				    enum aarch64_insn_register base,
+				    enum aarch64_insn_register offset,
+				    enum aarch64_insn_size_type size,
+				    enum aarch64_insn_ldst_type type)
+{
+	u32 insn;
+
+	switch (type) {
+	case AARCH64_INSN_LDST_LOAD_REG_OFFSET:
+		insn = aarch64_insn_get_ldr_reg_value();
+		break;
+	case AARCH64_INSN_LDST_STORE_REG_OFFSET:
+		insn = aarch64_insn_get_str_reg_value();
+		break;
+	default:
+		BUG_ON(1);
+	}
+
+	insn = aarch64_insn_encode_ldst_size(size, insn);
+
+	insn = aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RT, insn, reg);
+
+	insn = aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RN, insn,
+					    base);
+
+	return aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RM, insn,
+					    offset);
+}
-- 
1.9.1
