From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net] x86: bpf_jit: fix FROM_BE16 and FROM_LE16/32 instructions
Date: Mon, 11 May 2015 23:25:16 -0700
Message-ID: <1431411916-6104-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36434 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752369AbbELGZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 02:25:25 -0400
Received: by pabsx10 with SMTP id sx10so134725332pab.3
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 23:25:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FROM_BE16:
'ror %reg, 8' doesn't clear upper bits of the register,
so use additional 'movzwl' insn to zero extend 16 bits into 64

FROM_LE16:
should zero extend lower 16 bits into 64 bit

FROM_LE32:
should zero extend lower 32 bits into 64 bit

Fixes: 89aa075832b0 ("net: sock: allow eBPF programs to be attached to sockets")
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
Though these instructions were implemented incorrectly during
the first eBPF JIT drop:
commit 622582786c9e ("net: filter: x86: internal BPF JIT")
and FROM_BE16 was used by converter from classic to extended,
the coverter used zero-extending 16-bit load from memory
right before FROM_BE16 insn, so classic extension skb->protocol
was not affected.
Therefore it makes sense to backport this fix only till commit
89aa075832b0 (which is above Fixes tag) when eBPF programs became
accessible via sockets.

The bug was found via new exhaustive eBPF testsuite.

 arch/x86/net/bpf_jit_comp.c |   28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 987514396c1e..99f76103c6b7 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -559,6 +559,13 @@ static int do_jit(struct bpf_prog *bpf_prog, int *addrs, u8 *image,
 				if (is_ereg(dst_reg))
 					EMIT1(0x41);
 				EMIT3(0xC1, add_1reg(0xC8, dst_reg), 8);
+
+				/* emit 'movzwl eax, ax' */
+				if (is_ereg(dst_reg))
+					EMIT3(0x45, 0x0F, 0xB7);
+				else
+					EMIT2(0x0F, 0xB7);
+				EMIT1(add_2reg(0xC0, dst_reg, dst_reg));
 				break;
 			case 32:
 				/* emit 'bswap eax' to swap lower 4 bytes */
@@ -577,6 +584,27 @@ static int do_jit(struct bpf_prog *bpf_prog, int *addrs, u8 *image,
 			break;
 
 		case BPF_ALU | BPF_END | BPF_FROM_LE:
+			switch (imm32) {
+			case 16:
+				/* emit 'movzwl eax, ax' to zero extend 16-bit
+				 * into 64 bit
+				 */
+				if (is_ereg(dst_reg))
+					EMIT3(0x45, 0x0F, 0xB7);
+				else
+					EMIT2(0x0F, 0xB7);
+				EMIT1(add_2reg(0xC0, dst_reg, dst_reg));
+				break;
+			case 32:
+				/* emit 'mov eax, eax' to clear upper 32-bits */
+				if (is_ereg(dst_reg))
+					EMIT1(0x45);
+				EMIT2(0x89, add_2reg(0xC0, dst_reg, dst_reg));
+				break;
+			case 64:
+				/* nop */
+				break;
+			}
 			break;
 
 			/* ST: *(u8*)(dst_reg + off) = imm */
-- 
1.7.9.5
