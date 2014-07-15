From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: [PATCH RFCv3 13/14] arm64: introduce
 aarch64_insn_gen_logical_shifted_reg()
Date: Mon, 14 Jul 2014 23:25:11 -0700
Message-ID: <1405405512-4423-14-git-send-email-zlim.lnx@gmail.com>
References: <1405405512-4423-1-git-send-email-zlim.lnx@gmail.com>
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
In-Reply-To: <1405405512-4423-1-git-send-email-zlim.lnx@gmail.com>
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

Introduce function to generate logical (shifted register)
instructions.

Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
---
 arch/arm64/include/asm/insn.h | 25 ++++++++++++++++++
 arch/arm64/kernel/insn.c      | 60 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 85 insertions(+)

diff --git a/arch/arm64/include/asm/insn.h b/arch/arm64/include/asm/insn.h
index 36e8465..56a9e63 100644
--- a/arch/arm64/include/asm/insn.h
+++ b/arch/arm64/include/asm/insn.h
@@ -206,6 +206,17 @@ enum aarch64_insn_data3_type {
 	AARCH64_INSN_DATA3_MSUB,
 };
 
+enum aarch64_insn_logic_type {
+	AARCH64_INSN_LOGIC_AND,
+	AARCH64_INSN_LOGIC_BIC,
+	AARCH64_INSN_LOGIC_ORR,
+	AARCH64_INSN_LOGIC_ORN,
+	AARCH64_INSN_LOGIC_EOR,
+	AARCH64_INSN_LOGIC_EON,
+	AARCH64_INSN_LOGIC_AND_SETFLAGS,
+	AARCH64_INSN_LOGIC_BIC_SETFLAGS
+};
+
 #define	__AARCH64_INSN_FUNCS(abbr, mask, val)	\
 static __always_inline bool aarch64_insn_is_##abbr(u32 code) \
 { return (code & (mask)) == (val); } \
@@ -243,6 +254,14 @@ __AARCH64_INSN_FUNCS(rorv,	0x7FE0FC00, 0x1AC02C00)
 __AARCH64_INSN_FUNCS(rev16,	0x7FFFFC00, 0x5AC00400)
 __AARCH64_INSN_FUNCS(rev32,	0x7FFFFC00, 0x5AC00800)
 __AARCH64_INSN_FUNCS(rev64,	0x7FFFFC00, 0x5AC00C00)
+__AARCH64_INSN_FUNCS(and,	0x7F200000, 0x0A000000)
+__AARCH64_INSN_FUNCS(bic,	0x7F200000, 0x0A200000)
+__AARCH64_INSN_FUNCS(orr,	0x7F200000, 0x2A000000)
+__AARCH64_INSN_FUNCS(orn,	0x7F200000, 0x2A200000)
+__AARCH64_INSN_FUNCS(eor,	0x7F200000, 0x4A000000)
+__AARCH64_INSN_FUNCS(eon,	0x7F200000, 0x4A200000)
+__AARCH64_INSN_FUNCS(ands,	0x7F200000, 0x6A000000)
+__AARCH64_INSN_FUNCS(bics,	0x7F200000, 0x6A200000)
 __AARCH64_INSN_FUNCS(b,		0xFC000000, 0x14000000)
 __AARCH64_INSN_FUNCS(bl,	0xFC000000, 0x94000000)
 __AARCH64_INSN_FUNCS(cbz,	0xFE000000, 0x34000000)
@@ -323,6 +342,12 @@ u32 aarch64_insn_gen_data3(enum aarch64_insn_register dst,
 			   enum aarch64_insn_register reg2,
 			   enum aarch64_insn_variant variant,
 			   enum aarch64_insn_data3_type type);
+u32 aarch64_insn_gen_logical_shifted_reg(enum aarch64_insn_register dst,
+					 enum aarch64_insn_register src,
+					 enum aarch64_insn_register reg,
+					 int shift,
+					 enum aarch64_insn_variant variant,
+					 enum aarch64_insn_logic_type type);
 
 bool aarch64_insn_hotpatch_safe(u32 old_insn, u32 new_insn);
 
diff --git a/arch/arm64/kernel/insn.c b/arch/arm64/kernel/insn.c
index 01664e3..22b07dc 100644
--- a/arch/arm64/kernel/insn.c
+++ b/arch/arm64/kernel/insn.c
@@ -872,3 +872,63 @@ u32 aarch64_insn_gen_data3(enum aarch64_insn_register dst,
 	return aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RM, insn,
 					    reg2);
 }
+
+u32 aarch64_insn_gen_logical_shifted_reg(enum aarch64_insn_register dst,
+					 enum aarch64_insn_register src,
+					 enum aarch64_insn_register reg,
+					 int shift,
+					 enum aarch64_insn_variant variant,
+					 enum aarch64_insn_logic_type type)
+{
+	u32 insn;
+
+	switch (type) {
+	case AARCH64_INSN_LOGIC_AND:
+		insn = aarch64_insn_get_and_value();
+		break;
+	case AARCH64_INSN_LOGIC_BIC:
+		insn = aarch64_insn_get_bic_value();
+		break;
+	case AARCH64_INSN_LOGIC_ORR:
+		insn = aarch64_insn_get_orr_value();
+		break;
+	case AARCH64_INSN_LOGIC_ORN:
+		insn = aarch64_insn_get_orn_value();
+		break;
+	case AARCH64_INSN_LOGIC_EOR:
+		insn = aarch64_insn_get_eor_value();
+		break;
+	case AARCH64_INSN_LOGIC_EON:
+		insn = aarch64_insn_get_eon_value();
+		break;
+	case AARCH64_INSN_LOGIC_AND_SETFLAGS:
+		insn = aarch64_insn_get_ands_value();
+		break;
+	case AARCH64_INSN_LOGIC_BIC_SETFLAGS:
+		insn = aarch64_insn_get_bics_value();
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
