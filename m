From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: [PATCH 07/14] arm64: introduce aarch64_insn_gen_bitfield()
Date: Fri, 18 Jul 2014 11:28:13 -0700
Message-ID: <1405708100-13604-8-git-send-email-zlim.lnx@gmail.com>
References: <1405708100-13604-1-git-send-email-zlim.lnx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Zi Shen Lim <zlim.lnx@gmail.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Catalin Marinas <catalin.marinas@arm.com>,
 Will Deacon <will.deacon@arm.com>, Jiang Liu <liuj97@gmail.com>,
 AKASHI Takahiro <takahiro.akashi@linaro.org>,
 "David S. Miller" <davem@davemloft.net>,
 Daniel Borkmann <dborkman@redhat.com>,
 Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1405708100-13604-1-git-send-email-zlim.lnx@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Introduce function to generate bitfield instructions.

Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
---
 arch/arm64/include/asm/insn.h | 16 +++++++++++++
 arch/arm64/kernel/insn.c      | 56 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 72 insertions(+)

diff --git a/arch/arm64/include/asm/insn.h b/arch/arm64/include/asm/insn.h
index 29386aa..8fd31fc 100644
--- a/arch/arm64/include/asm/insn.h
+++ b/arch/arm64/include/asm/insn.h
@@ -67,6 +67,8 @@ enum aarch64_insn_imm_type {
 	AARCH64_INSN_IMM_12,
 	AARCH64_INSN_IMM_9,
 	AARCH64_INSN_IMM_7,
+	AARCH64_INSN_IMM_S,
+	AARCH64_INSN_IMM_R,
 	AARCH64_INSN_IMM_MAX
 };
 
@@ -170,6 +172,12 @@ enum aarch64_insn_adsb_type {
 	AARCH64_INSN_ADSB_SUB_SETFLAGS
 };
 
+enum aarch64_insn_bitfield_type {
+	AARCH64_INSN_BITFIELD_MOVE,
+	AARCH64_INSN_BITFIELD_MOVE_UNSIGNED,
+	AARCH64_INSN_BITFIELD_MOVE_SIGNED
+};
+
 #define	__AARCH64_INSN_FUNCS(abbr, mask, val)	\
 static __always_inline bool aarch64_insn_is_##abbr(u32 code) \
 { return (code & (mask)) == (val); } \
@@ -186,6 +194,9 @@ __AARCH64_INSN_FUNCS(add_imm,	0x7F000000, 0x11000000)
 __AARCH64_INSN_FUNCS(adds_imm,	0x7F000000, 0x31000000)
 __AARCH64_INSN_FUNCS(sub_imm,	0x7F000000, 0x51000000)
 __AARCH64_INSN_FUNCS(subs_imm,	0x7F000000, 0x71000000)
+__AARCH64_INSN_FUNCS(sbfm,	0x7F800000, 0x13000000)
+__AARCH64_INSN_FUNCS(bfm,	0x7F800000, 0x33000000)
+__AARCH64_INSN_FUNCS(ubfm,	0x7F800000, 0x53000000)
 __AARCH64_INSN_FUNCS(b,		0xFC000000, 0x14000000)
 __AARCH64_INSN_FUNCS(bl,	0xFC000000, 0x94000000)
 __AARCH64_INSN_FUNCS(cbz,	0xFE000000, 0x34000000)
@@ -236,6 +247,11 @@ u32 aarch64_insn_gen_add_sub_imm(enum aarch64_insn_register dst,
 				 enum aarch64_insn_register src,
 				 int imm, enum aarch64_insn_variant variant,
 				 enum aarch64_insn_adsb_type type);
+u32 aarch64_insn_gen_bitfield(enum aarch64_insn_register dst,
+			      enum aarch64_insn_register src,
+			      int immr, int imms,
+			      enum aarch64_insn_variant variant,
+			      enum aarch64_insn_bitfield_type type);
 
 bool aarch64_insn_hotpatch_safe(u32 old_insn, u32 new_insn);
 
diff --git a/arch/arm64/kernel/insn.c b/arch/arm64/kernel/insn.c
index ec3a902..e07d026 100644
--- a/arch/arm64/kernel/insn.c
+++ b/arch/arm64/kernel/insn.c
@@ -26,6 +26,7 @@
 #include <asm/insn.h>
 
 #define AARCH64_INSN_SF_BIT	BIT(31)
+#define AARCH64_INSN_N_BIT	BIT(22)
 
 static int aarch64_insn_encoding_class[] = {
 	AARCH64_INSN_CLS_UNKNOWN,
@@ -259,6 +260,14 @@ u32 __kprobes aarch64_insn_encode_immediate(enum aarch64_insn_imm_type type,
 		mask = BIT(7) - 1;
 		shift = 15;
 		break;
+	case AARCH64_INSN_IMM_S:
+		mask = BIT(6) - 1;
+		shift = 10;
+		break;
+	case AARCH64_INSN_IMM_R:
+		mask = BIT(6) - 1;
+		shift = 16;
+		break;
 	default:
 		pr_err("aarch64_insn_encode_immediate: unknown immediate encoding %d\n",
 			type);
@@ -599,3 +608,50 @@ u32 aarch64_insn_gen_add_sub_imm(enum aarch64_insn_register dst,
 
 	return aarch64_insn_encode_immediate(AARCH64_INSN_IMM_12, insn, imm);
 }
+
+u32 aarch64_insn_gen_bitfield(enum aarch64_insn_register dst,
+			      enum aarch64_insn_register src,
+			      int immr, int imms,
+			      enum aarch64_insn_variant variant,
+			      enum aarch64_insn_bitfield_type type)
+{
+	u32 insn;
+	u32 mask;
+
+	switch (type) {
+	case AARCH64_INSN_BITFIELD_MOVE:
+		insn = aarch64_insn_get_bfm_value();
+		break;
+	case AARCH64_INSN_BITFIELD_MOVE_UNSIGNED:
+		insn = aarch64_insn_get_ubfm_value();
+		break;
+	case AARCH64_INSN_BITFIELD_MOVE_SIGNED:
+		insn = aarch64_insn_get_sbfm_value();
+		break;
+	default:
+		BUG_ON(1);
+	}
+
+	switch (variant) {
+	case AARCH64_INSN_VARIANT_32BIT:
+		mask = GENMASK(4, 0);
+		break;
+	case AARCH64_INSN_VARIANT_64BIT:
+		insn |= AARCH64_INSN_SF_BIT | AARCH64_INSN_N_BIT;
+		mask = GENMASK(5, 0);
+		break;
+	default:
+		BUG_ON(1);
+	}
+
+	BUG_ON(immr & ~mask);
+	BUG_ON(imms & ~mask);
+
+	insn = aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RD, insn, dst);
+
+	insn = aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RN, insn, src);
+
+	insn = aarch64_insn_encode_immediate(AARCH64_INSN_IMM_R, insn, immr);
+
+	return aarch64_insn_encode_immediate(AARCH64_INSN_IMM_S, insn, imms);
+}
-- 
1.9.1
