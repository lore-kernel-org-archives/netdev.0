From: Vladimir Murzin <murzin.v@gmail.com>
Subject: [RESEND PATCH 2/2] ppc: bpf_jit: support MOD operation
Date: Sat, 21 Sep 2013 09:25:34 +0200
Message-ID: <1379748334-3313-2-git-send-email-murzin.v@gmail.com>
References: <1379748334-3313-1-git-send-email-murzin.v@gmail.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	benh@kernel.crashing.org, paulus@samba.org, matt@ozlabs.org,
	edumazet@google.com, dborkman@redhat.com,
	Vladimir Murzin <murzin.v@gmail.com>
To: linuxppc-dev@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:57438 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082Ab3IUH1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 03:27:43 -0400
Received: by mail-la0-f41.google.com with SMTP id ec20so1046493lab.14
        for <netdev@vger.kernel.org>; Sat, 21 Sep 2013 00:27:42 -0700 (PDT)
In-Reply-To: <1379748334-3313-1-git-send-email-murzin.v@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit b6069a9570 (filter: add MOD operation) added generic
support for modulus operation in BPF.

This patch brings JIT support for PPC64

Signed-off-by: Vladimir Murzin <murzin.v@gmail.com>
Acked-by: Matt Evans <matt@ozlabs.org>
---
 arch/powerpc/net/bpf_jit_comp.c | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index bf56e33..96f24dc 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -193,6 +193,28 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 				PPC_MUL(r_A, r_A, r_scratch1);
 			}
 			break;
+		case BPF_S_ALU_MOD_X: /* A %= X; */
+			ctx->seen |= SEEN_XREG;
+			PPC_CMPWI(r_X, 0);
+			if (ctx->pc_ret0 != -1) {
+				PPC_BCC(COND_EQ, addrs[ctx->pc_ret0]);
+			} else {
+				PPC_BCC_SHORT(COND_NE, (ctx->idx*4)+12);
+				PPC_LI(r_ret, 0);
+				PPC_JMP(exit_addr);
+			}
+			PPC_DIVWU(r_scratch1, r_A, r_X);
+			PPC_MUL(r_scratch1, r_X, r_scratch1);
+			PPC_SUB(r_A, r_A, r_scratch1);
+			break;
+		case BPF_S_ALU_MOD_K: /* A %= K; */
+#define r_scratch2 (r_scratch1 + 1)
+			PPC_LI32(r_scratch2, K);
+			PPC_DIVWU(r_scratch1, r_A, r_scratch2);
+			PPC_MUL(r_scratch1, r_scratch2, r_scratch1);
+			PPC_SUB(r_A, r_A, r_scratch1);
+#undef r_scratch2
+			break;
 		case BPF_S_ALU_DIV_X: /* A /= X; */
 			ctx->seen |= SEEN_XREG;
 			PPC_CMPWI(r_X, 0);
-- 
1.8.1.5
