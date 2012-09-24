From: Daniel Borkmann <dxchgb@gmail.com>
Subject: [PATCH net-next] x86: bpf_jit_comp: add XOR instruction for BPF JIT
Date: Mon, 24 Sep 2012 19:34:51 +0200
Message-ID: <20120924173450.GA28969@thinkbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:42773 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755502Ab2IXRe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 13:34:56 -0400
Received: by wibhr14 with SMTP id hr14so5199826wib.1
        for <netdev@vger.kernel.org>; Mon, 24 Sep 2012 10:34:55 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is a follow-up for patch "filter: add XOR instruction for use
with X/K" that implements BPF x86 JIT parts for the BPF XOR operation.

Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
---
 arch/x86/net/bpf_jit_comp.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index 106c578..520d2bd 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -335,9 +335,18 @@ void bpf_jit_compile(struct sk_filter *fp)
 					EMIT1_off32(0x0d, K);	/* or imm32,%eax */
 				break;
 			case BPF_S_ANC_ALU_XOR_X: /* A ^= X; */
+			case BPF_S_ALU_XOR_X:
 				seen |= SEEN_XREG;
 				EMIT2(0x31, 0xd8);		/* xor %ebx,%eax */
 				break;
+			case BPF_S_ALU_XOR_K: /* A ^= K; */
+				if (K == 0)
+					break;
+				if (is_imm8(K))
+					EMIT3(0x83, 0xf0, K);	/* xor imm8,%eax */
+				else
+					EMIT1_off32(0x35, K);	/* xor imm32,%eax */
+				break;
 			case BPF_S_ALU_LSH_X: /* A <<= X; */
 				seen |= SEEN_XREG;
 				EMIT4(0x89, 0xd9, 0xd3, 0xe0);	/* mov %ebx,%ecx; shl %cl,%eax */
