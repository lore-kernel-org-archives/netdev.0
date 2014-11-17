From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH net-next] PPC: bpf_jit_comp: Unify BPF_MOD | BPF_X and BPF_DIV | BPF_X
Date: Mon, 17 Nov 2014 23:07:41 +0300
Message-ID: <1416254861-3879-1-git-send-email-kda@linux-powerpc.org>
Cc: linuxppc-dev@ozlabs.org, Denis Kirjanov <kda@linux-powerpc.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Philippe Bergheaud <felix@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:53694 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907AbaKQUfo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 15:35:44 -0500
Received: by mail-lb0-f178.google.com with SMTP id f15so18584546lbj.9
        for <netdev@vger.kernel.org>; Mon, 17 Nov 2014 12:35:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reduce duplicated code by unifying
BPF_ALU | BPF_MOD | BPF_X and BPF_ALU | BPF_DIV | BPF_X

CC: Alexei Starovoitov<alexei.starovoitov@gmail.com>
CC: Daniel Borkmann<dborkman@redhat.com>
CC: Philippe Bergheaud<felix@linux.vnet.ibm.com>
Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
---
 arch/powerpc/net/bpf_jit_comp.c | 27 ++++++++-------------------
 1 file changed, 8 insertions(+), 19 deletions(-)

diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index d3fa80d..1ca125b 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -181,6 +181,7 @@ static int bpf_jit_build_body(struct bpf_prog *fp, u32 *image,
 			}
 			break;
 		case BPF_ALU | BPF_MOD | BPF_X: /* A %= X; */
+		case BPF_ALU | BPF_DIV | BPF_X: /* A /= X; */
 			ctx->seen |= SEEN_XREG;
 			PPC_CMPWI(r_X, 0);
 			if (ctx->pc_ret0 != -1) {
@@ -190,9 +191,13 @@ static int bpf_jit_build_body(struct bpf_prog *fp, u32 *image,
 				PPC_LI(r_ret, 0);
 				PPC_JMP(exit_addr);
 			}
-			PPC_DIVWU(r_scratch1, r_A, r_X);
-			PPC_MUL(r_scratch1, r_X, r_scratch1);
-			PPC_SUB(r_A, r_A, r_scratch1);
+			if (code == (BPF_ALU | BPF_MOD | BPF_X)) {
+				PPC_DIVWU(r_scratch1, r_A, r_X);
+				PPC_MUL(r_scratch1, r_X, r_scratch1);
+				PPC_SUB(r_A, r_A, r_scratch1);
+			} else {
+				PPC_DIVWU(r_A, r_A, r_X);
+			}
 			break;
 		case BPF_ALU | BPF_MOD | BPF_K: /* A %= K; */
 			PPC_LI32(r_scratch2, K);
@@ -200,22 +205,6 @@ static int bpf_jit_build_body(struct bpf_prog *fp, u32 *image,
 			PPC_MUL(r_scratch1, r_scratch2, r_scratch1);
 			PPC_SUB(r_A, r_A, r_scratch1);
 			break;
-		case BPF_ALU | BPF_DIV | BPF_X: /* A /= X; */
-			ctx->seen |= SEEN_XREG;
-			PPC_CMPWI(r_X, 0);
-			if (ctx->pc_ret0 != -1) {
-				PPC_BCC(COND_EQ, addrs[ctx->pc_ret0]);
-			} else {
-				/*
-				 * Exit, returning 0; first pass hits here
-				 * (longer worst-case code size).
-				 */
-				PPC_BCC_SHORT(COND_NE, (ctx->idx*4)+12);
-				PPC_LI(r_ret, 0);
-				PPC_JMP(exit_addr);
-			}
-			PPC_DIVWU(r_A, r_A, r_X);
-			break;
 		case BPF_ALU | BPF_DIV | BPF_K: /* A /= K */
 			if (K == 1)
 				break;
-- 
2.1.0
