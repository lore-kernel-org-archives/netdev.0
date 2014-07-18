From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: [PATCH 11/14] arm64: introduce aarch64_insn_gen_data2()
Date: Fri, 18 Jul 2014 11:28:17 -0700
Message-ID: <1405708100-13604-12-git-send-email-zlim.lnx@gmail.com>
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

Introduce function to generate data-processing (2 source) instructions.

Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
---
 arch/arm64/include/asm/insn.h | 20 ++++++++++++++++++
 arch/arm64/kernel/insn.c      | 48 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 68 insertions(+)

diff --git a/arch/arm64/include/asm/insn.h b/arch/arm64/include/asm/insn.h
index 246d214..367245f 100644
--- a/arch/arm64/include/asm/insn.h
+++ b/arch/arm64/include/asm/insn.h
@@ -191,6 +191,15 @@ enum aarch64_insn_data1_type {
 	AARCH64_INSN_DATA1_REVERSE_64,
 };
 
+enum aarch64_insn_data2_type {
+	AARCH64_INSN_DATA2_UDIV,
+	AARCH64_INSN_DATA2_SDIV,
+	AARCH64_INSN_DATA2_LSLV,
+	AARCH64_INSN_DATA2_LSRV,
+	AARCH64_INSN_DATA2_ASRV,
+	AARCH64_INSN_DATA2_RORV,
+};
+
 #define	__AARCH64_INSN_FUNCS(abbr, mask, val)	\
 static __always_inline bool aarch64_insn_is_##abbr(u32 code) \
 { return (code & (mask)) == (val); } \
@@ -217,6 +226,12 @@ __AARCH64_INSN_FUNCS(add,	0x7F200000, 0x0B000000)
 __AARCH64_INSN_FUNCS(adds,	0x7F200000, 0x2B000000)
 __AARCH64_INSN_FUNCS(sub,	0x7F200000, 0x4B000000)
 __AARCH64_INSN_FUNCS(subs,	0x7F200000, 0x6B000000)
+__AARCH64_INSN_FUNCS(udiv,	0x7FE0FC00, 0x1AC00800)
+__AARCH64_INSN_FUNCS(sdiv,	0x7FE0FC00, 0x1AC00C00)
+__AARCH64_INSN_FUNCS(lslv,	0x7FE0FC00, 0x1AC02000)
+__AARCH64_INSN_FUNCS(lsrv,	0x7FE0FC00, 0x1AC02400)
+__AARCH64_INSN_FUNCS(asrv,	0x7FE0FC00, 0x1AC02800)
+__AARCH64_INSN_FUNCS(rorv,	0x7FE0FC00, 0x1AC02C00)
 __AARCH64_INSN_FUNCS(rev16,	0x7FFFFC00, 0x5AC00400)
 __AARCH64_INSN_FUNCS(rev32,	0x7FFFFC00, 0x5AC00800)
 __AARCH64_INSN_FUNCS(rev64,	0x7FFFFC00, 0x5AC00C00)
@@ -289,6 +304,11 @@ u32 aarch64_insn_gen_data1(enum aarch64_insn_register dst,
 			   enum aarch64_insn_register src,
 			   enum aarch64_insn_variant variant,
 			   enum aarch64_insn_data1_type type);
+u32 aarch64_insn_gen_data2(enum aarch64_insn_register dst,
+			   enum aarch64_insn_register src,
+			   enum aarch64_insn_register reg,
+			   enum aarch64_insn_variant variant,
+			   enum aarch64_insn_data2_type type);
 
 bool aarch64_insn_hotpatch_safe(u32 old_insn, u32 new_insn);
 
diff --git a/arch/arm64/kernel/insn.c b/arch/arm64/kernel/insn.c
index 81ef3b5..c054164 100644
--- a/arch/arm64/kernel/insn.c
+++ b/arch/arm64/kernel/insn.c
@@ -784,3 +784,51 @@ u32 aarch64_insn_gen_data1(enum aarch64_insn_register dst,
 
 	return aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RN, insn, src);
 }
+
+u32 aarch64_insn_gen_data2(enum aarch64_insn_register dst,
+			   enum aarch64_insn_register src,
+			   enum aarch64_insn_register reg,
+			   enum aarch64_insn_variant variant,
+			   enum aarch64_insn_data2_type type)
+{
+	u32 insn;
+
+	switch (type) {
+	case AARCH64_INSN_DATA2_UDIV:
+		insn = aarch64_insn_get_udiv_value();
+		break;
+	case AARCH64_INSN_DATA2_SDIV:
+		insn = aarch64_insn_get_sdiv_value();
+		break;
+	case AARCH64_INSN_DATA2_LSLV:
+		insn = aarch64_insn_get_lslv_value();
+		break;
+	case AARCH64_INSN_DATA2_LSRV:
+		insn = aarch64_insn_get_lsrv_value();
+		break;
+	case AARCH64_INSN_DATA2_ASRV:
+		insn = aarch64_insn_get_asrv_value();
+		break;
+	case AARCH64_INSN_DATA2_RORV:
+		insn = aarch64_insn_get_rorv_value();
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
+	insn = aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RN, insn, src);
+
+	return aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RM, insn, reg);
+}
-- 
1.9.1
