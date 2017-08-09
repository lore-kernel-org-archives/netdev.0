From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 7/9] bpf, nfp: implement jiting of BPF_J{LT,LE}
Date: Wed,  9 Aug 2017 12:23:59 +0200
Message-ID: <561a6dfdef9810a0e08e41f15229e9c0f64c2257.1502272924.git.daniel@iogearbox.net>
References: <cover.1502272924.git.daniel@iogearbox.net>
Cc: ast@fb.com, holzheu@linux.vnet.ibm.com,
        naveen.n.rao@linux.vnet.ibm.com, jakub.kicinski@netronome.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58250 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751974AbdHIKYV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 06:24:21 -0400
In-Reply-To: <cover.1502272924.git.daniel@iogearbox.net>
In-Reply-To: <cover.1502272924.git.daniel@iogearbox.net>
References: <cover.1502272924.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This work implements jiting of BPF_J{LT,LE} instructions with
BPF_X/BPF_K variants for the nfp eBPF JIT. The two BPF_J{SLT,SLE}
instructions have not been added yet given BPF_J{SGT,SGE} are
not supported yet either.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/jit.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/jit.c b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
index 8e57fda..239dfbe 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/jit.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
@@ -1238,6 +1238,16 @@ static int jge_imm(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 	return wrp_cmp_imm(nfp_prog, meta, BR_BHS, true);
 }
 
+static int jlt_imm(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return wrp_cmp_imm(nfp_prog, meta, BR_BHS, false);
+}
+
+static int jle_imm(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return wrp_cmp_imm(nfp_prog, meta, BR_BLO, true);
+}
+
 static int jset_imm(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
 	const struct bpf_insn *insn = &meta->insn;
@@ -1325,6 +1335,16 @@ static int jge_reg(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 	return wrp_cmp_reg(nfp_prog, meta, BR_BHS, true);
 }
 
+static int jlt_reg(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return wrp_cmp_reg(nfp_prog, meta, BR_BHS, false);
+}
+
+static int jle_reg(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return wrp_cmp_reg(nfp_prog, meta, BR_BLO, true);
+}
+
 static int jset_reg(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
 	return wrp_test_reg(nfp_prog, meta, ALU_OP_AND, BR_BNE);
@@ -1383,11 +1403,15 @@ static int goto_out(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 	[BPF_JMP | BPF_JEQ | BPF_K] =	jeq_imm,
 	[BPF_JMP | BPF_JGT | BPF_K] =	jgt_imm,
 	[BPF_JMP | BPF_JGE | BPF_K] =	jge_imm,
+	[BPF_JMP | BPF_JLT | BPF_K] =	jlt_imm,
+	[BPF_JMP | BPF_JLE | BPF_K] =	jle_imm,
 	[BPF_JMP | BPF_JSET | BPF_K] =	jset_imm,
 	[BPF_JMP | BPF_JNE | BPF_K] =	jne_imm,
 	[BPF_JMP | BPF_JEQ | BPF_X] =	jeq_reg,
 	[BPF_JMP | BPF_JGT | BPF_X] =	jgt_reg,
 	[BPF_JMP | BPF_JGE | BPF_X] =	jge_reg,
+	[BPF_JMP | BPF_JLT | BPF_X] =	jlt_reg,
+	[BPF_JMP | BPF_JLE | BPF_X] =	jle_reg,
 	[BPF_JMP | BPF_JSET | BPF_X] =	jset_reg,
 	[BPF_JMP | BPF_JNE | BPF_X] =	jne_reg,
 	[BPF_JMP | BPF_EXIT] =		goto_out,
-- 
1.9.3
