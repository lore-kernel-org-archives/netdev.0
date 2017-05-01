From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf, arm64: implement jiting of BPF_XADD
Date: Mon,  1 May 2017 02:57:20 +0200
Message-ID: <47ce6fc238596120f02fb6c7116f05b30be2f377.1493599299.git.daniel@iogearbox.net>
Cc: ast@fb.com, zlim.lnx@gmail.com, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56801 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2992521AbdEAA5a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 20:57:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This work adds BPF_XADD for BPF_W/BPF_DW to the arm64 JIT and therefore
completes JITing of all BPF instructions, meaning we can thus also remove
the 'notyet' label and do not need to fall back to the interpreter when
BPF_XADD is used in a program!

This now also brings arm64 JIT in line with x86_64, s390x, ppc64, sparc64,
where all current eBPF features are supported.

BPF_W example from test_bpf:

  .u.insns_int = {
    BPF_ALU32_IMM(BPF_MOV, R0, 0x12),
    BPF_ST_MEM(BPF_W, R10, -40, 0x10),
    BPF_STX_XADD(BPF_W, R10, R0, -40),
    BPF_LDX_MEM(BPF_W, R0, R10, -40),
    BPF_EXIT_INSN(),
  },

  [...]
  00000020:  52800247  mov w7, #0x12 // #18
  00000024:  928004eb  mov x11, #0xffffffffffffffd8 // #-40
  00000028:  d280020a  mov x10, #0x10 // #16
  0000002c:  b82b6b2a  str w10, [x25,x11]
  // start of xadd mapping:
  00000030:  928004ea  mov x10, #0xffffffffffffffd8 // #-40
  00000034:  8b19014a  add x10, x10, x25
  00000038:  f9800151  prfm pstl1strm, [x10]
  0000003c:  885f7d4b  ldxr w11, [x10]
  00000040:  0b07016b  add w11, w11, w7
  00000044:  880b7d4b  stxr w11, w11, [x10]
  00000048:  35ffffab  cbnz w11, 0x0000003c
  // end of xadd mapping:
  [...]

BPF_DW example from test_bpf:

  .u.insns_int = {
    BPF_ALU32_IMM(BPF_MOV, R0, 0x12),
    BPF_ST_MEM(BPF_DW, R10, -40, 0x10),
    BPF_STX_XADD(BPF_DW, R10, R0, -40),
    BPF_LDX_MEM(BPF_DW, R0, R10, -40),
    BPF_EXIT_INSN(),
  },

  [...]
  00000020:  52800247  mov w7,  #0x12 // #18
  00000024:  928004eb  mov x11, #0xffffffffffffffd8 // #-40
  00000028:  d280020a  mov x10, #0x10 // #16
  0000002c:  f82b6b2a  str x10, [x25,x11]
  // start of xadd mapping:
  00000030:  928004ea  mov x10, #0xffffffffffffffd8 // #-40
  00000034:  8b19014a  add x10, x10, x25
  00000038:  f9800151  prfm pstl1strm, [x10]
  0000003c:  c85f7d4b  ldxr x11, [x10]
  00000040:  8b07016b  add x11, x11, x7
  00000044:  c80b7d4b  stxr w11, x11, [x10]
  00000048:  35ffffab  cbnz w11, 0x0000003c
  // end of xadd mapping:
  [...]

Tested on Cavium ThunderX ARMv8, test suite results after the patch:

  No JIT:   [ 3751.855362] test_bpf: Summary: 311 PASSED, 0 FAILED, [0/303 JIT'ed]
  With JIT: [ 3573.759527] test_bpf: Summary: 311 PASSED, 0 FAILED, [303/303 JIT'ed]

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 ( Based against net-next where BPF related patches are usually
   routed, if something else is preferred please let me know. )

 arch/arm64/include/asm/insn.h |  30 ++++++++++++
 arch/arm64/kernel/insn.c      | 106 ++++++++++++++++++++++++++++++++++++++++++
 arch/arm64/net/bpf_jit.h      |  19 ++++++++
 arch/arm64/net/bpf_jit_comp.c |  16 +++++--
 lib/test_bpf.c                | 105 +++++++++++++++++++++++++++++++++++++++++
 5 files changed, 271 insertions(+), 5 deletions(-)

diff --git a/arch/arm64/include/asm/insn.h b/arch/arm64/include/asm/insn.h
index aecc07e..29cb2ca 100644
--- a/arch/arm64/include/asm/insn.h
+++ b/arch/arm64/include/asm/insn.h
@@ -80,6 +80,7 @@ enum aarch64_insn_register_type {
 	AARCH64_INSN_REGTYPE_RM,
 	AARCH64_INSN_REGTYPE_RD,
 	AARCH64_INSN_REGTYPE_RA,
+	AARCH64_INSN_REGTYPE_RS,
 };
 
 enum aarch64_insn_register {
@@ -188,6 +189,8 @@ enum aarch64_insn_ldst_type {
 	AARCH64_INSN_LDST_STORE_PAIR_PRE_INDEX,
 	AARCH64_INSN_LDST_LOAD_PAIR_POST_INDEX,
 	AARCH64_INSN_LDST_STORE_PAIR_POST_INDEX,
+	AARCH64_INSN_LDST_LOAD_EX,
+	AARCH64_INSN_LDST_STORE_EX,
 };
 
 enum aarch64_insn_adsb_type {
@@ -240,6 +243,23 @@ enum aarch64_insn_logic_type {
 	AARCH64_INSN_LOGIC_BIC_SETFLAGS
 };
 
+enum aarch64_insn_prfm_type {
+	AARCH64_INSN_PRFM_TYPE_PLD,
+	AARCH64_INSN_PRFM_TYPE_PLI,
+	AARCH64_INSN_PRFM_TYPE_PST,
+};
+
+enum aarch64_insn_prfm_target {
+	AARCH64_INSN_PRFM_TARGET_L1,
+	AARCH64_INSN_PRFM_TARGET_L2,
+	AARCH64_INSN_PRFM_TARGET_L3,
+};
+
+enum aarch64_insn_prfm_policy {
+	AARCH64_INSN_PRFM_POLICY_KEEP,
+	AARCH64_INSN_PRFM_POLICY_STRM,
+};
+
 #define	__AARCH64_INSN_FUNCS(abbr, mask, val)	\
 static __always_inline bool aarch64_insn_is_##abbr(u32 code) \
 { return (code & (mask)) == (val); } \
@@ -248,6 +268,7 @@ enum aarch64_insn_logic_type {
 
 __AARCH64_INSN_FUNCS(adr,	0x9F000000, 0x10000000)
 __AARCH64_INSN_FUNCS(adrp,	0x9F000000, 0x90000000)
+__AARCH64_INSN_FUNCS(prfm,	0x3FC00000, 0x39800000)
 __AARCH64_INSN_FUNCS(prfm_lit,	0xFF000000, 0xD8000000)
 __AARCH64_INSN_FUNCS(str_reg,	0x3FE0EC00, 0x38206800)
 __AARCH64_INSN_FUNCS(ldr_reg,	0x3FE0EC00, 0x38606800)
@@ -357,6 +378,11 @@ u32 aarch64_insn_gen_load_store_pair(enum aarch64_insn_register reg1,
 				     int offset,
 				     enum aarch64_insn_variant variant,
 				     enum aarch64_insn_ldst_type type);
+u32 aarch64_insn_gen_load_store_ex(enum aarch64_insn_register reg,
+				   enum aarch64_insn_register base,
+				   enum aarch64_insn_register state,
+				   enum aarch64_insn_size_type size,
+				   enum aarch64_insn_ldst_type type);
 u32 aarch64_insn_gen_add_sub_imm(enum aarch64_insn_register dst,
 				 enum aarch64_insn_register src,
 				 int imm, enum aarch64_insn_variant variant,
@@ -397,6 +423,10 @@ u32 aarch64_insn_gen_logical_shifted_reg(enum aarch64_insn_register dst,
 					 int shift,
 					 enum aarch64_insn_variant variant,
 					 enum aarch64_insn_logic_type type);
+u32 aarch64_insn_gen_prefetch(enum aarch64_insn_register base,
+			      enum aarch64_insn_prfm_type type,
+			      enum aarch64_insn_prfm_target target,
+			      enum aarch64_insn_prfm_policy policy);
 s32 aarch64_get_branch_offset(u32 insn);
 u32 aarch64_set_branch_offset(u32 insn, s32 offset);
 
diff --git a/arch/arm64/kernel/insn.c b/arch/arm64/kernel/insn.c
index 3a63954..b884a92 100644
--- a/arch/arm64/kernel/insn.c
+++ b/arch/arm64/kernel/insn.c
@@ -474,6 +474,7 @@ static u32 aarch64_insn_encode_register(enum aarch64_insn_register_type type,
 		shift = 10;
 		break;
 	case AARCH64_INSN_REGTYPE_RM:
+	case AARCH64_INSN_REGTYPE_RS:
 		shift = 16;
 		break;
 	default:
@@ -757,6 +758,111 @@ u32 aarch64_insn_gen_load_store_pair(enum aarch64_insn_register reg1,
 					     offset >> shift);
 }
 
+u32 aarch64_insn_gen_load_store_ex(enum aarch64_insn_register reg,
+				   enum aarch64_insn_register base,
+				   enum aarch64_insn_register state,
+				   enum aarch64_insn_size_type size,
+				   enum aarch64_insn_ldst_type type)
+{
+	u32 insn;
+
+	switch (type) {
+	case AARCH64_INSN_LDST_LOAD_EX:
+		insn = aarch64_insn_get_load_ex_value();
+		break;
+	case AARCH64_INSN_LDST_STORE_EX:
+		insn = aarch64_insn_get_store_ex_value();
+		break;
+	default:
+		pr_err("%s: unknown load/store exclusive encoding %d\n", __func__, type);
+		return AARCH64_BREAK_FAULT;
+	}
+
+	insn = aarch64_insn_encode_ldst_size(size, insn);
+
+	insn = aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RT, insn,
+					    reg);
+
+	insn = aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RN, insn,
+					    base);
+
+	insn = aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RT2, insn,
+					    AARCH64_INSN_REG_ZR);
+
+	return aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RS, insn,
+					    state);
+}
+
+static u32 aarch64_insn_encode_prfm_imm(enum aarch64_insn_prfm_type type,
+					enum aarch64_insn_prfm_target target,
+					enum aarch64_insn_prfm_policy policy,
+					u32 insn)
+{
+	u32 imm_type = 0, imm_target = 0, imm_policy = 0;
+
+	switch (type) {
+	case AARCH64_INSN_PRFM_TYPE_PLD:
+		break;
+	case AARCH64_INSN_PRFM_TYPE_PLI:
+		imm_type = BIT(0);
+		break;
+	case AARCH64_INSN_PRFM_TYPE_PST:
+		imm_type = BIT(1);
+		break;
+	default:
+		pr_err("%s: unknown prfm type encoding %d\n", __func__, type);
+		return AARCH64_BREAK_FAULT;
+	}
+
+	switch (target) {
+	case AARCH64_INSN_PRFM_TARGET_L1:
+		break;
+	case AARCH64_INSN_PRFM_TARGET_L2:
+		imm_target = BIT(0);
+		break;
+	case AARCH64_INSN_PRFM_TARGET_L3:
+		imm_target = BIT(1);
+		break;
+	default:
+		pr_err("%s: unknown prfm target encoding %d\n", __func__, target);
+		return AARCH64_BREAK_FAULT;
+	}
+
+	switch (policy) {
+	case AARCH64_INSN_PRFM_POLICY_KEEP:
+		break;
+	case AARCH64_INSN_PRFM_POLICY_STRM:
+		imm_policy = BIT(0);
+		break;
+	default:
+		pr_err("%s: unknown prfm policy encoding %d\n", __func__, policy);
+		return AARCH64_BREAK_FAULT;
+	}
+
+	/* In this case, imm5 is encoded into Rt field. */
+	insn &= ~GENMASK(4, 0);
+	insn |= imm_policy | (imm_target << 1) | (imm_type << 3);
+
+	return insn;
+}
+
+u32 aarch64_insn_gen_prefetch(enum aarch64_insn_register base,
+			      enum aarch64_insn_prfm_type type,
+			      enum aarch64_insn_prfm_target target,
+			      enum aarch64_insn_prfm_policy policy)
+{
+	u32 insn = aarch64_insn_get_prfm_value();
+
+	insn = aarch64_insn_encode_ldst_size(AARCH64_INSN_SIZE_64, insn);
+
+	insn = aarch64_insn_encode_prfm_imm(type, target, policy, insn);
+
+	insn = aarch64_insn_encode_register(AARCH64_INSN_REGTYPE_RN, insn,
+					    base);
+
+	return aarch64_insn_encode_immediate(AARCH64_INSN_IMM_12, insn, 0);
+}
+
 u32 aarch64_insn_gen_add_sub_imm(enum aarch64_insn_register dst,
 				 enum aarch64_insn_register src,
 				 int imm, enum aarch64_insn_variant variant,
diff --git a/arch/arm64/net/bpf_jit.h b/arch/arm64/net/bpf_jit.h
index 7c16e54..b02a926 100644
--- a/arch/arm64/net/bpf_jit.h
+++ b/arch/arm64/net/bpf_jit.h
@@ -83,6 +83,25 @@
 /* Rt = Rn[0]; Rt2 = Rn[8]; Rn += 16; */
 #define A64_POP(Rt, Rt2, Rn)  A64_LS_PAIR(Rt, Rt2, Rn, 16, LOAD, POST_INDEX)
 
+/* Load/store exclusive */
+#define A64_SIZE(sf) \
+	((sf) ? AARCH64_INSN_SIZE_64 : AARCH64_INSN_SIZE_32)
+#define A64_LSX(sf, Rt, Rn, Rs, type) \
+	aarch64_insn_gen_load_store_ex(Rt, Rn, Rs, A64_SIZE(sf), \
+				       AARCH64_INSN_LDST_##type)
+/* Rt = [Rn]; (atomic) */
+#define A64_LDXR(sf, Rt, Rn) \
+	A64_LSX(sf, Rt, Rn, A64_ZR, LOAD_EX)
+/* [Rn] = Rt; (atomic) Rs = [state] */
+#define A64_STXR(sf, Rt, Rn, Rs) \
+	A64_LSX(sf, Rt, Rn, Rs, STORE_EX)
+
+/* Prefetch */
+#define A64_PRFM(Rn, type, target, policy) \
+	aarch64_insn_gen_prefetch(Rn, AARCH64_INSN_PRFM_TYPE_##type, \
+				  AARCH64_INSN_PRFM_TARGET_##target, \
+				  AARCH64_INSN_PRFM_POLICY_##policy)
+
 /* Add/subtract (immediate) */
 #define A64_ADDSUB_IMM(sf, Rd, Rn, imm12, type) \
 	aarch64_insn_gen_add_sub_imm(Rd, Rn, imm12, \
diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
index 3047368..4f2b351 100644
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -321,6 +321,7 @@ static int build_insn(const struct bpf_insn *insn, struct jit_ctx *ctx)
 	const s32 imm = insn->imm;
 	const int i = insn - ctx->prog->insnsi;
 	const bool is64 = BPF_CLASS(code) == BPF_ALU64;
+	const bool isdw = BPF_SIZE(code) == BPF_DW;
 	u8 jmp_cond;
 	s32 jmp_offset;
 
@@ -681,7 +682,16 @@ static int build_insn(const struct bpf_insn *insn, struct jit_ctx *ctx)
 	case BPF_STX | BPF_XADD | BPF_W:
 	/* STX XADD: lock *(u64 *)(dst + off) += src */
 	case BPF_STX | BPF_XADD | BPF_DW:
-		goto notyet;
+		emit_a64_mov_i(1, tmp, off, ctx);
+		emit(A64_ADD(1, tmp, tmp, dst), ctx);
+		emit(A64_PRFM(tmp, PST, L1, STRM), ctx);
+		emit(A64_LDXR(isdw, tmp2, tmp), ctx);
+		emit(A64_ADD(isdw, tmp2, tmp2, src), ctx);
+		emit(A64_STXR(isdw, tmp2, tmp, tmp2), ctx);
+		jmp_offset = -3;
+		check_imm19(jmp_offset);
+		emit(A64_CBNZ(0, tmp2, jmp_offset), ctx);
+		break;
 
 	/* R0 = ntohx(*(size *)(((struct sk_buff *)R6)->data + imm)) */
 	case BPF_LD | BPF_ABS | BPF_W:
@@ -748,10 +758,6 @@ static int build_insn(const struct bpf_insn *insn, struct jit_ctx *ctx)
 		}
 		break;
 	}
-notyet:
-		pr_info_once("*** NOT YET: opcode %02x ***\n", code);
-		return -EFAULT;
-
 	default:
 		pr_err_once("unknown opcode %02x\n", code);
 		return -EINVAL;
diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 0362da0..3a7730c 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -434,6 +434,41 @@ static int bpf_fill_ld_abs_vlan_push_pop(struct bpf_test *self)
 	return 0;
 }
 
+static int __bpf_fill_stxdw(struct bpf_test *self, int size)
+{
+	unsigned int len = BPF_MAXINSNS;
+	struct bpf_insn *insn;
+	int i;
+
+	insn = kmalloc_array(len, sizeof(*insn), GFP_KERNEL);
+	if (!insn)
+		return -ENOMEM;
+
+	insn[0] = BPF_ALU32_IMM(BPF_MOV, R0, 1);
+	insn[1] = BPF_ST_MEM(size, R10, -40, 42);
+
+	for (i = 2; i < len - 2; i++)
+		insn[i] = BPF_STX_XADD(size, R10, R0, -40);
+
+	insn[len - 2] = BPF_LDX_MEM(size, R0, R10, -40);
+	insn[len - 1] = BPF_EXIT_INSN();
+
+	self->u.ptr.insns = insn;
+	self->u.ptr.len = len;
+
+	return 0;
+}
+
+static int bpf_fill_stxw(struct bpf_test *self)
+{
+	return __bpf_fill_stxdw(self, BPF_W);
+}
+
+static int bpf_fill_stxdw(struct bpf_test *self)
+{
+	return __bpf_fill_stxdw(self, BPF_DW);
+}
+
 static struct bpf_test tests[] = {
 	{
 		"TAX",
@@ -4303,6 +4338,41 @@ static int bpf_fill_ld_abs_vlan_push_pop(struct bpf_test *self)
 		{ { 0, 0x22 } },
 	},
 	{
+		"STX_XADD_W: Test side-effects, r10: 0x12 + 0x10 = 0x22",
+		.u.insns_int = {
+			BPF_ALU64_REG(BPF_MOV, R1, R10),
+			BPF_ALU32_IMM(BPF_MOV, R0, 0x12),
+			BPF_ST_MEM(BPF_W, R10, -40, 0x10),
+			BPF_STX_XADD(BPF_W, R10, R0, -40),
+			BPF_ALU64_REG(BPF_MOV, R0, R10),
+			BPF_ALU64_REG(BPF_SUB, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0 } },
+	},
+	{
+		"STX_XADD_W: Test side-effects, r0: 0x12 + 0x10 = 0x22",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0x12),
+			BPF_ST_MEM(BPF_W, R10, -40, 0x10),
+			BPF_STX_XADD(BPF_W, R10, R0, -40),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x12 } },
+	},
+	{
+		"STX_XADD_W: X + 1 + 1 + 1 + ...",
+		{ },
+		INTERNAL,
+		{ },
+		{ { 0, 4134 } },
+		.fill_helper = bpf_fill_stxw,
+	},
+	{
 		"STX_XADD_DW: Test: 0x12 + 0x10 = 0x22",
 		.u.insns_int = {
 			BPF_ALU32_IMM(BPF_MOV, R0, 0x12),
@@ -4315,6 +4385,41 @@ static int bpf_fill_ld_abs_vlan_push_pop(struct bpf_test *self)
 		{ },
 		{ { 0, 0x22 } },
 	},
+	{
+		"STX_XADD_DW: Test side-effects, r10: 0x12 + 0x10 = 0x22",
+		.u.insns_int = {
+			BPF_ALU64_REG(BPF_MOV, R1, R10),
+			BPF_ALU32_IMM(BPF_MOV, R0, 0x12),
+			BPF_ST_MEM(BPF_DW, R10, -40, 0x10),
+			BPF_STX_XADD(BPF_DW, R10, R0, -40),
+			BPF_ALU64_REG(BPF_MOV, R0, R10),
+			BPF_ALU64_REG(BPF_SUB, R0, R1),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0 } },
+	},
+	{
+		"STX_XADD_DW: Test side-effects, r0: 0x12 + 0x10 = 0x22",
+		.u.insns_int = {
+			BPF_ALU32_IMM(BPF_MOV, R0, 0x12),
+			BPF_ST_MEM(BPF_DW, R10, -40, 0x10),
+			BPF_STX_XADD(BPF_DW, R10, R0, -40),
+			BPF_EXIT_INSN(),
+		},
+		INTERNAL,
+		{ },
+		{ { 0, 0x12 } },
+	},
+	{
+		"STX_XADD_DW: X + 1 + 1 + 1 + ...",
+		{ },
+		INTERNAL,
+		{ },
+		{ { 0, 4134 } },
+		.fill_helper = bpf_fill_stxdw,
+	},
 	/* BPF_JMP | BPF_EXIT */
 	{
 		"JMP_EXIT",
-- 
1.9.3
