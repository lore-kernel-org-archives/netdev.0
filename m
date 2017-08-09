From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 3/9] bpf, arm64: implement jiting of BPF_J{LT,LE,SLT,SLE}
Date: Thu, 10 Aug 2017 01:39:57 +0200
Message-ID: <48f30467f8543679708b031f7ed018c4ed6be0d5.1502320623.git.daniel@iogearbox.net>
References: <cover.1502320623.git.daniel@iogearbox.net>
Cc: ast@fb.com, holzheu@linux.vnet.ibm.com,
        naveen.n.rao@linux.vnet.ibm.com, jakub.kicinski@netronome.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35690 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752232AbdHIXkO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 19:40:14 -0400
In-Reply-To: <cover.1502320623.git.daniel@iogearbox.net>
In-Reply-To: <cover.1502320623.git.daniel@iogearbox.net>
References: <cover.1502320623.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This work implements jiting of BPF_J{LT,LE,SLT,SLE} instructions
with BPF_X/BPF_K variants for the arm64 eBPF JIT.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 arch/arm64/net/bpf_jit.h      |  4 ++++
 arch/arm64/net/bpf_jit_comp.c | 20 ++++++++++++++++++++
 2 files changed, 24 insertions(+)

diff --git a/arch/arm64/net/bpf_jit.h b/arch/arm64/net/bpf_jit.h
index b02a926..783de51 100644
--- a/arch/arm64/net/bpf_jit.h
+++ b/arch/arm64/net/bpf_jit.h
@@ -44,8 +44,12 @@
 #define A64_COND_NE	AARCH64_INSN_COND_NE /* != */
 #define A64_COND_CS	AARCH64_INSN_COND_CS /* unsigned >= */
 #define A64_COND_HI	AARCH64_INSN_COND_HI /* unsigned > */
+#define A64_COND_LS	AARCH64_INSN_COND_LS /* unsigned <= */
+#define A64_COND_CC	AARCH64_INSN_COND_CC /* unsigned < */
 #define A64_COND_GE	AARCH64_INSN_COND_GE /* signed >= */
 #define A64_COND_GT	AARCH64_INSN_COND_GT /* signed > */
+#define A64_COND_LE	AARCH64_INSN_COND_LE /* signed <= */
+#define A64_COND_LT	AARCH64_INSN_COND_LT /* signed < */
 #define A64_B_(cond, imm19) A64_COND_BRANCH(cond, (imm19) << 2)
 
 /* Unconditional branch (immediate) */
diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
index f32144b..ba38d40 100644
--- a/arch/arm64/net/bpf_jit_comp.c
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -527,10 +527,14 @@ static int build_insn(const struct bpf_insn *insn, struct jit_ctx *ctx)
 	/* IF (dst COND src) JUMP off */
 	case BPF_JMP | BPF_JEQ | BPF_X:
 	case BPF_JMP | BPF_JGT | BPF_X:
+	case BPF_JMP | BPF_JLT | BPF_X:
 	case BPF_JMP | BPF_JGE | BPF_X:
+	case BPF_JMP | BPF_JLE | BPF_X:
 	case BPF_JMP | BPF_JNE | BPF_X:
 	case BPF_JMP | BPF_JSGT | BPF_X:
+	case BPF_JMP | BPF_JSLT | BPF_X:
 	case BPF_JMP | BPF_JSGE | BPF_X:
+	case BPF_JMP | BPF_JSLE | BPF_X:
 		emit(A64_CMP(1, dst, src), ctx);
 emit_cond_jmp:
 		jmp_offset = bpf2a64_offset(i + off, i, ctx);
@@ -542,9 +546,15 @@ static int build_insn(const struct bpf_insn *insn, struct jit_ctx *ctx)
 		case BPF_JGT:
 			jmp_cond = A64_COND_HI;
 			break;
+		case BPF_JLT:
+			jmp_cond = A64_COND_CC;
+			break;
 		case BPF_JGE:
 			jmp_cond = A64_COND_CS;
 			break;
+		case BPF_JLE:
+			jmp_cond = A64_COND_LS;
+			break;
 		case BPF_JSET:
 		case BPF_JNE:
 			jmp_cond = A64_COND_NE;
@@ -552,9 +562,15 @@ static int build_insn(const struct bpf_insn *insn, struct jit_ctx *ctx)
 		case BPF_JSGT:
 			jmp_cond = A64_COND_GT;
 			break;
+		case BPF_JSLT:
+			jmp_cond = A64_COND_LT;
+			break;
 		case BPF_JSGE:
 			jmp_cond = A64_COND_GE;
 			break;
+		case BPF_JSLE:
+			jmp_cond = A64_COND_LE;
+			break;
 		default:
 			return -EFAULT;
 		}
@@ -566,10 +582,14 @@ static int build_insn(const struct bpf_insn *insn, struct jit_ctx *ctx)
 	/* IF (dst COND imm) JUMP off */
 	case BPF_JMP | BPF_JEQ | BPF_K:
 	case BPF_JMP | BPF_JGT | BPF_K:
+	case BPF_JMP | BPF_JLT | BPF_K:
 	case BPF_JMP | BPF_JGE | BPF_K:
+	case BPF_JMP | BPF_JLE | BPF_K:
 	case BPF_JMP | BPF_JNE | BPF_K:
 	case BPF_JMP | BPF_JSGT | BPF_K:
+	case BPF_JMP | BPF_JSLT | BPF_K:
 	case BPF_JMP | BPF_JSGE | BPF_K:
+	case BPF_JMP | BPF_JSLE | BPF_K:
 		emit_a64_mov_i(1, tmp, imm, ctx);
 		emit(A64_CMP(1, dst, tmp), ctx);
 		goto emit_cond_jmp;
-- 
1.9.3
