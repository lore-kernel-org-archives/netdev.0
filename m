From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: [PATCH 12/14] arm64: introduce aarch64_insn_gen_data3()
Date: Fri, 18 Jul 2014 11:28:18 -0700
Message-ID: <1405708100-13604-13-git-send-email-zlim.lnx@gmail.com>
References: <1405708100-13604-1-git-send-email-zlim.lnx@gmail.com>
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
In-Reply-To: <1405708100-13604-1-git-send-email-zlim.lnx@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduce function to generate data-processing (3 source) instructions.

Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
---
 arch/arm64/include/asm/insn.h | 14 ++++++++++++++
 arch/arm64/kernel/insn.c      | 42 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 56 insertions(+)

diff --git a/arch/arm64/include/asm/insn.h b/arch/arm64/include/asm/insn.h
index 367245f..36e8465 100644
--- a/arch/arm64/include/asm/insn.h
+++ b/arch/arm64/include/asm/insn.h
@@ -79,6 +79,7 @@ enum aarch64_insn_register_type {
 	AARCH64_INSN_REGTYPE_RT2,
 	AARCH64_INSN_REGTYPE_RM,
 	AARCH64_INSN_REGTYPE_RD,
+	AARCH64_INSN_REGTYPE_RA,
 };
 
 enum aarch64_insn_register {
@@ -200,6 +201,11 @@ enum aarch64_insn_data2_type {
 	AARCH64_INSN_DATA2_RORV,
 };
 
+enum aarch64_insn_data3_type {
+	AARCH64_INSN_DATA3_MADD,
+	AARCH64_INSN_DATA3_MSUB,
+};
+
 #define	__AARCH64_INSN_FUNCS(abbr, mask, val)	\
 static __always_inline bool aarch64_insn_is_##abbr(u32 code) \
 { return (code & (mask)) == (val); } \
@@ -226,6 +232,8 @@ __AARCH64_INSN_FUNCS(add,	0x7F200000, 0x0B000000)
 __AARCH64_INSN_FUNCS(adds,	0x7F200000, 0x2B000000)
 __AARCH64_INSN_FUNCS(sub,	0x7F200000, 0x4B000000)
 __AARCH64_INSN_FUNCS(subs,	0x7F200000, 0x6B000000)
+__AARCH64_INSN_FUNCS(madd,	0x7FE08000, 0x1B000000)
+__AARCH64_INSN_FUNCS(msub,	0x7FE08000, 0x1B008000)
 __AARCH64_INSN_FUNCS(udiv,	0x7FE0FC00, 0x1AC00800)
 __AARCH64_INSN_FUNCS(sdiv,	0x7FE0FC00, 0x1AC00C00)
 __AARCH64_INSN_FUNCS(lslv,	0x7FE0FC00, 0x1AC02000)
@@ -309,6 +317,12 @@ u32 aarch64_insn_gen_data2(enum aarch64_insn_register dst,
 			   enum aarch64_insn_register reg,
 			   enum aarch64_insn_variant variant,
 			   enum aarch64_insn_data2_type type);
+u32 aarch64_insn_gen_data3(enum aarch64_insn_register dst,
+			   enum aarch64_insn_register src,
+			   enum aarch64_insn_register reg1,
+			   enum aarch64_insn_register reg2,
+			   enum aarch64_insn_variant variant,
+			   enum aarch64_insn_data3_type type);
 
 bool aarch64_insn_hotpatch_safe(u32 old_insn, u32 new_insn);
 
diff --git a/arch/arm64/kernel/insn.c b/arch/arm64/kernel/insn.c
index c054164..f73a4bf 100644
--- a/arch/arm64/kernel/insn.c
+++ b/arch/arm64/kernel/insn.c
@@ -302,6 +302,7 @@ static u32 aarch64_insn_encode_register(enum aarch64_insn_register_type type,
 		shift = 5;
 		break;
 	case AARCH64_INSN_REGTYPE_RT2:
+	case AARCH64_INSN_REGTYPE_RA:
 		shift = 10;
 		break;
 	case AARCH64_INSN_REGTYPE_RM:
@@ -832,3 +833,44 @@ u32 aarch64_insn_gen_data2(enum aarch64_insn_register dst,
 
 	return aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RM, insn, reg);
 }
+
+u32 aarch64_insn_gen_data3(enum aarch64_insn_register dst,
+			   enum aarch64_insn_register src,
+			   enum aarch64_insn_register reg1,
+			   enum aarch64_insn_register reg2,
+			   enum aarch64_insn_variant variant,
+			   enum aarch64_insn_data3_type type)
+{
+	u32 insn;
+
+	switch (type) {
+	case AARCH64_INSN_DATA3_MADD:
+		insn = aarch64_insn_get_madd_value();
+		break;
+	case AARCH64_INSN_DATA3_MSUB:
+		insn = aarch64_insn_get_msub_value();
+		break;
+	default:
+		BUG_ON(1);
+	}
+
+	switch (variant) {
+	case AARCH64_INSN_VARIANT_32BIT:
+		break;
+	case AARCH64_INSN_VARIANT_64BIT:
+		insn |= AARCH64_INSN_SF_BIT;
+		break;
+	default:
+		BUG_ON(1);
+	}
+
+	insn = aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RD, insn, dst);
+
+	insn = aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RA, insn, src);
+
+	insn = aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RN, insn,
+					    reg1);
+
+	return aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RM, insn,
+					    reg2);
+}
-- 
1.9.1
