From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: [PATCH 10/14] arm64: introduce aarch64_insn_gen_data1()
Date: Fri, 18 Jul 2014 11:28:16 -0700
Message-ID: <1405708100-13604-11-git-send-email-zlim.lnx@gmail.com>
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

Introduce function to generate data-processing (1 source) instructions.

Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
---
 arch/arm64/include/asm/insn.h | 13 +++++++++++++
 arch/arm64/kernel/insn.c      | 37 +++++++++++++++++++++++++++++++++++++
 2 files changed, 50 insertions(+)

diff --git a/arch/arm64/include/asm/insn.h b/arch/arm64/include/asm/insn.h
index c0a765d..246d214 100644
--- a/arch/arm64/include/asm/insn.h
+++ b/arch/arm64/include/asm/insn.h
@@ -185,6 +185,12 @@ enum aarch64_insn_bitfield_type {
 	AARCH64_INSN_BITFIELD_MOVE_SIGNED
 };
 
+enum aarch64_insn_data1_type {
+	AARCH64_INSN_DATA1_REVERSE_16,
+	AARCH64_INSN_DATA1_REVERSE_32,
+	AARCH64_INSN_DATA1_REVERSE_64,
+};
+
 #define	__AARCH64_INSN_FUNCS(abbr, mask, val)	\
 static __always_inline bool aarch64_insn_is_##abbr(u32 code) \
 { return (code & (mask)) == (val); } \
@@ -211,6 +217,9 @@ __AARCH64_INSN_FUNCS(add,	0x7F200000, 0x0B000000)
 __AARCH64_INSN_FUNCS(adds,	0x7F200000, 0x2B000000)
 __AARCH64_INSN_FUNCS(sub,	0x7F200000, 0x4B000000)
 __AARCH64_INSN_FUNCS(subs,	0x7F200000, 0x6B000000)
+__AARCH64_INSN_FUNCS(rev16,	0x7FFFFC00, 0x5AC00400)
+__AARCH64_INSN_FUNCS(rev32,	0x7FFFFC00, 0x5AC00800)
+__AARCH64_INSN_FUNCS(rev64,	0x7FFFFC00, 0x5AC00C00)
 __AARCH64_INSN_FUNCS(b,		0xFC000000, 0x14000000)
 __AARCH64_INSN_FUNCS(bl,	0xFC000000, 0x94000000)
 __AARCH64_INSN_FUNCS(cbz,	0xFE000000, 0x34000000)
@@ -276,6 +285,10 @@ u32 aarch64_insn_gen_add_sub_shifted_reg(enum aarch64_insn_register dst,
 					 int shift,
 					 enum aarch64_insn_variant variant,
 					 enum aarch64_insn_adsb_type type);
+u32 aarch64_insn_gen_data1(enum aarch64_insn_register dst,
+			   enum aarch64_insn_register src,
+			   enum aarch64_insn_variant variant,
+			   enum aarch64_insn_data1_type type);
 
 bool aarch64_insn_hotpatch_safe(u32 old_insn, u32 new_insn);
 
diff --git a/arch/arm64/kernel/insn.c b/arch/arm64/kernel/insn.c
index d7a4dd4..81ef3b5 100644
--- a/arch/arm64/kernel/insn.c
+++ b/arch/arm64/kernel/insn.c
@@ -747,3 +747,40 @@ u32 aarch64_insn_gen_add_sub_shifted_reg(enum aarch64_insn_register dst,
 
 	return aarch64_insn_encode_immediate(AARCH64_INSN_IMM_6, insn, shift);
 }
+
+u32 aarch64_insn_gen_data1(enum aarch64_insn_register dst,
+			   enum aarch64_insn_register src,
+			   enum aarch64_insn_variant variant,
+			   enum aarch64_insn_data1_type type)
+{
+	u32 insn;
+
+	switch (type) {
+	case AARCH64_INSN_DATA1_REVERSE_16:
+		insn = aarch64_insn_get_rev16_value();
+		break;
+	case AARCH64_INSN_DATA1_REVERSE_32:
+		insn = aarch64_insn_get_rev32_value();
+		break;
+	case AARCH64_INSN_DATA1_REVERSE_64:
+		BUG_ON(variant != AARCH64_INSN_VARIANT_64BIT);
+		insn = aarch64_insn_get_rev64_value();
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
+	return aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RN, insn, src);
+}
-- 
1.9.1
