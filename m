From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFCv2 16/16] nfp: bpf: add offload of TC direct action mode
Date: Fri, 26 Aug 2016 19:06:15 +0100
Message-ID: <1472234775-29453-17-git-send-email-jakub.kicinski@netronome.com>
References: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
        dinan.gunawardena@netronome.com, jiri@resnulli.us,
        john.fastabend@gmail.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:36932 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751643AbcHZSI4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 14:08:56 -0400
Received: by mail-wm0-f45.google.com with SMTP id i5so3358438wmg.0
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 11:08:07 -0700 (PDT)
In-Reply-To: <1472234775-29453-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add offload of TC in direct action mode.  We just need
to provide appropriate checks in the verifier and
a new outro block to translate the exit codes to what
data path expects

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_bpf.h       |  1 +
 drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c   | 66 ++++++++++++++++++++++
 .../net/ethernet/netronome/nfp/nfp_bpf_verifier.c  | 11 +++-
 .../net/ethernet/netronome/nfp/nfp_net_offload.c   |  6 +-
 4 files changed, 82 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_bpf.h b/drivers/net/ethernet/netronome/nfp/nfp_bpf.h
index ccb8c2fa20d5..3fd4cf6fa47b 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_bpf.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_bpf.h
@@ -61,6 +61,7 @@ enum static_regs {
 enum nfp_bpf_action_type {
 	NN_ACT_TC_DROP,
 	NN_ACT_TC_REDIR,
+	NN_ACT_DIRECT,
 };
 
 /* Software register representation, hardware encoding in asm.h */
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c b/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
index e784ed827afe..1bed2ae05da5 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
@@ -321,6 +321,16 @@ __emit_br(struct nfp_prog *nfp_prog, enum br_mask mask, enum br_ev_pip ev_pip,
 	nfp_prog_push(nfp_prog, insn);
 }
 
+static void emit_br_def(struct nfp_prog *nfp_prog, u16 addr, u8 defer)
+{
+	if (defer > 2) {
+		pr_err("BUG: branch defer out of bounds %d\n", defer);
+		nfp_prog->error = -EFAULT;
+		return;
+	}
+	__emit_br(nfp_prog, BR_UNC, BR_EV_PIP_UNCOND, BR_CSS_NONE, addr, defer);
+}
+
 static void
 emit_br(struct nfp_prog *nfp_prog, enum br_mask mask, u16 addr, u8 defer)
 {
@@ -1465,9 +1475,65 @@ static void nfp_outro_tc_legacy(struct nfp_prog *nfp_prog)
 		      SHF_SC_L_SHF, 16);
 }
 
+static void nfp_outro_tc_da(struct nfp_prog *nfp_prog)
+{
+	/* TC direct-action mode:
+	 *   0,1   ok        NOT SUPPORTED[1]
+	 *   2   drop  0x22 -> drop,  count as stat1
+	 *   4,5 nuke  0x02 -> drop
+	 *   7  redir  0x44 -> redir, count as stat2
+	 *   * unspec  0x11 -> pass,  count as stat0
+	 *
+	 * [1] We can't support OK and RECLASSIFY because we can't tell TC
+	 *     the exact decision made.  We are forced to support UNSPEC
+	 *     to handle aborts so that's the only one we handle for passing
+	 *     packets up the stack.
+	 */
+	/* Target for aborts */
+	nfp_prog->tgt_abort = nfp_prog_current_offset(nfp_prog);
+
+	emit_br_def(nfp_prog, nfp_prog->tgt_done, 2);
+
+	emit_alu(nfp_prog, reg_a(0),
+		 reg_none(), ALU_OP_NONE, NFP_BPF_ABI_FLAGS);
+	emit_ld_field(nfp_prog, reg_a(0), 0xc, reg_imm(0x11), SHF_SC_L_SHF, 16);
+
+	/* Target for normal exits */
+	nfp_prog->tgt_out = nfp_prog_current_offset(nfp_prog);
+
+	/* if R0 > 7 jump to abort */
+	emit_alu(nfp_prog, reg_none(), reg_imm(7), ALU_OP_SUB, reg_b(0));
+	emit_br(nfp_prog, BR_BLO, nfp_prog->tgt_abort, 0);
+	emit_alu(nfp_prog, reg_a(0),
+		 reg_none(), ALU_OP_NONE, NFP_BPF_ABI_FLAGS);
+
+	wrp_immed(nfp_prog, reg_b(2), 0x41221211);
+	wrp_immed(nfp_prog, reg_b(3), 0x41001211);
+
+	emit_shf(nfp_prog, reg_a(1),
+		 reg_none(), SHF_OP_NONE, reg_b(0), SHF_SC_L_SHF, 2);
+
+	emit_alu(nfp_prog, reg_none(), reg_a(1), ALU_OP_OR, reg_imm(0));
+	emit_shf(nfp_prog, reg_a(2),
+		 reg_imm(0xf), SHF_OP_AND, reg_b(2), SHF_SC_R_SHF, 0);
+
+	emit_alu(nfp_prog, reg_none(), reg_a(1), ALU_OP_OR, reg_imm(0));
+	emit_shf(nfp_prog, reg_b(2),
+		 reg_imm(0xf), SHF_OP_AND, reg_b(3), SHF_SC_R_SHF, 0);
+
+	emit_br_def(nfp_prog, nfp_prog->tgt_done, 2);
+
+	emit_shf(nfp_prog, reg_b(2),
+		 reg_a(2), SHF_OP_OR, reg_b(2), SHF_SC_L_SHF, 4);
+	emit_ld_field(nfp_prog, reg_a(0), 0xc, reg_b(2), SHF_SC_L_SHF, 16);
+}
+
 static void nfp_outro(struct nfp_prog *nfp_prog)
 {
 	switch (nfp_prog->act) {
+	case NN_ACT_DIRECT:
+		nfp_outro_tc_da(nfp_prog);
+		break;
 	case NN_ACT_TC_DROP:
 	case NN_ACT_TC_REDIR:
 		nfp_outro_tc_legacy(nfp_prog);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_bpf_verifier.c b/drivers/net/ethernet/netronome/nfp/nfp_bpf_verifier.c
index 8b66d98e37eb..b628836896fa 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_bpf_verifier.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_bpf_verifier.c
@@ -85,7 +85,16 @@ nfp_bpf_check_exit(struct nfp_prog *nfp_prog, const struct verifier_env *env)
 		return -EINVAL;
 	}
 
-	if (reg0->imm != 0 && (reg0->imm & ~0U) != ~0U) {
+	if (nfp_prog->act != NN_ACT_DIRECT &&
+	    reg0->imm != 0 && (reg0->imm & ~0U) != ~0U) {
+		pr_info("unsupported exit state: %d, imm: %llx\n",
+			reg0->type, reg0->imm);
+		return -EINVAL;
+	}
+
+	if (nfp_prog->act == NN_ACT_DIRECT && reg0->imm <= TC_ACT_REDIRECT &&
+	    reg0->imm != TC_ACT_SHOT && reg0->imm != TC_ACT_STOLEN &&
+	    reg0->imm != TC_ACT_QUEUED) {
 		pr_info("unsupported exit state: %d, imm: %llx\n",
 			reg0->type, reg0->imm);
 		return -EINVAL;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c b/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
index 6399801c4196..a826fa390d4e 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
@@ -112,8 +112,12 @@ nfp_net_bpf_get_act(struct nfp_net *nn, struct tc_cls_bpf_offload *cls_bpf)
 	LIST_HEAD(actions);
 
 	/* TC direct action */
-	if (cls_bpf->exts_integrated)
+	if (cls_bpf->exts_integrated) {
+		if (tc_no_actions(cls_bpf->exts))
+			return NN_ACT_DIRECT;
+
 		return -ENOTSUPP;
+	}
 
 	/* TC legacy mode */
 	if (!tc_single_action(cls_bpf->exts))
-- 
1.9.1
