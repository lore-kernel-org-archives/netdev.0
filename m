From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 05/15] nfp: bpf: encode all 64bit shifts
Date: Sun,  8 Oct 2017 21:04:07 -0700
Message-ID: <20171009040417.22172-6-jakub.kicinski@netronome.com>
References: <20171009040417.22172-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:57093 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751652AbdJIEFw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 00:05:52 -0400
Received: by mail-pf0-f171.google.com with SMTP id b85so1373229pfj.13
        for <netdev@vger.kernel.org>; Sun, 08 Oct 2017 21:05:51 -0700 (PDT)
In-Reply-To: <20171009040417.22172-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add encodings of all 64bit shift operations.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/jit.c | 48 +++++++++++++++++++++-------
 1 file changed, 36 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/jit.c b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
index 7bcff007075c..095cf50e8450 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/jit.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
@@ -825,12 +825,24 @@ static int sub_imm64(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 static int shl_imm64(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
 	const struct bpf_insn *insn = &meta->insn;
-
-	if (insn->imm != 32)
-		return 1; /* TODO */
-
-	wrp_reg_mov(nfp_prog, insn->dst_reg * 2 + 1, insn->dst_reg * 2);
-	wrp_immed(nfp_prog, reg_both(insn->dst_reg * 2), 0);
+	u8 dst = insn->dst_reg * 2;
+
+	if (insn->imm < 32) {
+		emit_shf(nfp_prog, reg_both(dst + 1),
+			 reg_a(dst + 1), SHF_OP_NONE, reg_b(dst),
+			 SHF_SC_R_DSHF, 32 - insn->imm);
+		emit_shf(nfp_prog, reg_both(dst),
+			 reg_none(), SHF_OP_NONE, reg_b(dst),
+			 SHF_SC_L_SHF, insn->imm);
+	} else if (insn->imm == 32) {
+		wrp_reg_mov(nfp_prog, dst + 1, dst);
+		wrp_immed(nfp_prog, reg_both(dst), 0);
+	} else if (insn->imm > 32) {
+		emit_shf(nfp_prog, reg_both(dst + 1),
+			 reg_none(), SHF_OP_NONE, reg_b(dst),
+			 SHF_SC_L_SHF, insn->imm - 32);
+		wrp_immed(nfp_prog, reg_both(dst), 0);
+	}
 
 	return 0;
 }
@@ -838,12 +850,24 @@ static int shl_imm64(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 static int shr_imm64(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
 	const struct bpf_insn *insn = &meta->insn;
-
-	if (insn->imm != 32)
-		return 1; /* TODO */
-
-	wrp_reg_mov(nfp_prog, insn->dst_reg * 2, insn->dst_reg * 2 + 1);
-	wrp_immed(nfp_prog, reg_both(insn->dst_reg * 2 + 1), 0);
+	u8 dst = insn->dst_reg * 2;
+
+	if (insn->imm < 32) {
+		emit_shf(nfp_prog, reg_both(dst),
+			 reg_a(dst + 1), SHF_OP_NONE, reg_b(dst),
+			 SHF_SC_R_DSHF, insn->imm);
+		emit_shf(nfp_prog, reg_both(dst + 1),
+			 reg_none(), SHF_OP_NONE, reg_b(dst + 1),
+			 SHF_SC_R_SHF, insn->imm);
+	} else if (insn->imm == 32) {
+		wrp_reg_mov(nfp_prog, dst, dst + 1);
+		wrp_immed(nfp_prog, reg_both(dst + 1), 0);
+	} else if (insn->imm > 32) {
+		emit_shf(nfp_prog, reg_both(dst),
+			 reg_none(), SHF_OP_NONE, reg_b(dst + 1),
+			 SHF_SC_R_SHF, insn->imm - 32);
+		wrp_immed(nfp_prog, reg_both(dst + 1), 0);
+	}
 
 	return 0;
 }
-- 
2.14.1
