From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] net: filter: cleanup A/X name usage
Date: Fri,  6 Jun 2014 14:46:06 -0700
Message-ID: <1402091166-5206-1-git-send-email-ast@plumgrid.com>
Cc: Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:58701 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901AbaFFVqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 17:46:14 -0400
Received: by mail-pd0-f173.google.com with SMTP id v10so2923949pde.32
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2014 14:46:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The macro 'A' used in internal BPF interpreter:
 #define A regs[insn->a_reg]
was easily confused with the name of classic BPF register 'A', since
'A' would mean two different things depending on context.

This patch is trying to clean up the naming and clarify its usage in the
following way:

- A and X are names of two classic BPF registers

- BPF_REG_A denotes internal BPF register R0 used to map classic register A
  in internal BPF programs generated from classic

- BPF_REG_X denotes internal BPF register R7 used to map classic register X
  in internal BPF programs generated from classic

- internal BPF instruction format:
struct sock_filter_int {
        __u8    code;           /* opcode */
        __u8    dst_reg:4;      /* dest register */
        __u8    src_reg:4;      /* source register */
        __s16   off;            /* signed offset */
        __s32   imm;            /* signed immediate constant */
};

- BPF_X/BPF_K is 1 bit used to encode source operand of instruction
In classic:
  BPF_X - means use register X as source operand
  BPF_K - means use 32-bit immediate as source operand
In internal:
  BPF_X - means use 'src_reg' register as source operand
  BPF_K - means use 32-bit immediate as source operand

Suggested-by: Chema Gonzalez <chema@google.com>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 Documentation/networking/filter.txt |    2 +-
 arch/x86/net/bpf_jit_comp.c         |  260 +++++++++++++++++------------------
 include/linux/filter.h              |  156 +++++++++++----------
 net/core/filter.c                   |  198 +++++++++++++-------------
 4 files changed, 314 insertions(+), 302 deletions(-)

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index 58c443926647..9f49b8690500 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -805,7 +805,7 @@ to seccomp_data, for converted BPF filters R1 points to a skb.
 
 A program, that is translated internally consists of the following elements:
 
-  op:16, jt:8, jf:8, k:32    ==>    op:8, a_reg:4, x_reg:4, off:16, imm:32
+  op:16, jt:8, jf:8, k:32    ==>    op:8, dst_reg:4, src_reg:4, off:16, imm:32
 
 So far 87 internal BPF instructions were implemented. 8-bit 'op' opcode field
 has room for new instructions. Some of them may use 16/24/32 byte encoding. New
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 080f3f071bb0..99bef86ed6df 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -64,10 +64,10 @@ static inline bool is_simm32(s64 value)
 	return value == (s64) (s32) value;
 }
 
-/* mov A, X */
-#define EMIT_mov(A, X) \
-	do {if (A != X) \
-		EMIT3(add_2mod(0x48, A, X), 0x89, add_2reg(0xC0, A, X)); \
+/* mov dst, src */
+#define EMIT_mov(DST, SRC) \
+	do {if (DST != SRC) \
+		EMIT3(add_2mod(0x48, DST, SRC), 0x89, add_2reg(0xC0, DST, SRC)); \
 	} while (0)
 
 static int bpf_size_to_x86_bytes(int bpf_size)
@@ -194,16 +194,16 @@ static inline u8 add_2mod(u8 byte, u32 r1, u32 r2)
 	return byte;
 }
 
-/* encode dest register 'a_reg' into x64 opcode 'byte' */
-static inline u8 add_1reg(u8 byte, u32 a_reg)
+/* encode 'dst_reg' register into x64 opcode 'byte' */
+static inline u8 add_1reg(u8 byte, u32 dst_reg)
 {
-	return byte + reg2hex[a_reg];
+	return byte + reg2hex[dst_reg];
 }
 
-/* encode dest 'a_reg' and src 'x_reg' registers into x64 opcode 'byte' */
-static inline u8 add_2reg(u8 byte, u32 a_reg, u32 x_reg)
+/* encode 'dst_reg' and 'src_reg' registers into x64 opcode 'byte' */
+static inline u8 add_2reg(u8 byte, u32 dst_reg, u32 src_reg)
 {
-	return byte + reg2hex[a_reg] + (reg2hex[x_reg] << 3);
+	return byte + reg2hex[dst_reg] + (reg2hex[src_reg] << 3);
 }
 
 struct jit_context {
@@ -286,9 +286,9 @@ static int do_jit(struct sk_filter *bpf_prog, int *addrs, u8 *image,
 	}
 
 	for (i = 0; i < insn_cnt; i++, insn++) {
-		const s32 K = insn->imm;
-		u32 a_reg = insn->a_reg;
-		u32 x_reg = insn->x_reg;
+		const s32 imm32 = insn->imm;
+		u32 dst_reg = insn->dst_reg;
+		u32 src_reg = insn->src_reg;
 		u8 b1 = 0, b2 = 0, b3 = 0;
 		s64 jmp_offset;
 		u8 jmp_cond;
@@ -315,32 +315,32 @@ static int do_jit(struct sk_filter *bpf_prog, int *addrs, u8 *image,
 			case BPF_XOR: b2 = 0x31; break;
 			}
 			if (BPF_CLASS(insn->code) == BPF_ALU64)
-				EMIT1(add_2mod(0x48, a_reg, x_reg));
-			else if (is_ereg(a_reg) || is_ereg(x_reg))
-				EMIT1(add_2mod(0x40, a_reg, x_reg));
-			EMIT2(b2, add_2reg(0xC0, a_reg, x_reg));
+				EMIT1(add_2mod(0x48, dst_reg, src_reg));
+			else if (is_ereg(dst_reg) || is_ereg(src_reg))
+				EMIT1(add_2mod(0x40, dst_reg, src_reg));
+			EMIT2(b2, add_2reg(0xC0, dst_reg, src_reg));
 			break;
 
-			/* mov A, X */
+			/* mov dst, src */
 		case BPF_ALU64 | BPF_MOV | BPF_X:
-			EMIT_mov(a_reg, x_reg);
+			EMIT_mov(dst_reg, src_reg);
 			break;
 
-			/* mov32 A, X */
+			/* mov32 dst, src */
 		case BPF_ALU | BPF_MOV | BPF_X:
-			if (is_ereg(a_reg) || is_ereg(x_reg))
-				EMIT1(add_2mod(0x40, a_reg, x_reg));
-			EMIT2(0x89, add_2reg(0xC0, a_reg, x_reg));
+			if (is_ereg(dst_reg) || is_ereg(src_reg))
+				EMIT1(add_2mod(0x40, dst_reg, src_reg));
+			EMIT2(0x89, add_2reg(0xC0, dst_reg, src_reg));
 			break;
 
-			/* neg A */
+			/* neg dst */
 		case BPF_ALU | BPF_NEG:
 		case BPF_ALU64 | BPF_NEG:
 			if (BPF_CLASS(insn->code) == BPF_ALU64)
-				EMIT1(add_1mod(0x48, a_reg));
-			else if (is_ereg(a_reg))
-				EMIT1(add_1mod(0x40, a_reg));
-			EMIT2(0xF7, add_1reg(0xD8, a_reg));
+				EMIT1(add_1mod(0x48, dst_reg));
+			else if (is_ereg(dst_reg))
+				EMIT1(add_1mod(0x40, dst_reg));
+			EMIT2(0xF7, add_1reg(0xD8, dst_reg));
 			break;
 
 		case BPF_ALU | BPF_ADD | BPF_K:
@@ -354,9 +354,9 @@ static int do_jit(struct sk_filter *bpf_prog, int *addrs, u8 *image,
 		case BPF_ALU64 | BPF_OR | BPF_K:
 		case BPF_ALU64 | BPF_XOR | BPF_K:
 			if (BPF_CLASS(insn->code) == BPF_ALU64)
-				EMIT1(add_1mod(0x48, a_reg));
-			else if (is_ereg(a_reg))
-				EMIT1(add_1mod(0x40, a_reg));
+				EMIT1(add_1mod(0x48, dst_reg));
+			else if (is_ereg(dst_reg))
+				EMIT1(add_1mod(0x40, dst_reg));
 
 			switch (BPF_OP(insn->code)) {
 			case BPF_ADD: b3 = 0xC0; break;
@@ -366,10 +366,10 @@ static int do_jit(struct sk_filter *bpf_prog, int *addrs, u8 *image,
 			case BPF_XOR: b3 = 0xF0; break;
 			}
 
-			if (is_imm8(K))
-				EMIT3(0x83, add_1reg(b3, a_reg), K);
+			if (is_imm8(imm32))
+				EMIT3(0x83, add_1reg(b3, dst_reg), imm32);
 			else
-				EMIT2_off32(0x81, add_1reg(b3, a_reg), K);
+				EMIT2_off32(0x81, add_1reg(b3, dst_reg), imm32);
 			break;
 
 		case BPF_ALU64 | BPF_MOV | BPF_K:
@@ -377,23 +377,23 @@ static int do_jit(struct sk_filter *bpf_prog, int *addrs, u8 *image,
 			 * use 'mov eax, imm32' (which zero-extends imm32)
 			 * to save 2 bytes
 			 */
-			if (K < 0) {
+			if (imm32 < 0) {
 				/* 'mov rax, imm32' sign extends imm32 */
-				b1 = add_1mod(0x48, a_reg);
+				b1 = add_1mod(0x48, dst_reg);
 				b2 = 0xC7;
 				b3 = 0xC0;
-				EMIT3_off32(b1, b2, add_1reg(b3, a_reg), K);
+				EMIT3_off32(b1, b2, add_1reg(b3, dst_reg), imm32);
 				break;
 			}
 
 		case BPF_ALU | BPF_MOV | BPF_K:
 			/* mov %eax, imm32 */
-			if (is_ereg(a_reg))
-				EMIT1(add_1mod(0x40, a_reg));
-			EMIT1_off32(add_1reg(0xB8, a_reg), K);
+			if (is_ereg(dst_reg))
+				EMIT1(add_1mod(0x40, dst_reg));
+			EMIT1_off32(add_1reg(0xB8, dst_reg), imm32);
 			break;
 
-			/* A %= X, A /= X, A %= K, A /= K */
+			/* dst %= src, dst /= src, dst %= imm32, dst /= imm32 */
 		case BPF_ALU | BPF_MOD | BPF_X:
 		case BPF_ALU | BPF_DIV | BPF_X:
 		case BPF_ALU | BPF_MOD | BPF_K:
@@ -406,14 +406,14 @@ static int do_jit(struct sk_filter *bpf_prog, int *addrs, u8 *image,
 			EMIT1(0x52); /* push rdx */
 
 			if (BPF_SRC(insn->code) == BPF_X)
-				/* mov r11, X */
-				EMIT_mov(AUX_REG, x_reg);
+				/* mov r11, src_reg */
+				EMIT_mov(AUX_REG, src_reg);
 			else
-				/* mov r11, K */
-				EMIT3_off32(0x49, 0xC7, 0xC3, K);
+				/* mov r11, imm32 */
+				EMIT3_off32(0x49, 0xC7, 0xC3, imm32);
 
-			/* mov rax, A */
-			EMIT_mov(BPF_REG_0, a_reg);
+			/* mov rax, dst_reg */
+			EMIT_mov(BPF_REG_0, dst_reg);
 
 			/* xor edx, edx
 			 * equivalent to 'xor rdx, rdx', but one byte less
@@ -421,7 +421,7 @@ static int do_jit(struct sk_filter *bpf_prog, int *addrs, u8 *image,
 			EMIT2(0x31, 0xd2);
 
 			if (BPF_SRC(insn->code) == BPF_X) {
-				/* if (X == 0) return 0 */
+				/* if (src_reg == 0) return 0 */
 
 				/* cmp r11, 0 */
 				EMIT4(0x49, 0x83, 0xFB, 0x00);
@@ -457,8 +457,8 @@ static int do_jit(struct sk_filter *bpf_prog, int *addrs, u8 *image,
 			EMIT1(0x5A); /* pop rdx */
 			EMIT1(0x58); /* pop rax */
 
-			/* mov A, r11 */
-			EMIT_mov(a_reg, AUX_REG);
+			/* mov dst_reg, r11 */
+			EMIT_mov(dst_reg, AUX_REG);
 			break;
 
 		case BPF_ALU | BPF_MUL | BPF_K:
@@ -468,15 +468,15 @@ static int do_jit(struct sk_filter *bpf_prog, int *addrs, u8 *image,
 			EMIT1(0x50); /* push rax */
 			EMIT1(0x52); /* push rdx */
 
-			/* mov r11, A */
-			EMIT_mov(AUX_REG, a_reg);
+			/* mov r11, dst_reg */
+			EMIT_mov(AUX_REG, dst_reg);
 
 			if (BPF_SRC(insn->code) == BPF_X)
-				/* mov rax, X */
-				EMIT_mov(BPF_REG_0, x_reg);
+				/* mov rax, src_reg */
+				EMIT_mov(BPF_REG_0, src_reg);
 			else
-				/* mov rax, K */
-				EMIT3_off32(0x48, 0xC7, 0xC0, K);
+				/* mov rax, imm32 */
+				EMIT3_off32(0x48, 0xC7, 0xC0, imm32);
 
 			if (BPF_CLASS(insn->code) == BPF_ALU64)
 				EMIT1(add_1mod(0x48, AUX_REG));
@@ -491,8 +491,8 @@ static int do_jit(struct sk_filter *bpf_prog, int *addrs, u8 *image,
 			EMIT1(0x5A); /* pop rdx */
 			EMIT1(0x58); /* pop rax */
 
-			/* mov A, r11 */
-			EMIT_mov(a_reg, AUX_REG);
+			/* mov dst_reg, r11 */
+			EMIT_mov(dst_reg, AUX_REG);
 			break;
 
 			/* shifts */
@@ -503,39 +503,39 @@ static int do_jit(struct sk_filter *bpf_prog, int *addrs, u8 *image,
 		case BPF_ALU64 | BPF_RSH | BPF_K:
 		case BPF_ALU64 | BPF_ARSH | BPF_K:
 			if (BPF_CLASS(insn->code) == BPF_ALU64)
-				EMIT1(add_1mod(0x48, a_reg));
-			else if (is_ereg(a_reg))
-				EMIT1(add_1mod(0x40, a_reg));
+				EMIT1(add_1mod(0x48, dst_reg));
+			else if (is_ereg(dst_reg))
+				EMIT1(add_1mod(0x40, dst_reg));
 
 			switch (BPF_OP(insn->code)) {
 			case BPF_LSH: b3 = 0xE0; break;
 			case BPF_RSH: b3 = 0xE8; break;
 			case BPF_ARSH: b3 = 0xF8; break;
 			}
-			EMIT3(0xC1, add_1reg(b3, a_reg), K);
+			EMIT3(0xC1, add_1reg(b3, dst_reg), imm32);
 			break;
 
 		case BPF_ALU | BPF_END | BPF_FROM_BE:
-			switch (K) {
+			switch (imm32) {
 			case 16:
 				/* emit 'ror %ax, 8' to swap lower 2 bytes */
 				EMIT1(0x66);
-				if (is_ereg(a_reg))
+				if (is_ereg(dst_reg))
 					EMIT1(0x41);
-				EMIT3(0xC1, add_1reg(0xC8, a_reg), 8);
+				EMIT3(0xC1, add_1reg(0xC8, dst_reg), 8);
 				break;
 			case 32:
 				/* emit 'bswap eax' to swap lower 4 bytes */
-				if (is_ereg(a_reg))
+				if (is_ereg(dst_reg))
 					EMIT2(0x41, 0x0F);
 				else
 					EMIT1(0x0F);
-				EMIT1(add_1reg(0xC8, a_reg));
+				EMIT1(add_1reg(0xC8, dst_reg));
 				break;
 			case 64:
 				/* emit 'bswap rax' to swap 8 bytes */
-				EMIT3(add_1mod(0x48, a_reg), 0x0F,
-				      add_1reg(0xC8, a_reg));
+				EMIT3(add_1mod(0x48, dst_reg), 0x0F,
+				      add_1reg(0xC8, dst_reg));
 				break;
 			}
 			break;
@@ -543,117 +543,117 @@ static int do_jit(struct sk_filter *bpf_prog, int *addrs, u8 *image,
 		case BPF_ALU | BPF_END | BPF_FROM_LE:
 			break;
 
-			/* ST: *(u8*)(a_reg + off) = imm */
+			/* ST: *(u8*)(dst_reg + off) = imm */
 		case BPF_ST | BPF_MEM | BPF_B:
-			if (is_ereg(a_reg))
+			if (is_ereg(dst_reg))
 				EMIT2(0x41, 0xC6);
 			else
 				EMIT1(0xC6);
 			goto st;
 		case BPF_ST | BPF_MEM | BPF_H:
-			if (is_ereg(a_reg))
+			if (is_ereg(dst_reg))
 				EMIT3(0x66, 0x41, 0xC7);
 			else
 				EMIT2(0x66, 0xC7);
 			goto st;
 		case BPF_ST | BPF_MEM | BPF_W:
-			if (is_ereg(a_reg))
+			if (is_ereg(dst_reg))
 				EMIT2(0x41, 0xC7);
 			else
 				EMIT1(0xC7);
 			goto st;
 		case BPF_ST | BPF_MEM | BPF_DW:
-			EMIT2(add_1mod(0x48, a_reg), 0xC7);
+			EMIT2(add_1mod(0x48, dst_reg), 0xC7);
 
 st:			if (is_imm8(insn->off))
-				EMIT2(add_1reg(0x40, a_reg), insn->off);
+				EMIT2(add_1reg(0x40, dst_reg), insn->off);
 			else
-				EMIT1_off32(add_1reg(0x80, a_reg), insn->off);
+				EMIT1_off32(add_1reg(0x80, dst_reg), insn->off);
 
-			EMIT(K, bpf_size_to_x86_bytes(BPF_SIZE(insn->code)));
+			EMIT(imm32, bpf_size_to_x86_bytes(BPF_SIZE(insn->code)));
 			break;
 
-			/* STX: *(u8*)(a_reg + off) = x_reg */
+			/* STX: *(u8*)(dst_reg + off) = src_reg */
 		case BPF_STX | BPF_MEM | BPF_B:
 			/* emit 'mov byte ptr [rax + off], al' */
-			if (is_ereg(a_reg) || is_ereg(x_reg) ||
+			if (is_ereg(dst_reg) || is_ereg(src_reg) ||
 			    /* have to add extra byte for x86 SIL, DIL regs */
-			    x_reg == BPF_REG_1 || x_reg == BPF_REG_2)
-				EMIT2(add_2mod(0x40, a_reg, x_reg), 0x88);
+			    src_reg == BPF_REG_1 || src_reg == BPF_REG_2)
+				EMIT2(add_2mod(0x40, dst_reg, src_reg), 0x88);
 			else
 				EMIT1(0x88);
 			goto stx;
 		case BPF_STX | BPF_MEM | BPF_H:
-			if (is_ereg(a_reg) || is_ereg(x_reg))
-				EMIT3(0x66, add_2mod(0x40, a_reg, x_reg), 0x89);
+			if (is_ereg(dst_reg) || is_ereg(src_reg))
+				EMIT3(0x66, add_2mod(0x40, dst_reg, src_reg), 0x89);
 			else
 				EMIT2(0x66, 0x89);
 			goto stx;
 		case BPF_STX | BPF_MEM | BPF_W:
-			if (is_ereg(a_reg) || is_ereg(x_reg))
-				EMIT2(add_2mod(0x40, a_reg, x_reg), 0x89);
+			if (is_ereg(dst_reg) || is_ereg(src_reg))
+				EMIT2(add_2mod(0x40, dst_reg, src_reg), 0x89);
 			else
 				EMIT1(0x89);
 			goto stx;
 		case BPF_STX | BPF_MEM | BPF_DW:
-			EMIT2(add_2mod(0x48, a_reg, x_reg), 0x89);
+			EMIT2(add_2mod(0x48, dst_reg, src_reg), 0x89);
 stx:			if (is_imm8(insn->off))
-				EMIT2(add_2reg(0x40, a_reg, x_reg), insn->off);
+				EMIT2(add_2reg(0x40, dst_reg, src_reg), insn->off);
 			else
-				EMIT1_off32(add_2reg(0x80, a_reg, x_reg),
+				EMIT1_off32(add_2reg(0x80, dst_reg, src_reg),
 					    insn->off);
 			break;
 
-			/* LDX: a_reg = *(u8*)(x_reg + off) */
+			/* LDX: dst_reg = *(u8*)(src_reg + off) */
 		case BPF_LDX | BPF_MEM | BPF_B:
 			/* emit 'movzx rax, byte ptr [rax + off]' */
-			EMIT3(add_2mod(0x48, x_reg, a_reg), 0x0F, 0xB6);
+			EMIT3(add_2mod(0x48, src_reg, dst_reg), 0x0F, 0xB6);
 			goto ldx;
 		case BPF_LDX | BPF_MEM | BPF_H:
 			/* emit 'movzx rax, word ptr [rax + off]' */
-			EMIT3(add_2mod(0x48, x_reg, a_reg), 0x0F, 0xB7);
+			EMIT3(add_2mod(0x48, src_reg, dst_reg), 0x0F, 0xB7);
 			goto ldx;
 		case BPF_LDX | BPF_MEM | BPF_W:
 			/* emit 'mov eax, dword ptr [rax+0x14]' */
-			if (is_ereg(a_reg) || is_ereg(x_reg))
-				EMIT2(add_2mod(0x40, x_reg, a_reg), 0x8B);
+			if (is_ereg(dst_reg) || is_ereg(src_reg))
+				EMIT2(add_2mod(0x40, src_reg, dst_reg), 0x8B);
 			else
 				EMIT1(0x8B);
 			goto ldx;
 		case BPF_LDX | BPF_MEM | BPF_DW:
 			/* emit 'mov rax, qword ptr [rax+0x14]' */
-			EMIT2(add_2mod(0x48, x_reg, a_reg), 0x8B);
+			EMIT2(add_2mod(0x48, src_reg, dst_reg), 0x8B);
 ldx:			/* if insn->off == 0 we can save one extra byte, but
 			 * special case of x86 r13 which always needs an offset
 			 * is not worth the hassle
 			 */
 			if (is_imm8(insn->off))
-				EMIT2(add_2reg(0x40, x_reg, a_reg), insn->off);
+				EMIT2(add_2reg(0x40, src_reg, dst_reg), insn->off);
 			else
-				EMIT1_off32(add_2reg(0x80, x_reg, a_reg),
+				EMIT1_off32(add_2reg(0x80, src_reg, dst_reg),
 					    insn->off);
 			break;
 
-			/* STX XADD: lock *(u32*)(a_reg + off) += x_reg */
+			/* STX XADD: lock *(u32*)(dst_reg + off) += src_reg */
 		case BPF_STX | BPF_XADD | BPF_W:
 			/* emit 'lock add dword ptr [rax + off], eax' */
-			if (is_ereg(a_reg) || is_ereg(x_reg))
-				EMIT3(0xF0, add_2mod(0x40, a_reg, x_reg), 0x01);
+			if (is_ereg(dst_reg) || is_ereg(src_reg))
+				EMIT3(0xF0, add_2mod(0x40, dst_reg, src_reg), 0x01);
 			else
 				EMIT2(0xF0, 0x01);
 			goto xadd;
 		case BPF_STX | BPF_XADD | BPF_DW:
-			EMIT3(0xF0, add_2mod(0x48, a_reg, x_reg), 0x01);
+			EMIT3(0xF0, add_2mod(0x48, dst_reg, src_reg), 0x01);
 xadd:			if (is_imm8(insn->off))
-				EMIT2(add_2reg(0x40, a_reg, x_reg), insn->off);
+				EMIT2(add_2reg(0x40, dst_reg, src_reg), insn->off);
 			else
-				EMIT1_off32(add_2reg(0x80, a_reg, x_reg),
+				EMIT1_off32(add_2reg(0x80, dst_reg, src_reg),
 					    insn->off);
 			break;
 
 			/* call */
 		case BPF_JMP | BPF_CALL:
-			func = (u8 *) __bpf_call_base + K;
+			func = (u8 *) __bpf_call_base + imm32;
 			jmp_offset = func - (image + addrs[i]);
 			if (ctx->seen_ld_abs) {
 				EMIT2(0x41, 0x52); /* push %r10 */
@@ -663,9 +663,9 @@ xadd:			if (is_imm8(insn->off))
 				 */
 				jmp_offset += 4;
 			}
-			if (!K || !is_simm32(jmp_offset)) {
+			if (!imm32 || !is_simm32(jmp_offset)) {
 				pr_err("unsupported bpf func %d addr %p image %p\n",
-				       K, func, image);
+				       imm32, func, image);
 				return -EINVAL;
 			}
 			EMIT1_off32(0xE8, jmp_offset);
@@ -682,21 +682,21 @@ xadd:			if (is_imm8(insn->off))
 		case BPF_JMP | BPF_JGE | BPF_X:
 		case BPF_JMP | BPF_JSGT | BPF_X:
 		case BPF_JMP | BPF_JSGE | BPF_X:
-			/* cmp a_reg, x_reg */
-			EMIT3(add_2mod(0x48, a_reg, x_reg), 0x39,
-			      add_2reg(0xC0, a_reg, x_reg));
+			/* cmp dst_reg, src_reg */
+			EMIT3(add_2mod(0x48, dst_reg, src_reg), 0x39,
+			      add_2reg(0xC0, dst_reg, src_reg));
 			goto emit_cond_jmp;
 
 		case BPF_JMP | BPF_JSET | BPF_X:
-			/* test a_reg, x_reg */
-			EMIT3(add_2mod(0x48, a_reg, x_reg), 0x85,
-			      add_2reg(0xC0, a_reg, x_reg));
+			/* test dst_reg, src_reg */
+			EMIT3(add_2mod(0x48, dst_reg, src_reg), 0x85,
+			      add_2reg(0xC0, dst_reg, src_reg));
 			goto emit_cond_jmp;
 
 		case BPF_JMP | BPF_JSET | BPF_K:
-			/* test a_reg, imm32 */
-			EMIT1(add_1mod(0x48, a_reg));
-			EMIT2_off32(0xF7, add_1reg(0xC0, a_reg), K);
+			/* test dst_reg, imm32 */
+			EMIT1(add_1mod(0x48, dst_reg));
+			EMIT2_off32(0xF7, add_1reg(0xC0, dst_reg), imm32);
 			goto emit_cond_jmp;
 
 		case BPF_JMP | BPF_JEQ | BPF_K:
@@ -705,13 +705,13 @@ xadd:			if (is_imm8(insn->off))
 		case BPF_JMP | BPF_JGE | BPF_K:
 		case BPF_JMP | BPF_JSGT | BPF_K:
 		case BPF_JMP | BPF_JSGE | BPF_K:
-			/* cmp a_reg, imm8/32 */
-			EMIT1(add_1mod(0x48, a_reg));
+			/* cmp dst_reg, imm8/32 */
+			EMIT1(add_1mod(0x48, dst_reg));
 
-			if (is_imm8(K))
-				EMIT3(0x83, add_1reg(0xF8, a_reg), K);
+			if (is_imm8(imm32))
+				EMIT3(0x83, add_1reg(0xF8, dst_reg), imm32);
 			else
-				EMIT2_off32(0x81, add_1reg(0xF8, a_reg), K);
+				EMIT2_off32(0x81, add_1reg(0xF8, dst_reg), imm32);
 
 emit_cond_jmp:		/* convert BPF opcode to x86 */
 			switch (BPF_OP(insn->code)) {
@@ -773,27 +773,27 @@ emit_jmp:
 			func = sk_load_word;
 			goto common_load;
 		case BPF_LD | BPF_ABS | BPF_W:
-			func = CHOOSE_LOAD_FUNC(K, sk_load_word);
+			func = CHOOSE_LOAD_FUNC(imm32, sk_load_word);
 common_load:		ctx->seen_ld_abs = true;
 			jmp_offset = func - (image + addrs[i]);
 			if (!func || !is_simm32(jmp_offset)) {
 				pr_err("unsupported bpf func %d addr %p image %p\n",
-				       K, func, image);
+				       imm32, func, image);
 				return -EINVAL;
 			}
 			if (BPF_MODE(insn->code) == BPF_ABS) {
 				/* mov %esi, imm32 */
-				EMIT1_off32(0xBE, K);
+				EMIT1_off32(0xBE, imm32);
 			} else {
-				/* mov %rsi, x_reg */
-				EMIT_mov(BPF_REG_2, x_reg);
-				if (K) {
-					if (is_imm8(K))
+				/* mov %rsi, src_reg */
+				EMIT_mov(BPF_REG_2, src_reg);
+				if (imm32) {
+					if (is_imm8(imm32))
 						/* add %esi, imm8 */
-						EMIT3(0x83, 0xC6, K);
+						EMIT3(0x83, 0xC6, imm32);
 					else
 						/* add %esi, imm32 */
-						EMIT2_off32(0x81, 0xC6, K);
+						EMIT2_off32(0x81, 0xC6, imm32);
 				}
 			}
 			/* skb pointer is in R6 (%rbx), it will be copied into
@@ -808,13 +808,13 @@ common_load:		ctx->seen_ld_abs = true;
 			func = sk_load_half;
 			goto common_load;
 		case BPF_LD | BPF_ABS | BPF_H:
-			func = CHOOSE_LOAD_FUNC(K, sk_load_half);
+			func = CHOOSE_LOAD_FUNC(imm32, sk_load_half);
 			goto common_load;
 		case BPF_LD | BPF_IND | BPF_B:
 			func = sk_load_byte;
 			goto common_load;
 		case BPF_LD | BPF_ABS | BPF_B:
-			func = CHOOSE_LOAD_FUNC(K, sk_load_byte);
+			func = CHOOSE_LOAD_FUNC(imm32, sk_load_byte);
 			goto common_load;
 
 		case BPF_JMP | BPF_EXIT:
diff --git a/include/linux/filter.h b/include/linux/filter.h
index f0c2ad43b4af..a7e3c48d73a7 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -78,161 +78,173 @@ enum {
 
 /* Helper macros for filter block array initializers. */
 
-/* ALU ops on registers, bpf_add|sub|...: A += X */
+/* ALU ops on registers, bpf_add|sub|...: dst_reg += src_reg */
 
-#define BPF_ALU64_REG(OP, A, X)					\
+#define BPF_ALU64_REG(OP, DST, SRC)				\
 	((struct sock_filter_int) {				\
 		.code  = BPF_ALU64 | BPF_OP(OP) | BPF_X,	\
-		.a_reg = A,					\
-		.x_reg = X,					\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
 		.off   = 0,					\
 		.imm   = 0 })
 
-#define BPF_ALU32_REG(OP, A, X)					\
+#define BPF_ALU32_REG(OP, DST, SRC)				\
 	((struct sock_filter_int) {				\
 		.code  = BPF_ALU | BPF_OP(OP) | BPF_X,		\
-		.a_reg = A,					\
-		.x_reg = X,					\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
 		.off   = 0,					\
 		.imm   = 0 })
 
-/* ALU ops on immediates, bpf_add|sub|...: A += IMM */
+/* ALU ops on immediates, bpf_add|sub|...: dst_reg += imm32 */
 
-#define BPF_ALU64_IMM(OP, A, IMM)				\
+#define BPF_ALU64_IMM(OP, DST, IMM)				\
 	((struct sock_filter_int) {				\
 		.code  = BPF_ALU64 | BPF_OP(OP) | BPF_K,	\
-		.a_reg = A,					\
-		.x_reg = 0,					\
+		.dst_reg = DST,					\
+		.src_reg = 0,					\
 		.off   = 0,					\
 		.imm   = IMM })
 
-#define BPF_ALU32_IMM(OP, A, IMM)				\
+#define BPF_ALU32_IMM(OP, DST, IMM)				\
 	((struct sock_filter_int) {				\
 		.code  = BPF_ALU | BPF_OP(OP) | BPF_K,		\
-		.a_reg = A,					\
-		.x_reg = 0,					\
+		.dst_reg = DST,					\
+		.src_reg = 0,					\
 		.off   = 0,					\
 		.imm   = IMM })
 
 /* Endianess conversion, cpu_to_{l,b}e(), {l,b}e_to_cpu() */
 
-#define BPF_ENDIAN(TYPE, A, LEN)				\
+#define BPF_ENDIAN(TYPE, DST, LEN)				\
 	((struct sock_filter_int) {				\
 		.code  = BPF_ALU | BPF_END | BPF_SRC(TYPE),	\
-		.a_reg = A,					\
-		.x_reg = 0,					\
+		.dst_reg = DST,					\
+		.src_reg = 0,					\
 		.off   = 0,					\
 		.imm   = LEN })
 
-/* Short form of mov, A = X */
+/* Short form of mov, dst_reg = src_reg */
 
-#define BPF_MOV64_REG(A, X)					\
+#define BPF_MOV64_REG(DST, SRC)					\
 	((struct sock_filter_int) {				\
 		.code  = BPF_ALU64 | BPF_MOV | BPF_X,		\
-		.a_reg = A,					\
-		.x_reg = X,					\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
 		.off   = 0,					\
 		.imm   = 0 })
 
-#define BPF_MOV32_REG(A, X)					\
+#define BPF_MOV32_REG(DST, SRC)					\
 	((struct sock_filter_int) {				\
 		.code  = BPF_ALU | BPF_MOV | BPF_X,		\
-		.a_reg = A,					\
-		.x_reg = X,					\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
 		.off   = 0,					\
 		.imm   = 0 })
 
-/* Short form of mov, A = IMM */
+/* Short form of mov, dst_reg = imm32 */
 
-#define BPF_MOV64_IMM(A, IMM)					\
+#define BPF_MOV64_IMM(DST, IMM)					\
 	((struct sock_filter_int) {				\
 		.code  = BPF_ALU64 | BPF_MOV | BPF_K,		\
-		.a_reg = A,					\
-		.x_reg = 0,					\
+		.dst_reg = DST,					\
+		.src_reg = 0,					\
 		.off   = 0,					\
 		.imm   = IMM })
 
-#define BPF_MOV32_IMM(A, IMM)					\
+#define BPF_MOV32_IMM(DST, IMM)					\
 	((struct sock_filter_int) {				\
 		.code  = BPF_ALU | BPF_MOV | BPF_K,		\
-		.a_reg = A,					\
-		.x_reg = 0,					\
+		.dst_reg = DST,					\
+		.src_reg = 0,					\
 		.off   = 0,					\
 		.imm   = IMM })
 
-/* Short form of mov based on type, BPF_X: A = X,  BPF_K: A = IMM */
+/* Short form of mov based on type, BPF_X: dst_reg = src_reg, BPF_K: dst_reg = imm32 */
 
-#define BPF_MOV64_RAW(TYPE, A, X, IMM)				\
+#define BPF_MOV64_RAW(TYPE, DST, SRC, IMM)			\
 	((struct sock_filter_int) {				\
 		.code  = BPF_ALU64 | BPF_MOV | BPF_SRC(TYPE),	\
-		.a_reg = A,					\
-		.x_reg = X,					\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
 		.off   = 0,					\
 		.imm   = IMM })
 
-#define BPF_MOV32_RAW(TYPE, A, X, IMM)				\
+#define BPF_MOV32_RAW(TYPE, DST, SRC, IMM)			\
 	((struct sock_filter_int) {				\
 		.code  = BPF_ALU | BPF_MOV | BPF_SRC(TYPE),	\
-		.a_reg = A,					\
-		.x_reg = X,					\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
 		.off   = 0,					\
 		.imm   = IMM })
 
-/* Direct packet access, R0 = *(uint *) (skb->data + OFF) */
+/* Direct packet access, R0 = *(uint *) (skb->data + imm32) */
 
-#define BPF_LD_ABS(SIZE, OFF)					\
+#define BPF_LD_ABS(SIZE, IMM)					\
 	((struct sock_filter_int) {				\
 		.code  = BPF_LD | BPF_SIZE(SIZE) | BPF_ABS,	\
-		.a_reg = 0,					\
-		.x_reg = 0,					\
+		.dst_reg = 0,					\
+		.src_reg = 0,					\
 		.off   = 0,					\
-		.imm   = OFF })
+		.imm   = IMM })
 
-/* Indirect packet access, R0 = *(uint *) (skb->data + X + OFF) */
+/* Indirect packet access, R0 = *(uint *) (skb->data + src_reg + imm32) */
 
-#define BPF_LD_IND(SIZE, X, OFF)				\
+#define BPF_LD_IND(SIZE, SRC, IMM)				\
 	((struct sock_filter_int) {				\
 		.code  = BPF_LD | BPF_SIZE(SIZE) | BPF_IND,	\
-		.a_reg = 0,					\
-		.x_reg = X,					\
+		.dst_reg = 0,					\
+		.src_reg = SRC,					\
 		.off   = 0,					\
-		.imm   = OFF })
+		.imm   = IMM })
 
-/* Memory store, A = *(uint *) (X + OFF), and vice versa */
+/* Memory load, dst_reg = *(uint *) (src_reg + off16) */
 
-#define BPF_LDX_MEM(SIZE, A, X, OFF)				\
+#define BPF_LDX_MEM(SIZE, DST, SRC, OFF)			\
 	((struct sock_filter_int) {				\
 		.code  = BPF_LDX | BPF_SIZE(SIZE) | BPF_MEM,	\
-		.a_reg = A,					\
-		.x_reg = X,					\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
 		.off   = OFF,					\
 		.imm   = 0 })
 
-#define BPF_STX_MEM(SIZE, A, X, OFF)				\
+/* Memory store, *(uint *) (dst_reg + off16) = src_reg */
+
+#define BPF_STX_MEM(SIZE, DST, SRC, OFF)			\
 	((struct sock_filter_int) {				\
 		.code  = BPF_STX | BPF_SIZE(SIZE) | BPF_MEM,	\
-		.a_reg = A,					\
-		.x_reg = X,					\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
 		.off   = OFF,					\
 		.imm   = 0 })
 
-/* Conditional jumps against registers, if (A 'op' X) goto pc + OFF */
+/* Memory store, *(uint *) (dst_reg + off16) = imm32 */
+
+#define BPF_ST_MEM(SIZE, DST, OFF, IMM)				\
+	((struct sock_filter_int) {				\
+		.code  = BPF_ST | BPF_SIZE(SIZE) | BPF_MEM,	\
+		.dst_reg = DST,					\
+		.src_reg = 0,					\
+		.off   = OFF,					\
+		.imm   = IMM })
+
+/* Conditional jumps against registers, if (dst_reg 'op' src_reg) goto pc + off16 */
 
-#define BPF_JMP_REG(OP, A, X, OFF)				\
+#define BPF_JMP_REG(OP, DST, SRC, OFF)				\
 	((struct sock_filter_int) {				\
 		.code  = BPF_JMP | BPF_OP(OP) | BPF_X,		\
-		.a_reg = A,					\
-		.x_reg = X,					\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
 		.off   = OFF,					\
 		.imm   = 0 })
 
-/* Conditional jumps against immediates, if (A 'op' IMM) goto pc + OFF */
+/* Conditional jumps against immediates, if (dst_reg 'op' imm32) goto pc + off16 */
 
-#define BPF_JMP_IMM(OP, A, IMM, OFF)				\
+#define BPF_JMP_IMM(OP, DST, IMM, OFF)				\
 	((struct sock_filter_int) {				\
 		.code  = BPF_JMP | BPF_OP(OP) | BPF_K,		\
-		.a_reg = A,					\
-		.x_reg = 0,					\
+		.dst_reg = DST,					\
+		.src_reg = 0,					\
 		.off   = OFF,					\
 		.imm   = IMM })
 
@@ -241,18 +253,18 @@ enum {
 #define BPF_EMIT_CALL(FUNC)					\
 	((struct sock_filter_int) {				\
 		.code  = BPF_JMP | BPF_CALL,			\
-		.a_reg = 0,					\
-		.x_reg = 0,					\
+		.dst_reg = 0,					\
+		.src_reg = 0,					\
 		.off   = 0,					\
 		.imm   = ((FUNC) - __bpf_call_base) })
 
 /* Raw code statement block */
 
-#define BPF_RAW_INSN(CODE, A, X, OFF, IMM)			\
+#define BPF_RAW_INSN(CODE, DST, SRC, OFF, IMM)			\
 	((struct sock_filter_int) {				\
 		.code  = CODE,					\
-		.a_reg = A,					\
-		.x_reg = X,					\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
 		.off   = OFF,					\
 		.imm   = IMM })
 
@@ -261,8 +273,8 @@ enum {
 #define BPF_EXIT_INSN()						\
 	((struct sock_filter_int) {				\
 		.code  = BPF_JMP | BPF_EXIT,			\
-		.a_reg = 0,					\
-		.x_reg = 0,					\
+		.dst_reg = 0,					\
+		.src_reg = 0,					\
 		.off   = 0,					\
 		.imm   = 0 })
 
@@ -287,8 +299,8 @@ enum {
 
 struct sock_filter_int {
 	__u8	code;		/* opcode */
-	__u8	a_reg:4;	/* dest register */
-	__u8	x_reg:4;	/* source register */
+	__u8	dst_reg:4;	/* dest register */
+	__u8	src_reg:4;	/* source register */
 	__s16	off;		/* signed offset */
 	__s32	imm;		/* signed immediate constant */
 };
diff --git a/net/core/filter.c b/net/core/filter.c
index 6bd2e350e751..b3f21751b238 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -59,12 +59,12 @@
 #define BPF_R10	regs[BPF_REG_10]
 
 /* Named registers */
-#define A	regs[insn->a_reg]
-#define X	regs[insn->x_reg]
+#define DST	regs[insn->dst_reg]
+#define SRC	regs[insn->src_reg]
 #define FP	regs[BPF_REG_FP]
 #define ARG1	regs[BPF_REG_ARG1]
 #define CTX	regs[BPF_REG_CTX]
-#define K	insn->imm
+#define IMM	insn->imm
 
 /* No hurry in this branch
  *
@@ -264,7 +264,7 @@ static unsigned int __sk_run_filter(void *ctx, const struct sock_filter_int *ins
 	FP = (u64) (unsigned long) &stack[ARRAY_SIZE(stack)];
 	ARG1 = (u64) (unsigned long) ctx;
 
-	/* Register for user BPF programs need to be reset first. */
+	/* Registers used in classic BPF programs need to be reset first. */
 	regs[BPF_REG_A] = 0;
 	regs[BPF_REG_X] = 0;
 
@@ -274,16 +274,16 @@ select_insn:
 	/* ALU */
 #define ALU(OPCODE, OP)			\
 	ALU64_##OPCODE##_X:		\
-		A = A OP X;		\
+		DST = DST OP SRC;	\
 		CONT;			\
 	ALU_##OPCODE##_X:		\
-		A = (u32) A OP (u32) X;	\
+		DST = (u32) DST OP (u32) SRC;	\
 		CONT;			\
 	ALU64_##OPCODE##_K:		\
-		A = A OP K;		\
+		DST = DST OP IMM;		\
 		CONT;			\
 	ALU_##OPCODE##_K:		\
-		A = (u32) A OP (u32) K;	\
+		DST = (u32) DST OP (u32) IMM;	\
 		CONT;
 
 	ALU(ADD,  +)
@@ -296,92 +296,92 @@ select_insn:
 	ALU(MUL,  *)
 #undef ALU
 	ALU_NEG:
-		A = (u32) -A;
+		DST = (u32) -DST;
 		CONT;
 	ALU64_NEG:
-		A = -A;
+		DST = -DST;
 		CONT;
 	ALU_MOV_X:
-		A = (u32) X;
+		DST = (u32) SRC;
 		CONT;
 	ALU_MOV_K:
-		A = (u32) K;
+		DST = (u32) IMM;
 		CONT;
 	ALU64_MOV_X:
-		A = X;
+		DST = SRC;
 		CONT;
 	ALU64_MOV_K:
-		A = K;
+		DST = IMM;
 		CONT;
 	ALU64_ARSH_X:
-		(*(s64 *) &A) >>= X;
+		(*(s64 *) &DST) >>= SRC;
 		CONT;
 	ALU64_ARSH_K:
-		(*(s64 *) &A) >>= K;
+		(*(s64 *) &DST) >>= IMM;
 		CONT;
 	ALU64_MOD_X:
-		if (unlikely(X == 0))
+		if (unlikely(SRC == 0))
 			return 0;
-		tmp = A;
-		A = do_div(tmp, X);
+		tmp = DST;
+		DST = do_div(tmp, SRC);
 		CONT;
 	ALU_MOD_X:
-		if (unlikely(X == 0))
+		if (unlikely(SRC == 0))
 			return 0;
-		tmp = (u32) A;
-		A = do_div(tmp, (u32) X);
+		tmp = (u32) DST;
+		DST = do_div(tmp, (u32) SRC);
 		CONT;
 	ALU64_MOD_K:
-		tmp = A;
-		A = do_div(tmp, K);
+		tmp = DST;
+		DST = do_div(tmp, IMM);
 		CONT;
 	ALU_MOD_K:
-		tmp = (u32) A;
-		A = do_div(tmp, (u32) K);
+		tmp = (u32) DST;
+		DST = do_div(tmp, (u32) IMM);
 		CONT;
 	ALU64_DIV_X:
-		if (unlikely(X == 0))
+		if (unlikely(SRC == 0))
 			return 0;
-		do_div(A, X);
+		do_div(DST, SRC);
 		CONT;
 	ALU_DIV_X:
-		if (unlikely(X == 0))
+		if (unlikely(SRC == 0))
 			return 0;
-		tmp = (u32) A;
-		do_div(tmp, (u32) X);
-		A = (u32) tmp;
+		tmp = (u32) DST;
+		do_div(tmp, (u32) SRC);
+		DST = (u32) tmp;
 		CONT;
 	ALU64_DIV_K:
-		do_div(A, K);
+		do_div(DST, IMM);
 		CONT;
 	ALU_DIV_K:
-		tmp = (u32) A;
-		do_div(tmp, (u32) K);
-		A = (u32) tmp;
+		tmp = (u32) DST;
+		do_div(tmp, (u32) IMM);
+		DST = (u32) tmp;
 		CONT;
 	ALU_END_TO_BE:
-		switch (K) {
+		switch (IMM) {
 		case 16:
-			A = (__force u16) cpu_to_be16(A);
+			DST = (__force u16) cpu_to_be16(DST);
 			break;
 		case 32:
-			A = (__force u32) cpu_to_be32(A);
+			DST = (__force u32) cpu_to_be32(DST);
 			break;
 		case 64:
-			A = (__force u64) cpu_to_be64(A);
+			DST = (__force u64) cpu_to_be64(DST);
 			break;
 		}
 		CONT;
 	ALU_END_TO_LE:
-		switch (K) {
+		switch (IMM) {
 		case 16:
-			A = (__force u16) cpu_to_le16(A);
+			DST = (__force u16) cpu_to_le16(DST);
 			break;
 		case 32:
-			A = (__force u32) cpu_to_le32(A);
+			DST = (__force u32) cpu_to_le32(DST);
 			break;
 		case 64:
-			A = (__force u64) cpu_to_le64(A);
+			DST = (__force u64) cpu_to_le64(DST);
 			break;
 		}
 		CONT;
@@ -401,85 +401,85 @@ select_insn:
 		insn += insn->off;
 		CONT;
 	JMP_JEQ_X:
-		if (A == X) {
+		if (DST == SRC) {
 			insn += insn->off;
 			CONT_JMP;
 		}
 		CONT;
 	JMP_JEQ_K:
-		if (A == K) {
+		if (DST == IMM) {
 			insn += insn->off;
 			CONT_JMP;
 		}
 		CONT;
 	JMP_JNE_X:
-		if (A != X) {
+		if (DST != SRC) {
 			insn += insn->off;
 			CONT_JMP;
 		}
 		CONT;
 	JMP_JNE_K:
-		if (A != K) {
+		if (DST != IMM) {
 			insn += insn->off;
 			CONT_JMP;
 		}
 		CONT;
 	JMP_JGT_X:
-		if (A > X) {
+		if (DST > SRC) {
 			insn += insn->off;
 			CONT_JMP;
 		}
 		CONT;
 	JMP_JGT_K:
-		if (A > K) {
+		if (DST > IMM) {
 			insn += insn->off;
 			CONT_JMP;
 		}
 		CONT;
 	JMP_JGE_X:
-		if (A >= X) {
+		if (DST >= SRC) {
 			insn += insn->off;
 			CONT_JMP;
 		}
 		CONT;
 	JMP_JGE_K:
-		if (A >= K) {
+		if (DST >= IMM) {
 			insn += insn->off;
 			CONT_JMP;
 		}
 		CONT;
 	JMP_JSGT_X:
-		if (((s64) A) > ((s64) X)) {
+		if (((s64) DST) > ((s64) SRC)) {
 			insn += insn->off;
 			CONT_JMP;
 		}
 		CONT;
 	JMP_JSGT_K:
-		if (((s64) A) > ((s64) K)) {
+		if (((s64) DST) > ((s64) IMM)) {
 			insn += insn->off;
 			CONT_JMP;
 		}
 		CONT;
 	JMP_JSGE_X:
-		if (((s64) A) >= ((s64) X)) {
+		if (((s64) DST) >= ((s64) SRC)) {
 			insn += insn->off;
 			CONT_JMP;
 		}
 		CONT;
 	JMP_JSGE_K:
-		if (((s64) A) >= ((s64) K)) {
+		if (((s64) DST) >= ((s64) IMM)) {
 			insn += insn->off;
 			CONT_JMP;
 		}
 		CONT;
 	JMP_JSET_X:
-		if (A & X) {
+		if (DST & SRC) {
 			insn += insn->off;
 			CONT_JMP;
 		}
 		CONT;
 	JMP_JSET_K:
-		if (A & K) {
+		if (DST & IMM) {
 			insn += insn->off;
 			CONT_JMP;
 		}
@@ -488,15 +488,15 @@ select_insn:
 		return BPF_R0;
 
 	/* STX and ST and LDX*/
-#define LDST(SIZEOP, SIZE)					\
-	STX_MEM_##SIZEOP:					\
-		*(SIZE *)(unsigned long) (A + insn->off) = X;	\
-		CONT;						\
-	ST_MEM_##SIZEOP:					\
-		*(SIZE *)(unsigned long) (A + insn->off) = K;	\
-		CONT;						\
-	LDX_MEM_##SIZEOP:					\
-		A = *(SIZE *)(unsigned long) (X + insn->off);	\
+#define LDST(SIZEOP, SIZE)						\
+	STX_MEM_##SIZEOP:						\
+		*(SIZE *)(unsigned long) (DST + insn->off) = SRC;	\
+		CONT;							\
+	ST_MEM_##SIZEOP:						\
+		*(SIZE *)(unsigned long) (DST + insn->off) = IMM;	\
+		CONT;							\
+	LDX_MEM_##SIZEOP:						\
+		DST = *(SIZE *)(unsigned long) (SRC + insn->off);	\
 		CONT;
 
 	LDST(B,   u8)
@@ -504,16 +504,16 @@ select_insn:
 	LDST(W,  u32)
 	LDST(DW, u64)
 #undef LDST
-	STX_XADD_W: /* lock xadd *(u32 *)(A + insn->off) += X */
-		atomic_add((u32) X, (atomic_t *)(unsigned long)
-			   (A + insn->off));
+	STX_XADD_W: /* lock xadd *(u32 *)(dst_reg + off16) += src_reg */
+		atomic_add((u32) SRC, (atomic_t *)(unsigned long)
+			   (DST + insn->off));
 		CONT;
-	STX_XADD_DW: /* lock xadd *(u64 *)(A + insn->off) += X */
-		atomic64_add((u64) X, (atomic64_t *)(unsigned long)
-			     (A + insn->off));
+	STX_XADD_DW: /* lock xadd *(u64 *)(dst_reg + off16) += src_reg */
+		atomic64_add((u64) SRC, (atomic64_t *)(unsigned long)
+			     (DST + insn->off));
 		CONT;
-	LD_ABS_W: /* BPF_R0 = ntohl(*(u32 *) (skb->data + K)) */
-		off = K;
+	LD_ABS_W: /* BPF_R0 = ntohl(*(u32 *) (skb->data + imm32)) */
+		off = IMM;
 load_word:
 		/* BPF_LD + BPD_ABS and BPF_LD + BPF_IND insns are
 		 * only appearing in the programs where ctx ==
@@ -527,51 +527,51 @@ load_word:
 		 * BPF_R6-BPF_R9, and store return value into BPF_R0.
 		 *
 		 * Implicit input:
-		 *   ctx
+		 *   ctx == skb == BPF_R6 == CTX
 		 *
 		 * Explicit input:
-		 *   X == any register
-		 *   K == 32-bit immediate
+		 *   SRC == any register
+		 *   IMM == 32-bit immediate
 		 *
 		 * Output:
 		 *   BPF_R0 - 8/16/32-bit skb data converted to cpu endianness
 		 */
 
-		ptr = load_pointer((struct sk_buff *) ctx, off, 4, &tmp);
+		ptr = load_pointer((struct sk_buff *) CTX, off, 4, &tmp);
 		if (likely(ptr != NULL)) {
 			BPF_R0 = get_unaligned_be32(ptr);
 			CONT;
 		}
 
 		return 0;
-	LD_ABS_H: /* BPF_R0 = ntohs(*(u16 *) (skb->data + K)) */
-		off = K;
+	LD_ABS_H: /* BPF_R0 = ntohs(*(u16 *) (skb->data + imm32)) */
+		off = IMM;
 load_half:
-		ptr = load_pointer((struct sk_buff *) ctx, off, 2, &tmp);
+		ptr = load_pointer((struct sk_buff *) CTX, off, 2, &tmp);
 		if (likely(ptr != NULL)) {
 			BPF_R0 = get_unaligned_be16(ptr);
 			CONT;
 		}
 
 		return 0;
-	LD_ABS_B: /* BPF_R0 = *(u8 *) (ctx + K) */
-		off = K;
+	LD_ABS_B: /* BPF_R0 = *(u8 *) (skb->data + imm32) */
+		off = IMM;
 load_byte:
-		ptr = load_pointer((struct sk_buff *) ctx, off, 1, &tmp);
+		ptr = load_pointer((struct sk_buff *) CTX, off, 1, &tmp);
 		if (likely(ptr != NULL)) {
 			BPF_R0 = *(u8 *)ptr;
 			CONT;
 		}
 
 		return 0;
-	LD_IND_W: /* BPF_R0 = ntohl(*(u32 *) (skb->data + X + K)) */
-		off = K + X;
+	LD_IND_W: /* BPF_R0 = ntohl(*(u32 *) (skb->data + src_reg + imm32)) */
+		off = IMM + SRC;
 		goto load_word;
-	LD_IND_H: /* BPF_R0 = ntohs(*(u16 *) (skb->data + X + K)) */
-		off = K + X;
+	LD_IND_H: /* BPF_R0 = ntohs(*(u16 *) (skb->data + src_reg + imm32)) */
+		off = IMM + SRC;
 		goto load_half;
-	LD_IND_B: /* BPF_R0 = *(u8 *) (skb->data + X + K) */
-		off = K + X;
+	LD_IND_B: /* BPF_R0 = *(u8 *) (skb->data + src_reg + imm32) */
+		off = IMM + SRC;
 		goto load_byte;
 
 	default_label:
@@ -675,7 +675,7 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
 	case SKF_AD_OFF + SKF_AD_PROTOCOL:
 		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, protocol) != 2);
 
-		/* A = *(u16 *) (ctx + offsetof(protocol)) */
+		/* A = *(u16 *) (CTX + offsetof(protocol)) */
 		*insn++ = BPF_LDX_MEM(BPF_H, BPF_REG_A, BPF_REG_CTX,
 				      offsetof(struct sk_buff, protocol));
 		/* A = ntohs(A) [emitting a nop or swap16] */
@@ -741,7 +741,7 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
 		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, vlan_tci) != 2);
 		BUILD_BUG_ON(VLAN_TAG_PRESENT != 0x1000);
 
-		/* A = *(u16 *) (ctx + offsetof(vlan_tci)) */
+		/* A = *(u16 *) (CTX + offsetof(vlan_tci)) */
 		*insn++ = BPF_LDX_MEM(BPF_H, BPF_REG_A, BPF_REG_CTX,
 				      offsetof(struct sk_buff, vlan_tci));
 		if (fp->k == SKF_AD_OFF + SKF_AD_VLAN_TAG) {
@@ -760,13 +760,13 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
 	case SKF_AD_OFF + SKF_AD_NLATTR_NEST:
 	case SKF_AD_OFF + SKF_AD_CPU:
 	case SKF_AD_OFF + SKF_AD_RANDOM:
-		/* arg1 = ctx */
+		/* arg1 = CTX */
 		*insn++ = BPF_MOV64_REG(BPF_REG_ARG1, BPF_REG_CTX);
 		/* arg2 = A */
 		*insn++ = BPF_MOV64_REG(BPF_REG_ARG2, BPF_REG_A);
 		/* arg3 = X */
 		*insn++ = BPF_MOV64_REG(BPF_REG_ARG3, BPF_REG_X);
-		/* Emit call(ctx, arg2=A, arg3=X) */
+		/* Emit call(arg1=CTX, arg2=A, arg3=X) */
 		switch (fp->k) {
 		case SKF_AD_OFF + SKF_AD_PAY_OFFSET:
 			*insn = BPF_EMIT_CALL(__skb_get_pay_offset);
@@ -941,12 +941,12 @@ do_pass:
 				 */
 				*insn++ = BPF_MOV32_IMM(BPF_REG_TMP, fp->k);
 
-				insn->a_reg = BPF_REG_A;
-				insn->x_reg = BPF_REG_TMP;
+				insn->dst_reg = BPF_REG_A;
+				insn->src_reg = BPF_REG_TMP;
 				bpf_src = BPF_X;
 			} else {
-				insn->a_reg = BPF_REG_A;
-				insn->x_reg = BPF_REG_X;
+				insn->dst_reg = BPF_REG_A;
+				insn->src_reg = BPF_REG_X;
 				insn->imm = fp->k;
 				bpf_src = BPF_SRC(fp->code);
 			}
-- 
1.7.9.5
