From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 6/9] bpf, ppc64: implement jiting of BPF_J{LT,LE,SLT,SLE}
Date: Wed,  9 Aug 2017 12:23:58 +0200
Message-ID: <92225f5f0a116d0f9be53645f85b4b8da5400299.1502272924.git.daniel@iogearbox.net>
References: <cover.1502272924.git.daniel@iogearbox.net>
Cc: ast@fb.com, holzheu@linux.vnet.ibm.com,
        naveen.n.rao@linux.vnet.ibm.com, jakub.kicinski@netronome.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58243 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752098AbdHIKYV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 06:24:21 -0400
In-Reply-To: <cover.1502272924.git.daniel@iogearbox.net>
In-Reply-To: <cover.1502272924.git.daniel@iogearbox.net>
References: <cover.1502272924.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This work implements jiting of BPF_J{LT,LE,SLT,SLE} instructions
with BPF_X/BPF_K variants for the ppc64 eBPF JIT.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
Tested-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
---
 arch/powerpc/net/bpf_jit.h        |  1 +
 arch/powerpc/net/bpf_jit_comp64.c | 20 ++++++++++++++++++++
 2 files changed, 21 insertions(+)

diff --git a/arch/powerpc/net/bpf_jit.h b/arch/powerpc/net/bpf_jit.h
index 30cf03f..47fc666 100644
--- a/arch/powerpc/net/bpf_jit.h
+++ b/arch/powerpc/net/bpf_jit.h
@@ -263,6 +263,7 @@ static inline bool is_nearbranch(int offset)
 #define COND_EQ		(CR0_EQ | COND_CMP_TRUE)
 #define COND_NE		(CR0_EQ | COND_CMP_FALSE)
 #define COND_LT		(CR0_LT | COND_CMP_TRUE)
+#define COND_LE		(CR0_GT | COND_CMP_FALSE)
 
 #endif
 
diff --git a/arch/powerpc/net/bpf_jit_comp64.c b/arch/powerpc/net/bpf_jit_comp64.c
index 861c5af..faf2016 100644
--- a/arch/powerpc/net/bpf_jit_comp64.c
+++ b/arch/powerpc/net/bpf_jit_comp64.c
@@ -795,12 +795,24 @@ static int bpf_jit_build_body(struct bpf_prog *fp, u32 *image,
 		case BPF_JMP | BPF_JSGT | BPF_X:
 			true_cond = COND_GT;
 			goto cond_branch;
+		case BPF_JMP | BPF_JLT | BPF_K:
+		case BPF_JMP | BPF_JLT | BPF_X:
+		case BPF_JMP | BPF_JSLT | BPF_K:
+		case BPF_JMP | BPF_JSLT | BPF_X:
+			true_cond = COND_LT;
+			goto cond_branch;
 		case BPF_JMP | BPF_JGE | BPF_K:
 		case BPF_JMP | BPF_JGE | BPF_X:
 		case BPF_JMP | BPF_JSGE | BPF_K:
 		case BPF_JMP | BPF_JSGE | BPF_X:
 			true_cond = COND_GE;
 			goto cond_branch;
+		case BPF_JMP | BPF_JLE | BPF_K:
+		case BPF_JMP | BPF_JLE | BPF_X:
+		case BPF_JMP | BPF_JSLE | BPF_K:
+		case BPF_JMP | BPF_JSLE | BPF_X:
+			true_cond = COND_LE;
+			goto cond_branch;
 		case BPF_JMP | BPF_JEQ | BPF_K:
 		case BPF_JMP | BPF_JEQ | BPF_X:
 			true_cond = COND_EQ;
@@ -817,14 +829,18 @@ static int bpf_jit_build_body(struct bpf_prog *fp, u32 *image,
 cond_branch:
 			switch (code) {
 			case BPF_JMP | BPF_JGT | BPF_X:
+			case BPF_JMP | BPF_JLT | BPF_X:
 			case BPF_JMP | BPF_JGE | BPF_X:
+			case BPF_JMP | BPF_JLE | BPF_X:
 			case BPF_JMP | BPF_JEQ | BPF_X:
 			case BPF_JMP | BPF_JNE | BPF_X:
 				/* unsigned comparison */
 				PPC_CMPLD(dst_reg, src_reg);
 				break;
 			case BPF_JMP | BPF_JSGT | BPF_X:
+			case BPF_JMP | BPF_JSLT | BPF_X:
 			case BPF_JMP | BPF_JSGE | BPF_X:
+			case BPF_JMP | BPF_JSLE | BPF_X:
 				/* signed comparison */
 				PPC_CMPD(dst_reg, src_reg);
 				break;
@@ -834,7 +850,9 @@ static int bpf_jit_build_body(struct bpf_prog *fp, u32 *image,
 			case BPF_JMP | BPF_JNE | BPF_K:
 			case BPF_JMP | BPF_JEQ | BPF_K:
 			case BPF_JMP | BPF_JGT | BPF_K:
+			case BPF_JMP | BPF_JLT | BPF_K:
 			case BPF_JMP | BPF_JGE | BPF_K:
+			case BPF_JMP | BPF_JLE | BPF_K:
 				/*
 				 * Need sign-extended load, so only positive
 				 * values can be used as imm in cmpldi
@@ -849,7 +867,9 @@ static int bpf_jit_build_body(struct bpf_prog *fp, u32 *image,
 				}
 				break;
 			case BPF_JMP | BPF_JSGT | BPF_K:
+			case BPF_JMP | BPF_JSLT | BPF_K:
 			case BPF_JMP | BPF_JSGE | BPF_K:
+			case BPF_JMP | BPF_JSLE | BPF_K:
 				/*
 				 * signed comparison, so any 16-bit value
 				 * can be used in cmpdi
-- 
1.9.3
