From: Vladimir Murzin <murzin.v@gmail.com>
Subject: [PATCH v2 2/2] ppc: bpf_jit: support MOD operation
Date: Sat, 28 Sep 2013 10:22:01 +0200
Message-ID: <1380356521-3432-2-git-send-email-murzin.v@gmail.com>
References: <1380356521-3432-1-git-send-email-murzin.v@gmail.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	benh@kernel.crashing.org, paulus@samba.org, matt@ozlabs.org,
	edumazet@google.com, dborkman@redhat.com,
	Vladimir Murzin <murzin.v@gmail.com>
To: linuxppc-dev@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:42632 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751855Ab3I1IXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 04:23:40 -0400
Received: by mail-lb0-f177.google.com with SMTP id w7so2977677lbi.36
        for <netdev@vger.kernel.org>; Sat, 28 Sep 2013 01:23:39 -0700 (PDT)
In-Reply-To: <1380356521-3432-1-git-send-email-murzin.v@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit b6069a9570 (filter: add MOD operation) added generic
support for modulus operation in BPF.

This patch brings JIT support for PPC64

Signed-off-by: Vladimir Murzin <murzin.v@gmail.com>
Acked-by: Matt Evans <matt@ozlabs.org>
---
Changelog

v1->v2

Definition for r_scratch2 was moved to header file.

 arch/powerpc/net/bpf_jit.h      |  1 +
 arch/powerpc/net/bpf_jit_comp.c | 20 ++++++++++++++++++++
 2 files changed, 21 insertions(+)

diff --git a/arch/powerpc/net/bpf_jit.h b/arch/powerpc/net/bpf_jit.h
index 8a5dfaf..42a115a 100644
--- a/arch/powerpc/net/bpf_jit.h
+++ b/arch/powerpc/net/bpf_jit.h
@@ -39,6 +39,7 @@
 #define r_X		5
 #define r_addr		6
 #define r_scratch1	7
+#define r_scratch2	8
 #define r_D		14
 #define r_HL		15
 #define r_M		16
diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index bf56e33..cbb2702 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -193,6 +193,26 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
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
+			PPC_LI32(r_scratch2, K);
+			PPC_DIVWU(r_scratch1, r_A, r_scratch2);
+			PPC_MUL(r_scratch1, r_scratch2, r_scratch1);
+			PPC_SUB(r_A, r_A, r_scratch1);
+			break;
 		case BPF_S_ALU_DIV_X: /* A /= X; */
 			ctx->seen |= SEEN_XREG;
 			PPC_CMPWI(r_X, 0);
-- 
1.8.1.5
