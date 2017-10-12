From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 04/12] nfp: bpf: fix compare instructions
Date: Thu, 12 Oct 2017 10:34:10 -0700
Message-ID: <20171012173418.4029-5-jakub.kicinski@netronome.com>
References: <20171012173418.4029-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:51571 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752744AbdJLRew (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:34:52 -0400
Received: by mail-pf0-f169.google.com with SMTP id n14so5839126pfh.8
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:34:52 -0700 (PDT)
In-Reply-To: <20171012173418.4029-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we have BPF assemebler support in LLVM 6 we can easily
test all compare instructions (LLVM 4 didn't generate most of them
from C).  Fix the compare to immediates and refactor the order
of compare to regs to make sure they both follow the same pattern.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/jit.c | 21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/jit.c b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
index 5ac834e91aed..e970f284c8a4 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/jit.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
@@ -720,7 +720,10 @@ wrp_cmp_reg(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
 	    enum br_mask br_mask, bool swap)
 {
 	const struct bpf_insn *insn = &meta->insn;
-	u8 areg = insn->src_reg * 2, breg = insn->dst_reg * 2;
+	u8 areg, breg;
+
+	areg = insn->dst_reg * 2;
+	breg = insn->src_reg * 2;
 
 	if (insn->off < 0) /* TODO */
 		return -EOPNOTSUPP;
@@ -1129,22 +1132,22 @@ static int jeq_imm(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 
 static int jgt_imm(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
-	return wrp_cmp_imm(nfp_prog, meta, BR_BLO, false);
+	return wrp_cmp_imm(nfp_prog, meta, BR_BLO, true);
 }
 
 static int jge_imm(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
-	return wrp_cmp_imm(nfp_prog, meta, BR_BHS, true);
+	return wrp_cmp_imm(nfp_prog, meta, BR_BHS, false);
 }
 
 static int jlt_imm(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
-	return wrp_cmp_imm(nfp_prog, meta, BR_BHS, false);
+	return wrp_cmp_imm(nfp_prog, meta, BR_BLO, false);
 }
 
 static int jle_imm(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
-	return wrp_cmp_imm(nfp_prog, meta, BR_BLO, true);
+	return wrp_cmp_imm(nfp_prog, meta, BR_BHS, true);
 }
 
 static int jset_imm(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
@@ -1227,22 +1230,22 @@ static int jeq_reg(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 
 static int jgt_reg(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
-	return wrp_cmp_reg(nfp_prog, meta, BR_BLO, false);
+	return wrp_cmp_reg(nfp_prog, meta, BR_BLO, true);
 }
 
 static int jge_reg(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
-	return wrp_cmp_reg(nfp_prog, meta, BR_BHS, true);
+	return wrp_cmp_reg(nfp_prog, meta, BR_BHS, false);
 }
 
 static int jlt_reg(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
-	return wrp_cmp_reg(nfp_prog, meta, BR_BHS, false);
+	return wrp_cmp_reg(nfp_prog, meta, BR_BLO, false);
 }
 
 static int jle_reg(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
-	return wrp_cmp_reg(nfp_prog, meta, BR_BLO, true);
+	return wrp_cmp_reg(nfp_prog, meta, BR_BHS, true);
 }
 
 static int jset_reg(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
-- 
2.14.1
