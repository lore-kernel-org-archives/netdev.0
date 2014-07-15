From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: [PATCH RFCv3 08/14] arm64: introduce aarch64_insn_gen_movewide()
Date: Mon, 14 Jul 2014 23:25:06 -0700
Message-ID: <1405405512-4423-9-git-send-email-zlim.lnx@gmail.com>
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
Received: from mail-pd0-f180.google.com ([209.85.192.180]:35486 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757855AbaGOGZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 02:25:41 -0400
In-Reply-To: <1405405512-4423-1-git-send-email-zlim.lnx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce function to generate move wide (immediate) instructions.

Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
---
 arch/arm64/include/asm/insn.h | 13 +++++++++++++
 arch/arm64/kernel/insn.c      | 43 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 56 insertions(+)

diff --git a/arch/arm64/include/asm/insn.h b/arch/arm64/include/asm/insn.h
index 8fd31fc..49dec28 100644
--- a/arch/arm64/include/asm/insn.h
+++ b/arch/arm64/include/asm/insn.h
@@ -172,6 +172,12 @@ enum aarch64_insn_adsb_type {
 	AARCH64_INSN_ADSB_SUB_SETFLAGS
 };
 
+enum aarch64_insn_movewide_type {
+	AARCH64_INSN_MOVEWIDE_ZERO,
+	AARCH64_INSN_MOVEWIDE_KEEP,
+	AARCH64_INSN_MOVEWIDE_INVERSE
+};
+
 enum aarch64_insn_bitfield_type {
 	AARCH64_INSN_BITFIELD_MOVE,
 	AARCH64_INSN_BITFIELD_MOVE_UNSIGNED,
@@ -194,9 +200,12 @@ __AARCH64_INSN_FUNCS(add_imm,	0x7F000000, 0x11000000)
 __AARCH64_INSN_FUNCS(adds_imm,	0x7F000000, 0x31000000)
 __AARCH64_INSN_FUNCS(sub_imm,	0x7F000000, 0x51000000)
 __AARCH64_INSN_FUNCS(subs_imm,	0x7F000000, 0x71000000)
+__AARCH64_INSN_FUNCS(movn,	0x7F800000, 0x12800000)
 __AARCH64_INSN_FUNCS(sbfm,	0x7F800000, 0x13000000)
 __AARCH64_INSN_FUNCS(bfm,	0x7F800000, 0x33000000)
+__AARCH64_INSN_FUNCS(movz,	0x7F800000, 0x52800000)
 __AARCH64_INSN_FUNCS(ubfm,	0x7F800000, 0x53000000)
+__AARCH64_INSN_FUNCS(movk,	0x7F800000, 0x72800000)
 __AARCH64_INSN_FUNCS(b,		0xFC000000, 0x14000000)
 __AARCH64_INSN_FUNCS(bl,	0xFC000000, 0x94000000)
 __AARCH64_INSN_FUNCS(cbz,	0xFE000000, 0x34000000)
@@ -252,6 +261,10 @@ u32 aarch64_insn_gen_bitfield(enum aarch64_insn_register dst,
 			      int immr, int imms,
 			      enum aarch64_insn_variant variant,
 			      enum aarch64_insn_bitfield_type type);
+u32 aarch64_insn_gen_movewide(enum aarch64_insn_register dst,
+			      int imm, int shift,
+			      enum aarch64_insn_variant variant,
+			      enum aarch64_insn_movewide_type type);
 
 bool aarch64_insn_hotpatch_safe(u32 old_insn, u32 new_insn);
 
diff --git a/arch/arm64/kernel/insn.c b/arch/arm64/kernel/insn.c
index 01ed35c..1cb94b4 100644
--- a/arch/arm64/kernel/insn.c
+++ b/arch/arm64/kernel/insn.c
@@ -653,3 +653,46 @@ u32 aarch64_insn_gen_bitfield(enum aarch64_insn_register dst,
 
 	return aarch64_insn_encode_immediate(AARCH64_INSN_IMM_S, insn, imms);
 }
+
+u32 aarch64_insn_gen_movewide(enum aarch64_insn_register dst,
+			      int imm, int shift,
+			      enum aarch64_insn_variant variant,
+			      enum aarch64_insn_movewide_type type)
+{
+	u32 insn;
+
+	switch (type) {
+	case AARCH64_INSN_MOVEWIDE_ZERO:
+		insn = aarch64_insn_get_movz_value();
+		break;
+	case AARCH64_INSN_MOVEWIDE_KEEP:
+		insn = aarch64_insn_get_movk_value();
+		break;
+	case AARCH64_INSN_MOVEWIDE_INVERSE:
+		insn = aarch64_insn_get_movn_value();
+		break;
+	default:
+		BUG_ON(1);
+	}
+
+	BUG_ON(imm < 0 || imm > 65535);
+
+	switch (variant) {
+	case AARCH64_INSN_VARIANT_32BIT:
+		BUG_ON(shift != 0 && shift != 16);
+		break;
+	case AARCH64_INSN_VARIANT_64BIT:
+		insn |= BIT(31);
+		BUG_ON(shift != 0 && shift != 16 && shift != 32 &&
+		       shift != 48);
+		break;
+	default:
+		BUG_ON(1);
+	}
+
+	insn |= (shift >> 4) << 21;
+
+	insn = aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RD, insn, dst);
+
+	return aarch64_insn_encode_immediate(AARCH64_INSN_IMM_16, insn, imm);
+}
-- 
1.9.1
