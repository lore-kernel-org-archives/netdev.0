From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 4/8] PPC: bpf_jit_comp: add JMP instructions for BPF JIT
Date: Mon, 31 Dec 2012 14:59:44 +0100
Message-ID: <a1249b4c7ab7ec4a48a3471e7316f8e60585c2b7.1356960070.git.dborkman@redhat.com>
References: <cover.1356960070.git.dborkman@redhat.com>
Cc: netdev@vger.kernel.org, Matt Evans <matt@ozlabs.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10201 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751314Ab2LaOAA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Dec 2012 09:00:00 -0500
In-Reply-To: <cover.1356960070.git.dborkman@redhat.com>
In-Reply-To: <cover.1356960070.git.dborkman@redhat.com>
References: <cover.1356960070.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is a follow-up for patch "net: bpf: add lt,le jump
operations to bpf machine" that implements BPF PowerPC JIT parts
for BPF JMP_LT/JMP_LE operations.

Cc: Matt Evans <matt@ozlabs.org>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 arch/powerpc/net/bpf_jit.h      |  1 +
 arch/powerpc/net/bpf_jit_comp.c | 12 ++++++++++++
 2 files changed, 13 insertions(+)

diff --git a/arch/powerpc/net/bpf_jit.h b/arch/powerpc/net/bpf_jit.h
index 8a5dfaf..f105b3b 100644
--- a/arch/powerpc/net/bpf_jit.h
+++ b/arch/powerpc/net/bpf_jit.h
@@ -221,6 +221,7 @@ static inline bool is_nearbranch(int offset)
 #define COND_EQ		(CR0_EQ | COND_CMP_TRUE)
 #define COND_NE		(CR0_EQ | COND_CMP_FALSE)
 #define COND_LT		(CR0_LT | COND_CMP_TRUE)
+#define COND_LE		(CR0_GT | COND_CMP_FALSE)
 
 #define SEEN_DATAREF 0x10000 /* might call external helpers */
 #define SEEN_XREG    0x20000 /* X reg is used */
diff --git a/arch/powerpc/net/bpf_jit_comp.c b/arch/powerpc/net/bpf_jit_comp.c
index e834f1e..46b4d21 100644
--- a/arch/powerpc/net/bpf_jit_comp.c
+++ b/arch/powerpc/net/bpf_jit_comp.c
@@ -484,6 +484,14 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 		case BPF_S_JMP_JGE_X:
 			true_cond = COND_GE;
 			goto cond_branch;
+		case BPF_S_JMP_JLT_K:
+		case BPF_S_JMP_JLT_X:
+			true_cond = COND_LT;
+			goto cond_branch;
+		case BPF_S_JMP_JLE_K:
+		case BPF_S_JMP_JLE_X:
+			true_cond = COND_LE;
+			goto cond_branch;
 		case BPF_S_JMP_JEQ_K:
 		case BPF_S_JMP_JEQ_X:
 			true_cond = COND_EQ;
@@ -503,6 +511,8 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 			switch (filter[i].code) {
 			case BPF_S_JMP_JGT_X:
 			case BPF_S_JMP_JGE_X:
+			case BPF_S_JMP_JLT_X:
+			case BPF_S_JMP_JLE_X:
 			case BPF_S_JMP_JEQ_X:
 				ctx->seen |= SEEN_XREG;
 				PPC_CMPLW(r_A, r_X);
@@ -514,6 +524,8 @@ static int bpf_jit_build_body(struct sk_filter *fp, u32 *image,
 			case BPF_S_JMP_JEQ_K:
 			case BPF_S_JMP_JGT_K:
 			case BPF_S_JMP_JGE_K:
+			case BPF_S_JMP_JLT_K:
+			case BPF_S_JMP_JLE_K:
 				if (K < 32768)
 					PPC_CMPLWI(r_A, K);
 				else {
-- 
1.7.11.7
