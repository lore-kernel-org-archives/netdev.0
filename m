From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 06/15] nfp: bpf: remove register rename
Date: Sun,  8 Oct 2017 21:04:08 -0700
Message-ID: <20171009040417.22172-7-jakub.kicinski@netronome.com>
References: <20171009040417.22172-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:43947 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751653AbdJIEFw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 00:05:52 -0400
Received: by mail-pf0-f179.google.com with SMTP id d2so9340782pfh.0
        for <netdev@vger.kernel.org>; Sun, 08 Oct 2017 21:05:52 -0700 (PDT)
In-Reply-To: <20171009040417.22172-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the register renumbering optimization.  To implement calling
map and other helpers we need more strict register layout.  We can't
freely reassign register numbers.

This will have the effect of running in 4 context/thread mode, which
should be OK since we are moving towards integrating the BPF closer
with FW app datapath anyway, and the target datapath itself runs in
4 context mode.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/jit.c | 46 ++--------------------------
 1 file changed, 3 insertions(+), 43 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/jit.c b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
index 095cf50e8450..469dc8a055f2 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/jit.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
@@ -1621,38 +1621,6 @@ static void nfp_bpf_opt_reg_init(struct nfp_prog *nfp_prog)
 	}
 }
 
-/* Try to rename registers so that program uses only low ones */
-static int nfp_bpf_opt_reg_rename(struct nfp_prog *nfp_prog)
-{
-	bool reg_used[MAX_BPF_REG] = {};
-	u8 tgt_reg[MAX_BPF_REG] = {};
-	struct nfp_insn_meta *meta;
-	unsigned int i, j;
-
-	list_for_each_entry(meta, &nfp_prog->insns, l) {
-		if (meta->skip)
-			continue;
-
-		reg_used[meta->insn.src_reg] = true;
-		reg_used[meta->insn.dst_reg] = true;
-	}
-
-	for (i = 0, j = 0; i < ARRAY_SIZE(tgt_reg); i++) {
-		if (!reg_used[i])
-			continue;
-
-		tgt_reg[i] = j++;
-	}
-	nfp_prog->num_regs = j;
-
-	list_for_each_entry(meta, &nfp_prog->insns, l) {
-		meta->insn.src_reg = tgt_reg[meta->insn.src_reg];
-		meta->insn.dst_reg = tgt_reg[meta->insn.dst_reg];
-	}
-
-	return 0;
-}
-
 /* Remove masking after load since our load guarantees this is not needed */
 static void nfp_bpf_opt_ld_mask(struct nfp_prog *nfp_prog)
 {
@@ -1729,14 +1697,8 @@ static void nfp_bpf_opt_ld_shift(struct nfp_prog *nfp_prog)
 
 static int nfp_bpf_optimize(struct nfp_prog *nfp_prog)
 {
-	int ret;
-
 	nfp_bpf_opt_reg_init(nfp_prog);
 
-	ret = nfp_bpf_opt_reg_rename(nfp_prog);
-	if (ret)
-		return ret;
-
 	nfp_bpf_opt_ld_mask(nfp_prog);
 	nfp_bpf_opt_ld_shift(nfp_prog);
 
@@ -1783,10 +1745,8 @@ nfp_bpf_jit(struct bpf_prog *filter, void *prog_mem,
 	if (ret)
 		goto out;
 
-	if (nfp_prog->num_regs <= 7)
-		nfp_prog->regs_per_thread = 16;
-	else
-		nfp_prog->regs_per_thread = 32;
+	nfp_prog->num_regs = MAX_BPF_REG;
+	nfp_prog->regs_per_thread = 32;
 
 	nfp_prog->prog = prog_mem;
 	nfp_prog->__prog_alloc_len = prog_sz;
@@ -1799,7 +1759,7 @@ nfp_bpf_jit(struct bpf_prog *filter, void *prog_mem,
 	}
 
 	res->n_instr = nfp_prog->prog_len;
-	res->dense_mode = nfp_prog->num_regs <= 7;
+	res->dense_mode = false;
 out:
 	nfp_prog_free(nfp_prog);
 
-- 
2.14.1
