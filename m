From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 4/5] bpf, x86: detect/optimize loading 0 immediates
Date: Thu, 17 Dec 2015 23:51:56 +0100
Message-ID: <9f39c6c743309353ca414aa7925b74d6230a12e4.1450391511.git.daniel@iogearbox.net>
References: <cover.1450391511.git.daniel@iogearbox.net>
Cc: ast@kernel.org, holzheu@linux.vnet.ibm.com, zlim.lnx@gmail.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53895 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754865AbbLQWwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 17:52:05 -0500
In-Reply-To: <cover.1450391511.git.daniel@iogearbox.net>
In-Reply-To: <cover.1450391511.git.daniel@iogearbox.net>
References: <cover.1450391511.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When sometimes structs or variables need to be initialized/'memset' to 0 in
an eBPF C program, the x86 BPF JIT converts this to use immediates. We can
however save a couple of bytes (f.e. even up to 7 bytes on a single emmission
of BPF_LD | BPF_IMM | BPF_DW) in the image by detecting such case and use xor
on the dst register instead.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 arch/x86/net/bpf_jit_comp.c | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index c080e81..4286f36 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -459,6 +459,18 @@ static int do_jit(struct bpf_prog *bpf_prog, int *addrs, u8 *image,
 			}
 
 		case BPF_ALU | BPF_MOV | BPF_K:
+			/* optimization: if imm32 is zero, use 'xor <dst>,<dst>'
+			 * to save 3 bytes.
+			 */
+			if (imm32 == 0) {
+				if (is_ereg(dst_reg))
+					EMIT1(add_2mod(0x40, dst_reg, dst_reg));
+				b2 = 0x31; /* xor */
+				b3 = 0xC0;
+				EMIT2(b2, add_2reg(b3, dst_reg, dst_reg));
+				break;
+			}
+
 			/* mov %eax, imm32 */
 			if (is_ereg(dst_reg))
 				EMIT1(add_1mod(0x40, dst_reg));
@@ -473,6 +485,20 @@ static int do_jit(struct bpf_prog *bpf_prog, int *addrs, u8 *image,
 				return -EINVAL;
 			}
 
+			/* optimization: if imm64 is zero, use 'xor <dst>,<dst>'
+			 * to save 7 bytes.
+			 */
+			if (insn[0].imm == 0 && insn[1].imm == 0) {
+				b1 = add_2mod(0x48, dst_reg, dst_reg);
+				b2 = 0x31; /* xor */
+				b3 = 0xC0;
+				EMIT3(b1, b2, add_2reg(b3, dst_reg, dst_reg));
+
+				insn++;
+				i++;
+				break;
+			}
+
 			/* movabsq %rax, imm64 */
 			EMIT2(add_1mod(0x48, dst_reg), add_1reg(0xB8, dst_reg));
 			EMIT(insn[0].imm, 4);
-- 
1.9.3
