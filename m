From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/9] bpf, x86: implement jiting of BPF_J{LT,LE,SLT,SLE}
Date: Wed,  9 Aug 2017 12:23:54 +0200
Message-ID: <221f42aa47139be452f3a2b26d41ac3406683516.1502272924.git.daniel@iogearbox.net>
References: <cover.1502272924.git.daniel@iogearbox.net>
Cc: ast@fb.com, holzheu@linux.vnet.ibm.com,
        naveen.n.rao@linux.vnet.ibm.com, jakub.kicinski@netronome.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58227 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752098AbdHIKYT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 06:24:19 -0400
In-Reply-To: <cover.1502272924.git.daniel@iogearbox.net>
In-Reply-To: <cover.1502272924.git.daniel@iogearbox.net>
References: <cover.1502272924.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This work implements jiting of BPF_J{LT,LE,SLT,SLE} instructions
with BPF_X/BPF_K variants for the x86_64 eBPF JIT.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 arch/x86/net/bpf_jit_comp.c | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index e1324f2..8194696 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -94,7 +94,9 @@ static int bpf_size_to_x86_bytes(int bpf_size)
 #define X86_JNE 0x75
 #define X86_JBE 0x76
 #define X86_JA  0x77
+#define X86_JL  0x7C
 #define X86_JGE 0x7D
+#define X86_JLE 0x7E
 #define X86_JG  0x7F
 
 static void bpf_flush_icache(void *start, void *end)
@@ -888,9 +890,13 @@ static int do_jit(struct bpf_prog *bpf_prog, int *addrs, u8 *image,
 		case BPF_JMP | BPF_JEQ | BPF_X:
 		case BPF_JMP | BPF_JNE | BPF_X:
 		case BPF_JMP | BPF_JGT | BPF_X:
+		case BPF_JMP | BPF_JLT | BPF_X:
 		case BPF_JMP | BPF_JGE | BPF_X:
+		case BPF_JMP | BPF_JLE | BPF_X:
 		case BPF_JMP | BPF_JSGT | BPF_X:
+		case BPF_JMP | BPF_JSLT | BPF_X:
 		case BPF_JMP | BPF_JSGE | BPF_X:
+		case BPF_JMP | BPF_JSLE | BPF_X:
 			/* cmp dst_reg, src_reg */
 			EMIT3(add_2mod(0x48, dst_reg, src_reg), 0x39,
 			      add_2reg(0xC0, dst_reg, src_reg));
@@ -911,9 +917,13 @@ static int do_jit(struct bpf_prog *bpf_prog, int *addrs, u8 *image,
 		case BPF_JMP | BPF_JEQ | BPF_K:
 		case BPF_JMP | BPF_JNE | BPF_K:
 		case BPF_JMP | BPF_JGT | BPF_K:
+		case BPF_JMP | BPF_JLT | BPF_K:
 		case BPF_JMP | BPF_JGE | BPF_K:
+		case BPF_JMP | BPF_JLE | BPF_K:
 		case BPF_JMP | BPF_JSGT | BPF_K:
+		case BPF_JMP | BPF_JSLT | BPF_K:
 		case BPF_JMP | BPF_JSGE | BPF_K:
+		case BPF_JMP | BPF_JSLE | BPF_K:
 			/* cmp dst_reg, imm8/32 */
 			EMIT1(add_1mod(0x48, dst_reg));
 
@@ -935,18 +945,34 @@ static int do_jit(struct bpf_prog *bpf_prog, int *addrs, u8 *image,
 				/* GT is unsigned '>', JA in x86 */
 				jmp_cond = X86_JA;
 				break;
+			case BPF_JLT:
+				/* LT is unsigned '<', JB in x86 */
+				jmp_cond = X86_JB;
+				break;
 			case BPF_JGE:
 				/* GE is unsigned '>=', JAE in x86 */
 				jmp_cond = X86_JAE;
 				break;
+			case BPF_JLE:
+				/* LE is unsigned '<=', JBE in x86 */
+				jmp_cond = X86_JBE;
+				break;
 			case BPF_JSGT:
 				/* signed '>', GT in x86 */
 				jmp_cond = X86_JG;
 				break;
+			case BPF_JSLT:
+				/* signed '<', LT in x86 */
+				jmp_cond = X86_JL;
+				break;
 			case BPF_JSGE:
 				/* signed '>=', GE in x86 */
 				jmp_cond = X86_JGE;
 				break;
+			case BPF_JSLE:
+				/* signed '<=', LE in x86 */
+				jmp_cond = X86_JLE;
+				break;
 			default: /* to silence gcc warning */
 				return -EFAULT;
 			}
-- 
1.9.3
