From: Vladimir Murzin <murzin.v@gmail.com>
Subject: [PATCH v2] arm: bpf_jit: support MOD operation
Date: Sat, 21 Sep 2013 09:32:37 +0200
Message-ID: <1379748757-3512-1-git-send-email-murzin.v@gmail.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux@arm.linux.org.uk, mgherzan@gmail.com, dborkman@redhat.com,
	edumazet@google.com, will.daecon@arm.com,
	Vladimir Murzin <murzin.v@gmail.com>
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:59623 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752123Ab3IUHdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 03:33:32 -0400
Received: by mail-lb0-f173.google.com with SMTP id o14so1253849lbi.18
        for <netdev@vger.kernel.org>; Sat, 21 Sep 2013 00:33:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit b6069a9570 (filter: add MOD operation) added generic
support for modulus operation in BPF.

This patch brings JIT support for ARM.

Signed-off-by: Vladimir Murzin <murzin.v@gmail.com>
---
v1->v2
    - wrapper for udiv_mod is added
    - MUL and SUB are squashed into MLS instruction
    
For BPF program

(000) ldh      [12]
(001) jeq      #0x800           jt 2	jf 10
(002) ldh      [16]
(003) sub      #20
(004) mod      #5
(005) jeq      #0x0             jt 10	jf 6
(006) ldb      [20]
(007) and      #0x20
(008) jeq      #0x20            jt 9	jf 10
(009) ret      #65535
(010) ret      #0

Following code is generated

256 bytes emitted from JIT compiler (pass:2, flen:11)
bf008000 + <x>:
   0:	push	{r4, r6, r7, r8, lr}
   4:	mov	r6, r0
   8:	ldr	r7, [r6, #168]	; 0xa8
   c:	ldr	r8, [r6, #80]	; 0x50
  10:	ldr	r0, [r6, #84]	; 0x54
  14:	sub	r8, r8, r0
  18:	mov	r1, #12
  1c:	sub	r0, r8, #2
  20:	cmp	r0, r1
  24:	addcs	r0, r1, r7
  28:	ldrhcs	r4, [r0]
  2c:	rev16cs	r4, r4
  30:	bcs	0x00000054
  34:	movw	r3, #7012	; 0x1b64
  38:	movt	r3, #49154	; 0xc002
  3c:	mov	r0, r6
  40:	blx	r3
  44:	cmp	r1, #0
  48:	bne	0x000000f8
  4c:	nop			; (mov r0, r0)
  50:	mov	r4, r0
  54:	cmp	r4, #2048	; 0x800
  58:	bne	0x000000f8
  5c:	mov	r1, #16
  60:	sub	r0, r8, #2
  64:	cmp	r0, r1
  68:	addcs	r0, r1, r7
  6c:	ldrhcs	r4, [r0]
  70:	rev16cs	r4, r4
  74:	bcs	0x00000098
  78:	movw	r3, #7012	; 0x1b64
  7c:	movt	r3, #49154	; 0xc002
  80:	mov	r0, r6
  84:	blx	r3
  88:	cmp	r1, #0
  8c:	bne	0x000000f8
  90:	nop			; (mov r0, r0)
  94:	mov	r4, r0
  98:	sub	r4, r4, #20
  9c:	mov	r0, #5
  a0:	udiv	r3, r4, r0
  a4:	mls	r4, r3, r0, r4
  a8:	cmp	r4, #0
  ac:	beq	0x000000f8
  b0:	mov	r1, #20
  b4:	cmp	r8, r1
  b8:	addhi	r0, r1, r7
  bc:	ldrbhi	r4, [r0]
  c0:	bhi	0x000000e4
  c4:	movw	r3, #7068	; 0x1b9c
  c8:	movt	r3, #49154	; 0xc002
  cc:	mov	r0, r6
  d0:	blx	r3
  d4:	cmp	r1, #0
  d8:	bne	0x000000f8
  dc:	nop			; (mov r0, r0)
  e0:	mov	r4, r0
  e4:	and	r4, r4, #32
  e8:	cmp	r4, #32
  ec:	bne	0x000000f8
  f0:	movw	r0, #65535	; 0xffff
  f4:	b	0x000000fc
  f8:	mov	r0, #0
  fc:	pop	{r4, r6, r7, r8, pc}

Raw opcodes are

flen=11 proglen=256 pass=2 image=bf008000
JIT code: 00000000: d0 41 2d e9 00 60 a0 e1 a8 70 96 e5 50 80 96 e5
JIT code: 00000010: 54 00 96 e5 00 80 48 e0 0c 10 a0 e3 02 00 48 e2
JIT code: 00000020: 01 00 50 e1 07 00 81 20 b0 40 d0 21 b4 4f bf 26
JIT code: 00000030: 07 00 00 2a 64 3b 01 e3 02 30 4c e3 06 00 a0 e1
JIT code: 00000040: 33 ff 2f e1 00 00 51 e3 2a 00 00 1a 00 00 a0 e1
JIT code: 00000050: 00 40 a0 e1 02 0b 54 e3 26 00 00 1a 10 10 a0 e3
JIT code: 00000060: 02 00 48 e2 01 00 50 e1 07 00 81 20 b0 40 d0 21
JIT code: 00000070: b4 4f bf 26 07 00 00 2a 64 3b 01 e3 02 30 4c e3
JIT code: 00000080: 06 00 a0 e1 33 ff 2f e1 00 00 51 e3 19 00 00 1a
JIT code: 00000090: 00 00 a0 e1 00 40 a0 e1 14 40 44 e2 05 00 a0 e3
JIT code: 000000a0: 14 f0 33 e7 93 40 64 e0 00 00 54 e3 11 00 00 0a
JIT code: 000000b0: 14 10 a0 e3 01 00 58 e1 07 00 81 80 00 40 d0 85
JIT code: 000000c0: 07 00 00 8a 9c 3b 01 e3 02 30 4c e3 06 00 a0 e1
JIT code: 000000d0: 33 ff 2f e1 00 00 51 e3 06 00 00 1a 00 00 a0 e1
JIT code: 000000e0: 00 40 a0 e1 20 40 04 e2 20 00 54 e3 01 00 00 1a
JIT code: 000000f0: ff 0f 0f e3 00 00 00 ea 00 00 a0 e3 d0 81 bd e8

 arch/arm/net/bpf_jit_32.c |   38 ++++++++++++++++++++++++++++++++++++++
 arch/arm/net/bpf_jit_32.h |    3 +++
 2 files changed, 41 insertions(+)

diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index f50d223..faec4d3 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -111,6 +111,11 @@ static u32 jit_udiv(u32 dividend, u32 divisor)
 	return dividend / divisor;
 }
 
+static u32 jit_udiv_mod(u32 dividend, u32 divisor)
+{
+	return dividend % divisor;
+}
+
 static inline void _emit(int cond, u32 inst, struct jit_ctx *ctx)
 {
 	if (ctx->target != NULL)
@@ -458,6 +463,29 @@ static inline void emit_udiv(u8 rd, u8 rm, u8 rn, struct jit_ctx *ctx)
 		emit(ARM_MOV_R(rd, ARM_R0), ctx);
 }
 
+static inline void emit_udiv_mod(u8 rd, u8 rm, u8 rn, struct jit_ctx *ctx)
+{
+#if __LINUX_ARM_ARCH__ == 7
+	if (elf_hwcap & HWCAP_IDIVA) {
+		emit(ARM_UDIV(ARM_R3, rm, rn), ctx);
+		emit(ARM_MLS(rd, ARM_R3, rn, rm), ctx);
+		return;
+	}
+#endif
+	if (rm != ARM_R0)
+		emit(ARM_MOV_R(ARM_R0, rm), ctx);
+	if (rn != ARM_R1)
+		emit(ARM_MOV_R(ARM_R1, rn), ctx);
+
+	ctx->seen |= SEEN_CALL;
+	emit_mov_i(ARM_R3, (u32)jit_udiv_mod, ctx);
+	emit_blx_r(ARM_R3, ctx);
+
+	if (rd != ARM_R0)
+		emit(ARM_MOV_R(rd, ARM_R0), ctx);
+}
+
+
 static inline void update_on_xread(struct jit_ctx *ctx)
 {
 	if (!(ctx->seen & SEEN_X))
@@ -636,6 +664,16 @@ load_ind:
 			update_on_xread(ctx);
 			emit(ARM_MUL(r_A, r_A, r_X), ctx);
 			break;
+		case BPF_S_ALU_MOD_X: /* A %= X; */
+			update_on_xread(ctx);
+			emit(ARM_CMP_I(r_X, 0), ctx);
+			emit_err_ret(ARM_COND_EQ, ctx);
+			emit_udiv_mod(r_A, r_A, r_X, ctx);
+			break;
+		case BPF_S_ALU_MOD_K: /* A %= K; */
+			emit_mov_i(r_scratch, k, ctx);
+			emit_udiv_mod(r_A, r_A, r_scratch, ctx);
+			break;
 		case BPF_S_ALU_DIV_K:
 			/* current k == reciprocal_value(userspace k) */
 			emit_mov_i(r_scratch, k, ctx);
diff --git a/arch/arm/net/bpf_jit_32.h b/arch/arm/net/bpf_jit_32.h
index afb8462..640a8fd 100644
--- a/arch/arm/net/bpf_jit_32.h
+++ b/arch/arm/net/bpf_jit_32.h
@@ -90,6 +90,7 @@
 #define ARM_INST_MOVT		0x03400000
 
 #define ARM_INST_MUL		0x00000090
+#define ARM_INST_MLS		0x00600090
 
 #define ARM_INST_POP		0x08bd0000
 #define ARM_INST_PUSH		0x092d0000
@@ -192,5 +193,7 @@
 
 #define ARM_UMULL(rd_lo, rd_hi, rn, rm)	(ARM_INST_UMULL | (rd_hi) << 16 \
 					 | (rd_lo) << 12 | (rm) << 8 | rn)
+#define ARM_MLS(rd, rn, rm, ra)	(ARM_INST_MLS | (rd) << 16 \
+					 | (ra) << 12 | (rm) << 8 | rn)
 
 #endif /* PFILTER_OPCODES_ARM_H */
-- 
1.7.10.4
