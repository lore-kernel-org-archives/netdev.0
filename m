From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 5/9] bpf, s390x: implement jiting of BPF_J{LT,LE,SLT,SLE}
Date: Wed,  9 Aug 2017 12:23:57 +0200
Message-ID: <7244c8a06f99b80525328620ff0539c7ef5cc6d1.1502272924.git.daniel@iogearbox.net>
References: <cover.1502272924.git.daniel@iogearbox.net>
Cc: ast@fb.com, holzheu@linux.vnet.ibm.com,
        naveen.n.rao@linux.vnet.ibm.com, jakub.kicinski@netronome.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58233 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752267AbdHIKYU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 06:24:20 -0400
In-Reply-To: <cover.1502272924.git.daniel@iogearbox.net>
In-Reply-To: <cover.1502272924.git.daniel@iogearbox.net>
References: <cover.1502272924.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This work implements jiting of BPF_J{LT,LE,SLT,SLE} instructions
with BPF_X/BPF_K variants for the s390x eBPF JIT.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
---
 arch/s390/net/bpf_jit_comp.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index 01c6fbc..b5228ca 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -1093,15 +1093,27 @@ static noinline int bpf_jit_insn(struct bpf_jit *jit, struct bpf_prog *fp, int i
 	case BPF_JMP | BPF_JSGT | BPF_K: /* ((s64) dst > (s64) imm) */
 		mask = 0x2000; /* jh */
 		goto branch_ks;
+	case BPF_JMP | BPF_JSLT | BPF_K: /* ((s64) dst < (s64) imm) */
+		mask = 0x4000; /* jl */
+		goto branch_ks;
 	case BPF_JMP | BPF_JSGE | BPF_K: /* ((s64) dst >= (s64) imm) */
 		mask = 0xa000; /* jhe */
 		goto branch_ks;
+	case BPF_JMP | BPF_JSLE | BPF_K: /* ((s64) dst <= (s64) imm) */
+		mask = 0xc000; /* jle */
+		goto branch_ks;
 	case BPF_JMP | BPF_JGT | BPF_K: /* (dst_reg > imm) */
 		mask = 0x2000; /* jh */
 		goto branch_ku;
+	case BPF_JMP | BPF_JLT | BPF_K: /* (dst_reg < imm) */
+		mask = 0x4000; /* jl */
+		goto branch_ku;
 	case BPF_JMP | BPF_JGE | BPF_K: /* (dst_reg >= imm) */
 		mask = 0xa000; /* jhe */
 		goto branch_ku;
+	case BPF_JMP | BPF_JLE | BPF_K: /* (dst_reg <= imm) */
+		mask = 0xc000; /* jle */
+		goto branch_ku;
 	case BPF_JMP | BPF_JNE | BPF_K: /* (dst_reg != imm) */
 		mask = 0x7000; /* jne */
 		goto branch_ku;
@@ -1119,15 +1131,27 @@ static noinline int bpf_jit_insn(struct bpf_jit *jit, struct bpf_prog *fp, int i
 	case BPF_JMP | BPF_JSGT | BPF_X: /* ((s64) dst > (s64) src) */
 		mask = 0x2000; /* jh */
 		goto branch_xs;
+	case BPF_JMP | BPF_JSLT | BPF_X: /* ((s64) dst < (s64) src) */
+		mask = 0x4000; /* jl */
+		goto branch_xs;
 	case BPF_JMP | BPF_JSGE | BPF_X: /* ((s64) dst >= (s64) src) */
 		mask = 0xa000; /* jhe */
 		goto branch_xs;
+	case BPF_JMP | BPF_JSLE | BPF_X: /* ((s64) dst <= (s64) src) */
+		mask = 0xc000; /* jle */
+		goto branch_xs;
 	case BPF_JMP | BPF_JGT | BPF_X: /* (dst > src) */
 		mask = 0x2000; /* jh */
 		goto branch_xu;
+	case BPF_JMP | BPF_JLT | BPF_X: /* (dst < src) */
+		mask = 0x4000; /* jl */
+		goto branch_xu;
 	case BPF_JMP | BPF_JGE | BPF_X: /* (dst >= src) */
 		mask = 0xa000; /* jhe */
 		goto branch_xu;
+	case BPF_JMP | BPF_JLE | BPF_X: /* (dst <= src) */
+		mask = 0xc000; /* jle */
+		goto branch_xu;
 	case BPF_JMP | BPF_JNE | BPF_X: /* (dst != src) */
 		mask = 0x7000; /* jne */
 		goto branch_xu;
-- 
1.9.3
