From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: [PATCH 06/14] arm64: introduce aarch64_insn_gen_add_sub_imm()
Date: Fri, 18 Jul 2014 11:28:12 -0700
Message-ID: <1405708100-13604-7-git-send-email-zlim.lnx@gmail.com>
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

Introduce function to generate add/subtract (immediate) instructions.

Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
---
 arch/arm64/include/asm/insn.h | 16 ++++++++++++++++
 arch/arm64/kernel/insn.c      | 44 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 60 insertions(+)

diff --git a/arch/arm64/include/asm/insn.h b/arch/arm64/include/asm/insn.h
index eef8f1e..29386aa 100644
--- a/arch/arm64/include/asm/insn.h
+++ b/arch/arm64/include/asm/insn.h
@@ -75,6 +75,7 @@ enum aarch64_insn_register_type {
 	AARCH64_INSN_REGTYPE_RN,
 	AARCH64_INSN_REGTYPE_RT2,
 	AARCH64_INSN_REGTYPE_RM,
+	AARCH64_INSN_REGTYPE_RD,
 };
 
 enum aarch64_insn_register {
@@ -162,6 +163,13 @@ enum aarch64_insn_ldst_type {
 	AARCH64_INSN_LDST_STORE_PAIR_POST_INDEX,
 };
 
+enum aarch64_insn_adsb_type {
+	AARCH64_INSN_ADSB_ADD,
+	AARCH64_INSN_ADSB_SUB,
+	AARCH64_INSN_ADSB_ADD_SETFLAGS,
+	AARCH64_INSN_ADSB_SUB_SETFLAGS
+};
+
 #define	__AARCH64_INSN_FUNCS(abbr, mask, val)	\
 static __always_inline bool aarch64_insn_is_##abbr(u32 code) \
 { return (code & (mask)) == (val); } \
@@ -174,6 +182,10 @@ __AARCH64_INSN_FUNCS(stp_post,	0x7FC00000, 0x28800000)
 __AARCH64_INSN_FUNCS(ldp_post,	0x7FC00000, 0x28C00000)
 __AARCH64_INSN_FUNCS(stp_pre,	0x7FC00000, 0x29800000)
 __AARCH64_INSN_FUNCS(ldp_pre,	0x7FC00000, 0x29C00000)
+__AARCH64_INSN_FUNCS(add_imm,	0x7F000000, 0x11000000)
+__AARCH64_INSN_FUNCS(adds_imm,	0x7F000000, 0x31000000)
+__AARCH64_INSN_FUNCS(sub_imm,	0x7F000000, 0x51000000)
+__AARCH64_INSN_FUNCS(subs_imm,	0x7F000000, 0x71000000)
 __AARCH64_INSN_FUNCS(b,		0xFC000000, 0x14000000)
 __AARCH64_INSN_FUNCS(bl,	0xFC000000, 0x94000000)
 __AARCH64_INSN_FUNCS(cbz,	0xFE000000, 0x34000000)
@@ -220,6 +232,10 @@ u32 aarch64_insn_gen_load_store_pair(enum aarch64_insn_register reg1,
 				     int offset,
 				     enum aarch64_insn_variant variant,
 				     enum aarch64_insn_ldst_type type);
+u32 aarch64_insn_gen_add_sub_imm(enum aarch64_insn_register dst,
+				 enum aarch64_insn_register src,
+				 int imm, enum aarch64_insn_variant variant,
+				 enum aarch64_insn_adsb_type type);
 
 bool aarch64_insn_hotpatch_safe(u32 old_insn, u32 new_insn);
 
diff --git a/arch/arm64/kernel/insn.c b/arch/arm64/kernel/insn.c
index 7880c06..ec3a902 100644
--- a/arch/arm64/kernel/insn.c
+++ b/arch/arm64/kernel/insn.c
@@ -285,6 +285,7 @@ static u32 aarch64_insn_encode_register(enum aarch64_insn_register_type type,
 
 	switch (type) {
 	case AARCH64_INSN_REGTYPE_RT:
+	case AARCH64_INSN_REGTYPE_RD:
 		shift = 0;
 		break;
 	case AARCH64_INSN_REGTYPE_RN:
@@ -555,3 +556,46 @@ u32 aarch64_insn_gen_load_store_pair(enum aarch64_insn_register reg1,
 	return aarch64_insn_encode_immediate(AARCH64_INSN_IMM_7, insn,
 					     offset >> shift);
 }
+
+u32 aarch64_insn_gen_add_sub_imm(enum aarch64_insn_register dst,
+				 enum aarch64_insn_register src,
+				 int imm, enum aarch64_insn_variant variant,
+				 enum aarch64_insn_adsb_type type)
+{
+	u32 insn;
+
+	switch (type) {
+	case AARCH64_INSN_ADSB_ADD:
+		insn = aarch64_insn_get_add_imm_value();
+		break;
+	case AARCH64_INSN_ADSB_SUB:
+		insn = aarch64_insn_get_sub_imm_value();
+		break;
+	case AARCH64_INSN_ADSB_ADD_SETFLAGS:
+		insn = aarch64_insn_get_adds_imm_value();
+		break;
+	case AARCH64_INSN_ADSB_SUB_SETFLAGS:
+		insn = aarch64_insn_get_subs_imm_value();
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
+	BUG_ON(imm & ~(SZ_4K - 1));
+
+	insn = aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RD, insn, dst);
+
+	insn = aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RN, insn, src);
+
+	return aarch64_insn_encode_immediate(AARCH64_INSN_IMM_12, insn, imm);
+}
-- 
1.9.1
