From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 4/9] bpf, sparc64: implement jiting of BPF_J{LT,LE,SLT,SLE}
Date: Wed,  9 Aug 2017 12:23:56 +0200
Message-ID: <eba27d241bd5b78e09002614e39e60b618d9146d.1502272924.git.daniel@iogearbox.net>
References: <cover.1502272924.git.daniel@iogearbox.net>
Cc: ast@fb.com, holzheu@linux.vnet.ibm.com,
        naveen.n.rao@linux.vnet.ibm.com, jakub.kicinski@netronome.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58231 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752084AbdHIKYU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 06:24:20 -0400
In-Reply-To: <cover.1502272924.git.daniel@iogearbox.net>
In-Reply-To: <cover.1502272924.git.daniel@iogearbox.net>
References: <cover.1502272924.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This work implements jiting of BPF_J{LT,LE,SLT,SLE} instructions
with BPF_X/BPF_K variants for the sparc64 eBPF JIT.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 arch/sparc/net/bpf_jit_comp_64.c | 34 ++++++++++++++++++++++++++++++++++
 1 file changed, 34 insertions(+)

diff --git a/arch/sparc/net/bpf_jit_comp_64.c b/arch/sparc/net/bpf_jit_comp_64.c
index 8799ae9..c340af7 100644
--- a/arch/sparc/net/bpf_jit_comp_64.c
+++ b/arch/sparc/net/bpf_jit_comp_64.c
@@ -128,6 +128,8 @@ static u32 WDISP10(u32 off)
 
 #define BA		(BRANCH | CONDA)
 #define BG		(BRANCH | CONDG)
+#define BL		(BRANCH | CONDL)
+#define BLE		(BRANCH | CONDLE)
 #define BGU		(BRANCH | CONDGU)
 #define BLEU		(BRANCH | CONDLEU)
 #define BGE		(BRANCH | CONDGE)
@@ -715,9 +717,15 @@ static int emit_compare_and_branch(const u8 code, const u8 dst, u8 src,
 		case BPF_JGT:
 			br_opcode = BGU;
 			break;
+		case BPF_JLT:
+			br_opcode = BLU;
+			break;
 		case BPF_JGE:
 			br_opcode = BGEU;
 			break;
+		case BPF_JLE:
+			br_opcode = BLEU;
+			break;
 		case BPF_JSET:
 		case BPF_JNE:
 			br_opcode = BNE;
@@ -725,9 +733,15 @@ static int emit_compare_and_branch(const u8 code, const u8 dst, u8 src,
 		case BPF_JSGT:
 			br_opcode = BG;
 			break;
+		case BPF_JSLT:
+			br_opcode = BL;
+			break;
 		case BPF_JSGE:
 			br_opcode = BGE;
 			break;
+		case BPF_JSLE:
+			br_opcode = BLE;
+			break;
 		default:
 			/* Make sure we dont leak kernel information to the
 			 * user.
@@ -746,18 +760,30 @@ static int emit_compare_and_branch(const u8 code, const u8 dst, u8 src,
 		case BPF_JGT:
 			cbcond_opcode = CBCONDGU;
 			break;
+		case BPF_JLT:
+			cbcond_opcode = CBCONDLU;
+			break;
 		case BPF_JGE:
 			cbcond_opcode = CBCONDGEU;
 			break;
+		case BPF_JLE:
+			cbcond_opcode = CBCONDLEU;
+			break;
 		case BPF_JNE:
 			cbcond_opcode = CBCONDNE;
 			break;
 		case BPF_JSGT:
 			cbcond_opcode = CBCONDG;
 			break;
+		case BPF_JSLT:
+			cbcond_opcode = CBCONDL;
+			break;
 		case BPF_JSGE:
 			cbcond_opcode = CBCONDGE;
 			break;
+		case BPF_JSLE:
+			cbcond_opcode = CBCONDLE;
+			break;
 		default:
 			/* Make sure we dont leak kernel information to the
 			 * user.
@@ -1176,10 +1202,14 @@ static int build_insn(const struct bpf_insn *insn, struct jit_ctx *ctx)
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
 	case BPF_JMP | BPF_JSET | BPF_X: {
 		int err;
 
@@ -1191,10 +1221,14 @@ static int build_insn(const struct bpf_insn *insn, struct jit_ctx *ctx)
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
 	case BPF_JMP | BPF_JSET | BPF_K: {
 		int err;
 
-- 
1.9.3
